public class britishgasCoUkEnterpriseAddress {
	public class BasicAddress {
        public String Postcode;
        public String DependentLocality;
        public String OrganisationName;
        public String DepartmentName;
        public String SubBuildingName;
        public String BuildingName;
        public String ThoroughfareOrStreet;
        public String DoubleDependentLocality;
        public String PostalTownOrCity;
        public String POBoxNumber;
        public String DependentThoroughfare;
        public String BuildingNumberSecondary;
        public String BuildingNumber;
        public String BuildingNumberPrimary;
        public String County;
        public String Country;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 CountryCodeDesc;
        public String BfpoNumber;
        public String ForeignAddressFlag;
        public String BfpoAddressFlag;
        public String PlotNumber;
        public String DeliveryPointSuffix;
        public String Floor;
        public String RoomNumber;
        private String[] Postcode_type_info = new String[]{'Postcode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DependentLocality_type_info = new String[]{'DependentLocality','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] OrganisationName_type_info = new String[]{'OrganisationName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DepartmentName_type_info = new String[]{'DepartmentName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] SubBuildingName_type_info = new String[]{'SubBuildingName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] BuildingName_type_info = new String[]{'BuildingName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ThoroughfareOrStreet_type_info = new String[]{'ThoroughfareOrStreet','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DoubleDependentLocality_type_info = new String[]{'DoubleDependentLocality','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PostalTownOrCity_type_info = new String[]{'PostalTownOrCity','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] POBoxNumber_type_info = new String[]{'POBoxNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DependentThoroughfare_type_info = new String[]{'DependentThoroughfare','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] BuildingNumberSecondary_type_info = new String[]{'BuildingNumberSecondary','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] BuildingNumber_type_info = new String[]{'BuildingNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] BuildingNumberPrimary_type_info = new String[]{'BuildingNumberPrimary','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] County_type_info = new String[]{'County','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Country_type_info = new String[]{'Country','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] CountryCodeDesc_type_info = new String[]{'CountryCodeDesc','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] BfpoNumber_type_info = new String[]{'BfpoNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ForeignAddressFlag_type_info = new String[]{'ForeignAddressFlag','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] BfpoAddressFlag_type_info = new String[]{'BfpoAddressFlag','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] PlotNumber_type_info = new String[]{'PlotNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DeliveryPointSuffix_type_info = new String[]{'DeliveryPointSuffix','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Floor_type_info = new String[]{'Floor','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] RoomNumber_type_info = new String[]{'RoomNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'Postcode','DependentLocality','OrganisationName','DepartmentName','SubBuildingName','BuildingName','ThoroughfareOrStreet','DoubleDependentLocality','PostalTownOrCity','POBoxNumber','DependentThoroughfare','BuildingNumberSecondary','BuildingNumber','BuildingNumberPrimary','County','Country','CountryCodeDesc','BfpoNumber','ForeignAddressFlag','BfpoAddressFlag','PlotNumber','DeliveryPointSuffix','Floor','RoomNumber'};
    }
    public class FindAddressesByElementsResponseMessage {
        public britishgasCoUkEnterpriseAddress.BasicAddressDetail[] AddressForAddressQueryResponse;
        public britishgasCoUkEnterpriseCommon.BG_Log Log;
        private String[] AddressForAddressQueryResponse_type_info = new String[]{'AddressForAddressQueryResponse','urn:britishgas.co.uk:Enterprise:Address','BasicAddressDetail','0','-1','false'};
        private String[] Log_type_info = new String[]{'Log','urn:britishgas.co.uk:Enterprise:Common','BG_Log','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'AddressForAddressQueryResponse','Log'};
    }
    public class Binding_x1QueryAddressBinding {
        public String endpoint_x = System.Label.CHIPH_QueryCustomer_Endpoint;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x; 
        private String[] ns_map_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CustomerAccount', 'britishgasCoUkEnterpriseCustomeracco', 'urn:britishgas.co.uk:Enterprise:Common', 'britishgasCoUkEnterpriseCommon', 'urn:britishgas.co.uk:Enterprise:Address', 'britishgasCoUkEnterpriseAddress'};
        public britishgasCoUkEnterpriseAddress.FindAddressesByElementsResponseMessage FindAddressesByElements(britishgasCoUkEnterpriseAddress.AddressSearchCriteria AddressSearchCriteria,britishgasCoUkEnterpriseCommon.BG_ProcessingConditions ProcessingConditions,String SearchType) {
            britishgasCoUkEnterpriseAddress.FindAddressesByElementsQueryMessage request_x = new britishgasCoUkEnterpriseAddress.FindAddressesByElementsQueryMessage();
            britishgasCoUkEnterpriseAddress.FindAddressesByElementsResponseMessage response_x;
            request_x.AddressSearchCriteria = AddressSearchCriteria;
            request_x.ProcessingConditions = ProcessingConditions;
            request_x.SearchType = SearchType;
            Map<String, britishgasCoUkEnterpriseAddress.FindAddressesByElementsResponseMessage> response_map_x = new Map<String, britishgasCoUkEnterpriseAddress.FindAddressesByElementsResponseMessage>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x, 
              'http://sap.com/xi/WebService/soap1.1',
              'urn:britishgas.co.uk:Enterprise:Address',
              'FindAddressesByElementsQuery',
              'urn:britishgas.co.uk:Enterprise:Address', 
              'FindAddressesByElementsResponse',
              'britishgasCoUkEnterpriseAddress.FindAddressesByElementsResponseMessage'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        } 
        public britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDResponseMessage FindAddressesByAccountID(britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey AccountId,britishgasCoUkEnterpriseCommon.BG_StartEndDate LimitFromTo,britishgasCoUkEnterpriseCommon.BG_ProcessingConditions ProcessingConditions) {
            britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDQueryMessage request_x = new britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDQueryMessage();
            britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDResponseMessage response_x;
            request_x.AccountId = AccountId;
            request_x.LimitFromTo = LimitFromTo;
            request_x.ProcessingConditions = ProcessingConditions;
            Map<String, britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDResponseMessage> response_map_x = new Map<String, britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDResponseMessage>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://sap.com/xi/WebService/soap1.1',
              'urn:britishgas.co.uk:Enterprise:Address',
              'FindAddressesByAccountIDQuery',
              'urn:britishgas.co.uk:Enterprise:Address',
              'FindAddressesByAcountIDResponse',
              'britishgasCoUkEnterpriseAddress.FindAddressesByAccountIDResponseMessage'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
    public class FindAddressesByAccountIDQueryMessage {
        public britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey AccountId;
        public britishgasCoUkEnterpriseCommon.BG_StartEndDate LimitFromTo;
        public britishgasCoUkEnterpriseCommon.BG_ProcessingConditions ProcessingConditions;
        private String[] AccountId_type_info = new String[]{'AccountId','urn:britishgas.co.uk:Enterprise:CustomerAccount','CustomerAccountKey','1','1','false'};
        private String[] LimitFromTo_type_info = new String[]{'LimitFromTo','urn:britishgas.co.uk:Enterprise:Common','BG_StartEndDate','0','1','false'};
        private String[] ProcessingConditions_type_info = new String[]{'ProcessingConditions','urn:britishgas.co.uk:Enterprise:Common','BG_ProcessingConditions','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'AccountId','LimitFromTo','ProcessingConditions'};
    }
    public class BasicAddressDetail { 
        public britishgasCoUkEnterpriseAddress.AddressKey Key;
        public britishgasCoUkEnterpriseAddress.BasicAddress BasicAddress;
        public britishgasCoUkEnterpriseCommon.BG_StartEndDate StartEndDate;
        public britishgasCoUkEnterpriseAddress.AddressForeignKeys ForeignKeys;
        public String PAFValidIndicator;
        public String SingleLineAddress;
        public String[] FormattedAddress;
        public String ExactMatchFlag;
        private String[] Key_type_info = new String[]{'Key','urn:britishgas.co.uk:Enterprise:Address','AddressKey','1','1','false'};
        private String[] BasicAddress_type_info = new String[]{'BasicAddress','urn:britishgas.co.uk:Enterprise:Address','BasicAddress','1','1','false'};
        private String[] StartEndDate_type_info = new String[]{'StartEndDate','urn:britishgas.co.uk:Enterprise:Common','BG_StartEndDate','0','1','false'};
        private String[] ForeignKeys_type_info = new String[]{'ForeignKeys','urn:britishgas.co.uk:Enterprise:Address','AddressForeignKeys','0','1','false'};
        private String[] PAFValidIndicator_type_info = new String[]{'PAFValidIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] SingleLineAddress_type_info = new String[]{'SingleLineAddress','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] FormattedAddress_type_info = new String[]{'FormattedAddress','http://www.w3.org/2001/XMLSchema','string','0','-1','false'};
        private String[] ExactMatchFlag_type_info = new String[]{'ExactMatchFlag','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'Key','BasicAddress','StartEndDate','ForeignKeys','PAFValidIndicator','SingleLineAddress','FormattedAddress','ExactMatchFlag'};
    }
    public class AddressSearchCriteria {
        public String POBoxNumber;
        public String SubBuildingName;
        public String BuildingName;
        public String BuildingNumber;
        public String DependentThoroughfare;
        public String ThoroughfareOrStreet;
        public String DoubleDependentLocality;
        public String DependentLocality;
        public String PostalTownOrCity;
        public String County;
        public String Postcode;
        public String Country;
        private String[] POBoxNumber_type_info = new String[]{'POBoxNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] SubBuildingName_type_info = new String[]{'SubBuildingName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] BuildingName_type_info = new String[]{'BuildingName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] BuildingNumber_type_info = new String[]{'BuildingNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DependentThoroughfare_type_info = new String[]{'DependentThoroughfare','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ThoroughfareOrStreet_type_info = new String[]{'ThoroughfareOrStreet','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DoubleDependentLocality_type_info = new String[]{'DoubleDependentLocality','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DependentLocality_type_info = new String[]{'DependentLocality','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PostalTownOrCity_type_info = new String[]{'PostalTownOrCity','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] County_type_info = new String[]{'County','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Postcode_type_info = new String[]{'Postcode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Country_type_info = new String[]{'Country','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'POBoxNumber','SubBuildingName','BuildingName','BuildingNumber','DependentThoroughfare','ThoroughfareOrStreet','DoubleDependentLocality','DependentLocality','PostalTownOrCity','County','Postcode','Country'};
    }
    public class AddressForeignKeys {
        public britishgasCoUkEnterpriseCommon.BG_Identifier ExternalAddressIdentifier;
        private String[] ExternalAddressIdentifier_type_info = new String[]{'ExternalAddressIdentifier','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'ExternalAddressIdentifier'};
    }
    public class AddressKey {
        //public britishgasCoUkEnterpriseCommon.BG_Identifier_Unlimited AddressId;
        public String AddressId;
        private String[] AddressId_type_info = new String[]{'AddressId','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier_Unlimited','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'AddressId'};
    }
    public class FindAddressesByAccountIDResponseMessage {
        public britishgasCoUkEnterpriseAddress.BasicAddressDetail[] AddressForAddressQueryResponse;
        public britishgasCoUkEnterpriseCommon.BG_Log Log;
        private String[] AddressForAddressQueryResponse_type_info = new String[]{'AddressForAddressQueryResponse','urn:britishgas.co.uk:Enterprise:Address','BasicAddressDetail','0','-1','false'};
        private String[] Log_type_info = new String[]{'Log','urn:britishgas.co.uk:Enterprise:Common','BG_Log','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'AddressForAddressQueryResponse','Log'};
    }
    public class FindAddressesByElementsQueryMessage {
        public britishgasCoUkEnterpriseAddress.AddressSearchCriteria AddressSearchCriteria;
        public britishgasCoUkEnterpriseCommon.BG_ProcessingConditions ProcessingConditions;
        public String SearchType;
        private String[] AddressSearchCriteria_type_info = new String[]{'AddressSearchCriteria','urn:britishgas.co.uk:Enterprise:Address','AddressSearchCriteria','1','1','false'};
        private String[] ProcessingConditions_type_info = new String[]{'ProcessingConditions','urn:britishgas.co.uk:Enterprise:Common','BG_ProcessingConditions','1','1','false'};
        private String[] SearchType_type_info = new String[]{'SearchType','urn:britishgas.co.uk:Enterprise:Common','BG_SearchType','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'AddressSearchCriteria','ProcessingConditions','SearchType'};
    }
    public class AddressBody {
        public String PropertyType;
        public String AdditionalAddressText;
        public String GeographicAreaType;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 PafDeliveryPointType;
        public britishgasCoUkEnterpriseCommon.BG_Identifier PafAddressKey;
        public britishgasCoUkEnterpriseCommon.BG_Identifier PafOrganisationKey;
        public britishgasCoUkEnterpriseAddress.AddressCoordinates AddressCoordinates;
        public britishgasCoUkEnterpriseAddress.BasicAddress BasicAddress;
        public britishgasCoUkEnterpriseAddress.AddressValidity AddressValidity;
        private String[] PropertyType_type_info = new String[]{'PropertyType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] AdditionalAddressText_type_info = new String[]{'AdditionalAddressText','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] GeographicAreaType_type_info = new String[]{'GeographicAreaType','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] PafDeliveryPointType_type_info = new String[]{'PafDeliveryPointType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] PafAddressKey_type_info = new String[]{'PafAddressKey','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','0','1','false'};
        private String[] PafOrganisationKey_type_info = new String[]{'PafOrganisationKey','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','0','1','false'};
        private String[] AddressCoordinates_type_info = new String[]{'AddressCoordinates','urn:britishgas.co.uk:Enterprise:Address','AddressCoordinates','1','1','false'};
        private String[] BasicAddress_type_info = new String[]{'BasicAddress','urn:britishgas.co.uk:Enterprise:Address','BasicAddress','1','1','false'};
        private String[] AddressValidity_type_info = new String[]{'AddressValidity','urn:britishgas.co.uk:Enterprise:Address','AddressValidity','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'PropertyType','AdditionalAddressText','GeographicAreaType','PafDeliveryPointType','PafAddressKey','PafOrganisationKey','AddressCoordinates','BasicAddress','AddressValidity'};
    }
    public class AddressValidity {
        public String PafValidFlag;
        private String[] PafValidFlag_type_info = new String[]{'PafValidFlag','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'PafValidFlag'};
    }
    public class AddressCoordinates { 
        public String GridCoordinateY;
        public String GridCoordinateX;
        public String GridCoordinateZ;
        private String[] GridCoordinateY_type_info = new String[]{'GridCoordinateY','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] GridCoordinateX_type_info = new String[]{'GridCoordinateX','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] GridCoordinateZ_type_info = new String[]{'GridCoordinateZ','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'GridCoordinateY','GridCoordinateX','GridCoordinateZ'};
    }
    public class AddressUsage {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 AddressType;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 AddressUsageStatus;
        public String CareOfName;
        public String DefaultAddressIndicator;
        public britishgasCoUkEnterpriseAddress.BasicAddressDetail Address;
        private String[] AddressType_type_info = new String[]{'AddressType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] AddressUsageStatus_type_info = new String[]{'AddressUsageStatus','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] CareOfName_type_info = new String[]{'CareOfName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DefaultAddressIndicator_type_info = new String[]{'DefaultAddressIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] Address_type_info = new String[]{'Address','urn:britishgas.co.uk:Enterprise:Address','BasicAddressDetail','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Address','false','false'};
        private String[] field_order_type_info = new String[]{'AddressType','AddressUsageStatus','CareOfName','DefaultAddressIndicator','Address'};
    }
}