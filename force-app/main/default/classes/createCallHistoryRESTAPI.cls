@RestResource(urlMapping='/createCallHistory/*')
global with sharing class createCallHistoryRESTAPI {
	
	 //**************************************************
    //Private methods 
    //**************************************************
    
    //Check if Object is NULL or Blank
    global static boolean isNotNullOrEmpty(string str)
    {
        return str!=null || !String.isBlank(str); 
    }
    
    // Create a callHistory 
    public static Call_History__c createHistory(string callDate, string callDirection, string callType, string duration, string empLanId, string Start, string endDatetime, string phoneNumber, string consultMade , string consultRecieved)
    {
        //check if the fields provided on not empty
        if(isNotNullOrEmpty(callDirection)  && isNotNullOrEmpty(duration))
        {
        	
            Call_History__c newHistory = new Call_History__c();
            //newHistory.Call_Date__c = date.parse(callDate);
            newHistory.Call_Direction__c = callDirection;
            newHistory.Call_Type__c = callType;
            newHistory.Duration__c = decimal.valueof(duration);
            newHistory.Start__c = datetime.parse(Start);
            newHistory.End__c = datetime.parse(endDatetime);
            newHistory.Phone_Num__c = phoneNumber;
            newHistory.Emp_LAN_Id__c = empLanId; 
            newHistory.Consult_Made__c = consultMade; 
            newHistory.Consult_Recieved__c = consultRecieved; 
            return newHistory;    
              
        }
        else 
        {
            System.Debug('Required field values are not provided here');
            return null;
        }
    }
    
    
    //====================================================================================
    // *** REST POST *** : Require field should not be empty, method to post a new Call History
    //====================================================================================
    @HttpPost
    global static ResponseHandler post(string callDate, String  callDirection, String callType, string duration, string empLanId , string Start , string endDateTime, string phoneNumber, string consultMade , string consultRecieved)
    {
    	
        ResponseHandler response = new ResponseHandler();
        try
        {
            Call_History__c  newHistory =  createHistory(callDate, callDirection, callType, duration, empLanId, Start, endDateTime, phoneNumber, consultMade, consultRecieved);
            if(newHistory!=null)
            {
            insert newHistory;
            List<sObject> thesObjectList = new List<sObject>();
            thesObjectList.add((sObject)newHistory);
            response.Data = thesObjectList;
            response.Status = 'Success';
            response.ErrorCode = null;
            response.Message = null;
            }
        } 
        catch(exception e) 
        {
            //Add custom error code when you could not insert a record
            response.ErrorCode = 'Oyecode - 0001';
            response.Status = 'error';
            response.Message = e.getMessage();
        }
        return response;   
    }
    
    
    

}