public class britishgasCoUkEnterpriseParty 
{ 
    //test url
    //public static string SERVICEENDPOINT = 'XISOAPAdapter/MessageServlet?senderParty=&senderService=BSR_Salesforce&receiverParty=&receiverService=&interface=QueryCustomer&interfaceNamespace=urn%3Abritishgas.co.uk%3AEnterprise%3AParty'; 
    //Server url
    //public static string SERVICEENDPOINT = '/xp1/XISOAPAdapter/MessageServlet?senderParty=&senderService=BSR_Salesforce&receiverParty=& receiverService=&interface=QueryCustomer&interfaceNamespace=urn%3Abritishgas.co.uk%3AEnterprise%3AParty'; 
    public class FindCustomersByAccountIDQueryMessage {
        public britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey AccountID;
        public String ServiceConsumer;
        private String[] AccountID_type_info = new String[]{'AccountID','urn:britishgas.co.uk:Enterprise:CustomerAccount','CustomerAccountKey','1','1','false'};
        private String[] ServiceConsumer_type_info = new String[]{'ServiceConsumer','urn:britishgas.co.uk:Enterprise:Common','BG_ServiceConsumer','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'AccountID','ServiceConsumer'};
    }
    /*
    public class PartyKey {
        public britishgasCoUkEnterpriseCommon.BG_Identifier PartyID;
        private String[] PartyID_type_info = new String[]{'PartyID','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'PartyID'};
    }
    */
    
    public class PartyKey {
        public String PartyID;
        private String[] PartyID_type_info = new String[]{'PartyID','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'PartyID'};
    }
    public class Customer {
        public britishgasCoUkEnterpriseParty.PartyKey CustomerID;
        public britishgasCoUkEnterpriseParty.PersonBiographicData PersonBiographicData;
        public britishgasCoUkEnterpriseParty.CRM Crm;
        public britishgasCoUkEnterpriseParty.PartySecurity PartySecurity;
        public britishgasCoUkEnterpriseParty.PersonVIPDetails PersonVIPDetails;
        public britishgasCoUkEnterpriseParty.ServiceNeed[] ServiceNeed;
        public britishgasCoUkEnterpriseCreditratingQC.CreditRatingEventBody[] RiskSegment;
        public britishgasCoUkEnterpriseAddress.AddressUsage[] CorrespondenceAddressHistory; 
        public britishgasCoUkEnterpriseAddress.AddressUsage[] LandlordAddressHistory;
        public britishgasCoUkEnterpriseCustomeracco.SimpleCustomerAccount[] SimpleAccount; 
        public britishgasCoUkEnterpriseParty.CustomerMeterInformation CustomerMeterInformation;
        public String MasterSystemID;
        public britishgasCoUkEnterpriseEmployeeQC.EmployeeRelationshipDiscount EmployeeRelationshipDiscount; 
        public britishgasCoUkEnterpriseParty.PersonSensitivityType PersonSensitivityType;
        public britishgasCoUkEnterpriseCampaignQC.Campaign[] Campaign;
        public britishgasCoUkEnterpriseSalesQC.CustomerOrderHeader_V2[] CustomerOrder; 
        private String[] CustomerID_type_info = new String[]{'CustomerID','urn:britishgas.co.uk:Enterprise:Party','PartyKey','0','1','false'};
        private String[] PersonBiographicData_type_info = new String[]{'PersonBiographicData','urn:britishgas.co.uk:Enterprise:Party','PersonBiographicData','0','1','false'};
        private String[] Crm_type_info = new String[]{'Crm','urn:britishgas.co.uk:Enterprise:Party','CRM','0','1','false'};
        private String[] PartySecurity_type_info = new String[]{'PartySecurity','urn:britishgas.co.uk:Enterprise:Party','PartySecurity','0','1','false'};
        private String[] PersonVIPDetails_type_info = new String[]{'PersonVIPDetails','urn:britishgas.co.uk:Enterprise:Party','PersonVIPDetails','0','1','false'};
        private String[] ServiceNeed_type_info = new String[]{'ServiceNeed','urn:britishgas.co.uk:Enterprise:Party','ServiceNeed','0','-1','false'};
        private String[] RiskSegment_type_info = new String[]{'RiskSegment','urn:britishgas.co.uk:Enterprise:CreditRating','CreditRatingEventBody','0','-1','false'};
        private String[] CorrespondenceAddressHistory_type_info = new String[]{'CorrespondenceAddressHistory','urn:britishgas.co.uk:Enterprise:Address','AddressUsage','0','-1','false'};
        private String[] LandlordAddressHistory_type_info = new String[]{'LandlordAddressHistory','urn:britishgas.co.uk:Enterprise:Address','AddressUsage','0','-1','false'};
        private String[] SimpleAccount_type_info = new String[]{'SimpleAccount','urn:britishgas.co.uk:Enterprise:CustomerAccount','SimpleCustomerAccount','0','-1','false'};
        private String[] CustomerMeterInformation_type_info = new String[]{'CustomerMeterInformation','urn:britishgas.co.uk:Enterprise:Party','CustomerMeterInformation','0','1','false'};
        private String[] MasterSystemID_type_info = new String[]{'MasterSystemID','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EmployeeRelationshipDiscount_type_info = new String[]{'EmployeeRelationshipDiscount','urn:britishgas.co.uk:Enterprise:Employee','EmployeeRelationshipDiscount','0','1','false'};
        private String[] PersonSensitivityType_type_info = new String[]{'PersonSensitivityType','urn:britishgas.co.uk:Enterprise:Party','PersonSensitivityType','0','1','false'};
        private String[] Campaign_type_info = new String[]{'Campaign','urn:britishgas.co.uk:Enterprise:Campaign','Campaign','0','-1','false'};
        private String[] CustomerOrder_type_info = new String[]{'CustomerOrder','urn:britishgas.co.uk:Enterprise:Sales','CustomerOrderHeader_V2','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'CustomerID','PersonBiographicData','Crm','PartySecurity','PersonVIPDetails','ServiceNeed','RiskSegment','CorrespondenceAddressHistory','LandlordAddressHistory','SimpleAccount','CustomerMeterInformation','MasterSystemID','EmployeeRelationshipDiscount','PersonSensitivityType','Campaign','CustomerOrder'};
    }
    public class PersonName {
        public String FirstName;
        public String MiddleName;
        public String Surname;
        public String Title;
        public String NameSuffix;
        public String NameChangeReason;
        public String KnownAsName;
        private String[] FirstName_type_info = new String[]{'FirstName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] MiddleName_type_info = new String[]{'MiddleName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Surname_type_info = new String[]{'Surname','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Title_type_info = new String[]{'Title','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] NameSuffix_type_info = new String[]{'NameSuffix','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] NameChangeReason_type_info = new String[]{'NameChangeReason','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] KnownAsName_type_info = new String[]{'KnownAsName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'FirstName','MiddleName','Surname','Title','NameSuffix','NameChangeReason','KnownAsName'};
    }
    public class ServiceNeed {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ServiceNeed;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 CategoryType;
        private String[] ServiceNeed_type_info = new String[]{'ServiceNeed','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] CategoryType_type_info = new String[]{'CategoryType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'ServiceNeed','CategoryType'};
    }
    public class FindCustomersByElementsResponseMessage {
        public britishgasCoUkEnterpriseParty.Customer[] CustomerData;
        public britishgasCoUkEnterpriseCommon.BG_Log Log;
        private String[] CustomerData_type_info = new String[]{'CustomerData','urn:britishgas.co.uk:Enterprise:Party','Customer','0','-1','false'};
        private String[] Log_type_info = new String[]{'Log','urn:britishgas.co.uk:Enterprise:Common','BG_Log','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'CustomerData','Log'};
    }
    public class PhoneNumber {
        public String AreaCode;
        public String Number_x;
        public String Extension;
        public String InternationalDiallingCode;
        public String ExDirectoryNumberIndicator;
        private String[] AreaCode_type_info = new String[]{'AreaCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Number_x_type_info = new String[]{'Number','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Extension_type_info = new String[]{'Extension','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] InternationalDiallingCode_type_info = new String[]{'InternationalDiallingCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ExDirectoryNumberIndicator_type_info = new String[]{'ExDirectoryNumberIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'AreaCode','Number_x','Extension','InternationalDiallingCode','ExDirectoryNumberIndicator'};
    }
    public class CustomerSearchCriteria {
        public String DateOfBirth;
        public String Surname;
        public String EmailAddress;
        public String PhoneNumber;
        private String[] DateOfBirth_type_info = new String[]{'DateOfBirth','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] Surname_type_info = new String[]{'Surname','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] EmailAddress_type_info = new String[]{'EmailAddress','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PhoneNumber_type_info = new String[]{'PhoneNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'DateOfBirth','Surname','EmailAddress','PhoneNumber'};
    }
    public class PartyClassification {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 CustomerType;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 CustomerSegment;
        public String InternalFraudIndicator;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 SuspectedFraudStatus;
        public String ExtraCareDetails;
        public String ExtraCareIndicator;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 MarketingConsentStatus;
        public String VipIndicator;
        public String CustomerValue;
        public String DebtRiskIndicator;
        public String NoInformationToThirdPartiesFlag;
        private String[] CustomerType_type_info = new String[]{'CustomerType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] CustomerSegment_type_info = new String[]{'CustomerSegment','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] InternalFraudIndicator_type_info = new String[]{'InternalFraudIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] SuspectedFraudStatus_type_info = new String[]{'SuspectedFraudStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ExtraCareDetails_type_info = new String[]{'ExtraCareDetails','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ExtraCareIndicator_type_info = new String[]{'ExtraCareIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] MarketingConsentStatus_type_info = new String[]{'MarketingConsentStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] VipIndicator_type_info = new String[]{'VipIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] CustomerValue_type_info = new String[]{'CustomerValue','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DebtRiskIndicator_type_info = new String[]{'DebtRiskIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] NoInformationToThirdPartiesFlag_type_info = new String[]{'NoInformationToThirdPartiesFlag','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'CustomerType','CustomerSegment','InternalFraudIndicator','SuspectedFraudStatus','ExtraCareDetails','ExtraCareIndicator','MarketingConsentStatus','VipIndicator','CustomerValue','DebtRiskIndicator','NoInformationToThirdPartiesFlag'};
    }
    public class CustomerMeterInformation {
        public String SmartMeterUsedIndicator;
        private String[] SmartMeterUsedIndicator_type_info = new String[]{'SmartMeterUsedIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'SmartMeterUsedIndicator'};
    }
    public class PartyEmailContactMethodBody {
        public String EmailAddress;
        public String ContactMethodType;
        public String ContactMethodLocation;
        public String DefaultIndicator;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ContactMethodStatus;
        public String ContactMethodStatusChangeDate;
        private String[] EmailAddress_type_info = new String[]{'EmailAddress','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ContactMethodType_type_info = new String[]{'ContactMethodType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ContactMethodLocation_type_info = new String[]{'ContactMethodLocation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DefaultIndicator_type_info = new String[]{'DefaultIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] ContactMethodStatus_type_info = new String[]{'ContactMethodStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ContactMethodStatusChangeDate_type_info = new String[]{'ContactMethodStatusChangeDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'EmailAddress','ContactMethodType','ContactMethodLocation','DefaultIndicator','ContactMethodStatus','ContactMethodStatusChangeDate'};
    }
    public class PartySecurity {
        public String PasswordReminderQuestion;
        public String Password;
        private String[] PasswordReminderQuestion_type_info = new String[]{'PasswordReminderQuestion','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'PasswordReminderQuestion','Password'};
    }
    public class Binding_x1QueryCustomerBinding {
        
        //public String endpoint_x = System.Label.CHIPH_QueryCustomer_Endpoint + SERVICEENDPOINT;
        public String endpoint_x = System.Label.CHIPH_QueryCustomer_Endpoint;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x; 
        private String[] ns_map_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Campaign', 'britishgasCoUkEnterpriseCampaignQC', 'urn:britishgas.co.uk:Enterprise:Party', 'britishgasCoUkEnterpriseParty', 'urn:britishgas.co.uk:Enterprise:CustomerAccount', 'britishgasCoUkEnterpriseCustomeracco', 'urn:britishgas.co.uk:Enterprise:Common', 'britishgasCoUkEnterpriseCommon', 'urn:britishgas.co.uk:Enterprise:Product', 'britishgasCoUkEnterpriseProduct', 'urn:britishgas.co.uk:Enterprise:Employee', 'britishgasCoUkEnterpriseEmployeeQC', 'urn:britishgas.co.uk:Enterprise:CreditRating', 'britishgasCoUkEnterpriseCreditratingQC', 'urn:britishgas.co.uk:Enterprise:Sales', 'britishgasCoUkEnterpriseSalesQC', 'urn:britishgas.co.uk:Enterprise:Address', 'britishgasCoUkEnterpriseAddress'};
        public britishgasCoUkEnterpriseParty.FindCustomersByAccountIDResponseMessage FindCustomersByAccountID(britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey AccountID,String ServiceConsumer) {
            britishgasCoUkEnterpriseParty.FindCustomersByAccountIDQueryMessage request_x = new britishgasCoUkEnterpriseParty.FindCustomersByAccountIDQueryMessage();
            britishgasCoUkEnterpriseParty.FindCustomersByAccountIDResponseMessage response_x;
            request_x.AccountID = AccountID;
            request_x.ServiceConsumer = ServiceConsumer;
            Map<String, britishgasCoUkEnterpriseParty.FindCustomersByAccountIDResponseMessage> response_map_x = new Map<String, britishgasCoUkEnterpriseParty.FindCustomersByAccountIDResponseMessage>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://sap.com/xi/WebService/soap1.1',
              'urn:britishgas.co.uk:Enterprise:Party',
              'FindCustomersByAccountIDQuery',
              'urn:britishgas.co.uk:Enterprise:Party',
              'FindCustomersByAccountIDResponse',
              'britishgasCoUkEnterpriseParty.FindCustomersByAccountIDResponseMessage'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsResponseMessage FindCustomersByAddressElements(britishgasCoUkEnterpriseAddress.AddressSearchCriteria AddressSearch,String ServiceConsumer,britishgasCoUkEnterpriseCommon.BG_ProcessingConditions ProcessingConditions) {
            britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsQueryMessage request_x = new britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsQueryMessage();
            britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsResponseMessage response_x;
            request_x.AddressSearch = AddressSearch;
            request_x.ServiceConsumer = ServiceConsumer;
            request_x.ProcessingConditions = ProcessingConditions;
            Map<String, britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsResponseMessage> response_map_x = new Map<String, britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsResponseMessage>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://sap.com/xi/WebService/soap1.1',
              'urn:britishgas.co.uk:Enterprise:Party',
              'FindCustomersByAddressElementsQuery',
              'urn:britishgas.co.uk:Enterprise:Party',
              'FindCustomersByAddressElementsResponse',
              'britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsResponseMessage'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public britishgasCoUkEnterpriseParty.FindCustomersByElementsResponseMessage FindCustomersByElements(britishgasCoUkEnterpriseParty.CustomerSearchCriteria CustomerSearch,britishgasCoUkEnterpriseCommon.BG_ProcessingConditions ProcessingConditions,String ServiceConsumer) {
            britishgasCoUkEnterpriseParty.FindCustomersByElementsQueryMessage request_x = new britishgasCoUkEnterpriseParty.FindCustomersByElementsQueryMessage();
            britishgasCoUkEnterpriseParty.FindCustomersByElementsResponseMessage response_x;
            request_x.CustomerSearch = CustomerSearch;
            request_x.ProcessingConditions = ProcessingConditions;
            request_x.ServiceConsumer = ServiceConsumer;
            Map<String, britishgasCoUkEnterpriseParty.FindCustomersByElementsResponseMessage> response_map_x = new Map<String, britishgasCoUkEnterpriseParty.FindCustomersByElementsResponseMessage>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://sap.com/xi/WebService/soap1.1',
              'urn:britishgas.co.uk:Enterprise:Party',
              'FindCustomersByElementsQuery',
              'urn:britishgas.co.uk:Enterprise:Party',
              'FindCustomersByElementsResponse',
              'britishgasCoUkEnterpriseParty.FindCustomersByElementsResponseMessage'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
    public class PersonSensitivityType {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60_V2 SensitivityType;
        private String[] SensitivityType_type_info = new String[]{'SensitivityType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60_V2','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'SensitivityType'};
    }
    public class FindCustomersByAccountIDResponseMessage {
        public britishgasCoUkEnterpriseParty.Customer[] Customer;
        public britishgasCoUkEnterpriseCommon.BG_Log Log;
        private String[] Customer_type_info = new String[]{'Customer','urn:britishgas.co.uk:Enterprise:Party','Customer','0','-1','false'};
        private String[] Log_type_info = new String[]{'Log','urn:britishgas.co.uk:Enterprise:Common','BG_Log','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'Customer','Log'};
    }
    public class FindCustomersByElementsQueryMessage {
        public britishgasCoUkEnterpriseParty.CustomerSearchCriteria CustomerSearch;
        public britishgasCoUkEnterpriseCommon.BG_ProcessingConditions ProcessingConditions;
        public String ServiceConsumer;
        private String[] CustomerSearch_type_info = new String[]{'CustomerSearch','urn:britishgas.co.uk:Enterprise:Party','CustomerSearchCriteria','0','1','false'};
        private String[] ProcessingConditions_type_info = new String[]{'ProcessingConditions','urn:britishgas.co.uk:Enterprise:Common','BG_ProcessingConditions','0','1','false'};
        private String[] ServiceConsumer_type_info = new String[]{'ServiceConsumer','urn:britishgas.co.uk:Enterprise:Common','BG_ServiceConsumer','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'CustomerSearch','ProcessingConditions','ServiceConsumer'};
    }
    public class PartyCommunicationPreferences {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ConsentToSendMarketingByEmail;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ConsentToSendMarketingBySms;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ConsentToSendServicesBySms;
        public String NotOnPhoneIndicator;
        public String RefusedPhoneNumber;
        public String RefusedPhoneNumberDate;
        public String OnLineUserIndicator;
        public String OnlineUserName;
        public String OnlinePassword;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 PreferredContactMethod;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 PreferredCommunicationFormat;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 PreferredLanguage;
        private String[] ConsentToSendMarketingByEmail_type_info = new String[]{'ConsentToSendMarketingByEmail','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ConsentToSendMarketingBySms_type_info = new String[]{'ConsentToSendMarketingBySms','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ConsentToSendServicesBySms_type_info = new String[]{'ConsentToSendServicesBySms','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] NotOnPhoneIndicator_type_info = new String[]{'NotOnPhoneIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] RefusedPhoneNumber_type_info = new String[]{'RefusedPhoneNumber','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] RefusedPhoneNumberDate_type_info = new String[]{'RefusedPhoneNumberDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] OnLineUserIndicator_type_info = new String[]{'OnLineUserIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] OnlineUserName_type_info = new String[]{'OnlineUserName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] OnlinePassword_type_info = new String[]{'OnlinePassword','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PreferredContactMethod_type_info = new String[]{'PreferredContactMethod','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] PreferredCommunicationFormat_type_info = new String[]{'PreferredCommunicationFormat','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] PreferredLanguage_type_info = new String[]{'PreferredLanguage','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'ConsentToSendMarketingByEmail','ConsentToSendMarketingBySms','ConsentToSendServicesBySms','NotOnPhoneIndicator','RefusedPhoneNumber','RefusedPhoneNumberDate','OnLineUserIndicator','OnlineUserName','OnlinePassword','PreferredContactMethod','PreferredCommunicationFormat','PreferredLanguage'};
    }
    public class FindCustomersByAddressElementsQueryMessage {
        public britishgasCoUkEnterpriseAddress.AddressSearchCriteria AddressSearch;
        public String ServiceConsumer;
        public britishgasCoUkEnterpriseCommon.BG_ProcessingConditions ProcessingConditions;
        private String[] AddressSearch_type_info = new String[]{'AddressSearch','urn:britishgas.co.uk:Enterprise:Address','AddressSearchCriteria','0','1','false'};
        private String[] ServiceConsumer_type_info = new String[]{'ServiceConsumer','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ProcessingConditions_type_info = new String[]{'ProcessingConditions','urn:britishgas.co.uk:Enterprise:Common','BG_ProcessingConditions','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'AddressSearch','ServiceConsumer','ProcessingConditions'};
    }
    public class PartyPhoneContactMethodBody {
        public String ContactMethodType;
        public String ContactMethodLocation;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 PreferredContactTimeSlot;
        public String PreferredNumberIndicator;
        public String ContactMethodStatusChangeDate;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 ContactMethodStatus;
        public britishgasCoUkEnterpriseParty.PhoneNumber PhoneNumber;
        private String[] ContactMethodType_type_info = new String[]{'ContactMethodType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ContactMethodLocation_type_info = new String[]{'ContactMethodLocation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PreferredContactTimeSlot_type_info = new String[]{'PreferredContactTimeSlot','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] PreferredNumberIndicator_type_info = new String[]{'PreferredNumberIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] ContactMethodStatusChangeDate_type_info = new String[]{'ContactMethodStatusChangeDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] ContactMethodStatus_type_info = new String[]{'ContactMethodStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] PhoneNumber_type_info = new String[]{'PhoneNumber','urn:britishgas.co.uk:Enterprise:Party','PhoneNumber','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'ContactMethodType','ContactMethodLocation','PreferredContactTimeSlot','PreferredNumberIndicator','ContactMethodStatusChangeDate','ContactMethodStatus','PhoneNumber'};
    }
    public class FindCustomersByAddressElementsResponseMessage {
        public britishgasCoUkEnterpriseParty.Customer[] CustomerData;
        public britishgasCoUkEnterpriseCommon.BG_Log Log;
        private String[] CustomerData_type_info = new String[]{'CustomerData','urn:britishgas.co.uk:Enterprise:Party','Customer','0','-1','false'};
        private String[] Log_type_info = new String[]{'Log','urn:britishgas.co.uk:Enterprise:Common','BG_Log','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'CustomerData','Log'};
    }
    public class PersonBiographicData {
        public britishgasCoUkEnterpriseParty.PersonName PersonName;
        public String DateOfBirth;
        public String DateOfDeath;
        public Boolean DeceasedIndicator;
        public String Gender;
        public String MaidenName;
        public britishgasCoUkEnterpriseParty.PersonName[] PreviousNames;
        public String PartySalutation;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 MaritalStatus;
        private String[] PersonName_type_info = new String[]{'PersonName','urn:britishgas.co.uk:Enterprise:Party','PersonName','0','1','false'};
        private String[] DateOfBirth_type_info = new String[]{'DateOfBirth','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] DateOfDeath_type_info = new String[]{'DateOfDeath','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] DeceasedIndicator_type_info = new String[]{'DeceasedIndicator','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] Gender_type_info = new String[]{'Gender','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] MaidenName_type_info = new String[]{'MaidenName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PreviousNames_type_info = new String[]{'PreviousNames','urn:britishgas.co.uk:Enterprise:Party','PersonName','0','-1','false'};
        private String[] PartySalutation_type_info = new String[]{'PartySalutation','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] MaritalStatus_type_info = new String[]{'MaritalStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'PersonName','DateOfBirth','DateOfDeath','DeceasedIndicator','Gender','MaidenName','PreviousNames','PartySalutation','MaritalStatus'};
    }
    public class PersonVIPDetails {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 VIPType;
        public String VIPIndicator;
        private String[] VIPType_type_info = new String[]{'VIPType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] VIPIndicator_type_info = new String[]{'VIPIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'VIPType','VIPIndicator'};
    }
    public class CRM {
        public Integer NumberOfOpenProcesses;
        public Integer NumberOfOpenComplaints;
        public britishgasCoUkEnterpriseParty.PartyClassification Classification;
        public britishgasCoUkEnterpriseParty.PartyCommunicationPreferences CommunicationPreferences;
        public britishgasCoUkEnterpriseParty.PartyPhoneContactMethodBody[] Phone;
        public britishgasCoUkEnterpriseParty.PartyEmailContactMethodBody[] Email;
        private String[] NumberOfOpenProcesses_type_info = new String[]{'NumberOfOpenProcesses','http://www.w3.org/2001/XMLSchema','integer','0','1','false'};
        private String[] NumberOfOpenComplaints_type_info = new String[]{'NumberOfOpenComplaints','http://www.w3.org/2001/XMLSchema','integer','0','1','false'};
        private String[] Classification_type_info = new String[]{'Classification','urn:britishgas.co.uk:Enterprise:Party','PartyClassification','0','1','false'};
        private String[] CommunicationPreferences_type_info = new String[]{'CommunicationPreferences','urn:britishgas.co.uk:Enterprise:Party','PartyCommunicationPreferences','0','1','false'};
        private String[] Phone_type_info = new String[]{'Phone','urn:britishgas.co.uk:Enterprise:Party','PartyPhoneContactMethodBody','0','-1','false'};
        private String[] Email_type_info = new String[]{'Email','urn:britishgas.co.uk:Enterprise:Party','PartyEmailContactMethodBody','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Party','false','false'};
        private String[] field_order_type_info = new String[]{'NumberOfOpenProcesses','NumberOfOpenComplaints','Classification','CommunicationPreferences','Phone','Email'};
    }
}