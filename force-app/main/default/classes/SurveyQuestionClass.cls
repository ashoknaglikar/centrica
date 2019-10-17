public class SurveyQuestionClass {
    public QMaster__c questionRecord {get;set;}
    public list<selectOption> selectOptions {get;set;}
    public string selectValue {get;set;}
    public Decimal dynamicNumber{get;set;}
    public  SurveyQuestionClass (QMaster__c questionRecord, string tradingName , Decimal  dynamicNumber){
        
        this.questionRecord = questionRecord;
        this.dynamicNumber = dynamicNumber;
        
        if(questionRecord.NPS_Options_Text__c != null)
        {
            selectOptions = new list<selectOption>();
            list <string> selectList = questionRecord.NPS_Options_Text__c.replaceall('%BRAND%', tradingName).split('\\|');
            
            for(string s: selectList)
            { 
                selectOptions.add(new selectOption(s,s));
            }
            
        }
        
    }
    
}