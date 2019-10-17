global class barclaysIntegration {
    
    public opportunity opp{get;set;}
    public decimal financeAmount {get;set;}
    public string financeRefNum{get;set;}
    
    
    utilities util = new utilities();
    string CHILeadRef;
    string financeAmount_Str;
    string submissionUrl;
    string redirectURL;
    String title;
    String lastName;
    String firstName;
    String email;
    String houseNumber ;
    String firstLine;
    String postCode;
    String city;
    String county ;
    
    public barclaysIntegration()
    {
        id oppId = System.currentPageReference().getParameters().get('oppId');  
        
        opp = [Select id, Amount,  Sum_of_Deposits__c,Bill_title__c, Bill_firstName__c, Bill_LastName__c, CHI_Lead_Id1__c , Final_Monies_Outstanding__c,
               Product_interest__c, Bill_Street__c ,Bill_City__c ,Bill_Post_Code__c, Bill_State__c, Account.Primary_contact__r.Email__c,Account.Primary_contact__r.FirstName,Account.Primary_contact__r.LastName,
               Account.Primary_contact__r.Salutation,Account.Primary_contact__r.MailingStreet,Account.Primary_contact__r.MailingCity, Account.Primary_contact__r.MailingPostalCode,
               Finance_Proposal_Id__c from Opportunity where id = : oppId];
               
        financeAmount = opp.Final_Monies_Outstanding__c;    
        //financeRefNum = opp.CHI_Lead_Id1__c;
        
        //CHILeadRef = financeRefNum;
        
       
        
        submissionUrl = system.label.BarclaysEndPoint;
        
        redirectURL = system.label.BarclaysRedirect;
        
        title = opp.Bill_title__c!=null && opp.Bill_title__c!= '' ? opp.Bill_title__c : (opp.Bill_title__c =opp.Account.Primary_contact__r.Salutation);
        
        lastName = opp.Bill_LastName__c !=null && opp.Bill_LastName__c!= '' ? opp.Bill_LastName__c : (opp.Bill_LastName__c =opp.Account.Primary_contact__r.LastName);
        
        firstName = opp.Bill_FirstName__c!=null && opp.Bill_FirstName__c!= '' ? opp.Bill_FirstName__c : (opp.Bill_FirstName__c =opp.Account.Primary_contact__r.FirstName);
        
        email = opp.Account.Primary_contact__r.Email__c;
        
        firstLine = opp.Bill_Street__c!=null && opp.Bill_Street__c!= '' ?  opp.Bill_Street__c :  (opp.Bill_Street__c =opp.Account.Primary_contact__r.MailingStreet);
        
        postCode = opp.Bill_Post_Code__c!=null && opp.Bill_Post_Code__c != '' ? opp.Bill_Post_Code__c : (opp.Bill_Post_Code__c=opp.Account.Primary_contact__r.MailingPostalCode); 
        
        city = opp.Bill_City__c!=null && opp.Bill_City__c!='' ?  opp.Bill_City__c : (opp.Bill_City__c = opp.Account.Primary_contact__r.MailingCity);
        
        county = opp.Bill_State__c;
               
        
    }
    
    public pagereference createApplication()
    {
    	financeAmount_Str = string.valueof(financeAmount);
    	system.debug('financeRefNum-->'+financeRefNum); 
    	if(financeRefNum!=null && financeRefNum!='')
    	{
    		system.debug(!financeRefNum.isNumeric());
    		if(financeRefNum.isNumeric())
    		{
    			financeRefNum = null;
    			util.seterrorMsg(true,'Only aplhabets can be used as a suffix.');
    			return null;
    		}
    		CHILeadRef = opp.CHI_Lead_Id1__c + '-'+financeRefNum;
    	}else
    	{
    		CHILeadRef = opp.CHI_Lead_Id1__c;
    	}
    	
    	system.debug('New Ref Number -->'+financeRefNum);
    	
        string username = system.label.BarclaysUsername;
        
        string passwrod = system.label.BarclaysPassword;
        
        
        
        HttpRequest createApplication = new HttpRequest();
        createApplication.setEndpoint(submissionUrl);
        createApplication.setMethod('POST');
        createApplication.setTimeout(60000);
        //createApplication.setHeader('soapAction','serviceName/operation');
        createApplication.setHeader('Content-Type','text/xml');
        
        //create login XML
        createApplication.setBody('<?xml version="1.0" encoding="utf-8"?>'+
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bar="http://www.barclays-partnerfinance.com/">'+
        '<soapenv:Header/>'+
        '<soapenv:Body>'+
        '<SubmitNewApplicationShort xmlns="http://www.barclays-partnerfinance.com/">'+
            '<newApplicationDataShort>'+
                '<UserCredentials>'+
                    '<LoginName>'+username+'</LoginName>'+
                    '<Password>'+passwrod+'</Password>'+
                '</UserCredentials>'+
                '<ProposalShort>'+
                      '<ClientReference>'+CHILeadRef+'</ClientReference>'+
                      '<CashPrice>'+financeAmount_Str+'</CashPrice>'+
                '</ProposalShort>'+
                '<Goods Type="CH1">'+
                      '<Description>'+opp.Product_interest__c+'</Description>'+
                      '<Quantity>1</Quantity>'+
                '</Goods>'+
                '<Customer>'+
                     '<Title>'+title+'</Title>'+
                      '<Forename>'+firstName+'</Forename>'+
                      '<Initial />'+
                      '<Surname>'+lastName+'</Surname>'+
                      '<EmailAddress>'+email+'</EmailAddress>'+
                '</Customer>'+
                '<Address>'+
                      '<HouseNumber>1</HouseNumber>'+
                      '<HouseName>2</HouseName>'+
                      '<Flat>1</Flat>'+
                      '<Street>'+firstLine+'</Street>'+
                      '<District/>'+
                      '<Town>'+city+'</Town>'+
                      '<County>'+county+'</County>'+
                      '<Postcode>'+postCode+'</Postcode>'+
                '</Address>'+
            '</newApplicationDataShort>'+
        '</SubmitNewApplicationShort>'+
        '</soapenv:Body>'+
        '</soapenv:Envelope>');
      
      system.debug('Application -->'+createApplication);
          
      try{
          Http http = new Http();
          HttpResponse applicationResponse = http.send(createApplication);     
          System.debug('Result from URL call: ' + applicationResponse.getBody());
        
          system.debug('applicationResponse-- >'+applicationResponse);
          
          //message = applicationResponse.getBody();
          
          string Token = BGProductHoldingServiceHelper.readXML(applicationResponse, 'Token');
          string proposalId = BGProductHoldingServiceHelper.readXML(applicationResponse, 'ProposalID');
          system.debug('Token-->'+Token);
          system.debug('proposalId-->'+proposalId);
          
          if(Token!=null && Token.startswith('0000'))
          {
              string Error = readAttribute(applicationResponse, 'Errors', 'IsError');
              string ErrorDetails = readAttribute(applicationResponse, 'ErrorDetail','Message');
              system.debug('Error-->'+Error);
              system.debug('Error-->'+ErrorDetails);
              util.seterrorMsg(true,ErrorDetails);
              return null;
          }else
          {
          	  opp.BarclaysFinanceRef__c = financeRefNum;	
              opp.FinanceAmountApplied__c = financeAmount;
              opp.Finance_Proposal_Id__c = proposalId;
              opp.FinanceApplicationStatus__c = 'Applied';
              update opp;
                
              string redirectPageref  =redirectURL+Token;
              pagereference barclaysRedirect = new pagereference(redirectPageref);
              return barclaysRedirect;
          }
      }catch (exception e)
      {
          util.seterrorMsg(true,e.getmessage());
          return null;
      }
      
        
    }
    
    
    public string readAttribute(HttpResponse response, String tag, string attribute){
       String text;                            
        XmlStreamReader responseReader = new XmlStreamReader(response.getBody());
        
        while(responseReader.hasNext()) {               
            if (responseReader.getEventType() == XmlTag.START_ELEMENT){                         
                if (tag == responseReader.getLocalName()){
                    text = responseReader.getAttributeValue(null, attribute);
                    break;                                                                                      
                }
            }                                           
            responseReader.next();
        }           
        system.debug(tag+' tag text is: '+text);
        return text;
    }
    

}