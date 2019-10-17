public with sharing class AccountJSONCreator {

    public String getJSON()
    {
        String AccountName = Apexpages.currentPage().getParameters().get('AccName');
        List<AccountWrapper> wrp = new List<AccountWrapper>();
        for (Account a : [Select a.Id, a.Website, a.Name, a.BillingCountry, a.BillingCity
                            From
                                Account a
                            WHERE Name Like : '%'+AccountName+'%' ]) {
               AccountWrapper w = new AccountWrapper (a.Name, nullToBlank (a.BillingCountry), nullToBlank (a.BillingCity));
               wrp.add(w);
            }
        return JSON.serialize(wrp);
    }

    public String nullToBlank(String val)
    {
        return val == null ?'':val;
    }

    public class AccountWrapper
    {
        String AccName,BillingCountry,BillingCity;

        public AccountWrapper(String aName, String bCountry, String bCity)
        {
            AccName = aName;
            BillingCountry = bCountry;
            BillingCity = bCity;
        }
    }
    /*
    static testMethod void AccountJSONCreatorTest() {
        AccountJSONCreator obj = new AccountJSONCreator();
        obj.getJSON();
    }
    */
}