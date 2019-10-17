Global class CustomerPortalFinance {
    Public String typeOfFinance;
    Public String title;
    Public String firstName;
    Public String middleName;
    Public String lastName ;
    Public String homePhone ;
    Public String workPhone ;
    Public String mobile;
    Public String email;
    Public string dateOfBirth ;
    Public String maritalStatus ;
    Public String gender ;
    Public String nationality;
    Public Decimal numberOfDependents;
    Public String employmentStatus;
    Public Decimal depositAmount;
    Public Decimal financeAmount;
    Public String jobDescription;
    Public Decimal grossAnnualSalary;
    Public String timeAtBank;
    Public String bankAccountNumber;
    public string nameOnBankAccount;
    public string quoteId;
    Public String sortCode;
    Public String securityQuestion;
    Public String securityAnswer;
    public decimal noOfCreditCards;
    public decimal monthlyRepayments;
    public decimal mortgage;
    public decimal houserent;
    public string financeOptions;
    Public List <CustomerPortalFinanceAddress> customerAddress =new List <CustomerPortalFinanceAddress> ();
    Public CustomerPortalFinanceAddress employerAddress = new CustomerPortalFinanceAddress() ;
    
    
   /*
    Public CustomerPortalFinance(){
        CustomerPortalFinanceAddress address= new CustomerPortalFinanceAddress();
        
        address.postcode;
        address.street='51 Caistor Street';
        address.city='Stockport';
        address.State='Greater Manchester';
        address.Country='UK';
        address.BuildingHouseName='Test';
        address.BuildingHouseNumber='51';
        address.TimeatAddressYear=1;
        address.TimeatAddressMonth=0;
        address.DateFrom=date.parse('01/01/2014');
        address.OccupancyStatus='Rent';
        customerAddress.add(address);
        
        
        EmployerAddress.Postcode='SK1 2LG';
        EmployerAddress.street='51 Caistor Street';
        EmployerAddress.city='Stockport';
        EmployerAddress.State='Greater Manchester';
        EmployerAddress.Country='UK';
        EmployerAddress.BuildingHouseName= 'DLF';
        EmployerAddress.EmployerName='Cognizant';
        EmployerAddress.EmployerPhone='123456789';
        EmployerAddress.TimeatEmployerYear=5;
        EmployerAddress.TimeatEmployerMonth=10;
        
    }
    */
    
    
}