trigger Populate_Other_Installer on Installer__c (after insert,after update)
{
    //Populate Installer Names in the Job Commissioning Report and Job Completion Report
    Set<String> set_JobId=new Set<String>{};
    Map<String,String> map_User=new Map<String,String>{};
    Map<String,Commissioning_Report__c> map_CommissioningReport=new Map<String,Commissioning_Report__c>{};
    Map<String,Payment_Collection__c> map_Payment=new Map<String,Payment_Collection__c>{};
    
    //CHI CR-000209:START: 16/09/2010.
    Map<String,Installer__c> installerMap = new Map<String,Installer__c>();
    Map<String,String> mechInstallerJobMap = new Map<String,String>();
    Map<String,String> elecInstallerJobMap = new Map<String,String>();
    Map<String,String> mechJobInstallerMap = new Map<String,String>();
    Map<String,String> elecJobInstallerMap = new Map<String,String>();      
    //CHI CR-000209:END: 16/09/2010.
    
    // CR - Customer History Card - Starts
    
    Map<Id,List<String>> jobMechInstallersMap = new Map<Id,List<String>>();
    Map<Id,List<String>> jobElecInstallersMap = new Map<Id,List<String>>();
    Map<Id,List<String>> jobSPBInstallersMap = new Map<Id,List<String>>();
    
    // CR - Customer History Card - Ends
    map<id, string> mechWorkdayIds  = new map<id, string>();
    map<id, string> elecWorkdayIds  = new map<id, string>();

         
    for (Installer__c obj_Id: Trigger.New) {
        set_JobId.add(obj_Id.Job__c);

        if(obj_Id.Installer_status__c == 'Active')
        {
            if(obj_Id.Sub_Type__c == 'Mechanical')
            {
                if(!mechWorkdayIds.containsKey(obj_Id.Job__c))
                mechWorkdayIds.put(obj_Id.Job__c, obj_Id.WorkDay_Id__c);
                else
                mechWorkdayIds.put(obj_Id.Job__c,  mechWorkdayIds.get(obj_Id.Job__c) +','+obj_Id.WorkDay_Id__c);

            }else if(obj_Id.Sub_Type__c == 'Electrical')
            {
                if(!elecWorkdayIds.containsKey(obj_Id.Job__c))
                elecWorkdayIds.put(obj_Id.Job__c, obj_Id.WorkDay_Id__c);
                else
                elecWorkdayIds.put(obj_Id.Job__c,  elecWorkdayIds.get(obj_Id.Job__c) +','+obj_Id.WorkDay_Id__c);
            }
        }
    }     
    
    // CR - Customer History Card - Starts
    
    for(ID job : set_JobId){
        
        jobMechInstallersMap.put(job, new List<String>());
        jobElecInstallersMap.put(job, new List<String>());
        jobSPBInstallersMap.put(job, new List<String>());
        
    }
    
    // CR - Customer History Card - Ends
     //Removed the condition User_Phase_4_Status__c =:'True' from the query as per the client request. - BGSAMS Support     
    for (Installer__c obj_Installer:[select Job__c,User__c, User__r.Alias,User_Phase_4_Status__c,Id,Installer_Status__c,Name,User__r.Name from Installer__c where Job__c In:set_JobId and Installer_Status__c=:'Active']) {
        if (map_User.get(obj_Installer.Job__c)==null ) {
            map_User.put(obj_Installer.Job__c,obj_Installer.User__r.Alias);  
        } else {
            String str_temp=map_User.get(obj_Installer.Job__c);
            str_temp=str_temp + ', ' + obj_Installer.User__r.Alias;
            map_User.put(obj_Installer.Job__c,str_temp);
        }  
         
        //CHI CR-000209:START: 16/09/2010. 
        installerMap.put(obj_Installer.Id,obj_Installer); 
        if(obj_Installer.name.toUpperCase()=='MECHANICAL'){
            mechInstallerJobMap.put(obj_Installer.Id,obj_Installer.Job__c);
        } 
        if(obj_Installer.name.toUpperCase()=='ELECTRICAL'){
            elecInstallerJobMap.put(obj_Installer.Id,obj_Installer.Job__c);
        } 
        //CHI CR-000209:END: 16/09/2010.
        
        // CR - Customer History Card - Starts
        
        if(obj_Installer.name.toUpperCase()=='MECHANICAL'){
            jobMechInstallersMap.get(obj_Installer.Job__c).add(obj_Installer.User__r.Name);
          }
        
        if(obj_Installer.name.toUpperCase()=='ELECTRICAL'){
            jobElecInstallersMap.get(obj_Installer.Job__c).add(obj_Installer.User__r.Name);
        }
        
        if(obj_Installer.name.toUpperCase()=='SPECIALIST BUILDING'){
            jobSPBInstallersMap.get(obj_Installer.Job__c).add(obj_Installer.User__r.Name);
        }
        
        // CR - Customer History Card - Ends
        
    }
    
    //CHI CR-000209:START: 16/09/2010.
    for(Installer__c installer : installerMap.values()){
        String mechJob = mechInstallerJobMap.get(installer.Id);
        String elecJob = elecInstallerJobMap.get(installer.Id);
        
        if(mechJob != null && installer.Job__c == mechJob){
            if(!mechJobInstallerMap.containsKey(installer.Job__c)){
                mechJobInstallerMap.put(installer.Job__c,installer.Id);
            }
        }
        if(elecJob != null && installer.Job__c == elecJob){
            if(!elecJobInstallerMap.containsKey(installer.Job__c)){
                elecJobInstallerMap.put(installer.Job__c,installer.Id);
            }
        } 
    }    
    //CHI CR-000209:END: 16/09/2010.
    
    List<Job__c> lst_Job=new List<Job__c>{};
    
    for(Job__c obj_Job:[Select InstallerAliasName__c,Id,Electrical_Installer__c,Mechanical_Installer__c,Status__c from Job__c where Id In:set_JobId]) {

        if(mechWorkdayIds.containskey(obj_Job.id))
        obj_Job.Mech_Inst_Workday_Id__c = mechWorkdayIds.get(obj_Job.id);

        if(elecWorkdayIds.containskey(obj_Job.id))
        obj_Job.Elec_Inst_WorkDay_Id__c = elecWorkdayIds.get(obj_Job.id);


        obj_Job.InstallerAliasName__c = map_User.get(obj_Job.Id);
        
        //CHI CR-000209:START: 16/09/2010.        
        String elecInstallerId = elecJobInstallerMap.get(obj_Job.Id);
        Installer__c ei = installerMap.get(elecInstallerId);
        if(ei != null && ei.User__c != null){
            obj_Job.Electrical_Installer__c = installerMap.get(elecInstallerId).User__r.Name;
        }
        
        String mechInstallerId = mechJobInstallerMap.get(obj_Job.Id);
        Installer__c mi = installerMap.get(mechInstallerId);
        if(mi != null && mi.User__c != null){
            obj_Job.Mechanical_Installer__c = installerMap.get(mechInstallerId).User__r.Name;
        }   
        //CHI CR-000209:END: 16/09/2010.
       
       // CR - Customer History Card - Starts
       
        Integer i;
        String mechInstallers = '';
        String elecInstallers = '';
        String spbInstallers = '';
        
        if(jobMechInstallersMap.get(obj_Job.Id).size()>0){
            i = 0;
        }
        
        for(String mechInstaller : jobMechInstallersMap.get(obj_Job.Id)){
            i++;
            if(jobMechInstallersMap.get(obj_Job.Id).size()>i)
            mechInstallers = mechInstallers + mechInstaller + ', ';
            else{
            mechInstallers = mechInstallers + mechInstaller;
            obj_Job.Mechanical_Installer__c = mechInstallers;
            }
        }
        
        if(jobElecInstallersMap.get(obj_Job.Id).size()>0){
            i = 0;
        }
        
        for(String elecInstaller : jobElecInstallersMap.get(obj_Job.Id)){
            i++;
            if(jobElecInstallersMap.get(obj_Job.Id).size()>i)
            elecInstallers = elecInstallers + elecInstaller + ', ';
            else{
            elecInstallers = elecInstallers + elecInstaller;
            obj_Job.Electrical_Installer__c = elecInstallers;
            }
        }
        
        if(jobSPBInstallersMap.get(obj_Job.Id).size()>0){
            i = 0;
        }
        
        for(String spbInstaller : jobSPBInstallersMap.get(obj_Job.Id)){
            i++;
            if(jobSPBInstallersMap.get(obj_Job.Id).size()>i)
            spbInstallers = spbInstallers + spbInstaller + ', ';
            else{
            spbInstallers = spbInstallers + spbInstaller;
            obj_Job.Specialist_Builder__c = spbInstallers;
            }
        }
        // CR - Customer History Card - Ends
        
        lst_Job.add(obj_Job);       
    }
    if(system.label.transfer_hours_switch == 'on'){
    //PRB00032289 - Added to reduce soql queries exception
    cls_IsRun.transferhrstrg = true;
    system.debug(LoggingLevel.INFO, 'cls_IsRun.transferhrstrg: ' + cls_IsRun.transferhrstrg);
    }
    
    if (lst_Job.size()>0) {
        update lst_Job;
    }
    
   
    for (Commissioning_Report__c obj_CommissioningReport:[select Job_Number__c,Job_Number__r.Status__c,Job_Number__r.Mechanical_Installer__c,Job_Number__r.Electrical_Installer__c,InstallerName__c,Id,RecordType.Name,RecordTypeId from Commissioning_Report__c where Job_Number__c In:set_JobId]){                
        obj_CommissioningReport.InstallerName__c=map_User.get(obj_CommissioningReport.Job_Number__c); 
        map_CommissioningReport.put(obj_CommissioningReport.Id,obj_CommissioningReport);           
    }    
    for (Payment_Collection__c obj_Payment:[select Job__c,Installer_Name__c,Id from Payment_Collection__c where Job__c IN:set_JobId]) {
        obj_Payment.Installer_Name__c=map_User.get(obj_Payment.Job__c);
        map_Payment.put(obj_Payment.Id,obj_Payment);               
    }    
    List<Commissioning_Report__c> lst_CommissioningRpt=new List<Commissioning_Report__c>{};
    lst_CommissioningRpt=map_CommissioningReport.values();
    List<Payment_Collection__c> lst_Payment=new List<Payment_Collection__c>{};
    lst_Payment=map_Payment.values();
    if (lst_CommissioningRpt.size()>0) {
        try{
        update lst_CommissioningRpt;
        }catch(Exception ex){
            System.debug('Exception occured while updating Job completion Document: '+ex );
        }
    }
    
     if (lst_Payment.size()>0) {
        try{
            update lst_Payment;
        }catch(Exception ex){
            System.debug('Exception occured while updating Payment collection Document: '+ex );
        }
    } 
    //PRB00032289 - Added to reduce soql queries exception 
    cls_IsRun.transferhrstrg = false;      
}