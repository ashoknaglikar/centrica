@isTest
public class BarclaysFinalResultWebserivceTest {
    
    static testmethod void testSenrio1()
    {
        BarclaysFinalResultWebserivce newResultObj = new BarclaysFinalResultWebserivce();
        BarclaysFinalResultWebserivce.CallbackCls objCallBack = new BarclaysFinalResultWebserivce.CallbackCls();
        BarclaysFinalResultWebserivce.ProposalStatusCls objP = new  BarclaysFinalResultWebserivce.ProposalStatusCls();
        BarclaysFinalResultWebserivce.CustomerAddressCls  objAdd = new  BarclaysFinalResultWebserivce.CustomerAddressCls();
        BarclaysFinalResultWebserivce.SnagsCls objSnag = new BarclaysFinalResultWebserivce.SnagsCls();
        BarclaysFinalResultWebserivce.ChecklistConditionsCls objCheck = new BarclaysFinalResultWebserivce.ChecklistConditionsCls();
        
        BarclaysFinalResultWebserivce.SalesforceReponseResult objResponse = new BarclaysFinalResultWebserivce.SalesforceReponseResult();
        
        objResponse = BarclaysFinalResultWebserivce.updateFinaceCallBackDetails(objCallBack);
        system.assert(objResponse.error);
        
        Account Acc = Testclasshelper.createAccout();
        insert Acc;
        
        
        Opportunity opp = TestClassHelper.createCHILead(Acc);
        opp.Finance_Proposal_Id__c= '123456';
        insert opp;
        
        // Non Exisiting Lead details
        objCallBack.ProposalID =  '123456';
        objCallBack.ClientReference = '123456';
        objResponse = BarclaysFinalResultWebserivce.updateFinaceCallBackDetails(objCallBack);
        system.assert(objResponse.error);
        
        // Exisiting Lead details
        
        opp = [Select CHI_Lead_Id1__c from Opportunity where Id = : opp.Id];
        objCallBack.ClientReference = opp.CHI_Lead_Id1__c;
        objP.Status= 'Accepted';
        objCallBack.ProposalStatus = objP;
        
        objResponse = BarclaysFinalResultWebserivce.updateFinaceCallBackDetails(objCallBack);
        
        system.assert(objResponse.error==false);
        
        
    }

}