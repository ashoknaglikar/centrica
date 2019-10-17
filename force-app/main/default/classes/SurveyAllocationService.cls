// author DHarfleet
public with sharing class SurveyAllocationService
{
    private static String TASK_SUBJECT = 'A Development Survey {0} needs completing';
    private static String TASK_DESCRIPTION_RECIPIENT = 'A Development Survey has been sent to you by {0} for completion by {1}';
    private static String TASK_DESCRIPTION_ALLOCATOR = 'A Development Survey has been sent by you for completion by {0}';

    private class SurveyQuestionWrapper {
        
        // Wrapper class to encapsulate a Survey uestion instance along with its order in a particular survey
        
        public Development_Survey_Question__c surveyQuestion;
        public Double orderRank;
    }


    public void createSurveyResponses(Map<Id, Allocated_Survey__c> vanillaAllocatedSurveys)
    {
        
        Set<Id> allocatedSurveyKeys = vanillaAllocatedSurveys.keySet();


        List<Allocated_Survey__c> allocatedSurveys = [select Id, Name, Group__c, Employee__c, Development_Survey__r.Id, Development_Survey__r.Name, Development_Survey__r.Description__c, Development_Survey__r.Publication_Status__c from Allocated_Survey__c where Id in :allocatedSurveyKeys];

        
        List<Survey_Response__c> newSurveyResponses = createSurveyResponsesFromAllocatedSurveys(allocatedSurveys);

        insert newSurveyResponses;

        new SurveyResponseSharer().shareWithRecipients(newSurveyResponses);

        Set<Id> developmentSurveyIds = new Set<Id>();
        for(Survey_Response__c surveyResponse : newSurveyResponses)
        {
            developmentSurveyIds.add(surveyResponse.Development_Survey__c);
        }


        Map<Id, List<SurveyQuestionWrapper>> questionsKeyedBySurvey = new Map<Id, List<SurveyQuestionWrapper>>();
        Map<Id, Development_Survey__c> developmentSurveysMap = new Map<Id, Development_Survey__c>();
        for(Development_Survey_Question_Assignment__c junction : [select Id, Name, Order__c, Development_Survey__r.Id, Development_Survey__r.Name, Development_Survey__r.Description__c, Development_Survey__r.Publication_Status__c, Survey_Question__r.Id ,Survey_Question__r.Name, Survey_Question__r.Publication_Status__c from Development_Survey_Question_Assignment__c Where Development_Survey__r.Id in :developmentSurveyIds])
        {
            Id key = junction.Development_Survey__r.Id;
            SurveyQuestionWrapper sqw = new SurveyQuestionWrapper();
            sqw.surveyQuestion = junction.Survey_Question__r;
            sqw.orderRank = junction.Order__c;
            if(questionsKeyedBySurvey.containsKey(key))
            {
                questionsKeyedBySurvey.get(key).add(sqw);
            }
            else
            {
                List<SurveyQuestionWrapper> questions = new List<SurveyQuestionWrapper>();
                questions.add(sqw);
                questionsKeyedBySurvey.put(key, questions);
            }
            developmentSurveysMap.put(junction.Development_Survey__c, junction.Development_Survey__r);
        }


        new SurveyQuestionResponseCreator().createQuestionResponses(newSurveyResponses, questionsKeyedBySurvey);


        List<Task> newTasks = createTasksForSurveyResponses(newSurveyResponses, developmentSurveysMap);

        insert newTasks;

        
    }

    
    private List<Survey_Response__c> createSurveyResponsesFromAllocatedSurveys(List<Allocated_Survey__c> allocatedSurveys)
    {
        List<Survey_Response__c> results = new List<Survey_Response__c>();

        for (Allocated_Survey__c allocatedSurvey : allocatedSurveys)
        {
            results.addAll(createSurveyResponsesFromAllocatedSurvey(allocatedSurvey));
        }

        return results;
    }


    private List<Survey_Response__c> createSurveyResponsesFromAllocatedSurvey(Allocated_Survey__c allocatedSurvey)
    {
        List<Survey_Response__c> results = new List<Survey_Response__c>();

        Id employeeId = allocatedSurvey.Employee__c;
        Id groupId = allocatedSurvey.Group__c;  

        System.debug(LoggingLevel.DEBUG, 'employeeId:' + employeeId);
        System.debug(LoggingLevel.DEBUG, 'groupId:' + groupId);

        Development_Survey__c survey = allocatedSurvey.Development_Survey__r;

        System.debug(LoggingLevel.DEBUG, 'survey.Name:' + survey.Name);

        if( survey == null )
        {
            Id surveyId = allocatedSurvey.Development_Survey__c;
            allocatedSurvey.addError('Development Survey with Id ' + surveyId + 'could not be found');
            System.debug(LoggingLevel.ERROR, 'survey is null');
        }
        else if( survey.Publication_Status__c != 'Published' )
        {
            allocatedSurvey.addError('Development Survey ' + survey.Name + '(' + survey.Id + ')is NOT published, you can not allocate it.');
            System.debug(LoggingLevel.ERROR, 'survey is not published - this should not happen during normal UI usage');
        }
        else if( shouldAllocateToEmployee(groupId, employeeId) )
        {
            System.debug(LoggingLevel.DEBUG, 'allocating to employee ' + employeeId);
            results.add(createSurveyResponseFromEmployeeId(employeeId, survey, allocatedSurvey));
        }
        else if( shouldAllocateToGroup(groupId, employeeId) )
        {
            System.debug(LoggingLevel.DEBUG, 'allocating to group ' + groupId);
            results.addAll(createSurveyResponsesFromGroupId(groupId, survey, allocatedSurvey));
        }

        return results;
    }


    private Boolean shouldAllocateToEmployee(Id groupdId, Id employeeId)
    {
        return( (groupdId == null) && (employeeId != null) );
    }


    private Boolean shouldAllocateToGroup(Id groupId, Id employeeId)
    {
        return( (employeeId == null) && (groupId != null) );
    }


    private List<Survey_Response__c> createSurveyResponsesFromGroupId(Id groupId, Development_Survey__c survey, Allocated_Survey__c allocatedSurvey)
    {
        List<Survey_Response__c> responses = new List<Survey_Response__c>();

        // TODO - The following query should be bulkified by applying the query to all Ids in the allocated survey input to the public function
        //         and then mapping the results in a Map with allocatedSurvey.Id as the key and the User or Group as the value depending on which Id is null
        for(Employee__c employee : [SELECT Salesforce_User__c FROM Employee__c WHERE Id IN (SELECT Employee__c FROM Employee_Group__c WHERE Group__c = :groupId)])//'a0k11000000E8tHAAS')])
        {
            Id userId = employee.Salesforce_User__c;
            responses.add(createSurveyResponseFromUserId(userId, survey, allocatedSurvey));
        }

        return responses;
    }


    private Survey_Response__c createSurveyResponseFromEmployeeId(Id employeeId, Development_Survey__c survey, Allocated_Survey__c allocatedSurvey)
    {   
        List<Employee__c> employees;
        try
        {
            employees = [SELECT Salesforce_User__c FROM Employee__c WHERE Id = :employeeId LIMIT 1];
        }
        catch(Exception e)
        {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            employees = new List<Employee__c>();
        }
        if(employees[0] == null)
        {
            allocatedSurvey.addError('Employee with Id ' + employeeId + 'could not be found');
        }
        Id userId = employees[0].Salesforce_User__c;
        return createSurveyResponseFromUserId(userId, survey, allocatedSurvey);
    }


    private Survey_Response__c createSurveyResponseFromUserId(Id userId, Development_Survey__c survey, Allocated_Survey__c allocatedSurvey)
    {
        Survey_Response__c response = new Survey_Response__c();

        response.SurveyName__c = allocatedSurvey.Name;
        response.Allocated_Survey__c = allocatedSurvey.Id;
        response.Development_Survey__c = survey.Id;
        response.Allocator__c = Userinfo.getUserId();
        response.Recipient__c = userId;

        return response;
    }


    private List<Task> createTasksForSurveyResponses(List<Survey_Response__c> surveyResponses, Map<Id,Development_Survey__c> developmentSurveys)
    {
        List<Task> newTasks = new List<Task>();

        Date dueDate = Date.today().addDays(1);
        String dueDateFormatted = dueDate.format();

        for(Survey_Response__c response : surveyResponses)
        {
            Development_Survey__c developmentSurvey = developmentSurveys.get(response.Development_Survey__c);

            newTasks.add(createAllocatorsTask(response, dueDate, dueDateFormatted));
            newTasks.add(createRecipientsTask(response, dueDate, dueDateFormatted, developmentSurvey));
        }

        return newTasks;
    }


    private Task createAllocatorsTask(Survey_Response__c response, Date dueDate, String dueDateFormatted)
    {
        String subject = String.format(TASK_SUBJECT, new String[]{response.SurveyName__c});
        String description = String.format(TASK_DESCRIPTION_ALLOCATOR, new String[]{dueDateFormatted});
        return DevelopmentSurveyTaskFactory.createTask(Userinfo.getUserId(), dueDate, response.Id, subject, description);
    }


    private Task createRecipientsTask(Survey_Response__c response, Date dueDate, String dueDateFormatted, Development_Survey__c developmentSurvey)
    {
        String subject = String.format(TASK_SUBJECT, new String[]{response.SurveyName__c});
        String description = String.format(TASK_DESCRIPTION_ALLOCATOR, new String[]{UserInfo.getName(),dueDateFormatted});
        return DevelopmentSurveyTaskFactory.createTask(response.Recipient__c, dueDate, response.Id, subject, description);
    }
    

    /**
     * Utility class for creating Question Responses (i.e. Answer holders)
     * In a seperate class so that sharing can be ignored and instead controlled by
     * code by way of setting the OwnerId.
     */
    private without sharing class SurveyQuestionResponseCreator
    {

        public void createQuestionResponses(List<Survey_Response__c> responses, Map<Id, List<SurveyQuestionWrapper>> questionsKeyedBySurvey)
        {
            
            List<Survey_Question_Response__c> questionResponses = new List<Survey_Question_Response__c>();
            for(Survey_Response__c surveyResponse : responses)
            {
                List<SurveyQuestionWrapper> questions = questionsKeyedBySurvey.get(surveyResponse.Development_Survey__c);
                for(SurveyQuestionWrapper questionWrapper : questions)
                {
                    Development_Survey_Question__c question = questionWrapper.surveyQuestion;
                    Double orderRank = questionWrapper.orderRank;
                    if(question.Publication_Status__c == 'Published')
                    {
                        System.debug(LoggingLevel.DEBUG, 'user id' + UserInfo.getUserId());
                        System.debug(LoggingLevel.DEBUG, 'recipient id' + surveyResponse.Recipient__c);
                        questionResponses.add(createQuestionResponseForRecipient(surveyResponse, question, orderRank));
                        questionResponses.add(createQuestionResponseForAllocator(surveyResponse, question, orderRank));
                    }
                }
            }
            insert questionResponses;
        }


        private Survey_Question_Response__c createQuestionResponseForRecipient(Survey_Response__c surveyResponse, Development_Survey_Question__c question, Double orderRank)
        {
            return createQuestionResponse(surveyResponse, question, orderRank, surveyResponse.Recipient__c, true);
        }


        private Survey_Question_Response__c createQuestionResponseForAllocator(Survey_Response__c surveyResponse, Development_Survey_Question__c question, Double orderRank)
        {
            return createQuestionResponse(surveyResponse, question, orderRank, UserInfo.getUserId(), false);
        }


        private Survey_Question_Response__c createQuestionResponse(Survey_Response__c surveyResponse, Development_Survey_Question__c question, Double orderRank, Id ownerId, Boolean isForRecipient)
        {
            Survey_Question_Response__c questionResponse = new Survey_Question_Response__c();
            
            questionResponse.Development_Survey_Question__c = question.Id;
            questionResponse.SurveyResponse__c = surveyResponse.Id;
            questionResponse.Allocator__c = Userinfo.getUserId();
            questionResponse.Recipient__c = surveyResponse.Recipient__c;
            questionResponse.OwnerId = ownerId;
            questionResponse.Is_for_Recipient__c = isForRecipient;
            questionResponse.Question_order__c = orderRank;

            return questionResponse;
        }

    }

    /**
     * Utility Class for sharing SurveyResponses
     * In a seperate class so that without sharing can be used.
     * Very similar to inner class in SurveyResponseService. Refactor to extract
     * commonality.
     */
    private without sharing class SurveyResponseSharer
    {

        private void shareWithRecipients(List<Survey_Response__c> surveyResponses)
        {
            List<Survey_Response__Share> shares = new List<Survey_Response__Share>();

            for(Survey_Response__c surveyResponse : surveyResponses)
            {
                shares.add(createSurveyResponseShareFrom(surveyResponse));
            }

            List<Database.SaveResult> saveResults = Database.insert(shares, false);

            handleSurveyResponseShareErrors(saveResults);
        }


        private Survey_Response__Share createSurveyResponseShareFrom(Survey_Response__c surveyResponse)
        {
            Survey_Response__Share share = new Survey_Response__Share();
            share.ParentId = surveyResponse.Id;
            share.UserOrGroupId = surveyResponse.Recipient__c;
            share.AccessLevel = 'Edit';
            share.RowCause = Schema.Survey_Response__share.RowCause.Recipient__c;
            return share;
        }


        private void handleSurveyResponseShareErrors(List<Database.SaveResult> saveResults)
        {   
            for(Database.SaveResult saveResult : saveResults)
            {
                if(saveResult.isSuccess())
                {
                    System.debug(LoggingLevel.DEBUG, 'Sharing applied for recipents');
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
                            System.debug(LoggingLevel.WARN, 'Something went wrong with sharing a Survey to recipient' + databaseError.getMessage());
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

    }


}