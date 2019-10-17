public without sharing class CS_ProductBasketController {

    public List<ConfigWrapper> allBasketItems {get; set;}
    public List<ConfigWrapper> allConfigAllowanceItems {get; set;}
        
    public Id basketId {get; set;}
    public Id appointmentId {get; set;}
    public Id opportunityId {get; set;}
    
    public cscfga__Product_Basket__c mybasket { get; set; }
    
    private final Set<String> allowanceAttributes = new Set<String> {'Allowance1', 'Allowance2', 'Allowance3', 'Allowance4', 'Allowance5', 'Allowance6'};
    
    public CS_ProductBasketController(ApexPages.StandardController c) {
        
        basketId = c.getRecord().Id;
        cscfga__Product_Basket__c basket = [select Id, Name, Appointment__c, Appointment__r.Opportunity__c 
                                                from cscfga__Product_Basket__c 
                                                where Id = :basketId];
                                                
        appointmentId = basket.Appointment__c;
        opportunityId = basket.Appointment__r.Opportunity__c;
                
        Map<Id, cscfga__Product_Configuration__c> configs = new Map<Id, cscfga__Product_Configuration__c> ([select Id, Name, cscfga__Parent_Configuration__c, cscfga__Product_Basket__r.cscfga__Basket_Status__c, cscfga__Product_Definition__c, cscfga__Configuration_Status__c
                                                                                                                    from cscfga__Product_Configuration__c 
                                                                                                                    where cscfga__Product_Basket__c = :basketId
                                                                                                                    and cscfga__Parent_Configuration__c = null]);
                                                                                                                    
        //get all attributes and attribute fields
        List<cscfga__Attribute__c> allAttributes = [select  cscfga__Annualised_Price__c, 
                                                            cscfga__Attribute_Definition__c, 
                                                            cscfga__Billing_Price__c, 
                                                            cscfga__Cascade_value__c, 
                                                            cscfga__Discount_Amount__c, 
                                                            cscfga__Discount_Type__c, 
                                                            cscfga__Display_Value__c, 
                                                            cscfga__Hidden__c, 
                                                            cscfga__Is_Line_Item__c, 
                                                            cscfga__Is_rate_line_item__c, 
                                                            cscfga__Is_Read_Only__c, 
                                                            cscfga__Is_Required__c, 
                                                            cscfga__is_active__c, 
                                                            cscfga__Key__c, 
                                                            cscfga__Line_Item_Description__c, 
                                                            cscfga__Line_Item_Sequence__c, 
                                                            cscfga__List_Price__c, 
                                                            Name, 
                                                            cscfga__Attribute_Definition__r.Name,
                                                            cscfga__Price__c, 
                                                            cscfga__Product_Configuration__c, 
                                                            Id, 
                                                            cscfga__Recurring__c, 
                                                            cscfga__Value__c,
                                                            (select     cscfga__Attribute__c, 
                                                                        Name, 
                                                                        Id, 
                                                                        cscfga__Value__c
                                                            from cscfga__Attribute_Fields__r)
                                                    from cscfga__Attribute__c 
                                                    where cscfga__Product_Configuration__r.cscfga__Product_Basket__c = : basket.Id];


        //AaJSON
        Set<Id> pConfigsAllIds = (new Map<Id,cscfga__Product_Configuration__c>(configs)).keySet();
        List<Id> pConfigsIdList = new List<Id>(pConfigsAllIds);
        Map<String,Object> configsData = cscfga.API_1.getProductConfigurations(pConfigsIdList); 


    
        //Change for JSON
        Map<Id, Map<String, cscfga__Attribute__c>> configAttributesMap = new Map<Id, Map<String, cscfga__Attribute__c>>(); //in case more than 1 configs are supported per basket in the future
        
        for (cscfga__Attribute__c att : allAttributes) {
            if (!configAttributesMap.containsKey(att.cscfga__Product_Configuration__c)) {
                configAttributesMap.put(att.cscfga__Product_Configuration__c, new Map<String, cscfga__Attribute__c> {att.Name => att});
            }
            else {
                configAttributesMap.get(att.cscfga__Product_Configuration__c).put(att.Name, att);
            }
        }

        //aAJSON required filter - partsModel.txt
        List<Attachment> attachmentList = [SELECT Id, Name, Body, ParentId FROM Attachment where ParentId in :configs.keySet() and Name='partsModel.txt'];
        
        allBasketItems = new List<ConfigWrapper> ();
        allConfigAllowanceItems  = new List<ConfigWrapper> ();
                
        Map<Id, Attachment> configAttachmentMap = new Map<Id, Attachment>();
        
        for (Attachment doc : attachmentList) {
            configAttachmentMap.put(doc.ParentId, doc);
        }
        //System.debug('******* There are ' + configs.size() + ' configurations');
        for (Id configId : configs.keySet()) {
            List<cscfga__Attribute__c> allowanceAttributeList = getAllowanceAttributesForConfig(configId, configsData);
            allBasketItems.add(new ConfigWrapper(configs.get(configId),  configAttachmentMap.get(configId), allowanceAttributeList, configsData));
        }
        
        mybasket = basket;
    }
    
    private List<cscfga__Attribute__c> getAllowanceAttributesForConfig(Id configId, Map<String, Object> configsData) {
        
        List<cscfga__Attribute__c> allowanceAttributesForConfig = new List<cscfga__Attribute__c>();
        List<cscfga__Attribute__c> configAttributeList = (List<cscfga__Attribute__c>)configsData.get(configId +'-attributes');
        //System.debug('******* There are in total ' + configAttributeList.size() + ' attributes for config with ID: ' + configId);

        
        for (cscfga__Attribute__c att : configAttributeList) {
            if (allowanceAttributes.contains(att.Name)) {
                //System.debug('******** Found allowance attribute: ' + att);
                allowanceAttributesForConfig.add(att);
            }
        }
        //System.debug('******* Of which ' + allowanceAttributesForConfig.size() + ' of them are allowances');
        
        return allowanceAttributesForConfig;
    }
    
   
    public class ConfigWrapper {
        public cscfga__Product_Configuration__c config {get; set;}
        public List<LineItemWrapper> lineItemList {get; set;}
        public List<LineItemWrapper> allowanceItemList {get; set;}
        public Decimal totalNetPrice {get; set;}
        public Decimal totalPriceInclVAT {get; set;}
        
        public Decimal totalDiscounts {get; set;}
        public Decimal totalPayable {get; set;} //includes Allowances
        
        public Boolean canBeEdited {get 
            {
                if (config != null) {
                    //2016 added if
                    //if(config.cscfga__Parent_Configuration__c == null){
                        return config.cscfga__Configuration_Status__c == CS_Constants.ProductConfiguration_ClonedStatus;
                    /*
                    }
                    else{
                        return true;
                    }
                    */
                }
                return false;
            }
        }
        
        public ConfigWrapper(cscfga__Product_Configuration__c c, Attachment doc, List<cscfga__Attribute__c> allowanceAttributes, Map<String,Object> configsData) {
            config = c;
            lineItemList = new List<LineItemWrapper>();
            allowanceItemList = new List<LineItemWrapper>(); 

            totalPriceInclVAT = 0;
            totalDiscounts = 0;
            
            //Construct Allowance Line Items
            for (cscfga__Attribute__c allowanceAtt : allowanceAttributes) {
                if (allowanceAtt.cscfga__Value__c != null && allowanceAtt.cscfga__Value__c != '') {
                    String isApplied = 'FALSE';
                    String allowanceName;
                    Decimal allowanceActualValue;

                    List<cscfga__Attribute_Field__c> attributeFields = 
                        (List<cscfga__Attribute_Field__c>)configsData.get(c.Id + '-' + allowanceAtt.cscfga__Attribute_Definition__c + '-attributeFields');
                    
                    for (cscfga__Attribute_Field__c af : attributeFields) {

                            if (af.Name == 'AllowanceName') {
                                allowanceName = af.cscfga__Value__c;
                            }
                            else if (af.Name == 'ActualAmount') {
                                allowanceActualValue = Decimal.valueOf(af.cscfga__Value__c);
                            } 
                            else if (af.Name == 'Is_Applied'){
                                isApplied = af.cscfga__Value__c;
                            }
                       
                    }
                    
                    if(isApplied == 'TRUE'){
                        totalDiscounts += allowanceActualValue;
                    
                        LineItemWrapper li = new LineItemWrapper(allowanceName, allowanceName, 1, allowanceActualValue, allowanceActualValue); //DO NOT DISPLAY NET FOR ALLOWANCES
                        allowanceItemList.add(li);
                    }         
                }
            }
            
            //Construct Priced Line items
            if (doc != null) {
                try {
                    Map<String, CS_PartModelEntry> partsModel = (Map<String, CS_PartModelEntry>)JSON.deserialize(doc.Body.toString(), Map<String, CS_PartModelEntry>.class); 
                    
                    buildLineItems(partsModel);
                }
                catch (Exception e) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                    ApexPages.addMessage(myMsg);
                }
                
                calculateTotals();
            }
            
            totalPayable = totalPriceInclVAT - totalDiscounts;
        }
        
        private void buildLineItems(Map<String, CS_PartModelEntry> partsModel) {
            
            for (String key : partsModel.keySet()) {
                CS_PartModelEntry entry = partsModel.get(key);
                
                if (entry.isLineItem && entry.isPart && !entry.isMultilookup) {
                    //construct item for Parent Part
                    String description = String.isNotEmpty(entry.parentPart.part.Quote_Description__c) ? entry.parentPart.part.Quote_Description__c : (String.isNotEmpty(entry.parentPart.part.Description__c) ? entry.parentPart.part.Description__c : (String.isNotEmpty(entry.parentPart.part.Name) ? entry.parentPart.part.Name : ''));
                    LineItemWrapper li = new LineItemWrapper(entry.parentPart.part.Name, description, entry.parentPart.quantity, entry.aggregatedNetPrice, entry.aggregatedPriceInclVAT);
                    lineItemList.add(li);
                }
                else if (entry.isLineItem && entry.isBundle) {
                
                    //Only Bundles of type "Core Bundle", "Condensate" and "Flue" need to appear as 1 line in the pricing screen.
                    //All other bundles should not appear in the pricing screen, instead parts associated to it need to be listed.
                    String bundleType = entry.parentBundle.Type__c != null ? entry.parentBundle.Type__c : '';
                    if ((bundleType == 'Core Bundle') || (bundleType == 'Condensate') || (bundleType == 'Flue')) {
                        String description = String.isNotEmpty(entry.parentBundle.Quote_Description__c) ? entry.parentBundle.Quote_Description__c : (String.isNotEmpty(entry.parentBundle.Description__c) ? entry.parentBundle.Description__c : (String.isNotEmpty(entry.parentBundle.Name) ? entry.parentBundle.Name : ''));
                        LineItemWrapper li = new LineItemWrapper(entry.parentBundle.Name, description, entry.attLastQuantity, entry.aggregatedNetPrice, entry.aggregatedPriceInclVAT);
                        lineItemList.add(li);
                    } 
                    else {                     
                     for (CS_PartModelEntry.CS_PartInformation  associatedPart : entry.associatedParts) {
                        String description = String.isNotEmpty(associatedPart.part.Quote_Description__c) ? associatedPart.part.Quote_Description__c : (String.isNotEmpty(associatedPart.part.Description__c) ? associatedPart.part.Description__c : (String.isNotEmpty(associatedPart.part.Name) ? associatedPart.part.Name : ''));
                        LineItemWrapper li = new LineItemWrapper(associatedPart.part.Name, description, associatedPart.quantity, associatedPart.totalNetPrice, associatedPart.totalPriceIncVAT);
                        lineItemList.add(li);
                    }
                   }
                }
                else if (entry.isLineItem && entry.isPart && entry.isMultilookup) {
                    for (CS_PartModelEntry.CS_PartInformation pi : entry.associatedParts) {
                        String description = String.isNotEmpty(pi.part.Quote_Description__c) ? pi.part.Quote_Description__c : (String.isNotEmpty(pi.part.Description__c) ? pi.part.Description__c : (String.isNotEmpty(pi.part.Name) ? pi.part.Name : ''));
                        LineItemWrapper li = new LineItemWrapper(pi.part.Name, description, pi.quantity, pi.totalNetPrice, pi.totalPriceIncVAT);
                        lineItemList.add(li);
                    }
                }
            }
        }
        
        private void calculateTotals() {
            totalNetPrice = 0;
            totalPriceInclVAT = 0;
            
            if (lineItemList != null) {
                for (LineItemWrapper li : lineItemList) {
                    totalNetPrice += li.ItemTotalNetPrice;
                    totalPriceInclVAT += li.ItemTotalPriceInclVAT;
                }
            }
        
        }
         
    }
    
     public class LineItemWrapper {
    
        public String ItemName {get; set;}
        public String ItemDescription {get; set;}
        public Decimal ItemQuantity {get; set;}
        public Decimal ItemTotalNetPrice {get; set;}
        public Decimal ItemTotalPriceInclVAT {get; set;}
        
        public LineItemWrapper (String aName, String descr, Decimal qty, Decimal totalPrice, Decimal totalPriceWithVat) {
            this.ItemName = aName;
            this.ItemDescription = descr;
            this.ItemQuantity = qty;
            this.ItemTotalNetPrice = totalPrice;
            this.ItemTotalPriceInclVAT = totalPriceWithVat;
        }
    }
    
    private static String getUniqueKey() {
        return CS_GuidGenerator.NewGUID();
    }
    
    public PageReference cloneBasket() {
        
        cscfga__Product_Basket__c basket = mybasket;
        
        //Construct new Quote Reference
        String newQuoteReference = CS_QuoteReferenceGenerator.getNextQuoteReference(opportunityId);
        system.debug('***** newQuoteReference: ' + newQuoteReference);

        //get all product configurations from this basket
        List<cscfga__Product_Configuration__c> allProdConfigs = [select     cscfga__Attribute_Name__c,
                                                                        cscfga__Configuration_Offer__c, 
                                                                        cscfga__Configuration_Status__c, 
                                                                        cscfga__Contract_Term__c, 
                                                                        cscfga__Contract_Term_Period__c, 
                                                                        cscfga__Contract_Term_Period_Description__c, 
                                                                        cscfga__Description__c, 
                                                                        cscfga__Entry_Date__c, 
                                                                        cscfga__Index__c, 
                                                                        cscfga__Key__c, 
                                                                        cscfga__Last_Screen_Index__c, 
                                                                        cscfga__Billing_Frequency__c, 
                                                                        cscfga__Recurrence_Frequency__c, 
                                                                        Name, 
                                                                        cscfga__One_Off_Charge__c, 
                                                                        OwnerId, 
                                                                        cscfga__Parent_Configuration__c, 
                                                                        cscfga__Product_Basket__c, 
                                                                        cscfga__Product_Bundle__c, 
                                                                        cscfga__Product_Definition__c, 
                                                                        cscfga__Product_Family__c, 
                                                                        cscfga__Quantity__c, 
                                                                        Id, 
                                                                        cscfga__Recurring_Charge__c, 
                                                                        cscfga__Root_Configuration__c, 
                                                                        cscfga__Screen_Flow__c, 
                                                                        cscfga__Serial_Number__c, 
                                                                        cscfga__Total_Price__c, 
                                                                        cscfga__Unit_Price__c, 
                                                                        cscfga__User_Session__c, 
                                                                        cscfga__Validation_Message__c,
                                                                        CS_Cloned_Config_Id__c
                                                            from cscfga__Product_Configuration__c  
                                                            where cscfga__Product_Basket__c = : basket.Id];
        
                                                     
        //get all attributes and attribute fields
        List<cscfga__Attribute__c> allAttributes = [select  cscfga__Annualised_Price__c, 
                                                            cscfga__Attribute_Definition__c, 
                                                            cscfga__Billing_Price__c, 
                                                            cscfga__Cascade_value__c, 
                                                            cscfga__Discount_Amount__c, 
                                                            cscfga__Discount_Type__c, 
                                                            cscfga__Display_Value__c, 
                                                            cscfga__Hidden__c, 
                                                            cscfga__Is_Line_Item__c, 
                                                            cscfga__Is_rate_line_item__c, 
                                                            cscfga__Is_Read_Only__c, 
                                                            cscfga__Is_Required__c, 
                                                            cscfga__is_active__c, 
                                                            cscfga__Key__c, 
                                                            cscfga__Line_Item_Description__c, 
                                                            cscfga__Line_Item_Sequence__c, 
                                                            cscfga__List_Price__c, 
                                                            Name, 
                                                            cscfga__Price__c, 
                                                            cscfga__Product_Configuration__c, 
                                                            Id, 
                                                            cscfga__Recurring__c, 
                                                            cscfga__Value__c,
                                                            (select     cscfga__Attribute__c, 
                                                                        Name, 
                                                                        Id, 
                                                                        cscfga__Value__c
                                                            from cscfga__Attribute_Fields__r)
                                                    from cscfga__Attribute__c 
                                                    where cscfga__Product_Configuration__r.cscfga__Product_Basket__c = : basket.Id];
                                
        // get all attachments
        List<Attachment> attachments = [select  Id, 
                                                Body, BodyLength, 
                                                ContentType, 
                                                Description, 
                                                Name, 
                                                OwnerId, 
                                                ParentId, 
                                                IsPrivate 
                                         from   Attachment 
                                         where ParentId in : allProdConfigs];
        
        //cloned basket
        cscfga__Product_Basket__c clonedBasket = basket.clone(false);
        clonedBasket.Name = newQuoteReference; // change the name of the cloned basket
        clonedBasket.OwnerId = UserInfo.getUserId();
        clonedBasket.Original_Basket__c = basket.Id;
        clonedBasket.CS_Quote_Status__c = '-- None --';
        
        insert clonedBasket;
        
        //cloned product configurations, attributes and attribute fields
        List <cscfga__Product_Configuration__c> clonedProdConfigs = new List<cscfga__Product_Configuration__c>();
        List <cscfga__Attribute__c> clonedAttributes = new List<cscfga__Attribute__c>(); 
        List <cscfga__Attribute_Field__c> clonedAttributeFields = new List<cscfga__Attribute_Field__c>();
        List <Attachment> clonedAttachments = new List<Attachment>();
        
        Map <Id, Id> oldIdToParentId = new Map <Id, Id>();
        Map <Id, Id> oldIdToRootId = new Map <Id, Id>();
        
        Map <cscfga__Attribute__c, Id> newAttrToOldId = new Map <cscfga__Attribute__c, Id>();
        //Map <cscfga__Attribute_Field__c, cscfga__Attribute__c> attrFieldToAttr = new Map <cscfga__Attribute_Field__c, cscfga__Attribute__c>();
        Map <Id, cscfga__Attribute__c> attrFieldToAttr = new Map <Id, cscfga__Attribute__c>(); //changed by Stjepan for T-35345
        
        Map <String, Id> keyToConfigId = new Map <String, Id>();
        Map <cscfga__Attribute__c, List<String>> newAttrToPCkeys = new Map <cscfga__Attribute__c, List<String>>();
        
        // iterate through all product configurations
        // create a map of (product configuration key, product configuration id)
        for (cscfga__Product_Configuration__c pc : allProdConfigs) {
            keyToConfigId.put(pc.cscfga__Key__c, pc.Id);
            system.debug('***** pc.cscfga__Key__c: ' + pc.cscfga__Key__c);
        }
        
        // iterate through all product configurations
        for (cscfga__Product_Configuration__c pc : allProdConfigs) {
            
            cscfga__Product_Configuration__c newPc = pc.clone (false); // clone the product configuration
            newPC.cscfga__Key__c = getUniqueKey();  // crete a new unique key for the product configuration
            newPc.cscfga__Product_Basket__c = clonedBasket.Id; // link the product configuration to the basket

            newPc.CS_Cloned_Config_Id__c = pc.Id;
            newPc.OwnerId = UserInfo.getUserId();
            //2016 - cloned
            //newPc.cscfga__Configuration_Status__c = CS_Constants.ProductConfiguration_ClonedStatus;
            
            newPc.cscfga__Configuration_Status__c = pc.cscfga__Configuration_Status__c;
            if (pc.cscfga__Parent_Configuration__c == null){
                newPc.cscfga__Configuration_Status__c = CS_Constants.ProductConfiguration_ClonedStatus;
            } 
            
            clonedProdConfigs.add(newPc);
   
            // if a parent configuration exists, create a map of(product configuration id, parent configuration id)
            if (pc.cscfga__Parent_Configuration__c != null) {
                oldIdToParentId.put(pc.Id, pc.cscfga__Parent_Configuration__c);
            }
            
            // if a root configuration exists, create a map of(product configuration id, root configuration id)
            if (pc.cscfga__Root_Configuration__c != null) {
                oldIdToRootId.put(pc.Id, pc.cscfga__Root_Configuration__c);
            }
          
            // iterate through all of the attributes
            for (cscfga__Attribute__c att: allAttributes) {
                // take only the attributes of the current product configuration
                if (att.cscfga__Product_Configuration__c == pc.id) {
                    
                    cscfga__Attribute__c newAtt = att.clone(false);
                    newAtt.cscfga__Key__c = getUniqueKey();
                    
                    //system.debug('***** newAtt.cscfga__Attribute_Definition__r.Name ' + newAtt.cscfga__Attribute_Definition__r.Name);
                    
                    if (newAtt.Name == CS_Constants.QuoteReferenceAttributeName) {
                        system.debug('***** Quote Reference Attribute found and set to: ' + newQuoteReference);
                        newAtt.cscfga__Value__c = newQuoteReference;
                    }
                    else if (newAtt.Name == 'Pdf Signed') {
                        newAtt.cscfga__Value__c = '0';
                    }
                    else if (newAtt.Name == 'Pdf Path') {
                        newAtt.cscfga__Value__c = '';
                    }
                    else if (newAtt.Name == 'Quote Status') {
                        newAtt.cscfga__Value__c = '--None--';
                    }
                    else if (newAtt.Name == 'Reason') {
                        newAtt.cscfga__Value__c = '--None--';
                    }
                    

                    // map attToKeys holds attributes and their values only if values contains cscfga__Key__c of some configuration (only if attribute definition is related product)
                    String s1 = newAtt.cscfga__Value__c;
                    if (s1 != null) {
                        Set<String> s1parts = new Set<String>(new List<String>(s1.split(',')));
                        for (String s : keyToConfigId.keySet()) {
                        
                            if (s1parts.Contains(s)) {
                                System.debug(LoggingLevel.INFO, '>>>> Attribute ' + att.Name + ' refers to config key: ' + s + ' (' + s1 + ')');
                                if (newAttrToPCkeys.containsKey(newAtt)) {
                                    List <String> list1 = newAttrToPCkeys.get(newAtt);
                                    list1.add(s);
                                    newAttrToPCkeys.put(newAtt, list1);
                                }
                                else {
                                    List <String> list1 = new List <String>();
                                    list1.add(s);
                                    newAttrToPCkeys.put(newAtt, list1);
                                }
                            }
                        }
                    }
                    
                    newAttrToOldId.put(newAtt, pc.Id);
                    clonedAttributes.add(newAtt);    
                    for (cscfga__Attribute_Field__c attF : att.cscfga__Attribute_Fields__r) {
                        
                        //cscfga__Attribute_Field__c newAttField = attF.clone(false);
                        cscfga__Attribute_Field__c newAttField = attF.clone(true); //changed by Stjepan for T-35345
                        //attrFieldToAttr.put(newAttField, newAtt);
                        attrFieldToAttr.put(newAttField.id, newAtt); //changed by Stjepan for T-35345
                        clonedAttributeFields.add(newAttField);
                        
                    }
                }
             }
             
             for (Attachment a : attachments) {
                if (a.ParentId == pc.Id) {
                    Attachment newAttachment = a.clone(false);
                    a.OwnerId = UserInfo.getUserId();
                    clonedAttachments.add(newAttachment);
                }
             }
        }

        if (clonedProdConfigs.size() > 0) {
            //insert of cloned product configurations + update of parent configurations
            insert clonedProdConfigs;
            
            Map<String, Id> oldToNewIds = new Map<String, Id>();
            Map<Id, cscfga__Product_Configuration__c> newIdToNewPrConf = new Map <Id, cscfga__Product_Configuration__c>();
            Map<Id, cscfga__Product_Configuration__c> toUpdate = new Map <Id, cscfga__Product_Configuration__c>();
            
            // iterate through all of the newly inserted product configurations
            // create a map of (old pc id, cloned pc id)
            // create a map of (new pc id, new pc)
            for (cscfga__Product_Configuration__c clonePC : clonedProdConfigs) {
                oldToNewIds.put(clonePC.CS_Cloned_Config_Id__c, clonePC.Id);
                newIdToNewPrConf.put(clonePC.Id, clonePC);
            }
            // iterate through all of the old pc ids
            for (Id idA : oldIdToParentId.keySet()) {
                String newParentId = oldToNewIds.get(oldIdToParentId.get(idA)); //id of parent configuration of new configuration
                cscfga__Product_Configuration__c newPCwithParent = newIdToNewPrConf.get(oldToNewIds.get(idA)); //new product configuration
                newPCwithParent.cscfga__Parent_Configuration__c = newParentId;
                toUpdate.put(newPCwithParent.Id, newPCwithParent);                  
            }
            for (Id idA : oldIdToRootId.keySet()) {
                String newRootId = oldToNewIds.get(oldIdToRootId.get(idA)); //id of root configuration of new configuration
                cscfga__Product_Configuration__c newPCwithRoot = newIdToNewPrConf.get(oldToNewIds.get(idA)); //new product configuration
                newPCwithRoot.cscfga__Root_Configuration__c = newRootId;
                toUpdate.put(newPCwithRoot.Id, newPCwithRoot);                  
            }
            
            if (toUpdate.size() > 0) {
                List<cscfga__Product_Configuration__c> listToUpdate = toUpdate.values();
                update listToUpdate;
            }
            //insert attributes and attribute fields
            if (clonedAttributes.size() > 0) { 
                for (cscfga__Attribute__c att : clonedAttributes) {
                    
                    String oldId = newAttrToOldId.get(att); 
                    System.debug(LoggingLevel.INFO, '>>> WORKING HERE !!!!!');
                    //setting the cscfga__Value__c to cscfga__Key__c of new related configuration(s)
                    if (newAttrToPCkeys.containsKey(att)) {
                        List<String> list1 = new List<String>(new Set<String>(newAttrToPCkeys.get(att)));
                        
                        System.debug(LoggingLevel.INFO, '>>> Mapping new keys in value for Attribute ' + att.Name + ': ' + list1);
                        att.cscfga__Value__c = newIdToNewPrConf.get(oldToNewIds.get(keyToConfigId.get(list1[0]))).cscfga__Key__c;
                        if (list1.size() > 1) {
                            for (integer i = 1; i < list1.size(); ++i) {
                                att.cscfga__Value__c += ',' + newIdToNewPrConf.get(oldToNewIds.get(keyToConfigId.get(list1[i]))).cscfga__Key__c;
                            }
                        }
                        
                    }
                    //2016 FIX
                    //split string of values
                    //if value is in keys - replace with new value
                    else {
                        List<String> oldIdStrings = new List<String>(oldToNewIds.keySet());
                        String relatedAttributeValue = att.cscfga__Value__c;
                        //System.debug(LoggingLevel.INFO, '****AN will replace following attribute value '+relatedAttributeValue);

                        String newValue = '';
                        if(relatedAttributeValue != null){
                            if(relatedAttributeValue.contains(',')){
                                System.debug(LoggingLevel.INFO, '****AN Replacing Multiple ');
                                for(String separateId : relatedAttributeValue.split(',')){
                                     if(oldToNewIds.containsKey(separateId)){
                                        newValue += oldToNewIds.get(separateId) +',';
                                        System.debug(LoggingLevel.INFO, '****AN FETCHED  '+newValue);
                                        System.debug(LoggingLevel.INFO, '****AN Replacing Multiple '+separateId +'  with '+oldToNewIds.get(separateId));
                                    }
                                }

                                if(newValue.length()>0){
                                    newValue.removeEnd(',');
                                    att.cscfga__Value__c = newValue;
                                    System.debug(LoggingLevel.INFO, '****AN SUCCESSFULLY REPLACED MULTIPLE  '+att.cscfga__Value__c);
                                }

                            }
                            else{
                                if(oldToNewIds.containsKey(relatedAttributeValue)){
                                    att.cscfga__Value__c = oldToNewIds.get(relatedAttributeValue);
                                    System.debug(LoggingLevel.INFO, '****AN Replacing Single'+relatedAttributeValue +'  with '+oldToNewIds.get(relatedAttributeValue));
                                }
                            }
                        }
                    }

                    att.cscfga__Product_Configuration__c = oldToNewIds.get(oldId);
                    
                }
                insert clonedAttributes;
             
                map <cscfga__Attribute__c, Id> newAttToAttId = new map <cscfga__Attribute__c, Id>();
                map <String, Id> oldAttIdToNew = new map <String, Id>();
                
                for (cscfga__Attribute__c cloneAtt : clonedAttributes) {
                    newAttToAttId.put(cloneAtt, cloneAtt.Id);
                    
                    System.debug(LoggingLevel.INFO, '****-- newAttID: ' +  cloneAtt + ' '+cloneAtt.Id);  
                }
                
                if (clonedAttributeFields.size() > 0) {
                    for (cscfga__Attribute_Field__c cloneAttField : clonedAttributeFields) {
                        //cloneAttField.cscfga__Attribute__c = newAttToAttId.get(attrFieldToAttr.get(cloneAttField)); 
                        cloneAttField.cscfga__Attribute__c = newAttToAttId.get(attrFieldToAttr.get(cloneAttField.id));  //changed by Stjepan for T-35345
                        cloneAttField.Id = null;           //added by Stjepan for T-35345
                    } 
                    insert clonedAttributeFields;
                }
            }
            
            //insert attachments
            
            for (Attachment a : clonedAttachments) {
                a.ParentId = oldToNewIds.get(a.ParentId);
                a.OwnerId = UserInfo.getUserId();
            }
            
            insert clonedAttachments;
            
        }
        
        PageReference pageRef = new PageReference('/' + clonedBasket.Id);
        return pageRef; 
    }
    
}