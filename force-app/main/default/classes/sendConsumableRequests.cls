/*
Creator: Cognizant 01/12/2011
Description : This class used to generate Text file for Callidus and a Excel file for Salesforce team by Looking into consumable request that were submitted by engineers.

The files will be named BGSO*.txt

NB: The * can be up to 10 alphanumeric or underscores characters long to make the file unique.

Each file can hold multiple sales orders. All lines for 1 order will be sequential in the file, and the first line will contain the information for the header.

The first line will be used for the header but it is also used for line 1; every line is a product line.

The file structure should consist of the following
*****************************************************************************************************************************************
Field                              Size                Padding             Example              Salesforce Field Used/data Used
**************************** Consumable Requests*****************************************************************************************
Customer Code                      7 chars             zero filled         “0000030”            Consumables_Requests__c.Employee_ID__c(Payroll Number)
Customer Ref                       15 chars            space filled        “ABCDEFGHIJ     ”    Consumables_Requests__c.Name
Order Type                         3 chars             space filled        “OTG”                Constant -"OTG"
Pref Delivery Date                 8 numbers           format yyyymmdd     “20100810”           Date - Always Tomorrow
Patch ID                           5 chars             space filled        “13010” or “     “   Consumables_Requests__c.Callidus_Patch_Id__c
Market Code                        4 chars             space filled        “BGAS”               Constant - "BGAS"
Sales Product Type                 4 numbers           zero filled         “1234”               Constant -"0000"
End Customer Name                  36 chars            Space filled         Not Mandatory       36 Blank Spaces
End Customer Add line 1            36 chars            Space filled         Not Mandatory       36 Blank Spaces
End Customer Add line 2            36 chars            Space filled         Not Mandatory       36 Blank Spaces
End Customer Add line 3            36 chars            Space filled         Not Mandatory       36 Blank Spaces
End Customer Add line 4            36 chars            Space filled         Not Mandatory       36 Blank Spaces

*****************************Only relevant to an order line**********************************************************************************
Product Line Number                4 numbers           zero filled          “0001”              sequential Number for each line item      
Product Code                       6 chars             space filled         “123456”            Consumable_Items__c.Product_Code__c
Quantity                           9 numbers           zero filled           Last 3             Consumable_Items__c.Quantity__c
                                                                             decimal included 
                                                                            (000001500)= 1.5 
                                                                            “000022000” is 22

************************************************************************************************

A example of text file would look like.

01110655000003643     OTY2011020914ASMBGAS0000                                                                                                                                                                                    0001C00232000001000
<-------------Header string-----------------Header string-----------------------Header string----------------------Header string------------------------Header string----------------Header string---------------Header string---><---Child String--->
01110655000003643     OTY2011020914ASMBGAS0000                                                                                                                                                                                    0002C34559000001000

*****************************************************************************************************************************************
 
*/
global class sendConsumableRequests implements Database.Batchable<sObject> {
    
    public void createConReqBatch()
    {
        sendConsumableRequests objConReq = new sendConsumableRequests();
         // ++ CSI00003709 - Send consumable batch should not run on bank holidays changes starts
        Utilities util = new Utilities();
        boolean bank_holidays_flag = util.isTodayBankHoliday(system.today());
        System.debug('********* 12345 bank_holidays_flag '+bank_holidays_flag);
        if(bank_holidays_flag == false){
            ID batchprocessid = Database.executeBatch(objConReq);
        }
        // ++ CSI00003709 - Send consumable batch should not run on bank holidays changes ends
        
    }
    
    string CreatedDateStrng = system.label.Consumable_request_Deploy;
    Date CreatedDate = date.valueOf(CreatedDateStrng);  
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        date todayDate = system.today();
        list<Document> dList = [Select Name, Id, FolderId, Body From Document d where FolderId= :system.label.Consumable_Folder_Id and CreatedDate >= :todayDate];
        if(dList.size()>0)
        delete dList;
         return Database.getQueryLocator('Select Id,Raised_By__c,Name, Employee_ID__c,Picked_Up_by_Email__c,Item_Count__c, Employee__c, Delivery_Date__c, Callidus_Patch_Id__c, ApprovedTick__c, (Select Id, Product_Code__c, Quantity__c From Consumable_Items__r) From Consumables_Requests__c  where Picked_Up_by_Email__c = false and CreatedDate >=:CreatedDate and Status__c = \'Submitted\' and (Approval_Required__c= \'No\' OR (Approval_Required__c= \'Yes\' and Approved__c = true)) and Employee__c != null');
         //return Database.getQueryLocator('Select Id,Raised_By__c,Name, Employee_ID__c,Picked_Up_by_Email__c,Item_Count__c, Employee__c, Delivery_Date__c, Callidus_Patch_Id__c, ApprovedTick__c, (Select Id, Product_Code__c, Quantity__c From Consumable_Items__r) From Consumables_Requests__c  where Status__c = \'Submitted\' and Item_Count__c >0 order by CreatedDate desc limit 20');
         
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> consumableRequests)
    {
        list<Consumables_Requests__c> conReqLst = new list<Consumables_Requests__c>();
        
         for(sObject sObj : consumableRequests)
         {
            Consumables_Requests__c c = (Consumables_Requests__c)sObj;
            conReqLst.add(c);
         }
         createTextExcelFile(conReqLst);
    }
    
    public void createTextExcelFile(list<Consumables_Requests__c> conReqLst)
    {
        
        list<Consumables_Requests__c> conReqToUpdate = new list<Consumables_Requests__c>();
        string todayTime = system.now().format();
        string fileName = todayTime.substring(0,2)+todayTime.substring(3,5)+todayTime.substring(8,10)+'_'+todayTime.substring(11,13)+todayTime.substring(14,16);
        String[] str = new String[]{}; 
        string excelHeader = 'Consumer Request Id,Consumer Item Id,Consumer Request No,Employee Payroll,Product Code, Quantity, Status\n';
        string TextBody;
        string excelBody = excelHeader;
        for(Integer i=0;i<conReqLst.size();i++)
        {
            string headerSting = createHeaderString(conReqLst[i]);
            if(headerSting!= null)
            {
                
                list<Consumable_Items__c> cItems = conReqLst[i].Consumable_Items__r;
                integer j = 1;
                for(Consumable_Items__c c: cItems)
                    {
                        string sinlgleLineItem = createChildString(headerSting,c,j);
                        if(sinlgleLineItem != null)
                        {
                            if(TextBody!=null )
                            {
                                TextBody = TextBody +sinlgleLineItem+'\n';
                            }
                            else
                            {
                                TextBody = sinlgleLineItem +'\n';
                            }
                        }
                        j++;
                        string individualExcelLine = conReqLst[i].Id+','+c.Id+','+conReqLst[i].Name+','+conReqLst[i].Employee_ID__c+','+c.Product_Code__c+','+c.Quantity__c+','+',\n';
                        excelBody = excelBody+individualExcelLine;
                        }
                        
                     }
                    
                    conReqLst[i].Picked_Up_by_Email__c = true;
                    conReqLst[i].File_Name__c = 'EXSO_CHI_'+fileName;
                    conReqToUpdate.add(conReqLst[i]);
                
              }     
       
        if(TextBody!=null)     
        {   
            // excel Attachment
            //Messaging.EmailFileAttachment excelAttc = new Messaging.EmailFileAttachment();
            blob excelBlob = Blob.valueOf( excelBody );
            string excelName = 'EXSO_CHI_'+fileName+'excel.csv';
            Document d = new Document(); 
            d.Name = excelName;
            d.FolderId = system.label.Consumable_Folder_Id;
            d.Body = excelBlob;
            d.ContentType = 'text/csv';
            d.Type = 'csv';
            insert d;
            //excelAttc.setFileName(excelName);
            //excelAttc.setBody(excelBlob); 
            
            //Text Attachment
            string finalTextBody = string.format(TextBody,str);
            blob textBlob = Blob.valueOf( finalTextBody );
            //Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            fileName = 'EXSO_CHI_'+fileName+'.txt';
            //efa.setFileName(fileName);
           // efa.setBody(textBlob);  
            d = new Document(); 
            d.Name = fileName;
            d.FolderId = system.label.Consumable_Folder_Id;
            d.Body = textBlob;
            d.ContentType = 'text/plain';
            d.Type = 'txt';
            insert d;
            /*Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = system.label.Callidus_Batch_Emails.split(',');
            String subject = 'CHI orders for Callidus for : '+System.now();
            email.setSubject( subject );
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('PFA for Callidus Orders');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa,excelAttc});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});*/
            
            if(conReqToUpdate.size()>0)
            {
                update conReqToUpdate;
            }
        }
        
    }
    // following two methods will add required number of spaces depending upon size of my string and maxlength,  
    //a max of 80 spaces can be added in leftpad and 100 spaces in rightpad. 
    public String leftpad(String source, integer maxlength) {
        if(source==null) return null;
        if(source.length()>maxlength) return source;
        return '                                                                                ' .substring(0,maxlength-source.length()) + source;
    }
    
    //100 spaces in rightpad. 
    public String rightpad(String source, integer maxlength) {
        if(source==null) return null;
        if(source.length()>maxlength) return source;
        return source + '                                                                                                    ' .substring(0,maxlength-source.length());
    }
    // This generates the Headerstring from consumble requests. See the Top Header comments for better undersatnding.
    public string createHeaderString(Consumables_Requests__c cReq)
    {
        boolean error = false;
        string headerSting;
        //Customer Code                      7 chars             zero filled         “0000030” 
        if(cReq.Employee_ID__c!=null)
        {
            string payrollNum = string.valueof(cReq.Employee_ID__c);
            payrollNum = padChar(payrollNum,7,'0',true);
            headerSting = payrollNum;
        }else
        {
            return null;
        }
        //Customer Ref                       15 chars            space filled        “ABCDEFGHIJ     ”  
        if(cReq.Name!=null)
        {
            string orderId = string.valueof(cReq.Name);
            orderId = rightpad(orderId,15);
            headerSting = headerSting+orderId;  
        }else
        {
            headerSting = headerSting+rightpad('',15);
        }
        //Order Type                         3 chars             space filled        “OTG”                Constant -"OTG"
        string orderType = 'OTG';
        headerSting = headerSting+orderType;
        
        //Pref Delivery Date                 8 numbers           format yyyymmdd     “20100810”           Date - Always Tomorrow
        Date deliveryDt = system.today()+1;
        string dateString;
        dateString = deliveryDt.format().substring(6,10)+deliveryDt.format().substring(3,5)+deliveryDt.format().substring(0,2);
        headerSting =headerSting+dateString;
        
        //Patch ID                           5 chars             space filled        “13010” or “     “   Consumables_Requests__c.Callidus_Patch_Id__c
        if(cReq.Callidus_Patch_Id__c!=null)
        {
            string patchId = string.valueof(cReq.Callidus_Patch_Id__c);
            patchId = rightpad(patchId,5);
            headerSting = headerSting+patchId;  
        }else
        {
            headerSting = null;
            return null;
        }
        //Market Code                        4 chars             space filled        “BGAS”               Constant - "BGAS"
        string marketCode = 'BGAS';
        headerSting =headerSting+marketCode;
        
        //Sales Product Type                 4 numbers           zero filled         “1234”               Constant -"0000"
        string productType = '0000';
        headerSting = headerSting+productType;
        //End Customer Name                  36*5 = 180 chars            Space filled         Not Mandatory       180 Blank Spaces
        string empDetails = '';
        empDetails = leftpad(empDetails,80);
        headerSting = headerSting+empDetails + leftpad('',80)+leftpad('',20);
        
        return headerSting;
    } 
    
    // This generates the Child string  from consumble items under a particular Consumable request. See the Top Header comments for better undersatnding.
    public string createChildString(string headerSting, Consumable_Items__c cItem, integer itemNumber)
    {
        // Product Line Number                4 numbers           zero filled          “0001”              sequential Number for each line item
        string childString;
        if(itemNumber!=null)
        {
            string itemString = string.valueof(itemNumber);
            itemString = padChar(itemString,4,'0',true);
            headerSting = headerSting+itemString;   
        }else 
        {
            headerSting = headerSting + padChar('0',4,'0',true);
        }
        //Product Code                       6 chars             space filled         “123456”            Consumable_Items__c.Product_Code__c
        if(cItem.Product_Code__c!=null)
        {
            string productCode = string.valueof(cItem.Product_Code__c);
            productCode = rightpad(productCode,6);
            headerSting = headerSting+productCode;  
        }else
        {
            return null;
        }
        if(cItem.Quantity__c!=null)
        {
            string quantity = string.valueof(cItem.Quantity__c);
            quantity = padChar(quantity,6,'0',true);
            headerSting = headerSting+quantity; 
        }else
        {
            headerSting = headerSting + padChar('0',6,'0',true);
        }
        
        headerSting = headerSting+ '000';
        
        return headerSting;
    }
    // This method will pad required number of specfic character to a given string.
    public string padChar(string word, integer length, string charcter, boolean direction )
    {
        integer diff =  length - word.length();
                
        if(diff>0 && direction == true)
        {
            for(integer i=0;i< diff ;i++)
            {
                word = charcter+word;
            }
            return word;
        }else if(diff>0 && direction == false)
        {
            for(integer i=0;i< diff ;i++)
            {
                word = word+charcter;
            }
            return word;
        }else if(diff<0)
        {
            return word.substring(0,length);
        }else{
            return word;
        }
        
    }
    global void finish(Database.BatchableContext bc){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
          if(a.TotalJobItems>0)
          {
            date todayDate = system.today();
            
            list<Document> dList = [Select Name, Id, FolderId, Body From Document d where FolderId= :system.label.Consumable_Folder_Id and CreatedDate >= :todayDate];
            string finalText;
            string FinalExcel;
            string fileName;
            string ExcelName;
            for(Document d:dList)
            {
                if(finalText !=null && !d.Name.contains('excel'))
                {
                    finalText += d.Body.tostring();
                    fileName = d.Name;
                }else if(!d.Name.contains('excel'))
                {
                    finalText = d.Body.tostring();
                    fileName = d.Name;
                }else if(FinalExcel !=null && d.Name.contains('.csv'))
                {
                    FinalExcel += d.Body.tostring();
                    ExcelName = d.Name;
                }else if(d.Name.contains('.csv'))
                {
                    FinalExcel = d.Body.tostring();
                    ExcelName = d.Name;
                }
            }
            
            
            Messaging.EmailFileAttachment txtAtt = new Messaging.EmailFileAttachment();
            if(finalText!=null)
            {
            blob textBlob = Blob.valueOf( finalText );
            txtAtt.setFileName(fileName);
            txtAtt.setBody(textBlob); 
            }
            Messaging.EmailFileAttachment csvAtt = new Messaging.EmailFileAttachment();
            if(FinalExcel!=null)
            {
            blob csvBlob = Blob.valueOf( FinalExcel );
            csvAtt.setFileName(ExcelName);
            csvAtt.setBody(csvBlob); 
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = system.label.Callidus_Batch_Emails.split(',');
            String subject = 'CHI orders for Callidus for : '+System.now();
            email.setSubject( subject );
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('PFA for Callidus Orders');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {txtAtt,csvAtt});
            
            if(!test.isRunningTest())
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            
           
            delete dlist;
            
          }
          else if(a.TotalJobItems == 0)
          {
            createEmail.CretaeSendTextEmail(system.label.Callidus_Batch_Emails.split(','), 'No Ordres were Requested.', 'Zero CHI orders for Callidus this day.');
          }
          if(a.NumberOfErrors>0)
          {
            createEmail.CretaeSendTextEmail(new list<string>{'ashoknaglikar@hotmail.co.uk'}, 'Error in Callidus file', 'Error in Callidus file');
          }
       
    }
    
    
}