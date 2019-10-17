/*
        Author          : Cognizant
        Functionality   : This is a controller class for the ELESCSA_Report_Controller,to Generate ELESCSA Report in text format.
        Create Date     : 21 July 2010
        Change History  :
        Modified Date   :
*/

public class ELESCSA_Report_Controller  
{
    public String ReportData {get; set;}
    public Compliance_Report__c dateObj {get; set;}
    public String strOut1;
    public Boolean IsGenerate{get; set;}
    Id DiaryEntry = null;
    Map<ID, Diary_Entry__c> Map_DiaryEntries = new Map<ID,Diary_Entry__c>();
    
        public ELESCSA_Report_Controller() 
    	{
    		dateObj = new Compliance_Report__c();
			dateObj.Start_Date__c = System.today().AddDays(-7);
			dateObj.End_Date__c = System.today();
            IsGenerate = false;
    	} 
    
     public PageReference CreateReport()
    	{ 
    
    	 Date startDate = dateObj.Start_Date__c.Adddays(-1);
        Date endDate = dateObj.End_Date__c.Adddays(1);
    	IsGenerate = true;
    	system.debug('---startDate' +startDate);
    	system.debug('---startDate' +endDate);
    	
    	
        //Executing the flow for bulk records. 
       List<Job__c> lstjob = [Select Id,Installation_Date__c,CHI_Lead__r.Account.Primary_Contact__r.MailingPostalCode,CHI_Lead__r.Account.Primary_Contact__r.FirstName,
        						CHI_Lead__r.Account.Primary_Contact__r.LastName,CHI_Lead__r.Account.BillingPostalCode,
        						CHI_Lead__r.Account.BillingCountry,CHI_Lead__r.Account.BillingCity,CHI_Lead__r.Account.BillingState,
        						CHI_Lead__r.Account.BillingStreet,CHI_Lead__r.Account.Primary_Contact__r.MailingCountry,
        						CHI_Lead__r.Account.Primary_Contact__r.MailingState,CHI_Lead__r.Account.Primary_Contact__r.MailingCity,
        						CHI_Lead__r.Account.Primary_Contact__r.MailingStreet,
        						CHI_Lead__r.Account.Primary_Contact__r.Salutation ,CHI_Lead__r.Platform__c,Contractor_Installation_Hours__c,
        						Quote__c,Elesca_Part_Number__c,CHI_Lead__r.CHI_Lead_Id__c,
        						(Select Week__c,Job__c,Sub_Type__c,Week__r.Employee__r.id From Diary_Entries__r where Sub_Type__c ='Electrical' limit 1)
        						From Job__c where Installation_Date__c> :startDate and Installation_Date__c < :endDate and 
        						CHI_Lead__r.Platform__c = 'SFDC' and (Status__c ='Planned' or Status__c ='Installed')];
        system.debug('lstjob---'+lstjob.size());
        Set<string> jobset = new Set<string>();
        List<Job__c> lstjobsecond = new List<Job__c>();
        Map<id,string> jobpackmap = new Map<id,string>();
        String temp;
        List<string> lstpack = new List<string>();
        for(Job__c jobid : lstjob)
        {  
            temp= jobid.Id;
            if(temp.length()==18)
            temp= temp.substring(0,temp.length()-3);
            jobset.add(temp);
                        
       }
        List<Diary_Entry__c> jobEntries = new List<Diary_Entry__c>([Select Week__r.Employee__r.First_Name__c,Week__r.Employee__r.Last_Name__c,Week__r.Employee__r.id,Job__c,Employee_ID_18__c,Sub_Type__c,Id From Diary_Entry__c where Sub_Type__c ='Electrical'  and  Job__c IN : jobset ]);         
        
        Map<id,Diary_Entry__c> Diary_map = new Map<id,Diary_Entry__c>();
        for(Diary_Entry__c DEtry : jobEntries){
        	
          Diary_map.put(DEtry.Job__c,DEtry);
        }
        system.debug('Diary_map-->'+Diary_map);
        //List<Job__c> lstjobsecond = new List<Job__c>();
        Map<string,string> mappack = new Map<string,string>();
        List<ELECSA_Work_Code__c> lstelesca = [Select work_description__c,WT_Code__c,Pack_Number__c from ELECSA_Work_Code__c];
        for(ELECSA_Work_Code__c objele :lstelesca){
        	mappack.put(objele.WT_Code__c,objele.work_description__c);
        }
        system.debug('mappack-->'+mappack);
        Map<id,string> lstpromap = new Map<id,string>();
        //List<ELECSA_Work_Code__c> elItemList = new List<ELECSA_Work_Code__c>();
          	for(Job__c jobid : lstjob){
             	for(ELECSA_Work_Code__c oLineItem: lstelesca){
                 if(oLineItem.WT_Code__c == jobid.Elesca_Part_Number__c){
                     string elItemList = (mappack.get(oLineItem.WT_Code__c));
                     system.debug('Jobid-->'+jobid.id);
                     system.debug('elItemList-->'+elItemList);
                     lstpromap.put(jobid.id,elItemList);
                    break; 
                 }
             }
         }
        										 
       system.debug('lstpromap-->'+lstpromap);
       strOut1 = 'YourCertificateNumber\tWorkType\tDwellingHouseNumberOrName\tPlanningApplicationNumber\tLocalAuthority\tDwellingTown\tDwellingCounty\tDwellingPostcode\tPostalHouseNumberOrName\tPostalPostcode\tCertificateRecipientTitle\tCertificateRecipientFirstName\tCertificateRecipientLastName\tContractStartDate\tContractEndDate\tNewBuildFlag\tYourJobReference\tContractorAmount\tEmployees\tYourNotes\tMajorContractor\t';
         for(Job__c job : lstjob)
        {    
        	system.debug('Inside If for -->'+job.Id);
            String strOut='';
            //Retrieves yor Cerficate Number
            strOut +='ELP1502';
            
            //Retrives  Workcode 
            if(lstpromap.get(job.id)!=null){
            strOut += lstpromap.get(job.id);
            }else
            {
             
            strOut +='\t';   
            }
            
             //Retrieves DwellingHouseNumberOrName
            //strOut +=' '; 
            strOut +='\t';
              
             //RetrivesPlanningApplicationNumber
            //strOut +=' ';
            strOut +='\t';
            
            //RetrivesLocalAuthority
        	//strOut +=' ';
        	strOut +='\t';
        	
        	//Retrieves Blank for DwellingTown
            //strOut +=' ';
        	strOut +='\t';
        	//Retrieves blank for DwellingCounty
            //strOut +=' ';
        	strOut +='\t';
            //Retrieves DwellingPostcode
            //strOut +=' '; 
            strOut +='\t';
            //Retrives Blank PostalHouseNumberOrName 
           	//strOut +=' '; 
            strOut +='\t';
            //Retrieves Postcode            
            if(job.CHI_Lead__r.Account.BillingPostalCode!=null){
            strOut += job.CHI_Lead__r.Account.BillingPostalCode;
            }else
            {
            //strOut +=' ';
            strOut +='\t';    
            }
            
            //Retrieves CertificateRecipientTitle
            if(job.CHI_Lead__r.Account.Primary_Contact__r.Salutation!=null){
            strOut += job.CHI_Lead__r.Account.Primary_Contact__r.Salutation;
            }else
            {
            //strOut +=' ';
            strOut +='\t';    
            } 
                     
            //Retrieves CertificateRecipientFirstName
            if(job.CHI_Lead__r.Account.Primary_Contact__r.FirstName!=null){
            strOut += job.CHI_Lead__r.Account.Primary_Contact__r.FirstName;
            }else
            {
            //strOut +=' ';
            strOut +='\t';    
            } 
            //Retrieves CertificateRecipientLastName
            if(job.CHI_Lead__r.Account.Primary_Contact__r.LastName!=null){
            strOut += job.CHI_Lead__r.Account.Primary_Contact__r.LastName;
            }else
            {
            //strOut +=' '; 
            strOut +='\t';   
            } 
            
            //Retrieves blank for Contractor Start Date
            //strOut +=' ';
            strOut +='\t';    
            //Retrieves Contractor End Date
            if(job.Installation_Date__c!=null){
            Datetime dt = DateTime.newInstance(job.Installation_Date__c, System.now().Time());
            strOut += dt.format('yyyyMMdd');
            }else
            {
            //strOut +=' ';
            strOut +='\t';    
            }
             
            //Retrieves  Zero for New Build flag
            strOut +='0'+'\t';
            //strOut +='\t';
           	//Retrieves CHI Lead Name
            if(job.CHI_Lead__r.CHI_Lead_Id__c!=null){
            strOut += job.CHI_Lead__r.CHI_Lead_Id__c.substring(0,8);
            }else
            {
            //strOut +=' '; 
            strOut +='\t';   
            }
            
            //Retrieves Contract Amount 
            //strOut +=' '; 
            strOut +='\t';
            //Retrieves Employee Name
            if(Diary_map.get(job.Id)!=null){
            if((Diary_map.get(job.Id).Week__r.Employee__r.First_Name__c!=null && Diary_map.get(job.Id).Week__r.Employee__r.Last_Name__c!=null)){
            strOut += Diary_map.get(job.Id).Week__r.Employee__r.First_Name__c+' '+Diary_map.get(job.Id).Week__r.Employee__r.Last_Name__c;
            }
            }else
            {
            //strOut +=' ';
            strOut +='\t';    
            }
            //Retrieves blank for Your Notes 
            //strOut +=' ';   
            strOut +='\t';        
            
             //Retrieves blank for MajorContractor
             //strOut +=' ';
             strOut +='\t';
                        
            strOut1 +=strOut.replaceAll('\n', '').replaceAll('\r', '') +'\n'; 
        }
        ReportData = strOut1;

        system.debug('ReportData-->'+ReportData);
        if (ReportData != '') 
        {
        	//Pagereference pgRef=new Pagereference('/apex/ELESCSA_Report');
	        //pgRef.setRedirect(true);
	        return Page.ELESCSA_Report;
        }
        else
        	return null;       
    	}
    }