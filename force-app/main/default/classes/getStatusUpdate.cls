//
//Generated by AdminBooster
//

public class getStatusUpdate{
	public String externalApplicationReference;	//string
	public Integer applicationId;	//0
	public String applicationStatus;	//string
	public String agreementNumber;	//string
	public String clientCustomerAccessToken;	//string
	public cls_finance finance;
	public datetime createDate;	//2019-01-10T12:37:22.908Z
	public datetime liveDate;	//2019-01-10T12:37:22.908Z
	class cls_finance {
		public decimal advance;	//0
		public decimal interestCharge;	//0
		public decimal term;	//0
		public decimal monthlyInstallment;	//0
		public decimal apr;	//0
		public decimal deposit;	//0
		public decimal totalAmountPayable;	//0
		public decimal subsidy;	//0
		public decimal commission;	//0
	}
	public static getStatusUpdate parse(String json){
		return (getStatusUpdate) System.JSON.deserialize(json, getStatusUpdate.class);
	}
/*
	static testMethod void testParse() {
		String json=		'{'+
		'  "externalApplicationReference": "string",'+
		'  "applicationId": 0,'+
		'  "applicationStatus": "string",'+
		'  "agreementNumber": "string",'+
		'  "clientCustomerAccessToken": "string",'+
		'  "finance": {'+
		'    "advance": 0,'+
		'    "interestCharge": 0,'+
		'    "term": 0,'+
		'    "monthlyInstallment": 0,'+
		'    "apr": 0,'+
		'    "deposit": 0,'+
		'    "totalAmountPayable": 0,'+
		'    "subsidy": 0,'+
		'    "commission": 0'+
		'  },'+
		'  "createDate": "2019-01-10T12:37:22.908Z",'+
		'  "liveDate": "2019-01-10T12:37:22.908Z"'+
		'}';
		getStatusUpdate obj = parse(json);
		System.assert(obj != null);
	}
	*/
}