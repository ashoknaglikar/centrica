/*
    Class Name:AmalgamateNotesController
    developer: Ashok Kumar
    Date created: 03/04/2011
    Purpose: To show different notes fields associated with CHI lead, Opportunity, Job, cases etc. in one page and render them as PDF.
*/  

global without sharing class AmalgamateNotesController {

    public Opportunity CHILead {get; set;}
    public list<CaseComment> CaseNotes{get;set;}
    public boolean C_Notedisplay{get;set;}
    public list<NotesInnerclass> Noteslist {get;set;}
    public list<NotesInnerclass> pinNotesList{get;set;} // Added 12/09/2017 By Dheeraj Bhatt
    public boolean AllNotedisplay{get;set;}
    public String boilerNotes{get;set;}
    public String officeNotes{get;set;}     //Added 04/03/2016
    public List<contact_log__c> contactLogs{get;set;}      //Added 04/03/2016
    String chiLeadID;
    public list<Note> PCNNotes{get;set;}        // Added 25/05/2011 by Phil Dennison
    public boolean PCN_Notedisplay{get;set;}    // Added 25/05/2011 by Phil Dennison
    
    public List<Customer_Call_Back__c> CCBack{get;set;}   // Added 21/09/2016 by Phil Dennison
    public boolean CCBack_Display{get;set;}     // Added 09/09/2016 by Phil Dennison
    
    public List<Note> billingActNote{get;set;}  
    public List<Cancel_Re_Issue_Request__c> billingAction{get;set;}
    public boolean bAction{get;set;}
    public boolean bActDisplay{get;set;}
    
    public boolean Inform_No_PCN{get;set;}    // Added 25/05/2011 by Phil Dennison
    public list<Note> PEWDNotes{get;set;}      //Added 12/09/2014 by Priti Patil
    public boolean PEWD_Notedisplay{get;set;}  //Added 12/09/2014 by Priti Patil
    public boolean Inform_No_PEWD{get;set;}    //Added 12/09/2014 by Priti Patil 
    
    public list<Note> SMNotes {get; set;} // variable created for Smart Meter notes
    public list<Note> GDNotes {get; set;}  
    public list<NotesInnerclass> ActivityHistoryList {get;set;}
    public List<NotesInnerclass> QualityList{get;set;}
    
    public  AmalgamateNotesController()
    {
        // Get CHI Lead Id from URL.
        chiLeadID =System.currentPageReference().getParameters().get('OppId');
        ActivityHistoryList = new list<NotesInnerclass>();
        QualityList = new List<NotesInnerclass>();
        billingActNote=new List<Note>();
        bAction=false;
        bActDisplay=false;
        // fetch CHI Lead from database.
        try{
        CHILead = [Select o.Id,o.Name, o.ta_notes__c, o.Lead_Comments__c, o.Landlord_lead_details__c, (Select Name,Id,Delivery_Notes__c, Installer_Notes__c, Quote__c, Job_Notes__c From Jobs__r),(Select Id From Cases__r)  
                   ,(Select  Subject, OwnerId, Description,CreatedById,CreatedDate,isTask from ActivityHistories order by CreatedDate desc)From Opportunity o where id=:chiLeadID];
        }catch(Exception e)
        {
            
        }
        List<Id> JobId = new List<Id>();
        
        List<Quote_Product__c> boilerQuoteProducts = new List<Quote_Product__c>() ;
        
        Set<ID> bigMachinesQuoteIdSet = new Set<ID>();
        if(CHILead.ActivityHistories!=null && CHILead.ActivityHistories.size()>0)
        {
            for(ActivityHistory a: CHILead.ActivityHistories)
            {
              NotesInnerclass n = new NotesInnerclass(a);
              n.ObjType = 'CHI Lead Activity';
              ActivityHistoryList.add(n);
            }   
        }   
        
        
        
        //collect all Job Ids from the CHI Lead     
        for(Job__c j : CHILead.Jobs__r)
        {
            JobId.add(j.Id);
            
            // Collect Quote from the job to display Boiler Notes Presenton Quote Products.
            if(j.Quote__c != null){
                
                bigMachinesQuoteIdSet.add(j.Quote__c);
                
            }
            
        }
        
        List<Job__c> jList = [Select id ,(Select  Subject, OwnerId, Description, CreatedById, CreatedDate, isTask from ActivityHistories order by CreatedDate desc),(select id,Name,CreatedById,Notes__c,Visit_Completed_By__c,CreatedDate,Status__c,WIP_Type__c from WIP_Header__r order by CreatedDate desc) from Job__c where Id in : JobId];
        for(Job__c j : jList)
        {
            for(ActivityHistory a: j.ActivityHistories)
            {
              NotesInnerclass n = new NotesInnerclass(a);
              n.ObjType = 'Job Activity';
              ActivityHistoryList.add(n);
            }  
            
            for(WIP_Header__c QVisit: j.WIP_Header__r){
               NotesInnerclass n = new NotesInnerclass(Qvisit);
               n.ObjType = 'Quality Note';
               QualityList.add(n);
            }
        }
        
        if(ActivityHistoryList.size()>0){
          ActivityHistoryList.sort();
        }
        
        system.debug('Activity History -->'+ActivityHistoryList);
        //Fecth Quote Products from Quote collected above where part number is 'CBLR' indicates Boiler.
        if(bigMachinesQuoteIdSet.size()>0){
            
          boilerQuoteProducts = [Select installationNotes__c From Quote_Product__c 
                                                 where Part_Number__c like 'CBLR%'and BigMachines_Quote__c in :bigMachinesQuoteIdSet];
                    
          if(boilerQuoteProducts.size()>0){
            
              boilerNotes = boilerQuoteProducts[0].installationNotes__c;
            
          }
                    
        }
        
        // collect all cases associated with CHI Lead, for displaying Case Comments.
        List<Id> CaseId = new List<Id>();
        for(Case c : CHILead.Cases__r)
        {
            CaseId.add(c.Id);
        }
        // fetch Case comments.
        if(CaseId.size()>0)
        {
            CaseNotes = new list<CaseComment>();
            CaseNotes = [Select c.ParentId, c.LastModifiedDate, c.LastModifiedById, c.CreatedDate, c.CreatedById, c.CommentBody From CaseComment c where ParentId in :CaseId order by CreatedDate desc];
            if(CaseNotes.size()>0)
            {
                C_Notedisplay = true;
            }
        }
      
        list<Id> parentIdlst = new list<Id>();
        // create a sigle list of all parent Ids in order to fetch Notes from Note and attachement object.
        // add CHI Lead Id.
        parentIdlst.add(CHILead.Id);
        
        //add Jod Ids
        parentIdlst.addall(JobId);
        
          
        FOR(Landlord_Record__c lLrecord : [Select id from Landlord_Record__c where Chi_Lead__c = :chiLeadID])
        {
            parentIdlst.add(lLrecord.Id);
        }
        
        //Keyprefix for Job and CHI Lead used to segretgate the Notes fetched.
        string jobkey = Job__c.SObjectType.getDescribe().getKeyPrefix();
        string oppkey = Opportunity.SObjectType.getDescribe().getKeyPrefix();
        list<Note> AllNote = new list<Note>();
        // fetch all notes.
        AllNote = [Select n.Title, n.ParentId,n.CreatedDate, n.LastModifiedDate, n.LastModifiedById, n.CreatedById, n.Body 
                   From Note n 
                   where ParentId in :parentIdlst order by CreatedDate desc];
                
        // Wrapperclass list initialization
        Noteslist = new list<NotesInnerclass>();
        pinNotesList= new list<NotesInnerclass>();
        // iterate all Notes and depending upon keyprefix of Parent ID, assign "CHI Lead" or "Job" for diplsying purpose.
        for(Note n :AllNote)
        {
            AllNotedisplay = true;
            NotesInnerclass newobj = new NotesInnerclass(n);
            string Pid = n.ParentId;
            if(Pid.substring(0,3) == jobkey)
            {
                newobj.ObjType = 'Job';
            }else if(Pid.substring(0,3) == oppkey){
                newobj.ObjType = 'CHI Lead';
            }else
            {
                 newobj.ObjType = 'Landlord Record';
            }
            Noteslist.add(newobj);
            // For selecting #PIN Note
            If(n.title.containsIgnoreCase(system.label.PIN)){
               pinNotesList.add(newobj); 
            }
        
        }
        
        
        // Query to collect the 'Office notes' from the sold quote
        // Added by Phil Dennison - 04/03/2016
        list<BigMachines_Quote__c> BMQuote = new list <BigMachines_Quote__c>();
        BMQuote = [SELECT Office_Notes__c FROM BigMachines_Quote__c WHERE stage__c = 'Quote Finalised - Accepted' AND Opportunity__c =: CHILeadID ];
        if(BMQuote.size()>0)
        officeNotes = BMQuote[0].Office_Notes__c;
        
        
        // List of contact logs linked to the CHI Lead
        // Added by Phil Dennison - 05/03/2016
        contactLogs = new List<contact_log__c>();
        contactLogs = [select outcome__c, outcome_detail__c, RecordType.Name, CreatedDate, CreatedByID from contact_log__c where CHI_Lead__c =: CHILeadID order by CreatedDate desc];
        
        
        // Query to collect all PCN Notes added against the JOBs
        // Added by Phil Dennison - 28/05/2011     
        List<Payment_Collection__c> PCNIDs = new List<Payment_Collection__c>();
        PCNIDs = [SELECT id FROM Payment_Collection__c WHERE Job__c in :JobId];
        
        PCNNotes = [SELECT pcn.Title, pcn.ParentId, 
                    pcn.CreatedDate, pcn.LastModifiedDate, 
                    pcn.LastModifiedById, pcn.CreatedById, pcn.Body 
                    FROM Note pcn
                    WHERE ParentId in :PCNIDs
                    order by CreatedDate desc];
        if(PCNNotes.size()>0)
            {
                PCN_Notedisplay = true;
                Inform_No_PCN = false;
            }else {Inform_No_PCN = true;}
   
   
            
       // Query to collect all customer call back records linked to the CHI Lead
       // Added by Phil Dennison 09/09/2016
       
       CCBack = new List<Customer_Call_Back__c>();
       CCBack = [SELECT id, Name, Status__c, assigned_to_person__c, Assigned_To_Group__c, days_open__c FROM Customer_Call_Back__c WHERE CHI_Lead__c =: chiLeadID];
       if(CCBack.size()>0)
        {
            CCBack_Display = true;
        } else {
            CCBack_Display = false;
        }
      //Added for billing action notes
      billingAction=[select id,name,CHI_Lead__c,createdby.name,createddate,Status__c,TypeofRequest__c,Comments__c, Notes__c from Cancel_Re_Issue_Request__c where CHI_Lead__c=:chiLeadID];
      
      set<Id> billActionId=new set<id>();
      for(Cancel_Re_Issue_Request__c  reIssue : billingAction ){
          billActionId.add(reIssue.id);
      }
      if(billActionId.size()>0){
          bActDisplay=true;
          billingActNote= [select id,owner.name, body,title,parentId,createddate from note where parentId in : billActionId];
      }
      else{
       bActDisplay=false;
      }
      if(billingActNote.size()>0)
        {
            bAction= true;
        } else {
            bAction= false;
        }
       // ++ Added for displaying Smart Meter notes     
       List<Smart_Meter__c> smartMeterList = new List<Smart_Meter__c>();
       Smart_Meter__c smartMeter = new Smart_Meter__c(); 
       smartMeterList = [Select s.Id, s.CHI_Lead__c From Smart_Meter__c s where s.CHI_Lead__c =: chiLeadID];
       if(smartMeterList.size() > 0)
       {
            smartMeter = smartMeterList[0];
            SMNotes = [Select n.Title, n.ParentId, n.CreatedDate, n.CreatedById, n.Body From Note n
                      where n.ParentId =: smartMeter.Id];
       }
       // -- Added for displaying Smart Meter notes
       
       List<Green_Deal_Reconsilliation__c> GDList = new List<Green_Deal_Reconsilliation__c>();
       Green_Deal_Reconsilliation__c GD = new Green_Deal_Reconsilliation__c(); 
       GDList = [Select Id, Opportunity__c From Green_Deal_Reconsilliation__c  where Opportunity__c =: chiLeadID];
       if(GDList.size() > 0)
       {
            GD = GDList[0];
            GDNotes = [Select n.Title, n.ParentId, n.CreatedDate, n.CreatedById, n.Body From Note n
                      where n.ParentId =: GD.Id];
       }
       
       // Query to collect all PEWD Notes added against the JOBs
       // Added by Priti Patil - 12/09/2014
       List<Pre_Electrical_Work_Document__c> PEWDList = new List<Pre_Electrical_Work_Document__c>();
       PEWDList  = [SELECT id FROM Pre_Electrical_Work_Document__c WHERE Job__c in :JobId];
       PEWDNotes = [SELECT Title, ParentId, 
                    CreatedDate, LastModifiedDate, 
                    LastModifiedById, CreatedById, Body 
                    FROM Note
                    WHERE ParentId in :PEWDList
                    order by CreatedDate desc];
        if(PEWDNotes.size()>0)
            {
                PEWD_Notedisplay = true;
                Inform_No_PEWD = false;
            }else {Inform_No_PEWD = true;}
    }
    
   
    
    // Action called up on click of "Generate PDF" genrated PDF for the same page.
    public pagereference generatePDF(){
        
        //return(new pagereference('/apex/AmalgamateNotes?OppId'+chiLeadID+'&p=pdf'));
        PageReference pageref = new PageReference('/apex/AmalgamateNotes?OppId='+chiLeadID+'&p=pdf');
        pageref.setRedirect(false);
        return pageref;
    }
    
    //inner wrapper class used in page for display purpose.
    
    global class NotesInnerclass implements Comparable
    {
        public Note Notes{get; set;}
        public ActivityHistory activit {get;set;}
        public WIP_Header__c QuaVisit {get;set;}
        public string ObjType{get; set;}
        
        public  NotesInnerclass(Note n) {
              Notes= n;
        }           
        
        public NotesInnerclass(ActivityHistory a)
        {
            activit = a;
        } 
        
        Public NotesInnerclass(WIP_Header__c Qvisit){
           QuaVisit = Qvisit;
        }  
        
        global Integer compareTo(Object compareTo) {
        // Cast argument to NotesInnerclass 
        NotesInnerclass compareToActi = (NotesInnerclass)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (activit.CreatedDate > compareToActi.activit.CreatedDate) { // Set return value to a negative value for sorting in DESC
            // Set return value to a negative value.
            returnValue = -1;
        } else if (activit.CreatedDate < compareToActi.activit.CreatedDate) {
            // Set return value to a Positive value. 
            returnValue = 1;
        } 
        
        return returnValue;       
      }
        
        
    }

}