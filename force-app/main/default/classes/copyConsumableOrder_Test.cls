@isTest
private class copyConsumableOrder_Test {
    
    static testMethod void copyConsumableOrderMethod_1Test()
    {
        user u = TestClassHelper.createUser();
        u.EmployeeNumber = '1234321';
        insert u;
        
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = u.Id;
        insert emp;
        
        
        system.runas(u){
        Consumables_Requests__c cReq1 = TestClassHelper.createCosumableRequest(emp.Id);
        cReq1.Status__c = 'In Progress';
        cReq1.IsShoppingBasket__c = true;
        insert cReq1;
        
        
        Consumables__c c = TestClassHelper.createCosumable();
        insert c;
        
        Consumable_Items__c conSu  = TestClassHelper.createCosumableItem(c.Id, cReq1.Id);
        insert conSu;
        
        test.setCurrentPage(new pagereference('/apex/copyConsumableOrder?crId='+cReq1.Id+'&isCopy=T'));
        //ApexPages.currentPage().getParameters().put('isCopy','true');
        copyConsumableOrder copyObj = new copyConsumableOrder();
        SYSTEM.DEBUG('---->'+copyObj);
        system.assert(copyObj.conClassList.size()==1);
        copyObj.recalculatePrice();
        copyObj.confirmDelete();
        copyObj.cancel();
        copyObj.homePage();
        pagereference p = copyObj.goToShpngBasket();
        system.assertEquals(p.getUrl(), '/apex/ConsumableSearch');
        copyObj.Submit();
        for(copyConsumableOrder.conItemClass cItem: copyObj.conClassList)
        cItem.isSelected = true;
        
        copyObj.RemoveItems();
        copyObj.Discard();
       
        }
    }
    static testMethod void copyConsumableOrderMethod_2Test()
    {
    
         user u = TestClassHelper.createUser();
        u.EmployeeNumber = '1234321';
        insert u;
        
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = u.Id;
        insert emp;
        Consumables_Requests__c cReq1 = TestClassHelper.createCosumableRequest(emp.Id);
        cReq1.Status__c = 'In Progress';
        cReq1.IsShoppingBasket__c = true;
        insert cReq1;
        Consumables__c c = TestClassHelper.createCosumable();
        insert c;
       /* Consumable_Items__c cItems=new Consumable_Items__c();
        cItems.Quantity__c=123;
        cItems.name='test item-1234';
        insert cItem;*/
        Consumable_Items__c conSu  = TestClassHelper.createCosumableItem(c.Id, cReq1.Id);
        insert conSu;
        conSu.Quantity__c=123;
        update conSu;
        test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.copyConsumableOrder'));

        ApexPages.currentPage().getParameters().put('isCopy','true');
        copyConsumableOrder copyObj = new copyConsumableOrder();
         copyObj.shpngBasket =false;
         
        copyObj.conReq =cReq1;
        copyObj.continue_Btn();
        copyConsumableOrder.conItemClass clist=new copyConsumableOrder.conItemClass(conSu);
        copyObj.conClassList =new list<copyConsumableOrder.conItemClass>();
        copyObj.conClassList.add(clist);
        copyObj.CreateCopyOrder();
        copyObj.shpngBasket =true;
        copyObj.goToShpngBasket();
        copyObj.Discard();
        copyObj.Submit();
        test.stopTest();
    }

}