public class scaffoldViewController {

/* 
WP20515 - Scaffolding view - 17/08/18 - Phil Dennison, requested by UKI George Moore
List all work related to a company/supplier.  
A user must have an EMPLOYEE__c linked to their USER record.  The EMPLOYEE__C record must be linked to the required 'SUPPLIER__c'.
*/

public boolean showDetail{get;set;} 
public employee__c employeeDetail{get;set;}
public String selectedJobID{get;set;}

public id opportunityID{get;set;}
public id supplierID{get;set;}

public List<attachment> attachmentList{get;set;}
public List<job_element__c> jobElementList{get;set;}
public List<order__c> jobSAPList{get;set;}
public List<diary_entry__c> resourceList{get;set;}

public job__c selectedJOBObj{get;set;}

public job__c jobInfo{get;set;}
public list<order__c> orderList{get;set;}


// Used for date input fields
public job__c startDate1{get;set;}
public job__c endDate1{get;set;}

//Render control
public Boolean showWorkList{get;set;}
public Boolean jobListSection{get;set;}
public Boolean showJobDetails{get;set;}
public Boolean invalidDates = true;

    // Run section when page loads
    public scaffoldViewController(){
         getEmployeeInfo();
         jobListSection = false;
         showJobDetails = false;
         startDate1 = new Job__c();
         endDate1   = new Job__c();
         selectedJOBObj = new job__c();
         startDate1.Installation_Date__c = date.today();
         endDate1.Installation_Date__c = date.today();
    }

    // Search function to grab all work between a given date range.
    public PageReference Search(){
                showJobDetails = false;
                checkDates();
                if(!invalidDates){
                    getPurchaseOrders(); // Based on employee supplier get orders
                }
                return null;
    } // End of search function

    public void getEmployeeInfo(){
        list<employee__c> empList = [  SELECT id, name, supplier__c, supplier__r.name
                            FROM employee__c 
                            WHERE Salesforce_User__c =: UserInfo.getUserId()]; 

        if(empList.size()>0  && empList[0].supplier__c != NULL){
            employeeDetail = empList[0];
            supplierID =  employeeDetail.supplier__c;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There are no employees or supplier details found.  Please contact your administrator'));
        }
    }
    
    // Find all purchase orders between the search dates.
    public void getPurchaseOrders(){
        orderList = [SELECT id, name, sap_number__c, supplier__c, order_value_text__c, job__c, job__r.name, job__r.customer_name__c, job__r.installation_date__c,
                     job__r.Install_Street__c, job__r.Install_Postcode__c, Total_Order_Value__c, job__r.id, job__r.CHI_Lead_Name__c
                     FROM order__c
                     WHERE supplier__c =: supplierID
                     AND job__r.installation_date__c >=: startDate1.Installation_Date__c 
                     AND job__r.installation_date__c <=: endDate1.Installation_Date__c
                     AND status__c != 'Cancelled'
                     ORDER BY job__r.installation_date__c
                     limit 100];
        
        if(orderList.size() == 0){
            // warning type - CONFIRM ERROR FATAL INFO WARNING.
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There are no orders between those dates. '));
        }
      
    }
    
    public void getJobDetails(){
        jobInfo =   [SELECT id, name, Installation_Date__c, Vulnerable_Customer__c, DHM_Name__c, DHM_Phone__c, CAM_Name__c, Latest_customer_category__c,
                     Customer_Name__c, Install_Street__c, Installation_County__c, Install_Postcode__c, chi_lead__r.id,  CHI_Lead_Name__c, district__r.Customer_Account_Manager_Phone__c,
                     Latest_customer_category_indicator__c
                    FROM job__c WHERE id =: selectedJobID];
        
        opportunityID = jobInfo.chi_lead__r.id;
        jobListSection = true;
        getJobElements();
        getSAPList();
        getPhotos();
        
    }
    
    public void getPhotos(){
        attachmentList = [SELECT id, parentID, Name, createdDate, CreatedByID, ContentType FROM attachment WHERE parentID =: opportunityID];
    }
    
    public void getJobElements(){
        jobElementList = [SELECT id, name, order__c, type__c, current_supplier__c, description__c, skill__c, supplier_order_number__c, units__c, Code__c, unitsFormula__c
                          FROM job_element__c
                          WHERE order__r.supplier__c =: supplierID
                          AND job__c =: selectedJobID
                          AND order__r.status__c != 'Cancelled'];
    }
    
    public void getSAPList(){
        jobSAPList = [SELECT id, name, sap_number__c, supplier__c, order_value_text__c, job__c, job__r.name, Total_Order_Value__c, createdDate, status__c
                      FROM order__c
                      WHERE job__c =: selectedJobID
                      AND supplier__c =: supplierID
                      AND status__c != 'Cancelled'];
    }
    
    public void getResourceList(){
        resourceList = [select id, employee_name__c, employee_phone__c, week__r.employee__r.first_name__c, week__r.employee__r.last_name__c, sub_type__c
                        FROM diary_entry__c
                        WHERE job__c =: selectedJobID
                        AND sub_type__c = 'Mechanical'];
    }
    
    public void checkDates(){
        
        showWorkList = true;
        invalidDates = false;
        jobListSection = true;
        showJobDetails = true;
        
        if(startDate1.Installation_Date__c == null || endDate1.Installation_Date__c == null){
            showJobDetails = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Both start and end date must be populated'));
            invalidDates = true;
        }else if(startDate1.Installation_Date__c > endDate1.Installation_Date__c){
            showJobDetails = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Start date must be before end date.'));
            invalidDates = true;
        }else if(startDate1.Installation_Date__c.daysBetween(endDate1.Installation_Date__c) > 25){
            showJobDetails = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'The time frame cannot be more that 25 days.'));
            invalidDates = true;
        }
        
        if(invalidDates){
            jobListSection = false;
            showJobDetails = false;
        }
        
    }
    
    public void getSelected(){
        showJobDetails = true;
        getJobDetails();
        getResourceList();
    }
    

}