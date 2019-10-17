/* OpportunityUpdate Trigger

    Trigger that happens after an Opportunity update. If an Opportunity's
    Stage is updated, we need to create an Appointment History for any
    Appointments related to the Opportunity that are in the future and of
    Status New or Appointed.
    
    Most of the work is done in the CheckRelatedAppointmentHistories class.

*/

trigger OpportunityUpdate on Opportunity (after update) {

    System.debug('Before entering opportunityTriggerHandler-->');
    if(trigger.isAfter && trigger.isUpdate && !Lock.cchContactOppRecursiveStopper)
    {
        System.debug('After entering opportunityTriggerHandler-->');
        Lock.cchContactOppRecursiveStopper = true;
        opportunityTriggerHandler.handleMaketingPreference(trigger.newMap, trigger.oldMap);
    }

    
    // Code added to maintain Lead Field History whenever Product of Interest field of Lead is changed    
    if(!Lock.hasAlreadyDone()){
        System.debug('===Welcome!!=====');    
        List<Lead_Field_History__c> lfhToInsert = new List<Lead_Field_History__c>();    
        for(Id l : trigger.newMap.keySet()){        
            System.debug('===Welcome1!!=====');            
            if(trigger.newMap.get(l).Product_Interest__c != trigger.oldMap.get(l).Product_Interest__c){            
                System.debug('===Welcome2!!=====');            
                lfhToInsert.add(new Lead_Field_History__c(CHI_Lead__c=l,                            
                Product_of_Interest_Name_Before__c=trigger.oldMap.get(l).Product_Interest__c,                            
                Product_of_Interest_Name_After__c=trigger.newMap.get(l).Product_Interest__c));        
            }    
        }   
        System.debug('===Welcome3!!====='+lfhToInsert);    
        if(lfhToInsert.size()>0)
         insert lfhToInsert;
        Lock.setAlreadyDone();
    }
    
    if(cls_IsRun.generalTriggerSwitch)
    {
        return;
    }
    // If user is Dataloader, set the variable accordingly
    if(UserInfo.getUserId() == '00520000000mTzkAAE') {
        System.debug('User is DataLoader');
        Lock.userIsNotDataloader = false;
    }
    
    // This trigger is used for invoking the logic which calculates net price charged to the customer on big machines quote in case of below events
    // When we override billing options on CHI Lead.
    
    // ++ Added for Smart Meter CR start
    Set<Id> oppIds = new Set<Id> ();
    List<Smart_Meter__c> smToBeUpdated = new List<Smart_Meter__c> ();
    if(cls_IsRun.doNotUpdateSMToCHILead == false)
    {
        for(Integer i =0; i < Trigger.new.size(); i++)
        {
            if((Trigger.new[i].SMStatus__c != Trigger.old[i].SMStatus__c) && (Trigger.new[i].SMStatus__c != null) && system.label.SmartMeterRecord == 'on')
            {
                oppIds.add(Trigger.new[i].id);
            }
        }
        if(oppIds.size() > 0)
        {
            for(Opportunity oppty : [Select o.SMStatus__c, o.Id, (Select Id, S_M_Status__c From Smart_Meters__r)
                                    From Opportunity o
                                    where o.id in: oppIds])
            {
                for(Smart_Meter__c sm : oppty.Smart_Meters__r)
                {
                    sm.S_M_Status__c = oppty.SMStatus__c;
                    smToBeUpdated.add(sm);
                }
            }
        }
        if(smToBeUpdated.size() > 0)
        {
            try
            {
                cls_IsRun.setdoNotUpdateSMToCHILead();
                update smToBeUpdated;
            }
            catch(Exception ex)
            {
                system.debug('--------Exception occured-------'+ex);
            }
        }
    } 
    // -- Added for Smart Meter CR end
    
    if(Trigger.new.size()==1 && Trigger.isUpdate && cls_IsRun.isCalculateNetCustomerPrice == false){
        
        Opportunity newNetPriceCalcOpp = Trigger.new[0];
        Opportunity oldNetPriceCalcOpp = Trigger.Old[0];
        boolean fireCalculationForNetPrice = false;
        CalculateQuoteNetValue c = new CalculateQuoteNetValue();
        List<BigMachines_Quote__c> bmQuoteList = new List<BigMachines_Quote__c>();
        BigMachines_Quote__c q;
        
        
        if(newNetPriceCalcOpp.Installation_Date_Billing__c != null && oldNetPriceCalcOpp.Installation_Date_Billing__c == null){
            
            fireCalculationForNetPrice = true;
            
        }
        
        if(newNetPriceCalcOpp.Installation_Date_Billing__c != null && oldNetPriceCalcOpp.Installation_Date_Billing__c != null){
            
            if(newNetPriceCalcOpp.Installation_Date_Billing__c != oldNetPriceCalcOpp.Installation_Date_Billing__c){
                
                fireCalculationForNetPrice = true;
            }
            
        }
        
        if(newNetPriceCalcOpp.Installation_Date_Billing__c == null && oldNetPriceCalcOpp.Installation_Date_Billing__c != null){
            
            fireCalculationForNetPrice = true;
            
        }
        
        if(fireCalculationForNetPrice){
           cls_IsRun.setIsCalculateNetCustomerPrice();
           q = [select id, name, createdDate_quote__c,IsSystem__c, 
           Number_of_paperworks_recieved__c,
           Opportunity__r.Platform__c,
           Opportunity__r.CHI_Lead_Id__c,Opportunity__c, 
           Opportunity__r.Account.Primary_Contact__r.Salutation,
           Opportunity__r.Account.Primary_Contact__r.FirstName,
           Opportunity__r.Account.Primary_Contact__r.LastName,
           Opportunity__r.Account.BillingStreet,
           Opportunity__r.Account.BillingCity,
           Opportunity__r.Account.BillingState,
           Opportunity__r.Account.BillingPostalCode,
           Opportunity__r.Account.Primary_Contact__r.MailingCity,
           Opportunity__r.Account.Primary_Contact__r.MailingState,
           Opportunity__r.Account.Primary_Contact__r.MailingPostalCode ,
           Opportunity__r.Account.Primary_Contact__r.MailingStreet,
           Opportunity__r.Payment_Reference_Number__c,
           Opportunity__r.Override_Billing_checks__c,
           Opportunity__r.discountsTotalOnPricing__c,
           Opportunity__r.Manual_Bill__c,VAT_1_Total_Amount_For_Net_Price_Calc__c,VAT_4_Total_Amount_For_Net_Price_Calc__c,Net_Price_Charged_To_Customer__c,
           Opportunity__r.Bill_to_Office__c,
           Opportunity__r.StageName,Opportunity__r.Bill_Period__c,Opportunity__r.Installation_Date_Billing__c,
           VAT_17_5_Total_Amount__c, POC_Payment_Method__c,ASP_Discounts__c,
           VAT_5_Total_Amount__c,discountsTotalOnPricing__c,App_Assigned_Payroll__c,
           Pricebook_Id__c, App_Assigned_To__c,POC_Payment_Option__c, 
           priceMatchDifference__c,ISpec_Difference__c,Billed__c,newPriceMatchDifference__c,closeDate__c,
           newTotalNetPrice_quote__c,
           (Select ID from Paperwork_Recieved_Details__r where Sales_Paperwork_Validated_Date__c != null),
           (Select Employee_ID__c, Employee__r.Emp_type__c From Diary_Entries__r where Employee__r.Group__c = 'INST'),                                                                      
           (Select Product_Code__c, VAT_Code__c, User_Defined_VAT_Code__c,FirstVATCode__c, Gross_Total__c, Merchant_Price__c,Total_Price__c, BigMachines_Quote__c From Quote_Products__r),
           (Select Id, Delivery_Date__c,Installation_Date__c,Status__c, Region_Code__c,Is_Downtime_Job__c,Is_Remedial_Job__c,createddate From Jobs__r where Is_Downtime_Job__c = false and Is_Remedial_Job__c = false)
            from  BigMachines_Quote__c where Opportunity__r.ID = :newNetPriceCalcOpp.ID and Opportunity__r.Platform__c = 'SFDC' and Consider_for_Installation_Planning__c = 'Y' and Line_Items_Decompiled__c = TRUE limit 1];
            
            System.debug('Overidden date is '+q.Opportunity__r.Installation_Date_Billing__c);
            
            System.debug('Overidden period is '+q.Opportunity__r.Bill_Period__c);
            
            bmQuoteList.add(q);
            
            c.calculateQuoteNetValueForCustomer(bmQuoteList);
            
        }
        
    }
    
    // If the Opportunity has been updated by a trigger, we don't want to create
    // any Appointment Histories. In the trigger, Lock.triggerUpdatingOpps will
    // have been set before updating the Opportunitys - if this variable is set to 
    // true, return straight away.
    //
    // Basically, this ensures that only Opportunity updates by users create
    // Appointment Histories
    if(Lock.triggerUpdatingOpps) {
        System.debug('Lock.triggerUpdatingOpps is true, returning');
        return;
    }
    
    // A map to hold the Opportunities
    Map<ID, Opportunity> opps = new Map<ID, Opportunity>();
    
    for(Opportunity newOpp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(newOpp.Id);
        if(oldOpp.StageName != newOpp.StageName && !Lock.triggerUpdatingOpps) {
            // We will need to get this Opportunity's Appointments
            System.debug('Opportunity\'s Stage updated, create Appointment History');
            opps.put(newOpp.Id, oldOpp);
        }
    }
    
    // If there are no Opportunities with Stage updates, nothing for us to do, so return
    if(opps.isEmpty()) {
        System.debug('No opportunities with Stage updates, returning');
        return;
    }
    
    // Get the related Appointments out of the database
    Appointment__c[] apps = [SELECT a.id, a.Status__c, 
                            a.Any_Time__c, a.Assigned_To__c, a.Do_Not_Send_To_Premier__c,
                            a.Converted_Visit_Type__c, a.End__c, a.Mode__c,
                            a.Notes__c, a.Overbooked__c, a.Resource_Type__c, 
                            a.Sale_Flag__c, a.Show_Time_As__c, a.Siebel_Created_Date__c,
                            a.Specific_Date_Requested__c, a.Start__c,
                            a.Status_Reason__c, a.Subject__c, a.Time_Band__c,
                            a.Visit_Type__c, a.Opportunity__c, a.Who__c, a.Type__c
                            FROM Appointment__c a
                            WHERE a.Opportunity__c IN :opps.keySet() 
                            AND a.Start__c > :Datetime.now()
                            AND (a.Status__c='New' OR a.Status__c='Appointed')];
    
    System.debug('Number of returned Appointments: ' + apps.size());
    
    // If there are no Appointments returned, no Appointment Histories need to be created
    // so we can exit here
    if(apps.isEmpty()) {
        System.debug('No Appointments returned, none to update, returning');
        return;
    }
    
    // Call the createAppointmentHistoriesOnUpdate method - this will create Appointment
    // Histories on relevant Appointment objects
    CheckRelatedAppointmentHistories.createAppointmentHistoriesOnUpdate(apps, 'Lead Stage Updated');
    
    
}