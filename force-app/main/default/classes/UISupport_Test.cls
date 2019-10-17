@isTest
public class UISupport_Test {

    public static String pricebookType = 'Standard';
    public static String boilerGroup = 'Worcester';
    public static String regionCode = 'South London';
    public static String postcodeSector = 'SW London';
    public static Decimal geographicUpliftFactor = 0;
    
    static testMethod void testPartsRetrievalAndSave() {
    
        //Create a Configuration
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'Heating Hot Water Solution Test';
        prodDef.cscfga__Description__c = 'Heating Hot Water Solution Test Description';
        insert prodDef;
        
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c();
        prodConfig.Name = 'Heating Hot Water Solution Product Configuration';
        prodConfig.cscfga__Product_Definition__c = prodDef.Id;
        insert prodConfig;
        String configId = prodConfig.Id;
        
        //Create a parts Model
        CS_PartModelRemoterTest.createData();
        
        CS_RemotingParamWrapper attBoiler = new CS_RemotingParamWrapper('boiler_0', CS_PartModelRemoterTest.boiler.Id, 0, 1,'Ignore', true, true, false, false, false, false, 'Kitchen', 'notes');   //Boiler, no override
        CS_RemotingParamWrapper attPlcRad = new CS_RemotingParamWrapper('plcRadMedium_0', CS_PartModelRemoterTest.plcRadMedium.Id, 0, 1,'Ignore', true, true, false, false, true, false, 'Living room', 'notes');   //Plc Rad, no override
        CS_RemotingParamWrapper attRad = new CS_RemotingParamWrapper('radiator_0', CS_PartModelRemoterTest.radiator.Id, 180, 2,'Overriden Desc: Medium', true, true, false, false, false, true, 'Bedroom', 'notes');   //Radiators, 2, with override
        CS_RemotingParamWrapper attPackC = new CS_RemotingParamWrapper('packC_0', (CS_PartModelRemoterTest.packC1.Id + ',' + CS_PartModelRemoterTest.packC2.Id), 0, 1,'Ignore', true, true, false, true, false, false, '', 'notes');   //A multilookup
        CS_RemotingParamWrapper attBundleAB = new CS_RemotingParamWrapper('bundleAB_0', CS_PartModelRemoterTest.bundleAB.Id, 0, 1,'Ignore', true, false, true, false, false, false, '', 'notes');   //A Bundle
        CS_RemotingParamWrapper attFlueBundle = new CS_RemotingParamWrapper('flue_0', CS_PartModelRemoterTest.flueBundle.Id, 0, 1,'Ignore', true, false, true, false, false, false, '', 'notes');   //Flue Bundle 
        
        List<CS_RemotingParamWrapper> attsChanged = new List<CS_RemotingParamWrapper>{attBoiler, attPlcRad, attRad, attPackC, attBundleAB, attFlueBundle};
        Map<String, CS_PartModelEntry> partsModel = CS_PartModelRemoter.getPartModelInformation(attsChanged, regionCode,  postcodeSector, CS_Constants.CS_PricebookType_Standard, boilerGroup, geographicUpliftFactor);
                                                            
        //storePartsModel
        UISupport.savePartsModel(configId, partsModel);
        
        List<Attachment> attachmentList = [SELECT Id, Name FROM Attachment where ParentId = :configId];
        
        //getPartsModel
        Map<String, CS_PartModelEntry> parts = UISupport.getPartsModel(configId);    
        
        system.assertEquals(6, parts.keySet().size());
        
        //Test getBundlesWithAssociations
        List<Id> parentBundles = new List<Id>{CS_PartModelRemoterTest.bundleAB.Id, CS_PartModelRemoterTest.flueBundle.Id};
        Map<Id, CS_Bundle__c> bundlesWithAssoc = UISupport.getBundlesWithAssociations(parentBundles);
        
        for (Id bundleId : bundlesWithAssoc.keySet()) {
            if (bundleId == CS_PartModelRemoterTest.bundleAB.Id) {
               system.assertEquals(3, bundlesWithAssoc.get(bundleId).CS_Bundle_Part_Associations__r.size());
            }
            else if (bundleId == CS_PartModelRemoterTest.flueBundle.Id) {
                system.assertEquals(2, bundlesWithAssoc.get(bundleId).CS_Bundle_Part_Associations__r.size());
            }
        }

        
        //Test getPartsWithAssociations
        List<Id> parentPartIds = new List<Id>{CS_PartModelRemoterTest.boiler.Id, CS_PartModelRemoterTest.plcRadMedium.Id,
                                               CS_PartModelRemoterTest.radiator.Id, CS_PartModelRemoterTest.packC1.Id, CS_PartModelRemoterTest.packC2.Id};
        List<CS_Part_Association__c> partsWithAssociations = UISupport.getPartsWithAssociations(parentPartIds);
        system.assertEquals(7, partsWithAssociations.size()); //4 for Bundle, 3 for Radiator
       
        
        //Test getAllReferencedPartInformation
        List<String> partIdsToQuery = new List<String>();
        for (Id partId : parentPartIds) {
            partIdsToQuery.add(partId); //4 Ids
        }
        for (CS_Part_Association__c pa : partsWithAssociations) {
            partIdsToQuery.add(pa.Part_2__c); //7 Ids
        }
        
        Map<Id, CS_PartWrapper> allPartsInfo = UISupport.getAllReferencedPartInformation(partIdsToQuery, postcodeSector, pricebookType);
        
        system.assertEquals(10, allPartsInfo.keySet().size()); //entries expected: 4 for the parentIds and 3 associatedParts for Boiler, 1 for radiator, 2 for Pack C
        
        //check that the CS_Part__c property of each CS_Part_Wrapper has no relationships attached to it
        for (Id partId : allPartsInfo.keySet()) {
            CS_PartWrapper wrapper = allPartsInfo.get(partId);
            system.assert(wrapper.part != null);
            system.assert(wrapper.partPrices != null);
            system.assert(wrapper.partMaterials != null);
            system.assert(wrapper.partSkills != null);
            
           // system.assertEquals(null, wrapper.part.CS_Part_Prices__r);
           // system.assertEquals(null, wrapper.part.CS_Part_Materials__r);
           // system.assertEquals(null, wrapper.part.CS_Part_Skills__r);
        }
    
    }

    static testMethod void testAllowancesRetrieval() {
        String productType = 'ABC';
        Decimal grossPrice = 2000;
        Integer customerAge = 20;
        String leadCreation = String.valueOf(Date.Today());
        String voucherNo = 'A123';
        String employeeId = '123';
        String productInterest = 'Central Heating Boiler';
        //Create 2 allowances
        CS_Allowance__c allowance1 = new CS_Allowance__c(Description__c = 'Allowance 1', Allowance_Type__c = 'Amount', Amount__c = 20, Valid_Product_Types__c = productType, Minimum_Threshold__c = 1000, Minimum_Age__c = 18);
        CS_Allowance__c allowance2 = new CS_Allowance__c(Description__c = 'Allowance 2', Allowance_Type__c = 'Amount', Amount__c = 30);
        
        insert new List<CS_Allowance__c> {allowance1, allowance2};
        
        //Test getApplicableAllowances
        List<CS_Allowance__c> allowances = UISupport.getApplicableAllowances(productType, grossPrice, customerAge, leadCreation, voucherNo, employeeId, productInterest);
        system.assertEquals(1, allowances.size());
        
        //Test getAssignedToEmployeeGroups
        Employee__c empl = new Employee__c(First_Name__c = 'Test', Last_Name__c ='Test', Employee_Number__c = '123');
        insert empl;
        
        Groups__c g = new Groups__c(Name = 'Test Group');
        insert g;
        
        Employee_Group__c empGroup = new Employee_Group__c(Employee__c = empl.Id, Group__c = g.Id);
        insert empGroup;
        
        List<String> groups = UISupport.getAssignedToEmployeeGroups(empl.Id);
        system.assertEquals(1, groups.size());
        
        //getAllowance
        Id allowanceId;
        CS_Allowance__c retrievedAllowance = UISupport.getAllowance(allowance1.Id);
        
        List<CS_Allowance_Part_Availability__c> partAvail = UISupport.getAllowancePartAvailabilities(allowanceId);
        
        List<CS_Allowance_Category_Availability__c> catgAvail = UISupport.getAllowanceCategoryAvailabilities(allowanceId);
    }

    static testMethod void testConstructors(){
    
        CS_TestHelper.createBasketWithProductConfiguration(null);
        
        Id prodDefId = CS_TestHelper.prodDef.Id;
        Id configId = CS_TestHelper.prodConfig.Id;
        Id prodBasketId = CS_TestHelper.prodBasket.Id;
        
        //Inject params to the page: linkedId, basketId, configId     
        ApexPages.currentPage().getParameters().put('definitionId', prodDefId);
        ApexPages.currentPage().getParameters().put('configId', configId);
        ApexPages.currentPage().getParameters().put('basketId', prodBasketId);
        
        UISupport ctrl = new UISupport();
        system.assertEquals(ctrl.definitionId, prodDefId);
        system.assertEquals(ctrl.configId, configId);
        system.assertEquals(ctrl.basketId, prodBasketId);
        
        cscfga.ProductConfiguratorController pcc = new cscfga.ProductConfiguratorController();
        ctrl = new UISupport(pcc);
        system.assertEquals(ctrl.definitionId, prodDefId);
        system.assertEquals(ctrl.configId, configId);
        system.assertEquals(ctrl.basketId, prodBasketId);
        
        Map<String, String> paramsMap = new Map<String, String> {'definitionId' => prodDefId,'configId'=> configId, 'basketId' => prodBasketId };
        ctrl = new UISupport(paramsMap);
        system.assertEquals(ctrl.definitionId, prodDefId);
        system.assertEquals(ctrl.configId, configId);
        system.assertEquals(ctrl.basketId, prodBasketId);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(CS_TestHelper.prodBasket); 
        ctrl = new UISupport(sc);
        
        system.assertEquals(ctrl.definitionId, prodDefId);
        system.assertEquals(ctrl.configId, configId);
    }
     
    static testMethod void testStoreConfigs(){
        Appointment__c app = CS_TestHelper.prepareDataForAppointment();
        insert app;
        
        CS_TestHelper.createBasketWithProductConfiguration(app.Id);
        
        Id prodDefId = CS_TestHelper.prodDef.Id;
        Id configId = CS_TestHelper.prodConfig.Id;
        Id prodBasketId = CS_TestHelper.prodBasket.Id;
        
        //Test storeConfigs
        List<List<Object>> objectList = new List<List<Object>>();
        objectList.add(new List<Object> {CS_TestHelper.prodBasket});
        objectList.add(new List<Object> {CS_TestHelper.prodConfig});
        objectList.add(CS_TestHelper.attributeList);
        objectList.add(CS_TestHelper.attributeFieldList);
        
        String js = JSON.serializePretty(objectList);
        UISupport.storeConfigs(js);
    }
     
    static testMethod void testOther(){
    
        //cscfga__Date_Range__c = ctrl.dateRange;
        
        Appointment__c app = CS_TestHelper.prepareDataForAppointment();
        insert app;
        
        CS_TestHelper.createBasketWithProductConfiguration(app.Id);
        
        Id prodDefId = CS_TestHelper.prodDef.Id;
        Id configId = CS_TestHelper.prodConfig.Id;
        Id prodBasketId = CS_TestHelper.prodBasket.Id;
        
        ApexPages.currentPage().getParameters().put('definitionId', prodDefId);
        ApexPages.currentPage().getParameters().put('configId', configId);
        ApexPages.currentPage().getParameters().put('basketId', prodBasketId);
        ApexPages.currentPage().getParameters().put('linkedId', app.Id);
        
        UISupport ctrl = new UISupport();
        ctrl.redirectProductBasket();
        
        ctrl.redirectProductConfiguration();
        try {
            UISupport.getProductModel(prodDefId);//provide Product Definition Id, catch exception
        }
        catch (Exception ex) {
            //System.assert(ex.getMessage().indexOf('No ProductModelData attachment found') > 0);
        }
        
        String template = 'SQTOnlineTemplate';
        try {
            UISupport.getProductTemplate(configId, '', template); //same, catch exception
        }
        catch (Exception ex) {
            // System.assert(ex.getMessage().indexOf('No DefaultScreenFlow attachment found') > 0);
        }
        
        UISupport.getProductConfiguration(configId);
        
        UISupport.getHeaderData(app.Id);
        
        List<String> sectionIds = new List<String>();
        UISupport.getSequenceNumbers(sectionIds);
        
        UISupport.getConfigurationData(configId);
    }
    
    static testMethod void testGetAllSectionsRemoteAction(){
        
        List<CS_Template_Section_Header__c> headersList = new List<CS_Template_Section_Header__c>();
        headersList.add(new CS_Template_Section_Header__c(Name = 'System Controls 1', Sequence__c = 100));
        headersList.add(new CS_Template_Section_Header__c(Name = 'System Controls 2', Sequence__c = 100));
        headersList.add(new CS_Template_Section_Header__c(Name = 'System Controls 3', Sequence__c = 100));
        
        insert headersList;
        
        List<CS_Template_Section_Header__c> fetchedSections = UISupport.getAllSections();
        
        system.assertEquals(headersList.size(), fetchedSections.size());
    }
    
    static testMethod void testGetPartsByPartCode(){

        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;
        insert vat20;
        
        List<CS_Part__c> partList = new List<CS_Part__c>();
        for (Integer i=0; i< 10; i++){
            partList.add(new CS_Part__c(Name = 'Test part 333', Part_Code__c = string.valueOf(i), VAT_Code__c = vat20.Id));
        }
        
        insert partList;
        List<String> partCodes = new List<String>();
        partCodes.add('1');
        partCodes.add('2');
        partCodes.add('20'); // non existing part code
        
        List<CS_Part__c> fetchedParts = UISupport.getPartsByPartCode(partCodes);
        system.assertEquals(2, fetchedParts.size());
    }
    
    static testMethod void testGetSobjectFieldMap(){
        
        String so = 'Account';
        Set<String> colSet = new Set<String>();
        colSet.add('Name');
        colSet.add('AccountNumber');
        colSet.add('NonExistingField');
        
        Map<String, String> sObjectFieldMap = UISupport.getSobjectFieldMap(so, colSet);
        
        system.assertEquals(2, sObjectFieldMap.keySet().size());
    }
	
    static testMethod void testAttachPdfReturnId() {
        cscfga__Product_Basket__c a = new cscfga__Product_Basket__c();
        insert a;
        
       	String attachmentId = UISupport.AttachPdfReturnId(a.id, 'Test attachment', '123');
        Attachment att = [SELECT Id, Name FROM Attachment WHERE Id = :attachmentId LIMIT 1];
        
        system.assert(att != null);        
    }
    
    static testMethod void testSetTriggersOnOff() {
        UISupport.setTriggersOff(System.UserInfo.getUserId());
        
        UISupport.setTriggersOn(System.UserInfo.getUserId());
    }

	static testmethod void testAttachTempFileReturnId() {
		cscfga__Product_Basket__c a = new cscfga__Product_Basket__c();
        insert a;


		String idAttach = UISupport.AttachTempFileReturnId(a.id, 'Temp file', '432');

		Attachment att = [SELECT Id, Name FROM Attachment WHERE Id = :idAttach LIMIT 1];
		
		system.assert(att != null);    
		System.assert(id.valueOf(idAttach) ==  att.id);
	}

	static testmethod void testGetAssignedToEmployeesGroupAndId() {
		Appointment__c app = CS_TestHelper.prepareDataForAppointment();
        insert app;
		Map<String, List<String>> result = UISupport.getAssignedToEmployeeGroupsAndId();
		System.assert(result != null);
	}

	static testmethod void testSaveInstallationNotesPdf() {
		Appointment__c app = CS_TestHelper.prepareDataForAppointment();
        insert app;

		CS_TestHelper.createBasketWithProductConfiguration(app.Id);

        cscfga__Product_Basket__c basket = [SELECT id from cscfga__Product_Basket__c WHERE Appointment__c = :app.Id];

        System.debug('*** Basket new = ' + basket);

		UISupport.SaveInstallationNotesPdf(String.valueOf(app.Id), String.valueOf(app.id), 
											String.valueOf(app.Opportunity__c), 'A34234222', 'Brittish Gas', true, basket.Id, '');

        string attName = CS_Constants.InstallationNotesPDF + '%';
		
		Attachment att = [SELECT id, body from Attachment WHERE ParentId = :basket.Id AND Name Like :attName];

        System.debug('*** Att new = ' + att);

		System.assertEquals('@Test PDF data install notes', att.body.toString());

	}


	static testmethod void testSaveNewOnlineQuotePdf() {
		Appointment__c app = CS_TestHelper.prepareDataForAppointment();
        insert app;

		CS_TestHelper.createBasketWithProductConfiguration(app.Id);

		UISupport.SaveNewOnlineQuotePdf(String.valueOf(app.Id), String.valueOf(app.id), 
											String.valueOf(app.Opportunity__c), 'A34234222', 'Brittish Gas');
		
		Attachment att = [SELECT id, body from Attachment WHERE ParentId = :app.Opportunity__c AND Name Like '%New Online Quote.pdf'];

		System.assertEquals('@Test PDF data online quote', att.body.toString());


	}

	static testmethod void testUpdateAsbestosRecords() {
		Appointment__c app = CS_TestHelper.prepareDataForAppointment();
        insert app;

		Opportunity oppty = [SELECT accountId FROM Opportunity WHERE Id = :app.Opportunity__c][0];

		String result = UISupport.updateAsbestosDetails(oppty.accountId);

		System.assertEquals('Account updated successfully.', result);

	}

	static testmethod void testMapToProductConfigurations() {
		Appointment__c app = CS_TestHelper.prepareDataForAppointment();
        insert app;
		CS_TestHelper.createBasketWithProductConfiguration(app.Id);

	    List<cscfga__Product_Configuration__c> expected = new List<cscfga__Product_Configuration__c>();
		expected.add(CS_TestHelper.prodConfig);

		List<cscfga__Product_Configuration__c> result = UISupport.mapToProductConfigurations((List<SObject>) expected);

		for (Integer i = 0; i < expected.size(); ++i) {
			System.assertEquals(expected[i], result[i]);
		}
	}

	static testmethod void testMapToAttributes() {
		Appointment__c app = CS_TestHelper.prepareDataForAppointment();
        insert app;
		CS_TestHelper.createBasketWithProductConfiguration(app.Id);
		

		List<cscfga__Attribute__c> result = UISupport.mapToAttributes(CS_TestHelper.attributeList);

		
		for (Integer i = 0; i < CS_TestHelper.attributeList.size(); ++i) {
			System.assertEquals(CS_TestHelper.attributeList[i], result[i]);
		}
	}

	static testmethod void testGetBundleComplexPriceAssociations() {
		UISupport.getBundleComplexPriceAssociations(new List<Id>(), 0);
	}
}