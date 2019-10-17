public with sharing class publishidea 
{ 
    
        private ApexPages.StandardController stdController{get;set;}
        public Idea ida{get;set;}
        public boolean Adminsection {get;set;}
        public boolean savebutton {get;set;}
        public boolean editbutton {get;set;}
        public boolean flag{get;set;}
        public boolean cancelbutton {get;set;}
        public boolean IdeaComment{get;set;}  
        public boolean status{get;set;} 
        public boolean Statusupdate{get;set;} 
        public boolean Idacmmnt{get;set;} 
        public IdeaComment comment {get; set;}
        public integer pagesize{get;set;} // change by Ashok G -- CR 1352
        public integer Total_size{get;set;}
        public boolean showall{get;set;}
        public boolean IdeaHistory{get;set;}
        public list<Business_Admin_History__c> History{get;set;}  //Change End
        public list<Idea> IdeaList{get;set;}
        public boolean ARow{get;set;}
        public list<Idea> RelatedIdeas{get;set;}
        public boolean childRec{get;set;}
        public list<string> userids{get;set;}
        
        
      public publishidea(ApexPages.StandardController stdController) 
        
        {     
              ARow = False;
              flag=false;  
              editbutton=true;
              savebutton=false;
              cancelbutton =false;
              IdeaComment=true;
              status=true;
              Statusupdate=true;
              childRec = false;
              //Cr -1352
              pagesize = 5;
              IdeaHistory = false;
              showall = false;
              //End
              IdeaList = new list<Idea>();
              System.debug('@@@ entering in the const');
              
              this.stdController = stdController;
              this.ida= (Idea)stdController.getRecord();
        
              this.ida = [SELECT Id,Status_Indicator__c,Title,Categories,Body,Status,Accepted_Date__c,Business_Area__c,
                            District__c,E_mail_Address__c,Suggesstion__c,Idea_Number__c,No_Of_Votes__c,On_Behalf_Of__c,Others__c,Prioritisation_Score__c,
                            Region__c,Status_Notes__c,Sub_Status__c,Sytem_Affected__c,Vote__c,Reason__c,WithHold_Name__c,
                            Your_Contact_Number__c,Assigned_We_ve_assigned_someone_to_st__c,Awaiting_allocation__c,
                            Awaiting_Reading__c,Complete_Unable_to_Progress__c,Complete_We_ve_completed_it__c,
                            Duplicate__c,IdeaVF__c,In_progress_We_re_doing_it__c,Sent_for_prioritization__c,Department__c,
                            Sent_for_review__c,send_email__c,Contact__c,Recorded_Date__c,Work_Product__c,Final_Resolution_Answer__c FROM Idea WHERE Id = :ida.Id ];
                            
                         system.debug('@@@@this.ida'+this.ida);  
              //CR - 1352 Change by Ashok G           
              Total_size=[select count() from Business_Admin_History__c where Idea_ref__c=:ida.id]; //get the count of all History records for the current id 
              if(total_size >5)
              showall = true; //to show the link in vfpage
              else{
               showall = false;
              }
               RunQuery(); 
               RunRelatedQuery();
              //End
   
  }

  
              
      public PageReference editidea() 
      
      {  
           savebutton=true;
           flag=true;
           cancelbutton=true;
           IdeaComment=false;
           status=false;
           Statusupdate=true;


           PageReference page1 = new Pagereference('/apex/EditPage?Id='+ida.Id);
           editbutton=false;
           return page1;
           
            
      }
            
      public PageReference saveidea() 
      
      {   
                
               flag = false;
               savebutton=false;
               editbutton=true;
               cancelbutton=false;
               IdeaComment=true;
               status=true;
                    
               this.ida= (Idea)stdController.getRecord();
               if(ida.send_email__c && childRec){
                  system.debug('---------------------');  
                    
                    EmailTemplate templateId = [Select id from EmailTemplate where name = 'Idea Email template'];
                    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                    for(string str:userids){
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templateId.Id); 
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(str);
                    allmsg.add(mail);
                    }
                    Messaging.sendEmail(allmsg,false); 
               
               }
               
               this.stdController.save(); 
                
               PageReference newPage = New PageReference('/apex/EditPage');
               newPage.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
               newPage.setRedirect(true);
               return newPage;
               
               //update ida; 
               //pagereference redirect = new PageReference('/apex/EditPage?id='+ida.id);
               //redirect.setRedirect(true);
               //return redirect;            
             
     }
     
     public Pagereference cancelidea()
     
     {
            flag = false;
            savebutton =false;
            editbutton=true;
            cancelbutton=false;
            IdeaComment=true;
            status=true;
            Statusupdate=true;
            PageReference page3 = new Pagereference('/apex/EditPage?Id='+ida.Id);
            return page3;
     }
     
     //Change By Ashok G..
    public void RunQuery(){
      History = [select id,name,CreatedByID,CreatedDate,idea_Ref__c,from_status__c,To_status__c from Business_Admin_history__c where idea_ref__c =:ida.Id order by CreatedDate DESC LIMIT :pagesize];    
      if(History.size()>0)
      IdeaHistory = True;
      else 
      IdeaHistory = False;
      
    } 
    
    public void RunRelatedQuery(){
       RelatedIdeas = [SELECT Id,Idea_Number__c,status,Region__c,Accepted_Date__c,createdByID,On_Behalf_Of__c,createddate FROM Idea WHERE Parent_Idea__c = :ApexPages.currentPage().getParameters().get('id')];
               
       if(RelatedIdeas.size()>0){
       ChildRec = TRUE;
       userids = new list<string>();
       for(Idea RIda: RelatedIdeas){
         userids.add(RIda.On_Behalf_Of__c);  
       }
       }
       else
       ChildRec = FALSE;
    }
    
    /*public void DefaultIdea(){
    this.ida= (Idea)stdController.getRecord(); 
    system.debug('++++++++++++++++++++++++'+ida.Make_this_a_Parent_Idea__c);
      if(ida.Make_this_a_Parent_Idea__c)
      {
      Arow=true;
      Idea Ide = new Idea();
      IdeaList.add(Ide);
      }
      else{
       ARow = false;
       IdeaList.clear();
      }
    }
    
    public void AddRow(){
      Idea Ide = new Idea();
      IdeaList.add(Ide);
    }
    
    Public void RemoveRow(){
      integer count= IdeaList.size()-1;
      IdeaList.remove(count);
          if(Count==0){
           ARow=false;
           IdeaList.clear();
          }
    }
     */  
   //End
}