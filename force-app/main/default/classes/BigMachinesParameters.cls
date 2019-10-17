public class BigMachinesParameters {
    
    // BigMachines parameters - Set specific for the BM enviroment that you wish to connect to (Prod or Test environment)
    
    //Use the below to connect to Big Machine Production environment i.e. https://centrica.bigmachines.com
    public static Boolean usesSSL =       true; // does BigMachines site use SSL?
    public static String bm_site =        'centrica'; // subdomain of BigMachines site
    public static String version_id =     '8183571'; // version id 
    
    //Use the below values to connect to the current testcentrica1 enviroment i.e. http://testcentrica1.bigmachines.com
    //public static Boolean usesSSL =       false; // does BigMachines site use SSL?
    //public static String bm_site =        'testcentrica1'; // subdomain of BigMachines site
    //public static String version_id =     '4130645'; // version id
    
    //Big Machines login credentials for integration user. Used by the SFDC to BM Interface to login to BM
	public static String username = 'Qk1TRkRDSW50ZWdyYXRpb24=';
	public static String password = 'SW50ZWdyYXRlTWU='; 
    
    //Other BM parameters that are the same in BM prod or test enviroments and shouldnt need to be altered
    public static String process_id =     '4128545'; // id of commerce process
    public static String action_id_copy = '4129928'; // id of commerce process's copy action
    public static String action_id_open = '4129958'; // id of commerce process's open action
    public static String document_id =    '4128610'; // id of main document in commerce process   
    public static String process_var =    'quotes_process_bmClone_43'; // variable name of commerce process
}