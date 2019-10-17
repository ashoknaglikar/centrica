public class freedomFinanceJSONQuoteResponse{
    public cls_submissions submissions;
	public class cls_submissions {
		public Integer id;	//13
		public Double actualApr;	//14.9
		public String dateCreated;	//2016-02-26T18:40:41Z
		public String lenderCode;	//hcb
		public String lenderName;	//Honeycomb
		public String lenderReference;	//4001324545
		public Integer loanAmountOffered;	//15000
		public Integer loanTerm;	//60
		public Double monthlyRepayment;	//123.45
		public String submissionStatus;	//ACCEPT
		public string notes;
		public double totalRepayable;
		public double totalCostOfCredit;
		public string pricingBand;
	}
	
	
	public static freedomFinanceJSONQuoteResponse parse(String json){
		return (freedomFinanceJSONQuoteResponse) System.JSON.deserialize(json, freedomFinanceJSONQuoteResponse.class);
	}

}