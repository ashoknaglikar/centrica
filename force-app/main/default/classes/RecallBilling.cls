/*Type Name:RecallBilling
Author: Cognizant
Created Date: 24/06/2010
Reason: This class is recalls/deletes the installation billing record when "Recall Billing" button is pressed.
Change History:*/
global class RecallBilling 
{ 
   /* This method retrives the quote and related installation billing record which has not yet been integrated with NBBS from an opportunity 
     and deletes the record.
     method is called as part of "Recall Billing" button functionality from CHI Lead.
   */
    Webservice static String delinstbill(string oppId)
    {
        String sresult='';
        Opportunity opp = new Opportunity();
        List<Installation_Billing__c> instbilldelete = new List<Installation_Billing__c>();
        BigMachines_Quote__c quotechngstatus = new BigMachines_Quote__c();
         
        //Retrive  the opportunity whose quote status is "Awaiting Billing"
        List<Opportunity> oppList = [Select Platform__c,Id,Billed_Status__c,Billed_Date__c,isSystem__c,CHI_Lead_Id__c,ASP_after_Billed__c,Charge_to_Cutomer_after_Billed__c, (Select id,Stage__c,Billed__c,ASP_after_Billed__c,Charge_to_Cutomer_after_Billed__c From BigMachines_Quotes__r where Billed__c = true 
                   and Is_Primary__c = true) From Opportunity where id =:oppId];
        
        if(oppList != null && oppList.size() > 0 && oppList[0].BigMachines_Quotes__r != null && oppList[0].BigMachines_Quotes__r.size() > 0)
        {
            opp = oppList[0];
            quotechngstatus = opp.BigMachines_Quotes__r;
            system.debug('---quotechngstatus' +quotechngstatus);
            system.debug('---opp.CHI_Lead_Id__c' +opp.CHI_Lead_Id__c);
                   
            //Retrive installation billing with quote status "Awainting Billing" and batch field is not populated
            instbilldelete = [Select i.SFNB7521_Batch__c, i.Id From Installation_Billing__c i where i.Big_Machine_Quote__c=:quotechngstatus.Id 
                     and i.CHI_Lead_Number__c =: opp.CHI_Lead_Id__c and SFNB7521_Batch__c =null];
            
            // delete the installation billing record if batch id is not populated
            system.debug('instbillobj--->'+instbilldelete);
            if(instbilldelete != null && instbilldelete.size()>0 )
            {
                try
                {
                         
                    delete instbilldelete;
                    NBBSInterfaceController.checksystem=true;
                    if(NBBSInterfaceController.checksystem==true)
                    {
                        quotechngstatus.IsSystem__c=true;
                    }
                   // quotechngstatus.Stage__c='Quote Finalised - Accepted';
                    quotechngstatus.Billed__c = false;
                    opp.Billed_Status__c=false;
                    opp.isSystem__c=true;
                    quotechngstatus.ASP_after_Billed__c = false;
                    quotechngstatus.Charge_to_Cutomer_after_Billed__c = 0.00;
                    opp.ASP_after_Billed__c = false;
                    opp.Charge_to_Cutomer_after_Billed__c = 0.00;
                    opp.Billed_Date__c = null ;
                    update opp;
                    update quotechngstatus;
                    sresult= 'success';
                    return sresult;
                } 
                catch(Exception e)
                {
                    System.debug('## could not Recall the Record '+e);
                    sresult='Could not recall the record';
                    return sresult;
                }
            }
            else
            {
                sresult= 'Recalling process failed';
                // change the status of the quote
                return sresult;
            }
        }
        else
        {
            sresult= 'Recalling process failed';
            // change the status of the quote
            return sresult;
        }
    } 
}