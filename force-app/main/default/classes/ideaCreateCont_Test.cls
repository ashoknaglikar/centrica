@isTest(SeeAllData=true)

private class ideaCreateCont_Test
{     
     
     static testMethod void ideatest1()
     {   
         Attachment attachment= new Attachment();
         
         User user = TestClassHelper.createUser();        
         insert user;
         
         
         Idea ida = TestClassHelper.createidea(user.id);
         ida.AttachmentBody=Blob.valueOf('FFFFFF');
         ida.AttachmentContentType = 'application/pdf';
         ida.AttachmentName = '1234554321.pdf';
         insert ida;
         
         attachment.body=Blob.valueOf('FFFFFF');
         //attachment.Name='.doc';
        
        
                
         ideaCreateCont controller = new ideaCreateCont();
         controller.post();
   
         
     }

        static testMethod void ideatest2()
     {   
         Attachment attachment = new Attachment();
         
         User user = TestClassHelper.createUser();        
         insert user;
         
         
         Idea ida = TestClassHelper.createidea(user.id);
         ida.AttachmentBody=Blob.valueOf('FFFFFF');
         ida.AttachmentContentType = 'application/pdf';
         ida.AttachmentName = '1234554321.pdf';
         insert ida;
     
         ideaCreateCont controller = new ideaCreateCont();
         attachment.Name='.doc';
        
         controller.post();
         

     }
}