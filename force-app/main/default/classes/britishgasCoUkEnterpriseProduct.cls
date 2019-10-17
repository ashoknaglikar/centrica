public class britishgasCoUkEnterpriseProduct {
	public class ProductKey {
        public britishgasCoUkEnterpriseCommon.BG_Identifier ProductIdentifier;
        private String[] ProductIdentifier_type_info = new String[]{'ProductIdentifier','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Product','false','false'};
        private String[] field_order_type_info = new String[]{'ProductIdentifier'};
    }
	public class EnergyTypeKey {
        public britishgasCoUkEnterpriseCommon.BG_Identifier Key;
        private String[] Key_type_info = new String[]{'Key','urn:britishgas.co.uk:Enterprise:Common','BG_Identifier','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Product','false','false'};
        private String[] field_order_type_info = new String[]{'Key'};
    }
    public class EnergyTypeBody {
        public britishgasCoUkEnterpriseCommon.BG_Code_Desc60 EnergyType;
        private String[] EnergyType_type_info = new String[]{'EnergyType','urn:britishgas.co.uk:Enterprise:Common','BG_Code_Desc60','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Product','false','false'};
        private String[] field_order_type_info = new String[]{'EnergyType'};
    }
    public class TariffKey {
        public String TariffCode;
        public String TariffType;
        public String EnergyTypeCode;
        private String[] TariffCode_type_info = new String[]{'TariffCode','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] TariffType_type_info = new String[]{'TariffType','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] EnergyTypeCode_type_info = new String[]{'EnergyTypeCode','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:britishgas.co.uk:Enterprise:Product','false','false'};
        private String[] field_order_type_info = new String[]{'TariffCode','TariffType','EnergyTypeCode'};
    }
}