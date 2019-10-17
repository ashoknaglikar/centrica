/**
 * test class for all web service stubs used by Product Holding functionality 
 * Modified By Ashok G on 10-26-2015
 */
@isTest
private class BGServiceStub_Test implements WebServiceMock{
    
   private static testMethod void coverTypes()
    {   
        //britishgasCoUkEnterpriseAddress
       
        new britishgasCoUkEnterpriseAddress.BasicAddress();
        new britishgasCoUkEnterpriseAddress.FindAddressesByElementsResponseMessage();
        new britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDQueryMessage();
        new britishgasCoUkEnterpriseAddress.BasicAddressDetail();
        new britishgasCoUkEnterpriseAddress.AddressSearchCriteria();
        new britishgasCoUkEnterpriseAddress.AddressForeignKeys();
        new britishgasCoUkEnterpriseAddress.AddressKey();
        new britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDResponseMessage();
        new britishgasCoUkEnterpriseAddress.FindAddressesByElementsQueryMessage();
        new britishgasCoUkEnterpriseAddress.AddressBody();
        new britishgasCoUkEnterpriseAddress.AddressValidity();
        new britishgasCoUkEnterpriseAddress.AddressCoordinates();
        new britishgasCoUkEnterpriseAddress.AddressUsage();
        
        //britishgasCoUkOnline24x7servicesMADO
        
        new britishgasCoUkOnline24x7servicesMADO.PaymentOption_Online();
        new britishgasCoUkOnline24x7servicesMADO.LongTermContractWithExpDate_Online();
        new britishgasCoUkOnline24x7servicesMADO.Country50_Name_Online();
        new britishgasCoUkOnline24x7servicesMADO.ServiceNeeds_Online();
        new britishgasCoUkOnline24x7servicesMADO.AddressUsage_Online();
        new britishgasCoUkOnline24x7servicesMADO.AccountBalanceByProductID_Online();
        new britishgasCoUkOnline24x7servicesMADO.NOSC_Log_Online();
        new britishgasCoUkOnline24x7servicesMADO.CommunicationLanguage_Online();
        new britishgasCoUkOnline24x7servicesMADO.BillingBlock_Online();
        new britishgasCoUkOnline24x7servicesMADO.MergeDetails_Online();
        new britishgasCoUkOnline24x7servicesMADO.AccountDetailsRspMsgC_s_Online();
        new britishgasCoUkOnline24x7servicesMADO.OutsortingReason_Online();
        new britishgasCoUkOnline24x7servicesMADO.Product_Online();
        new britishgasCoUkOnline24x7servicesMADO.NOSC_LogItem_Online();
        new britishgasCoUkOnline24x7servicesMADO.Amount_Online();
        new britishgasCoUkOnline24x7servicesMADO.SuppressPrintReason_Online();
        new britishgasCoUkOnline24x7servicesMADO.AccountIDQry_sSel();
        new britishgasCoUkOnline24x7servicesMADO.WarrantIndicator_Online();
        new britishgasCoUkOnline24x7servicesMADO.AccountDetailsC_Online();
        new britishgasCoUkOnline24x7servicesMADO.JointInvoicingIndicator_Online();
        new britishgasCoUkOnline24x7servicesMADO.AccountID();
        new britishgasCoUkOnline24x7servicesMADO.MoveOutReason_Online();
        new britishgasCoUkOnline24x7servicesMADO.AccountType_Online();
        new britishgasCoUkOnline24x7servicesMADO.ExchangeFaultData();
        new britishgasCoUkOnline24x7servicesMADO.CommunicationFormat_Online();
        new britishgasCoUkOnline24x7servicesMADO.AdvancedMeteringSystem_Online();
        new britishgasCoUkOnline24x7servicesMADO.AddressDetails_Online();
        new britishgasCoUkOnline24x7servicesMADO.MonthlyBillingProductDetails_Online();
        new britishgasCoUkOnline24x7servicesMADO.Products_element();
        new britishgasCoUkOnline24x7servicesMADO.LocalFaultMsg_element();
        new britishgasCoUkOnline24x7servicesMADO.Bank_Online();
        new britishgasCoUkOnline24x7servicesMADO.ServiceNeed_element();
        new britishgasCoUkOnline24x7servicesMADO.AccountDetailsByAccountIDResp_Online();
        new britishgasCoUkOnline24x7servicesMADO.OutsortingCheckGroup_Online();
        new britishgasCoUkOnline24x7servicesMADO.LEN60_Description_Online();
        new britishgasCoUkOnline24x7servicesMADO.MergeType_Online();
        new britishgasCoUkOnline24x7servicesMADO.AddressFormat_element();
        new britishgasCoUkOnline24x7servicesMADO.PaymentTerms_Online();
        new britishgasCoUkOnline24x7servicesMADO.AdvancedMeterCapabilityGroup_Online();
        new britishgasCoUkOnline24x7servicesMADO.ProductID();
        new britishgasCoUkOnline24x7servicesMADO.ExchangeLogData();
        new britishgasCoUkOnline24x7servicesMADO.AppliancesList_Online();
        new britishgasCoUkOnline24x7servicesMADO.Stationery_Online();
        new britishgasCoUkOnline24x7servicesMADO.AccountDesc_Online();
        new britishgasCoUkOnline24x7servicesMADO.LEN50_Name_Online();
        new britishgasCoUkOnline24x7servicesMADO.AccountDeterminationID_Online();
        new britishgasCoUkOnline24x7servicesMADO.ProductsDetailsRspMsg1_s_Online();
        new britishgasCoUkOnline24x7servicesMADO.MoveInReason_Online();
        new britishgasCoUkOnline24x7servicesMADO.AccountBalanceByProductIDRspMsg1_s_Online();
        new britishgasCoUkOnline24x7servicesMADO.AddressSet_Online();
        new britishgasCoUkOnline24x7servicesMADO.BankAccountDetails_Online();
        new britishgasCoUkOnline24x7servicesMADO.ProductType_Online();
        new britishgasCoUkOnline24x7servicesMADO.PaperlessBilling_element();
        new britishgasCoUkOnline24x7servicesMADO.DunningProcedure_Online();
        new britishgasCoUkOnline24x7servicesMADO.JobType_Online();
        new britishgasCoUkOnline24x7servicesMADO.PropositionID();
        new britishgasCoUkOnline24x7servicesMADO.AddressID();
        new britishgasCoUkOnline24x7servicesMADO.PaperlessBillingIndicator_Online();
        new britishgasCoUkOnline24x7servicesMADO.UtilitiesPointOfDeliveryPartyID_Online();
        new britishgasCoUkOnline24x7servicesMADO.NoSafetyCheckReason_Online();
        new britishgasCoUkOnline24x7servicesMADO.PreferredCommunicationMethod_Online(); 
        new britishgasCoUkOnline24x7servicesMADO.Segment_Online();
        new britishgasCoUkOnline24x7servicesMADO.ApplianceDetails_Online();
        new britishgasCoUkOnline24x7servicesMADO.SHORT_Description_Online();
        new britishgasCoUkOnline24x7servicesMADO.AccountIDQryMsg1_s();
        new britishgasCoUkOnline24x7servicesMADO.AddressFormatMultiLine();
        new britishgasCoUkOnline24x7servicesMADO.MedicalEquipment_Online();
        new britishgasCoUkOnline24x7servicesMADO.LegacyAccountID();
        
        //test_britishgasCoUkEnterpriseCampaignQC
        
        new britishgasCoUkEnterpriseCampaignQC.TreatmentAim ();
        new britishgasCoUkEnterpriseCampaignQC.TreatmentChannel ();
        new britishgasCoUkEnterpriseCampaignQC.TreatmentStatus ();
        new britishgasCoUkEnterpriseCampaignQC.TreatmentPublished ();
        new britishgasCoUkEnterpriseCampaignQC.PropositionKey ();
        new britishgasCoUkEnterpriseCampaignQC.TreatmentCode ();
        new britishgasCoUkEnterpriseCampaignQC.Campaign ();
        new britishgasCoUkEnterpriseCampaignQC.CampaignDescription ();
        new britishgasCoUkEnterpriseCampaignQC.TreatmentDescription ();
        new britishgasCoUkEnterpriseCampaignQC.CampaignClassification ();
        new britishgasCoUkEnterpriseCampaignQC.CampaignStatus ();
        new britishgasCoUkEnterpriseCampaignQC.CampaignTreatment ();
        new britishgasCoUkEnterpriseCampaignQC.CampaignAim ();
        new britishgasCoUkEnterpriseCampaignQC.TreatmentCallGuide ();
        new britishgasCoUkEnterpriseCampaignQC.TreatmentDates ();
        new britishgasCoUkEnterpriseCampaignQC.TreatmentScript ();
        new britishgasCoUkEnterpriseCampaignQC.CampaignDates ();
        new britishgasCoUkEnterpriseCampaignQC.CampaignIdentification ();
        new britishgasCoUkEnterpriseCampaignQC.CampaignKey ();
        new britishgasCoUkEnterpriseCampaignQC.TreatmentClassification ();
        new britishgasCoUkEnterpriseCampaignQC.TreatmentKey (); 
        
       
        //britishgasCoUkEnterpriseCommon
        
        new britishgasCoUkEnterpriseCommon.BG_Code_Desc150();
        new britishgasCoUkEnterpriseCommon.BG_Code_Desc60();
        new britishgasCoUkEnterpriseCommon.BG_Code_Desc60_V2();
        new britishgasCoUkEnterpriseCommon.BG_CurrencyAmount();
        new britishgasCoUkEnterpriseCommon.BG_CurrencyAmountItem();
        new britishgasCoUkEnterpriseCommon.BG_Description();
        new britishgasCoUkEnterpriseCommon.BG_Identifier();
        new britishgasCoUkEnterpriseCommon.BG_Identifier_Unlimited();
        new britishgasCoUkEnterpriseCommon.BG_LEN60_Description();
        new britishgasCoUkEnterpriseCommon.BG_Log();
        new britishgasCoUkEnterpriseCommon.BG_LogItem();
        new britishgasCoUkEnterpriseCommon.BG_MessageHeader();
        new britishgasCoUkEnterpriseCommon.BG_ProcessingConditions();
        new britishgasCoUkEnterpriseCommon.BG_Quantity();
        new britishgasCoUkEnterpriseCommon.BG_StandardMessageFault_element();
        new britishgasCoUkEnterpriseCommon.BG_StartEndDate();
        new britishgasCoUkEnterpriseCommon.ExchangeFaultData();
        new britishgasCoUkEnterpriseCommon.ExchangeLogData();
        
        //britishgasCoUkEnterpriseConsumptionAPS 
        new britishgasCoUkEnterpriseConsumptionAPS.Consumption();
        
        //britishgasCoUkEnterpriseCreditratingQC
        new britishgasCoUkEnterpriseCreditratingQC.CreditRatingEventBody();
        
        //britishgasCoUkEnterpriseFinancialtraAPS
        new britishgasCoUkEnterpriseFinancialtraAPS.FinancialTransactionAmount_V2();
        
        //britishgasCoUkEnterpriseServiceexecuQP
        new britishgasCoUkEnterpriseServiceexecuQP.AppointmentTimes();
        
        //britishgasCoUkEnterpriseCustomeracco
        
        new britishgasCoUkEnterpriseCustomeracco.ContractBody();
        new britishgasCoUkEnterpriseCustomeracco.ContractedServicesProduct();
        new britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductBasic();
        new britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductInsurance();
        new britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductPackage();
        new britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductPackageBasic();
        new britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductTermOrConditionBasic();
        new britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductVisit();
        new britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductVisit();
        new britishgasCoUkEnterpriseCustomeracco.ContractKey();
        new britishgasCoUkEnterpriseCustomeracco.JointInvoicedAccount();
        new britishgasCoUkEnterpriseCustomeracco.ServiceApplianceOrItem();
        new britishgasCoUkEnterpriseCustomeracco.ServiceApplianceOrItemBasic();
        new britishgasCoUkEnterpriseCustomeracco.ServiceApplianceOrItemKey();
        new britishgasCoUkEnterpriseCustomeracco.ServicesContract();
        new britishgasCoUkEnterpriseCustomeracco.ServicesContractBody();
        new britishgasCoUkEnterpriseCustomeracco.ServicesContractCoolingOff();
        new britishgasCoUkEnterpriseCustomeracco.ServicesContractPayment();
        new britishgasCoUkEnterpriseCustomeracco.SimpleCustomerAccount();
        new britishgasCoUkEnterpriseCustomeracco.SimpleEnergyContract();
        new britishgasCoUkEnterpriseCustomeracco.SimpleServicesContract();
        new britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDRequestMessage();
        new britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDResponseMessage();
        new britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey();  
       
       //britishgasCoUkEnterpriseEmployeeQC
       
        new britishgasCoUkEnterpriseEmployeeQC.EmployeeKey();
        new britishgasCoUkEnterpriseEmployeeQC.EmployeeRelationshipDiscount();
        new britishgasCoUkEnterpriseEmployeeQC.InternalOrganisationUnitKey();
        
        //britishgasCoUkEnterpriseParty
        
        new britishgasCoUkEnterpriseParty.CRM();
        new britishgasCoUkEnterpriseParty.Customer();
        new britishgasCoUkEnterpriseParty.CustomerMeterInformation();
        new britishgasCoUkEnterpriseParty.CustomerSearchCriteria();
        new britishgasCoUkEnterpriseParty.PartyClassification();
        new britishgasCoUkEnterpriseParty.PartyCommunicationPreferences();
        new britishgasCoUkEnterpriseParty.PartyEmailContactMethodBody();
        new britishgasCoUkEnterpriseParty.PartyKey();
        new britishgasCoUkEnterpriseParty.PartyPhoneContactMethodBody();
        new britishgasCoUkEnterpriseParty.PartySecurity();
        new britishgasCoUkEnterpriseParty.PersonBiographicData();
        new britishgasCoUkEnterpriseParty.PersonName();
        new britishgasCoUkEnterpriseParty.PersonSensitivityType();
        new britishgasCoUkEnterpriseParty.PersonVIPDetails();
        new britishgasCoUkEnterpriseParty.PhoneNumber();
        new britishgasCoUkEnterpriseParty.ServiceNeed();
        new britishgasCoUkEnterpriseParty.FindCustomersByElementsResponseMessage();
        new britishgasCoUkEnterpriseParty.FindCustomersByAccountIDResponseMessage();
        new britishgasCoUkEnterpriseParty.FindCustomersByElementsQueryMessage();
        new britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsQueryMessage();
        new britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsResponseMessage();
        
        //britishgasCoUkEnterprisePaymentschemAPS
        
        new britishgasCoUkEnterprisePaymentschemAPS.ContractInformation();
        new britishgasCoUkEnterprisePaymentschemAPS.PaymentSchemeProjectionDetails();
        new britishgasCoUkEnterprisePaymentschemAPS.RecommendationBasedOnPlanStatus();
        new britishgasCoUkEnterprisePaymentschemAPS.GeneratePaymentSchemeProjectionByElementsConfirmationMessage();
        new britishgasCoUkEnterprisePaymentschemAPS.GeneratePaymentSchemeProjectionByElementsRequestMessage();
        
        //britishgasCoUkEnterprisePaymentschemPPO
        
        new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeInformation();
        new britishgasCoUkEnterprisePaymentschemPPO.AssociatedInstalmentItem();
        new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeSimpleByElementsResponse_SyncMessage();
        new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeAttributes();
        new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeAttributesSimpleByAccountIdResponseMessage();
        new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeInstalment();
        new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeSimpleByElementsQuery_SyncMessage();
        new britishgasCoUkEnterprisePaymentschemPPO.NextInstalmentItem();
        new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeAttributesSimpleByAccountIdQueryMessage();
        new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeContractDetails_V2();
        new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeTolerance();
        
        //britishgasCoUkEnterpriseProduct
        
        new britishgasCoUkEnterpriseProduct.EnergyTypeBody();
        new britishgasCoUkEnterpriseProduct.EnergyTypeKey();
        new britishgasCoUkEnterpriseProduct.ProductKey();
        new britishgasCoUkEnterpriseProduct.TariffKey();
        
        //britishgasCoUkEnterpriseSalesQC
        
        new britishgasCoUkEnterpriseSalesQC.CustomerOrderHeader_V2();
        new britishgasCoUkEnterpriseSalesQC.CustomerOrderItemBasic_V2();
        new britishgasCoUkEnterpriseSalesQC.CustomerOrderKey();
        
        //britishgasCoUkEnterpriseTaskQP
        
        new britishgasCoUkEnterpriseTaskQP.TaskReason();
        new britishgasCoUkEnterpriseTaskQP.TaskReasonForeignKeys();
        new britishgasCoUkEnterpriseTaskQP.TaskReasonKey();
        
        //britishgasCoUkErpPaymentschemePPO
        
        new britishgasCoUkErpPaymentschemePPO.AssociatedInstalmentItem();
        new britishgasCoUkErpPaymentschemePPO.NextInstalmentItem();
        new britishgasCoUkErpPaymentschemePPO.PaymentSchemeContractDetails();
        new britishgasCoUkErpPaymentschemePPO.PaymentSchemeInstalment();
        new britishgasCoUkErpPaymentschemePPO.PaymentSchemeSimpleByBasicDataResponse_SyncMessage();
        new britishgasCoUkErpPaymentschemePPO.PaymentSchemeSimpleByBasicDataQuery_SyncMessage();
        
    }
     public void doInvoke(
          Object stub,
          Object request,
          Map<String, Object> response,
          String endpoint,
          String soapAction,
          String requestName,
          String responseNS,
          String responseName,
          String responseType) {
           
        System.debug(LoggingLevel.INFO, 'toaCapacityMockImpl.doInvoke() - ' +
          '\n request: ' + request +
          '\n response: ' + response +
          '\n endpoint: ' + endpoint +
          '\n soapAction: ' + soapAction +
          '\n requestName: ' + requestName +
          '\n responseNS: ' + responseNS +
          '\n responseName: ' + responseName +
          '\n responseType: ' + responseType);
         
        
        if(request instanceOf britishgasCoUkEnterpriseAddress.FindAddressesByElementsQueryMessage) {
          response.put( 'response_x', new britishgasCoUkEnterpriseAddress.FindAddressesByElementsResponseMessage());
        }
        else if(request instanceOf britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDQueryMessage) {
          response.put( 'response_x', new britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDResponseMessage());
        }
        else if(request instanceOf britishgasCoUkOnline24x7servicesMADO.AccountIDQryMsg1_s) {
          response.put( 'response_x', new britishgasCoUkOnline24x7servicesMADO.AccountDetailsByAccountIDResp_Online());
        }
        else if(request instanceOf britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDRequestMessage) {
          response.put( 'response_x', new britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDResponseMessage());
        }
        else if(request instanceOf britishgasCoUkEnterpriseParty.FindCustomersByElementsQueryMessage) {
          response.put( 'response_x', new britishgasCoUkEnterpriseParty.FindCustomersByElementsResponseMessage());
        }
        else if(request instanceOf britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsQueryMessage) {
          response.put( 'response_x', new britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsResponseMessage());
        }
        else if(request instanceOf britishgasCoUkEnterpriseParty.FindCustomersByAccountIDQueryMessage) {
          response.put( 'response_x', new britishgasCoUkEnterpriseParty.FindCustomersByAccountIDResponseMessage());
        }
        else if(request instanceOf britishgasCoUkEnterprisePaymentschemAPS.GeneratePaymentSchemeProjectionByElementsRequestMessage) {
          response.put( 'response_x', new britishgasCoUkEnterprisePaymentschemAPS.GeneratePaymentSchemeProjectionByElementsConfirmationMessage());
        }
        else if(request instanceOf britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeSimpleByElementsQuery_SyncMessage) {
          response.put( 'response_x', new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeSimpleByElementsResponse_SyncMessage());
        }
        else if(request instanceOf britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeAttributesSimpleByAccountIdQueryMessage) {
          response.put( 'response_x', new britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeAttributesSimpleByAccountIdResponseMessage());
        }
        else if(request instanceOf britishgasCoUkErpPaymentschemePPO.PaymentSchemeSimpleByBasicDataQuery_SyncMessage) {
          response.put( 'response_x', new britishgasCoUkErpPaymentschemePPO.PaymentSchemeSimpleByBasicDataResponse_SyncMessage());
        }
        return ;
      }
      
      @isTest  
      private static void test_britishgasCoUkEnterpriseAddress()
      {   
            System.Test.setMock(WebServiceMock.class, new BGServiceStub_Test());
            
            new britishgasCoUkEnterpriseAddress.Binding_x1QueryAddressBinding().FindAddressesByElements(null, null, null);
            new britishgasCoUkEnterpriseAddress.Binding_x1QueryAddressBinding().FindAddressesByAccountID(null,null,null);
           
     } 
     
     @isTest  
      private static void test_britishgasCoUkOnline24x7servicesMADO()
      {   
            System.Test.setMock(WebServiceMock.class, new BGServiceStub_Test());
            
            new britishgasCoUkOnline24x7servicesMADO.Binding_x1ManageAccountDetailsOutBinding().AccountEnergybyIDQueryRequest_Out(null, null);
           
     }
      
     @isTest  
      private static void test_britishgasCoUkEnterpriseCustomeracco()
      {   
            System.Test.setMock(WebServiceMock.class, new BGServiceStub_Test());
            
            new britishgasCoUkEnterpriseCustomeracco.Binding_x1QueryProduct().ServiceProductByCustomer(null, null);
           
     }
     
     @isTest  
      private static void test_britishgasCoUkEnterpriseParty()
      {   
            System.Test.setMock(WebServiceMock.class, new BGServiceStub_Test());
            
            new britishgasCoUkEnterpriseParty.Binding_x1QueryCustomerBinding().FindCustomersByAccountID(null, null);
            new britishgasCoUkEnterpriseParty.Binding_x1QueryCustomerBinding().FindCustomersByAddressElements(null, null, null);
            new britishgasCoUkEnterpriseParty.Binding_x1QueryCustomerBinding().FindCustomersByElements(null, null, null);
           
     }
     
     @isTest  
      private static void test_britishgasCoUkEnterprisePaymentschemAPS()
      {   
            System.Test.setMock(WebServiceMock.class, new BGServiceStub_Test());
            
            new britishgasCoUkEnterprisePaymentschemAPS.Binding_x1ActionPaymentSchemeBinding().GeneratePaymentSchemeProjectionByElements(null, null, null, null, null, null, null);
           
     }
     
     @isTest  
      private static void test_britishgasCoUkErpPaymentschemePPO()
      {   
            System.Test.setMock(WebServiceMock.class, new BGServiceStub_Test());
            
            new britishgasCoUkErpPaymentschemePPO.Binding_x1PaymentschemeprocessingQueryPaymentSchemeOutBinding().FindPaymentSchemeNextInstallmentsByBasicData(null, null);
            new britishgasCoUkErpPaymentschemePPO.Binding_x1PaymentschemeprocessingQueryPaymentSchemeOutBinding().FindPaymentSchemeAttributesByAccountId(null, null);
            new britishgasCoUkErpPaymentschemePPO.Binding_x1PaymentschemeprocessingQueryPaymentSchemeOutBinding().FindPaymentSchemeByElements(null, null);
           
     }
    
   
}