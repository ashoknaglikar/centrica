public with sharing class viewIdeaExtension 
{
    
    public Idea ida{get;set;}
    private ApexPages.StandardController controller{get;set;}
    public IdeaComment comment {get; set;}
    public boolean alreadyliked{get;set;}
    public boolean attachementBln{get;set;}
    public boolean Commentsectionrendered{get;set;}
    public boolean outputlinkforparent{get;set;}
    public boolean Duplicateideamsg{get;set;}
    //public vote vte1{get;set;}


 

        public viewIdeaExtension(ApexPages.StandardController controller)
        {
                  
                   Id currentUserloggedin = userinfo.getuserid();      
                   this.controller= controller;
                   this.ida= (Idea)controller.getRecord();
                   comment = new IdeaComment ();
                   comment.IdeaId = ida.id;
                   ida.On_Behalf_Of__c=Userinfo.getUserId();
                   Commentsectionrendered=true;
                   outputlinkforparent=false;
                   Duplicateideamsg=false;
                   //vte1= new vote();
               
                              
                  this.ida = [SELECT Id,Decimalremove__c,Parent_Idea__c,Status_Indicator__c,Title,Categories,Body,Status,Accepted_Date__c,Business_Area__c,
                              District__c,E_mail_Address__c,Suggesstion__c,Idea_Number__c,No_Of_Votes__c,On_Behalf_Of__c,Others__c,Prioritisation_Score__c,
                              Region__c,Status_Notes__c,Sub_Status__c,Sytem_Affected__c,Vote__c,Reason__c,WithHold_Name__c,
                              Your_Contact_Number__c,Assigned_We_ve_assigned_someone_to_st__c,Awaiting_allocation__c,
                              Awaiting_Reading__c,Complete_Unable_to_Progress__c,Complete_We_ve_completed_it__c,AttachmentName,
                              Duplicate__c,IdeaVF__c,In_progress_We_re_doing_it__c,Sent_for_prioritization__c,CreatedById,
                              Sent_for_review__c FROM Idea WHERE Id = :ida.Id ];              
                    
                   List<Vote> vte=[Select Id, IsDeleted, ParentId, Type, CreatedDate, CreatedById, SystemModstamp From Vote 
                                where CreatedById=:currentUserloggedin and ParentId=:ida.Id];
                                          
                    
                     if(ida.AttachmentName!=null)
                     {
                     	attachementBln = true;
                     }         
                               
                     if(vte.size()>0)

                     {
                      
                       alreadyliked=false;
                      
                     } 
                     else
                     {
                      
                       alreadyliked=true;
                       
                     } 
                     
             if(ida.Sub_Status__c=='Duplicate')
             {
               Commentsectionrendered=false;
               outputlinkforparent=true;
               Duplicateideamsg=true;
             }
             else
             {
               Commentsectionrendered=true;
               outputlinkforparent=false;
               Duplicateideamsg=false;
               
             }
                  
    
        }  

     public PageReference Go() 
   {
         Id id = System.currentPageReference().getParameters().get('id');
         PageReference nextpage = new PageReference('/apex/viewIdea?id='+ida.Parent_Idea__c);
         nextpage.setRedirect(true);
         return nextpage;
    }
  
  
 public void createVote()
 {
 		 ida.Vote__c = true;
         update ida;
         ida = [SELECT Id,Parent_Idea__c,Decimalremove__c,Status_Indicator__c,Title,Categories,Body,Status,Accepted_Date__c,Business_Area__c,
                              District__c,E_mail_Address__c,Suggesstion__c,Idea_Number__c,No_Of_Votes__c,On_Behalf_Of__c,Others__c,Prioritisation_Score__c,
                              Region__c,Status_Notes__c,Sub_Status__c,Sytem_Affected__c,Vote__c,Reason__c,WithHold_Name__c,
                              Your_Contact_Number__c,Assigned_We_ve_assigned_someone_to_st__c,Awaiting_allocation__c,
                              Awaiting_Reading__c,Complete_Unable_to_Progress__c,Complete_We_ve_completed_it__c,AttachmentName,
                              Duplicate__c,IdeaVF__c,In_progress_We_re_doing_it__c,Sent_for_prioritization__c,CreatedById ,
                              Sent_for_review__c FROM Idea WHERE Id = :ida.Id ];  
         system.debug('@@@@@update ida'+ida);
         alreadyliked=false;
        
           
 }   
             
    public PageReference post()
        {
            insert comment;
            comment = new IdeaComment();
            comment.IdeaId = ida.id;
            pagereference redirect = new PageReference('/apex/viewIdea?id='+ida.id);
            redirect.setRedirect(true);
            return redirect;
            
        }
            
}