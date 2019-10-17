public with sharing class GetAvailableResources 
{
        
        public Account accountSearch{get; set;}         
        public Opportunity opp;
        public Job__c job{get; set;} 
        public GetAvailableResources()
        {
               system.debug('inside costructor');
               accountSearch = new Account();  
               job = new Job__c();
               job.Customer_Preferred_Date__c = system.today();
        } 
        
        public PageReference getResources()
        {
         
            boolean AccChk = false;
            boolean OppChk = false;
            boolean JobChk = false;
         
            AccChk = insertAcc();
         
             if(AccChk)
             {
                    OppChk = insertOpp();
             } 
             
             if(OppChk)
             {
                    Jobchk = insertJob();
             } 
            if(Jobchk)
            {
                PageReference pageRef = new PageReference('/apex/JobSearchResults?jobId='+job.Id);          
                return pageRef; 
            }
            return null;
             
        }
      private boolean insertAcc()
      {
            
            accountSearch.Name = 'Dummy Test';
                 
             try
             {
                    accountSearch.Dummy_Data__c = true;
                    system.debug('accountSearch.Name'+accountSearch.Name);
                    insert accountSearch;
                    
                    return true;
                  
             }
             catch(Exception e )
             {
                    system.debug('Exception---->'+e);
                    return false;
             }
      }
     private boolean insertOpp()
     {
            Employee__c emp =[select id from Employee__c limit 1];  
            opp = new Opportunity(Name = 'Dummy Opp', StageName ='Deposit Taken', Referral_Employee__c = emp.Id,                                                
                                  AccountId=accountSearch.Id, LeadSource='Engineer',Product_Interest__c ='Solar',
                                  CloseDate=System.today());        
                                
           try
           {
                insert(opp);
                system.debug('22222222222');
                return (true);
            
           }     
           catch(Exception e)
           {
                system.debug('Exception----->'+e);
                return false;
           }
       }                  
    private boolean insertJob()
    {
        job.CHI_Lead__c = opp.Id;
        job.Status__c = 'Allocated';    
        //job = new Job__c(CHI_Lead__c = opp.ID, status__c = 'Alloctaed');
                             
           try
           {
                insert(job);
                system.debug('333333333');
                return (true);
            
           }     
           catch(Exception e)
           {
                system.debug('Exception----->'+e);
                return false;
           }
    }   
        
	public boolean deleteDummyRecords()
	{
		Id loginUserId = Userinfo.getUserId();
		
		List<Account> DummyAccs = [Select Id from Account where Dummy_Data__c = true and CreatedById =:loginUserId];
		List<Opportunity> DummyOpps = [select Id from Opportunity where AccountId in :DummyAccs];
		List<Job__c> DummyJobs = [Select Id from Job__c where CHI_Lead__c in :DummyOpps];
		
		if(DummyJobs.size()>0)
		{
			try
			{
				delete DummyJobs;	
			}catch (Exception e)
			{
				system.debug('Exception----->'+e);
			}
		}
		if(DummyAccs.size()>0)
		{
			try
			{
				delete DummyAccs;	
			}catch (Exception e)
			{
				system.debug('Exception----->'+e);
			}
			
		}

		
		
		return null;
		
	}
}