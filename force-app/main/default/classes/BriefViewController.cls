public with sharing class BriefViewController {
    
    public Mandatory_Briefings__c brief {get; set;}
    public boolean isBriefEnabled {get; set;}
    User currentUser {get; set;}
    public boolean isEdit {get; set;}
    public List<Attachment> briefDocuments ;
    //public String documentStatus {get; set;}
    public boolean isNotUnderstood {get; set;}
    public String oldStatus;
    public String oldSubStatus;
    public List<DocumentHelper> docHelperList {get; set;}
    public String selectedDocument {get; set;}
    public boolean isCompletionReasonEnabled {get; set;}
    public String completionReason {get; set;}
    public DateTime NotUnderstoodDatetime {get; set;}
    
    
    
    public BriefViewController(ApexPages.StandardController controller) {
        isBriefEnabled = false;
        isEdit = true;
        isCompletionReasonEnabled = true;
        completionReason = '';
        //isNotUnderstood = false;
        oldStatus = '';
        oldSubStatus='';
        docHelperList = new List<DocumentHelper>();    
        brief = new Mandatory_Briefings__c();
        briefDocuments = new List<Attachment>();
        currentUser = [Select u.Profile.Name, u.Id, u.Brief_User__c From User u where id =: Userinfo.getUserId()];
        brief = (Mandatory_Briefings__c)controller.getRecord();
        brief = [select id,Issued_Date_Time__c,Mandatory_Briefing_Creator__c,I_have_read_understood_document__c,
                 Status__c , Sub_Status__c , Name , Briefing_Name__c ,Over_All_Status_Text__c ,Documents_Viewed__c,
                 Employee__c , District__c ,Region__c ,Status_Indicator__c ,Actual_End_Date_Time__c , 
                 I_have_read_understood_content__c , Completion_Reason__c,Not_Understood_Date_time__c
                 from Mandatory_Briefings__c where id =: brief.id];
        if(brief.Issued_Date_Time__c > system.now())
        {
            isBriefEnabled = true;
        }
        if(String.valueOf(currentUser.Profile.Name).contains('System Administrator') || (currentUser.Brief_User__c))
        {
            isBriefEnabled = false;
        }
        if(brief.Status__c == 'Complete' && brief.Sub_Status__c == 'Not Understood')
        {
            isNotUnderstood = true;
        }
       /* if(brief.Status__c == 'Complete' && brief.Sub_Status__c == 'Not Understood')
        {
            NotUnderstoodDatetime = system.now();
        }*/
        oldStatus = brief.Status__c;
        oldSubStatus=brief.Sub_Status__c;
        briefDocuments = [Select a.ParentId, a.Name, a.Id From Attachment a where a.ParentId =: brief.Mandatory_Briefing_Creator__c];
        if(briefDocuments.size() > 0)
        {
            for(Attachment attach : briefDocuments)
            {
                DocumentHelper docHelper = new DocumentHelper();
                if(brief.Documents_Viewed__c == null)
                {
                    docHelper.documentViewed = false;
                }
                else if(String.valueOf(brief.Documents_Viewed__c).contains(attach.Name))
                {
                    docHelper.documentViewed = true;
                }
                docHelper.briefDocument = attach;
                docHelperList.add(docHelper);
            }
             
        }
    }
  
    public void editDetails()
    {
        isEdit = false;
        
    }
    public PageReference saveDetails()
    {
        Boolean allDocuemntsViewed = false;
        for(DocumentHelper doc : docHelperList)
        {
            if(doc.documentViewed == false)
            {
                allDocuemntsViewed = true;
            }
        }
        if(brief.Status__c=='Complete' && brief.Sub_Status__c == 'Understood' && oldSubStatus=='Not Understood')
        {
            if((completionReason == null || completionReason == '') && (brief.Completion_Reason__c==null || brief.Completion_Reason__c==''))
            {
                
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'You have to specify the completion reason.');
                ApexPages.addMessage(msg);
                isEdit = false;
                return null;
            }
            if(allDocuemntsViewed == true)
            {
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'You have not viewed the document.');
                ApexPages.addMessage(msg);
                isEdit = false;
            }
            else
            {
                try
                {
                    brief.Completion_Reason__c = completionReason;
                    update brief;
                    isEdit = true;
                    PageReference pageRef = new PageReference('/'+brief.Id);
                    return pageRef;
                }
                catch(System.DMLException ex)
                {
                    extractErrorMessage(ex);
                }
            }
            
        }
        else if(brief.Status__c=='Complete' && brief.Sub_Status__c == 'Understood' && (oldSubStatus == ''|| oldSubStatus==null))
        {
            update brief;
            isEdit = true;
            PageReference pageRef = new PageReference('/'+brief.Id);
            return pageRef;
        }
        else if(brief.Status__c == 'Complete' && brief.Sub_Status__c == 'Not Understood')
        {
            try
            {
                NotUnderstoodDatetime = system.now();
                update brief;
                isEdit = true;
                PageReference pageRef = new PageReference('/'+brief.Id);
                return pageRef;
            }
            catch(Exception ex){}
       }
        else if(oldStatus == 'Complete' & brief.Status__c == 'In Progress')
        {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'You can not change the status to In Progress once it is complete.');
            ApexPages.addMessage(msg);
            isEdit = false;
        }
        return null;    
    }
    
    public PageReference cancelDetails()
    {
        isEdit = true;
        PageReference pageRef = new PageReference('/'+brief.Id);
        return pageRef;
    }
    
    public void isDocumentViewed()
    {
        for(DocumentHelper doc : docHelperList)
        {
            if(selectedDocument == doc.briefDocument.Name)
            {
                doc.documentViewed = true;
                if(brief.Documents_Viewed__c == null)
                {
                    brief.Documents_Viewed__c = doc.briefDocument.Name;
                }
                else
                {
                    brief.Documents_Viewed__c = brief.Documents_Viewed__c + ';' + doc.briefDocument.Name;
                }
                update brief;
                break;
            }
            
        }
    }
    
    public static void extractErrorMessage(System.DMLException excp)
    {
        if(excp != null && excp.getNumDml() != null)
        {
            for(Integer failedRow = 0; failedRow < excp.getNumDml(); failedRow++)
            {
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR,excp.getDMLMessage(failedRow));
                ApexPages.addMessage(msg);
            }
        }
    }
 
    public void enableisCompletionReasonEnabled()
    {
        if(brief.Status__c == 'Complete' && brief.Sub_Status__c == 'Understood' && oldSubStatus=='Not Understood')
        {
            isCompletionReasonEnabled = false;
        }
        else
        {
            isCompletionReasonEnabled = true;
        }
    }
    
    public class DocumentHelper
    {
        public Boolean documentViewed {get; set;}
        public Attachment briefDocument {get; set;}
        
        public DocumentHelper()
        {
            documentViewed = false;
            briefDocument = new Attachment();
        }
    }
}