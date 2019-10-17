public class britishgasCoUkEnterpriseCustomeracco {
	
	private static string SERVICEENDPOINT = '/xe1/XISOAPAdapter/MessageServlet?senderParty=&senderService=BSR_Salesforce&receiverParty=&receiverService=&interface=PaymentschemeprocessingQueryPaymentSchemeOut&interfaceNamespace=urn:britishgas.co.uk:ERP:PaymentScheme';
											
	public class ContractKey { 
        public britishgasCoUkEnterpriseCommon.BG_Identifier ContractReference;
        private String[] ContractReference_type_info = new String[]{'ContractReference','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ContractReference'};
    }
	public class ContractBody {
        public Date ContractStartDate;
        public Date ContractEndDate;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ContractStatus;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 JointInvoicingPreference;
        public String ContractBalance;
        private String[] ContractStartDate_type_info = new String[]{'ContractStartDate','http://www.w3.org/2001/XMLSchema','date','0','1','false'};
        private String[] ContractEndDate_type_info = new String[]{'ContractEndDate','http://www.w3.org/2001/XMLSchema','date','0','1','false'};
        private String[] ContractStatus_type_info = new String[]{'ContractStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] JointInvoicingPreference_type_info = new String[]{'JointInvoicingPreference','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ContractBalance_type_info = new String[]{'ContractBalance','urn:britishgas.co.uk:Enterprise:Common','BG_Amount','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ContractStartDate','ContractEndDate','ContractStatus','JointInvoicingPreference','ContractBalance'};
    }
    public class ContractedServicesProductPackage {
        public britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductPackageBasic ServicesProductPackageBasic;
        public britishgasCoUkEnterpriseCustomeracco.ContractedServicesProduct[] ServicesProduct;
        private String[] ServicesProductPackageBasic_type_info = new String[]{'ServicesProductPackageBasic','urn:britishgas.co.uk:Enterprise:CustomerAccount','ContractedServicesProductPackageBasic','1','1','false'};
        private String[] ServicesProduct_type_info = new String[]{'ServicesProduct','urn:britishgas.co.uk:Enterprise:CustomerAccount','ContractedServicesProduct','1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ServicesProductPackageBasic','ServicesProduct'};
    }
    public class ContractedServicesProductBasic {
        public String ServiceStandardDescription;
        public String HomeServicingProductName;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ServicesProductCategory;
        private String[] ServiceStandardDescription_type_info = new String[]{'ServiceStandardDescription','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] HomeServicingProductName_type_info = new String[]{'HomeServicingProductName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ServicesProductCategory_type_info = new String[]{'ServicesProductCategory','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ServiceStandardDescription','HomeServicingProductName','ServicesProductCategory'};
    }
    public class ServiceApplianceOrItemBasic {
        public String ApplianceDescription;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ApplianceStatus;
        public String ApplianceMake;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ApplianceFuelType;
        public String ApplianceModel;
        public String GasSafetyCertificateRequired;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ApplianceType;
        private String[] ApplianceDescription_type_info = new String[]{'ApplianceDescription','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ApplianceStatus_type_info = new String[]{'ApplianceStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ApplianceMake_type_info = new String[]{'ApplianceMake','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ApplianceFuelType_type_info = new String[]{'ApplianceFuelType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ApplianceModel_type_info = new String[]{'ApplianceModel','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] GasSafetyCertificateRequired_type_info = new String[]{'GasSafetyCertificateRequired','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] ApplianceType_type_info = new String[]{'ApplianceType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ApplianceDescription','ApplianceStatus','ApplianceMake','ApplianceFuelType','ApplianceModel','GasSafetyCertificateRequired','ApplianceType'};
    }
    public class ContractedServicesProductVisit {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 NextVisitType;
        public String DateContractedServiceVisitDeferred;
        public String NextContractedServiceVisitDate;
        private String[] NextVisitType_type_info = new String[]{'NextVisitType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] DateContractedServiceVisitDeferred_type_info = new String[]{'DateContractedServiceVisitDeferred','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] NextContractedServiceVisitDate_type_info = new String[]{'NextContractedServiceVisitDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'NextVisitType','DateContractedServiceVisitDeferred','NextContractedServiceVisitDate'};
    }
    public class ContractedServicesProduct {
        public britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductBasic ServicesProductBasic;
        public britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductTermOrConditionBasic ServicesProductTermOrConditionBasic;
        public britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductInsurance ServicesProductInsurance;
        public britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductVisit ServicesProductVisit;
        public britishgasCoUkEnterpriseCustomeracco.ServiceApplianceOrItem[] ServiceApplianceOrItem;
        private String[] ServicesProductBasic_type_info = new String[]{'ServicesProductBasic','urn:britishgas.co.uk:Enterprise:CustomerAccount','ContractedServicesProductBasic','1','1','false'};
        private String[] ServicesProductTermOrConditionBasic_type_info = new String[]{'ServicesProductTermOrConditionBasic','urn:britishgas.co.uk:Enterprise:CustomerAccount','ContractedServicesProductTermOrConditionBasic','1','1','false'};
        private String[] ServicesProductInsurance_type_info = new String[]{'ServicesProductInsurance','urn:britishgas.co.uk:Enterprise:CustomerAccount','ContractedServicesProductInsurance','1','1','false'};
        private String[] ServicesProductVisit_type_info = new String[]{'ServicesProductVisit','urn:britishgas.co.uk:Enterprise:CustomerAccount','ContractedServicesProductVisit','1','1','false'};
        private String[] ServiceApplianceOrItem_type_info = new String[]{'ServiceApplianceOrItem','urn:britishgas.co.uk:Enterprise:CustomerAccount','ServiceApplianceOrItem','1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ServicesProductBasic','ServicesProductTermOrConditionBasic','ServicesProductInsurance','ServicesProductVisit','ServiceApplianceOrItem'};
    }
    public class Binding_x1QueryProduct {
        public String endpoint_x = System.Label.CHIPH_QueryCustomer_Endpoint + SERVICEENDPOINT;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party', 'britishgasCoUkEnterpriseParty', 'urn:britishgas.co.uk:Enterprise:Task', 'britishgasCoUkEnterpriseTaskQP', 'urn:britishgas.co.uk:Enterprise:CustomerAccount', 'britishgasCoUkEnterpriseCustomeracco', 'urn:britishgas.co.uk:Enterprise:Common', 'britishgasCoUkEnterpriseCommon', 'urn:britishgas.co.uk:Enterprise:ServiceExecutionOrder', 'britishgasCoUkEnterpriseServiceexecuQP', 'urn:britishgas.co.uk:Enterprise:Address', 'britishgasCoUkEnterpriseAddress'};
        //public britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDResponseMessage ServiceProductByCustomer(britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey[] CustomerAccountKey,String[] BG_ServiceConsumer) {
        public britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDResponseMessage ServiceProductByCustomer(britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey[] CustomerAccountKey,String BG_ServiceConsumer) {
            britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDRequestMessage request_x = new britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDRequestMessage();
            britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDResponseMessage response_x;
            request_x.CustomerAccountKey = CustomerAccountKey;
            request_x.BG_ServiceConsumer = BG_ServiceConsumer;
            Map<String, britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDResponseMessage> response_map_x = new Map<String, britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDResponseMessage>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://sap.com/xi/WebService/soap1.1',
              'urn:britishgas.co.uk:Enterprise:CustomerAccount',
              'FindServicesProductsByAccountIDRequest',
              'urn:britishgas.co.uk:Enterprise:CustomerAccount',
              'FindServicesProductsByAccountIDResponse',
              'britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDResponseMessage'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
    public class ServicesContract {
        public britishgasCoUkEnterpriseCustomeracco.ContractBody ContractBody;
        public britishgasCoUkEnterpriseParty.PartyKey CustomerID; 
        public britishgasCoUkEnterpriseAddress.AddressKey AddressID;
        public britishgasCoUkEnterpriseCustomeracco.ServicesContractBody ServicesContractBody;
        public britishgasCoUkEnterpriseCustomeracco.ServicesContractCoolingOff ServicesContractCoolingOff;
        public britishgasCoUkEnterpriseCustomeracco.ServicesContractPayment ServicesContractPayment;
        public britishgasCoUkEnterpriseCustomeracco.ContractedServicesProductPackage[] ServicesProductPackage;
        private String[] ContractBody_type_info = new String[]{'ContractBody','urn:britishgas.co.uk:Enterprise:CustomerAccount','ContractBody','1','1','false'};
        private String[] CustomerID_type_info = new String[]{'CustomerID','urn:britishgas.co.uk:Enterprise:Party','PartyKey','1','1','false'};
        private String[] AddressID_type_info = new String[]{'AddressID','urn:britishgas.co.uk:Enterprise:Address','AddressKey','1','1','false'};
        private String[] ServicesContractBody_type_info = new String[]{'ServicesContractBody','urn:britishgas.co.uk:Enterprise:CustomerAccount','ServicesContractBody','1','1','false'};
        private String[] ServicesContractCoolingOff_type_info = new String[]{'ServicesContractCoolingOff','urn:britishgas.co.uk:Enterprise:CustomerAccount','ServicesContractCoolingOff','1','1','false'};
        private String[] ServicesContractPayment_type_info = new String[]{'ServicesContractPayment','urn:britishgas.co.uk:Enterprise:CustomerAccount','ServicesContractPayment','1','1','false'};
        private String[] ServicesProductPackage_type_info = new String[]{'ServicesProductPackage','urn:britishgas.co.uk:Enterprise:CustomerAccount','ContractedServicesProductPackage','1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ContractBody','CustomerID','AddressID','ServicesContractBody','ServicesContractCoolingOff','ServicesContractPayment','ServicesProductPackage'};
    }
    public class ServicesContractCoolingOff {
        public String CoolingOffPeriodIndicator;
        private String[] CoolingOffPeriodIndicator_type_info = new String[]{'CoolingOffPeriodIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'CoolingOffPeriodIndicator'};
    }
    public class ContractedServicesProductPackageBasic {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ServicesProductPackageCode;
        private String[] ServicesProductPackageCode_type_info = new String[]{'ServicesProductPackageCode','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ServicesProductPackageCode'};
    }
    public class FindServicesProductsByAccountIDRequestMessage {
        public britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey[] CustomerAccountKey;
        //public String[] BG_ServiceConsumer;
        public String BG_ServiceConsumer;
        //private String[] CustomerAccountKey_type_info = new String[]{'CustomerAccountKey','urn:britishgas.co.uk:Enterprise:CustomerAccount','CustomerAccountKey','1','-1','false'};
        private String[] CustomerAccountKey_type_info = new String[]{'CustomerAccountKey','urn:britishgas.co.uk:Enterprise:CustomerAccount','CustomerAccountKey','0','1','false'};
        //private String[] BG_ServiceConsumer_type_info = new String[]{'BG_ServiceConsumer','urn:britishgas.co.uk:Enterprise:Common','BG_ServiceConsumer','1','-1','false'};
        private String[] BG_ServiceConsumer_type_info = new String[]{'BG_ServiceConsumer','http://www.w3.org/2001/XMLSchema','String','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'CustomerAccountKey','BG_ServiceConsumer'};
    }
    public class ServiceApplianceOrItemKey {
        public britishgasCoUkEnterpriseCommon.BG_Identifier ServiceApplianceOrItemIdentifier;
        private String[] ServiceApplianceOrItemIdentifier_type_info = new String[]{'ServiceApplianceOrItemIdentifier','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ServiceApplianceOrItemIdentifier'};
    }
    public class ContractedServicesProductInsurance {
        //public String ServicesInsuranceIndicator;
        public String ServicesInsuranceIndicator;
        private String[] ServicesInsuranceIndicator_type_info = new String[]{'ServicesInsuranceIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ServicesInsuranceIndicator'};
    }
    public class ServicesContractBody {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ServicesTypeCode;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ContractRenewalStatus;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ContractEndAction;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ContractEndActionReason;
        public String DescriptionOfContractEndAction;
        public String PlannedEndDate;
        public String ActualEndDate;
        public String BulkIndicator;
        private String[] ServicesTypeCode_type_info = new String[]{'ServicesTypeCode','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ContractRenewalStatus_type_info = new String[]{'ContractRenewalStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ContractEndAction_type_info = new String[]{'ContractEndAction','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ContractEndActionReason_type_info = new String[]{'ContractEndActionReason','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] DescriptionOfContractEndAction_type_info = new String[]{'DescriptionOfContractEndAction','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PlannedEndDate_type_info = new String[]{'PlannedEndDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] ActualEndDate_type_info = new String[]{'ActualEndDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] BulkIndicator_type_info = new String[]{'BulkIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ServicesTypeCode','ContractRenewalStatus','ContractEndAction','ContractEndActionReason','DescriptionOfContractEndAction','PlannedEndDate','ActualEndDate','BulkIndicator'};
    }
    public class FindServicesProductsByAccountIDResponseMessage {
        public britishgasCoUkEnterpriseCustomeracco.ServicesContract[] ServicesContract;
        public britishgasCoUkEnterpriseCommon.BG_Log[] BG_Log;
        private String[] ServicesContract_type_info = new String[]{'ServicesContract','urn:britishgas.co.uk:Enterprise:CustomerAccount','ServicesContract','0','-1','false'};
        private String[] BG_Log_type_info = new String[]{'BG_Log','urn:britishgas.co.uk:Enterprise:Common','BG_Log','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ServicesContract','BG_Log'};
    }
    public class ContractedServicesProductTermOrConditionBasic {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ServiceLevelAgreement;
        //public String TimedAppointmentIndicator;
        public Boolean TimedAppointmentIndicator;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ProductRenewalLevelOfService;
        private String[] ServiceLevelAgreement_type_info = new String[]{'ServiceLevelAgreement','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] TimedAppointmentIndicator_type_info = new String[]{'TimedAppointmentIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] ProductRenewalLevelOfService_type_info = new String[]{'ProductRenewalLevelOfService','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ServiceLevelAgreement','TimedAppointmentIndicator','ProductRenewalLevelOfService'};
    }
    public class ServicesContractPayment {
        public britishgasCoUkEnterpriseCommon.BG_CurrencyAmount ContractInstallmentAmount;
        public britishgasCoUkEnterpriseCommon.BG_CurrencyAmount ContractAnnualAmount;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 InstallmentFrequency; 
        private String[] ContractInstallmentAmount_type_info = new String[]{'ContractInstallmentAmount','urn:britishgas.co.uk:Enterprise:Common','BG_CurrencyAmount','0','1','false'};
        private String[] ContractAnnualAmount_type_info = new String[]{'ContractAnnualAmount','urn:britishgas.co.uk:Enterprise:Common','BG_CurrencyAmount','0','1','false'};
        private String[] InstallmentFrequency_type_info = new String[]{'InstallmentFrequency','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ContractInstallmentAmount','ContractAnnualAmount','InstallmentFrequency'};
    }
    public class CustomerAccountKey {
        //public britishgasCoUkEnterpriseCommon.BG_Identifier CustomerAccountID; 
        public String CustomerAccountID;
        //private String[] CustomerAccountID_type_info = new String[]{'CustomerAccountID','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','1','1','false'};
        private String[] CustomerAccountID_type_info = new String[]{'CustomerAccountID','http://www.w3.org/2001/XMLSchema','String','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'CustomerAccountID'};
    }
    public class ServiceApplianceOrItem {
        public britishgasCoUkEnterpriseCustomeracco.ServiceApplianceOrItemKey ApplianceID;
        public britishgasCoUkEnterpriseCustomeracco.ServiceApplianceOrItemBasic ServiceApplianceOrItemBasic;
        public britishgasCoUkEnterpriseServiceexecuQP.AppointmentTimes AppointmentTimes;
        public britishgasCoUkEnterpriseTaskQP.TaskReason[] Fault;
        private String[] ApplianceID_type_info = new String[]{'ApplianceID','urn:britishgas.co.uk:Enterprise:CustomerAccount','ServiceApplianceOrItemKey','1','1','false'};
        private String[] ServiceApplianceOrItemBasic_type_info = new String[]{'ServiceApplianceOrItemBasic','urn:britishgas.co.uk:Enterprise:CustomerAccount','ServiceApplianceOrItemBasic','1','1','false'};
        private String[] AppointmentTimes_type_info = new String[]{'AppointmentTimes','urn:britishgas.co.uk:Enterprise:ServiceExecutionOrder','AppointmentTimes','1','1','false'};
        private String[] Fault_type_info = new String[]{'Fault','urn:britishgas.co.uk:Enterprise:Task','TaskReason','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ApplianceID','ServiceApplianceOrItemBasic','AppointmentTimes','Fault'};
    }
    public class SimpleCustomerAccount {
        //public britishgasCoUkEnterpriseCommon.BG_Identifier CustomerAccountID;
        public String CustomerAccountID;
        public String AccountName;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 AccountClass;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 AccountStatus;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60_V2 AccountType;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 PreferredCommunicationFormat;
        public String AuthorityLevel;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ResponsibilityType;
        //public String PaymentOption;
        public britishgasCoUkOnline24x7servicesMADO.PaymentOption_Online PaymentOption;
        public String AccountOnLineIndicator;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 PaperlessBillingStatus;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 PreferredLanguage;
        public britishgasCoUkEnterpriseAddress.AddressUsage[] BillingAddressHistory;
        public britishgasCoUkEnterpriseAddress.AddressUsage[] ForwardingAddressHistory;
        public britishgasCoUkEnterpriseCustomeracco.SimpleEnergyContract[] EnergyContract;
        public britishgasCoUkEnterpriseCustomeracco.SimpleServicesContract[] ServicesContract;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 StationeryFormat;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 Brand;
        public britishgasCoUkEnterpriseCommon.BG_Identifier LegacyAccountReference;
        public britishgasCoUkEnterpriseCustomeracco.JointInvoicedAccount JointInvoicedAccount;
        private String[] CustomerAccountID_type_info = new String[]{'CustomerAccountID','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','0','1','false'};
        private String[] AccountName_type_info = new String[]{'AccountName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] AccountClass_type_info = new String[]{'AccountClass','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] AccountStatus_type_info = new String[]{'AccountStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] AccountType_type_info = new String[]{'AccountType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60_V2','0','1','false'};
        private String[] PreferredCommunicationFormat_type_info = new String[]{'PreferredCommunicationFormat','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] AuthorityLevel_type_info = new String[]{'AuthorityLevel','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ResponsibilityType_type_info = new String[]{'ResponsibilityType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] PaymentOption_type_info = new String[]{'PaymentOption','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] AccountOnLineIndicator_type_info = new String[]{'AccountOnLineIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] PaperlessBillingStatus_type_info = new String[]{'PaperlessBillingStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] PreferredLanguage_type_info = new String[]{'PreferredLanguage','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] BillingAddressHistory_type_info = new String[]{'BillingAddressHistory','urn:britishgas.co.uk:Enterprise:Address','AddressUsage','0','-1','false'};
        private String[] ForwardingAddressHistory_type_info = new String[]{'ForwardingAddressHistory','urn:britishgas.co.uk:Enterprise:Address','AddressUsage','0','-1','false'};
        private String[] EnergyContract_type_info = new String[]{'EnergyContract','urn:britishgas.co.uk:Enterprise:CustomerAccount','SimpleEnergyContract','0','-1','false'};
        private String[] ServicesContract_type_info = new String[]{'ServicesContract','urn:britishgas.co.uk:Enterprise:CustomerAccount','SimpleServicesContract','0','-1','false'};
        private String[] StationeryFormat_type_info = new String[]{'StationeryFormat','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] Brand_type_info = new String[]{'Brand','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] LegacyAccountReference_type_info = new String[]{'LegacyAccountReference','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','0','1','false'};
        private String[] JointInvoicedAccount_type_info = new String[]{'JointInvoicedAccount','urn:britishgas.co.uk:Enterprise:CustomerAccount','JointInvoicedAccount','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'CustomerAccountID','AccountName','AccountClass','AccountStatus','AccountType','PreferredCommunicationFormat','AuthorityLevel','ResponsibilityType','PaymentOption','AccountOnLineIndicator','PaperlessBillingStatus','PreferredLanguage','BillingAddressHistory','ForwardingAddressHistory','EnergyContract','ServicesContract','StationeryFormat','Brand','LegacyAccountReference','JointInvoicedAccount'};
    }
    public class SimpleEnergyContract {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 EnergyTypeCode;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ContractStatus;
        public britishgasCoUkEnterpriseCommon.BG_Identifier ContractReference;
        public String ContractStartDate;
        public String ContractEndDate;
        public britishgasCoUkEnterpriseAddress.AddressUsage ContractAddress;
        private String[] EnergyTypeCode_type_info = new String[]{'EnergyTypeCode','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ContractStatus_type_info = new String[]{'ContractStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ContractReference_type_info = new String[]{'ContractReference','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','0','1','false'};
        private String[] ContractStartDate_type_info = new String[]{'ContractStartDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] ContractEndDate_type_info = new String[]{'ContractEndDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] ContractAddress_type_info = new String[]{'ContractAddress','urn:britishgas.co.uk:Enterprise:Address','AddressUsage','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'EnergyTypeCode','ContractStatus','ContractReference','ContractStartDate','ContractEndDate','ContractAddress'};
    }
    public class SimpleServicesContract {
        public String ContractStartDate;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ServicesTypeCode;
        public britishgasCoUkEnterpriseCommon.BG_Identifier ContractReference;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ContractStatus;
        public String ContractEndDate;
        public britishgasCoUkEnterpriseAddress.AddressUsage ContractAddress;
        private String[] ContractStartDate_type_info = new String[]{'ContractStartDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] ServicesTypeCode_type_info = new String[]{'ServicesTypeCode','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ContractReference_type_info = new String[]{'ContractReference','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','0','1','false'};
        private String[] ContractStatus_type_info = new String[]{'ContractStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ContractEndDate_type_info = new String[]{'ContractEndDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] ContractAddress_type_info = new String[]{'ContractAddress','urn:britishgas.co.uk:Enterprise:Address','AddressUsage','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'ContractStartDate','ServicesTypeCode','ContractReference','ContractStatus','ContractEndDate','ContractAddress'};
    }
    public class JointInvoicedAccount {
        public String JointInvoicedIndicator;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 JointInvoicedPreference;
        public String JointInvoiceMergeDate;
        public String JointInvoiceDeMergeDate;
        private String[] JointInvoicedIndicator_type_info = new String[]{'JointInvoicedIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] JointInvoicedPreference_type_info = new String[]{'JointInvoicedPreference','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] JointInvoiceMergeDate_type_info = new String[]{'JointInvoiceMergeDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] JointInvoiceDeMergeDate_type_info = new String[]{'JointInvoiceDeMergeDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount','false','false'};
        private String[] field_order_type_info = new String[]{'JointInvoicedIndicator','JointInvoicedPreference','JointInvoiceMergeDate','JointInvoiceDeMergeDate'};
    }
}