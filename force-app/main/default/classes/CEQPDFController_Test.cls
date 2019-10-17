@isTest
public class CEQPDFController_Test {
    
    
    static id CEQID1;
    
    static void createData(){
        
        //Create district
        District__c district= TestClassHelper.createDistrict();
        insert district;
        
        //Create account
        Account acc= TestClassHelper.createAccout();
        insert acc;
        
        //Create opportunity
        Opportunity  opp=TestClassHelper.createCHILead(Acc);
        insert opp;
        Id oppID = opp.id;
        
        //Create Quote
        BigMachines_Quote__c BMQ = TestClassHelper.createBMQuote(opp);
        insert BMQ;
        
        //Create JOB
        JOB__c job1 = TestClassHelper.createJob('planned','planned',oppID,District.id);
        job1.quote__c = BMQ.id;
        insert job1;
        id job1ID = job1.id;
        
        //Create CEQ Audit Header
        CEQ_Header__c CEQH1 = new CEQ_Header__c(job__c = job1ID);
        insert CEQH1;
        CEQID1 = CEQH1.id;
        
        //Create CEQ qustions & answers
        CEQ_Item__c CEQItem1 = new CEQ_Item__c();
            CEQItem1.CEQ_Header__c = CEQID1;
            CEQItem1.Question_Text__c = 'Test Question';
            CEQItem1.AnswerPick__c = 'Yes';
            CEQItem1.Notes__c = 'Customer notes';
            CEQItem1.Section__c = 'Customer';
        insert CEQItem1;
        
    }


    //Test Open new PDF page
    static testmethod void test1(){
        
        createData();
        test.starttest();
        pagereference pageRef = new pagereference('/apex/CEQPDFPage?CEQID='+CEQID1);
        test.setCurrentPage(pageRef);  
        CEQPDFController controller1 = new CEQPDFController();
    
    }
    
    


    
    

}