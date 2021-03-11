global class AutoPrdBatchClass implements database.batchable<sobject>,Database.AllowsCallouts{
    
        list<Paperwork_Recieved_Details__c> newPRDs = new list<Paperwork_Recieved_Details__c>();
        
        // ++ Variable created for PDF Reieved CR start
        set<BigMachines_Quote__c> pdfQuoteList = new set<BigMachines_Quote__c>();
        Map<Id,List<Attachment>> pdfAttachmentMap = new Map<Id,List<Attachment>>();
        Map<Id,BigMachines_Quote__c> bmPDFRecievedMap = new Map<Id,BigMachines_Quote__c>();
        // -- Variable created for PDF Reieved CR end
        
        set<Opportunity> updateOpp = new set<Opportunity>();
        set<BigMachines_Quote__c> updateBmQuote = new set<BigMachines_Quote__c>();
        set<job__c> updateJob = new set<job__c>();
    
    public static void createAutoPrdBatch()
    {
        AutoPrdBatchClass objAutoPrd = new AutoPrdBatchClass();
        ID batchprocessid = Database.executeBatch(objAutoPrd,50);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Date startDate;
        Date endDate;
        if(system.label.AutoPRD == 'ON')
        {
            startDate = system.today()-integer.valueof(system.label.AutoPrd_DateRange);
            endDate = system.today()+1;
        }else
        {
            startDate =date.valueOf(system.label.AutoPRD.split(',')[0]);
            endDate = date.valueOf(system.label.AutoPRD.split(',')[0])+ decimal.valueOf(system.label.AutoPRD.split(',')[1]).intValue();
        }  
        
        string query='Select CreatedBy.Profile.Name,CreatedDate,Job_Type__c, PDF_Received__c,FaultPDF__c,POC_Payment_Method__c,Num_Of_Validated_SA_Paperworks__c, Opportunity__c,Opportunity__r.Sales_Paperwork_Count__c,b.Name, b.Id, b.quoteNumber_quote__c, b.QuoteVersion__c, b.BigMachines_Transaction_Id__c, (Select Id, ParentId, Name,CreatedDate From Attachments), (Select id,Sales_Paperwork_Validated_Date__c,Sales_Paperwork_Returned_Date__c,Additional_Information__c from Paperwork_Recieved_Details__r) From BigMachines_Quote__c b where lastmodifieddate >= :startDate and lastmodifieddate< =:endDate and Stage__c = \'Quote Finalised - Accepted\' and Is_Primary__c = true';
        if(test.isRunningTest())
        query=query+' limit 10';
        // ++ Changed query for PDF Recieved CR start
        //return Database.getQueryLocator('Select FaultPDF__c,POC_Payment_Method__c,Num_Of_Validated_SA_Paperworks__c, Opportunity__c,Opportunity__r.Sales_Paperwork_Count__c,b.Name, b.Id, b.quoteNumber_quote__c, b.QuoteVersion__c, b.BigMachines_Transaction_Id__c, (Select Id, ParentId, Name,CreatedDate From Attachments), (Select id from Paperwork_Recieved_Details__r) From BigMachines_Quote__c b where CreatedDate >= :startDate and CreatedDate< =:endDate and Is_Electronically_Signed__c = true and Stage__c = \'Quote Finalised - Accepted\' and POC_Payment_Method__c = \'Cash\' and Num_Of_Validated_SA_Paperworks__c = 0 and Is_Primary__c = true');
        return Database.getQueryLocator(query);
        //return Database.getQueryLocator('Select b.id,CreatedBy.Profile.Name,CreatedDate,Job_Type__c, PDF_Received__c,FaultPDF__c,POC_Payment_Method__c,Num_Of_Validated_SA_Paperworks__c, Opportunity__c,Opportunity__r.Sales_Paperwork_Count__c,b.Name, b.quoteNumber_quote__c, b.QuoteVersion__c, b.BigMachines_Transaction_Id__c, (Select Id, ParentId, Name,CreatedDate From Attachments), (Select id,Sales_Paperwork_Validated_Date__c,Sales_Paperwork_Returned_Date__c,Additional_Information__c from Paperwork_Recieved_Details__r) From BigMachines_Quote__c b where Stage__c = \'Quote Finalised - Accepted\' and Is_Primary__c = true and Num_Of_Validated_SA_Paperworks__c<=0 and POC_Payment_Method__c=\'Finance\' limit 3');
        // -- Changed query for PDF Recieved CR end
        
         
    }
    
    global void execute(Database.BatchableContext BC, List<BigMachines_Quote__c> bmQuotes)
    {
        List<BigMachines_Quote__c> bmListCash= new List<BigMachines_Quote__c>();
        List<BigMachines_Quote__c> bmListFinance= new List<BigMachines_Quote__c>();
        
        system.debug('bmQuotes '+bmQuotes);
        for(BigMachines_Quote__c b : bmQuotes)
        {
            // AutoPRD Affordable warmth Jobs i.e.Quote with Job Type 13, 14
            if(b.Job_Type__c != '13' && b.Job_Type__c != '14')
            {
                // ++ Added for PDF Reieved CR start
                if(b.PDF_Received__c==false)
                {
                   pdfAttachmentMap.put(b.Id, b.Attachments);
                   bmPDFRecievedMap.put(b.id , b);
                }
                // -- Added for PDF Reieved CR end
                
                if(b.POC_Payment_Method__c=='Cash')
                bmListCash.add(b);
                else
                bmListFinance.add(b);
                
            }else 
            {
                if(b.Paperwork_Recieved_Details__r.size()==0)
                {
                    updateOpp.add(new Opportunity(Id= b.Opportunity__c, Sales_Paperwork_Count__c = 1));
                    Paperwork_Recieved_Details__c newPrd = new Paperwork_Recieved_Details__c(Big_Machines_Quote__c=b.Id, Sales_Paperwork_Validated_Date__c = b.CreatedDate.date());
                    newPRDs.add(newPrd);
                }
            }
        }
        
        
        if(bmListFinance.size()>0)
            financeQuoteAutoPRD(bmListFinance);
        if(bmListCash.size()>0)
            cashQuoteAutoPRD(bmListCash);
        
        
         // -- Added for PDF Reieved CR start
         for(id i: pdfAttachmentMap.keyset())
         {
            list<Attachment> pdfAttList= new list<Attachment> ();
            pdfAttList = pdfAttachmentMap.get(i);
            //PRB00027481 fix starts
            String pdfname; 
            for(Attachment att : pdfAttList)
            {
            pdfname = bmPDFRecievedMap.get(att.ParentId).BigMachines_Transaction_Id__c+'_quote.pdf'; 
            System.debug('pdfname '+pdfname);
            System.debug(att.Name.equalsIgnoreCase(pdfname));
                if(bmPDFRecievedMap.containsKey(att.ParentId) && att.Name.equalsIgnoreCase(pdfname)) //PRB00027481 - added att.Name.equalsIgnoreCase(pdfname)
                {
                    bmPDFRecievedMap.get(att.ParentId).PDF_Received__c = true;
                    pdfQuoteList.add(bmPDFRecievedMap.get(att.ParentId));
                }
            }
            //PRB00027481 fix ends 
        }
        
        cls_IsRun.dontFireTriggers = true;
         
        if(pdfQuoteList.size() > 0)
            update new list<Bigmachines_Quote__c>(pdfQuoteList);
        // -- Added for PDF Reieved CR end
        
    
       
        
        if(newPRDs.size()>0)
        upsert newPRDs;
        
        if(updateOpp.size()>0)
        update (new list<Opportunity>(updateOpp));
        
        /*if(updateBmQuote.size()>0)
        update new list<Bigmachines_Quote__c>(updateBmQuote);*/
        
        if(updateJob.size()>0)
        update new list<job__c>(updateJob);
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
    public void cashQuoteAutoPRD(List<BigMachines_Quote__c> bmList)
    {
        map<id, BigMachines_Quote__c> oppBmMap = new map<id, BigMachines_Quote__c>();
        map <id , BigMachines_Quote__c> bm =  new map<id, BigMachines_Quote__c>();
        map<id, list<Attachment>> bmAttachemntMap = new map<id, list<Attachment>>();
        map<id, list<Attachment>> bmAttachemntMap2 = new map<id, list<Attachment>>();
        set<id> bmidSet= new set<id>();
        
        for(BigMachines_Quote__c b : bmList)
        {
            if(b.Paperwork_Recieved_Details__r.size()==0)
                {
                    if(!oppBmMap.containsKey(b.Opportunity__c))
                    oppBmMap.put(b.Opportunity__c, b);
                    if(!bmAttachemntMap.containsKey(b.Id))
                    {
                        bmAttachemntMap.put(b.Id, b.Attachments);  
                        bm.put(b.Id, b) ;
                    }
                }
        }  
       
        list<BGS_Payment__c> bgPayments = new list<BGS_Payment__c>([Select id,Amount__c,Payment_Method__c, Opportunity__c,CreatedDate, Opportunity__r.Sales_Paperwork_Count__c from BGS_Payment__c where Opportunity__c in:oppBmMap.keyset() and Payment_Type__c = 'Deposit' /*and (Payment_Method__c = 'Debit Card' or Payment_Method__c = 'Credit Card' or Payment_Method__c = 'Cheque') */]);
        
        for(BGS_Payment__c b: bgPayments)
        {
            if((b.Payment_Method__c == 'Debit Card' || b.Payment_Method__c == 'Credit Card' || b.Payment_Method__c == 'Cheque' || ( b.Payment_Method__c == 'Cash' && b.Amount__c <= 0 )) && oppBmMap.containsKey(b.Opportunity__c) && !bmAttachemntMap2.containskey(oppBmMap.get(b.Opportunity__c).Id))
            {
                // Populated the values in Map only if POC_Payment_Method__c == 'Cash'
                if(oppBmMap.get(b.Opportunity__c).POC_Payment_Method__c == 'Cash')
                {
                    bmAttachemntMap2.put(oppBmMap.get(b.Opportunity__c).Id, bmAttachemntMap.get(oppBmMap.get(b.Opportunity__c).Id));
                    updateOpp.add(new Opportunity(Id= b.Opportunity__c, Sales_Paperwork_Count__c = 1));
                    if(!system.label.AutoPRDSwitch.contains(oppBmMap.get(b.Opportunity__c).CreatedBy.Profile.Name) &&  b.Opportunity__r.Sales_Paperwork_Count__c <1)
                    {   
                        bmidSet.add(oppBmMap.get(b.Opportunity__c).Id);
                        Paperwork_Recieved_Details__c newPrd = new Paperwork_Recieved_Details__c(Big_Machines_Quote__c=oppBmMap.get(b.Opportunity__c).Id, Sales_Paperwork_Validated_Date__c = oppBmMap.get(b.Opportunity__c).CreatedDate.date());
                        newPRDs.add(newPrd);
                        
                    }
                }
                
            }       
        } 
        
       
        for(id i: bmAttachemntMap2.keyset())
        {
            list<Attachment> attlist= new list<Attachment> ();
            attlist = bmAttachemntMap2.get(i);
            //PRB00027481 fix starts
            String attname; 
            for(Attachment a : attlist)
            {
                  attname = bm.get(a.ParentId).BigMachines_Transaction_Id__c+'_quote.pdf'; 
                  System.debug('attname '+attname);
                  System.debug(a.Name.equalsIgnoreCase(attname));
               if(bm.get(a.ParentId).POC_Payment_Method__c == 'Cash' && bm.get(a.ParentId).Num_Of_Validated_SA_Paperworks__c == 0 && a.Name.equalsIgnoreCase(attname) && bm.get(a.ParentId).FaultPDF__c == false && !bmidSet.contains(i)) //PRB00027481 - added a.Name.equalsIgnoreCase(attname)
                {
                    Paperwork_Recieved_Details__c newPrd = new Paperwork_Recieved_Details__c(Big_Machines_Quote__c=i, Sales_Paperwork_Validated_Date__c = a.CreatedDate.date());
                    newPRDs.add(newPrd);
                    Break; 
                }    
            }
            //PRB00027481 fix ends  
        }
       
    }
     
    
    public void financeQuoteAutoPRD(List<BigMachines_Quote__c> bmList)
    {
        map<id,job__c> oppJobMap = new map<id,job__c>();
        set<id> oppid= new set<id>();
        map<id, BigMachines_Quote__c> oppBmMap = new map<id, BigMachines_Quote__c>();
        
        map <id , BigMachines_Quote__c> bm =  new map<id, BigMachines_Quote__c>();
        map<id, list<Attachment>> bmAttachemntMap = new map<id, list<Attachment>>();
        map<id, list<Attachment>> bmAttachemntMap2 = new map<id, list<Attachment>>();
        
        set<id> bmidSet = new set<id>();
        
        for(BigMachines_Quote__c b : bmList)
        {
            if(b.Paperwork_Recieved_Details__r.size()>0)
            {
                for(Paperwork_Recieved_Details__c prd: b.Paperwork_Recieved_Details__r)
                {
                    if(prd.Sales_Paperwork_Validated_Date__c==null&& prd.Sales_Paperwork_Returned_Date__c==null && prd.Additional_Information__c==null)
                    {
                       Paperwork_Recieved_Details__c newPrd = new Paperwork_Recieved_Details__c(id=prd.id, Sales_Paperwork_Validated_Date__c = b.CreatedDate.date());
                       newPRDs.add(newPrd);
                    }
                }
            }  
            else if(b.Paperwork_Recieved_Details__r.size()==0)
                {
                    if(!oppBmMap.containsKey(b.Opportunity__c))
                    oppBmMap.put(b.Opportunity__c, b);
                    
                    oppid.add(b.opportunity__c);
                    if(!bmAttachemntMap.containsKey(b.Id))
                    {
                        bmAttachemntMap.put(b.Id, b.Attachments);  
                        bm.put(b.Id, b) ;
                    }
                }
        }

        List<job__c> jobList = new List<job__C>([select id,CHI_lead__c,status__c,sub_status__c,Pre_Electrical_Required__c, Asbestos_Removal_Required__c, Scaffolding_Required__c from job__c where CHI_lead__c in:oppBmMap.keyset() and is_remedial_job__c=false and is_downtime_job__c=false]);
        for(job__c j:jobList)
        {
            oppJobMap.put(j.CHI_lead__c,j);
        }
        
        
       /* List<Finance_Application__c> financeAppList = new List<Finance_Application__c>([select id,Valid_New_Application__c,Finance_Product__r.name,Finance_Product__r.Parent_Product__r.Name,
                                                       name,Application_ID__c,Referral_Reason__c,Document_Link__c,X2nd_Lended_Soft_Search__c,Application_Status__c,status__c,CHI_Lead__c,CHI_Lead__r.Sales_Paperwork_Count__c,CHI_Lead__r.Account.Primary_Contact__c,Agreement_Number__c,Cash_Price__c,Finance_Lender__c from Finance_Application__c where CHI_Lead__c in:oppBmMap.keyset() and (Application_status__c='Parked' or Application_status__c='Live')]);*/
                                                       
         string applicationQuery= Utilities.makeQueryWithAllFields('Finance_Application__c', '');
		 applicationQuery = applicationQuery.replace('from Finance_Application__c' , ',Finance_Product__r.X2nd_Lender_Product__c,Finance_Product__r.Product_Code__c,Finance_Product__r.Asset_Type__c ,CHI_Lead__r.Product_Interest__c,CHI_Lead__r.ExternalRef__c,'+ 
		'Finance_Product__r.Not_Available_For__c, CHI_Lead__r.CHI_Lead_Id__c, Finance_Product__r.Parent_Product__r.Name, Finance_Product__r.Name, Finance_Product__r.Code__c,Finance_Product__r.Asset_Type_Description__c,'+
		'Finance_Product__r.New_Product__c, Finance_Product__r.Selling_Type__c,CHI_Lead__r.Sales_Paperwork_Count__c,CHI_Lead__r.Account.Primary_Contact__c from Finance_Application__c where CHI_Lead__c in:oppid');
		
		//'Finance_Product__r.New_Product__c, Finance_Product__r.Selling_Type__c,CHI_Lead__r.Sales_Paperwork_Count__c,CHI_Lead__r.Account.Primary_Contact__c from Finance_Application__c where (Application_status__c=\'Parked\' or Application_status__c=\'Live\') and CHI_Lead__c in:oppid');
		
		List<Finance_Application__c> financeAppList = database.query(applicationQuery);
        
        //get the finance application's current status
        FinanceApplicationEnqBatch batch = new FinanceApplicationEnqBatch();
        List<Finance_Application__c> financeList = batch.getFinanceAppStatus(financeAppList);
        
        if(test.isrunningTest())
        financeList=financeAppList;
        
        List<String> jobSubStatus = system.label.Auto_Prd_Job_Sub_Status.split(',');
        string allParkedValues = IV_Vectors__c.getInstance('Finance_Parked_Status').Key__c;
        string allLiveValues = IV_Vectors__c.getInstance('Finance_Live_Status').Key__c;
        
        for(Finance_Application__c fa: financeList)
        {
            if((allParkedValues.contains(fa.Application_status__c)||allLiveValues.contains(fa.Application_status__c))&& !bmAttachemntMap2.containskey(oppBmMap.get(fa.CHI_Lead__c).Id)&&oppBmMap.containsKey(fa.CHI_Lead__c))
            {
                //updateBmQuote.add(new BigMachines_Quote__c(id=oppBmMap.get(fa.CHI_Lead__c).Id,POC_Payment_Option__c=fa.Finance_Lender__c,POC_Payment_Method__c='Finance'));
                bmAttachemntMap2.put(oppBmMap.get(fa.CHI_Lead__c).Id, bmAttachemntMap.get(oppBmMap.get(fa.CHI_Lead__c).Id));
                
                if(!system.label.AutoPRDSwitch.contains(oppBmMap.get(fa.CHI_Lead__c).CreatedBy.Profile.Name) && fa.CHI_Lead__r.Sales_Paperwork_Count__c <1)
                {
                    bmidSet.add(oppBmMap.get(fa.CHI_Lead__c).Id);
                Paperwork_Recieved_Details__c newPrd = new Paperwork_Recieved_Details__c(Big_Machines_Quote__c=oppBmMap.get(fa.CHI_Lead__c).Id, Sales_Paperwork_Validated_Date__c = oppBmMap.get(fa.CHI_Lead__c).CreatedDate.date());
                newPRDs.add(newPrd);
                }
                updateOpp.add(new Opportunity(Id=fa.CHI_Lead__c, Sales_Paperwork_Count__c = 1));
                
                job__c jb= oppJobMap.containsKey(fa.CHI_Lead__c)?oppJobMap.get(fa.CHI_Lead__c):null;
                
                
                string substatus = 'Install Date Required';
                
                if(jb.Pre_Electrical_Required__c)
                substatus = 'Planning Pending - pre electrical survey';
                
                if(jb.Scaffolding_Required__c == 'Yes')
                substatus = 'Scaffolding Required';
                
                if(jb.Asbestos_Removal_Required__c == 'Yes')
                substatus = 'Planning Pending - Asbestos';
                
                if(jb!=null && jobSubStatus.contains(jb.sub_status__c))
                updateJob.add(new job__c(id=jb.id,sub_status__c=substatus));
                
            }
        }
        
        for(id i: bmAttachemntMap2.keyset())
        {
            list<Attachment> attlist= new list<Attachment> ();
            attlist = bmAttachemntMap2.get(i);
            String attname; 
            for(Attachment a : attlist)
            {
                  attname = bm.get(a.ParentId).BigMachines_Transaction_Id__c+'_quote.pdf'; 
                  System.debug('attname '+attname);
                  System.debug(a.Name.equalsIgnoreCase(attname));
               if(bm.get(a.ParentId).POC_Payment_Method__c == 'Finance' && bm.get(a.ParentId).Num_Of_Validated_SA_Paperworks__c == 0 && a.Name.equalsIgnoreCase(attname) && bm.get(a.ParentId).FaultPDF__c == false && !bmidSet.contains(i)) //PRB00027481 - added a.Name.equalsIgnoreCase(attname)
                {
                    Paperwork_Recieved_Details__c newPrd = new Paperwork_Recieved_Details__c(Big_Machines_Quote__c=i, Sales_Paperwork_Validated_Date__c = a.CreatedDate.date());
                    newPRDs.add(newPrd);
                    Break; 
                }    
            }
        }
    }
    
    
     

}