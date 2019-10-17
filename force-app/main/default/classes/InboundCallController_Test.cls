/*
Test class for InboundCallController.
Created Date: 28/10/09.
*/

@isTest
private class InboundCallController_Test{
    static Account account;
    static Campaign campaign;
    static Opportunity opp;
    static Opportunity opportunity;
    
    
    static void createData()
    {
        account=new Account();
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
        
        insert account;
        
        campaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert campaign;
        //Campaign campaign=[select Id from campaign limit 1];
       
        opp= new Opportunity();
        opp.name='Test Opp';
        opp.StageName='Active';
        opp.CloseDate=System.today();
        opp.CampaignId=campaign.Id;
        opp.AccountId=account.Id;
        opp.LeadSource='Marcomms';
        opp.Product_Interest__c='Solar';
        insert opp;
        opportunity = new Opportunity();
      
        opportunity.name='Test Opp';
        opportunity.StageName='Active';
        opportunity.CloseDate=System.today();
        opportunity.CampaignId=campaign.Id;
        opportunity.AccountId=account.Id;
        opportunity.LeadSource='Marcomms';
        opportunity.Product_Interest__c='Solar';
      
        insert opportunity;
        
        
    }
    
    static testmethod void customerCallTestMethod(){
        
        createData();
        User user = [select id, EnabledForProductHolding__c from User where id = :UserInfo.getUserId()];
        user.EnabledForProductHolding__c = true;
        update user;
        
        System.runas(user)
        {
           
            System.debug('### opportunity.CHI_Lead_Id1__c==>'+opportunity.CHI_Lead_Id1__c);
            
            opp=[select Id,CHI_Lead_Id1__c,name from opportunity where id =:opp.Id];
          
            System.debug('### opp==> '+opp);
            System.debug('### opp.CHI_Lead_Id__c==> '+opp.CHI_Lead_Id1__c);
            
            InboundCallController inboundCall= new InboundCallController();
            inboundCall.accountSearch=account;
            inboundCall.setLeadNumber(opp.CHI_Lead_Id1__c);
            inboundCall.leadNumberExist=true;
            inboundCall.CheckLeadNumber();
            inboundCall.setErrorMsg();
            
            inboundCall.opp.add(opportunity); 
            inboundCall.InvokeCustomerCall();
            inboundCall.InvokeEngineerCall();
            inboundCall.InvokeEmployeeCall();
            inboundCall.InvokeHSACall();
            inboundCall.InvokeWasteCall();
            
            //inboundCall.setLeadNumber('');
            inboundCall.InvokeCustomerCall();
            inboundCall.InvokeEngineerCall();
            inboundCall.InvokeEmployeeCall();
            inboundCall.InvokeHSACall();
            inboundCall.InvokeWasteCall();
            inboundCall.setLeadNumber('1234');
            inboundCall.getLeadNumber();
            inboundCall.CheckLeadAddress();
            
            inboundCall.accountSearch.BillingPostalCode = null;
            //inboundCall.getCustomerDetailsFromSAP();
            //inboundCall.ConfirmAccountAddress=true;
            inboundCall.InvokeCustomerCall();
            inboundCall.InvokeEngineerCall();
            inboundCall.InvokeEmployeeCall();
            inboundCall.InvokeHSACall();        
              
            //inboundCall.setLeadNumber('');
            inboundCall.accountSearch.BillingPostalCode=null;
            inboundCall.validateData();
            
            //inboundCall.setLeadNumber('');
            inboundCall.accountSearch.BillingPostalCode='12334';
            inboundCall.accountSearch.BillingCity='city';
            inboundCall.accountSearch.BillingCountry='UK';
            inboundCall.accountSearch.BillingState='state';
            inboundCall.accountSearch.BillingStreet='street';
            inboundCall.CheckLeadAddress();
            
            inboundCall.InvokeCustomerCall();
            inboundCall.InvokeEngineerCall();
            inboundCall.InvokeEmployeeCall();
            inboundCall.InvokeHSACall();
            inboundCall.InvokeWasteCall();
            
            List<britishgasCoUkEnterpriseParty.Customer> lstTemp = new List<britishgasCoUkEnterpriseParty.Customer>();
            for(Integer i=0; i < 1; i++)
            {
                britishgasCoUkEnterpriseParty.Customer customerInfo = new britishgasCoUkEnterpriseParty.Customer();
                
                customerInfo.CustomerID = new britishgasCoUkEnterpriseParty.PartyKey();
                customerInfo.CustomerID.PartyID = 'TEMPUCRN' + i;
                
                customerInfo.PersonBiographicData = new britishgasCoUkEnterpriseParty.PersonBiographicData();
                customerInfo.PersonBiographicData.PersonName = new britishgasCoUkEnterpriseParty.PersonName();
                customerInfo.PersonBiographicData.PersonName.FirstName = 'Firstname' + i;
                customerInfo.PersonBiographicData.PersonName.Surname = 'Surname' + i;
                
                
                britishgasCoUkEnterpriseAddress.AddressUsage addressInfo = new britishgasCoUkEnterpriseAddress.AddressUsage(); 
                addressInfo.DefaultAddressIndicator = 'True';
                addressInfo.Address = new britishgasCoUkEnterpriseAddress.BasicAddressDetail();
                addressInfo.Address.BasicAddress = new britishgasCoUkEnterpriseAddress.BasicAddress();
                addressInfo.Address.BasicAddress.BuildingName = 'Phoneix Bldg.';
                addressInfo.Address.BasicAddress.BuildingNumber = 'A-' + i;
                addressInfo.Address.BasicAddress.Country = 'UK';
                addressInfo.Address.BasicAddress.County = 'Leicester';
                addressInfo.Address.BasicAddress.Postcode = 'LE1 5UJ';
                addressInfo.Address.BasicAddress.PostalTownOrCity = 'Leicester';
                
                //String strAddress = inboundCall.getAddress(addressInfo.Address.BasicAddress);
                
                britishgasCoUkEnterpriseCustomeracco.SimpleCustomerAccount simpleAcc = new britishgasCoUkEnterpriseCustomeracco.SimpleCustomerAccount();
                simpleAcc.BillingAddressHistory = new List<britishgasCoUkEnterpriseAddress.AddressUsage>{addressInfo};
                customerInfo.SimpleAccount = new List<britishgasCoUkEnterpriseCustomeracco.SimpleCustomerAccount>{ simpleAcc };
                
                lstTemp.add(customerInfo);
            }
            
            //inboundCall.generateCustomerUCRNSelectionData(lstTemp);
            
            Pagereference pageRef = Page.InboundCall;
            pageRef.getParameters().put('cUCRN', 'TEMPUCRN0');
            Test.setCurrentPageReference(pageRef);
            inboundcall.selectUCRN();
            
            //inboundcall.parseAccountAddressData(account);
        }
    }
    static testmethod void customerCallTestMethod1()
    {
        createData();
        opp=[select Id,CHI_Lead_Id1__c,name from opportunity where id =:opp.Id];
        InboundCallController inboundCall= new InboundCallController();
        //inboundCall.ConfirmAccountAddress = true;
        inboundCall.accountSearch=account;
        inboundCall.setLeadNumber('');
        inboundCall.opp = new list<Opportunity>();
        inboundCall.opp.add(opp); 
        inboundCall.InvokeCustomerCall();
        inboundCall.CheckProspectAdd();
        inboundCall.Prospectdisplay();
        inboundCall.skipProfileSelection();
    }
    
    
    static testmethod void commercialMethod1_exisitngOpporunity()
    {
    	createData();
        opp=[select Id,CHI_Lead_Id1__c,name from opportunity where id =:opp.Id];
        InboundCallController inboundCall= new InboundCallController();
        inboundCall.accountSearch=account;
        inboundCall.InvokeCommerialCall();
        
        
        
        // Continue button without selecting one opportunity
        inboundCall.contiueBtnMethod();
        
        // Continue button after selecting one Opporunity
        for(InboundCallController.oppClass oppClass: inboundCall.opportunityClassList)
        {
        	oppClass.isSelect = true;
        }
        inboundCall.contiueBtnMethod();
        
        inboundCall.createNew();
        
        inboundCall.salesAptBtn();
        
        inboundCall.exitInbound();
        
    }
    
    static testmethod void commercialMethod1_exisitngSearchOpporunity()
    {
    	createData();
        opp=[select Id,CHI_Lead_Id1__c,name from opportunity where id =:opp.Id];
        InboundCallController inboundCall= new InboundCallController();
        inboundCall.accountSearch=account;
        inboundCall.setLeadNumber(opp.CHI_Lead_Id1__c);
        inboundCall.leadNumberExist=true;
        inboundCall.InvokeCommerialCall();
    }
    
    static testmethod void commercialMethod2_nonTrial()
    {
    	
    	Sub_Patch__c sub = TestClassHelper.createSubPatch(null);
    	
    	insert sub;
    	
    	Postcode_sector__c nonTrial = TestClassHelper.createPostCode(sub.Id);
    	nonTrial.NotAvailableFor__c = 'Small Commercial';
    	insert nonTrial;
    	
    	Account Acc = new Account (Name = 'Test Record', BillingStreet = 'Billing Street', BillingCity = 'BillingCity', BillingPostalCode = nonTrial.Name+'ET', BillingState = 'Billing State');
    	InboundCallController inboundCall= new InboundCallController();
        inboundCall.accountSearch=Acc;
        inboundCall.InvokeCommerialCall();
        
        
        
    }
    
    static testmethod void commercialMethod1_newOpporunity()
    {
    	Account Acc = new Account (Name = 'Test Record', BillingStreet = 'Billing Street', BillingCity = 'BillingCity', BillingPostalCode = 'ZZ1 2LG', BillingState = 'Billing State');
    	InboundCallController inboundCall= new InboundCallController();
        inboundCall.accountSearch=Acc;
        inboundCall.InvokeCommerialCall();
        
        // Test mandatory Field;
        inboundCall.createRecords();
        inboundCall.checkOpp();
        inboundCall.validateOpp();
        inboundCall.oppurtunitySelect = new Opportunity(Boiler_Size__c =40 ,Number_of_boilers_in_scope_to_replace__c = 1, Number_Of_Radiators__c = 12, 
        Number_of_Additional_Appliances__c = 1,Total_number_of_boilers_onsite__c=1, Fuel_Type__c = 'Natural Gas', Job_Type__c = 'Boiler', Description_of_Work_Required__c = 'Test' );
       
        inboundCall.validateOpp();
        inboundCall.createRecords();
        for(Contact c : inboundCall.contact)
        {
        	c.LastName = 'testName';
        	break;
        }
        inboundCall.createRecords();
        
        for(Contact c : inboundCall.contact)
        {
        	c.LastName = 'testName';
        	c.Primary_Contact__c = true;
        	c.FirstName = 'FirstName';
        	c.Email__c = 'test@email.com';
        	c.Contact_type__c = 'Onsite Contact';
        	c.MobilePhone = '07777777777';
        	break;
        	
        }
        inboundCall.createRecords();
        inboundCall.CallMode = new CallMode();
        inboundCall.DisplayMode = new DisplayMode();
    }
    
    
    
    
}