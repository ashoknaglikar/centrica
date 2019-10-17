public class TestOfferInsertOrUpdate {
    
    public class TestOfferSetup {
    
        public Offer__c newOffer(String description, 
                            Integer startDay, Integer startMonth, Integer startYear,
                            Integer endDay, Integer endMonth, Integer endYear,string offertype) {
            Date startD = Date.newInstance(2008, 06, 1);
            Date endD = Date.newInstance(2008, 06, 30);
            
            Offer__c offer = new Offer__c(Start_Date__c = startD, End_Date__c = endD, Description__c = description,offer_type__c=offertype);
            
            return offer;
        }   
    }
    
    static testmethod void testOffers() {
        TestOfferSetup setup = new TestOfferSetup();
        Offer__c offer1 = setup.newOffer('Test Offer 1', 1, 6, 2008, 30, 6, 2008,'Monetary');
        Database.insert(offer1);
        
        // Try an offer with the same dates
        try {
            Offer__c offer2 =  setup.newOffer('Test Offer 2', 1, 6, 2008, 30, 6, 2008,'Monetary');
            Database.insert(offer2);
            
        } catch (Exception exc) {
            // Do nothing
        }
        
        // Try an offer that starts before offer1 and ends after it
        try {
            Offer__c offer3 =  setup.newOffer('Test Offer 3', 31, 5, 2008, 1, 7, 2008,'Monetary');
            Database.insert(offer3);
        
        } catch (Exception exc) {
            // Do nothing
        }
        
        // Try an offer that starts before offer1 and ends during it
        try {
            Offer__c offer4 =  setup.newOffer('Test Offer 4', 1, 5, 2008, 1, 6, 2008,'Monetary');
            Database.insert(offer4);
        
        } catch (Exception exc) {
            // Do nothing
        }
        
        // Try another offer that starts before offer1 and ends during it
        try {
            Offer__c offer5 =  setup.newOffer('Test Offer 5', 1, 5, 2008, 15, 6, 2008,'Monetary');
            Database.insert(offer5);
        
        } catch (Exception exc) {
            // Do nothing
        }       
        
        // Try another offer that starts before offer1 and ends during it
        try {
            Offer__c offer6 =  setup.newOffer('Test Offer 6', 1, 5, 2008, 30, 6, 2008,'Monetary');
            Database.insert(offer6);
            
        } catch (Exception exc) {
            // Do nothing
        }
        
        // Try an offer that starts during offer1 and ends during it
        try {
            Offer__c offer7 =  setup.newOffer('Test Offer 7', 2, 6, 2008, 29, 6, 2008,'Monetary');
            Database.insert(offer7);
            
        } catch (Exception exc) {
            // Do nothing
        }       
        
        // Try an offer that starts during offer1 and ends after it
        try {
            Offer__c offer8 =  setup.newOffer('Test Offer 8', 2, 6, 2008, 1, 7, 2008,'Monetary');
            Database.insert(offer8);
            
        } catch (Exception exc) {
            // Do nothing
        }

        // Try another offer that starts during offer1 and ends after it
        try {
            Offer__c offer9 =  setup.newOffer('Test Offer 9', 15, 6, 2008, 1, 7, 2008,'Monetary');
            Database.insert(offer9);
            
        } catch (Exception exc) {
            // Do nothing
        }
        
        // Try another offer that starts during offer1 and ends after it
        try {
            Offer__c offer10 =  setup.newOffer('Test Offer 10', 30, 6, 2008, 1, 7, 2008,'Monetary');
            Database.insert(offer10);
            
        } catch (Exception exc) {
            // Do nothing
        }
        
        // Now for some valid offers
        try {
            // Offer before offer1
            Offer__c offer11 = setup.newOffer('Test Offer 11', 1, 5, 2008, 31, 5, 2008,'Monetary');
            // Offer after offer1
            Offer__c offer12 = setup.newOffer('Test Offer 11', 1, 7, 2008, 31, 7, 2008,'Monetary');
        } catch (Exception exc) {
            
        }
    }
}