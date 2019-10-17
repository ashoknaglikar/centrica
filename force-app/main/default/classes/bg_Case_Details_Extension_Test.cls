@isTest

public class bg_Case_Details_Extension_Test{

    static Account acc;
    static Case c;
    static Product2 prod;
    static User user;
    static Id aspRec;
    static list<ASP_Requested_Items__c> asp = new list<ASP_Requested_Items__c>();
    static ApexPages.StandardController controller; 
    static  bg_Case_Details_Extension ext;
    
    static void createData(){
        user = TestClassHelper.createUser();
        insert user;
        acc = TestClassHelper.createAccout();
        insert acc;
        aspRec = [Select Name from RecordType where  SObjectType ='Case' AND Name='Request for ASP'].id;
        c = new Case(RecordTypeId=aspRec,Function__c='Sales',Definition__c='Building Work',Reason__c='Asbestos',Charge_to_Customer_Info__c='No Charge',
                        Status='New',Priority='Low',Is_there_a_CHARGE_REFUND_to_customer__c='No',Person_Approved_By__c='Ashok');
        prod = new Product2(Name='PB140',ProductCode='ProductCode');
        insert prod;
        controller = new ApexPages.StandardController(c);       
        ext  = new bg_Case_Details_Extension(controller);  
    }
    
    static testmethod void testmethod1(){
        createdata();
        ext.save(); 
    }
    
    static testmethod void testmethod2(){
        createdata();
        ext.newASPRequestedItem(); 
        ASP_Requested_Items__c aspItem = [select id,Quantity__c,Action__c,Product__c from ASP_Requested_Items__c where ASP_Request__c=:c.id];
        aspItem.Action__c='Add';
        aspItem.Quantity__c=2;
        aspItem.Product__c =prod.id;
        ext.save();
    }
    
    static testmethod void testmethod3(){
        createdata();
        ext.newASPRequestedItem(); 
        ASP_Requested_Items__c aspItem = [select id,Quantity__c,Action__c,Product__c from ASP_Requested_Items__c where ASP_Request__c=:c.id];
        aspItem.Action__c='Add';
        aspItem.Quantity__c=2;
        aspItem.Product__c =prod.id;
        ext.save();
        ext.chosenChildId = aspItem.id;
        ext.deleteASPRequestedItem();
    }
    
    static testmethod void testmethod4(){
        createdata();
        ext.newASPRequestedItem(); 
        ASP_Requested_Items__c aspItem = [select id,Quantity__c,Action__c,Product__c from ASP_Requested_Items__c where ASP_Request__c=:c.id];
        aspItem.Action__c='Add';
        aspItem.Quantity__c=2;
        aspItem.Product__c =prod.id;
        ext.saveAndExit();
    }

}