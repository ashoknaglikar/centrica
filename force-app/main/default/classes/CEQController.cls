public class CEQController {

    // Customer Excellence Questionnaire project for use by RQMs
    // Created 25/11/2013 by Phil Dennison
    
    // Bug fixes made 20/12/2013
    // Fix - 1) Upload of first image creates own header
    // Fix - 2) Query for primary JOB from search (not downtime or remedial)
    // Fix - 3) Allow edit of audit and add upload of photo
    
    public string searchString {get; set;}       // Capture reference for search
    public string searchNumber {get; set;}       // Capture reference for search
    public opportunity oppDetails {get; set;}    // Hold details of searched lead
    public opportunity opp{get;set;}             // Hold details of Survey 
    public job__c jobDetails {get; set;}         // Hold details of primary JOB 
    public id jobID {get;set;}
    public id CEQID {get;set;}
    public string TypeOfSurvey{get;set;}
    public string fileName {get;set;}
    
    public string errorMsg{get;set;}             // Store error messages
    public boolean missedItems {get;set;}        // Flag as true if any questions not answered
    public boolean hideSearch {get;set;}         // Search section to render if not accessed via JOB
    public boolean showSearch {get;set;}         // As above
    public boolean showCustomer {get; set;}      // Show customer details if lead/job details found
    public boolean showQuestions {get; set;}     // Show questions if lead/job details found
    public id isSavedID {get; set;}              // Used incase header needs to be saved before items
    public boolean customerUnavailable{get;set;} // Get whether customer is available or not
    public string quoteProdNote {get;set;}       // Store boiler notes
    public CEQ_Header__c newCEQ {get;set;}
    public integer jobCount {get;set;}           // Count of JOBs found
    public boolean headerCreated {get;set;}      // Set when header created - help with attachment create
    
    
    public List<QMaster__c> theQuestions{get;set;} // Hold the details of the questions from QMaster__c
    public List<Commissioning_Report__c> Documents{get;set;} // List of JCDs related to JOB
    public List<ASP__c> ASPList {get;set;} // List of ASPs linked to the quote.
    public List<payment_collection__c> PCNList {get;set;} //List details of payment collection on job
    
    public bigmachines_quote__c quoteDetails{get;set;}    // Hold BMQuote details for job type
    public List<questionAnswer> IQuestionsClass{get;set;} // Installation questions class
    public List<questionAnswer> SQuestionsClass{get;set;} // Sales questions class
    public List<questionAnswer> CQuestionsClass{get;set;} // Customer questions class
    public List<questionAnswer> OQuestionsClass{get;set;} // Other questions class
    public List<questionAnswer> RQuestionsClass{get;set;} // RQM questions class - added 10.1.16
    
    public List<CEQ_Item__c> ExistingAnswers;
    
    //Attachment items
    public List<attachment> attachmentList {get;set;}
    
    // Run when page loaded and refreshed to check how the user go to the page
    public CEQController(){ 
        try{
        headerCreated =  false;
        TypeOfSurvey = 'Customer Excellence Audit';
        //jobDetails= new job__c();
        jobID = ApexPages.currentPage().getParameters().get('jobID');
        CEQID = ApexPages.currentPage().getParameters().get('CEQID');
        newCEQ = new CEQ_Header__c ();
        IF (CEQID != NULL)
            {
            newCEQ = [SELECT id,WIP__c,Pre_Install__c,Post_Install__c,Job__c,Deep_Dive__c ,NAME FROM CEQ_Header__c WHERE id =: CEQID];
            headerCreated = true;
            showSearch = false;     // Hide the search section                      
            showCustomer = true;
            showQuestions = true;          
            jobDetails = [SELECT id, Payment_Method__c, Customer_Name__c,hsa_name__c, mechanical_installer__c, best_phone_number__c, home_phone__c, customer_email_address__c, Latest_customer_category_indicator__c, CHI_Lead__c,CHI_Lead__r.surveys_taken__c, quote__c, install_street__c, install_postcode__c, name, Status__c, sub_status__c, Installation_Date__c 
                          FROM job__c WHERE id =: jobID limit 1];
                          
            // Fetch quote details
            quoteDetails = [select id, job_type_description__c FROM bigmachines_quote__c WHERE id =: jobDetails.Quote__c]; 
            
                // Fetch any ASP details.
                if (quoteDetails.id != NULL){
                    ASPList = [select id, name, definition__c, picklist__c, function__c, createdDate FROM ASP__c WHERE quote__c =: quoteDetails.id];
                }    
                
                // Added 05/02/2018 by Phil Dennison - as per RQM request 
                if(jobDetails.id != NULL){
                    PCNList = [SELECT id, name, payment_collection_status__c, status_indicator__c, payment_notes__c FROM payment_collection__c WHERE job__c =: jobDetails.id limit 1];
                }
                
            // Get the boiler instructions from the related quote product
            try{
            quoteProdNote = [SELECT installationNotes__c FROM quote_product__c WHERE bigmachines_quote__c =: jobDetails.Quote__c AND Part_Number__c like 'CBLR%' limit 1].installationNotes__c;
            }catch (Exception e){}
                          
            // Get JCDs linked to JOB 
                if(jobDetails.id != NULL){                
                    Documents = [SELECT id, name, report_name__c, status__c, job_number__c, status_indicator__c FROM Commissioning_Report__c WHERE Job_Number__c =: jobDetails.Id];               
                }
            ExistingQAQuery();

            }
        ELSE IF (jobID != NULL)
            { 
                
            showSearch = false;     //If the user adds new via JOB page then show the search else hide it.                   
            
            // Fetch JOB details based on URL parameter
            jobDetails = [SELECT id, Payment_Method__c,CHI_Lead__r.surveys_taken__c,Customer_Name__c,hsa_name__c, mechanical_installer__c, best_phone_number__c, home_phone__c, customer_email_address__c, Latest_customer_category_indicator__c, CHI_Lead__c, quote__c, install_street__c, install_postcode__c, name, Status__c, sub_status__c, Installation_Date__c 
                          FROM job__c WHERE id =: jobID limit 1];
            // Get JCDs linked to JOB 
                if(jobDetails.id != NULL){                
                    Documents = [SELECT id, name, report_name__c, status__c, job_number__c, status_indicator__c FROM Commissioning_Report__c WHERE Job_Number__c =: jobDetails.Id];               
                }    
            
            // Check for Survey happened for this lead or not
            
              opp=[select id,name,surveys_taken__c,CHI_Lead_Id__c from opportunity where id=:jobdetails.CHI_Lead__c];
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
            
            // Fetch quote details
            quoteDetails = [select id, job_type_description__c FROM bigmachines_quote__c WHERE id =: jobDetails.Quote__c]; 
                          
            // Get the boiler instructions from the related quote product
            try{
            quoteProdNote = [SELECT installationNotes__c FROM quote_product__c WHERE bigmachines_quote__c =: jobDetails.Quote__c AND Part_Number__c like 'CBLR%' limit 1].installationNotes__c;               
            
        // Fetch any ASP details.
                if (quoteDetails.id != NULL){
                    ASPList = [select id, name, definition__c, picklist__c, function__c, createdDate FROM ASP__c WHERE quote__c =: quoteDetails.id];
                } 
                
                // Added 19/01/2018 by Phil Dennison - as per RQM request 
                if(jobDetails.id != NULL){
                    PCNList = [SELECT id, name, payment_collection_status__c, status_indicator__c, payment_notes__c FROM payment_collection__c WHERE job__c =: jobDetails.id limit 1];
                }

        }catch(Exception e){}
            headerCreated = false;
            showCustomer = true;
            showQuestions = true;
            questionQuery();            
        }else {
            showSearch = true;
        }
        }catch (Exception e){}
        
    }
    
    public void showCustomerSelection(){
    
        
    }
    
    
    // Search button action. 
    public PageReference search() 
    {
    
        system.debug('Search Option: ' + searchString);
      
        
        try
        {
            system.debug('@@@entered');
            oppDetails = [SELECT id, name, chi_lead_id__c From opportunity WHERE chi_lead_id__c =:searchString limit 1];
           
                
        }
        catch(exception e)
        {
            errorMsg = 'Invalid CHI Lead number';
            setErrorMsg();
        }
        
        if(oppDetails != NULL)
        {
            //jobCount = [SELECT count() FROM job__c WHERE CHI_Lead__c =: oppDetails.id limit 1];  
            
            //if(jobCount > 0){
            // Get JOB details  
            TRY
            {
            jobDetails = [SELECT id, best_phone_number__c, hsa_name__c, mechanical_installer__c, home_phone__c, customer_email_address__c, Customer_Name__c, Latest_customer_category_indicator__c, CHI_Lead__c, quote__c, install_street__c, install_postcode__c, name, Status__c, sub_status__c, Installation_Date__c 
                          FROM job__c  
                          WHERE Is_Remedial_Job__c = False AND Is_Downtime_Job__c = FALSE AND CHI_Lead__c =: oppDetails.id limit 1]; 
             
                // Get JCDs linked to JOB 
                if(jobDetails.id != NULL)
                {                
                  
                    system.debug('@@@@jobDetails.CHI_Lead__c'+jobDetails.CHI_Lead__c);
                    newCEQ = [SELECT id,WIP__c,Pre_Install__c,Post_Install__c,Job__c,Deep_Dive__c ,NAME FROM CEQ_Header__c WHERE Job__c=:jobDetails.id limit 1];
                    
                    system.debug('@@@newCEQ '+newCEQ);
                    
                    
                  
                  Documents = [SELECT id, name, report_name__c, status__c, job_number__c, status_indicator__c FROM Commissioning_Report__c WHERE Job_Number__c =: oppDetails.Id];               
                }
                quoteDetails = [select id, job_type_description__c FROM bigmachines_quote__c WHERE id =: jobDetails.Quote__c]; 
                   
                
                            
            // Get the boiler instructions from the related quote product
            try
            {
            quoteProdNote = [SELECT installationNotes__c FROM quote_product__c 
                             WHERE bigmachines_quote__c =: jobDetails.Quote__c  
                             AND Part_Number__c like 'CBLR%' limit 1].installationNotes__c;
            }
            catch (Exception e){}
            }
            Catch(exception e)
            {
                errorMsg = 'No Jobs exist for this lead';
                setErrorMsg();
            }    
        }
        
        if(jobDetails != NULL)
        {
            showCustomer = true;
            showQuestions = true;
            questionQuery();
            PageReference jobPage ;
            if(newCEQ.Id != null)
            {
               jobPage = new PageReference ('/apex/CEQPage?jobID='+jobDetails.id+'&CEQID='+newCEQ.Id);  
             
            }else
            {
                jobPage = new PageReference ('/apex/CEQPage?jobID='+jobDetails.id);  
            }    
            jobPage.setRedirect(true);
            return jobPage;

        }
        
        return null;
       
        
    }
    
   
    public void questionQuery(){
        IQuestionsClass= new List<questionAnswer> ();
        SQuestionsClass= new List<questionAnswer> ();
        CQuestionsClass= new List<questionAnswer> ();
        OQuestionsClass= new List<questionAnswer> ();
        RQuestionsClass= new List<questionAnswer> ();  // RQM section added 10.1.16
        
        
        // Question for loop
        for(QMaster__c theQuestions : [SELECT id, name, version__c, Options__c, report_text__c, question_text__c, section__c, order__c 
                                       FROM QMaster__c  
                                       WHERE active__c = true
                                       order by order__c ASC])                                 
        {
            list<selectoption> options = new list<selectoption> ();
            
            if(theQuestions.Section__c == 'Installation')
            {    
                if(theQuestions.Options__c!=null)
                {
                    //options.add(new selectoption('','-select-'));
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                //newQuesClass.answer ='Yes';
                IQuestionsClass.add(newQuesClass);
            }     

            if(theQuestions.Section__c == 'Sales')
            {    
                if(theQuestions.Options__c!=null)
                {
                    //options.add(new selectoption('','-select-'));
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                SQuestionsClass.add(newQuesClass);
            }  
            
            if(theQuestions.Section__c == 'Customer')
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                CQuestionsClass.add(newQuesClass);               
            } 
            
            if(theQuestions.Section__c == 'Other')
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                OQuestionsClass.add(newQuesClass);               
            }
            
            // RQM Section
            if(theQuestions.Section__c == 'RQM')
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                RQuestionsClass.add(newQuesClass);               
            }
            
              
        } // end of question for loop    
    }
    
    public void ExistingQAQuery(){
        system.debug('Enterin Query--->');
        IQuestionsClass= new List<questionAnswer> ();
        SQuestionsClass= new List<questionAnswer> ();
        CQuestionsClass= new List<questionAnswer> ();
        OQuestionsClass= new List<questionAnswer> ();
        RQuestionsClass= new List<questionAnswer> ();  // New RQM section added 1.1.16
        
        // Question for loop
        for(CEQ_Item__c theQuestions : [SELECT id, AnswerPick__c    , notes__c, CEQ_Header__c, CEQ_Header__r.job__c, name, version__c, Options__c, report_text__c, question_text__c, section__c, order__c 
                                       FROM CEQ_Item__c where CEQ_Header__c = :CEQID 
                                       order by order__c ASC])                                 
        {
            list<selectoption> options = new list<selectoption> ();
            
            if(theQuestions.Section__c == 'Installation')
            {    
                if(theQuestions.Options__c!=null)
                {
                    //options.add(new selectoption('','-select-'));
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                IQuestionsClass.add(newQuesClass);
            }     

            if(theQuestions.Section__c == 'Sales')
            {    
                if(theQuestions.Options__c!=null)
                {
                    //options.add(new selectoption('','-select-'));
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                SQuestionsClass.add(newQuesClass);
            }  
            
            if(theQuestions.Section__c == 'Customer')
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                CQuestionsClass.add(newQuesClass);               
            } 
            
            if(theQuestions.Section__c == 'Other')
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                OQuestionsClass.add(newQuesClass);               
            }
            
            if(theQuestions.Section__c == 'RQM')
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                RQuestionsClass.add(newQuesClass);               
            }
              
        } // end of question for loop    
    }
       
    public class questionAnswer
    {
        public QMaster__c question {get;set;}
        public list<selectoption> options {get;set;}
        public string answer {get;set;}
        public string notes {get;set;}
        public CEQ_Item__c item2 {get;set;}
        public questionAnswer(QMaster__c ques, list<selectoption> opts)
        {
            question = ques;
            options = opts;     
        }
        
        public questionAnswer(CEQ_Item__c ques, list<selectoption> opts)
        {
            item2= ques;
            
            question = new QMaster__c();
        
            question.question_text__c = ques.question_text__c;
            options = opts;   
            answer =  ques.AnswerPick__c;
            notes = ques.Notes__c;
            
        }   
    }    
    
    
    public void mandatoryCheck(){
        
        missedItems = false;
        // Check Sales questions are completed       
        for(questionAnswer QM : SQuestionsClass )
        {          
            If(qm.answer == NULL){                
                errorMsg = 'Missing sales question: '+qm.question.question_text__c;
                missedItems = true;
                setErrorMsg();
            }  
        } 

        // Check install questions are completed
        for(questionAnswer QM : IQuestionsClass )
        {          
            If(qm.answer == NULL){                
                errorMsg = 'Missing install question: '+qm.question.question_text__c;
                missedItems = true;
                setErrorMsg();
            }  
        }

        // Check customer questions are completed
        for(questionAnswer QM : CQuestionsClass )
        {          
            If(qm.answer == NULL  && customerUnavailable == false){                
                errorMsg = 'Missing customer question: '+qm.question.question_text__c;
                missedItems = true;
                setErrorMsg();
            }  
        }

        /* Commented until required
        // Check other questions are completed
        for(questionAnswer QM : OQuestionsClass )
        {          
            If(qm.answer == NULL){               
                errorMsg = 'Missing customer question: '+qm.question.question_text__c;
                missedItems = true;
                setErrorMsg();
            }  
        } */       
        
    }
    
    public void createHeader(){
        
        // Create new CEQ Header record   
        newCEQ .job__c = jobDetails.id;
        insert newCEQ;
        headerCreated = true;
    }
    
    public void createItems(){
        // Add all Install Q&As    
        for(questionAnswer QM : IQuestionsClass )
        {
            CEQ_Item__c QAItem = new CEQ_Item__c
            (
                CEQ_Header__c = newCEQ.id,
                question_code__c = QM.question.name,
                report_text__c = QM.question.report_text__c,
                question_text__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                options__c = QM.question.options__c,
                order__c = QM.question.order__c                
            );
                insert QAItem;                
        }
       
        // Add all Sales Q&As    
        for(questionAnswer QM : SQuestionsClass )
        {   
            CEQ_Item__c QAItem = new CEQ_Item__c
            (
                CEQ_Header__c = newCEQ.id,
                question_code__c = QM.question.name,
                report_text__c = QM.question.report_text__c,
                question_text__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                options__c = QM.question.options__c,
                order__c = QM.question.order__c                
            );
                insert QAItem;       
        } 

        // Add all Customer Q&As    
        for(questionAnswer QM : CQuestionsClass )
        {   
            IF(customerUnavailable == true){
                QM.answer = 'Customer unavailable';
            }
            CEQ_Item__c QAItem = new CEQ_Item__c
            (
                CEQ_Header__c = newCEQ.id,
                question_code__c = QM.question.name,
                report_text__c = QM.question.report_text__c,
                question_text__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                options__c = QM.question.options__c,
                order__c = QM.question.order__c                
            );
                insert QAItem;          
        } 
        
        // Add all other Q&As    
        for(questionAnswer QM : OQuestionsClass )
        {   
            CEQ_Item__c QAItem = new CEQ_Item__c
            (
                CEQ_Header__c = newCEQ.id,
                question_code__c = QM.question.name,
                report_text__c = QM.question.report_text__c,
                question_text__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                options__c = QM.question.options__c,
                order__c = QM.question.order__c                
            );
                insert QAItem;                     
        }
        
        // Add all RQM questions 
        for(questionAnswer QM : RQuestionsClass )
        {   
            CEQ_Item__c QAItem = new CEQ_Item__c
            (
                CEQ_Header__c = newCEQ.id,
                question_code__c = QM.question.name,
                report_text__c = QM.question.report_text__c,
                question_text__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                options__c = QM.question.options__c,
                order__c = QM.question.order__c                
            );
                insert QAItem;                     
        }
        
    }
    
    public void updateExistingItems(){
        
        // Update all Install Q&As 
        update newCEQ;
        List<CEQ_Item__c> existingItemsInstall = new List<CEQ_Item__c>();        
        for(questionAnswer QM : IQuestionsClass )
        {
            QM.item2.AnswerPick__c = QM.answer; 
            QM.item2.notes__c = QM.notes;
            existingItemsInstall.add(QM.item2);
        }
        
        if(existingItemsInstall.size()>0)
        {
        
            UPDATE existingItemsInstall;                  
        }
        
        // Update all Sales Q&As 
        List<CEQ_Item__c> existingItemsSales = new List<CEQ_Item__c>();        
        for(questionAnswer QM : SQuestionsClass )
        {
            QM.item2.AnswerPick__c = QM.answer; 
            QM.item2.notes__c = QM.notes;
            existingItemsSales.add(QM.item2);
        }
        
        if(existingItemsSales.size()>0)
        {
            UPDATE existingItemsSales;
        }
        
        // Update all customer Q&As 
        List<CEQ_Item__c> existingItemscustomer = new List<CEQ_Item__c>();        
        for(questionAnswer QM : CQuestionsClass )
        {
            QM.item2.AnswerPick__c = QM.answer; 
            QM.item2.notes__c = QM.notes;
            existingItemsCustomer.add(QM.item2);
        }
        
        if(existingItemscustomer.size()>0)
        {
            UPDATE existingItemsCustomer;
        }
        
        // Update all other Q&As 
        List<CEQ_Item__c> existingItemsOther = new List<CEQ_Item__c>();        
        for(questionAnswer QM : OQuestionsClass )
        {
            QM.item2.AnswerPick__c = QM.answer; 
            QM.item2.notes__c = QM.notes;
            existingItemsOther.add(QM.item2);
        }
        
        if(existingItemsOther.size()>0)
        {
            UPDATE existingItemsOther;
        }
        
        // Update all RQM Q&As 
        List<CEQ_Item__c> existingItemsRQM = new List<CEQ_Item__c>();        
        for(questionAnswer QM : RQuestionsClass )
        {
            QM.item2.AnswerPick__c = QM.answer; 
            QM.item2.notes__c = QM.notes;
            existingItemsRQM.add(QM.item2);
        }
        
        if(existingItemsRQM.size()>0)
        {
            UPDATE existingItemsRQM;
        }
        
        
    }
       
    public pageReference save(){
        
        mandatoryCheck();
        
        
        system.debug('Beore If---->'+missedItems);
        IF(CEQID != NULL){
       
            headerCreated = true;
            updateExistingItems();
            PageReference jobPage = new PageReference ('/'+ CEQID);  // Take user to new question header.
            jobPage.setRedirect(true);
            update newCEQ;
            return jobPage;

        }else IF(missedItems == false){
            system.debug('Beore If---->'+headerCreated);
            IF(headerCreated == false){
                createHeader();
            }                  
            createItems();  
            update opp;         
            PageReference jobPage = new PageReference ('/'+ newCEQ.id);  // Take user to new question header.
            jobPage.setRedirect(true);
            return jobPage;
        }
       
        return null;    
    }
    

      //  Attachement Code  taken from web and amended.
      public Attachment attachment {
        get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
        }
      set;
      }
 
    public PageReference upload() {
                
        IF(!headerCreated){
            createHeader();
         }//else{
            //attachment.ParentId = ApexPages.currentPage().getParameters().get('CEQID');
       // }
         attachment.ParentId = newCEQ.ID;
 
        attachment.OwnerId = UserInfo.getUserId();
        attachment.IsPrivate = false;
        if(fileName.length() < 1){
            attachment.name = system.Datetime.now()+'.jpg';  
        }else{
            attachment.name = fileName +'.jpg';      
        }
        
        try {
          insert attachment;
        } catch (DMLException e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
          return null;
        } finally {
          attachment.body = NULL;
          attachment = new Attachment();
          
          //https://cs18.salesforce.com/apex/CEQPage?jobID=a0n20000001PUM9  
        }
 
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        return null;
     }    

    // Return user to the job page for the related job
    public PageReference cancel(){
        PageReference jobPage = new PageReference('/'+ jobDetails.id);
        jobPage.setRedirect(true);
        return jobPage;
    }        
    
    public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.warning, errorMsg);
        ApexPages.addMessage(msg);
    }    
    
}