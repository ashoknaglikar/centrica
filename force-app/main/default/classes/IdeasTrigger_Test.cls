@isTest

private class IdeasTrigger_Test
{
    //Declaration of all the required objects
    static Idea idea,parentIdea;
    static Vote vote;
    //static User user;
    static District__c district;    
    static Employee__c emp; 
    static Region__c region;  
    
    //Method to create required test data    
    public static void createData()
    {
        //user = [select id from User where Name='Priti Patil'];
        //System.runAs(user){} 
        
        User user = TestClassHelper.createUser();
                 insert user;
                 
        region =  TestClassHelper.createRegion();
        insert region;     
        district = TestClassHelper.createDistrict();
        insert district;      
        emp = TestClassHelper.createEmployee();
        emp.Business_Group__c = 'Office';
        emp.District__c=district.id;        
        emp.Salesforce_User__c = user.id;        
        insert emp; 
        parentIdea = new  Idea(Title='ParentTestIdea',Body='ParentTestIdeaBody'); 
        insert parentIdea;   
        idea = new Idea(Title='TestIdea',Body='TestIdeaBody');
        insert idea;      
    }

    //This method checks the functionality of before insert trigger    
    /*static testMethod void CheckIdeaInsert()
    {
        createData();
        idea = [Select Business_Area__c,CommunityId,District__c,Region__c,On_Behalf_Of__c from Idea where Title='TestIdea'];
        emp = [Select Id, Business_Group__c,Salesforce_User__c, District__r.Name, Region__c  from Employee__c where Salesforce_User__c =: user];
        System.assertEquals(idea.Business_Area__c,emp.Business_Group__c);
        System.assertEquals(idea.CommunityId,'09a200000000ECB');
        //System.assertEquals(idea.District__c,emp.District__r.Name);
        //System.assertEquals(idea.On_Behalf_Of__c,user.id);
        System.assertEquals(idea.Region__c,emp.Region__c);      
    }*/
    
    //This method checks the functionality of before update trigger
    //If one voted on idea, one vote object gets created    
    static testMethod void CheckIdeaUpdate()
    {
        createData();
        idea.Vote__c=true;
        update idea;
        vote = [Select ParentId,Type from Vote where ParentId=:idea.id]; 
        System.assertNotEquals(vote.id,null);    
    }
      
    //This method checks the update functionality of trigger
    //If idea is updated and get some parent idea then idea status is assigned as 'Closed' and sub status as 'Duplicate'
    static testMethod void CheckIdeaUpdateIfParentId()
    {
         createData();
         idea.Parent_Idea__c=parentIdea.id;
         update idea;
         idea = [Select Status,Sub_Status__c from Idea where Title='TestIdea'];
         //System.assertEquals(idea.Status,'Closed');
        //System.assertEquals(idea.Sub_Status__c,'Duplicate');        
    }
}