public class honeyCombFinanceJSONFulfilmentResponse{
   
		public String applicationId;	//123456
		public boolean fulfilmentAccepted;      //true
	
	public static honeyCombFinanceJSONFulfilmentResponse parse(String json){
		return (honeyCombFinanceJSONFulfilmentResponse) System.JSON.deserialize(json, honeyCombFinanceJSONFulfilmentResponse.class);
	}
}