trigger BasketTriggerBeforeUpdate on cscfga__Product_Basket__c (before update) {

/*

    Set<Id> basketIds = Trigger.newMap.keyset();
    
    List<cscfga__Product_Configuration__c> configs = [
        SELECT  Name,
                cscfga__Product_Basket__c,                
                (SELECT Name,
                        cscfga__Value__c
                 FROM   cscfga__Attributes__r
                 WHERE  Name = 'Outstanding Balance'
                 OR     Name = 'Quote Status')
        FROM    cscfga__Product_Configuration__c
        WHERE   cscfga__Product_Basket__c IN :basketIds
    ];
    
    for (cscfga__Product_Configuration__c config : configs) {
        if (config.Name == 'Heating Hot Water Solution') {
            String balance, status;
            cscfga__Product_Basket__c basket = Trigger.newMap.get(config.cscfga__Product_Basket__c);
            
            for (cscfga__Attribute__c att : config.cscfga__Attributes__r) {
                if (att.Name == 'Outstanding Balance') {
                    balance = att.cscfga__Value__c;
                } else if (att.Name == 'Quote Status') {
                    status = att.cscfga__Value__c;
                }
            }
            if (basket != null) {
                if (balance != null) {
                    try {
                        basket.Outstanding_Balance__c = Decimal.valueOf(balance);
                    } catch (Exception e) {
                        System.debug(LoggingLevel.WARN, 'Could not parse Outstanding Balance as decimal for basket ' + basket.Id + ': ' + balance);
                    }
                }
                basket.CS_Quote_Status__c = status;
            }
        }
    }
    */
}