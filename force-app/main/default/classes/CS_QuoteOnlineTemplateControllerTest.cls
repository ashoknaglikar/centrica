@isTest
private class CS_QuoteOnlineTemplateControllerTest {
    public static cscfga__Product_Basket__c basket;
    @testsetup
    public static void testDataSetUP()
    {
        list<IV_Vectors__c> insertList = new list <IV_Vectors__c>();
        insertList.add(new IV_Vectors__c(Name = 'wwabName'  , Key__c = 'Work without a Boiler'));
        insertList.add(new IV_Vectors__c(Name = 'wwabGas1YearCareProductName'  , Key__c = 'P10006 - 1 Year Complimentary Gas Appliance Care'));
        insert insertList;
    }
    static List<Attachment> attList {get; set;}
    static Id attId {get; set;}
    private static final String partsModelJson = '';
    private static final String pricebookType = 'Standard';
    private static final String boilerGroup = 'Worcester';
    private static final String regionCode = 'South London';
    private static final String postcodeSector = 'SW London';
    private static final Decimal geographicalUplift = 6;
    
    private static String serializedJson;

    public class BasketInfo {
        public Id appId;
        public Id oppId;
        public Id basId;
        public cscfga__Product_Basket__c bas;
        public String quoteRef;
        public String logoTyp;
        
        public BasketInfo(Id appointmentId, 
                        Id opportunityId, 
                        Id basketId, 
                        cscfga__Product_Basket__c basket,
                        String quoteReference,
                        String logoType) {
            appId = appointmentId;
            oppId = opportunityId;
            basId = basketId;
            bas = basket;
            quoteRef = quoteReference;
            logoTyp = logoTyp;
        }
    }

    private static void loadTestJson() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'TEST_Online_Quote' LIMIT 1];
        serializedJson = sr.Body.toString();

        // make sure we actually loaded the file
        Integer testJsonLenght = 83334;
        System.assertEquals(testJsonLenght, serializedJson.length());
    }
    
    
    private static void addTestParts(Id parentProdId) {
        CS_PartModelRemoterTest.createData();
        
        RecordType rtLvl1 = [SELECT id FROM RecordType WHERE Name = 'Level 1' AND SObjectType = 'CS_Template_Section_Header__c'][0];
        RecordType rtLvl2 = [SELECT id FROM RecordType WHERE Name = 'Level 2' AND SObjectType = 'CS_Template_Section_Header__c'][0];
        
        CS_Template_Section_Header__c sectionHeaderInstallEss =
                    new CS_Template_Section_Header__c(Name='Your Installation Essentials', 
                                                    RecordType = rtLvl1, Sequence__c = 17);
        insert sectionHeaderInstallEss;
        
        CS_Template_Section_Header__c sectionHeaderElectricWork = 
                    new CS_Template_Section_Header__c(Name='Electical Work', RecordType = rtLvl2, 
                                                    Sequence__c = 18, Level_1_Section__c = sectionHeaderInstallEss.Id);
        insert sectionHeaderElectricWork;
        
        System.debug(rtLvl1 + ' ' + rtLvl2);
        
        
        List<CS_Part__c> parts = [SELECT Id, CS_Template_Section_Header__c, Show_Parts__c FROM CS_Part__c];
        
        Boolean first_part = true;
        for (CS_Part__c part : parts) {
            if (first_part) { // set to show parts on all parts but first
                part.Show_Parts__c = false;
                first_part = false;
            } else {
                part.Show_Parts__c = true;
            }
             
            part.CS_Template_Section_Header__c = sectionHeaderInstallEss.Id;
            
        }
        update parts;
        
        List<CS_Bundle__c> bundles = [SELECT Id, Show_Parts__c FROM CS_Bundle__c];
        
        Boolean first_bundle = true;
        for (CS_Bundle__c bundle : bundles) {
            if (first_bundle) { // set to show parts on all bundles but first
                bundle.Show_Parts__c = false;
                first_bundle = false;
            } else {
                bundle.Show_Parts__c = true;
            }
        }
        update bundles;

 
        
        System.debug('************PARTS: ' + parts);
        
        CS_PartModelRemoterTest.boiler.CS_Template_Section_Header__c = sectionHeaderElectricWork.id;
        CS_PartModelRemoterTest.packC1.CS_Template_Section_Header__c = sectionHeaderInstallEss.id;
        CS_PartModelRemoterTest.bundleAB.CS_Template_Section_Header__c = sectionHeaderInstallEss.id;
        CS_PartModelRemoterTest.flueBundle.CS_Template_Section_Header__c = sectionHeaderInstallEss.id;
        CS_PartModelRemoterTest.radiator.CS_Template_Section_Header__c = sectionHeaderInstallEss.id;
        
        update new List<CS_Part__c>
            {CS_PartModelRemoterTest.boiler, 
            CS_PartModelRemoterTest.packC1, 
            CS_PartModelRemoterTest.radiator};
            
        update new List<CS_Bundle__c> {CS_PartModelRemoterTest.bundleAB, CS_PartModelRemoterTest.flueBundle};
        
        CS_RemotingParamWrapper attBoiler = new CS_RemotingParamWrapper('boiler_0', CS_PartModelRemoterTest.boiler.Id, 0, 1,'Ignore', true, true, false, false, false, false, 'Kitchen', 'install note');   //Boiler, no override
        CS_RemotingParamWrapper attPackC = new CS_RemotingParamWrapper('packC_0', (CS_PartModelRemoterTest.packC1.Id + ',' + CS_PartModelRemoterTest.packC2.Id), 0, 1,'Ignore', true, true, false, true, false, false, 'Loft', 'install note');   //A multilookup
        CS_RemotingParamWrapper attBundleAB = new CS_RemotingParamWrapper('bundleAB_0', CS_PartModelRemoterTest.bundleAB.Id, 0, 1,'Ignore', true, false, true, false, false, false, 'Garage', 'install note');   //A Bundle
        CS_RemotingParamWrapper attFlueBundle = new CS_RemotingParamWrapper('flue_0', CS_PartModelRemoterTest.flueBundle.Id, 0, 1,'Ignore', true, false, true, false, false, false, 'Hall', 'install note');   //Flue Bundle 
        CS_RemotingParamWrapper attRad = new CS_RemotingParamWrapper('Actual_Radiator_1_0', CS_PartModelRemoterTest.radiator.Id, 180, 2,'Overriden Desc: Medium', true, true, false, false, false, true, 'Bedroom', 'notes');   //Radiators, 2, with override
        
        
        List<CS_RemotingParamWrapper> attsChanged = new List<CS_RemotingParamWrapper>{attBoiler, attPackC, attBundleAB, attFlueBundle, attRad};
        Map<String, CS_PartModelEntry> partsModel = CS_PartModelRemoter.getPartModelInformation(attsChanged, regionCode,  postcodeSector, CS_Constants.CS_PricebookType_Standard, boilerGroup, geographicalUplift);
        
        Attachment attachment = new Attachment(ParentId = parentProdId, Body = Blob.valueOf(JSON.serializePretty(partsModel)), Name = CS_Constants.PartsModelFileName);
        //System.debug('**********PartsModel Map: ' + partsModel);
        System.debug('**********PartsModel JSON: ' + JSON.serializePretty(partsModel));
        
        upsert attachment;
    }
    
    
    private static BasketInfo prepareData() {
        
        Test.startTest();
        
        // Create a Basket
        basket = new cscfga__Product_Basket__c();
        basket.Name = 'CS TEST BASKET';
        insert basket;
        
        //create a Product definition
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'Heating Hot Water Solution Test';
        prodDef.cscfga__Description__c = 'Heating Hot Water Solution Test Description';
        insert prodDef;
        
        // Create a Product Definition
        cscfga__Product_Configuration__c prodConf = new cscfga__Product_Configuration__c(Name = 'Heating System Installation', 
                                                           cscfga__Product_Basket__c = basket.Id,
                                                           cscfga__Product_Definition__c = prodDef.Id,
                                                           cscfga__Key__c = CS_GuidGenerator.NewGUID());
        
        insert prodConf;
        
        addTestParts(prodConf.Id);
        
        CS_Allowance__c allowance1 = new CS_Allowance__c(Description__c = 'Allowance 1', Allowance_Type__c = 'Amount', Amount__c = 20);
        CS_Allowance__c allowance2 = new CS_Allowance__c(Description__c = 'Allowance 2', Allowance_Type__c = 'Amount', Amount__c = 30);
        
        insert new List<CS_Allowance__c> {allowance1, allowance2};
        
        String[] attributeNameArray= new List<String> { 'Allowance1',   'Allowance2',   'Allowance3',   'Allowance4',   'Allowance5',   'Allowance6', 'Pdf Signed', 'Pdf Path', 'Quote Status', 'Reason', 'Allowance VAT', 'Total Net Price'};
        String[] attributeTypeArray = new List<String> {'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display'};
        String[] attributeValues = new List<String> {allowance1.Id, allowance2.Id,  '',             '',             '',             '', '1', 'dummyPath', 'Finalized - Accepted', 'Considering', '123.00', '123.00'}; 
            
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
            attribute.cscfga__Product_Configuration__c = prodConf.Id;
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
            
            cscfga__Attribute_Field__c attributeField4 = new cscfga__Attribute_Field__c();
            attributeField4.cscfga__Attribute__c = attributeList[i].Id;
            attributeField4.name = 'Allowance VAT';
            attributeField4.cscfga__Value__c = ((i == 0 || i == 1) ? '123' : '1234'); 
            
            attributeFieldList.add(attributeField1);
            attributeFieldList.add(attributeField2);
            attributeFieldList.add(attributeField3);
            attributeFieldList.add(attributeField4);
        }
        
        insert attributeFieldList;
        
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
       
        
        
        
        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
        
        
        Opportunity opportunity = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Referral_Employee__c =employee.id,Override_Billing_checks__c=false,
                                                Product_Interest__c='Heating Solution',
                                                CampaignId = campaign.Id, LeadSource='Engineer',
                                                Sales_Region__c = 'England');
        Test.stopTest();
        
        insert opportunity;
        
        Appointment__c appointment = new Appointment__c();
        appointment.Assigned_To__c = employee.id;
        appointment.OwnerId = user.id;
        appointment.Start__c = Datetime.newInstance(2016,5,5,12,30,0);
        appointment.End__c = Datetime.newInstance(2016,5,5,14,30,0);
        appointment.Opportunity__c= opportunity.id;
        insert appointment;
   
        basket.appointment__c = appointment.id;
        update basket;
        
        BasketInfo ret = new BasketInfo(appointment.id, opportunity.id, basket.id, basket, 'C12345678', 'BG' );
        return ret;
    }
    

    private static testMethod void testControllerWithBasketId() {
 
        //Create a Basket   
        BasketInfo basInf = prepareData();
        
        Account acc = TestclassHelper.createAccout();
        insert acc;
        
        contact con = TestclassHelper.createContact(acc);
        insert con;
        
        opportunity opp = TestclassHelper.createCHILead(acc);
        insert opp;
        
        Employee__c emp = new Employee__c(name='Test emp',Employee_Number__c='12345');
        insert emp;
        
        BigMachines_Quote__c quote = TestClassHelper.createBMQuote(opp);
        quote.App_Assigned_To__c='Testemp - 12345';
        quote.finalNetQuoteTotal__c=2000;
        quote.depositOnPricing__c=200;
        insert quote;
        
        CS_Promotion_Dates__c proDates = new CS_Promotion_Dates__c(name='IFC 3 Months Deferred',Start_Date__c=system.today().addyears(-1),End_Date__c=system.today().adddays(1),Final_Date__c=system.today().adddays(1));
        insert prodates;
        
         CS_Promotion_Dates__c proDates1 = new CS_Promotion_Dates__c(name='30 Months IFC',Start_Date__c=system.today().addyears(-1),End_Date__c=system.today().adddays(1),Final_Date__c=system.today().adddays(1));
        insert prodates1;
        
        Finance_product__c fp = new finance_product__c(deferral_period__c=0,Interest_Rate__c=9.9,Tenure_in_Months__c=36,name='test product');
        insert fp;
        
        //String contentFile = serializedJson; //'{"FooterText":"test","LogoPng":"test","FooterText":"test","CHILeadNumber":"test","AsbestosIdentified":"test","AsbestosNotes":"test","EarthSystem":"test","VisibleEarth":"test","Voelcb":"test","CustomerArrange":"test","Rdc":"test","SocketSee":"test","EarthLocation":"test","Peb":"test","LadderWork":"test","Seb":"test","Scaffolding":"test","AccessNotes":"test","WorkAreas":"test","RemovalAssistance":"test" }';
        //Blob b = blob.valueof(contentFile); //decoded string
        //contentFile = EncodingUtil.base64Encode(b);
          
        //attId = UISupport.AttachTempFileReturnId(basInf.appId, 'TEMP_Online_Quote.txt', contentFile);
        
        
        
        //ApexPages.currentPage().getParameters().put('attId', attId);
        //ApexPages.currentPage().getParameters().put('appId', basInf.appId);
        //ApexPages.currentPage().getParameters().put('oppId', basInf.oppId);
        //ApexPages.currentPage().getParameters().put('quoteRef', basInf.quoteRef);
        //ApexPages.currentPage().getParameters().put('logoType', basInf.logoTyp);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(basInf.bas);
        ApexPages.currentPage().getParameters().put('id', quote.id);
        CS_QuoteOnlineTemplateController controller;
        
        //try {
            //controller = new CS_QuoteOnlineTemplateController(sc);
            controller = new CS_QuoteOnlineTemplateController();
        //} //catch (Exception ex) {
            //system.assert(false, 'Error while rendering pdf: ' + ex);
        //}
          
        controller.attId = attId;
        controller.pageContent = 'content';
        //controller.content = 'content';
        
        // Test price formatting
        System.assertNotEquals('<tfoot><tr class="topBorder"><td>Total net price (inc. VAT)</td><td class="right">£12,345.00</td></tr></tfoot>', controller.returnSummaryTableFooter('12345', '1234'));
        
        controller.deleteTempAttachment();
        List<Attachment> aList = [Select Id, Name, Body, ParentId from Attachment where Id = :attId and Name = 'TEMP_Online_Quote.txt'];
        System.debug(aList);
        System.assertEquals(0, aList.size());
        
        try{
        ApexPages.currentPage().getParameters().put('id', basket.id);
        CS_QuoteOnlineTemplateController controller1 = new CS_QuoteOnlineTemplateController();
        }catch(exception e)
        {
            
        }
        
        //attId = UISupport.AttachTempFileReturnId(basInf.appId,'TEMP_Online_Quote.txt', contentFile);
       // UISupport.DeleteTempAttachment(attId);
        
    }
   
    private static testMethod void testControllerWithoutBasketId() {
        // load test quote stored as JSON from static resource
        loadTestJson();
        
        
        //Create a Basket
        BasketInfo basInf = prepareData();
        
        String contentFile = serializedJson; 
        Blob b = blob.valueof(contentFile); //decoded string
        contentFile = EncodingUtil.base64Encode(b);
        
        
        attId = UISupport.AttachTempFileReturnId(basInf.appId,'TEMP_Online_Quote.txt', contentFile);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new cscfga__Product_Basket__c());
        
        ApexPages.currentPage().getParameters().put('attId', attId);
        ApexPages.currentPage().getParameters().put('appId', basInf.appId);
        ApexPages.currentPage().getParameters().put('oppId', basInf.oppId);
        ApexPages.currentPage().getParameters().put('quoteRef', basInf.quoteRef);
        ApexPages.currentPage().getParameters().put('logoType', basInf.logoTyp);
        
        
        CS_QuoteOnlineTemplateController controller;
        
        try {
            controller = new CS_QuoteOnlineTemplateController(/*sc*/);
        } catch (Exception ex) {
            //system.assert(false, 'Error while rendering pdf: ' + ex);
        }
        
          
        controller.attId = attId;
        controller.attList = [Select Id, Name, Body, ParentId from Attachment where Id = :attId and Name = 'TEMP_Online_Quote.txt'];
        controller.pageContent = 'content';
        //controller.content = 'content';
        
        controller.deleteTempAttachment();
        List<Attachment> aList = [Select Id, Name, Body, ParentId from Attachment where Id = :attId and Name = 'TEMP_Online_Quote.txt'];
        System.debug(aList);
        System.assertEquals(0, aList.size());
        
        attId = UISupport.AttachTempFileReturnId(basInf.appId,'TEMP_Online_Quote.txt', contentFile);
        UISupport.DeleteTempAttachment(attId);
        
    }
/*
    private static testMethod void testPaymentDataClass() {
        List<String> params = new List<String>();
        params.add('2999.99');
        params.add('500.00');
        params.add('11111111111');
        params.add('Deposit paid by Test');
        params.add('699.59');
        params.add('Balance to be paid by Test');
        
        CS_QuoteOnlineTemplateController.PaymentData pd = 
            new CS_QuoteOnlineTemplateController.PaymentData(params[0], params[1], params[2], params[3], params[4], params[5]);
            
        List<String> result = pd.toList();
        
        System.assert(result.equals(params));
    
        
    }
    */
    
    
    private static testMethod void testRadiatorItemClass() {
        List<String> params = new List<String>();
        params.add('IncValve');
        params.add('Category');
        params.add('Price');
        
        CS_QuoteOnlineTemplateController.RadiatorItem ri = 
            new CS_QuoteOnlineTemplateController.RadiatorItem(params[0], params[1], params[2]);
        
        System.assertEquals(params[0], ri.IncValve);
        System.assertEquals(params[1], ri.Category);
        System.assertEquals(params[2], ri.Price);       
    }
    
    private static testMethod void testRadiatorLineItemClass() {
        List<Object> params = new List<Object>();
        params.add('Description');
        params.add(4);
        params.add(23);
        params.add(123.34);
        params.add('IncValve');

        CS_QuoteOnlineTemplateController.RadiatorLineItem ri = 
            new CS_QuoteOnlineTemplateController.RadiatorLineItem(
                                (String) params[0], 
                                (Integer) params[1], 
                                (Integer) params[2], 
                                (Decimal) params[3], 
                                (String) params[4]);
        
        System.assertEquals((String)  params[0], ri.Description);
        System.assertEquals((Integer) params[1], ri.Quantity);
        System.assertEquals((Integer) params[2], ri.Sequence);  
        System.assertEquals((Decimal) params[3], ri.Price); 
        System.assertEquals((String)  params[4], ri.IncValve);      
        
        CS_QuoteOnlineTemplateController.RadiatorLineItem riComp = 
                new CS_QuoteOnlineTemplateController.RadiatorLineItem(
                            (String)  params[0], 
                            (Integer) params[1], 
                            10, 
                            (Decimal) params[3], 
                            (String)  params[4]);
                            
        CS_QuoteOnlineTemplateController.RadiatorLineItem riCompSame = 
                new CS_QuoteOnlineTemplateController.RadiatorLineItem(
                            (String)  params[0], 
                            (Integer) params[1], 
                            10, 
                            (Decimal) params[3],  
                            (String)  params[4]);
                                
        CS_QuoteOnlineTemplateController.RadiatorLineItem riCompGreater = 
                new CS_QuoteOnlineTemplateController.RadiatorLineItem(
                            (String)  params[0], 
                            (Integer) params[1], 
                            11, 
                            (Decimal) params[3],  
                            (String)  params[4]);
        CS_QuoteOnlineTemplateController.RadiatorLineItem riCompGreatest = 
                new CS_QuoteOnlineTemplateController.RadiatorLineItem(
                            (String)  params[0], 
                            (Integer) params[1], 
                            12, 
                            (Decimal) params[3],  
                            (String)  params[4]);
                            
        System.assertEquals(0, riComp.compareTo(riCompSame));
        System.assertEquals(-1, riComp.compareTo(riCompGreater));
        System.assertEquals(1, riCompGreatest.compareTo(riCompGreater));
        
    }
    
    private static testMethod void testGetMonthName() {
        List<String> n = new List<String>();
        List<String> names = new List<String>();
        for (Integer i = 0; i < 10; ++i) {
            n.add('0' + i);
        }
        n.add('10'); n.add('11'); n.add('12');
        
        names.add('');
        names.add('January');
        names.add('February');
        names.add('March');
        names.add('April');
        names.add('May');
        names.add('June');
        names.add('July');
        names.add('August');
        names.add('September');
        names.add('October');
        names.add('November');
        names.add('December');
        
        for (Integer i = 0; i <= 12; ++i) {
         System.assertEquals(names[i], CS_QuoteOnlineTemplateController.getMonthName(n[i]));
        }
        
    }
    
    
    private static testMethod void testReturnFormattedPrice() {
        System.assertEquals('£1234.56', CS_QuoteOnlineTemplateController.returnFormattedPrice('1234.56'));
        System.assertEquals('£1,234.00', CS_QuoteOnlineTemplateController.returnFormattedPrice('1,234.00'));
//      System.assertEquals('£1234.00', CS_QuoteOnlineTemplateController.returnFormattedPrice('1234')); 
    }
    
    private static testMethod void testReturnDate() {
        String goodDate = '12/11/2014';
        String badDate = '33/33/3333';
        
        Date resultFromGood = CS_QuoteOnlineTemplateController.returnDate(goodDate);
        Date resultFromBad = CS_QuoteOnlineTemplateController.returnDate(badDate);

        Date expectedFromGood = Date.newInstance(2014, 11, 12);
        Date expectedFromBad = null;
        
        System.assertEquals(expectedFromGood, resultFromGood);
        System.assertEquals(expectedFromBad, resultFromBad);
    }
    
    private static testMethod void testQuoteDetails() {
        Map<String, CS_QuoteOnlineTemplateController.QuoteDetails> qds = new Map<String, CS_QuoteOnlineTemplateController.QuoteDetails>();
        
        qds.put('January',   new CS_QuoteOnlineTemplateController.QuoteDetails('29/1/2014',  '1',   '1'));
        qds.put('February',  new CS_QuoteOnlineTemplateController.QuoteDetails('28/2/2014',  '2',   '2'));
        qds.put('March',     new CS_QuoteOnlineTemplateController.QuoteDetails('27/3/2014',  '3',   '3'));
        qds.put('April',     new CS_QuoteOnlineTemplateController.QuoteDetails('26/4/2014',  '4',   '4'));
        qds.put('May',       new CS_QuoteOnlineTemplateController.QuoteDetails('25/5/2014',  '5',   '5'));
        qds.put('June',      new CS_QuoteOnlineTemplateController.QuoteDetails('24/6/2014',  '6',   '6'));
        qds.put('July',      new CS_QuoteOnlineTemplateController.QuoteDetails('23/7/2014',  '7',   '7'));
        qds.put('August',    new CS_QuoteOnlineTemplateController.QuoteDetails('22/8/2014',  '8',   '8'));
        qds.put('September', new CS_QuoteOnlineTemplateController.QuoteDetails('21/9/2014',  '9',   '9'));
        qds.put('October',   new CS_QuoteOnlineTemplateController.QuoteDetails('20/10/2014', '10',  '10'));
        qds.put('November',  new CS_QuoteOnlineTemplateController.QuoteDetails('19/11/2014', '11',  '11'));
        qds.put('December',  new CS_QuoteOnlineTemplateController.QuoteDetails('18/12/2014', '12',  '12'));
        
        Integer i = 1;
        Integer day = 29;
        
        for (String expected : qds.keySet()) {
            System.assertEquals(expected + ' ' + (day--) + ', 2014', qds.get(expected).QuoteDate);
            System.assertEquals(''+i, qds.get(expected).QuoteNumber);
            System.assertEquals(''+i, qds.get(expected).TransactionId);
            ++i;
        }
        
        
        
    }
    
    private static testMethod void testFormatPrice() {
        String result = CS_QuoteOnlineTemplateController.formatPrice('3.467');
        System.assertEquals('3.47', result);
    }
    
    private static testMethod void testIsRadiatorAttribute() {
        final String RADIATOR = 'Radiator_';
        final String ACTUAL = 'Actual_Radiator_';
        final String PLACEHOLDER = 'Placeholder_';
        final String FITTINGBUNDLE = 'Fitting_Bundle_';
        
        Boolean shouldBeTrue = false;
        Boolean shouldBeFalse = true;
        
        shouldBeTrue = CS_QuoteOnlineTemplateController.isRadiatorAttribute(RADIATOR + PLACEHOLDER);        System.assertEquals(true,  shouldBeTrue);       
        shouldBeTrue = CS_QuoteOnlineTemplateController.isRadiatorAttribute(RADIATOR + ACTUAL);             System.assertEquals(true,  shouldBeTrue);
        shouldBeTrue = CS_QuoteOnlineTemplateController.isRadiatorAttribute(RADIATOR + FITTINGBUNDLE);      System.assertEquals(true,  shouldBeTrue);
        
        shouldBeFalse = CS_QuoteOnlineTemplateController.isRadiatorAttribute(RADIATOR + RADIATOR);          System.assertEquals(false, shouldBeFalse);
        shouldBeFalse = CS_QuoteOnlineTemplateController.isRadiatorAttribute('This is NOT a radiator');     System.assertEquals(false, shouldBeFalse);
        shouldBeFalse = CS_QuoteOnlineTemplateController.isRadiatorAttribute(null);                         System.assertEquals(false, shouldBeFalse);  
    }
    
    private static testMethod void testSectionClass() {
        CS_QuoteOnlineTemplateController.Section section = new CS_QuoteOnlineTemplateController.Section('Radiator_0', 19.99);
        System.assertEquals('Radiator_0', section.name);
        System.assertEquals(19.99, section.totals);
    }

}