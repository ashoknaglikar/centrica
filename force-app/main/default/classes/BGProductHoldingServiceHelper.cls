public class BGProductHoldingServiceHelper 
{
    public static String STR_SERVICECONSUMER = 'SFDC-CHI PRODUCT HOLDINGS';
    public static String STR_SERVICECONSUMERVERSION = '1.0';
    public static String STR_SERVICETYPE_GAS = 'Gas';
    public static String STR_SERVICETYPE_ELEC = 'Electricity';
    public static String STR_SERVICETYPE_ENERGY = 'Energy';
    public static String STR_SERVICETYPE_HOMESERVICES = 'Home Services';
    public static Integer MAXSERVICEPRODUCT = 4;
    
    public static String PAYMENTCODE_INPROCESS = 'IN-PROCESS'; 
    
    public static String ENERGYCODE_ELEC = '01';
    public static String ENERGYCODE_GAS = '02';
    
    
    public static String STR_SERVICEERROR = 'Error in Interface';
    public static String STR_NOSERVICECOVER = 'No Service Cover';
    
    public static Boolean SERVICEACCESSERROR = false;
    public static Integer SERVICETIMEOUT = integer.valueof(system.label.PH_Time_Out);
    
    //public static string SERVICE_QUERYPRODUCT_ENDPOINT = 'XISOAPAdapter/MessageServlet?senderParty=&senderService=BSR_Salesforce&receiverParty=&receiverService=&interface=QueryProduct&interfaceNamespace=urn%3Abritishgas.co.uk%3AEnterprise%3ACustomerAccount';
    //public static string SERVICE_PAYMENTSCHEME_ENDPOINT = 'XISOAPAdapter/MessageServlet?senderParty=&senderService=BSR_Salesforce&receiverParty=&receiverService=&interface=PaymentschemeprocessingQueryPaymentSchemeOut&interfaceNamespace=urn%3Abritishgas.co.uk%3AERP%3APaymentScheme';
    //public static string SERVICE_MANAGEACCOUNT_ENDPOINT = 'XISOAPAdapter/MessageServlet?senderParty=&senderService=BSR_Salesforce&receiverParty=&receiverService=&interface=ManageAccountDetailsOut&interfaceNamespace=urn%3Abritishgas.co.uk%3AONLINE%3A24X7Services';
    
    public static string SERVICE_QUERYPRODUCT_ENDPOINT = System.Label.CHI_Product_Holding_Product;
    public static string SERVICE_PAYMENTSCHEME_ENDPOINT = System.Label.CHI_Product_Holding_Payment_Scheme_endpoint;
    public static string SERVICE_MANAGEACCOUNT_ENDPOINT = System.Label.CHI_Product_Holding_Manage_Account_endpoint;
    
    public static Map<String, String> PAYMENTOPTIONMAP = new Map<String, String>{
        '2419' => 'Pending Fuel Direct',
        '2410' => 'Cash/Cheque',
        '2411' => 'Direct Debit',
        '2412' => 'Standing Order',
        '2413' => 'Advance Payment Tariff',
        '2414' => 'Magnetic Card',
        '2415' => 'Quarterly equal payments',
        '2416' => 'Cash/Cheque',
        '2417' => 'Fuel Direct',
        '2418' => 'Prepayment',
        '2401' => 'Prepayment',
        '2402' => 'Cash/Cheque',
        '2403' => 'Direct Debit',
        '2404' => 'Standing Order',
        '2405' => 'MAG Card',
        '2406' => 'Variable Direct Debit',
        '2408' => 'Unknown',
        '2409' => 'Fuel Direct'
    };
    
    public static Map<String, String> ENERGYCODEMAP = new Map<String, String>{
        '01' => 'Electricity',
        '02' => 'Gas'
    };
    
    private static Map<String,String> getUserAuthenticationInformation(Map<String,String> headerInfo)
    {
        if(headerInfo == null) headerInfo = new Map<String,String>();
        
        //generate authentication code
        String authCode = System.Label.CHIProductHoldingUsername + ':' + System.Label.CHIProductHoldingPassword;
        
        //base64 encode string
        authCode = Encodingutil.base64Encode(Blob.valueOf(authCode));
        
        headerInfo.put('Authorization', 'Basic ' + authCode);
        
        return headerInfo; 
    }
    
    private static String getUserAuthenticationInformation()
    {
        //generate authentication code
        String authCode = System.Label.CHIProductHoldingUsername + ':' + System.Label.CHIProductHoldingPassword;
        
        //base64 encode string
        authCode = 'Basic ' + Encodingutil.base64Encode(Blob.valueOf(authCode));
        
        return authCode;
    }
    
    public static List<britishgasCoUkEnterpriseParty.Customer> getCustomersByAddress(britishgasCoUkEnterpriseAddress.AddressSearchCriteria searchCriteria)
    {
        try
        {
            britishgasCoUkEnterpriseCommon.BG_ProcessingConditions processingConditions = new britishgasCoUkEnterpriseCommon.BG_ProcessingConditions();
            processingConditions.QueryHitsMaximumNumberValue = 100; //retrieve a maximum of 100 customer records
            
            
            //invoke customer search web service
            britishgasCoUkEnterpriseParty.Binding_x1QueryCustomerBinding queryCustomerService = new britishgasCoUkEnterpriseParty.Binding_x1QueryCustomerBinding();
            queryCustomerService.inputHttpHeaders_x = getUserAuthenticationInformation(queryCustomerService.inputHttpHeaders_x);
            //queryCustomerService.clientCertName_x = 'CHIProductHolding';
            queryCustomerService.timeout_x = SERVICETIMEOUT;
            britishgasCoUkEnterpriseParty.FindCustomersByAddressElementsResponseMessage response = queryCustomerService.FindCustomersByAddressElements(searchCriteria, STR_SERVICECONSUMER, processingConditions);
            
            System.debug('---------response : ' + response);
            return response.CustomerData;
        }
        catch(Exception ex)
        {
            SERVICEACCESSERROR = true;
            System.debug('---------error occurred : ' +ex);
            return null;
        }
    }
    
    //public static List<ProductHolding__c> getCustomerProductHoldingInformation(britishgasCoUkEnterpriseParty.Customer customerInfo )
    //public static ProductHolding__c getCustomerProductHoldingInformation(ProductHolding__c productHoldingInfo, String schemeID, String schemeAgencyID)
    public static ProductHoldingData getCustomerProductHoldingInformation(Workflow.WorkflowInfo info)
    {
        ProductHolding__c productHoldingInfo = info.ProductHoldingInfo;
         
        ProductHoldingData productHoldingDataObj = new ProductHoldingData();
        productHoldingDataObj.ProductHolding = productHoldingInfo;
        system.debug('Info.CurrentAccount='+Info.CurrentAccount);
        try
        {
            //STEP 1: invoke "FindCustomersByAddressElements" of QueryCustomer to retrieve product related information
            Map<String, List<String>> mapAccountInfo = new Map<String, List<String>>();
            
            britishgasCoUkEnterpriseAddress.AddressSearchCriteria searchCriteria = new britishgasCoUkEnterpriseAddress.AddressSearchCriteria();
            
            searchCriteria.Postcode = info.Call.Billing_Zip__c;
            if(info.HouseNumber != null && info.HouseNumber != '')
            {
                searchCriteria.BuildingNumber = info.HouseNumber;
            }
            else if(info.houseName != null && info.houseName != '')
            {
                searchCriteria.BuildingName = info.houseName;
            }
            else if(info.poBoxNumber != null && info.poBoxNumber != '')
            {
                searchCriteria.POBoxNumber = info.poBoxNumber;
            }
            system.debug('--------- searchCriteria = ' + searchCriteria);
            for( britishgasCoUkEnterpriseParty.Customer customerRec :getCustomersByAddress(searchCriteria))
            {
                if(customerRec != null && 
                customerRec.CustomerID != null && 
                customerRec.CustomerID.PartyID != null)
                {   
                    //changes for IPD 3653 begin - dated 2/11/2013
                    if(info.CustomerUCRN == customerRec.CustomerID.PartyID){
                    ContactInfo temp= new ContactInfo();
                    temp.contact= new contact();
            
            temp.contact.MailingStreet=info.Call.Billing_Street__c;
            temp.contact.MailingCity=info.Call.Billing_City__c;
            temp.contact.MailingState=info.Call.Billing_State__c;
            temp.contact.MailingPostalCode=info.Call.Billing_Zip__c;
            temp.contact.MailingCountry=info.Call.Billilng_Country__c;
                    //retrieve customer name                
                    if(customerRec.personBiographicData != null &&                     
                    customerRec.personBiographicData.PersonName != null)                
                    { system.debug('customer person rec='+customerRec.personBiographicData);
                        if(CustomerResponseTitleXMLAttribute__c.getInstance(customerRec.personBiographicData.PersonName.Title)!=null)       
                        temp.contact.Salutation = CustomerResponseTitleXMLAttribute__c.getInstance(customerRec.personBiographicData.PersonName.Title).Attribute_Value__c;           
                        temp.contact.FirstName = customerRec.personBiographicData.PersonName.FirstName;                     
                        temp.contact.LastName = customerRec.personBiographicData.PersonName.Surname;                
                    }
                                        
                    //retrieve customer phone
                    if(customerRec.crm != null && customerRec.Crm.phone != null){
                     system.debug('customer phone rec='+customerRec.Crm.phone);
                         for(integer i=0;i<customerRec.Crm.phone.size();i++){
                            britishgasCoUkEnterpriseParty.PartyPhoneContactMethodBody  phonebody=customerRec.Crm.phone[i];
                            if( customerRec.Crm.phone[i].ContactMethodStatus!=null && customerRec.Crm.phone[i].ContactMethodStatus.Code == '01' 
                            && customerRec.Crm.phone[i].ContactMethodLocation=='05' && customerRec.Crm.phone[i].PhoneNumber.Number_x!=null)                
                            {
                                if( customerRec.Crm.phone[i].PreferredNumberIndicator=='true' )             
                                    temp.contact.MobilePhone=customerRec.Crm.phone[i].PhoneNumber.Number_x;
                                else if (temp.contact.MobilePhone==null ||  temp.contact.MobilePhone=='') 
                                    temp.contact.MobilePhone=customerRec.Crm.phone[i].PhoneNumber.Number_x;              
                            }
                            else if( customerRec.Crm.phone[i].ContactMethodStatus!=null && customerRec.Crm.phone[i].ContactMethodStatus.Code == '01' 
                            && (customerRec.Crm.phone[i].ContactMethodLocation=='02' || customerRec.Crm.phone[i].ContactMethodLocation=='03') 
                            && customerRec.Crm.phone[i].PhoneNumber.Number_x!=null)                
                            {
                                 if( customerRec.Crm.phone[i].PreferredNumberIndicator=='true')             
                                    temp.contact.homePhone=customerRec.Crm.phone[i].PhoneNumber.Number_x;
                                else if (temp.contact.homePhone==null ||  temp.contact.homePhone=='') 
                                    temp.contact.homePhone=customerRec.Crm.phone[i].PhoneNumber.Number_x; 
                            }
                            else if( customerRec.Crm.phone[i].ContactMethodStatus!=null && customerRec.Crm.phone[i].ContactMethodStatus.Code == '01' 
                            && customerRec.Crm.phone[i].ContactMethodLocation=='08' && customerRec.Crm.phone[i].PhoneNumber.Number_x!=null)                
                            {
                                 if( customerRec.Crm.phone[i].PreferredNumberIndicator=='true')             
                                     temp.contact.otherPhone=customerRec.Crm.phone[i].PhoneNumber.Number_x;
                                 else if (temp.contact.Phone==null ||  temp.contact.Phone=='')
                                     temp.contact.otherPhone=customerRec.Crm.phone[i].PhoneNumber.Number_x;
                             }
                        }                    
                    }                   
                    
                    system.debug('temp.contact='+temp.contact);
                    //retrieve customer email
                    if(customerRec.crm != null && customerRec.Crm.Email != null){
                    system.debug('customer email rec='+customerRec.Crm.Email);

                        if( customerRec.Crm.Email[0].ContactMethodStatus!=null && customerRec.Crm.Email[0].ContactMethodStatus.Code == '01')                
                        {
                         temp.contact.email__c=customerRec.Crm.Email[0].EmailAddress;
                        }
                        for(integer i=1;i<customerRec.Crm.Email.size();i++){
                            britishgasCoUkEnterpriseParty.PartyEmailContactMethodBody  emailbody=customerRec.Crm.Email[i];
                            if( emailbody.ContactMethodStatus!=null && emailbody.ContactMethodStatus.Code == '01' && emailbody.DefaultIndicator=='true')                
                            {       
                                temp.contact.email__c=emailbody.EmailAddress;                               
                                break;
                            }
                        }system.debug('temp.contact='+temp.contact);
                    }

                    productHoldingDataObj.NewContactInfos.add(temp);
                    }
                    //changes for IPD 3653 end   - dated 2/11/2013
                    
                    //check if data is for current customer
                    if(info.CustomerUCRN == customerRec.CustomerID.PartyID 
                        && customerRec.SimpleAccount != null && customerRec.SimpleAccount.size() > 0)
                    {
                        for(britishgasCoUkEnterpriseCustomeracco.SimpleCustomerAccount customerInfo :customerRec.SimpleAccount)
                        {
                            system.debug('--------- customerInfo.PaymentOption = ' + customerInfo.PaymentOption);
                            
                            if(customerInfo != null && 
                                customerInfo.AccountType != null && 
                                customerInfo.AccountType.Code != null)
                            {
                                
                                String code = customerInfo.AccountType.Code;
                                Boolean isEnergyContract = false;
                                
                                if(code.equalsIgnoreCase(STR_SERVICETYPE_GAS))
                                {
                                    //GAS ACCOUNT
                                    isEnergyContract = true;
                                    productHoldingInfo.GasIsCurrentCustomer__c = true;
                                    if(customerInfo.PaymentOption != null)
                                        productHoldingInfo.GasPaymentMethod__c = customerInfo.PaymentOption.PaymentOptionCode;
                                }
                                else if(code.equalsIgnoreCase(STR_SERVICETYPE_ELEC))
                                {
                                    //ELECTRICITY ACCOUNT
                                    isEnergyContract = true;
                                    productHoldingInfo.ElectricityIsCurrentCustomer__c = true;
                                    if(customerInfo.PaymentOption != null)
                                        productHoldingInfo.ElectricityPaymentMethod__c = customerInfo.PaymentOption.PaymentOptionCode;
                                }
                                else if(code.equalsIgnoreCase(STR_SERVICETYPE_ENERGY))
                                {
                                    //ENERGY ACCOUNT
                                    isEnergyContract = true;
                                    productHoldingInfo.GasIsCurrentCustomer__c = true;
                                    
                                    if(customerInfo.PaymentOption != null)
                                        productHoldingInfo.GasPaymentMethod__c = customerInfo.PaymentOption.PaymentOptionCode;
                                    
                                    //add customeraccount id in map
                                    productHoldingInfo.ElectricityIsCurrentCustomer__c = true;
                                    
                                    if(customerInfo.PaymentOption != null)
                                        productHoldingInfo.ElectricityPaymentMethod__c = customerInfo.PaymentOption.PaymentOptionCode;
                                }
                            
                                System.debug('---------111 code = ' + code);
                                
                                //if its energy contract validate contract no. else just add it to map
                                
                                
                                if(isEnergyContract == false 
                                    || (isEnergyContract && isValidEnergyContract(customerInfo.CustomerAccountID)))
                                {
                                    List<String> lstString = new List<String>();
                                    if(mapAccountInfo.containsKey(code)) lstString = mapAccountInfo.get(code);
                                
                                    //add codes to map
                                    //mapAccountInfo = addCustomerAccountValue(mapAccountInfo, code, customerInfo.CustomerAccountID);
                                    lstString.add(customerInfo.CustomerAccountID);
                                    mapAccountInfo.put(code, lstString);
                                }
                                else
                                {
                                    System.debug('---------- invalid contract = code:' + code + '; contractno:' + customerInfo.CustomerAccountID);
                                }
                            }
                        }
                        
                        //identify credit rating
                        if(customerRec.RiskSegment != null)
                        {
                            for(britishgasCoUkEnterpriseCreditratingQC.CreditRatingEventBody creditRatingInfo :customerRec.RiskSegment)
                            {
                                if(creditRatingInfo.InternalCreditRatingCode != null 
                                    && creditRatingInfo.InternalCreditRatingCode.Code != null
                                    && creditRatingInfo.InternalCreditRatingCode.Code.trim() != '')
                                {
                                    productHoldingInfo.CreditRating__c = creditRatingInfo.InternalCreditRatingCode.Code;
                                    
                                    /*if(CREDITRATINGMAP.containsKey(productHoldingInfo.CreditRating__c))
                                    {
                                        productHoldingInfo.CreditRating__c = CREDITRATINGMAP.get(productHoldingInfo.CreditRating__c);
                                    }*/
                                    
                                    System.debug('--------------- rating ' + productHoldingInfo.CreditRating__c); 
                                    break;
                                }
                            }
                        }
                        break;
                    }
                }
            }
            
            system.debug('--------- productHoldingInfo = ' + productHoldingInfo);
            system.debug('--------- mapAccountInfo = ' + mapAccountInfo);
            
            
            if(mapAccountInfo.size() > 0)
            {
                //STEP 2: invoke "ServiceProductByCustomer" web method of web service "QueryProduct"
                if(mapAccountInfo.containsKey(STR_SERVICETYPE_HOMESERVICES))
                {
                    //Home services account exists
                    productHoldingDataObj = retrieveQueryProductInfo(productHoldingDataObj, mapAccountInfo);
                }
                else
                {
                    productHoldingInfo.ServiceCover__c = STR_NOSERVICECOVER;
                }
                
                //STEP 3:invoke "FindPaymentSchemeByElements" web method of web service "QueryPaymentScheme"
                productHoldingDataObj = retrievePaymentSchemeInfo(productHoldingDataObj, mapAccountInfo);
            }
            else
            {
                productHoldingInfo.ServiceCover__c = STR_NOSERVICECOVER;
            }
        
        }
        catch(Exception ex)
        {
            SERVICEACCESSERROR = true;
            System.debug('---------error occurred : ' +ex);
        }
        
        for(ProductHoldingAccount__c ac :productHoldingDataObj.ProductHoldingAccounts)
        {
            System.debug('-------ac = ' + ac);
        }
        
        //mark employee having at least one product
        if((productHoldingDataObj.ProductHoldingAccounts != null && productHoldingDataObj.ProductHoldingAccounts.size() > 0) 
            || (productHoldingDataObj.ProductHolding.ServiceProducts__c != null && productHoldingDataObj.ProductHolding.ServiceProducts__c != ''))
        {
            productHoldingInfo.IsCurrentCustomerOfAnyProduct__c = 'Yes';
        }
        else
        {
            productHoldingInfo.IsCurrentCustomerOfAnyProduct__c = 'No';
        }
                                    
        
        return productHoldingDataObj;
    }
    
    //validates if Energy contract no. is valid
    //Energy contract no. should start with 85
    public static Boolean isValidEnergyContract(String contractNumber)
    {
        return contractNumber != null ? contractNumber.trim().startsWith('85') : false;
    } 
    
    public static Map<String, List<String>> addCustomerAccountValue(Map<String, List<String>> mapValues, String key, String value)
    {
        List<String> lstString = new List<String>();
        if(mapValues.containsKey(key))
        {
            lstString = mapValues.get(key);
        }
        lstString.add(value);
        mapValues.put(key, lstString);
        return mapValues;
    }
    
    public class GetCustomerProductHoldingInformationMessage
    {
        public britishgasCoUkEnterpriseCustomeracco.FindServicesProductsByAccountIDResponseMessage ResponseQP;
        public britishgasCoUkOnline24x7servicesMADO.AccountDetailsByAccountIDResp_Online ResponseMDS;
        public britishgasCoUkEnterprisePaymentschemPPO.PaymentSchemeSimpleByElementsResponse_SyncMessage ResponsePayment;
    }
    
    
    
    public static HttpRequest getProductHoldingRequest(String endpointURL, String body)
    {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointURL);
        request.setMethod('GET');
        request.setTimeout(SERVICETIMEOUT);
        
        request.setHeader('Authorization', getUserAuthenticationInformation());
        request.setHeader('Content-Type', 'text/xml');
        
        //----------------additional headers added on Sep 6, 2012
        //request.setHeader('Accept', 'text/xml');
        //request.setHeader('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
        //request.setHeader('Content-Type', 'text/xml');
        request.setBody(body);
        
        return request;
    }
    
    public static HttpRequest getRequestPacketForQueryProduct(britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey[] customerKeyList, String serviceConsumer)
    {
        String accoundIdentifierXML = '';
        
        for(britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey key :customerKeyList)
        {
            accoundIdentifierXML += '<CustomerAccountKey>' +
                            '<CustomerAccountID schemeID="" schemeAgencyID="">' + key.CustomerAccountID + '</CustomerAccountID>' +
                         '</CustomerAccountKey>';
        }
        
        //-------------------- SOAP Packet
        String requestXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:britishgas.co.uk:Enterprise:CustomerAccount">' +
               '<soapenv:Header/>' +
                   '<soapenv:Body>' +
                      '<urn:FindServicesProductsByAccountIDRequest>' +
                         accoundIdentifierXML +
                         '<BG_ServiceConsumer>?</BG_ServiceConsumer>' +
                      '</urn:FindServicesProductsByAccountIDRequest>' +
                   '</soapenv:Body>' + 
                '</soapenv:Envelope>';
        
        System.debug('------ request URL : ' + SERVICE_QUERYPRODUCT_ENDPOINT);
        HttpRequest newRequest = getProductHoldingRequest(SERVICE_QUERYPRODUCT_ENDPOINT, requestXML);
        
        System.debug('------------ getRequestPacketForQueryProduct: ' + newRequest.getBody());
        return newRequest; 
    }
    
    public static HttpRequest getRequestPacketForPaymentScheme(britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey customerAccountKey, String serviceConsumer)
    {
        String requestXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:britishgas.co.uk:ERP:PaymentScheme">' +
            '<soapenv:Header/>' + 
               '<soapenv:Body>' +
                  '<urn:PaymentSchemeSimpleByElementsQuery_Sync>' +
                     '<AccountIdentifier>' +
                        '<CustomerAccountID>' + customerAccountKey.CustomerAccountID + '</CustomerAccountID>' +
                     '</AccountIdentifier>' + 
                     '<MessageHeader>' +
                        '<ServiceConsumer>' + serviceConsumer + '</ServiceConsumer>' +
                        '<Version>?</Version>' +
                     '</MessageHeader>' +
                  '</urn:PaymentSchemeSimpleByElementsQuery_Sync>' +
               '</soapenv:Body>' +
            '</soapenv:Envelope>';
        
        HttpRequest newRequest = getProductHoldingRequest(SERVICE_PAYMENTSCHEME_ENDPOINT, requestXML);
            
        System.debug('------------------ getRequestPacketForPaymentScheme: ' + newRequest.getBody());
        return newRequest; 
    }
    
    public static HttpRequest getRequestPacketForManageAccount(britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey customerAccountKey, String serviceConsumer)
    {
        String requestXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:britishgas.co.uk:ONLINE:24X7Services">' +
               '<soapenv:Header/>' +
               '<soapenv:Body>' +
                  '<urn:AccountIDQuery1_sync>' +
                     '<Account>' +
                        '<AccountID>' + customerAccountKey.CustomerAccountID + '</AccountID>' +
                     '</Account>' +
                     '<Consumer></Consumer>' +
                  '</urn:AccountIDQuery1_sync>' +
               '</soapenv:Body>' +
            '</soapenv:Envelope>';
        
        HttpRequest newRequest = getProductHoldingRequest(SERVICE_MANAGEACCOUNT_ENDPOINT, requestXML);
            
        System.debug('------------------ getRequestPacketForManageAccount: ' + newRequest.getBody());
        return newRequest; 
    }
    
   
    ///       
    //Read Http response XML message
    ///
    public static string readXMLtemp(HttpResponse response, String tag, String pcode ){
        String shortNameCheck = 'GB';
        String longName = 'long_name';
        String shortName = 'short_name';
        String text;
        String text1;
        String text2;
        XmlStreamReader responseReader = new XmlStreamReader(response.getBody());
        System.debug(responseReader );
        Boolean found = false;
        Boolean find = false;
       while(responseReader.hasNext()) {  
            System.debug('Entered the first1 while loop');
            if (responseReader.getEventType() == XmlTag.START_ELEMENT){
            System.debug('Entered the first1 if condition' + responseReader.getLocalName());
                if(shortName == responseReader.getLocalName())
                {
                    System.debug('Entered into the second if condition matching the shortname tag');
                    if(found != true) {
                        while(responseReader.hasNext()) {
                            System.debug('Entered into the second while loop' + responseReader.getLocalName());
                            if (responseReader.getEventType() == XmlTag.END_ELEMENT)
                            {
                                System.debug('Breaks incase of end element');
                                break;
                            }
                            //System.debug('Before going into the else if');
                            else if (responseReader.getEventType() == XmlTag.CHARACTERS) { 
                                System.debug('Gets the character value incase of characters present');
                                text1 = responseReader.getText();
                                System.debug(text1+'text' + shortNameCheck);
                                if( text1 == shortNameCheck )
                                {
                                    found = true;
                                    break;
                                }
                            }
                            responseReader.next();
                        }
                    }
                }     
            }
            responseReader.next();
            if(found == true) {
                break;
            }
            
       }
        while(responseReader.hasNext()) {  
            System.debug('Entered the first while loop');
            if (responseReader.getEventType() == XmlTag.START_ELEMENT){
            System.debug('Entered the first if condition'+ responseReader.getLocalName());
                if(longName == responseReader.getLocalName())
                {
                    System.debug('Entered into the second if condition matching the shortname tag');
                    if(find != true) {
                        while(responseReader.hasNext()) {
                            System.debug('Entered into the second1 while loop');
                            if (responseReader.getEventType() == XmlTag.END_ELEMENT)
                            {
                                System.debug('Breaks incase of end1 element');
                                break;
                            }
                            //System.debug('Before going into the else if');
                            else if (responseReader.getEventType() == XmlTag.CHARACTERS) { 
                                System.debug('Gets the character value incase of characters present');
                                text2 = responseReader.getText().normalizeSpace().replaceall(' ','+').trim();
                                System.debug(text2+'text2'+ pcode);
                                if( pcode.contains(text2))
                                {
                                    system.debug('found');
                                    find = true;
                                    break;
                                }
                            }
                            responseReader.next();
                        }
                    }
                } 
            
                if( found == true && find == true)   {
                    
                        System.debug('Entered after the short name match');
                        if (tag == responseReader.getLocalName()){                                      
                            while(responseReader.hasNext()) {
                                if (responseReader.getEventType() == XmlTag.END_ELEMENT)
                                    break;
                                else if (responseReader.getEventType() == XmlTag.CHARACTERS)
                                    text = responseReader.getText();
                                 System.debug(text+'text');
                                 System.debug(XmlTag.CHARACTERS+'XmlTag.CHARACTERS----->');
                                responseReader.next();  
                            }
                        }
                    }
                }
            system.debug(tag+' tag text is: '+text);
            responseReader.next();
            }
     return text;
    }
   
      public static string readXML(HttpResponse response, String tag){
            
        String text;                            
        XmlStreamReader responseReader = new XmlStreamReader(response.getBody());
        
        while(responseReader.hasNext()) {               
            if (responseReader.getEventType() == XmlTag.START_ELEMENT){                         
                if (tag == responseReader.getLocalName()){                                      
                    while(responseReader.hasNext()) {
                        if (responseReader.getEventType() == XmlTag.END_ELEMENT)
                            break;
                        else if (responseReader.getEventType() == XmlTag.CHARACTERS)
                            text = responseReader.getText();                        
                        responseReader.next();  
                    }
                    break;                                                                                      
                }
            }                                           
            responseReader.next();
        }           
        system.debug(tag+' tag text is: '+text);
        return text;
    }
    public static ProductHoldingData retrieveQueryProductInfo(ProductHoldingData productHoldingDataObj, Map<String, List<String>> mapAccountInfo)
    {
        ProductHolding__c productHoldingInfo = productHoldingDataObj.ProductHolding;
        try
        {
            britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey[] customerKeyList = new britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey[]{};
            britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey customerKey = new britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey();
            
            String serviceCover = '';
            String serviceProduct = '';
            String logValue = '';
            Integer serviceProductCount = 0;
            for(String customerAccountKey :mapAccountInfo.get(STR_SERVICETYPE_HOMESERVICES))
            {
                customerKey = new britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey();
                customerKey.CustomerAccountID = customerAccountKey;
                
                //to take only last customer account in consideration
                customerKeyList = new britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey[]{};
                
                customerKeyList.add(customerKey);
            }
            
            HttpRequest requestPacket = getRequestPacketForQueryProduct(customerKeyList, STR_SERVICECONSUMER);
            
            Http http = new Http();
            HttpResponse responsePacket = http.send(requestPacket);
                                      
            System.debug('----------- retrieveQueryProductInfo:responsePacket = ' + responsePacket.getBody());
                                           
            //Check a response was received successfully
            if(responsePacket.getStatusCode() != 200)
            {
                //error: throw exception
                //throw new Exception('Error: Failed to invoke QueryProduct web service. The create request did not receive a successfully http response code of 200. The response received was: ' + responsePacket.toString());
                productHoldingInfo.ServiceCover__c = STR_SERVICEERROR;
            }                                                                          
            else
            {                                           
                //data recieved successfully
                
                XmlStreamReader responseReader = new XmlStreamReader(responsePacket.getBody());
                
                while(responseReader.hasNext()) {               
                    if (responseReader.isStartElement()){
                        
                        if (responseReader.getLocalName().equalsIgnoreCase( 'ServicesProductPackageCode' ))
                        {       
                            responseReader.next();
                            if (responseReader.getLocalName().equalsIgnoreCase( 'Code' ))
                            {   
                                responseReader.next();
                                if(responseReader.isCharacters() && responseReader.getText() != '')
                                {
                                    serviceCover = responseReader.getText();
                                }
                                responseReader.next();
                            }
                            responseReader.next();
                            if (responseReader.getLocalName().equalsIgnoreCase( 'Description' ))
                            {   
                                responseReader.next();
                                if(responseReader.isCharacters() && responseReader.getText() != '')
                                {
                                    if(serviceCover != '') serviceCover += ' - ';
                                    serviceCover += responseReader.getText();
                                }
                            }
                            
                            responseReader.next();
                        }
                        
                        
                        if (responseReader.getLocalName().equalsIgnoreCase( 'HomeServicingProductName' )
                         && serviceProductCount < MAXSERVICEPRODUCT)
                        {       
                            responseReader.next();
                            String strValue = '';
                            if(responseReader.isCharacters() && responseReader.getText() != '')
                            {
                                strValue = responseReader.getText();
                            }
                            
                            if(serviceProduct != '') serviceProduct += ', ';
                            serviceProduct += strValue;
                            
                            serviceProductCount++; //to increment count on finding one service product
                            
                            responseReader.next();
                            
                        }
                        
                        //if log is retrieved
                        if(serviceCover == '' && responseReader.getLocalName().equalsIgnoreCase( 'BG_Log' ))
                        {
                            logValue = findValue(responseReader, 'Note');
                        }
                    }
                    responseReader.next();
                }
            }
            
            System.debug('------------ serviceProduct = ' + serviceProduct);
            
            if(serviceCover != '')
                productHoldingInfo.ServiceCover__c = serviceCover;
            else if(logValue != '')
                productHoldingInfo.ServiceCover__c = logValue;
            else
                productHoldingInfo.ServiceCover__c = STR_NOSERVICECOVER;
            
            productHoldingInfo.ServiceProducts__c = serviceProduct;
        }
        catch(Exception ex)
        {
            System.debug('Error in retrieveQueryProductInfo = ' + ex);
            productHoldingInfo.ServiceCover__c = STR_SERVICEERROR;
        }
        
        return productHoldingDataObj;
    }
    
    public static String findValue(XmlStreamReader responseReader, String nodeName)
    {
        String retVal = '';
        for(Integer i = 1; i > 0;)
        {
            while(responseReader.hasNext())
            {
                System.debug('------ ' + i + ' = ' + responseReader.getLocalName());
                
                if ( responseReader.isStartElement() )
                {
                    if ( responseReader.getLocalName().equalsIgnoreCase( nodeName ) )
                    {
                        responseReader.next();
                        retVal = responseReader.getText();
                        return retVal;
                    }
                    else
                    {
                        i++;
                    }
                }
                else if ( responseReader.isEndElement() )
                {
                    i--;
                    break;
                }
                responseReader.next();
            }
            responseReader.next();
        }
        return retVal;
    }
    
    public static ProductHoldingData retrievePaymentSchemeInfo(ProductHoldingData productHoldingDataObj, Map<String, List<String>> mapAccountInfo)
    {
        ProductHolding__c productHoldingInfo = productHoldingDataObj.ProductHolding;
        
        if(productHoldingDataObj.ProductHoldingAccounts == null)
        {
            productHoldingDataObj.ProductHoldingAccounts = new List<ProductHoldingAccount__c>();
        }
        
        List<String> lstCustomerAccountId = new List<String>();
        if(mapAccountInfo.containsKey(STR_SERVICETYPE_GAS))
        {
            //retrieve information for gas accounts 
            List<String> lstAccounts = mapAccountInfo.get(STR_SERVICETYPE_GAS);
            
            if(lstAccounts != null && lstAccounts.size() > 0)
            {
                String customerAccountID = lstAccounts[lstAccounts.size() - 1];
                
                //retrieve payment amount
                Map<String, ContractPaymentDetail> mapPaymentInfo = retrievePaymentSchemeInfo(customerAccountID);
                
                //retrieve payment method
                String paymentMethod = retrievePaymentMethod(customerAccountID);
                
                //populate data present at hand
                productHoldingInfo.GasAccount__c = customerAccountID;
                productHoldingInfo.GasPaymentMethod__c = paymentMethod;
                
                //create account record
                if(paymentMethod != null)
                {
                    ProductHoldingAccount__c customerAccount = new ProductHoldingAccount__c();
                    customerAccount.Name = customerAccountID;
                    customerAccount.Type__c = STR_SERVICETYPE_GAS;
                    customerAccount.PaymentMethod__c = paymentMethod;
                    productHoldingDataObj.ProductHoldingAccounts.add(customerAccount);
                    
                    productHoldingDataObj = setPaymentInformation(productHoldingDataObj, mapPaymentInfo, customerAccountID, paymentMethod);
                }
                else
                {
                    //account is not active; don't add any account record
                }
            }
        }
        if(mapAccountInfo.containsKey(STR_SERVICETYPE_ELEC))
        {
            List<String> lstAccounts = mapAccountInfo.get(STR_SERVICETYPE_ELEC);
            
            if(lstAccounts != null && lstAccounts.size() > 0)
            {
                String customerAccountID = lstAccounts[lstAccounts.size() - 1];
                //model = elec
                
                //retrieve payment amount
                Map<String, ContractPaymentDetail> mapPaymentInfo = retrievePaymentSchemeInfo(customerAccountID);
                
                //retrieve payment method
                String paymentMethod = retrievePaymentMethod(customerAccountID);
                
                //populate data present at hand
                productHoldingInfo.ElectricityAccount__c = customerAccountID;
                productHoldingInfo.ElectricityPaymentMethod__c = paymentMethod;
                
                //create account record
                if(paymentMethod != null)
                {
                    ProductHoldingAccount__c customerAccount = new ProductHoldingAccount__c();
                    customerAccount.Name = customerAccountID;
                    customerAccount.Type__c = STR_SERVICETYPE_ELEC;
                    customerAccount.PaymentMethod__c = paymentMethod;
                    productHoldingDataObj.ProductHoldingAccounts.add(customerAccount);
                    
                    productHoldingDataObj = setPaymentInformation(productHoldingDataObj, mapPaymentInfo, customerAccountID, paymentMethod);
                }
                else
                {
                    //account is not active; don't add any account record
                }
                System.debug('------------2 lstPaymentInfo = ' + mapPaymentInfo);
            }
        }
        if(mapAccountInfo.containsKey(STR_SERVICETYPE_ENERGY))
        {
            List<String> lstAccounts = mapAccountInfo.get(STR_SERVICETYPE_ENERGY);
            Integer lstSize = lstAccounts.size();
            
            //use last 2 energy accounts for retrieving payment details
            for(Integer i = lstSize - 1; i >= 0 && i > lstSize - 3; i--)
            {
                //String customerAccountID = mapAccountInfo.get(STR_SERVICETYPE_ENERGY)[0];
                String customerAccountID = lstAccounts[i];
                
                //retrieve payment method
                String paymentMethod = retrievePaymentMethod(customerAccountID);
                
                //create account record
                if(paymentMethod != null)
                {
                    ProductHoldingAccount__c customerAccount = new ProductHoldingAccount__c();
                    customerAccount.Name = customerAccountID;
                    customerAccount.Type__c = STR_SERVICETYPE_ENERGY;
                    customerAccount.PaymentMethod__c = paymentMethod;
                    productHoldingDataObj.ProductHoldingAccounts.add(customerAccount);
                
                
                    Map<String, ContractPaymentDetail> mapPaymentInfo = retrievePaymentSchemeInfo(customerAccountID);
                    productHoldingDataObj = setPaymentInformation(productHoldingDataObj, mapPaymentInfo, customerAccountID, paymentMethod);
                    
                    System.debug('------------3 lstPaymentInfo = ' + mapPaymentInfo);
                }
            }
        }
        
        return productHoldingDataObj;
    }
    
    public static String retrievePaymentMethod(String customerAccountKey)
    {
        String paymentMethod = '';
        
        britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey customerKey = new britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey();
        customerKey.CustomerAccountID = customerAccountKey;
        
        HttpRequest requestPacket = getRequestPacketForManageAccount(customerKey, STR_SERVICECONSUMER);
        
        Http http = new Http();
        HttpResponse responsePacket = http.send(requestPacket);
                                  
        System.debug('----------- retrievePaymentMethod:responsePacket = ' + responsePacket.getBody());
                                       
        //Check a response was received successfully
        if(responsePacket.getStatusCode() != 200)
        {
            //error: throw exception
            //throw new Exception('Error: Failed to invoke QueryProduct web service. The create request did not receive a successfully http response code of 200. The response received was: ' + responsePacket.toString());
            //paymentMethod = STR_SERVICEERROR;
        }                                                                          
        else
        {                                           
            //data recieved successfully
            paymentMethod = readXML(responsePacket, 'PaymentOptionCode');
            String strMoveOutDate = readXML(responsePacket, 'MoveOutDate');
            
            //convert payment method code to payment type description to make it user friendly
            if(PAYMENTOPTIONMAP.containsKey(paymentMethod))
                paymentMethod = PAYMENTOPTIONMAP.get(paymentMethod);
            
            system.debug('--------------- checking if active');
            if(strMoveOutDate != null && strMoveOutDate != '')
            {
                Date moveOutDate;
                try
                {
                    moveOutDate = Date.valueOf(strMoveOutDate); 
                }
                catch(Exception ex)
                {
                    //invalid date; do nothing
                }
                system.debug('--------------- moveOutDate = ' + moveOutDate);
                if(moveOutDate != null && moveOutDate < System.today())
                {
                    //move out date is less than today; account is no longer active
                    paymentMethod = null;
                }
            }
            
        }
        
        return paymentMethod;
    }
    
    public static ProductHoldingData setPaymentInformation(ProductHoldingData productHoldingDataObj, Map<String, ContractPaymentDetail> mapPaymentInfo, String customerAccountID, String paymentMethod)
    {
        Boolean multipleRequired = false; //to check if multiple accounts have to be created
        
        if(mapPaymentInfo != null)
        {
            //retrieve primary account for current account id
            ProductHoldingAccount__c primaryAccount = new ProductHoldingAccount__c();
        
            for(ProductHoldingAccount__c customerAccount :productHoldingDataObj.ProductHoldingAccounts)
            {
                if(customerAccount.Name == customerAccountID)
                {
                    primaryAccount = customerAccount;
                    break; 
                }
            }
        
            //loop through all accounts recieved from PaymentScheme
            for(String energyCode :mapPaymentInfo.keyset())
            {
                Decimal paymentAmount = -999;
                
                ContractPaymentDetail paymentDetail = mapPaymentInfo.get(energyCode);
                for(Installment installment :paymentDetail.InstallmentDetails)
                {
                    if(installment.Code.equalsIgnoreCase(PAYMENTCODE_INPROCESS))
                    {
                        //consider only last payment present with code "in-process" 
                        paymentAmount = installment.Amount;
                    }
                }
                
                //if no payment exists with code "in-process" set the last payment recieved as payment amount
                if(paymentAmount == -999 && paymentDetail.InstallmentDetails != null && paymentDetail.InstallmentDetails.size() > 0)
                {
                    paymentAmount = paymentDetail.InstallmentDetails[paymentDetail.InstallmentDetails.size() -1].Amount;
                }
                        
                if(multipleRequired == false)
                {
                    //update primary account
                    multipleRequired = true;    
                    primaryAccount.PaymentMethod__c = paymentMethod;
                    if(paymentAmount != -999) primaryAccount.MonthlySpend__c = paymentAmount;
                    if(ENERGYCODEMAP.containsKey(energyCode))
                    {
                        primaryAccount.Type__c = ENERGYCODEMAP.get(energyCode);
                    }
                }
                else
                {
                    //create additional accounts
                    ProductHoldingAccount__c customerAccount = new ProductHoldingAccount__c();
                    customerAccount.Name = primaryAccount.Name;
                    if(ENERGYCODEMAP.containsKey(energyCode))
                    {
                        customerAccount.Type__c = ENERGYCODEMAP.get(energyCode);
                    }
                    
                    customerAccount.PaymentMethod__c = paymentMethod;
                    if(paymentAmount != -999) customerAccount.MonthlySpend__c = paymentAmount;
                    productHoldingDataObj.ProductHoldingAccounts.add(customerAccount);
                }
            }
        }
        
        return productHoldingDataObj; 
    }
    
    
    public class ContractPaymentDetail
    {
        public String EnergyCode;
        public List<Installment> InstallmentDetails;
        
        public ContractPaymentDetail()
        {
            InstallmentDetails = new List<Installment>();
        }
    }
    
    public class Installment
    {
        public Date PaymentDate;
        public Decimal Amount;
        public String Code;
    }
    
    
    public static Map<String, ContractPaymentDetail> retrievePaymentSchemeInfo(String customerAccountKey)
    {
        britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey customerKey = new britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey();
        customerKey.CustomerAccountID = customerAccountKey;
        
        Map<String, ContractPaymentDetail> mapPaymentInfo = new Map<String, ContractPaymentDetail>(); 
        
        //String paymentValue = '';
        String logValue = '';
        HttpRequest requestPacket = getRequestPacketForPaymentScheme(customerKey, STR_SERVICECONSUMER);
        
        Http http = new Http();
        
        HttpResponse responsePacket = http.send(requestPacket);
                                  
        System.debug('----------- retrievePaymentSchemeInfo:responsePacket = ' + responsePacket.getBody());
                                       
        //Check a response was received successfully
        if(responsePacket.getStatusCode() != 200)
        {
            //error: throw exception
            //throw new Exception('Error: Failed to invoke QueryProduct web service. The create request did not receive a successfully http response code of 200. The response received was: ' + responsePacket.toString());
        }                                                                          
        else
        {                                           
            //data recieved successfully
            XmlStreamReader responseReader = new XmlStreamReader(responsePacket.getBody());
            
            while(responseReader.hasNext()) {               
                if (responseReader.isStartElement()){ 
                    
                    if (responseReader.getLocalName().equalsIgnoreCase( 'PaymentSchemetDetails' ))
                    {
                        ContractPaymentDetail paymentDetailsObj = new ContractPaymentDetail();
                        
                        while(responseReader.hasNext()) {
                            if (responseReader.isStartElement())
                            {
                                System.debug('----------- starting element :' + responseReader.getLocalName());
                                
                                if (responseReader.getLocalName().equalsIgnoreCase( 'EnergyType' ))
                                {       
                                    //detect energy type
                                    responseReader.next();
                                    responseReader.next();
                                    if ( responseReader.isCharacters() )
                                    {
                                        System.debug(' energy code value = ' + responseReader.getText());
                                        paymentDetailsObj.EnergyCode = responseReader.getText();
                                    }
                                }
                                else if (responseReader.getLocalName().equalsIgnoreCase( 'InstalmentItem' ))
                                {       
                                    //detect energy type
                                    Installment installmentDetail = new Installment();
                                    while(responseReader.hasNext()) {               
                                        if (responseReader.isStartElement() 
                                            && responseReader.getLocalName().equalsIgnoreCase( 'InstalmentStatus' ))
                                        {
                                            responseReader.next();
                                            responseReader.next();
                                            if ( responseReader.isCharacters() && responseReader.getText() != '')
                                            {
                                                try
                                                {
                                                    //retrieve payment code
                                                    installmentDetail.Code = responseReader.getText();
                                                }
                                                catch(Exception ex)
                                                {
                                                    //incorrect date: as of now do nothing  
                                                }
                                            }
                                        }
                                        else if (responseReader.isStartElement() 
                                            && responseReader.getLocalName().equalsIgnoreCase( 'InstalmentBeginDate' ))
                                        {
                                            //responseReader.next();
                                            responseReader.next();
                                            if ( responseReader.isCharacters() && responseReader.getText() != '')
                                            {
                                                try
                                                {
                                                    //retrieve payment date
                                                    System.debug(' payment date = ' + responseReader.getText());
                                                    installmentDetail.PaymentDate = Date.valueOf(responseReader.getText());
                                                }
                                                catch(Exception ex)
                                                {
                                                    //incorrect date: as of now do nothing  
                                                }
                                            }
                                        }
                                        else if (responseReader.isStartElement() 
                                            && responseReader.getLocalName().equalsIgnoreCase( 'NextInstalmentAmount' ))
                                        {
                                            //responseReader.next();
                                            responseReader.next();
                                            if ( responseReader.isCharacters() && responseReader.getText() != '')
                                            {
                                                try
                                                {
                                                    //retrieve payment amount
                                                    System.debug(' payment amount = ' + responseReader.getText());
                                                    installmentDetail.Amount = Decimal.valueOf(responseReader.getText());
                                                }
                                                catch(Exception ex)
                                                {
                                                    //incorrect amount: as of now do nothing    
                                                }
                                            }
                                        }
                                        else if(responseReader.isEndElement() && 
                                            responseReader.getLocalName().equalsIgnoreCase( 'InstalmentItem' ))
                                        {
                                            if(installmentDetail != null)
                                            {
                                                paymentDetailsObj.InstallmentDetails.add(installmentDetail);
                                            }
                                            break;
                                        }
                                        responseReader.next();
                                    }
                                }
                                /*else if (responseReader.getLocalName().equalsIgnoreCase( 'NextInstalmentAmount' ))
                                {
                                    PaymentInfo
                                    
                                    responseReader.next();
                                    if ( responseReader.isCharacters() )
                                    {
                                        paymentValue = responseReader.getText();
                                        System.debug(' value = ' + paymentValue);
                                    }
                                }*/
                            }
                            else if(responseReader.isEndElement() && 
                                responseReader.getLocalName().equalsIgnoreCase( 'PaymentSchemetDetails' ))
                            {
                                if(paymentDetailsObj.EnergyCode != null)
                                {
                                    mapPaymentInfo.put(paymentDetailsObj.EnergyCode, paymentDetailsObj);
                                }
                                break;
                            }
                            responseReader.next();  
                        }
                    }
                }
                responseReader.next();
            }
        }
        
        /*Decimal paymentAmount = 0;
        try
        {
            paymentAmount = Decimal.valueOf(paymentValue);
        }
        catch(Exception ex)
        {
            //do nothing
        }*/
        
        system.debug('------------------------- mapPaymentInfo = ' + mapPaymentInfo);
        
        return mapPaymentInfo;
    }
    
    
    
}