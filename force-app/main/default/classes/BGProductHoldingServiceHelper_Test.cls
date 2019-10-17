/**
 * 
 */
@isTest
private class BGProductHoldingServiceHelper_Test {

    static testMethod void myUnitTest() {
        
        Inbound_Call__c callObj = new Inbound_Call__c();
        callObj.Workflow_Step__c = 1;
        insert callObj;
        Inbound_Call__c inboundCall =[select Id,Workflow_Step__c from Inbound_Call__c limit 1];
        
        
        //Add parameters to page URL 
        System.debug('####**** inboundCall'+inboundCall);
        //ApexPages.currentPage().getParameters().put('c',inboundCall.Id);
        
        ///////////////
        Account account=new Account();
        account.Name='Test Account';
        account.Number_of_Bedrooms__c=1;
        account.Gas_Supply_At_Address__c=true;
        account.Current_Heating_System__c=true;
        account.BillingStreet='Test Street';
        account.BillingState='Test State';
        account.BillingPostalCode='441111';
        account.BillingCountry='Test Country';
        account.BillingCity='Test City';
        account.Water_Hardness__c=0;
        account.CustomerUCRN__c = 'testucrn';
        account.BuildingNo__c = '1234';
        
        insert account;
        
        List<Contact> contactList = new List<Contact>();
        Contact contact=new Contact();
        contact.Primary_Contact__c=true;
        contact.Phone='9022332343';                
        contact.MailingStreet='test Street';
        contact.MailingState='Test State';
        contact.MailingPostalCode='4411189';
        contact.MailingCountry='Test country';
        contact.MailingCity='Test City';
        contact.LastName='Last Name';
        contact.FirstName='First name';
        contact.Email='test@gmail.com';
        contact.AccountId=account.Id;
        
        insert contact;
        
        Contact contact1=new Contact();
        contact1.Primary_Contact__c=false;
        contact1.Phone='9022332343';                
        contact1.MailingStreet='test Street';
        contact1.MailingState='Test State1';
        contact1.MailingPostalCode='M25 017';
        contact1.MailingCountry='Test country1';
        contact1.MailingCity='Test City';
        contact1.LastName='Last Name1';
        contact1.FirstName='First name1';
        contact1.Email='test@gmail.com';
        contact1.AccountId=account.Id;
        
        insert contact1;

        contactList.add(contact);
        contactList.add(contact1);
        
        ContactInfo conInfo = new ContactInfo();
        conInfo.contact= contact;
        conInfo.AddSlct = true;
        conInfo.ConSlct = true;
        conInfo.AddStrt='Street';
        conInfo.AddCty='city';
        conInfo.AddStat='state';
        conInfo.AddCntr='country';
        conInfo.AddZip='442222';
        conInfo.ConAdd='conAddress';
        
        ContactInfo conInfo1 = new ContactInfo();
        conInfo1.contact= contact1;
        conInfo1.AddSlct = true;
        conInfo1.ConSlct = true;
        conInfo1.AddStrt='Street';
        conInfo1.AddCty='city';
        conInfo1.AddStat='state';
        conInfo1.AddCntr='country';
        conInfo1.AddZip='442222';
        conInfo1.ConAdd='conAddress';

        List<ContactInfo> contactInfoList= new List<ContactInfo>();        
        contactInfoList.add(conInfo);
        contactInfoList.add(conInfo1);
            
        Campaign campaign=[select Id from campaign limit 1];
        List<Opportunity> opportunityList=new List<Opportunity>();
        
        Opportunity opp= new Opportunity();
        Opportunity opportunity = new Opportunity();
      
        opportunity.name='Test Opp';
        opportunity.StageName='Active';
        opportunity.CloseDate=System.today();
        opportunity.CampaignId=campaign.Id;
        opportunity.AccountId=account.Id;
        opportunity.LeadSource='Marcomms';
        opportunity.Product_Interest__c='Solar';
        
        insert opportunity;
        
        Workflow.WorkflowInfo WorkflowInfo = new Workflow.WorkflowInfo();
        WorkflowInfo.CustomerUCRN = account.CustomerUCRN__c;
        
        Account relatedAccount = [select id , HouseName__c, BuildingNo__c, POBoxNumber__c, BillingPostalCode, ProductHoldingLastUpdated__c  from Account where id =: account.Id];
        
        WorkflowInfo.Call = new Inbound_Call__c();
        WorkflowInfo.Call.Billing_Zip__c = relatedAccount.BillingPostalCode;
        
        WorkflowInfo.HouseNumber = account.BuildingNo__c;
        
        
        BGProductHoldingServiceHelper.isValidEnergyContract('asd');
        
        Map<String, List<String>> mapValues = new Map<String, List<String>>{
            'test' => new List<String>{ 'a','b'}
        };
        
        BGProductHoldingServiceHelper.addCustomerAccountValue(mapValues, 'test', 'a');
        
        BGProductHoldingServiceHelper.getProductHoldingRequest('test', 'test');
        
        
        britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey key = new britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey(); 
        key.CustomerAccountID = 'test';
        
        britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey[] customerKeyList = new britishgasCoUkEnterpriseCustomeracco.CustomerAccountKey[]{ key };
        
        BGProductHoldingServiceHelper.getRequestPacketForQueryProduct(customerKeyList, 'test');
        
        BGProductHoldingServiceHelper.getRequestPacketForPaymentScheme(key, 'test');
        
        BGProductHoldingServiceHelper.getRequestPacketForManageAccount(Key, 'test');
        
        //BGProductHoldingServiceHelper.readXML(new HttpResponse(), 'asd');
        
        ProductHoldingData productHoldingDataObj = new ProductHoldingData();
        productHoldingDataObj.ProductHolding = new ProductHolding__c();
         
        Map<String, List<String>> mapAccountInfo = new Map<String, List<String>>{
            BGProductHoldingServiceHelper.STR_SERVICETYPE_HOMESERVICES => new List<String>{ 'testh' },
            BGProductHoldingServiceHelper.STR_SERVICETYPE_ELEC => new List<String>{ 'teste' },
            BGProductHoldingServiceHelper.STR_SERVICETYPE_GAS => new List<String>{ 'testg' },
            BGProductHoldingServiceHelper.STR_SERVICETYPE_ENERGY => new List<String>{ 'testen' }
        };
        
        //BGProductHoldingServiceHelper.retrieveQueryProductInfo(productHoldingDataObj, mapAccountInfo);
        
        //BGProductHoldingServiceHelper.findValue(null, '');
        
        //BGProductHoldingServiceHelper.retrievePaymentSchemeInfo(productHoldingDataObj, mapAccountInfo);
        
        //BGProductHoldingServiceHelper.retrievePaymentMethod('asd');
        
        
        BGProductHoldingServiceHelper.Installment installment = new BGProductHoldingServiceHelper.Installment();
        installment.Amount = 100; 
        installment.Code = 'test';
        installment.PaymentDate = System.today();
        
        BGProductHoldingServiceHelper.ContractPaymentDetail paymentDetaile = new BGProductHoldingServiceHelper.ContractPaymentDetail();
        paymentDetaile.EnergyCode = 'teste';
        paymentDetaile.InstallmentDetails.add(installment);
        
        BGProductHoldingServiceHelper.ContractPaymentDetail paymentDetailg = new BGProductHoldingServiceHelper.ContractPaymentDetail();
        paymentDetailg.EnergyCode = 'testg';
        paymentDetailg.InstallmentDetails.add(installment);
        
        BGProductHoldingServiceHelper.ContractPaymentDetail paymentDetailen = new BGProductHoldingServiceHelper.ContractPaymentDetail();
        paymentDetailen.EnergyCode = 'testen';
        paymentDetailen.InstallmentDetails.add(installment);
        
        
        
        Map<String, BGProductHoldingServiceHelper.ContractPaymentDetail> mapPaymentInfo = new Map<String, BGProductHoldingServiceHelper.ContractPaymentDetail>{
            'teste' => paymentDetaile,
            'teste' => paymentDetailg,
            'testen' => paymentDetailen
        };
        
        BGProductHoldingServiceHelper.setPaymentInformation(productHoldingDataObj, mapPaymentInfo, 'asd', 'test');
        //new BGProductHoldingServiceHelper().dummyCode();
         HttpResponse response = New HttpResponse();
        String body = '<GeocodeResponse><status>OK</status><result><type>locality</type><type>political</type><formatted_address>HeyfieldVIC3858,Australia</formatted_address><address_component><long_name>Heyfield</long_name><short_name>Heyfield</short_name><type>locality</type><type>political</type></address_component><address_component><long_name>WellingtonShire</long_name><short_name>Wellington</short_name><type>administrative_area_level_2</type><type>political</type></address_component><address_component><long_name>Victoria</long_name><short_name>VIC</short_name><type>administrative_area_level_1</type><type>political</type></address_component><address_component><long_name>Australia</long_name><short_name>AU</short_name><type>country</type><type>political</type></address_component><address_component><long_name>3858</long_name><short_name>3858</short_name><type>postal_code</type></address_component><geometry><location><lat>-37.9827396</lat><lng>146.7911606</lng></location><location_type>APPROXIMATE</location_type><viewport><southwest><lat>-38.0261869</lat><lng>146.7152190</lng></southwest><northeast><lat>-37.9176030</lat><lng>146.8615709</lng></northeast></viewport><bounds><southwest><lat>-38.0261869</lat><lng>146.7152190</lng></southwest><northeast><lat>-37.9176030</lat><lng>146.8615709</lng></northeast></bounds></geometry><partial_match>true</partial_match><place_id>ChIJgwAuXS3OKGsRcGCgMKR5BQQ</place_id></result><result><type>route</type><formatted_address>NewMillRd,HolmfirthHD97SG,UK</formatted_address><address_component><long_name>NewMillRoad</long_name><short_name>NewMillRd</short_name><type>route</type></address_component><address_component><long_name>Holmfirth</long_name><short_name>Holmfirth</short_name><type>postal_town</type></address_component><address_component><long_name>WestYorkshire</long_name><short_name>WestYorkshire</short_name><type>administrative_area_level_2</type><type>political</type></address_component><address_component><long_name>England</long_name><short_name>England</short_name><type>administrative_area_level_1</type><type>political</type></address_component><address_component><long_name>UnitedKingdom</long_name><short_name>GB</short_name><type>country</type><type>political</type></address_component><address_component><long_name>HD97SG</long_name><short_name>HD97SG</short_name><type>postal_code</type></address_component><geometry><location><lat>53.5812219</lat><lng>-1.7725918</lng></location><location_type>GEOMETRIC_CENTER</location_type><viewport><southwest><lat>53.5796671</lat><lng>-1.7744324</lng></southwest><northeast><lat>53.5823650</lat><lng>-1.7709638</lng></northeast></viewport><bounds><southwest><lat>53.5806037</lat><lng>-1.7744324</lng></southwest><northeast><lat>53.5814284</lat><lng>-1.7709638</lng></northeast></bounds></geometry><partial_match>true</partial_match><place_id>EiJOZXcgTWlsbCBSZCwgSG9sbWZpcnRoIEhEOSA3U0csIFVLIkgqRgoUChIJ019BeErae0gRGpNOqjc74BkSFAoSCaWaGEI42ntIEa1brESQX-j2GhgKCg1VwO8fFTw-8f4SCg2M4O8fFbrF8f4</place_id></result></GeocodeResponse>';
        response.setBody(body);
        BGProductHoldingServiceHelper.readXMLtemp(response,'lat','HD9+7SG');
    }
    
    
}