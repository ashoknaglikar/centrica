/*
* CLASS - bUPD_bDEL_toggleChkCommentStatus_Test
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to run unit test
            of bUPD_bDEL_toggleChkCommentStatus trigger on CaseComment object.
*/

@isTest
private class bUPD_bDEL_toggleChkCommentStatus_Test
{
    static testMethod void MyunitTestMethos()
    {
        //CREATING TEST DATA.
        Account account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');        
        insert account;        // Insert mandatory fields in the Account                          
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
        MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',FirstName='First name',Email='test@gmail.com',AccountId=account.Id);             
        insert contact;        // Insert mandatory fields in the Contact 
        
        //Employee__c emp = [select id,Name,Emp_type__c,Group__c,Resource_Type__c,Last_Name__c,Employee_Number__c,First_Name__c from Employee__c limit 1];
        //insert emp;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Employee_Number__c = '0002991');        
        insert emp;
        
        Opportunity opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(),AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar',Referral_Employee__c=emp.ID);          
        insert (opportunity); 
      
        Region__c region = new Region__c(Code__c='25',Geography_Code__c='12',Type__c='Installation',Name='Singland');                    
        insert region;
        
        
        District__c district = new District__c();
        district.Code__c='4411';
        district.Name='sambroun';
        district.Region__c=region.Id;
        insert district;

        Job__c job = new Job__c(CHI_Lead__c = opportunity.ID, Status__c = 'Installed',PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                            Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,Electrical_Hours__c = 1,Is_Remedial_Job__c = false, 
                            Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,Is_Downtime_Job__c = false ,
                            Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1,
                            Water_Heating_Fixing_Hours__c =  5,Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                            Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today());                                                                 
            
        job.District__c=district.Id;
            
        insert job; 
        
        User[] inclUpdate = [select id,name from User where name in  ('Dave Rigby','Ann Ord','Andrew Kennedy','Jane Hill','Michael Furneaux','Paul Hancock')];
        List<RecordType> rt= new List<RecordType>([Select r.Name, r.Id From RecordType r where r.Name =:'Complaint']);   
            
        Case ca=new Case();
        ca.RecordTypeId=rt.get(0).Id;
        ca.Sub_Cause__c='Across departments';
        ca.Issued_To_Group__c='Sales';
        ca.Case_Source__c='BSI';
        ca.Classification__c='Office';
        ca.Reason='Existing problem';
        ca.Primary_Cause__c='Repeat';
        ca.Subject='mysubject';
        ca.Description='testDescription';
        ca.Communication_status__c='Awaiting customer';
        ca.Priority='Medium';
        ca.Sub_Cause__c='Across departments';
        //ca.Comments='myComments';
        ca.ContactID=contact.ID;
        ca.Job__c=job.ID;
        ca.AccountID=account.ID;
        ca.Opportunity__c=opportunity.ID;
        insert ca;
        
        CaseComment c=new CaseComment();
        c.ParentId=ca.id;
        insert c;  
        
        
        Map<Id,User> userMap = new Map<Id,User>();
        List<User> users= [select id,name from User 
                where name in ('Dave Rigby','Ann Ord','Andrew Kennedy','Jane Hill','Michael Furneaux','Paul Hancock')];
        
        for(User u : users)
        {
            userMap.put(u.id,u);            
        }
        
        if(userMap.containsKey(UserInfo.getUserId()))
        {
            delete c;        
        }
        
    }
}