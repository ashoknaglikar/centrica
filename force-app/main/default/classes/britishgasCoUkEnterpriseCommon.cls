public class britishgasCoUkEnterpriseCommon 
{
	public class BG_Log { 
        public String BusinessDocumentProcessingResultCode;
        public String MaximumLogItemSeverityCode;
        public britishgasCoUkEnterpriseCommon.BG_LogItem[] Item;
        private String[] BusinessDocumentProcessingResultCode_type_info = new String[]{'BusinessDocumentProcessingResultCode','urn:britishgas.co.uk:Enterprise:Common','BG_ProcessingResultCode','0','1','false'};
        private String[] MaximumLogItemSeverityCode_type_info = new String[]{'MaximumLogItemSeverityCode','urn:britishgas.co.uk:Enterprise:Common','BG_LogItemSeverityCode','0','1','false'};
        private String[] Item_type_info = new String[]{'Item','urn:britishgas.co.uk:Enterprise:Common','BG_LogItem','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'BusinessDocumentProcessingResultCode','MaximumLogItemSeverityCode','Item'};
    }
    public class BG_LogItem {
        public String TypeID;
        public String CategoryCode;
        public String SeverityCode;
        public String Note;
        public String WebURI;
        private String[] TypeID_type_info = new String[]{'TypeID','urn:britishgas.co.uk:Enterprise:Common','BG_LogItemTypeID','0','1','false'};
        private String[] CategoryCode_type_info = new String[]{'CategoryCode','urn:britishgas.co.uk:Enterprise:Common','BG_LogItemCategoryCode','0','1','false'};
        private String[] SeverityCode_type_info = new String[]{'SeverityCode','urn:britishgas.co.uk:Enterprise:Common','BG_LogItemSeverityCode','0','1','false'};
        private String[] Note_type_info = new String[]{'Note','urn:britishgas.co.uk:Enterprise:Common','BG_LogItemNote','1','1','false'};
        private String[] WebURI_type_info = new String[]{'WebURI','urn:britishgas.co.uk:Enterprise:Common','BG_WebURI','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'TypeID','CategoryCode','SeverityCode','Note','WebURI'};
    }
    public class BG_StandardMessageFault_element {
        public britishgasCoUkEnterpriseCommon.ExchangeFaultData standard;
        private String[] standard_type_info = new String[]{'standard','urn:britishgas.co.uk:Enterprise:Common','ExchangeFaultData','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'standard'};
    }
    public class BG_Quantity {
        public String Unit;
        private String[] Unit_att_info = new String[]{'Unit'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class BG_Identifier_Unlimited {
        public String schemeID;
        public String schemeAgencyID;
        private String[] schemeID_att_info = new String[]{'schemeID'};
        private String[] schemeAgencyID_att_info = new String[]{'schemeAgencyID'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class BG_Code_Desc60 {
        public String Code;
        //public britishgasCoUkEnterpriseCommon.BG_LEN60_Description Description;
        public String Description;
        private String[] Code_type_info = new String[]{'Code','urn:britishgas.co.uk:Enterprise:Common','BG_CommonCodeFormat','1','1','false'};
        private String[] Description_type_info = new String[]{'Description','urn:britishgas.co.uk:Enterprise:Common','BG_LEN60_Description','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'Code','Description'};
    }
    public class BG_Identifier {
        public String schemeID;
        public String schemeAgencyID;
        private String[] schemeID_att_info = new String[]{'schemeID'};
        private String[] schemeAgencyID_att_info = new String[]{'schemeAgencyID'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class ExchangeLogData {
        public String severity;
        public String text;
        public String url;
        public String id;
        private String[] severity_type_info = new String[]{'severity','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] text_type_info = new String[]{'text','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] url_type_info = new String[]{'url','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] id_type_info = new String[]{'id','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'severity','text','url','id'};
    }
    public class BG_LEN60_Description {
        public String languageCode;
        private String[] languageCode_att_info = new String[]{'languageCode'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class ExchangeFaultData {
        public String faultText;
        public String faultUrl;
        public britishgasCoUkEnterpriseCommon.ExchangeLogData[] faultDetail;
        private String[] faultText_type_info = new String[]{'faultText','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] faultUrl_type_info = new String[]{'faultUrl','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] faultDetail_type_info = new String[]{'faultDetail','urn:britishgas.co.uk:Enterprise:Common','ExchangeLogData','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'faultText','faultUrl','faultDetail'};
    }
    public class BG_CurrencyAmount {
        public String CurrencyType;
        public String Amount;
        private String[] CurrencyType_type_info = new String[]{'CurrencyType','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] Amount_type_info = new String[]{'Amount','urn:britishgas.co.uk:Enterprise:Common','BG_Amount','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'CurrencyType','Amount'};
    }
    public class BG_Code_Desc60_V2 {
        public String Code;
        public britishgasCoUkEnterpriseCommon.BG_LEN60_Description Description;
        private String[] Code_type_info = new String[]{'Code','urn:britishgas.co.uk:Enterprise:Common','BG_CommonCodeFormat_V2','1','1','false'};
        private String[] Description_type_info = new String[]{'Description','urn:britishgas.co.uk:Enterprise:Common','BG_LEN60_Description','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'Code','Description'};
    }
    public class BG_MessageHeader {
        public String ServiceConsumer;
        public String Version;
        private String[] ServiceConsumer_type_info = new String[]{'ServiceConsumer','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Version_type_info = new String[]{'Version','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'ServiceConsumer','Version'};
    }
    public class BG_ProcessingConditions {
        public Integer QueryHitsMaximumNumberValue;
        public String UnlimitedQueryHitsIndicator;
        private String[] QueryHitsMaximumNumberValue_type_info = new String[]{'QueryHitsMaximumNumberValue','http://www.w3.org/2001/XMLSchema','integer','0','1','false'};
        private String[] UnlimitedQueryHitsIndicator_type_info = new String[]{'UnlimitedQueryHitsIndicator','urn:britishgas.co.uk:Enterprise:Common','BG_Indicator','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'QueryHitsMaximumNumberValue','UnlimitedQueryHitsIndicator'};
    }
    public class BG_StartEndDate {
        public String StartDate;
        public String EndDate;
        private String[] StartDate_type_info = new String[]{'StartDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','1','1','false'};
        private String[] EndDate_type_info = new String[]{'EndDate','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'StartDate','EndDate'};
    }
    public class BG_CurrencyAmountItem {
        public String CurrencyType;
        public String Amount;
        public britishgasCoUkEnterpriseCommon.BG_Description Description;
        private String[] CurrencyType_type_info = new String[]{'CurrencyType','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] Amount_type_info = new String[]{'Amount','urn:britishgas.co.uk:Enterprise:Common','BG_Amount','1','1','false'};
        private String[] Description_type_info = new String[]{'Description','urn:britishgas.co.uk:Enterprise:Common','BG_Description','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'CurrencyType','Amount','Description'};
    }
    public class BG_Description {
        public String languageCode;
        private String[] languageCode_att_info = new String[]{'languageCode'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{};
    }
 	public class BG_Code_Desc150 {
        public String Code;
        public britishgasCoUkEnterpriseCommon.BG_Description Description;
        private String[] Code_type_info = new String[]{'Code','urn:britishgas.co.uk:Enterprise:Common','BG_CommonCodeFormat','1','1','false'};
        private String[] Description_type_info = new String[]{'Description','urn:britishgas.co.uk:Enterprise:Common','BG_Description','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Common','false','false'};
        private String[] field_order_type_info = new String[]{'Code','Description'};
    }   
}