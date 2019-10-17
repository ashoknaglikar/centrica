/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 
 Autor : Cognizant Jan 2012
 Description : Please refer to DiallerPageCont.cls for all the detailed comments and use of this Email service.
 There are two cases in this email service.
 Case 1) If body = end then this email service fetches the all the required files and creates an email with attachment and sends email to requestor.
 case 2) if body != end then it should have some more record to process, it will fetch the query and processes the dialler fiel explained in DiallerPageCont.cls
 
 */
global class diallerEmailService implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        DiallerPageCont dCont = new DiallerPageCont();
        // ++ Added for CR#889 start
        DiallerPreCallController preCall = new DiallerPreCallController();
        // -- Added for CR#889 end
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        string query = email.plainTextBody;
        string subject = email.subject;
        list<string> fileProp = subject.split('#');
        string filename1 = fileProp[0];
        if(fileName1.startswith('Sandbox'))
            {
                filename1 = fileName1.substring(9,fileName1.length());
            }
        
        if(query!= 'end')
        {
        	date submittedDate;
        	string CHILeadNum ;
            string fileName;
            if(subject.contains('PRE_CALL'))
            {
            	CHILeadNum = preCall.queryData(query, filename1);
            	fileName =filename1+ '#'+ fileProp[1]+'#'+CHILeadNum;
            }
            else
            {
            	CHILeadNum =dCont.queryData(query, filename1,submittedDate);
            	submittedDate = date.valueOf(fileProp[3]);
            	fileName =filename1+ '#'+ fileProp[1]+'#'+CHILeadNum+'#'+fileProp[3]; 
            }  
            //string fileName =filename1+ '#'+ fileProp[1]+'#'+CHILeadNum+'#'+fileProp[3]; 
           
            IF(CHILeadNum!=null)
            {
                
               query= query.replace(fileProp[2], CHILeadNum);
                
            }
            else
            {
                query = 'end';
            }
            
            CreateEmail.CretaeSendTextEmail(new list<string>{system.label.DiallerEmailService}, query, fileName);
       }
        else
        {
            date todayDate = system.today();
            
            list<Document> dList = [Select Name, Id, FolderId, Body From Document d where FolderId= :system.label.Dailler_Folder_Id and CreatedDate >= :todayDate and name = :filename1];
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
            if(finalText != null)
            {
            	blob textBlob = Blob.valueOf( finalText );
            	if(subject.contains('PRE_CALL'))
	            {
	            	fileName = 'CHI_DIALLER_PRE_CALL'+fileName+'.txt';
	            }
	            else
	            {
	            	fileName = 'CHI_DIALLER'+fileName+'.txt';
	            }
	            diallerAttc.setFileName(fileName);
	            diallerAttc.setBody(textBlob); 
	            Messaging.SingleEmailMessage sendemail = new Messaging.SingleEmailMessage();
	            String[] toAddresses = fileProp[1].split(',');
	            String sendSubject = 'Dialler information for: '+System.now();
	            sendemail.setSubject( sendSubject );
	            sendemail.setToAddresses( toAddresses );
	            sendemail.setPlainTextBody('PFA for Dialler information');
	            sendemail.setFileAttachments(new Messaging.EmailFileAttachment[] {diallerAttc});
	            Messaging.SendEmailResult [] mssg = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sendemail});
            }
            
            
            
            
        }
        
        return result;
    }
}