public with sharing class EmployeeSearchController 
{
	/*---------------------PUBLIC PROPERTIES-------------------------------*/
	public string searchText{get; set;}
	public String Err_msg{get; set;}
	public List<Employee__c> EmployeesList {get; set;}
	public Employee__c NewEmployee{get; set;}
	public Boolean searchMode{get; set;}
	public Boolean SaveError{get; set;}
	 
	/*---------------------CONSTRUCTOR-------------------------------------*/
	//Default constructor
	public EmployeeSearchController(ApexPages.StandardController controller) 
	{
        EmployeesList = new List<Employee__c>();
        getAllEmployees();
        searchMode = true;
        SaveError = false;
	}
	
	/*---------------------EVENTS------------------------------------------*/
	//Event to handle click event of "Go" button
	public void SearchEmployee()
	{
		findEmployee();
	}
	
	//Event to handle click event of "New" button
	public void CreateNewEmployee()
    {
    	searchMode = false;
    	System.debug('>>>>>>>>>>>>. searchMode = ' + searchMode);
    	NewEmployee = new Employee__c();
    	//NewEmployee.Name = 'NAME';
    	//NewEmployee.Last_Name__c = 'LNAME';
    }
    
    public void Cancel()
    {
    	searchMode = true;
    	System.debug('>>>>>>>>>>>>. searchMode = ' + searchMode);
    }
    
    public void Save()
    {
    	try
    	{
    		insert NewEmployee;
    		SaveError = false;
    	}
    	catch(Exception ex)
    	{
    		err_msg = ex.getMessage();
    		SaveError = true;
    	}
    }
	/*---------------------PRIVATE METHODS---------------------------------*/
	//Searches for an employee
    private void findEmployee() 
    {
        String searchText_dup = searchText;
        
        if(searchText != null)
        {
            
            err_msg=null;
            searchText_dup=searchText_dup.replace('*','');
            if(searchText_dup.length()>1)
            {
                try
                {
                	searchText +='*';
                    EmployeesList = (List<Employee__c>)[FIND :searchText IN ALL FIELDS RETURNING Employee__c (ID, Name, First_Name__c, Last_Name__c, Employee_Number__c, Emp_type__c, Email__c, Phone_No__c, Group__c,	Advisor_Id__c)][0];
                }
                catch(Exception e){}
            }
            else
            {
                EmployeesList.clear();
                Employee__c obj = new Employee__c();
                obj.Name='No Matches Found';
                EmployeesList.add(obj);    
            }            
        }
    }
    
    //Gets all employees
    private void getAllEmployees()
    {
		EmployeesList = [select ID, Name, First_Name__c, Last_Name__c, Employee_Number__c, Emp_type__c, Email__c, Phone_No__c, Group__c,Advisor_Id__c from Employee__c limit 50];
    }
}