public class newProductHoldingClass {
    
    
    String strUsername=system.label.PH_Username;
    String strPwd=system.label.PH_Password;
    string client_id = system.label.PH_Client_ID;
    string client_secret = system.label.PH_Client_Secret;
    string grant_type = system.label.PH_Grant_Type;
    string scope = system.label.PH_Scope;
    string clientcertificate = system.label.PH_Client_Cetificate_Name;
    string returl = system.label.PH_Return_URL;
    
    integer timeOut = integer.valueof(system.label.PH_Time_Out);
    public string loginDetails()
    {
        try{
        string loginUrl = system.label.PH_Base_Url+system.label.PH_Login_URL;
        
        Http m_http = new Http();
        HttpRequest req = new HttpRequest();
        
        String content = 'username='+EncodingUtil.urlEncode(strUsername, 'UTF-8')+'&password='+EncodingUtil.urlEncode(strPwd, 'UTF-8')
                        +'&client_id='+EncodingUtil.urlEncode(client_id, 'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(client_secret, 'UTF-8')
                        +'&grant_type='+EncodingUtil.urlEncode(grant_type, 'UTF-8')+'&scope='+EncodingUtil.urlEncode(scope, 'UTF-8')
                        +'&sfuid='+userinfo.getuserId()
                        +'&redirect_uri='+returl;
        
        req.setEndpoint(loginUrl);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');        
        req.setMethod('POST');
        req.setBody(content);
        req.setTimeout(timeOut);
        req.setClientCertificateName(clientcertificate);
        
        system.debug('Request -->'+req);
        httpResponse response = m_http.send(req);
        
        string responseBody = response.getBody();
        
        system.debug('Login in reponse--->'+responseBody);
        
        string accesstoken;
        integer expiresIn;
        //resp is a JSON string
        JSONParser parser = JSON.createParser(responseBody);
        while (parser.nextToken()!= null) {
        	if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
        		String fieldName = parser.getText();
        		parser.nextToken();
        		if(fieldName == 'access_token') {
        			accesstoken = parser.getText();
           		} else if(fieldName == 'expires_in'){
        			expiresIn = parser.getIntegerValue();
           		}
            }
        }
        
        
        return accesstoken;
        }catch (exception e)
        {
            system.debug(e);
            return null;
        }
            
    }
    
    
    public postcodeReposnse getAllAddress(string accesstoken, string postcode)
    {
        try{
        
        
        string postCodeUrl = system.label.PH_Base_Url+system.label.PH_Postcode_URL+postcode;
        
        Http m_http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(postCodeUrl);
        req.setHeader('Content-Type','application/json');        
        req.setMethod('GET');
        req.setClientCertificateName(clientcertificate);
        req.setTimeout(timeOut);
        string authorizationHeader = 'Bearer ' +accesstoken;
        req.setHeader('Authorization', authorizationHeader);
        //req.setHeader('env', 'blue');
        httpResponse response = m_http.send(req);
        
        string responseBody = response.getBody();
        
        system.debug('Login in reponse--->'+responseBody);
        
        
		return (postcodeReposnse) System.JSON.deserialize(responseBody, postcodeReposnse.class);
        }catch(Exception e)
        {
            system.debug('Exception---'+e);
            return null;
        }
	}
	
	public productHoldingReponseClass getProductHoldingByAddressId(string accesstoken, string address_id)
	{
	   try{
	    string postCodeUrl = system.label.PH_Base_Url+system.label.PH_Address_Url+address_id;
        
        Http m_http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(postCodeUrl);
        req.setHeader('Content-Type','application/json');        
        req.setMethod('GET');
        req.setClientCertificateName(clientcertificate);
        req.setTimeout(timeOut);
        string authorizationHeader = 'Bearer ' +accesstoken;
        req.setHeader('Authorization', authorizationHeader);
        //req.setHeader('env', 'blue');
        httpResponse response = m_http.send(req);
        
        string responseBody = response.getBody();
        
        system.debug('Login in reponse--->'+responseBody);
        
        productHoldingReponseClass responseObj =  productHoldingReponseClass.parse(responseBody);
	    return responseObj;
	   }catch(exception e)
	   {
	       system.debug('Exception ----'+e);
	       return null;
	   }
	   
	}
        
        
      
   public class Addresses {
		public String street;
		public String town;
		public String id;
		public String firstLine;
		public string connectedBoilerEligible;
	}
   public class postcodeReposnse{
	public Integer totalRows;
	public Integer offset;
	public List<Addresses> addresses;
   }	
    

}