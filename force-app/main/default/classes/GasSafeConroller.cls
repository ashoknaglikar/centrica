/*
        Author          : Cognizant
        Functionality   : This is a controller class for the GasSafeReport,to Generate Gas Safe Report in CSV format.
        Create Date     : 22 July 2010
        Change History  :
        Modified Date   :
    */
public class GasSafeConroller    
{
    public String ReportData {get; set;}
    public Compliance_Report__c dateObj {get; set;}
    public String strOut;
    public Boolean IsGenerate{get; set;} 
    Id DiaryEntry = null;
    
    Map<ID, Diary_Entry__c> Map_DiaryEntries = new Map<ID,Diary_Entry__c>();

    public GasSafeConroller() 
    {
        dateObj = new Compliance_Report__c();
        dateObj.Start_Date__c  = System.today().AddDays(-7);
        dateObj.End_Date__c = System.today();
        IsGenerate = false;
    }
    public PageReference CreateReport()
    {   
        Set<ID> rem_jobs = new Set<ID>();
        Date startDate = dateObj.Start_Date__c.Adddays(-1);
        Date endDate = dateObj.End_Date__c.Adddays(1);
        IsGenerate = true;
        system.debug('startDate----'+startDate);
        
        //PRB00016438 - code fix done by BGSAMS Support starts
        List<Job__c> remedialjobs = [Select Id
                                From Job__c where Installation_Date__c> :startDate and Installation_Date__c < :endDate and 
                                CHI_Lead__r.Platform__c = 'SFDC' and (Status__c ='Planned' or Status__c ='Installed')
                                and Is_Remedial_Job__c = true 
                                and Is_Downtime_Job__c != true and Region__c!= 'Scotland' 
                                and Quote__r.Work_Request_Number__c =null and Trading_Name__c!= 'Scottish Gas']; //and  Quote__r.Product_Type_ID__c != 'CHC']; PRB00021983 - code fix done by Support Team IS
                                
        List<Job_Element__c>  remedialelements = [Select id, Code__c, Job__c from Job_Element__c where Type__c = 'Material' and Status__c !='Cancelled' and Job__r.Id in :remedialjobs];
                   
        for (Job_Element__c rem_elements :remedialelements)
        {
            if((rem_elements.Code__c.startsWith('CBLR') || rem_elements.Code__c.startsWith('CAPF')))
            {
                  
                        rem_jobs.add(rem_elements.Job__c);                
                
                                     
            }
        } 
        system.debug('rem_jobs---'+rem_jobs);
        
        List<Job__c> lstjob = [Select Id,Installation_Date__c, maximum_End_Date__c,
                                CHI_Lead__r.Account.Primary_Contact__r.MailingPostalCode,CHI_Lead__r.Account.Primary_Contact__r.FirstName,
                                CHI_Lead__r.Account.Primary_Contact__r.LastName,CHI_Lead__r.Account.BillingPostalCode,
                                CHI_Lead__r.Account.BillingCountry,CHI_Lead__r.Account.BillingCity,CHI_Lead__r.Account.BillingState,
                                CHI_Lead__r.Account.BillingStreet,CHI_Lead__r.Account.Primary_Contact__r.MailingCountry,CHI_Lead__r.Name,
                                CHI_Lead__r.Account.Primary_Contact__r.MailingState,CHI_Lead__r.Account.Primary_Contact__r.MailingCity,
                                CHI_Lead__r.Account.Primary_Contact__r.MailingStreet, CHI_Lead__c,Type__c,Installer_Notes__c,
                                (Select id from Purchase_Orders__r where Type__c = 'Material' and Status__c !='Cancelled'),
                                CHI_Lead__r.Account.Primary_Contact__r.Salutation ,Delivery_Notes__c,CHI_Lead__r.Platform__c,Job_Property_Type__c
                                From Job__c where (Installation_Date__c> :startDate and Installation_Date__c < :endDate and 
                                CHI_Lead__r.Platform__c = 'SFDC' and (Status__c ='Planned' or Status__c ='Installed')
                                and Is_Remedial_Job__c != true 
                                and Is_Downtime_Job__c != true and Region__c!= 'Scotland' 
                                and Quote__r.Work_Request_Number__c =null and Trading_Name__c!= 'Scottish Gas') //and  Quote__r.Product_Type_ID__c != 'CHC' PRB00021983 - code fix done by Support Team IS
                                or Id in :rem_jobs];// Bgsams support 20092011 to exclude scotland region for PRB00004988
        
                              
        system.debug('lstjob---'+lstjob.size());
        
        
        
               //PRB00016438 - code fix done by BGSAMS Support ends
        
        Set<string> jobset = new Set<string>();
        Set<id> orderidSet = new Set<id>();
        String temp;
        system.debug('lstjob----'+lstjob);
        for(Job__c jobid : lstjob)
        {  
            temp= jobid.Id;
            for(Order__c po:jobid.Purchase_Orders__r){
                orderidSet.add(po.id);
            }
             if(temp.length()==18)
            temp= temp.substring(0,temp.length()-3);
            jobset.add(temp);
            
        }
        system.debug('jobset---'+jobset); 
        system.debug('orderidSet---'+orderidSet); 
        List<Order__c> orderList = [Select id,(Select P5_Type__c, P5_Purchase_Order__c,Job__c,P5_Purchase_Order__r.Job__r.ID ,Id,Code__c,
                                    BGC_Number__c From Order_Line_Items__r where P5_Type__c= 'Material' and P5_Status_c__c = 'Active' and 
                                    BGC_Number__c !='' limit 6) from Order__c where ID in :orderidSet];
        system.debug('orderList---'+orderList); 
         Map<id,List<Order_Line_Item__c>> lstordmap = new Map<id,List<Order_Line_Item__c>>();
         List<Order_Line_Item__c> olItemList = new List<Order_Line_Item__c>();
         for(Order__c po : orderList){
             for(Order_Line_Item__c oLineItem:po.Order_Line_Items__r){
                 if(lstordmap.containsKey(oLineItem.P5_Purchase_Order__r.Job__r.ID)){
                     olItemList = (lstordmap.get(oLineItem.P5_Purchase_Order__r.Job__r.ID));
                     olItemList.add(oLineItem);
                     lstordmap.put(oLineItem.P5_Purchase_Order__r.Job__r.ID,olItemList);
                 }else{
                    olItemList = new List<Order_Line_Item__c>();
                    olItemList.add(oLineItem);
                    lstordmap.put(oLineItem.P5_Purchase_Order__r.Job__r.ID,olItemList);
                }
             }
         }
        System.debug('lstordmap--->'+lstordmap);
        String str='';
        List<Diary_Entry__c> jobEntries = new List<Diary_Entry__c>([Select Week__r.Employee__r.GasSafe_Licence_Number__c,Week__r.Employee__r.GasSafe_Business_ID__c,Week__r.Employee__r.Employee_GasSafe_Business_ID__c,Job__c,Employee_ID_18__c,Sub_Type__c From Diary_Entry__c where Sub_Type__c ='Mechanical'  and  Job__c IN :jobset]);         
        
        Map<id,Diary_Entry__c> Diary_map = new Map<id,Diary_Entry__c>();
        for(Diary_Entry__c DEtry : jobEntries){
          Diary_map.put(DEtry.Job__c,DEtry);
        }
        
                
        
        Integer cnt=0;
        
        strOut ='Business_ID,GSLicense,Fix_Date,Addr_1,Addr_2,Addr_3,Addr_4,Post_Code,New Build,LACode,PropertyType,Title,First_Name,Surname,Del_Cust_Addr1,Del_Cust_Addr2,Del_Cust_Addr3,Del_Cust_Addr4,Del_Post_code,Delivery Address Reason,JobReference,Removed Appliance Code,GC Number 1,Serial Number 1,Location 1,GC Number 2,Serial Number 2,Location 2,GC Number 3,Serial Number 3,Location 2,GC Number 4,Serial Number 4,Location 4,GC Number 5,Serial Number 5,Location 5,GC Number 6,Serial Number 6,Location 6\n';          
        for(Job__c job : lstjob)
         {
            boolean passsecond =false;   
            String strTemp = ''; 
            String busID;
            String licnu;
           
          //Retrieves GasSafe_Business_ID__c
           if(Diary_map.containsKey(job.Id)==false)
            {
                strTemp +=',';
                system.debug('1stif----');
            }
            
            else if(Diary_map.get(job.Id).Week__r.Employee__r.Employee_GasSafe_Business_ID__c==null || Diary_map.get(job.Id).Week__r.Employee__r.Employee_GasSafe_Business_ID__c =='')
            {
                strTemp +=',';  
                system.debug('3rdtif----');
            }
            else
            {
                
                system.debug('2stif----');
                strTemp += Diary_map.get(job.Id).Week__r.Employee__r.Employee_GasSafe_Business_ID__c.replaceall(',', ' ') + ',';
                
            }
            //Retrieves GasSafe_Licence_Number__c
            if(Diary_map.containsKey(job.Id)==false)
            {
                strTemp +=',';
                system.debug('1stif----');
            }
            
            else if(Diary_map.get(job.Id).Week__r.Employee__r.GasSafe_Licence_Number__c==null || Diary_map.get(job.Id).Week__r.Employee__r.GasSafe_Licence_Number__c =='')
            {
                strTemp +=',';  
                system.debug('3rdtif----');
            }
            else
            {
                
                system.debug('2stif----');
                strTemp += Diary_map.get(job.Id).Week__r.Employee__r.GasSafe_Licence_Number__c.replaceall(',', ' ') + ',';
                
            }
            //Retrieves Fixed date
            if(job.maximum_End_Date__c!=null){
            //objGasSafe.Fix_Date__c.format('dd-MM-yyyy hh:mm:ss');
            // Datetime dt = DateTime.newInstance(job.installation_date__c, System.now().Time());
            
            strTemp += job.maximum_End_Date__c.format('"dd/MM/yyyy"') + ','; //Added to use end of installation instead of start of 'fix date' - PD 20/07/2017
                         
            }else
            {
            strTemp +=',';  
            }  
            
             //Retrieves Address1        
         
            if(job.CHI_Lead__r.Account.BillingStreet!=null){
            strTemp += job.CHI_Lead__r.Account.BillingStreet.replaceall(',', ' ') + ',';
            }else{
            strTemp +=',';  
            }
                    
            //Retrieves Address2
            
           if(job.CHI_Lead__r.Account.BillingCity!=null){
            strTemp += job.CHI_Lead__r.Account.BillingCity.replaceall(',', ' ') + ',';
            }else{
            strTemp +=',';  
            }          
                      
            //Retrieves Address3
             if(job.CHI_Lead__r.Account.BillingState!=null){
            strTemp += job.CHI_Lead__r.Account.BillingState.replaceall(',', ' ') + ',';
            }else {
            strTemp +=',';  
            }         
           //Retrieves Address4
            strTemp +=',';
            /*if(job.CHI_Lead__r.Account.BillingCountry!=null){
            strTemp += job.CHI_Lead__r.Account.BillingCountry.replaceall(',', ' ') + ',';
            }else
            {
            strTemp +=',';  
            }*/   
           
            //Retrieves Postcode
            if(job.CHI_Lead__r.Account.BillingPostalCode!=null){
             strTemp += job.CHI_Lead__r.Account.BillingPostalCode.replaceall(',', ' ') + ',';
            }else{
            strTemp +=',';  
            }           
            

            //Retrieves 'N' for New Bild
            strTemp +='N'+',';
            //Retrieves  blank forLA Code
            strTemp +=',';
            //Retrieves Property Type 
             
             if(job.Job_Property_Type__c!=null){
                strTemp += job.Job_Property_Type__c + ',';
            }
            else{
                strTemp +='1'+',';
            }
             //Retrieves Title of Name
            if(job.CHI_Lead__r.Account.Primary_Contact__r.Salutation!=null){
            strTemp += job.CHI_Lead__r.Account.Primary_Contact__r.Salutation.replaceall(',', ' ') + ',';
            }else{
            strTemp +=',';  
            }          
            //Retrieves Certificate first Name
            if(job.CHI_Lead__r.Account.Primary_Contact__r.FirstName!=null){
            strTemp += job.CHI_Lead__r.Account.Primary_Contact__r.FirstName.replaceall(',', ' ') + ',';
            }else{
            strTemp +=',';  
            }
            //Retrieves Certificate SurName          
            if(job.CHI_Lead__r.Account.Primary_Contact__r.LastName!=null){
            strTemp += job.CHI_Lead__r.Account.Primary_Contact__r.LastName.replaceall(',', ' ') + ',';
            }else {
            strTemp +=',';  
            }   

            //Retrieves customer Delivery Address1
            if(job.CHI_Lead__r.Account.Primary_Contact__r.MailingStreet!=null)
            {
                strTemp += job.CHI_Lead__r.Account.Primary_Contact__r.MailingStreet.replaceall(',', ' ') + ',';
            }
            else
            {
                strTemp +=',';
            }
            //Retrieves customer Delivery Address2          
            
            if(job.CHI_Lead__r.Account.Primary_Contact__r.MailingCity!=null){
            strTemp += job.CHI_Lead__r.Account.Primary_Contact__r.MailingCity.replaceall(',', ' ') + ',';
            }else
            {
                
            strTemp +=',';  
            }        
            //Retrieves customer Delivery Address3
            if(job.CHI_Lead__r.Account.Primary_Contact__r.MailingState!=null){
            strTemp += job.CHI_Lead__r.Account.Primary_Contact__r.MailingState.replaceall(',', ' ') + ',';
            }else
            {
            strTemp +=',';  
            }           
            //Retrieves customer Delivery Address4
            strTemp +=',';
             /*if(job.CHI_Lead__r.Account.Primary_Contact__r.MailingCountry!=null){
            strTemp += job.CHI_Lead__r.Account.Primary_Contact__r.MailingCountry.replaceall(',', ' ') + ',';
            }else
            {
            strTemp +=',';  
            }*/         
            //Retrieves customer Delivery PostCode
            if(job.CHI_Lead__r.Account.Primary_Contact__r.MailingPostalCode!=null){
            strTemp += job.CHI_Lead__r.Account.Primary_Contact__r.MailingPostalCode.replaceall(',', ' ') + ',';
            }else{
            strTemp +=',';  
            } 

            //Retrieves customer Delivery Address Reason
            strTemp +=',';  
            /*if(job.Delivery_Notes__c!=null){
            strTemp += job.Delivery_Notes__c.replaceall(',', ' ') + ',';
            }else
            {
            strTemp +=',';  
            } */
             //Retrieves CHI Lead Name
            if(job.CHI_Lead__r.Name!=null){
            strTemp += job.CHI_Lead__r.Name.substring(0,8).replaceall(',', ' ') + ',';
            }else
            {
            strTemp +=',';  
            }
            //Retrieves for Removed Appliance Code
            strTemp +=',';           
            //Retrieves GC Number       
            
            List<Order_Line_Item__c> templist1 = new List<Order_Line_Item__c>();
             if(lstordmap.containsKey(job.Id)){
                templist1 = lstordmap.get(job.id);
            }
            system.debug('templist-->'+templist1.size());
            system.debug('templist-->'+templist1);   
            if(templist1.size()>0) {
               for(Integer i=0; i<templist1.size();i++){
                   strTemp += templist1[i].BGC_NUMBER__c +','+','+',';
                   system.debug('strTemp -->'+strTemp );
                   if(i>=5)
                   break;
              }
            }
         // This is used to add space between when there is a new line          
         strOut += strTemp.replaceAll('\n',' ').replaceAll('\r','')+ '\n'; 
        }
        
       ReportData = strOut; 
       system.debug('strOut1----'+strOut);
        if (ReportData != '') 
        {
            return Page.GasSafeReport;
        }
        else
            return null;       
    } 

}