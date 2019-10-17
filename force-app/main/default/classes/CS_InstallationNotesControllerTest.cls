@isTest
private class CS_InstallationNotesControllerTest {
    
    static Id appId {get; set;}
    static Id basketId {get; set;}
    static Id attId {get; set;}
    static Id oppId{get;set;}
    static String quoteRef {get;set;}
    static String logoType {get;set;}
    
    static List<Attachment> attList {get; set;}

  private static testMethod void controllerTest() {
         
        //Create a Basket
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.Name = 'CS TEST BASKET';
        insert basket;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName=Userinfo.getuserid()+'newuser@testorg.com');
        
        insert user;
        
        Supplier__c supplier = new Supplier__c(Name='Test Supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Employee__c employee = new Employee__c(Name = 'Test Employee', Salesforce_User__c=user.id ,First_Name__c = 'Test1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '1234567',Resource_Id__c='1test2',Resource_Type__c='Installer');
        
       
        insert employee;
        
        
        Campaign campaign = new Campaign(Source__c = 'TE', Media_Cost_Code__c = 'TEST', Group_Code__c = 'TEST', Name='Test campaign');
        insert campaign;
       
        Appointment__c appointment = new Appointment__c();
        appointment.Assigned_To__c = employee.id;
        appointment.OwnerId = user.id;
        appointment.Start__c = Datetime.newInstance(2016,5,5,12,30,0);
        appointment.End__c = Datetime.newInstance(2016,5,5,14,30,0);
        insert appointment;
        
        
        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
        
        
        Opportunity opportunity = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Referral_Employee__c =employee.id,Override_Billing_checks__c=false,
                                                Product_Interest__c='Heating Solution',
                                                CampaignId = campaign.Id, LeadSource='Engineer');
        
        insert opportunity;

        appId = appointment.id;
        oppId = opportunity.id;
        basketId = basket.id;
        
        logoType = 'BG';
        quoteRef = 'C12345678';
        
        attList = new List<Attachment>();
        
        String contentFile = '{"FooterText":"test1","LogoPng":"test2", "CHILeadNumber":"test4","AsbestosIdentified":"test5","AsbestosNotes":"test6","EarthSystem":"test7","VisibleEarth":"test8","Voelcb":"test9","CustomerArrange":"test10","Rdc":"test11","SocketSee":"test12","EarthLocation":"test13","Peb":"test14","LadderWork":"test16","Seb":"test15","Scaffolding":"test17","AccessNotes":"test18","WorkAreas":"test19","RemovalAssistance":"test20", "AllNotes":"test21", "Radiator":"test22", "Flow":"test23","WaterTestPressure":"test24","SystemCharacter":"test25","asbestosConfirmed":"test26", "boilerDetailsTable":"test27" }';
        Blob b = blob.valueof(contentFile); //decoded string
        contentFile = EncodingUtil.base64Encode(b);
        
        
        attId = UISupport.AttachTempFileReturnId(appId, CS_InstallationNotesController.TEMP_ATT_NAME, contentFile);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(basket);
        
        ApexPages.currentPage().getParameters().put('attId', attId);
        ApexPages.currentPage().getParameters().put('appId', appId);
        ApexPages.currentPage().getParameters().put('oppId', oppId);
        ApexPages.currentPage().getParameters().put('quoteRef', quoteRef);
        ApexPages.currentPage().getParameters().put('logoType', logoType);
        
        
        CS_InstallationNotesController controller;
        try {
            controller = new CS_InstallationNotesController(sc);
        } catch (Exception ex) {
            system.assert(false, 'Error while rendering pdf');
        }
        
        System.assertEquals('test1', controller.inputNotes.FooterText);
        System.assertEquals('test2', controller.inputNotes.LogoPng);
        System.assertEquals('test4', controller.inputNotes.CHILeadNumber);
        System.assertEquals('test5', controller.inputNotes.AsbestosIdentified);
        System.assertEquals('test6', controller.inputNotes.AsbestosNotes);
        System.assertEquals('test7', controller.inputNotes.EarthSystem);
        System.assertEquals('test8', controller.inputNotes.VisibleEarth);
        System.assertEquals('test9', controller.inputNotes.Voelcb);
        System.assertEquals('test10', controller.inputNotes.CustomerArrange);
        System.assertEquals('test11', controller.inputNotes.Rdc);
        System.assertEquals('test12', controller.inputNotes.SocketSee);
        System.assertEquals('test13', controller.inputNotes.EarthLocation);
        System.assertEquals('test14', controller.inputNotes.Peb);
        System.assertEquals('test15', controller.inputNotes.Seb);
        System.assertEquals('test16', controller.inputNotes.LadderWork);
        System.assertEquals('test17', controller.inputNotes.Scaffolding);
        System.assertEquals('test18', controller.inputNotes.AccessNotes);
        System.assertEquals('test19', controller.inputNotes.WorkAreas);
        System.assertEquals('test20', controller.inputNotes.RemovalAssistance);
        System.assertEquals('test21', controller.inputNotes.AllNotes);
        System.assertEquals('test22', controller.inputNotes.Radiator);
        System.assertEquals('test23', controller.inputNotes.Flow);
        System.assertEquals('test24', controller.inputNotes.WaterTestPressure);
        System.assertEquals('test25', controller.inputNotes.SystemCharacter);
        System.assertEquals('test26', controller.inputNotes.asbestosConfirmed);
        System.assertEquals('test27', controller.inputNotes.boilerDetailsTable);

        controller.deleteTempAttachment();
        
        List<Attachment> aList = [Select Id, Name, Body, ParentId from Attachment where Id = :attId and Name = :CS_InstallationNotesController.TEMP_ATT_NAME];
        System.assertEquals(0, aList.size());

        
  }
  
  private static testMethod void testReformatAsbestosNotesHtml() {
      final String TO_REFORMAT = '<span class=\'warning\'><p class=\'bold\'>Asbestos Identified</p><ol><li>Asbestos Location 1</li><li>Asbestos Location 2</li></ol></span>';
      final String NO_REFORMAT = 'This string doesn\'t have to be reformatted!';
      final String REFORMAT_EXPECTED = '<div class=\'warning\'><p class=\'boldFont\'>Asbestos Identified</p><ol><ol><li>Asbestos Location 1</li><li>Asbestos Location 2</li></ol></ol></div>';
      String resReformatActual = CS_InstallationNotesController.reformatAsbestosNotesHtml(TO_REFORMAT);
      String resNoReformatActual = CS_InstallationNotesController.reformatAsbestosNotesHtml(NO_REFORMAT);
      
      System.assertEquals(REFORMAT_EXPECTED, resReformatActual);
      System.assertEquals(NO_REFORMAT, resNoReformatActual);
  }

}