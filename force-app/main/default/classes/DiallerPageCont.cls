/*
        Author: Cognizant Jan 2012
        Description: This controller class is used to create dialler file depending on status and StatusReason selected by user on DiallerPage Vf page.
        All the generation and format of dialler file is taken care in "SendDiallerDetails.cls" This class mainly created query string and queries 
        for first 100 quote record and sends it to SendDiallerDetails.cls where these 100 quotes are processed and text file is created and stored 
        in documents.
        
        One more important and challenging point was salesforce can process only 100 quotes in one trasaction, but if user selects "All" option on substatuses then file can not be 
        produced in one call as there will more than 100 quotes in that quey. So in order to achieve batch class like functionality an email service is created and which will get triggered repetedly till all the quotes are 
        processed. 
        
        We pass different parameters in email so that email service captures these information and processes the request. A typical email will contain.
        
        
        Subject : Filename'#'+ requestor email +'#'+last chiLeadNum+'#'+submittedDate; 
        
        subject will be always in this format for every trasaction.
        
        
        1) Filename ---> this is name of the file which is unique it is formed by "CHI_DIALLER_+Substaus selelcted+ User id"
        2) Reuestor Email--> This generated file is sent to this address and is captured in vf page.-->   public string message {get;set;}
        3) last chiLeadNum --> this is last CHI Lead number which was processed in present transactio. So that next set of records are greater than this. By
                                                        this we ensure that we dont get and repeated Lead numbers.
        4) submittedDate ---> this is quote submitted date captured in page.
        
        case 1): When there are more than 100 records.
        
        body : This will be always query which was constructed in this page so that email service directly uses the query and carries out its trasaction.
                
                 example: select * from Bigmachine_quotes__c etc
                                                 
        case 2) When there are less than 100 records
        
        body : end
        
        end---> this is the indication to email service that there are no more quotes to process so that it can complete the transcation  and send the file 
                        to requested email.
                        
        Body of the email in both cases: 
*/
public with sharing class DiallerPageCont {
    //public string qSubstatus {get;set;}
    public BigMachines_Quote__c bm {get;set;}
    public string email {get;set;}
    public string message {get;set;}
    public boolean flag {get;set;}
    
    // ++ Variables created for Dialler Tab CR - Nitish start
    public SelectOption[] allSubStatusSelected { get; set; }
    public SelectOption[] allStatusSelected { get; set; }
    public SelectOption[] allDistrictsSelected { get; set; }
    public SelectOption[] allProductTypesSelected {get; set;}
    // -- Variables created for Dialler Tab CR - Nitish end
    
    // ++ Variable created for CR#892 start
    public Boolean isConsiderAllRecords {get; set;}
    // -- Variable created for CR#892 end
	
    public list<selectoption>getSubStatusOPtions(){
        List<selectoption> options = new List<selectoption>();
        Schema.DescribeFieldResult subStatuseField = BigMachines_Quote__c.bmStatusReason__c.getDescribe();
        List <Schema.PicklistEntry>  picklistskills = subStatuseField.getPicklistValues();
        Options.add(new SelectOption('All','All'));
        for(Schema.PicklistEntry p : picklistskills)
        {
        	// Add the values to the options excpet the default status reason values
        	if(!Utilities.defaultStatusReasonValues.contains(p.getLabel()))
        	{
        		Options.add(new SelectOption(p.getLabel(),p.getLabel()));
        	}    
        } 
        
        return options;
    }
    
    // ++ Added for Dialler Tab CR - Nitish start
    public list<selectoption>getStatusOPtions(){
        List<selectoption> options = new List<selectoption>();
        Schema.DescribeFieldResult statusField = BigMachines_Quote__c.stage__c.getDescribe();
        List <Schema.PicklistEntry>  picklistskills = statusField.getPicklistValues();
        Options.add(new SelectOption('All','All'));
        for(Schema.PicklistEntry p : picklistskills)
        {    
            Options.add(new SelectOption(p.getLabel(),p.getLabel()));
            
        } 
        
        return options;
    }
     
    public list<selectoption>getProductTypeOPtions(){
    	List<selectoption> options = new List<selectoption>();
    	List<String> productTypes = new List<String>{'C4C','CHB','CHC','CHR','CHS','CHX','FER','FSE','ECH'};
    	//Options.add(new SelectOption('All','All'));
    	for(String productType : productTypes)
    	{
    		Options.add(new SelectOption(productType,productType));
    	}
    	return options;
    }
    // -- Added for Dialler Tab CR - Nitish end
    
    public List<District__c> Districts {get;set;}
    public string AreaName {get;set;}
    public List<SelectOption> getAreaItems() 
    {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('All','All'));
            if(Districts == null)loadDistricts();

            for (Integer i = 0; i < Districts.size(); i++)
            {                             
                options.add(new SelectOption(Districts[i].Name,Districts[i].Name));
            }                                               
            return options;
    }
    
     public void loadDistricts() {
        Districts = [Select d.Name, d.Id,dhmname__c ,dhmphone__c From District__c d where d.Type__c = 'Installation' order by d.Name];  
     }
    
    public DiallerPageCont()
    {
            bm = new BigMachines_Quote__c();
            bm.submittedDate_quote__c = system.today()-7;   
            // ++ Added for Dialler Tab CR - Nitish start
	        allSubStatusSelected = new List<SelectOption>();
	        // set default status reason values 
	        for(String defaultReason : Utilities.defaultStatusReasonValues)
	        {
	        	allSubStatusSelected.add(new SelectOption(defaultReason , defaultReason));
	        }
	        allStatusSelected = new List<SelectOption>();
	        allDistrictsSelected = new List<SelectOption>();
	        allProductTypesSelected = new List<SelectOption>();
	        // -- Added for Dialler Tab CR - Nitish end
	        
	        // ++ Variable created for CR#892 start
	        isConsiderAllRecords = false;
	        // -- Variable created for CR#892 end
    }

    public boolean createDiallerFile()
    {
    	// ++ Variables created for Dialler Tab CR - Nitish start
    	string districtCriteria;
    	string statusCriteria;
    	string substausCriteria;
    	string productTypeCriteria;
    	string endCriteria;
    	Set<string> status = new Set<string>();
        Set<string> substatus = new Set<string>();
        Set<string> productType = new Set<string>();
        Set<string> district = new Set<string>();
        // -- Variables created for Dialler Tab CR - Nitish end
        
    	string finalquery;
    	Utilities utl = new Utilities();
        date submittedDate = bm.submittedDate_quote__c;
        
        // ++ Added for Dialler Tab CR - Nitish start
        status = formatSelectOptionsToString(allStatusSelected);
        substatus = formatSelectOptionsToString(allSubStatusSelected);
        productType = formatSelectOptionsToString(allProductTypesSelected);
        district = formatSelectOptionsToString(allDistrictsSelected);
        // -- Added for Dialler Tab CR - Nitish end
        
        // ++ Modified for Dialler Tab CR - Nitish start
        string query = 'Select Opportunity__r.closeDate__c, Opportunity__r.Campaign_Name__c, Opportunity__r.Account.Primary_Contact__r.MailingPostalCode, Opportunity__r.Account.Primary_Contact__r.Salutation,Opportunity__r.Account.Primary_Contact__r.LastName,Picked_By_Dialler__c,';
        query += 'Opportunity__r.Account.Primary_Contact__r.OtherPhone, Opportunity__r.Account.Primary_Contact__r.Phone, Opportunity__r.Account.Primary_Contact__r.MobilePhone, Opportunity__r.Account.Primary_Contact__r.HomePhone,';
        query += 'Opportunity__r.CHI_Lead_Id__c, Opportunity__r.Account.Primary_Contact__r.MailingStreet, Opportunity__r.Account.Primary_Contact__r.MailingCity,bmStatusReason__c,Product_Type_ID__c From BigMachines_Quote__c where Id != null'; 
        
        // ++ Modified for CR#892 start
        if(isConsiderAllRecords == true)
        {
        	endCriteria = 'Opportunity__r.Sold_Quote_Received_Date__c = null and Opportunity__c != null order by Opportunity__r.CHI_Lead_Id__c ';
        }
        else
        {
        	endCriteria = 'Opportunity__r.Sold_Quote_Received_Date__c = null and Opportunity__c != null and Picked_By_Dialler__c = false order by Opportunity__r.CHI_Lead_Id__c ';
        }
        // -- Modified for CR#892 end
        
        string limits = 'limit 100';
        //string submitdate = 'submittedDate_quote__c =:submittedDate';
        string submitdate = 'submittedDate_quote__c >=' +getDateToStringValue(bm.installationDate__c) +' AND submittedDate_quote__c <='+getDateToStringValue(bm.closeDate__c);
        finalquery = query + prepareFinalQuery(status , substatus , productType , district)+ 'AND ('+submitdate+ ') AND '+endCriteria+limits;
        
        system.debug('QUERY----->'+finalquery);
        //string fileName = 'CHI_DIALLER_'+qSubstatus+userinfo.getuserid();
        string fileName = 'CHI_DIALLER_'+userinfo.getuserid()+system.now();
        // -- Modified for Dialler Tab CR - Nitish end
        
        string chiLeadNum = queryData(finalquery,fileName,submittedDate);
        
        if(chiLeadNum!= null)
        {
                string nextCriteria = 'Opportunity__r.CHI_Lead_Id__c >\''+chiLeadNum+'\'';
                string secquery;
                // ++ Added for Dialler Tab CR - Nitish start
                secquery = query + prepareFinalQuery(status , substatus , productType , district)+ 'AND ('+submitdate+ ') AND '+nextCriteria+ ' AND '+endCriteria+limits;
                // -- Added for Dialler Tab CR - Nitish end
                fileName += '#'+ email +'#'+chiLeadNum+'#'+submittedDate;
                CreateEmail.CretaeSendTextEmail(new list<string>{system.label.DiallerEmailService}, secquery, fileName);
                message = 'Dialler file is being generated. Please Wait for few minutes before you check in mentioned mailbox';
                utl.setErrorMsg(false,message);
                flag = true;
        }
        else{
                message = 'No Quotes to generate file. Please try changing Date or Status/Sub Status values';
                utl.setErrorMsg(true,message);
                flag = false;
        }
        return null;
        
    }
    
    public pagereference back()
    {
        flag = false;
        return (new pagereference ('/apex/DiallerPage'));
    }
    
    public string queryData(string query, string filename, date submittedDate)
    {
        list<BigMachines_Quote__c> bmList = Database.query(query);
        if(bmList.size()>0)
        {
            //sendDiallerDetails.createTextFileForDialler(bmList,fileName);
            // ++ Added for CR#892 start
            Map<Id,BigMachines_Quote__c> oppBMMap = new map<Id,BigMachines_Quote__c>();
	         for(BigMachines_Quote__c b : bmList)
	         {
	         	if(!oppBMMap.containskey(b.Opportunity__c))
	         	{
	         		oppBMMap.put(b.Opportunity__c,b);
	         	}
	         }
    	 	if(sendDiallerDetails.createTextFileForDialler(oppBMMap.values(),fileName))
            {
            	if(cls_IsRun.bigMachineSwitch == false)
		        {
		        	List<BigMachines_Quote__c> quotesToUpdated  = new List<BigMachines_Quote__c>();
		        	if(oppBMMap.size() > 0)
		        	{
		        		quotesToUpdated = oppBMMap.values();
		        	}
		        	for(BigMachines_Quote__c quote : quotesToUpdated)
			        {
			        	quote.Picked_By_Dialler__c = true;
			        }
			        try
			        {
			        	if(quotesToUpdated.size() > 0)
			        	{
			        		cls_IsRun.setbigMachineSwitch();
			        		database.update(quotesToUpdated);
			        	}
			        }
			        catch(Exception ex)
			        {
			        	system.debug('------Exception Occured--'+ex);
			        	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			        	String[] toAddresses = system.label.Dialler_Mails.split(',');
				        String subject = 'Eoor occured in dialler';
				        email.setSubject( subject );
				        email.setToAddresses( toAddresses );
				        email.setPlainTextBody(string.valueOf(ex));
				        Messaging.SendEmailResult [] mssg = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
			        }
		        }
            }
            // -- Added for CR#8962 end
            return (bmList[bmList.size()-1].Opportunity__r.CHI_Lead_Id__c);
        }
        else
        {
            return null;
        }
        
    }
    public string createCriteria(Set<string> conditions, string fieldName)
    {
        string finalcriteria='';
        if(fieldName == 'Product_Type_ID__c')
        {
        	for(string s : conditions)
	        {
	            finalcriteria=finalcriteria + fieldName + '!=\''+s+'\' OR ';
	        }
        }
        else
        {
        	for(string s : conditions)
	        {
	            finalcriteria=finalcriteria + fieldName + '=\''+s+'\' OR ';
	        }
        }
        finalcriteria=finalcriteria.substring(0,finalcriteria.length()-3);
        system.debug('finalcriteria-->'+finalcriteria);
        return finalcriteria;
    }
    
    // ++ Added for Dialler Tab CR - Nitish start
    // Method formats date value to string format to be used in query
    public static String getDateToStringValue(Date value)
    {
        DateTime dt = Datetime.newInstance(value, Time.newInstance(0,0,0,0));
        return dt.format('yyyy-MM-dd');
    }
    
    //Method formats List<SelectOption> to Set<String>
    public static Set<String> formatSelectOptionsToString(List<SelectOption> options)
    {
    	Set<String> values = new Set<String>(); 
    	for(SelectOption sOption : options)
    	{
    		values.add(sOption.getValue());
    	}
    	return values;
    }
    
    /* Method prepares query based on the dropdown values of
       status , substatus , distirct & ProductType selected by the user.
       Preparing query below scenarios are considered:
       1. If user has not selected any value in dropdown then those conditions are filtered from Query.
       2. If user has selected 'All' value in dropdown then those conditions are filtered from Query.
    
    */
    public String prepareFinalQuery(Set<string> status , Set<string> substatus , Set<string> productType , Set<string> district)
    {
    	String finalquery = ' ';
    	if(!status.contains('All') && status.size() > 0 && status != null)
        {
        	finalquery =' AND ('+ createCriteria(status,'stage__c') +')';
        }
        if(!substatus.contains('All') && substatus.size() > 0 && substatus != null)
        {
        	finalquery =finalquery+' AND ('+ createCriteria(substatus,'bmStatusReason__c') +')';
        }
        if(!district.contains('All') && district.size() > 0 && district != null)
        {
        	finalquery =finalquery+' AND ('+ createCriteria(district,'Opportunity__r.DistrictName_Sales__c') +')';
        }
        if(productType.size() > 0 && productType != null)
        {
        	finalquery =finalquery+' AND ('+ createCriteria(productType,'Product_Type_ID__c') +')';
        }
        return finalquery;
    }
    // -- Added for Dialler Tab CR - Nitish end
   



	
}