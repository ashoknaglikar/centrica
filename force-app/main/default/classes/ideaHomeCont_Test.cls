@isTest

private class ideaHomeCont_Test
{
    
     static testMethod void ideatest1()
      {
         User user = TestClassHelper.createUser();        
         insert user;
         Idea idea = new Idea(Title='TestIdea',Body='TestIdeaBody');
         insert idea;
         //Attachment att = new Attachment(Body = Blob.valueOf('FFFFFF'),ContentType = 'application/pdf',Name = '1234554321.pdf',ParentId = idea.id);
         //insert att;        
         ideaHomeCont controller = new ideaHomeCont();
         PageReference pageRef = page.IdeasHome; 
         Test.setCurrentPage(pageRef);
         controller.createNewIdea();
         controller.post();
         
         controller.newidea.title = 'Test';
         controller.FindDuplicates();
         controller.newidea.Body = 'Test Record';
         controller.attachment.body = Blob.valueOf('FFFFFF');
         controller.attachment.Name = '1234554321.pdf';
         controller.post();
         /*idea = [Select Status,AttachmentBody,AttachmentName,AttachmentContentType from Idea where AttachmentName='1234554321.pdf'];         
         System.assertEquals(page,null);  
         System.assertNotEquals(idea.id,null);*/
      } 
    /*
    static testMethod void ideatest2()
     {
         User user = TestClassHelper.createUser();        
         insert user;
         Idea idea = new Idea(Title='TestIdea',Body='TestIdeaBody');
         insert idea;        
         Attachment att = new Attachment(Body = Blob.valueOf('FFFFFF'),ContentType = 'application/pdf',Name = '1234554321.pdf',ParentId = idea.id);
         insert att;
         ideaHomeContcontroller = new ideaHomeCont();
         controller.draft();
         idea = [Select Status from Idea where AttachmentName='1234554321.pdf'];
         System.assertNotEquals(idea.Status,'Draft');     
     } */
      
     static testMethod void ideatest3()
       {
          ideaHomeCont controller = new ideaHomeCont();
          controller.createNewIdea();
          System.assertEquals(controller.createNew,true);          
       } 
        
      static testMethod void ideatest4()
       {
          ideaHomeCont controller = new ideaHomeCont();
          controller.cancelIdea();
          System.assertEquals(controller.createNew,false);          
       } 
        
      static testMethod void ideatest5()
       {
          ideaHomeCont controller = new ideaHomeCont();
          controller.getoptions();          
          controller.likeIdea();          
       } 
        
      static testMethod void ideatest6()
       {
          ideaHomeCont controller = new ideaHomeCont();
          controller.populateALlideas();
          System.assertEquals(controller.createNew,false); 
          System.assertEquals(controller.viewName ,'All Ideas');        
       }
       
      static testMethod void ideatest7()
       {
          ideaHomeCont controller = new ideaHomeCont();
          controller.populateDistrictView();
          System.assertEquals(controller.createNew,false); 
          System.assertEquals(controller.viewName ,'My Office Ideas');        
       }
       

     static testMethod void ideatest8()
       {
          ideaHomeCont controller = new ideaHomeCont();
          controller.populateMYideas();
          System.assertEquals(controller.createNew,false); 
          System.assertEquals(controller.viewName ,'My Ideas');        
       }
       
    static testMethod void ideatest9()
       {
          ideaHomeCont controller = new ideaHomeCont();
          controller.Beginning();
          controller.Next();
          controller.Previous();
          controller.End();
          controller.Next();
          controller.getDisablePrevious();
          controller.getDisableNext();
          controller.getPageNumber();
          controller.getTotalPages();      
       }
       
    static testMethod void ideatest10()
       {
          ideaHomeCont controller = new ideaHomeCont();
          controller.getoptions();
          controller.populateFilter();
          //Added by Ashok G
          controller.selected = 'Most Recent';
          controller.Filter = 'Open';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newidea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          
          controller.newIdea.sub_status__c = 'We\'ve got it';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          controller.Filter = 'All Ideas';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
                    
          controller.newIdea.sub_status__c = null;
          controller.populateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
       }
       
   static testMethod void ideaTest12(){
      
          ideaHomeCont controller = new ideaHomeCont();
          controller.getoptions();
          controller.populateFilter();
          //Added by Ashok G
          controller.selected = 'Most Popular';
          controller.Filter = 'Open';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newidea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          
          controller.newIdea.sub_status__c = 'We\'ve got it';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          controller.Filter = 'All Ideas';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
                    
          controller.newIdea.sub_status__c = null;
          controller.populateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
   
   }
   
    static testMethod void ideatest13()
       {
          ideaHomeCont controller = new ideaHomeCont();
          controller.getoptions();
          controller.populateFilter();
          controller.Viewname = 'My Ideas';
          controller.selected = 'Most Recent';
          controller.Filter = 'Open';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newidea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          
          controller.newIdea.sub_status__c = 'We\'ve got it';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          controller.Filter = 'All Ideas';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
                    
          controller.newIdea.sub_status__c = null;
          controller.populateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
       }
       
   static testMethod void ideaTest14(){
      
          ideaHomeCont controller = new ideaHomeCont();
          controller.getoptions();
          controller.populateFilter();
          controller.Viewname = 'My Ideas';
          controller.selected = 'Most Popular';
          controller.Filter = 'Open';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newidea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          
          controller.newIdea.sub_status__c = 'We\'ve got it';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          controller.Filter = 'All Ideas';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
                    
          controller.newIdea.sub_status__c = null;
          controller.populateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
   
   }
   
   
    static testMethod void ideatest15()
       {
          ideaHomeCont controller = new ideaHomeCont();
          controller.getoptions();
          controller.populateFilter();
          controller.Viewname = 'My Office Ideas';
          controller.selected = 'Most Recent';
          controller.Filter = 'Open';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newidea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          
          controller.newIdea.sub_status__c = 'We\'ve got it';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          controller.Filter = 'All Ideas';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
                    
          controller.newIdea.sub_status__c = null;
          controller.populateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
       }
       
   static testMethod void ideaTest16(){
      
          ideaHomeCont controller = new ideaHomeCont();
          controller.getoptions();
          controller.populateFilter();
          controller.Viewname = 'My Office Ideas';
          controller.selected = 'Most Popular';
          controller.Filter = 'Open';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newidea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          
          controller.newIdea.sub_status__c = 'We\'ve got it';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
          
          controller.Filter = 'All Ideas';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = 'Office';
          controller.PopulateFilter();
          
          controller.newidea.Department__c = null;
          controller.PopulateFilter();
                    
          controller.newIdea.sub_status__c = null;
          controller.populateFilter();
          
          controller.newidea.Department__c = 'Hsc';
          controller.PopulateFilter();
          
          controller.newIdea.Business_Area__c = null;
          controller.PopulateFilter();
          
   
   }
   
}