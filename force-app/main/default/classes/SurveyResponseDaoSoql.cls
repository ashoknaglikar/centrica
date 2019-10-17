/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
public with sharing class SurveyResponseDaoSoql
    implements SurveyResponseDao
{
    private static String LEVEL_ERROR = ErrorHandler.LEVEL_ERROR;


    public SurveyResponseDaoSoql(ErrorHandler errorHandler)
    {
        this.errorHandler = errorHandler;
    }


    public class SurveyResponseDaoException extends Exception{}



    public SurveyResponse loadSurvey(Id idToLookup)
    {
        SurveyResponse response;
        Survey_Response__c surveySobject = loadSurveyRecord(idToLookup);
        if(surveySobject != null)
        {
            response = new SurveyResponseSobjectAdapter(surveySobject);
        }
        return response;
    }


    public void updateSurvey(SurveyResponse survey)
    {
       List<SurveyResponse> surveyList = new List<SurveyResponse>();
       surveyList.add(survey);
       saveAnySObjects(surveyList);
    }


    public List<SurveyQuestionResponse> questionsForSurvey(Id surveyId)
    {
        List<SurveyQuestionResponse> result = new List<SurveyQuestionResponse>();
        for(Survey_Question_Response__c record : [  SELECT
                                                          Id
                                                        , SurveyResponse__c
                                                        , Question_Text__c
                                                        , Question_order__c
                                                        , Answer_Text__c
                                                        , Answer_Comment__c
                                                        , Is_for_Recipient__c
                                                        , Development_Survey_Question__c
                                                    FROM
                                                        Survey_Question_Response__c
                                                    WHERE
                                                        SurveyResponse__c = :surveyId
                                                    ORDER BY
                                                        Question_order__c ASC
                                                    ])
        {
            SurveyQuestionResponse adapter = new SurveyQuestionResponseSobjectAdapter(record);
            result.add(adapter);
        }
        return result;
    }


    public void saveQuestions(List<SurveyQuestionResponse> questions)
    {
        saveAnySObjects(questions);
    }


    public List<Survey_Action__c> actionsForSurvey(Id surveyId)
    {
        List<Survey_Action__c> result = new List<Survey_Action__c>();

        result = [  SELECT
                          Id
                        , Action__c
                        , Desired_Outcome__c
                        , Action_Owner__c
                        , Action_Timescale__c
                        , Progress_Made__c
                    FROM
                        Survey_Action__c
                    WHERE
                        Survey_Response__c = :surveyId
                    ORDER BY
                        CreatedDate ASC
                    ];

        return result;
    }

    public void saveActions(List<Survey_Action__c> actions)
    {
        update actions;
    }


    private Survey_Response__c loadSurveyRecord(Id idToLookup)
    {
        Survey_Response__c result;
        List<Survey_Response__c> surveys = [SELECT
                                                  Id
                                                , Name
                                                , SurveyName__c
                                                , Overall_Status__c
                                                , Allocator_Status__c
                                                , Allocator__c
                                                , Allocator__r.Name
                                                , Recipient_Status__c
                                                , Recipient__c
                                                , Recipient__r.Name
                                                , Recipient_Additional_Comments__c
                                                , Review_Date__c
                                                , Desired_Outcome__c
                                                , Development_Action__c
                                                , Action_timescales__c
                                                , Action_owner__c
                                                , Development_Action_Progress__c
                                                , CreatedDate
                                                , LastModifiedDate
                                            FROM 
                                                Survey_Response__c
                                            WHERE
                                                Id = :idToLookup
                                            LIMIT 1];


        if(surveys.size() == 1)
        {
            result = surveys[0];
        }
        else
        {
            errorHandler.handleException(LEVEL_ERROR, 
                'Could not find the Survey you are trying to access', 
                'Contact system administrator. Information trying to find survey with id [' + idToLookup + ']',
                new SurveyResponseDaoException('Trying to lookup Survey_Response__c with id of ' + idToLookup + ', but got ' + surveys.size() + ' results'));
        }
        return result;
    }

    private void saveAnySObjects(List<Object> objects)
    {
        List<SObject> sobjects = new List<SObject>();
        for(Object obj : objects)
        {
            if(obj instanceOf SObjectAdapter)
            {
                SObjectAdapter sobjectAdapter = (SObjectAdapter)obj;
                SObject record = sobjectAdapter.getAdaptedRecord();
                sobjects.add(record);
            }
            else
            {
                System.debug(LoggingLevel.WARN, 'trying to save an Apex object which is not an SObject');
            }
        }
        update sobjects;
    }


    private ErrorHandler errorHandler;
}