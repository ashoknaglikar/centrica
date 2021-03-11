//This class is used to invoke OFS REST web service API's GET/PUT/POST ;in order to update unavalabilities in OFS
public class UnavailUpadateInOFS_Rest{

public string userOFS =System.Label.toa_user+'@'+System.Label.toa_Company;
public string passwordOFS =System.Label.toa_password;
public string urlOFS =System.Label.URL_for_updating_Unavailability;




public string searchUnavail( String offset, String dateFrom,String dateTo, string requestURL){
    
    Http http = new Http();
    
    HttpRequest request = new HttpRequest();
    string urlUnavail=urlOFS+'/activities/custom-actions/search?'+requestURL+'&dateFrom='+dateFrom+'&dateTo='+dateTo+'&fields=activityId,resourceId,activityType,status,startTime,endTime,duration,XA_duration,timeZone,timeOfAssignment,timeOfBooking,worktype,date,recordType&limit=100';
    if(offset !=null)
    urlUnavail+='&offset='+offset;
    request.setEndpoint(urlUnavail);
    Blob headerValue = Blob.valueOf(userOFS + ':' + passwordOFS);
    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    system.debug('**'+response.getStatusCode());
    system.debug('**'+response.getBody());
    if (response.getStatusCode() == 200) {
    
        //System.debug('Received the following :');
       
            //System.debug('***'+response.getBody());
       
    }

        return response.getBody();
      


 }
 


public string  getCalendars(string resourceId,string dateFrom,string dateTo){
  
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    String strURL=urlOFS+'/resources/'+resourceId+'/workSchedules/calendarView?dateFrom='+dateFrom+'&dateTo='+dateTo;
    request.setEndpoint(strURL);
     Blob headerValue = Blob.valueOf(userOFS + ':' + passwordOFS);
    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    system.debug('**'+response.getStatusCode());
    if (response.getStatusCode() == 200) {
    
        System.debug('Received the following :');
       
            System.debug('***'+response.getBody());
       
    }

        return response.getBody();
}

public string createActivity(GetUnavailabilityController.UnavailWrap unavailNew){

    Http http = new Http();
    HttpRequest request = new HttpRequest();
    string urlStr=urlOFS+'/activities';
    request.setEndpoint(urlStr);
    Blob headerValue = Blob.valueOf(userOFS + ':' + passwordOFS);
    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
    String serialUnavail = JSON.serialize(unavailNew,true).replace('date_x', 'date');
    request.setHeader('Authorization', authorizationHeader);
    request.setHeader('Content-Type','application/json');
    request.setMethod('POST');
    system.debug('Request Body --->'+serialUnavail+' '+urlStr);
    request.setBody(serialUnavail);
   
   //request.setBody('{"resourceId": "a0A20000007EQQjEAO","date": "2017-05-19","activityType": "MR","duration":60,"serviceWindowEnd":"15:00:00","serviceWindowStart":"14:00:00","setPositionInRoute":{"position":"byServiceWindow"}}');
    HttpResponse response = http.send(request);
    system.debug('**'+response.getStatusCode());
    system.debug('***'+response.getStatus());
    if (response.getStatusCode() == 201) {
     
        System.debug('Received the following :');
       
            System.debug('***'+response.getBody());
            return response.getBody();
       
    }else
    {
    	return null;
    }
    

}
 public Integer deleteActivity(String activityId){

    Http http = new Http();
    HttpRequest request = new HttpRequest();
    string urlStr=urlOFS +'/activities/'+activityId;
    request.setEndpoint(urlStr);
    Blob headerValue = Blob.valueOf(userOFS + ':' + passwordOFS);
    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    request.setHeader('Content-Type','application/json');
    request.setMethod('DELETE');
    HttpResponse response = http.send(request);
    system.debug('**'+response.getStatusCode());
    system.debug('***'+response.getStatus());
    if (response.getStatusCode() == 204) {
     
        System.debug('Received the following :');
       
            System.debug('***'+response.getBody());
       
    }
        return response.getStatusCode();

 }
 
 
 public string  getRoute(string resourceId,string dateFrom){
  
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    String strURL=urlOFS+'/resources/'+resourceId+'/routes/'+dateFrom;
    request.setEndpoint(strURL);
     Blob headerValue = Blob.valueOf(userOFS + ':' + passwordOFS);
    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    system.debug('**'+response.getStatusCode());
    if (response.getStatusCode() == 200) {
    
        System.debug('Received the following :');
       
            System.debug('***'+response.getBody());
       
    }

    return response.getBody();
}

public string  getCalendarsVer2(string resourceIds,date dateFrom,date dateTo){
  
    string startString = datetime.newinstance(dateFrom, time.newinstance(0,0,0,0)).format('yyyy-MM-dd');
    string endString = datetime.newinstance(dateTo, time.newinstance(0,0,0,0)).format('yyyy-MM-dd');
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    String strURL=urlOFS+'/calendars?resources='+resourceIds+'&dateFrom='+startString+'&dateTo='+endString;
    request.setEndpoint(strURL);
     Blob headerValue = Blob.valueOf(userOFS + ':' + passwordOFS);
    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    system.debug('**'+response.getStatusCode());
    if (response.getStatusCode() == 200) {
    
            System.debug('Received the following :');
       
            System.debug('***'+response.getBody());
            return response.getBody().replaceall('date','date_x');
       
    }
    return null;

        
}

/*
public string  getActvity(long activityId){
  
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    String strURL=urlOFS+'/activities/'+activityId;//+'/workskills';
    request.setEndpoint(strURL);
     Blob headerValue = Blob.valueOf(userOFS + ':' + passwordOFS);
    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    system.debug('**'+response.getStatusCode());
    if (response.getStatusCode() == 200) {
    
        System.debug('Received the following :');
       
            System.debug('***'+response.getBody());
       
    }

        return response.getBody();
}
*/

}