/*
 * Test class created for CEQPage Screen & CEQController
 * Created by Phil Dennison
 */
@isTest/*(SeeAllData=true)*/
private class CEQController_Test {

        static account acc;  
        static contact con;
        static opportunity opp;
        static BigMachines_Quote__c bm;
        static quote_product__c bmprod;
        static job__c job; 
        static CEQ_Header__c Audit,Cqheader ; 
        static CEQ_Item__c Citem,Citem1,Citem2,Citem3,Citem4;
        static QMaster__c qmaster;
        
         

     public static void createData(){
        acc = TestClassHelper.createAccout();
        insert acc;
        
        opp = TestClassHelper.createCHILead(acc);
        insert opp;

        bm = TestClassHelper.createBMQuote(opp);
        bm.Job_Type_Description__c = 'Job Description';
        insert bm;
        
        bmprod = TestClassHelper.createQuoteProduct(bm.id);
        bmprod.installationNotes__c = 'Boiler note';
        insert bmprod; 
        
        District__c ds= TestClassHelper.createDistrict();
        insert ds;
        
        job = TestClassHelper.createJob('Planned','Planned',opp.Id, ds.id);
        job.quote__c = bm.id;
        insert job; 
        
        Cqheader = new CEQ_Header__c(Job__c=job.id,Mechanical_Employees__c='Phil Dennison - 15154');
        insert Cqheader ; 
        
        Citem= new CEQ_Item__c (CEQ_Header__c=Cqheader.id,Section__c='Sales',AnswerPick__c='This is me',Notes__c='This is you',Options__c='This is we',Order__c=22,Question_Text__c='This is all',Question_Code__c='This is world',Report_Text__c='This is uni',Version__c=22);   
        
        Citem1= new CEQ_Item__c (CEQ_Header__c=Cqheader.id,Section__c='Customer',AnswerPick__c='This is me',Notes__c='This is you',Options__c='This is we',Order__c=22,Question_Text__c='This is all',Question_Code__c='This is world',Report_Text__c='This is uni',Version__c=22);   
        
        Citem2= new CEQ_Item__c (CEQ_Header__c=Cqheader.id,Section__c='Other',AnswerPick__c='This is me',Notes__c='This is you',Options__c='This is we',Order__c=22,Question_Text__c='This is all',Question_Code__c='This is world',Report_Text__c='This is uni',Version__c=22);   
        
        Citem3= new CEQ_Item__c (CEQ_Header__c=Cqheader.id,Section__c='Installation',AnswerPick__c='This is me',Notes__c='This is you',Options__c='This is we',Order__c=22,Question_Text__c='This is all',Question_Code__c='This is world',Report_Text__c='This is uni',Version__c=22); 
        
        Citem4 = new CEQ_Item__c (CEQ_Header__c=Cqheader.id,Section__c='RQM',AnswerPick__c='This is me',Notes__c='This is you',Options__c='This is we',Order__c=22,Question_Text__c='This is all',Question_Code__c='This is world',Report_Text__c='This is uni',Version__c=22);
          
        insert new list<CEQ_Item__c>{Citem,Citem1,Citem2,Citem3,Citem4};
        
        QMaster__c qmaster1= new QMaster__c(Section__c='Other',End_Date__c=system.today()+5,Form__c='EQ',Options__c='This is',Order__c=1,Question_Text__c='all',Report_Text__c='well',Start_Date__c=system.today(),Version__c=34);
        QMaster__c qmaster2= new QMaster__c(Section__c='Sales',End_Date__c=system.today()+5,Form__c='EQ',Options__c='This is',Order__c=2,Question_Text__c='all',Report_Text__c='well',Start_Date__c=system.today(),Version__c=34);
        QMaster__c qmaster3= new QMaster__c(Section__c='Customer',End_Date__c=system.today()+5,Form__c='EQ',Options__c='This is',Order__c=3,Question_Text__c='all',Report_Text__c='well',Start_Date__c=system.today(),Version__c=34);
        QMaster__c qmaster4= new QMaster__c(Section__c='Installation',End_Date__c=system.today()+5,Form__c='EQ',Options__c='This is',Order__c=4,Question_Text__c='all',Report_Text__c='well',Start_Date__c=system.today(),Version__c=34);
        QMaster__c qmaster5= new QMaster__c(Section__c='Sales',End_Date__c=system.today()+5,Form__c='EQ',Options__c='This is',Order__c=5,Question_Text__c='all',Report_Text__c='well',Start_Date__c=system.today(),Version__c=34);
        QMaster__c qmaster6= new QMaster__c(Section__c='RQM',End_Date__c=system.today()+5,Form__c='EQ',Options__c='This is',Order__c=6,Question_Text__c='all',Report_Text__c='well',Start_Date__c=system.today(),Version__c=34);
        
       
       
        insert new list<QMaster__c>{ qmaster1,qmaster2,qmaster3,qmaster4,qmaster5,qmaster6};
    }
    
    static testMethod void createTestData(){        
        createData();
        test.starttest();
        pagereference pageRef = new pagereference('/apex/CEQPage?CEQID='+Cqheader.id+'&jobID='+job.Id);
        test.setCurrentPage(pageRef);  
        CEQController controller1 = new CEQController();

        controller1.searchString = opp.chi_lead_id__c;
        controller1.search();
        controller1.errorMsg = 'Exception occurred';
        controller1.setErrorMsg();
        controller1.mandatoryCheck();
        
        pagereference pageRef1 = new pagereference('/apex/CEQPage?jobID='+job.Id);
        test.setCurrentPage(pageRef1); 
        controller1.showCustomerSelection();
        controller1.FileName = 'TestFile';
        controller1.upload();
        controller1.cancel();
     
       CEQController controller2 = new CEQController();
       controller2.searchString = opp.chi_lead_id__c;
       controller2.search();
       controller2.errorMsg = 'Exception occurred';
       controller2.setErrorMsg(); 

       CEQController controller3 = new CEQController();
       controller3.searchString = 'test123';
       controller3.search();
       controller3.errorMsg = 'Exception occurred';
       controller3.setErrorMsg();        
   
       CEQController controller5 = new CEQController();
       controller5.searchString = opp.chi_lead_id__c;
       controller5.search();
       controller5.customerUnavailable = false;
       controller5.headerCreated = false;
        for(CEQController.questionAnswer QM : controller5.OQuestionsClass){
            QM.answer = 'Yes';
        }
        for(CEQController.questionAnswer QM : controller5.SQuestionsClass){
            QM.answer = 'Yes';
        }
        for(CEQController.questionAnswer QM : controller5.CQuestionsClass){
            QM.answer = 'Yes';           
        }
        for(CEQController.questionAnswer QM : controller5.IQuestionsClass){
            QM.answer = 'Yes';
        }
        controller5.save();
        
       
        pagereference pageRef3 = new pagereference('/apex/CEQPage?CEQID='+ Cqheader.id +'&jobID='+job.Id);
        test.setCurrentPage(pageRef3);
        CEQController controller55 = new CEQController();
        
        for(CEQController.questionAnswer ceqClassVar: controller55.IQuestionsClass)
        {
            ceqClassVar.answer = 'Yes';
        }
        controller55.save();
    
        CEQController controller6 = new CEQController();
        controller6.jobID = job.id;
        controller6.customerUnavailable = false;
        controller6.errorMsg = 'Exception occurred';
        controller6.setErrorMsg();
        
       
        pagereference pageRef2 = new pagereference('/apex/CEQPage');
        test.setCurrentPage(pageRef2);     
        CEQController controller7 = new CEQController();
        controller7.customerUnavailable = TRUE;
        controller7.searchString = opp.chi_lead_id__c;
        controller7.search();
        string chiLeadNum = [select chi_lead_id__c from Opportunity where id = :opp.Id ].chi_lead_id__c;
        controller7.searchString = chiLeadNum;
        controller7.search();
        controller7.errorMsg = 'Exception occurred';
        controller7.setErrorMsg();
        controller7.mandatoryCheck();
        test.stoptest();                        

    }
    
   
    
     static testmethod void test1(){
        createData();
        pagereference pageRef = new pagereference('/apex/CEQPage');
        test.setCurrentPage(pageRef);  
        CEQController controller = new CEQController();
        opp = [Select chi_lead_id__c from Opportunity where id=:opp.id];
        controller.searchString = opp.chi_lead_id__c;
        controller.search();
        controller.save();

    }
    
     static testMethod void createTestData1()
     
     {  
       acc = TestClassHelper.createAccout();
       insert acc;
          
       opp = TestClassHelper.createCHILead(acc);
       insert opp;
        
       District__c ds= TestClassHelper.createDistrict();
       insert ds;
       
       bm = TestClassHelper.createBMQuote(opp);
       bm.Job_Type_Description__c = 'Job Description';
       insert bm;
       
       job = TestClassHelper.createJob('Planned','Planned', opp.id, ds.id);
       job.quote__c = bm.id;
       insert job;
        
       CEQ_Header__c Cqheader1 = new CEQ_Header__c(Job__c=job.id,Mechanical_Employees__c='Phil Dennison - 15154');
       insert Cqheader1 ; 
       
       Quote_Product__c qp = TestClassHelper.createQuoteProduct(bm.id);
       qp.bigmachines_quote__c=job.quote__c;
       insert qp;
        
       QMaster__c qmaster1= new QMaster__c(End_Date__c=system.today()+5,Form__c='EQ',Options__c='This is',Order__c=22,Question_Text__c='all',Report_Text__c='well',Start_Date__c=system.today(),Version__c=34);
       qmaster1.Section__c='Other';
       insert qmaster1;

       pagereference pageRef1 = new pagereference('/apex/CEQPage?jobID='+job.Id);
       test.setCurrentPage(pageRef1);
       CEQController controller1 = new CEQController();
       controller1.FileName = 'TestFile';
       controller1.upload();
       controller1.customerUnavailable = false;
       controller1.save();

 }

}