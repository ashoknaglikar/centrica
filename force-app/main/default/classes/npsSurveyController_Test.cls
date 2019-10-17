@isTest
public class npsSurveyController_Test {

    
    public static testMethod  void npsSurveyQuestion(){
    
        Account acc=TestClassHelper.createAccout();
        insert acc;
        
        Campaign camp =new Campaign();
        camp.Name='employee';
        camp.Group_Code__c='MEDA';
        camp.Source__c='SN';
        insert camp;
        
        opportunity testOpp= TestClassHelper.createCHILead(acc);
        testOpp.Payment_Method__c='cash';
        testOpp.Product_Interest__c ='Gas Central Heating System';
        testOpp.CampaignId=camp.Id;
        insert testOpp;
        
        BigMachines_Quote__c bmQuote=new BigMachines_Quote__c();
        bmQuote.Name='Quote test';
        bmQuote.Opportunity__c=testOpp.id;
        bmQuote.Is_Primary__c=true;
        insert bmQuote;
        
       List<QMaster__c> qMasterList =new List<QMaster__c>();
        For(integer i=0;i<3;i++){
        QMaster__c qMaster =new QMaster__c();
        qMaster.Form__c='NPS - Unsold Quotes';
        qMaster.Order__c=1+i;
        qMaster.Page_Number__c='1'+string.valueOf(i);
        qMaster.Question_Text__c='Question test %BRAND%';
        qMaster.Question_Type__c='Radio Button Horizontal';
        qMaster.Required__c='NO';
        qMaster.Options__c='0|1|2|3|4|5|6|7|8|9|10';
        qMaster.Question_Code__c='P1';
        qMaster.Campaign_Show__c='employee';
        qMaster.Start_Date__c=system.today().adddays(-1);
        qMaster.End_Date__c=system.today().adddays(1);
           qMasterList.add(qMaster) ;
        }
        insert qMasterList;
         
      
        
        IV_Vectors__c npsType=new IV_Vectors__c();
        npsType.Name='NPS1';
        npsType.Key__c='NPS - Unsold Quotes';
        insert npsType;
     
        test.startTest();
        ApexPages.currentPage().getParameters().put('LeadId', String.valueOf(testOpp.id));
        npsSurveyController nps=new npsSurveyController();
        nps.firstPage();
        nps.next();
        test.stopTest();
        
 }
   
    public static  Testmethod void surveyIsIncomplete(){
         Account acc=TestClassHelper.createAccout();
        insert acc;
        
        Campaign camp =new Campaign();
        camp.Name='employee';
        camp.Group_Code__c='MEDA';
        camp.Source__c='SN';
        insert camp;
        
        opportunity testOpp= TestClassHelper.createCHILead(acc);
        testOpp.Payment_Method__c='cash';
        testOpp.Product_Interest__c ='Gas Central Heating System';
        testOpp.CampaignId=camp.Id;
        insert testOpp;
        
        List<QMaster__c> qMasterList =new List<QMaster__c>();
        For(integer i=0;i<2;i++){
        QMaster__c qMaster =new QMaster__c();
        qMaster.Form__c='NPS - Unsold Quotes';
        qMaster.Order__c=1+i;
        qMaster.Page_Number__c='1'+string.valueOf(i);
        qMaster.Question_Text__c='Question test %BRAND%';
        qMaster.Question_Type__c='Radio Button Horizontal';
        qMaster.Required__c='NO';
        qMaster.Options__c='0|1|2|3|4|5|6|7|8|9|10';
        qMaster.Question_Code__c='P1';
        qMaster.Campaign_Show__c='employee';
        qMaster.Start_Date__c=system.today().adddays(-1);
        qMaster.End_Date__c=system.today().adddays(1);
           qMasterList.add(qMaster) ;
        }
        insert qMasterList;
        
        Survey__c survey= new Survey__c();
        survey.Opportunity__c=testOpp.id;
        Survey.Survey_Name__c='Post Install';
        survey.Status__c='incomplete';
        insert survey;
        List<Survey_Answer__c> listSurveyAnswer=new List<Survey_Answer__c> ();
        For(integer i=0;i<2;i++)
        {
       Survey_Answer__c surveyAnswer= new Survey_Answer__c();
        surveyAnswer.Question__c='Question test';
        surveyAnswer.Response__c='1';
        surveyAnswer.Question_Code__c='P1';
        surveyAnswer.Order__c=1 + i;
        surveyAnswer.Survey__c=survey.Id;
        listSurveyAnswer.add(surveyAnswer);
        }
        insert listSurveyAnswer;
        
        IV_Vectors__c npsType=new IV_Vectors__c();
        npsType.Name='NPS1';
        npsType.Key__c='NPS - Unsold Quotes';
        insert npsType;
        
         test.startTest();
        ApexPages.currentPage().getParameters().put('LeadId', testOpp.id);
        npsSurveyController nps=new npsSurveyController();
        nps.firstPage();
        nps.next(); 
        nps.previous();
        test.stopTest();
    } 
    
    public static  Testmethod void chiLEADIsNull(){
         Account acc=TestClassHelper.createAccout();
        insert acc;
        
        Campaign camp =new Campaign();
        camp.Name='employee';
        camp.Group_Code__c='MEDA';
        camp.Source__c='SN';
        insert camp;
        
        opportunity testOpp= TestClassHelper.createCHILead(acc);
        testOpp.Payment_Method__c='cash';
        testOpp.Product_Interest__c ='Gas Central Heating System';
        testOpp.CampaignId=camp.Id;
        insert testOpp;
        
        IV_Vectors__c npsType=new IV_Vectors__c();
        npsType.Name='NPS1';
        npsType.Key__c='NPS - Unsold Quotes';
        insert npsType;
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('LeadId', '');
        npsSurveyController nps=new npsSurveyController();
        
        test.stopTest();
    } 
    

    public static  Testmethod void Finish(){
         Account acc=TestClassHelper.createAccout();
        insert acc;
        
        Campaign camp =new Campaign();
        camp.Name='employee';
        camp.Group_Code__c='MEDA';
        camp.Source__c='SN';
        insert camp;
        
        opportunity testOpp= TestClassHelper.createCHILead(acc);
        testOpp.Payment_Method__c='cash';
        testOpp.Product_Interest__c ='Gas Central Heating System';
        testOpp.CampaignId=camp.Id;
        insert testOpp;
        
        QMaster__c qMaster =new QMaster__c();
        qMaster.Form__c='NPS - Unsold Quotes';
        qMaster.Order__c=1;
        qMaster.Page_Number__c='1';
        qMaster.Question_Text__c='Question test';
        qMaster.Question_Type__c='Radio Button Horizontal';
        qMaster.Required__c='NO';
        qMaster.Options__c='0|1|2|3|4|5|6|7|8|9|10';
        qMaster.Question_Code__c='P1';
        qMaster.Campaign_Show__c='employee';
        qMaster.Start_Date__c=system.today().adddays(-1);
        qMaster.End_Date__c=system.today().adddays(1);
        insert qMaster;
        
        Survey__c survey= new Survey__c();
        survey.Opportunity__c=testOpp.id;
        Survey.Survey_Name__c='Post Install';
        survey.Status__c='incomplete';
        insert survey;
       
       Survey_Answer__c surveyAnswer= new Survey_Answer__c();
        surveyAnswer.Question__c='Question test %BRAND%';
        surveyAnswer.Response__c='1';
        surveyAnswer.Question_Code__c='P1';
        surveyAnswer.Order__c=1 ;
        surveyAnswer.Survey__c=survey.Id;
       insert surveyAnswer;
        
        IV_Vectors__c npsType=new IV_Vectors__c();
        npsType.Name='NPS1';
        npsType.Key__c='NPS - Unsold Quotes';
        insert npsType;
        
         test.startTest();
        ApexPages.currentPage().getParameters().put('LeadId', testOpp.id);
        npsSurveyController nps=new npsSurveyController();
        nps.firstPage();
        nps.next();        
        test.stopTest();
    }
    public static  Testmethod void saveSurveyOnFinish(){
         Account acc=TestClassHelper.createAccout();
        insert acc;
        
        Campaign camp =new Campaign();
        camp.Name='employee';
        camp.Group_Code__c='MEDA';
        camp.Source__c='SN';
        insert camp;
        
        opportunity testOpp= TestClassHelper.createCHILead(acc);
        testOpp.Payment_Method__c='cash';
        testOpp.Product_Interest__c ='Gas Central Heating System';
        testOpp.CampaignId=camp.Id;
        insert testOpp;
        
        QMaster__c qMaster =new QMaster__c();
        qMaster.Form__c='NPS - Unsold Quotes';
        qMaster.Order__c=1;
        qMaster.Page_Number__c='1';
        qMaster.Question_Text__c='Question test %BRAND%';
        qMaster.Question_Type__c='Radio Button Horizontal';
        qMaster.Required__c='no';
        qMaster.NPS_Options_Text__c='0|1|2|3|4|5|6|7|8|9|10';
        qMaster.Question_Code__c='P1';
        qMaster.Campaign_Show__c='employee';
        qMaster.Start_Date__c=system.today().adddays(-1);
        qMaster.End_Date__c=system.today().adddays(1);
        insert qMaster;
        
        Survey__c survey= new Survey__c();
        survey.Opportunity__c=testOpp.id;
        Survey.Survey_Name__c='Post Install';
        survey.Status__c='incomplete';
        insert survey;
       
      
        IV_Vectors__c npsType=new IV_Vectors__c();
        npsType.Name='NPS1';
        npsType.Key__c='NPS - Unsold Quotes';
        insert npsType;
        
         test.startTest();
        ApexPages.currentPage().getParameters().put('LeadId', testOpp.id);
        npsSurveyController nps=new npsSurveyController();
        nps.firstPage();
        nps.next();       
        test.stopTest();
    }
    
    public static  Testmethod void surveyStatusComplete(){
         Account acc=TestClassHelper.createAccout();
        insert acc;
        
        opportunity testOpp= TestClassHelper.createCHILead(acc);
        testOpp.Payment_Method__c='cash';
        testOpp.Product_Interest__c ='Gas Central Heating System';
        insert testOpp; 
        Survey__c survey= new Survey__c();
        survey.Opportunity__c=testOpp.id;
        Survey.Survey_Name__c='Post Install';
        survey.Status__c='complete';
        insert survey;
        
        
         test.startTest();
        ApexPages.currentPage().getParameters().put('LeadId', testOpp.id);
        npsSurveyController nps=new npsSurveyController();
        test.stopTest();
        
    }
    public static  Testmethod void requiredQuestion(){
         Account acc=TestClassHelper.createAccout();
        insert acc;
        
        Campaign camp =new Campaign();
        camp.Name='employee';
        camp.Group_Code__c='MEDA';
        camp.Source__c='SN';
        insert camp;
        
        opportunity testOpp= TestClassHelper.createCHILead(acc);
        testOpp.Payment_Method__c='cash';
        testOpp.Product_Interest__c ='Gas Central Heating System';
        testOpp.CampaignId=camp.Id;
        insert testOpp;
        
        QMaster__c qMaster =new QMaster__c();
        qMaster.Form__c='NPS - Unsold Quotes';
        qMaster.Order__c=1;
        qMaster.Page_Number__c='1';
        qMaster.Question_Text__c='Question test %BRAND%';
        qMaster.Question_Type__c='Radio Button Horizontal';
        qMaster.Required__c='yes';
        qMaster.NPS_Options_Text__c='0|1|2|3|4|5|6|7|8|9|10';
        qMaster.Question_Code__c='P1';
        qMaster.Campaign_Show__c='employee';
        qMaster.Start_Date__c=system.today().adddays(-1);
        qMaster.End_Date__c=system.today().adddays(1);
        insert qMaster;
        
        Survey__c survey= new Survey__c();
        survey.Opportunity__c=testOpp.id;
        Survey.Survey_Name__c='Post Install';
        survey.Status__c='incomplete';
        insert survey;
       
      
        IV_Vectors__c npsType=new IV_Vectors__c();
        npsType.Name='NPS1';
        npsType.Key__c='NPS - Unsold Quotes';
        insert npsType;
        
         test.startTest();
        ApexPages.currentPage().getParameters().put('LeadId', testOpp.id);
        npsSurveyController nps=new npsSurveyController();
        nps.firstPage();
        nps.next();       
        test.stopTest();
    }
    
}