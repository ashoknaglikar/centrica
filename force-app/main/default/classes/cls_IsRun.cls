public class cls_IsRun{
    public static boolean isBGRun=false;
    public static boolean isRHCRun=false;
    public static boolean isOppoJobRun =false;
    public static boolean isQuoteInsertUpdate =false;
    public static boolean isorderInsertUpdate =false;
    public static boolean isAppInsertUpdate =false;
    public static boolean isSalesAppCorrectUpdate=false;    
    public static boolean isCalculateNetCustomerPrice = false;
    public static boolean dontFireTriggers = false;
    public static boolean isDecompiledQuoteProducts = false;
    public static boolean isaInsUpd_OnPaymentsObjectRun = false;
    public static boolean istrg_UpdatePayment = false;
    public static boolean generalTriggerSwitch = false;
    public static boolean isinstUpdCustCatMasRec = false;
    public static boolean callsmartmeter = false;
    public static boolean calljob = false;
    public static boolean transferhrstrg = false; //PRB00032289
    public static boolean txtmailsalesman=false;
    //CR - 1352 change by Ashok G
    private static boolean blnAlreadyDone = false; 
   
    public static boolean hasAlreadyDone()
    { 
    return blnAlreadyDone;
    }
    
    public static void setAlreadyDone() {
    blnAlreadyDone = true;
    } 
    //CR - 1352 END 
    public static void setcallsmartmeter(){
        callsmartmeter=true;
    }
    
    public static void setcalljob (){
        calljob =true;
    } 
       
    public static void setgeneralTriggerSwitch(){
        generalTriggerSwitch=true;
    }
    
    //PRB00032289
    public static void settransferhrstrg(){
        transferhrstrg=true;
    }
    
    public static void setisinstUpdCustCatMasRec()
    {
        isinstUpdCustCatMasRec = true;
    }
    
    public static void setisaInsUpd_OnPaymentsObjectRun(){
        isaInsUpd_OnPaymentsObjectRun=true;
    }
    
    public static void setistrg_UpdatePayment(){
        istrg_UpdatePayment=true;
    }
    
    public static void setIsDecompiledQuoteProducts(){
        isDecompiledQuoteProducts=true;
    }
    
    public static void setDontFireTriggers(){
        dontFireTriggers=true;
    }
    
    public static void setIsCalculateNetCustomerPrice(){
        isCalculateNetCustomerPrice=true;
    }
    
    public static void setIsAppInsertUpdate (){
        isAppInsertUpdate =true;
    }
    public static void setIsSalesAppCorrectUpdate(){
        isSalesAppCorrectUpdate =true;
    }
    public static void setIsorderRun (){
        isorderInsertUpdate =true;
    }
    public static void setIsOppoJobRun (){
        isOppoJobRun =true;
    }
    public static void setIsQuoteInsertUpdate  (){
        isQuoteInsertUpdate =true;
    }
    public static void setIsBGRun(){
        isBGRun=true;
    }
     public static void setRHCBGRun(){
        isRHCRun=true;
    }
    public static boolean isOppoRun=false;
    public static void setIsOppoRun(){
        isOppoRun=true;
    }
    public static boolean isOppoUpdRun=false;
    public static void setIsOppoUpdRun(){
        isOppoUpdRun=true;
    }
    public static boolean isOppoCanRun=false;
    public static void setIsOppoCanRun(){
        isOppoCanRun=true;
    }
    public static boolean ischkAppRun=false;
    
    public static void setIschkAppRun(){
        IschkAppRun=true;
    }
    public static boolean isJobPlanned=false;
    
    public static void setIsJobPlanned(){
        isJobPlanned=true;
    }
    public static boolean isConsumReq=false;
    
    public static void setIsConsumReq(){
        isConsumReq=true;
    }
    public static boolean isJobCompletion=false;
    
    public static void setIsJobCompletion(){
        isJobCompletion=true;
    }
    public static boolean isCompReq=false;
    
    public static void setIsCompReq(){
        isCompReq=true;
    }
    public static Boolean isOrder=false;
    
    public static void setIsOrder(){
        isOrder=true;
    }
    public static Boolean isSuspendJob=false;
    
    public static void setIsSuspendJob(){
        isSuspendJob=true;
    }
    // Cr 04 Ashok 
    public static boolean isBMQuoteUpdateInsertAppRun=false;
    public static void setIsBMQuoteUpdateInsertAppRun(){
        isBMQuoteUpdateInsertAppRun=true;
    }
    // Cr 04 End
    
    // ++ variable created for Mandatory Briefing CR start
    public static boolean istrg_CompleteBriefs = false;
    public static void setistrg_CompleteBriefs(){
        istrg_CompleteBriefs=true;
    }
    // -- variable created for Mandatory Briefing CR end
    // ++ variable created for Priority Installations CR start
    public static boolean istrg_CustAppt = false;
    public static boolean istrg_CustApptAfterInsert = false;
    public static boolean isRestrictCustCategory = false;
    public static boolean isUpdateServiceLevelValues = false;
    public static void setistrg_CustAppt(){
        istrg_CustAppt=true;
    }
    public static void setistrg_CustApptAfterInsert(){
        istrg_CustApptAfterInsert=true;
    }
    public static void setisRestrictCustCategory()
    {
        isRestrictCustCategory = true;
    }
    public static void setisUpdateServiceLevelValues()
    {
        isUpdateServiceLevelValues = true;
    }
    // -- variable created for Priority Installations CR end
    
    // ++ Variables created for CR#889 & CR#892 start
    public static boolean appointmentSwitch = false;
    public static boolean bigMachineSwitch = false;
    public static boolean istrg_emailSendSingle = false;
    public static boolean istrg_CreateCustCategory = false;
    public static boolean istrg_bINS_bUPD_chkEmpSkillForItnry = false;
    public static boolean istrg_AppointmentBeforeUpdate = false; 
    public static boolean istrg_AppointmentUpdate = false;
    public static boolean istrg_AppointmentBeforeInsert = false;
    public static boolean istrg_ensurePrimary = false;
    public static boolean istrg_aUPD_AutocancelAppointmentOnQuoteCancelation = false;
    public static boolean istrg_updateOpportunityPaymentDetails = false;
    public static boolean istrg_aUPD_changeBillingAddress = false;
    public static boolean istrg_BigMachinesQuoteInsertJobReconciliation = false;
    
    public static void setappointmentSwitch(){
        appointmentSwitch = true;
    }
    public static void setbigMachineSwitch(){
        bigMachineSwitch = true;
    }
    public static void setistrg_emailSendSingle(){
        istrg_emailSendSingle = true;
    }
    public static void setistrg_CreateCustCategory(){
        istrg_CreateCustCategory = true;
    }
    public static void setistrg_bINS_bUPD_chkEmpSkillForItnry(){
        istrg_bINS_bUPD_chkEmpSkillForItnry = true;
    }
    public static void setistrg_AppointmentBeforeUpdate(){
        istrg_AppointmentBeforeUpdate = true;
    }
    public static void setistrg_AppointmentUpdate(){
        istrg_AppointmentUpdate = true;
    }
    public static void setistrg_AppointmentBeforeInsert(){
        istrg_AppointmentBeforeInsert = true;
    }
    public static void setistrg_ensurePrimary(){
        istrg_ensurePrimary = true;
    }
    public static void setistrg_aUPD_AutocancelAppointmentOnQuoteCancelation(){
        istrg_aUPD_AutocancelAppointmentOnQuoteCancelation = true;
    }
    public static void setistrg_updateOpportunityPaymentDetails(){
        istrg_updateOpportunityPaymentDetails = true;
    }
    public static void setistrg_aUPD_changeBillingAddress(){
        istrg_aUPD_changeBillingAddress = true;
    }
    public static void setistrg_BigMachinesQuoteInsertJobReconciliation(){
        istrg_BigMachinesQuoteInsertJobReconciliation = true;
    }
    // -- Variables created for CR#889 & CR#892 end
    
    // ++ Variables crteated for Smart Meter CR start
    public static boolean doNotUpdateSMToCHILead = false;
    public static void setdoNotUpdateSMToCHILead(){
        doNotUpdateSMToCHILead = true;
    }
    // -- Variables crteated for Smart Meter CR end
    
    // ++ Variable added for Next 7 Day employee search change start
    public static date customerPreferredDate {get; set;}
    // -- Variable added for Next 7 Day employee search change end
    
     // ++ Variable added to know who planned the job change start
    public Static String isPlanner{get;set;}
    // -- Variable added to know who planned the job change end
    
    //variable added to know the job planning is via portal
    public static boolean isPortal{get;set;}
    
    public static boolean iscopyQuoteAC{get;set;}
    public static boolean isSmartNovoManagerChange{get;set;}
    
    public String returnMonth(Integer iMonth){
        String sMonth='';
        if (iMonth==1){
            sMonth='Jan';            
        } else if (iMonth==2){
            sMonth='Feb';            
        } else if (iMonth==3){
            sMonth='Mar';            
        } else if (iMonth==4){
            sMonth='Apr';            
        } else if (iMonth==5){
            sMonth='May';            
        } else if (iMonth==6){
            sMonth='Jun';            
        } else if (iMonth==7){
            sMonth='Jul';            
        } else if (iMonth==8){
            sMonth='Aug';            
        } else if (iMonth==9){
            sMonth='Sep';            
        } else if (iMonth==10){
            sMonth='Oct';            
        } else if (iMonth==11){
            sMonth='Nov';            
        } else if (iMonth==12){
            sMonth='Dec';            
        }
        
        return sMonth;
    }
  /* Moved to seprate class cls_IsRun_Test   
  private static testMethod void cls_IsRun_test() {
        cls_IsRun.setIsorderRun();
        cls_IsRun.setIsQuoteInsertUpdate();
        cls_IsRun.setIsBGRun();
        cls_IsRun.SetIsOppoJobRun();
        cls_IsRun.setIschkAppRun(); 
        cls_IsRun.setIsOppoRun(); 
        cls_IsRun.setIsOppoUpdRun();
        cls_IsRun.setDontFireTriggers(); 
        cls_IsRun.setIsJobPlanned();
        cls_IsRun.setIsConsumReq();    
        cls_IsRun.setIsJobCompletion(); 
        cls_IsRun.setIsCompReq();
        cls_IsRun.setIsOrder();
        cls_IsRun.setIsSuspendJob();
        cls_IsRun.setIsBMQuoteUpdateInsertAppRun();
        cls_IsRun.setisaInsUpd_OnPaymentsObjectRun(); 
        cls_IsRun.setIsDecompiledQuoteProducts();
        cls_IsRun.setIsCalculateNetCustomerPrice();
        cls_IsRun.setIsAppInsertUpdate(); 
        cls_IsRun.setistrg_UpdatePayment();
        cls_IsRun.setIsOppoCanRun(); 
        cls_IsRun clsRun=new cls_IsRun();
        clsRun.returnMonth(1);
        clsRun.returnMonth(2);
        clsRun.returnMonth(3);
        clsRun.returnMonth(4);
        clsRun.returnMonth(5);
        clsRun.returnMonth(6);
        clsRun.returnMonth(7);
        clsRun.returnMonth(8);
        clsRun.returnMonth(9);
        clsRun.returnMonth(10);
        clsRun.returnMonth(11);
        clsRun.returnMonth(12);
        
    } */
}