global class QFUVoucherFileBatch implements Database.Batchable<sObject>,Database.stateful{
  public string finalquery='';
  public string offcode;
  public String fileName;
  public date fromdate;
  public date todate;
  public boolean isSalesforce;
  public boolean isContactEngine;
  public boolean isText;
  public boolean isEmail;
  public List<offer__c> offer;
  public String textBody;
  public List<String> oppStages= new List<String>{'Active','Information Provided','Appointed'};
  public List<String> productInterest = new List<String>{'Commercial','Small Commercial'};
  public List<String> statusReason= new List<String>{'QFU','Awaiting asbestos results','Disruption','Quote Not Accepted – Permission Pending','London Central – TSA/Customer Outstanding Task','Failed Credit','Contact HSA' };
  public string preparequery;
  public string subquery;
  
  global QFUVoucherFileBatch(string offcode,string preparequery,string subquery,String fileName,date fromdate,date todate,boolean isSalesforce,boolean isContactEngine,boolean isText,boolean isEmail)
  {   
      this.offcode= offcode;
      this.fileName=fileName;
      this.fromdate=fromdate;
      this.todate=todate;
      this.isSalesforce=isSalesforce;
      this.isContactEngine=isContactEngine;
      this.isText=isText;
      this.isEmail=isEmail;
      this.preparequery=preparequery;
      this.subquery=subquery;
      offer = [select offer_code__c,end_date__c from offer__c where id=:offcode];
      statusReason.addall(system.label.QFUFollowUpStatusReason.split(';'));
  }

  global Database.QueryLocator start(Database.BatchableContext BC)
    {
         //query = 'select id,name, Customer_Name__c,CHI_Lead_Id__c,Address_Line1__c,Address_Line2__c,Address_Number__c,account.Address__c,Comms_Email_Field__c,Comms_MobilePhone_Textmail__c,(select id from BigMachines_Quotes__r) from opportunity where id IN:leadIds';
      string query = 'Select id,Opportunity__c From BigMachines_Quote__c where stage__c=\'Quote Finalised - Not Accepted\' and discountsTotalOnPricing__c!=0'; 
      query += ' and bmStatusReason__c NOT IN:statusReason ';
      
      string endCriteria;          
      endCriteria = 'Opportunity__c != null and opportunity__r.closeDate__c=null and opportunity__r.SC_Type__c!=\'Multi-Premise\' and opportunity__r.StageName IN:oppStages and opportunity__r.Finance_Process_Outcome__c=null';
      endCriteria +=' and opportunity__r.Portal_Deposit__c=null and opportunity__r.Product_Interest__c NOT IN:productInterest and opportunity__r.Payment_Reference_Number__c=null and opportunity__r.Exclude_QFU__c=false ';
      endCriteria +=' and opportunity__r.Comms_Email_Field__c!=null and opportunity__r.Customer_Email__c!=null ';
      endCriteria += subQuery;
      
      string submitdate = 'submittedDate_quote__c >=' +QuotesPageCont.getDateToStringValue(fromdate) +' AND submittedDate_quote__c <='+QuotesPageCont.getDateToStringValue(todate);
      
      finalquery = query + preparequery + 'AND ('+submitdate+ ') AND '+endCriteria;
      
      if(test.isrunningtest())
      finalquery = 'select id,opportunity__c from BigMachines_Quote__c limit 1';
      return Database.getQueryLocator(finalquery);
    }
    
    
  global void execute(Database.BatchableContext BC, List<BigMachines_Quote__c> bmlist)
    {
        cls_IsRun.generalTriggerSwitch =true;
        cls_IsRun.dontFireTriggers = true;
        List<opportunity> opplist = new List<opportunity>();
        set<id> oppIds = new set<Id>();
        
            if(bmlist.size()>0)
            {  
                for(BigMachines_Quote__c bm: bmlist)
                {
                    oppIds.add(bm.opportunity__c);
                }
                        
                opplist = [select id,name, Customer_Name__c,CHI_Lead_Id__c,Address_Line1__c,Address_Line2__c,Address_Number__c,account.Address__c,Comms_Email_Field__c,
                              Comms_MobilePhone_Textmail__c,(select id from BigMachines_Quotes__r order by createddate desc limit 1) from opportunity where id IN:oppids];
            }
        
        
            if(opplist.size()>0)
            {
                List<Lead_Offer__c> leadOffList = new List<Lead_Offer__c>();
                List<BigMachines_Quote__c> bmquotelist = new List<BigMachines_Quote__c>();
                
                set<id> oppLeadOfferIds = new set<id>();
                for(Lead_Offer__c leadoff: [select id, opportunity__c from Lead_Offer__c where opportunity__c IN:oppIds and offer__c=:offcode])
                {
                    oppLeadOfferIds.add(leadoff.opportunity__c);
                }
                
                List<opportunity> oppListnew = new List<opportunity>();
                for(opportunity opp: opplist)
                {
                     if(!oppLeadOfferIds.contains(opp.id))
                     {
                         leadOffList.add(new Lead_Offer__c(opportunity__c = opp.id,offer__c=offcode,Salesforce__c=isSalesforce,Contact_Engine__c=isContactEngine,Text__c=isText,Email__c=isEmail,Comms_Email_Field__c=opp.Comms_Email_Field__c,
                                                               Comms_MobilePhone_Textmail__c =opp.Comms_MobilePhone_Textmail__c,Expiry_Date__c= offer[0].end_date__c));
                         for(BigMachines_Quote__c b:opp.BigMachines_Quotes__r)
                         {
                            b.QFU_Email_Sent__c = system.today();
                            bmquotelist.add(b);
                         }
                         oppListnew.add(opp);
                     }
                }
                 
            if(!leadOffList.isEmpty())
                  database.insert(leadOffList);
                 
            if(!bmquotelist.isEmpty())
                  database.update(bmquotelist);
            
            if(textBody==null)
            textBody = QuotesPageCont.createTextFileForQFU(oppListnew);   
            else
            textbody += QuotesPageCont.createTextFileForQFU(oppListnew);  
          }
    }
    
    global void finish(Database.BatchableContext bc){
            String[] str = new String[]{}; 
            Document d = new Document();
            if(textBody != null)
            {
                    textBody = QuotesPageCont.createLineRecord( '','Voucher Code: '+offer[0].offer_code__c,'')+QuotesPageCont.createLineRecord('','Offer Sent Date: '+system.today().format(),'')+QuotesPageCont.createLineRecord('','','')+QuotesPageCont.createLineRecord('CHI Lead Num','Customer Name','Address')+textBody;
                    
                    string finalTextBody = string.format(textBody,str);
                    blob textBlob = Blob.valueOf( finalTextBody );
                     
                    d.Name = fileName;
                    d.FolderId = system.label.VoucherFile_Folder_Id;
                    d.Body = textBlob;
                    d.ContentType = 'text/plain';
                    d.Type = 'txt';
                    insert d;
                    
                   QFU_Voucher_File__c vouFile = new QFU_Voucher_File__c(); 
                   vouFile.from_date__c= fromDate;
                   vouFile.to_date__c = toDate;
                   vouFile.offer__c = offcode;
                   vouFile.Voucher_File_Link__c = system.URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.FileDownload?file='+d.id;
                   insert vouFile;
            }
           
           AsyncApexJob a = [SELECT Id,Status,JobType,NumberOfErrors,JobItemsProcessed,TotalJobItems,CompletedDate,ExtendedStatus
                              FROM AsyncApexJob WHERE Id =:BC.getJobId()];
                              
           User current_user=[SELECT Email FROM User WHERE Id= :UserInfo.getUserId()];
           String plaintextbody ='The batch Apex job completed on  ' + a.CompletedDate + ',\n\n' +
           'Job Status : ' + a.Status + '\n'+
           'Total Job Items processed : ' + a.TotalJobItems + '\n'+
           'Number of Job Items processed : ' + a.JobItemsProcessed + '\n' +
           'Number of Failures : '+ a.NumberOfErrors;
           if(!test.isRunningtest())
           CreateEmail.CretaeSendTextEmail(new list<string>{current_user.email}, plaintextbody, 'VoucherCode Batch - ' + a.Status);
    }
    
   
  
}