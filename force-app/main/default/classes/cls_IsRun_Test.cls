/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class cls_IsRun_Test {

    private static testMethod void cls_IsRun_test() {
        cls_IsRun.setIsorderRun();
        system.assertequals(cls_IsRun.isorderInsertUpdate,true);
        cls_IsRun.setIsQuoteInsertUpdate();
        system.assertequals(cls_IsRun.isQuoteInsertUpdate,true);
        cls_IsRun.setIsBGRun();
        system.assertequals(cls_IsRun.isBGRun,true);
        cls_IsRun.setRHCBGRun();
        system.assertequals(cls_IsRun.isRHCRun,true);
        cls_IsRun.SetIsOppoJobRun();
        system.assertequals(cls_IsRun.isOppoJobRun,true);
        cls_IsRun.setIschkAppRun(); 
        system.assertequals(cls_IsRun.ischkAppRun,true);
        cls_IsRun.setIsOppoRun(); 
        system.assertequals(cls_IsRun.isOppoRun,true);
        cls_IsRun.setIsOppoUpdRun();
        system.assertequals(cls_IsRun.isOppoUpdRun,true);
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
        /***Lines addes on 3/4/2015********/
        cls_IsRun.setcallsmartmeter();
        system.assertequals(cls_IsRun.callsmartmeter,true);
        cls_IsRun.setcalljob ();
        system.assertequals(cls_IsRun.calljob,true);
        cls_IsRun.setgeneralTriggerSwitch(); 
        cls_IsRun.setisinstUpdCustCatMasRec();
        cls_IsRun.setIsSalesAppCorrectUpdate();
        cls_IsRun.setistrg_CompleteBriefs();
        cls_IsRun.setistrg_CustAppt();
        cls_IsRun.setistrg_CustApptAfterInsert();
        cls_IsRun.setisRestrictCustCategory();
        cls_IsRun.setisUpdateServiceLevelValues();
        cls_IsRun.setappointmentSwitch();
        cls_IsRun.setbigMachineSwitch();
        cls_IsRun.setistrg_emailSendSingle();
        cls_IsRun.setistrg_CreateCustCategory();
        cls_IsRun.setistrg_bINS_bUPD_chkEmpSkillForItnry();
        cls_IsRun.setistrg_AppointmentBeforeUpdate();
        cls_IsRun.setistrg_AppointmentUpdate();
        cls_IsRun.setistrg_AppointmentBeforeInsert();
        cls_IsRun.setistrg_ensurePrimary();
        cls_IsRun.setistrg_aUPD_AutocancelAppointmentOnQuoteCancelation();
        cls_IsRun.setistrg_updateOpportunityPaymentDetails();
        cls_IsRun.setistrg_aUPD_changeBillingAddress();
        cls_IsRun.setistrg_BigMachinesQuoteInsertJobReconciliation();
        cls_IsRun.setdoNotUpdateSMToCHILead();
        
              
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
        
    }
}