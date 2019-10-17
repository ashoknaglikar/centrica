/*
Creator: Cognizant 01/12/2011
Description : This class used to generate Text file for dailler and a Excel file for Salesforce team by Looking into Appointments which are happened, and there are no sold quote.

The file structure should consist of the following
*****************************************************************************************************************************************
Field                              Size                Padding              Salesforce Field Used/data Used
**************************** Consumable Requests*****************************************************************************************
lead Number                      20 chars            space filled           app.CHI_Lead_No__c
Customer Name                    125 chars           space filled           app.Customer_Greeting_Name__c
Address                          255 chars           space filled           app.First_Address_Line__c+ app.Billing_Street__c + app.Billing_City__c 
Phone                            20 chars            space filled           app.Contact_Phone__c
WorkPhone                        20 chars            space filled           app.Contact_Work_Phone__c
Mobile                           20 chars            space filled           app.Contact_Mobile__c
Phone                            20 chars            space filled           app.Contact_Phone__c
Campign Name                     30 chars            Space filled           app.Opportunity__r.Campaign_Name__c
*/
global class sendDiallerDetails implements Database.Batchable<sObject> {
    // fetch all the happened appointments from all the leads seven day before and generate dailler file.
    
    public static void createDiallerBatch()
    {
        sendDiallerDetails objDialler = new sendDiallerDetails();
        ID batchprocessid = Database.executeBatch(objDialler);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        date sevenDaysBefore;
        if( system.label.Dialler_Detail_Date == 'code')
        {
            sevenDaysBefore = system.today()-7;
        }else
        {
            sevenDaysBefore = date.valueOf(system.label.Dialler_Detail_Date);  
        }
        //Integer DayOfYear = sevenDaysBefore.dayOfYear();
        string query = 'Select Opportunity__r.closeDate__c, Opportunity__r.Campaign_Name__c, Opportunity__r.Account.Primary_Contact__r.MailingPostalCode, Opportunity__r.Account.Primary_Contact__r.Salutation,Opportunity__r.Account.Primary_Contact__r.LastName,';
        query += 'Opportunity__r.Account.Primary_Contact__r.OtherPhone, Opportunity__r.Account.Primary_Contact__r.Phone, Opportunity__r.Account.Primary_Contact__r.MobilePhone, Opportunity__r.Account.Primary_Contact__r.HomePhone,';
        query += 'Opportunity__r.CHI_Lead_Id__c, Opportunity__r.Account.Primary_Contact__r.MailingStreet, Opportunity__r.Account.Primary_Contact__r.MailingCity,bmStatusReason__c From BigMachines_Quote__c  where stage__c = \'Quote Finalised - Not Accepted\' and sFDCApptStatus__c = \'Happened\'and submittedDate_quote__c =:sevenDaysBefore and Opportunity__r.Sold_Quote_Received_Date__c = null and Opportunity__c != null';
        return Database.getQueryLocator(query);
          
    }
    global void execute(Database.BatchableContext BC, List<sObject> BMs)
    {
        
        Map<Id,BigMachines_Quote__c> oppBMMap = new map<Id,BigMachines_Quote__c>();
         for(sObject sObj : BMs)
         {
            BigMachines_Quote__c b = (BigMachines_Quote__c)sObj;
            
            if(!oppBMMap.containskey(b.Opportunity__c))
            {
                oppBMMap.put(b.Opportunity__c,b);
            }
         }
         createTextFileForDialler(oppBMMap.values(),'CHI_DIALLER');
    }
    
    //static string excelHeader = 'Lead Number, Title & Customer Name, Address,Home Number,Work Number,Mobile Number ,other , Campaign Id\n';
    //static string excelBody = excelHeader;
    public static boolean createTextFileForDialler(list<BigMachines_Quote__c> BMList, string fileName)
    {
        string textBody ;
        for(BigMachines_Quote__c bm : BMList)
        {
            if((bm.Opportunity__r.Account.Primary_Contact__r.Phone == null || bm.Opportunity__r.Account.Primary_Contact__r.Phone == '') && (bm.Opportunity__r.Account.Primary_Contact__r.OtherPhone == null || bm.Opportunity__r.Account.Primary_Contact__r.OtherPhone == '')&& (bm.Opportunity__r.Account.Primary_Contact__r.MobilePhone == null || bm.Opportunity__r.Account.Primary_Contact__r.MobilePhone == ''))
            continue;
            if(textBody != null)
            {
                //textBody +=  createLineRecord(bm.Opportunity__r.CHI_Lead_Id__c,bm.Opportunity__r.Account.Primary_Contact__r.Salutation+' '+bm.Opportunity__r.Account.Primary_Contact__r.LastName,bm.Opportunity__r.Account.Primary_Contact__r.MailingCity,bm.Opportunity__r.Account.Primary_Contact__r.MailingStreet,bm.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode,bm.Opportunity__r.Account.Primary_Contact__r.Phone,bm.Opportunity__r.Account.Primary_Contact__r.OtherPhone,bm.Opportunity__r.Account.Primary_Contact__r.MobilePhone,bm.bmStatusReason__c);
                textBody +=  createLineRecord(bm.Opportunity__r.CHI_Lead_Id__c,bm.Opportunity__r.Account.Primary_Contact__r.Salutation+' '+bm.Opportunity__r.Account.Primary_Contact__r.LastName,bm.Opportunity__r.Account.Primary_Contact__r.MailingCity,bm.Opportunity__r.Account.Primary_Contact__r.MailingStreet,bm.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode,returnNumbers(String.valueOf(bm.Opportunity__r.Account.Primary_Contact__r.Phone)),returnNumbers(String.valueOf(bm.Opportunity__r.Account.Primary_Contact__r.OtherPhone)),returnNumbers(String.valueOf(bm.Opportunity__r.Account.Primary_Contact__r.MobilePhone)),bm.bmStatusReason__c);
            }else
            {
                //textBody = createLineRecord(bm.Opportunity__r.CHI_Lead_Id__c,bm.Opportunity__r.Account.Primary_Contact__r.Salutation+' '+bm.Opportunity__r.Account.Primary_Contact__r.LastName,bm.Opportunity__r.Account.Primary_Contact__r.MailingCity,bm.Opportunity__r.Account.Primary_Contact__r.MailingStreet,bm.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode,bm.Opportunity__r.Account.Primary_Contact__r.Phone,bm.Opportunity__r.Account.Primary_Contact__r.OtherPhone,bm.Opportunity__r.Account.Primary_Contact__r.MobilePhone,bm.bmStatusReason__c);
                textBody =  createLineRecord(bm.Opportunity__r.CHI_Lead_Id__c,bm.Opportunity__r.Account.Primary_Contact__r.Salutation+' '+bm.Opportunity__r.Account.Primary_Contact__r.LastName,bm.Opportunity__r.Account.Primary_Contact__r.MailingCity,bm.Opportunity__r.Account.Primary_Contact__r.MailingStreet,bm.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode,returnNumbers(String.valueOf(bm.Opportunity__r.Account.Primary_Contact__r.Phone)),returnNumbers(String.valueOf(bm.Opportunity__r.Account.Primary_Contact__r.OtherPhone)),returnNumbers(String.valueOf(bm.Opportunity__r.Account.Primary_Contact__r.MobilePhone)),bm.bmStatusReason__c);
            }
        }
        String[] str = new String[]{}; 
        
        if(textBody != null)
        {
            string finalTextBody = string.format(textBody,str);
        
            blob textBlob = Blob.valueOf( finalTextBody );
           
            Document d = new Document(); 
            d.Name = fileName;
            d.FolderId = system.label.Dailler_Folder_Id;
            d.Body = textBlob;
            d.ContentType = 'text/plain';
            d.Type = 'txt';
            insert d;
            return true;
        }
        else
        {
            return false;
        }
        
    }
    // this generates the sigle line required for dailler in dialler specific format.
     public static string createLineRecord(string ChiLeadNo, string custDetails, string BillingCity, string BillingStreet , string postCode, string Phone, string WorkPhone, string Mobile, string bmStatusReason)
    {
        sendConsumableRequests sendObj= new sendConsumableRequests();
        string lineRecord =  sendObj.rightpad(ChiLeadNo,30);
        //sendDiallerDetails.excelBody += ChiLeadNo+',';
        if(custDetails!=null)
        {
         lineRecord += (sendObj.rightpad(custDetails,100)+ sendObj.rightpad('',25)).substring(0,125);
         //sendDiallerDetails.excelBody += custDetails+',';
        }else
        {
            lineRecord +=  sendObj.rightpad('',100)+ sendObj.rightpad('',25);
            //sendDiallerDetails.excelBody += ',';
        }
        string Address;
        if(postCode!=null && BillingStreet!=null && BillingCity!=null)
        {
            Address = BillingStreet ;
            list<string> strList = new list<String>();
            strList = Address.split('\n');
            Address = '';
            for(string s : strList)
            {
                Address += s.trim()+'';
            }
            
            Address= Address.trim();
            Address += ' '+ BillingCity+' '+postCode ;
            //sendDiallerDetails.excelBody += Address.replaceall(',','  ')+',';
        } else
        {
            Address = '';
            //sendDiallerDetails.excelBody += ',';  
        }
        string spaceStr = '';
        integer noOfLoop;
        if(Address.length() > 255)
        {   
            Address = Address.substring(0,255);
        }else{
            
            noOfLoop = (600-Address.length()/255);
        
            for(integer i=1; i<=noOfLoop;i++ )
            {
                spaceStr  = spaceStr + sendObj.rightpad('',100);
            }
        }
        Address = (Address + spaceStr).substring(0,255);
        
        lineRecord += Address; 
        if(Phone != null)
        {
            lineRecord += sendObj.rightpad(Phone,20);
            //sendDiallerDetails.excelBody += Phone+',';
        }else
        {
            lineRecord +=  sendObj.rightpad('',20);
            //sendDiallerDetails.excelBody +=',';
        }
        
        if(WorkPhone != null)
        {
            lineRecord += sendObj.rightpad(WorkPhone,20);
            //sendDiallerDetails.excelBody += WorkPhone+',';
        }else
        {
            lineRecord += sendObj.rightpad('',20);
            //sendDiallerDetails.excelBody +=',';
        }
        
        if(Mobile != null)
        {
            lineRecord += sendObj.rightpad(Mobile,20);
            //sendDiallerDetails.excelBody += Mobile+',';
        }else
        {
            lineRecord += sendObj.rightpad('',20);
            //sendDiallerDetails.excelBody += ',';
        }
        
        if(Phone != null)
        {
            lineRecord += sendObj.rightpad(Phone,20);
            //sendDiallerDetails.excelBody += Phone+',';
        }else
        {
            lineRecord += sendObj.rightpad('',20);
            //sendDiallerDetails.excelBody += ',';
        }
        
        if(bmStatusReason != null)
        {
            lineRecord += +(sendObj.rightpad(bmStatusReason,30)).substring(0,30);
            //sendDiallerDetails.excelBody += bmStatusReason +',';
        }else
        {
            lineRecord += sendObj.rightpad('',30);
            //sendDiallerDetails.excelBody += ',';
        }
        lineRecord += '\n';
        //sendDiallerDetails.excelBody += '\n';
        return lineRecord;
    }
    
    // ++ Added for CR#889 start
    public static boolean createTextFileForPreCallDialler(list<Appointment__c> appointList, string fileName)
    {
        string textBody  ;
        for(Appointment__c appoint : appointList)
        {
            if(appoint.Contact_Mobile__c == null && appoint.Contact_Home_Phone__c == null)
            {
                continue;
            }
            if(textBody != null)
            {
                //textBody += createPreCallTextFile(appoint.CHI_Lead_No__c , appoint.Customer_Greeting_Name__c , string.valueof(appoint.Visit_Date__c.format()) , appoint.Contact_Mobile__c , appoint.Contact_Home_Phone__c , appoint.Pre_Called__c);
                textBody += createPreCallTextFile(appoint.CHI_Lead_No__c , appoint.Customer_Greeting_Name__c , string.valueof(appoint.Visit_Date__c.format()) , returnNumbers(String.valueOf(appoint.Contact_Mobile__c)) , returnNumbers(String.valueOf(appoint.Contact_Home_Phone__c)) , appoint.Pre_Called__c);
            }
            else
            {
                //textBody = createPreCallTextFile(appoint.CHI_Lead_No__c , appoint.Customer_Greeting_Name__c , string.valueof(appoint.Visit_Date__c.format()) , appoint.Contact_Mobile__c , appoint.Contact_Home_Phone__c , appoint.Pre_Called__c);
                textBody = createPreCallTextFile(appoint.CHI_Lead_No__c , appoint.Customer_Greeting_Name__c , string.valueof(appoint.Visit_Date__c.format()) , returnNumbers(String.valueOf(appoint.Contact_Mobile__c)) , returnNumbers(String.valueOf(appoint.Contact_Home_Phone__c)) , appoint.Pre_Called__c);
            }
        }
        String[] str = new String[]{}; 
        if(textBody != null)
        {
            string finalTextBody = string.format(textBody,str);
        
            blob textBlob = Blob.valueOf( finalTextBody );
           
            Document d = new Document(); 
            d.Name = fileName;
            d.FolderId = system.label.Dailler_Folder_Id;
            d.Body = textBlob;
            d.ContentType = 'text/plain';
            d.Type = 'txt';
            insert d;
            return true;
        }
        else
        {
            return false;
        }
        
    }
    public static string createPreCallTextFile(string CHILeadNo , string customerName , string visitDate , string mobile , string homePhone , string preCalled)
    {
        string preCallFile = '';
        string leadNo = '';
        string cusomer = '';
        string visit = '';
        string mobilePhone = '';
        string phone = '';
        string preCall = '';
        if(CHILeadNo != null)
        {
            leadNo = leadNo + CHILeadNo + leadNo.rightPad(30-(CHILeadNo.length()));
        }
        else
        {
            leadNo = leadNo.rightPad(30);
        }
        if(customerName != null)
        {
            cusomer = cusomer + customerName + cusomer.rightPad(125-(customerName.length()));
        }
        else
        {
            cusomer = cusomer.rightPad(125);
        }
        if(visitDate != null)
        {
            visit = visit + visitDate + visit.rightPad(255-(visitDate.length()));
        }
        else
        {
            visit = visit.rightPad(255);
        }
        if(mobile != null)
        {
            mobilePhone = mobilePhone + mobile + mobilePhone.rightPad(20-(mobile.length()));
        }
        else
        {
            mobilePhone = mobilePhone.rightPad(20);
        }
        if(homePhone != null)
        {
            phone = phone + homePhone + phone.rightPad(60-(homePhone.length()));
        }
        else
        {
            phone = phone.rightPad(60);
        }
        if(preCalled != null)
        {
            preCall = preCall + preCalled + preCall.rightPad(25-(preCalled.length()));
        }
        else
        {
            preCall = preCall + Utilities.defaultPreCallStatus + preCall.rightPad(25-(Utilities.defaultPreCallStatus.length()));
            //preCall = preCall.rightPad(25);
        }
        preCallFile = leadNo + cusomer + visit + mobilePhone + phone + preCall;
        preCallFile += '\n';
        return preCallFile;
    }
    public static String returnNumbers(String phoneNumber)
    {
        String validPhone;
        if(phoneNumber != null)
        {
            String phone = phoneNumber;
            phone = phone.deleteWhitespace();
            List<String> charList = phone.splitByCharacterType();
            for(String tmpString : charList)
            {
                if(tmpString.isNumeric() && tmpString.length() > 8)
                {
                    validPhone = tmpString;
                }
            }
            return validPhone;
        }
        else
        {
            return '';
        }
        
    }
    // -- Added for CR#889 end  
    global void finish(Database.BatchableContext bc){
          AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
          if(a.TotalJobItems == 0)
          {
            CreateEmail.CretaeSendTextEmail(system.label.Dialler_Mails.split(','), 'No Contact details present on this day.', 'No Leads for Dialler');
          }else{
            date todayDate = system.today();
            list<Document> dList = [Select Name, Id, FolderId, Body From Document d where FolderId= :system.label.Dailler_Folder_Id and CreatedDate >= :todayDate and name = 'CHI_DIALLER'];
            string finalText;
            for(Document d:dList)
            {
                if(finalText !=null)
                {
                    finalText += d.Body.tostring();
                }else
                {
                    finalText = d.Body.tostring();
                }
            }
            delete dlist;
            string todayTime = system.now().format();
            string fileName = todayTime.substring(0,2)+todayTime.substring(3,5)+todayTime.substring(8,10);
            Messaging.EmailFileAttachment diallerAttc = new Messaging.EmailFileAttachment();
            blob textBlob = Blob.valueOf( finalText );
            fileName = 'CHI_DIALLER'+fileName+'.txt';
            diallerAttc.setFileName(fileName);
            diallerAttc.setBody(textBlob); 
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = system.label.Dialler_Mails.split(',');
            String subject = 'Dialler information for: '+System.now();
            email.setSubject( subject );
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('PFA for Dialler information');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {diallerAttc});
            Messaging.SendEmailResult [] mssg = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
          }
          if(a.NumberOfErrors>0)
          {
            createEmail.CretaeSendTextEmail(new list<string>{'ashoknaglikar@hotmail.co.uk'}, 'Error in Dailler file', 'Error in Dailler file');
          }
          
       
    }
    
}