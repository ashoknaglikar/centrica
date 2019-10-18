@isTest
private class AccountEditViewController_Test {
    // i am adding a comment
    static testMethod void accountTestMethod(){
    //Select a.Number_of_Bedrooms__c, a.Gas_Supply_At_Address__c, a.Current_Heating_System__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity From Account a
        Account m_account;
        Account account=new Account();
        account.Name='Test Account';
        account.Number_of_Bedrooms__c=1;
        account.Gas_Supply_At_Address__c=true;
        account.Current_Heating_System__c=true;
        account.BillingStreet='Test Street';
        account.BillingState='Test State';
        account.BillingPostalCode='441111';
        account.BillingCountry='Test Country';
        account.BillingCity='Test City';
        account.Water_Hardness__c=0;
        
        insert account;
        
        AccountEditViewController controller= new AccountEditViewController();
        controller.setAccount(account);
        controller.getAccount();
        controller.getTempData();
        controller.getAccountAddress();
        controller.getGasSupply();
        controller.getHeatingSystem();
        
        account.Gas_Supply_At_Address__c=false;
        account.Current_Heating_System__c=false;
        update account;
        controller.getGasSupply();
        controller.getHeatingSystem();

        
        

    }
}