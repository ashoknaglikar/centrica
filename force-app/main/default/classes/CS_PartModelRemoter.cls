global with sharing class CS_PartModelRemoter {
       
    /* -------------------------------------------------------------------------------------
     * This class is used to replicate the creation of the partsModelJS for testing purposes
     * -------------------------------------------------------------------------------------
     */
       
       
       
    public CS_PartModelRemoter(ApexPages.StandardController controller) {

    }   
   
    /*
     * This class is used to hold required info about an associated Part
     * Should be kept in sync with the homonymous function in partsModelOfflineSupport.js
     */
    global class AssociatedPartWrapper {
        
        public Id associatedPartId {get; set;}
        public Integer quantity {get; set;}
        
        public AssociatedPartWrapper (Id partId, Integer partQuantity) {
            this.associatedPartId = partId;
            this.quantity = partQuantity;
        }
    }
    
    /*
     * Simulates creation of partsModelJS for testing purposes
     */
    global static Map<String, CS_PartModelEntry> getPartModelInformation(List<CS_RemotingParamWrapper> attsChanged, String regionCode, String districtCode, String pricebookType, String boilerGroup, Decimal geographicalUpliftFactor) {
        
        Map<String, CS_PartModelEntry> partModelInfo = new Map<String, CS_PartModelEntry>(); //key is attRef
        
        Set<Id> parentPartIds = new Set<Id>(); //hold parentPartIds
        Set<Id> parentBundleIds = new Set<Id>(); //hold (parent) BundleIds
        
        Set<Id> partIdsToQuery = new Set<Id>(); //List of all PartIds that (may) form part of the entire parts model (given they comply to some eligibility rules)
        
        //This will only be used for non multilookups. Key is  ParentPartId or BundleId, values are the associated Parts
        Map<String, List<AssociatedPartWrapper>> parentToAssociatedPartsMap = new Map<String, List<AssociatedPartWrapper>>();  //Key here is a BundleId or a PartId
        Map<String, List<Id>> multilookupAttToAssociatedPartsMap = new Map<String, List<Id>>(); //Key here is the attRef. Quantity is assumed to be '1'
        
        for (CS_RemotingParamWrapper rpw : attsChanged) {
            if (rpw.isBundle) {
                parentBundleIds.add(rpw.attValue);
            }
            else if (rpw.isPart && !rpw.isMultilookup) {
                parentPartIds.add(rpw.attValue);
            }
            else if (rpw.isMultilookup) {
                //split the string, add values to partIdsToQuery, populate the multilookupAttToAssociatedPartsMap
                List<Id> partIds = rpw.attValue.split(',');
                for (Id pId : partIds) {
                    partIdsToQuery.add(pId);
                    if (!multilookupAttToAssociatedPartsMap.containsKey(rpw.attRef)) {
                        multilookupAttToAssociatedPartsMap.put(rpw.attRef, new List<Id> {pId});
                    }
                    else {
                        multilookupAttToAssociatedPartsMap.get(rpw.attRef).add(pId);
                    }
                }
            }
        }
        
        partIdsToQuery.addAll(parentPartIds);
        
        // --------------- Get Bundle Info, Bundle-to-Part Associations & populate Map --------------------
        Map<Id, CS_Bundle__c> allReferencedBundlesMap = UISupport.getBundlesWithAssociations(new List<Id> (parentBundleIds));
                                                                    
        for (Id bundleId : allReferencedBundlesMap.keySet()) {
            CS_Bundle__c bundle = allReferencedBundlesMap.get(bundleId);
            
            for (CS_Bundle_Part_Association__c bpa : allReferencedBundlesMap.get(bundleId).CS_Bundle_Part_Associations__r) {    
                
                if(bundle.Type__c == 'Flue'){
                    if(bpa.Part_Boiler_Group__c == boilerGroup){ 
                        if (!parentToAssociatedPartsMap.containsKey(bundleId)) {
                        parentToAssociatedPartsMap.put(bundleId, new List<AssociatedPartWrapper> {new AssociatedPartWrapper(bpa.Part__c, Integer.valueOf(bpa.Quantity__c))});
                        }
                        else {
                            parentToAssociatedPartsMap.get(bundleId).add(new AssociatedPartWrapper(bpa.Part__c, Integer.valueOf(bpa.Quantity__c)));
                        }                   
                        partIdsToQuery.add(bpa.Part__c);
                    }
                } else {
                    if (!parentToAssociatedPartsMap.containsKey(bundleId)) {
                        parentToAssociatedPartsMap.put(bundleId, new List<AssociatedPartWrapper> {new AssociatedPartWrapper(bpa.Part__c, Integer.valueOf(bpa.Quantity__c))});
                    }
                    else {
                        parentToAssociatedPartsMap.get(bundleId).add(new AssociatedPartWrapper(bpa.Part__c, Integer.valueOf(bpa.Quantity__c)));
                    }                   
                    partIdsToQuery.add(bpa.Part__c);
                }
            }
        }
        
        // ------------- Get Part-to-Part Associations & populate Map ----------------------------------
        List<CS_Part_Association__c> partAssociations = UISupport.getPartsWithAssociations(new List<Id> (parentPartIds));
        
        for (CS_Part_Association__c pa: partAssociations) {
            if (!parentToAssociatedPartsMap.containsKey(pa.Part_1__c)) {
                parentToAssociatedPartsMap.put(pa.Part_1__c, new List<AssociatedPartWrapper> {new AssociatedPartWrapper(pa.Part_2__c, Integer.valueOf(pa.Quantity__c))});
            }
            else {
                parentToAssociatedPartsMap.get(pa.Part_1__c).add(new AssociatedPartWrapper(pa.Part_2__c, Integer.valueOf(pa.Quantity__c)));
            }
            
            partIdsToQuery.add(pa.Part_2__c);
        }
        
        system.debug('***** multilookupAttToAssociatedPartsMap: ' + multilookupAttToAssociatedPartsMap);
        system.debug('**** parentToAssociatedPartsMap: ' + parentToAssociatedPartsMap);
        system.debug('****** PartIds to query: ' + partIdsToQuery.size());
        
        
        // ------------------- Get all Parts & Associated Parts Information -----------------------
        
        Map<Id, CS_PartWrapper> allReferencedPartsMap = UISupport.getAllReferencedPartInformation(new List<Id> (partIdsToQuery), districtCode, pricebookType) ;
        
        
        // -------------------- Now construct the Entry Model in a map structure for easier retrieval in JS. ----------------------
        // The Keys of the Map will be the attRefs
        // For each key, get its associations from parentToAssociatedPartsMap. Loop through each AssociatedPartWrapper and transform the Key With Associations into a CS_PartModelEntry structure
        
        
        system.debug('**** Building Map ...');
        for (CS_RemotingParamWrapper attWrapper : attsChanged) {
        
            system.debug('**** attWrapper: ' + attWrapper);
            
            // ------- Create the List of associatedParts for each Key - Check Region applicability -------------
            List<CS_PartModelEntry.CS_PartInformation> associatedParts = new List<CS_PartModelEntry.CS_PartInformation>();
            
            //For Multi lookups, build associatedPart list given the info in multilookupAttToAssociatedPartsMap
            if (attWrapper.isMultilookup && multilookupAttToAssociatedPartsMap.containsKey(attWrapper.attRef)) {
            
                system.debug('***Multilookup found with associated parts: ' + multilookupAttToAssociatedPartsMap.get(attWrapper.attRef).size());
                
                for (Id partId : multilookupAttToAssociatedPartsMap.get(attWrapper.attRef)) {
                                        
                    //Note: the multi lookup values should all be valid, as Configurator has filtered them
                    if (allReferencedPartsMap.containsKey(partId)) {
                        CS_PartWrapper retrievedPartWrapper = allReferencedPartsMap.get(partId);
                                                
                        if (retrievedPartWrapper.part.Included_In_Regions__c.contains(regionCode)) {
                            CS_PartModelEntry.CS_PartInformation assPartInfo = new  CS_PartModelEntry.CS_PartInformation(retrievedPartWrapper, null, districtCode, 1, geographicalUpliftFactor);
                            associatedParts.add(assPartInfo);      
                            
                             system.debug('***** Ass Part Added for ' + attWrapper.attRef + ' - ' + retrievedPartWrapper.part.Name);               
                        }
                        else {
                            system.debug('***** Ass Part Ignored for: ' + attWrapper.attRef + ' - '  + retrievedPartWrapper.part.Id + ' - ' + retrievedPartWrapper.part.Name);
                        }
                    }
                }
            }
            
            //For ParentParts & ParentBundles, build associatedPart list given the info in parentToAssociatedPartsMap
            //(attWrapper.isPart || attWrapper.isBundle) &&  : omitted as multilookup check goes first
            else if (parentToAssociatedPartsMap.containsKey(attWrapper.attValue)) {
            
                system.debug('*** ParentPart/Bundle found with associatedEntries: ' + parentToAssociatedPartsMap.get(attWrapper.attValue).size());
                for (AssociatedPartWrapper apw : parentToAssociatedPartsMap.get(attWrapper.attValue)) {
                    
                    //Note: not all AssociatedParts may be retrieved if they don't match the filter criteria
                    if (allReferencedPartsMap.containsKey(apw.associatedPartId)) {
                        CS_PartWrapper retrievedPartWrapper = allReferencedPartsMap.get(apw.associatedPartId);
                           
                           system.debug('******* ' + attWrapper.attRef + ' - ' + retrievedPartWrapper.part.Name);                 
                           system.debug('******* ' + attWrapper.attRef + ' - ' + retrievedPartWrapper.part.Included_In_Regions__c);
                                                
                        if (retrievedPartWrapper.part.Included_In_Regions__c.contains(regionCode)) {
                            CS_PartModelEntry.CS_PartInformation assPartInfo = new  CS_PartModelEntry.CS_PartInformation(retrievedPartWrapper, null, districtCode, apw.quantity, geographicalUpliftFactor);
                            associatedParts.add(assPartInfo);
                            
                            system.debug('***** Ass Part Added for ' + attWrapper.attRef + ' - ' + retrievedPartWrapper.part.Name);
                        }
                        else {
                            system.debug('***** Ass Part Ignored for: ' + attWrapper.attRef + ' - '  + retrievedPartWrapper.part.Id + ' - ' + retrievedPartWrapper.part.Name);
                        }
                    }
                }
            }
            
            else {
                system.debug('**** No associated Parts found for: ' + attWrapper.attRef + ' - ' + attWrapper.attValue + ' ****');
            }
            
            
            // ---------- Now create the entry (key of the Map will be the attRef) ------------------ 
            CS_PartModelEntry entry = null;
            
            //If parent is Part
            if (attWrapper.isPart && !(attWrapper.isMultilookup) && parentPartIds.contains(attWrapper.attValue)) {
                
                //Configurator has already performed the eligibility checks otherwise this couldn't have been selected
                CS_PartWrapper parentPartWrapper = allReferencedPartsMap.containsKey(attWrapper.attValue) ? allReferencedPartsMap.get(attWrapper.attValue) : null; 
                
                if (parentPartWrapper == null) {
                    system.debug('***** problem with parentPart filtered out on the DB but not on Configurator: ' + attWrapper.attRef + ' with value ' + attWrapper.attValue);
                }
                
                /// Exception Handling
                if (parentPartWrapper != null) {
                    entry = new CS_PartModelEntry(attWrapper, null, parentPartWrapper, associatedParts, pricebookType, districtCode, geographicalUpliftFactor);
                }
            }
            //Else if parent is Bundle
            else if (attWrapper.isBundle  && parentBundleIds.contains(attWrapper.attValue)) {
                CS_Bundle__c parentBundle = allReferencedBundlesMap.containsKey(attWrapper.attValue) ? allReferencedBundlesMap.get(attWrapper.attValue) : null;
                
                system.debug('****** parentBundle is: ' + parentBundle);
                
                if (parentBundle != null) { //will not be..
                    //entry = new CS_PartModelEntry(attWrapper, parentBundle, associatedParts, pricebookType, districtCode);  EP 19/05
                    entry = new CS_PartModelEntry(attWrapper, parentBundle, null, associatedParts, pricebookType, districtCode, geographicalUpliftFactor);
                }
            }   
            
            else if (attWrapper.isMultilookup) {
                //entry = new CS_PartModelEntry(attWrapper,associatedParts, pricebookType, districtCode); EP 19/05
                entry = new CS_PartModelEntry(attWrapper, null, null, associatedParts, pricebookType, districtCode, geographicalUpliftFactor);
            }
            
            if (entry != null) {
                partModelInfo.put(attWrapper.attRef, entry);
            }
        }
        
        return partModelInfo;            
    }     
}