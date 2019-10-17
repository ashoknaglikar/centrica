public without sharing class CaseNPSCardController {
  
    public string q1color{get;set;}                             // Store colours for style of question to highlight unanswered
    public string q2color{get;set;}
    public string q3color{get;set;}
    public string q4color{get;set;}
    public string q5color{get;set;}
    
    public integer question1{get;set;}                          // Store the answer of each question
    public integer question2{get;set;}
    public integer question3{get;set;}    
    public integer question4{get;set;}
    public boolean question5{get;set;}
    
    public boolean showQ1{get;set;}                            // show and hide each question section
    public boolean showQ2{get;set;}
    public boolean showQ3{get;set;}
    public boolean showQ4{get;set;}
    public boolean showQ5{get;set;}
    
    public string  TradingName{get;set;}                // Store trading name for British/Scottish gas logo
    public boolean  missingAnswers{get;set;}            // Hold whether answers are missing
    public id caseID;                                                   // id of case linked
    public boolean showThanks{get;set;}                         // Allow show and hide of thanks section
    public boolean showQuestionSection {get;set;}       // Allow show and hide of questions
    public string errorMsg{get;set;}                            // Store error message
    public case caseDetails{get;set;} 
        
    public CaseNPSCardController(){
       
        caseID = ApexPages.currentPage().getParameters().get('caseid');
        
        // Check if page opened with a valid case id.
        try{
        System.debug('Case ID :' +caseID);    
        caseDetails = [SELECT case.caseNumber, case.Account.Trading_Name__c FROM case WHERE id =: caseID limit 1];
        }catch(exception e){
                errorMsg = 'You have no valid customer reference you do not have permissions on this record';
            setErrorMsg();
            showQuestionSection = false;
        }
        
        if (caseDetails != NULL) 
        {
        showQuestionSection = true;
        missingAnswers = false;
        // Set style colour for question sections.
        q1color = 'color:black';
        showQ1 = TRUE;    
        q2color = 'color:black';
        showQ2 = TRUE;    
        q3color = 'color:black';
        showQ3 = TRUE;
        q4color = 'color:black';
        showQ4 = TRUE;    
        q5color = 'color:black';
        showQ5 = TRUE;
        }  
    }
    
    // Action when 'Submit' button pressed.
    public void save(){   
        checkQuestions();        
        if(missingAnswers == true){
                errorMsg = 'Please complete all highlighted questions before submitting your scores.  Thank You.';
                setErrorMsg();
        }else{
            showQuestionSection = false;
            showThanks = true;
                saveNPSScore();
        }         
    }
       
    public void checkQuestions(){
        missingAnswers = false;        
        if(question4 == NULL){q4color = 'color:red'; missingAnswers = true;}
                else{q4color = 'color:black';question4 = question4;showQ4 = FALSE;}
        if(question3 == NULL){q3color = 'color:red'; missingAnswers = true;} 
                else{q3color = 'color:black';question3 = question3;showQ3 = FALSE;}
        if(question2 == NULL){q2color = 'color:red'; missingAnswers = true;}
            else{q2color = 'color:black';question2 = question2;showQ2 = FALSE;}
        if(question1 == NULL){q1color = 'color:red'; missingAnswers = true;}
            else{q1color = 'color:black';question1 = question1;showQ1 = FALSE;}
    }
    
    public void setErrorMsg()
        {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.warning, errorMsg);
            ApexPages.addMessage(msg);
        }

    // Save score record against relevant case.
    public void saveNPSScore(){   
        system.debug('question1----->'+question1);
        CaseNPS__c NewNPS = new CaseNPS__c 
        (
        Question1__c = question1,
        Question2__c = question2,
        Question3__c = question3,
        Question4__c = question4,
        Question5__c = question5,
        Case__c = caseID
        );
            insert NewNPS;
    }
    
   // Question radio buttons
    public List<SelectOption> getQuestionItem() {
        List<SelectOption> options = new List<SelectOption>(); 
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
    
    public void assignfirst()
    {
        
        String temp=apexpages.currentPage().getParameters().get('question1');
        system.debug('IN aCTION FIRST--->'+temp);
        if(temp!=null)
        question1 = integer.valueOf(temp);
        system.debug('IN aCTION FIRST--->'+question1);
    } 
    
     
     public void assignSec()
    {
        
        String temp=apexpages.currentPage().getParameters().get('question2');
        system.debug('IN aCTION FIRST--->'+temp);
        if(temp!=null)
        question2 = integer.valueOf(temp);
        system.debug('IN aCTION FIRST--->'+question2);
    } 
    
     public void assignThird()
    {
        
        String temp=apexpages.currentPage().getParameters().get('question3');
        system.debug('IN aCTION FIRST--->'+temp);
        if(temp!=null)
        question3 = integer.valueOf(temp);
        system.debug('IN aCTION FIRST--->'+question3);
    } 
    
    public void assignForth()
    {
        
        String temp=apexpages.currentPage().getParameters().get('question4');
        system.debug('IN aCTION FIRST--->'+temp);
        if(temp!=null)
        question4 = integer.valueOf(temp);
        system.debug('IN aCTION FIRST--->'+question4);
    } 
    
}