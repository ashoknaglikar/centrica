@RestResource(urlMapping='/engineerPayrollCheck/*')
Global class engineerCallAppPayRollCheck {
    @HttpPost    
    global static Boolean engineerPayrollcheck(string engineerPayrollNumber)
    {
        Boolean employeeExist=false ;
        List<Employee__c> emp= new List<Employee__c>();
        if(string.isNotBlank(engineerPayrollNumber))
        {
            emp=[select id from Employee__c where employee_number__c=:engineerPayrollNumber /*AND Group__c='ENGI'*/];
            
        }
        if(emp.size()>0){
            employeeExist=TRUE;
        }
        return employeeExist; 
        
    }
    
}