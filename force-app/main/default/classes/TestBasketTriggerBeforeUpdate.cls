@IsTest
public class TestBasketTriggerBeforeUpdate {

    @IsTest
    public static void testBeforeUpdate() {
    
    /*
    
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'Test Basket');
        insert basket;
        
        cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c(Name = 'Heating Hot Water Solution', cscfga__Product_Basket__c = basket.Id);
        insert config;
        
        cscfga__Attribute__c status = new cscfga__Attribute__c(Name = 'Quote Status', cscfga__Value__c = 'Test Status', cscfga__Product_Configuration__c = config.Id);
        cscfga__Attribute__c balance = new cscfga__Attribute__c(Name = 'Outstanding Balance', cscfga__Value__c = '150.00', cscfga__Product_Configuration__c = config.Id);
        
        insert new cscfga__Attribute__c[]{status, balance};
        
        update basket;
        
        cscfga__Product_Basket__c comp = [SELECT Outstanding_Balance__c, CS_Quote_Status__c FROM cscfga__Product_Basket__c WHERE Id = :basket.Id];
        
        System.assertEquals(comp.Outstanding_Balance__c, Decimal.valueOf(balance.cscfga__Value__c));
        System.assertEquals(comp.CS_Quote_Status__c, status.cscfga__Value__c);       
        
      */
    }
}