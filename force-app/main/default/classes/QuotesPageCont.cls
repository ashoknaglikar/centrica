public with sharing class QuotesPageCont {
    
    public  BigMachines_Quote__c bm {get;set;}
    public  QFU_Voucher_File__c voucherFile{get;set;}
    public string message {get;set;}
    public List<QFU_Voucher_File__c> voucherFileList{get;set;}
    
    public SelectOption[] allDistrictsSelected { get; set; }
    public SelectOption[] allProductTypesSelected {get; set;}
    public SelectOption[] allRegionsSelected{get;set;}
    public SelectOption[] allAllowanceKeySelected{get;set;}
    public SelectOption[] allProductIntSelected{get;set;}
    public SelectOption[] allCoreBundleSelected{get;set;}
   
    public List<District__c> Districts {get;set;}
    public List<Region__c> Regions {get;set;}
    
    Public transient list<opportunity> oppList{get;set;}
    public Integer count{get;set;}
    public Integer pageNumber{get;set;}
    public Integer setRecords {get;set;}
    public Double pageUp {get;set;}
    public Double  setRecordsDouble;
    public Double  pageDecimal;
    public Integer pageUpInt {get;set;}
    
    Public transient String finalStringCSV{get;set;}
    public string fileName{get;set;}
    
    Public string currentProductHoldings{get;set;}
    Public string partNumber{get;set;}
    Public boolean isPrevious{get;set;}
    
    Public  boolean isSalesforce{get;set;}
    Public  boolean isContactEngine{get;set;}
    Public  boolean isText{get;set;}
    Public  boolean isEmail{get;set;}
    public boolean errorFlag;
    
    public string preparequery;
    public string subquery='';
    
    public boolean isShowVoucherBlock{get;set;}
    
    public Utilities utl = new Utilities();
    public set<id> oppids;
   
    public QuotesPageCont()
    {
            bm = new BigMachines_Quote__c();
            voucherFile= new QFU_Voucher_File__c();
            voucherFileList= new List<QFU_Voucher_File__c>();
            isPrevious=false;
            isShowVoucherBlock = false;
            filename='QFULeadsExport'+system.now();
            count=0;
            
            /*isSalesforce= false;
            isContactEngine=false;
            isText = false;
            isEmail = false;*/
            allDistrictsSelected = new List<SelectOption>();
            allProductTypesSelected = new List<SelectOption>();
            allRegionsSelected = new List<SelectOption>();
            allAllowanceKeySelected = new List<SelectOption>();
            allProductIntSelected = new List<SelectOption>();
            allCoreBundleSelected = new List<SelectOption>();
    }
    
    public list<selectoption> getProductInterestOptions(){
        List<selectoption> options = new List<selectoption>();
        Schema.DescribeFieldResult productInterestField = opportunity.Product_Interest__c.getDescribe();
        List <Schema.PicklistEntry>  picklistskills = productInterestField.getPicklistValues();
        List<String> productInterest = new List<String>{'Commercial','Small Commercial'};
        Options.add(new SelectOption('All','All'));
        for(Schema.PicklistEntry p : picklistskills)
        {    
            if(!productInterest.contains(p.getLabel()))
            Options.add(new SelectOption(p.getLabel(),p.getLabel()));
            
        } 
        return options;
    }
    
     public list<selectoption> getAllowanceKeyOptions(){
        List<selectoption> options = new List<selectoption>();
        Schema.DescribeFieldResult allowanceKeyField = BigMachines_Quote__c.appliedAllowance1__c.getDescribe();
        List <Schema.PicklistEntry>  picklistskills = allowanceKeyField.getPicklistValues();
        List<String> allowanceKey = new List<String>{'M2','EM','XD','X5','X9'};
        Options.add(new SelectOption('All','All'));
        for(Schema.PicklistEntry p : picklistskills)
        {    
            if(!allowanceKey.contains(p.getLabel()))
            Options.add(new SelectOption(p.getLabel(),p.getLabel()));
            
        } 
        return options;
    }
     
    public list<selectoption> getCoreBundleOptions(){
        List<selectoption> options = new List<selectoption>();
        List<String> coreBundleList = new List<String>{'A1 B1','A1 B2','A1 B3a','A1 B3b','A1 B3c','A2 B1','A2 B2','A2 B3a','A2 B3b','A2 B3c','A3 B1','A3 B2','A3 B3a','A3 B3b',
                                                   'A3 B3c','A4 B1','A4 B2','A4 B3a','A4 B3b','A4 B3c','A5 B4','A5 B5','A6 B4','A6 B5','Straight Swap','Telesales Conv'};
        Options.add(new SelectOption('All','All'));
        for(String coreBundle : coreBundleList)
        {
            Options.add(new SelectOption(coreBundle,coreBundle));
        }
        return options;
    }
    
   
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
     
    public List<SelectOption> getRegionItems() 
    {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('All','All'));
            if(Regions == null)loadRegions();

            for (Integer i = 0; i < Regions.size(); i++)
            {                             
                options.add(new SelectOption(Regions[i].Name,Regions[i].Name));
            }                                               
            return options;
    }
    
     public void loadRegions() {
        Regions = [Select id,name From Region__c where Type__c = 'Installation' order by Name];  
     }
     
    
    public string createCriteria(Set<string> conditions, string fieldName)
    {
        string finalcriteria='';
        
        if(fieldName == 'opportunity__r.Product_Holdings__c')
        { 
            for(string s : conditions)
            {
                finalcriteria=finalcriteria + fieldName + ' Like \''+'%'+s+'%'+'\'  OR ';
            }
        }
         
        if(fieldName == 'Core_Bundle__c')
        { 
            for(string s : conditions)
            {
                finalcriteria=finalcriteria + '(NOT ' + fieldName + ' Like \''+'%'+s+'%'+'\' ) AND ';
            }
        }
        if(fieldName == 'Allowance_Key__c')
        { 
            for(string s : conditions)
            {
                finalcriteria=finalcriteria + '(NOT ' + fieldName + ' Like \''+'%'+s+'%'+'\' ) AND ';
            }
        }
        if(fieldName!='Allowance_Key__c'&&fieldName!='Core_Bundle__c'&&fieldName!='opportunity__r.Product_Holdings__c')
        {
            for(string s : conditions)
            {
                finalcriteria=finalcriteria + fieldName + '=\''+s+'\'  OR ';
            }
        }
        system.debug('finalcriteria-->'+finalcriteria);
        finalcriteria=finalcriteria.substring(0,finalcriteria.length()-4);
        return finalcriteria;
    }
    
    
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
    
    public static Set<String> formatTextToString(String parts)
    {
        Set<String> values = new Set<String>(); 
        if(parts.contains(','))
        values.addAll(parts.split(','));
        else
        values.add(parts);
        return values;
    }
   
    public String prepareFinalQuery(Set<string> productInt , Set<string> district , Set<string> Region , Set<string> AllowanceKey,Set<string> coreBundle, Set<string> currentPHs)
    {
        String finalquery = ' ';
        if(!productInt.contains('All') && productInt.size() > 0 && productInt!= null)
        {
            finalquery =' AND ('+ createCriteria(productInt,'Opportunity__r.Product_Interest__c') +')';
        }
         if(!district.contains('All') && district.size() > 0 && district != null)
        {
            finalquery =finalquery+' AND ('+ createCriteria(district,'Opportunity__r.DistrictName_Sales__c') +')';
        }
        if(!Region.contains('All') && Region.size() > 0 && Region!= null)
        {
            finalquery =finalquery+' AND ('+ createCriteria(Region,'Opportunity__r.Sales_Region__c') +')';
        }
        if(AllowanceKey.size() > 0 && AllowanceKey != null)
        {
            finalquery =finalquery+' AND ('+ createCriteria(AllowanceKey,'Allowance_Key__c') +')';
        }
        if(!coreBundle.contains('All') && coreBundle.size() > 0 && coreBundle!= null)
        {
            finalquery =finalquery+' AND ('+ createCriteria(coreBundle,'Core_Bundle__c') +')';
        }
        if(currentPHs.size() > 0 && currentPHs!= null)
        {
            finalquery =finalquery+' AND ('+ createCriteria(currentPHs,'opportunity__r.Product_Holdings__c') +')';
        }
        return finalquery;
    }
   
     public String prepareSubQueryFilter(Set<string> partNum)
     {
        String subQuery = ' ';
        subQuery =subQuery+' AND ('+ createCriteria(partNum,'name') +')';
        return subQuery;
     }
   
    
    
    public PageReference queryLeads()
    {
        if(!validateFields())
        {
                try{
                pageNumber=1;
                setRecords=10;
                oppList = new List<opportunity>();
                oppids= new set<id>();
                
                string districtCriteria;
                string substausCriteria;
                string endCriteria;
                Set<string> productInt = new Set<string>();
                Set<string> Region = new Set<string>();
                Set<string> allowanceKey = new Set<string>();
                Set<string> district = new Set<string>();
                Set<string> coreBundle = new Set<string>();
                Set<String> partNum = new Set<String>();
                Set<String> currentPHs = new Set<String>();
               
                productInt = formatSelectOptionsToString(allProductIntSelected);
                district = formatSelectOptionsToString(allDistrictsSelected);
                Region = formatSelectOptionsToString(allRegionsSelected);
                allowanceKey = formatSelectOptionsToString(allAllowanceKeySelected);
                allowanceKey.addall(new List<String>{'M2','EM','XD','X5','X9'});
                coreBundle = formatSelectOptionsToString(allCoreBundleSelected);
                partNum = formatTextToString(partNumber);
                 if(currentProductHoldings!=null && currentProductHoldings!='')
                currentPHs = formatTextToString(currentProductHoldings);
                
        
                if(partNumber!=null && partNumber!='' && partNum.size()>0)
                {
                     subQuery = ' and id IN (select BigMachines_Quote__c from Quote_Product__c where name!=null '+prepareSubQueryFilter(partNum)+')';
                }
               
        
                List<String> oppStages= new List<String>{'Active','Information Provided','Appointed'};
                List<String> productInterest = new List<String>{'Commercial','Small Commercial'};
                List<String> statusReason= new List<String>{'QFU','Awaiting asbestos results','Disruption','Quote Not Accepted – Permission Pending','London Central – TSA/Customer Outstanding Task','Failed Credit','Contact HSA' };
                statusReason.addall(system.label.QFUFollowUpStatusReason.split(';'));
                
                string query = 'Select id,Opportunity__c From BigMachines_Quote__c where stage__c=\'Quote Finalised - Not Accepted\' and discountsTotalOnPricing__c!=0'; 
                query += ' and bmStatusReason__c NOT IN:statusReason ';
                
                endCriteria = 'Opportunity__c != null and opportunity__r.closeDate__c=null and opportunity__r.SC_Type__c!=\'Multi-Premise\' and opportunity__r.StageName IN:oppStages and opportunity__r.Finance_Process_Outcome__c=null';
                endCriteria +=' and opportunity__r.Portal_Deposit__c=null and opportunity__r.Product_Interest__c NOT IN:productInterest and opportunity__r.Payment_Reference_Number__c=null and opportunity__r.Exclude_QFU__c=false ';
                endCriteria +=' and opportunity__r.Comms_Email_Field__c!=null and opportunity__r.Customer_Email__c!=null ';
                endCriteria += subQuery;
                
                string submitdate = 'submittedDate_quote__c >=' +getDateToStringValue(bm.installationDate__c) +' AND submittedDate_quote__c <='+getDateToStringValue(bm.closeDate__c);
                prepareQuery = prepareFinalQuery(productInt , district , Region , allowanceKey,coreBundle,currentPHs);
                String finalquery = query + prepareQuery + 'AND ('+submitdate+ ') AND '+endCriteria;
                
                transient List<BigMachines_Quote__c> bmlist = database.query(finalquery+' limit 10000');
                
                
                if(bmlist.size()>0)
                {    
                     for(BigMachines_Quote__c bm: bmlist)
                     {
                         oppIds.add(bm.opportunity__c);
                     }
                     opplist = [select id,name, Customer_Name__c,CHI_Lead_Id__c,account.Address__c from opportunity where id IN:oppids limit 10000];
                }
                if(opplist.isEmpty())
                {
                        message = 'No Leads to apply voucher code. Please try changing the filter criteria.';
                        utl.setErrorMsg(false,message);
                }
                else{
                    
                    count = opplist.size();                  
                    /*if(count>10000)
                    {
                        message = 'Your Search results more than 10000 records. Please refine your filters.';
                        utl.setErrorMsg(false,message);
                        return null;
                     }*/
                     setRecordsDouble = double.valueOf(setRecords);  
                     pageDecimal = count/setRecordsDouble;
                     pageUp  = Math.Ceil(pageDecimal);
                     pageUpInt = integer.valueOf(pageUp);
                     isShowVoucherBlock =true;
                }
                
        }catch(Exception e)
        {
             message = 'Error in getting Leads. '+e.getmessage()+e.getlinenumber();
             utl.setErrorMsg(false,message);
        }
        }
        return null;
    }
    
    Public void downloadCSV()
    {
         transient List<opportunity> opporlist = [select id,name, Customer_Name__c,CHI_Lead_Id__c,account.Address__c from opportunity where id IN:oppids limit 10000];
         finalStringCSV = extratctXLS(opporlist);
    }
    
    public string extratctXLS(list<opportunity> LeadList)
    {
        String  excelHeader = 'CHI Lead Num,CHI Lead ID,Customer Name,Address\n';
        string finalstring = excelHeader;
        for(opportunity opp : LeadList)
        {
            String Address ='';
            if(opp.account.address__c!=null && opp.account.address__c.contains(','))
            {
               Address = opp.account.address__c.replaceAll(',',';');
            }
            string temp = opp.CHI_Lead_Id__c+','+opp.name +','+opp.Customer_Name__c+','+Address+'\n';
            finalstring += temp;
        }
        return finalstring;
    } 
    
    
    Public PageReference applyVoucher()
    {
        if(voucherFile.offer__c==null|| string.isBlank(voucherFile.offer__c))
        {
                message = 'Please select voucher code to apply.';
                utl.setErrorMsg(true,message);
                return null;
        }
        
        try{
               if(count>0)
               {   
                       //call batch class
                       //attachQFUVoucherFile(voucherFile.offer__c, oppid,fileName,bm.installationDate__c,bm.closeDate__c,isSalesforce,isContactEngine,isText,isEmail);
                       //QFUVoucherFileBatch batch= new QFUVoucherFileBatch(voucherFile.offer__c, oppid,fileName,bm.installationDate__c,bm.closeDate__c,isSalesforce,isContactEngine,isText,isEmail);
                       QFUVoucherFileBatch batch= new QFUVoucherFileBatch(voucherFile.offer__c,preparequery,subquery,fileName,bm.installationDate__c,bm.closeDate__c,isSalesforce,isContactEngine,isText,isEmail);
                       database.executeBatch(batch);
                       message = 'Selected voucher code is being applied. An email will be sent to you once completed.';
                       utl.setErrorMsg(false,message);
               }
          }catch(Exception e)
          {
                      message = e.getmessage()+' '+e.getlinenumber();
                      utl.setErrorMsg(true,message);
          }
         isShowVoucherBlock=false;
         count=0;
         return null;
    }
    
    Public PageReference queryVoucherFiles(){
        
        if(!validateFields())
        {
                voucherFileList = [SELECT id,name, from_date__c,to_date__c, VoucherCode__c,Voucher_File_Link__c,createddate,Voucher_Name__c FROM QFU_Voucher_File__c 
                                   WHERE from_date__c>=: bm.installationDate__c AND to_date__c<=:bm.closeDate__c AND offer__c=:voucherFile.Offer__c ORDER BY createddate DESC limit 1000];
                                   
                if(voucherFileList.isEmpty())
                {
                    message = 'No records to display. Please try changing the filter criteria.';
                    utl.setErrorMsg(false,message);
                }
        }
        return null;
    }
     
    Public PageReference previousVFSent()
     {
         isPrevious= true;
         bm = new BigMachines_Quote__c();
         voucherFile = new QFU_Voucher_File__c();
         return null;
     }
     
     Public PageReference back()
     {
         isPrevious= false;
         bm = new BigMachines_Quote__c();
         voucherFile = new QFU_Voucher_File__c();
         return null;
     }
     
     public static string createTextFileForQFU(list<opportunity> oppList)
     {
        string textBody ;
        for(opportunity opp : oppList)
        {
            if((opp.CHI_Lead_Id__c == null || opp.CHI_Lead_Id__c == '') && (opp.name== null || opp.name == '')&& (opp.Customer_Name__c == null || opp.Customer_Name__c == ''))
            continue;
            
            if(textBody != null)
            {
                textBody +=  createLineRecord(opp.CHI_Lead_Id__c,opp.Customer_Name__c,opp.account.address__c);
            }else
            {
                textBody =  createLineRecord(opp.CHI_Lead_Id__c,opp.Customer_Name__c,opp.account.address__c);
            }
        }
        return textBody;
    }
    
   
     public static string createLineRecord(string ChiLeadNo, /*string name,*/ String customerName,string address)
    {
        sendConsumableRequests sendObj= new sendConsumableRequests();
        string lineRecord =  sendObj.rightpad(ChiLeadNo,20);
    
        if(customerName != null)
        {
            lineRecord += sendObj.rightpad(customerName,30);
            
        }else
        {
            lineRecord += sendObj.rightpad('',30);
            
        }
    
        if(Address.length() > 255)
        {   
            Address = Address.substring(0,255);
        }
        
        lineRecord += Address; 
        lineRecord += '\n';
        return lineRecord;
    }
    
    
    public boolean validateFields()
    {
        errorFlag = false;
        if(bm.installationDate__c==null)
        {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'From Date: You must enter a value'));
                errorFlag=true;
        }
        if(bm.closeDate__c==null)
        {      
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'To Date: You must enter a value'));
               errorFlag=true;
        }
        if((voucherFile.offer__c==null|| string.isBlank(voucherFile.offer__c))&& isPrevious)
        {
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Voucher Code: You must enter a value'));
              errorFlag=true;
        }
        return errorFlag;
    }
     
     
     //Pagination-navigates to first page
    public PageReference firstPage()
    {
        pageNumber = 1;
        return null;
    }
    
    //Pagination-navigates to previous page
    public PageReference previousPage() 
    {
        pageNumber = pageNumber-1;
        return null;
    }
    
    //Pagination-navigates to next page
    public PageReference nextPage() 
    {
        pageNumber = pageNumber+1;
        return null;
    }
    
    //Pagination-navigates to last page
    public PageReference lastPage()
    {
        pageNumber = (count/setRecords);
        if(pageNumber < pageUp)
        {
            pageNumber = (count/setRecords)+1;
        }   
        return null;
    }
    
   /* @future(callout=true)
    public static void attachQFUVoucherFile(string offcode,set<id> oppid,String fileName, date fromdate,date todate,boolean isSalesforce,boolean isContactEngine,boolean isText,boolean isEmail)
    {
             List<BigMachines_Quote__c> bmlist = new List<BigMachines_Quote__c>();
             List<offer__c> offer = [select offer_code__c,end_date__c from offer__c where id=:offcode];
             List<opportunity> opplist = [select id,name, Customer_Name__c,CHI_Lead_Id__c,Address_Line1__c,Address_Line2__c,Address_Number__c,account.Address__c,Comms_Email_Field__c,Comms_MobilePhone_Textmail__c,(select id from BigMachines_Quotes__r) from opportunity where id IN:oppId];
             
             
             List<Lead_Offer__c> leadOffList = new List<Lead_Offer__c>();
             for(opportunity opp: opplist)
             {
                leadOffList.add(new Lead_Offer__c(opportunity__c = opp.id,offer__c=offcode,Salesforce__c=isSalesforce,Contact_Engine__c=isContactEngine,Text__c=isText,Email__c=isEmail,Comms_Email_Field__c=opp.Comms_Email_Field__c,
                                                   Comms_MobilePhone_Textmail__c =opp.Comms_MobilePhone_Textmail__c,Expiry_Date__c= offer[0].end_date__c));
                                                   
                for(BigMachines_Quote__c b:opp.BigMachines_Quotes__r)
                 {
                     b.QFU_Email_Sent__c = system.today();
                     bmlist.add(b);
                 }
             }
             
             if(!leadOffList.isEmpty())
             insert leadOffList;
             
             if(bmlist!=null)
             {
                 cls_IsRun.dontFireTriggers = true;
                 update bmlist;
             }
            
             
            String textBody;
            textBody = createTextFileForQFU(opplist);
           
            String[] str = new String[]{}; 
            Document d = new Document();
            if(textBody != null)
            {
                    textBody = createLineRecord( '','Voucher Code: '+offer[0].offer_code__c,'')+createLineRecord('','Offer Sent Date: '+system.today().format(),'')+createLineRecord('','','')+createLineRecord('CHI Lead Num','Customer Name','Address')+textBody;
                    
                    string finalTextBody = string.format(textBody,str);
                    blob textBlob = Blob.valueOf( finalTextBody );
                     
                    d.Name = fileName;
                    d.FolderId = system.label.VoucherFile_Folder_Id;
                    d.Body = textBlob;
                    d.ContentType = 'text/plain';
                    d.Type = 'txt';
                    insert d;
            }
        
           QFU_Voucher_File__c vouFile = new QFU_Voucher_File__c(); 
           vouFile.from_date__c= fromDate;
           vouFile.to_date__c = toDate;
           vouFile.offer__c = offcode;
           vouFile.Voucher_File_Link__c = system.URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.FileDownload?file='+d.id;
           insert vouFile;
    }*/
    
  }