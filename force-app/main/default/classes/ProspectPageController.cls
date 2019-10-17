public with sharing class ProspectPageController {

    public list<Lead> Leadlist = new list<Lead>();  
    private MessageConstants errorMsg;
    public List<LeadSelectClass> LeadClassList;
    public Account Acc;
    public DisplayMode DisplayMode{get; set;}
    String errMsg;
    String callID;
    
    public  ProspectPageController()
    {   
        callID = System.currentPageReference().getParameters().get('c'); 
        system.debug('---->callid'+callID);
        DisplayMode = new DisplayMode();
        if(callID != null || callID != '')
        {   
            Inbound_Call__c call = [Select Workflow_Type__c, Billing_Zip__c, Billing_Street__c, Billing_State__c, Billing_City__c, Billilng_Country__c From Inbound_Call__c where Id =:callID ];
            String AccountName = call.Billing_Zip__c.trim() + '  ';
            String str2 = call.Billing_Street__c.trim(); // 2 space in between
           // if( str2.length() > 8) 
            //    AccountName += str2.substring(0,8).trim(); // 2 space in between
           // else
                AccountName += str2;
            
           Leadlist = [Select Status, Phone, Reason_Code__c,Call_Back_Date__c, Name,Enquiry_Num__c, CreatedDate,Account_Key_Calc__c From Lead where Account_Key_Calc__c =:AccountName and (Status != 'Closed' and Status != 'Qualified')  and Lead_Type__c = 'Prospect' order by CreatedDate ];
           acc = new Account();
           acc.BillingPostalCode = call.Billing_Zip__c;
           acc.BillingStreet = call.Billing_Street__c;
           acc.BillingCity = call.Billing_City__c;
           acc.BillingState = call.Billing_State__c;
           acc.BillingCountry = call.Billing_City__c;
                
            
        }
            
    }
    public Account getacc()
    {
        return acc;
    }
    public list<LeadSelectClass> getLeadClassList()
    {
        LeadClassList= new list<LeadSelectClass>();
         
        for(Lead l: Leadlist)
        {
            LeadSelectClass tempRecord = new LeadSelectClass(l);
            
            LeadClassList.add(tempRecord);
        }
        LeadClassList[LeadClassList.size()-1].isDisabled = false;
        system.debug('LeadClassList---->'+LeadClassList);
        return LeadClassList;
    }
    
    public PageReference BtnWasteCall_Click()
    {
        PageReference pageref = new PageReference('/apex/wastecallpage?c='+callID);
        pageref.setRedirect(true);
        return pageref;
    }
    
    public class LeadSelectClass
    {
        public Lead ava_lead{get; set;}
        public Boolean isSelected { get; set; }
        public boolean isDisabled {get; set;}
        public LeadSelectClass(Lead l) {
              ava_lead= l;
              isSelected = false;
              isDisabled = true;
        }           
        
    }
    
    public PageReference BtnContinue_Click(){        
            integer numberOfSlections = 0;
            list<LeadSelectClass> SelectedProspect = new list<LeadSelectClass>();
            for(LeadSelectClass sampleData : LeadClassList) {
                  if(sampleData.isSelected){
                        numberOfSlections = numberOfSlections + 1;
                        SelectedProspect.add(sampleData);
                  }
            }           
            if(numberOfSlections > 1){
                  
                  errMsg = 'Only one Prospect can be selected.';
                  setErrorMsg();
            }
            
            else if(numberOfSlections == 1)
            {
                PageReference pageref = new PageReference('/apex/WorkflowPage?c='+callID+'&p='+SelectedProspect[0].ava_lead.Id);
                pageref.setRedirect(true);
                return pageref;
            }
            PageReference pageref = new PageReference('/apex/WorkflowPage?c='+callID);
            pageref.setRedirect(true);
            return pageref;
      }
    
    
    public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errMsg);
        ApexPages.addMessage(msg);
    }
    
   
}