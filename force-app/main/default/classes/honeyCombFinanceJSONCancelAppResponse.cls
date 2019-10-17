public class honeyCombFinanceJSONCancelAppResponse{
   
		public String applicationId;	//123456
		public boolean applicationCancelled;      //true
	
	public static honeyCombFinanceJSONCancelAppResponse parse(String json){
		return (honeyCombFinanceJSONCancelAppResponse) System.JSON.deserialize(json, honeyCombFinanceJSONCancelAppResponse.class);
	}
}