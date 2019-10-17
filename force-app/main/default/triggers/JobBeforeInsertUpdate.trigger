/*
  CR - Send text message to Salesman when the job is planned
  Quote reconcilation trigger would have already populated salesman name on job.
  This trigger populates text mail address of corresponding salesman on job object.
  This is used for sending text message to salesman who completed the quote for this 
  job.This is a generic before insert and update trigger which can be used later for any 
  other purposes in future.
*/

trigger JobBeforeInsertUpdate on Job__c (before insert, before update) {

   
 // PRB00032289 - transferhrstrg
  if(cls_IsRun.generalTriggerSwitch || cls_IsRun.transferhrstrg)
    {  
        return;
    }
 
 system.debug(LoggingLevel.INFO, 'Entry JobBeforeInsertUpdate Trigger');
 List<Id> jobIds = new List<Id>(); 
 List<Id> boilerJob = new List<Id>(); 

//if(UserInfo.getUserId()!= System.Label.BM_UserId)
//{
/*//Arithmetic error changes starts
     for (Job__c newJob : Trigger.new)  
     {  
       //System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~ newJob  :' +newJob);
        //System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~ newJob.id  :' +newJob.id);
        ID jobId = newJob.id;
        List<Job_Element__c> jobElements = new List<Job_Element__c>();
        String prevProd;
        double units = 0;
        List<double> unitsList = new List<double>();
        jobElements = [SELECT Code__c,Units__c FROM Job_Element__c WHERE Job__c = :newJob.Id ORDER BY Product_ID__c];
        //System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~ jobElements  :' +jobElements);
        //System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~ jobElements.size()  :' +jobElements.size());
        for(Integer x = 0; x < jobElements.size()-1; x++){
            //System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~ x : ' +x);
            //System.debug('~~~~~~~~~~~JOB ELEMENT~~~~~~~~~~~~~~~ ' +jobElements);
            if(x == 0){
                units = jobElements[x].Units__c;
            }
            else{
                //System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~ jobElements[x-1].Code__c : ' +jobElements[x-1].Code__c);
                //System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~ jobElements[x].Code__c : ' +jobElements[x].Code__c);
                if(jobElements[x-1].Code__c == jobElements[x].Code__c)
                    units = units + jobElements[x].Units__c;
                else{
                    unitsList.add(units);
                    units = 0;
                }
            }
        }
        //System.debug('~~~~~~~~~~TATOAL~~~~~~~~~~~~~~~~ unitsList : ' +unitsList);
        for(double unit  : unitsList ){
            //System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~ unit inside for  :' + unit);
            //System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~ unitsList inside for  :' + unitsList);
            if(unit > 999){
                //System.debug('The Job Elements unit cannot be greater than 999 -- Latha');
                newJob.addError('The Job Elements unit cannot be greater than 999 -- Latha'); 
            }
        }
     } 
    //Arithmetic error changes ends*/
    
if(Trigger.isInsert){

    List<ID> Oppid_newJob = new List<ID>();
    List<Job__c>   OldJob_withCHI= new List<Job__c>();  
    Set<ID> Oppid_oldJob = new Set<ID>();
    
    
    for (Job__c newJob : Trigger.new)  
    {  
        //Job__c oldJob = trigger.oldmap.get(newJob.Id); 
        if(newJob.CHI_Lead__c!=null && newJob.Quote__c==null)
        {   
            Oppid_newJob.add(newJob.CHI_Lead__c);
        }
    }
    if(Oppid_newJob.size()>0)
    {
        OldJob_withCHI = [SELECT Id,Status__c,CHI_Lead__c from Job__c where Is_Downtime_Job__c != true and Is_Remedial_Job__c !=true and Split_Job__c != true and Status__c != 'Cancelled' and CHI_Lead__c in :Oppid_newJob];
        if(OldJob_withCHI.size()>0)
        { 
          for (Job__c job : OldJob_withCHI)
          { 
            Oppid_oldJob.add(job.CHI_Lead__c);
            
          }
            
        }
       }
        
    for (Job__c newJob : Trigger.new)  
    {       
        if (newJob.Is_Downtime_Job__c != true && newJob.Is_Remedial_Job__c !=true && newJob.Split_Job__c != true && Oppid_oldJob.contains(newJob.CHI_Lead__c)) 
         newJob.addError('There is already an active job exist for the Lead');   
       
    }
 
//}
}
//Changed by BGSAMS support on 25/01/2012 to avoid Duplicate jobs on a chi lead in case of pre-allocation scenario -  PRB00006300 ends
 
    //Landlord and tenant fields population
    
    if(Trigger.isBefore && (Trigger.isInsert )){// commented by Dev team to reduce the queries || Trigger.isUpdate)){
        System.debug('====LL & Tenant===');    
        Map<Id, Job__c> oppIdJobMap = new Map<Id, Job__c>();
        for (Job__c newJob : Trigger.new)
        {
            if(newJob.Landlord_Email__c == null||newJob.Landlord_Name__c == null || newJob.Tenants_Name__c == null || newJob.Tenants_Email__c == null )
            {
                oppIdJobMap.put(newJob.CHI_Lead__c, newJob);
            }
        }
        
        
        if(oppIdJobMap.keyset().size()>0)
        {
            Map<Id,Id> opJobId = new Map<Id,Id>();
            Map<id, Opportunity> oppMap = new Map<id, Opportunity>([Select id, Account.Landlord_Account__c, AccountId,(Select id,Job__c from Land_Lord_Records__r limit 1) from Opportunity where Id in :oppIdJobMap.keyset() and Account.Landlord_Account__c = true]);
            
            Map<Landlord_Record__c,Job__c> JobLLId = new Map<Landlord_Record__c,Job__c>();
            
            System.debug('=======oppIdJobMap===='+oppIdJobMap); 
            
            if(oppIdJobMap.values()!=null)
            for(Job__c job : oppIdJobMap.values()){
                
                 if( oppMap.containsKey(job.CHI_Lead__c) &&  oppMap.get(job.CHI_Lead__c).Land_Lord_Records__r != null && !oppMap.get(job.CHI_Lead__c).Land_Lord_Records__r.isEmpty()){
                     JobLLId.put(oppMap.get(job.CHI_Lead__c).Land_Lord_Records__r,job);
                 }             
            }  
            
            List<Landlord_record__c> ToBeUpdateLL = new List<Landlord_record__c>();        
            //for(Job__c job : oppIdJobMap.values())
                        
            if(JobLLId.keySet()!=null) 
            for(Landlord_Record__c l : JobLLId.keySet()) {
                if(l!=null){
                    l.Job__c = JobLLId.get(l).id;
                    ToBeUpdateLL.add(l); 
                }         
            } 
            
            System.debug('====ll======'+ToBeUpdateLL);
            if(ToBeUpdateLL.size()>0)
                try{
                    update ToBeUpdateLL;
                }
                Catch(DmlException e){
                    System.debug('======DMLError====='+e.getMessage());
                }        
            for(Opportunity o: oppMap.values())
            {
                if(o.Account.Landlord_Account__c)
                {
                    opJobId.put(o.AccountId,o.Id);
                }    
            }
    
         map<Id, List<Contact>> oppContact = new map<Id,list<Contact>>();
            
            list<string> contactTypes = new list<string>{'Landlord','Tenant','Multi-premise'};
            if(opJobId.keyset().size()>0)
            {
                for(Account a: [Select id, (Select id, Email,Preferred_Contact_Method__c,Salutation,FirstName,LastName,Contact_Type__c from Contacts where contact_type__c in: contactTypes) from Account where Id in:opJobId.keyset() ])
                {
                    oppContact.put(opJobId.get(a.Id),a.Contacts );
                }
            }
            
            for(Job__c a: trigger.new)
            {
                if(oppContact.containskey(a.CHI_Lead__c))
                {
                    for(Contact c: oppContact.get(a.CHI_Lead__c))
                    {
                        if(c.Contact_Type__c == 'Tenant')
                        {
                            a.Tenants_Name__c = c.Salutation +' '+c.FirstName+' '+c.LastName;
                            a.Tenants_Email__c = c.Email;
                            a.Tenant_Preferred_Con__c = c.Preferred_Contact_Method__c; 
    
                        }else if(c.Contact_Type__c == 'Landlord' || c.Contact_Type__c == 'Agent')
                        {
                            a.Landlord_Name__c = c.Salutation +' '+c.FirstName+' '+c.LastName;
                            a.Landlord_Email__c = c.Email;
                            a.Landlord_Preffered_Con__c = c.Preferred_Contact_Method__c;
    
                        }else if(c.Contact_Type__c == 'Multi-premise' )
                        {
                            a.Landlord_Name__c = c.LastName;
                            a.Landlord_Email__c = c.Email;
                            a.Landlord_Preffered_Con__c = c.Preferred_Contact_Method__c;
    
                        }
                        
                    }
                }
                System.debug('==LL&Tenant=='+ a.Tenants_Name__c + a.Landlord_Name__c);                
            }
        }
        
    }
    
  // Added as part of customer history card change request.   
  if(Trigger.isUpdate){
  
      CustomerHistoryCardHelper c = new CustomerHistoryCardHelper();
      c.updateCustHistCardOnJobbUpdate(Trigger.old[0], Trigger.new[0]); 

         
      /*
     Smart meter change: 
     Code added to handle cancellation and suspension scenarios.
     1) if Primary job is cancelled, then we update the status meter and smart meter change reason to appropriate values below. ir respective of weather smart 
        meter installation is coupled or decoupled.
     2) If primary job was suspended then we update the smart meter status and smart meter change reason to appropriate values below only if the smart meter 
        installtion is decoupled.
     */
    
    for (Job__c newJob : Trigger.new)  
    {   
        Job__c oldJob = trigger.oldmap.get(newJob.Id); 
        
        if( Lock.calBalancingSkill)
        {
            jobTriggerHelper.calculateBalancingMechanicalHours(new List<Job__c> {newJob});
            Lock.calBalancingSkill = false;
        }
        
        if(newJob.Installation_Date__c!=null && oldJob.Installation_Date__c !=newJob.Installation_Date__c )
        {
            
            if(newJob.Installation_Date__c>=system.today() && newJob.Status__c =='Planned')
            {
                newJob.GM_Status__c = 'In Progress';
                
            }
            
            if((newJob.Job_Type__c == 'GDF' || newJob.Job_Type__c == 'Green Deal')  && !newJob.Is_Downtime_Job__c && !newJob.Is_Remedial_Job__c && !newJob.Split_Job__c)
            {
                boilerJob.add(newJob.Id);
            }
            
            
        }
           
        if (newJob.Status__c == 'Cancelled' && oldJob.Status__c != 'Cancelled' )
        {
            if( newJob.Smart_Meter_Required_Flag__c == 'Yes' && newJob.Smart_meter_installation_status__c!= 'Installed') 
            {
                newJob.Reason_for_acknowledgement__c = 'Job Cancelled';
                newJob.Smart_meter_installation_status__c = 'Cancelled';
                newJob.Smart_meter_installation_sub_status__c = 'Unacknowledged';
                newJob.Smart_meter_install_date_changed__c = false;
            } 
            if(newJob.Installation_Date__c>system.today() &&newJob.GM_Status__c == 'Loaded')  
            {
                newJob.GM_Status__c = 'In Progress';
            }
        }else if((newJob.Status__c == 'Pending') && (oldJob.Status__c == 'Cancelled') && newJob.Smart_Meter_Required_Flag__c == 'Yes' && newJob.Smart_meter_installation_status__c!= 'Installed')
        {
            newJob.Reason_for_acknowledgement__c = 'Uncancelled';
            newJob.Smart_meter_installation_status__c = 'Pending';
            newJob.Smart_meter_installation_sub_status__c = 'Unacknowledged';
            newJob.Smart_meter_install_date_changed__c = false;
            
        }
        if (newJob.Smart_Meter_Required_Flag__c == 'Yes' && newJob.Smart_meter_installation_status__c!= 'Installed' && newJob.Decouple_Smart_Meter_Install_Date__c == false && newJob.Status__c == 'Suspended' && oldJob.Status__c != 'Suspended') 
        {
            newJob.Reason_for_acknowledgement__c = 'Job Suspended';
            newJob.Smart_meter_installation_status__c = 'Suspended';
            newJob.Smart_meter_installation_sub_status__c = 'Unacknowledged';
            newJob.Smart_meter_install_date_changed__c = false;
        }else if((newJob.Status__c =='Pending') && (oldJob.Status__c == 'Suspended') && newJob.Smart_Meter_Required_Flag__c == 'Yes' && newJob.Smart_meter_installation_status__c!= 'Installed')
        {
            newJob.Reason_for_acknowledgement__c = 'Unsuspended';
            newJob.Smart_meter_installation_status__c = 'Pending';
            newJob.Smart_meter_installation_sub_status__c = 'Unacknowledged';
            newJob.Smart_meter_install_date_changed__c = false;
            
        }
        system.debug('Check the planning ---> Delivery Date:'+newJob.Delivery_Date__c+'Old Delivery Date'+oldJob.Delivery_Date__c+'Smart Install Status:'+newJob.Smart_meter_installation_status__c+'Decople flag :'+newJob.Decouple_Smart_Meter_Install_Date__c+'New Job Status: '+newJob.Status__c);
        if (!Lock.smInstDateLock && newJob.Delivery_Date__c!=oldJob.Delivery_Date__c && newJob.Delivery_Date__c != newJob.Smart_meter_installation_date__c && (newJob.Smart_meter_installation_status__c!= 'Installed' || newJob.Smart_meter_installation_status__c!= 'Cancelled')&& newJob.Smart_Meter_Required_Flag__c == 'Yes' && newJob.Decouple_Smart_Meter_Install_Date__c == false ) 
        {
            if(newJob.Smart_meter_installation_date__c!= null)
            {
                newJob.Reason_for_acknowledgement__c = 'Delivery Date Changed';
                newJob.S_M_Prior_Date__c = oldJob.Smart_meter_installation_date__c;
                newJob.Smart_meter_install_date_changed__c = true;
            }
            else 
            {
                newJob.Reason_for_acknowledgement__c = 'New Job';
                newJob.Smart_meter_installation_status__c = 'Pending';
            }
            newJob.Smart_meter_installation_date__c = newJob.Delivery_Date__c;
            newJob.Smart_meter_installation_sub_status__c = 'Unacknowledged';
        }
        else if (!Lock.smInstDateLock && newJob.Delivery_Date__c != newJob.Smart_meter_installation_date__c && newJob.Smart_Meter_Required_Flag__c == 'Yes' && oldJob.Smart_Meter_Required_Flag__c == 'No') 
        {
            
            newJob.Reason_for_acknowledgement__c = 'New Job';
            newJob.Smart_meter_installation_date__c = newJob.Delivery_Date__c;
            newJob.Smart_meter_installation_sub_status__c = 'Unacknowledged';
        }
        
       
        if(newJob.Smart_meter_installation_date__c != oldJob.Smart_meter_installation_date__c || newJob.SMInstalltionTime__c != oldJob.SMInstalltionTime__c)
        {
        
            newJob.Actual_Fields__c=userinfo.getname();
            system.debug('newJob.Actual_Fields__c' + newJob.Actual_Fields__c);
            jobIds.add(newJob.Id);
            
        }
  
    } 
     if(jobIds.size()>0)
    {
     
     list<Smart_Meter__c> updatingList = new list<Smart_Meter__c>();
     
     if(system.label.SM_change == 'on')
     {
        for(Smart_Meter__c smrtmtr:[select Id,Job__c,Actual_SM_Installation_Date__c,Actual_SM_Installtion_Time__c from Smart_Meter__c where Job__c =:jobIds])
         {   
               
             smrtmtr.Actual_SM_Installtion_Time__c = Trigger.newmap.get(smrtmtr.Job__c).SMInstalltionTime__c;
             smrtmtr.Actual_SM_Installation_Date__c = Trigger.newmap.get(smrtmtr.Job__c).Smart_meter_installation_date__c;
             updatingList.add(smrtmtr);
             
         
         } 
         system.debug('@@cls_IsRun.calljob' + cls_IsRun.calljob);
         
         if(updatingList.size()>0)
         {
            cls_IsRun.generalTriggerSwitch = true;
            update(updatingList); 
            cls_IsRun.generalTriggerSwitch = false;
         } 
         
    } 
  }
  
   if(boilerJob.size()>0)
  {    
     List<Green_Deal_Measures__c> updatingList = new list<Green_Deal_Measures__c>();
     for(Green_Deal_Measures__c gdM:[select Id,Installation_date__c,Recommended_measure__c,Green_Deal_Record__r.Job__c from Green_Deal_Measures__c where Recommended_measure__c = 'Condensing Boilers' AND Green_Deal_Record__r.Job__c in:boilerJob])
     {
         gdM.Installation_date__c = Trigger.newmap.get(gdM.Green_Deal_Record__r.Job__c).Installation_Date__c;
         updatingList.add(gdM);
     } 
     Database.update(updatingList); 
  }
      
  }
  // End of customer history card change request.
  
  //CHI CR-000209:START: 19/09/2010.
  for(Job__c job : Trigger.New){
      if(job.Status__c=='Suspended' || job.Status__c=='Cancelled'){
            job.Electrical_Installer__c = null;
            job.Mechanical_Installer__c = null;
      }
  }
  //CHI CR-000209:END: 19/09/2010.
  
  if(Trigger.new.size()==1 && Trigger.new[0].Quote__c != null && !Trigger.new[0].Suspend_Job__c && !Trigger.new[0].Cancel_Job__c){  
     
     Job__c jb = Trigger.new[0];
     
     if(!jb.Populated_txtmail_salesman__c){
     
       String salesmanName = jb.Quote_app_assigned_to__c;
       system.debug(LoggingLevel.INFO, 'Salesman is : '+salesmanName);
       system.debug(LoggingLevel.INFO, 'Populated_txtmail_salesman__c value is : '+jb.Populated_txtmail_salesman__c);
     
        try{
          if(salesmanName!=null){
              if(salesmanName.length()>5){
               Employee__c emp = [Select EmployeeTextMailAddress__c from Employee__c where Name  = :salesmanName limit 1];
               if(emp!=null)
                  if(emp.EmployeeTextMailAddress__c!=null){
                  jb.Salesman_Textmail_Addr__c = emp.EmployeeTextMailAddress__c;
                  jb.Populated_txtmail_salesman__c = true;
                  system.debug(LoggingLevel.INFO, 'Salesman text email is : '+emp.EmployeeTextMailAddress__c);
                  }
               }
           }
         }catch(Exception excp){
            System.debug(LoggingLevel.Info,'Error occured in JobBeforeInsertUpdate : '+excp.getMessage());
         }
         
     }else{

       return;
       
     }
     
  }else if(Trigger.new.size()>1 || Trigger.new[0].Quote__c == null){
    
      return;
      
    }
    

        
  system.debug(LoggingLevel.INFO, 'Exit JobBeforeInsertUpdate Trigger');

}