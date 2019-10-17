public with sharing class CombiSwapCont {
	public boolean result{get;set;}
	public CombiSwapQuestion__c combiSwap;
	
	public CombiSwapQuestion__c getcombiSwap(){
		return this.combiSwap;
	}  
	public void setcombiSwap(CombiSwapQuestion__c c)
	{
		this.combiSwap=c;
	    
	}
	
	public CombiSwapCont()
	{
		result = false;
	}
}