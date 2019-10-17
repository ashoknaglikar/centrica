public with sharing class casecommentscontroller {

    public list<casecomment> comments_list{get;set;}
    
    public casecommentscontroller(ApexPages.StandardController controller) {
    getList();
    }
    public PageReference getList(){
    
        Id record = System.currentPageReference().getParameters().get('id');
        comments_list = [select CommentBody,CreatedBy.name,CreatedDate from casecomment where ParentId =: record order by createddate];
        return null;
    }
}