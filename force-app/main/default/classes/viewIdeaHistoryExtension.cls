public class viewIdeaHistoryExtension{

 
    public Idea ida{get;set;}
    public integer pagesize{get;set;}
    public integer Total_size{get;set;}
    public boolean showall{get;set;}
    public list<Business_Admin_History__c> History{get;set;} 
    private ApexPages.StandardController controller{get;set;}

    public viewIdeaHistoryExtension(ApexPages.StandardController controller)
        {
                   pagesize = 5;
                   Id currentUserloggedin = userinfo.getuserid();      
                   this.controller= controller;
                   this.ida= (Idea)controller.getRecord();
                   ida.On_Behalf_Of__c=Userinfo.getUserId();
                   system.debug('##id'+ida);
                   Total_size=[select count() from Business_Admin_History__c where Idea_ref__c=:ida.id]; //get the count of all History records for the current id 
                   if(total_size >5)
                   showall = true; //to show the link in vfpage
                   else{
                   showall = false;
                   }
                   RunQuery();
                   
    
        } 
        
    public void RunQuery(){
      History = [select id,name,CreatedByID,CreatedDate,idea_Ref__c,from_status__c,To_status__c from Business_Admin_history__c where idea_ref__c =:ida.Id order by CreatedDate DESC ];    
    } 
    public void showall(){
        pagesize = total_size; 
        RunQuery();
        showall = false;
    }
  

}