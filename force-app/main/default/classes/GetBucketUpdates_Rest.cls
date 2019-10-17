//This class is used to invoke OFS REST web service API's in order get resources from OFS
public class GetBucketUpdates_Rest{

public string username =System.Label.toa_user+'@'+System.Label.toa_Company;
public string password =System.Label.toa_password;

public string baseURL =System.Label.OFS_REST_Resources_Base_URL;
//A REST call to get resources from OFS
public string getResourcesOFS(string resourceId){

      
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(baseURL+resourceId+System.Label.Get_resource_children);
    Blob headerValue = Blob.valueOf(username + ':' + password);
    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    if (response.getStatusCode() == 200) {
         //System.debug('***'+response.getBody());
                string respJson=response.getBody();
                return respJson;
        }
    return null;
  }
}