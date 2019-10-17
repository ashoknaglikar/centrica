@isTest
public class toaCapacityMockImpl implements WebServiceMock {
 
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

    if(request instanceOf toaCapacity.capacity_request_element) {
      response.put( 'response_x', new toaCapacity.capacity_response_element());
    }
    else if(request instanceOf toaCapacity.get_quota_close_time_request_element) {
      response.put( 'response_x', new toaCapacity.get_quota_close_time_response_element());
    }
    else if(request instanceOf toaCapacity.get_quota_data_request_element) {
      response.put( 'response_x', new toaCapacity.get_quota_data_response_element());
    }
    else if(request instanceOf toaCapacity.set_quota_request_element) {
      response.put( 'response_x', new toaCapacity.set_quota_response_element());
    }
    else if(request instanceOf toaCapacity.set_quota_close_time_request_element) {
      response.put( 'response_x', new toaCapacity.set_quota_close_time_response_element());
    }     
     
    return ;
  }
  
  private static testMethod void coverTypes()
    {
        new toaCapacity.activity_field_element();
        new toaCapacity.capacity_element();
        new toaCapacity.capacity_request_element();
        new toaCapacity.capacity_response_element();
        new toaCapacity.get_quota_close_time_request_element();
        new toaCapacity.get_quota_close_time_response_element();
        new toaCapacity.get_quota_data_bucket_element();
        new toaCapacity.get_quota_data_category_element();
        new toaCapacity.get_quota_data_day_element();
        new toaCapacity.get_quota_data_day_total_element();
        new toaCapacity.get_quota_data_request_element();
        new toaCapacity.get_quota_data_response_element();
        new toaCapacity.get_quota_data_time_slot_element();
        new toaCapacity.get_quota_data_time_slot_total_element();
        
        new toaCapacity.get_quota_data_work_zone_element();
        new toaCapacity.quota_close_time_schedule();
        new toaCapacity.set_quota_bucket_element();
        new toaCapacity.set_quota_category_element();
        new toaCapacity.set_quota_close_time_request_element();
        new toaCapacity.set_quota_close_time_response_element();
        new toaCapacity.set_quota_close_time_result();
        new toaCapacity.set_quota_request_element();
        new toaCapacity.set_quota_response_element();
        new toaCapacity.set_quota_result_element();
        new toaCapacity.set_quota_time_slot_element();
        new toaCapacity.set_quota_work_zone_element();
        new toaCapacity.time_slot_info_element();
        new toaCapacity.user_element();
        new toaCapacity.set_quota_day_element();
     
    }
  @isTest  
  private static void coverMethods()
    {   
        System.Test.setMock(WebServiceMock.class, new toaCapacityMockImpl());
        
        new toaCapacity.toa_capacity_interface().get_capacity(null, null, null, null,null, null, null, null,null, null,null, null, null,null);
        new toaCapacity.toa_capacity_interface().get_quota_close_time(null,null,null,null,null,null);
        new toaCapacity.toa_capacity_interface().get_quota_data(null,null,null,null,null,null,null,null,null,null,null);
        new toaCapacity.toa_capacity_interface().set_quota(null,null);
        new toaCapacity.toa_capacity_interface().set_quota_close_time(null,null);
    }
}