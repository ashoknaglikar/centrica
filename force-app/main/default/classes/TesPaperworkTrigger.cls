public with sharing class TesPaperworkTrigger {

    static testMethod void checkPaperworkDetialsTrigger() {
    
        // Create Account
        Account acc = new Account(name = 'Test', BillingStreet='8 Paperwork Test', 
                                  BillingPostalCode='SW19 6DF', BillingCity='London', 
                                  BillingCountry='UK', BillingState='London');
        Database.insert(acc);
        
        // Create campaign
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Paperwork');
        Database.insert(camp);      
        
        // Create Opportunity
        Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'Test', 
                                            AccountId = acc.Id, 
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Active',
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);
        Database.insert(opp);
  
        // Create contact
        Contact contact = new Contact(LastName = 'paperwork contact', AccountId = acc.Id);
        Database.insert(contact);
        
        // Create big machines quote
        
        BigMachines_Quote__c bmQuote = new BigMachines_Quote__c(Name = 'Test paperwork trigger 1',Opportunity__c = opp.Id, 
                                                                                             stage__c = 'Quote Finalised - Accepted');
        Database.insert(bmQuote);
        
       // Create dummy paperwork details record.
       
       Paperwork_Recieved_Details__c paperRecDetails = new Paperwork_Recieved_Details__c();
       paperRecDetails.Big_Machines_Quote__c = bmQuote.Id;
       String err = '';
       Database.insert(paperRecDetails);
       
       try{
            
            paperRecDetails = new Paperwork_Recieved_Details__c();
            paperRecDetails.Big_Machines_Quote__c = bmQuote.Id;
            Database.insert(paperRecDetails);
            
       }catch(DMLException exp){
        
        err = 'Test successfull';
        System.debug('Insert did not happen succesfully due to an error.');
        
       }
 
       System.assertEquals( 'Test successfull', err );
       
       // Create one more big machines quote
        
       bmQuote = new BigMachines_Quote__c(Name = 'Test paperwork trigger 2',Opportunity__c = opp.Id, 
                                                                    stage__c = 'Quote Finalised - Not Accepted');
       Database.insert(bmQuote);
        
       paperRecDetails = new Paperwork_Recieved_Details__c();
       
       paperRecDetails.Big_Machines_Quote__c = bmQuote.Id;
       
       err = '';
       
       try{
       
            Database.insert(paperRecDetails);
       
       }catch(DMLException exp){
        
            err = 'Test successfull';
            System.debug('Insert did not happen succesfully due to an error.');
        
       }
       
         System.assertEquals( 'Test successfull', err );
         
        }

}