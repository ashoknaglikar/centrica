public class Sendmail{
public static void createMail()
{
  try
    {
       List<EmailTemplate> emailtemplatelist = new List<EmailTemplate>();
      // for(EmailTemplate e : [select Id from EmailTemplate where name like :'Job status Notification'+'%'])
       for(EmailTemplate e : [select Id from EmailTemplate where DeveloperName = 'Job_Status_Notification'])
        { 
         emailtemplatelist.add(e);
         System.debug('Template ID is => ' + e.ID); 
       } 
          
       /*List<Installer__c> UsrID = [Select User__r.ID from Installer__c where Is_Ready__c = 1];
       Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage(); 
       List<ID> MailID = new List<ID>();
       Set<ID> TempMailID  = new Set<ID>();
       
       for(Installer__c Ins:UsrID){
       System.debug('Initial ID List is => ' + Ins.User__r.ID);
       } 
       */
       Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage(); 
       List<ID> MailID = new List<ID>();
       Set<ID> TempMailID  = new Set<ID>();
       for(Installer__c Ins: [Select User__r.ID from Installer__c where Is_Ready__c = 1])
       {
	       TempMailID.add(Ins.User__r.ID);
	       System.debug('IN Set Mail ID is => ' + Ins.User__r.ID); 
       }    
        
           for(ID Insstr:TempMailID){
           MailID.add(Insstr);
           System.debug('Final Mail ID list Mail ID is => ' + Insstr); 
           }
                                           
           //mail.setSubject('Jobs Notification');
           //mail.setWhatIds(MailID);
           mail.setTargetObjectIds(MailID);
           mail.setSenderDisplayName('Salesforce Support');
           mail.setBccSender(false);
           mail.setUseSignature(false);
           mail.setSaveAsActivity(false);
           mail.setTemplateId(emailtemplatelist[0].ID);
                    
           Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });
                    
          }
 catch(Exception e){ 
      System.debug('Exception is => ' + e.getMessage());
    }
  }
  
  // Test Method for this class
  
  /*
  Public static testMethod void Sendmail_Test() { 
  Sendmail sd = new Sendmail();
  createmail();
  }
  */
 }