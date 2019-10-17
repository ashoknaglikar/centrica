@isTest

private class viewIdeaHistoryExtension_test 
{
     static testmethod void testMethod1()
        {
          User user = TestClassHelper.createUser();
          insert user;
                    
          Idea ida = TestClassHelper.createidea(user.id);
          insert ida;
          ida.AttachmentBody=Blob.valueOf('FFFFFF');
          ida.AttachmentContentType = 'application/pdf';
          ida.AttachmentName = '1234554321.pdf';
          update ida;
          
          Idea ida1 = TestClassHelper.createidea(user.id);
          insert ida1;
          
          Business_Admin_History__c H = new Business_Admin_History__c(Idea_ref__c = ida.id, from_status__c ='We\'ve got it',To_status__c ='We\'re looking at it');
          Business_Admin_History__c H1 = new Business_Admin_History__c(Idea_ref__c = ida.id, from_status__c ='We\'ve got it',To_status__c ='We\'re looking at it');
          Business_Admin_History__c H2 = new Business_Admin_History__c(Idea_ref__c = ida.id, from_status__c ='We\'ve got it',To_status__c ='We\'re looking at it');
          Business_Admin_History__c H3 = new Business_Admin_History__c(Idea_ref__c = ida.id, from_status__c ='We\'ve got it',To_status__c ='We\'re looking at it');
          Business_Admin_History__c H4 = new Business_Admin_History__c(Idea_ref__c = ida.id, from_status__c ='We\'ve got it',To_status__c ='We\'re looking at it');
          Business_Admin_History__c H5 = new Business_Admin_History__c(Idea_ref__c = ida.id, from_status__c ='We\'ve got it',To_status__c ='We\'re looking at it');
          
          Business_Admin_History__c[] HistoryList = new Business_Admin_History__c[]{H,H1,H2,H3,H4,H5};
          insert HistoryList;
          
          system.assert(Historylist.size()>0,'No history records');
          viewIdeaHistoryExtension  viewidea = new viewIdeaHistoryExtension (new ApexPages.StandardController(ida));
          viewidea.showall();
          
          Business_Admin_History__c H6 = new Business_Admin_History__c(Idea_ref__c = ida1.id, from_status__c ='We\'ve got it',To_status__c ='We\'re looking at it');                                                                  
          insert H6;
          
          viewIdeaHistoryExtension  viewidea1 = new viewIdeaHistoryExtension (new ApexPages.StandardController(ida1));
          viewidea1.showall();
          
          
        }
}