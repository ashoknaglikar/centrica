@isTest

private class viewIdeaExtension_test 
{

     static testmethod void testMethod1()
        {
                
                User user = TestClassHelper.createUser();
                insert user;
                    
                Idea ida = TestClassHelper.createidea(user.id);
                insert ida;
               
                ida.Sub_Status__c='Duplicate';
                ida.AttachmentBody=Blob.valueOf('FFFFFF');
                ida.AttachmentContentType = 'application/pdf';
                ida.AttachmentName = '1234554321.pdf';
                update ida;
                
                viewIdeaExtension  viewidea = new viewIdeaExtension (new ApexPages.StandardController(ida));
                viewidea.createVote() ;
                viewidea.post() ;
                viewidea.Go()  ;
                
         } 
         
      static testmethod void testMethod2()
        {
         
                User user = TestClassHelper.createUser();
                insert user;
                    
                Idea ida = TestClassHelper.createidea(user.id);
                insert ida;
                
                ida.Sub_Status__c='Awaiting publication';
                update ida;
                
                viewIdeaExtension  viewidea = new viewIdeaExtension (new ApexPages.StandardController(ida));
        }
 
 }