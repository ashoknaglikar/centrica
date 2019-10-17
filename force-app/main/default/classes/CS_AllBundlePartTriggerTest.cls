@isTest
private class CS_AllBundlePartTriggerTest {

	private static testMethod void testHandleAfterInsert() {
    
        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;
        insert vat20;
    
        // create a bundle
        CS_Bundle__c bundleForInsert = new CS_Bundle__c(Name = 'Test bundle 999', Type__c = 'Flue');
        insert bundleForInsert;
        
        // create parts
        List<CS_Part__c> partsListForInsert = new List<CS_Part__c>();
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 999', Part_Code__c = string.valueOf(12432), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi A'));
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 998', Part_Code__c = string.valueOf(32423), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi B'));
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 997', Part_Code__c = string.valueOf(53464), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi C'));
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 996', Part_Code__c = string.valueOf(98567), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi D'));
        insert partsListForInsert;
        
        List<CS_Part__c> insertedParts = [select Id, Flue_Boiler_Groups__c, Flue_Boiler_Groups_Formula__c from CS_Part__c];
        system.debug('*********** testing inserted parts formula field: ' + insertedParts);
    
        // create and insert bundle part associations
        List<CS_Bundle_Part_Association__c> bpasForInsert = new List<CS_Bundle_Part_Association__c>();
        for(Integer j=0; j<partsListForInsert.size(); j++){
            bpasForInsert.add(new CS_Bundle_Part_Association__c(Bundle__c = bundleForInsert.Id, Part__c = partsListForInsert[j].Id, Quantity__c = 1, Type__c = 'Requires'));                    
        }
        insert bpasForInsert;
        
        // assert that bundle supported boiler groups contain all of the  bundle.Supported_boiler_groups__c = String.Join(new List<String>(includedBoilerGroups), ',');  
        List<CS_Bundle__c> fetchedBundleList = [select Id, Name, Supported_boiler_groups__c from CS_Bundle__c where Name = 'Test bundle 999'];
        CS_Bundle__c fetchedBundle = fetchedBundleList[0];
        
        system.assertEquals('Baxi A,Baxi B,Baxi C,Baxi D', fetchedBundle.Supported_boiler_groups__c);
	}
	
	private static testMethod void handleAfterUpdate() {
    
        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;
        insert vat20;
    
        // create a bundle
        CS_Bundle__c bundleForInsert = new CS_Bundle__c(Name = 'Test bundle 999', Type__c = 'Flue');
        insert bundleForInsert;
        
        // create parts
        List<CS_Part__c> partsListForInsert = new List<CS_Part__c>();
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 999', Part_Code__c = string.valueOf(12432), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi A'));
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 998', Part_Code__c = string.valueOf(32423), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi B'));
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 997', Part_Code__c = string.valueOf(53464), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi C'));
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 996', Part_Code__c = string.valueOf(98567), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi D'));
        insert partsListForInsert;
        
        //create a part with different flue boiler group
        CS_Part__c aPart = new CS_Part__c(Name = 'Test part 995', Part_Code__c = string.valueOf(98332), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Glowworm');
        insert aPart;
    
        // create and insert bundle part associations
        List<CS_Bundle_Part_Association__c> bpasForInsert = new List<CS_Bundle_Part_Association__c>();
        for(Integer j=0; j<partsListForInsert.size(); j++){
            bpasForInsert.add(new CS_Bundle_Part_Association__c(Bundle__c = bundleForInsert.Id, Part__c = partsListForInsert[j].Id, Quantity__c = 1, Type__c = 'Requires'));                    
        }
        insert bpasForInsert;
        
        //Update one bpa, change the quantity
        List<CS_Bundle_Part_Association__c> fetchedBpaList = [select Id, Name, Quantity__c, Part__c from CS_Bundle_Part_Association__c where Part__c = :partsListForInsert[2].Id];
        CS_Bundle_Part_Association__c fetchedBpa = fetchedBpaList[0];
        fetchedBpa.Quantity__c = 3;
        update fetchedBpa;
        
        // assertion
        List<CS_Bundle__c> fetchedBundleList = [select Id, Name, Supported_boiler_groups__c from CS_Bundle__c where Name = 'Test bundle 999'];
        CS_Bundle__c fetchedBundle = fetchedBundleList[0];
        
        system.assertEquals('Baxi A,Baxi B,Baxi C,Baxi D', fetchedBundle.Supported_boiler_groups__c);
	}
	
	public static testMethod void testUpdateBundleSupportedBoilerGroupsAfterBPAssociationDelete(){
	    
	    CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;
        insert vat20;
    
        // create a bundle
        CS_Bundle__c bundleForInsert = new CS_Bundle__c(Name = 'Test bundle 999', Type__c = 'Flue');
        insert bundleForInsert;
        
        // create parts
        List<CS_Part__c> partsListForInsert = new List<CS_Part__c>();
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 999', Part_Code__c = string.valueOf(12432), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi A'));
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 998', Part_Code__c = string.valueOf(32423), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi B'));
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 997', Part_Code__c = string.valueOf(53464), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi C'));
        partsListForInsert.add(new CS_Part__c(Name = 'Test part 996', Part_Code__c = string.valueOf(98567), VAT_Code__c = vat20.Id, Flue_Boiler_Groups__c = 'Baxi D'));
        insert partsListForInsert;
        
        List<CS_Part__c> insertedParts = [select Id, Flue_Boiler_Groups__c, Flue_Boiler_Groups_Formula__c from CS_Part__c];
        system.debug('*********** testing inserted parts formula field: ' + insertedParts);
    
        // create and insert bundle part associations
        List<CS_Bundle_Part_Association__c> bpasForInsert = new List<CS_Bundle_Part_Association__c>();
        for(Integer j=0; j<partsListForInsert.size(); j++){
            bpasForInsert.add(new CS_Bundle_Part_Association__c(Bundle__c = bundleForInsert.Id, Part__c = partsListForInsert[j].Id, Quantity__c = 1, Type__c = 'Requires'));                    
        }
        insert bpasForInsert;
        
        //delete a bpa
        List<CS_Bundle_Part_Association__c> fetchedBpaList = [select Id, Name, Quantity__c, Part__c from CS_Bundle_Part_Association__c where Part__c = :partsListForInsert[2].Id];
        delete fetchedBpaList;
        
        // assertion
        List<CS_Bundle__c> fetchedBundleList = [select Id, Name, Supported_boiler_groups__c from CS_Bundle__c where Name = 'Test bundle 999'];
        CS_Bundle__c fetchedBundle = fetchedBundleList[0];
        
        system.assertEquals('Baxi A,Baxi B,Baxi D', fetchedBundle.Supported_boiler_groups__c);
	}

}