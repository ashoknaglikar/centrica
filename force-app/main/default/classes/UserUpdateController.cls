public class UserUpdateController {

// Created By Phil Dennison 04-May-2009
// This is the controller for the UserUpdate screen.  This screen has been created to allow none admin users to update.
// user sales and survey districts without having access to the full 'User' screeen.

user userSelected;

    //Get the details for the user using the id passed via the URL for use on page.
    public user getuserSelected(){
        userSelected = [select id, isActive, name, EmployeeNumber, 
                        Pool_User__c, sales_district__c, survey_district__c
                        from user
                        where id = :ApexPages.currentPage().getParameters().get('id')];
  
        return userSelected;
    }
  
    // Save any changes made and return user to the previous employee page.  
    public PageReference save(){
    // update the amended details to the database.
        update userSelected;
                
        PageReference userdetail = new PageReference('/' + ApexPages.currentPage().getParameters().get('previd'));
        userdetail.setRedirect(true);
        return userdetail;    
    }
    
    // Return user to the previous employee page without saving changes.
    public PageReference cancel(){
    PageReference userdetail = new PageReference('/' + ApexPages.currentPage().getParameters().get('previd'));
    userdetail.setRedirect(true);
    return userdetail;
    }
        
      
}