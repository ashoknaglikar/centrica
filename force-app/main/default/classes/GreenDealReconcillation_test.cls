@isTest(SeeAllData=true)


private class GreenDealReconcillation_test {

static testMethod void TestMethod_withBlankValues() 
{


        
Account Acc = TestClassHelper.createAccout();
                insert Acc;
        
Opportunity opp = TestClassHelper.createCHILead(Acc);
                insert opp;
                 //oppId=opp.id;
 /*       

Contact con = TestClassHelper.createContact(acc);
                 insert con ;
        
Employee__c emp = TestClassHelper.createEmployee();
                 emp.Salesforce_User__c=userinfo.getuserid();
                 insert emp;
        
User user = TestClassHelper.createUser();
                 insert user;
               
Id App = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
          
Appointment__c app1 = TestClassHelper.createAppointment(opp,emp.id,userinfo.getuserid(),App,con.id);
                 insert app1 ;
 
       
ID gasDocuementID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Gas Installation Works');
       
Commissioning_Report__c jcd = TestClassHelper.createJobCompletionDoc(gasDocuementID, job.Id); 
                 insert jcd;
  */    
 
/*Green_Deal_Reconsilliation__c Testgd = new Green_Deal_Reconsilliation__c(Opportunity__c=opp.Id);
insert Testgd;*/

 
string gdId = GreenDealReconcillation.greendealreco(opp.Id);

GreenDealReconcillation.greendealreco(opp.Id);

system.debug('Test This ---->'+gdId);

pagereference pageRef = new pagereference('/apex/GreenDealReconcillation?gdId='+gdId+'&retURL='+opp.Id);
test.setCurrentPage(pageRef);   
GreenDealReconcillation cont_Gd = new GreenDealReconcillation();
cont_Gd.epcReqFunc();
pageRef.getParameters().put('PortalDate', '');
cont_Gd.insulationDateReq();
pageRef.getParameters().put('secEpc', '');
cont_Gd.secEpcFunc();
cont_Gd.dblCashBk();
cont_Gd.dateVoucherReq();
//pageRef.getParameters().put('PortalDate', '');
pageRef.getParameters().put('GdfOffer', 'Double Cash Back');
cont_Gd.dblCashBk();
cont_Gd.Qualification();
pageRef.getParameters().put('PortalDate', '');
cont_Gd.popCoolDates();
pageRef.getParameters().put('Date_Req', '');
cont_Gd.popQuoteEx();
pageRef.getParameters().put('EarlyPay', '');
cont_Gd.popEarlyPay();
pageRef.getParameters().put('CD', '');
cont_Gd.popCDreq();
pageRef.getParameters().put('CC', '');
cont_Gd.popCCreq();
pageRef.getParameters().put('fina', '');
cont_Gd.popfinan();
pageRef.getParameters().put('incReq', '');
cont_Gd.insulationDateReq();

pageRef.getParameters().put('dVocReq', '01/01/2011');   
pageRef.getParameters().put('reffer', 'Referred');
pageRef.getParameters().put('PortalDate', 'xx');
pageRef.getParameters().put('vibrant', 'Yes');
pageRef.getParameters().put('PortalDate', '01/01/2011');
cont_Gd.epcReqFunc();
cont_Gd.insulationDateReq();
cont_Gd.dateVoucherReq();
cont_Gd.secEpcFunc();
cont_Gd.dblCashBk();
cont_Gd.reffer();
pageRef.getParameters().put('reffer', 'Accepted');
cont_Gd.reffer();
pageRef.getParameters().put('reffer', 'Declined');
cont_Gd.reffer();
pageRef.getParameters().put('reffer', '');
cont_Gd.reffer();
cont_Gd.popCoolDates();
cont_Gd.vibrant();
pageRef.getParameters().put('vibrant', 'No');
cont_Gd.vibrant();
pageRef.getParameters().put('PortalDate', '01/01/01');
cont_Gd.popCoolDates();
pageRef.getParameters().put('Date_Req', '01/01/01');
cont_Gd.popQuoteEx();
pageRef.getParameters().put('EarlyPay', 'test');
cont_Gd.popEarlyPay();
pageRef.getParameters().put('CD', 'Cheque');
cont_Gd.popCDreq();
pageRef.getParameters().put('CC', 'Cheque');
cont_Gd.popCCreq();
pageRef.getParameters().put('fina', '01/01/01');
cont_Gd.popfinan();

cont_Gd.updatenewvalues();
//cont_Gd.saveRecord();
cont_Gd.exitcancel();
cont_Gd.epcReqFunc();
pageRef.getParameters().put('incReq', '01/01/01');
cont_Gd.insulationDateReq();
cont_Gd.dateVoucherReq();

Contact con = TestClassHelper.createContact(acc);
 insert con ;
        
Employee__c emp = TestClassHelper.createEmployee();
 emp.Salesforce_User__c=userinfo.getuserid();
 insert emp;

               
Id App = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
          
Appointment__c app1 = TestClassHelper.createAppointment(opp,emp.id,userinfo.getuserid(),App,con.id);
insert app1 ;

Appointment__c app2 = TestClassHelper.createAppointment(opp,emp.id,userinfo.getuserid(),App,con.id);
app2.Type__c = 'Green Deal';
insert app2 ;
//insert new list<Appointment__c>{app1,app2} ;


BigMachines_Quote__c quote = TestClassHelper.createBMQuote(opp );
quote.GDCashBack__c ='Yes';
//quote.Opportunity__c=opp.id;
//quote.Is_Primary__c=true ;
//uote.stage__c='Quote Finalised - Accepted';
insert quote ; 





Quote_Product__c  qp = TestClassHelper.createQuoteProduct(quote.Id);
//qp.BigMachines_Quote__c=quote .id;
//qp.Part_Number__c='CBLR001';
insert qp;

District__c dist = TestClassHelper.createDistrict();
                insert dist;
        
Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,dist.Id);
job.Quote__c = quote.Id;
//job.Status__c='Installed';
//job.CHI_Lead__c =opp.Id;
//job.Is_Remedial_Job__c=False; 
//job.Is_Downtime_Job__c=False ;
//ob.Split_Job__c=False;
insert(job);

/*Green_Deal_Reconsilliation__c gd = new Green_Deal_Reconsilliation__c(Opportunity__c=opp.Id);
gd.BigMachine_Quote__c=quote.id;
gd.Job__c=job.id;
//gd.Status__c ='Installed';
insert gd;

Green_Deal_Questions__c gdq = TestClassHelper.createGDPreQual(job.id,opp.id);
insert gdq ;*/
            
pageRef = new pagereference('/apex/GreenDealReconcillation?gdId='+gdId+'&retURL='+opp.Id);
test.setCurrentPage(pageRef);   
//cont_Gd = new GreenDealReconcillation();
//cont_Gd.updatenewvalues();    

            

}

static testMethod void TestMethod_CallActionFunctions() 
{
    Account Acc = TestClassHelper.createAccout();
                insert Acc;
        
Opportunity opp = TestClassHelper.createCHILead(Acc);
                insert opp;
                
        

Contact con = TestClassHelper.createContact(acc);
                 insert con ;
        
Employee__c emp = TestClassHelper.createEmployee();
                 emp.Salesforce_User__c=userinfo.getuserid();
                 insert emp;

               
Id App = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
          
Appointment__c app1 = TestClassHelper.createAppointment(opp,emp.id,userinfo.getuserid(),App,con.id);

Appointment__c app2 = TestClassHelper.createAppointment(opp,emp.id,userinfo.getuserid(),App,con.id);
app2.Type__c = 'Green Deal';
insert new list<Appointment__c>{app1,app2} ;

BigMachines_Quote__c quote = TestClassHelper.createBMQuote(opp );
quote.GDCashBack__c ='Yes';

insert quote ;
      
string gdId = GreenDealReconcillation.greendealreco( opp.Id);       

update (new Green_Deal_Reconsilliation__c(id= gdId,EPC_Lodge_Date__c =system.today() ));       
//TestMethod_withValues();
pagereference pageRef = new pagereference('/apex/GreenDealReconcillation?gdId='+gdId+'&retURL='+opp.Id);
test.setCurrentPage(pageRef);  
GreenDealReconcillation cont_Gd = new GreenDealReconcillation();
 
try{
cont_Gd.saveRecord();
}
catch(Exception e)
{
    
}




}



}