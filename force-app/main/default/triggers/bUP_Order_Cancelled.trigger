/* Trigger will Update Order Element Status to Cancelled When an order is cancelled 
*/
trigger bUP_Order_Cancelled on order__c (after update) {

    order__c oldorder;
    if(!trigger.new.isEmpty()){ 
        order__c newOrder = trigger.new.get(0);
        oldorder = trigger.oldMap.get(newOrder.Id);
        if(oldorder.Status__c != 'Cancelled' && newOrder.Status__c == 'Cancelled')
        {
                               
           UpdateOrderElements.cancelorderElementsFuture(newOrder.ID);
         }
    }
}