public class CS_AllAttributeTriggerHelper {

    /**
     *  After insert trigger handler.
     */
    public static void handleAfterInsert(map<id, cscfga__Attribute__c> newAttributes) {
    
        List<cscfga__Product_Basket__c> basketsToUpdate = new List<cscfga__Product_Basket__c>();
        
        List<cscfga__Attribute__c> insertedAttributes = [select Id, Name, cscfga__Value__c,
                                                            cscfga__Attribute_Definition__c,
                                                            cscfga__Attribute_Definition__r.Name,
                                                            cscfga__Product_Configuration__c,
                                                            cscfga__Product_Configuration__r.cscfga__Configuration_Status__c,
                                                            cscfga__Product_Configuration__r.cscfga__Product_Basket__c,
                                                            cscfga__Product_Configuration__r.cscfga__Product_Basket__r.CS_Quote_Status__c
                                                          from cscfga__Attribute__c
                                                          where Id in :newAttributes.keySet()];
                                                          
         for (cscfga__Attribute__c att : insertedAttributes) {
             if (att.cscfga__Product_Configuration__r.cscfga__Configuration_Status__c != CS_Constants.ProductConfiguration_ClonedStatus) {
                 if (att.cscfga__Attribute_Definition__r.Name == CS_Constants.QuoteStatusAttributeName) {
                     att.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.CS_Quote_Status__c = att.cscfga__Value__c;
                 }
             }
         }
         
         if (basketsToUpdate.size() > 0) {
             update basketsToUpdate;
         }
    
    }

}