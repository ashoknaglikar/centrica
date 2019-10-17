//This class is used to invoke OFS REST web service API's GET/PUT/POST ;in order to create/update/get work zones in OFS
public class SubPatchUpadateInOFS_Rest{

public string username =System.Label.toa_user+'@'+System.Label.toa_Company;
public string password =System.Label.toa_password;

public string baseURL =System.Label.OFS_REST_Base_URL+System.Label.URL_automateWorkZones;
//A REST call to get all work zones from OFS
public  string getWorkZonesOFS(){

      
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseURL);
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        system.debug('**'+response.getStatusCode());
       
        if (response.getStatusCode() == 200) {
         
                System.debug('Received the following :');
           
                System.debug('***'+response.getBody());
                string respJson=response.getBody();
             
              return respJson;
        }
    return null;

}
//A REST call to create / update work zones in OFS
public string createUpdateWorkZonesOFS(WorkZoneUpdateBatch.SubPatchWrapper patch, string wzLabel){

      
        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        if(wzLabel!=null)
        baseURL+='/'+wzLabel;
        
        request.setEndpoint(baseURL);
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type','application/json');
        if(wzLabel!=null)
        request.setMethod('PUT');
        else
        request.setMethod('POST');
        
        string workzoneLabel= patch.workZoneName.replace(' ','_');
        
            String serialWZ = JSON.serialize(patch,true);
            request.setBody(serialWZ);
            HttpResponse response = http.send(request);
            system.debug('***'+serialWZ);
            system.debug('**'+response.getStatusCode());
            system.debug('***'+response.getStatus());
           
                System.debug('Received the following :');
               
               System.debug('***'+response.getBody());
               return response.getBody();
        
       
        
       

 return null;



}

//REST cALL FOR Search acivities


public  string searchActivities(string searchString){
	
	Http http = new Http();
    HttpRequest request = new HttpRequest();
    
    username =System.Label.toa_user+'@'+System.Label.toa_Company;
    
    request.setEndpoint(system.label.URL_for_updating_Unavailability+system.label.OFS_Search_activitiy+searchString);
    
    Blob headerValue = Blob.valueOf(username + ':' + password);
    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    system.debug('**'+response.getStatusCode());
   
    if (response.getStatusCode() == 200) {
     
            System.debug('Received the following :');
       
            System.debug('***'+response.getBody());
            string respJson=response.getBody();
         
          return respJson;
    }
    return null;

}


}