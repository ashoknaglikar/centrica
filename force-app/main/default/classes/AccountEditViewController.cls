/* BGB_CTS: AccountEditViewController 
   Description : This Class is the controller of AccountEditViewComponent.
   Created : 13/10/09 :By Aruna
*/

public class AccountEditViewController {
    Account m_account;
    List<Account> acc; 
    String Address;
    public Account getAccount(){
    	system.debug('getting into get account');
        return this.m_account;
    }  
    public void setAccount(Account account)
    {
    	system.debug('getting into setaccount '+account);
        this.m_account=account;
        system.debug('-------m_account------ '+m_account);
    }
    
    public AccountEditViewController()
    {
    	Address = '';
    }
    public String getTempData()
    {
    	return '';
    }
   public String getAccountAddress()
   {
   		system.debug('-------m_account is------ '+m_account);
   		if(m_account != null)
    	{
    		if(m_account.BillingStreet != null)
    		{
    			Address = m_account.BillingStreet;
    		}
    		if(m_account.BillingCity != null){
    			if(Address != '') Address += ', ';
				Address += m_account.BillingCity;
    		}
    		if(m_account.BillingState != null){
    			if(Address != '') Address += ', ';
    			Address += m_account.BillingState;
    		}
    		if(m_account.BillingCountry != null){
    			if(Address != '') Address += ', ';
				Address += m_account.BillingCountry;
    		}
    		if(m_account.BillingPostalCode != null){
    			if(Address != '') Address += ', ';
    			Address += m_account.BillingPostalCode;
    		}	
    	}
    	
		System.debug('------------------- address = ' + Address);
   		return Address;	
   }
    
    public String getGasSupply(){
        if(m_account.Gas_Supply_At_Address__c){
            return 'Yes';
        }
        system.debug('getting into getgassupply  ');
        return 'No';
    }
    
    public String getHeatingSystem(){
        if(m_account.Current_Heating_System__c){
            return 'Yes';
        }
        system.debug('getting into getheating system  ');
        return 'No';
    }
}