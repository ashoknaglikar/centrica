@isTest (SeeAllData=true)

private class GeographyChangeReqController_Test{
    static Account acc;
    static Contact contact;
    static User user;
    static Opportunity oppo; 
    static Employee__c emp;
    static Role__c role; 
    static Role_Sub_Patch__c rsbp;  
    static Diary_Change__c diaryChng;
    static Diary_Change_Request__c week;
    static District__c  dist;
    static Sub_Patch__c sb;
    
    static void createData(){
        user = TestClassHelper.createUser();
        insert user;       
        acc = TestClassHelper.createAccout();
        insert acc;              
        contact = TestClassHelper.createContact(acc);
        insert contact;              
        oppo = TestClassHelper.createCHILead(acc);
        insert oppo;             
        emp = TestClassHelper.createEmployee();
        insert emp; 
        role = new Role__c(Employee__c=emp.id,Start_Date__c=Date.valueOf('2000-01-01'),End_Date__c=Date.valueOf('2999-01-01'));
        insert role;
        
        dist = TestClassHelper.createdistrict();
        insert dist;
        sb = new Sub_Patch__c(Name='Sales_Dist_UNALLOC_P99',Code__c='HT99_Tes',Country_Differentiator__c='England',District__c=dist.id,Type__c='Sales',Upsert_Reference__c='HT99_P99_Inactive_OldSales');
        insert sb;
        
        rsbp = new Role_Sub_Patch__c(Role__c=role.id,Type__c='Availability',Sub_Patch__c=sb.Id,Start_Date__c=Date.valueOf('2014-12-01'),End_Date__c=Date.valueOf('2014-12-30'));
        insert rsbp;     
        
        id avail = RecordTypeIdHelper.getRecordTypeId('Diary_Change__c', 'Availability & Geography');  
        
        diaryChng = new Diary_Change__c(RecordTypeId = avail ,Employee__c=emp.id,Start__c=Date.valueOf('2014-12-01'),StartDT__c=Datetime.newInstance(2014,12,1,8,0,0),No_Of_Weeks__c=1,Week_1__c=true,Unavailability_Reason__c='Not Applicable');
        insert diaryChng;
        week = new Diary_Change_Request__c(Diary_Change_Master__c=diaryChng.id,Week_Number__c=1,Mon_PM_RoleWk1__c='HT03_S07');
        insert week;      
        PageReference page = new PageReference('/apex/GeographyChangeReqPage?var_DCId='+diaryChng.id); 
        Test.setCurrentPage(page);                 
    } 
    

    static testmethod void testmethod1(){
        createData();
        GeographyChangeReqController controller = new GeographyChangeReqController();
        GeographyChangeReqController.RoleSubPatchWrap controller1 = new  GeographyChangeReqController.RoleSubPatchWrap(true,rsbp);      
        controller.onSelect(); 
        controller.onClickRefresh();  
        controller.onClickBack();  
    }
     
     static testmethod void testmethod2(){
        createData();
        GeographyChangeReqController controller = new GeographyChangeReqController();
        controller.Beginning();
        controller.Next();
        controller.Previous();
        controller.End();
        controller.getDisablePrevious(); 
        controller.getDisableNext(); 
        controller.getTotal_size();
        controller.getPageNumber();
        controller.getTotalPages();
     }
     
    static testmethod void testmethod3(){
        createData();
        GeographyChangeReqController controller = new GeographyChangeReqController();
        controller.getRoleSubPatches();
        controller.onClickDeleteAll();
        controller.onClickDeleteSelected();
        controller.onClickGeography();
        controller.checkValid(rsbp); 
    }
}