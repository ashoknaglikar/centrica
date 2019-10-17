public with sharing class SmartMeterHandler extends TriggerHandler 
    implements TriggerHandler.ITrigger
{
    public List<Opportunity> oppList = new List<Opportunity> (); 
    Set<ID> JobIds = new Set<ID>();
    public list<Job__c> job_list = new list<Job__c> ();
    
   
    public SmartMeterHandler(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, List<SObject> oldList, List<SObject> newList)
    {
        super(oldMap, newMap, oldList, newList);
    }
    
    public void bulkBefore()
    {
        
    }
    
    public void bulkAfter()
    {
        
    }
            
    public void beforeInsert(SObject so)
    {
        
    }
    
    public void beforeUpdate(SObject oldSo, SObject so)
    {
        Smart_Meter__c smartMeterNew = (Smart_Meter__c)so;
        Smart_Meter__c smartMeterOld = (Smart_Meter__c)oldSo;
        if((smartMeterNew.S_M_Status__c != smartMeterOld.S_M_Status__c) && (smartMeterNew.S_M_Status__c != null) && system.label.SmartMeterRecord == 'on')
        {
            system.debug('-----InsideChange----');
            smartMeterNew.Eligible__c = SmartMeterHelper.populateEligibleValues(smartMeterNew.S_M_Status__c);
        }
        
       
    }
  
    public void beforeDelete(SObject so)
    {
        
    }
    
    public void afterInsert(SObject so)
    {   
        
    }
    
    public void afterUpdate(SObject oldSo, SObject so)
    {   
        Smart_Meter__c smartMeterNew = (Smart_Meter__c)so;
        Smart_Meter__c smartMeterOld = (Smart_Meter__c)oldSo;
        if((smartMeterNew.S_M_Status__c != smartMeterOld.S_M_Status__c) && (smartMeterNew.S_M_Status__c != null) && system.label.SmartMeterRecord == 'on')
        {
            Opportunity chiLead = new Opportunity(Id = smartMeterNew.CHI_Lead__c);
            chiLead.SMStatus__c = smartMeterNew.S_M_Status__c;
            oppList.add(chiLead);
        }
        system.debug('Inside -->3');
        if(system.label.SM_change  == 'on')
      	{
      		system.debug('Inside -->');
	        if(smartMeterNew.Actual_SM_Installation_Date__c!=smartMeterOld.Actual_SM_Installation_Date__c || smartMeterNew.Actual_SM_Installtion_Time__c!=smartMeterOld.Actual_SM_Installtion_Time__c)
	        {
	        	system.debug('Inside -->');
	          Job__c j = new Job__c(id= smartMeterNew.Job__c ,Smart_meter_installation_date__c = smartMeterNew.Actual_SM_Installation_Date__c ,SMInstalltionTime__c = smartMeterNew.Actual_SM_Installtion_Time__c);
	          job_list.add(j);
	          
	         }
	     }
    }
    
    public void afterDelete(SObject so)
    {       
    }
    
    public void postProcessing()
    {   
        if(oppList.size() > 0)
        {
            try
            {
                cls_IsRun.setgeneralTriggerSwitch();
                update oppList;
            }
            catch(Exception ex)
            {
                system.debug('--------Exception occured-----'+ex);
            }
        }
        
        if(job_list.size()>0)
        {
        	cls_IsRun.generalTriggerSwitch = true;
        	update job_list;
        }	
        
    }
}