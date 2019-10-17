@isTest
public class toaActivityMockImpl implements WebServiceMock {
 
 public void doInvoke(
      Object stub,
      Object request,
      Map<String, Object> response,
      String endpoint,
      String soapAction,
      String requestName,
      String responseNS,
      String responseName,
      String responseType) {
       
    System.debug(LoggingLevel.INFO, 'toaCapacityMockImpl.doInvoke() - ' +
      '\n request: ' + request +
      '\n response: ' + response +
      '\n endpoint: ' + endpoint +
      '\n soapAction: ' + soapAction +
      '\n requestName: ' + requestName +
      '\n responseNS: ' + responseNS +
      '\n responseName: ' + responseName +
      '\n responseType: ' + responseType);

    if(request instanceOf toaActivity.activity_response) {
      response.put( 'response_x', new toaActivity.activity_response());
    }
    
    return ;
  }
  
  private static testMethod void coverTypes()
    {
        
        new toaActivity.search_activities_parameters();
        new toaActivity.activity_response();
        new toaActivity.property();
        new toaActivity.simple_response();
        new toaActivity.user_x();
        new toaActivity.activity();
        new toaActivity.get_file_parameters();
        new toaActivity.activity_new();
        new toaActivity.activity_list();
        new toaActivity.activities();
        
       
    }
  @isTest  
  private static void coverMethods()
    {   
        System.Test.setMock(WebServiceMock.class, new toaActivityMockImpl());
        new toaActivity.activity().search_activities(null, null, null, null,null, null, null, null,null);
         new toaActivity.activity().delete_file(null, null, null);
    
    }
}