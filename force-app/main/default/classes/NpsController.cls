/*
Type Name: NpsController
Author: Cognizant
Created Date: 22/04/2010
Reason: To populated CHI lead and Account in NPS while creating NPS object.
Change History:
*/

public class NpsController{
    //Variable declaration section.
    Pagereference pageRef = null;
    Opportunity opportunity = null;
    String accountName = null;
    Id accountId = null;
    NPS__c npsObject;
    
    //public constructor to get NPS record.
    public NpsController(ApexPages.StandardController controller) {
        npsObject = (NPS__c)controller.getRecord();
    }

    /**
    This is the action method called from NPSIntermidiate page.
    This method is populates the Account and CHI Lead from for NPS and
    redirects to the NPS create view.
    */  
    public Pagereference npsCHILeadAccountMethod()
    {
        /**
        Checkinfg for NPS object.
        Following flow will be exceuted if NPS is not null and
        Opportunity for that NPS is not null.
        */
        
        if(npsObject != null)
        {
            if(npsObject.Opportunity__c != null)        
            {
                //Retrieving Opportunity object assciated with NPS.
                opportunity = [Select o.Name, o.Id, o.Account.Name, o.Account.Id,
                o.AccountId From Opportunity o where o.Id =: npsObject.Opportunity__c
                limit 1];
                
                //Associating Account of NPS with the Account of Opportunity of NPS.
                accountId = opportunity.Account.Id;
                accountName = opportunity.Account.Name;
                
                /**
                Setting the url on which flow will be redirected and Account
                and CHI Lead is populated in the standard layout.
                */
                pageRef = new Pagereference('/a19/e?retURL=%2Fa19%2Fo?CF00NR0000000nY93_lkwgt='
                +accountId+'&CF00NR0000000nY93='+accountName+'&CF00NR0000000nj85_lkid='
                +opportunity.Id+'&CF00NR0000000nj85='+opportunity.Name+'&nooverride=1');
            }
             else
            {
                pageRef = null; 
                //new Pagereference('/a19/e?retURL=%2Fa19%2Fo');
            }
        }
     //Returning the url on which the user will be navigated to.       
     return pageRef ;  
     
     }

}