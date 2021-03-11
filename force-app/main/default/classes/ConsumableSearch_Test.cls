/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class ConsumableSearch_Test {

    static testMethod void myUnitTest() {
  
        try{
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = userinfo.getuserId();
        insert emp;
            
            
        //system.runas(u)
        
            pagereference p = new pagereference('/apex/consumableSearch');
            test.setcurrentpage(p);
            consumableSearch c = new consumableSearch();
            c.getcategoryList();
            c.populateSubcategory();
            system.assert(c.SubcategoryList.size()>0);
            c.populateConsumables();    // TO DO: implement unit test
            c.loadfav();
            //c.getconsumables();
            FOR(Consumables__c co: [SELECT c.image_location__c, c.Sub_Product_Description__c,Image_URL__c, c.Sub_Product_Code_Description__c, c.SubProductGroup__c, c.Status__c, c.Short_Name__c, c.ShortDescription__c, c.Product_Group__c, c.Product_Code__c, c.Name, c.Id,ProductGroupDescription__c,CostPrice__c,Size__c ,Unit_Quantity__c From Consumables__c c where  Status__c = 'Active' LIMIT 10])
            {
               consumableSearch.genericClass genObj = new consumableSearch.genericClass(co, '');
               c.consumables.add(genObj);
            }
            //c.continue_Btn();
            c.consumableId = c.consumables[0].consu.Id;
            c.addFavorite();
            c.removeFavorite();
            
            for(consumableSearch.genericClass g : c.consumables)
            {
                g.isSelected = true;
                break;
                
            }
            c.addBasket();
            c.continue_Btn();
            //c.next();
            //c.previous();
            c.Discard();
            //c.toggleMode();
            system.assertnotequals(c.mode,4);
            }catch (exception e)
            {
            	system.debug( e);
            }
            
        
        
        
    }
    
    static testMethod void testMethod2() {
  
  		user u = TestClassHelper.createUser();
  		insert u;
        
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = u.id;
        insert emp;
        
        Consumables__c con = TestClassHelper.createCosumable();
        insert con;
         
        system.runas(u)
        {
        	Consumables_Requests__c  cr =  TestClassHelper.createCosumableRequest(emp.Id);
	        cr.Status__c = 'In Progress';
	        cr.IsShoppingBasket__c = true;
	        cr.Employee__c = emp.Id;
	        insert cr;
	        
	        Consumable_Items__c ci = TestClassHelper.createCosumableItem(con.Id,cr.Id);
	        insert ci;
	        pagereference p = new pagereference('/apex/consumableSearch');
	        test.setcurrentpage(p);
	        system.debug('************Debug***********'+cr);
	        consumableSearch c = new consumableSearch();
	        
	        c.bln_mode = false;
	        c.toggleMode();
        }    
    }
}