@isTest
private class PreElectric_Test {
    
  static testMethod void checkDateswithvalue()
    { 
       PreElectricWork con=new PreElectricWork ();
       con.jb.Customer_Journey_First_Update__c=null;
       con.jb.BGNE_Install_Date__c=null;  
       con.checkDates();      
    }
    
    static testMethod void checkDateswithoutvalue()
    { 
      PreElectricWork con=new PreElectricWork ();
      con.jb.Customer_Journey_First_Update__c=System.today()+7;
      con.jb.BGNE_Install_Date__c= System.today();  
      con.checkDates();   
    }
    
   
   static testMethod void PlannedJobswithdata() {
   
    PreElectricWork con=new PreElectricWork ();
  
    Account Acc = TestClassHelper.createAccout();
                   insert Acc;
        
    Opportunity opp = TestClassHelper.createCHILead(Acc);
                   insert opp;
    
    Region__c   reg= TestClassHelper.createRegion();
                   insert reg;
                
    District__c dist = TestClassHelper.createDistrict();
    dist.Region__c=reg.id;
    insert dist;
    
    Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,dist.Id);
    job.Installation_Date__c=System.today();
    job.Customer_Journey_Status_Change_Date__c=System.today();
    job.BGNE_Install_Date__c=System.today()+7;
    insert(job);
     
    Job_Element__c jbele = new Job_Element__c();
    jbele.job__c=job.id;
    jbele.Product_ID__c='PE2969';
     
     con.AreaName='Anglia';
     con.RegionName='Central';
     con.showplannedjobs();
     
     con.AreaName='';
     con.RegionName='Central';
     con.showplannedjobs();
     
     con.AreaName='';
     con.RegionName='';
     con.showplannedjobs();
     }
     
static testMethod void PlannedJobswithLabelOff() {
   
    PreElectricWork con=new PreElectricWork ();
  
    Account Acc = TestClassHelper.createAccout();
                   insert Acc;
        
    Opportunity opp = TestClassHelper.createCHILead(Acc);
                   insert opp;
    
    Region__c   reg= TestClassHelper.createRegion();
                   insert reg;
                
    District__c dist = TestClassHelper.createDistrict();
    dist.Region__c=reg.id;
    insert dist;
    
    Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,dist.Id);
    job.Installation_Date__c=System.today();
    job.Customer_Journey_Status_Change_Date__c=System.today();
    job.BGNE_Install_Date__c=System.today()+7;
    insert(job);
     
    Job_Element__c jbele = new Job_Element__c();
    jbele.job__c=job.id;
    jbele.Product_ID__c='PE2969';
     
     test.startTest();
     //System.Label.Trial_For_ESD = 'Off';
     con.AreaName='Anglia';
     con.RegionName='Central';
     con.showplannedjobs();
     
     con.AreaName='';
     con.RegionName='Central';
     con.showplannedjobs();
     
     con.AreaName='';
     con.RegionName='';
     con.showplannedjobs();
     test.stopTest();
     }
     
   static testMethod void PlannedJobswithoutdata() {
   
    PreElectricWork con=new PreElectricWork ();
  
    
    Account Acc = TestClassHelper.createAccout();
                insert Acc;
        
    Opportunity opp = TestClassHelper.createCHILead(Acc);
                insert opp;
    
                
    Region__c   reg= TestClassHelper.createRegion();
                insert reg;
                
    District__c dist = TestClassHelper.createDistrict();
    dist.Region__c=reg.id;
    insert dist;
    
    Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,dist.Id);
    job.Installation_Date__c=System.today();
    job.Customer_Journey_Status_Change_Date__c=System.today();
    job.BGNE_Install_Date__c=System.today()+7;
    insert(job);
     
     Job_Element__c jbele = new Job_Element__c();
     jbele.job__c=job.id;
     jbele.Product_ID__c='PE2969';
     
     con.AreaName='';
     con.RegionName='';
     con.getRegionItems();
     
     }
     
     static testMethod void unplannedJobswithdata() {
   
    PreElectricWork con=new PreElectricWork ();
  
    
    Account Acc = TestClassHelper.createAccout();
                insert Acc;
        
    Opportunity opp = TestClassHelper.createCHILead(Acc);
                insert opp;
                
    Region__c   reg= TestClassHelper.createRegion();
                insert reg;
                
    District__c dist = TestClassHelper.createDistrict();
    dist.Region__c=reg.id;
    insert dist;
   
    
    Job__c job  = TestClassHelper.createJob('Pending','Pending',opp.Id,dist.Id);
    job.Customer_Journey_Status_Change_Date__c=System.today();
    job.BGNE_Install_Date__c=System.today()+7;
    insert(job);
     
     Job_Element__c jb = new Job_Element__c();
     jb.job__c=job.id;
     jb.Product_ID__c='P2969';
     
     con.AreaName='Angila';
     con.RegionName='Central';
     con.showunplannedjobs(); 
     
     con.AreaName='';
     con.RegionName='Central';
     con.showunplannedjobs();
     
     con.AreaName='';
     con.RegionName='';
     con.showunplannedjobs(); 
     }
     
     
    static testMethod void unplannedJobswithoutdata() {
   
    PreElectricWork con=new PreElectricWork ();
  
    
    Account Acc = TestClassHelper.createAccout();
                insert Acc;
        
    Opportunity opp = TestClassHelper.createCHILead(Acc);
                insert opp;
                
    Region__c   reg= TestClassHelper.createRegion();
                insert reg;
                
    District__c dist = TestClassHelper.createDistrict();
    dist.Region__c=reg.id;
    insert dist;
   
    
    Job__c job  = TestClassHelper.createJob('Pending','Pending',opp.Id,dist.Id);
    job.Customer_Journey_Status_Change_Date__c=System.today();
    job.BGNE_Install_Date__c=System.today()+7;
    insert(job);
     
     Job_Element__c jb = new Job_Element__c();
     jb.job__c=job.id;
     jb.Product_ID__c='P2969';
     
     con.AreaName='';
     con.RegionName='';
     con.showunplannedjobs();  
     }
     
 static testMethod void testgetRegionItems() 
 {
  
  PreElectricWork controller=new PreElectricWork ();
  
  Account Acc = TestClassHelper.createAccout();
                   insert Acc;
        
    Opportunity opp = TestClassHelper.createCHILead(Acc);
                   insert opp;
    
    Region__c   reg= TestClassHelper.createRegion();
                   insert reg;
                
    District__c dist = TestClassHelper.createDistrict();
    dist.Region__c=reg.id;
    insert dist;
    
    Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,dist.Id);
    job.Installation_Date__c=System.today();
    job.Customer_Journey_Status_Change_Date__c=System.today();
    job.BGNE_Install_Date__c=System.today()+7;
    insert(job);
     
    Job_Element__c jbele = new Job_Element__c();
    jbele.job__c=job.id;
    jbele.Product_ID__c='PE2969';
    insert jbele;
     
     controller.AreaName='Angila';
     controller.RegionName='Central';
     controller.getRegionItems();
     controller.getAreaItems();
 }
 
static testMethod void testWMISNumberSearch() {
PreElectricWork controller=new PreElectricWork ();
  
  User user = TestClassHelper.createUser();
  insert user;
  
  Account Acc = TestClassHelper.createAccout();
                   insert Acc;
        
    Opportunity opp = TestClassHelper.createCHILead(Acc);
                   insert opp;
                   
    Contact con = TestClassHelper.createContact(Acc);
    insert con;
    
    Employee__c emp = TestClassHelper.createEmployee();
    emp.Salesforce_User__c=user.id;
    insert emp;
    
    Region__c   reg= TestClassHelper.createRegion();
                   insert reg;
                
    District__c dist = TestClassHelper.createDistrict();
    dist.Region__c=reg.id;
    insert dist;
    
    Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,dist.Id);
    job.Installation_Date__c=System.today();
    job.Customer_Journey_Status_Change_Date__c=System.today();
    job.BGNE_Install_Date__c=System.today()+7;
    insert(job);
     
    Job_Element__c jbele = new Job_Element__c();
    jbele.job__c=job.id;
    jbele.Product_ID__c='PE2969';
    insert jbele;
    
    /*RecordType recordType = [SELECT Id, sObjectType,Name FROM RecordType WHERE Name='Appointment' and sObjectType='Appointment__c'];
    Appointment__c appt = TestClassHelper.createAppointment(opp,emp.id, user.id,recordType.id, con.id);
    appt.Midas_Number__c = '1234';
    appt.OwnerId = user.id;
    insert appt;*/
     Pre_Electrical_Work_Document__c pe = new Pre_Electrical_Work_Document__c(At_Risk_Situation_Identified__c='No',Job__c=job.id,Next_Action_Date__c=System.today(),WMIS_Reference_Number__c='1234');
     insert pe;
     
     controller.WMISNumber='1234';
     controller.onClickSearch();
}
}