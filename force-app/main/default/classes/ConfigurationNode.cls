public with sharing class ConfigurationNode {
    
    public cscfga__Attribute__c attr;
    public cscfga__Product_Configuration__c config;
    public Id definitionId;
    public String reference;
    public String displayInfo;
    public List<cscfga__Product_Configuration__c> relatedProducts;
    public List<String> relatedProductIds;
    public Map<String, cscfga__Attribute_Field__c> attributeFields;

    public ConfigurationNode(String reference) {
        this.reference = reference;
    }

    public ConfigurationNode setAttribute(cscfga__Attribute__c a, List<cscfga__Attribute_Field__c> attFields, String info, Map<String, cscfga__Product_Configuration__c> configMap) {        
        this.attr = a;
        this.definitionId = a.cscfga__Attribute_Definition__c;
        this.displayInfo = info;
        
        this.relatedProducts = new List<cscfga__Product_Configuration__C>();
        if (a.cscfga__Attribute_Definition__r.cscfga__Type__c == cscfga.Attribute.RELATED_PRODUCT && a.cscfga__Value__c != null && a.cscfga__Value__c != '') {
            this.relatedProductIds = a.cscfga__Value__c.split(',');
        }
        
        this.attributeFields = new Map<String, cscfga__Attribute_Field__c>();
        if (attFields != null) {
            for (cscfga__Attribute_Field__c field : attFields) {
                this.attributeFields.put(field.Name, field);
            }
        }

        return this;
    }
        
    public ConfigurationNode setConfig(cscfga__Product_Configuration__c sObj) {
        this.config = sObj;
        return this;
    }

}