trigger GasSafeReport_BGC_number on Order_Line_Item__c (before insert) {

        List<String> lstcode = new List<String>();
        
        /* Code change to include new codes -15/06/2011 */
        for(Order_Line_Item__c orderline : Trigger.new){
            system.debug('orderline.Code__c -->'+orderline.Code__c );
            if(orderline.Code__c!=null){
            if(orderline.Code__c.contains('BLR')||orderline.Code__c.contains('WTR')||orderline.Code__c.contains('FFT')||orderline.Code__c.contains('SUI')||orderline.Code__c.contains('INF')||orderline.Code__c.contains('STF')||orderline.Code__c.contains('OTR')||orderline.Code__c.contains('OTL')||orderline.Code__c.contains('BKT')||orderline.Code__c.contains('STO')||orderline.Code__c.contains('FFB')||orderline.Code__c.contains('APP')||orderline.Code__c.contains('CYL')|| orderline.Code__c.contains('APF')){
            lstcode.add(orderline.Code__c);
            }
        }
      }
        
        List<Product_Order__c> lstProduct = [Select Name, Product_Number__c, Product_Code__c,BGC_NUMBER__c  From Product_Order__c where BGC_NUMBER__c !=null and Product_Code__c IN : lstcode];
    
        if(lstProduct .size()>0){
            
        for(Product_Order__c objpro: lstProduct){
            for(Order_Line_Item__c objtemp : Trigger.new){
                if(objtemp.Code__c ==objpro.Product_Code__c ){
                    objtemp.BGC_Number__c = objpro.BGC_NUMBER__c;
                }
                
            } 
                  
         }
         
     }
     
 }