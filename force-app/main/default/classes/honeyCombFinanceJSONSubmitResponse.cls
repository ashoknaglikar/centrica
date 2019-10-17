public class honeyCombFinanceJSONSubmitResponse{     
   
    Public String applicationId; //153215DSA321BA
    Public String externalUniqueReference; //AB123ASD512351
    Public String status; //accepted
    Public date offerExpirationDate; //2019-01-12
    Public cls_finance finance; 
    
    public class cls_finance {
        public String financeProductCode;   //UPL
        public double advance; //1250
        public Integer termMonths;  //36
        public Double interestRate;  //1.23
        public Double deposit; //311.51
        public Double APR;  //9.9
        public Double costOfCredit; //187.5
        public double totalAmountRepayable; //1437.5
        public double monthlyRepayment; //39.94
        public double firstRepayment; //39.94
        public double finalRepayment; //39.6
        public string tier;
    }
    
    public static honeyCombFinanceJSONSubmitResponse parse(String json){
        return (honeyCombFinanceJSONSubmitResponse) System.JSON.deserialize(json, honeyCombFinanceJSONSubmitResponse.class);
    }

}