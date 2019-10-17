@isTest
public class CS_AllPartDiscountTriggerTest {
    
    public static CS_Discount_Category__c dc1;
    public static CS_Discount_Category__c dc2;
    public static CS_Part__c part;
    
    static void createData() {
         
         //Create Discount Categories
        
         dc1 = new CS_Discount_Category__c(Name = 'Rad');
         dc2 = new CS_Discount_Category__c(Name = 'Shr');
        
        insert new List<CS_Discount_Category__c> {dc1, dc2};
        
        //Create CS Part
        CS_VAT_Code__c vat1 = new CS_VAT_Code__c(Name='VAT Code 20%', Percentage__c=20);
        insert vat1;
        
        part = new CS_Part__c(Name='Special Radiator', Contributing_to_Margin__c=true, Part_Code__c = '004',
                                        Description__c='A special Radiator', VAT_Code__c = vat1.Id,  Active__c=false ); 
                                        
        insert part;
    }
    
    static testMethod void insertPartDiscountCategoriesTest() {
        
       createData();
        
        //Create Part Discount Category
        CS_Part_Discount_Category__c pdc1 = new CS_Part_Discount_Category__c(CS_Part__c = part.Id, CS_Discount_Category__c = dc1.Id);
        CS_Part_Discount_Category__c pdc2 = new CS_Part_Discount_Category__c(CS_Part__c = part.Id, CS_Discount_Category__c = dc2.Id);
        
        Test.startTest();
        insert new List<CS_Part_Discount_Category__c> {pdc1, pdc2};
        
        CS_Part__c retrievedPart = [select Id, Discount_Categories__c from CS_Part__c where Id = :part.Id];
        
        System.AssertEquals('Rad,Shr', retrievedPart.Discount_Categories__c);
        
        Test.stopTest();
    }
    
    static testMethod void deleteUndeleteDiscountCategoriesTest() {
        
       createData();
        
        //Create Part Discount Category
        CS_Part_Discount_Category__c pdc1 = new CS_Part_Discount_Category__c(CS_Part__c = part.Id, CS_Discount_Category__c = dc1.Id);
        CS_Part_Discount_Category__c pdc2 = new CS_Part_Discount_Category__c(CS_Part__c = part.Id, CS_Discount_Category__c = dc2.Id);
        insert new List<CS_Part_Discount_Category__c> {pdc1, pdc2};
        
        Test.startTest();
        delete dc1;
        
        CS_Part__c retrievedPart = [select Id, Discount_Categories__c from CS_Part__c where Id = :part.Id];
        System.AssertEquals(dc2.Name, retrievedPart.Discount_Categories__c);
        
        undelete dc1;
        retrievedPart = [select Id, Discount_Categories__c from CS_Part__c where Id = :part.Id];
        System.Assert((retrievedPart.Discount_Categories__c == 'Rad,Shr') || (retrievedPart.Discount_Categories__c == 'Shr,Rad'));
        
        Test.stopTest();
    }
    
    static testMethod void updateDiscountCategoriesTest() {
        
       createData();
        
        //Create Part Discount Category
        CS_Part_Discount_Category__c pdc1 = new CS_Part_Discount_Category__c(CS_Part__c = part.Id, CS_Discount_Category__c = dc1.Id);
        CS_Part_Discount_Category__c pdc2 = new CS_Part_Discount_Category__c(CS_Part__c = part.Id, CS_Discount_Category__c = dc2.Id);
        insert new List<CS_Part_Discount_Category__c> {pdc1, pdc2};
        
        Test.startTest();
        dc1.Name = 'Test1';
        dc2.Name = 'Test2';
        
        update new List<CS_Discount_Category__c> {dc1, dc2};
        
        CS_Part__c retrievedPart = [select Id, Discount_Categories__c from CS_Part__c where Id = :part.Id];
        System.Assert((retrievedPart.Discount_Categories__c == 'Test1,Test2') || (retrievedPart.Discount_Categories__c == 'Test2,Test1'));
        
        Test.stopTest();
    }
    
    static testMethod void deletePartDiscountCategoriesTest() {
        
       createData();
        
        //Create Part Discount Category
        CS_Part_Discount_Category__c pdc1 = new CS_Part_Discount_Category__c(CS_Part__c = part.Id, CS_Discount_Category__c = dc1.Id);
        CS_Part_Discount_Category__c pdc2 = new CS_Part_Discount_Category__c(CS_Part__c = part.Id, CS_Discount_Category__c = dc2.Id);
        insert new List<CS_Part_Discount_Category__c> {pdc1, pdc2};
        
        Test.startTest();
        delete pdc1;
        
        CS_Part__c retrievedPart = [select Id, Discount_Categories__c from CS_Part__c where Id = :part.Id];
        System.AssertEquals(dc2.Name, retrievedPart.Discount_Categories__c);
        
        Test.stopTest();
    }



}