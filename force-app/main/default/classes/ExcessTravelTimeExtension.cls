public class ExcessTravelTimeExtension{
    public Excess_Travel_Claim__c etc{get;set;}
    public User loggedInUser{get;set;}
    public List<Employee__c> emp{get;set;}
    public Job__c job{get;set;}
    ApexPages.StandardController sc;
    public boolean error{get;set;}
    
    public ExcessTravelTimeExtension(ApexPages.StandardController sc){
        this.sc = sc;
        etc = (Excess_Travel_Claim__c)sc.getrecord();
        if(etc.Job__c==null){
            Apexpages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: You are not allowed to create Excess Travel Claim from here.'));
            //return null;
            error = true;
        }
        else{
            error = false;
            RecordType InProgress = [Select id,name from RecordType where sObjectType='Excess_Travel_Claim__c' and Name='In Progress'];
            if(InProgress!= null)
            etc.RecordType = InProgress;
            loggedInUser = [Select id,name from User where id=:Userinfo.getUserId()];
            emp = [Select id, name from Employee__C where Salesforce_User__c = :loggedInUser.id and Inactive__c=false];
            if(!emp.isEmpty())
            etc.Employee__c = emp[0].id;
            
            Job__c j = [SELECT id,District__r.Name,Region__c,Installation_Date__c FROM Job__c where id = :etc.Job__c];
            if(j!=null){
                etc.District__c = j.District__r.Name;
                etc.Region__c = j.Region__c;
                etc.Installation_date__c = j.Installation_Date__c;
            }
            if(etc.Status__c==null)
            etc.Status__c = 'In Progress';
        }
    }
    
    public PageReference onClickSave(){
        try{
            PageReference page = sc.save();
            return page;
        }
        catch(Exception e){
            Apexpages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insert failed.'));
            System.debug('======Error===='+e);
            return null;
        }
    }

    public PageReference onClickCancel(){
        try{
            PageReference page = sc.cancel();
            return page;
        }
        catch(Exception e){
            Apexpages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Cancel failed.'));
            System.debug('======Error===='+e);
            return null;
        }
    }
}