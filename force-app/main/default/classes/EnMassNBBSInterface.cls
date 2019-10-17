public class EnMassNBBSInterface {
    
    /*
        Author             : Cognizant
        Functionality     : This is a controller class for the EnMassNBBSBillingInterface.
                                 The class is a extension controller class for the page 'En Mass NBBS Interface Page'.
                                 The controller class uses a standard set controller which can take multiple number of Opportunity.
                                 A private inner class is used to store the opportunity detail and Error message received
                                 during the insertion of data in the Installation Billing Data.
        Create Date      : 05 May 2010
        Change History  :
        Modified Date    :
    */
    
    
    private class EnMassNBBSInterfaceUpdateStatus{
        /*
            Author             : Cognizant
            Functionality     : This is a inner class for the EnMass NBBS Billing Interface.
                                     A private inner class is used to store the opportunity detail and Error message received
                                     during the insertion of data in the Installation Billing Data.
            Create Date      : 05 May 2010
        */    
        public Opportunity objOpportunity {get;set;}
        public String strErrorStatus{get;set;}
        public Boolean blErrorStatus{get;set;}
    }
    private Map<Id,EnMassNBBSInterfaceUpdateStatus> enMassNBBSInterfaceMap =new Map<Id,EnMassNBBSInterfaceUpdateStatus>{}; 
    public List<EnMassNBBSInterfaceUpdateStatus> enMassNBBSInterfaceUpdateStatusList {get; set;}
    private List<Opportunity> opportunityList=new List<Opportunity>{};
    private Set<Id> opportunityIdSet=new Set<Id>{};
    private EnMassNBBSInterfaceUpdateStatus objEnMassNBBSInterface = new EnMassNBBSInterfaceUpdateStatus();
    private List<String> billingStatus = new List<String>{};
    private Map<Id,List<String>> billingOutputMap= new Map<Id,List<String>>{};
    public Boolean blConfirmed{get; set;}
    /*
        Default Constructor of the Class
        This class processes the selected record and displays the user the success and failure of the creation of Billing Data
    */
    public EnMassNBBSInterface(ApexPages.StandardSetController controller) {
        controller.setPageSize(200);
        blConfirmed=false;
        opportunityList=(List<Opportunity>)controller.getSelected(); // Retreives the list of Opportunity that are selected from the Opportunity List View Page
        for (Opportunity objOpportunity:opportunityList) {
            opportunityIdSet.add(objOpportunity.Id);
        }
        ApexPages.StandardSetController opportunitySetController = new ApexPages.StandardSetController(Database.getQueryLocator([select Id, name,closedate,Payment_Reference_Number__c from Opportunity where Id In:opportunityIdSet]));
        opportunityList=(List<Opportunity>)opportunitySetController.getRecords();
        for (Opportunity objOpportunity:opportunityList) {
            objEnMassNBBSInterface=new  EnMassNBBSInterfaceUpdateStatus();
            objEnMassNBBSInterface.objOpportunity =objOpportunity;
            enMassNBBSInterfaceMap.put(objOpportunity.Id,objEnMassNBBSInterface); 
        }
        enMassNBBSInterfaceUpdateStatusList = new List<EnMassNBBSInterfaceUpdateStatus>{};
        enMassNBBSInterfaceUpdateStatusList =enMassNBBSInterfaceMap.values();
        
    }
    public void ConfirmSubmit(){
        /*
            Call the Bulkified NBBSIntefaceController Class. 
            The argument passed is as a list of selected opportunity 
            The output is a map with Key as the Opportunity Id 
            and Value as the Sucess message or Error Message if there is any error generated
       */ 
        NBBSInterfaceController objNBBSController=new NBBSInterfaceController (opportunityList);
        billingOutputMap=objNBBSController.insertMultipleData();
        System.debug('$$$$$$$$$$$$$$ : ' + billingOutputMap );
        
        /*
            The EnMassNBBSInterfaceUpdateStatus Map is updated with the output of the call NBBS Interface Controller Class
        */   
        opportunityIdSet=billingOutputMap.keySet();
        for (Id opportunityId : opportunityIdSet) {
            List<String> statusList=billingOutputMap.get(opportunityId);
            
            objEnMassNBBSInterface=new  EnMassNBBSInterfaceUpdateStatus();
            objEnMassNBBSInterface=enMassNBBSInterfaceMap.get(opportunityId);
            if (statusList[0]=='Success') {
                objEnMassNBBSInterface.strErrorStatus=statusList[1];
                objEnMassNBBSInterface.blErrorStatus=false;
            } else {
                objEnMassNBBSInterface.blErrorStatus=true;
                objEnMassNBBSInterface.strErrorStatus=statusList[1];
            }
            enMassNBBSInterfaceMap.put(opportunityId,objEnMassNBBSInterface);                 
        }
        blConfirmed=true;
        enMassNBBSInterfaceUpdateStatusList = new List<EnMassNBBSInterfaceUpdateStatus>{};
        enMassNBBSInterfaceUpdateStatusList =enMassNBBSInterfaceMap.values();
    }
}