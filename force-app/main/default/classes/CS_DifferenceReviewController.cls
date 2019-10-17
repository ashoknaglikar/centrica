global without sharing class CS_DifferenceReviewController {
    // input parameters
    public String dateFromString {get; set;}
    public String dateToString {get; set;}
    public String status {get; set;}
    
    // datepicker values
    public String firstOfMonth {get; set;}
    public String lastOfMonth {get; set;}

    //error model items
    public List<CustomErrorModel> errorModelList {get; set;}

    public cscfga__Date_Range__c dateRange {get {
           return new cscfga__Date_Range__c();
    }}

    public CS_DifferenceReviewController(ApexPages.StandardController c) {
        Date tdy = Date.today();
        
        Date first = tdy.toStartofMonth();
        DateTime firstDT = datetime.newInstance(first.year(), first.month(), first.day());
        firstOfMonth = firstDT.format('dd/MM/yyyy');
       
        Date last = tdy.addMonths(1).toStartofMonth().addDays(-1); 
        DateTime lastDT = datetime.newInstance(last.year(), last.month(), last.day());
        lastOfMonth = lastDT.format('dd/MM/yyyy');
    }

    public class CustomPartModel {
        public Id id {get; set;}
        public String Name{get; set;}
        
        public CustomPartModel(Id i, String n){
            this.id = i;
            this.Name = n;
        }
    } 
    
    global class CustomErrorModel implements Comparable {
        public Id ProductBasketId {get; set;}
        public String ProductBasketName {get; set;}
        public String ProductBasketCreatedDate {get; set;}
        
        public List<CustomPartModel> PartModels {get; set;}
        public List<CustomPartModel> AttrModels {get; set;}
        
        public CustomErrorModel(Id id, String name, DateTime d, List<CustomPartModel> pml, List<CustomPartModel> atl) {
            this.ProductBasketId = id;
            this.ProductBasketName = name;
            this.ProductBasketCreatedDate = d.format('dd/MM/yyyy');
            this.PartModels = pml;
            this.AttrModels = atl;
        }
        
        /*
            Comparable.compareTo() implementation
        */
        global Integer compareTo(Object other) {
            Date otherAge = Date.parse(((CustomErrorModel)other).ProductBasketCreatedDate);  
            return otherAge.daysBetween(Date.parse(this.ProductBasketCreatedDate));
        }
    }
    
    public PageReference getPcFilteredList() {
        // select all of the product configuration Ids based on the following filters
        Date dateFrom = parseDateString(dateFromString); 
        Date dateTo = parseDateString(dateToString);
        
        // retrieve  all root configuration inside that date range and status
        transient Map<Id, cscfga__Product_Configuration__c> rootPcs = new Map<Id, cscfga__Product_Configuration__c>(
            [SELECT CreatedDate, cscfga__Root_Configuration__c, Id, Name, 
             cscfga__Product_Basket__c, cscfga__Product_Basket__r.Name, cscfga__Product_Basket__r.CS_Quote_Status__c
             FROM cscfga__Product_Configuration__c 
             where cscfga__Root_Configuration__c = null 
             and CreatedDate >= :dateFrom
             and CreatedDate <= :dateTo
             and cscfga__Product_Basket__r.CS_Quote_Status__c = :status
            ]);
            
        system.debug('*** rootPcs:');
        system.debug(rootPcs);      
         
        
        // retrieve all of the descendant product configurations
        transient List<cscfga__Product_Configuration__c> descendantPcs = [SELECT cscfga__Root_Configuration__c, Id, Name 
                                                FROM cscfga__Product_Configuration__c 
                                                where cscfga__Root_Configuration__c in :rootPcs.keySet() 
                                                ];
                                                
        system.debug('*** descendantPcs:');
        system.debug(descendantPcs);  
    
        transient Set<Id> allPcIdsSet = new Set<Id>();
        allPcIdsSet.addAll(rootPcs.keySet());
        // map the root pc to the descendant configuration ids
        transient Map<Id, List<Id>> rootPcsToDescendantIdMap = new Map<Id, List<Id>>();
        for(cscfga__Product_Configuration__c pc : descendantPcs) {
            if(rootPcsToDescendantIdMap.containsKey(pc.cscfga__Root_Configuration__c)) {
                rootPcsToDescendantIdMap.get(pc.cscfga__Root_Configuration__c).add(pc.Id);
                allPcIdsSet.add(pc.Id);
            } else {
                rootPcsToDescendantIdMap.put(pc.cscfga__Root_Configuration__c, new List<Id> { pc.Id });
                allPcIdsSet.add(pc.cscfga__Root_Configuration__c);
                allPcIdsSet.add(pc.Id);
            }
            pc = null;
        }
        
        system.debug('*** allPcIdsSet:');
        system.debug(allPcIdsSet);  
    
       // retrieve all of the attributes for those product configurations 
        transient List<cscfga__Attribute__c> attributeList = [SELECT cscfga__Is_Line_Item__c, cscfga__Product_Configuration__c, cscfga__Value__c,
                                                    cscfga__Product_Configuration__r.cscfga__Root_Configuration__c, Name 
                                                    FROM cscfga__Attribute__c 
                                                    where cscfga__Is_Line_Item__c = true
                                                    and cscfga__Product_Configuration__c in :allPcIdsSet];
        system.debug('*** attributeList:');
        system.debug(attributeList);      
                     
        // map the root pc to the attribute list
        transient Map<Id, List<cscfga__Attribute__c>> rootPcsToAllAttributeListMap = new Map<Id, List<cscfga__Attribute__c>>();
        for(cscfga__Attribute__c att : attributeList) {
            if(att.cscfga__Product_Configuration__r.cscfga__Root_Configuration__c != null) {
                if(rootPcsToAllAttributeListMap.containsKey(att.cscfga__Product_Configuration__r.cscfga__Root_Configuration__c)) {
                    rootPcsToAllAttributeListMap.get(att.cscfga__Product_Configuration__r.cscfga__Root_Configuration__c).add(att);
                } else {
                    rootPcsToAllAttributeListMap.put(att.cscfga__Product_Configuration__r.cscfga__Root_Configuration__c, new List<cscfga__Attribute__c>{ att });
                }                
            } else {
                if(rootPcsToAllAttributeListMap.containsKey(att.cscfga__Product_Configuration__c)) {
                    rootPcsToAllAttributeListMap.get(att.cscfga__Product_Configuration__c).add(att);
                } else {
                    rootPcsToAllAttributeListMap.put(att.cscfga__Product_Configuration__c, new List<cscfga__Attribute__c>{ att });
                }  
            }  
            att = null;
        }
        
        // clear lists and maps to free the heap size 
        descendantPcs = null;
        rootPcsToDescendantIdMap = null;
        attributeList = null;
        
        // Iterate through all of the product configurations retrieved
        errorModelList = new List<CustomErrorModel>();
        transient Attachment a = new Attachment();
        transient List<CustomPartModel> rootPartsList = new List<CustomPartModel>();
        transient Map<String, CS_PartModelEntry> partsModel = new  Map<String, CS_PartModelEntry>();
        transient Map<Id, CustomPartModel> rootPartsMap = new Map<Id, CustomPartModel>();
        transient List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        transient Map<Id, cscfga__Attribute__c> attMap = new Map<Id, cscfga__Attribute__c>();
        transient List<CustomPartModel> pmErrors = new List<CustomPartModel>();
        transient List<CustomPartModel> attErrors = new List<CustomPartModel>();
        
        
        DateTime lastReturnedCreatedDate = datetime.newInstance(dateTo.year(), dateTo.month(), dateTo.day());
        List<Attachment> atList = new List<Attachment>();
        do {
            atList = null;
            atList = [SELECT Id, Name, OwnerId, ParentId, Body, CreatedDate FROM Attachment where ParentId in :rootPcs.keySet() and CreatedDate < :lastReturnedCreatedDate ORDER BY CreatedDate DESC LIMIT 10];
            for(Attachment at : atList) {
                lastReturnedCreatedDate = at.CreatedDate;
                system.debug('Current heap:::loop2: ' + Limits.getHeapSize());
                Id key = at.ParentId;
                // for each root product configuration get the parts model
                // get the root parts from the parts model
                // a = rootPcsToAttachmentsMap.get(key);
                rootPartsList = new List<CustomPartModel>();
                
                try {
                    partsModel = (Map<String, CS_PartModelEntry>)JSON.deserialize(at.Body.toString(), Map<String, CS_PartModelEntry>.class); 
                    
                    rootPartsList = returnRootCustomPartModels(partsModel);
                    system.debug('*** rootPartsList: ');
                    system.debug(rootPartsList);
                    at = null;
                } catch (Exception e) {} 
                rootPartsMap = new Map<Id, CustomPartModel>();
                for(CustomPartModel cpm : rootPartsList) {
                    rootPartsMap.put(cpm.Id, cpm);
                    cpm = null;
                }
    
                // get all of the line items from the product configurations
                attList = rootPcsToAllAttributeListMap.get(key);
                system.debug('**********');
                system.debug(rootPcsToAllAttributeListMap);
                if(attList == null) attList = new List<cscfga__Attribute__c>();
                system.debug('*** attList: ');
                system.debug(attList);
                attMap = new Map<Id, cscfga__Attribute__c>();
                for(cscfga__Attribute__c attrib : attList) {
                    if(attrib.cscfga__Value__c != null) {
                        attMap.put(attrib.cscfga__Value__c, attrib);
                    }
                    attrib = null;
                }
                
        
                // compare the two, if there are any differences, save them for display on user screen
                // iterate through one list, then the other
                // update the errorModelList accordingly
                pmErrors = new List<CustomPartModel>();
                for(CustomPartModel m : rootPartsList) {
                    if(!attMap.containsKey(m.Id)) {
                        pmErrors.add(m);   
                    }
                    m = null;
                }
                
                attErrors = new List<CustomPartModel>();
                for(cscfga__Attribute__c attr : attList) {
                   if(!rootPartsMap.containsKey(attr.cscfga__Value__c) && attr.cscfga__Value__c != null) {
                       attErrors.add(new CustomPartModel(attr.cscfga__Value__c, attr.Name));
                   }
                   attr = null;
                }
                
                attList = null;
                rootPartsList = null;
                system.debug('adding basket with id: ' + rootPcs.get(key).cscfga__Product_Basket__c);
                errorModelList.add(new CustomErrorModel(rootPcs.get(key).cscfga__Product_Basket__c, rootPcs.get(key).cscfga__Product_Basket__r.Name, rootPcs.get(key).CreatedDate, pmErrors, attErrors));
                pmErrors = null;
                attErrors = null;
            }
        } while (atList.size() > 0);
        
        clearEmptyErrorModelList(errorModelList);
        errorModelList.sort();
        system.debug('Error model list: ');
        system.debug(JSON.serializePretty(errorModelList));
        
        return null;
    }
    
    /**
     * Clears the CustomErrorModel list (removes the items which have no PartModels or AttrModels)
     */
    public static void clearEmptyErrorModelList(List<CustomErrorModel> errorModelList) {
        for(Integer i = 0; i < errorModelList.size(); i++) {
            CustomErrorModel cem = errorModelList[i];
            system.debug('error model list sizes are: ' + cem.ProductBasketId + ' ' + cem.PartModels.size() + ' and ' + cem.AttrModels.size());
            if(cem.PartModels.size() == 0 && cem.AttrModels.size() == 0) {
                errorModelList.remove(i);
                i--;
            }
        }
    }

    /**
     * Returns a list of only top level (ROOT) CustomPartModel objects containing Ids and Names of the parts and bundles present inside the partsModel.txt
     */
    public static List<CustomPartModel> returnRootCustomPartModels(Map<String, CS_PartModelEntry> partsModel) {
        List<CustomPartModel> partsModelIds = new List<CustomPartModel>();
        
        for (String key : partsModel.keySet()) {
            if(!key.contains('AutoAdded_')) {
                CS_PartModelEntry part = partsModel.get(key);
                if(part != null) {
                    if(part.parentPart != null) {
                        if(part.isLineItem) {
                            partsModelIds.add(new CustomPartModel(part.parentPart.part.Id, part.parentPart.part.Name));
                        }
                    } else {
                        partsModelIds.add(new CustomPartModel(part.parentBundle.Id, part.parentBundle.Name));
                    }
                }
                part = null;
            }
        }
        return partsModelIds;    
    }
    
    /**
     * Parses the provided date string, returns the date.
     */
    public static Date parseDateString(String d){
        if (d == null) {
            return null;
        }
        try {
            Date parsedDate = Date.parse(d); 
            return parsedDate; 
        }
        catch (TypeException e) {
            try {
                Date parsedDate = Date.valueOf(d); 
                return parsedDate;
            }
            catch (TypeException ex) {
                return null;
            }        
        }
        return null;    
    }

}