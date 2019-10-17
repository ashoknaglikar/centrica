/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AddNewSkill_Test {

    static testMethod void myUnitTest() 
    {   
        boolean[] hoursAffected = new boolean[10];
        List<String> jobList = new List<String>();
        List<Search_Result__c> tempResultOptions = new List<Search_Result__c>();
        List<Search_Result__c> resultOptions = new List<Search_Result__c>();
        List<Job__c> jobs = new List<Job__c>();
        Map<String, Boolean> skillToDoubleHandedMap = new Map<String, Boolean>();
        Map<String, Double> skillsAndHours = new Map<String, Double>();
        Map<String,Integer> qtyMap = new Map<String,Integer>();
        Map<String,String> pwMap = new Map<String,String>();
        Map<String, Boolean> jobBMap = new Map<String, Boolean>();
        pwMap.put('P1313','MECHANICAL:0.15');
        qtyMap.put('P1313',1);      
        
        resultOptions = [Select s.Start_Date_Time__c, s.Skill__c, 
            s.Option_Identifier__c, s.Job_ID__c, s.Id, s.Hours__c,
            s.End_Date_Time__c, s.Diary_Entry_ID__c, Order__c From Search_Result__c s
            limit 10];
            
        for(Search_Result__c searchResult : resultOptions)
        {
                skillToDoubleHandedMap.put(searchResult.Skill__c, true);            
        }
            
        Account Acc = TestScenarioCreateAccount();
        Opportunity opty = TestScenarioCreateOppty(Acc);
                
        BigMachines_Quote__c quote = TestScenarioCreateQuote(opty);  
        Job__c job = TestScenarioCreateJob('Pending','Install Date Required',opty.ID,quote.Id);
        
        jobList.add(job.Id);
        jobs.add(job);
        jobBMap.put(job.Id,true);
        
        //Job__c job = TestScenarioCreateJob('Planned','Planned',opty.ID,quote.Id);
                
        Job_Element__c[] jobelementlisttoinsert = TestScenarioCreateJobElement(job);
        Job_Element__c[] jobelementlisttoremove = TestScenarioCreateJobElementToRemove(job);
        
        AddNewSkill obj = new AddNewSkill();
        
        obj.setJobHours(jobs, pwMap, jobBMap, qtyMap);
        obj.setSkillHoursInfo(job, skillsAndHours);
        obj.setNewSkillHours(job, quote, jobelementlisttoinsert, jobelementlisttoremove, hoursAffected);        
        obj.fetchJobByCHILead(quote);
        obj.fetchQuoteByQuote(quote.Id);
        obj.fetchJobByQuote(quote.Id, true);
        obj.fetchJobByQuote(quote.Id, false);
        obj.fetchJobByJob(job.Id);
        obj.fetchJobforSharing(quote.Id);
        obj.fetchJobforTransferringHours(job.Id);
        obj.reduceSkillValues(job, 'Mechanical', 1);
        obj.reduceSkillValues(job, 'Building Work', 1);
        obj.reduceSkillValues(job, 'Unvented_Hot_Water', 1);
        obj.reduceSkillValues(job, 'Specialist_Building_Work', 1);
        obj.reduceSkillValues(job, 'Scaffolder', 1);
        obj.reduceSkillValues(job, 'Roof_Work', 1);
        obj.reduceSkillValues(job, 'Powerflush', 1);
        obj.reduceSkillValues(job, 'Payment_Collection', 1);
        obj.reduceSkillValues(job, 'LPG_Installation', 1);
        obj.reduceSkillValues(job, 'Fire/Wall_Heater_Fixing', 1);
        obj.reduceSkillValues(job, 'Electrical_Work_ASP', 1);
        obj.reduceSkillValues(job, 'Electrical', 1);
        obj.reduceSkillValues(job, 'Contractor_Installation', 1);
        obj.reduceSkillValues(job, 'Connect_Solar_Panels', 1);
        obj.reduceSkillValues(job, 'Asbestos_Removal', 1);
        obj.reduceSkillValues(job, 'Asbestos_Removal-Fixed_Rate', 1);
        obj.reduceSkillValues(job, 'Water_Heater_Fixing', 1);
        obj.reduceSkillValues(job, 'Ecogen Electrical', 1);
        obj.reduceSkillValues(job, 'Ecogen Mechanical', 1);
        obj.reduceSkillValues(job, 'ECO', 1);
        obj.reduceSkillValues(job, 'Landlord Check', 1);
        obj.reduceSkillValues(job, 'Remote Heating', 1);
        obj.setJobHoursFromQuote(job, quote); 
        obj.orderResultOptions(resultOptions, skillToDoubleHandedMap, tempResultOptions);
        obj.matchSkillHours(quote, job);
        obj.fetchJobByJobId(job.Id);      
        obj.fetchJobList(jobList);  
        obj.setSkillMap();
    }
    
    private static Account TestScenarioCreateAccount(){
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=district.Id, Code__c='yyyyyyyy');                
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='XXX X', Sub_Patch__c=subPatch.Id, Code__c='yyyyyyyy');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account quote decompile', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');                       
        insert Acc;        
        return Acc;
    }
    
    private static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
    }
    
    private static BigMachines_Quote__c TestScenarioCreateQuote(Opportunity opty)
    {                
        BigMachines_Quote__c quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2);                           
        insert quote;              
        return quote;    
    }
    
    private static Job__c TestScenarioCreateJob(string status, string substatus, ID optyId, ID quoteId){
        
        Job__c job = new Job__c(Quote__c=quoteId, Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID, Water_Heating_Fixing_Hours__c=1,Unvented_Hot_Water_Hours__c=1,Specialist_Building_Hours__c=1,Scaffolder_Hours__c=1,Roof_Work_Hours__c=1,Payment_Collection_Hours__c=1,Mechanical_Hours__c=1,LPG_Installation_Hours__c=1,Fire_Wall_Heater_Fixing_Hours__c=1,Electrical_Hours__c=1,Contractor_Installation_Hours__c=1,Connect_Solar_Panel_Hours__c=1,Building_Work_Hours__c=1,PowerFlush_Hours__c=1,Electrical_Work_ASP_Hours__c=1,Asbestos_Removal_Hours__c=1,Asbestos_Removal_Fixed_Rate_Hours__c=1,Solar_Hours__c=1,Ecogen_Electrical_Hours__c=1,Ecogen_Mechanical_Hours__c=1 , ECO_Hours__c=1, Landlord_Check_Hours__c=1,Remote_Heating__c=1,Pre_Electrical_Hours__c=1);              
        insert job;      
        return job;
    }

    private static Job_Element__c[] TestScenarioCreateJobElement(Job__c job){
        
        Job_Element__c JE1 = new Job_Element__c (Skill__c = 'Electrical', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);                                                            
        Job_Element__c JE2 = new Job_Element__c (Skill__c = 'MECHANICAL', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE3 = new Job_Element__c (Skill__c = 'WATER HEATER FIXING', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);                                                            
        Job_Element__c JE4 = new Job_Element__c (Skill__c = 'SPECIALIST BUILDING', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE5 = new Job_Element__c (Skill__c = 'SCAFFOLDER', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);                                                            
        Job_Element__c JE6 = new Job_Element__c (Skill__c = 'ROOF WORK', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE7 = new Job_Element__c (Skill__c = 'PAYMENT COLLECTION', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);                                                            
        Job_Element__c JE8 = new Job_Element__c (Skill__c = 'LPG INSTALLATION', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE9 = new Job_Element__c (Skill__c = 'FIREWALL HEATER FIXING', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);                                                            
        Job_Element__c JE10 = new Job_Element__c (Skill__c = 'CONTRACTOR INSTALLATION', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE11 = new Job_Element__c (Skill__c = 'CONNECT SOLAR PANELS', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);                                                            
        Job_Element__c JE12 = new Job_Element__c (Skill__c = 'BUILDING WORK', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE13 = new Job_Element__c (Skill__c = 'POWERFLUSH', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE14 = new Job_Element__c (Skill__c = 'ELECTRICAL WORK ASP', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE15 = new Job_Element__c (Skill__c = 'ASBESTOS REMOVAL', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE16 = new Job_Element__c (Skill__c = 'ASBESTOS REMOVAL FIXED RATE', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE17 = new Job_Element__c (Skill__c = 'SOLAR', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE18 = new Job_Element__c (Skill__c = 'ECOGEN MECHANICAL', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE19 = new Job_Element__c (Skill__c = 'ECOGEN ELECTRICAL', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE20 = new Job_Element__c (Skill__c = 'ECO', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE21 = new Job_Element__c (Skill__c = 'LANDLORD CHECK', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
                                           
        Job_Element__c[] jobelementlist = new Job_Element__c[]{JE1, JE2, JE3, JE4, JE5, JE6, JE7, JE8, JE9, JE10, JE11, JE12, JE13, JE14, JE15, JE16, JE17, JE18, JE19 , JE20, JE21};
        insert jobelementlist;
        return jobelementlist;                                                     
    
    }
    
    private static Job_Element__c[] TestScenarioCreateJobElementToRemove(Job__c job){
        
        Job_Element__c JE1 = new Job_Element__c (Skill__c = 'Electrical', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);                                                            
        Job_Element__c JE2 = new Job_Element__c (Skill__c = 'MECHANICAL', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE3 = new Job_Element__c (Skill__c = 'WATER HEATER FIXING', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);                                                            
        Job_Element__c JE4 = new Job_Element__c (Skill__c = 'SPECIALIST BUILDING', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE5 = new Job_Element__c (Skill__c = 'SCAFFOLDER', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);                                                            
        Job_Element__c JE6 = new Job_Element__c (Skill__c = 'ROOF WORK', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE7 = new Job_Element__c (Skill__c = 'PAYMENT COLLECTION', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);                                                            
        Job_Element__c JE8 = new Job_Element__c (Skill__c = 'LPG INSTALLATION', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE9 = new Job_Element__c (Skill__c = 'FIREWALL HEATER FIXING', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);                                                            
        Job_Element__c JE10 = new Job_Element__c (Skill__c = 'CONTRACTOR INSTALLATION', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE11 = new Job_Element__c (Skill__c = 'CONNECT SOLAR PANELS', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);                                                            
        Job_Element__c JE12 = new Job_Element__c (Skill__c = 'BUILDING WORK', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE13 = new Job_Element__c (Skill__c = 'POWERFLUSH', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE14 = new Job_Element__c (Skill__c = 'ELECTRICAL WORK ASP', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE15 = new Job_Element__c (Skill__c = 'ASBESTOS REMOVAL', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE16 = new Job_Element__c (Skill__c = 'ASBESTOS REMOVAL FIXED RATE', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE17 = new Job_Element__c (Skill__c = 'SOLAR', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE18 = new Job_Element__c (Skill__c = 'ECOGEN MECHANICAL', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE19 = new Job_Element__c (Skill__c = 'ECOGEN ELECTRICAL', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3);
        Job_Element__c JE20 = new Job_Element__c (Skill__c = 'ECO', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
        Job_Element__c JE21 = new Job_Element__c (Skill__c = 'LANDLORD CHECK', Code__c = '1260', Type__c = 'Work', Status__c = 'Active', Description__c = 'Description', Job__c = job.Id, Units__c = 3.70);
                                           
        Job_Element__c[] jobelementlist = new Job_Element__c[]{JE1, JE2, JE3, JE4, JE5, JE6, JE7, JE8, JE9, JE10, JE11, JE12, JE13, JE14, JE15, JE16, JE17, JE18, JE19 , JE20, JE21};
        insert jobelementlist;
        return jobelementlist;                                                     
    
    }
    
    
    static testMethod void myUnitTest2() 
    {   
        boolean[] hoursAffected = new boolean[10];
        List<String> jobList = new List<String>();
            
        Account Acc = TestScenarioCreateAccount();
        Opportunity opty = TestScenarioCreateOppty(Acc);
        BigMachines_Quote__c quote = TestScenarioCreateQuote1(opty);  
        Job__c job = TestScenarioCreateJob('Pending','Install Date Required',opty.ID,quote.Id);
        //Job__c job1 = TestScenarioCreateJob1('Pending','Install Date Required',opty.ID,quote.Id);
        
        Job__c job1 = new job__c(id=job.id);
        Map<id,Job__c> oldJob = new Map<id,Job__c>();
        Map<id,Job__c> newJob = new Map<id,Job__c>();
        map<string,Double> skillmap = new map<string,Double>();
        skillmap.put('BUILDING WORK',21.0);
        oldJob.put(job.id,job);
        newJob.put(job.id,job1);
                
        Job_Element__c[] jobelementlisttoinsert = TestScenarioCreateJobElement(job);
        Job_Element__c[] jobelementlisttoremove = TestScenarioCreateJobElementToRemove(job);        
        
        AddNewSkill obj = new AddNewSkill();
        obj.setJobSkillHistory(oldJob,newJob);
        obj.setSimpleSkills(job);
        obj.setNewSkillHours(job1, quote, jobelementlisttoinsert, jobelementlisttoremove, hoursAffected);
        try{
        obj.validateJobSkillHoursHSA(skillmap);
        }catch(Exception e)
        {}
        
    }
    
    private static Job__c TestScenarioCreateJob1(string status, string substatus, ID optyId, ID quoteId){
        
        //Job__c job = new Job__c(Quote__c=quoteId, Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID, Water_Heating_Fixing_Hours__c=2,Unvented_Hot_Water_Hours__c=2,Specialist_Building_Hours__c=2,Scaffolder_Hours__c=2,Roof_Work_Hours__c=2,Payment_Collection_Hours__c=3,Mechanical_Hours__c=2,LPG_Installation_Hours__c=2,Fire_Wall_Heater_Fixing_Hours__c=2,Electrical_Hours__c=2,Contractor_Installation_Hours__c=2,Connect_Solar_Panel_Hours__c=2,Building_Work_Hours__c=2,PowerFlush_Hours__c=2,Electrical_Work_ASP_Hours__c=2,Asbestos_Removal_Hours__c=2,Asbestos_Removal_Fixed_Rate_Hours__c=2,Solar_Hours__c=2,Ecogen_Electrical_Hours__c=2,Ecogen_Mechanical_Hours__c=2 , ECO_Hours__c=2, Landlord_Check_Hours__c=2);
        Job__c job = new Job__c(Quote__c=quoteId, Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID); 
        insert job;      
        return job;
    }
    
    private static BigMachines_Quote__c TestScenarioCreateQuote1(Opportunity opty)
    {                
        BigMachines_Quote__c quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opty.id, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2, skillTotalWaterHeatingFixing__c=2,skillTotalUnventedHotWater__c=2,skillTotalSpecialistBuilding__c=2,skillTotalScaffolder__c=2,skillTotalRoofWork__c=2,skillTotalPaymentCollection__c=3,skillTotalMechanical__c=2,skillTotalLPGInstallation__c=2,skillTotalFireWallHeaterFixing__c=2,skillTotalElectrical__c=2,skillTotalContractorInstallation__c=2,skillTotalConnectSolarPanels__c=2,skillTotalBuildingWork__c=2,skillTotalPowerFlush__c=2,skillTotalAsbestosRemoval__c=2,skillTotalAsbestosRemovalFixedRate__c=2,skillTotalSolar__c=2,skillTotal_ecogenElectrical__c=2,skillTotal_ecogenMechanical__c=2 ,Remote_Heating__c=2, skillTotalECO__c=2, Landlord_Check__c=2);                           
        insert quote;              
        return quote;    
    }
    
    static testMethod void myUnitTest3() 
    {   
        List<Job__c> jobs = new List<Job__c>();
        Map<String,Integer> qtyMap = new Map<String,Integer>();
        Map<String,String> pwMap = new Map<String,String>();
        Map<String, Boolean> jobBMap = new Map<String, Boolean>();
        pwMap.put('P1313','Mechanical:0.15/Ecogen Mechanical:0.0/Ecogen Electrical:0.0/Water Heater Fixing:0.0/Building Work:0.0/Connect Solar:0.0/Contractor Installation:0.0/Electrical:0.0/FIRE:0.0/LPG:0.0/Payment Collection:0.0/Roof Work:0.0/Specialist Building:0.0/Unvented:0.0/POWERFLUSH:0.0/INSTALL SOLAR:0.0/Remote Heating:0.0/ECO:0.0/Landlord Check:0.0');
        qtyMap.put('P1313',1); 
            
        Account Acc = TestScenarioCreateAccount();
        Opportunity opty = TestScenarioCreateOppty(Acc);
        BigMachines_Quote__c quote = TestScenarioCreateQuote(opty);  
        Job__c job = TestScenarioCreateJob('Pending','Install Date Required',opty.ID,quote.Id);
        
        jobs.add(job);
        jobBMap.put(job.Id,true);
        AddNewSkill obj = new AddNewSkill();
        obj.setJobHours(jobs, pwMap, jobBMap, qtyMap);
        
    }
    
}