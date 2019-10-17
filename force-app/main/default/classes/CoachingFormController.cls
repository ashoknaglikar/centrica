public class CoachingFormController{
    Utilities util = new Utilities();
    public Coaching_Header__c header{get;set;}
    public Employee__C emp{get;set;}    
    public List<QMaster__c> theQuestions{get;set;} // Hold the details of the questions from QMaster__c
    
    public List<questionAnswer> CQuestionsClass{get;set;} // Compliance questions class
    public List<questionAnswer> MQuestionsClass{get;set;} // Mindset questions class
    public List<questionAnswer> SQuestionsClass{get;set;} // Safety questions class
    public List<questionAnswer> CPBQuestionsClass{get;set;} // Capability questions class
    public List<questionAnswer> OQuestionsClass{get;set;} // Other questions class
    
    public boolean missedItems{get;set;}        // Flag as true if any questions not answered
    public boolean missedComplianceItem{get;set;}  // Used to show whether perticular section has been completed or not
    public boolean missedMindsetItem{get;set;}
    public boolean missedSafetyItem{get;set;}
    public boolean missedCapabilityItem{get;set;}
    public Boolean missedOtherItem{get;set;}
    
    public string errorMsg{get;set;}             // Store error messages
    
    public list <Attachment> signList{get;set;} 

    
    public Integer signSuccess{get;set;}
    public Boolean signSuccessRender{get;set;} // used on vf page
    public boolean email{get;set;}
    
    public string emailTo{get;set;}
    public string emailId{get;set;}
    public String Manager{get;set;}
    public String CompletedOn{get;set;}
    public String ConductedOn{get;set;}
      
    public boolean displayQuestions{get;set;}
    public String coachingType{get;set;}
    
    public boolean size1{get;set;}       // size of each section
    public boolean size2{get;set;}
    public boolean size3{get;set;}
    public boolean size4{get;set;}
    public boolean size5{get;set;}
    
    public String section1{get;set;}     // used to assign section names dynamically
    public String section2{get;set;}
    public String section3{get;set;}
    public String section4{get;set;}
    public String section5{get;set;}
    
    
    public CoachingFormController(ApexPages.StandardController controller){
        System.debug('====InCOnstructor===');        
        
            
        // Instantiate variables
        CQuestionsClass = new List<questionAnswer>();
        MQuestionsClass = new List<questionAnswer>();
        SQuestionsClass = new List<questionAnswer>();
        CPBQuestionsClass = new List<questionAnswer>();
        OQuestionsClass = new List<questionAnswer>();
        
        missedComplianceItem = true;
        missedMindsetItem= true;
        missedSafetyItem = true;
        missedCapabilityItem= true;
        missedOtherItem= true;
        
        missedItems = true;
        displayQuestions = false;
        
        header = new Coaching_Header__c();
        if(ApexPages.currentPage().getParameters().get('headerID')!=NULL)
            header.id = ApexPages.currentPage().getParameters().get('headerID');
        else
            header = (Coaching_Header__c) controller.getRecord();
        
        
        signSuccess = 0;
        signSuccessRender = false;
        if(ApexPages.currentPage().getParameters().get('signSuccess')=='1'){
            signSuccess = 1;
            signSuccessRender = true;
        }
        else if(ApexPages.currentPage().getParameters().get('signSuccess')=='2'){
            signSuccess = 2;
            signSuccessRender = true;
        }
        else if(ApexPages.currentPage().getParameters().get('signSuccess')=='0'){
            signSuccess = 0;
            signSuccessRender = false;
        }
        
        System.debug('===signSuccess==='+signSuccess +signSuccessRender );
        
        signList = new list <Attachment>();
        signList = [Select id from Attachment where ParentId =:header.id and (Name='Coach_Sign' or Name='Employee_Sign') order by Name];
        
        email = false;
        email = ApexPages.currentPage().getParameters().get('email')=='1'?true:false;
        
        System.debug('====Booleans==='+signSuccess+email);
        if(header.id!=Null){
            System.debug('====existing record====');
            header = [SELECT id, Name, Assigned_To__c,Coaching_Type__c,Completed_On__c,Conducted_On__c,District__c,
                      HSA_Name__c,Status__c,Visit_Completed_By__c,Visit_Completed_By__r.Name,Follow_up_actions__c,Status_Indicator__c,
                      Locked_indicator__c,Manager_Signed_Date__c,HSA_Signed_Date__c,Final_Score__c, Have_you_signed_the_form__c, Sub_Group__c,                   
                      (SELECT id,AnswerPick__c,Notes__c,Option__c,Question__c,Section__c,Question_Code__c  FROM Coaching_Response__r) 
                      FROM Coaching_Header__c where id=:header.id];
            displayQuestions(); 
            mandatoryCheck();  
        }
        else{       
            header = new Coaching_Header__c();
            header.Visit_Completed_By__c = Userinfo.getUserId();
            header.Status__c = 'In Progress'; 
            header.Conducted_On__c = System.Now();          
        }  
        header.Have_you_signed_the_form__c = false;
        Manager = header.Visit_Completed_By__r.Name;
        System.debug('DatesInConstructor==='+header.Completed_On__c);
        ConductedOn = header.Conducted_On__c.format();
        if(header.Completed_On__c!=NULL)
            CompletedOn = header.Completed_On__c.format(); 
    } 
     
     
    public void queryEmployee(){
        if(header.Assigned_To__c!=NULL){
            System.debug('========debug======'+header.Assigned_To__c);
            emp = [SELECT id, Name,District__r.Name,Email__c,Region__c FROM Employee__c where id = :header.Assigned_To__c];
            List<String> str = emp.Name.split('-');
            emp.Name = str[0];
        }        
    }
        
    public void displayQuestions(){
        System.debug('======displayQuestions=====');
        size1 = false;
        size2 = false;
        size3 = false;
        size4 = false;
        size5 = false;
        
        CQuestionsClass.clear();
        MQuestionsClass.clear();
        SQuestionsClass.clear();
        CPBQuestionsClass.clear();
        OQuestionsClass.clear();
        
        missedComplianceItem = true;
        missedMindsetItem= true;
        missedSafetyItem = true;
        missedCapabilityItem= true;
        missedOtherItem= true;
        
        displayQuestions = true;
        
        if(header.Coaching_Type__c=='General')
            coachingType = 'General';
        else if(header.Coaching_Type__c=='Specific')
            coachingType = 'Specific';
        
        String form = 'CoachingForm - ' + coachingType ;
        System.debug('====form==='+form);
        
        // query all questions
        theQuestions = [SELECT id,name,version__c,Options__c,report_text__c,question_text__c,section__c,
                     order__c,Question_Code__c,section_order__c FROM QMaster__c  WHERE active__c = true 
                     AND form__c = :form order by section_order__c ASC];
        System.debug('====header===='+header.id);
        
        
        System.debug('===queriedQue==='+theQuestions);
        
        Map<Integer,string> sectionOrder = new Map<Integer,string>();
        for(QMaster__c qm : theQuestions ) {
            sectionOrder.put(qm.section_order__c.intValue(),qm.section__c); 
        } 
        
        System.debug('===Set Of Strings==='+sectionOrder ); 
        
        section1 = sectionOrder.get(1); 
        section2 = sectionOrder.get(2);   
        section3 = sectionOrder.get(3);  
        section4 = sectionOrder.get(4); 
        section5 = sectionOrder.get(5); 
        
        if(header.id!=NULL){
            queryExistingQuestions();
        }
        else{    
             queryQuestions(); 
        }          
        
        if(!CQuestionsClass.isEmpty())
            size1=true;
        if(!MQuestionsClass.isEmpty())
            size2=true;
        if(!SQuestionsClass.isEmpty())
            size3=true;
        if(!CPBQuestionsClass.isEmpty())
            size4=true;
        if(!OQuestionsClass.isEmpty())
            size5=true;
        queryEmployee();
        System.debug('===signalBooleans==='+missedComplianceItem );
        System.debug('===sizeBooleans==='+size1+size2+size3+size4+size5+CQuestionsClass.isEmpty()+CQuestionsClass.size());
    }

    //wrappper classto bind question and response objects
    public class questionAnswer
    {
        public QMaster__c question {get;set;}
        public list<selectoption> options {get;set;}   
        public string answer {get;set;}
        public string notes {get;set;}
        public Coaching_Response__c response2 {get;set;}    
        
        // constructor used to create class object by passing question
        public questionAnswer(QMaster__c ques, list<selectoption> opts)
        {
            question = ques;         
            options = opts;  
        }
        
        //constructor used to create class object by passing response
        public questionAnswer(Coaching_Response__c res, list<selectoption> opts)
        {
            response2 = res;
            
            question = new QMaster__c();
        
            question.Question_Code__c = res.Question_Code__c;
            question.question_text__c = res.question__c;
            options = opts;   
            answer =  res.AnswerPick__c;
            notes = res.Notes__c;
        }   
    }
     
    //Query questions
    public void queryQuestions(){
        for(QMaster__c theQuestions : theQuestions)                                 
        {
            list<selectoption> options = new list<selectoption>();
            if(theQuestions.Section__c == section1)
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                CQuestionsClass.add(newQuesClass);
            }  
            
            else if(theQuestions.Section__c == section2)
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                MQuestionsClass.add(newQuesClass);
            } 
             
            else if(theQuestions.Section__c == section3)
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                SQuestionsClass.add(newQuesClass);
            }  
            
            else if(theQuestions.Section__c == section4)
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                CPBQuestionsClass.add(newQuesClass);
            } 
            
            else if(theQuestions.Section__c == section5)
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                OQuestionsClass.add(newQuesClass);
            } 
        }   
    }
    
    // query existing question when we are editing header record
    public void queryExistingQuestions(){
         System.debug('===queryExistingQuestions==='+header.Coaching_Response__r);
         for(Coaching_Response__c theQuestions : header.Coaching_Response__r)                                 
        {
            list<selectoption> options = new list<selectoption> ();
            
            System.debug('===In If==='+theQuestions.Section__c+section1) ; 
            if(theQuestions.Section__c == section1)
            { 
                 
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                CQuestionsClass.add(newQuesClass);
            }   
            
            else if(theQuestions.Section__c == section2)
            {    
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                MQuestionsClass.add(newQuesClass);
            } 
               
            else if(theQuestions.Section__c == section3)
            {    
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                SQuestionsClass.add(newQuesClass);
            } 
               
            else if(theQuestions.Section__c == section4)
            {    
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                CPBQuestionsClass.add(newQuesClass);
            }   
            
            else if(theQuestions.Section__c == section5)
            {    
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                OQuestionsClass.add(newQuesClass);
            }     
        }
        System.debug('===List size==='+CQuestionsClass.size());
    }
    

     public void mandatoryCheck(){
        // Check Compliance questions are completed       
        Integer count1 = 0;
        Integer count2 = 0;
        Integer count3 = 0;
        Integer count4 = 0;
        Integer count5 = 0;
        
        for(questionAnswer QM : CQuestionsClass )      
            If(qm.answer != NULL)            
                count1++;

        if(count1 == CQuestionsClass.size())
            missedComplianceItem = false;
       
       // Check Mindsetquestions are completed       
        for(questionAnswer QM : MQuestionsClass )        
             If(qm.answer != NULL)           
                 count2++;

        if(count2 == MQuestionsClass.size())
            missedMindsetItem = false;
       
       // Check Safetyquestions are completed       
        for(questionAnswer QM : SQuestionsClass )       
            If(QM.answer != NULL)             
                count3++;
                
        if(count3 == SQuestionsClass.size())
            missedSafetyItem = false;
                 
       // Check Capabilityquestions are completed       
        for(questionAnswer QM : CPBQuestionsClass )     
             If(qm.answer != NULL) 
                count4++;
                
        if(count4 == CPBQuestionsClass.size())
            missedCapabilityItem = false;
            
         // Check Capabilityquestions are completed       
        for(questionAnswer QM : OQuestionsClass )     
             If(qm.answer != NULL) 
                count5++;
                
        if(count5 == OQuestionsClass.size())
            missedOtherItem = false;
            
        if(count1 == CQuestionsClass.size() && count2 == MQuestionsClass.size() && count3 == SQuestionsClass.size() && count4 == CPBQuestionsClass.size() && count5 == OQuestionsClass.size())
            missedItems = false;
    }
    
    // Create new QA Header record 
    public void createHeader(){      
        insert header;           
    }
    
    // method used to insert response
    public void createQuestions(){
        List<Coaching_Response__c> responseToInsert = new  List<Coaching_Response__c>();
        for(questionAnswer QM : CQuestionsClass )
        {
            Coaching_Response__c CFRes = new Coaching_Response__c
            (
                Coaching_Header__c = header.id,
                question_code__c = QM.question.question_code__c,
                report_text__c = QM.question.report_text__c,
                question__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                option__c = QM.question.options__c,
                order__c = QM.question.order__c          
            );
                responseToInsert.add(CFRes);                
       } 
       for(questionAnswer QM : MQuestionsClass )
        {
            Coaching_Response__c CFRes = new Coaching_Response__c
            (
                Coaching_Header__c = header.id,
                question_code__c = QM.question.question_code__c,
                report_text__c = QM.question.report_text__c,
                question__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                option__c = QM.question.options__c,
                order__c = QM.question.order__c           
            );
                responseToInsert.add(CFRes);                
       } 
       for(questionAnswer QM : SQuestionsClass )
        {
            Coaching_Response__c CFRes = new Coaching_Response__c
            (
                Coaching_Header__c = header.id,
                question_code__c = QM.question.question_code__c,
                report_text__c = QM.question.report_text__c,
                question__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                option__c = QM.question.options__c,
                order__c = QM.question.order__c           
            );
                responseToInsert.add(CFRes);                
       } 
       for(questionAnswer QM : CPBQuestionsClass )
        {
            Coaching_Response__c CFRes = new Coaching_Response__c
            (
                Coaching_Header__c = header.id,
                question_code__c = QM.question.question_code__c,
                report_text__c = QM.question.report_text__c,
                question__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                option__c = QM.question.options__c,
                order__c = QM.question.order__c          
            );
                responseToInsert.add(CFRes);                
       }     
       for(questionAnswer QM : OQuestionsClass )
        {
            Coaching_Response__c CFRes = new Coaching_Response__c
            (
                Coaching_Header__c = header.id,
                question_code__c = QM.question.question_code__c,
                report_text__c = QM.question.report_text__c,
                question__c = QM.question.question_text__c,
                section__c = QM.question.section__c,
                notes__c = QM.notes,
                AnswerPick__c = QM.answer,                   
                version__c = QM.question.version__c,
                option__c = QM.question.options__c,
                order__c = QM.question.order__c          
            );
                responseToInsert.add(CFRes);                
       }         
       if(responseToInsert.size()>0)
         insert responseToInsert;
    }

    //method used to update existing response
    public void updateExistingQuestions(){
        List<Coaching_Response__c> existingResponse = new List<Coaching_Response__c>();        
        for(questionAnswer QM : CQuestionsClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        for(questionAnswer QM : MQuestionsClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        
        for(questionAnswer QM : SQuestionsClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        for(questionAnswer QM : CPBQuestionsClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        for(questionAnswer QM : OQuestionsClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        if(existingResponse.size()>0)
          UPDATE existingResponse ;                  
    }

        
    //method used to save signatures
   public PageReference saveSignature(){
          
        mandatoryCheck();
        System.debug('===missedItems==='+missedItems);
        if(missedItems==true){
            util.setErrorMsg(true, 'Please answer all questions before signing the form.');
            missedItems = false;
            return null;
        }  
             
         try{
             header.Manager_Signed_Date__c = System.now();
             header.HSA_Signed_Date__c = System.now();
             header.Completed_On__c = System.now();
             header.Status__c = 'Complete-Signed';
             System.debug('====Dates==='+CompletedOn+'==='+ConductedOn  );
             
            IF(header.id != NULL){
                // header already exists
                updateExistingQuestions();
                update header;
               
            } 
            else{
             // that means creating header for first time    
                createHeader(); 
                createQuestions();    
            }      
        }    
        catch(Exception e){
            util.setErrorMsg(true, e.getMessage()+'first catch');
            System.debug('=====FirstCatch==='+e.getMessage());
            return null;
        } 
        
        String enCoachValue = Apexpages.currentPage().getParameters().get('encCoach');
        String enEmpValue = Apexpages.currentPage().getParameters().get('encEmp');
        signList.Clear();
        System.debug('=======Paramvalues====='+enCoachValue+'==='+enEmpValue );
        try{
                string cSign = enCoachValue.split(',').get(1);
                string eSign = enEmpValue.split(',').get(1);
                
                Attachment att1 = new Attachment(Body = EncodingUtil.base64Decode(cSign),
                                                Name = 'Coach_Sign',
                                                ParentId = header.Id,
                                                isPrivate = false,
                                                ContentType = 'image/jpg',
                                                Description = 'Coachs Signature');

                Attachment att2 = new Attachment(Body = EncodingUtil.base64Decode(eSign),
                                                Name = 'Employee_Sign',
                                                ParentId = header.Id,
                                                isPrivate = false,
                                                ContentType = 'image/jpg',
                                                Description = 'Employees Signature');
                signList.add(att1);
                signList.add(att2);

            System.debug('======debug===='+signList);
            if(signList.size()>0)
              insert signList; 
            System.debug('======debug===='+header.id);
            pagereference p = new pagereference('/apex/CoachingForm?signSuccess=1&email=0&headerID='+header.id);
            p.setredirect(true);
            return p;  
        }catch(Exception e){
             util.setErrorMsg(true, e.getMessage()+'second catch');
             System.debug('=====SecondCatch==='+e.getMessage());
             return null;
        }          
    }
    
    
    // method used to save records and return detail page 
    public PageReference save(){
        mandatoryCheck();
        pagereference p;
        try{
        //if customer has completed all questions and signed the form, save the record and generate pdf
        if(missedItems==false && header.Have_you_signed_the_form__c==true){
            header.Manager_Signed_Date__c = System.now();
            header.HSA_Signed_Date__c = System.now();
            header.Completed_On__c = System.now();
            header.Status__c = 'Complete-Signed';
             IF(header.id != NULL){
                updateExistingQuestions();
                update header;
               
            } 
            else{
             // that means creating header for first time 
                createHeader(); 
                createQuestions();    
            }  
            
            String enCoachValue = Apexpages.currentPage().getParameters().get('encCoach');
            String enEmpValue = Apexpages.currentPage().getParameters().get('encEmp');
            signList.Clear();
            string cSign = enCoachValue.split(',').get(1);
            string eSign = enEmpValue.split(',').get(1);
                    
            Attachment att1 = new Attachment(Body = EncodingUtil.base64Decode(cSign),
                                                    Name = 'Coach_Sign',
                                                    ParentId = header.Id,
                                                    isPrivate = false,
                                                    ContentType = 'image/jpg',
                                                    Description = 'Coachs Signature');
    
            Attachment att2 = new Attachment(Body = EncodingUtil.base64Decode(eSign),
                                                    Name = 'Employee_Sign',
                                                    ParentId = header.Id,
                                                    isPrivate = false,
                                                    ContentType = 'image/jpg',
                                                    Description = 'Employees Signature');
            signList.add(att1);
            signList.add(att2);

            if(signList.size()>0)
                insert signList; 
            missedItems = false;
            p = new pagereference('/apex/CoachingForm?signSuccess=2&email=0&headerID='+header.id);
            p.setredirect(true);
                
        }
        
        // if customer have completed all questions and not signed the form, then only save the record and dont generate pdf
        else if((missedItems==false&& header.Have_you_signed_the_form__c==false))
        {
             header.Status__c = 'Complete-Not Signed';
             IF(header.id != NULL){
                updateExistingQuestions();
                update header;
            } 
            else{
             // that means creating header for first time 
                createHeader(); 
                createQuestions();    
            } 
            missedItems = false;
            p = new PageReference('/'+ header.id);  // Take user to existing question header.
            p.setRedirect(true); 
        }
        
         // if customer havn't completed all questions and signed the form, then only save the record and dont generate pdf
        else if((missedItems==true && header.Have_you_signed_the_form__c==true))
        {
           util.setErrorMsg(true, 'Please answer all questions before signing the form.');
           missedItems = false;
           p = null;
        }
        return p;  
        }
        catch(Exception e){
            util.setErrorMsg(true, e.getMessage());
            return null;
        }   
    }
     
    // Return user to the last page
    public PageReference cancel(){
        PageReference page = new PageReference('/'+header.id);
        page.setRedirect(true);
        return page;
    } 
    
    
    //method used to send email
    public void sendEmail(){
        try {
          Id headerID = ApexPages.currentPage().getParameters().get('headerID');
          Coaching_Header__c header = [SELECT id, Assigned_To__c FROM Coaching_Header__c WHERE id=:headerID];
          Attachment a = [SELECT id,body,name FROM Attachment WHERE parentId=:headerID LIMIT 1];
          emp = [SELECT id, Name,District__r.Name FROM Employee__c where id = :header.Assigned_To__c];
          List<String> str = emp.Name.split('-');
          emp.Name = str[0];
          List<String> ToAddresses = new List<String>();
          ToAddresses.add(emailId);
          
          System.debug('======'+!emailId.contains('@'));
          System.debug('======'+!(emailId.indexOf('@')<emailId.lastIndexOf('.')));
          System.debug('======'+!(emailId.lastIndexOf('.')>emailId.indexOf('@')+2));
          System.debug('======'+!(emailId.lastIndexOf('.')+2>=emailId.length()));
          if(!emailId.contains('@') || !(emailId.indexOf('@')<emailId.lastIndexOf('.')) 
                  || !(emailId.lastIndexOf('.')>emailId.indexOf('@')+2) )
          {
             util.setErrorMsg(true, 'Invalid email Id.'); 
             //return null;
          }
          else{
              // create email attachment
              Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
              efa.setBody(a.body);
              efa.setFileName(a.name);
              
              //create email message
              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
              email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
              email.setSubject('Coaching LOG for Employee '+ emp.Name);
              email.setPlainTextBody('Dear '+emailTo+',\n \nPlease Find attached Coaching LOG. \n \nThanks,\n British Gas\n\n Do not respond. This is the automated email.');
              email.setToAddresses( ToAddresses );
              
              OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@britishgas.co.uk'];
              if (owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
              }
              
              Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
              if(r[0].isSuccess())
                  util.setErrorMsg(false, 'Email sent successfully.');
              else
                  util.setErrorMsg(true, 'Email sending failed.');
             //return 'Success';
         }
        }
        catch(Exception e){
            util.setErrorMsg(true, e.getMessage());
            //return null;
        }
    }
    
    
    //method used to generate pdf file
    public void methodtest()
    {
        if(signSuccess!=0)
        {
        try{
        System.debug('===In MethodTest====');
        PageReference pdfPage = page.CoachingFormPDF;
        //putting id of custom object in parm id so that I can read it to fetch records
        pdfPage.getParameters().put('headerID',header.id);
        Blob pdfBlob = pdfPage.getContent();
            
        Attachment coachingFormPdf = new Attachment(Body = pdfBlob,
                                            Name = 'Coaching Log.pdf',
                                            ParentId = header.Id,
                                            isPrivate = false,
                                            contenttype='.pdf'
                                            );
          System.debug('====PDF===='+coachingFormPdf );  
          System.debug('====emp===='+emp.name);                                                                     
            try{                                                                        
                    insert coachingFormPdf ;
                    if(signList.size()>0)
                        delete signList;                   
                    
                    //send email to employee
                    if(signSuccess==1){
                    System.debug('====sending email====');
                        emailTo = emp.name;
                        emailId = emp.Email__c;
                        sendEmail();
                    }
            }
            catch (exception e)
            {
                    system.debug('Error  while saving Coaching Form Pdf:'+e.getmessage());
                    util.setErrorMsg(true, e.getmessage());
            }
        
        }   
        catch(Exception e)
        {
            system.debug('Error  while saving Coaching Form:'+e.getmessage()); 
            util.setErrorMsg(true, e.getmessage());         
        }
      }         
    }  
}