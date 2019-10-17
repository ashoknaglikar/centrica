/*

This is the before insert and update trigger on Account object. 

It copies water hardness & patch id value from 
corresponding to related postcode sector. 

If Account PostCode is null or it does not match with
any of the postcode sectors then set water hardness to zero.

This trigger can process at the maximum 1000 records at a time. 
If try processing more than this limit we will get exception.


*/

trigger AccountBeforeInsertUpdateTrigger on Account (before insert,before update) {

System.debug('Entered AccountBeforeInsertUpdateTrigger');
       
   // Populate the water hardness fields on the Account from corresponding postcode sector
    
   // If the postcode is null or invalid on account object then write water hardness value as zero
    
    String  postCodeSectorName ;
      
    String visitType = 'Sales';
    
    Account[] allAccounts = Trigger.new;
           
    private Set<String> postcodeSectorAccounts = new Set<String>();
               
    Boolean isMatchFound = false;
    
    for( Account newAccount : allAccounts ) {
        
     //++ Inbound call PRB00010961 changes starts
     if(newAccount.BillingStreet != null ){
        String billingStreet = newAccount.BillingStreet;
         if(billingStreet.contains('\r\n')){
                billingStreet = billingStreet.replace('\r\n', ' ');
         }
         //To remove extra spaces
         billingStreet = billingStreet.replaceAll('(\\s+)', ' ');
         newAccount.BillingStreet = billingStreet;
     }
     //-- Inbound call PRB00010961 changes ends
      
      if(newAccount.BillingPostalCode != null ) {
        // ++ Added for CR-000853 start
        newAccount.BillingPostalCode = newAccount.BillingPostalCode.toUpperCase(); 
        // -- Added for CR-000853 end
        postcodeSectorAccounts.add(newAccount.BillingPostalCode.substring(0,newAccount.BillingPostalCode.length()-2));
         system.debug('@@postcodeSectorAccounts'+postcodeSectorAccounts);
        }else {
   
          newAccount.Water_Hardness__c = 0;
          newAccount.Patch_ID__c = '';
   
      }
    
    }
                
    System.debug('Number of non-duplicate postcode sectors : '+postcodeSectorAccounts.size());
                                
    Postcode_Sector__c[] postCodeSectorInfo = [Select p.ID,p.Name,p.Water_Hardness__c,p.Sub_Patch__c,p.Patch_ID__c,Region_Code__c,Trading_Name__c,Country__c
                                                   From Postcode_Sector__c p where Name IN :postcodeSectorAccounts and type__c = :visitType];      
    
    for(Account newAccount : allAccounts) {
    
       for(Postcode_Sector__c postCodeSector : postCodeSectorInfo ) {
                    
           if( newAccount.BillingPostalCode != null && postCodeSector.Name == newAccount.BillingPostalCode.substring(0,newAccount.BillingPostalCode.length()-2) ) {
                
               
               newAccount.Water_Hardness__c = postCodeSector.Water_Hardness__c;
               newAccount.Patch_ID__c = postCodeSector.Region_Code__c;
               
               if( postCodeSector.Sub_Patch__c != null ){
                
                newAccount.Sales_Subpatch__c = postCodeSector.Sub_Patch__c;
               }
               newAccount.Country__c = postCodeSector.Country__c;
                system.debug('@@for');
                 system.debug('@@pcs id'+postCodeSector.id);
                 system.debug('@@pcs name'+postCodeSector.name);
               if( postCodeSector.Trading_Name__c != null ){
                
                newAccount.Trade_Name_Text__c = postCodeSector.Trading_Name__c;
                 system.debug('@@newAccount.Trade_Name_Text__c'+newAccount.Trade_Name_Text__c);
               }
           
               isMatchFound = true;
           
            }
       
       }
        
         if(isMatchFound == false) {
        
              newAccount.Water_Hardness__c = 0;
              newAccount.Patch_ID__c = '';
                   
          }else {
          
              isMatchFound = false;
          
          }
     
    }
       
    System.debug('Exiting AccountBeforeInsertUpdateTrigger');

}