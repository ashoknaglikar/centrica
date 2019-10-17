@isTest

public class update_Employee_Skills_Helper_Test{
    static Employee_Skills__c empSkill;
    static Employee__c emp;
    //static update_Employee_Skills_Helper helper = new update_Employee_Skills_Helper();
    
    static void createData(){
        emp = TestClassHelper.createEmployee();
        insert emp;
        empSkill = new Employee_Skills__c(Employee__c = emp.id, Skill_Name__c='Asbestos Removal');
        insert empSkill;
    }
    
    static testmethod void insertEmpSkill(){
       createData(); 
    }
    
    static testmethod void updateEmpSkill1(){
       createData();
       Update empSkill;
    }
    
    static testmethod void updateEmpSkill2(){
       createData();
       Update empSkill;
    }
    
    static testmethod void updateEmpSkill3(){
       createData();
       empSkill.Skill_Name__c = 'Building Work';
       Update empSkill;
    }
    
    static testmethod void deleteEmpSkill(){
       createData();
       Delete empSkill;
    }
}