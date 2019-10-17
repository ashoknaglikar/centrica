public class EmailCEQPDFController {
    
    
    public id CEQID;
    public Attachment a;
    public List<Attachment> pic;
    public String LeadNumber;
    
    
    public EmailCEQPDFController(){ 
    }
    
    public void SavePDFAttachment(id AttachmentParentID){
        
            system.debug('Entered SAVEPDFAttachment');  
            PageReference pdf = new PageReference('/apex/CEQPDFPage?CEQID='+ CEQID+'&LeadNum='+LeadNumber);
         
            Blob body ;
                if(Test.isRunningTest())
            
                    body=Blob.valueOf('UNIT.TEST');
                else
                    body=pdf.getContent();
                
            Attachment attachment = new Attachment();
            attachment.Body = body;
            attachment.Name = String.valueOf('AuditLog.pdf');
            attachment.ParentId = CEQID; 
            insert attachment;
            
        } 
    
    
    Utilities util = new Utilities();
    
    public PageReference sendEmail(){
        
        system.debug('Entered SendMail');
        
        try {
          CEQID = ApexPages.currentPage().getParameters().get('CEQID');
          LeadNumber = ApexPages.currentPage().getParameters().get('LeadNum');
          PageReference returnPage = new PageReference('/'+CEQID); // Send the user back to the CEQ record
          system.debug('Return address = '+returnPage);
          system.debug('Record Header ID = '+CEQID);
          system.debug('##Lead Number = '+LeadNumber);

         try{        
          a = [SELECT id,body,name FROM Attachment WHERE parentId=:CEQID AND name='AuditLog.pdf' LIMIT 1];
         } catch(Exception  e){
             system.debug(e);
         }
          
          if (a == null){
              system.debug('A = Null path');
              SavePDFAttachment(CEQID);
              a = [SELECT id,body,name FROM Attachment WHERE parentId=:CEQID AND name='AuditLog.pdf' LIMIT 1];
              system.debug('Attachment created');
              system.debug('Attachment name : ' +a.name);
          }
          List<String> ToAddresses = new List<String>();
          system.debug('email Address: '+ToAddresses);
          ToAddresses.add(userinfo.getUserEmail());
          
          
              // create email attachment
             /* pic = [SELECT id,body,name FROM Attachment WHERE parentId=:CEQID];
              list<Messaging.EmailFileAttachment> attachmentList = new list<Messaging.EmailFileAttachment>();
              
              for(attachment a: pic)
              {
                  Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                 efa.setBody(a.body);
                  efa.setFileName(a.name);
                  attachmentList.add(efa);
              }
              
              */
              //change By Ashok G -- starts      
                  String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
                  String url =  salesforceHost+'/'+CEQID;
                     
                  Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                  efa.setBody(a.body);
                  efa.setFileName(a.name);
              //Change End
              //create email message
              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
              //email.setFileAttachments(attachmentList); 
              email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa}); // set only AuditLog file
              email.setSubject('Service & Standard Visit - '+ LeadNumber);
              email.setPlainTextBody('Dear '+userinfo.getName()+',\n \nPlease find attached SSV audit.\n'+url+' \n \nThanks,\n British Gas\n\n Do not respond. This is the automated email.');
              email.setToAddresses( ToAddresses );
              
              OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@britishgas.co.uk'];
              if (owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
              }
              
              Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

              return returnPage;

        }
        catch(Exception e){
            util.setErrorMsg(true, e.getMessage());
            return null;
        }
    }
    
    

}