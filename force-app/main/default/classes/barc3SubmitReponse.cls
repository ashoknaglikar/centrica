public class barc3SubmitReponse{
	public String externalApplicationReference;	//string
	public string applicationId;	//0
	public String applicationStatus;	//NEWLY_CREATED
	public static barc3SubmitReponse parse(String json){
		return (barc3SubmitReponse) System.JSON.deserialize(json, barc3SubmitReponse.class);
	}
    /*
	static testMethod void testParse() {
		String json=		'{'+
		'  "externalApplicationReference": "string",'+
		'  "applicationId": 0,'+
		'  "applicationStatus": "NEWLY_CREATED"'+
		'}';
		barc3SubmitReponse obj = parse(json);
		System.assert(obj != null);
	}*/
}