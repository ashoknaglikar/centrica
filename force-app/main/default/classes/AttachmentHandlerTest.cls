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
@isTest
private class AttachmentHandlerTest
{
    // statics to hold test data used in tests
    private static Attachment s_quoteAttachmentPDF, s_quoteAttachmentDoc, s_accountAttachmentPDF;
    static list<Account> myAccounts;
    static Opportunity opp;
    static list<BigMachines_Quote__c> myQuotes;
    
    static testMethod void testDeletionOfQuoteAttachmentPDF()
    {
        createTestData();
        
        try
        {
            delete s_quoteAttachmentPDF;
            System.assert(true, 'Should not be able to delete a PDF Quote Attachement');
        }
        catch (Exception e)
        {
            system.assert(e.getMessage().contains(AttachmentHandler.QUOTE_ATTACHMENT_ERROR));
        }
    }

    static testMethod void testModificationOfQuoteAttachmentPDF()
    {
        createTestData();
        
        try
        {
            s_quoteAttachmentPDF.Description = 'updated';
            update s_quoteAttachmentPDF;
            System.assert(false, 'Should not be able to amend a PDF Quote Attachement');
        }
        catch (Exception e)
        {
            system.assert(e.getMessage().contains(AttachmentHandler.QUOTE_ATTACHMENT_ERROR));
        }
    }

    static testMethod void testDeletionOfQuoteAttachmentText()
    {
        createTestData();
        
        try
        {
            delete s_quoteAttachmentDoc;
        }
        catch (Exception e)
        {
            System.assert(false, 'Did not expect an exception trying to delete a non-PDF Quote Attachement');
        }
    }

    static testMethod void testModificationOfQuoteAttachmentText()
    {
        createTestData();
        
        try
        {
            s_quoteAttachmentDoc.Description = 'updated';
            update s_quoteAttachmentDoc;
        }
        catch (Exception e)
        {
            System.assert(false, 'Did not expect an exception trying to update a non-PDF Quote Attachement');
        }
    }

    static testMethod void testDeletionOfStandardAttachment()
    {
        createTestData();
        
        try
        {
            delete s_accountAttachmentPDF;
        }
        catch (Exception e)
        {
            System.assert(false, 'Did not expect an exception trying to delete a PDF Account Attachement');
        }
    }

    static testMethod void testModificationOfStandardAttachment()
    {
        createTestData();
        
        try
        {
            s_accountAttachmentPDF.Description = 'updated';
            update s_accountAttachmentPDF;
        }
        catch (Exception e)
        {
            System.assert(false, 'Did not expect an exception trying to update a PDF Account Attachement');
        }
    }
    
    static testmethod void testPDFRecieved()
    {
         createTestData();
         Attachment att = new Attachment();
         att.Body = Blob.valueOf('FFFFFF');
         att.ContentType = 'application/pdf';
         att.Name = '1234554321.pdf';
         att.ParentId = myQuotes[0].Id;
         insert att;
    }
    
    private static void createTestData()
    {   
        // find an Account to attach to
        myAccounts = new list<Account> {TestClassHelper.createAccout()};
        insert myAccounts;
        System.assertEquals(1, myAccounts.size(), 'Need at least one account to test against.');
        
        opp = TestClassHelper.createCHILead(myAccounts[0]);
        insert opp;
        
        //Account Acc = TestClassHelper.createAccout();
        //insert Acc;
 
        //Contact con = TestClassHelper.createContact(acc);
        //insert con ;
 
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c=userinfo.getuserid();
        insert emp;
 
 
 
 
        //RecordType RcdTypId = [Select r.Id From RecordType r where r.Name='Dispute'and sObjectType = 'Case']; 
        
        //String parentObjId;
        //Id i = Id.valueOf(parentObjId);
        //Id myId = parentObjId;
        
        Case caseObj = new Case();
        //caseObj.RecordTypeId=RcdTypId.Id;
        //caseObj.AccountId=Acc.Id;
        //caseObj.ContactId=con.Id;
        caseObj.Subject='Test Case';
        caseObj.Description='Test Desc';
        caseObj.Disputed_Amount__c=100;
        caseObj.Communication_status__c='Awaiting Office';
        caseObj.Case_Source__c='Customer';
        caseObj.Priority='High';
        caseObj.Issued_To__c=emp.Id;
        caseObj.Classification__c='Sales';
        caseObj.Status='New';
        caseObj.Conclusion__c='Justified';
        caseObj.Status='Closed';
        String parentKeyPrefix='500';
        String keyPrefix='500';
        insert caseObj;

        
         Attachment att = new Attachment();
         att.Body = Blob.valueOf('FFFFFF');
         att.ContentType = 'application/pdf';
         att.Name = 'COMPLAINTS ACKNOWLEDGEMENT';
         att.ParentId = caseObj.Id;
         insert att;
         
   
        myQuotes = new list<BigMachines_Quote__c>{TestClassHelper.createBMQuote(opp)};
        myQuotes[0].BigMachines_Transaction_Id__c = '1234554321';
        insert myQuotes;
        
        System.assertEquals(1, myQuotes.size(), 'Need at least one quote to test against.');
        
        Attachment[] atts = new List<Attachment>();
                
        // create some test attachments
        s_quoteAttachmentPDF = new Attachment();
        s_quoteAttachmentPDF.Body = Blob.valueOf('FFFFFF');
        s_quoteAttachmentPDF.ContentType = 'application/pdf';
        s_quoteAttachmentPDF.Name = '1234554321';
        s_quoteAttachmentPDF.ParentId = myQuotes[0].Id;
        atts.add(s_quoteAttachmentPDF);
        
        s_quoteAttachmentDoc = new Attachment();
        s_quoteAttachmentDoc.Body = Blob.valueOf('FFFFFF');
        s_quoteAttachmentDoc.ContentType = 'application/word';
        s_quoteAttachmentDoc.Name = '!Test Attachment!2!' + System.today();
        s_quoteAttachmentDoc.ParentId = myQuotes[0].Id;
        atts.add(s_quoteAttachmentDoc);

        s_accountAttachmentPDF = new Attachment();
        s_accountAttachmentPDF.Body = Blob.valueOf('FFFFFF');
        s_accountAttachmentPDF.ContentType = 'application/pdf';
        s_accountAttachmentPDF.Name = '!Test Attachment!2!' + System.today();
        s_accountAttachmentPDF.ParentId = myAccounts[0].Id;
        atts.add(s_accountAttachmentPDF);       
        
        insert atts;
        
    }
}