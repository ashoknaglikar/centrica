/*
    Class Name:EditDiaryEntryController 
    developer: Priyadharshini Umashankar
    Date created: 28/11/2011
    Purpose: To show the different fields to be shown on a diary entry edit page and update the diary entry
*/  


public with sharing class EditDiaryEntryController 
{

private String retURL;
private Boolean isException = false;
private String exceptionMessage = '';
public String Save_New_Url;
public String userMessage {get; set;}
public Diary_Entry__c entry {get; set;}

public Unavailability__c Unavailable{get;set;}
String Weeks;
String area;
public String msg {get;set;}
Utilities util = new  Utilities();
public boolean var{get;set;}
public boolean removeMode {get;set;}

public boolean needsReason {get;set;}


string UnHistory ;

public EditDiaryEntryController(ApexPages.StandardController controller)
{
  var=true; 
  removeMode = false;
  
  Unavailable = new Unavailability__c(); 
  
  entry = (Diary_Entry__c)controller.getRecord();
  //Setup retURL to use when redirecting back after successful update
  
  retURL = ApexPages.currentPage().getParameters().get('retURL');
  string remove = ApexPages.currentPage().getParameters().get('r');
  string needsReasonstr = ApexPages.currentPage().getParameters().get('needsReason');
  
  if(needsReasonstr == 'Yes')
    needsReason = true;
  else
    needsReason = false;
    
  if (retURL == null)
  retURL =entry.Id;
  
  
  entry = [Select Employee_ID__c,Authoriser__c,Week__r.Employee__r.District__c,Week__r.Week_Commencing__c, d.Name,d.Week__c,Week__r.Employee__r.id,Type__c,d.Sub_Type__c,d.Start__c,d.End__c,d.Hours__c,d.Extra_Hours__c,d.Overbooked_Hours__c,Create_History__c,History_Track__c,Needs_Removal_Reason__c,(Select id from Unavailability_History_Trackers__r),Removal_Reason__c,Primary_Type__c,Unavailability_Notes__c,Unavailability_Reason__c,Amendment_Reason__c,Labour_Type__c  From Diary_Entry__c d where id=:entry.Id];
  if(entry.Type__c=='Unavailability')
  {
    var=false;
    
  }
  if(remove == 'r')
  {
  var = true;
  removeMode = true;
  }
  
  Unavailable.Employee__c = entry.Week__r.Employee__r.id;
  Unavailable.Start_Date_Time__c = entry.Start__c;
  Unavailable.End_Date_Time__c = entry.End__c;
  Unavailable.Type__c =    entry.Primary_Type__c;
  Unavailable.Unavailability_Reason__c =  entry.Sub_Type__c;
  Unavailable.Unavailability_Notes__c = entry.Unavailability_Notes__c;
  Unavailable.Labour_Type__c = entry.Labour_Type__c;
  if(entry.Unavailability_History_Trackers__r.size()>0)
  UnHistory = entry.Unavailability_History_Trackers__r[0].Id;
}     
  
public PageReference Save()
    {   
        
         id entryid = ApexPages.currentPage().getParameters().get('id');
         
        //  If there was no exception and diary entry has been set
          if (entry != null)
          {     
                
                if((entry.Start__c == Unavailable.Start_Date_Time__c && entry.End__c==Unavailable.End_Date_Time__c /*&& entry.Sub_Type__c==Unavailable.Unavailability_Reason__c*/) ||var)
                
                {
                    boolean changed = false;
                    boolean entrychanged = false;
                    if(Unavailable.Labour_Type__c!=null && Unavailable.Labour_Type__c != entry.Labour_Type__c)
                    {
                        changed = true;
                        entry.Labour_Type__c = Unavailable.Labour_Type__c ;
                    }
                    if(Unavailable.Type__c!=null && Unavailable.Type__c != entry.Primary_Type__c)
                    {
                        changed = true;
                        entry.Primary_Type__c = Unavailable.Type__c ;
                    }
                    if(Unavailable.Unavailability_Reason__c!=null && Unavailable.Unavailability_Reason__c != entry.Sub_Type__c)
                    {   
                        system.debug('##reason, entry subtype:'+Unavailable.Unavailability_Reason__c+','+entry.Sub_Type__c);
                        changed = true;
                        if(Unavailable.Unavailability_Reason__c=='NWD - Working' || entry.Sub_Type__c == 'NWD - Non Working' || entry.Sub_Type__c=='NWD - Working' || Unavailable.Unavailability_Reason__c == 'NWD - Non Working')
                        {
                            entrychanged = true;
                        }
                        entry.Sub_Type__c = Unavailable.Unavailability_Reason__c;
                                               
                    }
                    if(changed)
                    {   
                       if(entry.Needs_Removal_Reason__c=='Yes' && Unavailable.Amendment_Reason__c == null)
                        {
                            userMessage = 'Please enter the Amendment Reason.';
                            util.setErrorMsg(true, userMessage);
                            return null;
                        }   
                         if(UnHistory != null)
                         {
                            system.debug('**** Ashok *****'+UnHistory);
                            update(new Unavailability_History_Tracker__c (id = UnHistory, Type__c = Unavailable.Type__c, Sub_Type__c = Unavailable.Unavailability_Reason__c, Amendment_Reason__c = Unavailable.Amendment_Reason__c,Unavailability_Notes__c=entry.Unavailability_Notes__c ));
                         }
                         
                    }
                    if(entrychanged){
                    
                       
                      insert Unavailable;
                      system.debug('##unavailable'+unavailable);
                      UnavailabilityHistoryHelper uHelper = new  UnavailabilityHistoryHelper();
                      if(UnHistory == null)
                      {
                        //create one 
                        system.debug('Before Entering Edit');
                        entry.Create_History__c =true;
                        uHelper.Createhistoryrecords(new list <Diary_Entry__c>{entry});
                        UnHistory = [Select id from Unavailability_History_Tracker__c where Diary_Entry__c = :entry.Id].Id;
                      }
                      system.debug('********Deleted Entry************');
                      if(entry.Week__r.Week_Commencing__c!=null)
                      {
                         string [] datelist = String.valueOf(entry.Week__r.Week_Commencing__c).split('-');
                         weeks = datelist[2]+'/'+datelist[1]+'/'+datelist[0];
                      }
                      area = entry.Week__r.Employee__r.District__c;
                      delete entry;
                       
                      system.debug('********Calling Create Unava Class************');
                      
                      CreateUnavailability cr = new CreateUnavailability();
                  
                      msg = cr.editUnavailability(new id[] {Unavailable.id},UnHistory);
                      system.debug('-------------------->'+msg);
                      
                      if(msg.contains('Job_Unavailability'))
                     { 
                        return (new PageReference('/apex/Job_Unavailabilitydisplay?s='+ Unavailable.id));
                     }
                             return (new pagereference('/apex/DiaryDisplay?week=' + weeks + '&area=' + area));
                          
                      }
                    else
                    try{
                    update entry;
                    }catch (exception e)
                    {
                        util.handleExceptions(e); 
                        return null;
                    }
                    if(removeMode)
                    {  
                         if(entry.Needs_Removal_Reason__c=='No' && entry.Authoriser__c==null )
                        {
                            userMessage = 'Please enter the Authoriser.';
                            util.setErrorMsg(true, userMessage);
                            return null;
                            
                        }
                        
                        if(entry.Needs_Removal_Reason__c=='Yes' && entry.Amendment_Reason__c == null) 
                        {
                            userMessage = 'Please enter the Amendment Reason.';
                            util.setErrorMsg(true, userMessage);
                            return null;
                        
                        }
                        
                        UnavailabilityDelete.deleteUnav(entry.Id);
                        if(entry.Week__r.Week_Commencing__c!=null)
                         {
                             string [] datelist = String.valueOf(entry.Week__r.Week_Commencing__c).split('-');
                             weeks = datelist[2]+'/'+datelist[1]+'/'+datelist[0];
                         }  
                         
                        area = entry.Week__r.Employee__r.District__c;
                        retURL=  '/apex/DiaryDisplay?week=' + weeks + '&area=' + area;
                        
                    }
                    return new PageReference(retURL); 
                }
                else 
                {
                     if(Unavailable.Type__c==null || Unavailable.Unavailability_Reason__c==null)  
                     {
                        userMessage = 'Please enter the Unavailable Type and Unavailable Reason.';
                        util.setErrorMsg(false, userMessage);
                        return null;
                     }
                     
                     if(entry.Needs_Removal_Reason__c=='Yes' && Unavailable.Amendment_Reason__c==null )
                     {
                        userMessage = 'Please enter the Amendment Reason and Notes1.';
                        util.setErrorMsg(true, userMessage);
                        return null;
                     }
                    
                    /* if(entry.Needs_Removal_Reason__c=='No')
                     {
                        //ammnd=true;
                        userMessage = 'Please enter the Unavailability Notes and Authoriser.';
                        util.setErrorMsg(true, userMessage);
                        return null;
                     }
                     */
                     
                      try{ 
                          
                          system.debug(LoggingLevel.INFO, 'Unavailable.Unavailability_Notes__c kp bi'+Unavailable.Unavailability_Notes__c);
                          system.debug(LoggingLevel.INFO, 'entry.Unavailability_Notes kp bi'+entry.Unavailability_Notes__c);
                          
                          //PRB00031582 -- fix to modify unavailability notes and amendment reason when the timings are changed
                          
                          if(Unavailable.Unavailability_Notes__c != entry.Unavailability_Notes__c)
                          Unavailable.Unavailability_Notes__c = entry.Unavailability_Notes__c;
                          
                          if(Unavailable.Amendment_Reason__c != entry.Amendment_Reason__c)
                          Unavailable.Amendment_Reason__c = entry.Amendment_Reason__c;
                          
                          //PRB00031582
                          
                          insert Unavailable;
                          
                          UnavailabilityHistoryHelper uHelper = new  UnavailabilityHistoryHelper();
                          if(UnHistory == null)
                          {
                            //create one 
                            system.debug('Before Entering Edit');
                            entry.Create_History__c =true;
                            uHelper.Createhistoryrecords(new list <Diary_Entry__c>{entry});
                            UnHistory = [Select id from Unavailability_History_Tracker__c where Diary_Entry__c = :entry.Id].Id;
                          }
                          system.debug('********Deleted Entry************');
                          delete entry;
                          
                          
                          
                          system.debug('********Calling Create Unava Class************');
                          CreateUnavailability cr = new CreateUnavailability();
                      
                          msg = cr.editUnavailability(new id[] {Unavailable.id},UnHistory);
                          system.debug('------>'+msg);
                          
                          if(msg.contains('Job_Unavailability'))
                          { 
                            return (new PageReference('/apex/Job_Unavailabilitydisplay?s='+ Unavailable.id));
                          }
                         
                      }catch (exception e)
                      {
                        util.handleExceptions(e);
                        return null;
                       // userMessage = 'Error Updating Diary Entry: ' + exceptionMessage;
                       // util.setErrorMsg(false, userMessage);
                      }
                      
                     if(entry.Week__r.Week_Commencing__c!=null)
                     {
                         string [] datelist = String.valueOf(entry.Week__r.Week_Commencing__c).split('-');
                         weeks = datelist[2]+'/'+datelist[1]+'/'+datelist[0];
                     }  
                      
                     area = entry.Week__r.Employee__r.District__c;
                     return new PageReference('/apex/DiaryDisplay?week=' + weeks + '&area=' + area);
               }
               
        }
        else
        { 
            // output exception message to screen
            userMessage = 'Error Updating Diary Entry: ' + exceptionMessage;
            util.setErrorMsg(false, userMessage);
            return null;
        }
        
    }
    
    
     
public PageReference Cancel()
 { // return to the previous page
    return (new PageReference(retURL));                             
 }
 
 
public PageReference Save_New()
{   /*This is used to diplay the save_new functionality to the system admin alone. 
    The function will save the entry and navigate the user to a create availability standard page 
    Note: The user will not be able to create a diary entry of type job booking or unavailability.*/
   
    //  If there was no exception and diary entry has been set
    if (entry != null)
        {
            // Update diary entry
            update entry;
            system.debug('The updated diary entry is '+entry);
        }
     else
        {
            // output exception message to screen
            userMessage = 'Error Updating Diary Entry: ' + exceptionMessage;
            return null;
        }
    // Naivigate to the create diary entry of type availability page    
    Save_New_Url= '/a0X/e?retURL='+retURL+'&RecordType=012200000009ipP&ent=01I200000006Zub';
    system.debug ('The url returned in save_new is '+Save_New_Url);
    return (new PageReference(Save_New_Url));    
}   

 
}