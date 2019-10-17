
require(['bower_components/q/q'], function (Q) {
 
/**
 * Handles the retrieval of Bundles by populating the partParams.allReferencedBundlesMap map.
 * The key of this map is the bundleId and the value is a CS_Bundle__c, containing CS_Bundle_Part_Associations__r to mimick the object format retrieved via the RemoteAction equivalent.
 * @param {Object} partParams
 */
window.getBundlesWithAssociations = function getBundlesWithAssociations(partParams) {
    CS.indicator.start();
    partParams.allReferencedBundlesMap = {}; // map of bundleId, CS_Bundle__C with CS_Bundle_Part_Associations__r relationship (being deleted later)
    
    if (!partParams.parentBundleIds || partParams.parentBundleIds.length == 0) {
        CS.Log.warn('***** No parentBundleIds to query.');
        
        return Q.resolve(partParams);
    }
    
    var device = (navigator.device ? 'iPad' : 'Laptop');
    
     //SMARTSTORE Query = > construct the CS_Bundle_Part_Associations__r relationship to match what is returned by the soql equivalent for online  
    if (device == 'iPad') {
        var bundle, assoc;
        
        CS.Log.warn('Calling SmartQuery for getBundles...');
    
        return CS.DB.smartQuery("SELECT {CS_Bundle__c:_soup} FROM {CS_Bundle__c} WHERE {CS_Bundle__c:Id} IN " + convertToListForSmartQuery(partParams.parentBundleIds))
            .then(function(qr) {
                return qr.getAll().then(function (results) {
                    for (var i = 0; i < results.length; i++) {
                        bundle = results[i][0];

                        if (!partParams.allReferencedBundlesMap[bundle.Id]) {
                            var bundleWithAssoc = bundle;
                            // AF 15/05/2014 Remove local fields from objects retrieved from SmartStore
                            delete bundleWithAssoc._soupEntryId;
                            delete bundleWithAssoc._soupLastModifiedDate;
                            delete bundleWithAssoc.Updated;
                            // end AF
                            bundleWithAssoc.CS_Bundle_Part_Associations__r = []; //construct similar structure to what soql returns. Just initialize the relationship here
                            partParams.allReferencedBundlesMap[bundle.Id] = bundleWithAssoc;
                        }
                    }

                    CS.Log.warn('Bundles retrieved: ' + Object.keys(partParams.allReferencedBundlesMap).length);
                    return Q.resolve(partParams);
                });
            })
            .then(function (partParams) {
                return getBundleAssociationsSmSt(partParams);
            })
            .fail(function(e) { CS.Log.error(e);});  
    }
    
    else if (device == 'Laptop'){
        //fire Remote Action to return  Map<Id, CS_Bundle__c> where CS_Bundle__c contains CS_Bundle_Part_Associations__r relationship
        
        var deferred = Q.defer(); 
        CS.Log.warn('Calling RemoteAction getBundlesWithAssociations...');
        
        UISupport.getBundlesWithAssociations(
            partParams.parentBundleIds,
            function (result, event) {
                if (event.status) {
                    partParams.allReferencedBundlesMap = result;
                    CS.Log.warn('BundlesWithAssociations retrieved: ' + Object.keys(partParams.allReferencedBundlesMap).length);
                    
                    deferred.resolve(partParams);
                }
                else {
                    deferred.reject('Event failed');
                }
            }
        );
        
        return deferred.promise;
    }
    
    throw 'Should not get here';
 }
 
 /**
  * Retrieves the BundleAssociations for the Bundles of interest and further populates the partParams.allReferencedBundlesMap map
  * (The 2 SmartStores queries could not be combined in an inner join as this would rule out Bundles without Associations)
  * @param {Object} partParams
  */
 function getBundleAssociationsSmSt(partParams) {
    CS.indicator.start();
    CS.Log.warn('Calling SmartQuery for getBundleAssociations...');
    
    return CS.DB.smartQuery("SELECT {CS_Bundle_Part_Association__c:_soup} FROM {CS_Bundle_Part_Association__c} WHERE {CS_Bundle_Part_Association__c:Bundle__c} IN " 
        + convertToListForSmartQuery(partParams.parentBundleIds) + " AND {CS_Bundle_Part_Association__c:Type__c} = '" + CS_PartAssocRelationship_Requires + "'")
        .then(function(qr) {
            return qr.getAll().then(function (results) {
                for (var i = 0; i < results.length; i++) {
                    assoc = results[i][0];
                                
                    if (partParams.allReferencedBundlesMap[assoc.Bundle__c])  {
                        var bundleWithAssoc = partParams.allReferencedBundlesMap[assoc.Bundle__c];
                        bundleWithAssoc.CS_Bundle_Part_Associations__r.push(assoc);
                        partParams.allReferencedBundlesMap[assoc.Bundle__c] = bundleWithAssoc;
                    }
                }
                            
                CS.Log.warn('BundleAssociations retrieved: ' + results.length);
                return Q.resolve(partParams);
            });
        })
        .fail(function(e) { CS.Log.error(e);});
 }
 
 
 /**
  * Retrieves an array of CS_Part_Association__c for the changed Part attributes
  * @param {Object} partParams
  */
 window.getPartAssociations = function getPartAssociations(partParams) {
    CS.indicator.start();
    var partAssociations = [];
    
    if (!partParams.parentPartIds || partParams.parentPartIds.length == 0) {
        CS.Log.warn('No parentPartIds to query.');
    
        return Q.resolve(partParams); 
    }
    
    var device = (navigator.device ? 'iPad' : 'Laptop');
    if (device == 'iPad' ) {
        
        CS.Log.warn('***** Promises: Now calling SmartQuery for getPartAssociations...');
        
        return CS.DB.smartQuery("SELECT {CS_Part_Association__c:_soup} FROM {CS_Part_Association__c} WHERE ({CS_Part_Association__c:Relationship__c} = '" + CS_PartAssocRelationship_Requires + "' OR {CS_Part_Association__c:Relationship__c} = '" + CS_PartAssocRelationship_Optional + "')" +
            " and {CS_Part_Association__c:Part_1__c} IN " + convertToListForSmartQuery(partParams.parentPartIds)).then(function(qr) {
                return qr.getAll().then(function (results) {
                    for (var i = 0; i < results.length; i++) {
                        partAssociations.push(results[i][0]);
                    }
                    CS.Log.warn('***** PartsWithAssociations retrieved: ' + partAssociations.length);
                            
                    partParams.partAssociations = partAssociations;
                    return Q.resolve(partParams);
                });
            })
            .fail(function(e) { CS.Log.error(e);});
    }
    
    else if (device == 'Laptop'){
        CS.Log.warn('***** Now calling RemoteAction getPartsWithAssociations for ' + partParams.parentPartIds.length + ' parentParts.');
        
        var deferred = Q.defer();
        
        UISupport.getPartsWithAssociations(
            partParams.parentPartIds,
            function (result, event) {
                if (event.status) {
                    partAssociations = result;
                    CS.Log.warn('***** Promises: PartsWithAssociations retrieved: ' + partAssociations.length);
                    
                    partParams.partAssociations = partAssociations;
                    deferred.resolve(partParams);
                }
                else {
                    deferred.reject('Event failed');
                }
            }
        );
        
        return deferred.promise;
    }
    
    throw 'Should not get here'; 
 }

 
 /**
  * Retrieves the entire CS Part records for all Parts in question (Part attributes that were changes as well as associated Parts of Parts or Bundles)
  * @param {Object} partParams
  */
 window.getAllReferencedPartInformation = function getAllReferencedPartInformation(partParams) {
    CS.indicator.start();
    CS.Log.warn('***** Entered getAllReferencedPartInformation function...');
    
    if (!partParams.partIdsToQuery || partParams.partIdsToQuery.length == 0) {
        CS.Log.warn('***** No partIds to query.');
        
        return Q.resolve(partParams); 
    }
    
    var device = (navigator.device ? 'iPad' : 'Laptop');
    
    if (device == 'iPad') {
        
        var pricebookFilter = ''; //(pricebookType == CS_PricebookType_Standard ? ' {CS_Part__c:Instances_in_Standard_Pricebook__c} > 0 ' : ' {CS_Part__c:Instances_in_LowCost_Pricebook__c} > 0');

        if(pricebookType == CS_PricebookType_Standard) {
            pricebookFilter = ' {CS_Part__c:Instances_in_Standard_Pricebook__c} > 0 '; 
        } else if(pricebookType == CS_PricebookType_SmallCommercial) {
            pricebookFilter = ' {CS_Part__c:Instances_in_SmallCommercial__c} > 0 ';
        } else {
            pricebookFilter = ' {CS_Part__c:Instances_in_LowCost_Pricebook__c} > 0';
        } 
        
        //4 Queries: Parts, Parts with PartPrices, Parts with Skills, Parts with Materials -> can be queried CONCURRENTLY!
        
        //Get ALL referenced Parts
        CS.Log.warn('***** Promises: Now calling SmartQuery for get All Referenced Parts...');
        
        return CS.DB.smartQuery("SELECT {CS_Part__c:_soup} FROM {CS_Part__c} WHERE {CS_Part__c:Active_Formula__c} = 1 AND  {CS_Part__c:Id} IN " + convertToListForSmartQuery(partParams.partIdsToQuery) + " and " + pricebookFilter)
            .then(function(qr) {
                return qr.getAll().then(function (results) {
             
                    partParams.allReferencedParts = results;
                    CS.Log.warn('***** AllReferencedParts retrieved: ' + results.length);

                    return Q.resolve(partParams);
                });
            })
            .then(function (partParams) {
                return getPartPriceInformation(partParams);
            })
            .then (function (partParams) {
                return getPartMaterialInformation(partParams);
            })
            .then(function (partParams) {
                return getPartSkillInformation(partParams);
            })
            .then(function (partParams) {
                return mapPartInformation(partParams);
            })
            .fail(function(e) { CS.Log.error(e);});
    }
    
    else if (device == 'Laptop'){
     
       var deferred = Q.defer();
      
        //fire Remote Action to return same structure as above
        partParams.allReferencedPartWrappersMap = {};
        
        CS.Log.warn('***** Promises: Now calling RemoteAction getAllReferencedPartsInformation');
         
        UISupport.getAllReferencedPartInformation(   //returns Map<Id, CS_PartWrapper> )
            partParams.partIdsToQuery,
            districtCode,
            pricebookType,
            function (result, event) {
                if (event.status) {
                    partParams.allReferencedPartWrappersMap = result;
                    CS.Log.warn('***** Parts with info retrieved: ' + Object.keys(partParams.allReferencedPartWrappersMap).length);
                        
                    deferred.resolve(partParams);
                }
                else {
                    deferred.reject('Event failed');
                }
            }
        );
    
        return deferred.promise;
    }
    
    throw 'Should not get here';
 }
 
 /**
  * Retrieves CS Part Prices for these parts
  * @param {Array} results
  * @param {Object} partParams
  */
 function getPartPriceInformation (partParams) {
    CS.indicator.start();
    var allReferencedParts = partParams.allReferencedParts;
    
    CS.Log.warn('***** Promises: AllReferencedParts retrieved: ' + allReferencedParts.length);
    
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();
    
    if(dd<10) {
        dd='0' + dd;
    } 
    if(mm<10) {
        mm='0' + mm;
    }
    today = yyyy + '-' + mm + '-' + dd;
    
    //Then, get Part Prices
    CS.Log.warn('***** Now calling SmartQuery for get All Part Prices...');
    
    return CS.DB.smartQuery("SELECT {CS_Part_Price__c:_soup} FROM {CS_Part_Price__c} WHERE {CS_Part_Price__c:CS_Pricebook_Type__c} = '" + pricebookType + "'" +
        " AND ({CS_Part_Price__c:District__c} IS NULL OR {CS_Part_Price__c:District_Code__c} = '" + districtCode + "')" +
        " AND ({CS_Part_Price__c:Start_Date__c} IS NULL OR {CS_Part_Price__c:Start_Date__c} <= '" + today +  "')" +
        " AND ({CS_Part_Price__c:End_Date__c} IS NULL OR {CS_Part_Price__c:End_Date__c} >= '" + today +  "')" + 
        " AND  {CS_Part_Price__c:Part__c} IN " + convertToListForSmartQuery(partParams.partIdsToQuery))
        .then(function(qr) {
            CS.Log.warn('Got Part Prices queryresult');
            return qr.getAll().then(function (results) {
                CS.Log.warn('***** PartPrices retrieved in total: ' + results.length);
            
                //build Part to PartPrices map
                var partToPartPricesMap = {}; // Map<partId, List<CS_Part_Price__c>

                for (var i = 0; i < results.length; i++) {
                    var pp = results[i][0];
                    if (!partToPartPricesMap[pp.Part__c]) {
                        var partPrices = [];
                        partPrices.push(pp);
                        partToPartPricesMap[pp.Part__c] = partPrices;
                    }
                    else {
                        var partPrices = partToPartPricesMap[pp.Part__c];
                        partPrices.push(pp);
                        partToPartPricesMap[pp.Part__c] = partPrices;
                    }
                }
            
                partParams.partToPartPricesMap = partToPartPricesMap;
            
                return Q.resolve(partParams);
            });
        })
        .fail(function(e) { CS.Log.error(e);});
 }
 
 /**
  * Handles the retrieval of CS Part Prices and then retrieves CS Part Materials for the parts.
  * @param {Object} partParams
  */
 function getPartMaterialInformation(partParams) { //put in args??
    CS.indicator.start();
    //Then, get Part Materials
    CS.Log.warn('***** Promises: Now calling SmartQuery for get All Part Materials...');
    
    return CS.DB.smartQuery("SELECT {CS_Part_Material__c:_soup} FROM {CS_Part_Material__c} WHERE {CS_Part_Material__c:Part__c} IN " + convertToListForSmartQuery(partParams.partIdsToQuery))
        .then(function(qr) {
            return qr.getAll().then(function (results) {
                CS.Log.warn('***** PartMaterials retrieved in total: ' + results.length);

                //build Part to PartMaterials map
                var partToPartMaterialsMap = {}; // Map<partId, List<CS_Part_Material__c>

                for (var i = 0; i < results.length; i++) {
                    var pm = results[i][0];
                    if (!partToPartMaterialsMap[pm.Part__c]) {
                        var partMaterials = [];
                        partMaterials.push(pm);
                        partToPartMaterialsMap[pm.Part__c] = partMaterials;
                    }
                    else {
                        var partMaterials = partToPartMaterialsMap[pm.Part__c];
                        partMaterials.push(pm);
                        partToPartMaterialsMap[pm.Part__c] = partMaterials;
                    }
                }

                partParams.partToPartMaterialsMap = partToPartMaterialsMap;
                return Q.resolve(partParams);
            });
        })
        .fail(function(e) { CS.Log.error(e);});
 }
 
 /**
  * Handles the retrieval of CS Part Materials and then retrieves CS Part Skills for the parts.
  * @param {Object} partParams
  */
 function getPartSkillInformation(partParams) {
    CS.indicator.start();
    //Then, get Part Skills
    CS.Log.warn('****** Promises: Now calling SmartQuery for get All Part Skills...');
    
    return CS.DB.smartQuery("SELECT {CS_Part_Skill__c:_soup} FROM {CS_Part_Skill__c} WHERE {CS_Part_Skill__c:Part__c} IN " + convertToListForSmartQuery(partParams.partIdsToQuery))
        .then(function(qr) {
            return qr.getAll().then(function (results) {

                //build Part to PartSkills map
                var partToPartSkillsMap = {}; // Map<partId, List<CS_Part_Skill__c>

                for (var i = 0; i < results.length; i++) {
                    var ps = results[i][0];
                    if (!partToPartSkillsMap[ps.Part__c]) {
                        var partSkills = [];
                        partSkills.push(ps);
                        partToPartSkillsMap[ps.Part__c] = partSkills;
                    }
                    else {
                        var partSkills = partToPartSkillsMap[ps.Part__c];
                        partSkills.push(ps);
                        partToPartSkillsMap[ps.Part__c] = partSkills;
                    }
                }
                CS.Log.warn('***** PartSkills retrieved in total: ' + results.length);

                partParams.partToPartSkillsMap = partToPartSkillsMap;
                return Q.resolve(partParams);
            });
        })
        .fail(function(e) { CS.Log.error(e);});
 }
 
  /**
  * Handles the retrieval of CS Part Skills and then builds maps for each Part and its associated Prices, Materials and Skills
  * Populates a Map where the key is a partId and the value is an object of type CS_PartWrapper.
  * CS_PartWrapper is a flat structure containing a CS_Part__c and a List its associated part prices (CS_Part_Price__c), part materials (CS_Part_Material__c) and part skills (CS_Part_Skill__c)
  * @param {Object} partParams
  */                      
 function mapPartInformation(partParams) {
    CS.indicator.start();
    CS.Log.warn('****** mapPartInformation called.. ');
    
    //At this point all queries have completed, so do:
    var allReferencedPartWrappersMap = {};
    
    for (var i = 0; i < partParams.allReferencedParts.length; i++ ) {
        var csPart = partParams.allReferencedParts[i][0];
         
         // AF 14/05/14 Remove SmartStore properties from sObject Part records
        delete csPart._soupEntryId;
        delete csPart._soupLastModifiedDate;
        delete csPart.Updated; // TEMP - this local field should not be appearing
        // end AF
        
        var csPartPrices = (partParams.partToPartPricesMap[csPart.Id] ? partParams.partToPartPricesMap[csPart.Id] : {});
        var csPartMaterials = (partParams.partToPartMaterialsMap[csPart.Id] ? partParams.partToPartMaterialsMap[csPart.Id] : {});
        var csPartSkills = (partParams.partToPartSkillsMap[csPart.Id] ? partParams.partToPartSkillsMap[csPart.Id] : {});
        
        allReferencedPartWrappersMap[csPart.Id] = new CS_PartWrapper (csPart, csPartPrices, csPartMaterials, csPartSkills);
    }
    
    CS.Log.warn('****** Referenced Parts retrieved: ' + Object.keys(allReferencedPartWrappersMap).length);

    partParams.allReferencedPartWrappersMap = allReferencedPartWrappersMap;
    return Q.resolve(partParams);
 }
})
 
