//Generated by wsdl2apex

public class britishgasCoUkEnterpriseCreditratingQC {
    public class CreditRatingEventBody {
        public String Date_x;
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 InternalCreditRatingCode;
        public britishgasCoUkEnterpriseCommon.BG_StartEndDate ValidityStartEndDate;
        public Integer CreditRatingAgencyScore;
        private String[] Date_x_type_info = new String[]{'Date','urn:britishgas.co.uk:Enterprise:Common','BG_Date','0','1','false'};
        private String[] InternalCreditRatingCode_type_info = new String[]{'InternalCreditRatingCode','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] ValidityStartEndDate_type_info = new String[]{'ValidityStartEndDate','urn:britishgas.co.uk:Enterprise:Common','BG_StartEndDate','0','1','false'};
        private String[] CreditRatingAgencyScore_type_info = new String[]{'CreditRatingAgencyScore','http://www.w3.org/2001/XMLSchema','integer','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:CreditRating','false','false'};
        private String[] field_order_type_info = new String[]{'Date_x','InternalCreditRatingCode','ValidityStartEndDate','CreditRatingAgencyScore'};
    }
}