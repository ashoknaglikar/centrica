public class honeyCombFinanceJSONSubmit{
    
    Public cls_references references;
    Public cls_finance finance;
    public cls_applicants applicants;
    public cls_retail retail;
    
    public class cls_references{
        public string externalUniqueReference; //AB123ASD512351
    }
    
    public class cls_finance{
       public string financeProductCode; //UPL
       public double advance; //1250
       public integer termMonths; //36
       public Double  APR; //9.9
       public Double  deposit; // 322.11
       public boolean depositTakenExternally; // false       //extra
    }
    
    public class cls_retail{
       public string retailerName; //Honeycomb Computers                    //extra
       public string productLegalDescription; //Computing goods             //extra
       public string retailSource; //Online                                 //extra
       Public cls_goods[] goods;
    }
    
    public class cls_goods{
       public string description; //Macbook Pro               //extra
       public String typeCode; //COMP001                      //extra
       public Double totalPrice; //1234.56                    //extra
       Public Integer quantity; //1                           //extra
    }
    
     public class cls_applicants{
       public cls_primaryApplicant primaryApplicant;
    }
    
    public class cls_primaryApplicant{
        public String title;    //Mrs
        public String firstName;    //Cynthia
        public String middleNames;   //Ann
        public String lastName;  //Test
        public date dateOfBirth;  //12/08/1962
        public String maritalStatus;    //married
        public String nationality;  //British
        public String residentialStatus;    //homeowner_no_mortgage
        public Integer dependents;  //2      
        Public cls_contactDetails contactDetails;
        Public cls_income income;
        Public cls_bankAccount bankAccount;
        Public cls_monthlyOutgoings monthlyOutgoings;
        Public cls_addresses addresses;
        public cls_employment employment;
    }
    
    Public class cls_addresses{
        public cls_address currentAddress;
        public cls_address[] previousAddresses;
    }
    
    Public class cls_employment{
        public String employmentStatus;
        public string occupation;
        public cls_employers employers;
    }
    
    public class cls_employers{
        Public cls_employeeDetails currentEmployer;
        //Public cls_employeeDetails[] previousEmployers;
    }
    
    public class cls_employeeDetails{
        public string employerName;
        //public cls_address employerAddress;
    }
    
    Public class cls_contactDetails{
        public String emailAddress;    //test@freedom-finance.com
        public String homePhone;    //01234567890
        public String workPhone;    //01234567890
        public String mobilePhone;    //01234567890
    }
    
   
    Public class cls_income{
        public Integer grossAnnualIncome; //9100
        //public integer netAnnualIncome; //8432
    }
    
    Public class cls_bankAccount{
        public String accountNumber;    //00123456       
        public String accountHolderName;  //MRS CYNTHIA A TEST 
        public String sortCode; //301122     
    }
    Public class cls_monthlyOutgoings{
        Public double Mortgage; //1234.44                         //extra
        public double Rent; // 543.21                             //extra
        //Public cls_otherOutgoings[] otherOutgoings;
    }
    
    /*Public class cls_otherOutgoings{
        public string outgoingName;  //Household: Council Tax     //extra
        Public double outgoingValue; //1234.56                    //extra
    }*/
    
     public class cls_address {
        //public String flatNumber;  //1                            //extra
        public String buildingNumber;  //12
        public string buildingName; //Grovehouse
        public String address1;   //Test Street
        //public String address2; //Test                            //extra
        //public String address3;   //test                          //extra
        public String town; //townton
        public String postcode;  //AB12 3CD
        public String countryCode;  //United Kingdom
        public date startDate;   //2018-01-01
        //public String endDate;   //2018-12-01                     //extra
        public Integer monthsAtAddress;  //0
    }
    
    public static honeyCombFinanceJSONSubmit parse(String json){
        return (honeyCombFinanceJSONSubmit) System.JSON.deserialize(json, honeyCombFinanceJSONSubmit.class);
    }

    
}