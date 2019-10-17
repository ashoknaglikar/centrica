Public class WIPController{

    Utilities util = new Utilities();
    public WIP_Header__c header{get;set;} 
    public Job__c job{get;set;}    
    //public Employee__c emp{get;set;} 
    public Opportunity opp{get;set;}
    public string Manager {get;set;}
    public String CompletedOn{get;set;}
    public String ConductedOn{get;set;}  
    public string errorMsg{get;set;}
    public boolean customerUnavailable{get;set;}
    public string message{get;set;}
    
    public List<QMaster__c> theQuestions{get;set;} // Hold the details of the questions from QMaster__c
    
    public List<questionAnswer> section1QuestionClass{get;set;} // Prepare questions class
    public List<questionAnswer> section2QuestionClass{get;set;} // pre install questions class
    public List<questionAnswer> section4QuestionClass{get;set;} // Installation- Work in Progress Visit questions class
    public List<questionAnswer> section3QuestionClass{get;set;} // Installation- Post Completion Visit
    public List<questionAnswer> section5QuestionClass{get;set;} // Customer- Work In Progress Visit
    public List<questionAnswer> section6QuestionClass{get;set;} // Customer- Post Completion Visit
    public List<questionAnswer> section7QuestionClass{get;set;} // Outcome/Actions
    public list<questionAnswer> section9QuestionClass{get;set;}
    
    public boolean missedItems{get;set;}        // Flag as true if any questions not answered
    public boolean missedSection1Item{get;set;}  // Used to show whether perticular section has been completed or not
    public boolean missedSection2Item{get;set;}
    public boolean missedSection4Item{get;set;}
    public boolean missedSection3Item{get;set;}
    public Boolean missedSection5Item{get;set;}
    public Boolean missedSection6Item{get;set;}
    public Boolean missedSection7Item{get;set;}
    public boolean missedsection11Item{get;set;}
    public boolean atleastOneItem{get;set;}
    //public string errorMsg{get;set;}             // Store error messages
    public string options1{get;set;}
    
    public boolean size1{get;set;}       // size of each section
    public boolean size2{get;set;}
    public boolean size3{get;set;}
    public boolean size4{get;set;}
    public boolean size5{get;set;}
    public boolean size6{get;set;}
    public boolean size7{get;set;}
    public boolean size9{get;set;}
    public boolean size10{get;set;}
    public boolean ischanged{get;set;}
    public boolean ischanged1{get;set;}
    public boolean Firsttime{get;set;} //check Section9QuestionClass is already there or not
    public boolean checkCustomer{get;set;}
    public boolean CheckUpload{get;set;}
    
        
    public String section1{get;set;}     // used to assign section names dynamically
    public String section2{get;set;}
    public String section3{get;set;}
    public String section4{get;set;}
    public String section5{get;set;}
    public String section6{get;set;}
    public String section7{get;set;}
    public string section9{get;set;}
    public string section11{get;set;}
    
    
    public string emailTo{get;set;}
    public string emailId{get;set;}
    public string InstallAddress{get;set;}
    
    public integer signsuccess{get;set;}
    public boolean signSuccessRender{get;set;}
    public boolean email{get;set;}
    public boolean ReadOnly{get;set;} // readonly for customer avaialble section
    
    public string WIPType{get;set;}
    public boolean displayQuestions{get;set;}
    //Attachment items
    public Attachment attachment {get;set;}
    public string fileName {get;set;}
    
     public WIPController(ApexPages.StandardController controller)
     {
         
         attachment = new attachment();
         
         ischanged=false;  
         ischanged1=false;
         checkCustomer = false; 
         checkUpload = false;
         ReadOnly = false;
         System.debug('====InCOnstructor===');        
         message = 'Try Again!!';
        // Instantiate variables
        section1QuestionClass = new List<questionAnswer>();
        section2QuestionClass= new List<questionAnswer>();
        section4QuestionClass = new List<questionAnswer>();
        section3QuestionClass= new List<questionAnswer>();
        section5QuestionClass= new List<questionAnswer>();
        section6QuestionClass= new List<questionAnswer>();
        section7QuestionClass= new List<questionAnswer>();
        section9QuestionClass= new List<questionAnswer>();
    
       
        missedSection1Item = true;
        missedSection2Item = true;
        missedSection4Item = true;
        missedSection3Item = true;
        missedSection5Item = true;
        missedSection6Item = true;
        missedSection7Item = true;
        missedsection11Item = true;
        atleastOneItem = true;
        Firsttime = True;
        
        missedItems = true;
        displayQuestions = false;
        
        header = new WIP_Header__c();
        if(ApexPages.currentPage().getParameters().get('headerID')!=NULL)
            header.id = ApexPages.currentPage().getParameters().get('headerID');
        else 
             header = (WIP_Header__c) controller.getRecord();
        system.debug('##'+header);
        signsuccess=0;
        signSuccessRender = false;
        if(ApexPages.currentPage().getParameters().get('signSuccess')=='1'){
            signSuccess = 1;
            signSuccessRender = true;
        }
        else if(ApexPages.currentPage().getParameters().get('signSuccess')=='0'){
            signSuccess = 0;
            signSuccessRender = false;
        }
        
        system.debug('ReadOnly Value'+readonly);        
        email = false;
        email = ApexPages.currentPage().getParameters().get('email')=='1'?true:false;

        System.debug('====Booleans==='+signSuccess+email);
        header.Status__c = 'InProgress';
        if(header.id!=Null){
            System.debug('====existing record====');
            header = [SELECT id, Name,status__c,job__c,notes__c,Status_Indicator__c,Customer_Unavailable__c,Conducted_On__c,Visit_Completed_By__c ,Visit_Completed_By__r.email,Completed_On__c,WIP_Type__c,Question__c,Reason_For_Visit__c,               
                     Visit_Completed_By__r.Name,(SELECT id,AnswerPick__c,Notes__c,order__c,Option__c,Question__c,Section__c,Question_Code__c  FROM WIP_Response__r) 
                      FROM WIP_Header__c where id=:header.id];
            header.Question__c = 'Is the Customer available?';
            options1 = 'Yes|No';
            Firsttime = false;
            displayQuestions();
            mandatoryCheck();  
        }
        else
        {   
            header.Customer_Unavailable__c = true;
            //customerUnavailable= header.Customer_Unavailable__c;
            header.Question__c = 'Is the Customer available?';
            options1 = 'Yes|No';
            header.Visit_Completed_By__c = Userinfo.getUserId();
            header.Status__c = 'In Progress'; 
            header.Conducted_On__c = System.Now(); 
        
        }
        Manager = header.Visit_Completed_By__r.Name;
        ConductedOn = header.Conducted_On__c.format();
        if(header.Completed_On__c!=NULL)
        CompletedOn = header.Completed_On__c.format(); 
                         
         //query job deatils
        job=[select id,name,Account__c,Address__c,CHI_Lead__c,CHI_Lead__r.surveys_taken__c,CHI_Lead_Name__c,Delivery_Date__c,Delivery_Notes__c,District__c,
            District_Name__c,HSA_Name__c,Installation_Address__c,Install_Street__c,Install_City__c,Installation_County__c,Install_Postcode__c,Installation_Date__c,
            Mechanical_Installer__c,Customer_Name__c,Latest_customer_category__c,Latest_customer_category_indicator__c,Quote__c,Region__c,Status__c,Sub_Status__c from JOb__c where id=:header.job__c];
       
        InstallAddress = job.Install_Street__c+','+job.Install_City__c+','+job.Install_Postcode__c+','+job.Installation_County__c;
        
    }
    public void displayQuestions(){
        System.debug('======displayQuestions=====');
        size1 = false;
        size2 = false;
        size3 = false;
        size4 = false;
        size5 = false;
        size6 = false;
        size7 = false;
        size9 = false;
        size10= false;
        
                      
        section1QuestionClass.clear();
        section2QuestionClass.clear();
        section3QuestionClass.clear();
        section4QuestionClass.clear();
        section5QuestionClass.clear();
        section6QuestionClass.clear();
        section7QuestionClass.clear();
        section9QuestionClass.clear();
        
        missedSection1Item = true;
        missedSection2Item = true;
        missedSection4Item = true;
        missedSection3Item = true;
        missedSection5Item = true;
        missedSection6Item = true;
        missedSection7Item = true;
        
        displayQuestions = true;
        
        string sect1,sect2,sect3,sect4,sect5,sect6,sect7;
        if(header.WIP_Type__c=='Pre-Install Survey'){
              WIPType = 'Pre-Install Survey';
              sect1='Preparation';sect2='pre-installation Visit';sect7='Outcome/Actions';
         }
         else if(header.WIP_Type__c=='In Progress Survey'){
              WIPType = 'In Progress Survey'; 
              sect1='Preparation';sect3='Installation- Work in Progress Visit';sect5='Customer- Work In Progress Visit';sect7='Outcome/Actions';
         }
        else if(header.WIP_Type__c=='Post-Install Survey'){
              WIPType = 'Post-Install Survey';
              sect1='Preparation';sect4='Installation- Post Completion Visit';sect6='Customer- Post Completion Visit';sect7='Outcome/Actions';
         }
            
         String form = 'WIPForm - '+WIPType ;
         System.debug('====form==='+form);
        
        // query all questions
        theQuestions = [SELECT id,name,version__c,Options__c,report_text__c,question_text__c,section__c,
                     order__c,Question_Code__c,section_order__c FROM QMaster__c  WHERE active__c = true 
                     AND form__c =:'WIPForm' AND (section__c=:sect1 OR section__c=:sect2 OR section__c=:sect3 OR
                     section__c=:sect4 OR section__c=:sect5 OR section__c=:sect6 OR section__c=:sect7) order by section_order__c,Order__c ASC];        
        if(job!=null){
            opp=[select id,name,Surveys_taken__c from opportunity where id=:job.CHI_Lead__c];
            system.debug('##opportunity'+opp+'  '+opp.surveys_taken__c);
            if(opp!=null){
                if(opp.Surveys_taken__c==NULL){
                   opp.Surveys_taken__c =WIPType;
                }
                else{
                   string survery=opp.Surveys_taken__c;
                   if(survery.contains(WIPType)){
                     
                   }
                   else
                    opp.surveys_taken__c =opp.surveys_taken__c+';'+WIPType;
                 }
            }
        }
        
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
        section6 = sectionOrder.get(6); 
        section7 = sectionOrder.get(7); 
        
        system.debug('@@section names'+section1+' '+section2+' '+section3+' '+' '+section4+' '+' '+section5+' '+section6+' '+section7);
        //section9 = 'Other'
        if(header.id!=NULL){
            queryExistingQuestions();
        }
        else{    
             queryQuestions(); 
        }          
        
        if(!section1QuestionClass.isEmpty())
            size1=true;
        if(!section2QuestionClass.isEmpty())
            size2=true;
        if(!section3QuestionClass.isEmpty())
              size3=true;
        if(!section4QuestionClass.isEmpty())
            size4=true;
        if(!section5QuestionClass.isEmpty())
            size5=true;
        if(!section6QuestionClass.isEmpty())
            size6=true;
        if(!section7QuestionClass.isEmpty())
            size7=true;
       
        if(!section9QuestionClass.isEmpty())
            size9=true;
        else if(Firsttime == true){
            if(WIPType=='In progress Survey'&& (size3==true && size5==true)){
               list<selectoption> options2 = new list<selectoption>();
                if(header.Question__c !=NULL){
                  if(Options1!=NULL){
                   for(string s: options1.split('\\|'))
                       options2.add(new selectoption(s,s));
                 }
                 questionAnswer newQuesClass1 = new questionAnswer(header.Question__c,options2);
                 section9QuestionClass.add(newQuesClass1);
               }
               size9=true;
               }
        } 
        else if(Firsttime == false){
          
          if(WIPType=='In progress Survey'&& size5==true){
               list<selectoption> options2 = new list<selectoption>();
                if(header.Question__c !=NULL){
                  if(Options1!=NULL){
                   for(string s: options1.split('\\|'))
                       options2.add(new selectoption(s,s));
                 }
                 questionAnswer newQuesClass1 = new questionAnswer(header.Question__c,options2);
                 section9QuestionClass.add(newQuesClass1);
                 newQuesClass1.answer='Yes';
                 system.debug('@@section9QuestionClass'+section9QuestionClass);
               }
             size9=true; 
               
         }
         if(WIPType=='In progress Survey'&& size5==false){
               list<selectoption> options2 = new list<selectoption>();
                if(header.Question__c !=NULL){
                  if(Options1!=NULL){
                   for(string s: options1.split('\\|'))
                       options2.add(new selectoption(s,s));
                 }
                 questionAnswer newQuesClass1 = new questionAnswer(header.Question__c,options2);
                 section9QuestionClass.add(newQuesClass1);
                 newQuesClass1.answer='No';
                 system.debug('@@section9QuestionClass'+section9QuestionClass);
               }
            size9=true;
          }
         //size9=true;
         }
        //    queryEmployee();
        System.debug('===sizeBooleans==='+size1+size2+size3+size4+size5+size6+size7); 
        System.debug('===header==='+header);
        system.debug('===size10'+size10);
     }
     
     
     //wrappper classto bind question and response objects
    public class questionAnswer
    {
        public QMaster__c question {get;set;}
        public list<selectoption> options {get;set;}   
        public string answer {get;set;}
        public string notes {get;set;}
        public WIP_Response__c response2 {get;set;} 
        public string header2{get;set;} 
        // constructor used to create class object by passing question
        public questionAnswer(string ques,list<selectoption> opts){
           header2 = ques;
           options = opts;
        
        }
       
        public questionAnswer(QMaster__c ques, list<selectoption> opts)
        {
            question = ques;         
            options = opts; 
            
        }
        
        //constructor used to create class object by passing response
        public questionAnswer(WIP_Response__c res, list<selectoption> opts)
        {
            response2 = res;
            
            question = new QMaster__c();
        
            question.Question_Code__c = res.Question_Code__c;
            question.question_text__c = res.question__c;
            question.order__c = res.order__c;
            question.section__c = res.section__c;
            question.Options__c = res.option__c;
            
            options = opts;   
            answer =  res.AnswerPick__c;
            notes = res.Notes__c;
        }   
    }
    
     //Query questions
    public void queryQuestions(){
        section1QuestionClass = new list<questionAnswer>();
        section2QuestionClass = new list<questionAnswer>();
        section3QuestionClass = new list<questionAnswer>();
        section4QuestionClass = new list<questionAnswer>();
        section5QuestionClass = new list<questionAnswer>();
        section6QuestionClass = new list<questionAnswer>();
        section7QuestionClass = new list<questionAnswer>();
        section9QuestionClass = new list<questionAnswer>();
              
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
                section1QuestionClass.add(newQuesClass);
            }  
            
            else if(theQuestions.Section__c == section2)
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section2QuestionClass.add(newQuesClass);
            } 
             
            else if(theQuestions.Section__c == section3)
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section3QuestionClass.add(newQuesClass);
            }  
            
            else if(theQuestions.Section__c == section4)
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section4QuestionClass.add(newQuesClass);
            } 
            
            else if(theQuestions.Section__c == section5)
            {   
                 if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section5QuestionClass.add(newQuesClass);
            } 
            
            else if(theQuestions.Section__c == section6)
            {    
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section6QuestionClass.add(newQuesClass);
            } 
            
            else if(theQuestions.Section__c == section7)
            {   system.debug('@@section7 options'+theQuestions.options__c); 
                if(theQuestions.Options__c!=null)
                {
                    for(string s: theQuestions.Options__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }           
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section7QuestionClass.add(newQuesClass);
            } 
            
        }   
    }
    
    // query existing question when we are editing header record
    public void queryExistingQuestions(){
         
         
         System.debug('===queryExistingQuestions==='+header.WIP_Response__r);
         for(WIP_Response__c theQuestions : header.WIP_Response__r)                                 
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
                section1QuestionClass.add(newQuesClass);
            }   
            
            else if(theQuestions.Section__c == section2)
            {    
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section2QuestionClass.add(newQuesClass);
            } 
               
            else if(theQuestions.Section__c == section3)
            {    
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section3QuestionClass.add(newQuesClass);
            } 
               
            else if(theQuestions.Section__c == section4)
            {    
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section4QuestionClass.add(newQuesClass);
            }   
            
            else if(theQuestions.Section__c == section5)
            {    
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section5QuestionClass.add(newQuesClass);
            } 
            
            else if(theQuestions.Section__c == section6)
            {    
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section6QuestionClass.add(newQuesClass);
            } 
            
            else if(theQuestions.Section__c == section7)
            {    
                if(theQuestions.Option__c!=null)
                {
                    for(string s: theQuestions.Option__c.split('\\|'))
                    options.add(new selectoption(s,s));
                }                  
                questionAnswer newQuesClass = new questionAnswer(theQuestions,options);
                section7QuestionClass.add(newQuesClass);
            }  
            
        }
    }
    
     public void mandatoryCheck(){       
        Integer count1 = 0;
        Integer count2 = 0;
        Integer count3 = 0;
        Integer count4 = 0;
        Integer count5 = 0;
        Integer count6 = 0;
        Integer count7 = 0;
        string val;
       list<questionAnswer> section8QuestionClass=new list<questionAnswer>();
       list<questionAnswer> section10QuestionClass=new list<questionAnswer>();
        // Check if Prepare Questions are completed
        for(questionAnswer QM : section1QuestionClass ){      
            If(qm.answer != NULL)            
                count1++;
        }
        
        if(count1 == section1QuestionClass.size())
            missedSection1Item = false;
             
        // Check if Arrival Questions are completed
        for(questionAnswer QM : section2QuestionClass ){
             If(qm.answer != NULL)           
                 count2++;
        }
        
        if(count2 == section2QuestionClass.size())
            missedSection2Item = false;
        
        system.debug('@@'+section9QuestionClass);
       // Check Bright Start questions are completed 
        for(questionAnswer QM2: section9QuestionClass){
        system.debug('@@Qm2'+Qm2);
        
        system.debug('@@val'+val);
        if(QM2.answer=='No'){
             header.Customer_Unavailable__c=true;
             size10 = false;
             //size3=false; 
             size5=false;
                   system.debug('@@@size5'+size5);
                   section5QuestionClass.clear();
                   //section3QuestionClass.clear();
                   //count3++;
                   count5++;
                   ischanged = true; 
                   system.debug('@@cleared');
              
         }
         else if(QM2.answer=='Yes'){
         //count3=0;
         count5=0; 
         
         system.debug('@@Customer_Unavailable'+header.Customer_Unavailable__c);
              if(header.customer_Unavailable__c == false){
              system.debug('@@inside customer Available');
                 size10 = false;
                 header.customer_Unavailable__c = false;
              }
              else{
                 size10 = true;
                 //header.customer_Unavailable__c = false;
              }                         
              //header.Customer_Unavailable__c=false;
              //   size10 = true;
               if(section5QuestionClass.size()==0){
                 for(QMaster__c theQuestions : theQuestions)                                 
                 {
                 system.debug('working fine');
                 list<selectoption> options = new list<selectoption>();
                 if(theQuestions.Section__c == section5)
                    {    
                        if(theQuestions.Options__c!=null)
                        {
                            for(string s: theQuestions.Options__c.split('\\|'))
                            options.add(new selectoption(s,s));
                        }           
                        questionAnswer newQuesClass1 = new questionAnswer(theQuestions,options);
                        section8QuestionClass.add(newQuesClass1);
                    } 
                   
                 }  
                 
                     system.debug('--------->entered into loop of new list');
                     section5QuestionClass.addall(section8QuestionClass); 
                     
                 }
                 size5=true;
                 //size3=true;
                 //missedSection3Item=true;
                 missedSection5Item=true;
                 
                 //system.debug('count3 and 5'+count3+' '+count5);
               }
              
           } 
        
            
        for(questionAnswer QM : section3QuestionClass )     
             If(qm.answer != NULL) 
                count3++;
        
           
        if(count3 == section3QuestionClass.size())
            missedSection3Item = false;
                 
       // Check Safety questions are completed       
       for(questionAnswer QM : section4QuestionClass ){
             If(qm.answer != NULL) 
                count4++;
       }
       
        if(count4 == section4QuestionClass.size())
            missedSection4Item = false;
            
         // Check Right First Time questions are completed       
        for(questionAnswer QM1 : section5QuestionClass ){
                         if(QM1.answer!=NULL)
                         count5++;
                         system.debug('##size5'+size5);
         }
              
        if(count5 == section5QuestionClass.size())
            missedSection5Item = false;
            
         // Check Complete questions are completed       
        for(questionAnswer QM : section6QuestionClass){
             If(qm.answer != NULL) 
                count6++;
        }
        
        if(count6 == section6QuestionClass.size())
            missedSection6Item = false;
            
        // Check Follow up questions are completed       
        for(questionAnswer QM : section7QuestionClass ){
        system.debug('@@QM'+Qm);
             If(qm.answer != NULL){ system.debug('@@'); 
                count7++;
                system.debug('@@count7'+count7);
                }
        }
        
        if(count7 == section7QuestionClass.size())
            missedSection7Item  = false;
        
        if((count1>0 && count2>0 && count7>0)||(count1>0 && count3>0 && count7>0 && count5>0)||(count1>0 && count4>0 && count6>0 && count7>0)){
            system.debug('@@countvalues'+count1 +' '+count2+' '+count3+' '+count4+' '+count5+' '+count6+' '+count7);
            atleastoneItem = false;
            system.debug('@@atleast'+atleastoneitem);
         }
        system.debug('@@'+section3QuestionClass.size()+' , '+section7QuestionClass.size()+' , '+section1QuestionClass.size());
        
        if(size5){
           if(section1QuestionClass.size()>0 && section3QuestionClass.size()>0 && section5QuestionClass.size()>0 && section7QuestionClass.size()>0){
                if(isChanged == True && count3==section3QuestionClass.size() && count7==section7QuestionClass.size()  && count5==section5QuestionClass.size() && count1 == section1QuestionClass.size()) {//
                    isChanged = false;
                    missedItems = false;   
                 }
             }
        }
        else {
            if(section1QuestionClass.size()>0 && section3QuestionClass.size()>0 && section7QuestionClass.size()>0){
                if(isChanged == True && count3==section3QuestionClass.size() && count7==section7QuestionClass.size() && count1 == section1QuestionClass.size()) {//
                    isChanged = false;
                    missedItems = false;   
                 }
             }
        }
        if(count1 == section1QuestionClass.size() && count2 == section2QuestionClass.size() && count3 == section3QuestionClass.size() && count4 == section4QuestionClass.size() && count5 == section5QuestionClass.size() && count6 == section6QuestionClass.size() && count7 == section7QuestionClass.size()){
                missedItems = false;
                ischanged = false;
               system.debug('Inside');
        }
        //else if(Ischanged==false && missedItems==false )
        //     missedItems=true;
       
        system.debug('@@ischanged'+ischanged);
        system.debug('@@MissedItems'+Misseditems);
    }
    
    // method used to insert response
    public void createQuestions(){
       
       system.debug('@@Sections'+section3QuestionClass);
       system.debug('@@Sections'+section5QuestionClass);
       system.debug('@@Sections'+section7QuestionClass);
        List<WIP_Response__c> responseToInsert = new  List<WIP_Response__c>();
        for(questionAnswer QM : section1QuestionClass )
        {
            WIP_Response__c w = new WIP_Response__c
            (
                WIP_Header__c = header.id,
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
                responseToInsert.add(w);                
       }
        
       for(questionAnswer QM : section2QuestionClass )
        {
            WIP_Response__c w = new WIP_Response__c
            (
                WIP_Header__c = header.id,
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
                responseToInsert.add(w);                
       }
       
       for(questionAnswer QM : section3QuestionClass )
        {
            WIP_Response__c w = new WIP_Response__c
            (
                WIP_Header__c = header.id,
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
                responseToInsert.add(w);                
       }
       
       for(questionAnswer QM : section4QuestionClass )
        {
            WIP_Response__c w = new WIP_Response__c
            (
                WIP_Header__c = header.id,
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
                responseToInsert.add(w);                
       }  
          
       for(questionAnswer QM : section5QuestionClass )
        {
           WIP_Response__c w = new WIP_Response__c
            (
                WIP_Header__c = header.id,
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
                responseToInsert.add(w);       
             
       }
       
       for(questionAnswer QM : section6QuestionClass )
        {
            WIP_Response__c w = new WIP_Response__c
            (
                WIP_Header__c = header.id,
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
                responseToInsert.add(w);                
       }
       
       for(questionAnswer QM : section7QuestionClass )
        {   system.debug('@@createSection7Questions'+QM.question.section__c);
            WIP_Response__c w = new WIP_Response__c
            (
                WIP_Header__c = header.id,
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
                responseToInsert.add(w);                
       }
       
       system.debug('@@size of header'+header.WIP_Response__r.size());
       if(header.WIP_Response__r.size()>0){
           
           if( WIPType == 'In Progress Survey')
           delete header.WIP_Response__r;
           
       
       }
       if(responseToInsert.size()>0)
         insert responseToInsert;
         system.debug('@@responseToInsert'+responseToInsert);
         system.debug('@@newresponseToInsert'+responseToInsert.size());
    }

    //method used to update existing response
    public void updateExistingQuestions(){
        List<WIP_Response__c> existingResponse = new List<WIP_Response__c>();
        system.debug('@@calling here');
        system.debug('@@calling 3'+section3QuestionClass.size());
        system.debug('@@calling 5'+section5QuestionClass.size());
        system.debug('@@calling 9'+section9QuestionClass);   
           
        for(questionAnswer QM : section1QuestionClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        for(questionAnswer QM : section2QuestionClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        
        for(questionAnswer QM : section3QuestionClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        for(questionAnswer QM : section4QuestionClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        for(questionAnswer QM : section5QuestionClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        for(questionAnswer QM : section6QuestionClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        for(questionAnswer QM : section7QuestionClass )
        {
            QM.response2.AnswerPick__c = QM.answer; 
            QM.response2.notes__c = QM.notes;           
            existingResponse.add(QM.response2);
        }
        
        
        system.debug('@@existingresponse'+existingResponse);
                
        if(existingResponse.size()>0)
          upsert existingResponse ;                  
    }
    
  
    // method used to save records and return detail page 
    public PageReference save(){
        system.debug('@@Ischanged1'+Ischanged1); 
        system.debug('@@Ischanged'+Ischanged);
        mandatoryCheck();
        system.debug('@@Ischanged1'+Ischanged1);
        system.debug('@@Ischanged'+Ischanged);
        pagereference p;
        System.debug('===missedItems==='+missedItems);
        
         if(missedItems == true){
           ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.info, 'Be aware all questions are not answered.  Press \'SAVE\' to close as \'In progress\'');
           ApexPages.addMessage(msg);
           missedItems = false;
           isChanged = true;
           ischanged1 = true;
           system.debug('@@Ischanged'+Ischanged1);
           return null;
        
        }
        system.debug('@@Ischanged'+Ischanged+' '+missedItems);
        try{
            IF(header.id != NULL ){
            if(size10){
                 if(missedItems == false && Ischanged==false)
                 header.Status__c = 'Complete';
                 if(section5QuestionClass.size()>0){
                 createQuestions();
                 system.debug('CreateQuesrtion done');
                 header.Completed_On__c = System.now();
                 header.Question__c='';
                 header.Customer_Unavailable__c=false;
                 update header; 
                 }
                }
                else {
                
                if(missedItems == false && Ischanged == false)
                 header.Status__c = 'Complete';
                 header.Completed_On__c = System.now();
                 header.Question__c='';
                 system.debug('@@hai');
                 updateExistingQuestions();
                 system.debug('@@bye');
                 update header;
                }
            }else IF(header.id == NULL){
                     system.debug('@@Ischanged'+missedItems +' '+Ischanged);
                     Firsttime = false;
                     if(missedItems == false && IsChanged == false){
                     header.Status__c = 'Complete';
                     }
                    header.Question__c=''; 
                    insert header; 
                    createQuestions();
                    update opp;
               
            }
            missedItems = false;
            system.debug('@@'+message);
            p = new pagereference('/'+header.id);
           // p = new pagereference('/apex/WIPForm?signsuccess=0&headerID='+header.id);
            p.setredirect(true);
            return p;
            
        }Catch(Exception e){
            util.setErrorMsg(true, e.getMessage());
            return null;
        }
              
    }
     public PageReference methodtest()
    {
        pagereference p;
        if(signsuccess!=0)
        {
        try{
        System.debug('===In MethodTest====');
        
        PageReference pdfPage = page.WIPFormPDF;
        
        //putting id of custom object in parm id so that I can read it to fetch records
        pdfPage.getParameters().put('headerID',header.id);
        
        Blob pdfBlob = pdfPage.getContent();
            
        Attachment WIPFormPdf = new Attachment(Body = pdfBlob,
                                            Name = 'WIP Log.pdf',
                                            ParentId = header.Id,
                                            isPrivate = false,
                                            contenttype='.pdf'
                                            );
          System.debug('====PDF===='+WIPFormPdf );  
          //System.debug('====emp===='+emp.name);                                                                     
            try{
              insert WIPFormPdf ;
              
                 if(signSuccess==1){
                    System.debug('====sending email====');
                        
                        emailId = header.Visit_Completed_By__r.email;
                        system.debug('@@emailid'+emailid);
                        sendEmail();
                    }
              }
               catch (exception e)
               {
                    system.debug('Error  while saving WIP Form Pdf:'+e.getmessage());
                    util.setErrorMsg(true, e.getmessage());
               }
               p= new pagereference('/'+header.id);
               p.setredirect(true);
               return p;
            }
            catch(Exception e)
        {
            system.debug('Error  while saving WIP Form:'+e.getmessage()); 
            util.setErrorMsg(true, e.getmessage());         
        }
        
        }   
        return null;        
    } 
     
    // Return user to the last page
     public PageReference cancel(){
        PageReference page;
        if(header.id==NULL)
        {
           page = new PageReference('/'+job.id);
        }
        else{
           page = new PageReference('/'+header.id);
        }
        page.setRedirect(true);
        
        return page;
    } 
    
     // To upload attachment
     public PageReference upload() {
        pageReference p;     
        
        IF(header.Id==NULL){
           system.debug('-------------->header value------>'+header.id+' '+header.WIP_Type__c);
            if(missedItems == false){
                 header.Status__c = 'Complete';
            }
            system.debug('@@section answer'+header.WIP_Type__c);
            if(header.WIP_Type__c == 'In Progress Survey' && section9QuestionClass!=NULL){
                if(section9QuestionClass[0].answer != NULL) {
                         insert header;
                         createQuestions(); 
                        
                         header = [SELECT id, Name,status__c,job__c,notes__c,Status_Indicator__c,Customer_Unavailable__c,Conducted_On__c,Visit_Completed_By__c ,Visit_Completed_By__r.email,Completed_On__c,WIP_Type__c,Question__c,               
                                   Visit_Completed_By__r.Name,Reason_For_Visit__c,(SELECT id,AnswerPick__c,Notes__c,order__c,Option__c,Question__c,Section__c,Question_Code__c  FROM WIP_Response__r) 
                                  FROM WIP_Header__c where id=:header.id];
                        
                         checkUpload=true;
                   }
               else {
                  ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.info, 'Please Answer the Customer Availablity Question');
                  ApexPages.addMessage(msg);
                  
               }
              }
             
            else{ 
                insert header;
                createQuestions(); 
            
                header = [SELECT id, Name,status__c,job__c,notes__c,Status_Indicator__c,Customer_Unavailable__c,Conducted_On__c,Visit_Completed_By__c ,Visit_Completed_By__r.email,Completed_On__c,WIP_Type__c,Question__c,Reason_For_Visit__c,              
                          Visit_Completed_By__r.Name,(SELECT id,AnswerPick__c,Notes__c,order__c,Option__c,Question__c,Section__c,Question_Code__c  FROM WIP_Response__r) 
                          FROM WIP_Header__c where id=:header.id];
            
               checkUpload=true;
            }
           
         }
        System.debug('===HeaderId=='+header.ID);
        attachment.ParentId = header.ID;
        //attachment.body=blob.valueof('');
        attachment.OwnerId = UserInfo.getUserId();
        attachment.IsPrivate = false;
        system.debug('@@'+filename);
        
        if(fileName.length() < 1){
            attachment.name = system.Datetime.now()+'.jpg';  
        }else{
            attachment.name = fileName +'.jpg';      
        }
        
        try {
          insert attachment;
          if(checkUpload==true){
                 p = new pagereference('/apex/WIPForm?headerID='+header.id);
                 p.setredirect(true);
                 return p;
           }
          }
          catch (DMLException e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
          return null;
         } finally {
          attachment.body = NULL;
          fileName = NULL;
          attachment = new Attachment();
        }
 
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        return null;
     }
     
     public void sendEmail(){
        try {
        system.debug('@@entered into mail box');
          Id headerID = ApexPages.currentPage().getParameters().get('headerID');
          WIP_Header__c header = [SELECT id, Visit_Completed_By__c,Visit_Completed_By__r.name,Reason_For_Visit__c, Visit_Completed_By__r.email FROM WIP_Header__c WHERE id=:headerID];
          Attachment[] a = [SELECT id,body,name FROM Attachment WHERE parentId=:headerID and Name=:'WIP Log.pdf' order by CreatedDate desc];
          
          //emp = [SELECT id, Name,District__r.Name FROM Employee__c where id = :header.Assigned_To__c];
          //emailId = header.Visit_Completed_By__r.email;
          //List<String> str = emp.Name.split('-');
          //emp.Name = str[0];
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
              efa.setBody(a[0].body);
              efa.setFileName(a[0].name);
              
              //create email message
              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
              email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
              email.setSubject('WIP LOG '+ header.Visit_Completed_By__c);
              email.setPlainTextBody('Dear '+header.Visit_Completed_By__r.name+',\n \nPlease Find attached WIP LOG. \n \nThanks,\n British Gas\n\n Do not respond. This is the automated email.');
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
     
      public void setErrorMsg()
      {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.warning, errorMsg);
        ApexPages.addMessage(msg);
      } 
 }