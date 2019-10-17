trigger UpdateBalanceinPayment on Opportunity (after update) 
{
    if(cls_IsRun.generalTriggerSwitch)
    {
        return;
    }
    try {
         System.debug('###4###  '+cls_IsRun.isOppoRun);
        if (cls_IsRun.isOppoRun==false || cls_IsRun.isRHCRun==true) { //PRB00020964  added '|| cls_IsRun.isRHCRun==true'
            cls_IsRun.setIsOppoRun();
            List<Opportunity> lst_opportunity=new List<Opportunity>{};
            List<Opportunity> lstUpdatePayment = new List<Opportunity>();
            Set<String> set_OppId=new set<String>{};
            Integer icount=0;
            for (Opportunity opp: Trigger.new)
            {
                System.debug('#### 2 ### '+opp.Amount);
                System.debug('#### 3 ### '+Trigger.Old[iCount].Amount);
                System.debug('#### 2b ### '+opp.Sum_of_Payments__c);
                System.debug('#### 3b ### '+Trigger.Old[iCount].Sum_of_Payments__c);
                System.debug('#### 2c ### '+opp.Finance_Amount__c);
                System.debug('#### 3c ### '+Trigger.Old[iCount].Finance_Amount__c);
                System.debug('#### 2d ### '+opp.discountsTotalOnPricing__c);
                System.debug('#### 3d ### '+Trigger.Old[iCount].discountsTotalOnPricing__c);
                System.debug('#### 2e ### '+opp.Payment_Reference_Number__c);
                System.debug('#### 3e ### '+Trigger.Old[iCount].Payment_Reference_Number__c);
                System.debug('#### 2e ### '+opp.ASP_Addition__c);
                System.debug('#### 3e ### '+Trigger.Old[iCount].ASP_Addition__c);
                System.debug('#### 2e ### '+opp.ASP_Discount__c);
                System.debug('#### 3e ### '+Trigger.Old[iCount].ASP_Discount__c);
                System.debug('#### 2e ### '+opp.ASP_Removal__c);
                System.debug('#### 3e ### '+Trigger.Old[iCount].ASP_Removal__c);
                System.debug('#### 2e ### '+opp.Bill_Period__c);
                System.debug('#### 3e ### '+Trigger.Old[iCount].Bill_Period__c);
                
                if((opp.Amount !=Trigger.Old[iCount].Amount)||(opp.Bill_Period__c != Trigger.Old[iCount].Bill_Period__c)||(opp.ASP_Removal__c!=Trigger.Old[iCount].ASP_Removal__c)||(opp.ASP_Discount__c !=Trigger.Old[iCount].ASP_Discount__c)||(opp.ASP_Addition__c !=Trigger.Old[iCount].ASP_Addition__c)||(opp.Sum_of_Payments__c!=Trigger.Old[iCount].Sum_of_Payments__c)||(opp.Finance_Amount__c !=Trigger.Old[iCount].Finance_Amount__c)||(opp.discountsTotalOnPricing__c !=Trigger.Old[iCount].discountsTotalOnPricing__c)||(opp.discountsTotalOnPricing__c <>Null && Trigger.Old[iCount].discountsTotalOnPricing__c ==Null )||(opp.Payment_Reference_Number__c != Trigger.old[icount].Payment_Reference_Number__c))
                {
                    set_OppId.add(opp.Id);
                }
                if((opp.StageName != 'Closed Lost' && opp.StageName != 'Suspended') && (opp.Amount > 0 && opp.StageName == 'Settled' && Trigger.Old[iCount].StageName != 'Settled')){
                    lstUpdatePayment.add(opp);
                }
                iCount++;
            }
            System.debug('#### 4 ### '+set_OppId);  
            if(set_OppId.size() > 0){  
                 List<Payment_Collection__c> lst_Payment_update = new List<Payment_Collection__c> ();
              //Code Fix done as a part of PRB00008739 by BGSAMS Support on 08/08/2012 - Starts                                 
                for(Opportunity o: Trigger.new)
                {
                   List<Payment_Collection__c> lst_Payment=[select Id,Balance_Outstanding__c,
                                                Opportunity__c,Payment_Collection_Status__c,Job_Installation_Date__c
                                                from Payment_Collection__c 
                                                where Opportunity__c =:o.Id
                                                and Payment_Collection_Status__c <>'Complete'];                                        
              //Code Fix done as a part of PRB00008739 by BGSAMS Support on 08/08/2012 - Ends                                
                    if(lst_Payment.size()>0)
                    {
                        for(Integer i=0; i<lst_Payment.size();i++)
                        {
                            Payment_Collection__c obj_Payment= new Payment_Collection__c(Id = lst_Payment[i].Id,Job_Installation_Date__c = lst_Payment[i].Job_Installation_Date__c);  
                            system.debug('Job_Installation_Date__c'+obj_Payment.Job_Installation_Date__c);  
                            VATchangecalculation.updatePCNASP(o,obj_Payment);
                            cls_IsRun.isRHCRun=false;    //PRB00020964
                            lst_Payment_update .add(obj_Payment);
                        }
                    }
                }
                if (lst_Payment_update.size()>0) {
                    update lst_Payment_update ;
                } 
                if(lstUpdatePayment.size() > 0){
                    BGS_Payment__c[] opptyPayments = [select id,Status__c from BGS_Payment__c where Opportunity__c in :lstUpdatePayment and Status__c != 'Settled'];
                    if(opptyPayments.size() > 0){
                        for(BGS_Payment__c pay : opptyPayments ){
                            pay.Status__c = 'Settled';      
                        }
                        try{
                            update opptyPayments;
                        }catch(DMLException e){
                            System.debug('@ Excpeiotn @ '+e.getMessage());
                        }
                    }
                }
            }
        }
    } catch(Exception ex) {
        //do nothing
    }
}