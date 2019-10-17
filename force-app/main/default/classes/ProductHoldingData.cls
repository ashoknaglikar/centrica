global class ProductHoldingData
{
    public ProductHolding__c ProductHolding;
    public List<ProductHoldingAccount__c> ProductHoldingAccounts;
    //changes for IPD 3653 begin - dated 2/11/2013
    //public List<ContactInfo> ContactInfos{get; set;}        
    public List<ContactInfo> NewContactInfos{get; set;}
    //changes for IPD 3653 end   - dated 2/11/2013
 
    public ProductHoldingData()
    {
        ProductHolding = new ProductHolding__c();
        ProductHoldingAccounts = new List<ProductHoldingAccount__c>();
        //changes for IPD 3653 begin - dated 2/11/2013
        //ContactInfos= new List<ContactInfo>();
        NewContactInfos= new List<ContactInfo>();
        //changes for IPD 3653 end   - dated 2/11/2013

    }
}