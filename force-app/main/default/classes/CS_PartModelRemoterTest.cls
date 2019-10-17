@isTest
public class CS_PartModelRemoterTest {

    public static String pricebookType = 'Standard';
    public static String boilerGroup = 'Worcester';
    public static String regionCode = 'South London';
    public static String districtCode = 'R03D10';
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
        
    static testMethod void getPartModelInformationTest(){
  
        createData();
        
        //Run test for Standard Pricebook, Region ''
        
        //atbRef, atbVal, atbPrice, attQuantity, attDesc,attIsLineItem, attIsPart, attIsBundle, attIsMultiLookup, attIsPlaceholder, attIsPriceOverriden, installLocation
        CS_RemotingParamWrapper attBoiler = new CS_RemotingParamWrapper('boiler_0', boiler.Id, 0, 1,'Ignore', true, true, false, false, false, false, 'Kitchen', 'notes');   //Boiler, no override
        CS_RemotingParamWrapper attPlcRad = new CS_RemotingParamWrapper('plcRadMedium_0', plcRadMedium.Id, 0, 1,'Ignore', true, true, false, false, true, false, 'Living room', 'notes');   //Plc Rad, no override
        CS_RemotingParamWrapper attRad = new CS_RemotingParamWrapper('radiator_0', radiator.Id, 180, 2,'Overriden Desc: Medium', true, true, false, false, false, true, 'Bedroom', 'notes');   //Radiators, 2, with override
        CS_RemotingParamWrapper attPackC = new CS_RemotingParamWrapper('packC_0', (packC1.Id + ',' + packC2.Id), 0, 1,'Ignore', true, true, false, true, false, false, '', 'notes');   //A multilookup
        CS_RemotingParamWrapper attBundleAB = new CS_RemotingParamWrapper('bundleAB_0', bundleAB.Id, 0, 1,'Ignore', true, false, true, false, false, false, '', 'notes');   //A Bundle
        CS_RemotingParamWrapper attFlueBundle = new CS_RemotingParamWrapper('flue_0', flueBundle.Id, 0, 1,'Ignore', true, false, true, false, false, false, '', 'notes');   //Flue Bundle 

        List<CS_RemotingParamWrapper> attsChanged = new List<CS_RemotingParamWrapper>{attBoiler, attPlcRad, attRad, attPackC, attBundleAB, attFlueBundle};
        
        Map<String, CS_PartModelEntry> model = CS_PartModelRemoter.getPartModelInformation(attsChanged, regionCode,  districtCode, CS_Constants.CS_PricebookType_Standard, boilerGroup, geographicalUplift);
        
        system.AssertEquals(6, model.keySet().size());
      
        //Check each Entry

        for (String attRef : model.keySet()) {
            CS_PartModelEntry entry = model.get(attRef);
            
            if (attRef == attBoiler.attRef) {
                checkForBoiler(attBoiler, entry);
            }
            else if (attRef == attPlcRad.attRef) {
                checkForPlcRad(attPlcRad, entry);
            }
            else if (attRef == attRad.attRef) {
                checkForRad(attRad, entry);
            }
            else if (attRef == attPackC.attRef) {
                checkForPackC(attPackC, entry);
            }
            else if (attRef == attBundleAB.attRef) {
                checkForBundleAB(attBundleAB, entry);
            }
            else if (attRef == attFlueBundle.attRef) {
                checkForFlueBundle(attFlueBundle, entry);
            }
        }
    } 
    

    static void checkGenericEntryLevelProperties(CS_RemotingParamWrapper att, CS_PartModelEntry entry) {
        system.assertEquals(att.isPart, entry.isPart);
        system.assertEquals(att.isLineItem, entry.isLineItem);
        system.assertEquals(att.isBundle, entry.isBundle);
        system.assertEquals(att.isMultilookup, entry.isMultilookup);
        system.assertEquals(pricebookType, entry.pricebookType);
        system.assertEquals(districtCode, entry.districtCode);
        system.assertEquals(att.attRef, entry.attRef);
        system.assertEquals(att.attValue, entry.attLastValue);
        system.assertEquals(att.quantity, entry.attLastQuantity);
        system.assertEquals(att.lineItemDescription, entry.attLastLineItemDescription);
        system.assertEquals(att.installationLocation, entry.installationLocation);
    
    }
    
    static void checkParentPartProperties(CS_PartModelEntry entry, Decimal unitPrice, Decimal vatPerc, Decimal quantity, Decimal unitSkillCost, Decimal unitMaterialCost) {
    
        system.assertEquals((unitPrice * vatPerc), entry.parentPart.vatAmount);
        system.assertEquals((unitPrice * vatPerc * quantity) , entry.parentPart.totalVatAmount);
        system.assertEquals(unitPrice * quantity, entry.parentPart.totalNetPrice);
        system.assertEquals((unitPrice + entry.parentPart.vatAmount) * quantity, entry.parentPart.totalPriceIncVAT);
        
        system.assertEquals(unitSkillCost, entry.parentPart.totalSkillsCostForUnit);
        system.assertEquals(unitSkillCost * quantity, entry.parentPart.totalSkillsCost);
        system.assertEquals(unitMaterialCost, entry.parentPart.totalMaterialsCostForUnit);
        system.assertEquals(unitMaterialCost * quantity, entry.parentPart.totalMaterialsCost);
        
        system.assertEquals(quantity, entry.parentPart.quantity);
        system.assertEquals((unitPrice + entry.parentPart.vatAmount), entry.parentPart.priceVatIncl);
        system.assertEquals(unitPrice, entry.parentPart.price);
        system.assertEquals(((unitPrice*quantity) - (unitSkillCost*quantity) - (unitMaterialCost*quantity)), entry.parentPart.marginPreAllowances);
    }
    
    static void checkAggregatedTotals(CS_PartModelEntry entry, Decimal aggregatedNetPrice, Decimal aggregatedPriceInclVAT, Decimal aggregatedCost) {
        
        system.assertEquals(aggregatedNetPrice.setScale(2), entry.aggregatedNetPrice);
        system.assertEquals(aggregatedPriceInclVAT.setScale(2), entry.aggregatedPriceInclVAT);
        system.assertEquals(aggregatedCost.setScale(2), entry.aggregatedCost);
      }
    
    /* 
     * The only associated Products that should be coming back are P2, P3, P4, P5.
     * P2 is £20 with vat2 (10%), Not contributing to Margin, Total Skills, Total Materials tbc
     * P3 is £23 with vat2 (10%), Contributing to Margin
     * P4 is not applicable for date, so Price should be £0, Contributing to Margin
     * P5 (£20) is not in district, so Price should be £0, Contributing to Margin
     * P6 (£18) is not in region, so Price should be £0, Contributing to Margin
     * p7Flue is £40, vat2, Contributing to Margin, right Boiler Group
     * p8Flue is £50, vat2, Not Contributing, NOT right Boiler Group
     */
    
    
    /*
    * Boiler is a Part. Associated Parts are:  2*P2, 1*P3, and 1*P4
    * Boiler @ £100 - vat1 - Contributing to Margin
    */
    static void checkForBoiler(CS_RemotingParamWrapper attBoiler, CS_PartModelEntry entry) {
        //generic
        checkGenericEntryLevelProperties(attBoiler, entry);
        
        system.assert(entry.parentBundle == null);
        system.assert(entry.parentPart != null);
        
        //Check parentPart
        checkParentPartProperties(entry, 100, (vat1.Percentage__c/100), 1, 12, 11);
        system.assertEquals(boiler.Id, entry.parentPart.part.Id);

        //system.assertEquals( , entry.parentPart.skillsList);
        //system.assertEquals( , entry.parentPart.materialsList);
        
        system.assertEquals(12, entry.parentPart.totalSkillsCost); //check!
        
        //Check AssociatedParts
        system.assertEquals(3, entry.associatedParts.size());
        
        //checkEntryLevelTotals
        Decimal aggregatedNetPrice = 100 + (2*20) + 23 + 0;
        Decimal aggregatedPriceInclVAT = aggregatedNetPrice + (100 * vat1.Percentage__c/100) + (2*20 * vat2.Percentage__c/100) + (23 * vat2.Percentage__c/100) + 0;
        
        Decimal aggregatedSkillsCost = 12 + 0 + 14 + 0;
        Decimal aggregatedMaterialsCost = 11 + 0 + 12 + 0;// + 8; //P4 seems to not be considered!!!!   To DO See Q123
        Decimal aggregatedCost = aggregatedSkillsCost + aggregatedMaterialsCost;

        checkAggregatedTotals(entry, aggregatedNetPrice, aggregatedPriceInclVAT, aggregatedCost); 
    }
  
    /*
    * PlcRad is a Part. Has NO associations
    * PlcRad @ £100 - vat1 - Contributing to Margin
    */
    static void checkForPlcRad (CS_RemotingParamWrapper attPlcRad, CS_PartModelEntry entry) {
        //generic
        checkGenericEntryLevelProperties(attPlcRad, entry);
        
        system.assert(entry.parentBundle == null);
        system.assert(entry.parentPart != null);
        
        //Check parentPart
        checkParentPartProperties(entry, 100, (vat1.Percentage__c/100), 1, 15, 0);
        system.assertEquals(plcRadMedium.Id, entry.parentPart.part.Id);

        //check No AssociatedParts
        system.assertEquals(0, entry.associatedParts.size());
        
        //checkEntryLevelTotals
        Decimal aggregatedNetPrice = 100;
        Decimal aggregatedPriceInclVAT = aggregatedNetPrice + (100 * vat1.Percentage__c/100);
        
        Decimal aggregatedSkillsCost = 15;
        Decimal aggregatedMaterialsCost = 0;
        Decimal aggregatedCost = aggregatedSkillsCost + aggregatedMaterialsCost;

        checkAggregatedTotals(entry, aggregatedNetPrice, aggregatedPriceInclVAT, aggregatedCost);
    }

    /*
    * Rad is a Part. Should have NO associations as they are all not applicable (P1, P5, P6) - *** for now only P1 & P6 are filtered out
    * Rad @ £70 - vat1 - Contributing to Margin. Price is overriden at £180. Quantity = 2
    */
    static void checkForRad(CS_RemotingParamWrapper attRad, CS_PartModelEntry entry) {
        //generic
        checkGenericEntryLevelProperties(attRad, entry);
        
        system.assert(entry.parentBundle == null);
        system.assert(entry.parentPart != null);
        
        //Check parentPart
        checkParentPartProperties(entry, 180, (vat1.Percentage__c/100), 2, 8, 10);
        system.assertEquals(radiator.Id, entry.parentPart.part.Id);

        //check AssociatedParts
        system.debug('***********');
        system.debug(JSON.serializePretty(entry));
        system.assertEquals(2, entry.associatedParts.size());
        
         //checkEntryLevelTotals
        Decimal aggregatedNetPrice = 2 * (198 + 0);
        Decimal aggregatedPriceInclVAT = aggregatedNetPrice + 2 * (189 * vat1.Percentage__c/100);
        
        Decimal aggregatedSkillsCost = (2 * 8);
        Decimal aggregatedMaterialsCost = (2 * 10); // To DO: this is not considered P5 + (2* 3); See Q123
        Decimal aggregatedCost = aggregatedSkillsCost + aggregatedMaterialsCost;

        checkAggregatedTotals(entry, aggregatedNetPrice, aggregatedPriceInclVAT, aggregatedCost); 
    }

    /*
    * PackC is a multilookup so associations are assumed to be N/A. Values are PackC1 and PackC2
    * PackC1 @ £40 - vat1 - Contributing to Margin
    * PackC2 @ £43 - vat2 - Not Contributing to Margin
    */
    static void checkForPackC(CS_RemotingParamWrapper attPackC, CS_PartModelEntry entry) {
        //generic
        checkGenericEntryLevelProperties(attPackC, entry);
        
        system.assert(entry.parentBundle == null);
        system.assert(entry.parentPart == null);
        
        //chec No AssociatedParts
         system.assertEquals(2, entry.associatedParts.size());
         
        //checkEntryLevelTotals
        Decimal aggregatedNetPrice = 40 + 30;
        Decimal aggregatedPriceInclVAT = aggregatedNetPrice + (40 * vat1.Percentage__c/100) + (30 * vat2.Percentage__c/100);
        
        Decimal aggregatedSkillsCost = 15 + 0;
        Decimal aggregatedMaterialsCost = 5 + 0;
        Decimal aggregatedCost = aggregatedSkillsCost + aggregatedMaterialsCost;

        checkAggregatedTotals(entry, aggregatedNetPrice, aggregatedPriceInclVAT, aggregatedCost); 
    }
    
    /*
    * BundleAB is a Bundle. Associations are 2*P1 (not in Pricebook), 1*P2 (£20), 3*P3 (£23)
    */
    static void checkForBundleAB(CS_RemotingParamWrapper attBundleAB, CS_PartModelEntry entry) {
        //generic
        checkGenericEntryLevelProperties(attBundleAB, entry);
        
        system.assert(entry.parentBundle != null);
        system.assert(entry.parentPart == null);
        
        // Check parentBundle
        system.assertEquals(bundleAB.Id, entry.parentBundle.Id);
        system.assertEquals(3, entry.parentBundle.CS_Bundle_Part_Associations__r.size());
        
        //checkAssociatedParts
        system.assertEquals(2, entry.associatedParts.size());
        
        //checkEntryLevelTotals
        Decimal aggregatedNetPrice = 20 + (3*23);
        Decimal aggregatedPriceInclVAT = aggregatedNetPrice + (20 * vat2.Percentage__c/100) + (3 * 23 * vat2.Percentage__c/100);
        
        Decimal aggregatedSkillsCost = 0 + (3 * 14);
        Decimal aggregatedMaterialsCost = 0 + (3*12);  //P2 is not contributing to Margin
        Decimal aggregatedCost = aggregatedSkillsCost + aggregatedMaterialsCost;

        checkAggregatedTotals(entry, aggregatedNetPrice, aggregatedPriceInclVAT, aggregatedCost); 
    }

    /*
    * Flue is a Bundle. Associations are 2*P7Flue (£40). P8Flue is not compatible with boiler group so shouldn't come back
    */
    static void checkForFlueBundle(CS_RemotingParamWrapper attFlue, CS_PartModelEntry entry) {
        //generic
        checkGenericEntryLevelProperties(attFlue, entry);
        
        system.assert(entry.parentBundle != null);
        system.assert(entry.parentPart == null);
        
        // Check parentBundle
        system.assertEquals(flueBundle.Id, entry.parentBundle.Id);
        system.assertEquals(2, entry.parentBundle.CS_Bundle_Part_Associations__r.size()); //Holds original list
        
        //checkAssociatedParts
        system.assertEquals(1, entry.associatedParts.size());
        
        //checkEntryLevelTotals
        Decimal aggregatedNetPrice = 2 * 40;
        Decimal aggregatedPriceInclVAT = aggregatedNetPrice + (2 * 40 * vat2.Percentage__c/100);
        
        Decimal aggregatedSkillsCost = (2 * 14);
        Decimal aggregatedMaterialsCost = (2*7);
        Decimal aggregatedCost = aggregatedSkillsCost + aggregatedMaterialsCost;

        checkAggregatedTotals(entry, aggregatedNetPrice, aggregatedPriceInclVAT, aggregatedCost); 
    }

    
    public static void createData() {

        //Create Region
        Region__c r = new Region__c(Name = regionCode, Code__c = 'bla');
        Region__c otherR = new Region__c(Name = 'other', Code__c = 'other');
        insert new List<Region__c> {r, otherR};
        
        //Create District
        District__c district1 = new District__c(Name = 'a district 1', Code__c = districtCode);
        District__c district2 = new District__c(Name = 'a district 2', Code__c = 'bla');
        insert new List<District__c> {district1, district2};
    
        //Create Pricebooks
        CS_Pricebook__c stdPricebook = new CS_Pricebook__c(Name = 'Standard', Type__c = CS_Constants.CS_PricebookType_Standard);
        CS_Pricebook__c lowCostPricebook = new CS_Pricebook__c(Name = 'Low Cost', Type__c = CS_Constants.CS_PricebookType_LowCost);
    
        insert new List<CS_Pricebook__c>{stdPricebook, lowCostPricebook};

        //Create an AB Bundle
        bundleAB = new CS_Bundle__c(Name='A1B1', Description__c='Same Room same location', Type__c = 'Core Bundle');
        
        //Create a Flue Bundle
        flueBundle = new CS_Bundle__c(Name='Flue 1', Description__c='A Flue', Type__c = 'Flue'); 
        insert new List<CS_Bundle__c> {bundleAB, flueBundle};
        
        //Create VAT Codes
        vat1 = new CS_VAT_Code__c(Name='VAT Code 20%', Percentage__c=20);
        vat2 = new CS_VAT_Code__c(Name='VAT Code 10%', Percentage__c=10);
        insert new List<CS_VAT_Code__c>{vat1, vat2};
   
        //Create parent Parts

        boiler = new CS_Part__c(Name='Worcester Boiler', Boiler_group__c=boilerGroup, Contributing_to_Margin__c=true, Part_Code__c = '001',
                                        Description__c='A Worcester Boiler', VAT_Code__c = vat1.Id, Active__c=false, Included_In_Regions__c =regionCode );
                                        
        plcRadMedium = new CS_Part__c(Name='Medium Radiator', Contributing_to_Margin__c=true, Part_Code__c = '003',
                                        Description__c='A Medium Radiator', VAT_Code__c = vat1.Id,  Active__c=false, Included_In_Regions__c =regionCode );             
                                        
        radiator = new CS_Part__c(Name='Special Radiator', Contributing_to_Margin__c=true, Part_Code__c = '004',
                                        Description__c='A special Radiator', VAT_Code__c = vat1.Id,  Active__c=false, Included_In_Regions__c =regionCode ); 
                                        
        packC1 = new CS_Part__c(Name='Pack C 1', Contributing_to_Margin__c=true, Part_Code__c = '005',
                                        Description__c='Pack C1', VAT_Code__c = vat1.Id,  Active__c=false, Included_In_Regions__c =regionCode );       
                                        
        packC2 = new CS_Part__c(Name='Pack C 2', Contributing_to_Margin__c=false, Part_Code__c = '006',
                                        Description__c='Pack C1', VAT_Code__c = vat2.Id,  Active__c=false, Included_In_Regions__c =regionCode );                     
                                        
        //Create associated Parts
        CS_Part__c p1 = new CS_Part__c(Name='Valve 1', Contributing_to_Margin__c=FALSE, Part_Code__c = '007',
                                        Description__c='A valve', VAT_Code__c = vat2.Id,  Active__c=false, Included_In_Regions__c =regionCode ); //Not in Pricebook - filtered out
                                        
        CS_Part__c p2 = new CS_Part__c(Name='Pipe 1', Contributing_to_Margin__c = FALSE, Part_Code__c = '008',
                                        Description__c='A pipe', VAT_Code__c = vat2.Id, Active__c=false, Included_In_Regions__c =regionCode ); //all good
                                        
        CS_Part__c p3 = new CS_Part__c(Name='Pipe 2', Contributing_to_Margin__c=TRUE, Part_Code__c = '009',
                                        Description__c='A pipe', VAT_Code__c = vat2.Id,Active__c=false, Included_In_Regions__c =regionCode ); //all good
                                        
        CS_Part__c p4 = new CS_Part__c(Name='Pipe 3', Contributing_to_Margin__c=TRUE, Part_Code__c = '010',
                                        Description__c='A pipe', VAT_Code__c = vat2.Id,Active__c=false, Included_In_Regions__c =regionCode ); //No date applicability => £0 Price
                                        
        CS_Part__c p5 = new CS_Part__c(Name='Pipe 4', Contributing_to_Margin__c=TRUE, Part_Code__c = '011',
                                        Description__c='A pipe', VAT_Code__c = vat2.Id,Active__c=false, Included_In_Regions__c =regionCode ); //Not in district => £0 Price
                                        
        CS_Part__c p6 = new CS_Part__c(Name='Pipe 5', Contributing_to_Margin__c=TRUE, Part_Code__c = '012',
                                        Description__c='A pipe', VAT_Code__c = vat2.Id,Active__c=false, Included_In_Regions__c =regionCode ); //Not in region - filtered out
                                        
                                        
        CS_Part__c p7Flue = new CS_Part__c(Name='Flue Pipe 7', Contributing_to_Margin__c=TRUE, Flue_Boiler_Groups__c=boilerGroup, Part_Code__c = '013',
                                        Description__c='A pipe', VAT_Code__c = vat2.Id,Active__c=false, Included_In_Regions__c =regionCode ); //all good, right boiler Group
                                        
        CS_Part__c p8Flue = new CS_Part__c(Name='Flue Pipe 7', Contributing_to_Margin__c=FALSE, Flue_Boiler_Groups__c='some other', Part_Code__c = '014',
                                        Description__c='A pipe', VAT_Code__c = vat2.Id,Active__c=false, Included_In_Regions__c =regionCode ); //all good, wrong boiler Group
                                        
        insert new List<CS_Part__c> {boiler, plcRadMedium, radiator, packC1, packC2, p1, p2, p3, p4, p5, p6, p7Flue, p8Flue};
        
        //BundleAB: Create 3 Bundle-Part associations
        CS_Bundle_Part_Association__c bpa1 = new CS_Bundle_Part_Association__c(Bundle__c=bundleAB.Id, Part__c=p1.Id, Quantity__c=2, Type__c = CS_Constants.CS_PartAssociationRelationship_Requires);
        CS_Bundle_Part_Association__c bpa2 = new CS_Bundle_Part_Association__c(Bundle__c=bundleAB.Id, Part__c=p2.Id, Quantity__c=1, Type__c = CS_Constants.CS_PartAssociationRelationship_Requires);
        CS_Bundle_Part_Association__c bpa3 = new CS_Bundle_Part_Association__c(Bundle__c=bundleAB.Id, Part__c=p3.Id, Quantity__c=3, Type__c = CS_Constants.CS_PartAssociationRelationship_Requires);
        insert new List<CS_Bundle_Part_Association__c> {bpa1, bpa2, bpa3};     
        
        //Flue Bundle: flueBundle
        CS_Bundle_Part_Association__c fluebpa1 = new CS_Bundle_Part_Association__c(Bundle__c=flueBundle.Id, Part__c=p7Flue.Id, Quantity__c=2, Type__c = CS_Constants.CS_PartAssociationRelationship_Requires);
        CS_Bundle_Part_Association__c fluebpa2 = new CS_Bundle_Part_Association__c(Bundle__c=flueBundle.Id, Part__c=p8Flue.Id, Quantity__c=2, Type__c = CS_Constants.CS_PartAssociationRelationship_Requires);
        insert new List<CS_Bundle_Part_Association__c> {fluebpa1, fluebpa2};
        
        //Create Part Associations
        CS_Part_Association__c boilerAss1 = new CS_Part_Association__c(Part_1__c = boiler.Id, Part_2__c = p2.Id, Quantity__c = 2, Relationship__c=CS_Constants.CS_PartAssociationRelationship_Requires);
        CS_Part_Association__c boilerAss2 = new CS_Part_Association__c(Part_1__c = boiler.Id, Part_2__c = p1.Id, Quantity__c = 1, Relationship__c=CS_Constants.CS_PartAssociationRelationship_Requires);
        CS_Part_Association__c boilerAss3 = new CS_Part_Association__c(Part_1__c = boiler.Id, Part_2__c = p3.Id, Quantity__c = 1, Relationship__c=CS_Constants.CS_PartAssociationRelationship_Requires);
        CS_Part_Association__c boilerAss4 = new CS_Part_Association__c(Part_1__c = boiler.Id, Part_2__c = p4.Id, Quantity__c = 1, Relationship__c=CS_Constants.CS_PartAssociationRelationship_Requires);

        CS_Part_Association__c radiatorAss1 = new CS_Part_Association__c(Part_1__c=radiator.Id, Part_2__c = p1.Id, Quantity__c = 1, Relationship__c=CS_Constants.CS_PartAssociationRelationship_Requires);
        CS_Part_Association__c radiatorAss2 = new CS_Part_Association__c(Part_1__c=radiator.Id, Part_2__c = p5.Id, Quantity__c = 1, Relationship__c=CS_Constants.CS_PartAssociationRelationship_Requires);
        CS_Part_Association__c radiatorAss3 = new CS_Part_Association__c(Part_1__c=radiator.Id, Part_2__c = p6.Id, Quantity__c = 1, Relationship__c=CS_Constants.CS_PartAssociationRelationship_Requires);
        
        //no associations for pack C's as they will be used in a multilookup
        insert new List<CS_Part_Association__c>{boilerAss1,boilerAss2,boilerAss3,boilerAss4,radiatorAss1,radiatorAss2,radiatorAss3};
        
        //Create Part Prices
        CS_Part_Price__c boilerStd = new CS_Part_Price__c(Part__c = boiler.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 100, Start_Date__c = Date.Today().addDays(-1));
        CS_Part_Price__c boilerLow = new CS_Part_Price__c(Part__c = boiler.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 90, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c plcRadMediumStd = new CS_Part_Price__c(Part__c = plcRadMedium.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 100, Start_Date__c = Date.Today().addDays(-1));
        CS_Part_Price__c plcRadMediumLow = new CS_Part_Price__c(Part__c = plcRadMedium.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 90, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c radiatorStd = new CS_Part_Price__c(Part__c = radiator.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 70, Start_Date__c = Date.Today().addDays(-1));
        CS_Part_Price__c radiatorLow = new CS_Part_Price__c(Part__c = radiator.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 50, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c packC1Std = new CS_Part_Price__c(Part__c = packC1.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 40, Start_Date__c = Date.Today().addDays(-1));
        CS_Part_Price__c packC1Low = new CS_Part_Price__c(Part__c = packC1.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 35, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c packC2Std = new CS_Part_Price__c(Part__c = packC2.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 30, Start_Date__c = Date.Today().addDays(-1));
        CS_Part_Price__c packC2Low = new CS_Part_Price__c(Part__c = packC2.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 25, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c p1Low = new CS_Part_Price__c(Part__c = p1.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 100, Start_Date__c = Date.Today().addDays(-1)); //Only Low Cost
        
        CS_Part_Price__c p2Std = new CS_Part_Price__c(Part__c = p2.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 20, Start_Date__c = Date.Today().addDays(-1));   //All Good
        CS_Part_Price__c p2Low = new CS_Part_Price__c(Part__c = p2.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 15, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c p3Std = new CS_Part_Price__c(Part__c = p3.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 23, Start_Date__c = Date.Today().addDays(-1)); //All Good
        CS_Part_Price__c p3Low = new CS_Part_Price__c(Part__c = p3.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 15, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c p4Std = new CS_Part_Price__c(Part__c = p4.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 20, Start_Date__c = Date.Today().addDays(1)); //No Date applicability
        CS_Part_Price__c p4Low = new CS_Part_Price__c(Part__c = p4.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 15, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c p5Std = new CS_Part_Price__c(Part__c = p5.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 20, District__c = district2.Id, Start_Date__c = Date.Today().addDays(-1)); //not in correct district
        CS_Part_Price__c p5Low = new CS_Part_Price__c(Part__c = p5.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 15, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c p6Std = new CS_Part_Price__c(Part__c = p6.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 18, Start_Date__c = Date.Today().addDays(-1));   //NOT in Region
        CS_Part_Price__c p6Low = new CS_Part_Price__c(Part__c = p6.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 15, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c p7FlueStd = new CS_Part_Price__c(Part__c = p7Flue.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 40, Start_Date__c = Date.Today().addDays(-1));  //all good
        CS_Part_Price__c p7FlueLow = new CS_Part_Price__c(Part__c = p7Flue.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 15, Start_Date__c = Date.Today().addDays(-1));
        
        CS_Part_Price__c p8FlueStd = new CS_Part_Price__c(Part__c = p8Flue.Id, CS_Pricebook__c = stdPricebook.Id, Price__c = 50, Start_Date__c = Date.Today().addDays(-1));   //all good
        CS_Part_Price__c p8FlueLow = new CS_Part_Price__c(Part__c = p8Flue.Id, CS_Pricebook__c = lowCostPricebook.Id, Price__c = 15, Start_Date__c = Date.Today().addDays(-1));
        
        insert new List<CS_Part_Price__c> {boilerStd, boilerLow,plcRadMediumStd,plcRadMediumLow,radiatorStd, radiatorLow,packC1Std, packC1Low, packC2Std, packC2Low,
                                               p1Low,p2Std, p2Low,p3Std, p3Low,p4Std,p4Low, p5Std, p5Low,p6Std, p6Low, p7FlueStd,p7FlueLow, p8FlueStd, p8FlueLow};
             
        // Update parts to active 
        List<CS_Part__c> partsToUpdate = new List<CS_Part__c> {boiler, plcRadMedium, radiator, packC1, packC2, p1, p2, p3, p4, p5, p6, p7Flue, p8Flue};
        for(CS_Part__c prt : partsToUpdate){
            prt.Active__c = true;
        }
        
        update partsToUpdate;
                                          
        //Create Materials
        CS_Material__c mat1 = new CS_Material__c(Name='Plug 1', Description__c='Plug 1', Cost_Per_Unit__c = 1, Material_ID__c = '12345');
        CS_Material__c mat2 = new CS_Material__c(Name='Plug 2', Description__c='Plug 2', Cost_Per_Unit__c = 3, Material_ID__c = '98765'); 
        CS_Material__c mat3 = new CS_Material__c(Name='Plug 3', Description__c='Plug 3', Cost_Per_Unit__c = 5, Material_ID__c = 'wkejhe'); 
        insert new List<CS_Material__c> {mat1, mat2, mat3};
        
        // ------ Create Part Materials ---------
        //Material Cost of P2 is £7
        CS_Part_Material__c p2Mat1 = new CS_Part_Material__c(Part__c = p2.Id, Material__c = mat1.Id , Quantity__c = 1);
        CS_Part_Material__c p2Mat2 = new CS_Part_Material__c(Part__c = p2.Id, Material__c = mat2.Id , Quantity__c = 2);
        
        //Material Cost of P3 is £12
        CS_Part_Material__c p3Mat1 = new CS_Part_Material__c(Part__c = p3.Id, Material__c = mat1.Id , Quantity__c = 2);
        CS_Part_Material__c p3Mat3 = new CS_Part_Material__c(Part__c = p3.Id, Material__c = mat3.Id , Quantity__c = 2);
        
        //Material Cost of P4 is £8
        CS_Part_Material__c p4Mat1 = new CS_Part_Material__c(Part__c = p4.Id, Material__c = mat1.Id , Quantity__c = 3);
        CS_Part_Material__c p4Mat3 = new CS_Part_Material__c(Part__c = p4.Id, Material__c = mat3.Id , Quantity__c = 1);
        
        //Material Cost of P5 is £3
        CS_Part_Material__c p5Mat1 = new CS_Part_Material__c(Part__c = p5.Id, Material__c = mat1.Id , Quantity__c = 3);
        
        //Material Cost of p7Flue is £7
        CS_Part_Material__c p7FlueMat1 = new CS_Part_Material__c(Part__c = p7Flue.Id, Material__c = mat1.Id , Quantity__c = 1);
        CS_Part_Material__c p7FlueMat2 = new CS_Part_Material__c(Part__c = p7Flue.Id, Material__c = mat2.Id , Quantity__c = 2);
               
        //Material Cost of p8Flue is £8
        CS_Part_Material__c p8FlueMat1 = new CS_Part_Material__c(Part__c = p8Flue.Id, Material__c = mat1.Id , Quantity__c = 3);
        CS_Part_Material__c p8FlueMat3 = new CS_Part_Material__c(Part__c = p8Flue.Id, Material__c = mat3.Id , Quantity__c = 1);      
        
        //Material Cost of boiler is £11
        CS_Part_Material__c boilerMat1 = new CS_Part_Material__c(Part__c = boiler.Id, Material__c = mat1.Id , Quantity__c = 5);
        CS_Part_Material__c boilerMat2 = new CS_Part_Material__c(Part__c = boiler.Id, Material__c = mat2.Id , Quantity__c = 2);
        
        //No Material Cost for plcRadMedium
        
        //Material Cost of radiator is £10
        CS_Part_Material__c radiatorMat3 = new CS_Part_Material__c(Part__c = radiator.Id, Material__c = mat3.Id , Quantity__c = 2);
        
        //Material Cost of packC1 is £5
        CS_Part_Material__c packC1Mat1 = new CS_Part_Material__c(Part__c = packC1.Id, Material__c = mat1.Id , Quantity__c = 2);
        CS_Part_Material__c packC1Mat2 = new CS_Part_Material__c(Part__c = packC1.Id, Material__c = mat2.Id , Quantity__c = 1);
        
        //Material Cost of packC2 is £7
        CS_Part_Material__c packC2Mat1 = new CS_Part_Material__c(Part__c = packC2.Id, Material__c = mat1.Id , Quantity__c = 2);
        CS_Part_Material__c packC2Mat3 = new CS_Part_Material__c(Part__c = packC2.Id, Material__c = mat3.Id , Quantity__c = 1);
        
        insert new List<CS_Part_Material__c> {p2Mat1, p2Mat2, p3Mat1, p3Mat3, p4Mat1, p4Mat3, p5Mat1, p7FlueMat1, p7FlueMat2, p8FlueMat1, p8FlueMat3, boilerMat1, boilerMat2, radiatorMat3,
                                               packC1Mat1, packC1Mat2, packC2Mat1, packC2Mat3};
                                               
        //Create Skills
        CS_Skill__c sk1 = new CS_Skill__c(Name='Electrical', Skill_Code__c='EL', Cost_per_Hour_Standard__c = 6, Cost_per_Hour_Low_Cost__c= 0.5);
        CS_Skill__c sk2 = new CS_Skill__c(Name='Mechanical', Skill_Code__c='ME', Cost_per_Hour_Standard__c = 4, Cost_per_Hour_Low_Cost__c= 0.5);
        CS_Skill__c sk3 = new CS_Skill__c(Name='Plumbing', Skill_Code__c='PL', Cost_per_Hour_Standard__c = 3, Cost_per_Hour_Low_Cost__c= 0.5);
        insert new List<CS_Skill__c> {sk1, sk2, sk3};
        
        // ------ Create Part Skills ----------
        
        //Skill Cost of P2 is £6 - Not contributing to Margin though
        CS_Part_Skill__c p2Skill1 = new CS_Part_Skill__c(Part__c = p2.Id, Skill__c = sk1.Id, No_of_Hours__c = 1);
        
        //Skill Cost of P3 is £14
        CS_Part_Skill__c p3Skill1 = new CS_Part_Skill__c(Part__c = p3.Id, Skill__c = sk1.Id, No_of_Hours__c = 1);
        CS_Part_Skill__c p3Skill2 = new CS_Part_Skill__c(Part__c = p3.Id, Skill__c = sk2.Id, No_of_Hours__c = 2);
        
        //Skill Cost of P4 is £6 - Not considered though as no Part Price found
        CS_Part_Skill__c p4Skill3 = new CS_Part_Skill__c(Part__c = p4.Id, Skill__c = sk3.Id, No_of_Hours__c = 2);
        
        //Skill Cost of P5 is £9 - Not considered though as no Part Price found
        CS_Part_Skill__c p5Skill3 = new CS_Part_Skill__c(Part__c = p5.Id, Skill__c = sk3.Id, No_of_Hours__c = 3);
        
        //Skill Cost of P7Flue is £14 - Not considered though as no Part Price found
        CS_Part_Skill__c p7FlueSkill2 = new CS_Part_Skill__c(Part__c = p7Flue.Id, Skill__c = sk2.Id, No_of_Hours__c = 2);
        CS_Part_Skill__c p7FlueSkill3 = new CS_Part_Skill__c(Part__c = p7Flue.Id, Skill__c = sk3.Id, No_of_Hours__c = 2);
        
        //Skill Cost of P8Flue is £7 - Not considered though as has wrong Boiler Group
        CS_Part_Skill__c p8FlueSkill2 = new CS_Part_Skill__c(Part__c = p8Flue.Id, Skill__c = sk2.Id, No_of_Hours__c = 1);
        CS_Part_Skill__c p8FlueSkill3 = new CS_Part_Skill__c(Part__c = p8Flue.Id, Skill__c = sk3.Id, No_of_Hours__c = 1);
        
        //Skill Cost of boiler is £12
        CS_Part_Skill__c boilerFlueSkill1 = new CS_Part_Skill__c(Part__c = boiler.Id, Skill__c = sk1.Id, No_of_Hours__c = 1);
        CS_Part_Skill__c boilerFlueSkill3 = new CS_Part_Skill__c(Part__c = boiler.Id, Skill__c = sk3.Id, No_of_Hours__c = 2);
        
        //Skill Cost of plcRadMedium is £15
        CS_Part_Skill__c plcRadMediumSkill1 = new CS_Part_Skill__c(Part__c = plcRadMedium.Id, Skill__c = sk1.Id, No_of_Hours__c = 2);
        CS_Part_Skill__c plcRadMediumSkill3 = new CS_Part_Skill__c(Part__c = plcRadMedium.Id, Skill__c = sk3.Id, No_of_Hours__c = 1);
        
        //Skill Cost of radiator is £8
        CS_Part_Skill__c radiatorSkill2 = new CS_Part_Skill__c(Part__c = radiator.Id, Skill__c = sk2.Id, No_of_Hours__c = 2);
                                               
        //Skill Cost of packC1 is £15
        CS_Part_Skill__c packC1Skill1 = new CS_Part_Skill__c(Part__c = packC1.Id, Skill__c = sk1.Id, No_of_Hours__c = 2);
        CS_Part_Skill__c packC1Skill3 = new CS_Part_Skill__c(Part__c = packC1.Id, Skill__c = sk3.Id, No_of_Hours__c = 1);
        
        //Skill Cost of packC2 is £12 - Not contributing
        CS_Part_Skill__c packC2Skill1 = new CS_Part_Skill__c(Part__c = packC2.Id, Skill__c = sk1.Id, No_of_Hours__c = 1);
        CS_Part_Skill__c packC2Skill3 = new CS_Part_Skill__c(Part__c = packC2.Id, Skill__c = sk3.Id, No_of_Hours__c = 2);
                                              
        insert new List<CS_Part_Skill__c> {p2Skill1, p3Skill1, p3Skill2, p4Skill3, p5Skill3, p7FlueSkill2, p7FlueSkill3, p8FlueSkill2, p8FlueSkill3, boilerFlueSkill1, boilerFlueSkill3,
                                             plcRadMediumSkill1, plcRadMediumSkill3, radiatorSkill2, packC1Skill1, packC1Skill3, packC2Skill1, packC2Skill3};
                                               
        //Necessary assertions to ensure data has been setup as expected
        
        //P1 should not be available for Standard Pricebook
        CS_Part__c retrievedP1 = [select Id, Exists_in_Pricebooks__c from CS_Part__c where Id = :p1.Id];
        system.assert(retrievedP1.Exists_in_Pricebooks__c != null);
        system.assert(!retrievedP1.Exists_in_Pricebooks__c.contains(CS_Constants.CS_PricebookType_Standard));
        
        //p5 not in district
        //p6 not in region
            
                                            
        // Create a Part Availability for p6
        CS_Part_Availability__c p6Unavail = new CS_Part_Availability__c(CS_Part__c = p6.Id, Region__c = r.Id);
        insert p6Unavail;
        CS_Part__c retrievedP6 = [select Id, Included_In_Regions__c from CS_Part__c where Id = :p6.Id];
        system.assert(retrievedP6.Included_In_Regions__c != null);
    }
}