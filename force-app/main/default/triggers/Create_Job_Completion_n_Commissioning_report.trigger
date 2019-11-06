trigger Create_Job_Completion_n_Commissioning_report on Job__c (after update) {
    //CreateEmail.CretaeSendTextEmail(new list<string>{'ashoknaglikar@hotmail.co.uk'},'Debug 1' , string.valueof(Lock.createJCD)+ string.valueof(Lock.jobTriggerSwitch)+string.valueof(cls_IsRun.generalTriggerSwitch));
    //code fix done by BGSAMS Support  as part of PRB00009436 - starts
    if(Lock.jobTriggerSwitch || Lock.createJCD)
    {
        System.debug('jobTriggerSwitch : ' +Lock.jobTriggerSwitch);
        System.debug('createJCD : ' +Lock.createJCD);
        return;
    }
  
    //code fix done by BGSAMS Support  as part of PRB00009436 - ends
    //PRB00032289 - transferhrstrg
    if(cls_IsRun.generalTriggerSwitch || cls_IsRun.transferhrstrg)
    {
        return;
    }
    List<Payment_Collection__c> lst_Payment =new List<Payment_Collection__c>{};
    List<Commissioning_Report__c> lst_CReports1= new List<Commissioning_Report__c>();
    //List<Commissioning_Report__c>  lst_CReports2= new List<Commissioning_Report__c>();
    //List<Commissioning_Report__c> lst_CReports3= new List<Commissioning_Report__c>();
    //List<Commissioning_Report__c> lst_CReports4 = new List<Commissioning_Report__c>();
    //List<Commissioning_Report__c> lst_CReports5= new List<Commissioning_Report__c>();
    Boolean blnNewRecord=false;
    Boolean blnJobRePlanned=false;
    map<String,id> map_recordtype=new map<String,id>();
    boolean Createfirst =false;
    boolean  blnreenter =false;
    // Changed for the Agency Changed and To reduce the SOQL limit.: START
    // This will prevent the call to Job sharing class in case of Preallocation quote condition. 
    Job__c jOld = new Job__c();
    for(Job__c j : Trigger.old){
        jOld = j;
    }

    Job__c jNew = new Job__c();
    for(Job__c j:Trigger.New){
        jNew = j;
    }


    if(((jOld.Status__c=='Allocated') && (jOld.Sub_Status__c=='Awaiting Quote')) && (jNew.Status__c=='Planned')){
        Createfirst =true;
    }
    // Changed for the Agency Changed and To reduce the SOQL limit.: END
    
    // Added by Cognizant
    boolean doEnter = false;
    map<Id, string> jobBoilerMap = new map<Id, string>();
    map<string, Product_Order__c> purchaseOrderMap = new map<string, Product_Order__c>();
    for (Job__c j:Trigger.new) {
    System.debug('#' + j.Status__c+'#'+cls_IsRun.isJobCompletion+'#'+j.Suspend_Job__c);
    
    /* Change : CTS
    JCD will be gnerated for downtim Jobs. A label has been created to control.
    */
   
    
    if(j.Status__c=='Planned' && cls_IsRun.isJobCompletion==false && (j.Suspend_Job__c<>True ||  j.Is_Downtime_Job__c))
    {   
        doEnter = true;
       for(Job_Element__c je : [Select Id,Job__c, Product_ID__c, Name from Job_Element__c where Product_ID__c Like 'CBLR%' and Status__c != 'Removed' and Job__c =: j.Id])
       {
        jobBoilerMap.put(je.Job__c, je.Product_ID__c);
       }
       
       
       
       if(jobBoilerMap.size()>0)
       for(Product_Order__c p: [Select id,BGC_NUMBER__c, Product_Code__c, COMPONENT_MAKE__c, COMPONENT_MODEL__c,COMPONENT_TYPE__c  from Product_Order__c where Product_Code__c in :jobBoilerMap.values()])
       {
            purchaseOrderMap.put(p.Product_Code__c, p);
       }
    }
    
    
    } 
   
    // below code fix done to populate the JCD installation date with the installation date on the job while planning on 19/09/2011 BGSAMS support for PRB00004894
    // BGSAMS Support PRB00016041- code fix to remove JCD installation date when the job is suspended starts
   if(((jOld.Installation_Date__c !=jNew.Installation_Date__c)&&(cls_IsRun.isJobCompletion==true)&& (jNew.Status__c=='Planned')) || (jNew.Status__c=='Suspended')) {
   system.debug('old date'+jOld.Installation_Date__c);
   system.debug('new date'+jNew.Installation_Date__c);
   system.debug('new status'+jNew.Status__c);
   
   
  
   
   if ((jOld.Installation_Date__c !=jNew.Installation_Date__c)&&(cls_IsRun.isJobCompletion==true)&& (jNew.Status__c=='Planned' || jNew.Status__c=='Suspended'))
   {
       List<Commissioning_Report__c> cr = [select Id,Job_Installation_Date__c,InstallerName__c from Commissioning_Report__c where Job_Number__c =: jNew.Id];
       for(Commissioning_Report__c jcd:cr)
       {
            if ((jOld.Installation_Date__c !=jNew.Installation_Date__c)&&(cls_IsRun.isJobCompletion==true)&& (jNew.Status__c=='Planned'))
            {
               jcd.Job_Installation_Date__c = jNew.Installation_Date__c;
               jcd.InstallerName__c=jNew.InstallerAliasName__c;
            }
            else if(jNew.Status__c=='Suspended')
            {
                jcd.Job_Installation_Date__c = null ;
            }
       }
   
       // BGSAMS Support PRB00016041- code fix to remove JCD installation date when the job is suspended ends
       Database.update(cr);
   }
   }
   
    
      if((jOld.Installation_Date__c !=jNew.Installation_Date__c)&&(cls_IsRun.isJobCompletion==true)&&(jNew.Status__c=='Planned' ) && jNew.Is_Downtime_Job__c == false && jNew.Is_Remedial_Job__c == false){
            blnreenter = true;
    }
    if(blnreenter ){
    Job__c[] job= Trigger.new;
    system.debug('inside reenter');
    Payment_Collection__c obj_Payment=new Payment_Collection__c();
    // PRB00010300 coding starts
    Map<String,Decimal> map_VAT = new Map<String,Decimal>(); 
    VATchangecalculation.CalculateNewAndOldVAT(map_VAT);
    // PRB00010300 coding ends
    for (Job__c j:job) {
                blnNewRecord=true;
                //cls_IsRun.setIsJobCompletion();
                obj_Payment=new Payment_Collection__c();
                //added extra parameter map_VAT to the updatePCN function for PR - PRB00010300 by BGSAMS
                VATchangecalculation.updatePCN(j, obj_Payment,map_VAT);
                system.debug('After -->'+j);
                system.debug('After -->'+obj_Payment);
                if(j.Is_Downtime_Job__c!=true)
                lst_Payment.add(obj_Payment);
    }
    try {     
         if(lst_Payment!= null)
         upsert lst_Payment Job_Special_ID__c;
         System.debug('PCN report: '+lst_Payment);  
         } catch(Exception exp) {
                System.debug('Exception'+ 'Payment is already created for this Job' );
        }
    }
    if(doEnter){
        /*String WasteID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Waste Disposal Report');
        String MinorID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Minor Electrical Installation');
        String AsbestosID= RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Asbestos Report');
        String GasID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Gas Installation Works');
        String EleID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Electrical Installation at Risk');
        String FodID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'FOD - No Access Report');
        String BuildingWorkId = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Building Work Report');
        
        */
        
        Set<String> set_JobId=new Set<String>{};
        Job__c[] job= Trigger.new;
        System.debug('Id-->'+job[0].Id);
        Payment_Collection__c obj_Payment=new Payment_Collection__c();
        integer iCount=0;
        integer jcount=0;
        List<String> jobIds = new List<String>();
        // PRB00010300 coding starts
        Map<String,Decimal> map_VAT = new Map<String,Decimal>(); 
        VATchangecalculation.CalculateNewAndOldVAT(map_VAT);
        // PRB00010300 coding ends
        for (Job__c j:job) {
            
                blnNewRecord=true;
                cls_IsRun.setIsJobCompletion();
                /*
                string homePhone = (j.Telephone_Number__c!=null && j.Telephone_Number__c.length()>20)? j.Telephone_Number__c.substring(0,20): j.Telephone_Number__c;
                string workPhone = (j.Telephone_Number_Work__c!=null && j.Telephone_Number_Work__c.length()>20)? j.Telephone_Number_Work__c.substring(0,20): j.Telephone_Number_Work__c;
                string telePhone = (j.Telephone_Number__c!=null && j.Telephone_Number__c.length()>15)? j.Telephone_Number__c.substring(0,15): j.Telephone_Number__c;
                */
                if(j.Is_Downtime_Job__c==false && j.Is_Remedial_Job__c == false)
                {
                    obj_Payment=new Payment_Collection__c();
                    //added extra parameter map_VAT to the updatePCN function for PR - PRB00010300 by BGSAMS
                    VATchangecalculation.updatePCN(j, obj_Payment,map_VAT);
                    system.debug('After -->'+j);
                    system.debug('After -->'+obj_Payment);
                    system.debug('After status-->'+obj_Payment.Payment_Collection_Status__c);
                    lst_Payment.add(obj_Payment);
                }
                lst_CReports1.add(JobCompletionTriggerHelper.JobCompletionDataPopulate(j,'Asbestos Report','AS' ));
                lst_CReports1.add(JobCompletionTriggerHelper.JobCompletionDataPopulate(j,'Gas Installation Works','GA' ));
                lst_CReports1.add(JobCompletionTriggerHelper.JobCompletionDataPopulate(j,'Minor Electrical Installation','ME' ));
                if(system.label.tunon2019H_S == 'YES')
                {
                    if(j.Secondary_Job_Type_New__c == 'Remedial' || j.Secondary_Job_Type_New__c == 'Recall')
                    {
                        lst_CReports1.add(JobCompletionTriggerHelper.JobCompletionDataPopulate(j,'Remedial No Appliance Report','RN' ));
                        lst_CReports1.add(JobCompletionTriggerHelper.JobCompletionDataPopulate(j,'System','SY' )); 
                    }
                    lst_CReports1.add(JobCompletionTriggerHelper.JobCompletionDataPopulate(j,'No Access Report','NA' ));
                }
                    
               // }
                /*e
                
                Commissioning_Report__c commissionreport = new Commissioning_Report__c();
                commissionreport .RecordtypeId=AsbestosID;
                commissionreport .Report_Name__c= 'Asbestos Report';
                commissionreport .Client_Name__c = j.Customer_Name__c;
                commissionreport .Customer_Name__c = j.Customer_Name__c;
                commissionreport .Job_Number__c = j.Id;
                commissionreport .Phone_Number_Home__c  = homePhone;
                commissionreport .Phone_Number_Work__c  = workPhone;
                commissionreport .Address__c = j.Address__c;
                commissionreport .Property__c = j.Account_Id__c;
                commissionreport .Installation_Notes__c = j.Job_Notes__c;
                commissionreport .Job_Special_ID__c = j.Id +'AS';
                commissionreport .District__c = j.District_Name__c;
                commissionreport .Job_Installation_Date__c = j.Installation_Date__c;
                commissionreport.InstallerName__c=j.InstallerAliasName__c;
                System.debug('Completion report: '+commissionreport );    
                */
                /*
                Commissioning_Report__c commissionreport1 = new Commissioning_Report__c();
                commissionreport1 .RecordtypeId=GasID;
                commissionreport1 .Report_Name__c= 'Gas Installation Works';
                commissionreport1 .Client_Name__c = j.Customer_Name__c;
                commissionreport1 .Customer_Name__c = j.Customer_Name__c;
                commissionreport1 .Job_Number__c = j.Id;
                commissionreport1 .Phone_Number_Home__c  = homePhone;
                commissionreport1 .Phone_Number_Work__c  = workPhone;
                commissionreport1 .Address__c = j.Address__c;
                commissionreport1 .Installation_Notes__c = j.Job_Notes__c;
                commissionreport1 .Job_Special_ID__c = j.Id +'GA';
                commissionreport1 .Property__c = j.Account_Id__c;
                commissionreport1 .District__c =j.District_Name__c;
                commissionreport1 .Job_Installation_Date__c =j.Installation_Date__c;
                commissionreport1.InstallerName__c=j.InstallerAliasName__c;
                System.debug('Completion report1: '+commissionreport1 );    
                lst_CReports2.add(commissionreport1 );
                */
                /*CR: 11/11/11 BY Ashok 
              AS Business wanted to stop creating this particula document, they will be moving some of the fields 
              to Minor electrical doc and maintain these deatils there.
                
                Commissioning_Report__c commissionreport2 = new Commissioning_Report__c();
                commissionreport2 .RecordtypeId=EleID;
                commissionreport2 .Report_Name__c= 'Electrical Installation at Risk';
                commissionreport2 .Client_Name__c = j.Customer_Name__c;
                commissionreport2 .Customer_Name__c = j.Customer_Name__c;
                commissionreport2 .Job_Number__c = j.Id;
                commissionreport2 .Phone_Number_Home__c  = homePhone;
                commissionreport2 .Phone_Number_Work__c  = workPhone;
                commissionreport2 .Address__c = j.Address__c;
                commissionreport2 .Property__c = j.Account_Id__c;
                commissionreport2 .Installation_Notes__c = j.Job_Notes__c;
                commissionreport2 .Job_Special_ID__c = j.Id +'ER';
                commissionreport2 .District__c = j.District_Name__c;
                commissionreport2 .Job_Installation_Date__c =j.Installation_Date__c;
                commissionreport2.InstallerName__c=j.InstallerAliasName__c;
                System.debug('Completion report: '+commissionreport );    
                lst_CReports3.add(commissionreport2 );*/
                /*
                Commissioning_Report__c commissionreport3 = new Commissioning_Report__c();
                commissionreport3.RecordtypeId= MinorID;
                commissionreport3.Report_Name__c= 'Minor Electrical Installation';
                commissionreport3.Customer_Name__c = j.Customer_Name__c;
                commissionreport3.Job_Number__c = j.Id;
                commissionreport3.Installation_Notes__c = j.Job_Notes__c;
                commissionreport3.Telephone_Number__c  = telePhone;
                commissionreport3.Job_Special_ID__c = j.Id +'ME';
                commissionreport3.Address__c = j.Address__c;
                commissionreport3 .Property__c = j.Account_Id__c;
                commissionreport3 .District__c = j.District_Name__c;
                commissionreport3 .Job_Installation_Date__c =j.Installation_Date__c;
                commissionreport3.InstallerName__c=j.InstallerAliasName__c;
                System.debug('Completion report: '+commissionreport3);    
                lst_CReports4.add(commissionreport3);
                */
                /*
                Commissioning_Report__c commissionreport4 = new Commissioning_Report__c();
                commissionreport4.RecordTypeId=WasteID ; 
                commissionreport4.Report_Name__c= 'Waste Disposal Report';
                commissionreport4.Customer_Name__c = j.Customer_Name__c;
                commissionreport4.Job_Number__c = j.Id;
                commissionreport4.Installation_Notes__c = j.Job_Notes__c;
                commissionreport4.Telephone_Number__c  = telePhone;
                commissionreport4.Address__c = j.Address__c;
                commissionreport4.Job_Special_ID__c = j.Id+'WA';
                commissionreport4 .Property__c = j.Account_Id__c;
                commissionreport4 .District__c =j.District_Name__c;
                commissionreport4 .Job_Installation_Date__c =j.Installation_Date__c;
                commissionreport4.InstallerName__c=j.InstallerAliasName__c;
                System.debug('Completion report: '+commissionreport4);    
                lst_CReports5.add(commissionreport4);
                */
                // Adding JOB ids in set
                jobIds.add(j.Id);
               
        }
        if (blnNewRecord==true) {
            try {     
                if(lst_Payment!= null)
                    upsert lst_Payment Job_Special_ID__c;
                System.debug('PCN report: '+lst_Payment);  
            } catch(Exception exp) {
                System.debug('Exception'+ 'Payment is already created for this Job' );
            }
            try {
                if(lst_CReports1!= null)
                    upsert lst_CReports1 Job_Special_ID__c;
                System.debug('Commission Report : '+lst_CReports1);  
            }catch(Exception exp) {
                System.debug('Exception'+ 'Asbestos Report is already created for this Job');
            } 
            
            try {
            
                //if(lst_CReports2!= null)
                //{
                    //upsert lst_CReports2 Job_Special_ID__c;
                    /*
                        Code changes to create the Boiler appliance record on Gas Installation Doc. 
                        Using Job Id as reference to create/update an exsiting records. 
                        
                    */
                    system.debug(jobBoilerMap);
                    system.debug(purchaseOrderMap);
                    if(lst_CReports1.size()>0 && lst_CReports1[1]!= null && System.label.Appliance_Switch == 'on' && lst_CReports1[1].Status__c!= 'Completed' && jobBoilerMap.containskey(lst_CReports1[1].Job_Number__c) && purchaseOrderMap.containsKey(jobBoilerMap.get(lst_CReports1[1].Job_Number__c)))
                    {
                        id jobId = lst_CReports1[1].Job_Number__c;
                        Product_Order__c materialRecord = purchaseOrderMap.get(jobBoilerMap.get(jobId));
                        Appliance_At_Risk__c newApplianceRecord = new Appliance_At_Risk__c(External_Id__c =jobId,   Appliance_Type__c = 'Boiler',
                                                                                         Model__c = materialRecord.COMPONENT_MODEL__c,  Manufacturer__c =materialRecord.COMPONENT_MAKE__c,
                                                                                          GC_Number__c = materialRecord.BGC_Number__c,  Compliance_Report__c=lst_CReports1[1].Id  );
                        upsert newApplianceRecord External_Id__c;
                    }
                    
                    
                    System.debug('Commission Report : '+lst_CReports1[1]);  
            } catch(Exception exp) {
                System.debug('Exception'+ 'Gas Installation Works is already created for this Job');
            } 
           /* try {
                if(lst_CReports3!= null)
                    upsert lst_CReports3 Job_Special_ID__c;
                System.debug('Commission Report : '+lst_CReports3);  
            } catch(Exception exp) {
                System.debug('Exception'+ 'Electrical Installation at Risk report is already created for this Job');
            } 
            /*
            try {     
                if(lst_CReports4!= null)
                    //upsert lst_CReports4 Job_Special_ID__c;
                System.debug('Completion report: '+lst_CReports4);  
            }catch(Exception exp){
                System.debug('Exception'+ 'Minor Electrical Installation report is already created for this Job' );
            } 
            /*
            try {
                if(lst_CReports5!= null)
                    upsert lst_CReports5 Job_Special_ID__c;
                System.debug('Completion report: '+lst_CReports5);   
            } catch(Exception exp) {
                System.debug('Exception'+  'Waste Disposal Report is already created for this Job');
            } 
            */
            
            // Inserting sharing rules for JOb completion documents and Payment Collection
            if(Createfirst){
            try{
                JobSharingCls.createJobSharing(jobIds);
             }catch(Exception e){
                 System.debug('Error inserting Sharing : '+e.getMessage());
             }
            }
        }   
        /*
        iCount=0;
        Map<Id,Job__c> map_JobDetail=new Map<Id,Job__c>{};
        List<Commissioning_Report__c> lst_CommRpt=new List<Commissioning_Report__c>{};
        List<Payment_Collection__c> lst_PaymentCollection = new List<Payment_Collection__c>{};
        Commissioning_Report__c obj_CommRpt=new Commissioning_Report__c();
        Payment_Collection__c obj_Paymnt=new Payment_Collection__c();
        for (Job__c obj_Job:job) {
            if (obj_Job.Status__c=='Planned') {
                blnJobRePlanned=true;
                obj_CommRpt=new Commissioning_Report__c();
                obj_CommRpt.Job_Special_ID__c=obj_Job.Id + 'AS';
                obj_CommRpt.Job_Installation_Date__c=obj_job.Installation_Date__c;
                lst_CommRpt.add(obj_CommRpt);
                obj_CommRpt=new Commissioning_Report__c();
                obj_CommRpt.Job_Special_ID__c=obj_Job.Id + 'GA';
                obj_CommRpt.Job_Installation_Date__c=obj_job.Installation_Date__c;
                lst_CommRpt.add(obj_CommRpt);
                obj_CommRpt=new Commissioning_Report__c();
                obj_CommRpt.Job_Special_ID__c=obj_Job.Id + 'ER';
                obj_CommRpt.Job_Installation_Date__c=obj_job.Installation_Date__c;
                lst_CommRpt.add(obj_CommRpt);
                obj_CommRpt=new Commissioning_Report__c();
                obj_CommRpt.Job_Special_ID__c=obj_Job.Id + 'ME';
                obj_CommRpt.Job_Installation_Date__c=obj_job.Installation_Date__c;
                lst_CommRpt.add(obj_CommRpt);
                obj_CommRpt=new Commissioning_Report__c();
                obj_CommRpt.Job_Special_ID__c=obj_Job.Id + 'WA';
                obj_CommRpt.Job_Installation_Date__c=obj_job.Installation_Date__c;
                lst_CommRpt.add(obj_CommRpt);                       
                obj_Paymnt=new Payment_Collection__c();
                obj_Paymnt.Job_Special_ID__c = obj_job.Id + 'PC';
                obj_Paymnt.Job_Installation_Date__c = obj_job.Installation_Date__c;
                lst_PaymentCollection.add(obj_Paymnt);
            }   
        }
        if (blnJobRePlanned==true) {
            upsert lst_CommRpt Job_Special_ID__c;
            upsert lst_PaymentCollection Job_Special_ID__c;
        }
        */
    }
}