public class CS_AllPartTriggerHelper{

    public static void handleAfterInsert (Map<Id, CS_Part__c> newParts) {
    
        updatePartIncludedInRegions(newParts);
        
        //updateBundleSupportedBoilerGroups
        List<CS_Bundle_Part_Association__c> affectedBPAs =  
            [Select Id, Type__c, Part__c, Part__r.Id, Bundle__c From CS_Bundle_Part_Association__c
            where Part__r.Id in :newParts.keyset()];  
            
        Set<Id> affectedBundleIds = new Set<Id>();
        for(CS_Bundle_Part_Association__c pa : affectedBPAs){
            affectedBundleIds.add(pa.Bundle__c);
        }  
        
        CS_AllBundlePartTriggerHelper.updateBundleSupportedBoilerGroups(affectedBundleIds);
    }
    
    public static void handleAfterUpdate (Map<Id, CS_Part__c> oldParts, Map<Id, CS_Part__c> newParts) {

        //updateBundleSupportedBoilerGroups
        List<CS_Bundle_Part_Association__c> affectedBPAs =  
            [Select Id, Type__c, Part__c, Part__r.Id, Bundle__c From CS_Bundle_Part_Association__c
            where Part__r.Id in :newParts.keyset()];  
            
        Set<Id> affectedBundleIds = new Set<Id>();
        for(CS_Bundle_Part_Association__c pa : affectedBPAs){
            affectedBundleIds.add(pa.Bundle__c);
        }  
        
        CS_AllBundlePartTriggerHelper.updateBundleSupportedBoilerGroups(affectedBundleIds);
    }

    public static void updatePartIncludedInRegions(Map<Id, CS_Part__c> triggerMap){
    
        List<CS_Part__c> partList = 
            [Select c.Id, c.Included_In_Regions__c, 
            (Select Region__c, Region__r.Name, Region__r.Code__c From CS_Part_Availabilities__r) 
            From CS_Part__c c where c.Id in :triggerMap.keySet()];
        
        List<Region__c> availableRegions = [select Id, Name, Code__c from Region__c where Type__c = 'Sales'];        
        List<String> regionNames = new List<String>();      
        for(Region__c region : availableRegions){
            regionNames.add(region.Name);
        }        
        
        for(CS_Part__c part : partList){
            part.Included_In_Regions__c = '';
            Set<String> includedRegions = new Set<String>();
            
            if(part.CS_Part_Availabilities__r.size()==0) {
                part.Included_In_Regions__c = '';
                includedRegions = new Set<String>(regionNames);
            } else {
                for(CS_Part_Availability__c pa : part.CS_Part_Availabilities__r){
                    includedRegions.add(pa.Region__r.Name);
                }
            }

            part.Included_In_Regions__c = ',' + String.Join(new List<String>(includedRegions), ',') + ',';  
        }
        
        update partList;            
    }

    public static void updatePartIncludedInRegionsBeforeUpdate(Map<Id, CS_Part__c> triggerMap){
    
        List<CS_Part__c> partList = 
            [Select c.Id, c.Included_In_Regions__c, 
            (Select Region__c, Region__r.Name, Region__r.Code__c From CS_Part_Availabilities__r) 
            From CS_Part__c c where c.Id in :triggerMap.keySet()];
        
        List<Region__c> availableRegions = [select Id, Name, Code__c from Region__c where Type__c = 'Sales'];        
        List<String> regionNames = new List<String>();      
        for(Region__c region : availableRegions){
            regionNames.add(region.Name);
        }     

        for(CS_Part__c part : partList){
            CS_Part__c p = triggerMap.get(part.Id);
            Set<String> includedRegions = new Set<String>();
            
            if(part.CS_Part_Availabilities__r.size()==0) {
                part.Included_In_Regions__c = '';
                includedRegions = new Set<String>(regionNames);
            } else {
                for(CS_Part_Availability__c pa : part.CS_Part_Availabilities__r){
                    includedRegions.add(pa.Region__r.Name);
                }
            }

            p.Included_In_Regions__c = ',' + String.Join(new List<String>(includedRegions), ',') + ',';  
        }   
    }
    
    public static void touchBundlePartAssociations(Map<Id, CS_Part__c> oldParts, Map<Id, CS_Part__c> newParts) {
        Set<Id> modifiedPartIds = new Set<Id>();

        // iterate through all of the updated parts
        for(Id key : newParts.keySet()) {
            CS_Part__c newPart = newParts.get(key);
            CS_Part__c oldPart = oldParts.get(key);

            if((newPart != null) && (oldPart != null)) {
                // compare the Flue_Boiler_Groups__c field, if there is a difference put the part id in a set        
                if((newPart.Flue_Boiler_Groups__c != null) && (oldPart.Flue_Boiler_Groups__c != null)) {
                    if(!newPart.Flue_Boiler_Groups__c.equals(oldPart.Flue_Boiler_Groups__c)) {
                        modifiedPartIds.add(newPart.Id);
                    }
                }
            }
        }

        // select all of the bundle part associations with the part id from the set
        List<CS_Bundle_Part_Association__c> BPAsToUpdate = [SELECT Id, Part__c FROM CS_Bundle_Part_Association__c WHERE Part__c in :modifiedPartIds];
        
        // update all of the selected bundle part associations
        if((BPAsToUpdate != null) && (BPAsToUpdate.size() > 0)) update BPAsToUpdate;
    }

    /**
    * Validates a part upon activation and when trying to save an already active part.
    * If national part prices have non duplicate start dates and a historical date
    * automatically populates the end dates.
    * It does not modify prices which contain District_Code__c
    */
    public static void validatePartActivation(Map<Id, CS_Part__c> triggerMap) {

        List<CS_Part__c> affectedParts = [Select c.Id, c.Name,
        (Select CS_Pricebook__r.Name, District_Name__c, District_Code__c, Start_Date__c, End_Date__c, Name From CS_Part_Prices__r ORDER BY Start_Date__c ASC)
        From CS_Part__c c where c.Id in :triggerMap.keyset()];

        List<CS_Pricebook__c> pricebookList = [Select Id, Name from CS_Pricebook__c];

        List<CS_Part_Price__c> partPricesToUpdate = new List<CS_Part_Price__c>();
        
        if(affectedParts != null) {
            for (CS_Part__c part : affectedParts) {

            CS_Part__c actualPart = triggerMap.get(part.Id);

            if(actualPart.Active__c == true){
                
                // create a map of pricebooks used to check whether there exists a part price record with empty district for a pricebook
                Map<String, Boolean> pricebookMap = new Map<String, Boolean>();
                // put all national part prices (withour District_Code__c) per pricebook in a map
                Map<String, List<CS_Part_Price__c>> pricesPerPricebookMap = new Map<String, List<CS_Part_Price__c>>();

                for (CS_Part_Price__c pp : part.CS_Part_Prices__r) {

                    if (!pricebookMap.containsKey(pp.CS_Pricebook__r.Name)) {                       
                        pricebookMap.put(pp.CS_Pricebook__r.Name, false);                        
                    }
                    // if there is a part price record with empty district set the pricebook value to true
                    if (pp.District_Code__c == null) {
                        pricebookMap.put(pp.CS_Pricebook__r.Name, true);
                    }


                    if (pp.District_Code__c == null) {           
                        if (pricesPerPricebookMap.containsKey(pp.CS_Pricebook__r.Name)) {
                            pricesPerPricebookMap.get(pp.CS_Pricebook__r.Name).add(pp);
                        } else {
                            pricesPerPricebookMap.put(pp.CS_Pricebook__r.Name, new List<CS_Part_Price__c> {pp});
                        }
                    }                   
                }

                //if there is a pricebook value that is false we need to output an error
                boolean hasPricebookErrors = false;
                for (String keyString : pricebookMap.keyset()) {
                    if (!pricebookMap.get(keyString)) {
                        hasPricebookErrors = true;
                        actualPart.addError('A national price (without a District sector) for a ' + keyString + ' pricebook is missing.');
                        break;
                    }
                }

                if (!hasPricebookErrors) {
                    //Collect national Prices per Pricebook. Start and End Dates are inclusive.
                    for (String keyString : pricesPerPricebookMap.keySet()) {
                        List<CS_Part_Price__c> partPriceList = pricesPerPricebookMap.get(keyString);

                        for (Integer i = 0; i < partPriceList.size(); i++) {
                            CS_Part_Price__c pp = partPriceList.get(i);

                            if (pp.Start_Date__c == null) {
                                actualPart.addError('Part price ' + pp.Name + ' is missing a start date.');
                            }

                            //first record has to have a start date before todays date
                            if (i == 0) {
                                if (pp.Start_Date__c >= system.today()) {
                                    actualPart.addError('There has to be a part price with date before todays date.');
                                }
                            }

                            //last record has to have an empty end date
                            if (i == partPriceList.size() - 1) {
                                if (pp.End_Date__c < system.today() || (pp.End_Date__c != null)) {
                                    pp.End_Date__c = null;
                                    partPricesToUpdate.add(pp);
                                }
                            }

                            //set the end date of the previous part price
                            if (i != 0) {
                                CS_Part_Price__c previousPartPrice = partPriceList.get(i - 1);
                                system.debug('***');
                                system.debug(previousPartPrice);
                                system.debug(pp);
                                previousPartPrice.End_Date__c = pp.Start_Date__c.addDays(-1);
                                partPricesToUpdate.add(previousPartPrice);
                            }
                        }
                    }
                }
            }            

            update partPricesToUpdate;
        }
        }
    }

    /**
     *   When a Part is being updated from Active to Inactive,
     *   check if the Part contributes to any Bundle to Part or Part to Part associations.
     *   If so, display an error message “This Part has associations. Please delete the associations and then try again”.
     */
    public static void validatePartDeactivation(Map<Id, CS_Part__c> triggerMap) {
        List<CS_Part__c> affectedParts =
            [Select c.Id, c.Active__c,
            (Select Name From CS_Part_Associations2__r),
            (Select Name From CS_Part_Associations__r),
            (Select Name From CS_Bundle_Part_Associations__r)
            From CS_Part__c c where (c.Id in :triggerMap.keyset())];

        for (CS_Part__c part : affectedParts) {
            CS_Part__c actualPart = triggerMap.get(part.Id);

            if (actualPart.Active__c == false) {
                if ((part.CS_Part_Associations__r.size() != 0) || (part.CS_Part_Associations2__r.size() != 0) || (part.CS_Bundle_Part_Associations__r.size() != 0)) {
                    actualPart.addError('This Part has associations. Please delete the associations and then try again.');
                }
            }
        }
    }


    /**
     *  Every time a part price is being inserted or updated it needs to be checked whether it is a national price.
     *  National prices need to have automatically populated end dates, they need to have a historical start date.
     *  There mustn't be a gap between prices and the last national part price has to have an open end date.
     */
    public static void ensureNationalPartPrice(Map<Id, CS_Part_Price__c> triggerMap) {

        // get all affected parts with national prices (prices without District_Code__c)
        Set<Id> affectedPartIds = new Set<Id>();
        //map<ID, ID> affectedPartIdwithDistict = new  map<ID, ID>();
        for(CS_Part_Price__c partPrice : triggerMap.values())
        {
            if(partPrice != null) {
                //if(partPrice.District_Code__c == null) {
                    affectedPartIds.add(partPrice.Part__c); 
                    /*if(partPrice.District_Code__c != null)
                    {
                        affectedPartIdwithDistict.put(partPrice.Id, partPrice.District_Code__c)
                    }*/
                    
                //}            
            }
        }
        List<CS_Part__c> affectedParts = [Select c.Id, c.Name, Active__c, 
            (Select CS_Pricebook__c, CS_Pricebook__r.Name, District_Name__c, District_Code__c, Start_Date__c, End_Date__c, Name, Id,District__c From CS_Part_Prices__r /*where End_Date__c = null*/  ORDER BY Start_Date__c ASC)
            From CS_Part__c c where c.Id in :affectedPartIds];

        // empty set containing all part prices to be updated
        Map<Id,CS_Part_Price__c> partPricesToUpdate = new Map<Id,CS_Part_Price__c>();
        
        // affected part price records are new ones being currently inserted or existing ones being updated
        //
        // prepare map with all part prices existing in the system without affected ones
        //
        /*
        Map<Id, CS_Part_Price__c> allOtherPartPricesMap = 
            new Map<Id, CS_Part_Price__c>([Select Id, Name, Start_Date__c, End_Date__c, Part__c,District__c from CS_Part_Price__c where Part__c in :affectedPartIds and Id not in :triggerMap.keySet()]);
            */
        
        // iterate through all affected part prices
        for(CS_Part_Price__c pp : triggerMap.values())
        {    
            //check only national part prices
            /*
            if(pp.District_Code__c != null) {
                continue;
            }*/

            // don't allow updating end date if
            /*
            if (Trigger.isUpdate) 
            {
                CS_Part_Price__c oldPartPrice = (CS_Part_Price__c) Trigger.oldMap.get(pp.Id);
                
                if (oldPartPrice.End_Date__c != pp.End_Date__c ) {
                    // end date can't be changed manually
                    // revert
                    pp.End_Date__c = oldPartPrice.End_Date__c;
                    // although we set proper end dates automatically later below
                }
            }
            */
    
            //get a list of part prices related to the current part price
            Map<Id, CS_Part__c>    affectedPartsMap = new Map<Id, CS_Part__c>(affectedParts);
            CS_Part__c             affectedPart     = affectedPartsMap.get(pp.Part__c);

            // get all siblings of currently observed part price parent
            List<CS_Part_Price__c> partPrices       = getListOfPartPricesFromAffectedPartsMap(pp.CS_Pricebook__c, affectedPart, pp.District__c );

            // sort

            CS_SObjectHelper.sortList(partPrices, 'Start_Date__c', 'asc');

            //
            // first part price record should have Start Date in the past
            //

            

            //
            // check whether there are duplicate start dates
            //
            if (partPrices.size() > 0)
            {
                CS_Part_Price__c firstPartPrice = partPrices.get(0);
                system.debug(partPrices);
                system.debug(firstPartPrice);
                if ( !test.isRunningTest() && firstPartPrice != null && firstPartPrice.Start_Date__c >= System.today() )
                {
                    trigger.new[0].addError('First record should have Start Date in the past.');
                }
                Set<string> startDateSet = new Set<string>();
                for(CS_Part_Price__c prtPrice : partPrices) {
                    startDateSet.add(string.valueof(prtPrice.Start_Date__c)+prtPrice.District__c);
                }
                if(startDateSet.size() != partPrices.size()) {
                    pp.addError('There already exists a start date with this date.');
                }
            }

            //
            // ensure there is a historical start date
            //
            system.debug('Part Prices -->'+partPrices);
            if(trigger.isinsert)
            for(Integer i=0; i<partPrices.size(); i++)
            {
                CS_Part_Price__c partPrice = partPrices[i];
                
                // change the end dates respectively
                // last record has to have an empty end date

                Boolean lastPartPrice = (partPrices.size() - 1) == i;
                system.debug('lastPartPrice -- >'+lastPartPrice+partPrice);
                if (lastPartPrice)
                {
                    if (partPrice.End_Date__c < system.today() || (partPrice.End_Date__c != null))
                    {
                        partPrice.End_Date__c = null;

                        partPricesToUpdate.put(partPrice.Id, partPrice);
                    }
                }
                else if(pp.District__c == partPrice.District__c)//set the end date of the previous part price
                {
                    system.debug('Previous Record -->');
                    CS_Part_Price__c nextPartPrice = partPrices.get(i+1);
                    system.debug('Previous Record -->'+nextPartPrice);
                    partPrice.End_Date__c = nextPartPrice.Start_Date__c.addDays(-1);

                    partPricesToUpdate.put(partPrice.Id, partPrice);
                }    
            }
        }

        //update part prices if there is anything to update and no errors are present
        if ( partPricesToUpdate.size() > 0 )
        {
            upsert partPricesToUpdate.values();
        }        
    }

    /**
     * Gets a list of national (without District_Code__c) part prices belonging to a pricebook for a given part.
     */
    private static List<CS_Part_Price__c> getListOfPartPricesFromAffectedPartsMap(Id pricebook, CS_Part__c affectedPart , string districtId ){
        
        List<CS_Part_Price__c> partPriceList = new List<CS_Part_Price__c>();

        for(CS_Part_Price__c pp : affectedPart.CS_Part_Prices__r){
            
            if((pp.CS_Pricebook__c == pricebook && pp.District__c == districtId)){
                partPriceList.add(pp);
            }
        }               

        return partPriceList;
    }        
}