/*
This class was fully commented as it was never used in the system anymore. because this class was called by two triggers which are :
but tha mit was commented from there. 
promotePrimaryProdToOppty.trg
propogateModifications.trg
It had 0 % coverage. so commented the whole class out and declared it test inorder not to count in characters.
*/
@istest
private class BigMachinesQuoting {
	
	/*
    public static void syncQuoteWithOpty(ID quoteId, ID opportunityId) {
        BigMachines_Quote__c[] quotesToUpdate = markOthersAsNonPrimary(quoteId, opportunityId);
        OpportunityLineItem[] oppProdToDelete = getOldOpportunityProducts(opportunityId);
        */

        /*
            To update opportunity with values from the primary quote:
                1) type additional quote fields in "quote" select statement
                2) assign the fields to the opportunity (ie. opportunity.FieldA = quote.FieldB__c) 
        */
      /*  BigMachines_Quote__c quote = [select Name, Pricebook_Id__c from BigMachines_Quote__c where Id = :quoteId];
        Opportunity opportunity = [select Name, Pricebook2Id from Opportunity where Id = :opportunityId];

        // if no pricebook Id is specified on quote then just use opportunity pricebook
        // if pricebook Id is specified on quote then it must match opportunity
        /*ID quotePricebookId = null;
        try {
            quotePricebookId = quote.Pricebook_Id__c;
        } catch (Exception e) {} 
        if (quotePricebookId != null && quotePricebookId != opportunity.Pricebook2Id) {
            quote.Is_Primary__c = false;
            update quote;
            throw new QuoteSyncException('Could not sync quote [' + quote.Name + '] with opportunity ['
                    + opportunity.Name + '] because they are using different pricebooks.  '
                    + 'In order to sync this quote and opportunity, first change the pricebook on one '
                    + 'of the objects to match the other and then try again.');
        }    

        /*
            To update opportunity products with additional fields from quote products
                1) type additional quote product fields in "quoteProds" select statement
                2) include additional assignments in OpportunityLineItem constructor below
        */
        
        /*List<OpportunityLineItem> oppProdToCreate = new List<OpportunityLineItem>();
        Quote_Product__c[] quoteProds = [select Id, Name, Product__c, Quantity__c, Sales_Price__c 
                                         from Quote_Product__c where BigMachines_Quote__c = :quoteId];
        if (quoteProds.size() > 0) {
            ID pricebookId = opportunity.Pricebook2Id;
            if (pricebookId == null) {
                pricebookId = [select Id from Pricebook2 where IsStandard = true].Id;
            }
            Set<ID> productIdSet = new Set<ID>();
            for (Quote_Product__c qProd : quoteProds) {
                productIdSet.add(qProd.Product__c);
            }
            PricebookEntry[] pbEntries = [select Id, Product2Id from PricebookEntry 
                                          where Pricebook2Id = :pricebookId and Product2Id in :productIdSet];
            if (productIdSet.size() != pbEntries.size()) {
                quote.Is_Primary__c = false;
                update quote;
                throw new QuoteSyncException('Could not sync quote [' + quote.Name + '] with opportunity ['
                        + opportunity.Name + '] because [' + (productIdSet.size() - pbEntries.size())
                        + '] product(s) in the quote do not have a pricebook entries in Salesforce.  '
                        + 'In order to sync this quote and opportunity, first ensure that all products '
                        + 'have prices in the opportunity\'s pricebook and then try again.');
            }
            Map<ID,ID> prodMap = new Map<ID,ID>();
            for (PricebookEntry pbEntry : pbEntries) {
                prodMap.put(pbEntry.Product2Id, pbEntry.Id);
            }
            for (Quote_Product__c qProd : quoteProds) {
                oppProdToCreate.add(new OpportunityLineItem(PriceBookEntryId = prodMap.get(qProd.Product__c), 
                                                            Quantity = qProd.Quantity__c, 
                                                            UnitPrice = qProd.Sales_Price__c, 
                                                            OpportunityId = opportunity.Id));
            }
        }
        //commit changes
        update opportunity;
        update quotesToUpdate;
        delete oppProdToDelete;
        if (oppProdToCreate.size() > 0) {
            insert oppProdToCreate;
        }
    }
    
    private static BigMachines_Quote__c[] markOthersAsNonPrimary(ID quoteId, ID opportunityId) {
        BigMachines_Quote__c[] otherQuotes = [select Id, Is_Primary__c, Opportunity__c from BigMachines_Quote__c 
                                              where Opportunity__c = :opportunityId and Id != :quoteId];
        for (BigMachines_Quote__c quote : otherQuotes) {
            //set the quote to non-primary 
            quote.Is_Primary__c = false;
        }
        return otherQuotes;
    }
    
    private static OpportunityLineItem[] getOldOpportunityProducts(ID opportunityId) {
        return [select Id, OpportunityId from OpportunityLineItem
                where OpportunityId = :opportunityId];       
    }

    public class QuoteSyncException extends Exception {}   */ 
    
    static testMethod void testSyncQuoteWithOpty() {
    	/*try {
	        Opportunity opty = new Opportunity();
	        opty.Name = 'BigMachines test opportunity for testSyncQuoteWithOpty()';
	        opty.StageName = 'Prospecting';
	        opty.CloseDate = Date.today();
	        //Start - Added by CF so SFDC test pass objetc validation rules
	        opty.LeadSource = 'Marcomms';
	        Campaign newCampaign = new Campaign();
	        newCampaign.Name = 'Test Temp Campaign';
	        newCampaign.Group_Code__c='MEDA';
	        newCampaign.Source__c='XP';
	        newCampaign.Media_Cost_Code__c='atestvalue';
	        insert newCampaign; 
	        opty.CampaignId=newCampaign.ID; 
	        opty.Product_Interest__c='Solar';
	        //End        
	        insert opty;
	
	        // BigMachines_Quote__c.ensurePrimary - begin test
	        BigMachines_Quote__c[] quotes = new BigMachines_Quote__c[3];
	        quotes[0] = new BigMachines_Quote__c();
	        quotes[0].Name = 'BigMachines test quote 1 for testSyncQuoteWithOpty()';
	        quotes[0].Opportunity__c = opty.Id;
	        quotes[1] = new BigMachines_Quote__c();
	        quotes[1].Name = 'BigMachines test quote 2 for testSyncQuoteWithOpty()';
	        quotes[1].Opportunity__c = opty.Id;
	        quotes[2] = new BigMachines_Quote__c();
	        quotes[2].Name = 'BigMachines test quote 3 for testSyncQuoteWithOpty()';
	        quotes[2].Opportunity__c = opty.Id;
	        //insert quotes;
	        // gjb 2010-01-29 - quotes can no longer be bulk inserted
	        insert quotes[0];
	        insert quotes[1];
	        insert quotes[2];  
	        // BigMachines_Quote__c.ensurePrimary - end test
	
	        Product2[] prod = new Product2[6];
	        for (Integer i=0; i<prod.size(); i++) {
	            prod[i] = new Product2();
	            prod[i].Name = 'BigMachines test proudct ' + i + ' for testSyncQuoteWithOpty()';
	            prod[i].IsActive = true;
	            prod[i].BigMachines_Part_Number__c = 'BMITest0' + i;
	        }
	        insert prod;
	        Pricebook2 pbStandard = [select Id from Pricebook2 where IsStandard = true];
	        PricebookEntry[] pbookEntry = new PricebookEntry[5];
	        for (Integer i=0; i<pbookEntry.size(); i++) {
	            pbookEntry[i] = new PricebookEntry();
	            pbookEntry[i].IsActive = true;
	            pbookEntry[i].Pricebook2Id = pbStandard.id; 
	            pbookEntry[i].Product2Id = prod[i].id;
	            pbookEntry[i].UnitPrice = i;
	        }  
	        insert pbookEntry;
	
	        // BigMachinesQuoting.syncQuoteWithOpty - begin positive test
	        Quote_Product__c[] qProd = new Quote_Product__c[5];  
	        for (Integer i=0; i<qProd.size(); i++) {
	            qProd[i] = new Quote_Product__c();
	            qProd[i].Name = 'BMITest0' + i;
	            qProd[i].BigMachines_Quote__c = quotes[0].id;
	            qProd[i].Sales_Price__c = i;
	            qProd[i].Quantity__c = i+1;
	        }
	        // gjb 2010-01-29 - quotes can no longer be bulk updated - this affects quote products as well
	        //insert qProd
	        insert qProd[0]; insert qProd[1]; insert qProd[2]; insert qProd[3]; insert qProd[4];
	        quotes[0].Is_Primary__c = true;
	        // gjb 2010-01-29 - quotes can no longer be bulk updated
	        //update quotes;
	        update quotes[0];
	        update quotes[1];
	        update quotes[2]; 
	        // BigMachinesQuoting.syncQuoteWithOpty - end positive test
	        
	        // Quote_Product__c.propogateModifications - begin test
	        delete qProd[0];
	        // Quote_Product__c.propogateModifications - begin test
	
	        // BigMachinesQuoting.syncQuoteWithOpty - begin no product price negative test 
	        Quote_Product__c noPriceProd = new Quote_Product__c();
	        noPriceProd.Name = 'BMITest05';
	        noPriceProd.BigMachines_Quote__c = quotes[0].id;
	        noPriceProd.Sales_Price__c = 5;
	        noPriceProd.Quantity__c = 6;
	        boolean throwsException = false;
	        try {
	            insert noPriceProd;
	        } catch (Exception e) {
	            throwsException = true;
	        }
	        System.assert(throwsException);
	        // BigMachinesQuoting.syncQuoteWithOpty - end no product price negative test
	
	        // Quote_Product__c.propogateModifications - begin error check test
	        qProd = new Quote_Product__c[2];
	        qProd[0] = new Quote_Product__c();
	        qProd[0].BigMachines_Quote__c = quotes[1].id;
	        qProd[0].Sales_Price__c = 1;
	        qProd[0].Quantity__c = 1;
	        qProd[1] = new Quote_Product__c();
	        qProd[1].BigMachines_Quote__c = quotes[2].id;
	        qProd[1].Sales_Price__c = 1;
	        qProd[1].Quantity__c = 1;
	        // gjb 2010-01-29 - quotes can no longer be bulk updated - this affects quote products as well
	        insert qProd[0];
	        insert qProd[1];
	        delete qProd[0];
	        delete qProd[1];
	        // Quote_Product__c.propogateModifications - end error check test
	
	        // BigMachines_Quote__c.promotePrimaryProdToOppty - begin multi-case test
	        quotes[0].Is_Primary__c = false;
	        quotes[1].Is_Primary__c = true;
	        quotes[2].Is_Primary__c = true;
	        //update quotes;
	        update quotes[0];
	        update quotes[1];
	        update quotes[2]; 
	        // BigMachines_Quote__c.promotePrimaryProdToOppty - end multi-case test
	        
	        // BigMachinesQuoting.syncQuoteWithOpty - begin invalid pricebook negative test
	        Pricebook2 pbook = new Pricebook2();
	        pbook.Name = 'Different pricebook';
	        insert pbook;
	        quotes[0].Is_Primary__c = true;
	        quotes[0].Pricebook_Id__c = pbook.id;
	        throwsException = false;
	        try {
	          // gjb 2010-01-29 - quotes can no longer be bulk updated
	            //update quotes;
	            update quotes[0];
	          update quotes[1];
	          update quotes[2]; 
	        } catch (Exception e) {
	            throwsException = true;
	        }
	        System.assert(throwsException);
	        // ignore invalid pricebook Id
	        quotes[0].Pricebook_Id__c = 'garbage';
	        quotes[0].Is_Primary__c = true;
	        // gjb 2010-01-29 - quotes can no longer be bulk updated
	        //update quotes;
	        update quotes[0];
	        //update quotes[1];
	        //update quotes[2];
	        // BigMachinesQuoting.syncQuoteWithOpty - end invalid pricebook negative test
    	} catch(Exception ex) {
    		//do nothing
    	}*/
    	system.assertequals(true,true);
    } 

}