global class customerportalDiscountAmountResponse {
    public string LeadID;
    public string QuoteID;
    public string voucherName;
    public string voucherCode;
    public Decimal voucherAmount;
    public Decimal initialQuotePrice;
    public Decimal netQuotePrice;
    public list<String> errorList = new list<String>();
}