/*
    *   This class is responsible for the following jobs - 
    *   1. Inserting Apex managed Sharing for the installers on a job for the Job Completion documents and 
    *       Payment Collection made against a given job
    *   2. Re-Doing all the Apex sharing rules for any chnages made to the installers of a job.
    *       a. Re-planning a job
    *       b. Transferring Work to other available installers on a job     
*/
global with sharing class JobSharingCls {
     // Method to be called evrytime configuration around the Installers for a job changes and the 
     // sharing rules governing teh document and payment collection access needs to be recalculated
     webservice static String createJobSharing(List<String> jobIds){
        // Variable to store the sucess and error status
        String result = '';
        // Checking if the variable needs to procees exists
        if(jobIds.size() ==0){
            result = null;
        }else{
            // Declaring variables
            // To Store Unique Installers
            Set<String> uniqueUsers = new Set<String>();
            // To Store Job Document Ids
            List<String> docIds  = new List<String>();
            // To Store Payment Collection Ids 
            List<String> payIds  = new List<String>();
            // To Store Commisionaing report share to re/Calculate
            List<Commissioning_Report__Share> commShareList = new List<Commissioning_Report__Share>();
            // To Store Payment Collection share to Re/calculate
            List<Payment_Collection__Share> paymentShareList = new List<Payment_Collection__Share>();
            
            //AGENCY CHANGE: START 08/07/2010
            // To Store Job share to Re/calculate
            List<Installer__c> uniqueInstallerList = new List<Installer__c>();
            List<Job__Share> jobShareList = new List<Job__Share >();
            
            Map<String,Employee__c> userEmployeeMap = new Map<String,Employee__c>();
            Map<String,String> employeeAgencyNameMap = new Map<String,String>();
            Map<String,Group> agencyNameGroupMap = new Map<String,Group>();
            Map<String,String> userIdProfileIdMap = new Map<String,String>();
            Map<String,String> profileIdProfileNameMap = new Map<String,String>();
            
            
            String sContractorProfileId = null;
            String sAgencyContractorProfileId = null;
            String sAgencyOfficeUserProfileId = null;
            //AGENCY CHANGE: END 08/07/2010
            
            System.debug('££££ STEP 000: Total Number of records that can be queried  in this apex code context:getLimitDmlRows= ' +  Limits.getLimitDmlRows());
            
            // Retrieves Job Completion documents, Installers and Payemnt collection against a job  
            //AGENCY CHANGE: START 08/07/2010       
            //Added User__r.ProfileId field in the existing query.
            List<Job__c> thisJob = [Select (Select Id From Payment_Collections__r),(Select Id, User__c,User__r.ProfileId, Installer_Status__c From User_Jobs__r), (Select Id From Job_Completion_Documents__r) From Job__c j where id in:jobIds];
            
            for(Profile profile :[Select p.Name, p.Id From Profile p where p.name='CHI CONTRACTOR' or p.name = 'CHI AGENCY OFFICE USER' or p.name = 'CHI AGENCY CONTRACTOR'])
            {
                if(profile.Name.toUpperCase() == 'CHI CONTRACTOR'){
                    sContractorProfileId = profile.Id; 
                }
                if(profile.Name.toUpperCase() == 'CHI AGENCY CONTRACTOR'){
                    sAgencyContractorProfileId = profile.Id;
                }
                if(profile.Name.toUpperCase() == 'CHI AGENCY OFFICE USER'){
                    sAgencyOfficeUserProfileId = profile.Id;
                }
            }
            
            System.debug('££££ STEP 1: sContractorProfileId= '+sContractorProfileId);
            System.debug('££££ STEP 1: sAgencyContractorProfileId= '+sAgencyContractorProfileId);
            System.debug('££££ STEP 1: sAgencyOfficeUserProfileId= '+sAgencyOfficeUserProfileId);
            
            //AGENCY CHANGE: END 08/07/2010
            
            // Iterating through the Installers against the job
            for(Job__c job : thisJob){
                List<Installer__c> installers=job.User_Jobs__r;
                for(Installer__c installer : installers) {
                    //CHANGE: THIS CONDITION IN BRACKET IS ADDED ACCORDING TO THE PHASE 5 DESIGN. 24/08/2010.
                    if(installer.User__c != null && (installer.Installer_Status__c == null || installer.Installer_Status__c == 'Active')){
                        uniqueUsers.add(installer.User__c);
                        //installerUserMap.put(installer.Id,installer.User__c);
                    }
                }
            }  
            
            System.debug('££££ STEP 2: uniqueUsers= '+uniqueUsers);
            
            for(User u : [Select u.Profile.Name,u.Profile.Id, u.ProfileId, u.Name, u.Id From User u where u.Id in : uniqueUsers])
            {
                userIdProfileIdMap.put(u.id,u.Profile.Id);
                profileIdProfileNameMap.put(u.Profile.Id,u.Profile.Name);
            }
             
                        
            //AGENCY CHANGE: START 08/07/2010
            
            for(Employee__c emp : [Select e.Salesforce_User__c,e.Is_Agency_Contractor__c,e.Agency__c, e.Agency__r.Name From Employee__c e where e.Salesforce_User__c in : uniqueUsers])
            {
                userEmployeeMap.put(emp.Salesforce_User__c,emp);
                employeeAgencyNameMap.put(emp.id,emp.Agency__r.Name);
            }
            
            System.debug('££££ STEP 3: userEmployeeMap= '+userEmployeeMap);
            System.debug('££££ STEP 4: employeeAgencyNameMap= '+employeeAgencyNameMap);
            
            for(Group g : [Select g.Name, g.Id From Group g where g.name in : employeeAgencyNameMap.values()])
            {
                agencyNameGroupMap.put(g.name, g);
            }
            
            System.debug('££££ STEP 5: agencyNameGroupMap= '+agencyNameGroupMap);
            
            //Preparing a list of unique installers 
            /*Integer iFlagForInstaller;
            for(Job__c job : thisJob){
                List<Installer__c> installers = job.User_Jobs__r;
                for(Installer__c installer : installers) {
                    iFlagForInstaller = 1;
                    for(Installer__c i : uniqueInstallerList){
                        if(i.Id == installer.Id){
                            iFlagForInstaller = 2;
                            break;
                        }
                    }
                    if(iFlagForInstaller != 2){
                        uniqueInstallerList.add(installer);
                    }
                }
            }
            
            System.debug('££££ STEP 6: uniqueInstallerList= '+uniqueInstallerList);*/
                        
            //AGENCY CHANGE: END 08/07/2010
            
            // Iterating through the JOb completion documents against the job
            for(Job__c job : thisJob){
                List<Commissioning_Report__c> reports=job.Job_Completion_Documents__r;
                for(Commissioning_Report__c docs : reports) {
                    docIds.add(docs.id);
                }
            }
            // Iterating through the Payment collection against the job
            for(Job__c job : thisJob){
                List<Payment_Collection__c> payments=job.Payment_Collections__r;
                for(Payment_Collection__c payment: payments) {
                    payIds.add(payment.id);
                }
            }
            
            //AGENCY CHANGE: START 08/07/2010
            // Retrieving existing Job sharing rules
            jobShareList = [Select  c.ParentId,c.Id From Job__Share c where c.ParentId in :thisJob AND (c.rowCause != 'Owner' AND c.rowCause != 'Rule')];            
            
            System.debug('££££ STEP 7: jobShareList to be deleted = '+jobShareList);
            System.debug('££££ STEP 7.1: jobShareList to be deleted = '+jobShareList.size());
            
            // Delete Existing sharing rules to recalculate
            if(jobShareList.size() > 0){
                try{
                    delete jobShareList;
                }catch(DMLException e){
                    result = 'EXCEPTION MESSAGE : '+e.getMessage();
                    System.debug('-- EXCEPTION IN  DELETING MANUAL SHARING FOR JOB -- '+e.getMessage());
                }   
            } 
            //AGENCY CHANGE: END 08/07/2010
            
                       
            // Retrieving existing Job completion sharing rules
            commShareList = [Select  c.ParentId,c.Id From Commissioning_Report__Share c where c.ParentId in :docIds AND (c.rowCause != 'Owner' AND c.rowCause != 'Rule')];
            // Retrieving existing Payment Collection sharing rules
            paymentShareList = [Select  c.ParentId,c.Id From Payment_Collection__Share c where c.ParentId in :payIds AND (c.rowCause != 'Owner' AND c.rowCause != 'Rule')];
            
            System.debug('££££ STEP 8: commShareList to be deleted = '+commShareList);
            System.debug('££££ STEP 8.1: commShareList to be deleted size= '+commShareList.size());
            
            System.debug('££££ STEP 9: paymentShareList to be deleted = '+paymentShareList);
            System.debug('££££ STEP 9.1: paymentShareList to be deleted size= '+paymentShareList.size());
            
            // Delete Existing sharing rules to recalculate
            if(commShareList.size() > 0){
                try{
                    delete commShareList;
                }catch(DMLException e){
                    result = 'EXCEPTION MESSAGE : '+e.getMessage();
                    System.debug('-- EXCEPTION IN  DELETING SHARING FOR JOB COMPLETION DOCUMENT -- '+e.getMessage());
                }   
            }
            if(paymentShareList.size() > 0){
                try{
                    delete paymentShareList;
                }catch(DMLException e){
                    result = 'EXCEPTION MESSAGE : '+e.getMessage();
                    System.debug('-- EXCEPTION IN  DELETING SHARING FOR PAYMENET COLLECTION-- '+e.getMessage());
                }   
            }
            
            System.debug('££££ STEP 111 :Number of rows queried so far(Till deletion of sharing): getDmlRows= ' + Limits.getDmlRows());
            // Nullify the List varibales to reuse them for storing new rules to be added
            jobShareList = new List<Job__Share>();
            commShareList = new List<Commissioning_Report__Share>();
            paymentShareList = new List<Payment_Collection__Share>();
            
            Integer Flag;
            if(uniqueUsers.size() > 0){
                // Iterating through the completion documents and Payment collection for adding sharing rules 
                // on a per installer basis     
                System.debug('££££ STEP 10: inside sharing if');               
                
                for(Job__c job : thisJob)
                {
                    List<Commissioning_Report__c> docs = job.Job_Completion_Documents__r;
                    List<Payment_Collection__c> payments = job.Payment_Collections__r;
                    
                    System.debug('££££ STEP 10.1: inside job sharing creation: docs = '+docs);
                    System.debug('££££ STEP 10.2: inside job sharing creation: payments = '+payments);
                    
                    for(String uniqueUser : uniqueUsers)
                    {
                        String userProfileId = userIdProfileIdMap.get(uniqueUser);
                        System.debug('££££ STEP 10.3: inside job sharing uniqueUser loop: userProfileId = '+userProfileId);
                        
                        //Adding installers on job sharing
                        Flag = 1;
                        //IDENTIFYING IF THE CURRENT INSTALLER IS CONTRACTOR. 
                        if(userProfileId == sContractorProfileId)
                        {
                                System.debug('££££ STEP 10.3.1: inside sContractorProfileId = '+sContractorProfileId);
                                //SETTING FLAG VALUE TO INDICATE THIRD PARTY CONTRACTORS.
                                Flag = 2;
                                
                                //SHARING JOB TO THE CONTRACTOR.
                                jobShareList.add(new Job__Share(UserOrGroupId = uniqueUser, 
                                                RowCause = 'Manual',ParentId = job.id, AccessLevel = 'Read'));
                                
                                //SHARING JOB COMPLETION DOCUMENTS TO THE CONTRACTOR.           
                                for(Commissioning_Report__c doc : docs) 
                                {
                                    commShareList.add(new Commissioning_Report__Share(UserOrGroupId = uniqueUser, 
                                                RowCause = 'Manual',ParentId = doc.id, AccessLevel = 'edit'));
                                }   
                                
                                for(Payment_Collection__c payment: payments) 
                                {
                                  paymentShareList.add(new Payment_Collection__Share(UserOrGroupId = uniqueUser, RowCause = 'Manual', 
                                                                                      ParentId = payment.id, AccessLevel = 'edit'));
                                } 
                        }
                                                        
                        //IDENTIFYING IF THE CURRENT INSTALLER IS AGENCY CONTRACTOR.
                        if(userProfileId == sAgencyContractorProfileId)
                        {
                                System.debug('££££ STEP 10.3.2: inside sAgencyContractorProfileId = '+sAgencyContractorProfileId);
                                //SHARING JOB AND JOB COMPLETION DOCUMENTS TO THE AGENCY CONTRACTOR AS WELL AS 
                                //PUBLIC GROUP OF HIS AGENCY.
                                
                                //SETTING FLAG VALUE TO INDICATE THIRD PARTY CONTRACTORS.
                                Flag = 2;
                                
                                //RETRIEVING THE PUBLIC GROUP ID.
                                Employee__c empRecord = userEmployeeMap.get(uniqueUser);
                                String sAgencyName = null;
                                String sGroupId = null;
                                
                                if(empRecord != null){
                                    sAgencyName = employeeAgencyNameMap.get(empRecord.Id);
                                }
                                if(sAgencyName != null)
                                {
                                    sGroupId = (agencyNameGroupMap.get(sAgencyName)).Id;
                                }
                                                             
                                //SHARING JOB WITH THE AGENCY CONTRACTOR AS WELL AS AGENCY OFFICE USER.
                                jobShareList.add(new Job__Share(UserOrGroupId = uniqueUser, 
                                                RowCause = 'Manual',ParentId = job.id, AccessLevel = 'Read'));
                                                
                                /*
                                jobShareList.add(new Job__Share(UserOrGroupId = sGroupId, 
                                                RowCause = 'Manual',ParentId = job.id, AccessLevel = 'Read'));
                                */
                                        
                                Boolean duplicateJobShared = false;                                         
                                for(integer i=0 ;i< jobShareList.size();i++){
                                    if(jobShareList[i].UserOrGroupId == sGroupId && jobShareList[i].ParentId == job.Id){
                                        duplicateJobShared = true;
                                        break;
                                    }
                                }
                                
                                if(!duplicateJobShared){
                                    jobShareList.add(new Job__Share(UserOrGroupId = sGroupId, 
                                                RowCause = 'Manual',ParentId = job.id, AccessLevel = 'Read'));
                                }      
                                                        
                                
                                //SHARING JOB COMPLETION DOCUMENT WITH AGENCY OFFICE USER AND AGENCY CONTRACTOR.                
                                for(Commissioning_Report__c doc : docs) 
                                {
                                    commShareList.add(new Commissioning_Report__Share(UserOrGroupId = uniqueUser, 
                                                RowCause = 'Manual',ParentId = doc.id, AccessLevel = 'edit'));
                                    /*
                                    commShareList.add(new Commissioning_Report__Share(UserOrGroupId = sGroupId, 
                                                RowCause = 'Manual',ParentId = doc.id, AccessLevel = 'edit'));
                                    */   
                                    Boolean duplicateDocShared = false;                                         
                                    for(integer i=0 ;i< commShareList.size();i++){
                                        if(commShareList[i].UserOrGroupId == sGroupId && commShareList[i].ParentId == doc.Id){
                                            duplicateDocShared = true;
                                            break;
                                        }
                                    }
                                    
                                    if(!duplicateDocShared){
                                        commShareList.add(new Commissioning_Report__Share(UserOrGroupId = sGroupId, 
                                                RowCause = 'Manual',ParentId = doc.id, AccessLevel = 'edit'));
                                    }
                                                                        
                                }
                                //Added By Ashok G
                                for(Payment_Collection__c payment: payments) 
                                {
                                  paymentShareList.add(new Payment_Collection__Share(UserOrGroupId = uniqueUser, RowCause = 'Manual', 
                                                                                      ParentId = payment.id, AccessLevel = 'edit'));
                                  Boolean duplicateDocShared = false;                                         
                                  for(integer i=0 ;i< paymentShareList.size();i++){
                                        if(paymentShareList[i].UserOrGroupId == sGroupId && paymentShareList[i].ParentId == payment.Id){
                                            duplicateDocShared = true;
                                            break;
                                        }
                                    }
                                    
                                   if(!duplicateDocShared){
                                        paymentShareList.add(new Payment_Collection__Share(UserOrGroupId = sGroupId, 
                                                RowCause = 'Manual',ParentId = payment.id, AccessLevel = 'edit'));
                                    }
                                }
                        }                       
                        //IDENTIFYING IF THE CURRENT INSTALLER IS AGENCY OFFICE USER.
                        if(userProfileId == sAgencyOfficeUserProfileId)
                        {
                                System.debug('££££ STEP 10.3.3: inside sAgencyOfficeUserProfileId = '+sAgencyOfficeUserProfileId);
                                //SETTING FLAG VALUE TO INDICATE THIRD PARTY CONTRACTORS.
                                Flag = 2;                                   
                        }
                        
                        // IF FLAG = 1,INSTALLER IS BRITISH GAS EMPLOYEE,
                        // SO, SHARE PAYMENT COLLECTION AS WELL AS JOB COMPLETION DOCUMENT TO THEM.
                        //Allow contractors and Agency contractors & Installers to complete the PCN.. Change By AshoK G
                        
                        if(Flag == 1)
                        {
                            System.debug('££££ STEP 10.3.4: FLAG = 1:inside British Gas installer');
                            for(Commissioning_Report__c doc : docs) {
                                commShareList.add(new Commissioning_Report__Share(UserOrGroupId = uniqueUser, RowCause = 'Manual', 
                                                                                  ParentId = doc.id, AccessLevel = 'edit'));
                            }  
                            for(Payment_Collection__c payment: payments) 
                            {
                              paymentShareList.add(new Payment_Collection__Share(UserOrGroupId = uniqueUser, RowCause = 'Manual', 
                                                                                  ParentId = payment.id, AccessLevel = 'edit'));
                            }                             
                        }  
                    }
                }
                
                /* Previous code before agency change.
                for(Job__c job : thisJob){
                    List<Commissioning_Report__c> docs = job.Job_Completion_Documents__r;
                    List<Payment_Collection__c> payments = job.Payment_Collections__r;
                    for(String installer : uniqueUsers){
                                                
                        for(Commissioning_Report__c doc : docs) {
                            commShareList.add(new Commissioning_Report__Share(UserOrGroupId = installer, RowCause = 'Manual', 
                                                                              ParentId = doc.id, AccessLevel = 'edit'));
                        }
                        for(Payment_Collection__c payment: payments) {
                            paymentShareList.add(new Payment_Collection__Share(UserOrGroupId = installer, RowCause = 'Manual', 
                                                                              ParentId = payment.id, AccessLevel = 'edit'));
                        }
                    }
                }
                */
                
                System.debug('££££ STEP 11: jobShareList to be inserted size= '+jobShareList.size());
                System.debug('££££ STEP 12: jobShareList to be inserted = '+jobShareList);
                
                System.debug('££££ STEP 13: commShareList to be inserted size= '+commShareList.size());
                System.debug('££££ STEP 14: commShareList to be inserted = '+commShareList);
                
                System.debug('££££ STEP 15: paymentShareList to be inserted size= '+paymentShareList.size());
                System.debug('££££ STEP 16: paymentShareList to be inserted = '+paymentShareList);
                
                // Insert new Job Share for new installers
                if(jobShareList.size() > 0){
                    try{
                        insert jobShareList;
                    }catch(DMLException e){
                        result = 'EXCEPTION MESSAGE : '+e.getMessage();
                        System.debug('-- EXCEPTION IN  CREATING SHARING FOR JOB -- '+e.getMessage());
                    }   
                }
                
                // Insert new Job Completion Documents Share for new installers
                if(commShareList.size() > 0){
                    try{
                        insert commShareList;
                    }catch(DMLException e){
                        result = 'EXCEPTION MESSAGE : '+e.getMessage();
                        System.debug('-- EXCEPTION IN  CREATING SHARING FOR JOB COMPLETION DOCUMENT -- '+e.getMessage());
                    }   
                }
                // Insert new Payment Collection Share for new installers
                if(paymentShareList.size() > 0){
                    try{
                        insert paymentShareList;
                    }catch(DMLException e){
                        result = 'EXCEPTION MESSAGE : '+e.getMessage();
                        System.debug('-- EXCEPTION IN  CREATING SHARING FOR PAYMENT COLLECTION-- '+e.getMessage());
                    }   
                }
            }
        }
        System.debug('££££ STEP 111 :Number of rows queried so far(Till end): getDmlRows= ' + Limits.getDmlRows()); 
        
        return result; 
    } 
    
    
    /*@isTest
    static  void createJobSharingTest(){
        // Creating the instance variable
        JobSharingCls obj = new JobSharingCls();
        // Create a new Account
        String accId = obj.getAccount();
        // Create a new Campaign
        String cId = obj.getCampaign();
        // Create a new Opportuntiy
        String opptyId = obj.getOpportunity(accId,cId);
        // Create a Quote and retrieve the job created
        JOb__c job = obj.getQuote(opptyId);
        // Create a Diary entry for the job
        obj.createDiaryEntry(job.Id);
        
        
        try{
            job.Status__c='Planned';
            update job;
        }catch(DmlException e){
            System.debug('--EXCEPTION -- '+e.getMessage());
        }
        // Calls the method to test
        String result = createJobSharing(new List<String>{job.Id});       
    }
    // This method is responsible for creating a Campaign o be used in ceation of opportunity
    // Output is the inserted records ID
    private String getCampaign(){
        Campaign cmp = new Campaign();
        cmp.Status = 'Completed';
        cmp.IsActive = true;
        cmp.Name = 'Test Campaign';
        cmp.Group_Code__c='MEDA';
        cmp.Media_Cost_Code__c='test';
        cmp.Source__c='TM';
        try{
            insert cmp;   
        }catch(DMLException e){
            System.debug('--EXCEPTION -- '+e.getMessage());
        }
        return cmp.Id;
    }
    // This method is responsible for creating a Account to be used in ceation of opportunity
    // Output is the inserted records ID
    private String getAccount(){
        Account account=new Account();
        account.Name='Test Account';
        account.Number_of_Bedrooms__c=1;
        account.Gas_Supply_At_Address__c=true;
        account.Current_Heating_System__c=true;
        account.BillingStreet='84,Range Road';
        account.BillingState='Cheshire';
        account.BillingPostalCode='SK3 8EE';
        account.BillingCountry='United Kingdom';
        account.BillingCity='Stockport';
        account.Water_Hardness__c=0;
        try{
            insert account;
        }catch(DMLException e){
            System.debug('--EXCEPTION -- '+e.getMessage());
        }
        return account.Id;
    }
    // This method is responsible for creating an Oppoetunity to be used in ceation of job
    // Output is the inserted records ID
    private String getOpportunity(String accid,String cId){
        // Create new opportunity
        Opportunity opportunity = new Opportunity();
      
        opportunity.name='Test Opportunity';
        opportunity.Product_Interest__c = 'XYZ';
        opportunity.CampaignId = cId;
        opportunity.StageName='Active';
        opportunity.CloseDate=System.today();
        opportunity.AccountId=accid;
        opportunity.LeadSource='Marcomms';
        opportunity.Product_Interest__c='Solar';
        opportunity.Lead_Comments__c = 'Lead Comments';
        try{
            insert opportunity;   
        }catch(DMLException e){
            System.debug('--EXCEPTION -- '+e.getMessage());
        }
        return opportunity.Id;
    }
    // This method is responsible for creating a Quote to be used in ceation of Job
    // Output is the automatically inserted job records ID
    private job__c getQuote(String opptyId){
        BigMachines_Quote__c qt = new BigMachines_Quote__c();
        qt.Opportunity__c=opptyId;
        qT.bmStatusReason__c='Sales';
        qt.stage__c='Quote Finalised - Accepted';
        qt.quoteNumber_quote__c = '12234';
        qt.installationDate__c = System.today();
        qt.deliveryDate__c = System.today();
        qt.Frozen_BM_Gross__c  = 12340;
        try{
            insert qt;   
        }catch(DMLException e){
            System.debug('--EXCEPTION -- '+e.getMessage());
        }
        
        // Cognizant - CHI Phase III CR-002 implementation... START
        
        AddNewSkill ObjNewSkill = new AddNewSkill();
        Job__c job = ObjNewSkill.fetchJobforSharing(qt.Id);         
        
        //JOb__c job = [select id,name,CHI_Lead__c,Status__c,Mechanical_Hours__c,PowerFlush_Hours__c,Building_Work_Hours__c,Installation_Date__c,Customer_Preferred_Date__c from Job__c where Quote__c =: qt.Id];
        
        // Cognizant - CHI Phase III CR-002 implementation... END        
        
       return job;
    }
 
    
    // This method is responsible for creating a Diary Entry for the job
    private void createDiaryEntry(String jobId) {
        try{       
            Region__c testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
            Database.insert(testRegion);
            
            District__c testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);
            Database.insert(testDistrict);
            
            Sub_Patch__c testSubPatch = new Sub_Patch__c(Name='Test SubPatch', Code__c = 'SP99', 
                                                        Type__c='Installation', District__c = testDistrict.ID);
            Database.insert(testSubPatch);
            
            Postcode_Sector__c testPostcodeSector = new Postcode_Sector__c(Name = 'XX99 9', Description__c = 'Test Postcode Sector', 
                                                                            Water_Hardness__c = 99, Type__c = 'Installation', 
                                                                            Sub_Patch__c = testSubPatch.ID);
            Database.insert(testPostcodeSector);
            Supplier__c supp = new Supplier__c(Name='TestSBB Supplier', Supplier_Num__c = '875411', Type__c = 'Resource', 
                                                Resource_Type__c='Own Labour');
            Database.insert(supp);
            User tUser = [select id from User where Phase_4_Ready__c=true limit 1];
            
                               
            Profile PInstal = [select id from Profile where name = 'CHI Contractor'];
            User uContractor = new User(profileid=PInstal.Id,alias = 'contra', email='contractor@testorg.com',
                                    emailencodingkey='UTF-8', lastname='TestContractor', languagelocalekey='en_US',
                                    localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='testContractor@testorg.com');
            insert uContractor;
            Employee__c empCon = new Employee__c(Name = 'testCon', First_Name__c = 'test', Last_Name__c = 'TestCon', Supplier__c = supp.ID,
                                                Employee_Number__c = '0002994', Resource_Type__c= 'Installer', Inactive__c = false,
                                                Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                                Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                                District__c = testDistrict.Id, Net_Promoter_Score__c = 10,Salesforce_User__c=uContractor.Id);
            Database.insert(empCon);
            
           
            Employee__c emp = new Employee__c(Name = 'testSBB1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                                Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false,
                                                Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                                Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                                District__c = testDistrict.Id, Net_Promoter_Score__c = 10,Salesforce_User__c=tUser.id);
            Database.insert(emp);
            Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                        Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                        Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                        Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                        Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                        Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                        Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                        Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
            Database.insert(sp);
            
            
            Week__c w = new Week__c(Employee__c = emp.ID, Week_Commencing__c = Date.today().toStartOfWeek(), Shift_Pattern__c = sp.ID);
            Database.insert(w);
            DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(9,0,0,0));
            DateTime endDT = DateTime.newInstance(Date.today().toStartOfWeek().addDays(4), Time.newInstance(17,0,0,0));
            Diary_Entry__c de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,
                                                    job__c = jobId,RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
            Database.insert(de);
            
            Week__c w1 = new Week__c(Employee__c = empCon.ID, Week_Commencing__c = Date.today().toStartOfWeek(), Shift_Pattern__c = sp.ID);
            Database.insert(w1);
            DateTime startDT1 = DateTime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(9,0,0,0));
            DateTime endDT1 = DateTime.newInstance(Date.today().toStartOfWeek().addDays(4), Time.newInstance(17,0,0,0));
            Diary_Entry__c de1 = new Diary_Entry__c(Start__c = startDT1, End__c = endDT1, Hours__c = 40, Week__c = w1.ID,
                                                    job__c = jobId,RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
            Database.insert(de1);
          
        }catch(Exception e){
            System.debug('Exception occured: '+e);
        }        
    }*/
}