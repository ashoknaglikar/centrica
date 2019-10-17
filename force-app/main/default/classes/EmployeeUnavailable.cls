public class EmployeeUnavailable {
    
  public Unavailability__c Unavailable {get;set;}
  public boolean var{get;set;}
  String Weeks;
  string area;
  Diary_Entry__c diaryentry;
  public String msg {get;set;}
  Utilities util = new  Utilities();
  boolean peopleView;
  string tab;
         
    public EmployeeUnavailable() 
    {
        msg = '';
        var = true; 
        peopleView = false;
        id diaryentryid = ApexPages.currentPage().getParameters().get('id');
        area =ApexPages.currentPage().getParameters().get('area');
        tab = ApexPages.currentPage().getParameters().get('sfdc.tabName');
        peopleView = tab == system.label.PeopleViewTab;
        system.debug('**area'+area);
        Unavailable = new Unavailability__c();
        diaryentry =[Select Week__r.Employee__r.District__c, Week__r.Employee__r.id,Week__r.Week_Commencing__c,Employee_Name__c,End__c,Start__c from Diary_Entry__c where id =:diaryentryid];
        Unavailable.Employee__c = diaryentry.Week__r.Employee__r.id;
        Unavailable.Start_Date_Time__c = diaryentry.Start__c;
        Unavailable.End_Date_Time__c = diaryentry.End__c;
        if(diaryentry.Week__r.Week_Commencing__c!=null)
        {
            string [] datelist = String.valueOf(diaryentry.Week__r.Week_Commencing__c).split('-');
            weeks = datelist[2]+'/'+datelist[1]+'/'+datelist[0];
        }   
       // area =  diaryentry.Week__r.Employee__r.District__c;
       system.debug('**area'+area);
       
    }
 
    public void mappingunavailable(){
        if(Unavailable!=null)
        try{
        insert Unavailable;
        var = false;
        
        }catch(exception e)
        {
            var = true;
            if(e.getmessage().Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                list<string> error = e.getmessage().split(',');
                
                //if(!error[1].contains('specified'))
                util.setErrorMsg(true, error[1]);
                
            }else
            {   
                util.setErrorMsg(true, e.getmessage());
            }  
        }
        
    }

    public pagereference cancel()
    {
        return (new pagereference('/'+diaryentry.id));
        
    }  

    public PageReference generateUnavail()
    {
        
        msg = CreateUnavailability.generateUnavailability(new id[] {Unavailable.id}, 'new');
        if(msg.contains('Job_Unavailability'))
        {
            return (new PageReference('/apex/Job_Unavailabilitydisplay?s='+ Unavailable.id));
            
        }
        util.setErrorMsg(false, msg);
        return null;
    }
    
   
   public PageReference goBack()
    { 
        PageReference newPage;
        String newURL='/apex/DiaryDisplay?&sfdc.tabname='+tab;
        if(!peopleView)
        newURL +='&week=' + weeks + '&area=' + area ;
        newPage = new PageReference(newURL);
        newPage.setRedirect(true);
        return newPage;
    } 
    
   
   }