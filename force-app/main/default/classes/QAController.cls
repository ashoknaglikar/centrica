public class QAController{
    
    public string searchString{get; set;}       // Capture reference for search
    public string searchNumber{get; set;}       // Capture reference for search
    public opportunity oppDetails{get; set;}    // Hold details of searched lead
    public Opportunity CHILeadDetails{get;set;}        //Details of related Lead
    public opportunity opp{get;set;}
    public Job__c jobDetails{get;set;}    // Details of related primary job
    public BigMachines_Quote__c quoteDetails{get;set;} //  Details of related primary quote  
    
    public id CHILeadID{get;set;}
    public id QAID{get;set;}
    
    public string TypeOfSurvey{get;set;}
    public string errorMsg{get;set;}             // Store error messages
    public boolean missedItems{get;set;}        // Flag as true if any questions not answered
    public boolean hideSearch{get;set;}         // Search section to render if not accessed via JOB
    public boolean showSearch{get;set;}         // As above
    public boolean showCustomer{get;set;}      // Show customer details if lead/job details found
    public boolean showQuestions{get;set;}     // Show questions if lead/job details found
    public id isSavedID{get;set;}              // Used incase header needs to be saved before items
    public boolean customerUnavailable{get;set;} // Get whether customer is available or not
    public string quoteProdNote{get;set;}       // Store boiler notes
    public QA_Header__c newQA{get;set;}
    public integer jobCount{get;set;}           // Count of JOBs found
    public boolean headerCreated{get;set;}      // Set when header created - help with attachment create
    
    public List<QMaster__c> theQuestions{get;set;} // Hold the details of the questions from QMaster__c
    
    public List<questionAnswer> GQuestionsClass{get;set;} // General questions class
    public List<questionAnswer> FQuestionsClass{get;set;} // Finance questions class
    public List<questionAnswer> OQuestionsClass{get;set;} // Other questions class

    
    public List<QA_Response__c> ExistingAnswers;   
    public boolean Finance{get;set;}  //Used to render Finance block
    public boolean locked{get;set;} //Used to show locked record indicator
    public String priorPaymentMethod{get;set;} //Used to show locked record indicator
    public list<QMaster__c> questions;   // List of all questions
    
    // Run when page loaded and refreshed to check how the user go to the page
    public QAController(ApexPages.StandardController controller){ 
        
        try{
            TypeOfSurvey = 'HSA QA';
            System.debug('====InCOnstructor===');        
            // query all questions
            questions = [SELECT id,name,version__c,Options__c,report_text__c,question_text__c,section__c,
                         order__c,Question_Code__c FROM QMaster__c  WHERE active__c = true 
                         AND (section__c = 'General' OR section__c='Finance' OR section__c='QAOther') order by order__c ASC];
            
            // Instantiate variables
            GQuestionsClass = new List<questionAnswer>();
            FQuestionsClass = new List<questionAnswer>();
            OQuestionsClass = new List<questionAnswer>();
            missedItems = false;
            locked = false; 
            newQA = new QA_Header__c();
            newQA = (QA_Header__c)controller.getrecord();
            if(newQA.id!=NULL)
             QAID = newQA.id; 
            else
             QAID  = NULL;
           
           if(QAID == NULL){
                if(newQA.CHI_Lead__c==NULL){           
                    // if QAID and Chilead both are null i.e. we are creating new header from search functionality
                    //get chi lead id from passes parameter oppoID
                    String str = ApexPages.currentPage().getParameters().get('OppoId');

                    if(str!=Null && str.startsWith('006'))
                     CHILeadID = str;
                    else
                     CHILeadID = NULL;  
                }
                // If chi lead is not null i.e. we are creating new header from related list of chi lead
                else
                   CHILeadID =  newQA.CHI_Lead__c; 
           }    


                   
            IF (QAID!= NULL)
            {
                System.debug('====INQAID===='+QAID);               
                newQA = [SELECT id,Name,CHI_Lead__c,Vulnerability_Identified__c,Call_Compliant__c,
                         Hand_off_to_CAT__c,Locked__c,Outcome_Required__c,Locked_Indicator__c,HSA_Name__c,Status__c,
                         BM_Finance_Acceptance_Number__c,General_Comments__c,Different_Name_on_Finance__c,Term__c,
                         (SELECT id,AnswerPick__c,notes__c,QA_Header__c,QA_Header__r.CHI_Lead__c,name,
                         Option__c,report_text__c,Question__c,section__c,version__c,order__c,Poor_Outcome__c,question_code__c
                         FROM QA_Response__r order by order__c ASC)
                         FROM QA_Header__c WHERE id =: QAID];
                if(newQA.Locked__c == true)
                    locked = true;
     
                for(QA_response__c res : newQA.QA_Response__r)   
                    if(res.answerpick__c == 'CASH')
                     priorPaymentMethod = 'CASH';
                    else if(res.answerpick__c == 'FINANCE')
                     priorPaymentMethod = 'FINANCE';             
                CHILeadID  = newQA.CHI_Lead__c;
                headerCreated = true;
                showSearch = false;     // Hide the search section                      
                showCustomer = true;
                showQuestions = true;          
               
               // Fetch related lead, job and quote details
               try{
                   CHILeadDetails = [SELECT id,Name,Install_Address_Street__c,surveys_taken__c,Install_Address_City__c,Install_Address_County__c,
                                Install_Postcode__c,CHI_Lead_Id__c,Latest_customer_category_indicator__c,Customer_Name__c,
                                Mobile_Phone__c,Home_Phone__c,Customer_Email__c,Account.Primary_Contact__r.bm_fAcceptanceNumber__c                               
                                FROM Opportunity WHERE id =: CHILeadID  limit 1];
               }Catch(Exception e){
                    errorMsg = 'No CHI Lead Details Found';
                    setErrorMsg(); 
               } 
                                             
               try{ 
                   jobDetails = [SELECT id,name,Customer_Name__c,Installation_Date__c,Best_Phone_Number__c,District_Name__c,Region__c,District__c,DSM_Name__c,DSM_Phone_Number__c,
                                 DHM_Name__c,DHM_Phone__c,Home_Phone__c,HSA_Name__c,Payment_Method__c,CHI_Lead__c          
                            FROM Job__c WHERE CHI_Lead__c=:CHILeadID  AND Is_Remedial_Job__c=false AND Is_Downtime_Job__c=false];             
               }Catch(Exception e){
                    errorMsg = 'No Related Job Found';
                    setErrorMsg(); 
               }
                
               try{            
               quoteDetails = [SELECT id,name,closeDate__c,POC_Payment_Method__c,depositOnPricing__c,App_Assigned_To__c
                               FROM BigMachines_Quote__c where Opportunity__c=:CHILeadID  AND Is_Primary__c=true];
               }Catch(Exception e){
                    errorMsg = 'No Related Quote Found';
                    setErrorMsg(); 
               }
                
                // query questions depending on payment method
                if(priorPaymentMethod == 'CASH')
                    queryExistingGeneralQuestions();
                else if(priorPaymentMethod == 'FINANCE'){
                    queryExistingGeneralQuestions();
                    queryExistingFinanceQuestions();
                }
                cashOrFinance();                
            }
            ELSE IF (CHILeadID!= NULL)
            { 
                System.debug('=======CHILEADID===='+CHILeadID);
                headerCreated = false;
                showCustomer = true;
                showQuestions = true;    
                showSearch = false;     //If the user adds new via JOB page then show the search else hide it.                   
                
                // Fetch related Lead, job and quote details
               try{
                   CHILeadDetails = [SELECT id,Name,Install_Address_Street__c,surveys_taken__c,Install_Address_City__c,Install_Address_County__c,
                                Install_Postcode__c,CHI_Lead_Id__c,Latest_customer_category_indicator__c,Customer_Name__c,
                                Mobile_Phone__c,Home_Phone__c,Customer_Email__c,Account.Primary_Contact__r.bm_fAcceptanceNumber__c                                
                                FROM Opportunity WHERE id =: CHILeadID limit 1];
               }Catch(Exception e){
                    errorMsg = 'No CHI Lead Details Found';
                    setErrorMsg(); 
               } 
                                             
               try{ 
                   jobDetails = [SELECT id,name,Customer_Name__c,Installation_Date__c,Best_Phone_Number__c,District_Name__c,Region__c,District__c,DSM_Name__c,DSM_Phone_Number__c,
                                 DHM_Name__c,DHM_Phone__c,Home_Phone__c,HSA_Name__c,Payment_Method__c,CHI_Lead__c          
                            FROM Job__c WHERE CHI_Lead__c=:CHILeadDetails.id AND Is_Remedial_Job__c=false AND Is_Downtime_Job__c=false];             
               }Catch(Exception e){
                    errorMsg = 'No Related Job Found';
                    setErrorMsg(); 
               }
               
               try{
                   if(CHILeadDetails.id!=NULL){
                   opp=[select id,name,surveys_taken__c from opportunity where id=:CHILeadDetails.id];
                   if(opp!=null){
                    if(opp.Surveys_taken__c==NULL){
                       opp.Surveys_taken__c =TypeOfSurvey;
                    }
                    else{
                    string survery=opp.Surveys_taken__c;
                    if(survery.contains(TypeOfSurvey)){                      
                    }
                    else
                       opp.surveys_taken__c =opp.surveys_taken__c+';'+TypeOfSurvey;
                     }
                    }
                   }
                  }Catch(Exception e){
                    errorMsg = 'No Records Found';
                    setErrorMsg();
                  } 
                  
               try{            
               quoteDetails = [SELECT id,name,closeDate__c,POC_Payment_Method__c,depositOnPricing__c,App_Assigned_To__c
                               FROM BigMachines_Quote__c where Opportunity__c=:CHILeadDetails.id AND Is_Primary__c=true];
               }Catch(Exception e){
                    errorMsg = 'No Related Quote Found';
                    setErrorMsg(); 
               }
               
               //creating header for first time, querry both general and finance question
               queryGeneralQuestions();
               queryFinanceQuestions();
           }
           else 
           {
                showSearch = true;              
           }
        }catch (Exception e){System.debug('======='+e);}
    }
        
    public class questionAnswer
    {
        public QMaster__c question {get;set;}
        public list<selectoption> options {get;set;}
        public list<selectoption> numberOptions; 
        public list<selectoption> paymentOptions;    
        public string answer {get;set;}
        public string notes {get;set;}
        public QA_Response__c response2 {get;set;}
        public boolean poorOutcome{get;set;} 
        public boolean ifAnsIsNumber=false; 
        public boolean ifAnsIsText=false;     
        
        // constructor used to create class object by passing question
        public questionAnswer(QMaster__c ques, list<selectoption> opts,String str)
        {
            String[] HSAName = str.split('-');
            question = ques;         
            if(HSAName[0]!=null)
             question.question_text__c = question.question_text__c.replace('[HSA Name]',HSAName[0]);
            options = opts;  
            poorOutcome = false;  
        }
        
        //constructor used to create class object by passing response
        public questionAnswer(QA_Response__c res, list<selectoption> opts)
        {
            response2 = res;
            
            question = new QMaster__c();
        
            question.Question_Code__c = res.Question_Code__c;
            question.question_text__c = res.question__c;
           // String[] HSAName = str.split('-');
            //question.question_text__c = question.question_text__c.replace('[HSA Name]',HSAName[0]);
            options = opts;   
            answer =  res.AnswerPick__c;
            notes = res.Notes__c;
            poorOutcome = res.Poor_Outcome__c;
        }  
        
        public boolean getIfAnsIsNumber(){
            if(options.isEmpty())
                ifAnsIsNumber = true;
            return ifAnsIsNumber;
        }
        
        public boolean getIfAnsIsText(){
            if(!options.isEmpty() && options[0] == new SelectOption('CF','CF'))
                ifAnsIsText= true;
            return ifAnsIsText;
        }
        
        public List<SelectOption> getNumberOptions(){
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('-NONE-','-NONE-'));
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
            options.add(new SelectOption('NA','NA')); 
            return options;
        }
        
         public List<SelectOption> getPaymentOptions(){
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('CASH','CASH'));
            options.add(new SelectOption('FINANCE','FINANCE')); 
            return options;
        }
       
    } 
    
    // query general and other questions while creating header for first time
    public void queryGeneralQuestions(){
         GQuestionsClass= new List<questionAnswer> ();
         OQuestionsClass= new List<questionAnswer> ();
         for(QMaster__c theQuestions : questions)                                 
        {
            list<selectoption> options = new list<selectoption> ();
            
            if(theQuestions.Section__c == 'General')
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options,jobDetails.HSA_Name__c);
                GQuestionsClass.add(newQuesClass);
            }  
            
             if(theQuestions.Section__c == 'QAOther')
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options,jobDetails.HSA_Name__c);
                OQuestionsClass.add(newQuesClass);
            }  
        }   
    } 
    
    // query finance questions while creating header for first time
    public void queryFinanceQuestions(){
         FQuestionsClass= new List<questionAnswer> ();
         for(QMaster__c theQuestions : questions)                                 
        {
            list<selectoption> options = new list<selectoption> ();
            
            if(theQuestions.Section__c == 'Finance')
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options,jobDetails.HSA_Name__c);
                FQuestionsClass.add(newQuesClass);
            }  
        }   
    }    

    // query existing general and other question when we are editing header record
    public void queryExistingGeneralQuestions(){
         GQuestionsClass= new List<questionAnswer> ();
         OQuestionsClass= new List<questionAnswer> ();
         for(QA_Response__c theQuestions : newQA.QA_Response__r)                                 
        {
            list<selectoption> options = new list<selectoption> ();
            
            if(theQuestions.Section__c == 'General')
            {    
                if(theQuestions.Option__c!=null)
                {
                    //options.add(new selectoption('','-select-'));
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                GQuestionsClass.add(newQuesClass);
            }   
            
            if(theQuestions.Section__c == 'QAOther')
            {    
                if(theQuestions.Option__c!=null)
                {
                    //options.add(new selectoption('','-select-'));
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                OQuestionsClass.add(newQuesClass);
            }    
        }
    }
    
      // query existing finance question when we are editing header record
     public void queryExistingFinanceQuestions(){
         FQuestionsClass= new List<questionAnswer> ();
          for(QA_Response__c theQuestions : newQA.QA_Response__r)                                 
        {
            list<selectoption> options = new list<selectoption> ();
            
            if(theQuestions.Section__c == 'Finance')
            {    
                if(theQuestions.Option__c!=null)
                {
                    //options.add(new selectoption('','-select-'));
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                FQuestionsClass.add(newQuesClass);
            }     
        }
    }

    //method called by javascript when answer is changed from cash to finance or vice versa
    public void cashOrFinance(){         
         for(questionAnswer  QM :GQuestionsClass){
             if(QM.answer=='CASH' || QM.answer=='FINANCE'){
                 if(QM.answer=='CASH'){
                     Finance = false;
                     break;                     
                 }                     
                 else if(QM.answer=='FINANCE'){
                     Finance = true;
                        break;                    
               }             
         }        
        } 
        // if we are changing payment method from cash to finance that means we dont have existing finance responses
        // so query finance questions
        if(priorPaymentMethod=='CASH' && Finance==true){
            System.debug('=====CashToFinance====');
            queryFinanceQuestions();
        }
    } 
    
     public void mandatoryCheck(){
        // Check General questions are completed       
        for(questionAnswer QM : GQuestionsClass )         
            If(qm.answer == NULL || qm.answer=='-NONE-')               
                missedItems = true; 
       
       // Check Other questions are completed         
       for(questionAnswer QM : OQuestionsClass )         
            If(qm.answer == NULL || qm.answer=='-NONE-')               
                missedItems = true;

        //Check Finance questions are completed
        for(questionAnswer QM : GQuestionsClass ){
            if(QM.answer == 'Finance')        
            for(questionAnswer QMF : FQuestionsClass )          
                If(QMF.answer == NULL || QMF.answer=='-NONE-')               
                    missedItems = true;  
        }   
        
    }
    
    // Create new QA Header record 
    public void createHeader(){      
        newQA.Employee__c = [SELECT id FROM Employee__c WHERE name=:quoteDetails.App_Assigned_To__c].id;
        newQA.CHI_Lead__c = CHILeadDetails.id;
        if(!missedItems)
        newQA.Status__c = 'Complete';
        insert newQA;           
        headerCreated = true;
    }
    
    // method used to insert general and other response
    public void createGeneralQuestions(){
        List<QA_Response__c> responseToInsert = new  List<QA_Response__c>();
        for(questionAnswer QM : GQuestionsClass )
        {
            QA_Response__c QARes = new QA_Response__c
            (
                QA_Header__c = newQA.id,
                question_code__c = QM.question.question_code__c,
                report_text__c = QM.question.report_text__c,
                question__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                option__c = QM.question.options__c,
                order__c = QM.question.order__c,
                Poor_Outcome__c = QM.poorOutcome             
            );
                responseToInsert.add(QARes);                
        } 
        
        for(questionAnswer QM : OQuestionsClass )
        {
            QA_Response__c QARes = new QA_Response__c
            (
                QA_Header__c = newQA.id,
                question_code__c = QM.question.question_code__c,
                report_text__c = QM.question.report_text__c,
                question__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                option__c = QM.question.options__c,
                order__c = QM.question.order__c,
                Poor_Outcome__c = QM.poorOutcome             
            );
                responseToInsert.add(QARes);                
        } 
        insert responseToInsert;
    }
    
      // method used to insert Finance response
     public void createFinanceQuestions(){
     List<QA_Response__c> responseToInsert = new  List<QA_Response__c>();
         for(questionAnswer QM : FQuestionsClass )
                {   
                    QA_Response__c QARes = new QA_Response__c
                    (
                        QA_Header__c = newQA.id,
                        question_code__c = QM.question.question_code__c,
                        report_text__c = QM.question.report_text__c,
                        question__c = QM.question.question_text__c,
                        section__c = QM.question.section__c,
                        notes__c = QM.notes,
                        AnswerPick__c = QM.answer,                   
                        version__c = QM.question.version__c,
                        option__c = QM.question.options__c,
                        order__c = QM.question.order__c,
                        Poor_Outcome__c = QM.poorOutcome               
                    );

                  responseToInsert.add(QARes);                
        } 
        System.debug('====FinanceQuestion====='+responseToInsert);
        insert responseToInsert;    
    }
    
    //method used to update existing general and other response
    public void updateExistingGeneralQuestions(){
        List<QA_Response__c> existingResponseGeneral = new List<QA_Response__c>();        
        for(questionAnswer QM : GQuestionsClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;
            QM.response2.Poor_Outcome__c = QM.PoorOutcome;            
            existingResponseGeneral.add(QM.response2);
        }
        
        for(questionAnswer QM : OQuestionsClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;
            QM.response2.Poor_Outcome__c = QM.PoorOutcome;            
            existingResponseGeneral.add(QM.response2);
        }
        
        if(existingResponseGeneral.size()>0)
        {
        
            UPDATE existingResponseGeneral;                  
        }
    }
    
    //method used to update existing finance response
    public void updateExistingFinanceQuestions(){
        List<QA_Response__c> existingResponseFinance = new List<QA_Response__c>();         
        for(questionAnswer QM : FQuestionsClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;
            QM.response2.Poor_Outcome__c = QM.PoorOutcome;            
            existingResponseFinance.add(QM.response2);
        }
        
        if(existingResponseFinance .size()>0)
        {
        
            UPDATE existingResponseFinance ;                  
        }
    }
    
    // method used to delete existing finance response if we dont need them
    public void deleteExistingFinanceQuestions(){
        List<QA_Response__c> existingResponseFinance = new List<QA_Response__c>();         
        existingResponseFinance = [SELECT id from QA_Response__c where section__c='Finance' AND QA_Header__c=:newQA.id];
        if(existingResponseFinance.size()>0)
        {
            delete existingResponseFinance ;                  
        }
    }

    // method used to save header record 
    public PageReference save(){
        system.debug('Beore If---->'+missedItems);
        mandatoryCheck();
        IF(QAID != NULL){
            headerCreated = true;
            // header already exists
            for(integer i=0;i<GQuestionsClass.size();i++){
                //payment method is cash and is not changed, so update existing general responses only
                if(GQuestionsClass[i].answer=='CASH' && priorPaymentMethod=='CASH'){
                    system.debug('=====CashToCash1===');
                    updateExistingGeneralQuestions();
                }
                //payment method is finance and is not changed, so update existing general and finance responses
                else if(GQuestionsClass[i].answer=='FINANCE' && priorPaymentMethod=='FINANCE'){
                    system.debug('=====FinanceToFinance1===');
                    updateExistingGeneralQuestions();
                    updateExistingFinanceQuestions();
                }
                // payment method is changed from cash to finance that means we dont have existing finance responses
                // so create new finance responses and update existing general responses
                else if(GQuestionsClass[i].answer=='FINANCE' && priorPaymentMethod=='CASH'){
                    system.debug('=====CashToFinance1===');
                    updateExistingGeneralQuestions();
                    createFinanceQuestions();
                }
                // payment method is changed from finance to cash that means we have existing finance responses and we dont need them
                // so delete finance responses and update existing general responses
                else if(GQuestionsClass[i].answer=='CASH' && priorPaymentMethod=='FINANCE'){
                    system.debug('=====FinanceToCash1===');
                    deleteExistingFinanceQuestions();
                    updateExistingGeneralQuestions();
                }
            }
            PageReference qaPage = new PageReference('/'+ QAID);  // Take user to existing question header.
            qaPage.setRedirect(true);
            if(!missedItems)
                newQA.Status__c = 'Complete';
            else
                newQA.Status__c = 'Incomplete';
            update newQA;
            return qaPage;
        }
        
        else{
            // that means creating header for first time
            system.debug('Beore If---->'+headerCreated);
            String PaymentMethod;
            if(!missedItems)
                newQA.Status__c = 'Complete';
            else
                newQA.Status__c = 'Incomplete';
            
            createHeader();
            for(integer i=0;i<GQuestionsClass.size();i++){
                if(GQuestionsClass[i].answer=='FINANCE')
                    PaymentMethod='FINANCE';
                else if(GQuestionsClass[i].answer=='CASH')
                    PaymentMethod='CASH';
            } 
            System.debug('====Paymentmehtosd==='+PaymentMethod);
            // if payment method is cash, insert general responses only
            if(PaymentMethod == 'CASH'){                
                System.debug('===creating 9 records==='+PaymentMethod );
                createGeneralQuestions();
            }
            // if payment method is finance, insert both general and finance responses
            else if(PaymentMethod == 'FINANCE'){
                System.debug('===creating 17 records==='+PaymentMethod );
                createGeneralQuestions();
                createFinanceQuestions();
            }   
            update opp;   
            PageReference qaPage = new PageReference ('/'+ newQA.id);  // Take user to new question header.
            qaPage.setRedirect(true);
            return qaPage;
        }
        return null;
    }

    // Return user to the CHILead page for the related lead
    public PageReference cancel(){
        PageReference leadPage = new PageReference('/'+ CHILeadDetails.id);
        leadPage.setRedirect(true);
        return leadPage;
    } 
    
     // Search button action. 
    public PageReference search() 
    {
        ApexPages.StandardController controller = new  ApexPages.StandardController(newQA);
        system.debug('Search Option: ' + searchString);
        try
        {
            system.debug('@@@entered');

            oppDetails = [SELECT id, name, chi_lead_id__c From opportunity WHERE chi_lead_id__c =:searchString limit 1];        
            system.debug('=============='+oppDetails );
                newQA = [SELECT id,Name,CHI_Lead__c FROM QA_Header__c WHERE CHI_Lead__c=:oppDetails.id order by createdDate DESC limit 1];
                system.debug('=============='+newQA  );               
        }
        catch(exception e)
        {
            System.debug('======'+e);
            errorMsg = 'Invalid CHI Lead number';
            setErrorMsg();        
        }           
        
        if(oppDetails != NULL)
        {
            showCustomer = true;
            showQuestions = true;
            PageReference qaPage;
            if(newQA.Id != null)
            {
               qaPage = new PageReference ('/apex/QAPage?id='+newQA.Id);  
             
            }else
            {
                qaPage = new PageReference ('/apex/QAPage?'+'OppoId='+oppDetails.id);  
            }    
            qaPage.setRedirect(true);
            return qaPage;
        }      
        return null;  
    }

    
    public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.Error, errorMsg);
        ApexPages.addMessage(msg);
    }   

}