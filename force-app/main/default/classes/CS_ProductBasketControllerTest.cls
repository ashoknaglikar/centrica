@isTest
public class CS_ProductBasketControllerTest {

    static cscfga__Product_Basket__c prodBasket;
    static cscfga__Product_Configuration__c prodConfig;
    static cscfga__Product_Definition__c prodDef;
    
    static Opportunity opp;

    //Copied from BG tests
    static Appointment__c app;
    static Datetime startTime;
    static Datetime endTime;
    static Datetime now;
  
    
    static testMethod void basketCloningTest(){
        
        preparedata();
        insert app;
        
        createBasket();
        
        //Create Parts Data
        setTriggersOff(UserInfo.getUserId());
        CS_PartModelRemoterTest.createData();
        setTriggersOn(UserInfo.getUserId());
        
        CS_RemotingParamWrapper attBoiler = new CS_RemotingParamWrapper('boiler_0', CS_PartModelRemoterTest.boiler.Id, 0, 1,'Ignore', true, true, false, false, false, false, 'Kitchen', 'notes'); //A Part
        CS_RemotingParamWrapper attPackC = new CS_RemotingParamWrapper('packC_0', (CS_PartModelRemoterTest.packC1.Id + ',' + CS_PartModelRemoterTest.packC2.Id), 0, 1,'Ignore', true, true, false, true, false, false, '', 'notes');   //A multilookup Part
        CS_RemotingParamWrapper attBundleAB = new CS_RemotingParamWrapper('bundleAB_0', CS_PartModelRemoterTest.bundleAB.Id, 0, 1,'Ignore', true, false, true, false, false, false, '', 'notes');   //A Bundle
        
        List<CS_RemotingParamWrapper> attsChanged = new List<CS_RemotingParamWrapper>{attBoiler, attPackC, attBundleAB};
        
        Test.startTest();
        
        //Save Attachment
        Map<String, CS_PartModelEntry> model = CS_PartModelRemoter.getPartModelInformation(attsChanged, CS_PartModelRemoterTest.regionCode,  CS_PartModelRemoterTest.districtCode, CS_Constants.CS_PricebookType_Standard, '', CS_PartModelRemoterTest.geographicalUplift);
        UISupport.storePartsModel(prodConfig.Id, model);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(prodBasket); 
        CS_ProductBasketController ctrl = new CS_ProductBasketController(sc);
        
        ctrl.cloneBasket();
        
        Test.stopTest();
        
        cscfga__Product_Basket__c clonedBasket = [select Id, Name, Appointment__c from cscfga__Product_Basket__c where Original_Basket__c = :prodBasket.Id];
        
        //Get all Attributes of Cloned Configuration
          //get all attributes and attribute fields
        List<cscfga__Attribute__c> allAttributes = [select  cscfga__Annualised_Price__c, 
                                                            cscfga__Attribute_Definition__c, 
                                                            cscfga__Billing_Price__c, 
                                                            cscfga__Cascade_value__c, 
                                                            cscfga__Discount_Amount__c, 
                                                            cscfga__Discount_Type__c, 
                                                            cscfga__Display_Value__c, 
                                                            cscfga__Hidden__c, 
                                                            cscfga__Is_Line_Item__c, 
                                                            cscfga__Is_rate_line_item__c, 
                                                            cscfga__Is_Read_Only__c, 
                                                            cscfga__Is_Required__c, 
                                                            cscfga__is_active__c, 
                                                            cscfga__Key__c, 
                                                            cscfga__Line_Item_Description__c, 
                                                            cscfga__Line_Item_Sequence__c, 
                                                            cscfga__List_Price__c, 
                                                            Name, 
                                                            cscfga__Price__c, 
                                                            cscfga__Product_Configuration__c, 
                                                            Id, 
                                                            cscfga__Recurring__c, 
                                                            cscfga__Value__c,
                                                            (select     cscfga__Attribute__c, 
                                                                        Name, 
                                                                        Id, 
                                                                        cscfga__Value__c
                                                            from cscfga__Attribute_Fields__r)
                                                    from cscfga__Attribute__c 
                                                    where cscfga__Product_Configuration__r.cscfga__Product_Basket__c = :clonedBasket.Id
                                                        and cscfga__Product_Configuration__r.cscfga__Root_Configuration__c = null]; //only get root config's attributes
                                                    
       for (cscfga__Attribute__c att: allAttributes) {
            
            if (att.Name == 'Pdf Signed') {
                system.assertEquals('0', att.cscfga__Value__c);
            }
            else if (att.Name == 'Pdf Path') {
                system.assertEquals(null, att.cscfga__Value__c);
            }
            else if (att.Name == 'Quote Status') {
                system.assertEquals('--None--', att.cscfga__Value__c);
            }
            else if (att.Name == 'Reason') {
                system.assertEquals('--None--', att.cscfga__Value__c);
            }
        }
        
    }

    static testMethod void basketSummaryTest(){
        
        preparedata();
        insert app;
        
        createBasket();
        
        //Create Parts Data
        setTriggersOff(UserInfo.getUserId());
        CS_PartModelRemoterTest.createData();
        setTriggersOn(UserInfo.getUserId());
        
        CS_RemotingParamWrapper attBoiler = new CS_RemotingParamWrapper('boiler_0', CS_PartModelRemoterTest.boiler.Id, 0, 1,'Ignore', true, true, false, false, false, false, 'Kitchen', 'notes'); //A Part
        CS_RemotingParamWrapper attPackC = new CS_RemotingParamWrapper('packC_0', (CS_PartModelRemoterTest.packC1.Id + ',' + CS_PartModelRemoterTest.packC2.Id), 0, 1,'Ignore', true, true, false, true, false, false, '', 'notes');   //A multilookup Part
        CS_RemotingParamWrapper attBundleAB = new CS_RemotingParamWrapper('bundleAB_0', CS_PartModelRemoterTest.bundleAB.Id, 0, 1,'Ignore', true, false, true, false, false, false, '', 'notes');   //A Bundle
        
        List<CS_RemotingParamWrapper> attsChanged = new List<CS_RemotingParamWrapper>{attBoiler, attPackC, attBundleAB};
        
        Test.startTest();
        
        //Save Attachment
        Map<String, CS_PartModelEntry> model = CS_PartModelRemoter.getPartModelInformation(attsChanged, CS_PartModelRemoterTest.regionCode,  CS_PartModelRemoterTest.districtCode, CS_Constants.CS_PricebookType_Standard, '', CS_PartModelRemoterTest.geographicalUplift);
        UISupport.storePartsModel(prodConfig.Id, model);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(prodBasket); 
        CS_ProductBasketController ctrl = new CS_ProductBasketController(sc);
        
        system.assertEquals(prodBasket.Id, ctrl.basketId);
        system.assertEquals(app.Id, ctrl.appointmentId);
        system.assertEquals(1, ctrl.allBasketItems.size());
        system.assertEquals(prodConfig.Id, ctrl.allBasketItems[0].config.Id);
        system.assertEquals(false, ctrl.allBasketItems[0].canBeEdited);
        
        //TEMP
        String concatItems = '';
        for (CS_ProductBasketController.LineItemWrapper item : ctrl.allBasketItems[0].lineItemList) {
            system.debug('***** ' + item.ItemName);
            concatItems += ', ' + item.ItemName;
        }
        
        //system.assertEquals('bla', concatItems);
        system.assertEquals(4, ctrl.allBasketItems[0].lineItemList.size()); //boiler, bundle and 2 for the multilookup with 2 values
        
        system.assertEquals(2, ctrl.allBasketItems[0].allowanceItemList.size());
        system.assertEquals(200 + 199, ctrl.allBasketItems[0].totalDiscounts);
        system.assertEquals(ctrl.allBasketItems[0].totalPriceInclVAT - 200 - 199, ctrl.allBasketItems[0].totalPayable);
        
        Test.stopTest();
    }
    
    static testMethod void testQuoteRefCreation() {
        
        preparedata();
        insert app;
        
        //Retrieve Opp's CHI_Lead_Id__c
        Opportunity savedOpp = [select Id, CHI_Lead_Id__c from Opportunity where Id = :opp.Id];
        
        String CHI_Lead_No = savedOpp.CHI_Lead_Id__c;
        
        //No Baskets yet, the next available Quote Ref should end with a '0'
        String ref = CS_QuoteReferenceGenerator.getNextQuoteReference(opp.Id);
        String expectedRef = 'C' + CHI_Lead_No + '0';
        
        System.assertEquals(expectedRef, ref);
        
        //Create 35 baskets
        List<cscfga__Product_Basket__c> newBaskets = new List<cscfga__Product_Basket__c>();
        for (Integer i = 0; i < 35; i++) {
            cscfga__Product_Basket__c pb = new cscfga__Product_Basket__c(Name = 'test', Appointment__c = app.Id);
            newBaskets.add(pb);
        }
        
        insert newBaskets;
        
         //Next available Quote Ref should end with 'Z'
        ref = CS_QuoteReferenceGenerator.getNextQuoteReference(opp.Id);
        expectedRef = 'C' + CHI_Lead_No + 'Z';
        
        System.assertEquals(expectedRef, ref);
        
        //Create another Basket => Next available Quote Ref should end with '0'
        cscfga__Product_Basket__c prodBasket36 = new cscfga__Product_Basket__c();
        prodBasket36.Name = 'test';
        prodBasket36.Appointment__c = app.Id;
        insert prodBasket36;
        
        ref = CS_QuoteReferenceGenerator.getNextQuoteReference(opp.Id);
        expectedRef = 'C' + CHI_Lead_No + '00';
        
        System.assertEquals(expectedRef, ref);
        
    }
    
    private static string getUniqueKey() {
        return CS_GuidGenerator.NewGUID();
    }
    
    /*
     * Creates  Basket, a Configuration and its Attributes and Attribute Fields
     */
    static void createBasket() {
    
         //Create a Basket
        prodBasket = new cscfga__Product_Basket__c();
        prodBasket.Name = 'test';
        prodBasket.Appointment__c = app.Id;
        insert prodBasket;
        
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

    /*
     * Prepares data in order to create a new Appointment
    */
    static void preparedata() {
        //TestEventAndAppointmentSynchronisation.Setup s = 
                                       // new TestEventAndAppointmentSynchronisation.Setup();
        now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
        startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 6, 0, 0);
        endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 21, 0, 0);
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
        String appointmentApptRecTypeId = '';
       
        String postcodeSector = 'SE3 9';
         RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];

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
        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        Campaign camp = new Campaign(Source__c = 'MC', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp);
        
        supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
        User user = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = 'a1@b.com', Username='us1er1@gmail.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert user;
        
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
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        
        
        //inserting opportunity with different employee
        opp = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false,
                                                Product_Interest__c='Central Heating Boiler',
                                                CampaignId = camp.Id, LeadSource='Engineer');
                                                        
       Database.insert(opp);  
 
              
       BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=employees[0].Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote; 
         
        District__c district = new District__c (Name='Test district', Code__c = 'test');
        insert district;
       
        Job__c job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                 
        insert job;
        Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
        insert JE;

        // Create Appointment
        //Appointment__c app = s.createNewAppt(false, '102 Pitt');    
        String who = contact.id;
         app = new Appointment__c(Start__c = startTime, 
                                 End__c = endTime, Subject__c = subject, 
                                 Assigned_To__c = employees[0].id, OwnerId = user.id,
                                 Any_Time__c = anyTime, Description__c = description,
                                 Converted_Visit_Type__c = convertedVisitType,
                                 Do_Not_Send_To_Premier__c = doNotSendToPremier,
                                 Mode__c = mode, Overbooked__c = overbooked,
                                 RecordTypeId = recordTypeId,
                                 Resource_Type__c = resourceType, 
                                 Sale_Flag__c = sale, Show_Time_As__c = showTimeAs,
                                 Status_Reason__c = statusReason, Status__c = status,
                                 Time_Band__c = timeBand, Type__c = typeC,
                                 Visit_Type__c = visitType, Opportunity__c = opp.id,
                                 Who__c = who);
                                 
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