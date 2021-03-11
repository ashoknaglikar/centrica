global class customerPortalQuoteJson {

	public boolean acceptNotAllowed;
    public boolean showVoucherCode;
	public list<quoteClass> quoteList;

	public errorClass errorDetail;

	public class quoteClass{
		public boolean validQuote;
		public string sfQuoteId;
		public string quoteName;
		public decimal totalAmountIncVAT;
		public decimal totalAllownacesIncVAT;
		public decimal totalNetAmountIncVAT;
		public string quotePDFId;
		public string warranty;
		public datetime quoteValidTill;

		public list<offer> leadOfferList;

		public list<quoteProductClass> quoteProductList;
		public list<dynamicCustomerPortalJSONClass.ContentVersionJSON> quoteCustomerDocs;

	}

	public class quoteProductClass{
		public string sfQuotePoductId;
		public string sfProductCode;
		public string description;
		public string identifier;
		public decimal quantity;
		public decimal totalAmountIncVAT; 
	}
	
	public class offer
	{
	    public String voucherCode;
	    public String voucherName;
	    public Decimal voucherAmount;
	}

	public class errorClass{
		public string errorCode;
		public string errorMessage;
	}



}