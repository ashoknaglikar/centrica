@isTest
private class CS_ProductBasketPdfControllerTest {

    static Appointment__c app {get; set;}
    static cscfga__Product_Basket__c prodBasket {get; set;}
    static cscfga__Product_Definition__c prodDef {get; set;}
    static cscfga__Product_Configuration__c prodConfig {get; set;}
    static Id basketId {get; set;}
    static String pageContent {get;set;}

    public static testMethod void controllerTest() {
      
        Datetime now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
        Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 6, 0, 0);
        Datetime endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 21, 0, 0);
        String subject = 'createNewAppt() Test';
        Boolean anyTime = false; // Also: True
        Boolean convertedVisitType = true; // Or False
        String description = 'createNewAppt() description';
        Boolean doNotSendToPremier = false; // Also: true
        Boolean allDayEvent = false; // Also: True
        Datetime lastSentToPremier = Datetime.now();
        String mode = 'SU'; // Other options available
        mode = 'Installation';
        Boolean overbooked = True; // Also: True
        String resourceType = 'A';
        Boolean sale = false; // Also: True
        String showTimeAs = 'Busy'; // Also: Out of Office, Free
        String statusReason = 'INFORMATION PROVIDED'; // Other options available
        String status = 'Appointed'; // Also: Appointed, Happened, Cancelled
        String timeBand = 'AM'; // Also: PM, EV, AT
        String typeC = 'Survey'; // Other options available
        String visitType = 'First Visit'; // Also: Recall Visit, Pickup
      
        RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];

        String appointmentApptRecTypeId;
        for(RecordType rt : recordTypes) {
            if(rt.sObjectType == 'Event') {
                if(rt.Name == 'Available') {}
                  //  availableEvtRecTypeId = rt.Id;
                else if(rt.Name == 'Unavailable') {}
                   // unavailableEvtRecTypeId = rt.Id;
                else if (rt.Name=='Installation')  {}
                   // installtionEvtRecTypeId=rt.id;
                else if (rt.Name=='Itinerary')  {}
                  //  itineraryEvtRecTypeId=rt.id;
                else {}
                  //  appointmentEvtRecTypeId = rt.Id;
            } else if(rt.sObjectType == 'Appointment__c'){
                if(rt.Name == 'Available') {}
                   // availableApptRecTypeId = rt.Id;
                else if(rt.Name == 'Unavailable') {}
                   // unavailableApptRecTypeId = rt.Id;
                else if (rt.Name=='Installation')  {}
                   // installtionApptRecTypeId=rt.id;
                 else if (rt.Name=='Itinerary') {}
                   // itineraryApptRecTypeId=rt.id; 
                else
                    appointmentApptRecTypeId = rt.Id;                   
            }
        }
        String recordTypeId = appointmentApptRecTypeId; // Other options available
      
        Account account = new Account(Name='Test Account', Number_of_Bedrooms__c=1, BillingStreet='Test Street', BillingState='Test State',
                                    BillingPostalCode='441111', BillingCountry='Test Country', BillingCity='Test City'); //ok
        insert account;
        
        Contact contact = new Contact(Primary_Contact__c=true, Phone='9022332343', MailingStreet='Test Street', MailingState='Test State',
                                     MailingPostalCode='441111', MailingCountry='Test Country', MailingCity='Test City', LastName='Last Name',
                                     FirstName='First name', Email='test@gmail.com', AccountId=account.Id, Salutation='Mr'); 
        insert contact;
        
        Campaign camp = new Campaign(Source__c = 'MC', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        insert(camp);
        
        Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
        User user = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = 'a1@b.com', Username='us1er1@gmail.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert user;
        
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', Salesforce_User__c=user.id ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        
        List<Employee__c> employees = new Employee__c[]{emp};                                          
        insert employees;
        
        Employee_Skills__c empSkill1 = new Employee_Skills__c(Skill_Name__c = 'LPG Installation', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        Employee_Skills__c empSkill2 = new Employee_Skills__c(Skill_Name__c = 'Roof Work', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        Employee_Skills__c empSkill3 = new Employee_Skills__c(Skill_Name__c = 'Building Work', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        Employee_Skills__c empSkill4 = new Employee_Skills__c(Skill_Name__c = 'Connect Solar Panels', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        
        List<Employee_Skills__c> empSkills = new Employee_Skills__c[]{empSkill1,empSkill2,empSkill3,empSkill4};
        insert empSkills;  
   
        Opportunity opp = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false,
                                                Product_Interest__c='Central Heating Boiler',
                                                CampaignId = camp.Id, LeadSource='Engineer');
        insert opp;
   
        app = new Appointment__c(
            Start__c = startTime, End__c = endTime, Subject__c = subject, Assigned_To__c = employees[0].id, OwnerId = user.id,
            Any_Time__c = anyTime, Description__c = description, Converted_Visit_Type__c = convertedVisitType,
            Do_Not_Send_To_Premier__c = doNotSendToPremier, Mode__c = mode, Overbooked__c = overbooked,
            RecordTypeId = recordTypeId, Resource_Type__c = resourceType, Sale_Flag__c = sale, Show_Time_As__c = showTimeAs,
            Status_Reason__c = statusReason, Status__c = status, Time_Band__c = timeBand, Type__c = typeC,
            Visit_Type__c = visitType, Opportunity__c = opp.id, Who__c = contact.id);
    
        createBasket();
        

        setTriggersOff(UserInfo.getUserId());
        CS_PartModelRemoterTest.createData();
        setTriggersOn(UserInfo.getUserId());
        
        CS_RemotingParamWrapper attBoiler = new CS_RemotingParamWrapper('boiler_0', CS_PartModelRemoterTest.boiler.Id, 0, 1,'Ignore', true, true, false, false, false, false, 'Kitchen', 'notes'); //A Part
        CS_RemotingParamWrapper attPackC = new CS_RemotingParamWrapper('packC_0', (CS_PartModelRemoterTest.packC1.Id + ',' + CS_PartModelRemoterTest.packC2.Id), 0, 1,'Ignore', true, true, false, true, false, false, '', 'notes');   //A multilookup Part
        CS_RemotingParamWrapper attBundleAB = new CS_RemotingParamWrapper('bundleAB_0', CS_PartModelRemoterTest.bundleAB.Id, 0, 1,'Ignore', true, false, true, false, false, false, '', 'notes');   //A Bundle
        
        List<CS_RemotingParamWrapper> attsChanged = new List<CS_RemotingParamWrapper>{attBoiler, attPackC, attBundleAB};
        
        //Save Attachment
        Map<String, CS_PartModelEntry> model = CS_PartModelRemoter.getPartModelInformation(attsChanged, CS_PartModelRemoterTest.regionCode,  CS_PartModelRemoterTest.districtCode, CS_Constants.CS_PricebookType_Standard, '', CS_PartModelRemoterTest.geographicalUplift);
        UISupport.storePartsModel(prodConfig.Id, model);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(prodBasket);
        CS_ProductBasketPdfController controller;
        try {
            controller = new CS_ProductBasketPdfController(sc);
        } catch (Exception ex) {
            system.assert(false, ex);
        }
        controller.pageContent = 'test page content';
        PageReference pr = controller.displayPDF(); 
        
        System.assertEquals('/apex/CS_Pdf?id=' + basketId, pr.getUrl());
    }
    
    static void createBasket() {
    
         //Create a Basket
        prodBasket = new cscfga__Product_Basket__c();
        prodBasket.Name = 'BasketTest';
        prodBasket.Appointment__c = app.Id;
        insert prodBasket;
        
        basketId = prodBasket.id;
        
        //create a Product definition
        prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'Heating Hot Water Solution Test';
        prodDef.cscfga__Description__c = 'Heating Hot Water Solution Test Description';
        insert prodDef;
        
        prodConfig = new cscfga__Product_Configuration__c(Name = 'Heating System Installation', 
                                                           cscfga__Product_Basket__c = prodBasket.Id,
                                                           cscfga__Product_Definition__c = prodDef.Id,
                                                           cscfga__Key__c = getUniqueKey());
        insert prodConfig;
        
        CS_Allowance__c allowance1 = new CS_Allowance__c(Description__c = 'Allowance 1', Allowance_Type__c = 'Amount', Amount__c = 20);
        CS_Allowance__c allowance2 = new CS_Allowance__c(Description__c = 'Allowance 2', Allowance_Type__c = 'Amount', Amount__c = 30);
        
        insert new List<CS_Allowance__c> {allowance1, allowance2};
        
        String[] attributeNameArray= new List<String> { 'Allowance1',   'Allowance2',   'Allowance3',   'Allowance4',   'Allowance5',   'Allowance6', 'Pdf Signed', 'Pdf Path', 'Quote Status', 'Reason'};
        String[] attributeTypeArray = new List<String> {'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display'};
        String[] attributeValues = new List<String> {allowance1.Id, allowance2.Id,  '',             '',             '',             '', '1', 'dummyPath', 'Finalized - Accepted', 'Considering'}; 
            
        //create attribute definitions
        // need attributes for our configuration
        List<cscfga__Attribute_Definition__c> attributeDefinitionList = new List<cscfga__Attribute_Definition__c>();
        for(Integer i=0; i<attributeNameArray.size(); i++){
            cscfga__Attribute_Definition__c attDef = new cscfga__Attribute_Definition__c();
            attDef.Name = attributeNameArray[i];
            attDef.cscfga__Type__c = attributeTypeArray[i];
            attDef.cscfga__Product_Definition__c = prodDef.Id;
            attributeDefinitionList.add(attDef);
        }
        
        insert attributeDefinitionList;
        
        //create necessary attributes
        List<cscfga__Attribute__c> attributeList = new List<cscfga__Attribute__c>();
        for(Integer i=0; i<attributeNameArray.size(); i++){
            cscfga__Attribute__c attribute = new cscfga__Attribute__c();
            attribute.Name = attributeNameArray[i];
            attribute.cscfga__Attribute_Definition__c = attributeDefinitionList.get(i).Id;
            attribute.cscfga__Product_Configuration__c = prodConfig.Id;
            attribute.cscfga__value__c = attributeValues[i];
            attributeList.add(attribute);
        }
        
        insert attributeList;
        
        List<cscfga__Attribute_Field__c> attributeFieldList = new List<cscfga__Attribute_Field__c>();
        for(Integer i=0; i<attributeNameArray.size(); i++){
            cscfga__Attribute_Field__c attributeField1 = new cscfga__Attribute_Field__c();
            attributeField1.cscfga__Attribute__c = attributeList[i].Id;
            attributeField1.name = 'AllowanceName';
            attributeField1.cscfga__Value__c = 'Allowance ' + i;
            
            cscfga__Attribute_Field__c attributeField2 = new cscfga__Attribute_Field__c();
            attributeField2.cscfga__Attribute__c = attributeList[i].Id;
            attributeField2.name = 'ActualAmount';
            attributeField2.cscfga__Value__c = string.valueOf(200 - i);
            
            cscfga__Attribute_Field__c attributeField3 = new cscfga__Attribute_Field__c();
            attributeField3.cscfga__Attribute__c = attributeList[i].Id;
            attributeField3.name = 'Is_Applied';
            attributeField3.cscfga__Value__c = ((i == 0 || i == 1) ? 'TRUE' : 'FALSE'); //only apply 2 allowances
            
            attributeFieldList.add(attributeField1);
            attributeFieldList.add(attributeField2);
            attributeFieldList.add(attributeField3);
        }
        
        insert attributeFieldList;
    }
    
    private static string getUniqueKey() {
       return CS_GuidGenerator.NewGUID();
    }

    public static void setTriggersOff(Id UserId) {
        List<No_Triggers__c> noTriggerFlag = [Select SetupOwnerId, Name, Id, Flag__c From No_Triggers__c
                                              Where SetupOwnerId = :UserId Limit 1];
        if(noTriggerFlag.isEmpty() == false) {
            noTriggerFlag[0].Flag__c = true;
            update noTriggerFlag;
        } else {
            No_Triggers__c noTrigger = new No_Triggers__c(SetupOwnerId = UserId, Name = 'No Triggers (User)', Flag__c = true);
            insert noTrigger;
        }
    }

    public static void setTriggersOn(Id UserId) {
        List<No_Triggers__c> noTriggerFlag = [Select SetupOwnerId, Name, Id, Flag__c From No_Triggers__c
                                              Where SetupOwnerId = :UserId Limit 1];
        if(noTriggerFlag.isEmpty() == false) {
            noTriggerFlag[0].Flag__c = false;
            update noTriggerFlag;
        }
    }
}