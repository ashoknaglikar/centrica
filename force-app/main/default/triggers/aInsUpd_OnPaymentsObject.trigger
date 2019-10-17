/*
Created by : Cognizant 
This trigger contains all the logic that should happen on after insert and upadte. 
This trigger contains logic to upddate CHI lead's Unbilled reason field to 'Payment Taken - card' 
or 'Payment Taken - Cash' or'Payment Taken - Online card', whenever a payemnts are created or 
upadted of type card or cash or online card respectively.  

*/
trigger aInsUpd_OnPaymentsObject on Payments__c (after insert, after update) {
/*
if(!cls_IsRun.isaInsUpd_OnPaymentsObjectRun && !cls_IsRun.istrg_UpdatePayment)
{
    cls_IsRun.setisaInsUpd_OnPaymentsObjectRun();
    list<Id> PCNIdLst = new list<Id>();
    
    //Recordtype Ids are fetched from recordtype helper class.
    string cardRTId = RecordTypeIdHelper.getRecordTypeId('Payments__c','Card'); 
    string onlineRTId= RecordTypeIdHelper.getRecordTypeId('Payments__c','Online Card'); 
    string cashRTId= RecordTypeIdHelper.getRecordTypeId('Payments__c','Cash'); 
    string chequeRTId= RecordTypeIdHelper.getRecordTypeId('Payments__c','Cheque'); 
    
    Map<Id,Payments__c> paymentsMap = trigger.newmap;
    for(Payments__c p : trigger.new)
    {
          PCNIdLst.add(p.Payment_Collection_Notice__c);  
    }
    
    Map<Id,Payment_Collection__c> PCNMap = new Map<Id,Payment_Collection__c>([Select Id,Opportunity__c, Opportunity__r.Unbilled_Reason__c from Payment_Collection__c where id in :PCNIdLst]);
    list<Opportunity> oppToBUpdated = new list<Opportunity>(); 
    for(Id pcn : paymentsMap .keyset())
    {
            
          Opportunity o = new opportunity(id = PCNMap.get(paymentsMap.get(pcn).Payment_Collection_Notice__c).Opportunity__c);
         if(paymentsMap.get(pcn).RecordtypeId == cardRTId || paymentsMap.get(pcn).RecordtypeId == onlineRTId)
         {
             o.Unbilled_Reason__c = 'Job Complete – card';
             
         }
         else if(paymentsMap.get(pcn).RecordtypeId == chequeRTId)
         {
            o.Unbilled_Reason__c = 'Job Complete – chq';
            
         }
         system.debug(o);
         oppToBUpdated.add(o); 
         
    }
    if(oppToBUpdated.size()>0)
    {
        update oppToBUpdated;
    }
}  */  
}