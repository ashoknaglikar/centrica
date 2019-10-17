/*
    Type Name:      Class NIASCodeHelper 
    Author:         Cognizant
    Created Date:   05/14/2010
    Reason:         Centrica Phase 5 - NBBS Integration: NIAS Code retrieval logic
    Change History:  Change has been made regarding the searching of EMPTYPE for a salesperson. Previously it was searching with Employee name and code has beeen amended to search with Payroll number.
    Author: 
    Modified Date: 06/18/2010
    Modified Date: 06/24/2010
    Reason: Change due to Enmass billing.
*/

public class NIASCodeHelper 
{
    
    public static Map<ID, NIASCode> GetNIASCodeMapByOpportunity(List<BigMachines_Quote__c> quoteList)
    {
            /*
                Code added by Anshul
                Purpose:- To build a map of CHI Lead related to quote to retrieve related payment objects
            */
            
            List<ID> CHILeadList = new List<ID>(); //to retrieve payment against CHI Lead related to Quote
            List<String> oppResourceTypeMap = new List<String>(); //to retrieve resource type of the Sales person
            List<String> jobTypeList = new List<String>();
            List<String> paymentCodeList = new List<String>();
            List<String> resourceTypeList = new List<String>();
            List<String> installerTypeList = new List<String>();
            List<String> regionCodeList = new List<String>();
            List<String> quoteIDList = new List<String>();
            Map<ID, NIASCode> niasCodeMap = new Map<ID, NIASCode>();
            
            //Retrieve resource type from "Add Assigned To" field for retrieving related employee records
            for(BigMachines_Quote__c quote: quoteList)
            {
                CHILeadList.add(quote.Opportunity__c);
                quoteIDList.Add(quote.ID);
                oppResourceTypeMap.Add(quote.App_Assigned_Payroll__c);
            } 
            
            //build map of opportunity and payment (only last payment is considered)
            Map<ID, BGS_Payment__c> oppPaymentMap = new Map<ID, BGS_Payment__c>();
            for(BGS_Payment__c paymentObj :[select id, Payment_Method__c, Payment_Date__c, Opportunity__c from BGS_Payment__c where Opportunity__c in : CHILeadList Order by Opportunity__c, Payment_Date__c])
            {
                if(oppPaymentMap.containsKey(paymentObj.Opportunity__c))
                {
                    BGS_Payment__c lastPayment = oppPaymentMap.get(paymentObj.Opportunity__c);
                    if(lastPayment.Payment_Date__c < paymentObj.Payment_Date__c)
                    {
                        oppPaymentMap.put(paymentObj.Opportunity__c, paymentObj);
                    }
                }
                else
                {
                    oppPaymentMap.put(paymentObj.Opportunity__c, paymentObj);
                }
            }
            
            
            Map<ID, String> mapQuoteInstallerType = new Map<ID, String>();
            
            //Retrieve Planned jobs and diary entries for the quote where
            // 1. Job status = 'Installed'
            // 2. Employee (to who diary entry is assigned) Group code = 'INST' 
            // 3. Modified because users can send the quote without job being installed.
            // 4. Modified because remedial and downtime job billing will be done in NBBS.
            for(Job__c job :[Select j.Status__c, j.CHI_Lead__c, j.Quote__c,
                (Select Week__r.Employee__r.Group__c From Diary_Entries__r where Week__r.Employee__r.Group__c = 'INST') 
                From Job__c j
                where j.Quote__c in :quoteIDList ])
            {
                String installerType = '';
                //If quote information is already present in map, retrieve corresponding installer type 
                if(mapQuoteInstallerType.containsKey(job.Quote__c))
                {
                    installerType = mapQuoteInstallerType.get(job.Quote__c);
                }
                //if more than 0 diary entries are present then INSTALLERTYPE = R
                if (job.Diary_Entries__r != null && job.Diary_Entries__r.size() > 0)
                {
                    installerType = 'R';
                }
                //if diary entries = 0 and no previous information present for this quote, then INSTALLERTYPE = C
                else if(installerType != 'R')
                {
                    installerType = 'C';
                }
                mapQuoteInstallerType.put(job.Quote__c, installerType);
            }
            
            System.debug(' ---mapQuoteInstallerType = ' + mapQuoteInstallerType);
            //Build the list of NIAS Codes to be retrieved
            for(BigMachines_Quote__c quote: quoteList)
            {
                NIASCode niasCodeObj = new NIASCode();
                niasCodeObj.WorkType = quote.Pricebook_Id__c;
                
                //Add job type 
                jobTypeList.Add(quote.Pricebook_Id__c);
                
                //Add payment code
                String paymentCode = '';
                if(quote.POC_Payment_Method__c != 'Finance' && oppPaymentMap.containsKey(quote.Opportunity__c))
                {
                    paymentCode = oppPaymentMap.get(quote.Opportunity__c).Payment_Method__c;
                }
                else
                {
                    paymentCode = quote.POC_Payment_Method__c;
                }
                if(paymentCode != '') paymentCodeList.add(paymentCode);
                niasCodeObj.PaymentCode = paymentCode;
                
             
                //Add installer Type
                String installerType = mapQuoteInstallerType.get(quote.ID);
                System.debug('---------- quote.ID=' + quote.ID);
                System.debug('---------- installerType=' + installerType);
                installerTypeList.Add(installerType);
                
                niasCodeObj.Installer = installerType;
                
                //add region code
                String regionCode = '  ';
                for(Job__c job :quote.Jobs__r)
                {
                    if(job.Region_Code__c != '')
                    {
                        regionCode = job.Region_Code__c;
                        break;
                    }   
                }
                if(regionCode != null && regionCode.trim() != '')
                {
                    regionCodeList.Add(regionCode);
                    niasCodeObj.RegionCode = regionCode;
                }
                
                niasCodeMap.put(quote.id, niasCodeObj);
            }
            
            //build list of Resource Type    
            for(Employee__c empObj :[select id, Name, Emp_type__c, Employee_Number__c from employee__c where Employee_Number__c in : oppResourceTypeMap])
            {
                resourceTypeList.Add(empObj.Emp_type__c);
                for(BigMachines_Quote__c quote: quoteList)
                {
                    //find Quotes to which this resource/ employee belongs for identifying resource type for that quote
                    if(quote.App_Assigned_Payroll__c == empObj.Employee_Number__c)
                    {
                        NIASCode niasCodeObj = niasCodeMap.get(quote.ID);
                        niasCodeObj.ResourceType = empObj.Emp_type__c;
                        niasCodeMap.put(quote.ID, niasCodeObj);
                    }
                }
            }
            System.debug(' --- jobTypeList = ' + jobTypeList);
            System.debug(' --- paymentCodeList = ' + paymentCodeList );
            System.debug(' --- resourceTypeList = ' + resourceTypeList);
            System.debug(' --- installerTypeList = ' + installerTypeList);
            System.debug(' --- regionCodeList = ' + regionCodeList);
            
            
            //search for NIAS codes based on job type, payment code, installer type and resource type
            for(ID quoteId :niasCodeMap.keyset())
            {
                for(NIAS_Code__c niasCode : [select CST_CODE__c, EMP_CODE__c, GEOG_CODE__c, WRK_TYPE__c,
                       INCOME_CODE__c, INSTALLER__c, OTH_CODE__c, PYMT_CODE__c, RESOURCE_TYPE__c, 
                       WVD_CODE__c from NIAS_Code__c 
                       where BUS_STREAM_ID__c = 'CH' and WRK_TYPE__c in :jobTypeList
                       and PYMT_CODE__c in :paymentCodeList and RESOURCE_TYPE__c in :resourceTypeList
                       and INSTALLER__c in :installerTypeList
                       and GEOG_CODE__c in :regionCodeList])
                {
                //match the criteria for each quote and fill the required fields on match
                    
                    NIASCode niasCodeObj = niasCodeMap.get(quoteId);
                    
                    if (niasCodeObj.getBlCompleted()==false) {
                        niasCodeObj.COSTCode = 0;
                        niasCodeObj.INCOMECode = 0;
                        niasCodeObj.EMPcode = 0;
                        niasCodeObj.ApplianceType = 0;
                        //niasCodeMap.put(quoteId, niasCodeObj);
                        if(niasCodeObj.PaymentCode == niasCode.PYMT_CODE__c
                                && niasCodeObj.ResourceType == niasCode.RESOURCE_TYPE__c
                                && niasCodeObj.Installer == niasCode.INSTALLER__c
                                && niasCodeObj.WorkType == niasCode.WRK_TYPE__c
                                && niasCodeObj.RegionCode == niasCode.GEOG_CODE__c)
                        {
                            System.debug('Testin4321-inside if-->');
                            niasCodeObj.COSTCode = niasCode.CST_CODE__c.intValue();
                            niasCodeObj.INCOMECode = niasCode.INCOME_CODE__c.intValue();
                            niasCodeObj.EMPcode = niasCode.EMP_CODE__c.intValue();
                            niasCodeObj.ApplianceType = niasCode.OTH_CODE__c.intValue();
                            niasCodeObj.setBlCompleted(true);
                            niasCodeMap.put(quoteId, niasCodeObj);
                            niasCodeMap.get(quoteId).isInvalidNIASCode = false;
                        }
                    }
                }
                
                // Fix for adding validation for valid NIAS Code - Starts
                
                if(niasCodeMap.get(quoteId).getBlCompleted()==false){
                	
                	niasCodeMap.get(quoteId).isInvalidNIASCode = true;
                	
                }
                
                // Fix for adding validation for valid NIAS Code - Ends
                
            }
            
            
            //Create Job Description records(Service) for newly created Installation billing record for appliances/service
            
            System.debug('Testing123--->'+niasCodeMap);
            return niasCodeMap;

    }

    //Inner classs to handle NIAS code information for a Quote
    public class NIASCode
    {
        public Integer COSTCode {get; set;}
        public Integer INCOMECode {get; set;}
        public Integer EMPcode {get; set;}
        public Integer ApplianceType {get; set;}
        public String WorkType {get; set;}
        public String PaymentCode {get; set;}
        public String ResourceType {get; set;}
        public String Installer {get; set;}
        public String ResourceID {get; set;}
        public String RegionCode {get; set;}
        private Boolean blCompleted=false;
        // Fix for adding validation for valid NIAS Code - Starts
        public boolean isInvalidNIASCode {get; set;}
        // Fix for adding validation for valid NIAS Code - Ends
        public Boolean getBlCompleted(){
            return blCompleted;
        }
        public void setBlCompleted(Boolean value){
            blCompleted=value;
        }
    }
}