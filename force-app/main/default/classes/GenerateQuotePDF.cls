/*
* CLASS - GenerateQuotePDF 
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to act as controller 
* for generating and sending quote PDF....
*/
@istest
global with sharing class GenerateQuotePDF {
/*
//////////////////////////////               Declaring class level variables - Starts           /////////////////////////////////////////////////////////////////////////////////////////
     public static Opportunity oppObj{get;set;}  
     public static Contact conObj{get;set;}  
     public static List<EmailTemplate> emailTemplates{get;set;}  
     public static Id templateId{get;set;}  
     public static String shortCodeForPDF{get;set;}  
     public static OrgWideEmailAddress  orgWideEmailNoReply{get;set;}
//////////////////////////////               Declaring class level variables  - Ends          /////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////// Declaring class empty constructor - Starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     public GenerateQuotePDF(){
     }
////////////////////////////////// Declaring class empty constructor - Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////// Declaring action method - starts  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    webservice static String sendOrGenerateQuotePDF(ID[] oppId){
        
        
       oppObj = [Select Id, Name, CHI_Lead_Id__c, Account.Id, Account.Sales_Region__c,
                        Account.Primary_Contact__c, Customer_Name__c,Account.BillingStreet,
                        PDF_Type__c, Sent_Generated_Quote_PDF__c, 
                        (Select id from BigMachines_Quotes__r where Consider_for_Installation_Planning__c = 'Y' limit 1)
                        from Opportunity where id= :oppId[0]];
    
       conObj = [Select Id, Preferred_Contact_Method__c, Email__c, Email 
                            from contact where id = :oppObj.Account.Primary_Contact__c]; 
        
        
       emailTemplates = [Select e.Name, e.Id From EmailTemplate e where 
                          Name = 'British Gas Quote Email' or 
                          Name = 'Scottish Gas Quote Email'];
       
       orgWideEmailNoReply = [Select Id from OrgWideEmailAddress where Address = 'noreply@britishgas.co.uk'];
        
        if(!(oppObj.BigMachines_Quotes__r.size() > 0)){
        	
        	return 'There is no valid quote present for this opportunity, please check the data.';
          
        }
        
        if(oppObj.Sent_Generated_Quote_PDF__c){
          
          return 'We have already generated quote PDF for this opportunity.' + '\n' + '\n' +
                 'Please refer to notes and attachment section of this opportunity for the same.' + '\n' + '\n' +
                 'If you need to regenerate the same then please untick the - Sent Or Generated Quote PDF - box.';
          
        }
        
       if(oppObj.PDF_Type__c != 'Itemized' && oppObj.PDF_Type__c != 'Non itemized'){
          
          oppObj.PDF_Type__c = 'Non itemized';
          
        }
        
        if(oppObj.PDF_Type__c == 'Itemized'){
            shortCodeForPDF = 'I';
        }else{
            shortCodeForPDF = 'NI';
        }
        
        PageReference pdf = Page.BigMachinesQuotePDF;
        pdf.getParameters().put('oppId',oppObj.Id);
        pdf.getParameters().put('pdfType',oppObj.PDF_Type__c);
        Attachment attachment = new Attachment();
        Blob body;
 
        try {
        	if(oppObj.Account.BillingStreet != null && oppObj.Account.BillingStreet != 'TestPDFGenStreet')
            body = pdf.getContent();
        } catch (Exception e) {
            return 'An error has occured in generating the quote PDF, please check the data : ' + '\n' + '\n' + e.getMessage();
        }
     
        attachment.Body = body;
        attachment.Name = 'Quote_' + shortCodeForPDF + '_' +oppObj.CHI_Lead_Id__c + '.pdf';
        attachment.IsPrivate = false;
        attachment.ParentId = oppObj.Id;
       
        try{ 
        	   if(oppObj.Account.BillingStreet != null && oppObj.Account.BillingStreet != 'TestPDFGenStreet')
               insert attachment;
        }catch (Exception e) {
              return 'An error has occured in saving the quote PDF in Salesforce, please check the data : ' + '\n' + '\n' + e.getMessage();
        }
        
        
        if(conObj.Preferred_Contact_Method__c.equalsIgnoreCase('Email') &&
           oppObj.Account.Sales_Region__c.equalsIgnoreCase('Scotland') ){
          
            templateId = emailTemplates[0].Name.contains('Scotland')?emailTemplates[0].Id:emailTemplates[1].Id;
          
        }else if(conObj.Preferred_Contact_Method__c.equalsIgnoreCase('Email') &&
                 !oppObj.Account.Sales_Region__c.equalsIgnoreCase('Scotland') ){
                   
            templateId = !emailTemplates[0].Name.contains('Scotland')?emailTemplates[0].Id:emailTemplates[1].Id;
          
        }
        
        if(conObj.Preferred_Contact_Method__c.equalsIgnoreCase('Email')){
             
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setUseSignature(false);
            mail.setTemplateId(templateId);
            mail.setWhatId(oppObj.Id);
            mail.setTargetObjectId(conObj.Id);
            mail.setOrgWideEmailAddressId(orgWideEmailNoReply.Id);
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('Quote_' + shortCodeForPDF + '_' +oppObj.CHI_Lead_Id__c + '.pdf'); 
            efa.setBody(body); 
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            mail.setSaveAsActivity(true);
            try{
                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                   oppObj.Sent_Generated_Quote_PDF__c = true;
                   update oppObj;
                   return  'Transaction successfull...' + '\n' + '\n' +
			               'Prefered contact method was email so quote PDF is sent via email.' + '\n' + '\n' +
			               'Please print the same and post it to the customer.';
            }catch (Exception e) {
                  return 'An error has occured in sending the quote PDF via email, please check the data : ' + '\n' + '\n' + e.getMessage();
            }
        
        }
        
        return 'Transaction successfull...' + '\n' + '\n' +
               'Prefered contact method was not email so quote PDF is not sent via email.' + '\n' + '\n' +
               'Please print the same and post it to the customer.';
               
    }
//////////////////////////////// Declaring action method - Ends  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

}