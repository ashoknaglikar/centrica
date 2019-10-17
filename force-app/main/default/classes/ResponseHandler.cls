/***************************************************************************
Name : Response Handler
Created By : Ashok Naglikar
Created Date : June 18, 2015
Description : Response Handler class handle response received on accessing API, 
the operations it supports are related to Call History.
***************************************************************************/
global class ResponseHandler {
    
    //List of custom attributes that we want to check the status of the org
    public String Status {get; set;}
    public List<sObject> Data {get;set;}
    public String Message {get;set;}
    public String ErrorCode {get; set;}
    
    
}