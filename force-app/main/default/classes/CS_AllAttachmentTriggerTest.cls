@isTest
public class CS_AllAttachmentTriggerTest {
    
    public static String pricebookType = 'Standard';
    public static String boilerGroup = 'Worcester';
    public static String regionCode = 'South London';
    public static String postcodeSector = 'SW London';
    public static Decimal geographicalUplift = 6;
    
    public static CS_VAT_Code__c vat1;
    public static CS_VAT_Code__c vat2;
    public static CS_Bundle__c bundleAB;
    public static CS_Bundle__c flueBundle;
    public static CS_Part__c boiler;
    public static CS_Part__c plcRadMedium;
    public static CS_Part__c radiator;
    public static CS_Part__c packC1;
    public static CS_Part__c packC2;

    
    /**
     * Description: Turn off Triggers
     * Author: Sasa Marjancic
     * Date: 27/08/2014
     * @param UserId Id
     * Example: setTriggersOff(UserInfo.getUserId());
     */
    public static void setTriggersOff(Id UserId) {
        List<No_Triggers__c> noTriggerFlag = [Select SetupOwnerId, Name, Id, Flag__c From No_Triggers__c
                                              Where SetupOwnerId = :UserId Limit 1];
        if(noTriggerFlag.isEmpty() == false) {
            noTriggerFlag[0].Flag__c = true;
            update noTriggerFlag;
        }

        else {
            No_Triggers__c noTrigger = new No_Triggers__c(SetupOwnerId = UserId, Name = 'No Triggers (User)', Flag__c = true);
            insert noTrigger;
        }
    }

    /**
     * Description: Turn on Triggers
     * Author: Sasa Marjancic
     * Date: 27/08/2014
     * @param UserId Id
     * Example: setTriggersOn(UserInfo.getUserId());
     */
    public static void setTriggersOn(Id UserId) {
        List<No_Triggers__c> noTriggerFlag = [Select SetupOwnerId, Name, Id, Flag__c From No_Triggers__c
                                              Where SetupOwnerId = :UserId Limit 1];
        if(noTriggerFlag.isEmpty() == false) {
            noTriggerFlag[0].Flag__c = false;
            update noTriggerFlag;
        }

    }

    static cscfga__Product_Configuration__c createBasketData() {
        
        Decimal grossTotal = 2000.00;
        Decimal totalAllowance = 700.00;
        
        String[] attributeNameArray= new List<String> { 'Allowance1',   'Allowance2',   'Allowance3',   'Allowance4',   'Allowance5',   'Allowance6',   'Gross Price incl VAT',     'Total Allowance Value',        'Reason',     'Quote Status',                                'Quote Creation Date',         'Delivery Date',    'Delivery Notes',       'Installation Date',   'Special Notes for Installer',  'Customer Date of Birth',       'Payment Type', 'Payment Option',   'HEAT Pricebook',   'System Type Required', 'Other Form of Heating',    'Hot Water Available',  'Existing Efficiency Rating',   'Existing Gas Council Number',  'Boiler Working',   'Vulnerable Customer',  'Job Type Required',    'Latest Customer Category', 'RHC Mobile', 'RHC Username',   'Vulnerable Reasons', 'Pdf Signed'};
        String[] attributeTypeArray = new List<String> {'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display',             'Text Display',                 'User Input', 'Select List',                                 'Calculation',                 'Date',             'User Input',           'Date',                'User Input',                   'Date',                         'Select List',  'Select List',      'Calculation',      'Select List',          'Select List',              'Select List',          'Select List',                  'User Input',                   'Select List',      'Select List',          'Select List',          'Select List',              'User Input', 'User Input',     'Select List', 'Calculation' };
        String[] attributeValues = new List<String> {   '',             '',             '',             '',             '',             '',             String.valueOf(grossTotal), String.valueOf(totalAllowance), 'Valid',       CS_Constants.QuoteStatus_FinalizedAccepted,   '2014-05-05',                  '2014-06-06',       'Test delivery note',   '2014-08-08',          'Special installer notes test', '1982-01-01',                   'Cash',         '--None--',         'CHB',              'Combination',          'Yes',                      'Yes',                  'C',                            '84527',                        'Yes',              'No',                   '5',                    '99',                       '0173954638', 'user@rhc.com',   'Age', '1'};     
            
        // createa a district 
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        
        //create a subpatch
        Sub_Patch__c sbp = new Sub_Patch__c();
        sbp.District__c = district.Id;
        sbp.Code__c ='12353';
        insert sbp;
        
        //create a postcode sector
        Postcode_Sector__c pstcd = new Postcode_Sector__c();
        pstcd.Name = 'UB7 7';
        pstcd.Sub_Patch__c = sbp.Id;
        pstcd.Type__c='Installation';
        insert pstcd;
            
        // create an Employee
        Employee__c emp = new Employee__c();
        emp.Name = 'test employee';
        emp.Employee_Number__c = '12312321';
        insert emp;
        
        // create a Contact 
        Contact c = new Contact();
        c.LastName = 'contact last name';
        insert c;
            
        // create an account
        Account acc = new Account();
        acc.Name = 'UB7 7QG 9A High';
        //acc.Account_Key_Calc__c = 'UB7 7QG 9A High';
        acc.BillingPostalCode = 'UB7 7QG';
        acc.BillingState = 'West Drayton';
        acc.BillingStreet = '9A High Street Yiewsley';
        //acc.District_Code__c = 'R03D08';
        acc.Name = 'UB7 7QG 9A High';
        //acc.Region_Code__c = 'R03';
        insert acc;
        
        // create an opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.LeadSource = 'Engineer';
        opp.Referral_Employee__c = emp.Id;
        opp.Product_Interest__c = 'Central Heating Boiler';
        opp.StageName = 'Deposit Taken';
        opp.Name = '44829956 - Test 2 - UB7 7QG - (R03D08_S01)';
        opp.CloseDate = date.today();
        insert opp;
        
        
        // create an appointment
        Appointment__c app = new Appointment__c();
        app.Opportunity__c = opp.Id;
        app.Start__c = date.today();
        app.End__c= date.today().addDays(1);
        app.Type__c = 'Installation';
        app.Who__c = c.Id;
        app.Visit_Type__c = 'Recall Visit';
        insert app;
            

		List<CS_Allowance__c> allowances = new List<CS_Allowance__c>();

		allowances.add(new CS_Allowance__c(Name = 'Test 1 Allowance', 
											Allowance_Type__c = 'Amount', 
											Amount_Type__c = 'Fixed', 
											Amount__c = 2.01,
											Requires_Voucher_ID__c = True,
											Requires_Employee_ID__c = True));

		allowances.add(new CS_Allowance__c(Name = 'Test 2 Allowance', 
											Allowance_Type__c = 'Amount', 
											Amount_Type__c = 'Fixed', 
											Amount__c = 3.01,
											Requires_Voucher_ID__c = True,
											Requires_Employee_ID__c = True));

		allowances.add(new CS_Allowance__c(Name = 'Test 3 Allowance', 
											Allowance_Type__c = 'Amount', 
											Amount_Type__c = 'Fixed', 
											Amount__c = 4.01,
											Requires_Voucher_ID__c = True,
											Requires_Employee_ID__c = True));

		allowances.add(new CS_Allowance__c(Name = 'Test 4 Allowance', 
											Allowance_Type__c = 'Amount', 
											Amount_Type__c = 'Fixed', 
											Amount__c = 5.01,
											Requires_Voucher_ID__c = True,
											Requires_Employee_ID__c = True));

		allowances.add(new CS_Allowance__c(Name = 'Test 5 Allowance', 
											Allowance_Type__c = 'Amount', 
											Amount_Type__c = 'Fixed', 
											Amount__c = 6.01,
											Requires_Voucher_ID__c = True,
											Requires_Employee_ID__c = True));

		allowances.add(new CS_Allowance__c(Name = 'Test 6 Allowance', 
											Allowance_Type__c = 'Amount', 
											Amount_Type__c = 'Fixed', 
											Amount__c = 7.01,
											Requires_Voucher_ID__c = True,
											Requires_Employee_ID__c = True));

		insert allowances;

		// set allowance id's to values of the attributes in attributeValues list

		for (Integer i = 0; i < 6; ++i) {
			attributeValues[i] = allowances[i].id;
		}
            
         //Create a Basket
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c();
        prodBasket.Name = 'test';
        prodBasket.Appointment__c = app.Id;
         //added 2017
        prodBasket.cscfga__Opportunity__c = opp.Id;
        //end
        insert prodBasket;
        
        //create a Product definition
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        //prodDef.Name = 'Heating Hot Water Solution Test';
        prodDef.Name = 'Heating Solution';
        prodDef.cscfga__Description__c = 'Heating Solution';
        //prodDef.cscfga__Description__c = 'Heating Hot Water Solution Test Description';
        insert prodDef;

		
        
        //create a Product Configuration
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c();
        prodConfig.Name = 'Heating Solution';
        //prodConfig.Name = 'Heating Hot Water Solution Product Configuration';
        prodConfig.cscfga__Product_Definition__c = prodDef.Id;
        prodConfig.cscfga__Product_Basket__c = prodBasket.Id;
        insert prodConfig;
        
        System.debug('****AN created product config');

		//// create a Controls product definition
		//cscfga__Product_Definition__c controlsProdDef = new cscfga__Product_Definition__c();
        ////prodDef.Name = 'Heating Hot Water Solution Test';
        //controlsProdDef.Name = 'Controls ';
        //controlsProdDef.cscfga__Description__c = 'Controls ';
        ////prodDef.cscfga__Description__c = 'Heating Hot Water Solution Test Description';
        //insert controlsProdDef;
 
        ////create a Controls Product Configuration
        //cscfga__Product_Configuration__c controlsProdConfig = new cscfga__Product_Configuration__c();
        //controlsProdConfig.Name = 'Controls ';
        ////prodConfig.Name = 'Heating Hot Water Solution Product Configuration';
        //controlsProdConfig.cscfga__Product_Definition__c = controlsProdDef.Id;
		//controlsProdConfig.cscfga__Root_Configuration__c = prodConfig.Id;
		//controlsProdConfig.cscfga__Parent_Configuration__c = prodConfig.Id;
        //controlsProdConfig.cscfga__Product_Basket__c = prodBasket.Id;
        //insert controlsProdConfig;
		


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
            
            //uncommented
            attribute.cscfga__is_Line_Item__c = True;
            attribute.cscfga__Price__c = 10.0;
            attribute.cscfga__Line_Item_Description__c = 'attributeDescription';
            //end uncommented
            
            attribute.cscfga__value__c = attributeValues[i];
            attributeList.add(attribute);
        }
        insert attributeList;
         System.debug('****AN created attributes');
        

		List<cscfga__Attribute_Field__c> attributeFields = new List<cscfga__Attribute_Field__c>();

		// add attr fields to allowances
		for (Integer i = 0; i < 6; ++i) {
			attributeFields.add(new cscfga__Attribute_Field__c(
				Name = 'ActualAmount',
				cscfga__Attribute__c = attributeList[i].Id,
				cscfga__Value__c = '400.00'));

			attributeFields.add(new cscfga__Attribute_Field__c(
				Name = 'AllowanceDescription',
				cscfga__Attribute__c = attributeList[i].Id,
				cscfga__Value__c = 'Allowance Description'));

			attributeFields.add(new cscfga__Attribute_Field__c(
				Name = 'AllowanceName',
				cscfga__Attribute__c = attributeList[i].Id,
				cscfga__Value__c = 'Allowance Name'));
					
			attributeFields.add(new cscfga__Attribute_Field__c(
				Name = 'Code',
				cscfga__Attribute__c = attributeList[i].Id,
				cscfga__Value__c = '234234'));
					
			attributeFields.add(new cscfga__Attribute_Field__c(
				Name = 'Is_Applied',
				cscfga__Attribute__c = attributeList[i].Id,
				cscfga__Value__c = 'TRUE'));
					
			attributeFields.add(new cscfga__Attribute_Field__c(
				Name = 'MaxAmount',
				cscfga__Attribute__c = attributeList[i].Id,
				cscfga__Value__c = '500.00'));	
		}

		insert attributeFields;

		System.debug('&&&&Attribute Fields ' + attributeFields); 

		//use the method from CS_PartModelRemoterTest check if it needs additional things
        CS_PartModelRemoterTest.createData();
        
        return prodConfig;
        /*
        System.debug('****-AN-ENTERED TEST!');
        
        // create an Employee
        Employee__c emp = new Employee__c();
        emp.Name = 'test employee';
        emp.Employee_Number__c = '12312321';
        insert emp;
        
        // create a Contact 
        Contact c = new Contact();
        c.LastName = 'contact last name';
        insert c;
            
        // create an account
        Account acc = new Account();
        acc.Name = 'UB7 7QG 9A High';
        //acc.Account_Key_Calc__c = 'UB7 7QG 9A High';
        acc.BillingPostalCode = 'UB7 7QG';
        acc.BillingState = 'West Drayton';
        acc.BillingStreet = '9A High Street Yiewsley';
        //acc.District_Code__c = 'R03D08';
        acc.Name = 'UB7 7QG 9A High';
        //acc.Region_Code__c = 'R03';
        insert acc;
        
        // create an opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.LeadSource = 'Engineer';
        opp.Referral_Employee__c = emp.Id;
        opp.Product_Interest__c = 'Central Heating Boiler';
        opp.StageName = 'Deposit Taken';
        opp.Name = '44829956 - Test 2 - UB7 7QG - (R03D08_S01)';
        opp.CloseDate = date.today();
        insert opp;
        
        
        // create an appointment
        Appointment__c app = new Appointment__c();
        app.Opportunity__c = opp.Id;
        app.Start__c = date.today();
        app.End__c= date.today().addDays(1);
        app.Type__c = 'Installation';
        app.Who__c = c.Id;
        app.Visit_Type__c = 'Recall Visit';
        insert app;
            
            
         //Create a Basket
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c();
        prodBasket.Name = 'test';
        prodBasket.Appointment__c = app.Id;
        //added 2017
        prodBasket.cscfga__Opportunity__c = opp.Id;
        //end
        insert prodBasket;
        
        //create a Product definition
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'Heating Hot Water Solution Test';
        prodDef.cscfga__Description__c = 'Heating Hot Water Solution Test Description';
        insert prodDef;
        
        //create a Product Configuration
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c();
        prodConfig.Name = 'Heating Hot Water Solution Product Configuration';
        prodConfig.cscfga__Product_Definition__c = prodDef.Id;
        prodConfig.cscfga__Product_Basket__c = prodBasket.Id;
        insert prodConfig;
        
        System.debug('****AN Created config =='+prodConfig);
        return prodConfig;
*/
    }
    
    //Tests scenario where both partsModel.txt and QuotePdf are uploaded concurrently
   
    static testMethod void testBothAttachmentsUploadedInBatch() {
        
        cscfga__Product_Configuration__c prodConfig = createBasketData();
        
        //use the method from CS_PartModelRemoterTest check if it needs additional things
        //setTriggersOff(UserInfo.getUserId());
        //CS_PartModelRemoterTest.createData();
        //setTriggersOn(UserInfo.getUserId());
        
        //atbRef, atbVal, atbPrice, attQuantity, attDesc, attIsLineItem, attIsPart, attIsBundle, attIsMultiLookup, attIsPlaceholder, attIsPriceOverriden, installLocation, installationNotes
        CS_RemotingParamWrapper attBoiler = new CS_RemotingParamWrapper('boiler_0', CS_PartModelRemoterTest.boiler.Id, 0, 1,'Ignore', true, true, false, false, false, false, 'Kitchen', 'install note');   //Boiler, no override
        CS_RemotingParamWrapper attPackC = new CS_RemotingParamWrapper('packC_0', (CS_PartModelRemoterTest.packC1.Id + ',' + CS_PartModelRemoterTest.packC2.Id), 0, 1,'Ignore', true, true, false, true, false, false, 'Loft', 'install note');   //A multilookup
        CS_RemotingParamWrapper attBundleAB = new CS_RemotingParamWrapper('bundleAB_0', CS_PartModelRemoterTest.bundleAB.Id, 0, 1,'Ignore', true, false, true, false, false, false, 'Garage', 'install note');   //A Bundle
        CS_RemotingParamWrapper attFlueBundle = new CS_RemotingParamWrapper('flue_0', CS_PartModelRemoterTest.flueBundle.Id, 0, 1,'Ignore', true, false, true, false, false, false, 'Hall', 'install note');   //Flue Bundle 
        List<CS_RemotingParamWrapper> attsChanged = new List<CS_RemotingParamWrapper>{attBoiler, attPackC, attBundleAB, attFlueBundle};
        Map<String, CS_PartModelEntry> partsModel = CS_PartModelRemoter.getPartModelInformation(attsChanged, regionCode,  postcodeSector, CS_Constants.CS_PricebookType_Standard, boilerGroup, geographicalUplift);
        
        //2016-TestCase---
        System.debug('AN****----TEST----partsModel =='+partsModel);
        
        //Create partsModel attachment against Product Configuration
        Attachment partsAttachment = new Attachment();
        partsAttachment.ParentID = prodConfig.Id;
        partsAttachment.Body = Blob.valueOf(JSON.serializePretty(partsModel));
        partsAttachment.Name = CS_Constants.PartsModelFileName; //'partsModel.txt';  
        
        //Create quotePdf attachment against Product Basket
        Attachment pdfAttachment = new Attachment();
        pdfAttachment.ParentID = prodConfig.cscfga__Product_Basket__c;
        pdfAttachment.Body = Blob.valueOf('');
        pdfAttachment.Name = CS_Constants.PdfQuoteFileNamePrefix + ' 123456';  
        
        Test.startTest();  

        //Insert them concurrently
        upsert new List<Attachment> {partsAttachment, pdfAttachment};
         System.debug('AN Attachments upserted =='+partsAttachment+'   '+pdfAttachment);
        Test.stopTest();
        
        // ----------- after the data has been created - assert that everything is working as intended --------------
        String bmQuoteQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('BigMachines_Quote__c') + ' From BigMachines_Quote__c';
        List<BigMachines_Quote__c> bmQuotesList = ((List<BigMachines_Quote__c>)database.query(bmQuoteQuery));
        System.debug('AN BM quote list =='+bmQuotesList);
        List<Attachment> bmQuoteAttachments = [select ParentId, Name from Attachment where ParentId = :bmQuotesList[0].Id];
        
        //check that only one BM Quote was created
        System.assertEquals(1, bmQuotesList.size());
        System.assertEquals(prodConfig.cscfga__Product_Basket__c, bmQuotesList[0].CS_Quote__c);
        
        //check pdf Attachment
        System.assertEquals(1, bmQuoteAttachments.size());
        System.assertEquals(bmQuotesList[0].BigMachines_Transaction_Id__c + '_quote.pdf', bmQuoteAttachments[0].Name);
        
    }
    
    /**
     * Tests scenario where partsModel.txt is uploaded first, followed by QuotePdf
     */
     
    static testMethod void testPartsModelAttachmentArrivesFirst() {
        
        cscfga__Product_Configuration__c prodConfig = createBasketData();
        
        //use the method from CS_PartModelRemoterTest check if it needs additional things
        //Test.startTest();  
        
        //CS_PartModelRemoterTest.createData();
        
        //Test.stopTest();
        
        //atbRef, atbVal, atbPrice, attQuantity, attDesc, attIsLineItem, attIsPart, attIsBundle, attIsMultiLookup, attIsPlaceholder, attIsPriceOverriden, installLocation, installationNotes
        CS_RemotingParamWrapper attBoiler = new CS_RemotingParamWrapper('boiler_0', CS_PartModelRemoterTest.boiler.Id, 0, 1,'Ignore', true, true, false, false, false, false, 'Kitchen', 'install note');   //Boiler, no override
        CS_RemotingParamWrapper attPackC = new CS_RemotingParamWrapper('packC_0', (CS_PartModelRemoterTest.packC1.Id + ',' + CS_PartModelRemoterTest.packC2.Id), 0, 1,'Ignore', true, true, false, true, false, false, 'Loft', 'install note');   //A multilookup
        CS_RemotingParamWrapper attBundleAB = new CS_RemotingParamWrapper('bundleAB_0', CS_PartModelRemoterTest.bundleAB.Id, 0, 1,'Ignore', true, false, true, false, false, false, 'Garage', 'install note');   //A Bundle
        CS_RemotingParamWrapper attFlueBundle = new CS_RemotingParamWrapper('flue_0', CS_PartModelRemoterTest.flueBundle.Id, 0, 1,'Ignore', true, false, true, false, false, false, 'Hall', 'install note');   //Flue Bundle 
        List<CS_RemotingParamWrapper> attsChanged = new List<CS_RemotingParamWrapper>{attBoiler, attPackC, attBundleAB, attFlueBundle};
        Map<String, CS_PartModelEntry> partsModel = CS_PartModelRemoter.getPartModelInformation(attsChanged, regionCode,  postcodeSector, CS_Constants.CS_PricebookType_Standard, boilerGroup, geographicalUplift);
        
        //Firstly, create partsModel attachment against Product Configuration
        Attachment partsAttachment = new Attachment();
        partsAttachment.ParentID = prodConfig.Id;
        partsAttachment.Body = Blob.valueOf(JSON.serializePretty(partsModel));
        partsAttachment.Name = CS_Constants.PartsModelFileName; //'partsModel.txt';  
        Test.startTest();  
        insert partsAttachment;
        
        // ----------- After the data has been created - assert that everything is working as intended --------------
        String bmQuoteQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('BigMachines_Quote__c') + ' From BigMachines_Quote__c ' + 
                                ' Where CS_Quote__c = \'' + prodConfig.cscfga__Product_Basket__c + '\'';
                                
        List<BigMachines_Quote__c> bmQuotesList = ((List<BigMachines_Quote__c>)database.query(bmQuoteQuery));
        
        List<Attachment> bmQuoteAttachments = [select ParentId, Name from Attachment where ParentId = :bmQuotesList[0].Id];
        
        //check that only one product configuration was created
        System.assertEquals(1, bmQuotesList.size());
        System.assertEquals(prodConfig.cscfga__Product_Basket__c, bmQuotesList[0].CS_Quote__c);
        
        //check pdf Attachment not exists
        System.assertEquals(0, bmQuoteAttachments.size());
        
        //Then, create quotePdf attachment against Product Basket
        Attachment pdfAttachment = new Attachment();
        pdfAttachment.ParentID = prodConfig.cscfga__Product_Basket__c;
        pdfAttachment.Body = Blob.valueOf('');
        pdfAttachment.Name = CS_Constants.PdfQuoteFileNamePrefix + ' 123456';  
        
        insert pdfAttachment;
        
        // ----------- after the data has been created - assert that everything is working as intended --------------
        //retrieve BM Quote again
        bmQuotesList = ((List<BigMachines_Quote__c>)database.query(bmQuoteQuery));
        
        bmQuoteAttachments = [select ParentId, Name from Attachment where ParentId = :bmQuotesList[0].Id];
        
        //check that only one BM Quote was created
        System.assertEquals(1, bmQuotesList.size());
        System.assertEquals(prodConfig.cscfga__Product_Basket__c, bmQuotesList[0].CS_Quote__c);
        
        //check pdf Attachment
        System.assertEquals(1, bmQuoteAttachments.size());
        System.assertEquals(bmQuotesList[0].BigMachines_Transaction_Id__c + '_quote.pdf', bmQuoteAttachments[0].Name);
        
        Test.stopTest();
        
    }
    
    /**
     * Tests scenario where Quote pdf is uploaded first, followed by QuotePdf
     */
     
    static testMethod void testQuotePdfAttachmentArrivesFirst() {
        
        cscfga__Product_Configuration__c prodConfig = createBasketData();
        
        //Test.startTest(); 
        
        //use the method from CS_PartModelRemoterTest check if it needs additional things
        //CS_PartModelRemoterTest.createData();
        
        //atbRef, atbVal, atbPrice, attQuantity, attDesc, attIsLineItem, attIsPart, attIsBundle, attIsMultiLookup, attIsPlaceholder, attIsPriceOverriden, installLocation, installationNotes
        CS_RemotingParamWrapper attBoiler = new CS_RemotingParamWrapper('boiler_0', CS_PartModelRemoterTest.boiler.Id, 0, 1,'Ignore', true, true, false, false, false, false, 'Kitchen', 'install note');   //Boiler, no override
        CS_RemotingParamWrapper attPackC = new CS_RemotingParamWrapper('packC_0', (CS_PartModelRemoterTest.packC1.Id + ',' + CS_PartModelRemoterTest.packC2.Id), 0, 1,'Ignore', true, true, false, true, false, false, 'Loft', 'install note');   //A multilookup
        CS_RemotingParamWrapper attBundleAB = new CS_RemotingParamWrapper('bundleAB_0', CS_PartModelRemoterTest.bundleAB.Id, 0, 1,'Ignore', true, false, true, false, false, false, 'Garage', 'install note');   //A Bundle
        CS_RemotingParamWrapper attFlueBundle = new CS_RemotingParamWrapper('flue_0', CS_PartModelRemoterTest.flueBundle.Id, 0, 1,'Ignore', true, false, true, false, false, false, 'Hall', 'install note');   //Flue Bundle 
        List<CS_RemotingParamWrapper> attsChanged = new List<CS_RemotingParamWrapper>{attBoiler, attPackC, attBundleAB, attFlueBundle};
        Map<String, CS_PartModelEntry> partsModel = CS_PartModelRemoter.getPartModelInformation(attsChanged, regionCode,  postcodeSector, CS_Constants.CS_PricebookType_Standard, boilerGroup, geographicalUplift);
        
        
        //First, create quotePdf attachment against Product Basket
        Attachment pdfAttachment = new Attachment();
        pdfAttachment.ParentID = prodConfig.cscfga__Product_Basket__c;
        pdfAttachment.Body = Blob.valueOf('');
        pdfAttachment.Name = CS_Constants.PdfQuoteFileNamePrefix + ' 123456';
        Test.startTest(); 
        insert pdfAttachment;
        
        
        // ----------- After the data has been created - assert that everything is working as intended --------------
        String bmQuoteQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('BigMachines_Quote__c') + ' From BigMachines_Quote__c ' + 
                                ' Where CS_Quote__c = \'' + prodConfig.cscfga__Product_Basket__c + '\'';
                                
        List<BigMachines_Quote__c> bmQuotesList = ((List<BigMachines_Quote__c>)database.query(bmQuoteQuery));
        
        //check that NO bm quote was created
        System.assertEquals(0, bmQuotesList.size());

        //Then, create partsModel attachment against Product Configuration
        Attachment partsAttachment = new Attachment();
        partsAttachment.ParentID = prodConfig.Id;
        partsAttachment.Body = Blob.valueOf(JSON.serializePretty(partsModel));
        partsAttachment.Name = CS_Constants.PartsModelFileName;  // 'partsModel.txt';  

        insert partsAttachment;
        
        Test.stopTest();
        

        // ----------- after the data has been created - assert that everything is working as intended --------------
        //retrieve BM Quote again
        bmQuotesList = ((List<BigMachines_Quote__c>)database.query(bmQuoteQuery));
        
        List<Attachment> bmQuoteAttachments = [select ParentId, Name from Attachment where ParentId = :bmQuotesList[0].Id];
        
        //check that only one BM Quote was created
        System.assertEquals(1, bmQuotesList.size());
        System.assertEquals(prodConfig.cscfga__Product_Basket__c, bmQuotesList[0].CS_Quote__c);
        
        //check pdf Attachment
        System.assertEquals(1, bmQuoteAttachments.size());
        System.assertEquals(bmQuotesList[0].BigMachines_Transaction_Id__c + '_quote.pdf', bmQuoteAttachments[0].Name);
        
    }
    
    static testMethod void testAttachmentUploadOnProductConfiguration(){
        

        
        Decimal grossTotal = 2000.00;
        Decimal totalAllowance = 700.00;
        
        String[] attributeNameArray= new List<String> { 'Allowance1',   'Allowance2',   'Allowance3',   'Allowance4',   'Allowance5',   'Allowance6',   'Gross Price incl VAT',     'Total Allowance Value',        'Reason',     'Quote Status',                                'Quote Creation Date',         'Delivery Date',    'Delivery Notes',       'Installation Date',   'Special Notes for Installer',  'Customer Date of Birth',       'Payment Type', 'Payment Option',   'HEAT Pricebook',   'System Type Required', 'Other Form of Heating',    'Hot Water Available',  'Existing Efficiency Rating',   'Existing Gas Council Number',  'Boiler Working',   'Vulnerable Customer',  'Job Type Required',    'Latest Customer Category', 'RHC Mobile', 'RHC Username',   'Vulnerable Reasons', 'Pdf Signed'};
        String[] attributeTypeArray = new List<String> {'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display', 'Text Display',             'Text Display',                 'User Input', 'Select List',                                 'Calculation',                 'Date',             'User Input',           'Date',                'User Input',                   'Date',                         'Select List',  'Select List',      'Calculation',      'Select List',          'Select List',              'Select List',          'Select List',                  'User Input',                   'Select List',      'Select List',          'Select List',          'Select List',              'User Input', 'User Input',     'Select List', 'Calculation' };
        String[] attributeValues = new List<String> {   '',             '',             '',             '',             '',             '',             String.valueOf(grossTotal), String.valueOf(totalAllowance), 'Valid',       CS_Constants.QuoteStatus_FinalizedAccepted,   '2014-05-05',                  '2014-06-06',       'Test delivery note',   '2014-08-08',          'Special installer notes test', '1982-01-01',                   'Cash',         '--None--',         'CHB',              'Combination',          'Yes',                      'Yes',                  'C',                            '84527',                        'Yes',              'No',                   '5',                    '99',                       '0173954638', 'user@rhc.com',   'Age', '1'};     
            
        // createa a district 
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        
        //create a subpatch
        Sub_Patch__c sbp = new Sub_Patch__c();
        sbp.District__c = district.Id;
        sbp.Code__c ='12353';
        insert sbp;
        
        //create a postcode sector
        Postcode_Sector__c pstcd = new Postcode_Sector__c();
        pstcd.Name = 'UB7 7';
        pstcd.Sub_Patch__c = sbp.Id;
        pstcd.Type__c='Installation';
        insert pstcd;
            
        // create an Employee
        Employee__c emp = new Employee__c();
        emp.Name = 'test employee';
        emp.Employee_Number__c = '12312321';
        insert emp;
        
        // create a Contact 
        Contact c = new Contact();
        c.LastName = 'contact last name';
        insert c;
            
        // create an account
        Account acc = new Account();
        acc.Name = 'UB7 7QG 9A High';
        //acc.Account_Key_Calc__c = 'UB7 7QG 9A High';
        acc.BillingPostalCode = 'UB7 7QG';
        acc.BillingState = 'West Drayton';
        acc.BillingStreet = '9A High Street Yiewsley';
        //acc.District_Code__c = 'R03D08';
        acc.Name = 'UB7 7QG 9A High';
        //acc.Region_Code__c = 'R03';
        insert acc;
        
        // create an opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.LeadSource = 'Engineer';
        opp.Referral_Employee__c = emp.Id;
        opp.Product_Interest__c = 'Central Heating Boiler';
        opp.StageName = 'Deposit Taken';
        opp.Name = '44829956 - Test 2 - UB7 7QG - (R03D08_S01)';
        opp.CloseDate = date.today();
        insert opp;
        
        
        // create an appointment
        Appointment__c app = new Appointment__c();
        app.Opportunity__c = opp.Id;
        app.Start__c = date.today();
        app.End__c= date.today().addDays(1);
        app.Type__c = 'Installation';
        app.Who__c = c.Id;
        app.Visit_Type__c = 'Recall Visit';
        insert app;
            
            
         //Create a Basket
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c();
        prodBasket.Name = 'test';
        prodBasket.Appointment__c = app.Id;
         //added 2017
        prodBasket.cscfga__Opportunity__c = opp.Id;
        //end
        insert prodBasket;
        
        //create a Product definition
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        //prodDef.Name = 'Heating Hot Water Solution Test';
        prodDef.Name = 'Heating Solution';
        prodDef.cscfga__Description__c = 'Heating Solution';
        //prodDef.cscfga__Description__c = 'Heating Hot Water Solution Test Description';
        insert prodDef;
        
        //create a Product Configuration
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c();
        prodConfig.Name = 'Heating Solution';
        //prodConfig.Name = 'Heating Hot Water Solution Product Configuration';
        prodConfig.cscfga__Product_Definition__c = prodDef.Id;
        prodConfig.cscfga__Product_Basket__c = prodBasket.Id;
        insert prodConfig;
        
        System.debug('****AN created product config');
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
            
            //uncommented
            attribute.cscfga__is_Line_Item__c = True;
            attribute.cscfga__Price__c = 10.0;
            attribute.cscfga__Line_Item_Description__c = 'attributeDescription';
            //end uncommented
            
            attribute.cscfga__value__c = attributeValues[i];
            attributeList.add(attribute);
        }
        insert attributeList;
         System.debug('****AN created attributes');
        //use the method from CS_PartModelRemoterTest check if it needs additional things
        CS_PartModelRemoterTest.createData();

        
        
        //atbRef, atbVal, atbPrice, attQuantity, attDesc, attIsLineItem, attIsPart, attIsBundle, attIsMultiLookup, attIsPlaceholder, attIsPriceOverriden, installLocation, installationNotes
        CS_RemotingParamWrapper attBoiler = new CS_RemotingParamWrapper('boiler_0', CS_PartModelRemoterTest.boiler.Id, 0, 1,'Ignore', true, true, false, false, false, false, 'Kitchen', 'install note');   //Boiler, no override
        CS_RemotingParamWrapper attPackC = new CS_RemotingParamWrapper('packC_0', (CS_PartModelRemoterTest.packC1.Id + ',' + CS_PartModelRemoterTest.packC2.Id), 0, 1,'Ignore', true, true, false, true, false, false, 'Loft', 'install note');   //A multilookup
        CS_RemotingParamWrapper attBundleAB = new CS_RemotingParamWrapper('bundleAB_0', CS_PartModelRemoterTest.bundleAB.Id, 0, 1,'Ignore', true, false, true, false, false, false, 'Garage', 'install note');   //A Bundle
        CS_RemotingParamWrapper attFlueBundle = new CS_RemotingParamWrapper('flue_0', CS_PartModelRemoterTest.flueBundle.Id, 0, 1,'Ignore', true, false, true, false, false, false, 'Hall', 'install note');   //Flue Bundle 
        List<CS_RemotingParamWrapper> attsChanged = new List<CS_RemotingParamWrapper>{attBoiler, attPackC, attBundleAB, attFlueBundle};
        Map<String, CS_PartModelEntry> partsModel = CS_PartModelRemoter.getPartModelInformation(attsChanged, regionCode,  postcodeSector, CS_Constants.CS_PricebookType_Standard, boilerGroup, geographicalUplift);
        System.debug('****AN PARTS MODEL='+partsModel);
        Attachment attachment = new Attachment();
        attachment.ParentID = prodConfig.Id;
        attachment.Body = Blob.valueOf(JSON.serializePretty(partsModel));
        attachment.Name = CS_Constants.PartsModelFileName; //'partsModel.txt';  
        //upsert attachment;
        
Test.startTest();  
        insert attachment;
         System.debug('****AN inserted attachments');
        
        
        // after the data has been created - assert that everything is working as intended
        String bmQuoteQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('BigMachines_Quote__c') + ' From BigMachines_Quote__c';
        List<BigMachines_Quote__c> bmQuotesList = ((List<BigMachines_Quote__c>)database.query(bmQuoteQuery));
        
        String productConfigurationsQuery = 
            'Select ' + CS_SObjectHelper.getFieldListForSOQL('cscfga__Product_Configuration__c') + 
            ',CreatedBy.Name, CreatedBy.Email, CreatedBy.MobilePhone, CreatedBy.Phone, CreatedBy.Title From cscfga__Product_Configuration__c';
        
        List<cscfga__Product_Configuration__c> productConfigurations = ((List<cscfga__Product_Configuration__c>)database.query(productConfigurationsQuery));
  
        List<Quote_Product__c> quoteProducts = [select Sales_Price__c, Quantity__c, geographicUplift__c, vATAAfterDiscount__c, quotingReason__c, price_list_price_each__c, Part_Number__c, Component_Type__c, Product_Code__c,
            BGC_Number__c, upliftable__c, Component_Group_Type__c, Quote_Description__c, EAN__c, Model_Description__c, installationLocation__c, installationNotes__c, FirstVATCode__c, VATABeforeDiscount__c, 
            Level_1_Print_Description__c, Manufacturer__c from Quote_Product__c];
        
        //check that only one product configuration was created
        system.assertEquals(1, productConfigurations.size());
        
        //check that only on bm quote was created
        System.assertEquals(1, bmQuotesList.size());
        
        //check that bm quote fields match the values
        // skills are missing   
        cscfga__Product_Configuration__c pc = productConfigurations[0];
        BigMachines_Quote__c bmQuote = bmQuotesList[0];
        
        System.assertEquals(prodBasket.Id, bmQuote.CS_Quote__c);
        System.assertEquals(totalAllowance, bmQuote.appliedAllowancesTotal__c, 'Total allowance expected: ' + totalAllowance +' actual: ' + bmQuote.appliedAllowancesTotal__c);
        System.assertEquals(grossTotal-totalAllowance, bmQuote.balancePricing__c, 'balancePricing__c expected: ' + (grossTotal-totalAllowance) + ' actual: ' + bmQuote.balancePricing__c);
        System.assertEquals('Valid', bmQuote.bmStatusReason__c, 'bmStatusReason__c expected: ' + 'Valid' +' actual: ' + bmQuote.bmStatusReason__c);
        System.assertEquals(Date.valueOf(Datetime.valueOf(pc.CreatedDate).date()), bmQuote.closeDate__c, 'closeDate__c expected: ' + Date.valueOf(Datetime.valueOf(pc.CreatedDate).date()) +' actual: ' + bmQuote.closeDate__c);
        System.assertEquals(Date.valueOf('2014-05-05'), bmQuote.createdDate_quote__c, 'createdDate_quote__c expected: ' + Date.valueOf('2014-05-05') +' actual: ' + bmQuote.createdDate_quote__c);
        System.assertEquals(Date.valueOf('2014-06-06'), bmQuote.deliveryDate__c, 'deliveryDate__c expected: ' + Date.valueOf('2014-06-06') +' actual: ' + bmQuote.deliveryDate__c);
        System.assertEquals('Test delivery note', bmQuote.deliveryNotes__c, 'deliveryNotes__c expected: ' + 'Test delivery note' +' actual: ' + bmQuote.deliveryNotes__c);
        System.assertEquals(totalAllowance, bmQuote.discountsTotalOnPricing__c, 'discountsTotalOnPricing__c expected: ' + totalAllowance +' actual: ' + bmQuote.discountsTotalOnPricing__c); 
        System.assertEquals(grossTotal, bmQuote.grossPricingTotal__c, 'grossPricingTotal__c expected: ' + grossTotal +' actual: ' + bmQuote.grossPricingTotal__c); 
        System.assertEquals('Special installer notes test', bmQuote.Installation_Special_Instructions__c, 'Installation_Special_Instructions__c expected: ' + 'Special installer notes test' +' actual: ' + bmQuote.Installation_Special_Instructions__c); 
        System.assertEquals(Date.valueOf('2014-08-08'), bmQuote.installationDate__c, 'installationDate__c expected: ' + Date.valueOf('2014-08-08') +' actual: ' + bmQuote.installationDate__c); 
        System.assertEquals((grossTotal - totalAllowance), bmQuote.net__c, 'net__c expected: ' + (grossTotal - totalAllowance) +' actual: ' + bmQuote.net__c); 
        System.assertEquals(Date.valueOf('1982-01-01'), bmQuote.OP_DOB__c, 'OP_DOB__c expected: ' + Date.valueOf('1982-01-01') +' actual: ' + bmQuote.OP_DOB__c); 
        System.assertEquals('--None--', bmQuote.POC_Payment_Option__c, 'POC_Payment_Option__c expected: ' + '--None--' +' actual: ' + bmQuote.POC_Payment_Option__c);      
        System.assertEquals(pc.CreatedBy.MobilePhone, bmQuote.preparedByCell_quote__c, 'preparedByCell_quote__c expected: ' + pc.CreatedBy.MobilePhone +' actual: ' + bmQuote.preparedByCell_quote__c);     
        System.assertEquals(pc.CreatedBy.Email, bmQuote.preparedByEmail_quote__c, 'preparedByEmail_quote__c expected: ' + pc.CreatedBy.Email +' actual: ' + bmQuote.preparedByEmail_quote__c);    
        System.assertEquals(pc.CreatedBy.Name, bmQuote.preparedByName_quote__c, 'preparedByName_quote__c expected: ' + pc.CreatedBy.Name +' actual: ' + bmQuote.preparedByName_quote__c);    
        System.assertEquals(pc.CreatedBy.Phone, bmQuote.preparedByPhone_quote__c, 'preparedByPhone_quote__c expected: ' + pc.CreatedBy.Phone +' actual: ' + bmQuote.preparedByPhone_quote__c);    
        System.assertEquals(pc.CreatedBy.Title, bmQuote.preparedByTitle_quote__c, 'preparedByTitle_quote__c expected: ' + pc.CreatedBy.Title +' actual: ' + bmQuote.preparedByTitle_quote__c);    
        System.assertEquals('CHB', bmQuote.Pricebook_Id__c, 'Pricebook_Id__c expected: ' + 'CHB' +' actual: ' + bmQuote.Pricebook_Id__c);             
        System.assertEquals('CHB', bmQuote.Product_Type_ID__c, 'Product_Type_ID__c expected: ' + 'CHB' +' actual: ' + bmQuote.Product_Type_ID__c);         
        System.assertEquals(Date.valueOf(Datetime.valueOf(pc.CreatedDate).date()), bmQuote.submittedDate_quote__c, 'submittedDate_quote__c expected: ' + Date.valueOf(Datetime.valueOf(pc.CreatedDate).date()) +' actual: ' + bmQuote.submittedDate_quote__c);  
        System.assertEquals('1', bmQuote.systemType__c, 'systemType__c expected: ' + '1' +' actual: ' + bmQuote.systemType__c);           
        System.assertEquals((grossTotal - totalAllowance), bmQuote.totalNetPrice_quote__c, 'totalNetPrice_quote__c expected: ' + (grossTotal - totalAllowance) +' actual: ' + bmQuote.totalNetPrice_quote__c);  
        System.assertEquals('Yes', bmQuote.Customer_have_any_other_form_of_heat__c, 'Customer_have_any_other_form_of_heat__c expected: ' + 'Yes' +' actual: ' + bmQuote.Customer_have_any_other_form_of_heat__c); 
        System.assertEquals('Yes', bmQuote.Does_the_customer_have_hot_water__c, 'Does_the_customer_have_hot_water__c expected: ' + 'Yes' +' actual: ' + bmQuote.Does_the_customer_have_hot_water__c);     
        System.assertEquals('Yes', bmQuote.Is_the_customer_s_boiler_working__c, 'Is_the_customer_s_boiler_working__c expected: ' + 'Yes' +' actual: ' + bmQuote.Is_the_customer_s_boiler_working__c);    
        System.assertEquals('No', bmQuote.Is_the_customer_vulnerable__c, 'Is_the_customer_vulnerable__c expected: ' + 'No' +' actual: ' + bmQuote.Is_the_customer_vulnerable__c);           
        System.assertEquals('Job Type not selected', bmQuote.Job_Type_Description__c, 'Job_Type_Description__c expected: ' + 'Job Type not selected' +' actual: ' + bmQuote.Job_Type_Description__c);   
        System.assertEquals(99, bmQuote.Latest_customer_category__c, 'Latest_customer_category__c expected: ' + 99 +' actual: ' + bmQuote.Latest_customer_category__c);  
        System.assertEquals('FALSE', bmQuote.RHCStatus__c, 'RHCStatus__c expected: ' + 'FALSE' +' actual: ' + bmQuote.RHCStatus__c);                
        System.assertEquals('Age', bmQuote.Vulnerable_reason__c, 'Vulnerable_reason__c expected: ' + 'Age' +' actual: ' + bmQuote.Vulnerable_reason__c); 
        System.assertEquals(true, bmQuote.Is_Electronically_Signed__c);
        
        //skills
        System.assertEquals(0.00, bmQuote.skillTotal_ecogenElectrical__c, 'Ecogen Electrical expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotal_ecogenElectrical__c);          
        System.assertEquals(0.00, bmQuote.skillTotal_ecogenMechanical__c, 'Ecogen Mechanical expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotal_ecogenMechanical__c);           
        System.assertEquals(0.00, bmQuote.skillTotalBuildingWork__c, 'BuildingWork expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalBuildingWork__c); 
        System.assertEquals(0.00, bmQuote.skillTotalConnectSolarPanels__c, 'ConnectSolarPanels expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalConnectSolarPanels__c);          
        System.assertEquals(0.00, bmQuote.skillTotalElectrical__c, 'Electrical expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalElectrical__c);                  
        System.assertEquals(0.00, bmQuote.SkillTotalElectricalWorkASP__c, 'ElectricalWorkASP expected: ' + 0.00 + ' actual: ' + bmQuote.SkillTotalElectricalWorkASP__c);           
        System.assertEquals(0.00, bmQuote.skillTotalFireWallHeaterFixing__c, 'FireWallHeaterFixing expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalFireWallHeaterFixing__c);        
        System.assertEquals(0.00, bmQuote.skillTotalLPGInstallation__c, 'TotalLPGInstallation expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalLPGInstallation__c);             
        System.assertEquals(0.00, bmQuote.skillTotalMechanical__c, 'TotalMechanical expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalMechanical__c);                  
        System.assertEquals(0.00, bmQuote.skillTotalPaymentCollection__c, 'PaymentCollection expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalPaymentCollection__c);           
        System.assertEquals(0.00, bmQuote.skillTotalPowerFlush__c, 'PowerFlush expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalPowerFlush__c);                  
        System.assertEquals(0.00, bmQuote.skillTotalRoofWork__c, 'RoofWork expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalRoofWork__c);                    
        System.assertEquals(0.00, bmQuote.skillTotalScaffolder__c, 'Scaffolder expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalScaffolder__c);                 
        System.assertEquals(0.00, bmQuote.skillTotalSpecialistBuilding__c, 'SpecialistBuilding expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalSpecialistBuilding__c);          
        System.assertEquals(0.00, bmQuote.skillTotalUnventedHotWater__c, 'UnventedHotWater expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalUnventedHotWater__c);           
        System.assertEquals(0.00, bmQuote.skillTotalWaterHeatingFixing__c, 'WaterHeatingFixing expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalWaterHeatingFixing__c); 
        System.assertEquals(0.00, bmQuote.Remote_Heating__c, 'Remote_Heating__c expected: ' + 0.00 + ' actual: ' + bmQuote.Remote_Heating__c); 
        System.assertEquals(0.00, bmQuote.skillTotalECO__c, 'skillTotalECO__c expected: ' + 0.00 + ' actual: ' + bmQuote.skillTotalECO__c); 
        
        //quote product assertions
        Integer numberOfQuoteProducts = 0;
        for(Quote_Product__c prod : quoteProducts){
            numberOfQuoteProducts ++;   
            system.debug('*-*-*-*-*-*-*-*');
            system.debug(prod);
        }   
        
        System.assertEquals(numberOfQuoteProducts, bmQuote.Active_QP_Lines__c, 'Active_QP_Lines__c expected: ' + (numberOfQuoteProducts + 1) + ' actual: ' + bmQuote.Active_QP_Lines__c); 
        
        Quote_Product__c firstQuote = quoteProducts[0];
        Quote_Product__c secondQuote = quoteProducts[1];
        Quote_Product__c thirdQuote = quoteProducts[2];
        
        /*System.assertEquals(120.00, firstQuote.Sales_Price__c, 'Sales_Price__c expected: ' + 120.00 + ' actual: ' + firstQuote.Sales_Price__c);                
        System.assertEquals(1, firstQuote.Quantity__c, 'Quantity__c expected: ' + 1 + ' actual: ' + firstQuote.Quantity__c);                   
        System.assertEquals(20.00, firstQuote.vATAAfterDiscount__c, 'vATAAfterDiscount__c expected: ' + 20.00 + ' actual: ' + firstQuote.vATAAfterDiscount__c);          
        System.assertEquals('First Quote', firstQuote.quotingReason__c, 'quotingReason__c expected: ' + 'First Quote' + ' actual: ' + firstQuote.quotingReason__c);              
        System.assertEquals(100.00, firstQuote.price_list_price_each__c, 'price_list_price_each__c expected: ' + 100.00 + ' actual: ' + firstQuote.price_list_price_each__c);      
        System.assertEquals(null, firstQuote.Component_Type__c, 'Component_Type__c expected: ' + 'null' + ' actual: ' + firstQuote.Component_Type__c);       
        // System.assertEquals(null, firstQuote.Product_Code__c, 'Product_Code__c expected: ' + 'null' + ' actual: ' + firstQuote.Product_Code__c);               
        System.assertEquals(null, firstQuote.BGC_Number__c, 'BGC_Number__c expected: ' + 'null' + ' actual: ' + firstQuote.BGC_Number__c);                 
        System.assertEquals(null, firstQuote.Quote_Description__c, 'Quote_Description__c expected: ' + 'null' + ' actual: ' + firstQuote.Quote_Description__c);          
        System.assertEquals(null, firstQuote.EAN__c, 'EAN__c expected: ' + 'null' + ' actual: ' + firstQuote.EAN__c);                        
        System.assertEquals(null, firstQuote.Model_Description__c, 'Model_Description__c expected: ' + 'null' + ' actual: ' + firstQuote.Model_Description__c);          
        System.assertEquals('Kitchen', firstQuote.installationLocation__c, 'installationLocation__c expected: ' + 'Kitchen' + ' actual: ' + firstQuote.installationLocation__c);       
        System.assertEquals(1.00, firstQuote.FirstVATCode__c, 'FirstVATCode__c expected: ' + 1.00 + ' actual: ' + firstQuote.FirstVATCode__c); 
        System.assertEquals(20.00, firstQuote.VATABeforeDiscount__c, 'VATABeforeDiscount__c expected: ' + 20.00 + ' actual: ' + firstQuote.VATABeforeDiscount__c);         
        System.assertEquals(null, firstQuote.Level_1_Print_Description__c, 'Level_1_Print_Description__c expected: ' + 'null' + ' actual: ' + firstQuote.Level_1_Print_Description__c);  
        System.assertEquals(null, firstQuote.Manufacturer__c, 'Manufacturer__c expected: ' + 'null' + ' actual: ' + firstQuote.Manufacturer__c);               
        
        System.assertEquals(44.00, secondQuote.Sales_Price__c, 'Sales_Price__c expected: ' + 44.00 + ' actual: ' + secondQuote.Sales_Price__c);                
        System.assertEquals(2, secondQuote.Quantity__c, 'Quantity__c expected: ' + 2 + ' actual: ' + secondQuote.Quantity__c);                   
        System.assertEquals(2.00, secondQuote.vATAAfterDiscount__c, 'vATAAfterDiscount__c expected: ' + 2.00 + ' actual: ' + secondQuote.vATAAfterDiscount__c);          
        System.assertEquals('First Quote', secondQuote.quotingReason__c, 'quotingReason__c expected: ' + 'First Quote' + ' actual: ' + secondQuote.quotingReason__c);              
        System.assertEquals(20.00, secondQuote.price_list_price_each__c, 'price_list_price_each__c expected: ' + 20.00 + ' actual: ' + secondQuote.price_list_price_each__c);      
        System.assertEquals(null, secondQuote.Component_Type__c, 'Component_Type__c expected: ' + 'null' + ' actual: ' + secondQuote.Component_Type__c);       
        // System.assertEquals(null, secondQuote.Product_Code__c, 'Product_Code__c expected: ' + 'null' + ' actual: ' + secondQuote.Product_Code__c);               
        System.assertEquals(null, secondQuote.BGC_Number__c, 'BGC_Number__c expected: ' + 'null' + ' actual: ' + secondQuote.BGC_Number__c);                 
        System.assertEquals(null, secondQuote.Quote_Description__c, 'Quote_Description__c expected: ' + 'null' + ' actual: ' + secondQuote.Quote_Description__c);          
        System.assertEquals(null, secondQuote.EAN__c, 'EAN__c expected: ' + 'null' + ' actual: ' + secondQuote.EAN__c);                        
        System.assertEquals(null, secondQuote.Model_Description__c, 'Model_Description__c expected: ' + 'null' + ' actual: ' + secondQuote.Model_Description__c);          
        System.assertEquals('Kitchen', secondQuote.installationLocation__c, 'installationLocation__c expected: ' + 'Kitchen' + ' actual: ' + secondQuote.installationLocation__c);       
        System.assertEquals(null, secondQuote.FirstVATCode__c, 'FirstVATCode__c expected: ' + 'null' + ' actual: ' + secondQuote.FirstVATCode__c); 
        System.assertEquals(2.00, secondQuote.VATABeforeDiscount__c, 'VATABeforeDiscount__c expected: ' + 2.00 + ' actual: ' + secondQuote.VATABeforeDiscount__c);         
        System.assertEquals(null, secondQuote.Level_1_Print_Description__c, 'Level_1_Print_Description__c expected: ' + 'null' + ' actual: ' + secondQuote.Level_1_Print_Description__c);  
        System.assertEquals(null, secondQuote.Manufacturer__c, 'Manufacturer__c expected: ' + 'null' + ' actual: ' + secondQuote.Manufacturer__c);               
                
        System.assertEquals(25.30, thirdQuote.Sales_Price__c, 'Sales_Price__c expected: ' + 25.30 + ' actual: ' + thirdQuote.Sales_Price__c);                
        System.assertEquals(1, thirdQuote.Quantity__c, 'Quantity__c expected: ' + 1 + ' actual: ' + thirdQuote.Quantity__c);                   
        System.assertEquals(2.30, thirdQuote.vATAAfterDiscount__c, 'vATAAfterDiscount__c expected: ' + 2.30 + ' actual: ' + thirdQuote.vATAAfterDiscount__c);          
        System.assertEquals('First Quote', thirdQuote.quotingReason__c, 'quotingReason__c expected: ' + 'First Quote' + ' actual: ' + thirdQuote.quotingReason__c);              
        System.assertEquals(23.00, thirdQuote.price_list_price_each__c, 'price_list_price_each__c expected: ' + 23.00 + ' actual: ' + thirdQuote.price_list_price_each__c);      
        System.assertEquals(null, thirdQuote.Component_Type__c, 'Component_Type__c expected: ' + 'null' + ' actual: ' + thirdQuote.Component_Type__c);       
        // System.assertEquals(null, thirdQuote.Product_Code__c, 'Product_Code__c expected: ' + 'null' + ' actual: ' + thirdQuote.Product_Code__c);               
        System.assertEquals(null, thirdQuote.BGC_Number__c, 'BGC_Number__c expected: ' + 'null' + ' actual: ' + thirdQuote.BGC_Number__c);                 
        System.assertEquals(null, thirdQuote.Quote_Description__c, 'Quote_Description__c expected: ' + 'null' + ' actual: ' + thirdQuote.Quote_Description__c);          
        System.assertEquals(null, thirdQuote.EAN__c, 'EAN__c expected: ' + 'null' + ' actual: ' + thirdQuote.EAN__c);                        
        System.assertEquals(null, thirdQuote.Model_Description__c, 'Model_Description__c expected: ' + 'null' + ' actual: ' + thirdQuote.Model_Description__c);          
        System.assertEquals('Kitchen', thirdQuote.installationLocation__c, 'installationLocation__c expected: ' + 'Kitchen' + ' actual: ' + thirdQuote.installationLocation__c);       
        System.assertEquals(null, thirdQuote.FirstVATCode__c, 'FirstVATCode__c expected: ' + 'null' + ' actual: ' + thirdQuote.FirstVATCode__c); 
        System.assertEquals(2.30, thirdQuote.VATABeforeDiscount__c, 'VATABeforeDiscount__c expected: ' + 2.30 + ' actual: ' + thirdQuote.VATABeforeDiscount__c);         
        System.assertEquals(null, thirdQuote.Level_1_Print_Description__c, 'Level_1_Print_Description__c expected: ' + 'null' + ' actual: ' + thirdQuote.Level_1_Print_Description__c);  
        System.assertEquals(null, thirdQuote.Manufacturer__c, 'Manufacturer__c expected: ' + 'null' + ' actual: ' + thirdQuote.Manufacturer__c);        
        */
        Test.stopTest();
    }

	static testMethod void testReturnBoolean() {
		System.assert(CS_AllAttachmentTriggerHelper.returnBoolean('true'));
		System.assert(CS_AllAttachmentTriggerHelper.returnBoolean('TRUe'));
		System.assert(!CS_AllAttachmentTriggerHelper.returnBoolean('false'));
		System.assert(!CS_AllAttachmentTriggerHelper.returnBoolean(null));
	}
  
}