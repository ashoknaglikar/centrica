public with sharing class DevelopmentSurveyNewController
{
    
    public DevelopmentSurveyNewController(ApexPages.StandardController standardController)
    {
        survey = new Development_Survey__c();
        survey.RecordTypeId = getDraftRecordTypeId();
        survey.Publication_Status__c = 'Draft';
    }
    
    public Development_Survey__c survey { get; private set; }
    
    public PageReference save()
    {
        insert survey;       
        return new PageReference('/' + survey.id);
    }
    
    
    private static Id getDraftRecordTypeId()
    {
        if(draftRecordTypeId == null)
        {
            List<RecordType> recordTypes = [SELECT Id, DeveloperName, Name FROM RecordType where DeveloperName = 'DevelopmentSurveyDraft' LIMIT 1];
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