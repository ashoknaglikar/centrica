/*
Test Class created for caseContactListController (VF displayed in standard case page)
*/

@isTest
public class caseContactListController_Test{

    //static Contact c;


    // Prepare data for test class
    static case createTestData() 
    {
        Account Acc = TestClassHelper.createAccout();
        insert Acc;
                    
        Contact Cont = TestClassHelper.createContact(Acc);
        insert Cont;
        
        Case Case1 = new Case(subject='Test subject', Description='test desc', accountID=Acc.id, contactID=Cont.id, status='New');
        insert Case1;
        return Case1;
    }

    static testMethod void myUnitTest1() {
        
        Case c = createTestData();
        system.debug('##id:'+c);
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        //pagereference pref = new pagereference('/apex/caseContactListPage?Id='+c.id);
    
        PageReference pageRef = Page.caseContactListPage;
        pageRef.getParameters().put('id', String.valueOf(c.Id));
        Test.setCurrentPage(pageRef);
        
        
        caseContactListController ccl = new  caseContactListController(sc);
        
        
    }

}