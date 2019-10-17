@isTest
private class CS_DifferenceReviewControllerTest {
    
    private static testMethod void CS_DifferenceReviewControllerTest() {
        
        Appointment__c a = new Appointment__c();
       
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        CS_DifferenceReviewController controller;
        try {
            controller = new CS_DifferenceReviewController(sc);
        } catch (Exception ex) {
            system.assert(false, 'The page has not been rendered properly');
        }
        
    }

    private static testMethod void getPcFilteredListTest() {
       
        // create a product basket
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c(Name = 'C123456780', CS_Quote_Status__c = 'Quote Finalised - Not Accepted');
        insert prodBasket;
        
        // create a product definition
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c(Name = 'Heating Hot Water Solution Test', cscfga__Description__c = 'Heating solution');
        insert prodDef;
        
        // create a product configuration
        cscfga__Product_Configuration__c rootConf = new cscfga__Product_Configuration__c(Name = 'Heating solution', cscfga__Product_Basket__c = prodBasket.Id, cscfga__Product_Definition__c = prodDef.Id);
        insert rootConf;
        
        // create at least 2 descendant configurations
        cscfga__Product_Configuration__c desc1Conf = new cscfga__Product_Configuration__c(Name = 'Descendant configuration 1', cscfga__Root_Configuration__c = rootConf.Id, cscfga__Parent_Configuration__c = rootConf.Id, cscfga__Product_Definition__c = prodDef.Id);
        cscfga__Product_Configuration__c desc2Conf = new cscfga__Product_Configuration__c(Name = 'Descendant configuration 2', cscfga__Root_Configuration__c = rootConf.Id, cscfga__Parent_Configuration__c = rootConf.Id, cscfga__Product_Definition__c = prodDef.Id);
        List<cscfga__Product_Configuration__c> descConfList = new List<cscfga__Product_Configuration__c>{desc1Conf, desc2Conf};
        insert descConfList;
        
        List<cscfga__Product_Configuration__c> retrievedConfigurations = [Select Id from cscfga__Product_Configuration__c];
        system.assertEquals(3, retrievedConfigurations.size(), 'Mismatched number of product configurations');
        
        // create a few attributes for each of the configurations (at least some need to be line items)
        // create attribute definitions
        cscfga__Attribute_Definition__c attDefRoot = new cscfga__Attribute_Definition__c(Name = 'Generic Attribute', cscfga__Type__c = 'Calculation', cscfga__Product_Definition__c = prodDef.Id);
        cscfga__Attribute_Definition__c attDefDesc1 = new cscfga__Attribute_Definition__c(Name = 'Generic Attribute', cscfga__Type__c = 'Calculation', cscfga__Product_Definition__c = prodDef.Id);
        cscfga__Attribute_Definition__c attDefDesc2 = new cscfga__Attribute_Definition__c(Name = 'Generic Attribute', cscfga__Type__c = 'Calculation', cscfga__Product_Definition__c = prodDef.Id);
        
        List<cscfga__Attribute_Definition__c> attDefList = new List<cscfga__Attribute_Definition__c>{attDefRoot, attDefDesc1, attDefDesc2};
        insert attDefList;
        
        // root configuration attributes
        cscfga__Attribute__c attr1 = new cscfga__Attribute__c(cscfga__Is_Line_Item__c = true, cscfga__Product_Configuration__c = rootConf.Id, cscfga__Attribute_Definition__c = attDefRoot.Id, cscfga__Value__c='a4L1100000005JOEAY', Name='TT System Type, Visible Earth NO, Customer to Arrange NO, Passed');
        cscfga__Attribute__c attr2 = new cscfga__Attribute__c(cscfga__Is_Line_Item__c = false, cscfga__Product_Configuration__c = rootConf.Id, cscfga__Attribute_Definition__c = attDefRoot.Id,cscfga__Value__c='a3R110000000A0dEAE', Name='Not a line item part');

        //descendand configuration 1 attributes
        cscfga__Attribute__c attr3 = new cscfga__Attribute__c(cscfga__Is_Line_Item__c = true, cscfga__Product_Configuration__c = descConfList[0].Id, cscfga__Attribute_Definition__c = attDefDesc1.Id,cscfga__Value__c='a4T110000000DGpEAM', Name='Specialist Building Work (5)');
        cscfga__Attribute__c attr4 = new cscfga__Attribute__c(cscfga__Is_Line_Item__c = false, cscfga__Product_Configuration__c = descConfList[0].Id, cscfga__Attribute_Definition__c = attDefDesc1.Id,cscfga__Value__c='a3R110000000A0dEAE', Name='Not a line item part');
        
        //descendand configuration 2 attributes
        cscfga__Attribute__c attr5 = new cscfga__Attribute__c(cscfga__Is_Line_Item__c = true, cscfga__Product_Configuration__c = descConfList[1].Id, cscfga__Attribute_Definition__c = attDefDesc2.Id,cscfga__Value__c='a4M1100000001jM', Name='No Asbestos');
        cscfga__Attribute__c attr6 = new cscfga__Attribute__c(cscfga__Is_Line_Item__c = false, cscfga__Product_Configuration__c = descConfList[1].Id, cscfga__Attribute_Definition__c = attDefDesc2.Id,cscfga__Value__c='a3R110000000A0dEAE', Name='Not a line item part');
        
        List<cscfga__Attribute__c> attributeList = new List<cscfga__Attribute__c>{attr1, attr2, attr3, attr4, attr5, attr6};
        insert attributeList;
        
        List<cscfga__Attribute__c> retrievedAttributes = [select Id from cscfga__Attribute__c];
        system.assertEquals(6, retrievedAttributes.size(), 'Mismatched number of attributes');
        
        // create a partsmodel attachment for the root configuration
        
        CS_Bundle__c nBundle = new CS_Bundle__c();
        insert nBundle;
        
        CS_VAT_Code__c nVat = new CS_VAT_Code__c(Percentage__c = 5);
        insert nVat;
        
        CS_Part__c nPart1 = new CS_Part__c(Part_Code__c = '12345', VAT_Code__c = nVat.Id);
        CS_Part__c nPart2 = new CS_Part__c(Part_Code__c = '54321', VAT_Code__c = nVat.Id);
        insert nPart1;
        insert nPart2;
        
        String partsModelString = '{"Default_Asbestos_0":{"pricebookType":"Standard","parentPart":{"vatAmount":0.5,"totalVatAmount":0.5,"totalSkillsCostForUnit":0,"totalSkillsCost":0,"totalPriceIncVAT":10.5,"totalNetPrice":10,"totalMaterialsCostForUnit":0,"totalMaterialsCost":0,"skillsList":[],"quantity":1,"priceVatIncl":10.5,"price":10,"part":{"Is_Placeholder_Formula__c":0,"POS__c":false,"Loft_Formula__c":"No","PM__c":false,"LastModifiedDate":"2014-05-08","Contributing_to_Margin__c":false,"Exists_in_Standard_Pricebook__c":true,"Instances_in_Standard_Pricebook__c":1,"Thumbnail_Image__c":"&lt;img src=&quot;/resource/part_images/&quot; alt=&quot;part image&quot; border=&quot;0&quot;/&gt;","Section_Level__c":"Level 2","Accessory__c":false,"Solar__c":false,"Wireless__c":false,"Part_Code__c":"No Asbestos","VAT_Code__c":"' + nVat.Id + '","Mandatory__c":false,"Low_Surface_Temp__c":"No","POR_Formula__c":"No","Active_Formula__c":1,"Active__c":true,"Included_In_Regions__c":"Test region south,South London,Test region central,North West,Test region north","IsDeleted":false,"Id":"' + nPart1.Id + '","Description__c":"No Asbestos Pack","Instances_in_LowCost_Pricebook__c":1,"Section_Name__c":"Safety","Visible_on_Quote__c":false,"Specific_Formula__c":0,"Commissionable__c":false,"Discountable__c":false,"Angled__c":false,"SystemModstamp":"2014-05-24","Programmable__c":false,"Work_without_a_Boiler__c":false,"Exists_in_Pricebooks__c":"Standard,Low Cost","Work_without_a_Boiler_Formula__c":"No","POR__c":false,"Valves__c":false,"Specific__c":false,"Electric__c":false,"Is_Placeholder__c":false,"Loft__c":false,"Exists_in_Low_Cost_Pricebook__c":true,"Name":"No Asbestos","Installation_Pack__c":false,"Record_Type_Name__c":"Other Packs","CreatedDate":"2014-04-10","VAT_Percentage__c":5,"Upliftable__c":false,"Installation_Pack_Formula__c":0,"Type__c":"No Asbestos"},"materialsList":[],"marginPreAllowances":10,"listPrice":10,"geographicUpliftAmount":0},"parentBundle":null,"isPriceOverriden":false,"isPlaceholder":false,"isPart":true,"isMultilookup":false,"isLineItem":true,"isBundle":false,"installationNotes":"","installationLocation":"","geographicUpliftFactor":0,"districtCode":"HT72","attRef":"Default_Asbestos_0","attLastValue":"' + nPart1.Id + '","attLastQuantity":1,"attLastLineItemDescription":null,"associatedParts":[],"aggregatedPriceInclVAT":10.5,"aggregatedNetPrice":10,"aggregatedCost":0},"Scaffolding_Pack_0":{"pricebookType":"Standard","parentPart":{"vatAmount":0.55,"totalVatAmount":0.55,"totalSkillsCostForUnit":100,"totalSkillsCost":100,"totalPriceIncVAT":11.55,"totalNetPrice":11,"totalMaterialsCostForUnit":0,"totalMaterialsCost":0,"skillsList":[{"totalStandardCost":100,"totalLowCost":50,"skillCode":"SB","name":"Specialist Building Work","hours":5,"costPerHrStandard":20,"costPerHrLowCost":10}],"quantity":1,"priceVatIncl":11.55,"price":11,"part":{"Is_Placeholder_Formula__c":0,"POS__c":false,"Loft_Formula__c":"No","PM__c":false,"LastModifiedDate":"2014-06-06","Contributing_to_Margin__c":true,"Exists_in_Standard_Pricebook__c":true,"Instances_in_Standard_Pricebook__c":1,"Thumbnail_Image__c":"&lt;img src=&quot;/resource/part_images/&quot; alt=&quot;part image&quot; border=&quot;0&quot;/&gt;","Section_Level__c":"Level 1","Accessory__c":false,"Solar__c":false,"Wireless__c":false,"Part_Code__c":"P1946","VAT_Code__c":"' + nVat.Id + '","Mandatory__c":false,"Low_Surface_Temp__c":"No","POR_Formula__c":"No","Active_Formula__c":1,"Active__c":true,"Quote_Description__c":"Specialist building work","Included_In_Regions__c":"Test region south,South London,Test region central,North West,Test region north","IsDeleted":false,"Id":"' + nPart2.Id + '","Description__c":"Specialist Building Work (5)","Instances_in_LowCost_Pricebook__c":0,"Quote_Section__c":"Customisation &amp; Compliance","Section_Name__c":"Installation Type &amp; Location","Visible_on_Quote__c":true,"Specific_Formula__c":0,"Commissionable__c":false,"Discountable__c":true,"Part_Group__c":"Pack","Angled__c":false,"SystemModstamp":"2014-06-06","Programmable__c":false,"Exists_in_Pricebooks__c":"Standard,None","Work_without_a_Boiler__c":false,"Work_without_a_Boiler_Formula__c":"No","Total_S_Cost_Standard__c":100,"POR__c":false,"Valves__c":false,"Specific__c":false,"Electric__c":false,"Total_S_Cost_Low_Cost__c":50,"Is_Placeholder__c":false,"Loft__c":false,"Exists_in_Low_Cost_Pricebook__c":false,"Name":"Specialist Building Work (5)","Installation_Pack__c":false,"Record_Type_Name__c":"Other Packs","CreatedDate":"2014-03-03","VAT_Percentage__c":5,"Upliftable__c":false,"Installation_Pack_Formula__c":0,"Type__c":"Scaffolding"},"materialsList":[],"marginPreAllowances":-89,"listPrice":11,"geographicUpliftAmount":0},"parentBundle":null,"isPriceOverriden":false,"isPlaceholder":false,"isPart":true,"isMultilookup":false,"isLineItem":true,"isBundle":false,"installationNotes":"","installationLocation":"","geographicUpliftFactor":0,"districtCode":"HT72","attRef":"Scaffolding_Pack_0","attLastValue":"' + nPart2.Id + '","attLastQuantity":1,"attLastLineItemDescription":null,"associatedParts":[],"aggregatedPriceInclVAT":122.25999999999999,"aggregatedNetPrice":116.71,"aggregatedCost":127.36},"Earthing_Bundle_Id_0":{"pricebookType":"Standard","parentPart":null,"parentBundle":{"Visible_Earth__c":"No","LastModifiedDate":"2014-05-22","Customer_to_Arrange__c":"No","RCD__c":"N/A","Name":"TT System Type, Visible Earth NO, Customer to Arrange NO, Passed","Socket_and_See_Result__c":"Passed","SystemModstamp":"2014-05-22","CreatedDate":"2014-05-21","IsDeleted":false,"Type__c":"Earthing","Working_VOELCB__c":"N/A","Id":"' + nBundle.Id + '","Description__c":"TT System Type, Visible Earth NO, Customer to Arrange NO, Passed","Earth_System_Type__c":"TT Earth System","Show_Parts__c":true},"isPriceOverriden":false,"isPlaceholder":false,"isPart":false,"isMultilookup":false,"isLineItem":true,"isBundle":true,"installationNotes":"","installationLocation":"","geographicUpliftFactor":0,"districtCode":"HT72","attRef":"Earthing_Bundle_Id_0","attLastValue":"' + nBundle.Id + '","attLastQuantity":1,"attLastLineItemDescription":null,"associatedParts":[],"aggregatedPriceInclVAT":155.0745,"aggregatedNetPrice":147.69,"aggregatedCost":0}}';
        Blob body = Blob.valueOf(partsModelString);
        Attachment a = new Attachment(Name = 'partsModel.txt', ParentId=rootConf.Id,  Body = body);
        insert a;
        
        List<Attachment> retrievedAttachments = [select Id from Attachment];
        system.assertEquals(1, retrievedAttachments.size(), 'Mismatched number of attachments');
        
        // create a controller
        Appointment__c app = new Appointment__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(app);
        CS_DifferenceReviewController controller;
        controller = new CS_DifferenceReviewController(sc);
        
        // set the dateFromString and dateToString
        controller.dateFromString = DateTime.now().addMonths(-1).format('dd/MM/yyyy');
        controller.dateToString = DateTime.now().addMonths(1).format('dd/MM/yyyy');
        controller.status = 'Quote Finalised - Not Accepted';
        
        // invoke the controller method
        controller.getPcFilteredList();
        
    }
        
    private static testMethod void clearEmptyErrorModelListTest() {
        
        List<CS_DifferenceReviewController.CustomPartModel> cpm1 = new List<CS_DifferenceReviewController.CustomPartModel> { 
                    new CS_DifferenceReviewController.CustomPartModel('a4T110000000DGpEAM', 'Specialist Building Work (5)') }; 
        
        CS_DifferenceReviewController.CustomErrorModel cem1 
            = new CS_DifferenceReviewController.CustomErrorModel('a3R110000000A0OEAU', 'C123456781', Datetime.now(), cpm1, new List<CS_DifferenceReviewController.CustomPartModel>());
        CS_DifferenceReviewController.CustomErrorModel cem2 
            = new CS_DifferenceReviewController.CustomErrorModel('a3R110000000A0dEAE', 'C123456782', Datetime.now(), new List<CS_DifferenceReviewController.CustomPartModel>(), new List<CS_DifferenceReviewController.CustomPartModel>());
        CS_DifferenceReviewController.CustomErrorModel cem3 
            = new CS_DifferenceReviewController.CustomErrorModel('a3R110000000A0TEAU', 'C123456783', Datetime.now(), new List<CS_DifferenceReviewController.CustomPartModel>(), cpm1);
            
        List<CS_DifferenceReviewController.CustomErrorModel> errModelList = new List<CS_DifferenceReviewController.CustomErrorModel>();
        errModelList.add(cem1);
        errModelList.add(cem2);
        errModelList.add(cem3);
        
        CS_DifferenceReviewController.clearEmptyErrorModelList(errModelList);
        System.assertEquals(2, errModelList.size());
    }

	private static testMethod void returnRootCustomPartModelsTest() {

        CS_Bundle__c nBundle = new CS_Bundle__c();
        insert nBundle;
        
        CS_VAT_Code__c nVat = new CS_VAT_Code__c(Percentage__c = 5);
        insert nVat;
        
        CS_Part__c nPart1 = new CS_Part__c(Part_Code__c = '12345', VAT_Code__c = nVat.Id);
        CS_Part__c nPart2 = new CS_Part__c(Part_Code__c = '54321', VAT_Code__c = nVat.Id);
        insert nPart1;
        insert nPart2;

        String partsModelString = '{"Default_Asbestos_0":{"pricebookType":"Standard","parentPart":{"vatAmount":0.5,"totalVatAmount":0.5,"totalSkillsCostForUnit":0,"totalSkillsCost":0,"totalPriceIncVAT":10.5,"totalNetPrice":10,"totalMaterialsCostForUnit":0,"totalMaterialsCost":0,"skillsList":[],"quantity":1,"priceVatIncl":10.5,"price":10,"part":{"Is_Placeholder_Formula__c":0,"POS__c":false,"Loft_Formula__c":"No","PM__c":false,"LastModifiedDate":"2014-05-08","Contributing_to_Margin__c":false,"Exists_in_Standard_Pricebook__c":true,"Instances_in_Standard_Pricebook__c":1,"Thumbnail_Image__c":"&lt;img src=&quot;/resource/part_images/&quot; alt=&quot;part image&quot; border=&quot;0&quot;/&gt;","Section_Level__c":"Level 2","Accessory__c":false,"Solar__c":false,"Wireless__c":false,"Part_Code__c":"No Asbestos","VAT_Code__c":"' + nVat.Id + '","Mandatory__c":false,"Low_Surface_Temp__c":"No","POR_Formula__c":"No","Active_Formula__c":1,"Active__c":true,"Included_In_Regions__c":"Test region south,South London,Test region central,North West,Test region north","IsDeleted":false,"Id":"' + nPart1.Id + '","Description__c":"No Asbestos Pack","Instances_in_LowCost_Pricebook__c":1,"Section_Name__c":"Safety","Visible_on_Quote__c":false,"Specific_Formula__c":0,"Commissionable__c":false,"Discountable__c":false,"Angled__c":false,"SystemModstamp":"2014-05-24","Programmable__c":false,"Work_without_a_Boiler__c":false,"Exists_in_Pricebooks__c":"Standard,Low Cost","Work_without_a_Boiler_Formula__c":"No","POR__c":false,"Valves__c":false,"Specific__c":false,"Electric__c":false,"Is_Placeholder__c":false,"Loft__c":false,"Exists_in_Low_Cost_Pricebook__c":true,"Name":"No Asbestos","Installation_Pack__c":false,"Record_Type_Name__c":"Other Packs","CreatedDate":"2014-04-10","VAT_Percentage__c":5,"Upliftable__c":false,"Installation_Pack_Formula__c":0,"Type__c":"No Asbestos"},"materialsList":[],"marginPreAllowances":10,"listPrice":10,"geographicUpliftAmount":0},"parentBundle":null,"isPriceOverriden":false,"isPlaceholder":false,"isPart":true,"isMultilookup":false,"isLineItem":true,"isBundle":false,"installationNotes":"","installationLocation":"","geographicUpliftFactor":0,"districtCode":"HT72","attRef":"Default_Asbestos_0","attLastValue":"' + nPart1.Id + '","attLastQuantity":1,"attLastLineItemDescription":null,"associatedParts":[],"aggregatedPriceInclVAT":10.5,"aggregatedNetPrice":10,"aggregatedCost":0},"Scaffolding_Pack_0":{"pricebookType":"Standard","parentPart":{"vatAmount":0.55,"totalVatAmount":0.55,"totalSkillsCostForUnit":100,"totalSkillsCost":100,"totalPriceIncVAT":11.55,"totalNetPrice":11,"totalMaterialsCostForUnit":0,"totalMaterialsCost":0,"skillsList":[{"totalStandardCost":100,"totalLowCost":50,"skillCode":"SB","name":"Specialist Building Work","hours":5,"costPerHrStandard":20,"costPerHrLowCost":10}],"quantity":1,"priceVatIncl":11.55,"price":11,"part":{"Is_Placeholder_Formula__c":0,"POS__c":false,"Loft_Formula__c":"No","PM__c":false,"LastModifiedDate":"2014-06-06","Contributing_to_Margin__c":true,"Exists_in_Standard_Pricebook__c":true,"Instances_in_Standard_Pricebook__c":1,"Thumbnail_Image__c":"&lt;img src=&quot;/resource/part_images/&quot; alt=&quot;part image&quot; border=&quot;0&quot;/&gt;","Section_Level__c":"Level 1","Accessory__c":false,"Solar__c":false,"Wireless__c":false,"Part_Code__c":"P1946","VAT_Code__c":"' + nVat.Id + '","Mandatory__c":false,"Low_Surface_Temp__c":"No","POR_Formula__c":"No","Active_Formula__c":1,"Active__c":true,"Quote_Description__c":"Specialist building work","Included_In_Regions__c":"Test region south,South London,Test region central,North West,Test region north","IsDeleted":false,"Id":"' + nPart2.Id + '","Description__c":"Specialist Building Work (5)","Instances_in_LowCost_Pricebook__c":0,"Quote_Section__c":"Customisation &amp; Compliance","Section_Name__c":"Installation Type &amp; Location","Visible_on_Quote__c":true,"Specific_Formula__c":0,"Commissionable__c":false,"Discountable__c":true,"Part_Group__c":"Pack","Angled__c":false,"SystemModstamp":"2014-06-06","Programmable__c":false,"Exists_in_Pricebooks__c":"Standard,None","Work_without_a_Boiler__c":false,"Work_without_a_Boiler_Formula__c":"No","Total_S_Cost_Standard__c":100,"POR__c":false,"Valves__c":false,"Specific__c":false,"Electric__c":false,"Total_S_Cost_Low_Cost__c":50,"Is_Placeholder__c":false,"Loft__c":false,"Exists_in_Low_Cost_Pricebook__c":false,"Name":"Specialist Building Work (5)","Installation_Pack__c":false,"Record_Type_Name__c":"Other Packs","CreatedDate":"2014-03-03","VAT_Percentage__c":5,"Upliftable__c":false,"Installation_Pack_Formula__c":0,"Type__c":"Scaffolding"},"materialsList":[],"marginPreAllowances":-89,"listPrice":11,"geographicUpliftAmount":0},"parentBundle":null,"isPriceOverriden":false,"isPlaceholder":false,"isPart":true,"isMultilookup":false,"isLineItem":true,"isBundle":false,"installationNotes":"","installationLocation":"","geographicUpliftFactor":0,"districtCode":"HT72","attRef":"Scaffolding_Pack_0","attLastValue":"' + nPart2.Id + '","attLastQuantity":1,"attLastLineItemDescription":null,"associatedParts":[],"aggregatedPriceInclVAT":122.25999999999999,"aggregatedNetPrice":116.71,"aggregatedCost":127.36},"Earthing_Bundle_Id_0":{"pricebookType":"Standard","parentPart":null,"parentBundle":{"Visible_Earth__c":"No","LastModifiedDate":"2014-05-22","Customer_to_Arrange__c":"No","RCD__c":"N/A","Name":"TT System Type, Visible Earth NO, Customer to Arrange NO, Passed","Socket_and_See_Result__c":"Passed","SystemModstamp":"2014-05-22","CreatedDate":"2014-05-21","IsDeleted":false,"Type__c":"Earthing","Working_VOELCB__c":"N/A","Id":"' + nBundle.Id + '","Description__c":"TT System Type, Visible Earth NO, Customer to Arrange NO, Passed","Earth_System_Type__c":"TT Earth System","Show_Parts__c":true},"isPriceOverriden":false,"isPlaceholder":false,"isPart":false,"isMultilookup":false,"isLineItem":true,"isBundle":true,"installationNotes":"","installationLocation":"","geographicUpliftFactor":0,"districtCode":"HT72","attRef":"Earthing_Bundle_Id_0","attLastValue":"' + nBundle.Id + '","attLastQuantity":1,"attLastLineItemDescription":null,"associatedParts":[],"aggregatedPriceInclVAT":155.0745,"aggregatedNetPrice":147.69,"aggregatedCost":0}}';
        List<CS_DifferenceReviewController.CustomPartModel> rootPartsList = new List<CS_DifferenceReviewController.CustomPartModel>();
	    try {
            Map<String, CS_PartModelEntry> partsModel = 
                (Map<String, CS_PartModelEntry>)JSON.deserialize(partsModelString, Map<String, CS_PartModelEntry>.class); 
            
            rootPartsList = CS_DifferenceReviewController.returnRootCustomPartModels(partsModel);
            
        } catch (Exception e) {}

        System.assertEquals(3, rootPartsList.size());
        
        CS_DifferenceReviewController.CustomPartModel o1 = rootPartsList[0];
        CS_DifferenceReviewController.CustomPartModel o2 = rootPartsList[1];
        CS_DifferenceReviewController.CustomPartModel o3 = rootPartsList[2];

        System.debug('###: ' + o1.Id);
        System.debug('###: ' + o2.Id);
        System.debug('###: ' + o3.Id);
        
        System.assertEquals(nPart1.Id, o1.Id);
        System.assertEquals('No Asbestos', o1.Name);
        System.assertEquals(nPart2.Id, o2.Id);
        System.assertEquals('Specialist Building Work (5)', o2.Name);
        System.assertEquals(nBundle.Id, o3.Id);
        System.assertEquals('TT System Type, Visible Earth NO, Customer to Arrange NO, Passed', o3.Name);
	}
	
	private static testMethod void parseDateStringTest(){
        
        System.assertEquals(null, CS_DifferenceReviewController.parseDateString(null));
        System.assertEquals(null, CS_DifferenceReviewController.parseDateString(''));
        System.assertEquals(Date.newInstance(2014,2,21), CS_DifferenceReviewController.parseDateString('21/02/2014'));
        System.assertEquals(Date.newInstance(2014,5,12), CS_DifferenceReviewController.parseDateString('2014-05-12'));
    }
	
	
}