@ isTest

public class WIPController_Test{
     static Employee__c emp;
     static job__c job;
     static List<QMaster__c> questions;
     static WIP_Header__c header;
     static WIP_Response__c res;
     
      static void createData(){
        emp = TestClassHelper.createEmployee();
        system.debug('###########emp = '+emp);
        insert emp; 
        
        Account acc= TestClassHelper.createAccout();
        system.debug('###########acc = '+acc);
        insert acc;
        Opportunity  opp=TestClassHelper.createCHILead(Acc);
        opp.Surveys_taken__c = '';
        insert opp;
        Id optyId=opp.id;
        District__c district= TestClassHelper.createDistrict();
        insert district;
        
        job = TestClassHelper.createJob('planned','planned',optyId,District.id);
        //job.Region__c='east';
        job.Account__c=acc.id;
        system.debug('###########job = '+job);
        Database.SaveResult sr = Database.insert(job, false);
        system.debug('######sr'+sr);
                
        questions = new List<QMaster__c>();
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='Are you there to carry out a survey?',options__c='Yes|No',section__c='pre-installation Visit',form__c='WIPForm',section_order__c=1));
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='Vehicle - Is it clean, tidy and parked correctly?',options__c='Yes|No',section__c='Installation- Work in Progress Visit',form__c='WIPForm',section_order__c=3));
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='Waste - has this been left in a safe, secure and tidy position and the engineer followed the waste process?',options__c='Yes|No',section__c='Installation- Post Completion Visit',form__c='WIPForm',section_order__c=4));
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='H.S.A visit - Was this to the customers satisfaction?',options__c='Yes|No',section__c='Customer- Work In Progress Visit',form__c='WIPForm',section_order__c=5));
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='H.S.A visit - Was this to the customers satisfaction?',options__c='Yes|No',section__c='Customer- Post Completion Visit',form__c='WIPForm',section_order__c=6));
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='Have you raised a job for any Remedial/Recall work required?',options__c='Yes|No',section__c='Outcome/Actions',form__c='WIPForm', section_order__c=7));
        //questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2), question_text__c='que7',options__c='Yes|No',section__c='Follow Up',form__c='WIP',section_order__c=7));
        
        Database.SaveResult[] sr1 = Database.insert(questions, false);
        system.debug('----------------->job'+job.id);
        system.debug('######questions'+questions);
      } 
      
      static testmethod void test1(){
          createData();
          header = new WIP_Header__c();
          header.job__c=job.id;
          system.debug('-------->job'+job.id);
          ApexPages.StandardController sc = new ApexPages.StandardController(header);
          WIPController controller = new WIPController(sc);
                    
          PageReference pageRef = Page.WIPForm;
          Test.setCurrentPage(pageRef);
         
          test.startTest();
            controller.header.job__c=job.id;
           
            //controller.header.Assigned_To__c = emp.id;
            controller.header.WIP_Type__c = 'Pre-Install Survey';
             controller.displayQuestions();
              System.debug('====debugtest6===='+header.id);
              PageReference p = Page.WIPForm;
              Test.setCurrentPage(p);
              ApexPages.StandardController sc1 = new ApexPages.StandardController(header);
              WIPController controller1 = new WIPController(sc1);
              controller1 .fileName='Unit Test Attachment';
              controller1 .upload();
            
              List<Attachment> attachments=[select id, name from Attachment where parent.id=:header.id];
          
          controller.save(); 
          
          test.stopTest(); 
      }
      
     static testmethod void test2(){
          createData();
          header = new WIP_Header__c();
          header.job__c=job.id;
          ApexPages.StandardController sc = new ApexPages.StandardController(header);
          WIPController controller = new WIPController(sc);
          
          PageReference pageRef = Page.WIPForm;
          Test.setCurrentPage(pageRef);
          
          test.startTest();
          
          controller.header.job__c = job.id;
          //controller.header.Assigned_To__c = emp.id;
          controller.header.WIP_Type__c = 'Pre-Install Survey';
          controller.displayQuestions();
          controller.section1QuestionClass[0].answer = 'Yes';
          controller.section7QuestionClass[0].answer = 'Yes';
          controller.save();
          
          header = [select id from WIP_Header__c where job__c=:job.id];
          System.debug(';'+header.id);
          PageReference p = Page.WIPForm;
          Test.setCurrentPage(p);
          ApexPages.StandardController sc1 = new ApexPages.StandardController(header);
          WIPController controller1 = new WIPController(sc1);
          controller1 .fileName='Unit Test Attachment';
          controller1 .upload();
        
          List<Attachment> attachments=[select id, name from Attachment where parent.id=:header.id];
          
          controller1 .cancel();
          test.stopTest();
      }
      static testmethod void test3(){
          createData();
          header = new WIP_Header__c();
          header.job__c=job.id;
          ApexPages.StandardController sc = new ApexPages.StandardController(header);
          WIPController controller = new WIPController(sc);
          
          PageReference pageRef = Page.WIPForm;
          Test.setCurrentPage(pageRef);
          
          test.startTest();
          
          controller.header.job__c = job.id;
          //controller.header.Assigned_To__c = emp.id;
          controller.header.WIP_Type__c = 'Pre-Install Survey';
          controller.displayQuestions();
          controller.section1QuestionClass[0].answer = 'Yes';
          controller.section7QuestionClass[0].answer = 'Yes';
          controller.save();
          
          PageReference p = new pagereference('/apex/WIPForm?signSuccess=1&headerID='+header.id);
          Test.setcurrentpage(p);
          ApexPages.StandardController sc1 = new ApexPages.StandardController(header);
          WIPController controller1 = new WIPController (sc1);
          controller1.methodtest();
          controller1.save();
          controller1.emailID='ashok gajapathi';
          controller1.sendemail();
          controller1.emailid= 'ashok.gajapathi@cognizant.com';
          controller1.sendemail();
          test.stopTest();
      }
     
      static testmethod void test4(){
          createData();
          header = new WIP_Header__c();
          header.job__c=job.id;
          ApexPages.StandardController sc = new ApexPages.StandardController(header);
          WIPController controller = new WIPController(sc);
          
          PageReference pageRef = Page.WIPForm;
          Test.setCurrentPage(pageRef);
          
          test.startTest();
          
          controller.header.job__c = job.id;
          //controller.header.Assigned_To__c = emp.id;
          controller.header.WIP_Type__c = 'Post-Install Survey';
          controller.displayQuestions();
          controller.section4QuestionClass[0].answer = 'Yes';
          controller.section6QuestionClass[0].answer = 'Yes';
          controller.section7QuestionClass[0].answer = 'Yes';
          controller.save();
          
          System.debug('====debugtest4===='+header.id);
          pagereference p = new pagereference('/apex/WIPForm?signSuccess=0&headerID='+header.id);
          Test.setCurrentPage(p);
          ApexPages.StandardController sc1 = new ApexPages.StandardController(header);
          WIPController controller1 = new WIPController (sc1);
          controller1.methodtest();
          controller1.save();
          test.stopTest();
      }
      
      static testmethod void test5(){
          createData();
          header = new WIP_Header__c();
          header.job__c=job.id;
          ApexPages.StandardController sc = new ApexPages.StandardController(header);
          WIPController controller = new WIPController(sc);
          
          PageReference pageRef = Page.WIPForm;
          Test.setCurrentPage(pageRef);
          
          test.startTest();
          
          controller.header.job__c = job.id;
          //controller.header.Assigned_To__c = emp.id;
          controller.header.WIP_Type__c = 'In Progress Survey';
          controller.displayQuestions();
          controller.section3QuestionClass[0].answer = 'Yes';
          controller.section5QuestionClass[0].answer = 'Yes';
          controller.section7QuestionClass[0].answer = 'Yes';
          controller.save();
          
          System.debug('====debugtest5===='+header.id);
          pagereference p = new pagereference('/apex/WIPForm?signSuccess=1&headerID='+header.id);
          Test.setCurrentPage(p);
          ApexPages.StandardController sc1 = new ApexPages.StandardController(header);
          WIPController controller1 = new WIPController (sc1);
          controller1.save();
          
          test.stopTest();
      }
      
   
}