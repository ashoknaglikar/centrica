/*
*
*  CLASS - GreenDealReconcillation
*  AUTHOR - 20 Sep 2013, Cognizant
*  PURPOSE - To Insert the Green Deal Record
* 
*  Change - CHI CR-001220 - 09/05/2014 - New field added to query for credit checks.
*  By Phil Dennison 
*/
global class  GreenDealReconcillation {

public Green_Deal_Reconsilliation__c greendeal{get;set;}
 
boolean isChanged;
public boolean epcNumberReq{get;set;}
public boolean financerecordtype{get;set;}
public boolean incDaterReq{get;set;} 
public boolean GDCBReq{get;set;}
public boolean postInst{get;set;}
public boolean secEpcReq{get;set;}
public boolean dblCashDate{get;set;}
public boolean ifReff{get;set;}
public boolean planIdReq{get;set;}
public boolean gdadate{get;set;}
id chiLeadId;
User usr;
string retURL;
String gdId ;
String oppId;

Utilities util = new Utilities();

public boolean CDReq  {get;set;}

public boolean CCReq  {get;set;}
public GreenDealReconcillation() 
{
 
    ID gasDocuement = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Gas Installation Works');
    ifReff= false;
    postInst = false;
    isChanged = false;
    financerecordtype=false;
    epcNumberReq = false;
    incDaterReq = false;
    secEpcReq =false;
    gdadate=false;
    
    gdId = ApexPages.currentPage().getParameters().get('gdId');
    oppId = ApexPages.currentPage().getParameters().get('oppId');
    chiLeadId = ApexPages.currentPage().getParameters().get('chiLeadId');
    retURL = ApexPages.currentPage().getParameters().get('retURL');
    GDCBReq = false;
    
    try{     
    
    if(gdId!=null)
    {  
         List<Green_Deal_Reconsilliation__c> gdlist =  [select id,X5th_Page_Complete__c,GDIP_Amendment__c,GDIP_Amendment_Complete__c,Plan_Sale_Notice_Complete__c,PlanSaleNoticeGDFC__c , COCUpload5thPage__c , GDFC_Status__c ,Comments5thPag__c,Survey_Date_Ins__c ,Loft_Date__c ,Cavity_Date__c,All_InsulComplete__c , InsulationType__c ,InsulationDepth__c ,Total_Insulation__c ,COC_Rec_Ins__c ,Redemption_cancelled__c,User__c,Customer_Email__c,Boiler_Description__c,Insulation_Installation_Date__c ,Job__c,Barclays_Acceptance_Number__c,Barclays_Amount__c,ASP_raised__c,X2nd_EPC_assigned_date__c,X2nd_EPC_checked__c,X2nd_EPC_Issue__c,X2nd_EPC_Number__c,
                                                      LU_Amount_Payable__c,Vibrant__c ,Opportunity__c,BigMachine_Quote__c,Sales_Appointment__c,LU_Customer_Name__c,Install_Street__c,Install_City__c,Installation_County__c,Installation_address__c,Home_Phone__c,Customer_Mobile_Phone__c,Work_Phone__c,
                                                      Barclays_Payout_Received_Date__c,LU_Billed__c,Bill_Payer_Name__c,Bill_Payer_Surname__c,Bill_Payer_Title__c,ECO_GD_AW_field__c,CHI_Lead_Number__c,Quote_Number__c,Region__c,LU_District__c,Status__c,Sub_Status__c,HSA_Name__c,CAM_name__c,
                                                      Installation_special_instructions__c,Quote_Sold_Date_AP__c,Cool_Off_End_Date_del__c,Cool_Off_Start_Date_del__c,Cool_of_Waived__c,CC_EPDQ_Reference__c,CD_EPDQ_Reference__c,CHI_UniqueId__c,
                                                      COC_Received_All_measures__c,Comments__c,Contact_Type__c,Charge_to_customer__c, Red_Items_Value__c,Green_Items_Value__c,Total_Value__c,LU_Amount_on_NBU1__c,Warning__c,ASP_Additions__c,ASP_Removal__c,ASP_Discounts__c,ASP_Outcome__c,LU_Installation_Date__c,
                                                      Insulation_Required__c,Electricity_Supplier__c,EPC_Checked__c,EPC_Lodge_Date__c,EPC_Number__c,Extra_Gross_Value__c,Finance_application_Accepted_Declined_Da__c,Finance_application_Accepted_Date__c, Double_Cashback_Issued__c,Early_Repayment_Amount_Taken__c,Date_Early_Repayment_Taken__c,
                                                      Date_of_Voucher_Requested__c,Date_Requested__c,Declined_letter_sent__c, CC_Amount__c,CC_Cheque_Number__c,CC_Date_Received__c,CD_Amount__c,CD_Cheque_Number__c,CD_Date_Received__c,
                                                      Customer_Taken_Up_measure__c,Date_2nd_EPC_received__c,Finance_application_Declined_Date__c,Finance_application_status__c,Formal_Quotation_Accepted__c,Formal_Quotation_Sent_to_Customer__c,GDA_Date__c,GDCB_Voucher_reference__c,GDF_Amount__c,GDF_Offer__c,GDF_Payment_Requested_Date__c,
                                                      GDF_Payout_Received_Date__c,Web_portal_Status__c,Voucher_Expiry__c,Scaffolding_Required__c,Scheduel_of_Works_Letter_Sent__c,Signed_plan_returned__c,Signed_Plan_Returned_to_Customer__c,Required_plan_return_Date__c,Redemption_Status__c,Recommended_measure__c,Redemption_Request_Date__c,
                                                      Quotation_Expiry__c,Quotation_requested__c, LU_Post_Code__c,Measure_Gross_Value__c,OA_Reference_Number__c,Offer_Controller__c,Barclays_Payment_Requested_Date__c,CC_Payment_Type__c,Plan_uploaded_to_GDFC_Portal__c,
                                                      Portal_Last_Checked_Date__c,GD_Make_of_boiler_installed__c,GD_Midas_Ref_Number__c,Green_Deal_Appointment__c,Green_Deal_Plan_Created__c,Green_Deal_Plan_ID__c,Green_Deal_Plan_sent_to_customer__c,If_referred__c,
                                                      RecordTypeId,GDA_Name__c,Record_Type__c,Sales_Appointment__r.Visit_Date__c, Opportunity__r.Account.Primary_Contact__r.Salutation,Opportunity__r.Account.Primary_Contact__r.FirstName,Eco_Funding__c,  ECO_Payment__c,ECO_Payout__c
                                                      ,BigMachine_Quote__r.ECO_AW_GD__c, Opportunity__r.Account.Primary_Contact__r.LastName,CD_Payment_Type__c,Name,X2nd_EPC_letter_sent__c,S_W_I_CC__c
                              ,CC_soft_credit_check__c, CC_credit_check_updated_by__c, CC_credit_check_updated__c, CC_credit_score__c, CC_Minimum_Score__c, CC_underwriting_comments__c
                                                      from Green_Deal_Reconsilliation__c where Id=:gdId limit 1];
                                                                                                            
        if(gdlist.size()>0){
              greendeal =gdlist[0];
              
         if(greendeal.Record_Type__c == 'Finance')
          {
                financerecordtype = true;
          }
           else
          {
                financerecordtype = false;
          }
          system.debug('--->'+greendeal.Record_Type__c +greendeal.BigMachine_Quote__r.ECO_AW_GD__c);
          if(greendeal.Record_Type__c == 'Finance' && greendeal.BigMachine_Quote__r.ECO_AW_GD__c == 'Green Deal')   
          {
            greendeal.Record_Type__c = 'Cash Back';
            isChanged = true;
          }else if(greendeal.Record_Type__c == 'Cash Back' && greendeal.BigMachine_Quote__r.ECO_AW_GD__c == 'GDF')   
          {
            greendeal.Record_Type__c = 'Finance';
            isChanged = true;
          }
                
          if(greendeal.Status__c =='Installed')
          {
            postInst = true;
          }
          
           
          
          if(greendeal.GDF_Offer__c != 'Double Cash Back' && greendeal.GDF_Offer__c!='cash back match')
          { 
          dblCashDate =true;
          }
        }
    chiLeadId= [Select Opportunity__c  from Green_Deal_Reconsilliation__c where id = :gdId ].Opportunity__c;
    
    if(oppId == null)
    {
        oppId = greendeal.Opportunity__c;
    }
    
    List<Green_Deal_Questions__c> gdq = [Select id,Electric_Supplier__c from Green_Deal_Questions__c where CHI_Lead__c = :oppId limit 1];
 
    if(gdq!=null && gdq.size() > 0)
    {
        greendeal.Electricity_Supplier__c = gdq[0].Electric_Supplier__c;
    }
    
    List<Appointment__c> salesapp= [select id, name, visit_date__c, Type__c, status__c  from Appointment__c where Opportunity__c=:oppId AND RecordType.Name = 'Appointment' AND Type__c = 'Sales' AND Status__c NOT IN ('Cancelled') order by Start__c DESC ];

    List<Appointment__c> greendealapp= [select id,name, visit_date__c,Assigned_To__r.Name, Type__c, status__c  from Appointment__c where Opportunity__c=:oppId AND RecordType.Name ='Appointment' AND Type__c = 'Green Deal' AND Status__c NOT IN ('Cancelled') order by Start__c DESC ];
    
    if(greendeal.BigMachine_Quote__c == null)
    {
         List<BigMachines_Quote__c> bms = [select id,ECO_AW_GD__c,Is_Primary__c,stage__c from BigMachines_Quote__c where Opportunity__c=:oppId AND Is_Primary__c=true AND stage__c='Quote Finalised - Accepted' ]; 
          
         if(bms.size()>0)
         {
             if(bms[0].ECO_AW_GD__c=='GDF' || bms[0].ECO_AW_GD__c =='Green Deal')
             
             {   
                greendeal.BigMachine_Quote__c = bms[0].Id;
                isChanged = true;
             }
             else
             {
                util.setErrorMsg(true, 'BM  Quote is not eligible');
             }
         }
    } 
      
    List<BigMachines_Quote__c> bms = [select id,ECO_AW_GD__c,Is_Primary__c,stage__c from BigMachines_Quote__c where Opportunity__c=:oppId AND Is_Primary__c=true AND stage__c='Quote Finalised - Accepted' ];
   
    List<Quote_Product__c> Quotprod = [Select Product_Description__c,Part_Number__c, installationNotes__c From Quote_Product__c  where Part_Number__c like 'CBLR%' and BigMachines_Quote__c in :bms limit 1];

    if (Quotprod.size()>0)
         {
           greendeal.GD_Make_of_boiler_installed__c = Quotprod[0].Part_Number__c;
           greendeal.Boiler_Description__c=Quotprod[0].Product_Description__c;
         }
        
    Job__c jb = [select id,Is_Remedial_Job__c , Is_Downtime_Job__c,Split_Job__c, (Select Id, RecordTypeId, Status_Indicator__c, GD_Claims_of_conformity__c From Job_Completion_Documents__r where RecordTypeId = :gasDocuement)from Job__c where  CHI_Lead__c =:oppId AND Is_Remedial_Job__c=False AND Is_Downtime_Job__c=False AND Split_Job__c=False limit 1 ];
    
    if (greendeal.Job__c==null )
    {
         if(jb!=null)
         {
             greendeal.Job__c=jb.Id;
             isChanged =true;
         }
        
    }
    
    
    
    if(jb.Job_Completion_Documents__r.size()>0)
     {
        if(jb.Job_Completion_Documents__r[0].GD_Claims_of_conformity__c == 'Completed Electronically')  
        {
            greendeal.COC_Received_All_measures__c ='Yes';
            isChanged = true;
        }
     }
     
       if(salesapp.size()>0)
       {
          if(salesapp[0].Id !=gdlist[0].Sales_Appointment__c)
        
           {
              greendeal.Sales_Appointment__c = salesapp[0].Id;
              isChanged =true;
           }
           
       }
       
       if(greendealapp.size()>0)
       {
          if (greendealapp[0].Id!=gdlist[0].Green_Deal_Appointment__c)
          {
             greendeal.Green_Deal_Appointment__c = greendealapp[0].Id;
             greendeal.GDA_Date__c = greendealapp[0].Visit_Date__c;
             greendeal.GDA_Name__c = greendealapp[0].Assigned_To__r.Name;
             isChanged =true;
          }
       }
       
       if(greendeal.EPC_Lodge_Date__c!=null)
       {
        epcNumberReq=true;
       }
     
    }
    }
    catch (exception e)
    {
        
    }
    
}

 
webservice static String greendealreco(String oppId ) 
{
    
    
    List<Green_Deal_Reconsilliation__c> gdlist =  [select id,Opportunity__c,CHI_UniqueId__c from Green_Deal_Reconsilliation__c where Opportunity__c=:oppId ];  
    
    if (gdlist.size()>0)
    {
        return ('Record Already Exists.');
    } 
    ID gasDocuement = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Gas Installation Works');
    
    Green_Deal_Reconsilliation__c gd =  new Green_Deal_Reconsilliation__c();
    gd.Record_Type__c =  'Finance';
    
    List<Opportunity> opp = [Select id, CHI_Lead_Id1__c,Account.Primary_Contact__r.Salutation,Account.Primary_Contact__r.LastName,Account.Primary_Contact__r.FirstName from Opportunity where id = :oppId];
    
    List<BigMachines_Quote__c> bm = [select id,Opportunity__c,ECO_AW_GD__c,Is_Primary__c,stage__c from BigMachines_Quote__c where Opportunity__c=:oppId AND Is_Primary__c=true AND stage__c='Quote Finalised - Accepted' ]; 
    
    List<Job__c> jb = [select id,Is_Remedial_Job__c , Is_Downtime_Job__c,Split_Job__c,(Select Id, RecordTypeId, Status_Indicator__c, GD_Claims_of_conformity__c From Job_Completion_Documents__r where RecordTypeId = :gasDocuement) from Job__c where  CHI_Lead__c =:oppId AND Is_Remedial_Job__c=False AND Is_Downtime_Job__c=False AND Split_Job__c=False limit 1 ];
      
    List<Appointment__c> salesapp= [select id,Opportunity__c, name, visit_date__c, Type__c, status__c  from Appointment__c where Opportunity__c=:oppId AND RecordType.Name = 'Appointment' AND Type__c = 'Sales' AND Status__c NOT IN ('Cancelled') order by Start__c DESC ];
       
    List< Appointment__c > greendealapp= [select id,Opportunity__c, name, visit_date__c,Assigned_To__r.Name, Type__c, status__c  from Appointment__c where Opportunity__c=:oppId AND RecordType.Name ='Appointment' AND Type__c = 'Green Deal' AND Status__c NOT IN ('Cancelled') order by Start__c DESC ];
        
    
    if(jb.size()>0)
    {
        gd.Job__c=jb[0].Id;
        
        if(jb[0].Job_Completion_Documents__r.size()>0)
         {
            if(jb[0].Job_Completion_Documents__r[0].GD_Claims_of_conformity__c == 'Completed Electronically')   
            {
                gd.COC_Received_All_measures__c ='Yes';
            }
         }
    }
               gd.Opportunity__c=oppId;
    if(salesapp.size()>0)
   
        gd.Sales_Appointment__c=salesapp[0].Id;
        //gd.Opportunity__c=oppId;
        gd.Offer_Controller__c ='Active'; 
              
    if(bm.size()>0 )
    {
        if(bm[0].ECO_AW_GD__c =='Green Deal')
        {
            gd.Record_Type__c = 'Cash Back';
        }
        gd.BigMachine_Quote__c=bm[0].Id;
        
    }   
   if(opp.size()>0)
   { 
       gd.CHI_UniqueId__c = opp[0].CHI_Lead_Id1__c;
   }
           
    if(greendealapp.size()>0)
    {
        gd.Green_Deal_Appointment__c=greendealapp[0].Id;
        gd.GDA_Date__c = greendealapp[0].Visit_Date__c;
        gd.GDA_Name__c = greendealapp[0].Assigned_To__r.Name;
    }
    if(opp.size()>0)
    {
        gd.Bill_Payer_Title__c = opp[0].Account.Primary_Contact__r.Salutation;
        gd.Bill_Payer_Surname__c = opp[0].Account.Primary_Contact__r.LastName;     
        gd.Bill_Payer_Name__c = opp[0].Account.Primary_Contact__r.FirstName;
    }        
    upsert gd gd.CHI_UniqueId__c;
    system.debug('upsert gd gd.CHI_UniqueId__c'+gd.CHI_UniqueId__c);
    return gd.Id;

 }
 
 public void updatenewvalues(){
 
     if(isChanged)
     {
        upsert greendeal greendeal.CHI_UniqueId__c;
        
        List<Green_Deal_Reconsilliation__c> gdlist =  [select id,X5th_Page_Complete__c,GDIP_Amendment__c,GDIP_Amendment_Complete__c,Plan_Sale_Notice_Complete__c,PlanSaleNoticeGDFC__c , COCUpload5thPage__c , GDFC_Status__c ,Comments5thPag__c,Survey_Date_Ins__c ,Loft_Date__c ,Cavity_Date__c,All_InsulComplete__c , InsulationType__c ,InsulationDepth__c ,Total_Insulation__c ,COC_Rec_Ins__c ,Redemption_cancelled__c,User__c, X2nd_EPC_letter_sent__c , Customer_Email__c,Boiler_Description__c,Insulation_Installation_Date__c ,Job__c,Barclays_Acceptance_Number__c,Barclays_Amount__c,ASP_raised__c,X2nd_EPC_assigned_date__c,X2nd_EPC_checked__c,X2nd_EPC_Issue__c,X2nd_EPC_Number__c,
                                                      LU_Amount_Payable__c,Vibrant__c ,Opportunity__c,BigMachine_Quote__c,Sales_Appointment__c,LU_Customer_Name__c,Install_Street__c,Install_City__c,Installation_County__c,/*Install_Postcode__c,*/Installation_address__c,Home_Phone__c,Customer_Mobile_Phone__c,Work_Phone__c,
                                                      Barclays_Payout_Received_Date__c,LU_Billed__c,Bill_Payer_Name__c,Bill_Payer_Surname__c,Bill_Payer_Title__c,ECO_GD_AW_field__c,CHI_Lead_Number__c,/*JOB_Number__c,*/Quote_Number__c,Region__c,LU_District__c,Status__c,Sub_Status__c,/*GDA_Name__c*/HSA_Name__c,CAM_name__c,
                                                      Installation_special_instructions__c,Quote_Sold_Date_AP__c,Cool_Off_End_Date_del__c,Cool_Off_Start_Date_del__c,Cool_of_Waived__c,CC_EPDQ_Reference__c,CD_EPDQ_Reference__c,CHI_UniqueId__c,
                                                      COC_Received_All_measures__c,Comments__c,Contact_Type__c,Charge_to_customer__c, Red_Items_Value__c,Green_Items_Value__c,Total_Value__c,LU_Amount_on_NBU1__c,Warning__c,ASP_Additions__c,ASP_Removal__c,ASP_Discounts__c,ASP_Outcome__c,LU_Installation_Date__c,
                                                      Insulation_Required__c,Electricity_Supplier__c,EPC_Checked__c,EPC_Lodge_Date__c,EPC_Number__c,Extra_Gross_Value__c,Finance_application_Accepted_Declined_Da__c,Finance_application_Accepted_Date__c, Double_Cashback_Issued__c,Early_Repayment_Amount_Taken__c,Date_Early_Repayment_Taken__c,
                                                      Date_of_Voucher_Requested__c,Date_Requested__c,Declined_letter_sent__c, CC_Amount__c,CC_Cheque_Number__c,CC_Date_Received__c,CD_Amount__c,CD_Cheque_Number__c,CD_Date_Received__c,
                                                      Customer_Taken_Up_measure__c,Date_2nd_EPC_received__c,Finance_application_Declined_Date__c,Finance_application_status__c,Formal_Quotation_Accepted__c,Formal_Quotation_Sent_to_Customer__c,GDA_Date__c,GDCB_Voucher_reference__c,GDF_Amount__c,GDF_Offer__c,GDF_Payment_Requested_Date__c,
                                                      GDF_Payout_Received_Date__c,Web_portal_Status__c,Voucher_Expiry__c,Scaffolding_Required__c,Scheduel_of_Works_Letter_Sent__c,Signed_plan_returned__c,Signed_Plan_Returned_to_Customer__c,Required_plan_return_Date__c,Redemption_Status__c,Recommended_measure__c,Redemption_Request_Date__c,
                                                      Quotation_Expiry__c,Quotation_requested__c, LU_Post_Code__c,Measure_Gross_Value__c,OA_Reference_Number__c,Offer_Controller__c,Barclays_Payment_Requested_Date__c,CC_Payment_Type__c,Plan_uploaded_to_GDFC_Portal__c,
                                                      Portal_Last_Checked_Date__c,GD_Make_of_boiler_installed__c,GD_Midas_Ref_Number__c,Green_Deal_Appointment__c,Green_Deal_Plan_Created__c,Green_Deal_Plan_ID__c,Green_Deal_Plan_sent_to_customer__c,If_referred__c,
                                                      RecordTypeId,GDA_Name__c,Record_Type__c, Opportunity__r.Account.Primary_Contact__r.Salutation,Opportunity__r.Account.Primary_Contact__r.FirstName,    ECO_Payment__c,ECO_Payout__c
                                                      ,BigMachine_Quote__r.ECO_AW_GD__c, CD_Payment_Type__c,Name,S_W_I_CC__c,
                                                      Sales_Appointment__r.Visit_Date__c,Eco_Funding__c,CC_soft_credit_check__c, CC_credit_check_updated_by__c, CC_credit_check_updated__c, CC_credit_score__c, CC_Minimum_Score__c, CC_underwriting_comments__c 
                                                      from Green_Deal_Reconsilliation__c where Id=:greendeal.Id limit 1];
                                  
        greendeal= gdlist[0];
        if(gdlist[0].Record_Type__c != 'Cash Back')
        {
            financerecordtype = true;
        }else
        {
            financerecordtype =false;
        }
     
      }
        
 }
 
 public pagereference saveRecord()
 {
    update greendeal;
    return(new pagereference('/'+greendeal.Id));
    
 }
 
 public pagereference Qualification()
 {
   
    return(new pagereference('/apex/GreenDealQuestionnaire?retURL=/'+chiLeadId+'&view='+1));
 }
 
 public pagereference exitcancel()
 {
    SYSTEM.DEBUG('iN CANCEL'+greendeal.Id);
    return(new pagereference('/'+greendeal.Id));
 }
 
 public void epcReqFunc()
 {
    String epcDate = Apexpages.currentPage().getParameters().get('epcDate');
    if(epcDate !='')
    epcNumberReq = true;
    else
    epcNumberReq = false;
 }
 
 public void insulationDateReq()
 {
    String incReq = Apexpages.currentPage().getParameters().get('incReq');
    if(incReq !='')
    incDaterReq = true;
    else
    incDaterReq = false;
 }
 
 public void dateVoucherReq()
 {
    String temp = Apexpages.currentPage().getParameters().get('dVocReq');
    if(temp !='' && temp!=null)
    {
        string[] temporary = temp.split('/') ;
        string dateof =temporary[2]+'-'+temporary[1]+'-'+temporary[0];
        date portDate = date.valueof(dateof);
        GDCBReq = true;
        
        greendeal.Voucher_Expiry__c = portDate.addDays(90);
        
    }
    else
    {
        GDCBReq = false;
        greendeal.Voucher_Expiry__c = null;
    }
    
 }
 
  public void secEpcFunc()
 {
    String temp = Apexpages.currentPage().getParameters().get('secEpc');
    if(temp !='')
    secEpcReq = true;
    else
    secEpcReq = false;
 }
 
 public void dblCashBk()
 {
    String temp = Apexpages.currentPage().getParameters().get('GdfOffer');
    if(temp == 'Double Cash Back' || temp == 'cash back match')
    dblCashDate = false;
    else
    dblCashDate = true;
 }
 
 public void reffer()
 {
    String temp = Apexpages.currentPage().getParameters().get('reffer');
    if(temp == 'Referred')
    {
        ifReff = true;
        planIdReq = false;
        greendeal.Finance_application_Accepted_Declined_Da__c = null;
    }
    else if(temp!= '')
    {   
        greendeal.Finance_application_Accepted_Declined_Da__c = system.today();
        if(temp == 'Accepted')
        {   
            greendeal.Required_plan_return_Date__c = system.today().addDays(21);
        }
        
        if(temp != '')
        {
            planIdReq = true;
        }else
        {
            planIdReq = false;
        }
        
        if(temp == 'Declined')
        {
            greendeal.Declined_letter_sent__c= system.today();
        }else
        {
            greendeal.Declined_letter_sent__c = null;
        }
        
    }
    else
    {
        ifReff = false;
        planIdReq = false;
        greendeal.Finance_application_Accepted_Declined_Da__c = null;
    }
    
 }
 
 public void popCoolDates()
 {

      String temp = Apexpages.currentPage().getParameters().get('PortalDate');
        
        if(temp!='' && temp!=null)
        {
            string[] temporary = temp.split('/') ;
            string dateof =temporary[2]+'-'+temporary[1]+'-'+temporary[0];
            date portDate = date.valueof(dateof);
          
            greendeal.Cool_Off_Start_Date_del__c = portDate;
            greendeal.Cool_Off_End_Date_del__c = portDate.adddays(14);
   
        }else
        {
            greendeal.Cool_Off_Start_Date_del__c = null;
            greendeal.Cool_Off_End_Date_del__c =null;
        }
       
 }
 
/* public void popChedcedBy()
 {
    greendeal.GD_Plan_CheckBy__c = userinfo.getName();
 }*/
 
 
  public void vibrant()
 {  
    
    String temp = Apexpages.currentPage().getParameters().get('vibrant');
   
    if(temp=='Yes' ){
    //system.debug(' temp'+ temp);
    
    gdadate=true;
    greendeal.GDA_Name__c = 'Vibrant';
    }else if(temp!=null && temp!='')
    {
        gdadate=true;
        greendeal.GDA_Name__c = temp;
    }else
    {
        gdadate = false;
    }   
    
  }
 
 
 public void popQuoteEx()
 {
     String temp = Apexpages.currentPage().getParameters().get('Date_Req');
     
     if(temp!='' && temp!=null)
        {
            string[] temporary = temp.split('/') ;
            string dateof =temporary[2]+'-'+temporary[1]+'-'+temporary[0];
            date portDate = date.valueof(dateof);
          
            greendeal.Quotation_Expiry__c = portDate.adddays(28);
            
   
        }else
        {
             greendeal.Quotation_Expiry__c = null;
        }     
    
    
 }
 
 public void popEarlyPay()
 {
     String temp = Apexpages.currentPage().getParameters().get('EarlyPay');
     
     if(temp!='')
    {
      greendeal.Date_Early_Repayment_Taken__c = system.today();
            
   
    }else
    {
        greendeal.Date_Early_Repayment_Taken__c = null;
    }     
    
    
 }
 
 public void popCDreq()
 {
    String temp = Apexpages.currentPage().getParameters().get('CD');
    if(temp == 'Cheque' || temp == 'Card')
    CDReq = true;
    else
    CDReq = false;
 }
 
 
 public void popCCreq()
 {
    String temp = Apexpages.currentPage().getParameters().get('CC');
    if(temp == 'Cheque' || temp == 'Card')
    CCReq = true;
    else
    CCReq = false;
 }
 
 public void popfinan()
 {
    String temp = Apexpages.currentPage().getParameters().get('fina');
        if(temp!='' && temp!=null)
        {
            string[] temporary = temp.split('/') ;
            string dateof =temporary[2]+'-'+temporary[1]+'-'+temporary[0];
            date portDate = date.valueof(dateof);
          
            greendeal.Required_plan_return_Date__c = portDate.adddays(21);
            
   
        }else
        {
             greendeal.Quotation_Expiry__c = null;
        }    
 }
}