@isTest
public class toatechResMMockImpl implements WebServiceMock {
 
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

     if(request instanceOf  toatechResourcemanagement10.GetResourcesCalendarsElement) {
   /* toatechResourcemanagement10.GetResourcesCalendarsResponseElement respEle=new toatechResourcemanagement10.GetResourcesCalendarsResponseElement() ;
    toatechResourcemanagement10.CalendarList calEle;
    toatechResourcemanagement10.CalendarElement calElement;
    
    toatechResourcemanagement10.TextPropertiesElement textproEle;
    
    toatechResourcemanagement10.TextPropertyElement[] property=new List<toatechResourcemanagement10.TextPropertyElement>() ;
    toatechResourcemanagement10.TextPropertyElement prop1=new toatechResourcemanagement10.TextPropertyElement();
    
    prop1.name='time_from';
    prop1.value='09:00';
    toatechResourcemanagement10.TextPropertyElement prop2=new toatechResourcemanagement10.TextPropertyElement();
    property.add(prop1);
    prop2.name='time_to';
    prop2.value='19:00';
     property.add(prop2);
    
    textproEle.property=property;
    calElement.properties=textproEle;
    calEle.calendar.add(calElement);
    respEle.calendars=calEle;
    response.put( 'response_x',respEle); */
    response.put( 'response_x',new toatechResourcemanagement10.GetResourcesCalendarsResponseElement());
    }
    
    return ;
  }
  
  private static testMethod void coverTypes()
    {
        new toatechResourcemanagement10.GetResourcesCalendarsElement();
        new toatechResourcemanagement10.GetResourcesCalendarsResponseElement();
        new toatechResourcemanagement10.CalendarElement();
        new toatechResourcemanagement10.GetResourcesParamsElement();
        new toatechResourcemanagement10.TextPropertyElement();
        new toatechResourcemanagement10.CalendarList();
        new toatechResourcemanagement10.AuthNodeElement();
        new toatechResourcemanagement10.GetResourcesParamsList();
        new toatechResourcemanagement10.TextPropertiesElement();
              
       
    }
  @isTest  
  private static void coverMethods()
    {   
          System.Test.setMock(WebServiceMock.class, new toatechResMMockImpl());
          new toatechResourcemanagement10.ResourceManagementPort().get_resources_calendars(null,null);
    
    }
}