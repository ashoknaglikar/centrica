public class sendNPSDataController {
    public ID npsId;
    Public List<NPS__c> npsList = new List<NPS__c>();
    public SendSurveyDataBatch batch = new SendSurveyDataBatch();
   
     public sendNPSDataController(ApexPages.StandardController controller) {
        npsId = ApexPages.currentPage().getParameters().get('id');
        if(npsId!=null)
        {
           npsList = [Select id,Appointment__c,Appointment__r.name,job__C,job__r.name,HSA_Payroll__c,Mechanical_Engineer_1_Pay_Number__c,Mechanical_Engineer_2_Pay_Number__c,Product_Interest__c,
                      Step1_Score_Dup__c,Step2_Score__c,Step1_Comments__c,createddate,source__c,CHI_Lead_Number__c,opportunity__c from NPS__c where id=:npsId];
        }

    }
    
    
    public void sendNPSData()
    {
        List<NPS__c> npsListToUpdate = new List<NPS__c>();
        if(!npsList.isEmpty())
        {
             if(npsList[0].source__c=='Sales Appointment')
             {
                 npsListToUpdate.addAll(batch.processReqHSA(npsList));
             }
             else if(npsList[0].source__c=='Job Installation')
             {
                npsListToUpdate.addAll(batch.processReqInstaller(npsList));
             }
        }
        
        if(!npsListToUpdate.isEmpty())
        database.update(npsListToUpdate);
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The NPS survey data has been successfully sent to Virtuatel.'));
    }
    
    public pageReference back()
    {
        PageReference pageRef = new PageReference('/'+npsId); 
        pageRef.setRedirect(true);      
        return pageRef;
    }
}