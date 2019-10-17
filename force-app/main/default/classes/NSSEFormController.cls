public class NSSEFormController {
 
    public NSSEForm__c saveNSSEFORM{get;set;}
    public Boolean questionSection{get;set;}
    public Boolean submitSection{get;set;}
    public Boolean dataPresentSection{get;set;}
    public Opportunity OppInfo{get;set;}
    public Boolean BGLogo{get;set;}
    public Boolean SGLogo{get;set;}
    public string errorMsg{get;set;}
    public integer nsseCount{get;set;}
            
    // Store the answer of each question.
    public integer question1{get;set;}  
    public integer question2{get;set;}
    public integer question3{get;set;}
    public integer question4{get;set;}
    public integer question5{get;set;}
    public integer question6{get;set;}
    public integer question8{get;set;}
    public string  question7{get;set;}
        
    public NSSEFormController()
    {
        try{
         // https://cs4.salesforce.com/apex/nsseform?empid=a0A2000000IU3ud&leadid=006P0000003ELve&apptid=a0BP0000001cdsk
         Id OppId = ApexPages.currentPage().getParameters().get('leadid');
         Id EmpId = ApexPages.currentPage().getParameters().get('empid');
         Id ApptId = ApexPages.currentPage().getParameters().get('apptid');
         BGlogo = true;
                                   
         OppInfo = [SELECT id, name, Account.Sales_Region__c FROM Opportunity WHERE id =: OppID limit 1];
             
         IF(OppInfo.Account.Sales_Region__c == 'Scotland'){
             BGLogo = false;
             SGLogo = true;
             }
             ELSE
             {
             BGLogo = true;
             SGLogo = false;
         }
         
         NSSECount = checkOldNsse(OppID);                              
         IF(NSSECount > 0) 
                {
                dataPresentSection = true;
                questionSection = false;
                submitSection = false;
                }else{
                questionSection = true;
                submitSection = false;
                dataPresentSection = false;
                }
                
         }catch(exception e){
            errorMsg = 'An error has occurred with this site.  If you have any further questions about your visit or the quote your received please call our Customer Support team on 0333 202 9669.';
            setErrorMsg();
         }
         
    }
    private integer  checkOldNsse(id OppId)
    {
          Integer NSSECount = [SELECT count() FROM NSSEForm__c WHERE Opportunity__c =: OppID limit 1];
          return NSSECount;
    }
    public void saveNSSEForm(){
        id oppId = ApexPages.currentPage().getParameters().get('leadid');
        if(checkOldNsse(oppId)>0)
        {
            questionSection = false;
            dataPresentSection = true;
            submitSection = false;
        }else
        {
            questionSection = false;
            //Create new NSSEForm__c record with answer to all questions plus to id's passed.
            NSSEForm__c NewForm = new NSSEForm__c 
            (
                NSSEQ1__c =  question1,
                NSSEQ2__c =  question2,
                NSSEQ3__c =  question3,
                NSSEQ4__c =  question4,
                NSSEQ5__c =  question5,
                NSSEQ6__c =  question6,
                NSSEQ8__c =  question8,
                Opportunity__c = oppId,
                employee__c = ApexPages.currentPage().getParameters().get('empid'),
                appointment__c = Apexpages.currentPage().getParameters().get('apptid')
            );
            
            if(question7!= null && question7.length()>1000)
            NewForm.NSSEQ7__c =  question7.substring(0,1000);
            else if(question7!= null)
            NewForm.NSSEQ7__c =  question7;
            insert NewForm;
            
            questionSection = false;
            dataPresentSection = false;
            submitSection = true;
        }
    }
        
    // Question radio buttons
    public List<SelectOption> getQuestion2Items() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('',''));
        options.add(new SelectOption('0','0'));
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3'));
        options.add(new SelectOption('4','4'));
        options.add(new SelectOption('5','5'));
        options.add(new SelectOption('6','6'));
        options.add(new SelectOption('7','7'));
        options.add(new SelectOption('8','8'));
        options.add(new SelectOption('9','9'));
        options.add(new SelectOption('10','10')); 
        return options; 
    }
        
    public void setErrorMsg()
        {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.error, errorMsg);
            ApexPages.addMessage(msg);
        }
    
}