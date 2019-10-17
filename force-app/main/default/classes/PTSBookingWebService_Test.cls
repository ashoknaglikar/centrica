/**
 * Test class for PTSBookingWebService
 */
@isTest
private class PTSBookingWebService_Test 
{
    public static List<Job__c> Jobs;
    public static User ptsServiceUser = new User();
    public static void createTestData() 
    {
        
        String uniqueName = 'ptsservicetestuser' + System.now().format('ddddmmyy');
        Profile ptsServiceUserProfile;
        List<Profile> profiles = [select id from profile where name ='PTS Service Profile' limit 1];
        if(profiles != null && profiles.size() > 0)
        {
        	ptsServiceUserProfile = profiles[0];
        }
        else
        {
        	ptsServiceUserProfile = [select id from profile limit 1];
        }
        /*ptsServiceUser = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = uniqueName + '@test.com', Username=uniqueName + '@test.com',
                                ProfileId = ptsServiceUserProfile.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = uniqueName + '@test23.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');*/
        ptsServiceUser = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = 'a1@b.com', Username='us1er1' + uniqueName + '@gmail.com',
                                ProfileId = ptsServiceUserProfile.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert ptsServiceUser;
        
        Account Acc = TestScenarioCreateAccount();
        Opportunity opty = TestScenarioCreateOppty(Acc);
        
        String District = '';
        for(District__c distt :[Select Id, Name From District__c where Name='Decompile District'])
        {
            District = distt.id;
            if(District != '') break;
        }
        if(District == '')
        {
            District__c distt = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
            insert distt;
            District = distt.id;
        }
        Jobs = TestScenarioCreateJob('Installed','Installed',opty.Id,District );   
    }
    
    static testMethod void check_PTSAppointmentInfo_Null() 
    {
        PTSBookingWebService.PTSAppointmentInfo appInfo;
        
        PTSBookingWebService.ActionResult result = PTSBookingWebService.upsertAppointment(appInfo);
        System.assertEquals(false, result.Success, 'Send null PTSAppointmentInfo object; Expected error but invalid data succeeded');  
    }
    
    static testMethod void check_PTSAppointmentInfo_AllValue_Null() 
    {
        PTSBookingWebService.PTSAppointmentInfo appInfo = new PTSBookingWebService.PTSAppointmentInfo();
        PTSBookingWebService.ActionResult result  = PTSBookingWebService.upsertAppointment(appInfo);
        System.assertEquals(false, result.Success, 'Send PTSAppointmentInfo object with all null values; Expected error but invalid data succeeded');
    }
    
    static testMethod void check_InvalidTimeSlot1() 
    {
        PTSBookingWebService.PTSAppointmentInfo appInfo = new PTSBookingWebService.PTSAppointmentInfo();
        appInfo.TimeSlot = 'test';
        PTSBookingWebService.ActionResult result = PTSBookingWebService.upsertAppointment(appInfo);
        System.assertEquals(false, result.Success, 'Send invalid timeslot; Expected error but invalid data succeeded');
    }
    
    static testMethod void check_InvalidTimeSlot2() 
    {
        PTSBookingWebService.PTSAppointmentInfo appInfo = new PTSBookingWebService.PTSAppointmentInfo();
        appInfo.TimeSlot = 'asd:asd - asd:asd';
        PTSBookingWebService.ActionResult result = PTSBookingWebService.upsertAppointment(appInfo);
        System.assertEquals(false, result.Success, 'Send invalid timeslot; Expected error but invalid data succeeded');
    }
    
    static testMethod void check_insertAppointment() 
    {
        createTestData();
        System.runAs(ptsServiceUser)
        {
            PTSBookingWebService.PTSAppointmentInfo appInfo = new PTSBookingWebService.PTSAppointmentInfo();
            appInfo.BookingMethod = 'System';
            appInfo.BookingStatus = 'Booked';
            appInfo.DeliveryDate = Datetime.now();
            appInfo.DeliveryId = 'testDelID';
            appInfo.JobNumber = Jobs[0].Name;
            appInfo.TimeSlot = '15:00 - 18:00';
            PTSBookingWebService.ActionResult result = PTSBookingWebService.upsertAppointment(appInfo);
            System.assertEquals(true, result.Success, 'Send valid data; Expected success but recieved errors : ' + result.Errors);
        }
    }
    
    static testMethod void check_updateAppointment() 
    {
        createTestData();
            
        System.runAs(ptsServiceUser)
        {
            PTSBookingWebService.PTSAppointmentInfo appInfo = new PTSBookingWebService.PTSAppointmentInfo();
            appInfo.BookingMethod = 'System';
            appInfo.BookingStatus = 'Booked';
            appInfo.DeliveryDate = Datetime.now();
            appInfo.DeliveryId = 'testDelID';
            appInfo.JobNumber = Jobs[0].Name;
            appInfo.TimeSlot = '15:00 - 18:00';
            PTSBookingWebService.ActionResult result = PTSBookingWebService.upsertAppointment(appInfo);
            System.assertEquals(true, result.Success, 'Send valid data; Expected success but recieved errors : ' + result.Errors);
            
            appInfo.TimeSlot = '13:00 - 15:00';
            result = PTSBookingWebService.upsertAppointment(appInfo);
            System.assertEquals(true, result.Success, 'Send valid data; Expected success but recieved errors : ' + result.Errors);
        }
    }
    
    static testMethod void check_cancelAppointment() 
    {
        createTestData();
            
        System.runAs(ptsServiceUser)
        {
            PTSBookingWebService.PTSAppointmentInfo appInfo = new PTSBookingWebService.PTSAppointmentInfo();
            appInfo.BookingMethod = 'System';
            appInfo.BookingStatus = 'Booked';
            appInfo.DeliveryDate = Datetime.now();
            appInfo.DeliveryId = 'testDelID';
            appInfo.JobNumber = Jobs[0].Name;
            appInfo.TimeSlot = '15:00 - 18:00';
            PTSBookingWebService.ActionResult result = PTSBookingWebService.upsertAppointment(appInfo);
            System.assertEquals(true, result.Success, 'Send valid data; Expected success but recieved errors : ' + result.Errors);
            
            result = PTSBookingWebService.cancelAppointment(appInfo);
            System.assertEquals(true, result.Success, 'Send valid data; Expected success but recieved errors : ' + result.Errors);
        }
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
    
    //test method        
    private static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
    }
    
    public static Job__c[] TestScenarioCreateJob(string status, string substatus, ID optyId, string District){
        
        Job__c job1 = new Job__c(District__c = District , Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID, Water_Heating_Fixing_Hours__c=0,Unvented_Hot_Water_Hours__c=0,Specialist_Building_Hours__c=0,Scaffolder_Hours__c=0,Roof_Work_Hours__c=0,Payment_Collection_Hours__c=0,Mechanical_Hours__c=0,LPG_Installation_Hours__c=0,Fire_Wall_Heater_Fixing_Hours__c=0,Electrical_Hours__c=0,Contractor_Installation_Hours__c=0,Connect_Solar_Panel_Hours__c=0,Building_Work_Hours__c=0,PowerFlush_Hours__c=0,Electrical_Work_ASP_Hours__c=0,Asbestos_Removal_Hours__c=0,Asbestos_Removal_Fixed_Rate_Hours__c=0,Solar_Hours__c=0);              
        Job__c[] joblist = new Job__c[]{job1};          
        system.debug('joblist contains :'+joblist);
        insert joblist;        
        return [select id, Name, CHI_Lead__c, CHI_Lead__r.AccountID, DeliveryID__c, 
            PTSDeliverySlot__c, Delivery_Notes__c, PTSSlotBookingStatus__c, Delivery_Date__c,
            Quote__r.Delivery_Slot__c, Quote__r.deliveryDate__c,
            CHI_Lead__r.Account.Primary_Contact__c
            from Job__c where id in :jobList];
    }
}