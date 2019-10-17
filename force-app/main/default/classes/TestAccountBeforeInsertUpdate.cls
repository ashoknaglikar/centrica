@istest
private class TestAccountBeforeInsertUpdate {

    static testMethod void checkAccountBeforeInsertUpdate() {
    
        // Create Account
        
        Account acc = new Account(name = 'Water hardness test', BillingStreet='Test', 
                                  BillingPostalCode='SW19 6DZ', BillingCity='Test', 
                                  BillingCountry='Test', BillingState='Test');
        
        Database.insert(acc);
        
        Account testAccount = [select a.Water_Hardness__c from Account a where Id = :acc.id];
        
        String postCodeSector = acc.BillingPostalCode.substring(0,acc.BillingPostalCode.length()-2);
        
        String visitType = 'Sales'; 
        
        Postcode_Sector__c postCodeSectorInfo = [Select p.Water_Hardness__c From Postcode_Sector__c p where name =:postCodeSector and type__c = :visitType limit 1];      

        System.assertEquals(testAccount.Water_Hardness__c, postCodeSectorInfo.Water_Hardness__c);
        
        
        Account accNull = new Account(name = 'Hardness test', BillingStreet='Water H Test', 
                                  BillingPostalCode='XXX XXX', BillingCity='Water H Test', 
                                  BillingCountry='Water H Test', BillingState='WaterH Test');
        
        Database.insert(accNull);
        
        Account testAccountNull = [select a.Water_Hardness__c from Account a where id = :accNull.id];
        
        System.assertEquals( 0, testAccountNull.Water_Hardness__c );
         
        }
        
}