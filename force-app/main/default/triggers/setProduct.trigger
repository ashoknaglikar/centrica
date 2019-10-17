trigger setProduct on Quote_Product__c (before insert) {

   // Added for avoiding run of this trigger whenever needed while developing some apex batch to run etc.
	  if(cls_IsRun.dontFireTriggers){
	      return;
	  }

    List<String> partNumberList = new List<String>();

    for (Integer i=0; i<Trigger.size; i++) {
        if (Trigger.new[i].Product__c == null) {
            partNumberList.add(Trigger.new[i].Name);
        }
    }
    Product2[] products = [select Id, BigMachines_Part_Number__c from Product2 where BigMachines_Part_Number__c in :partNumberList];
    Map<String,ID> partNumberMap = new Map<String,ID>();
    for (Product2 product : products) {
        partNumberMap.put(product.BigMachines_Part_Number__c, product.Id);
    }

    for (Integer i=0; i<Trigger.size; i++) {
        if (Trigger.new[i].Product__c == null) {
            Trigger.new[i].Product__c = partNumberMap.get(Trigger.new[i].Name);
        }
    }
}