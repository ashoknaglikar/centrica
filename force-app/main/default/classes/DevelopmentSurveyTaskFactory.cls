public without sharing class DevelopmentSurveyTaskFactory
{

    public static final String TASK_TYPE_TAKE_SURVEY = 'Development Survey';
    public static final String TASK_TYPE_MAKE_REVIEW_APPOINTMENT = 'Development Survey Review';

    public static Id getSurveyTaskRecordType()
    {
        if(surveyTaskRecordTypeId == null)
        {
            Id recordTypeId = [Select Id From RecordType WHERE DeveloperName ='Development_Survey' and SobjectType ='Task'  limit 1][0].Id;
            surveyTaskRecordTypeId = recordTypeId;
        }
        return surveyTaskRecordTypeId;
    }
    private static Id surveyTaskRecordTypeId;


    public static Task createTask(Id ownerId, Date dueDate, Id surveyResponseId, String subject, String description)
    {
        Task task = new Task();
        task.Type = TASK_TYPE_TAKE_SURVEY;
        task.RecordTypeId = getSurveyTaskRecordType();
        task.Subject = subject;
        task.ActivityDate = dueDate;
        task.Description = description;
        task.OwnerId = ownerId;
        task.WhatId = surveyResponseId;
        return task;
    }
    
    public static Id getSurveyReviewTaskRecordType()
    {
        if(surveyReviewTaskRecordTypeId == null)
        {
            Id recordTypeId = [Select Id From RecordType WHERE DeveloperName ='DevelopmentSurveyReview' and SobjectType ='Task'  limit 1][0].Id;
            surveyReviewTaskRecordTypeId = recordTypeId;
        }
        return surveyReviewTaskRecordTypeId;
    }
    private static Id surveyReviewTaskRecordTypeId;


    public static Task createReviewTask(Id ownerId, Date dueDate, Id surveyResponseId, String subject, String description)
    {
        Task task = new Task();
        task.Type = TASK_TYPE_MAKE_REVIEW_APPOINTMENT;
        task.RecordTypeId = getSurveyReviewTaskRecordType();
        task.Subject = subject;
        task.ActivityDate = dueDate;
        task.Description = description;
        task.OwnerId = ownerId;
        task.WhatId = surveyResponseId;
        return task;
    }
    
    


}