public with sharing class caseContactListController  {

    public case caseDetail {get;set;}
    public List<contact> contactDetail {get;set;}
    public String caseID;

    public caseContactListController(ApexPages.StandardController controller) {
    
        system.debug(System.currentPageReference().getParameters().get('Id'));
        // try{
            caseDetail = [select ID, account.id from case where id =: System.currentPageReference().getParameters().get('Id')];
       // } catch (Exception e){}
    
       // try{
            contactDetail = [SELECT id, name, firstName, lastName, Primary_Contact__c, salutation, homephone, otherphone, mobilephone, email__c, Contact_Type__c
                       From contact WHERE account.id =: caseDetail.account.id order by primary_contact__c desc];
          //  }catch(Exception e){} 
    }
    
}