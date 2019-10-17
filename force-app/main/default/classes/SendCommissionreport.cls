global class SendCommissionreport  implements Database.Batchable<sObject>{
    String str = ''; 
    List<BigMachines_Quote__c> quoteList =new List<BigMachines_Quote__c>(); 
    Map<String,List<BigMachines_Quote__c>> Quoapp = new Map<String,List<BigMachines_Quote__c>>();
    Map<String,Employee__c> employeeMap = new Map<String,Employee__c>();
    static Date start;
    static Date end1;
    List<Commission_Period__c> lstcomm = new List<Commission_Period__c>();
    public static void sendQuoteLink(){
        SendCommissionreport sendQuote = new SendCommissionreport();
        ID batchprocessid = Database.executeBatch(sendQuote);
    }
    /*
    *   Input - Current Btch Context
    *   Output - Query Set
    *   Purpose - retrieves the query set to be processed by the current & future batches 
    */ 

    global Database.QueryLocator start(Database.BatchableContext BC){
        lstcomm = [Select Period_Sequence__c,Period_Start_Date__c,Period_Status__c,Period_End_Date__c from Commission_Period__c where Period_Status__c = 'TRUE' ];
        if(lstcomm .size()==1){
        for(Commission_Period__c objcomm :lstcomm ){
            start = objcomm .Period_Start_Date__c;
            end1 = objcomm .Period_End_Date__c;
            }
        }
        system.debug('lstcomm-->'+lstcomm);
        Date startdt =start;
        Date endDt = end1 ;
        return Database.getQueryLocator('SELECT b.Projected_Commissionable_Margin__c,b.App_Assigned_Payroll__c,b.Name,b.App_Assigned_To__c,b.POC_Payment_Method__c, b.stage__c,b.bmStatusReason__c,b.Opportunity__c,opportunity__r.Account.BillingStreet,Opportunity__r.Name,opportunity__r.Account.Sales_Subpatch__c, b.Sales_paperwork_validation_date__c,opportunity__r.Account.Sales_Region__c,opportunity__r.Account.Sales_District__c From BigMachines_Quote__c b WHERE stage__c = \'Quote Finalised - Accepted\' and Sales_paperwork_validation_date__c>=:startdt and Sales_paperwork_validation_date__c<=:endDt order by App_Assigned_To__c,opportunity__r.Account.Sales_Subpatch__c');
        
    }
    /*
    *   Input - current batch context and list of records to process
    *   Output - None
    *   Purpose - 
    */ 
    public Map<String,List<BigMachines_Quote__c>> populateEmployeeid(List<BigMachines_Quote__c> lstRecords){
        Set<String> EmployeeSet = new Set<String>();
        system.debug('lstRecords--->'+lstRecords);
        for(BigMachines_Quote__c objquote : lstRecords){              
            if(objquote.App_Assigned_Payroll__c !=null && objquote.App_Assigned_To__c !=null )
                //employeeMap.put(objquote.id,objquote.App_Assigned_Payroll__c);
                EmployeeSet.add(objquote.App_Assigned_Payroll__c);
                system.debug('Employee Map--->'+EmployeeSet);
        }
        List<Employee__c> lstemployee = [Select id,Name,Is_Commission_Report_Ready__c,Salesforce_User__c, Salesforce_User__r.Email,Employee_Number__c From Employee__c where Is_Commission_Report_Ready__c = true and Employee_Number__c in :EmployeeSet];
        system.debug('lstemployee Map--->'+lstemployee);
        if(lstemployee.size() > 0){
            for(Employee__c objemployee:lstemployee){
                List<BigMachines_Quote__c> tempEmpLst;
                    for(BigMachines_Quote__c objquoLst:lstRecords){
                        if(objemployee.Salesforce_User__c!=null){
                            if(objemployee.Salesforce_User__r.Email!=null){ 
                                if(Quoapp.get(objemployee.Employee_Number__c)== null){
                                  if(objquoLst.App_Assigned_Payroll__c==objemployee.Employee_Number__c){
                                    Quoapp.put(objemployee.Employee_Number__c,new List<BigMachines_Quote__c>{objquoLst});
                                     system.debug('Quoapp Map--->'+Quoapp);
                                  }
                                 }
                                else{
                                    if(objquoLst.App_Assigned_Payroll__c==objemployee.Employee_Number__c){
                                      tempEmpLst= Quoapp.get(objemployee.Employee_Number__c);
                                      tempEmpLst.add(objquoLst);
                                      Quoapp.put(objemployee.Employee_Number__c,tempEmpLst); 
                                      system.debug('Quoapp Map--->'+Quoapp);
                                    }
                                   }
                                }
                            }
                   quoteList.add(objquoLst);
                }
                employeeMap.put(objemployee.Employee_Number__c,objemployee);
                system.debug('employeeMap Map--->'+employeeMap);
            }
        }
        return Quoapp;
    }
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
      
      try{
        
        List<BigMachines_Quote__c> tempQuotes = new List<BigMachines_Quote__c>();
        for(sObject sObj : lstRecords)
            tempQuotes.add((BigMachines_Quote__c)sObj);
        Map<String,List<BigMachines_Quote__c>> tempQuote = this.populateEmployeeid(tempQuotes);
        Date startdt;
        Date endDt;
        Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{};
        lstcomm = [Select Period_Sequence__c,Period_Start_Date__c,Period_Status__c,Period_End_Date__c from Commission_Period__c where Period_Status__c = 'TRUE' ];
        if(lstcomm .size()==1){
        for(Commission_Period__c objcomm :lstcomm ){
            start = objcomm .Period_Start_Date__c;
            end1 = objcomm .Period_End_Date__c;
            }
        }
        system.debug('lstcomm-->'+lstcomm);
        if(start !=null){
             startdt = start;
        }else{
            startdt = system.today();
        }if(end1 !=null){
             endDt = end1 ;
        }else{
            endDt = system.today().adddays(7) ;
        }
        Integer count =0;
        system.debug('startdt--->'+startdt+'endDt-->'+endDt);
        if(tempQuote.size() > 0){
            // Iterating through the Quote against each HSAs
            Set<String> hsaSet = employeeMap.keySet();
            for(String hsa : hsaSet){
                
                Employee__c emp = employeeMap.get(hsa);
                
                if(emp.Salesforce_User__c == null){
                    
                    continue;
                    
                }
                
               if(emp.Salesforce_User__r.Email == null){
                    
                    continue;
                    
                }
                
                system.debug('emp--->'+emp);
                List<BigMachines_Quote__c> lstQuo = Quoapp.get(emp.Employee_Number__c);
                count=1;
                system.debug('lstQuo Map--->'+lstQuo);
                // If employee's user is having Phil's email address then exclude it.
                if((emp.Salesforce_User__r.Email).toLowerCase().contains('phil.dennison')){
                     continue;
                }
                
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();           
           mail.setToAddresses(new String[] {emp.Salesforce_User__r.Email});
            String str_header = 'Commission Progress Report for '+emp.Name+' From '+startdt.day()+'-'+startdt.month() +'-'+startdt.year()+ ' to '+ endDt.day()+'-'+endDt.month() +'-'+endDt.year();
                mail.setSubject(str_header);
                mail.setSaveAsActivity(false);  
                String str_emailBody = '<font face=\'calibri\' size=\'4\' color=\'#990000\' ><b>'+str_header+'</b></font>'+'<table cellpadding=\'5\' width=\'100%\'><tr ><td></td></tr>';  
                for(BigMachines_Quote__c objquote : lstQuo ){
                    system.debug('lstQuo Map--->'+lstQuo);
                    
                    // Fix - We do not require survey visit booked quotes on PCM report
                    
                    if(objquote.bmStatusReason__c.contains('Survey')){
                     
                      continue; 
                        
                    }
                    
                        str_emailBody = str_emailBody +'<tr><td colspan=\'3\'><hr/></td></tr><tr><td><font face=\'calibri\' size=\'3\'>Big Machine Quote :</font>'+count+' <b>of </b> '+lstQuo.size()+'</td></tr><tr><td colspan=\'4\'><hr/></td></tr>'

                            +'<tr>'
                            
                            +'<td>'

                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Opportunity : </b></font><font face=\'calibri\' size=\'2\'>'+objquote.Opportunity__r.Name+'</font>'

                            +'</td>'
                            
                            +'<td>'

                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Install Address Street : </b></font><font face=\'calibri\' size=\'2\'>'+objquote.opportunity__r.Account.BillingStreet+'</font>'

                            +'</td>'
                            
                            +'<td>'

                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Quote Number : </b></font><font face=\'calibri\' size=\'2\'>'+objquote.Name+'</font>'

                            +'</td>'
                            
                            +'<td>'

                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Status : </b></font><font face=\'calibri\' size=\'2\'>'
                               +objquote.stage__c+'</font>'

                            +'</td>'

                            +'</tr>'

                            +'<tr>'
                            
                            +'<td>'

                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Projected Commissionable Margin :</b> </font><font face=\'calibri\' size=\'2\'>'+objquote.Projected_Commissionable_Margin__c+'</font>'

                            +'</td>'

                            +'<td>'

                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Status Reason : </b></font><font face=\'calibri\' size=\'2\'>'+objquote.bmStatusReason__c+'</font>'

                            +'</td>'
                            
                            +'<td>'

                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Sales paperwork validation date :</b> </font><font face=\'calibri\' size=\'2\'>'+(objquote.Sales_paperwork_validation_date__c).day()+'-'+(objquote.Sales_paperwork_validation_date__c).month()+'-'+(objquote.Sales_paperwork_validation_date__c).year()+'</font>'

                            +'</td>' 

                            +'</tr>'

                            +'<tr>'
                            
                            +'<td>'

                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Payment Method : </b></font><font face=\'calibri\' size=\'2\'>'+objquote.POC_Payment_Method__c+'</font>'

                            +'</td>'

                            +'<td>'

                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Sales Region : </b></font><font face=\'calibri\' size=\'2\'>'+objquote.opportunity__r.Account.Sales_Region__c+'</font>'

                            +'</td>'
                            
                            +'<td>'

                            +'<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Sales District :</b> </font><font face=\'calibri\' size=\'2\'>'+objquote.opportunity__r.Account.Sales_District__c+'</font>'

                            +'</td>' 

                            +'</tr>' ;
                            
                            count++;                            

                    }

                

                    str_emailBody = str_emailBody + '</table>';

                    mail.setHtmlBody(str_emailBody); 

                    mails.add(mail);

            }

            try{

                Messaging.sendEmail(mails);                

            }catch(Exception e){

                System.debug('---EXC  ----   '+e.getMessage());

            }  

        }else{

            str = str+'No Quotes.';
            
          }       

       }catch(Exception e){
        
                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();        
             // String[] toAddresses1 = new String[] {'CHI-Salesforce.support@centrica.com','BGSAMS.Support@Centrica.com','Prashant.Kulkarni@cognizant.com','phil.dennison@britishgas.co.uk','Umashankar.Priyadarshini@Centrica.com','vijayakumar.radhakrishnan@centrica.com','priyaadharshini.u@gmail.com'};                                 
                String[] toAddresses1 = new String[] {'Umashankar.Priyadarshini@centrica.com','vijayakumar.radhakrishnan@centrica.com','priyaadharshini.u@gmail.com','BGSAMS.Support@centrica.com'};             
                mail1.setToAddresses(toAddresses1);
                mail1.setSubject('Exception ocurred in creating PCM email');
                mail1.setPlainTextBody('Exception ocurred in creating PCM email : ' + e.getMessage()+' Error in line number : '+ e.getLineNumber());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
                System.debug('@Exception sending PCM via email :  '+e.getMessage()+' Error in line number : '+e.getLineNumber());
                
        }
        
    }

     global void finish(Database.BatchableContext BC){

       // Get the ID of the AsyncApexJob representing this batch job 

       // from Database.BatchableContext. 

       // Query the AsyncApexJob object to retrieve the current job's information.  
        
           AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
    
              TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        
           // Send an email to the Apex job's submitter notifying of job completion. 
    
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
           String runningUserEmail = [select email from User where id = :UserInfo.getUserId()].email;
           String[] toAddresses = new String[] { runningUserEmail};
           mail.setToAddresses(toAddresses);
          mail.setSubject('Send app Result ' + a.Status);
    
           mail.setPlainTextBody
    
           ('The batch Apex job processed ' + a.TotalJobItems +
    
           ' batches with '+ a.NumberOfErrors + ' failures.');
    
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    /*
      // BEGIN - TEST METHODS
    @isTest
    public static void AppReport(){
        
        
        Region__c testRegion1 = new Region__c(Name='Test Region1', Code__c = 'TR991', Type__c='Sales');
        
        Database.insert(testRegion1);
        
        District__c testDistrict1 = new District__c(Name='Test District1', Code__c = 'TD991', Type__c='Sales', Region__c = testRegion1.ID);
        Database.insert(testDistrict1);
        
        Sub_Patch__c testSubPatch1 = new Sub_Patch__c(Name='Test SubPatch1', Code__c = 'SP991', 
                                                    Type__c='Sales', District__c = testDistrict1.ID);
        Database.insert(testSubPatch1);
        Account acc = new Account(name = 'test  account', BillingStreet='8 Merten', 
                                  BillingPostalCode='SW19 6DE', BillingCity='London', 
                                  BillingCountry='UK', BillingState='London',Sales_Subpatch__c = testSubPatch1.id);
        
        Database.insert(acc);
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp); 
        Contact contact = new Contact(AccountId=acc.Id,Best_Phone__c='2321738', LastName='updateContact Test');
        Database.insert(contact);
        
        Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'test extract flag lead', 
                                            AccountId = acc.Id, 
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Appointed', 
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);      
        Database.insert(opp);
        
        List<Commission_Period__c> lstcomm = new List<Commission_Period__c>();
        Commission_Period__c comm = new Commission_Period__c(Period_End_Date__c = System.today().adddays(100), Period_Sequence__c=1, 
                                  Period_Start_Date__c =System.today());
        lstcomm.add(comm);
        Database.insert(lstcomm);
        comm = [select Period_End_Date__c,Period_Start_Date__c,Period_Sequence__c, Period_Status__c from Commission_Period__c where id =:comm.id];
        System.debug('comm-->'+comm);
        Employee__c emp = new Employee__c(Employee_Number__c='123',First_Name__c = 'Emp',Last_Name__c = 'Name',Name='Emp Name - 123',primary_role__C = 'HSA',Is_Commission_Report_Ready__c=true,SalesForce_User__c = UserInfo.getUserId());
        Database.insert(emp);
        
        
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c='Emp Name - 123',
                                                             Projected_Commissionable_Margin__c = 1000,Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Install Date Given',
                                                             is_primary__c=true,quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        system.debug('Quote-->'+quote);
        Paperwork_Recieved_Details__c insertpaper = new Paperwork_Recieved_Details__c(Sales_Paperwork_Validated_Date__c = system.today(),Big_Machines_Quote__c = quote.id);
        Database.insert(insertpaper);
        
        quote = [select Projected_Commissionable_Margin__c,App_Assigned_Payroll__c,App_Assigned_To__c,opportunity__r.Account.BillingStreet,Opportunity__r.Name,opportunity__r.Account.Sales_Subpatch__c, opportunity__r.Account.Sales_Region__c,opportunity__r.Account.Sales_District__c,Stage__c,Name,Opportunity__c,POC_Payment_Method__c,bmstatusreason__c,is_primary__c,quote_reconciled__c,finalPriceVisibleToCustomer__c,Sales_paperwork_validation_date__c from BigMachines_quote__c where id =:quote.id ];
        system.debug('Quote App payroll-->'+quote.App_Assigned_Payroll__c);
        system.debug('Quote update-->'+quote);
        List<BigMachines_Quote__c> lst_BM = new List<BigMachines_Quote__c>();
        lst_BM.add(quote);
        Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
         
        insert product;
        insert quoteProduct;
        District__c district = [Select id from District__c limit 1];
        Job__c job = new Job__c(CHI_Lead__c = opp.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today().adddays(55),Installation_Date__c=Date.today().adddays(60),District__c=district.Id);
        insert job;
        Database.BatchableContext BC;
        Test.StartTest();
        SendCommissionreport Sendcomm=new SendCommissionreport();       
        Sendcomm.execute(BC,lst_BM); 
        Test.StopTest();
       }*/
   }