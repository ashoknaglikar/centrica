public with sharing class DevelopmentSurveyQuestionNewController
{

    public DevelopmentSurveyQuestionNewController(ApexPages.StandardController standardController)
    {
        question = new Development_Survey_Question__c();
        question.RecordTypeId = getDraftRecordTypeId();
        question.Publication_Status__c = 'Draft';
    }
    
    public Development_Survey_Question__c question { get; private set; }
    
    public PageReference save()
    {
        insert question;       
        return new PageReference('/' + question.id);
    }
    
    
    private static Id getDraftRecordTypeId()
    {
        if(draftRecordTypeId == null)
        {
            List<RecordType> recordTypes = [SELECT Id, DeveloperName, Name FROM RecordType where DeveloperName = 'Draft' LIMIT 1];
        	if(recordTypes.size() != 1)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Draft RecordType could not be found'));
            }
            else
            {
                draftRecordTypeId = recordTypes[0].Id;
            }
        }
        return draftRecordTypeId;
    }
    private static Id draftRecordTypeId;

}