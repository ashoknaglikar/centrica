@isTest(SeeAllData=true)

public class BriefSearchController_test {

    static testMethod void mbTest() 
    {
        //Id mbcId;
        BriefSearchController bsc = new BriefSearchController();
        
        
        User u= TestClassHelper.createUser();
        u.Brief_User__c = false;
        insert u;
        
        Employee__c emp= TestClassHelper.createEmployee();
        insert emp;
        
        Mandatory_Briefing_Creator__c mbc = new Mandatory_Briefing_Creator__c(Content__c='test123',Name__c = 'test mbc'+system.now(),Employee__c = emp.Id, Issued_Date_Time__c = system.now()+1 , Actual_End_Date_Time__c = system.now()+10 );
        insert mbc;
        //bsc.mbcId=mbc.id; 
        //mbc.Actual_Start_Date_Time__c= datetime.now();
       // mbc.Actual_End_Date_Time__c=datetime.now()+1;
        //mbc.Name__c = 'test mbc'+system.now();
        //update mbc;
        
        Mandatory_Briefings__c mb= new Mandatory_Briefings__c(Mandatory_Briefing_Creator__c = mbc.Id,Briefing_Name__c = mbc.Name__c);
        //mb.Briefing_Name__c = mbc.Name__c;
        mb.Completed_By__c = mbc.Employee__r.Salesforce_User__c;
        mb.Employee__c = mbc.Employee__r.Id;
        mb.Content__c = mbc.Content__c;
        mb.Status__c = 'In Progress';
        mb.Over_All_Status_Text__c ='Red';
        insert mb; 
        
        Mandatory_Briefings__c mb1= new Mandatory_Briefings__c(Mandatory_Briefing_Creator__c = mbc.Id,Briefing_Name__c = mbc.Name__c);
        //mb.Briefing_Name__c = mbc.Name__c;
        mb.Completed_By__c = mbc.Employee__r.Salesforce_User__c;
        mb.Employee__c = mbc.Employee__r.Id;
        mb.Content__c = mbc.Content__c;
        //mb.Mandatory_Briefing_Creator__c = mbc.Id;
        mb.Status__c = 'In Progress';
        mb.Over_All_Status_Text__c ='Blue';
        insert mb1;
        
        Mandatory_Briefings__c mb2= new Mandatory_Briefings__c(Mandatory_Briefing_Creator__c = mbc.Id,Briefing_Name__c = mbc.Name__c);
        //mb.Briefing_Name__c = mbc.Name__c;
        mb.Completed_By__c = mbc.Employee__r.Salesforce_User__c;
        mb.Employee__c = mbc.Employee__r.Id;
        mb.Content__c = mbc.Content__c;
        //mb.Mandatory_Briefing_Creator__c = mbc.Id;
        mb.Status__c = 'In Progress';
        mb.Over_All_Status_Text__c ='Amber';
        insert mb2;
        
        Mandatory_Briefings__c mb3= new Mandatory_Briefings__c(Mandatory_Briefing_Creator__c = mbc.Id,Briefing_Name__c = mbc.Name__c);
        //mb.Briefing_Name__c = mbc.Name__c;
        mb.Completed_By__c = mbc.Employee__r.Salesforce_User__c;
        mb.Employee__c = mbc.Employee__r.Id;
        mb.Content__c = mbc.Content__c;
        //mb.Mandatory_Briefing_Creator__c = mbc.Id;
        mb.Status__c = 'In Progress';
        mb.Over_All_Status_Text__c ='Green';
        insert mb3;

        
        List<Mandatory_Briefings__c> blueBriefslist = new List<Mandatory_Briefings__c>();
        blueBriefslist.add(mb);
        
        List<Mandatory_Briefings__c> redBriefslist = new List<Mandatory_Briefings__c>();
        blueBriefslist.add(mb1);
        
        List<Mandatory_Briefings__c> amberBriefslist = new List<Mandatory_Briefings__c>();
        blueBriefslist.add(mb2);
        
        List<Mandatory_Briefings__c> GreenBriefslist = new List<Mandatory_Briefings__c>();
        blueBriefslist.add(mb3);
     
        bsc.searchCreator();
        bsc.flagName='Blue';
        bsc.flagName='Green';
        bsc.showBriefs();
        bsc.flagName='Amber';
        bsc.showBriefs();
        bsc.flagName='Red';
        bsc.showBriefs();
        bsc.flagName='All';
        bsc.showBriefs();
        //bsc.searchBriefs();

        //bsc.showBriefs();
      
 }
    
    
}