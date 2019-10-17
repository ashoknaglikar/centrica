public without sharing class ideaHomeCont {
    
  
    public idea newidea {get;set;}
    public boolean showSub {get;set;}
    public boolean createNew{get;set;}
    public boolean aftPub{get;set;}
    public string message{get;set;}
    Utilities util = new Utilities();
    public string buttonName {get;set;}
    
    public string newIdeaStyle{get;set;}
    public string allIdeasStyle {get;set;}
    public string myIdeastyle{get;set;}
    public string myDistrictStyle {get;set;}
    public list<Idea> duplicateIdeas{get;set;}
    public boolean enableDe{get;set;} 
   
    public Attachment attachment {
        get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
        }
      set;
      }
   
   
   
    public list<selectoption> getoptions()
    {
        list<selectoption> temp = new list<selectoption> ();
        temp.add(new SelectOption('Most Recent', 'Most Recent'));
        temp.add(new SelectOption('Most Popular', 'Most Popular'));
        return  temp;
        
    }   
    //CR - 001352 Change by Ashok G
    public list<selectOption> getoptions1(){
    
        list<selectoption> temp1 = new list<selectoption> ();
        temp1.add(new SelectOption('All Ideas', 'All Ideas'));
        temp1.add(new SelectOption('Open', 'Open'));
        temp1.add(new SelectOption('Closed', 'Closed'));
        return  temp1;
    
    }
    //end
    
  
    public string Selected {get;set;}
    public string Filter {get;set;}
    public string Stage {get;set;} //Change added by Ashok G
    public string Dept {get;set;} //-- This holds Business Area Change added by Ashok G
    public string Dept1 {get;set;} // This Holds Department
    public boolean OfficeIdea {get;set;}
    public list<ideaClass> ideasClassList {get;set;}
    
    
    
    // Local Variables
    boolean updated =false;
    public integer pageSize {get;set;}
    string ideaSoql = 'Select i.Vote__c, i.Title, i.Status, i.ParentIdeaId, i.NumComments, i.No_Of_Votes__c,NextNoofLikes__c,'+ 
      'i.Idea_Number__c, i.CreatedDate, i.CreatedById,Decimalremove__c, i.Body,Published__c,WithHold_Name__c,Submitters_Name__c,Sub_Status__c,Final_Resolution_Answer__c,Business_Area__c,Department__c' +
      ' From Idea i where Published__c = true';
    
     string ideaSoql2 = 'Select i.Vote__c, i.Title, i.Status, i.ParentIdeaId, i.NumComments, i.No_Of_Votes__c,NextNoofLikes__c,'+ 
      'i.Idea_Number__c, i.CreatedDate, i.CreatedById,Decimalremove__c, i.Body,Published__c,WithHold_Name__c,Submitters_Name__c,Sub_Status__c,Final_Resolution_Answer__c,Business_Area__c,Department__c' +
      ' From Idea i';
     
    string orderbyAccDate =  ' Order by Accepted_Date__c Desc';
    string orderByLikes = ' Order by No_Of_Votes__c Desc';
    string orderByCreated = ' Order By CreatedDate Desc';
    string orderBYLikes2 = ' Order By CreatedDate Desc';
    string orderByPublished = ' AND status =\'Open\'';
    string orderByClosed = ' AND status =\'Closed\'';
    string orderByFilter = ' AND status ='+':Filter';//Added bY Ashok G
    string orderByDept = ' AND Business_Area__c='+':Dept';
    string orderByStage = ' AND Sub_Status__c ='+':stage';
    string orderByDept1 = ' AND Department__c ='+':Dept1';
    
    
    Id userId  = userinfo.getUserId();
    string createdby = ' and CreatedById = : userId';
    string DistrictCri = ' and District__c = :district';
    string finalQuery = ideaSoql+orderbyAccDate;
    string VOTEqUERY = 'Select id, ParentId from Vote where Parent.Type =  \'Idea\' and CreatedById = :userId ';
    string Offset= ' OFFSET :counter';
    string LimitString = ' LIMIT : pageSize';
    public string viewName{get;set;}
    List<Ideas>  ideaList = new List<Ideas> ();
    string district ='';
    string genericStyle = 'background:#3498db;background-image: -webkit-linear-gradient(top, #3498db, #2980b9);background-image: -moz-linear-gradient(top, #3498db, #2980b9); background-image: -ms-linear-gradient(top, #3498db, #2980b9);'+
        'background-image: -o-linear-gradient(top, #3498db, #2980b9);  background-image: linear-gradient(to bottom, #3498db, #2980b9);  -webkit-border-radius: 28;'+
        '  -moz-border-radius: 28;  border-radius: 28px;  font-family: calibri;  color: #ffffff;  font-size: 15px; padding: 10px 20px 10px 20px;  text-decoration: none;';
    string background = 'background:#A40000;'; //#3498db;;
    string changedStyle = 'background:#A3D119;background-image: -webkit-linear-gradient(top, #A3D119, #A3D119);background-image: -moz-linear-gradient(top, #A3D119, #A3D119); background-image: -ms-linear-gradient(top, #A3D119, #A3D119);'+
        'background-image: -o-linear-gradient(top, #A3D119, #A3D119);  background-image: linear-gradient(to bottom, #A3D119, #A3D119);  -webkit-border-radius: 28;'+
        '  -moz-border-radius: 28;  border-radius: 28px;  font-family: calibri;  color: #ffffff;  font-size: 15px; padding: 10px 20px 10px 20px;  text-decoration: none;';      
      public ideaHomeCont()
      {
        //set the style for the button
        allIdeasStyle = changedStyle;
        myIdeastyle = genericStyle;
        myDistrictStyle = genericStyle;
        newIdeaStyle = genericStyle;
        duplicateIdeas = new list<idea>();
        
        officeIdea = false; //added by Ashok G
        EnableDe = false;
        
        pageSize = 20;
        newidea = new Idea(); 
        total_size = [select count() from Idea where Published__c = true]; //set the total size in the constructor
          
        list<Employee__c> Emp = [Select id, Business_Group__c, District__c,  District__r.Name from Employee__c where Salesforce_User__c =:userId ];
        system.debug('####Emp:'+Emp);
        district = 'Office';
        buttonName = 'My Office Ideas';
        if(Emp.size()>0 && Emp[0].District__c!=null)
        {
          district =  Emp[0].District__r.Name;
          buttonName = 'My District Ideas';
        }
        
        finalQuery = ideaSoql + orderbyAccDate+LimitString+Offset;
        runQuery();
        viewName = 'All Ideas';
        newidea = new Idea();
        
        if(System.currentPageReference().getParameters().get('s') == 's')
        {
            message = 'Sucessfully Posted';
            util.setErrorMsg(false, message);
        }
      }
      
    // ************************************ 
    public pagereference post()
    {
      
       try {
            
           if(newidea.Body==null)
           {
            util.setErrorMsg(true, 'Please Enter some Body.');
            return null;
           }
            
            newidea.Status = 'Submitted';
            string contentype = 'image/jpeg';
           
           if(attachment.body!=null)
           {
            if(attachment.Name.contains('.doc')||attachment.Name.contains('.dox'))
            {
                
                contentype = 'application/msword';

            }else if(attachment.Name.contains('.pdf'))
            {
                contentype = 'application/pdf';
            }
            newIdea.AttachmentBody = attachment.body;
            newIdea.AttachmentName   = attachment.Name;
            newIdea.AttachmentContentType   = contentype;
           }   
            system.debug('--->'+newidea);
            system.debug('--->'+newidea.Department__c);
            system.debug('--->'+attachment + attachment.body);
            insert newidea;
            
            newidea = new Idea();
            showSub = false;
            aftPub = true;
            message = 'Sucessfully Posted';
            util.setErrorMsg(false, message);
            createNew = false;
            runQuery();
            attachment = new Attachment();
            pagereference p = new pagereference ('/apex/IdeasHome?s=s');
            p.setredirect(true);
            return p;
           
        }catch (Exception e){
            message = 'Oops.... Somethinng went wrong!';
            util.setErrorMsg(false, message+' '+ e.getMessage());
            return null;
        }
    }
    
    public void draft()
    {
        showSub = true;
        aftPub = true;
        newidea.Status = 'Draft';
        insert newidea;
    }
       
    public void createNewIdea()
    {
        allIdeasStyle = genericStyle;
        myIdeastyle = genericStyle;
        myDistrictStyle = genericStyle;
        newIdeaStyle = changedStyle;
        newidea = new Idea();
        newidea.On_Behalf_Of__c = userinfo.getuserid();

        createNew =true; 
    }    
    
    public void cancelIdea()
    {
        createNew = false;
    }  
    
    public void likeIdea()
    {
        for(ideaClass i: ideasClassList)
        {
            if(i.selected)
            {
                system.debug('Idea before upDate-->'+ i);
                i.presentIdea.Vote__c = true;
                i.likeBln =false;
                update i.presentIdea;
                i.selected =false;
                i.likes = i.presentIdea.NextNoofLikes__c;
                system.debug('Idea after update-->'+ i);
                break;
            }   
        }
        
    }    
    
    public void populateALlideas()
    {
        counter = 0;
        allIdeasStyle = changedStyle;
        myIdeastyle = genericStyle;
        myDistrictStyle = genericStyle;
        newIdeaStyle = genericStyle;
        total_size = database.query(ideaSoql + orderbyAccDate).size();
        createNew =false; 
        viewName = 'All Ideas';
        finalQuery = ideaSoql + orderbyAccDate + LimitString + Offset;
        runQuery();
        
    }
    
    public void populateDistrictView()
    {
      counter = 0;  
      allIdeasStyle = genericStyle;
      myIdeastyle = genericStyle;
      myDistrictStyle = changedStyle;
      newIdeaStyle = genericStyle;
      total_size = database.query(ideaSoql + DistrictCri + orderbyAccDate).size();  
      createNew =false; 
      OfficeIdea = TRUE; //Added by Ashok G
      viewName = 'My Office Ideas';
      if(district!='Office')
      {
        viewName = 'My Office Ideas: ' +district;
      }
      finalQuery = ideaSoql + DistrictCri + orderbyAccDate + LimitString + Offset; 
      runQuery();
    }
    
    public void populateMYideas()
    {
        counter =0;
        allIdeasStyle = genericStyle;
        myIdeastyle = changedStyle;
        myDistrictStyle = genericStyle;
        newIdeaStyle = genericStyle;
        total_size = database.query(VOTEqUERY).size();  
        createNew =false; 
        viewName = 'My Ideas';
        finalQuery = VOTEqUERY+ orderByCreated + LimitString + Offset;
        runQuery();
        
    } 
    
    
   //Change Cr - 1352 start 
   public void populateFilter()
    {
        if(Selected == 'Most Recent')
        {
            finalQuery = ideaSoql +  orderbyAccDate + LimitString +Offset;
            if(viewName != null)
            {
                system.debug('View Name-->'+viewName);
                if(viewName.contains('District') )
                {
                    finalQuery = ideaSoql + DistrictCri +orderbyAccDate + LimitString +Offset;
                }else if(viewName.contains('My') )
                {
                    finalQuery = VOTEqUERY+ orderByCreated + LimitString + Offset;
                }
                system.debug('finalQuery-->'+finalQuery);
            }
            
        //runQuery();
        populateFilter1();
        }else if(Selected == 'Most Popular')
        {
            finalQuery = ideaSoql +  orderByLikes+ LimitString +Offset;
            
            if(viewName != null)
            {
                if(viewName.contains('District') )
                {
                    finalQuery = ideaSoql + DistrictCri +orderByLikes + LimitString +Offset;
                }else if(viewName.contains('My') )
                {
                    finalQuery = VOTEqUERY+ orderByCreated + LimitString + Offset;
                }
                
            }
          //runQuery(); 
          populateFilter1();  
        }
        
    }  
    
    public void populateFilter1()
    {   
        system.debug('------------------------------>'+newIdea.sub_status__c);
        system.debug('------------------------------>'+newIdea.Business_Area__c);
        system.debug('------------------------------->'+newIdea.Department__c);
        
        Stage=newIdea.sub_status__c;
        Dept = newIdea.Business_Area__c;
        Dept1 = newIdea.Department__c;
        if(stage == null )
        stage='--None--';
        
        if(Dept == null){
            Dept='--None--';
            enableDe = false;
            Dept1='--None--';
        }else if(Dept=='Office'){
            enableDe = True;
            
        }else{
            enableDe = false;
            Dept1='--None--';
        }
        
        if(Dept1 == null)
        Dept1='--None--';
        
        runQuery();
        
             
    }
    
    public void populateFilter2()
    {   
        runQuery();
             
    }    
    
    // change End - By Ashok G
    
     //*********************************** New Code**********************************
    
    
    
   private integer counter=0;  //keeps track of the offset
   
   public integer total_size; //used to show user the total size of the list
   
   public PageReference Beginning() { //user clicked beginning
      counter = 0;
      runQuery();
      return null;
   }
 
   public PageReference Previous() { //user clicked previous button
      counter -= pageSize;
      runQuery();
      //populateFilter1();
      return null;
   }
 
   public PageReference Next() { //user clicked next button
      
      counter += pageSize;
      runQuery();
      //populateFilter1();
      return null;
   }
 
   public PageReference End() { //user clicked end
      counter = total_size - math.mod(total_size, pageSize);
      runQuery();
      return null;
   }
 
   public Boolean getDisablePrevious() {
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }
 
   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + pageSize < total_size) return false; else return true;
   }
 
   public Integer getTotal_size() {
      return total_size;
   }
 
   public Integer getPageNumber() {
      return counter/pageSize + 1;
   }
 
   public Integer getTotalPages() {
      if (math.mod(total_size, pageSize) > 0) {
         return total_size/pageSize + 1;
      } else {
         return (total_size/pageSize);
      }
   }
   
   
   public void runQuery()
    {   
    
       system.debug('-----RunQuery'+stage+' '+Dept+' '+Dept1);
        list<Id> ideaIds = new list<Id>(); 
        string listCriteria  = ' Where Id in:ideaIds';
        if(viewName == 'All Ideas')
        {
            finalQuery = ideaSoql + orderbyAccDate+ LimitString + Offset;
            if(Selected == 'Most Recent'){
                //finalQuery = ideaSoql + listCriteria + orderbyAccDate;
                if(Filter == 'Open' || Filter == 'Closed' ){
                  if(stage == '--None--'){
                   system.debug('Inside stage None');
                      if(Dept == '--None--'){
                        if(Dept1 == '--None--'){
                             total_size = database.query(ideaSoql + orderByFilter + orderbyAccDate).size();
                             finalQuery = ideaSoql + orderByFilter + orderbyAccDate + LimitString +Offset;
                         }else{
                             total_size = database.query(ideaSoql + orderByFilter + orderByDept1 + orderbyAccDate).size();
                             finalQuery = ideaSoql + orderByFilter + orderByDept1 + orderbyAccDate + LimitString +Offset;
                         }
                      }else{
                        system.debug('Inside Dept not equal none');
                          if(Dept1 == '--None--'){
                              total_size = database.query(ideaSoql + orderByFilter + orderByDept + orderbyAccDate).size();
                              finalQuery = ideaSoql + orderByFilter + orderByDept + orderbyAccDate + LimitString +Offset;
                          }else{
                            system.debug('inside Dept1 which is not eual none');
                              total_size = database.query(ideaSoql + orderByFilter + orderByDept + orderByDept1 + orderbyAccDate).size();
                              finalQuery = ideaSoql + orderByFilter + orderByDept + orderByDept1 + orderbyAccDate + LimitString +Offset;
                           system.debug('finalQuery:'+finalQuery);
                          }
                      }
                  }
                  else{
                      if(Dept == '--None--'){
                         if(Dept1 == '--None--'){
                              total_size = database.query(ideaSoql + orderByFilter + orderByStage + orderbyAccDate).size();
                              finalQuery = ideaSoql + orderByFilter + orderByStage + orderbyAccDate + LimitString +Offset;
                         }else{
                              total_size = database.query(ideaSoql + orderByFilter + orderByStage + orderByDept1 + orderbyAccDate).size();
                              finalQuery = ideaSoql + orderByFilter + orderByStage + orderByDept1 + orderbyAccDate + LimitString +Offset;
                         }
                      
                      
                      }else{
                         if(Dept1 == '--None--'){
                              total_size = database.query(ideaSoql + orderByFilter + orderByStage + orderByDept +orderbyAccDate).size();
                              finalQuery = ideaSoql + orderByFilter + orderByStage + orderByDept + orderbyAccDate + LimitString +Offset;
                         }else{
                             total_size = database.query(ideaSoql + orderByFilter + orderByStage + orderByDept + orderByDept1 +orderbyAccDate).size();
                             finalQuery = ideaSoql + orderByFilter + orderByStage + orderByDept + orderByDept1 + orderbyAccDate + LimitString +Offset;
                         }
                      }
                  }
                }
                
                else if(Filter == 'All Ideas'){
                  if(stage == '--None--' || stage == Null){
                     if(Dept == '--None--' || Dept == Null){
                       if(Dept1 == '--None--'|| Dept1 == Null){
                          system.debug('--------------------RUN QUERY'+total_size+' '+finalQuery);
                          total_size = database.query(ideaSoql + orderbyAccDate).size();
                          finalQuery = ideaSoql + orderbyAccDate+ LimitString + Offset;
                       }else{
                          total_size = database.query(ideaSoql + orderByDept1 +orderbyAccDate).size();
                          finalQuery = ideaSoql + orderByDept1 + orderbyAccDate+ LimitString + Offset;
                       }
                     }else{
                         if(Dept1 == '--None--'){
                           total_size = database.query(ideaSoql + orderbyDept +orderbyAccDate).size();
                           finalQuery = ideaSoql + orderBydept + orderbyAccDate+ LimitString + Offset;
                         }else{
                           total_size = database.query(ideaSoql + orderbyDept + orderByDept1 +orderbyAccDate).size();
                           finalQuery = ideaSoql + orderBydept + orderByDept1 + orderbyAccDate+ LimitString + Offset;
                         }
                     }
                  }
                  else{
                    if(Dept == '--None--'){
                      if(Dept1 == '--None--'){
                        total_size = database.query(ideaSoql + orderByStage +orderbyAccDate).size();
                        finalQuery = ideaSoql + orderByStage + orderbyAccDate+ LimitString + Offset;
                      }else{
                        total_size = database.query(ideaSoql + orderByStage + orderByDept1 +orderbyAccDate).size();
                        finalQuery = ideaSoql + orderByStage + orderByDept1 + orderbyAccDate + LimitString + Offset;
                      }
                     }else{
                       if(Dept1 == '--None--'){
                        total_size = database.query(ideaSoql + orderByStage + orderByDept + orderbyAccDate).size();
                        finalQuery = ideaSoql + orderByStage + orderByDept + orderbyAccDate+ LimitString + Offset;
                       }else{
                        total_size = database.query(ideaSoql + orderByStage + orderByDept + orderByDept1 + orderbyAccDate).size();
                        finalQuery = ideaSoql + orderByStage + orderByDept + orderByDept1 + orderbyAccDate+ LimitString + Offset;
                       }
                     }
                   }
                }
            }
            else if(Selected == 'Most Popular'){
            //finalQuery = ideaSoql + orderbyLikes+ LimitString + Offset;
            if(Filter == 'Open' || Filter == 'Closed' ){
                  if(stage == '--None--'){
                      if(Dept == '--None--'){
                        if(Dept1 == '--None--'){
                             total_size = database.query(ideaSoql + orderByFilter + orderbyLikes).size();
                             finalQuery = ideaSoql + orderByFilter + orderbyLikes + LimitString +Offset;
                         }else{
                             total_size = database.query(ideaSoql + orderByFilter + orderByDept1 + orderbyLikes).size();
                             finalQuery = ideaSoql + orderByFilter + orderByDept1 + orderbyLikes + LimitString +Offset;
                         }
                      }else{
                          if(Dept1 == '--None--'){
                              total_size = database.query(ideaSoql + orderByFilter + orderByDept + orderbyLikes).size();
                              finalQuery = ideaSoql + orderByFilter + orderByDept + orderbyLikes + LimitString +Offset;
                          }else{
                              total_size = database.query(ideaSoql + orderByFilter + orderByDept + orderByDept1 + orderbyLikes).size();
                              finalQuery = ideaSoql + orderByFilter + orderByDept + orderByDept1 + orderbyLikes + LimitString +Offset;
                          }
                      }
                  }
                  else{
                      if(Dept == '--None--'){
                         if(Dept1 == '--None--'){
                              total_size = database.query(ideaSoql + orderByFilter + orderByStage + orderbyLikes).size();
                              finalQuery = ideaSoql + orderByFilter + orderByStage + orderbyLikes + LimitString +Offset;
                         }else{
                              total_size = database.query(ideaSoql + orderByFilter + orderByStage + orderByDept1 + orderbyLikes).size();
                              finalQuery = ideaSoql + orderByFilter + orderByStage + orderByDept1 + orderbyLikes + LimitString +Offset;
                         }
                      
                      
                      }else{
                         if(Dept1 == '--None--'){
                              total_size = database.query(ideaSoql + orderByFilter + orderByStage + orderByDept +orderbyLikes).size();
                              finalQuery = ideaSoql + orderByFilter + orderByStage + orderByDept + orderbyLikes + LimitString +Offset;
                         }else{
                             total_size = database.query(ideaSoql + orderByFilter + orderByStage + orderByDept + orderByDept1 +orderbyLikes).size();
                             finalQuery = ideaSoql + orderByFilter + orderByStage + orderByDept + orderByDept1 + orderbyLikes + LimitString +Offset;
                         }
                      }
                  }
                }
                
                else if(Filter == 'All Ideas'){
                  if(stage == '--None--' || stage == Null){
                     if(Dept == '--None--' || Dept == Null){
                       if(Dept1 == '--None--' || Dept1 == Null){
                          total_size = database.query(ideaSoql + orderbyLikes).size();
                          finalQuery = ideaSoql + orderbyLikes + LimitString + Offset;
                       }else{
                          total_size = database.query(ideaSoql + orderByDept1 + orderbyLikes).size();
                          finalQuery = ideaSoql + orderByDept1 + orderbyLikes + LimitString + Offset;
                       }
                     }else{
                         if(Dept1 == '--None--'){
                           total_size = database.query(ideaSoql + orderbyDept +orderbyLikes).size();
                           finalQuery = ideaSoql + orderBydept + orderbyLikes+ LimitString + Offset;
                         }else{
                           total_size = database.query(ideaSoql + orderbyDept + orderByDept1 +orderbyLikes).size();
                           finalQuery = ideaSoql + orderBydept + orderByDept1 + orderbyLikes+ LimitString + Offset;
                         }
                     }
                  }
                  else{
                    if(Dept == '--None--'){
                      if(Dept1 == '--None--'){
                        total_size = database.query(ideaSoql + orderByStage +orderbyLikes).size();
                        finalQuery = ideaSoql + orderByStage + orderbyLikes+ LimitString + Offset;
                      }else{
                        total_size = database.query(ideaSoql + orderByStage + orderByDept1 +orderbyLikes).size();
                        finalQuery = ideaSoql + orderByStage + orderByDept1 + orderbyLikes + LimitString + Offset;
                      }
                     }else{
                       if(Dept1 == '--None--'){
                        total_size = database.query(ideaSoql + orderByStage + orderByDept + orderbyLikes).size();
                        finalQuery = ideaSoql + orderByStage + orderByDept + orderbyLikes+ LimitString + Offset;
                       }else{
                        total_size = database.query(ideaSoql + orderByStage + orderByDept + orderByDept1 + orderbyLikes).size();
                        finalQuery = ideaSoql + orderByStage + orderByDept + orderByDept1 + orderbyLikes+ LimitString + Offset;
                       }
                     }
                   }
                }
           }
       }  
        if(viewName == 'My Ideas')
        {
            finalQuery = VOTEqUERY+ orderByCreated + LimitString + Offset;
            system.debug('---->'+finalQuery);
            for(Vote v: Database.query(finalQuery))
            {
                ideaIds.add(v.ParentId);
            }
            finalQuery = ideaSoql2 + listCriteria + orderbyAccDate;
            if(Selected == 'Most Recent'){
                //finalQuery = ideaSoql2 + listCriteria + orderbyAccDate;
                if(Filter == 'Open' || Filter == 'Closed'){
                  if(stage == '--None--'){
                    if(Dept == '--None--'){
                     if(Dept1 == '--None--'){
                      total_size = database.query(ideaSoql2 + listCriteria + orderByFilter).size();
                      finalQuery = ideaSoql2 + listCriteria + orderByFilter+ orderbyAccDate ;
                     }else{
                      total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByDept1).size();
                      finalQuery = ideaSoql2 + listCriteria + orderByFilter+ orderByDept1 + orderbyAccDate ;
                     }
                     
                    }else{
                      if(Dept1 == '--None--'){
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByDept).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter+ orderByDept + orderbyAccDate ;
                      }else{
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByDept + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter+ orderByDept + orderByDept1 + orderbyAccDate ;
                      }
                    }
                  }else{
                     if(Dept=='--None--'){
                      if(Dept1 == '--None--'){
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByStage).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderbyAccDate ;
                       }else{
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept1 + orderbyAccDate ;
                       }
                     }else{
                       if(Dept1 == '--None--'){
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept + orderbyAccDate ;
                       }else{
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept + orderByDept1 + orderbyAccDate ;
                       }
                     
                     }
                   }
                }
                else if(Filter == 'All Ideas'){
                    if(stage == '--None--' || stage == Null){
                      if(Dept == '--None--' || Dept == Null){
                        if(Dept1 == '--None--' || Dept1 == Null){
                          total_size = database.query(ideaSoql2 + listCriteria).size();
                          finalQuery = ideaSoql2 + listCriteria + orderbyAccDate;
                        }else{
                          total_size = database.query(ideaSoql2 + listCriteria + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByDept1 + orderbyAccDate;
                        }
                       }else{
                        if(Dept1 == '--None--'){
                          total_size = database.query(ideaSoql2 + listCriteria + orderByDept + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByDept + orderByDept1 + orderbyAccDate;
                        }else{
                          total_size = database.query(ideaSoql2 + listCriteria + orderByDept + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByDept + orderByDept1 + orderbyAccDate;
                        }
                       }
                     }else{
                       if(Dept == '--None--'){
                        if(Dept1 == '--None--'){
                            total_size = database.query(ideaSoql2 + listCriteria + orderByStage +orderbyAccDate ).size();
                            finalQuery = ideaSoql2 + listCriteria + orderByStage + orderbyAccDate + LimitString + Offset;
                         }else{
                            total_size = database.query(ideaSoql2 + listCriteria + orderByStage + orderByDept1 + orderbyAccDate ).size();
                            finalQuery = ideaSoql2 + listCriteria + orderByStage + orderByDept1 + orderbyAccDate + LimitString + Offset;
                         }
                       }else{
                         if(Dept1 == '--None--'){
                            total_size = database.query(ideaSoql2 + listCriteria + orderByStage + orderByDept + orderbyAccDate ).size();
                            finalQuery = ideaSoql2 + listCriteria + orderByStage + orderByDept + orderbyAccDate + LimitString + Offset;
                         }else{
                            total_size = database.query(ideaSoql2 + listCriteria + orderByStage + orderByDept + orderByDept1 + orderbyAccDate ).size();
                            finalQuery = ideaSoql2 + listCriteria + orderByStage + orderByDept + orderByDept1 + orderbyAccDate + LimitString + Offset;
                         }
                       }
                     }
                }
            }
            else if(Selected == 'Most Popular'){
            //finalQuery = ideaSoql2 + listCriteria + orderByLikes; 
           if(Filter == 'Open' || Filter == 'Closed'){
                  if(stage == '--None--'){
                    if(Dept == '--None--'){
                     if(Dept1 == '--None--'){
                      total_size = database.query(ideaSoql2 + listCriteria + orderByFilter).size();
                      finalQuery = ideaSoql2 + listCriteria + orderByFilter+ orderbyLikes;
                     }else{
                      total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByDept1).size();
                      finalQuery = ideaSoql2 + listCriteria + orderByFilter+ orderByDept1 + orderbyLikes;
                     }
                     
                    }else{
                      if(Dept1 == '--None--'){
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByDept).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter+ orderByDept + orderbyLikes;
                      }else{
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByDept + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter+ orderByDept + orderByDept1 + orderbyLikes;
                      }
                    }
                  }else{
                     if(Dept=='--None--'){
                      if(Dept1 == '--None--'){
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByStage).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderbyLikes;
                       }else{
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept1 + orderbyLikes;
                       }
                     }else{
                       if(Dept1 == '--None--'){
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept + orderbyLikes;
                       }else{
                          total_size = database.query(ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByFilter + orderByStage + orderByDept + orderByDept1 + orderbyLikes;
                       }
                     
                     }
                   }
                }
                else if(Filter == 'All Ideas'){
                    if(stage == '--None--'){
                      if(Dept == '--None--'){
                        if(Dept1 == '--None--'){
                          total_size = database.query(ideaSoql2 + listCriteria).size();
                          finalQuery = ideaSoql2 + listCriteria + orderbyLikes;
                        }else{
                          total_size = database.query(ideaSoql2 + listCriteria + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByDept1 + orderbyLikes;
                        }
                       }else{
                        if(Dept1 == '--None--'){
                          total_size = database.query(ideaSoql2 + listCriteria + orderByDept + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByDept + orderByDept1 + orderbyLikes;
                        }else{
                          total_size = database.query(ideaSoql2 + listCriteria + orderByDept + orderByDept1).size();
                          finalQuery = ideaSoql2 + listCriteria + orderByDept + orderByDept1 + orderbyLikes;
                        }
                       }
                     }else{
                       if(Dept == '--None--'){
                        if(Dept1 == '--None--'){
                            total_size = database.query(ideaSoql2 + listCriteria + orderByStage +orderbyLikes).size();
                            finalQuery = ideaSoql2 + listCriteria + orderByStage + orderbyLikes+ LimitString + Offset;
                         }else{
                            total_size = database.query(ideaSoql2 + listCriteria + orderByStage + orderByDept1 + orderbyLikes).size();
                            finalQuery = ideaSoql2 + listCriteria + orderByStage + orderByDept1 + orderbyLikes+ LimitString + Offset;
                         }
                       }else{
                         if(Dept1 == '--None--'){
                            total_size = database.query(ideaSoql2 + listCriteria + orderByStage + orderByDept + orderbyLikes).size();
                            finalQuery = ideaSoql2 + listCriteria + orderByStage + orderByDept + orderbyLikes+ LimitString + Offset;
                         }else{
                            total_size = database.query(ideaSoql2 + listCriteria + orderByStage + orderByDept + orderByDept1 + orderbyLikes).size();
                            finalQuery = ideaSoql2 + listCriteria + orderByStage + orderByDept + orderByDept1 + orderbyLikes+ LimitString + Offset;
                         }
                       }
                     }
                }
             }
        }
        if(viewName == 'My Office Ideas')
        {
            finalQuery = VOTEqUERY+ orderByCreated + LimitString + Offset;
            system.debug('---->'+finalQuery);
            for(Vote v: Database.query(finalQuery))
            {
                ideaIds.add(v.ParentId);
            }
            finalQuery = ideaSoql + DistrictCri + orderbyAccDate + LimitString + Offset;
            if(Selected == 'Most Recent'){
                //finalQuery = ideaSoql + DistrictCri + orderbyAccDate + LimitString + Offset;
                if(Filter == 'Open' || Filter == 'Closed'){
                     if(stage == '--None--'){
                       if(Dept == '--None--'){
                         if(Dept1 == '--None--'){
                           total_size = database.query(ideaSoql + DistrictCri + orderByFilter).size();
                           finalQuery = ideaSoql +DistrictCri + orderByFilter + orderbyAccDate + LimitString + Offset;
                         }else{
                           total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByDept1).size();
                           finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByDept1 + orderbyAccDate + LimitString + Offset;
                         }
                       }else{
                         if(Dept1=='--None--'){
                           total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByDept).size();
                           finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByDept + orderbyAccDate + LimitString + Offset;
                         }else{
                           total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByDept + orderByDept1).size();
                           finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByDept + orderByDept1 + orderbyAccDate + LimitString + Offset;
                         }
                       }
                       
                     }else{
                        if(Dept == '--None--'){
                          if(Dept1 == '--None--'){
                            total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByStage).size();
                            finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByStage + orderbyAccDate + LimitString + Offset;
                          }else{
                            total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByStage + orderByDept1).size();
                            finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByStage + orderByDept1 + orderbyAccDate + LimitString + Offset;
                          }
                        }else{
                          if(Dept1 == '--None--'){
                            total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByStage + orderByDept).size();
                            finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByStage + orderByDept + orderbyAccDate + LimitString + Offset;
                          }else{
                            total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByStage + orderByDept + orderByDept1).size();
                            finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByStage + orderByDept + orderByDept1 + orderbyAccDate + LimitString + Offset;
                          }
                        }
                     }
                }
                else if(Filter == 'All Ideas'){
                 if(stage == '--None--' || stage == Null){
                        if(Dept == '--None--' || Dept == Null){
                          if(Dept1 == '--None--' || Dept1 == Null){
                             total_size = database.query(ideaSoql + DistrictCri).size();
                             finalQuery = ideaSoql + DistrictCri + orderbyAccDate + LimitString + Offset;
                          }else{
                             total_size = database.query(ideaSoql + DistrictCri + orderByDept1).size();
                             finalQuery = ideaSoql + DistrictCri + orderByDept1 + orderbyAccDate + LimitString + Offset;
                          }
                        }else{
                           if(Dept1 == '--None--'){
                             total_size = database.query(ideaSoql + DistrictCri + orderByDept).size();
                             finalQuery = ideaSoql + DistrictCri + orderByDept + orderbyAccDate + LimitString + Offset;
                           }else{
                             total_size = database.query(ideaSoql + DistrictCri + orderByDept + orderByDept1).size();
                             finalQuery = ideaSoql + DistrictCri + orderByDept + orderByDept1 + orderbyAccDate + LimitString + Offset;
                           }
                        }
                 }else{
                     if(Dept == '--None--'){
                        if(Dept1 == '--None--'){
                             total_size = database.query(ideaSoql + DistrictCri + orderByStage).size();
                             finalQuery = ideaSoql + DistrictCri + orderByStage + orderbyAccDate + LimitString + Offset;
                        }else{
                             total_size = database.query(ideaSoql + DistrictCri + orderByStage +orderByDept1).size();
                             finalQuery = ideaSoql + DistrictCri + orderByStage + orderByDept1 + orderbyAccDate + LimitString + Offset;
                        
                        }
                     }else{
                         if(Dept1 == '--None--'){
                             total_size = database.query(ideaSoql + DistrictCri + orderByStage + orderByDept).size();
                             finalQuery = ideaSoql + DistrictCri + orderByStage + orderByDept +orderbyAccDate + LimitString + Offset;
                         }else{
                             total_size = database.query(ideaSoql + DistrictCri + orderByStage + orderByDept + orderByDept1).size();
                             finalQuery = ideaSoql + DistrictCri + orderByStage + orderByDept + orderByDept1 + orderbyAccDate + LimitString + Offset;
                         }
                     }
                 }
               }
            }
            else if(Selected == 'Most Popular'){
            //finalQuery = ideaSoql +DistrictCri + orderbyLikes + LimitString + Offset; 
              if(Filter == 'Open' || Filter == 'Closed'){
                     if(stage == '--None--'){
                       if(Dept == '--None--'){
                         if(Dept1 == '--None--'){
                           total_size = database.query(ideaSoql + DistrictCri + orderByFilter).size();
                           finalQuery = ideaSoql +DistrictCri + orderByFilter + orderbyLikes + LimitString + Offset;
                         }else{
                           total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByDept1).size();
                           finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByDept1 + orderbyLikes + LimitString + Offset;
                         }
                       }else{
                          if(Dept1 == '--None--'){
                           total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByDept).size();
                           finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByDept + orderbyLikes + LimitString + Offset;
                          }else{
                           total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByDept + orderByDept1).size();
                           finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByDept + orderByDept1 + orderbyLikes + LimitString + Offset;
                          }
                       }
                       
                     }else{
                        if(Dept == '--None--'){
                          if(Dept1 == '--None--'){
                            total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByStage).size();
                            finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByStage + orderbyLikes + LimitString + Offset;
                          }else{
                            total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByStage + orderByDept1).size();
                            finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByStage + orderByDept1 + orderbyLikes + LimitString + Offset;
                          }
                        }else{
                          if(Dept1 == '--None--'){
                            total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByStage + orderByDept).size();
                            finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByStage + orderByDept + orderbyLikes + LimitString + Offset;
                          }else{
                            total_size = database.query(ideaSoql + DistrictCri + orderByFilter + orderByStage + orderByDept + orderByDept1).size();
                            finalQuery = ideaSoql +DistrictCri + orderByFilter + orderByStage + orderByDept + orderByDept1 + orderbyLikes + LimitString + Offset;
                          }
                        }
                     }
                }
                else if(Filter == 'All Ideas'){
                 if(stage == '--None--'){
                        if(Dept == '--None--'){
                          if(Dept1 == '--None--'){
                             total_size = database.query(ideaSoql + DistrictCri).size();
                             finalQuery = ideaSoql + DistrictCri + orderbyLikes + LimitString + Offset;
                          }else{
                             total_size = database.query(ideaSoql + DistrictCri +orderByDept1).size();
                             finalQuery = ideaSoql + DistrictCri + orderByDept1 + orderbyLikes + LimitString + Offset;
                          }
                        }else{
                           if(Dept1 == '--None--'){
                             total_size = database.query(ideaSoql + DistrictCri + orderByDept).size();
                             finalQuery = ideaSoql + DistrictCri + orderByDept + orderbyLikes + LimitString + Offset;
                           }else{
                             total_size = database.query(ideaSoql + DistrictCri + orderByDept + orderByDept1).size();
                             finalQuery = ideaSoql + DistrictCri + orderByDept + orderByDept1 + orderbyLikes + LimitString + Offset;
                           }
                        }
                 }else{
                     if(Dept == '--None--'){
                        if(Dept1 == '--None--'){
                             total_size = database.query(ideaSoql + DistrictCri + orderByStage).size();
                             finalQuery = ideaSoql + DistrictCri + orderByStage + orderbyLikes + LimitString + Offset;
                        }else{
                             total_size = database.query(ideaSoql + DistrictCri + orderByStage + orderByDept1).size();
                             finalQuery = ideaSoql + DistrictCri + orderByStage + orderByDept1 +orderbyLikes + LimitString + Offset;
                        }
                     }else{
                          if(Dept1 == '--None--'){
                             total_size = database.query(ideaSoql + DistrictCri + orderByStage + orderByDept).size();
                             finalQuery = ideaSoql + DistrictCri + orderByStage + orderByDept + orderbyLikes + LimitString + Offset;
                          }else{
                             total_size = database.query(ideaSoql + DistrictCri + orderByStage + orderByDept + orderByDept1).size();
                             finalQuery = ideaSoql + DistrictCri + orderByStage + orderByDept + orderByDept1 + orderbyLikes + LimitString + Offset;
                          }
                     }
                 }
               }
            }
        }
        
        system.debug('@@@FinalQuery'+FinalQuery +','+userid);
        ideasClassList = new List<ideaClass>();
        list<idea> ideas = database.query(finalQuery);
        if(!ideas.isEmpty()){        
            for(Idea i : database.query(finalquery))
            {   
                    ideasClassList.add(new ideaClass(i));
            }
        }
        else{
            message = 'No Records to display';
            util.setErrorMsg(false, message);
        }
        //system.debug('ideasClassList-->'+ideasClassList[0].presentIdea.id);
        
        /*try 
        {
          system.debug('Final Query-->'+finalQuery);
          stdcon = new ApexPages.StandardSetController(Database.getQueryLocator(finalQuery));  
          stdcon.setPageSize(pageSize);
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some thing went Wrong! Please contact Sys Admin'));
        }*/
    }    
    
    /* public PageReference upload() {

    attachment.OwnerId = UserInfo.getUserId();
    attachment.ParentId = 'a0n20000001OwQv'; // the record the file is attached to
    attachment.IsPrivate = false;

    
      insert attachment;
      
      
      attachment=null;
    
 
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
    return null;
  }*/
  
  public void findDuplicates()
  {
    string titlecriteira = '' ;
    if(newidea.Title!=null)
    {
        list<string> keywords = newidea.Title.split(' ');
        for(string s: keywords)
        {
            if(s.length()>2)
            {
                if(titlecriteira == '')
                titlecriteira+=' AND (Title Like \'%'+String.escapeSingleQuotes(s)+'%\'';
                else
                titlecriteira+=' OR Title Like \'%'+String.escapeSingleQuotes(s)+'%\'';
                
            }
            
        }
        
        if(titlecriteira.length()>0)
        {
            titlecriteira +=')';
            system.debug('titlecriteira -- >'+titlecriteira);
            system.debug('titlecriteira -- >'+ideaSoql+titlecriteira+orderByLikes+ ' limit 10');
            duplicateIdeas = database.query(ideaSoql+titlecriteira +orderByLikes+ ' limit 10');
            
        }
        
    }
    system.debug('newidea.Title -- >'+newidea.Title);
        system.debug('titlecriteira -- >'+titlecriteira);
        list <Id> similarIdeas =  Ideas.findSimilar(newidea);
        system.debug('similarIdeas -- >'+duplicateIdeas);
        //duplicateIdeas = [select id, Title from Idea where id in :similarIdeas];
    
  }
  
}