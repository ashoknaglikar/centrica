/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class BookJobOptionController_Test {

   
   static testmethod void testController1() {
        PageReference pageRef = new PageReference('/apex/BookJobOption');
        Test.setCurrentPage(pageRef);
        BookJobOptionController bjoc = new BookJobOptionController();
        //bjoc.populateResults();
        
        pageRef = new PageReference('/apex/BookJobOption?optionID=nosuchID&jobId=nosuchID');
        Test.setCurrentPage(pageRef);
        bjoc = new BookJobOptionController();
        try {
                 bjoc.populateResults();
        } catch(Exception ex) {
                 // Do nothing
        }
        Job__c j = Phase3TestHelper.createJob1();
        j.Job_Reason__c = 'Not within Standard';
        j.CRD_Code__c = 'Asbestos';
        j.squeeze_job__c = false; //squeeze job change test
        update j;
        Employee__c e = Phase3TestHelper.createEmployee();
        
        Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
        Database.insert(sp);
        Week__c w = new Week__c(Employee__c = e.ID, Week_Commencing__c = Date.today().toStartOfWeek(), Shift_Pattern__c = sp.ID);
        Database.insert(w);
        DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(9,0,0,0));
        DateTime endDT = DateTime.newInstance(Date.today().toStartOfWeek().addDays(4), Time.newInstance(17,0,0,0));
        Diary_Entry__c de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,Sub_Type__c='NWD - Working',
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));
        Database.insert(de);
        Search_Result__c sr = new Search_Result__c(Option_Identifier__c = 'realOptionID', Job_ID__c = j.ID,Gap_Tolerance__c=0,
                                    Diary_Entry_ID__c = de.ID, Start_Date_Time__c = startDT, End_Date_Time__c = startDT.addHours(1),
                                    Hours__c = 1.0, Skill__c = 'Skill');
        Database.insert(sr);
        pageRef = new PageReference('/apex/BookJobOption?optionID=realOptionID&jobId='+j.ID);
        Test.setCurrentPage(pageRef);
        try {
          bjoc = new BookJobOptionController();
          bjoc.populateResults();
        } catch(Exception ex) {
          // Do nothing
        }
        try {
                bjoc.bookOption(); // This will cause an exception(Changed)
                
                
                pageRef = new PageReference('/apex/BookJobOption?optionID=realOptionID&jobId='+j.ID);
                Test.setCurrentPage(pageRef);
                bjoc = new BookJobOptionController();
                j.status__c = 'Planned';
                j.sub_status__c = 'ASP Added';
                update j;
                bjoc.currentInstallDate = Date.today()+2;
                bjoc.populateResults();
                bjoc.bookOption();
                
                bjoc.JPH.Re_Plan_Reason__c = 'Double hand required';
                bjoc.bookOption();
                
                bjoc.serviceLevel = '-None-';
                bjoc.jph.Re_Plan_Sub_Reason__c = 'Roof Work';
                bjoc.bookOption();
                
                bjoc.serviceLevel='Within Standard';
                bjoc.job.DPA_Done__c = 'Yes';
                bjoc.smFlag = true;
                bjoc.job.Smart_Meter_Required_Flag__c = '';
                bjoc.job.not_booked__c = false;
                bjoc.job.Installation_Date__c =date.today().toStartOfWeek()-2;
                bjoc.job.Delivery_Date__c=Date.today().toStartOfWeek()-1;
                bjoc.bookOption();
                
                bjoc.job.Smart_Meter_Required_Flag__c = 'Yes';
                bjoc.job.Delivery_Date__c=Date.today()+8;
                bjoc.currentInstallDate= Date.today()+7;
                bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
                bjoc.bookOption();
                
                bjoc.job.Smart_Meter_Required_Flag__c = NULL;
                bjoc.job.Delivery_Date__c=Date.today()+8;
                bjoc.currentInstallDate= Date.today()+8;
                bjoc.job.Smart_meter_installation_date__c = NULL;
                bjoc.bookOption();
               
                
                bjoc.job.Smart_Meter_Required_Flag__c = 'Yes';
                bjoc.job.Delivery_Date__c=Date.today()+8;
                bjoc.currentInstallDate= Date.today()+8;
                bjoc.job.Smart_meter_installation_date__c = NULL;
                bjoc.bookOption();
                
                bjoc.job.Smart_Meter_Required_Flag__c = 'Yes';
                //bjoc.job.SMInstalltionTime__c = '08:00 - 13:00';
                bjoc.job.SMInstalltionTime__c = NULL;
                bjoc.job.Delivery_Date__c=Date.today()+8;
                bjoc.currentInstallDate= Date.today()+9;
                bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
                bjoc.bookOption();
                
                bjoc.job.Smart_Meter_Required_Flag__c = 'Yes';
                bjoc.job.SMInstalltionTime__c = '08:00 - 13:00';
                bjoc.job.Delivery_Date__c=Date.today()+8;
                bjoc.currentInstallDate= Date.today()+9;
                bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
                bjoc.bookOption();
                
                bjoc.failedInstall.Cause__c='Customer Cancelled';
                bjoc.failedInstall.Reason__c='Cost Related';
                bjoc.job.Delivery_Date__c=Date.today()+8;
                bjoc.priorDeliveryDate =date.today()+6;
                bjoc.currentInstallDate= Date.today()+9;
                bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
                bjoc.bookOption(); 
                
                bjoc.goback();
                bjoc.errorMsg = 'test';
                bjoc.setErrorMsg();
                
                 
        } catch(Exception ex) {
                // Do nothing
        }
    }
   static testmethod void testController3() {
        
        
        Job__c j = Phase3TestHelper.createJob1();
        j.Job_Reason__c = 'Green Deal';
        j.CRD_Code__c = 'Green Deal';
        update j;
        
        Job__c j1 = Phase3TestHelper.createJob5();
        j1.Job_Reason__c = 'Customer Requested';
        j1.CRD_Code__c = 'Direct labour only';
        update j1;
        
        order__c ord=new order__c(Delivery_Date_Changed__c=true,Type__c = 'Material',Status__c = 'Approved',job__c=j.id );
        District__c district = Phase3TestHelper.createTestGeographyDistrict();
        Supplier__c supp = [Select s.Type__c, s.SystemModstamp, s.Supplier_Num__c, s.Street__c, s.State__c, s.Start_Date__c, 
                s.Resource_Type__c, s.Postcode__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, 
                s.IsDeleted, s.Id, s.GasSafe_Business_ID__c, s.End_Date__c, s.Description__c, s.CreatedDate, s.CreatedById, 
                s.Country__c, s.City__c
                From Supplier__c s where s.Supplier_Num__c= :'2017' LIMIT 1];
                
         Employee__c e = new Employee__c(Name = 'testSBB1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                            District__c = district.Id, Net_Promoter_Score__c = 10);
        Database.insert(e);
       
        //Employee__c e = Phase3TestHelper.createEmployee();
        Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
        Database.insert(sp);
        
         
        Week__c w = new Week__c(Employee__c = e.ID, Week_Commencing__c = Date.today().toStartOfWeek(), Shift_Pattern__c = sp.ID);
        Database.insert(w);
        DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(9,0,0,0));
        DateTime endDT = DateTime.newInstance(Date.today().toStartOfWeek().addDays(4), Time.newInstance(17,0,0,0));
        Diary_Entry__c de = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,Sub_Type__c='NWD - Working',job__c=j.id,
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));
       
        Database.insert(de);
        
        Diary_Entry__c de1 = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,Sub_Type__c='Mechanical',job__c=j.id,
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
        database.insert(de1);
        
        Diary_Entry__c de2 = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,Sub_Type__c='Mechanical',job__c=j1.id,
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
        database.insert(de2);
        
        Search_Result__c sr = new Search_Result__c(Option_Identifier__c = 'realOptionID', Job_ID__c = j.ID, Gap_Tolerance__c=0,
                                    Diary_Entry_ID__c = de1.ID, Start_Date_Time__c = startDT, End_Date_Time__c = startDT.addHours(1),
                                    Hours__c = 1.0, Skill__c = 'Skill');
        Database.insert(sr);
        
        Search_Result__c sr1 = new Search_Result__c(Option_Identifier__c = 'realOptionID', Job_ID__c = j1.ID, Gap_Tolerance__c=0,
                                    Diary_Entry_ID__c = de1.ID, Start_Date_Time__c = startDT, End_Date_Time__c = startDT.addHours(1),
                                    Hours__c = 1.0, Skill__c = 'Skill');
        Database.insert(sr1);   
        PageReference pageRef = new PageReference('/apex/BookJobOption?optionID=realOptionID&jobId='+j.ID);
        Test.setCurrentPage(pageRef);
        BookJobOptionController bjoc = new BookJobOptionController();
        try{
        bjoc.populateResults();
        bjoc.bookOption();
        }
        catch(Exception ex){
        }
        pageRef = new PageReference('/apex/BookJobOption?optionID=realOptionID&date='+string.valueof(date.today())+'&jobId='+j.ID);
        Test.setCurrentPage(pageRef);
        try{
            
            test.startTest();
           
            bjoc = new BookJobOptionController();
            j.status__c = 'Planned';
            j.sub_status__c = 'ASP Added';
            j.squeeze_job__c = TRUE;
            update j;
            bjoc.currentInstallDate = Date.today();
            bjoc.populateResults();
            bjoc.CalcOverBookedHours();
            bjoc.bookOption();
            
            bjoc.JPH.Re_Plan_Reason__c = 'Double hand required';
            bjoc.bookOption();
            
            bjoc.serviceLevel = '-None-';
            bjoc.jph.Re_Plan_Sub_Reason__c = 'Roof Work';
            bjoc.bookOption();
            
            bjoc.serviceLevel='Within Standard';
            bjoc.job.DPA_Done__c = 'Yes';
            bjoc.smFlag = true;
            bjoc.job.Smart_Meter_Required_Flag__c = '';
            bjoc.job.not_booked__c = false;
            bjoc.job.Installation_Date__c =date.today().toStartOfWeek()-2;
            bjoc.job.Delivery_Date__c=Date.today().toStartOfWeek()-1;
            bjoc.bookOption();
            
            bjoc.job.Smart_Meter_Required_Flag__c = 'Yes';
            bjoc.job.Delivery_Date__c=Date.today()+8;
            bjoc.currentInstallDate= Date.today()+7;
            bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
            bjoc.bookOption();
            
            bjoc.job.Smart_Meter_Required_Flag__c = NULL;
            bjoc.job.Delivery_Date__c=Date.today()+8;
            bjoc.currentInstallDate= Date.today()+8;
            bjoc.job.Smart_meter_installation_date__c = NULL;
            bjoc.bookOption();
           
            
            bjoc.job.Smart_Meter_Required_Flag__c = 'Yes';
            bjoc.job.Delivery_Date__c=Date.today()+8;
            bjoc.currentInstallDate= Date.today()+8;
            bjoc.job.Smart_meter_installation_date__c = NULL;
            bjoc.bookOption();
            
            bjoc.job.Smart_Meter_Required_Flag__c = 'Yes';
            //bjoc.job.SMInstalltionTime__c = '08:00 - 13:00';
            bjoc.job.SMInstalltionTime__c = NULL;
            bjoc.job.Delivery_Date__c=Date.today()+8;
            bjoc.currentInstallDate= Date.today()+9;
            bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
            bjoc.bookOption();
            
            bjoc.job.Smart_Meter_Required_Flag__c = 'Yes';
            bjoc.job.SMInstalltionTime__c = '08:00 - 13:00';
            bjoc.job.Delivery_Date__c=Date.today()+8;
            bjoc.currentInstallDate= Date.today()+9;
            bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
            bjoc.bookOption();
            
            
            bjoc.failedInstall.Cause__c='Customer Cancelled';
            bjoc.failedInstall.Reason__c='Cost Related';
            bjoc.job.Delivery_Date__c=Date.today()+8;
            bjoc.priorDeliveryDate =date.today()+6;
            bjoc.currentInstallDate= Date.today()+9;
            bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
            bjoc.bookOption(); 
            test.stoptest();
            
            bjoc.goback();
            bjoc.errorMsg = 'test';
            bjoc.setErrorMsg();
            
        }
        catch(Exception ex){
        }
      
        
    }
   
  /* static testmethod void testController4() {
        
        Job__c j = Phase3TestHelper.createJob1();
        j.Job_Reason__c = 'Green Deal';
        j.CRD_Code__c = 'Green Deal';
        update j;
        
        order__c ord=new order__c(Delivery_Date_Changed__c=true,Type__c = 'Material',Status__c = 'Approved',job__c=j.id );
        District__c district = Phase3TestHelper.createTestGeographyDistrict();
        Supplier__c supp = [Select s.Type__c, s.SystemModstamp, s.Supplier_Num__c, s.Street__c, s.State__c, s.Start_Date__c, 
                s.Resource_Type__c, s.Postcode__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, 
                s.IsDeleted, s.Id, s.GasSafe_Business_ID__c, s.End_Date__c, s.Description__c, s.CreatedDate, s.CreatedById, 
                s.Country__c, s.City__c
                From Supplier__c s where s.Supplier_Num__c= :'2017' LIMIT 1];
                
         Employee__c e = new Employee__c(Name = 'testSBB1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                            District__c = district.Id, Net_Promoter_Score__c = 10);
        Database.insert(e);
       
        //Employee__c e = Phase3TestHelper.createEmployee();
        Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
        Database.insert(sp);
        
         
        Week__c w = new Week__c(Employee__c = e.ID, Week_Commencing__c = Date.today().toStartOfWeek(), Shift_Pattern__c = sp.ID);
        Database.insert(w);
        DateTime startDT = DateTime.newInstance(Date.today().toStartOfWeek(), Time.newInstance(9,0,0,0));
        DateTime endDT = DateTime.newInstance(Date.today().toStartOfWeek().addDays(4), Time.newInstance(17,0,0,0));
       
        
        Diary_Entry__c de1 = new Diary_Entry__c(Start__c = startDT, End__c = endDT, Hours__c = 40, Week__c = w.ID,Sub_Type__c='Mechanical',job__c=j.id,
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'));
        database.insert(de1);
        Search_Result__c sr1 = new Search_Result__c(Option_Identifier__c = 'realOptionID', Job_ID__c = j.ID, Gap_Tolerance__c=0,
                                    Diary_Entry_ID__c = de1.ID, Start_Date_Time__c = startDT, End_Date_Time__c = startDT.addHours(1),
                                    Hours__c = 1.0, Skill__c = 'Skill');
        
        Search_Result__c sr2 = new Search_Result__c(Option_Identifier__c = 'realOptionID', Job_ID__c = j.ID, Gap_Tolerance__c=0,
                                    Diary_Entry_ID__c = de1.ID, Start_Date_Time__c = startDT, End_Date_Time__c = startDT.addHours(1),
                                    Hours__c = 1.0, Skill__c = 'Skill');
        Search_Result__c[] sr= new Search_Result__c []{sr1,sr2};
        Database.insert(sr);
        PageReference pageRef = new PageReference('/apex/BookJobOption?optionID=realOptionID&jobId='+j.ID);
        Test.setCurrentPage(pageRef);
        BookJobOptionController bjoc = new BookJobOptionController();
        bjoc.populateResults();
        bjoc.bookOption();
        pageRef = new PageReference('/apex/BookJobOption?optionID=realOptionID&jobId='+j.ID);
        Test.setCurrentPage(pageRef);
        bjoc = new BookJobOptionController();
        j.Status__c = 'Planned';
        j.Sub_Status__c = 'Planned';
        j.Job_Reason__c = 'Within Standard';
        j.CRD_Code__c = 'Within Standard';
        j.DPA_Done__c = 'Yes';
        j.Installation_Date__c = date.today().toStartOfWeek()-2;
        update j;
        bjoc.currentInstallDate = Date.today();
        bjoc.populateResults();
        bjoc.bookOption();
       
        
        bjoc.smFlag = true;
        bjoc.job.Smart_Meter_Required_Flag__c = '';
        bjoc.job.not_booked__c = false;
        bjoc.job.Installation_Date__c =date.today().toStartOfWeek()-2;
        bjoc.job.Delivery_Date__c=Date.today().toStartOfWeek()-1;
        bjoc.bookOption();
        
        bjoc.job.Smart_Meter_Required_Flag__c = 'Yes';
        bjoc.job.Delivery_Date__c=Date.today()+8;
        bjoc.currentInstallDate= Date.today()+7;
        bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
        bjoc.bookOption();
        
        bjoc.job.Smart_Meter_Required_Flag__c = 'Yes';
        bjoc.job.Delivery_Date__c=Date.today()+8;
        bjoc.currentInstallDate= Date.today()+9;
        bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
        bjoc.jph.Re_Plan_Reason__c = 'System Issues';
        bjoc.jph.Re_Plan_Sub_Reason__c = 'Due to diary change';
        bjoc.bookOption();
        
        bjoc.job.Smart_Meter_Required_Flag__c = '';
        bjoc.failedInstall.Cause__c='Customer Cancelled';
        bjoc.failedInstall.Reason__c='Cost Related';
        bjoc.job.Delivery_Date__c=Date.today()+8;
        bjoc.priorDeliveryDate =date.today()+6;
        bjoc.currentInstallDate= Date.today()+9;
        bjoc.job.Smart_meter_installation_date__c = Date.today()+9;
        bjoc.jph.Re_Plan_Reason__c = 'System Issues';
        bjoc.jph.Re_Plan_Sub_Reason__c = 'Due to diary change';
        bjoc.bookOption();
        
        
        bjoc.goback();
        bjoc.errorMsg = 'test';
        bjoc.setErrorMsg();
        
    }*/ 
 }