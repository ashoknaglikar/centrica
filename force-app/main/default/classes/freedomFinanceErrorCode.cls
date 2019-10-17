public class freedomFinanceErrorCode {
    public cls_errors Error;
    public class cls_errors{
	    public string errorCode;
	    public string message;
	} 
	
	public static freedomFinanceErrorCode parse(string json)
	{
	    return (freedomFinanceErrorCode) System.JSON.deserialize(json, freedomFinanceErrorCode.class);
	}
	
	
	
	
}