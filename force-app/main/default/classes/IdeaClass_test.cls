@isTest
private class IdeaClass_test 

{

    static testMethod void ideatest1() 
    {
        User user = TestClassHelper.createUser();
        insert user;
       
       Idea ida = TestClassHelper.createidea(user.id);
       insert ida; 
     
       IdeaComment iComm = new IdeaComment(IdeaId = ida.Id);
       iComm.CommentBody = ' I like this idea';
       insert iComm;

       ideaClass idclass= new ideaClass(ida);
       

     }
    
    static testMethod void ideatest2() 
    {
       User user1 = TestClassHelper.createUser();
       insert user1;
        
       Idea ida = TestClassHelper.createidea(user1.id);
       ida.Body='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
       ida.WithHold_Name__c=true;
       ida.Vote__c=true;
       insert ida;   
      
       IdeaComment iComm = new IdeaComment(IdeaId = ida.Id);
       iComm.CommentBody = ' I like this idea';
       insert iComm;
       ideaClass idclass= new ideaClass(ida);
       

     }
    
}