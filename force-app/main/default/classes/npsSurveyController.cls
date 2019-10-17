public class npsSurveyController {
    public String valSelected = '';
    public boolean showQuestionSection{get;set;}
    public boolean showWelcomePage{get;set;}
    public boolean showThankyouPage{get;set;}
    public list <SurveyQuestionClass> npsSurveyQuestions {get;set;}
    public map<String , list<SurveyQuestionClass>> npsSurveyQuestionsByPage {get;set;}
    public integer intNextVal{get;set;}
    private list <SurveyQuestionClass> npsSurveyQuestionsLocal;
    public string errorMsg{get;set;}
    public String progressBar{get;set;}
    public boolean startSurvey{get;set;}
    public boolean showErrorMessage{get;set;}
    public boolean showCompleteMessage{get;set;}
    public boolean showfeedBackMessage{get;set;}
    public  List<Survey_Answer__c> CustomerSurvey{get;set;}
    public boolean showExistingSurvey{get;set;}
    Utilities utilClass = new Utilities();
    integer currentpage = 0;
    string chiLeadId = '';
    public string tradingName {get;set;}  
    public string buttonName {get;set;}
    public map<integer,string> mapOfOrderRes{get;set;}
    public map<integer,Survey_Answer__c> mapOfSavedRes{get;set;}
    Decimal totalNPSSurveyQuestion;
    List<Survey__c> newSurvey = new List<Survey__c>();
    public Integer rowNumCtr{get;set;}
    list<string> notShow = new list<string>();
    list<string> onlyShow = new list<string>();
    public boolean required{get;set;}
    public integer totalPage{get;set;} 
    String brandName='';
    public npsSurveyController()
    { 
        rowNumCtr = 1;
        totalNPSSurveyQuestion=0;//[SELECT count()FROM QMaster__c WHERE Form__c = 'NPS - Unsold Quotes'];
        mapOfOrderRes = new map<integer,string>();
        mapOfSavedRes = new map<integer,Survey_Answer__c>();
        showWelcomePage=True;
        intNextVal=0;
        npsSurveyQuestionsLocal=new list <SurveyQuestionClass>();
        showQuestionSection=False;
        showThankyouPage=False;
        startSurvey=False;
        tradingName = 'British Gas';
        showErrorMessage=False;
        buttonName = ' Next ';
        showExistingSurvey=False;
        showCompleteMessage=false;
        showfeedBackMessage=false;
        chiLeadId = ApexPages.currentPage().getParameters().get('LeadId');
        if(!String.IsBlank(chiLeadId)){
            startSurvey=true;
            showErrorMessage=False;
            Opportunity opp = [select id,NPS_Not_Show_Decider__c, Trading_Name__c, (Select id,NPS_Not_Show_decider__c from Bigmachines_Quotes__r where Is_Primary__c = true ) from Opportunity Where id = :chiLeadId];
            tradingName = opp.Trading_Name__c;
            
            newSurvey=[select id,Survey_Name__c,Opportunity__c,Status__c from Survey__c where Opportunity__c =: chiLeadId];
            
            list<string> showDecider = opp.NPS_Not_Show_Decider__c.split(':');
            if(showDecider.size()==4)
            {
                notShow = showDecider[1].split(';');
                onlyShow = showDecider[3].split(';');
            }
            
            if(opp.Bigmachines_Quotes__r.size()>0)
            {
                showDecider = opp.Bigmachines_Quotes__r[0].NPS_Not_Show_decider__c.split(':');
                if(showDecider.size()==4)
                {
                    notShow.addAll(showDecider[1].split(';'));
                    onlyShow.addAll(showDecider[3].split(';'));
                }
            }
            
            system.debug('Not Show-->'+notShow);
            system.debug('Not Show-->'+onlyShow);
            
            CustomerSurvey = [Select Question__c,Response__c,order__c from Survey_Answer__c where survey__r.Opportunity__c=:chiLeadId  order by Order__c];
            for(Survey_Answer__c temp: CustomerSurvey){
                
                mapOfOrderRes.put(integer.valueof(temp.order__c),temp.Response__c);
                mapOfSavedRes.put(integer.valueof(temp.order__c),temp);
            }
            
        }
        else
        {
            showErrorMessage=true;
            startSurvey=False;
            errorMsg = 'You have no valid customer survey link.';
            setErrorMsg();
        }
        
        if(newSurvey.size()>0 && newSurvey[0].status__c=='Complete')
        {
            showCompleteMessage=true;
            startSurvey=False;          
        }
        
    }
    Public void firstPage(){
        showWelcomePage=False;
        startSurvey=false;
        showQuestionSection=True;
        showfeedBackMessage=true;
        string surveyName = IV_Vectors__c.getInstance(ApexPages.currentPage().getParameters().get('NPSType')).Key__c;
        npsSurveyQuestionsByPage = new map<String , list<SurveyQuestionClass>>();
        npsSurveyQuestions = new list <SurveyQuestionClass>();
        //List<opportunity> notShowIn= new List<opportunity>([select Quote_Payment_Method__c,	Product_Interest__c from opportunity where id=:chiLeadId ]);
        list<QMaster__c> QuestionList = [Select id, Name ,  Active__c, Form__c, NPS_Options_Text__c, Page_Number__c, Order__c , NPS_Question_text__c,
                                         Question_Type__c, Report_Text__c, Section__c, 	Section_Description__c,	Section_Order__c,Required__c, Not_Show_in__c,Question_Code__c 
                                         , Only_Show_In__c from QMaster__c 
                                         where Form__c  =:surveyName and Active__c = true Order By Order__c]; 
        system.debug('QuestionList=='+QuestionList);
        list<SurveyQuestionClass> tempList = new list<SurveyQuestionClass>();
        for(QMaster__c q: QuestionList)
        {
            boolean add = false;
            system.debug('Question-->'+q.NPS_Question_text__c);
            system.debug('Only Show in-->'+q.Only_Show_In__c);
            system.debug('Not Show from Opp-->'+notShow);
            system.debug('Only Show in from opp -->'+onlyShow);
            if(q.Only_Show_In__c==null)
            {
                for(string s: notShow)
                {
                    system.debug('In Not Show -- >'+s +' '+q.Not_Show_in__c);
                    
                    if(!(q.Not_Show_in__c!=null && q.Not_Show_in__c.contains(s)))
                    {
                        add = true;
                        
                        
                    }else 
                    {
                        add = false;
                        break;
                    }
                    
                    
                }
            }
            system.debug(add);
            if(!add)
            {
                for(string s: onlyShow)
                {
                    system.debug('In only Show -- >'+s +' '+q.Only_Show_In__c);
                    if(q.Only_Show_In__c!=null && q.Only_Show_In__c.contains(s) )
                    {
                        add = true;
                        break;
                        
                    }else
                    {
                        add = false;
                        //break;
                    }
                    
                }
                system.debug(add);
            }
            
            if(add) 
            {
                totalNPSSurveyQuestion++;
                if(q.Page_Number__c!= null && npsSurveyQuestionsByPage.containsKey(q.Page_Number__c))
                {
                    npsSurveyQuestionsByPage.get(q.Page_Number__c).add(new SurveyQuestionClass(q, tradingName , totalNPSSurveyQuestion));
                }else
                {
                    npsSurveyQuestionsByPage.put(q.Page_Number__c, new list<SurveyQuestionClass>{new SurveyQuestionClass(q, tradingName , totalNPSSurveyQuestion)});
                }
            }
            
            
            
            // npsSurveyQuestions.add(new SurveyQuestionClass(q, 'British Gas'));
            
        }
        totalPage= npsSurveyQuestionsByPage.size();
        if(newSurvey.isEmpty() && chiLeadId!=NULL){
            Survey__c npsSurvey= new Survey__c();
            npsSurvey.Survey_Name__c= surveyName;
            npsSurvey.Opportunity__c=chiLeadId;
            npsSurvey.Status__c='Incomplete';
            newSurvey.add(npsSurvey);
            insert newSurvey;   
        }
        if(newSurvey.size()>0 && newSurvey[0].Status__c=='Incomplete' && totalNPSSurveyQuestion > 0){
            progressBar=Integer.valueOf((mapOfOrderRes.size()/totalNPSSurveyQuestion)*100) +'%';
        }else if(newSurvey.size()>0 && newSurvey[0].Status__c=='Complete'){
            progressBar = '100%';
        }else{
            progressBar='0%'; 
        }
        system.debug('npsSurveyQuestions=='+npsSurveyQuestions);
        //npsSurveyQuestions= npsSurveyQuestionsByPage.values()[currentpage];
        if(mapOfOrderRes.size()>0){
            for(SurveyQuestionClass temp : npsSurveyQuestionsByPage.values()[intNextVal]){
                temp.selectValue = mapOfOrderRes.get(integer.valueOf(temp.questionRecord.Order__c));
                npsSurveyQuestions.add(temp);
            }
        }else{
            if(npsSurveyQuestionsByPage.size()>0)
            {
                npsSurveyQuestions= npsSurveyQuestionsByPage.values()[intNextVal];
                if(npsSurveyQuestionsByPage.size() == 1) buttonName = 'Finish';
            }
            else
            {
                errorMsg = 'Sorry ! No questions to display.';
                setErrorMsg();
                
            }
        }
        
    }
    public  pagereference next(){
        list<Survey_Answer__c> surveyAnswerNextList=new list<Survey_Answer__c>();
        list<Survey_Answer__c> surveyAnswerSubmitList=new list<Survey_Answer__c>();
        List<Survey__c> newSurvey=new List<Survey__c>([select id,Survey_Name__c,Opportunity__c,Status__c from Survey__c where Opportunity__c =: chiLeadId]);
        showWelcomePage=False;
        startSurvey=false;
        showQuestionSection=true;
        showThankyouPage=False;
        showfeedBackMessage=false;
        CustomerSurvey = [Select Question__c,Response__c,order__c from Survey_Answer__c where survey__r.Opportunity__c=:chiLeadId  order by Order__c];
        for(Survey_Answer__c temp: CustomerSurvey){
            mapOfOrderRes.put(integer.valueof(temp.order__c),temp.Response__c);
            mapOfSavedRes.put(integer.valueof(temp.order__c),temp);
        }
        
        
        if(checkMandatory()){
            // add the code to save the current page records. 
            system.debug('npsSurveyQuestions='+npsSurveyQuestions);
            string surveyName = IV_Vectors__c.getInstance(ApexPages.currentPage().getParameters().get('NPSType')).Key__c;
            //Move to next page
            if (intNextVal+1 < npsSurveyQuestionsByPage.size())
            {
                intNextVal++;
                for(SurveyQuestionClass SQCObj:npsSurveyQuestions){
                    if(mapOfSavedRes.size()>0 && mapOfSavedRes.containsKey(integer.valueOf(SQCObj.questionRecord.Order__c))){
                        mapOfSavedRes.get(integer.valueOf(SQCObj.questionRecord.Order__c)).Response__c = SQCObj.selectValue;
                        surveyAnswerNextList.add(mapOfSavedRes.get(integer.valueOf(SQCObj.questionRecord.Order__c)));
                    }else{
                        Survey_Answer__c SAObj=new Survey_Answer__c();
                        brandName=SQCObj.questionRecord.NPS_Question_text__c;
                        system.debug('tradingName'+tradingName);
                        system.debug('brandName'+SQCObj.questionRecord.NPS_Question_text__c);
                        if(string.isNotBlank(brandName) && brandName.contains('%BRAND%')){
                        brandName=brandName.replace('%BRAND%', tradingName);
                        SAObj.Question__c=brandName;
                        }
                        else
                        {
                        SAObj.Question__c=SQCObj.questionRecord.NPS_Question_text__c;
                        }
                        system.debug('SAObj.Question__c'+SAObj.Question__c);
                        SAObj.Response__c=SQCObj.selectValue;
                        SAObj.Order__c = SQCObj.questionRecord.Order__c;
                        SAobj.Survey__c=newSurvey[0].Id;
                        SAobj.Question_Code__c=SQCObj.questionRecord.Question_Code__c;
                        SAobj.Short_Question__c=SQCObj.questionRecord.Report_Text__c;
                        surveyAnswerNextList.add(SAObj);
                        mapOfOrderRes.put(integer.valueOf(SQCObj.questionRecord.Order__c),SQCObj.selectValue);
                    }
                }
                
                if(mapOfOrderRes.size()>0){
                    npsSurveyQuestions.clear();
                    for(SurveyQuestionClass temp : npsSurveyQuestionsByPage.values()[intNextVal]){
                        temp.selectValue = mapOfOrderRes.get(integer.valueOf(temp.questionRecord.Order__c));
                        npsSurveyQuestions.add(temp);
                    }
                }else{
                    npsSurveyQuestions= npsSurveyQuestionsByPage.values()[intNextVal];
                    
                }    
                
                if(newSurvey[0].id!=NULL&& newSurvey[0].Status__c=='Incomplete')
                {   
                    upsert surveyAnswerNextList;
                    progressBar=Integer.valueOf((mapOfOrderRes.size()/totalNPSSurveyQuestion)*100) +'%';
                } 
                
                if(intNextVal+1 == npsSurveyQuestionsByPage.size()) {
                    buttonName = 'Finish';
                }
            }else
            {
                // Finish Screen
                showQuestionSection=False;  
                showThankyouPage=True;
                for(SurveyQuestionClass SQCObj:npsSurveyQuestions){
                    
                    if(mapOfSavedRes.size()>0 && mapOfSavedRes.containsKey(integer.valueOf(SQCObj.questionRecord.Order__c))){
                        mapOfSavedRes.get(integer.valueOf(SQCObj.questionRecord.Order__c)).Response__c = SQCObj.selectValue;
                        surveyAnswerSubmitList.add(mapOfSavedRes.get(integer.valueOf(SQCObj.questionRecord.Order__c)));
                    }else{
                        Survey_Answer__c SAObj=new Survey_Answer__c();
                        brandName=SQCObj.questionRecord.NPS_Question_text__c;
                        if(string.isNotBlank(brandName) && brandName.contains('%BRAND%')){
                        brandName=brandName.replace('%BRAND%', tradingName);
                        SAObj.Question__c=brandName;
                        }
                        else
                        {
                        SAObj.Question__c=SQCObj.questionRecord.NPS_Question_text__c;
                        }
                        SAObj.Response__c=SQCObj.selectValue;
                        SAObj.Order__c = SQCObj.questionRecord.Order__c;
                        SAobj.Survey__c=newSurvey[0].Id; 
                        SAobj.Question_Code__c=SQCObj.questionRecord.Question_Code__c;
                        SAobj.Short_Question__c=SQCObj.questionRecord.Report_Text__c;
                        surveyAnswerSubmitList.add(SAObj);
                        mapOfOrderRes.put(integer.valueOf(SQCObj.questionRecord.Order__c),SQCObj.selectValue);
                    }
                } 
                if(newSurvey[0].id!=NULL&& newSurvey[0].Status__c=='Incomplete')
                {
                    upsert  surveyAnswerSubmitList;
                    newSurvey[0].Status__c='Complete';
                    update newSurvey;
                } 
            }
            if(mapOfOrderRes.size()>0 && totalNPSSurveyQuestion > 0){
            progressBar=Integer.valueOf((mapOfOrderRes.size()/totalNPSSurveyQuestion)*100) +'%';
            }
        }
        else
        {
            errorMsg = 'Please answer all the * marked questions before moving to next page.  Thank You.';
            setErrorMsg();
            
        }
        return NULL; 
    }
    
    public  void previous(){
        //move to previous page
        //
        buttonName=' Next ';
        if(intNextVal>=1)
        {
            intNextVal--;
            for(Survey_Answer__c temp: CustomerSurvey){
                mapOfOrderRes.put(integer.valueof(temp.order__c),temp.Response__c);
            }
            if(mapOfOrderRes.size()>0){
                npsSurveyQuestions.clear();
                for(SurveyQuestionClass temp : npsSurveyQuestionsByPage.values()[intNextVal]){
                    temp.selectValue = mapOfOrderRes.get(integer.valueOf(temp.questionRecord.Order__c));
                    npsSurveyQuestions.add(temp);
                }
            }
            if(intNextVal==1){
                
             showfeedBackMessage=true;   
            }
        }
    }
    
    public boolean checkMandatory()
    {   
        required = false;
        Boolean checkMandatory=True;
        for(SurveyQuestionClass SQCObj:npsSurveyQuestions){
            if(SQCObj.questionRecord.Required__c == 'Yes' && SQCObj.selectValue==NULL ){
                checkMandatory = False;
                required = true;
            }            
        }
        return checkMandatory;
    }
    public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.warning, errorMsg);
        ApexPages.addMessage(msg);
    }
    
}