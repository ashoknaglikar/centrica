@isTest/*(seeAllData=true)*/

public class searchExcessTravelClaimController_Test{
    
      
      static void createData(){
         Account acc = TestClassHelper.createAccout();
         insert acc;
         Opportunity opp = TestClassHelper.createCHILead(acc);
         insert opp;
         Opportunity opp1 = TestClassHelper.createCHILead(acc);
         insert opp1;
         
         Region__c regionRecord = TestClassHelper.createRegion();
         regionRecord.Type__c = 'Installation';
         insert regionRecord;
         
         District__c dist = TestClassHelper.createDistrict(); //[Select id From District__c where Name='Greenwich' Limit 1];
         dist.Name = 'GreenwichTest';
         dist.Code__c = 'Test1';
         dist.Region__c = regionRecord.Id;
         District__c dist1 = TestClassHelper.createDistrict(); //[Select id From District__c where Name='North Scotland' Limit 1];
         dist1.Name = 'North ScotlandTest';
         dist1.Code__c = 'Test2';
         dist1.Region__c = regionRecord.Id;
         insert new list<District__c>{dist,dist1};
         
         Job__c j = TestClassHelper.createJob('Planned', 'Planned', opp.id, dist.id);
         insert j;
         Job__c j1 = TestClassHelper.createJob('Planned', 'Planned', opp1.id, dist1.id);
         insert j1;
         User user=   TestClassHelper.createUser();//[Select id, Name From User where Name='Ashok Kumar Nagaleekar'];
         Employee__c emp=TestClassHelper.createEmployee(); //[Select id,Name From Employee__c where Salesforce_User__c = :user.id];
         emp.Salesforce_User__c = user.Id;
         insert emp;
         Excess_Travel_Claim__c etc = new Excess_Travel_Claim__c(Job__c=j.id,Employee__c = emp.id,Status__c='Aprroved', Approved_Date_Time__c = system.today().adddays(1));
         insert etc; 
         Excess_Travel_Claim__c etc1 = new Excess_Travel_Claim__c(Job__c=j1.id,Employee__c = emp.id,Status__c='Aprroved',  Approved_Date_Time__c = system.today().adddays(1));
         insert etc1; 
     }

    
    static testmethod void method1(){
        createData();
        searchExcessTravelClaimController con = new searchExcessTravelClaimController();
        con.searchClaims();
        
        con.jb.Customer_Journey_First_Update__c = System.today();  
        con.jb.BGNE_Install_Date__c = System.today()+30;
        con.searchClaims();
        
        con.onSelectAll();
        con.getAreaItems();
        con.getRegionItems();
        con.getStatusItems();
    }
    
     static testmethod void method2(){
        createData();
        searchExcessTravelClaimController con = new searchExcessTravelClaimController();
        con.jb.Customer_Journey_First_Update__c = System.today();  
        con.jb.BGNE_Install_Date__c = System.today()+30;
        con.searchClaims();
        con.onSelectAll();
        searchExcessTravelClaimController.ClaimWrap claimObj = new searchExcessTravelClaimController.ClaimWrap(false, new Excess_Travel_Claim__c());
        con.onComplete();
     }
     
     static testmethod void method3(){
        createData();
        searchExcessTravelClaimController con = new searchExcessTravelClaimController();
        con.jb.Customer_Journey_First_Update__c = System.today();  
        con.jb.BGNE_Install_Date__c = System.today()+30;
        con.Status = 'Approved';
        con.searchClaims();
        con.onSelectAll();
        con.onComplete();
        
        con.Status = 'Submitted';
        con.searchClaims();
        con.onSelectAll();
        con.onComplete();
        
        con.Status = 'Approved';
        con.AreaName = 'Greenwich';
        con.searchClaims();
        con.onSelectAll();
        con.onComplete();
        
        con.Status = 'Approved';
        con.AreaName = 'Lancs';
        con.searchClaims();
        con.onSelectAll();
        con.onComplete();
        
        con.Status = 'Approved';
        con.AreaName = '';
        con.RegionName = 'Scotland';
        con.searchClaims();
        con.onSelectAll();
        con.onComplete();
        
        con.Status = 'Approved';
        con.AreaName = '';
        con.RegionName = 'East';
        con.searchClaims();
        con.onSelectAll();
        con.onComplete();
        
        con.Status = '';
        con.RegionName = 'East';
        con.searchClaims();
        con.onSelectAll();
        con.onComplete();
        
        con.Status = '';
        con.RegionName = 'Scotland';
        con.searchClaims();
        con.onSelectAll();
        con.onComplete();
        
        con.Status = '';
        con.AreaName = 'Lancs';
        con.searchClaims();
        con.onSelectAll();
        con.onComplete();
        
        con.Status = '';
        con.AreaName = 'Greenwich';
        con.searchClaims();
        con.onSelectAll();
        con.onComplete();
    }
    
    static testmethod void method4(){
        createData();
        searchExcessTravelClaimController con = new searchExcessTravelClaimController();
        con.jb.Customer_Journey_First_Update__c = System.today();  
        con.jb.BGNE_Install_Date__c = System.today()+30;
        con.Next();
        con.Previous();
        con.getDisablePrevious();
        con.getDisableNext();
        con.getPageNumber();
        con.getTotalPages();
    }
}