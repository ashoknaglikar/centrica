public class getActivityJSON{
	public Integer totalResults;	//2
	public Integer limit_x;	//10
	public Integer offset;	//0
	public cls_items[] items;
	public cls_links[] links;
	public class cls_items {
		public string apptNumber;	//4225371
		public String resourceId;	//33001
		public String date_x;	//2016-08-31
		public String status;	//pending
		public string XA_eta;
	}
	class cls_links {
		public String rel;	//canonical
		public String href;	//https://api.etadirect.com/rest/ofscCore/v1/activities/custom-actions/search?searchInField=customerName&searchForValue=testCustomerName&dateFrom=2016-08-31&dateTo=2016-08-31&limit=10&offset=0
	}
	public static getActivityJSON parse(String json){
		return (getActivityJSON) System.JSON.deserialize(Utilities.mogrifyJSON(json, new map<string, string>{'limit'=>'limit_x', 'date'=>'date_x'}), getActivityJSON.class);
	}

	
}