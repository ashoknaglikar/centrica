public class CreditCheckControler {   
    
    public Credit_Check__c oCreditCheck;
    private boolean renderDepositSection=false;
    private String oppId;
    public Opportunity opp;
    private Date birthdate;
    private String depositErrText;
    
    public boolean getRenderDepositSection() {
    System.debug('Returning renderDepositSection ' + renderDepositSection);
    return renderDepositSection;
    }
    
    public String getDepositErrText() {
    System.debug('Returning depositErrText ' + depositErrText);
    return depositErrText;
    }
    
    public Opportunity getOpp()
    {
    	return opp;
    }

   	public Credit_Check__c getOCreditCheck() {
        if(oCreditCheck==null)
        retrievePrimaryContact();
        return oCreditCheck;
    }
       
    public PageReference deposit()
    {
      if(opp.Accept_Quote_Amt__c==0 || opp.Accept_Quote_Amt__c==null)
      {
      	depositErrText = ' Error computing deposit, no \'Accepted\' Quote found on CHI Lead';
      	return null;
      }
      
      System.debug('Overriden values' + oCreditCheck.Override__c + ' , ' + oCreditCheck.Deposit_Percent_Reqd__c  + ' , ' +oCreditCheck.Deposit_Required__c);
      
      if(oCreditCheck.Override__c)
      {   
          oCreditCheck.Deposit_Percent_Reqd__c=computeDeposit(oCreditCheck.Deposit_Percent_Reqd__c);
          oCreditCheck.Deposit_Required__c=((oCreditCheck.Deposit_Percent_Reqd__c * opp.Accept_Quote_Amt__c)/100) ;
      }
      else
      {
          oCreditCheck.Deposit_Percent_Reqd__c=computeDeposit(0);
          oCreditCheck.Deposit_Required__c=((oCreditCheck.Deposit_Percent_Reqd__c * opp.Accept_Quote_Amt__c)/100) ;
      }
      renderDepositSection=true;
      return null;
    }
    
    public PageReference submit()
    {
      oCreditCheck.Search_Date__c=Datetime.now();
      opp.Deposit_Amount__c=oCreditCheck.Deposit_Required__c;
      Database.insert(oCreditCheck);
      Database.update(opp);
     
      return new PageReference('/' + oppId);
    }
    
    private void retrievePrimaryContact()
    {
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        System.debug('Opp Id is ' + oppId);
        opp = [Select o.Account.Primary_Contact__r.Salutation, o.Account.Primary_Contact__r.FirstName,
                o.Account.Primary_Contact__r.LastName, o.Account.Primary_Contact__r.Gender__c, 
                o.Account.Primary_Contact__r.MailingCity, o.Account.Primary_Contact__r.MailingState,
                o.Account.Primary_Contact__r.MailingStreet, o.Account.Primary_Contact__r.MailingPostalCode,
                o.Account.Primary_Contact__r.MailingCountry, o.Account.Primary_Contact__c,o.Accept_Quote_Amt__c,
                o.Account.Primary_Contact__r.Birthdate 
                FROM Opportunity o WHERE id=:oppId];
          
         oCreditCheck= new Credit_Check__c();
         oCreditCheck.Title_Searched__c=opp.Account.Primary_Contact__r.Salutation;
         oCreditCheck.First_Name_Searched__c=opp.Account.Primary_Contact__r.FirstName;
         oCreditCheck.Last_Name_Searched__c=opp.Account.Primary_Contact__r.LastName;
         oCreditCheck.Gender__c=opp.Account.Primary_Contact__r.Gender__c;
         oCreditCheck.Street_Searched__c=opp.Account.Primary_Contact__r.MailingStreet;
         oCreditCheck.City_Searched__c=opp.Account.Primary_Contact__r.MailingCity;
         oCreditCheck.County_Searched__c=opp.Account.Primary_Contact__r.MailingState;
         oCreditCheck.Postcode_Searched__c=opp.Account.Primary_Contact__r.MailingPostalCode;
         oCreditCheck.Country_Searched__c=opp.Account.Primary_Contact__r.MailingCountry ;
         oCreditCheck.Contact__c=opp.Account.Primary_Contact__c;
    }
    
     private double computeDeposit(double multiplier)
     {    
        boolean locatedAtAddress= oCreditCheck.Located_At_Address__c;
        boolean bankruptDateSet = oCreditCheck.Bankrupt__c;
        double numOfSearches= oCreditCheck.Number_of_Searches__c;
        oCreditCheck.Result__c ='Fail';
         
        if (locatedAtAddress)
        {
            oCreditCheck.Override__c=false;
           
            if(!bankruptDateSet && numOfSearches<9)
            {
                multiplier=10;
                oCreditCheck.Result__c ='Pass';
            }
            else if(!bankruptDateSet && numOfSearches>9)
                multiplier=50;
            else
                multiplier=100;
             
        }
        else
        {
            //manual process
            oCreditCheck.Override__c=true;
            if (multiplier==0)
                multiplier=200;
        }
        System.debug('Multiplier is ' + multiplier);
        return multiplier;
    }
}