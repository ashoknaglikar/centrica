@RestResource(urlMapping='/authenticateCustomer/*')

global with sharing class customerPortalAuthenticate {
    
    @HttpPost    
    global static boolean post(string Sf_id, string customerKey)
    {
        boolean endResult  = false;
        
        string saltedpassword ;
        
        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        String oppId = CustomerPortalHelper.getOpportunityId(Sf_id);
        /*
        if(!Sf_id.startswith(keyPrefix))
        {
            System.debug('SF_ID-->'+Sf_id);
            IV_Vectors__c  keyRecord = IV_Vectors__c.getinstance('Customer Portal');
            Blob key = Blob.valueOf(keyRecord.Key__c) ;
            blob encrypted2 = EncodingUtil.convertFromHex(Sf_id);
            if(!Test.IsrunningTest()){
            Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encrypted2);
            oppId = decrypted.toString();
            }
            
            
        }
        */
        
        if(customerKey != null)
        {
            Blob bPrehash = Blob.valueOf(customerKey); 
            Blob bsig = Crypto.generateDigest('SHA1', bPrehash); 
            saltedpassword =  EncodingUtil.convertToHex(bsig);
        }
        system.debug('--->'+oppId);
        system.debug('--->'+saltedpassword);
        
         list<Opportunity> result = [SELECT Id,Customer_Portal_Key_Salted__c, Name  FROM Opportunity WHERE id = :oppId];

         system.debug(result);
         
         if(result.size()>0)
         {
             endResult = result[0].Customer_Portal_Key_Salted__c == saltedpassword;
         }
        system.debug('endResult-->'+endResult);
        return endResult;
    }

}