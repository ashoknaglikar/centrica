/*
* CLASS - UpdateOrderElements
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to update orders line items if the order is cancelled
*/
public with sharing class UpdateOrderElements {

    public static void cancelorderElementsFuture(ID orderID) {
        List<Order_Line_Item__c> toUpdate = new List<Order_Line_Item__c>();
        order__c newOrder = [Select(Select Id,  P5_Status_c__c From Order_Line_Items__r where P5_Status_c__c != 'Cancelled')
                            From order__c  where id=:orderID];
        System.debug('##newOrder ------->##' +newOrder);
        
        for(Order_Line_Item__c ol : newOrder.Order_Line_Items__r){
            if(ol.P5_Status_c__c != 'Cancelled'&& ol.P5_Status_c__c =='Active' ){
                
                ol.P5_Status_c__c = 'Cancelled'; 
                toUpdate.add(ol);
            }
          }
    
        if(toUpdate.size() > 0){
            update toUpdate;
            
        }
       }
    }