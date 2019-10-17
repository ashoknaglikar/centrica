@isTest
private class BriefViewController_Test {

    static Employee__c emp;
    static Mandatory_Briefing_Creator__c mbc;
    static Mandatory_Briefings__c mb;
    
    static void createData()
    {
        //prepare employee data
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Employee_Number__c = '0992991');
        insert emp;
        //prepare mandatory briefing creator data
        mbc = new Mandatory_Briefing_Creator__c(Name__c = 'test mbc'+system.now(),Employee__c = emp.Id, Issued_Date_Time__c = system.now()+1 , Actual_End_Date_Time__c = system.now()+10 );
        insert mbc;
        
                
        //insert brief data
        mb  = new Mandatory_Briefings__c();
        mb.Briefing_Name__c = mbc.Name__c;
        mb.Completed_By__c = mbc.Employee__r.Salesforce_User__c;
        mb.Employee__c = mbc.Employee__r.Id;
        mb.Content__c = mbc.Content__c;
        mb.Mandatory_Briefing_Creator__c = mbc.Id;
        mb.Status__c = 'In Progress';
        insert mb;
    }
    
    static testmethod void testBriefValidation()
    {
        createData();
        User adminUser = [select id,Profile.Name,IsActive from User where Profile.Name =: 'System Administrator' and IsActive = true limit 1];
        System.RunAs(adminUser)
        {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(mb);
            BriefViewController controller = new BriefViewController(stdCtrl);
            controller.editDetails();
            controller.saveDetails();
            controller.cancelDetails();
        }
    }
    
    static testmethod void testDocumentNotViewd()
    {
        createData();
        //prepare Attachment data
        Attachment att = new Attachment();
        att.Body = Blob.valueOf('FFFFFF');
        att.ContentType = 'application/pdf';
        att.Name = '1234554321.pdf';
        att.ParentId = mbc.Id;
        insert att;
        mb.Status__c = 'Complete';
        //mb.I_have_read_understood_document__c = false;
        update mb;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(mb);
        BriefViewController controller = new BriefViewController(stdCtrl);
        //controller.documentStatus = null;
        controller.saveDetails();
        controller.isDocumentViewed();
       
    }
    
    static testmethod void testUserNotSelectedDocumentRead()
    {
        createData();
        mb.Status__c = 'Complete';
        mb.Sub_Status__c = 'Understood';
        update mb;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(mb);
        BriefViewController controller = new BriefViewController(stdCtrl);
       // controller.documentStatus = 'TRUE';
        controller.saveDetails();
        controller.isDocumentViewed();
        controller.enableisCompletionReasonEnabled();
      
    }
    
    static testmethod void testDocuemtnNotUnderstood()
    {
        createData();
        mb.Status__c = 'Complete';
        mb.Sub_Status__c = 'Not Understood';
        update mb;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(mb);
        BriefViewController controller = new BriefViewController(stdCtrl);
        //controller.documentStatus = 'TRUE';
        controller.saveDetails();
        controller.isDocumentViewed();
        controller.enableisCompletionReasonEnabled();
        
    }
    
    static testmethod void testDocuemtnUnderstood()
    {
        createData();
        //prepare Attachment data
        Attachment att = new Attachment();
        att.Body = Blob.valueOf('FFFFFF');
        att.ContentType = 'application/pdf';
        att.Name = '1234554321.pdf';
        att.ParentId = mbc.Id;
        insert att;
        mb.Documents_Viewed__c = att.Name;
        mb.Status__c = 'Complete';
        mb.Sub_Status__c = 'Understood';
        update mb;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(mb);
        BriefViewController controller = new BriefViewController(stdCtrl);
        BriefViewController.DocumentHelper docHelp = new BriefViewController.DocumentHelper();
        docHelp.briefDocument = att;
        docHelp.documentViewed = true;
        controller.docHelperList.add(docHelp);
        controller.selectedDocument = controller.docHelperList[0].briefDocument.Name;
        controller.completionReason = 'testReason';
        controller.saveDetails();
        controller.isDocumentViewed();
        
    }
    
    static testmethod void testDocuemtnUnderstoodNegativeScenario()
    {
        createData();
        //prepare Attachment data
        Attachment att = new Attachment();
        att.Body = Blob.valueOf('FFFFFF');
        att.ContentType = 'application/pdf';
        att.Name = '1234554321.pdf';
        att.ParentId = mbc.Id;
        insert att;
        mb.Documents_Viewed__c = att.Name;
        mb.Status__c = 'Complete';
        mb.Sub_Status__c = 'Understood';
        update mb;
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(mb);
        BriefViewController controller = new BriefViewController(stdCtrl);
        BriefViewController.DocumentHelper docHelp = new BriefViewController.DocumentHelper();
        docHelp.briefDocument = att;
        docHelp.documentViewed = true;
        controller.docHelperList.add(docHelp);
        controller.selectedDocument = controller.docHelperList[0].briefDocument.Name;
        controller.completionReason = 'testReason';
        controller.saveDetails();
        controller.isDocumentViewed();
        
    }
    
    static testmethod void testInProgressStatus()
    {
        createData();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(mb);
        BriefViewController controller = new BriefViewController(stdCtrl);
        controller.oldStatus = 'Complete';
        mb.Status__c = 'In Progress';
        update mb;
       // controller.documentStatus = 'TRUE';
       controller.saveDetails();
       controller.isDocumentViewed();
        
    }
 
}