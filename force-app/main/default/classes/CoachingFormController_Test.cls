@ isTest

public class CoachingFormController_Test{
     static Employee__c emp;
     static List<QMaster__c> questions;
     static Coaching_Header__c header;
     static Coaching_Response__c res;
     
      static void createData(){
        emp = TestClassHelper.createEmployee();
        system.debug('###########emp = '+emp);
        insert emp; 
        
        questions = new List<QMaster__c>();
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='que1',options__c='Yes|No',section__c='Compliance',form__c='CoachingForm - General',section_order__c=1));
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='que2',options__c='Yes|No',section__c='Mindset',form__c='CoachingForm - General',section_order__c=2));
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='que3',options__c='Yes|No',section__c='Safety',form__c='CoachingForm - General',section_order__c=3));
        questions.add(new QMaster__c(Start_Date__c=System.today().adddays(-2),End_Date__c=System.today().adddays(2),question_text__c='que4',options__c='Yes|No',section__c='Capability',form__c='CoachingForm - General',section_order__c=4));
        insert questions;
      } 
      
      static testmethod void test1(){
          createData();
          header = new Coaching_Header__c();
          
          ApexPages.StandardController sc = new ApexPages.StandardController(header);
          CoachingFormController controller = new CoachingFormController(sc);
          
          PageReference pageRef = Page.CoachingForm;
          Test.setCurrentPage(pageRef);
          
          test.startTest();
          controller.header.Assigned_To__c = emp.id;
          controller.header.Coaching_Type__c = 'General';
          controller.save();  
      }
      
      static testmethod void test2(){
          createData();
          header = new Coaching_Header__c();
          ApexPages.StandardController sc = new ApexPages.StandardController(header);
          CoachingFormController controller = new CoachingFormController(sc);
          
          String str='data:image/png;base64,iVboRw0KGgoAAAANSUhEUgAAAlgAAABkcAYAAABaQU4jAAAFCUIEQVR4Xu3WMREAAAgDMerfNCZ+DAI65Bh+byfyfdddzdhguifrtdgc=';
          String str1='data:image/png;base64,iVboRw0KGgoAAAANSUhEUgAAAlgAAABkcAYAAABaQU4jAAAFCUIEQVR4Xu3WMREAAAgDMerfNCZ+DAI65Bh+byfyfdddzdhguifrtdgc=';

          PageReference pageRef = new pagereference('/apex/CoachingForm?encCoach='+str+'&encEmp='+str1);
          Test.setCurrentPage(pageRef);
          
          test.startTest();
          controller.header.Assigned_To__c = emp.id;
          controller.header.Coaching_Type__c = 'General';
          controller.displayQuestions();
          controller.CQuestionsClass[0].answer = 'Yes';
          controller.MQuestionsClass[0].answer = 'Yes';
          controller.SQuestionsClass[0].answer = 'Yes';
          controller.CPBQuestionsClass[0].answer = 'Yes';
          controller.header.Have_you_signed_the_form__c = true;
          controller.saveSignature();
          test.stopTest();
      }
      
      static testmethod void test3(){
          createData();
          header = new Coaching_Header__c();
          ApexPages.StandardController sc = new ApexPages.StandardController(header);
          CoachingFormController controller = new CoachingFormController(sc);
          
          String str='data:image/png;base64,iVboRw0KGgoAAAANSUhEUgAAAlgAAABkcAYAAABaQU4jAAAFCUIEQVR4Xu3WMREAAAgDMerfNCZ+DAI65Bh+byfyfdddzdhguifrtdgc=';
          String str1='data:image/png;base64,iVboRw0KGgoAAAANSUhEUgAAAlgAAABkcAYAAABaQU4jAAAFCUIEQVR4Xu3WMREAAAgDMerfNCZ+DAI65Bh+byfyfdddzdhguifrtdgc=';

          PageReference pageRef = new pagereference('/apex/CoachingForm?encCoach='+str+'&encEmp='+str1);
          Test.setCurrentPage(pageRef);
          
          test.startTest();
          controller.header.Assigned_To__c = emp.id;
          controller.header.Coaching_Type__c = 'General';
          controller.displayQuestions();
          controller.CQuestionsClass[0].answer = 'Yes';
          controller.MQuestionsClass[0].answer = 'Yes';
          controller.SQuestionsClass[0].answer = 'Yes';
          controller.CPBQuestionsClass[0].answer = 'Yes';
          controller.header.Have_you_signed_the_form__c = true;
          controller.saveSignature();
          
          header = [select id from Coaching_Header__c where Assigned_To__c=:emp.id];
          System.debug('====debugtest3===='+header.id);
          pagereference p = new pagereference('/apex/CoachingForm?signSuccess=0&email=0&headerID='+header.id);
          Test.setCurrentPage(p);
          ApexPages.StandardController sc1 = new ApexPages.StandardController(header);
          CoachingFormController controller1 = new CoachingFormController(sc1);
          controller1.save();
          test.stopTest();
      }
      
      static testmethod void test4(){
           createData();
          header = new Coaching_Header__c();
          ApexPages.StandardController sc = new ApexPages.StandardController(header);
          CoachingFormController controller = new CoachingFormController(sc);
          
          String str='data:image/png;base64,iVboRw0KGgoAAAANSUhEUgAAAlgAAABkcAYAAABaQU4jAAAFCUIEQVR4Xu3WMREAAAgDMerfNCZ+DAI65Bh+byfyfdddzdhguifrtdgc=';
          String str1='data:image/png;base64,iVboRw0KGgoAAAANSUhEUgAAAlgAAABkcAYAAABaQU4jAAAFCUIEQVR4Xu3WMREAAAgDMerfNCZ+DAI65Bh+byfyfdddzdhguifrtdgc=';

          PageReference pageRef = new pagereference('/apex/CoachingForm?encCoach='+str+'&encEmp='+str1);
          Test.setCurrentPage(pageRef);
          
          test.startTest();
          controller.header.Assigned_To__c = emp.id;
          controller.header.Coaching_Type__c = 'General';
          controller.displayQuestions();
          controller.CQuestionsClass[0].answer = 'Yes';
          controller.MQuestionsClass[0].answer = 'Yes';
          controller.SQuestionsClass[0].answer = 'Yes';
          controller.CPBQuestionsClass[0].answer = 'Yes';
          controller.header.Have_you_signed_the_form__c = true;
          controller.saveSignature();
          
          header = [select id from Coaching_Header__c where Assigned_To__c=:emp.id];
          System.debug('====debugtest3===='+header.id);
          pagereference p = new pagereference('/apex/CoachingForm?signSuccess=0&email=0&headerID='+header.id);
          Test.setCurrentPage(p);
          ApexPages.StandardController sc1 = new ApexPages.StandardController(header);
          CoachingFormController controller1 = new CoachingFormController(sc1);
          controller1.saveSignature();
          
          Test.setCurrentPage(p);
          controller1.cancel();
          
          pagereference p1 = new pagereference('/apex/CoachingForm?signSuccess=0&email=1&headerID='+header.id);
          Test.setCurrentPage(p1);
          controller1.emailTo='Priti Patil';
          controller1.emailID='Priti Patil';
          controller1.sendEmail();
          
          controller1.emailTo='Priti Patil';
          controller1.emailID='Pritibaburao.patil@cognizant.com';
          controller1.sendEmail();
          test.stopTest();
      } 
}