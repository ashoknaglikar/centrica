public without sharing class SurveyResponseService
{
    

    public static final String NOT_STARTED = 'Not Started';
    public static final String ANSWERING = 'Answering';
    public static final String READY_FOR_REVIEW = 'Ready for Review';
    public static final String COMPLETE = 'Complete';


    public SurveyResponseService()
    {
         newTasks = new List<Task>();
         questionsToShare = new List<Survey_Question_Response__c>();
         questionsKeyedBySurvey = new Map<Id, List<Survey_Question_Response__c>>(); 
    }


    private void cacheQuestionsBySurvey(Map<Id, Survey_Response__c> newValues)
    {
        List<Survey_Question_Response__c> allQuestions = [Select Id, SurveyResponse__c, Is_for_Recipient__c, Recipient__c, Allocator__c from Survey_Question_Response__c where SurveyResponse__c in :newValues.keySet()];
        for(Survey_Question_Response__c question : allQuestions)
        {
            Id key = question.SurveyResponse__c;

            if(questionsKeyedBySurvey.containsKey(key))
            {
                questionsKeyedBySurvey.get(key).add(question);
            }
            else
            {
                List<Survey_Question_Response__c> questions = new List<Survey_Question_Response__c>();
                questions.add(question);
                questionsKeyedBySurvey.put(key, questions);
            }
        }
    }


    public void respondToSurveyStatusChanges(Map<Id, Survey_Response__c> oldValues, Map<Id, Survey_Response__c> newValues)
    {
        List<Survey_Response__c> surveyResponses = [Select Id, Name, Allocator_Status__c, Recipient_Status__c, Allocator__r.Name, Recipient__r.Name from Survey_Response__c where Id in :newValues.keySet()];

        cacheQuestionsBySurvey(newValues);


        for(Survey_Response__c survey : surveyResponses)
        {
            Survey_Response__c oldRecord = oldValues.get(survey.Id);

            if(statusHasChanged(survey, oldRecord))
            {
                respondToSurveyStatusChange(survey);
            }
        }

        //new AnswerSharer().shareWithBothParticipents(questionsToShare);

        insert newTasks;

    }


    public void respondToSurveyStatusChange(Survey_Response__c survey)
    {
        if(bothParticipantsAreReadyToReview(survey))
        {
            makeAllQuestionsReadOnly();
            shareAllQuestionsWithEachOther(survey);
            sendAllocatorTaskToMakeAppointment(survey);
        }
    }


    private void makeAllQuestionsReadOnly()
    {
        // Achieved by Validation Rule on Survey_Question_Response__c
        // named 'ReadyForReview'. This comment left here to document completeness
        // of solution
    }


    private void shareAllQuestionsWithEachOther(Survey_Response__c survey)
    {
        List<Survey_Question_Response__c> questions = questionsKeyedBySurvey.get(survey.Id);
        questionsToShare.addAll(questions);
    }


    private void sendAllocatorTaskToMakeAppointment(Survey_Response__c surveyResponse)
    {
        Id ownerId = surveyResponse.Allocator__c;
        Date dueDate = Date.today().addDays(1);
        String surveyName = surveyResponse.Name;
        String recipientName = surveyResponse.Recipient__r.Name;
        String subject = 'Make appointment with ' + recipientName;
        String description = 'Please make an appointment with ' + recipientName + ' to review the responses to the survey ' + surveyName + ' attached to this task';
        
        Task task = DevelopmentSurveyTaskFactory.createReviewTask(ownerId, dueDate, surveyResponse.Id, subject, description);
        
        newTasks.add(task);
    }


    private Boolean bothParticipantsAreReadyToReview(Survey_Response__c survey)
    {
        return ( (survey.Allocator_Status__c == READY_FOR_REVIEW) && (survey.Recipient_Status__c == READY_FOR_REVIEW) );
    }


    private Boolean statusHasChanged(Survey_Response__c survey, Survey_Response__c oldRecord)
    {
        return ( (survey.Recipient_Status__c != oldRecord.Recipient_Status__c) || (survey.Allocator_Status__c != oldRecord.Allocator_Status__c) );
    }

    private List<Task> newTasks;
    private List<Survey_Question_Response__c> questionsToShare;
    Map<Id, List<Survey_Question_Response__c>> questionsKeyedBySurvey;
        


    /**
     * Utility Class for sharing SurveyQuestionResponses
     * In a seperate class so that without sharing can be used
     * Note is very similar to class in SurveyAllocationService
     * need to refactor to extract commonality
     */
    /*
    private without sharing class AnswerSharer
    {

        private void shareWithBothParticipents(List<Survey_Question_Response__c> questions)
        {
            List<Survey_Question_Response__Share> shares = new List<Survey_Question_Response__Share>();

            for(Survey_Question_Response__c question : questions)
            {
                shares.add(createQuestionShareFrom(question));
            }

            List<Database.SaveResult> saveResults = Database.insert(shares, false);

            handleShareErrors(saveResults);
        }


        private Survey_Question_Response__Share createQuestionShareFrom(Survey_Question_Response__c question)
        {
            Survey_Question_Response__Share share = new Survey_Question_Response__Share();
            share.ParentId = question.Id;
            if(question.Is_for_Recipient__c)
            {
                share.UserOrGroupId = question.Allocator__c;
            }
            else
            {
                share.UserOrGroupId = question.Recipient__c;
            }
            share.AccessLevel = 'Read';
            share.RowCause = Schema.Survey_Question_Response__share.RowCause.Review_by_Participants__c;
            return share;
        }


        private void handleShareErrors(List<Database.SaveResult> saveResults)
        {   
            for(Database.SaveResult saveResult : saveResults)
            {
                if(saveResult.isSuccess())
                {
                    System.debug(LoggingLevel.DEBUG, 'Sharing applied for participants');
                }
                else
                {
                    for(Database.Error databaseError: saveResult.getErrors())
                    {
                        if(userOrGroupHasAccessAnyway(databaseError))
                        {
                            System.debug(LoggingLevel.DEBUG, databaseError.getMessage());
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Something went wrong with sharing an answer to a question between review participants:' + databaseError.getMessage());
                        }
                    }
                }
            }
        }


        private Boolean userOrGroupHasAccessAnyway(Database.Error databaseError)
        {
            return ( databaseError.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION
                      &&
                     databaseError.getMessage().contains('AccessLevel') );
        }


    }*/


    
}