public with sharing class aspAcknowledgmentsCont {
    
    public list<ASP_Exception__c> displayList {get;set;}
    public boolean showLink{get;set;}
    
    public integer pageSize {get;set;}
    
    id useriD = userinfo.getuserId();
    
    string query = 'Select Status__c, Description__c, Name, Id, ASP__R.Name,Exception_User__r.Name,'+ 
                    'Exception_User__c, Escalted_To__c, Due_Date__c, Comments__c, Assigned_To__c, '+
                    'Accept_Reject__c, ASP__c, Assigned_To_Email__c, Assigned_To__r.Name, CreatedDate  from ASP_Exception__c '+
                    'Where ';
                    
    
    string whereApproval = '(Assigned_To__c = :useriD OR Escalted_To__c = :useriD)';        
    string whereViewer = '(Exception_User__c = :useriD)';       
                    
    string orderBy = ' ORDER BY CreatedDate DESC';          
    
    string statusCriteria = ' And Status__c = :status';
    
    string offset= ' OFFSET :counter';
    
    string LimitString = ' LIMIT : pageSize'; 
    
    public string status{get;set;}
    
    public  ASP_Exception__c aspExceptionObj {get;set;}
    
    string finalQuery ;
    string baseQuery;
    
    Utilities util  = new Utilities();
    
    public aspAcknowledgmentsCont()
    {
        displayList = new list<ASP_Exception__c>();
        aspExceptionObj = new ASP_Exception__c();
        pageSize = 20; 
        counter = 0;
        system.debug(LoggingLevel.INFO,'View Mode: '+aspExceptionObj.viewMode__c+' '+aspExceptionObj.VfStatus__c);
        /*if(aspExceptionObj.viewMode__c == 'My Approvals' )
        {
        total_size = [select count() from ASP_Exception__c Where (Assigned_To__c = :useriD OR Escalted_To__c = :useriD)];
        }else
        {
            total_size = [select count() from ASP_Exception__c Where (Exception_User__c = :useriD)];
        }*/
        system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=TS:'+total_size);
        //finalQuery = query + orderBy + LimitString + offset;
        setQueryMode();
        finalQuery = baseQuery + orderBy + LimitString + offset;
        
        reRunQuery();
        
    }
    
    public void reRunQuery()
    {
        if (aspExceptionObj.VfStatus__c == null || aspExceptionObj.VfStatus__c == 'All')
        {
            status = null;
            aspExceptionObj.VfStatus__c = 'All';
            finalQuery = baseQuery +orderBy+LimitString+offset;
            total_size = database.query(baseQuery).size();

        }else
        {
            status = aspExceptionObj.VfStatus__c;
            finalQuery = baseQuery +statusCriteria+orderBy+LimitString+offset;
            total_size = database.query(baseQuery +statusCriteria).size();
        }
        
        system.debug('Final Query -->'+status);
        system.debug('pageSize -->'+pageSize);
        system.debug('counter -->'+counter);
        system.debug('useriD -->'+useriD);
        
        system.debug('Final Query -->'+finalQuery);
        displayList = database.query(finalQuery);
        if(displayList.size()==0)
        {
            util.setErrorMsg(false , 'No records to display.');
        }
    }
    
    
    public void setQueryMode()
    {
        baseQuery = query +whereApproval;
        if(aspExceptionObj.viewMode__c == 'My Approvals')
        {
            baseQuery = query +whereApproval;
            showLink = true;
            
        }else if (aspExceptionObj.viewMode__c == 'My Requests -Sent for Approval')
        {
            
            baseQuery = query +whereViewer;
            showLink = false;
        }else
        {
            aspExceptionObj.viewMode__c = 'My Approvals';   
            showLink = true;
        }
        //Get the Count of Records -->fix By Ashok G -- Change Starts
        if(aspExceptionObj.viewMode__c == 'My Approvals' )
        {
        total_size = [select count() from ASP_Exception__c Where (Assigned_To__c = :useriD OR Escalted_To__c = :useriD)];
        }else
        {
            total_size = [select count() from ASP_Exception__c Where (Exception_User__c = :useriD)];
        }
        counter = 0;
        //Change End
    }
    
    public void changeview()
    {
        setQueryMode();
        
        reRunQuery();
    }
    /*
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 10;
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(finalQuery));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }*/
     
    
    
   
       //*********************************** New Code**********************************
    
    
    
   private integer counter=0;  //keeps track of the offset
   
   public integer total_size; //used to show user the total size of the list
   
   public PageReference Beginning() { //user clicked beginning
      counter = 0;
      reRunQuery();
      return null;
   }
 
   public PageReference Previous() { //user clicked previous button
      counter -= pageSize;
      reRunQuery();
      return null;
   }
 
   public PageReference Next() { //user clicked next button
      counter += pageSize;
      reRunQuery();
      return null;
   }
 
   public PageReference End() { //user clicked end
      counter = total_size - math.mod(total_size, pageSize);
      reRunQuery();
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
   
   
   
    
}