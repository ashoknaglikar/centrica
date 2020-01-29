global class SendSurveyDataBatch implements database.batchable<sobject>,Database.AllowsCallouts,Database.Stateful{
                                                                 
    Map<string, integer> productInterestMap = new map<string,integer>();                                                             
    
    global SendSurveyDataBatch()
    {
        if(system.label.VirtuaTelProductInterestMap.contains('|'))
        {
          for(string s: system.label.VirtuaTelProductInterestMap.split('\\|'))
          {
              list<string> PIorder =s.split('>');
              productInterestMap.put(PIorder[0],integer.valueOf(PIorder[1]));
          }
        }
        system.debug('productInterestMap '+productInterestMap);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string query = 'Select id,Appointment__c,Appointment__r.name,job__C,job__r.name,HSA_Payroll__c,Mechanical_Engineer_1_Pay_Number__c,Mechanical_Engineer_2_Pay_Number__c,Product_Interest__c,Step1_Score_Dup__c,Step2_Score__c,Step1_Comments__c,createddate,source__c,CHI_Lead_Number__c,opportunity__c from NPS__c where Integration_Status__c=\'Ready to be Sent\' ';
       // string query = 'Select id,Appointment__c,Appointment__r.name,job__C,job__r.name,HSA_Payroll__c,Mechanical_Engineer_1_Pay_Number__c,Mechanical_Engineer_2_Pay_Number__c,Product_Interest__c,Step1_Score_Dup__c,Step2_Score__c,Step1_Comments__c,createddate,source__c,CHI_Lead_Number__c,opportunity__c from NPS__c where source__c=\'Sales Appointment\' and integration_datetime__c=null and step2_Score__c!=null and step1_score_Dup__c!=null order by createddate desc limit 50  ';
        //string query = 'Select id,Appointment__c,Appointment__r.name,job__C,job__r.name,HSA_Payroll__c,Mechanical_Engineer_1_Pay_Number__c,Mechanical_Engineer_2_Pay_Number__c,Product_Interest__c,Step1_Score_Dup__c,Step2_Score__c,Step1_Comments__c,createddate,source__c,CHI_Lead_Number__c,opportunity__c from NPS__c where  source__c=\'Job Installation\' and integration_datetime__c=null and step2_Score__c!=null and step1_score_Dup__c!=null order by createddate desc   ';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC,  List<NPS__c> lstRecords)
    {
        List<NPS__c> npsListHSA = new List<NPS__c>();
        List<NPS__c> npsListInstaller = new List<NPS__c>();
        List<NPS__c> npsListToUpdate = new List<NPS__c>();
        
        for(NPS__c nps:lstRecords)
        {
            if(nps.source__c=='Sales Appointment')
               npsListHSA.add(nps); 
            
            else if(nps.source__c=='Job Installation')
               npsListInstaller.add(nps);
        }
        
        if(!npsListHSA.isEmpty())
        {
             npsListToUpdate.addAll(processReqHSA(npsListHSA));
        }
        if(!npsListInstaller.isEmpty())
        {
             npsListToUpdate.addAll(processReqInstaller(npsListInstaller));
        }
        
        if(!npsListToUpdate.isEmpty())
        database.update(npsListToUpdate);
    }
    
    global void finish(Database.BatchableContext bc)
    {
      AsyncApexJob a = [Select Id, Status, ExtendedStatus,NumberOfErrors,TotalJobItems from AsyncApexJob where Id = :bc.getJobId()];
      list<string> toaddress = new list<string>{userinfo.getUserEmail()};
       if(a.NumberOfErrors>0)
       {
           CreateEmail.CretaeSendTextEmail(toaddress, 'Error in Sending NPS data to Virtuatel.',  'NPS Survey Data to Virtuatel');
       }
    }
    
    public List<NPS__c> processReqHSA(List<NPS__C> npsListHSA)
    {
        NpsSurveyData npsWrapperHSA = new NpsSurveyData();
        npsWrapperHSA.skey =system.label.SurveyKey_HSA;
         for(NPS__c nps: npsListHSA)
         {
             npsWrapperHSA.surveys.add(prepareWrap(nps));
         }
         
         Httpresponse HsaResponse = sendNpsSurveyData(npsWrapperHSA);
         return updateNPS(HsaResponse,npsListHSA);
    }
    
     public List<NPS__c> processReqInstaller(List<nps__c> npsListInstaller)
    {
        NpsSurveyData npsWrapperInstaller = new NpsSurveyData();
        npsWrapperInstaller.skey =system.label.SurveyKey_Installer;
         for(NPS__c nps: npsListInstaller)
         {
             npsWrapperInstaller.surveys.add( prepareWrap(nps));
         }
        Httpresponse InstallerResponse = sendNpsSurveyData(npsWrapperInstaller);
        return updateNPS(InstallerResponse,npsListInstaller);
    }
    
    public surveyData prepareWrap(NPS__c nps)
    {
             surveyData surveyWrap = new surveyData();
             surveyWrap.starttime = nps.createddate.format('yyyy-MM-dd HH:mm:ss');
             surveyWrap.endtime = nps.createddate.format('yyyy-MM-dd HH:mm:ss'); 
             surveyWrap.reference = nps.CHI_Lead_Number__c; 
             
             List<surveyQuestions> sQuestionsList = new List<surveyQuestions>();
             
             if(nps.source__c=='Job Installation')
             {
                 surveyWrap.agentid = nps.Mechanical_Engineer_1_Pay_Number__c;
                 if(nps.job__c!=null)
                 {
                    surveyQuestions sQuestions1 = new surveyQuestions(50214,nps.job__r.name,null);
                    sQuestionsList.add(sQuestions1);
                 }
                 if(nps.Mechanical_Engineer_2_Pay_Number__c!=null)
                 {
                    surveyQuestions sQuestions2 = new surveyQuestions(50210,nps.Mechanical_Engineer_2_Pay_Number__c,null);
                    sQuestionsList.add(sQuestions2);
                 }
             }
             else if(nps.source__c=='Sales Appointment')
             {
                 surveyWrap.agentid = nps.HSA_Payroll__c;
                 if(nps.Appointment__c!=null)
                 {
                     surveyQuestions sQuestions1 = new surveyQuestions(50214,nps.Appointment__r.name,null);
                     sQuestionsList.add(sQuestions1);
                 }
             }
             
             if(nps.Step1_Score_Dup__c!=null)
             {
                surveyQuestions sQuestions3 = new surveyQuestions(1365,null,integer.valueOf(nps.Step1_Score_Dup__c));
                sQuestionsList.add(sQuestions3);
             }
             if(nps.Step2_Score__c!=null)
             {
                surveyQuestions sQuestions4 = new surveyQuestions(1777,null,integer.valueOf(nps.Step2_Score__c));
                sQuestionsList.add(sQuestions4);
             }
             if(nps.Step1_Comments__c!=null)
             {
               surveyQuestions sQuestions5 = new surveyQuestions(1367,nps.Step1_Comments__c,null);
               sQuestionsList.add(sQuestions5);
             }
             
             Integer productInterest = productInterestMap.containsKey(nps.Product_Interest__c)?productInterestMap.get(nps.Product_Interest__c):99;
             surveyQuestions sQuestions6 = new surveyQuestions(50212,null,productInterest);
             sQuestionsList.add(sQuestions6);
             
             
             surveyWrap.questions = sQuestionsList;
             return surveyWrap;
    }
    
    public List<NPS__c> updateNPS(Httpresponse response, List<NPS__c> npsList)
    {
        String IntegrationStatus;
        List<String> responseIdsList;
        if(response.getStatusCode()==200)
        {
            IntegrationStatus='Success';
            String responseBody = response.getbody();
            if(responseBody.contains('record inserted '))
            {
               responseBody = responseBody.removeStart('record inserted ');
               responseIdsList = responsebody.split('record inserted ');
            }
            
        }
        else
        {
            IntegrationStatus= 'Errored';
        }
        
        for(integer i=0;i<npsList.size();i++)
        {
             if(responseIdsList!=null && responseIdsList.size()==npsList.size())
             {
                npsList[i].Integration_Id__c= responseIdsList[i];
             }
             npsList[i].Integration_DateTime__c = system.now();
             npsList[i].Integration_Status__c =IntegrationStatus;
        }
        return npsList;
    }
    
    
     public class surveyQuestions
     {
         public integer id;
         public string response;
         public integer  keyresponse;
         public surveyQuestions(integer id,string response,integer keyresponse){
             this.id=id;
             this.response= response;
             this.keyresponse= keyresponse;
         }
     }
     public class surveyData{
         public string  phonenumber;
         public String agentid;
         public String reference;
         public string starttime;
         public String endtime;
         public List<surveyQuestions> questions;
         public surveyData(){}
     }
    
     public class NpsSurveyData     
     {
        public String skey;
        public List<surveyData> surveys = new List<surveyData>();
        public NpsSurveyData()
        {
        }
    }
    
   public string endPointURL = system.label.VirtuatelEndPointURL;
   public HttpResponse sendNpsSurveyData(NpsSurveyData npsWrap){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPointURL);
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');
        String serialWZ = JSON.serialize(npsWrap,true);
        system.debug('JSON ==>  '+serialWZ);
        request.setBody(serialWZ);
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        system.debug('Response ==>  '+response);
        system.debug('Responsebody ==>  '+response.getbody());
        return response;
    }
}