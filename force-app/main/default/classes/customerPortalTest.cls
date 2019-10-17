@istest
public class customerPortalTest {
    
     public static testmethod void  portalAPIs()
    {
      Account acc = TestClassHelper.createAccout();
      insert acc;
    
      Contact con = TestClassHelper.createContact(acc);
      insert con;
    
      Opportunity opp  = TestClassHelper.createCHILead(acc);
      insert opp;
        
      BigMachines_Quote__c quote = TestClassHelper.createBMQuote(opp);
      insert quote;
        
      /*District__c district = TestClassHelper.createDistrict();
      insert district;*/
      
      District__c district = Phase3TestHelper.createTestGeographyDistrict();
      
      Job__c job = TestClassHelper.createJob('Pending', 'Install Date required', opp.id, district.id);        
      insert job;
      
      order__c ord=new order__c(Delivery_Date_Changed__c=true,Type__c = 'Material',Status__c = 'Approved',job__c=job.id );
        //District__c district = Phase3TestHelper.createTestGeographyDistrict();
        /*Supplier__c supp = [Select s.Type__c, s.SystemModstamp, s.Supplier_Num__c, s.Street__c, s.State__c, s.Start_Date__c, 
                s.Resource_Type__c, s.Postcode__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, 
                s.IsDeleted, s.Id, s.GasSafe_Business_ID__c, s.End_Date__c, s.Description__c, s.CreatedDate, s.CreatedById, 
                s.Country__c, s.City__c
                From Supplier__c s where s.Supplier_Num__c= :'2017' LIMIT 1];*/
                
         /*Employee__c e = new Employee__c(Name = 'testSBB1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                            District__c = district.Id, Net_Promoter_Score__c = 10);
        Database.insert(e);*/
       
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
       
       
      
      Search_Result__c sr = new Search_Result__c(Option_Identifier__c = 'realOptionID', Job_ID__c = job.ID, Gap_Tolerance__c=0,
                                    Diary_Entry_ID__c = de.ID, Start_Date_Time__c = startDT, End_Date_Time__c = startDT.addHours(1),
                                    Hours__c = 1.0, Skill__c = 'Skill');
      Database.insert(sr);
        
      String leadId = String.valueOf(opp.id);
      String quoteId = String.valueOf(quote.id);
      string jobId = String.valueOf(job.id);
        
      String delNotes = 'test delivery notes';
      String insNotes = 'test install notes';
      String optionIDSel1 ='realOptionID';
      String optionIDSel;
      boolean bringForwardJob,confirmFlag = true;        
      date callbackDate,insdate = System.today();
      String callBackTime ='09:00-10:00';
      String navigate = 'next';
      String paymentType ='Finnace';
      String instime ='08:00';
      String safePlaceFlag,restrictionFlag = 'Yes';
      date deliveryDate = System.today();
      String deliverySlot= '07:00-11:00';
        
      
      customerPortalCallbackAPI.callback(leadid,jobid,quoteId,callbackDate,callBackTime);
      customerPortalretrunInstallDeliveryAPI.returnDeliveryInstallDate(leadid,quoteId,jobid,insdate,instime,optionIDSel,bringForwardJob,delNotes,insNotes,confirmFlag,safePlaceFlag,restrictionFlag);
      try{      
      customerPortalBookJobAPI.bookJob(leadid,quoteId,jobid,insdate,instime,optionIDSel,bringForwardJob,delNotes,insNotes,confirmFlag,deliveryDate,deliverySlot);
       }catch(Exception ex)
       {}
    }
 }