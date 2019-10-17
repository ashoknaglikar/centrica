/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
/*
Custom Controller Usage
    controller="SurveyTakingController"
Controller Extension Usage
    standardController="Survey_Response__c"
    extensions="SurveyTakingController"
*/
public with sharing class SurveyTakingController
{
	
    private static final String STATUS_NOT_STARTED = DevelopmentSurveyConstants.STATUS_NOT_STARTED;
    private static final String STATUS_ANSWERING = DevelopmentSurveyConstants.STATUS_ANSWERING;
    private static final String STATUS_READY_FOR_REVIEW = DevelopmentSurveyConstants.STATUS_READY_FOR_REVIEW;
    private static final String STATUS_REVIEWED = DevelopmentSurveyConstants.STATUS_REVIEWED;

    private static final String STATUS_COMPLETE = DevelopmentSurveyConstants.STATUS_COMPLETE;

    private static String ERROR_MESSAGE_SURVEY_NOT_FOUND = 'Survey not found';
    private static String ERROR_MESSAGE_SURVEY_NOT_FOUND_DETAIL = 'The Survey you are attempting to naviate to can not be found, please inform you system administrator';

    id surveyIdTemp;
    //-------  Construction  --------------------------------------

    public SurveyTakingController(ApexPages.StandardController standardController)
    {
    	Id recordId = standardController.getId();
    	surveyIdTemp = recordId;
        SurveyResponseDao surveyDao = new SurveyResponseDaoSoql(new ErrorHandlerApexPage());
        initialize(UserInfo.getUserId(), recordId, surveyDao);
    }


    public SurveyTakingController()
    {
        String idUrlParam = ApexPages.currentPage().getParameters().get('id');
        Id recordId = Id.valueOf(idUrlParam);
        SurveyResponseDao surveyDao = new SurveyResponseDaoSoql(new ErrorHandlerApexPage());
        initialize(UserInfo.getUserId(), recordId, surveyDao);
    }


    public SurveyTakingController(Id userId, Id surveyId, SurveyResponseDao surveyDao)
    {
        initialize(userId, surveyId, surveyDao);
    }


    //-------  Properties  ----------------------------------------


    public Boolean isAllocator
    {
        get{ return ( this.userId == survey.getAllocatorId() ); }
    }

    public Boolean isRecipient
    {
        get{ return ( this.userId == survey.getRecipientId() ); }
    }

    public Boolean isParticipant
    {
        get{ return ( isAllocator || isRecipient ); }
    }

    public String userStatus
    {
        get{ return ( (isAllocator) ? survey.getAllocatorStatus() : survey.getRecipientStatus() ); } 
    }

    public String userName
    {
        get{ return ( (isAllocator) ? survey.getAllocatorName() : survey.getRecipientName() ); } 
    }

    public String userPersona
    {
    	get{ return ( (isAllocator) ? 'Allocator' : 'Recipient' ); }
    }

    public Boolean userInProgress
    {
        get
        {
            return ( (userStatus == STATUS_NOT_STARTED) || (userStatus == STATUS_ANSWERING) );
        }
    }

    public String otherStatus
    {
        get{ return ( (isAllocator) ? survey.getRecipientStatus() : survey.getAllocatorStatus() ); } 
    }

    public String otherName
    {
    	get{ return ( (isAllocator) ? survey.getRecipientName() : survey.getAllocatorName() ); } 
    }

    public String otherPersona
    {
    	get{ return ( (isAllocator) ? 'Recipient' : 'Allocator' ); }
    }


    // --- Rendering Decisions ------------------


    public Boolean followUpRendered
    {
        get
        {
            return ( (survey.getAllocatorStatus() == STATUS_READY_FOR_REVIEW || survey.getAllocatorStatus() == STATUS_REVIEWED)
             && 
             (survey.getRecipientStatus() == STATUS_READY_FOR_REVIEW || survey.getRecipientStatus() == STATUS_REVIEWED) );
        }
    }

    public Boolean followUpInputEnabled
    {
        get
        {
            return markReviewedVisible;
        }
    }

    public Boolean surveyActionInlineEditEnabled
    {
        get
        {
            return ( isAllocator && (overallStatus == STATUS_READY_FOR_REVIEW) );
        }
    }

    public Boolean progressMadeInlineEditEnabled
    {
        get
        {
            return ( isAllocator && (overallStatus == STATUS_READY_FOR_REVIEW || overallStatus == STATUS_COMPLETE) );
        }
    }

    public Boolean saveForLaterVisible
    {
        get{ return ( (userStatus == STATUS_NOT_STARTED) || (userStatus == STATUS_ANSWERING) ); }
    }


    public Boolean markReadyForReviewVisible
    {
        get{ return (userStatus == STATUS_ANSWERING); }
    }

    public Boolean markReviewedVisible
    {
        get
        { 
            return (   (isAllocator)
                    && (survey.getAllocatorStatus() == STATUS_READY_FOR_REVIEW)
                    && (survey.getRecipientStatus() == STATUS_READY_FOR_REVIEW)  );
        }
    }


    public Boolean saveProgressVisible
    {
        get
        {
            return ( isAllocator && (overallStatus == STATUS_READY_FOR_REVIEW || overallStatus == STATUS_COMPLETE) );
        }
    }


    public Boolean surveyLoaded
    {
        get{ return this.survey != null; }
    }



    //-------  Fields  -----------------------------------------
    
    public String surveyName
    {
        get{ return survey.getSurveyName(); }
    }

    public String overallStatus
    {
        get{ return survey.getOverallStatus(); }
    }

    public DateTime createdDate
    {
        get{ return survey.getCreatedDate(); }
    }

    public DateTime lastModifiedDate
    {
        get{ return survey.getLastModifiedDate(); }
    }

    public String recipientAdditionalComments
    {
        get{ return survey.getRecipientAdditionalComments(); }
        set{ survey.setRecipientAdditionalComments(value); }
    }


    public List<DualQuestionItem> questionResponses
    {
        get{ return dualQuestions; }
        set;
    }

    public String reviewDate
    {
        get{ return String.valueOf(survey.getReviewDate()); }
        set{ 
            if(value != null && String.isBlank(String.valueOf(value)) == false) {
                survey.setReviewDate(Date.parse(value));
            }
        }
    }
    
    /*
    public String desiredOutcome
    {
        get{ return survey.getDesiredOutcome(); }
        set{ survey.setDesiredOutcome(value); }
    }
    
    public String developmentAction
    {
        get{ return survey.getAction(); }
        set{ survey.setAction(value); }
    }

    public String actionTimescales
    {
        get{ return survey.getTimescales(); }
        set{ survey.setTimescales(value); }
    }
    
    public String actionOwner
    {
        get{ return survey.getActionOwner(); }
        set{ survey.setActionOwner(value); }
    }
    
    public String actionProgress
    {
        get{ return survey.getActionProgress(); }
        set{ survey.setActionProgress(value); }
    }
    */

    public String desiredOutcome { get; set; }
    public String developmentAction { get; set; }
    public String actionTimescales { get; set; }
    public String actionOwner { get; set; }
    public String actionProgress { get; set; }

    public List<Survey_Action__c> surveyActions { get; set; }


    //-------  Actions  ----------------------------------------

    public PageReference saveForLater()
    {
        surveyDao.updateSurvey(this.survey);
        saveQuestionsThatNeedSaving(this.dualQuestions);
        return pageToNavigateTo;
    }

    public PageReference markReadyForReview()
    {
        saveQuestionsThatNeedSaving(this.dualQuestions);
        if(isAllocator)
        {
            survey.setAllocatorStatus(STATUS_READY_FOR_REVIEW);
        }
        else
        {
            survey.setRecipientStatus(STATUS_READY_FOR_REVIEW);
        }
        surveyDao.updateSurvey(this.survey);
        return pageToNavigateTo;
    }


    public PageReference markReviewed()
    {
        if (String.isBlank(reviewDate)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Review Date is required.'));
            return null;
        } else {
            saveQuestionsThatNeedSaving(this.dualQuestions);
            survey.setAllocatorStatus(STATUS_REVIEWED);
            survey.setRecipientStatus(STATUS_REVIEWED);
            surveyDao.updateSurvey(this.survey);
            return pageToNavigateTo;
        }
    }


    public PageReference saveProgress() 
    {
        surveyDao.saveActions(this.surveyActions);
        return pageToNavigateTo;
    }

    public PageReference addAction()
    {
        Survey_Action__c surveyAction = new Survey_Action__c(
            Survey_Response__c = this.surveyId,
            Action_Owner__c = actionOwner,
            Action_Timescale__c = actionTimescales,
            Desired_Outcome__c = desiredOutcome,
            Action__c = developmentAction,
            Progress_Made__c = actionProgress
        );
        insert surveyAction;

        return pageToNavigateTo;
    }

    //-------  Helpers  ----------------------------------------


    private void initialize(Id userId, Id surveyId, SurveyResponseDao surveyDao)
    {
        this.userId = userId;
        this.surveyId = surveyId;
        this.surveyDao = surveyDao;
        this.pageToNavigateTo = new PageReference('/'+surveyId);

        
        survey = surveyDao.loadSurvey(surveyId); 

        if(survey != null)
        {     
            this.answerSelectOptions = buildAnswerSelectOptions();

            List<SurveyQuestionResponse> questionResponses = surveyDao.questionsForSurvey(this.surveyId);

            dualQuestions = buildDualQuestionItemsFrom(questionResponses);

            surveyActions = surveyDao.actionsForSurvey(this.surveyId);
        }
    }


    private List<DualQuestionItem> buildDualQuestionItemsFrom(List<SurveyQuestionResponse> questionResponses)
    {
        Map<Id, SurveyQuestionResponse> otherPersonsAnswers
             = pullOutOtherPersonsAnswersKeyedByTemplateId(questionResponses);

        List<DualQuestionItem> items = new List<DualQuestionItem>();
        for(SurveyQuestionResponse answer : questionResponses)
        {
            SurveyQuestionResponse otherPersonsAnswer = otherPersonsAnswers.get(answer.getQuestionTemplateId());
            
            if(isAllocator && !answer.isForRecipient())
            {
                DualQuestionItem item = new DualQuestionItem(answer, answerSelectOptions, otherPersonsAnswer);
                items.add(item);
            }
            else if(!isAllocator && answer.isForRecipient())
            {
                DualQuestionItem item = new DualQuestionItem(answer, answerSelectOptions, otherPersonsAnswer);
                items.add(item);
            }
        }

        return items;
    }


    private Map<Id, SurveyQuestionResponse> pullOutOtherPersonsAnswersKeyedByTemplateId(List<SurveyQuestionResponse> questionResponses)
    {
        Map<Id, SurveyQuestionResponse> result = new Map<Id, SurveyQuestionResponse>();
        for(SurveyQuestionResponse answer : questionResponses)
        {

            if(isAllocator && answer.isForRecipient())
            {
                result.put(answer.getQuestionTemplateId(), answer);
            }
            else if( (!isAllocator) && (!answer.isForRecipient()) )
            {
                result.put(answer.getQuestionTemplateId(), answer);
            }
        }
        return result;
    }


    private List<SelectOption> buildAnswerSelectOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
            
        Schema.DescribeFieldResult fieldResult = Survey_Question_Response__c.Answer_Text__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry entry : picklistEntries)
        {
            options.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }       
        return options;
    }


    private void saveQuestionsThatNeedSaving(List<DualQuestionItem> questions)
    {
        List<SurveyQuestionResponse> questionsToUpdate = new List<SurveyQuestionResponse>();
        for(DualQuestionItem adapter : questions)
        {
            if(adapter.needsSaving)
            {
                questionsToUpdate.add(adapter.questionResponse);
            }
        }
        surveyDao.saveQuestions(questionsToUpdate);
    } 

    private Id userId;

    private Id surveyId;
    private SurveyResponse survey;
    private PageReference pageToNavigateTo;

    private List<DualQuestionItem> dualQuestions;
    private List<SelectOption> answerSelectOptions;

    private SurveyResponseDao surveyDao;


    //======= Inner class ==========================================================

    /**
     * wraps/adapts both participants QuestionResponses in a way which is easy
     * to display side by side
     */
    public class DualQuestionItem
    {
        private final String TEXT_TO_SHOW_WHEN_VALUE_NOT_PRESENT = 'Not available';

        public DualQuestionItem( SurveyQuestionResponse thisPersonsAnswer, 
                                 List<SelectOption> options, 
                                 SurveyQuestionResponse otherPersonsAnswer)
        {
            this.thisPersonsAnswer = thisPersonsAnswer;
            this.otherPersonsAnswer = otherPersonsAnswer;
            this.answerTextChanged = false;
            this.answerCommentChanged = false;
            this.options = options;
        }

        public String questionText
        {
            get
            {
                return thisPersonsAnswer.getQuestionText();
            }
        }


        public String order
        {
            get{ return String.valueOf(thisPersonsAnswer.getQuestionOrder()); }
        }
        

        public List<SelectOption> possibleAnswers
        {
            get
            {       
                return options;
            }
        }


        public String answerText
        { 

            get{ return formatAnswerText(thisPersonsAnswer.getAnswerText()); }
            set
            {
                thisPersonsAnswer.setAnswerText(value);
                answerTextChanged = true;
            }
        }

        public String answerComment
        { 

            get{ return formatAnswerComment(thisPersonsAnswer.getAnswerComment()); }
            set
            {
                thisPersonsAnswer.setAnswerComment(value);
                answerCommentChanged = true;
            }
        }


        public String otherPersonsAnswerText
        {
            get
            {
                return (otherPersonsAnswerAvailable()) 
                    ? formatAnswerText(otherPersonsAnswer.getAnswerText()) 
                    : TEXT_TO_SHOW_WHEN_VALUE_NOT_PRESENT;
            }
        }


        public String otherPersonsAnswerComment
        {
            get
            {
                return (otherPersonsAnswerAvailable())
                    ? formatAnswerComment(otherPersonsAnswer.getAnswerComment())
                    : TEXT_TO_SHOW_WHEN_VALUE_NOT_PRESENT;
            }
        }

        public Boolean needsSaving
        {
            get{ return (answerTextChanged || answerCommentChanged); }
        }


        public SurveyQuestionResponse questionResponse
        {
            get{ return thisPersonsAnswer; }
        }
        

        private String formatAnswerText(String input)
        {
            String result = 'None Given';
            if(input != null && input != '')
            {
                result = input;
            }
            return result;
        }

        private String formatAnswerComment(String input)
        {
            String result = 'No Comment Made';
            if(input != null && input != '')
            {
                result = input;
            }
            return result;
        }

        private Boolean otherPersonsAnswerAvailable()
        {
            return (otherPersonsAnswer != null);
        }

       

        private SurveyQuestionResponse thisPersonsAnswer;
        private SurveyQuestionResponse otherPersonsAnswer;
        private Boolean answerTextChanged;
        private Boolean answerCommentChanged;
        private List<SelectOption> options;

    }
    
    public PageReference deleteRecord()
    {
        list<Survey_Question_Response__c> listSurveyResponseRecord = [Select id from Survey_Question_Response__c where SurveyResponse__c = :  surveyIdTemp];
        Survey_Response__c surveyRecord = new Survey_Response__c(id = surveyIdTemp);
        
        try{
            if(listSurveyResponseRecord.size()>0) 
            delete listSurveyResponseRecord;
            delete surveyRecord;
        }catch(exception e)
        {
            throw(e);
            return null;
        }
        return (new pagereference ('/home/home.jsp'));
        
    }

}