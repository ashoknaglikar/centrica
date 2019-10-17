//This is test class for UnavailUpadateInOFS_Rest apex class
@isTest
public class UnavailUpadateInOFS_Rest_Test{

 static testmethod void searchUnavailTest(){
    UnavailUpadateInOFS_Rest uRest=new UnavailUpadateInOFS_Rest();
    string searchUrl='searchInField=XA_Resource_ID&searchForValue='+'a0A20000007ZZZjEAO';
    SingleRequestMock fakeResp = new SingleRequestMock(200,
                                                 '200',
                                               '{"items": [{"resourceId": "a0A20000007ZZZjEAO","date": "2017-11-19","activityType": "MR","duration":60,"serviceWindowEnd":"15:00:00","serviceWindowStart":"14:00:00"}]}', null);
    Test.setMock(HttpCalloutMock.class, fakeResp); 
    uRest.searchUnavail('a0A20000007ZZZjEAO',string.valueOf(system.today()),string.valueOf(system.today()+1),searchUrl);
    uRest.getCalendars('a0A20000007ZZZjEAO',string.valueOf(system.today()),string.valueOf(system.today()+1));
    GetUnavailabilityController.UnavailWrap unWrap=new  GetUnavailabilityController.UnavailWrap('a0A20000007ZZZjEAO','01-01-2017','01-02-2017',48,'12:23:40','14:23:40','01-01-2017','AM','123356fjbo','notes','last');
    
    uRest.createActivity(unWrap);
    uRest.deleteActivity('a0A20000007ZZZjEAO');
    uRest.getRoute('a0A20000007ZZZjEAO',string.valueOf(system.today()));
}

}