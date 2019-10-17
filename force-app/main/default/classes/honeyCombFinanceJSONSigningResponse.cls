public class honeyCombFinanceJSONSigningResponse{
   
		public String applicationId;	//123456
		public string signingLink;      //https://honeycombexternal.com/signing/123456
		public date expirationDate;     //2019-02-01
	
	
	public static honeyCombFinanceJSONSigningResponse parse(String json){
		return (honeyCombFinanceJSONSigningResponse) System.JSON.deserialize(json, honeyCombFinanceJSONSigningResponse.class);
	}
}