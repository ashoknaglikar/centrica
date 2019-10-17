public class freedomFinanceDecisionUpdateResponse{
	public cls_DecisionUpdateResponse DecisionUpdateResponse;
	public class cls_DecisionUpdateResponse {
		public String proposalNo;	//BG378090
		public String status;	//REFER
		public String notes;	//Please send proof of address
		public String appStatus;	//Referred
		public String appSubStatus;	//Quotation
	}
	public static freedomFinanceDecisionUpdateResponse parse(String json){
		return (freedomFinanceDecisionUpdateResponse) System.JSON.deserialize(json, freedomFinanceDecisionUpdateResponse.class);
	}
}