@istest
private class TestSurveyPaperworkTrigger {

    static testMethod void checkSurveyPaperworkDetialsTrigger() {
    
        // Create Account
        Account acc = new Account(name = 'Test 1', BillingStreet='10 Paperwork Test', 
                                  BillingPostalCode='SW19 6DF', BillingCity='London', 
                                  BillingCountry='UK', BillingState='London');
        Database.insert(acc);
        
        // Create campaign
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Paperwork');
        Database.insert(camp);      
        
        // Create Opportunity
        Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'Test 1', 
                                            AccountId = acc.Id, 
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Active',
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);
        Database.insert(opp);
  
        // Create contact
        Contact contact = new Contact(LastName = 'survey paperwork contact', AccountId = acc.Id);
        Database.insert(contact);
        
        // Create big machines quote
        
        BigMachines_Quote__c bmQuote = new BigMachines_Quote__c(Name = 'Test survey paperwork trigger 1',Opportunity__c = opp.Id, 
                                                                                             stage__c = 'Quote Finalised - Accepted');
        Database.insert(bmQuote);
        
       // Create dummy paperwork details record.
       
       Surveyor_Paperwork_Received_Details__c surveyPaperRecDetails = new Surveyor_Paperwork_Received_Details__c();
       surveyPaperRecDetails.Quote__c = bmQuote.Id;
       String err = '';
       Database.insert(surveyPaperRecDetails);
       
       try{
            
            surveyPaperRecDetails = new Surveyor_Paperwork_Received_Details__c();
            surveyPaperRecDetails.Quote__c = bmQuote.Id;
            Database.insert(surveyPaperRecDetails);
            
       }catch(DMLException exp){
         
         err = 'Test successfull';
         System.debug('Insert did not happen succesfully due to an error.');
         
       }
       system.assertequals(err,'');
 
  }    

}