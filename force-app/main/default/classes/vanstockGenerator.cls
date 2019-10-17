public class vanstockGenerator {

	public Employee__c empObj{get;set;}
	public boolean showDeactivateConf{get;set;}
	public boolean showGenNew{get;set;}
	Utilities util = new Utilities();
	
	ApexPages.StandardController contObj;

	public vanstockGenerator(ApexPages.StandardController controller) {

		contObj = controller;
	    empObj =  (Employee__c) controller.getRecord();
	    showDeactivateConf= false;
	    showGenNew = false;
    
    }

    public pagereference generateNewVanstockNumber()
    {
        
    	
    	return contObj.save();
    }



    public pagereference deactivevanStock()
    {/*
    	empObj.Van_Stock_Card_Other__c = null;
    	empObj.TP_card_number__c = null;
    */
        empObj.Vanstock_Status__c = 'Deactivation';
    	return contObj.save();
    }
    
    public void checkDeactivateFirst()
    {
        util.setErrorMsg(false, 'Are you sure you want to deactive the exiting details? Click Yes to confirm!');
        showDeactivateConf = true;
        showGenNew = false;
    }
    
    public void checkGenerateNewVSNumber()
    {
        util.setErrorMsg(true, 'Are you sure you want to generate new VS number? Click Yes to confirm!');
        showDeactivateConf = false;
        showGenNew = true;
        
        if(empObj.Van_Stock_Card_Other__c==null || empObj.Van_Stock_Card_Other__c=='')
    	{
    	    string empNumber = empObj.Employee_Number__c;
            integer j = empNumber.length();
            while(j<7)
            {
                empNumber= '0'+empNumber;
                j++;
            }
    		empObj.Van_Stock_Card_Other__c = 'AA'+empNumber+'A';
    	}else 
    	{
    	    
    	    string existingVanStockNum = empObj.Van_Stock_Card_Other__c.touppercase();
    	    string firstletter = existingVanStockNum.substring(0,1);
    	    string secondletter = existingVanStockNum.substring(1,2);
    	    string remianingString = existingVanStockNum.substring(2,existingVanStockNum.length()-1);
    	    string lastletter = existingVanStockNum.substring(existingVanStockNum.length()-1,existingVanStockNum.length());
    	    
    	    system.debug('firstletter Before -->'+firstletter);
    	    system.debug('secondletter Before -->'+secondletter);
    	    system.debug('remianingString Before -->'+remianingString);
    	    system.debug('lastletter Before -->'+lastletter);
    	    
    	    if(secondletter == 'Z')
    	    {
    	        if(firstletter == 'Z')
    	        {
    	            //increment the Last letter 
    	            lastletter = getNextChar(lastletter);
    	            empObj.Van_Stock_Card_Other__c = 'AA'+remianingString+lastletter;
    	            
    	        }else
    	        {
    	            //increment firstLetter;
        	        firstletter = getNextChar(firstletter);
    	        }
    	    }else
    	    {
    	        //just increment second letter;
    	        secondletter = getNextChar(secondletter);
    	        
    	    }
    	    
    	    system.debug('firstletter after -->'+firstletter);
    	    system.debug('secondletter after -->'+secondletter);
    	    system.debug('remianingString after -->'+remianingString);
    	    system.debug('lastletter after -->'+lastletter);
    	    
    	    empObj.Van_Stock_Card_Other__c = firstletter+secondletter+remianingString+lastletter;
    	    
    	    
    		//empObj.
    	}
        empObj.Vanstock_Status__c = 'Activation';
    }
    

    public static String getNextChar(String oldChar) {
	    String key = 'ABCDEFGHJKLMNPQRSTUVWXYZA';
	    Integer index = key.indexOfChar(oldChar.charAt(0));
	    return index == -1? null: key.substring(index+1, index+2);
	}


}