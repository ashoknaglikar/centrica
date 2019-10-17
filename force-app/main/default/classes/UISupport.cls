public with sharing class UISupport {

    public cscfga__Date_Range__c dateRange {get {
           return new cscfga__Date_Range__c();
    }}

    public String basketId {get; set;}
    public String configId {get; set;}
    public String definitionId {get; set;}
    public String linkedId {get; set;}
    public String retURL {get; set;}
    public String template {get; set;}

    public String userProfileName {get;set;}
    public String screenFlowName {get;set;}

    public ApexPages.StandardController controller;

    public static final Pattern URL_ID_PATTERN = Pattern.compile('(?:.*/)?([\\da-zA-Z]{15}(?:[\\da-zA-Z]{3})?).*'); //'

    public UISupport() {
        init(ApexPages.currentPage().getParameters());
    }
    
    public UISupport(cscfga.ProductConfiguratorController c) {
        init(ApexPages.currentPage().getParameters());
    }

    public UISupport(ApexPages.StandardController c) {
        controller = c;
        init(ApexPages.currentPage().getParameters());
    }

    public UISupport(Map<String, String> params) {
        init(params);
    }

    void init(Map<String, String> params) {
        definitionId = params.get('definitionId');
        configId = params.get('configId');
        template = params.get('template');
        retURL = params.get('retURL');
        linkedId = params.get('linkedId');
        basketId = params.get('basketId');
        userProfileName = params.get('userProfileName');
        screenFlowName = params.get('screenFlowName');
    }

    public PageReference redirectProductBasket() {
        String configURL = '/apex/c__ProductConfigurationScreen';
        if (retURL == null) {
            retURL = '';
        }

        if (basketId == null && controller != null) {
            basketId = controller.getId();
        }

        PageReference p = Page.SelectProductCategory;
        p.getParameters().put('retURL', retURL);
        p.getParameters().put('configURL', configURL);
        if (linkedId != null) {
            p.getParameters().put('linkedId', linkedId);
        }
        if (basketId != null) {
            p.getParameters().put('basketId', basketId);
        }
        return p;
    }

    public PageReference redirectProductConfiguration() {
        String configURL = '/apex/c__ProductConfigurationScreen';

        if (controller != null) {
            configId = controller.getId();
        }

        cscfga__Product_Configuration__c config = [SELECT cscfga__Product_Definition__c FROM cscfga__Product_Configuration__c WHERE Id = :configId];

        Matcher retURLMatcher = URL_ID_PATTERN.matcher(retURL);

        if (retURL != null && retURLMatcher.matches()) {
            basketId = retURLMatcher.group(1);
        }

        cscfga__Product_Basket__c basket = [SELECT Appointment__c FROM cscfga__Product_Basket__c WHERE Id = :basketId];

        PageReference p = Page.ProductConfigurationScreen;
        p.getParameters().put('retURL', retURL);
        p.getParameters().put('configId', configId);
        p.getParameters().put('definitionId', config.cscfga__Product_Definition__c);
        p.getParameters().put('linkedId', basket.Appointment__c);
        p.getParameters().put('basketId', basketId);
        p.getParameters().put('userProfileName', '');
        p.getParameters().put('screenFlowName', '');
        return p;
    }

    @RemoteAction
    public static String getProductModel(Id id) {
        return getTextAttachment(id, 'ProductModelData');
    }

    @RemoteAction
    public static String getProductTemplate(Id id, String screenFlowName, String templateName) {
        String name = (screenFlowName != '' ? screenFlowName : 'DefaultScreenFlow') + '-' + (templateName != '' ? templateName : 'cfgoffline__RenderOfflineAppUI');
        return getTextAttachment(id, name);
    }

// added for new Configurator 
    @RemoteAction
    public static String getLinkedObjectProperties(Id linkedObjectId, Id productDefinitionId) {
        return cscfga.UISupport.getLinkedObjectProperties(linkedObjectId, productDefinitionId);
    }

    @RemoteAction
    public static String getScreenflowPredicateFunctions(Id productDefinitionId) {
        return cscfga.UISupport.getScreenflowPredicateFunctions(productDefinitionId);
    }

    @RemoteAction
    public static String evaluateScreenFlowPredicates(Id productDefinitionId, Id linkedObjectId) {
        return cscfga.UISupport.evaluateScreenFlowPredicates(productDefinitionId, linkedObjectId);
    }

    @RemoteAction
    public static Object getRelatedProductSelectionData(String params) {
        return cscfga.UISupport.getRelatedProductSelectionData(params);
    }

    @RemoteAction
    public static String loadCustomLookupReferencedAttributes(Id productDefinitionId) {
        return cscfga.UISupport.loadCustomLookupReferencedAttributes(productDefinitionId);
    }

     @RemoteAction
    public static Object getSelectListLookup(String params, String deprecated1, String deprecated2, String deprecated3) {
        return cscfga.UISupport.getSelectListLookup(params, deprecated1, deprecated2,  deprecated3);
    }
//end
    @RemoteAction
    public static String getProductConfiguration(Id id) {
        return JSON.serializePretty(getConfigurationData(id));
    }

    @RemoteAction
    public static Object lookupQuery(String queryName, Map<String, String> dynamicFilterMap, String productDefinitionID) {
//        throw new cscfga.ConfiguratorException('Temporarily disabled (AF)'); // 17-03-2014 17:30 due to invalid dependency resolution, will re-activate shortly 
        return cscfga.StatelessUIController.lookupQuery(queryName, dynamicFilterMap, productDefinitionID);
    }

    @RemoteAction
    public static Map<String, String> storeConfigs(String js) {
        List<Object> os = (List<Object>)JSON.deserializeUntyped(js);
        List<Map<String, Object>> basketMaps = decodeList(os[0]);
        List<Map<String, Object>> configMaps = decodeList(os[1]);
        List<Map<String, Object>> attrMaps = decodeList(os[2]);
        List<Map<String, Object>> attrFieldMaps = decodeList(os[3]);        
                
        cscfga__Product_Basket__c basket = (cscfga__Product_Basket__c) mapToSObject(cscfga__Product_Basket__c.class, basketMaps[0]);
        String status = basket.cscfga__Basket_Status__c;
        basket.cscfga__Basket_Status__c = 'Uploading'; // replace with savepoint
        if (basket.Id != null) {
            cscfga__Product_Basket__c original = [SELECT Appointment__c FROM cscfga__Product_Basket__c WHERE Id = :basket.Id];
            if (original.Appointment__c != basket.Appointment__c) {
                throw new cscfga.ConfiguratorException('Basket appointment Id mismatch: ' + original.Appointment__c + ' / ' + basket.Appointment__c);
            }
        }
       
        upsert basket;
               
        List<sObject> configs = mapsToSObjects(cscfga__Product_Configuration__c.class, configMaps);
        Map<String, List<sObject>> configsToInsert = new Map<String, List<sObject>>();
        Map<String, String> dependencies = new Map<String, String>();
        List<sObject> configsToUpdate = new List<sObject>();
        List<sObject> attrsToInsert = new List<sObject>();
        List<sObject> attrsToUpdate = new List<sObject>();
        List<sObject> attrFieldsToInsert = new List<sObject>();
        List<sObject> attrFieldsToUpdate = new List<sObject>();
        sObject root;        
        
        // Link configs to basket and insert in order (single DML insert is not working for some reason)
        Integer i = 0,
                pos = 0;
        for (sObject o : configs) {
            String configBasketId = (String) o.get('cscfga__Product_Basket__c');
            if (configBasketId != null && configBasketId != basket.Id) {
                throw new cscfga.ConfiguratorException('Updated configuration has mismatched basket Id');
            }
            o.put('cscfga__Product_Basket__c', basket.Id);
            if (o.get('cscfga__Attribute_Name__c') == null) {
                root = o;
            } else {
                if (o.get('Id') != null) {
                    configsToUpdate.add(o);
                } else {
                    List<sObject> sos = configsToInsert.get((String) o.getSObject('cscfga__Parent_Configuration__r').get('cscfga__Key__c'));
                    if (sos == null) {
                        sos = new List<sObject>();
                        configsToInsert.put((String) o.getSObject('cscfga__Parent_Configuration__r').get('cscfga__Key__c'), sos);
                    }
                    sos.add(o);
                    dependencies.put((String) o.get('cscfga__Key__c'), (String) o.getSObject('cscfga__Parent_Configuration__r').get('cscfga__Key__c')); 
                }
            }
            i++;
        }
        upsert root;
                
        List<sObject> attrs = mapsToSObjects(cscfga__Attribute__c.class, attrMaps);
        for (sObject o : attrs) {
            if (o.get('Id') != null) {
                attrsToUpdate.add(o);
            } else {
                attrsToInsert.add(o);
            }
            // truncate long displayValues (Text Display attrs)
            String displayValue = (String) o.get('cscfga__Display_Value__c');
            if (displayValue != null && displayValue.length() > 255) {
                displayValue = displayValue.substring(0, 254);
                o.put('cscfga__Display_Value__c', displayValue);
            }
        }

        List<sObject> attrFields = mapsToSObjects(cscfga__Attribute_Field__c.class, attrFieldMaps);
        for (sObject o : attrFields) {
        
            //EP 30/06/2014: Check and truncate cscfga__Value__c if length is greater than 255
            String afValue = (String) o.get('cscfga__Value__c');
            if (afValue != null && afValue.length() > 255) {
                afValue = afValue.substring(0, 254);
                o.put('cscfga__Value__c', afValue);
                system.debug('**** Truncated value for: ' + o.get('Name'));
            }
        
        
            if (o.get('Id') != null) {
                attrFieldsToUpdate.add(o);
            } else {
                attrFieldsToInsert.add(o);
            }
        }
        
        System.debug(LoggingLevel.INFO, 'Configs to insert: ' + configsToInsert);
        
        List<sObject> allConfigs = insertConfigs(configsToInsert, dependencies);
        update configsToUpdate;
        insert attrsToInsert;
        update attrsToUpdate;
        insert attrFieldsToInsert;
        update attrFieldsToUpdate;
                
        configsToUpdate.add(root);
        configsToUpdate.addAll(allConfigs);
        update configsToUpdate; // update price
        
        basket.put('cscfga__Basket_Status__c', status);
        update basket; // update status and price(?)
              
        return new Map<String, String>{
            'basketId' => basket.Id,
            'configId'=> root.Id
        };
    }
    
    
    @RemoteAction
    public static Integer getQuoteCountOnOpportunity(Id oppId)   {
        
        return CS_QuoteReferenceGenerator.getQuoteCountOnOpportunity(oppId);
    }
    
      
    /*
     * Serializes and stores the partsModel in an Attachment against the Product Configuration
     */
    public static void storePartsModel(String configId, Map<String, CS_PartModelEntry> partsModel) {
        
        List<Attachment> attachmentList = [SELECT Id, Name FROM Attachment where ParentId = :configId and Name!='Attributes as JSON'];
        Attachment attachment = (attachmentList != null && attachmentList .size()>0) ? attachmentList[0] : null;
        if (attachment == null) {
            attachment = new Attachment();
            attachment.ParentID = configId;
        }
        attachment.Body = Blob.valueOf(JSON.serializePretty(partsModel));
        attachment.Name = 'partsModel.txt';  
        
        upsert attachment;
        
        system.debug('******* Attachment Id: ' + attachment.Id);
    }
    
    @RemoteAction
    public static void savePartsModel(String configId, Map<String, CS_PartModelEntry> partsModel)   {
        storePartsModel(configId, partsModel);
    }
    
    @RemoteAction
    public static List<CS_Part__c> getPartsByPartCode(List<String> packCodesToRetrieve)   {
        
        String partQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Part__c') + 
        ' From CS_Part__c Where Part_Code__c in '+ CS_SObjectHelper.convertStringListToSoqlInListString(packCodesToRetrieve);
      
        List<CS_Part__c> fetchedParts = ((List<CS_Part__c>)database.query(partQuery));

        return fetchedParts;
    }
    
    @RemoteAction
    public static Map<String, CS_PartModelEntry > getPartsModel(String configId) {  //was Map<String, CS_PartModelEntry >
        String partsModel;
        List<Attachment> attachmentList = [SELECT Id, Name, Body FROM Attachment where ParentId = :configId and Name!='Attributes as JSON'];
        Attachment attachment = (attachmentList != null && attachmentList .size()>0) ? attachmentList[0] : null;
        
        Map<String, CS_PartModelEntry> mapPartsModel = new Map<String, CS_PartModelEntry>(); 
        if (attachment != null) {
            partsModel = attachment.Body.toString(); 
                       
           mapPartsModel = (Map<String, CS_PartModelEntry>)JSON.deserialize(partsModel, Map<String, CS_PartModelEntry>.class); 
        }
        
        return mapPartsModel;
    }
    
    /*
     * Get Bundle Info, Bundle-to-Part Associations
     */
    @RemoteAction
    public static Map<Id, CS_Bundle__c> getBundlesWithAssociations(List<Id> parentBundleIds) {
    
        //select all fields so that result matches what is retrieved from SmartStore
        String bundlesQuery = 'select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Bundle__c') +
                                ',(select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Bundle_Part_Association__c') + ' from CS_Bundle_Part_Associations__r' +
                                    ' where Type__c = \'' + CS_Constants.CS_PartAssociationRelationship_Requires + '\')' +
                                 ' from CS_Bundle__c where Id in ' +  CS_SObjectHelper.convertIdListToSoqlInListString(parentBundleIds) ;

        Map<Id, CS_Bundle__c> bundleMap = new Map<Id, CS_Bundle__c> ((List<CS_Bundle__c>)Database.query(bundlesQuery));
        return bundleMap;
    }
    
    /*
     * Get Bundle Info, BundleComplexPriceAssociations
     */
    @RemoteAction
    public static Map<Id, CS_Bundle_Complex_Price_Association__c> getBundleComplexPriceAssociations(List<Id> parentBundleIds, Decimal totalSkillHoursWithoutElectricalWork) {
        
        //select all fields so that result matches what is retrieved from SmartStore
        String query = 'select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Bundle_Complex_Price_Association__c') +
                         ', CS_Part__r.Name, CS_Part__r.Part_Code__c' +
                                 ' from CS_Bundle_Complex_Price_Association__c where CS_Bundle__c in ' +  CS_SObjectHelper.convertIdListToSoqlInListString(parentBundleIds) +
                                 ' and Lower_Skill_Hours_Limit__c <= ' + totalSkillHoursWithoutElectricalWork +
                                 ' and (Upper_Skill_Hours_Limit__c > ' + totalSkillHoursWithoutElectricalWork + ' or Upper_Skill_Hours_Limit__c = null)';

        Map<Id, CS_Bundle_Complex_Price_Association__c> bundleMap = new Map<Id, CS_Bundle_Complex_Price_Association__c> ((List<CS_Bundle_Complex_Price_Association__c>)Database.query(query));
        return bundleMap;
    }
    
    /*
     * Get Part-to-Part Associations
     */
    @RemoteAction
    public static List<CS_Part_Association__c> getPartsWithAssociations(List<Id> parentPartIds) {
        
        //select all fields so that result matches what is retrieved from SmartStore
        String partAssocQuery = 'select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Part_Association__c') +
                                 ' from CS_Part_Association__c where Part_1__c in ' +  CS_SObjectHelper.convertIdListToSoqlInListString(parentPartIds) +
                                ' and (Relationship__c = \'' + CS_Constants.CS_PartAssociationRelationship_Requires + '\' or Relationship__c = \'' + CS_Constants.CS_PartAssociationRelationship_Optional + '\')';
        
        List<CS_Part_Association__c> partAssociations = Database.query(partAssocQuery);
        return partAssociations;
    }
    
    /*
     * Get Part-to-Part Associations
     * overloaded original version and exteneded signature to accepts relationship type parameter
     * TODO: this method should replace all usages of orginal method, at that point orginal can be deleted
     */
    @RemoteAction
    public static List<CS_Part_Association__c> getPartsWithAssociationsOfType(List<Id> parentPartIds, String relationshipType) {
        
        //select all fields so that result matches what is retrieved from SmartStore
        String partAssocQuery = 'select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Part_Association__c') +
                                 ' from CS_Part_Association__c where Part_1__c in ' +  CS_SObjectHelper.convertIdListToSoqlInListString(parentPartIds) +
                                ' and Relationship__c = \'' + relationshipType + '\'';
        
        List<CS_Part_Association__c> partAssociations = Database.query(partAssocQuery);
        return partAssociations;
    }
    
     /*
     * Gets Part, Part Prices, Part Materials and Part Skills of provided partIds
     */
    @RemoteAction
    public static Map<Id, CS_PartWrapper> getAllReferencedPartInformation(List<Id> partIdsToQuery, String districtCode, String pricebookType) {
    
        Map<Id, CS_PartWrapper> allReferencedPartWrappersMap = new Map<Id, CS_PartWrapper>();
    
        String pricebookFilter = '';
        if(pricebookType == CS_Constants.CS_PricebookType_Standard) {
            pricebookFilter = ' Exists_in_Standard_Pricebook__c = true '; 
        } else if(pricebookType == CS_Constants.CS_PricebookType_Pricebook3) {
            pricebookFilter = ' Exists_in_Pricebook3__c = true ';
        } else if(pricebookType == CS_Constants.CS_PricebookType_Pricebook4) {
            pricebookFilter = ' Exists_in_Pricebook4__c = true ';
        } else if(pricebookType == CS_Constants.CS_PricebookType_SmallCommercial) {
            pricebookFilter = ' Exists_in_Small_Commercial__c = true ';
        } else {
            pricebookFilter = ' Exists_in_Low_Cost_Pricebook__c = true ';
        } 
        //select all fields so that result matches what is retrieved from SmartStore
        
        String partsQuery = 'select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Part__c') + 
                            ' ,(select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Part_Material__c') + ' from CS_Part_Materials__r) ' +
                            ' ,(select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Part_Skill__c') +  ' from CS_Part_Skills__r ) ' +
                            ' ,(select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Part_Price__c') +
                                ' from CS_Part_Prices__r  ' +
                                ' where CS_Pricebook_Type__c = \'' + pricebookType + '\'' +
                                   ' and (District__c = null or District_Code__c  = \'' + districtCode + '\') ' + 
                                   ' and (Start_Date__c = null or Start_Date__c <= TODAY) and (End_Date__c = null or End_Date__c >= TODAY)) ' +  
                            ' from CS_Part__c ' +
                            ' where Active__c = true and Id in ' + CS_SObjectHelper.convertIdListToSoqlInListString(partIdsToQuery) +
                            ' and ' + pricebookFilter; 
                                                          
        System.debug('****partsQuery: ' + partsQuery);
        
        Map<Id, CS_Part__c> allReferencedPartsMap = new Map<Id, CS_Part__c> ((List<CS_Part__c>)database.query(partsQuery));
        
        system.debug('**** Referenced Parts retrieved: ' + allReferencedPartsMap.keySet().size() + ' - ' + allReferencedPartsMap.keySet());
        
        //Now fire another soql to retrieve CS Parts ONLY without child relationships
        String simplePartsQuery = 'select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Part__c') + 
                                    ' from CS_Part__c ' +
                                    ' where Id in ' + CS_SObjectHelper.convertIdListToSoqlInListString(new List<Id>(allReferencedPartsMap.keySet()));
                                    
        Map<Id, CS_Part__c> simpleParts = new Map<Id, CS_Part__c> ((List<CS_Part__c>)database.query(simplePartsQuery));
        
        for (Id pId : allReferencedPartsMap.keySet()) {
            CS_Part__c simplePart = simpleParts.get(pId);
            CS_Part__c originalPart = allReferencedPartsMap.get(pId);
            
            CS_PartWrapper partWrapper = new CS_PartWrapper (simplePart, originalPart.CS_Part_Prices__r, originalPart.CS_Part_Materials__r, originalPart.CS_Part_Skills__r);
            allReferencedPartWrappersMap.put(pId, partWrapper);
        }
        
        return allReferencedPartWrappersMap;
    }
    
    ////////////////////////////////////////////////////////////////
    
     @RemoteAction
    public static List<CS_Allowance__c> getApplicableAllowances(String productType, Decimal grossPrice, Integer customerAge, 
        String leadCreation, String voucherNo, String employeeId, String productInterest) {
                        
        Date leadCreationDate = Date.valueOf(leadCreation);
		
        String allowancesQuery = 'Select c.Id, c.Name, c.Description__c, c.Allowance_Code__c, c.Allowance_Type__c, c.Amount__c, c.Amount_Type__c, c.Cash_Equivalent_Amount__c, c.Commissionable__c, ' +
                    'c.Margin_Based__c, C.Non_Cash__c, c.Quote_Description__c, c.Start_Date__c , c.End_Date__c, c.Expiry_Date__c, c.Minimum_Age__c, c.Minimum_Threshold__c, ' +
                    'c.Requires_Employee_ID__c, c.Requires_Voucher_ID__c, c.Valid_Product_Types__c, c.Media_Codes__c, c.Available_for_Products__c, c.Requires_Billing_Ref__c, ' + 
					'c.Requires_Email__c, c.Requires_Ref_Number__c, c.Ref_Number_Pattern__c, c.Ref_Number_Message__c, c.Product_Interest__c, ' +
                    '(Select CS_Part__c, Type__c, Quantity__c From CS_Allowance_Part_Availabilities__r), ' +
                    '(Select CS_Discount_Category__c, CS_Discount_Category_Name__c , CS_Discount_Category__r.Name, Type__c, Quantity__c From CS_Allowance_Category_Availabilities__r), ' +
                    '(Select Name, District__c, District_Name__c, District_Code__c, District__r.Name, District__r.Code__c From CS_Allowance_Availabilities__r), ' +
                    '(Select Group__c, Group_Name__c, Group__r.Name From CS_Allowance_Empl_Group_Availabilities__r), '+
                    '(Select Parent_Allowance__c From CS_Parent_Allowances__r) '+
                    'From CS_Allowance__c c ' +
                    'Where ((c.Minimum_Threshold__c = null) OR (c.Minimum_Threshold__c <= :grossPrice)) ' +
                    'AND ((c.Start_Date__c = null) OR (c.Start_Date__c <= TODAY)) ' +
                    'AND ((c.End_Date__c = null) OR (c.End_Date__c >= TODAY)) ' +
                    'AND ((c.Expiry_Date__c = null) OR (c.Expiry_Date__c >= :leadCreationDate)) ' + 
                    'AND ((c.Minimum_Age__c = null) OR (c.Minimum_Age__c <= :customerAge)) ' +
                    'AND (c.Valid_Product_Types__c includes(:productType)) ';
                    
        if((voucherNo == null) || (voucherNo == '')) allowancesQuery += 'AND (c.Requires_Voucher_ID__c = false) ';
        if((employeeId == null) || (employeeId == '')) allowancesQuery += 'AND (c.Requires_Employee_ID__c = false) ';
          
        system.debug('**** Allowances query: ' + allowancesQuery);  
        system.debug('**** Params are: ' + productType + '-' + grossPrice+ '-' + customerAge+ '-' + leadCreation+ '-' + voucherNo+ '-' + employeeId + '-' + productInterest);
          
        List<CS_Allowance__c> fetchedAllowances = ((List<CS_Allowance__c>)database.query(allowancesQuery ));

		//filter the allowances that either have blank Product Interests
		//or their Product Interests contain the one on Opportunity
		List<CS_Allowance__c> allowancesByProductInterest = new List<CS_Allowance__c>();
		for (Integer i = 0; i < fetchedAllowances.size(); i++) {
			CS_Allowance__c allowance = fetchedAllowances[i];
			if (String.isBlank(allowance.Product_Interest__c)){
				allowancesByProductInterest.add(allowance);
			} else {
				if (allowance.Product_Interest__c.containsIgnoreCase(productInterest)){
					allowancesByProductInterest.add(allowance);
				}
			}
		}
                              
        //return fetchedAllowances;
		return allowancesByProductInterest;
    }
    
    // ###############################################################
    // # THIS IS A TEMPORARY METHOD (getAssignedToEmployeeGroups)    #
    // # WHICH SHOULD BE REMOVED AS IT WILL NOT BE USED AFTER        #
    // # THE STATIC RESOURCE CS_ALLOWANCES IS DEPLOYED TO PRODUCTION #
    // ###############################################################
    @RemoteAction
    public static List<String> getAssignedToEmployeeGroups(Id assignedToEmployee) {
    
        Employee__c employee = [Select e.Id, (Select Group__r.Name From Employee_Groups__r) From Employee__c e Where e.Id = :assignedToEmployee];
        Set<String> assignedEmployeeGroups = new Set<String>();
        for(Employee_Group__c grp : employee.Employee_Groups__r){
            assignedEmployeeGroups.add(grp.Group__r.Name);
        }
        
        return new List<String>(assignedEmployeeGroups);
    }
    
    @RemoteAction
    public static Map<String, List<String>> getAssignedToEmployeeGroupsAndId() {
        
        String userId = UserInfo.getUserId();
        
        List<Employee__c> employeeList = [Select e.Id, e.Salesforce_User__c, 
                        (Select Group__r.Name From Employee_Groups__r) 
                        From Employee__c e 
                        Where e.Salesforce_User__c = :userId limit 1];
        
        Set<String> assignedEmployeeGroups = new Set<String>();
        List<String> employeeIdList = new List<String>();
        If(employeeList.size() > 0) { 
            Employee__c employee = employeeList.get(0);
            employeeIdList.add(employee.Id);
            for(Employee_Group__c grp : employee.Employee_Groups__r){
                assignedEmployeeGroups.add(grp.Group__r.Name);
            }
        }
        
        //a map containing an employee id and employee groups
        Map<String, List<String>> employeeMap = new Map<String, List<String>>();
        employeeMap.put('employeeId', employeeIdList);
        employeeMap.put('employeeGroups', new List<String>(assignedEmployeeGroups));
        
        return employeeMap;
    }
    
    
    @RemoteAction
    public static CS_Allowance__c getAllowance (Id allowanceId) {
        String allowancesQuery = 'SELECT ' + CS_SObjectHelper.getFieldListForSOQL('CS_Allowance__c') + ' FROM CS_Allowance__c WHERE Id = :allowanceId LIMIT 1';
        CS_Allowance__c allowance = ((CS_Allowance__c)database.query(allowancesQuery));
        return allowance;
    }
    
    
    @RemoteAction
    public static List<CS_Allowance_Part_Availability__c> getAllowancePartAvailabilities(Id allowanceId) {
        List<CS_Allowance_Part_Availability__c> records = [select CS_Part__c, Quantity__c, Type__c from CS_Allowance_Part_Availability__c where CS_Allowance__c = :allowanceId];
        
        return records;
    }
    
    @RemoteAction
    public static List<CS_Allowance_Category_Availability__c > getAllowanceCategoryAvailabilities(Id allowanceId) {
        List<CS_Allowance_Category_Availability__c> records = [select CS_Discount_Category__c, CS_Discount_Category_Name__c, CS_Discount_Category__r.Name, Quantity__c, Type__c from CS_Allowance_Category_Availability__c where CS_Allowance__c = :allowanceId];
        
        return records;
    }
    
    @RemoteAction
    public static Appointment__c getHeaderData(Id appointmentId){
        return [Select Id, Assigned_To_Name__c, CHI_Lead_No__c, 
            Opportunity__r.Install_Address_Street__c, Opportunity__r.Install_Postcode__c, Opportunity__r.SC_Home_Phone__c, Opportunity__r.SC_Mobile_Phone__c, 
            Opportunity__r.Account.Id, Opportunity__r.Account.Primary_Contact__c, Opportunity__r.Account.Primary_Contact__r.Salutation, Opportunity__r.Account.Primary_Contact__r.Name, Opportunity__r.Account.Primary_Contact__r.MailingStreet,
            Opportunity__r.Account.Primary_Contact__r.MailingCity, Opportunity__r.Account.Primary_Contact__r.MailingPostalCode, Opportunity__r.Account.Primary_Contact__r.Best_Phone__c,
            Opportunity__r.Account.Primary_Contact__r.MobilePhone 
            from Appointment__c where Id = :appointmentId];
    } 
    
    @RemoteAction
    public static List<CS_Template_Section_Header__c> getAllSections(){       
        String sectionQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Template_Section_Header__c') + 
        ' From CS_Template_Section_Header__c';
        List<CS_Template_Section_Header__c> fetchedSections = ((List<CS_Template_Section_Header__c>)database.query(sectionQuery));                  

        return fetchedSections;
    }  
    
    @RemoteAction
    public static List<CS_Template_Section_Header__c> getSequenceNumbers(List<String> sectionIds){       
        String sectionQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Template_Section_Header__c') + 
        ' From CS_Template_Section_Header__c Where Id in '+ CS_SObjectHelper.convertIdListToSoqlInListString(new List<String> (sectionIds));
        List<CS_Template_Section_Header__c> fetchedSections = ((List<CS_Template_Section_Header__c>)database.query(sectionQuery));                  

        return fetchedSections;
    }  
    
    @RemoteAction
    public static String updateAsbestosDetails(Id accountId) {
        try {
            Account a = [SELECT Id, Name, Asbestos_Found__c, Asbestos_Found_Date_New__c FROM Account WHERE Id = :accountId limit 1];
            a.Asbestos_found__c = 'Yes';
            a.Asbestos_Found_Date_New__c = Date.today();
            update a;
        } catch (Exception e) {
            return e.getMessage();
        }
        return 'Account updated successfully.';
    }    
    
    static List<sObject> insertConfigs(Map<String, List<sObject>> configMap, Map<String, String> dependencies) {
        Set<String> keys = findNonDependentKeys(dependencies);
        List<sObject> ctoi = new List<sObject>();
        System.debug(LoggingLevel.INFO, 'Free keys: ' + keys);
        for (String key : keys) {
            for (sObject so : configMap.get(key)) {
                String soKey = (String) so.get('cscfga__Key__c');
                System.debug(LoggingLevel.INFO, 'Adding for insert: ' + soKey);
                if (so.get('Id') == null) {
                    ctoi.add(so);
                }
                dependencies.remove(soKey);
            }
        }
        List<sObject> inserted = new List<sObject>();
        if (ctoi != null && ctoi.size() > 0 ) {
            insert ctoi;
            if (dependencies.keySet().size() > 0) {
                List<sObject> os = insertConfigs(configMap, dependencies);
                if (os != null && os.size() > 0) {
                    inserted.addAll(os);
                }
            }
        }
        if (ctoi == null) {
            ctoi = new List<sObject>();
        }
        ctoi.addAll(inserted);
        return ctoi;
    }
    
    static Set<String> findNonDependentKeys(Map<String, String> dependencies) {
        Set<String> free = new Set<String>();
        for (String key : dependencies.keySet()) {
            String dependency = dependencies.get(key);
            if (dependencies.get(dependency) == null) {
                free.add(dependency);
            }
        }
        if (free.isEmpty()) {
            System.debug(LoggingLevel.INFO, 'No free keys found in config dependencies');
        }
        return free;
    }
    
    private static List<Map<String, Object>> decodeList(Object l) {
        List<Map<String, Object>> lm = new List<Map<String, Object>>();
        for (Object o : (List<Object>) l) {
            lm.add((Map<String, Object>) o);
        }
        return lm;
    }
    
    private static List<sObject> mapsToSObjects(Type c, List<Map<String, Object>> ms) {
        List<sObject> os = new List<sObject>();
        for (Map<String, Object> m : ms) {
            os.add(mapToSObject(c, m));
        }
        return os;
    }
    
    private static sObject mapToSObject(Type c, Map<String, Object> m) {
        return (sObject) JSON.deserialize(JSON.serialize(m), c);
    }
    
    public static Map<String, ConfigurationNode> getConfigurationData(Id id) {
        System.debug(LoggingLevel.INFO, 'getConfigurationData: ' + id);

        Map<String, ConfigurationNode> nodes = new Map<String, ConfigurationNode>();
        Map<String, ConfigurationNode> index = new Map<String, ConfigurationNode>();

        Map<String, cscfga__Product_Configuration__c> configMap = loadConfigurations(id);
        Map<Id, List<cscfga__Attribute__c>> attMap = loadAttributesForConfigIds(configMap.keySet());
        Map<Id, List<cscfga__Attribute_Field__c>> attFieldMap = loadAttributeFieldsForConfigIds(configMap.keySet());

        Map<String, ConfigurationNode> configData = new Map<String, ConfigurationNode>();
        configData.putAll(addConfiguration('', 0, id, configMap, attMap, attFieldMap));

        return configData;
    }

    static Map<String, ConfigurationNode> addConfiguration( String currentRefBase,
                                                            Integer index,
                                                            String idOrKey,
                                                            Map<String, cscfga__Product_Configuration__c> configMap,
                                                            Map<Id, List<cscfga__Attribute__c>> attMap,
                                                            Map<Id, List<cscfga__Attribute_Field__c>> attFieldMap) {

        cscfga__Product_Configuration__c config = configMap.get(idOrKey);
        Map<String, ConfigurationNode> configData = new Map<String, ConfigurationNode>();
        String currentRef = currentRefBase != '' ? currentRefBase + '_' + index : '';
        ConfigurationNode configNode = new ConfigurationNode(currentRef).setConfig(config);
        configData.put(configNode.reference, configNode);

        //TEMP
        System.debug(LoggingLevel.WARN, 'In addConfiguration: ' + idOrKey + ', config id: ' + config.Id + ' / ' + currentRefBase + ':' + index);
        Map<String, String> configIds = new Map<String, String>();
        for (String k : configMap.keySet()) {
            configIds.put(k, configMap.get(k).Id);
        }
        System.debug(LoggingLevel.WARN, 'Config keys/ids: ' + configIds);

        List<cscfga__Attribute__c> atts = attMap.get(config.Id);
        
        //TEMP
        List<String> attNames = new List<String>();
        for (cscfga__Attribute__c a : atts) {
            attNames.add(a.Name);
        }
        System.debug(LoggingLevel.WARN, 'Attributes for ' + idOrKey + ': ' + attNames);
        
        for (cscfga__Attribute__c att : atts) {
            String refBase = currentRef + (currentRef != '' ? ':' : '') + makeRefSafe(att.Name);
            String ref = refBase + '_0';

            if (att.cscfga__Attribute_Definition__r.cscfga__Type__c == cscfga.Attribute.RELATED_PRODUCT) {
                List<String> relatedIds = (att.cscfga__Value__c == null || att.cscfga__Value__c == '') ? new List<String>() : att.cscfga__Value__c.split(',');
                for (Integer i = 0; i < relatedIds.size(); i++) {
                    //TEMP - revert WARN level
                    System.debug(LoggingLevel.WARN, 'Adding related product for attr ' + att.Name + ' : ' + relatedIds[i]);
                    configData.putAll(addConfiguration(refBase, i, relatedIds[i], configMap, attMap, attFieldMap));
                }
            }

            ConfigurationNode node = configData.get(ref);
            if (node == null) {
                node = new ConfigurationNode(ref);
                configData.put(ref, node);
            }
            node.setAttribute(att, attFieldMap.get(att.Id), att.cscfga__Attribute_Definition__r.cscfga__Type__c, configMap);
        }

        return configData;
    }

    static Map<String, cscfga__Product_Configuration__c> loadConfigurations(Id id) {
        Map<String, cscfga__Product_Configuration__c> configs = new Map<String, cscfga__Product_Configuration__c>([
            SELECT  Id,
                    CreatedByid,
                    CreatedDate,
                    LastModifiedById,
                    LastModifiedDate,
                    OwnerId,
                    Name,
                    cscfga__product_basket__c,
                    cscfga__last_screen_index__c,
                    cscfga__screen_flow__c,
                    cscfga__one_off_charge__c,
                    cscfga__key__c,
                    cscfga__configuration_offer__c,
                    cscfga__recurrence_frequency__c,
                    cscfga__billing_frequency__c,
                    cscfga__configuration_status__c,
                    cscfga__root_configuration__c,
                    cscfga__user_session__c,
                    cscfga__validation_message__c,
                    cscfga__contract_term_period_description__c,
                    cscfga__total_price__c,
                    cscfga__attribute_name__c,
                    cscfga__recurring_charge__c,
                    cscfga__index__c,
                    cscfga__contract_term__c,
                    cscfga__description__c,
                    cscfga__unit_price__c,
                    cscfga__contract_term_period__c,
                    cscfga__quantity__c,
                    cscfga__entry_date__c,
                    cscfga__product_definition__c,
                    cscfga__serial_number__c,
                    cscfga__parent_configuration__c
            FROM    cscfga__Product_Configuration__c
            WHERE   Id = :id
               OR   cscfga__Root_Configuration__c = :id
        ]);

        List<cscfga__Product_Configuration__c> configList = configs.values();

        for (cscfga__Product_Configuration__c config : configs.values()) {
            if (config.cscfga__Key__c != null) {
                configs.put(config.cscfga__Key__c, config);
            }
        }

        return configs;
    }

    static Map<Id, List<cscfga__Attribute__c>> loadAttributesForConfigIds(Set<String> ids) {
        List<cscfga__Attribute__c> atts = [
            SELECT  Id,
                    CreatedByid,
                    CreatedDate,
                    LastModifiedById,
                    LastModifiedDate,
                    Name,
                    cscfga__Annualised_Price__c,
                    cscfga__Attribute_Definition__c,
                    cscfga__Billing_Price__c,
                    cscfga__Cascade_Value__c,
                    cscfga__Display_Value__c,
                    cscfga__Hidden__c,
                    cscfga__Is_Active__c,
                    cscfga__Is_Line_Item__c,
                    cscfga__Is_Read_Only__c,
                    cscfga__Is_Required__c,
                    cscfga__Key__c,
                    cscfga__Line_Item_Description__c,
                    cscfga__Line_Item_Sequence__c,
                    cscfga__Price__c,
                    cscfga__Product_Configuration__c,
                    cscfga__Recurring__c,
                    cscfga__Value__c,
                    cscfga__Attribute_Definition__r.cscfga__Type__c,
                    cscfga__Attribute_Definition__r.cscfga__Lookup_Config__c,
                    cscfga__Attribute_Definition__r.cscfga__Lookup_Config__r.cscfga__Search_Columns__c
            FROM    cscfga__Attribute__c
            WHERE   cscfga__Product_Configuration__c IN :ids
        ];

        Map<Id, List<cscfga__Attribute__c>> attsByConfig = new Map<Id, List <cscfga__Attribute__c>>();
        for (cscfga__Attribute__c att : atts) {
            List<cscfga__Attribute__c> attList = attsByConfig.get(att.cscfga__Product_Configuration__c);
            if (attList == null) {
                attList = new List<cscfga__Attribute__c>();
                attsByConfig.put(att.cscfga__Product_Configuration__c, attList);
            }
            if (att.cscfga__Value__c == null) {
                att.cscfga__Value__c = '';
            }
            attList.add(att);
        }

        return attsByConfig;
    }

    static Map<Id, List<cscfga__Attribute_Field__c>> loadAttributeFieldsForConfigIds(Set<String> ids) {

        List<cscfga__Attribute_Field__c> afs = [
            SELECT  Id,
                    CreatedById,
                    CreatedDate,
                    LastModifiedById,
                    LastModifiedDate,
                    Name,
                    cscfga__Attribute__c,
                    cscfga__Value__c
            FROM    cscfga__Attribute_Field__c
            WHERE   cscfga__Attribute__c
               IN   (SELECT id
                     FROM cscfga__Attribute__c
                     WHERE cscfga__Product_Configuration__c = :ids)
        ];

        Map<Id, List<cscfga__Attribute_Field__c>> attFieldsByAttribute = new Map<Id, List<cscfga__Attribute_Field__c>>();

        for (cscfga__Attribute_Field__c field : afs) {
            List<cscfga__Attribute_Field__c> fieldList = attFieldsByAttribute.get(field.cscfga__Attribute__c);
            if (fieldList == null) {
                fieldList = new List<cscfga__Attribute_Field__c>();
                attFieldsByAttribute.put(field.cscfga__Attribute__c, fieldList);
            }
            fieldList.add(field);
        }

        return attFieldsByAttribute;
    }

    static String makeRefSafe(String s) {
        return s.replaceAll('[\\s\\|]', '_').replaceAll('[\'"]', '');
    }

    public static List<cscfga__Product_Configuration__c> mapToProductConfigurations(List<sObject> sos) {
        List<cscfga__Product_Configuration__c> configs = new List<cscfga__Product_Configuration__c>();
        for (sObject so : sos) {
            cscfga__Product_Configuration__c config = (cscfga__Product_Configuration__c) so;
            configs.add(config);
        }
        return configs;
    }

    public static List<cscfga__Attribute__c> mapToAttributes(List<sObject> sos) {
        List<cscfga__Attribute__c> configs = new List<cscfga__Attribute__c>();
        for (sObject so : sos) {
            cscfga__Attribute__c config = (cscfga__Attribute__c) so;
            configs.add(config);
        }
        return configs;
    }

    static String getTextAttachment(Id parentId, String name) {
        List<Attachment> atts = [SELECT Body FROM Attachment WHERE ParentId = :parentId AND Name = :name];
        if (atts.size() == 0) {
            throw new cscfga.ConfiguratorException('No ' + name + ' attachment found for ParentId ' + parentId);
        }

        return atts[0].Body.toString();
    }
    
    // Start - Fawzi Fares: 11-04-2014
    @RemoteAction
    public static Map<String,Map<String,Object>> loadLookupRecord(LookupAttribute lookupAttribute) {
        //
        String objectMappingId = lookupAttribute.attributeObjectMappingId;
        // Get coliumns declared in this object mapping
        cscfga__Object_Mapping__c objectMapping = [select Id, cscfga__From_Type__c, 
                                                   (select Id, cscfga__From_Field__c from cscfga__Field_Mappings__r order by cscfga__From_Field__c) 
                                                   from cscfga__Object_Mapping__c where id = :objectMappingId];
        // Form a column list to select
        String colString = objectMapping.cscfga__Field_Mappings__r[0].cscfga__From_Field__c;
        Set<string> columnSet = new Set<String>();
        columnSet.add(objectMapping.cscfga__Field_Mappings__r[0].cscfga__From_Field__c);
        for (Integer i = 1; i < objectMapping.cscfga__Field_Mappings__r.size(); i++) {
            colString += ',' + objectMapping.cscfga__Field_Mappings__r[i].cscfga__From_Field__c;
            columnSet.add(objectMapping.cscfga__Field_Mappings__r[i].cscfga__From_Field__c);
        }
        //
        String queryString = 'select '+colString+
                             ' from '+objectMapping.cscfga__From_Type__c+
                             ' where id = \''+lookupAttribute.attributeValue+'\'';
        list<sObject> lookedUpRecordList = Database.query(queryString);
        //
        Map<String,Map<String,Object>> recordDataMap = new Map<String,Map<String,Object>>();
        for (sObject rec : lookedUpRecordList) {
            Map<String,Object> recordData = new Map<String,Object>();
            for (String col : colString.split(',')) {
                recordData.put(col.toLowerCase(),rec.get(col));
            }
            recordDataMap.put(lookupAttribute.attributeValue,recordData);
        }
        //
        recordDataMap.put('columnMap',getSobjectFieldMap(objectMapping.cscfga__From_Type__c,columnSet));
        //
        return recordDataMap;
    }
    
    // Get a comma separated SObject Field list 
    public static Map<String,String> getSobjectFieldMap(String so, Set<String> colSet) {
        Map<String,String> fieldMap = new Map<String,String>();
   
        SObjectType sot = Schema.getGlobalDescribe().get(so);
        if (sot == null) return null;
   
        List<Schema.SObjectField> fields = sot.getDescribe().fields.getMap().values();
       
        for (Integer i = 0; i < fields.size(); i++) {
            String fieldName = fields[i].getDescribe().LocalName;
            String fieldLabel = fields[i].getDescribe().Label;
            if (colSet.contains(fieldName)) {
                fieldMap.put(fieldLabel,fieldName.toLowerCase());
            }
        }
        return fieldMap;
    }
    
    public class LookupAttribute {
        String attributeId;
        String attributeValue;
        String attributeDefinitionId;
        String attributeLookupConfigId;
        String attributeObjectMappingId;
    }
    // End - Fawzi Fares: 11-04-2014
                
    @RemoteAction
    public static String AttachPdfReturnId(Id id, String name, String content) {
        system.debug(content);
        Attachment att;
        
        List<Attachment> attList = [Select Id, Name, Body, ParentId from Attachment where ParentId = :id and Name = :name];
        if(attList.size() > 0) {
            att = attList[0];
        } else {
            att = new Attachment();
            att.ParentId = id;
        }
        att.Body = EncodingUtil.base64Decode(content);
        att.Name = name;
        att.ContentType = 'application/pdf';
        upsert att;
    
        system.debug('*** attachment id ***' + att.Id);
    
        return att.Id;
    }
    
    @RemoteAction
    public static String AttachTempFileReturnId(Id id, String name, String content) {
        system.debug(content);
        
        Attachment att;
        
        List<Attachment> attList = [Select Id, Name, Body, ParentId from Attachment where ParentId = :id and Name = :name];
        if(attList.size() > 0) {
            att = attList[0];
        } else {
            att = new Attachment();
            att.ParentId = id;
        }
        att.Body = EncodingUtil.base64Decode(content);
        att.Name = name;
        att.ContentType = 'text/plain';
        upsert att;
    
        system.debug('*** New attachment id ***' + att.Id);
    
        return att.Id;
    }
    
    
    @RemoteAction
    public static void SaveInstallationNotesPdf(string attId,string appId,string oppId,string quoteRef,string logoType,Boolean quoteAccepted, string basketId, string configId)
    {
        String installationNotesName = '%' + CS_Constants.InstallationNotesPDF + '%';
        List<Attachment> attList = [Select id from Attachment where ParentId = : oppId and (Name Like '%Installation Notes.pdf' or Name Like :installationNotesName)];
        
        if(attList.size()>0 && quoteAccepted){
            delete attList;
        }
         
        PageReference installationNotesPDF = new PageReference('/apex/CSInstallationNotes?attId='+ attId+'&appId='+appId+'&oppId='+oppId+'&quoteRef='+quoteRef+'&logoType='+logoType);
        string name = [select CHI_Lead_Id__c from opportunity where Id = :oppId].CHI_Lead_Id__c;
        Blob body ;
            
        if (Test.isRunningTest()) {
            body = Blob.valueOf('@Test PDF data install notes');
        } else {
            body=installationNotesPDF.getContent();
        }

        System.debug('*** Basket id = ' + basketId);

        // 2019-01-28, according to BG's request shared by Ashok, two different naming conventions
        string attNameOpp = 'C' + name + ' - Installation Notes.pdf';
        string attNameBasket = CS_Constants.InstallationNotesPDF + 'C' + name + '.pdf';

        List<Attachment> newAttachmentsList = new List<Attachment>();
        
        // accepted quotes on Opp (but handled in CS_AllAttachmentTriggerHelper)
        /*
        if (quoteAccepted) {
            Attachment attachment = new Attachment();
            attachment.Body = body;
            attachment.Name = attNameOpp;
            attachment.ParentId = oppId; 
            newAttachmentsList.add(attachment);
        }
        */

        if (basketId != '') {
            Attachment attachment2 = new Attachment();
            attachment2.Body = body;
            attachment2.Name = attNameBasket;
            attachment2.ParentId = basketId; 
            newAttachmentsList.add(attachment2);
        }

        // do not attach it on product configurations, issues with CSA download
        /*
        if (configId != '' && !quoteAccepted) {
            Attachment attachment3 = new Attachment();
            attachment3.Body = body;
            attachment3.Name = attNameBasket;
            attachment3.ParentId = configId; 
            newAttachmentsList.add(attachment3);
        }
        */

        if (newAttachmentsList.size() > 0) {
            insert newAttachmentsList;
        }
    }
     @RemoteAction
    public static void SaveNewOnlineQuotePdf(string attId,string appId,string oppId,string quoteRef,string logoType)
    {
        List<Attachment> attList = [Select id from Attachment where ParentId = : oppId and Name Like '%New Online Quote.pdf'];
        
        if(attList.size()>0)
        {
            delete attList;
        }
         
        PageReference installationNotesPDF = new PageReference('/apex/CSQuoteOnline?attId='+ attId+'&appId='+appId+'&oppId='+oppId+'&quoteRef='+quoteRef+'&logoType='+logoType);
        string name = [select CHI_Lead_Id__c from opportunity where Id = :oppId].CHI_Lead_Id__c;
        Blob body ;
            
        if (Test.isRunningTest()) {
            body = Blob.valueOf('@Test PDF data online quote');
        } else {          
            body=installationNotesPDF.getContent();
        }
            
        Attachment attachment = new Attachment();
        attachment.Body = body;
        attachment.Name ='C'+name+'New Online Quote.pdf';
        attachment.ParentId = oppId; 
        insert attachment;
    }
    @RemoteAction
    public static Boolean DeleteTempAttachment(Id id) {
        Boolean success = false;
        List<Attachment> attList = [Select Id from Attachment where Id = :id];
        
        if(attList.size() > 0) {
            try {
                success = true;
                delete attList;
            } catch (Exception e){
                success = false;
            }
        }        
        return success;
    }
    
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

    public static void setTriggersOn(Id UserId) {
        List<No_Triggers__c> noTriggerFlag = [Select SetupOwnerId, Name, Id, Flag__c From No_Triggers__c
                                              Where SetupOwnerId = :UserId Limit 1];
        if(noTriggerFlag.isEmpty() == false) {
            noTriggerFlag[0].Flag__c = false;
            update noTriggerFlag;
        }

    }
}