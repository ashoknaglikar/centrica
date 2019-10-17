global class Housekeeping_Scheduler implements Schedulable
    {    
        
        global string query = ''; 
        global HouseKeepingJobName JobBatch {get; set;} 
        Map<String,Housekeeping_Scheduler__c> tim = Housekeeping_Scheduler__c.getAll();                 
              
        DateTime SAHRSF_start = tim.get('Start').SAHRSF__c;
        DateTime SASF7525_start = tim.get('Start').SASF7525__c;
        DateTime SASF7525SR_start = tim.get('Start').SASF7525SR__c;
        DateTime SearchResult_start = tim.get('Start').SearchResult__c;
        DateTime SFED7542_start = tim.get('Start').SFED7542__c;
        DateTime SFNB7521_start = tim.get('Start').SFNB7521__c;
        DateTime SFPO7523_start = tim.get('Start').SFPO7523__c;
        DateTime SFPO7524_start = tim.get('Start').SFPO7524__c;
        

        global Boolean StartBatchDelete {get; set;}
        public Housekeeping_Scheduler()
        {
            StartBatchDelete = false;
            JobBatch = null;
        }
        
          
        global void execute(SchedulableContext sc) 
        {  
            DateTime d = Datetime.now();
            System.debug('-------------------d' +d);
             Integer i = integer.valueof(d.format('H')); 
            HouseKeepingJobName batchName = null;
            System.debug('----------------------------- StartBatchDelete = ' + StartBatchDelete);
            System.debug('--------------i' +i);
            if(StartBatchDelete == false)
            {
                 if (i == integer.valueof(SFNB7521_start.format('H')))
                {
                System.debug('-----Entering Nbbs = ' +integer.valueof(SFNB7521_start.format('H')));
                System.debug('----JobBatch' +JobBatch);
                query = 'Select SFNB7521_Batch__r.LastModifiedDate, SFNB7521_Batch__c, Id From Installation_Billing__c where SFNB7521_Batch__r.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFNB7521;
                batchName = HouseKeepingJobName.SFNB7521;
                }
                else if (i == integer.valueof(SAHRSF_start.format('H')))
                {
                System.debug('-----JobBatch' +JobBatch);
                System.debug('----Entering sahrsf = ' +integer.valueof(SAHRSF_start.format('H')));
                query = 'Select SAHRSF_Batch__r.LastModifiedDate, SAHRSF_Batch__c, Id From SAHRSF_Employee__c  where SAHRSF_Batch__r.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SAHRSF; 
                batchName = HouseKeepingJobName.SAHRSF;
               
                }
                else if (i == integer.valueof(SASF7525_start.format('H')))
                { 
                System.debug('----JobBatch' +JobBatch); 
                System.debug('----Entering sasf7525 = ' +integer.valueof(SASF7525_start.format('H')));                  
                query = 'Select SASF7525_Batch__r.LastModifiedDate, SASF7525_Batch__c, Id From SASF7525_Supplier__c where SASF7525_Batch__r.LastModifiedDate <  Last_N_Days:' + System.Label.Housekeeping_SASF7525;
                batchName = HouseKeepingJobName.SASF7525;
                }
               
                else if (i == integer.valueof(SFPO7523_start.format('H')))
                {
                System.debug('----JobBatch' +JobBatch);
                System.debug('----Entering sfpo7523 = ' +integer.valueof(SFPO7523_start.format('H')));  
                query = 'Select P5_SFPO7523_Batch__r.LastModifiedDate, P5_SFPO7523_Batch__c, Id From SFPO7523_Order_Header__c where Status__c =\'Integrated\' and P5_SFPO7523_Batch__r.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFPO7523;
                batchName = HouseKeepingJobName.SFPO7523;
                }
                
                else if (i == integer.valueof(SFPO7524_start.format('H')))
                {
                System.debug('----JobBatch' +JobBatch);
                System.debug('-----Entering sfpo7524 = ' +integer.valueof(SFPO7524_start.format('H')));  
                query = 'Select SFPO7524_Batch__r.LastModifiedDate, SFPO7524_Batch__c, Id From SFPO7524_ORDER_detail__c where Status__c =\'Integrated\' and SFPO7524_Batch__r.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFPO7524;
                batchName = HouseKeepingJobName.SFPO7524;
                }
                else if (i == integer.valueof(SASF7525SR_start.format('H')))
                {
                System.debug('----JobBatch' +JobBatch);
                System.debug('-----Entering SASF7525SR = ' +integer.valueof(SASF7525SR_start.format('H')));  
                query = 'Select createdDate,Id From SASF7525_Supplier_Region__c where LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SASF7525;
                batchName = null;
                }
                else if (i == integer.valueof(SearchResult_start.format('H')))
                {
                System.debug('----JobBatch' +JobBatch);
                System.debug('-----Entering SearchResult = ' +integer.valueof(SearchResult_start.format('H')));  
                query = 'Select createdDate,Id From Search_Result__c where LastModifiedDate < Last_N_Days:'+ System.Label.Housekeeping_SearchResult;
                batchName = null;
                }
                else if (i == integer.valueof(SFED7542_start.format('H')))
                {
                System.debug('----JobBatch' +JobBatch);
                System.debug('-----Entering SFED7542 = ' +integer.valueof(SFED7542_start.format('H')));  
                query = 'Select LastModifiedDate, Id From SFED7542_Batch__c where Status__c =\'Integrated\' and LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFED7542;
                batchName = null;
                }                
            }
            else
            {
                System.debug('----------------------------- JobName = ' + JobBatch );
                System.debug('--------------i' +i);
                if (i == integer.valueof(SFNB7521_start.format('H')) && JobBatch == HouseKeepingJobName.SFNB7521)
                {
                System.debug('-----Entering Nbbs = ' +integer.valueof(SFNB7521_start.format('H')));
                query = 'Select LastModifiedDate, Id From SFNB7521_Batch__c  where LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFNB7521;
                batchName = null;
                JobBatch = null;
                System.debug('-----JobBatch' +JobBatch);
                }
                else if (i == integer.valueof(SAHRSF_start.format('H')) && JobBatch == HouseKeepingJobName.SAHRSF)
                {
                System.debug('----Entering sahrsf = ' +integer.valueof(SAHRSF_start.format('H')));
                query = 'Select LastModifiedDate, Id From SAHRSF_Batch__c where LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SAHRSF;
                batchName = null;
                JobBatch = null;
                System.debug('-----JobBatch' +JobBatch);
                }
                else if (i == integer.valueof(SASF7525_start.format('H')) && JobBatch == HouseKeepingJobName.SASF7525)
                {
                System.debug('----Entering sasf7525 = ' +integer.valueof(SASF7525_start.format('H'))); 
                query = 'Select LastModifiedDate,Id From SASF7525_Batch__c where LastModifiedDate <  Last_N_Days:' + System.Label.Housekeeping_SASF7525;
                batchName = null;
                JobBatch = null;
                System.debug('-----JobBatch' +JobBatch);
                }
                else if (i == integer.valueof(SFPO7523_start.format('H')) && JobBatch == HouseKeepingJobName.SFPO7523)
                {
                    System.debug('----Entering sfpo7523 = ' +integer.valueof(SFPO7523_start.format('H'))); 
                query = 'Select s.LastModifiedDate, s.Id From SFPO7523_Batch__c s where  s.P5_Batch_Status__c=\'S\' and s.LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFPO7523;
                batchName = null;
                JobBatch = null;
                System.debug('-----JobBatch' +JobBatch);
                }
                 else if ( i == integer.valueof(SFPO7524_start.format('H')) && JobBatch == HouseKeepingJobName.SFPO7524)
                {
                    System.debug('-----Entering sfpo7524 = ' +integer.valueof(SFPO7524_start.format('H'))); 
                query = 'Select LastModifiedDate,Id From SFPO7524_Batch__c  where Batch_Status__c=\'S\' and LastModifiedDate < Last_N_Days:' + System.Label.Housekeeping_SFPO7524;
                batchName = null;
                JobBatch = null;
                System.debug('-----JobBatch' +JobBatch);
                }
                
            }    
            
                  
            System.debug('----------------------------- batchName = ' + batchName);
            Housekeeping_Batch objBatch = new Housekeeping_Batch(query, batchName);
            ID batchprocessid = Database.executeBatch(objBatch,5000);        
            System.debug('----------------------------- batchID = ' + batchprocessid); 
             
            List<CronTrigger> lstct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE State='DELETED' and TimesTriggered=1 and NextFireTime=null];
            system.debug(lstct);
    
            for( CronTrigger ct:lstct)
                {
                    system.abortJob(ct.Id);
                }          
        }    
             
    }