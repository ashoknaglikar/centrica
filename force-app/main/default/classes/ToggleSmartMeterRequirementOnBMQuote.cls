public with sharing class ToggleSmartMeterRequirementOnBMQuote{

   public BigMachines_Quote__c bmQuote{get;set;}
   
   public ToggleSmartMeterRequirementOnBMQuote() {
        
       String bmQuoteId = System.currentPageReference().getParameters().get('id');
       bmQuote = [Select Id, Smart_Meter_Required_Flag__c, Toggle_Smart_Meter_Required_Flag_Status__c, (Select Id, Smart_Meter_Required_Flag__c, Status__c, Any_issue_with_smart_meter_installation__c, Smart_meter_installation_status__c  from Jobs__r where Is_Remedial_Job__c = false and Is_Downtime_Job__c = false and Split_Job__c = false and isCancellation_Job__c = false limit 1), (Select Id, Product__r.ProductCode, quotingReasonOn2ndVisit__c from Quote_Products__r where Product__r.ProductCode = 'SM01') from BigMachines_Quote__c where Id = :bmQuoteId]; 
    
    }
    
   public Pagereference reloadBMQuotePage() {
      
      Product2 prod = [Select Id from Product2 where ProductCode = 'SM01' limit 1];

      if(bmQuote.Jobs__r != null && bmQuote.Jobs__r.size() > 0){
      
         if(bmQuote.Jobs__r[0].Status__c == 'Suspended' || bmQuote.Jobs__r[0].Status__c == 'Cancelled' || bmQuote.Jobs__r[0].Status__c == 'Installed'){
         
                  bmQuote.Toggle_Smart_Meter_Required_Flag_Status__c = 'Since job is '+bmQuote.Jobs__r[0].Status__c+'. Action could not be completed. Please try later.';
                  Database.update(bmQuote);
                  Pagereference pageref = new Pagereference('/apex/RedirectToBMQuote?id='+bmQuote.Id);
                  pageref.setRedirect(true);
                  return pageref;
         
         }
      
      }
      
      if((bmQuote.Smart_Meter_Required_Flag__c == null) ||( bmQuote.Smart_Meter_Required_Flag__c.trim() == '' || bmQuote.Smart_Meter_Required_Flag__c.trim() != 'Yes')){
      
        bmQuote.Smart_Meter_Required_Flag__c = 'Yes';
        bmQuote.Toggle_Smart_Meter_Required_Flag_Status__c = 'Success';
        Quote_Product__c qp = new Quote_Product__c(quotingReason__c = 'ASP', Name = 'SM01' ,BigMachines_Quote__c = bmQuote.Id, Product__c = prod.Id, Quantity__c = 1);
        Insert qp;
        if(bmQuote.Jobs__r != null && bmQuote.Jobs__r.size() > 0){
        
            bmQuote.Jobs__r[0].Smart_Meter_Required_Flag__c = 'Yes';
            bmQuote.Jobs__r[0].Reason_for_acknowledgement__c = 'New Job';
        	bmQuote.Jobs__r[0].Smart_meter_installation_status__c = 'Pending';
        	bmQuote.Jobs__r[0].Smart_meter_installation_sub_status__c = 'Unacknowledged';
        	if(bmQuote.Jobs__r[0].Status__c=='Planned')
        	bmQuote.Jobs__r[0].Smart_meter_installation_date__c = bmQuote.Jobs__r[0].Delivery_Date__c;
        }
        
      }else if(bmQuote.Smart_Meter_Required_Flag__c.trim() == 'Yes'){
      
       
        
        if(bmQuote.Jobs__r != null && bmQuote.Jobs__r.size() > 0 && bmQuote.Jobs__r[0].Smart_meter_installation_status__c != 'Installed'){
        	bmQuote.Smart_Meter_Required_Flag__c = 'No';
            bmQuote.Jobs__r[0].Reason_for_acknowledgement__c = 'Removed by ASP';
        	bmQuote.Jobs__r[0].Smart_meter_installation_status__c = 'Cancelled';
        	bmQuote.Jobs__r[0].Smart_meter_installation_sub_status__c = 'Unacknowledged';
            bmQuote.Toggle_Smart_Meter_Required_Flag_Status__c = 'Success';
            List<Quote_Product__c> lstQProducts = bmQuote.Quote_Products__r;
            if(lstQProducts != null && lstQProducts.size() > 0){
                 for(Quote_Product__c qp : lstQProducts){
                     qp.quotingReasonOn2ndVisit__c = 'Removed-ASP';
                 }
               Database.update(lstQProducts);
            }
        
        }else if(bmQuote.Jobs__r != null && bmQuote.Jobs__r.size() > 0 && bmQuote.Jobs__r[0].Smart_meter_installation_status__c == 'Installed'){
                  
                  bmQuote.Smart_Meter_Required_Flag__c = 'Yes';
                  bmQuote.Toggle_Smart_Meter_Required_Flag_Status__c = 'Since smart meter is already installed, action could not be completed.';
                  Database.update(bmQuote);
                  Pagereference pageref = new Pagereference('/apex/RedirectToBMQuote?id='+bmQuote.Id);
                  pageref.setRedirect(true);
                  return pageref;
        
        }
          
      }
      Database.update(bmQuote);
      Database.update(bmQuote.Jobs__r[0]);
      Pagereference pageref = new Pagereference('/apex/RedirectToBMQuote?id='+bmQuote.Id);
      pageref.setRedirect(true);
      return pageref;
   
   }
    
}