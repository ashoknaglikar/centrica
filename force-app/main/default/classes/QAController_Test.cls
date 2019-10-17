@ isTest

public class QAController_Test{
    static Account acc;
    static Contact con;
    static Opportunity lead;
    static QA_header__c QAheader;
    static QA_Response__c QARes;
    static List<QMaster__c> questions;
    static District__c testDistrict ;
    static Job__c job;
    static Region__c testRegion;
    static BigMachines_Quote__c quote; 
    static Employee__c emp;
    
    static void createData(){
        
        testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');        
        Database.insert(testRegion);
        testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);        
        insert testDistrict;
        acc = TestClassHelper.createAccout();
        insert acc;
        con = TestClassHelper.createContact(acc);
        insert con;
        lead = TestClassHelper.createCHILead(acc);
        lead.chi_lead_id__c = '123456';
        try{
        insert lead;
        
        emp = TestClassHelper.createEmployee();
        
        system.debug('###########emp = '+emp);
        insert emp;          
        emp = [SELECT id,name from Employee__c where id=:emp.id];
        system.debug('!!!emp = '+emp.name);
        quote = TestClassHelper.createBMQuote(lead);
        quote.App_Assigned_To__c = emp.name;
        insert quote; 
        system.debug('@@@quote = '+quote.Id);     
        job = TestClassHelper.createJob('planned', 'planned', lead.id, testDistrict.id);
        job.Quote__c = quote.id;        
        insert job; 
        }catch(Exception e){
        System.debug('@@@@@@@@@@@@@@@@@@'+e);
        }
       
        questions = new List<QMaster__c>();
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='que1',options__c='Yes|No',section__c='General'));
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='que2',options__c='Yes|No',section__c='Finance'));
        insert questions;
    }
    
    static testmethod void test1(){
        createData();
        QAheader = new QA_header__c(Employee__c=emp.id,CHI_Lead__c=lead.id);
        insert QAheader;
        list<selectoption> option = new  list<selectoption> ();
        option.add(new selectoption('yes','yes'));
        QA_Response__c res = new QA_Response__c(QA_Header__c=QAheader.id,Option__c='Yes|No',Answer__c='yes',Question__c='que1',Section__c='General');
        insert res;
        ApexPages.StandardController sc = new ApexPages.StandardController(QAheader);
        QAController controller = new QAController(sc);
        QAController.questionAnswer queAns = new QAController.questionAnswer(res,option);
        //Test.setCurrentPage(new pagereference('apex/QAPage/'));
        
        PageReference pageRef = Page.QAPage;
        pageRef.getParameters().put('id', String.valueOf(QAheader.Id));
        Test.setCurrentPage(pageRef);
            
        test.startTest();
        acc = [SELECT id FROM Account WHERE id=:acc.id];      
        Opportunity opp = [SELECT id,name,chi_lead_id__c from Opportunity where id=:lead.id];
        job = [select id, HSA_Name__c From Job__c where id = :job.id];
        System.debug('@@@@@@Priti'+job.HSA_Name__c);
        
        //controller.save();
        controller.searchString = opp.chi_lead_id__c;
        controller.search();
        controller.save();
        test.stopTest(); 
    }
    static testmethod void test2(){
        createData();
        QAheader = new QA_header__c(Employee__c=emp.id,CHI_Lead__c=lead.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(QAheader);
        QAController controller = new QAController(sc);
        PageReference pageRef = Page.QAPage;
        Test.setCurrentPage(pageRef);
        acc = [SELECT id FROM Account WHERE id=:acc.id];      
        Opportunity opp = [SELECT id,name,chi_lead_id__c from Opportunity where id=:lead.id];
        job = [select id, HSA_Name__c From Job__c where id = :job.id];
        System.debug('@@@@@@Priti'+job.HSA_Name__c);
        
        test.startTest();
        controller.searchString = '1234';
        controller.search();
        
        controller.searchString = opp.chi_lead_id__c;
        controller.search();
        controller.save();
        test.stopTest(); 
    }
    
     static testmethod void test3(){
        createData();
        QMaster__c que = new QMaster__c(Options__c='Yes|No',Question_text__c='que',order__c=1,section__c='General');
        insert que;
        QAheader = new QA_header__c(Employee__c=emp.id,CHI_Lead__c=lead.id);
        list<selectoption> option = new  list<selectoption> ();
        option.add(new selectoption('yes','yes'));
        ApexPages.StandardController sc = new ApexPages.StandardController(QAheader);
        QAController controller = new QAController(sc);
        QAController.questionAnswer queAns = new QAController.questionAnswer(que,option,'priti');
        PageReference pageRef = Page.QAPage;
        Test.setCurrentPage(pageRef);
        acc = [SELECT id FROM Account WHERE id=:acc.id];      
        Opportunity opp = [SELECT id,name,chi_lead_id__c from Opportunity where id=:lead.id];
        job = [select id, HSA_Name__c From Job__c where id = :job.id];
        System.debug('@@@@@@Priti'+job.HSA_Name__c);
        
        test.startTest();
        controller.searchString = opp.chi_lead_id__c;
        controller.search();
        controller.save();
        controller.cancel();
        controller.queryGeneralQuestions();
        controller.queryFinanceQuestions();
        controller.queryExistingGeneralQuestions();
        controller.queryExistingFinanceQuestions();
        
        queAns.getIfAnsIsNumber();
        queAns.getIfAnsIsText();
        queAns.getNumberOptions();
        queAns.getPaymentOptions();
        
        controller.GQuestionsClass.add(queAns);
        controller.GQuestionsClass[0].answer = 'CASH' ;
        controller.GQuestionsClass[0].poorOutcome = true ;
        controller.cashOrFinance();
        test.stopTest(); 
    } 
    
     /*static testmethod void test4(){
        createData();
        acc = [SELECT id FROM Account WHERE id=:acc.id];      
        Opportunity opp = [SELECT id,name,chi_lead_id__c from Opportunity where id=:lead.id];
        job = [select id, HSA_Name__c From Job__c where id = :job.id];
        quote = [select id,App_Assigned_To__c from BigMachines_Quote__c where id=:quote.id];
        System.debug('@@@@@@Priti'+job.HSA_Name__c);
        QMaster__c que = new QMaster__c(Options__c='CASH|FINANCE',Question_text__c='que',order__c=1,section__c='General');
        insert que;
        QAheader = new QA_header__c();
        list<selectoption> option = new  list<selectoption> ();
        option.add(new selectoption('FINANCE','FINANCE'));
        ApexPages.StandardController sc = new ApexPages.StandardController(QAheader);
        QAController controller = new QAController(sc);
        QAController.questionAnswer queAns = new QAController.questionAnswer(que,option,'priti');
        Test.setCurrentPage(new pagereference('apex/QAPage?OppoId='+opp.id));
        
        
        test.startTest();
        controller.GQuestionsClass.add(queAns);
        controller.GQuestionsClass[0].answer = 'CASH' ;
        controller.GQuestionsClass[0].poorOutcome = true ;
        controller.cashOrFinance();
        controller.save();
        test.stopTest();
    }*/
}