global class AutoPrdBatchClass implements database.batchable<sobject>{
    
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
            startDate = system.today()-2;
            endDate = system.today()+1;
        }else
        {
            startDate =date.valueOf(system.label.AutoPRD.split(',')[0]);
            endDate = date.valueOf(system.label.AutoPRD.split(',')[0])+ decimal.valueOf(system.label.AutoPRD.split(',')[1]).intValue();
        }   
        
        // ++ Changed query for PDF Recieved CR start
        //return Database.getQueryLocator('Select FaultPDF__c,POC_Payment_Method__c,Num_Of_Validated_SA_Paperworks__c, Opportunity__c,Opportunity__r.Sales_Paperwork_Count__c,b.Name, b.Id, b.quoteNumber_quote__c, b.QuoteVersion__c, b.BigMachines_Transaction_Id__c, (Select Id, ParentId, Name,CreatedDate From Attachments), (Select id from Paperwork_Recieved_Details__r) From BigMachines_Quote__c b where CreatedDate >= :startDate and CreatedDate< =:endDate and Is_Electronically_Signed__c = true and Stage__c = \'Quote Finalised - Accepted\' and POC_Payment_Method__c = \'Cash\' and Num_Of_Validated_SA_Paperworks__c = 0 and Is_Primary__c = true');
        return Database.getQueryLocator('Select CreatedBy.Profile.Name,CreatedDate,Job_Type__c, PDF_Received__c,FaultPDF__c,POC_Payment_Method__c,Num_Of_Validated_SA_Paperworks__c, Opportunity__c,Opportunity__r.Sales_Paperwork_Count__c,b.Name, b.Id, b.quoteNumber_quote__c, b.QuoteVersion__c, b.BigMachines_Transaction_Id__c, (Select Id, ParentId, Name,CreatedDate From Attachments), (Select id from Paperwork_Recieved_Details__r) From BigMachines_Quote__c b where CreatedDate >= :startDate and CreatedDate< =:endDate and Stage__c = \'Quote Finalised - Accepted\' and Is_Primary__c = true and PDF_Received__c = false');
        // -- Changed query for PDF Recieved CR end
        
         
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> bmQuotes)
    {
        cls_IsRun.dontFireTriggers = true;
        list<Paperwork_Recieved_Details__c> newPRDs = new list<Paperwork_Recieved_Details__c>();
        map <id , BigMachines_Quote__c> bm =  new map<id, BigMachines_Quote__c>();
        map<id, list<Attachment>> bmAttachemntMap = new map<id, list<Attachment>>();
        map<id, BigMachines_Quote__c> oppBmMap = new map<id, BigMachines_Quote__c>();
        map<id, list<Attachment>> bmAttachemntMap2 = new map<id, list<Attachment>>();
        set<Opportunity> updateOpp = new set<Opportunity>();
        // ++ Variable created for PDF Reieved CR start
        set<BigMachines_Quote__c> pdfQuoteList = new set<BigMachines_Quote__c>();
        Map<Id,List<Attachment>> pdfAttachmentMap = new Map<Id,List<Attachment>>();
        Map<Id,BigMachines_Quote__c> bmPDFRecievedMap = new Map<Id,BigMachines_Quote__c>();
        // -- Variable created for PDF Reieved CR end
        
        for(sObject s : bmQuotes)
        {
            BigMachines_Quote__c b = (BigMachines_Quote__c)s;
            // AutoPRD Affordable warmth Jobs i.e.Quote with Job Type 13, 14
            if(b.Job_Type__c != '13' && b.Job_Type__c != '14')
            {
                // ++ Added for PDF Reieved CR start
                pdfAttachmentMap.put(b.Id, b.Attachments);
                bmPDFRecievedMap.put(b.id , b);
                // -- Added for PDF Reieved CR end
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
        system.debug('opp1---->'+oppBmMap.keyset());
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
               if(bm.get(a.ParentId).POC_Payment_Method__c == 'Cash' && bm.get(a.ParentId).Num_Of_Validated_SA_Paperworks__c == 0 && a.Name.equalsIgnoreCase(attname) && bm.get(a.ParentId).FaultPDF__c == false) //PRB00027481 - added a.Name.equalsIgnoreCase(attname)
                {
                    Paperwork_Recieved_Details__c newPrd = new Paperwork_Recieved_Details__c(Big_Machines_Quote__c=i, Sales_Paperwork_Validated_Date__c = a.CreatedDate.date());
                    newPRDs.add(newPrd);
                    Break; 
                }    
            }
            //PRB00027481 fix ends  
        } 
        
        // ++ Added for PDF Reieved CR start
        //if(system.label.AutoPRDSwitch== 'on')
        //{
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
        if(pdfQuoteList.size() > 0)
        {
            update new list<Bigmachines_Quote__c>(pdfQuoteList);
        }
        // }
        // -- Added for PDF Reieved CR end
        if(newPRDs.size()>0)
        insert newPRDs;
        
        if(updateOpp.size()>0)
        update (new list<Opportunity>(updateOpp));
                
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }

}