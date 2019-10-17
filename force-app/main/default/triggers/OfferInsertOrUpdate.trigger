/* OfferInsertOrUpdate Trigger

    A trigger that fires when Offers are inserted or updated. Checks that
    there no Offers already exist that overlap with the Offer being
    inserted. Also makes sure that the Offer end date is after the start
    date.

*/

trigger OfferInsertOrUpdate on Offer__c (before insert, before update) {

    // Loop over each of the Offers in the database
    for(Offer__c existingOffer : [SELECT o.Id, o.Start_Date__c, o.End_Date__c, o.Name FROM Offer__c o]) {
        // Loop over each of the Offers being inserted or updated
        for(Offer__c newOffer : Trigger.new) {
            // Check that the end date is after the start date and report error if necessary
            if(newOffer.End_Date__c < newOffer.Start_Date__c)
                newOffer.addError('End Date was before Start Date');
            
            // Check the current offers IDs do not match - if they do, we will be comparing
            // the same Offer, so continue if they do match to avoid this!
            if(newOffer.Id == existingOffer.Id)
                continue;
            
            // Logic to check if the current offers overlap. We check:
            // a. if the start date of the new offer occurs between the start and 
            //    end date of the current existing offer
            // b. if the end date of the new offers occurs between the start and
            //    end date of the current existing offer
            // c. if the new offer's start date is before the current existing offer's 
            //    start date and the new offer's end date is after the current offer's
            //    end date
            // If either of a, b or c are true, we do not allow the Offer to be inserted
            // or updated
            if((newOffer.Start_Date__c >= existingOffer.Start_Date__c &&
                newOffer.Start_Date__c <= existingOffer.End_Date__c) 
                || 
                (newOffer.End_Date__c <= existingOffer.End_Date__c &&
                newOffer.End_Date__c >= existingOffer.Start_Date__c)
                ||
                (newOffer.Start_Date__c <= existingOffer.Start_Date__c) &&
                (newOffer.End_Date__c >= existingOffer.End_Date__c)) {
                    newOffer.addError('Trying to insert or update an Offer that overlaps ' + 
                    'with an existing Offer:\nOffer Name: ' + existingOffer.Name + '\n' +
                    'Offer Start Date: ' + existingOffer.Start_Date__c + '\n' +
                    'Offer End Date: ' + existingOffer.End_Date__c); 
            }
        }
    }
    

}