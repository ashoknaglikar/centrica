public class NovoSmartController{
 
 public Employee_NOVO_Log__c header{get;set;} 
 public NOVO_Activities__c emailHeader1{get;set;} 
 public List<NovoWrapper> theQuestions{get;set;}
 public Boolean NovoAct{get;set;} 
 public Boolean NovoActivity{get;set;} 
 public boolean firstTime{get;set;}
 public boolean attachFile{get;set;}
 public boolean pickupUser{get;set;}
 public Integer val{get;set;}
 public Integer numberOfRowToRemove{ get; set; }
 public integer signsuccess{get;set;}
 public ID EmpId{get;set;} 
 @TestVisible Utilities util = new Utilities();
 public string email{get;set;}
 public string attachementParent {get;set;}
 public string errorMsg{get;set;}
 public boolean signSucessRender{get;set;}
 public string emailString{get;set;}
 @TestVisible string reqFrom;
 string view;
 string sfUser;
 string edit;
 @TestVisible Boolean viewPdf;
 public List<EmailWrapper> emailWrapList{get;set;}
 
 public NovoSmartController(ApexPages.StandardController controller)
 {
   NovoAct = False;
   firstTime = True;
   NovoActivity=true;
   pickupUser=false;
   attachFile=true;
   signSucessRender = False;
   emailWrapList=new List<EmailWrapper>();
   theQuestions = new List<NovoWrapper>();
   header = new Employee_NOVO_Log__c();   
   emailHeader1 = new NOVO_Activities__c();   
   set<id> ActIds = new set<id>();
   signsuccess=0;
   if(ApexPages.currentPage().getParameters().get('signSuccess')=='1'){
            signsuccess = 1;
            signSucessRender = True;
            CallSendPdf(ApexPages.currentPage().getParameters().get('headerID'));
   }
   else if(ApexPages.currentPage().getParameters().get('signSuccess')=='0'){
            signsuccess = 0;
   }else if(ApexPages.currentPage().getParameters().get('signSuccess')=='2'){
            signsuccess = 2;
            signSucessRender = False;
   }
   
   email = ApexPages.currentPage().getParameters().get('email'); 
   sfUser = ApexPages.currentPage().getParameters().get('sfUser')!=null?ApexPages.currentPage().getParameters().get('sfUser'):'';
   view = ApexPages.currentPage().getParameters().get('view');
   edit = ApexPages.currentPage().getParameters().get('e');
   reqFrom = ApexPages.currentPage().getParameters().get('req');
   viewPdf = ApexPages.currentpage().getParameters().get('vPdf')=='1'?True:false;
   system.debug(LoggingLevel.INFO,'-=-Vpdf:'+viewPdf);
   system.debug(LoggingLevel.INFO,'-=-=hId:'+ApexPages.currentPage().getParameters().get('headerID'));
   if(ApexPages.currentPage().getParameters().get('headerID')!=NULL)
    header.id = ApexPages.currentPage().getParameters().get('headerID');
   else 
    header = (Employee_NOVO_Log__c) controller.getRecord();
     EmpId=ApexPages.currentPage().getParameters().get('eId'); 
      if(EmpId!=NULL){
      header.Employee__c=EmpId;
      system.debug('*gjh'+header.Employee__c);
      }
   
    if(header.id!=Null){
            System.debug('====existing record====');
            header = [SELECT id, Name,Employee__c,Employee__r.Salesforce_User__r.Email,Number_of_Actions__c,Employee__r.name,Status__c,Reason__c,Related_Strategic_Priority__c,Pay_Number__c,Job_CHI_Lead_Number__c,
                             Goal_Target_Date__c,Goal_Novo__c,Where_Are_U_Now__c,How_will_you_measure_prog__c,
                             Note_on_Outcome__c,(select id,name,Action_activity__c,Owner__c,owner__r.name,Action_Completion_Date__c,Status__c from NOVO_Activities__r) From Employee_NOVO_Log__c where id=:header.id];
   
        NovoAct = True;
       attachFile=false;
      NovoActivity=false;
     
        for(NOVO_Activities__c novoAct:header.NOVO_Activities__r ){
         Actids.add(novoAct.id);
        
        }
         List<Attachment> attQuery = [select id,body,parentId,name from Attachment where parentid=:Actids];
          Map<id,decimal> m= new Map<id,decimal>();
          for(Attachment a: attQuery){
            if(!m.containskey(a.parentId))
            m.put(a.parentId,1);
            else{
             decimal k=m.get(a.parentId)+1;
             m.put(a.parentId,k);  
            }
            
          }
          integer i = 1;
        for(NOVO_Activities__c novoAct:header.NOVO_Activities__r ){
       
               NovoWrapper wrapNovo=new NovoWrapper(novoAct, i);
               wrapNovo.Nov=novoAct;
                if(m.containskey(novoAct.id)){
                  wrapNovo.attsize = m.get(novoAct.id);
                }
                theQuestions.add(wrapNovo);
                i++;
         }
    } 
    
 }
  public void CallSendPdf(Id headerID){
      if(headerID!=Null){
            System.debug('====existing record====');
            header = [SELECT id, Name,Employee__c,Employee__r.Salesforce_User__r.Email,Number_of_Actions__c,Employee__r.name,Status__c,Reason__c,Related_Strategic_Priority__c,Pay_Number__c,Job_CHI_Lead_Number__c,
                             Goal_Target_Date__c,Goal_Novo__c,Where_Are_U_Now__c,How_will_you_measure_prog__c,
                             Note_on_Outcome__c,(select id,name,Action_activity__c,Owner__c,owner__r.name,Action_Completion_Date__c,Status__c from NOVO_Activities__r) From Employee_NOVO_Log__c where id=:headerID];

          if(header!=null){
            sendpdfAction();
           }
      }
      
  }
 public void NovoAction(){
      //theQuestions.clear();
       //for(integer i=0;i<integer.valueof(header.Number_of_Actions__c);i++){
       upsert header;
       NOVO_Activities__c newObj = new  NOVO_Activities__c();
       newObj.Employee_NOVO_Log__c = header.Id;
       insert newObj;
       system.debug('**theQuestions 1'+theQuestions);
       theQuestions.add(new NovoWrapper(newObj, theQuestions.size()+1));
       system.debug('**theQuestions 2'+theQuestions);
    //  }
      NovoAct = True;
      
 }
  public PageReference RemoveAction(){
       system.debug(LoggingLevel.INFO,'-=-=-=-=-=>'+numberOfRowToRemove);
       NovoWrapper wrapNovo=new NovoWrapper(new NOVO_Activities__c(), 0);
       if(theQuestions.get(numberOfRowToRemove)!=null){
       wrapNovo= theQuestions.get(numberOfRowToRemove);
       system.debug('**1'+theQuestions.get(numberOfRowToRemove));
       }
       theQuestions.remove(numberOfRowToRemove);
         if(theQuestions.size()==0){
         NovoAct=false;
            NovoActivity=true;
        system.debug('**NovoActivity'+NovoActivity);
        }
       system.debug('**2'+wrapNovo);
       if(wrapNovo.Nov.Id!=null){
       List<NOVO_Activities__c> deleteAct=[select id,Employee_NOVO_Log__c from NOVO_Activities__c where id=: wrapNovo.Nov.id ];
         system.debug('**3'+deleteAct);
       delete deleteAct;
       }
     
        return null;
 }
 
 public void createNovoActivity(){
    List<NOVO_Activities__c> activeList = new List<NOVO_Activities__c>();
    for(NOVOwrapper a: theQuestions){
       system.debug(LoggingLevel.INFO,'-=-=>NoV:'+a);
       system.debug(LoggingLevel.INFO,''+a.nov.owner__c+' '+a.nov.status__c);
       //a.nov.Employee_NOVO_Log__c = header.id;
       activeList.add(a.nov);
      
    }
     system.debug('*activeList'+activeList);
    if(activeList.size()>0)
    Database.upsert(activeList,false);
    attachFile=false;
     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'Saved successfully:To email please select or write in additional names and emails below.'));
    system.debug(LoggingLevel.INFO,'--=-=-=--=-=-=-=--=line 37:'+activeList+' '+theQuestions);
    
    list<Attachment> AtchList = new list<Attachment>();
    for(NOVOwrapper a: theQuestions){
        system.debug(LoggingLevel.INFO,''+a.nov.id);
        a.attachment.ParentId = a.nov.ID;
        a.attachment.OwnerId = UserInfo.getUserId();
        a.attachment.IsPrivate = false;
        system.debug(LoggingLevel.INFO,'@@'+a.filename);
        
       /* if(a.fileName.length() < 1){
            a.attachment.name = system.Datetime.now()+'.jpg';  
        }else{
            a.attachment.name = a.fileName +'.jpg';      
        }*/
        if(a.attachment.body!=null)
        atchList.add(a.attachment);
        
    }
        
       
    
    system.debug(LoggingLevel.INFO,'-=-=-=-=--=-=-=->'+atchList);
    
    if(AtchList.size()>0)
    Database.upsert(AtchList);
    
 }
  
 public pageReference saveAction(){
    system.debug(LoggingLevel.INFO,'I am inside Save');
    pageReference pageRef;
    if(header.id == NULL){
     NovoActivity=false;
       try{
       upsert header;
       createNovoActivity();
       /*pageRef = new pagereference('/'+header.id);
       pageRef.setredirect(true);
       return pageRef; */
       }Catch(Exception e){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
          return null;
       }
       
    
    }
    else if(header.id != NULL){
    try{
       attachFile=true;
       NovoActivity=false;
       update header;
       List<NOVO_Activities__c> activeList = new List<NOVO_Activities__c>();
       for(NOVOwrapper a: theQuestions){
       //a.nov.Employee_NOVO_Log__c = header.id;
      system.debug('** a.nov.id'+a.nov.id);
       activeList.add(a.nov);
      
    }
    
    if(activeList.size()>0)
        {
          NovoActivity=false;
          system.debug('**activeList'+activeList);
          Database.upsert(activeList);
          attachFile=false;
        }
       pageRef = new pagereference('/'+header.id);
       pageRef.setredirect(true);
       return pageRef; 
       }Catch(Exception e){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
          return null;
       }
       
    
    }
    return null;
 }
 
 public pagereference upload()
 {
     createNovoActivity();
     
     pagereference p = new pagereference('/p/attach/NoteAttach?pid='+attachementParent+'&parentname='+attachementParent+'&retURL=%2F'+'apex/Smart_Novo?headerID='+header.id);
     
     return p;
 }
 
 /*public pageReference AddAttachment(){
      pageReference pageRef;
      try{
      pageRef = new pagereference('/p/attach/NoteAttach?pid='+a.Nov.id+'&parentname='+a.Nov.name+'&retURL=%2F'+a.nov.id);
       pageRef.setredirect(true);
       return pageRef; 
       }Catch(Exception e){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
          return null;
       }
    return null;
 }  */
 public PageReference generatePdf()
 {
        pagereference p;
        Blob pdfBlob;
     
        //if(signsuccess==2)
        //{
            try{
            System.debug('===In MethodTest====');
            
            PageReference pdfPage = page.NovoSmartPdf;
            
            //putting id of custom object in parm id so that I can read it to fetch records
            pdfPage.getParameters().put('headerID',header.id);
            
            if(viewPdf){
              system.debug(LoggingLevel.INFO,'-=-=-=-=-'+pdfPage);
              pdfPage.getParameters().put('vPdf','0');
              return pdfPage;
            }
           
            if(test.isRunningTest())
            {
              pdfBlob = Blob.valueOf('Unit Test Attachment Body');
            
            }
            else 
            {
             pdfBlob = pdfPage.getContent();
            } 
    
                
            Attachment NovoFormPdf = new Attachment(Body = pdfBlob,
                                                Name = 'Novo Log.pdf',
                                                ParentId = header.Id,
                                                isPrivate = false,
                                                contenttype='.pdf'
                                                );
              //System.debug('====PDF===='+NovoFormPdf );  
              //System.debug('====emp===='+emp.name);                                                                     
                try{
                   //insert WIPFormPdf ;
                   //sendEmail(NovoFormPdf);  
                     system.debug(LoggingLevel.INFO,'@@entered into mail box');
              
                     List<String> ToAddresses = new List<String>();
                     //ToAddresses.add(email);
                     ToAddresses.add(emailString);
                 
                     Id headerID = ApexPages.currentPage().getParameters().get('headerID');
                      List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                      // create email attachment
                      Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                      //efa.setContentType('application/pdf');
                      efa.setFileName(NovoFormPdf.name);
                      //efa.setInline(false);
                      efa.body = NovoFormPdf.body;
                      emailAttachments.add(efa);
                      set<id> novoActId=new set<id>();
                      List<NOVO_Activities__c> novoActIds=new List<NOVO_Activities__c>([SELECT Id, Employee_NOVO_Log__c FROM NOVO_Activities__c  WHERE Employee_NOVO_Log__c =:header.ID]);
                    
                    for(NOVO_Activities__c nAct : novoActIds){
                          
                          novoActId.add(nAct.id);
                          
                      }
                      List<Attachment> attachments = [SELECT Id, Name, Body,Parentid, ContentType FROM Attachment  WHERE Parentid =:novoActId OR Parentid =:header.ID ];
                      system.debug('*attachments'+attachments);
                      List<Employee__c> empList=new  List<Employee__c>([select id,Salesforce_User__r.email,Name from Employee__c where Salesforce_User__r.email=:emailString LIMIT 1]);
                       for(Attachment att : attachments) {

                            Messaging.EmailFileAttachment attach= new Messaging.EmailFileAttachment();
                            attach.setFileName(att.Name);
                            attach.setBody(att.Body);
                           // attach.setContentType(att.ContentType);
                            emailAttachments.add(attach);
                      }
                      //create email message
                      
                      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                      email.setFileAttachments(emailAttachments);
                    
                    List<Employee_NOVO_Log__c> smartNovoName = [Select id,Name from Employee_NOVO_Log__c where id=:header.id limit 1];

                    
                      email.setSubject('Employee NOVO Log :'+smartNovoName[0].Name);
                      if(empList.size()>0){
                      email.setPlainTextBody('Dear '+empList[0].name+',\n \nPlease Find attached Novo LOG. \n \nThanks,\n British Gas\n\n Do not respond. This is the automated email.');
                      }
                      else{
                      email.setPlainTextBody('Dear User'+',\n \nPlease Find attached Novo LOG. \n \nThanks,\n British Gas\n\n Do not respond. This is the automated email.');
                      
                      }
                      //'+header.Employee__r.name
                      email.setToAddresses( ToAddresses );
                      
                      OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@britishgas.co.uk'];
                      if (owea.size() > 0 ) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                      }
                      
                      Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                      efa = null;
                      email = null;
                      NovoFormPdf = null;
                      pdfBlob = null;
                      if(r[0].isSuccess()){
                          util.setErrorMsg(false, 'Email sent successfully.');
                           system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=273:'+reqFrom+' '+sfUser); 
                           if(reqFrom == 'NG'){
                             p= new pagereference('/apex/Novo_Logs_View?sfUser='+sfUser+'&view='+view+'&e='+edit+'&goalId='+header.id+'&sent=1');
                             
                           }else if(reqFrom == 'NP'){
                             system.debug(LoggingLevel.INFO,'I am inside NP:');
                             p= new pagereference('/apex/NovoReporteePage?sfUser='+sfUser+'&view='+view+'&e='+edit+'&goalId='+header.id+'&sent=1');
                             
                           }
                           else{
                             //util.setErrorMsg(false, 'Email sucesfully sent.');  
                             return null;
                            
                           }
                            p.setredirect(true);
                             return p;
                           
                         
                      }
                      else{
                          util.setErrorMsg(true, 'Email sending failed.');
                          p.setredirect(true);
                          return p;
                      }   
                  }
                   catch (exception e)
                   {
                        system.debug('Error  while Sending Novo Form Pdf:'+e.getmessage());
                        util.setErrorMsg(true, e.getmessage());
                        return null;
                   }
                   system.debug(LoggingLevel.INFO,'-=-=-=-=290:'+reqFrom);
                   if(reqFrom == 'NG')
                   p= new pagereference('/apex/Novo_Logs_View?sfUser='+sfUser+'&view='+view+'&e='+edit+'&goalId='+header.id);
                   else if(reqFrom == 'NP')
                   p= new pagereference('/apex/NovoReporteePage?sfUser='+sfUser+'&view='+view+'&e='+edit+'&goalId='+header.id);
                   else
                   {
                    util.setErrorMsg(false, 'Email sucesfully sent.');  
                    return null;
                   }
                   
                   p.setredirect(true);
                   return p;
            }
            catch(Exception e)
            {
                system.debug('Error  while saving :'+e.getmessage()); 
                util.setErrorMsg(true, e.getmessage());  
                return null;       
            }
        
        //}   
        return null;        
  }
  public pageReference ProcessSelected(){
    pageReference p;
    boolean check=false;  
   /* for(EmailWrapper eWrap :emailWrapList){
         if(eWrap.checked && eWrap.emailWrap==null && (eWrap.emailHead.Owner__c==null ||eWrap.emailHead.Owner__c=='')){
          util.setErrorMsg(true, 'Please fill in values for either name or email to send pdf.'); 
          return null;
         }
        
        
    } */
      system.debug('>>>>>emailWrapList'+emailWrapList);
    for(EmailWrapper eWrap :emailWrapList){
         if(eWrap.checked){
          check=true;
          emailString = eWrap.emailWrap;
          p=  generatePdf();
         }
    } 
    if(!check){
    
    util.setErrorMsg(true, 'Please select atleast one checkbox to send pdf.'); 
        return null;
    } 
   
   return p;   
  }
  
  public pagereference AttachPdf(string email,NOVO_Activities__c emailHeader ){
     /*System.debug('======'+!email.contains('@'));
     System.debug('======'+!(email.indexOf('@')<email.lastIndexOf('.')));
     System.debug('======'+!(email.lastIndexOf('.')>email.indexOf('@')+2));
     System.debug('======'+!(email.lastIndexOf('.')+2>=email.length()));  */
     if(email== null && emailHeader.Owner__c == null  )
     {
        util.setErrorMsg(true, 'Please enter atleast one; Email or Employee to send pdf.'); 
        return null;
          
     }
     
     if(emailHeader.Owner__c == null && (email== null || email== '' || !email.contains('@') || !(email.indexOf('@')<email.lastIndexOf('.')) 
                  || !(email.lastIndexOf('.')>email.indexOf('@')+2)) )
     {
        util.setErrorMsg(true, 'Invalid email Id.'); 
        return null;
     } 
     
     
     if(emailHeader.Owner__c != null)
     {
         email = [Select Id, Salesforce_User__r.Email from Employee__c where Id = : emailHeader.Owner__c].Salesforce_User__r.Email;
     }
     emailHeader1=emailHeader;
     System.debug('*attachpdfstart');
     System.debug('*emailHeader1'+emailHeader1);
     System.debug('*emailHeader'+emailHeader);
     pageReference p;
     if(reqFrom == 'NG'){
       p = new pageReference('/apex/Smart_Novo?headerId='+header.Id+'&signsuccess=2'+'&email='+email+'&view='+view+'&sfUser='+sfUser+'&e='+edit+'&req=NG');
     }else if(reqFrom == 'NP'){
       p = new pageReference('/apex/Smart_Novo?headerId='+header.Id+'&signsuccess=2'+'&email='+email+'&view='+view+'&sfUser='+sfUser+'&e='+edit+'&req=NP');
     }else{    
       p = new pageReference('/apex/Smart_Novo?headerId='+header.Id+'&signsuccess=2'+'&email='+email);
     }
     p.setRedirect(true);
     System.debug('*attachpdfend');
     return p;
  }
  
  public pageReference sendEmail(Attachment a){
        pagereference pageref = new pageReference('/apex/Smart_Novo?headerId='+header.Id+'&signsuccess=1'+'&email='+email);
         System.debug('*sendemailstart');
        try{
          system.debug(LoggingLevel.INFO,'@@entered into mail box');
          
          List<String> ToAddresses = new List<String>();
          ToAddresses.add(email);
         
         
              Id headerID = ApexPages.currentPage().getParameters().get('headerID');
              
              // create email attachment
              Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
              //efa.setContentType('application/pdf');
              efa.setFileName(a.name);
              //efa.setInline(false);
              efa.body = a.body;
              List<Attachment> attachments = [SELECT Id, Name, Body,Parentid, ContentType FROM Attachment  WHERE Parentid =:emailHeader1.ID];
                 
              List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
              for(Attachment att : attachments) {

                    Messaging.EmailFileAttachment attach= new Messaging.EmailFileAttachment();
                    attach.setFileName(att.Name);
                    attach.setBody(att.Body);
                    attach.setContentType(att.ContentType);
                    emailAttachments.add(attach);
              }
              //create email message 
              emailAttachments.add(efa);
              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
              email.setFileAttachments(emailAttachments);
              email.setSubject('Employee NOVO Log :'+header.Name);
              email.setPlainTextBody('Dear '+header.Employee__r.name+',\n \nPlease Find attached Novo LOG. \n \nThanks,\n British Gas\n\n Do not respond. This is the automated email.');
              email.setToAddresses( ToAddresses );
              
             // OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@britishgas.co.uk'];
            //  if (owea.size() > 0 ) {
             //   email.setOrgWideEmailAddressId(owea.get(0).Id);
             // }
              
              Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
              if(r[0].isSuccess()){
                  util.setErrorMsg(false, 'Email sent successfully.');
                  pageRef = new pageReference('/'+header.id);
                  pageRef.setredirect(true);
                  return pageRef;
                 
              }
              else{
                  util.setErrorMsg(true, 'Email sending failed.');
                  pageRef.setredirect(true);
                  return pageRef;
              }
         }
        
        catch(Exception e){
            util.setErrorMsg(true, e.getMessage());
            pageRef.setredirect(true);
            return pageRef;
        }
        
      return pageRef;
    }
    
   public void setErrorMsg()
   {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.warning, errorMsg);
        ApexPages.addMessage(msg);
   } 
 
 public class NovoWrapper{
    public NOVO_Activities__c Nov{get;set;}
    public Attachment attachment {get;set;}
    public string fileName{get;set;}
    public decimal attSize{get;set;}
    public string uniqId1{get;set;}
    public string uniqId2{get;set;}
    public NovoWrapper(NOVO_Activities__c n, decimal  uniqId){
      this.Nov = n;
      this.attachment = new Attachment();
      this.attSize=0;
      this.uniqId1 = 'a'+string.valueof(uniqId);
      this.uniqId2 = 'b'+string.valueof(uniqId);
    }
    
   public list<Schema.FieldSetMember> NovoFields {get {return sObjectType.NOVO_Activities__c.FieldSets.NovoFieldSet.getFields();}} 
 }
  
  
  public pagereference goBack()
  {
      for(NOVOwrapper a: theQuestions)
      {
          errorMsg= '';
          if(a.Nov.Owner__c  == null)
          {
              errorMsg = 'Owner ';
             
          }
          if(a.Nov.Action_Completion_Date__c  == null)
          { 
              if(errorMsg!='') errorMsg+= ', ';
              errorMsg += 'Action Completion Date';
              
          }
          if(a.Nov.Action_activity__c  == null)
          {
              if(errorMsg!='') errorMsg+= ', ';
              errorMsg += 'Action';
             
              
          }
          if(errorMsg!='')
          {
            errorMsg += ' Fields are mandatory';
            setErrorMsg();
            return null;
          }
 
      }
      createNovoActivity();
      
      pagereference p  = new pagereference('/apex/Novo_Logs_View');
       p.setredirect(true);
       return p;
  }
  
  
  public void sendpdfAction()
  {
      Set<id> empList= new set<id>();
      empList.add([select id,Salesforce_User__c from Employee__c where id=: header.Employee__c].Salesforce_User__c);
      List<User> userList=new List<User>([select id,email,managerid,manager.email from User where id in :empList]);
      if(userList.size()>0){
      List<Employee__c> novoLog=new List<Employee__c>([select id,Salesforce_User__c from Employee__c where Salesforce_User__c=: userList[0].managerid]);
     
      for(User u : userList){
      emailWrapList.add(new EmailWrapper(false,new NOVO_Activities__c(owner__c=header.employee__c),string.valueOf(u.Email)));
      if(novoLog.size()>0){
      emailWrapList.add(new EmailWrapper(false,new NOVO_Activities__c(owner__c=novoLog[0].id),string.valueOf(u.manager.email)));
      }
      emailWrapList.add(new EmailWrapper(false,new NOVO_Activities__c(),null));
      }
      }
      goBack();
      signSucessRender = true;
  }
  
  public pagereference deleteNovo()
  {
      try{
      delete header;
      }catch (exception e)
      {
          
      }
      
      return new pagereference('/apex/Novo_Logs_View');
  }
  
  public class EmailWrapper {

    public Boolean checked{ get; set; }
    public NOVO_Activities__c emailHead{ get; set; }
    public string emailWrap{ get; set; }

    public EmailWrapper(boolean checked,NOVO_Activities__c emailHead,string emailWrap){
        this.checked=checked;
        this.emailHead=emailHead;
        this.emailWrap=emailWrap;
    }
  }
}