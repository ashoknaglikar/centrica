@isTest 
private class populate_Installer_and_Create_Event_Test 
{    
   
    public static testmethod void populateInstaller_and_CreateEvent()
    {
        Supplier__c supplier = new Supplier__c(Name = 'TestSupp', Supplier_Num__c = 'x12345',Type__c = 'Product');
        
        Database.insert(supplier);
    
        Employee__c Em = new Employee__c();
        Em.Name = 'Test';
        Em.First_Name__c='nTest';
        Em.Last_name__c='Test';
        Em.Employee_Number__c='123213';
        Em.Salesforce_User__c = UserInfo.getUserid();
        Em.Resource_Type__c = 'Installer';
        Em.Supplier__c = supplier.Id;
        Insert Em;
        
         Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
        Insert sp;
               
        
        Week__c ws = new Week__c();
        ws.Employee__c = Em.id;
        ws.Shift_pattern__c = sp.id;
        Insert ws;
        date myDate = date.today();
     	 Job__c job = new Job__c(Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=1, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =1, 
                                Customer_Preferred_Date__c = Date.today(), Installation_Date__c = Date.today(),
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = true);
        insert job;
        
        Diary_Entry__c dc = new Diary_Entry__c();
        dc.Week__c = ws.id;
        dc.Job__c =job.id;
        dc.Start__c = System.today();
        dc.End__c = System.today()+1;
        dc.Type__c = 'Job Booking';
        dc.hours__c = 20;
        dc.Sub_Type__c = 'Mechnaical';
      	insert dc;
        
  		
    
    }
    
    }