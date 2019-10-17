@isTest
private class newProductHoldingClassTest {

    
	private static testMethod void testLogin() {

        newProductHoldingClass obj = new newProductHoldingClass();
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"access_token": "sForceTest1"},{"expires_in": "600"}]',
                                                 null);
                                                 
		Test.setMock(HttpCalloutMock.class, fakeResponse);
		
        obj.loginDetails();
        
        
    }
    
    private static testMethod void testgetAllAddress() {

        newProductHoldingClass obj = new newProductHoldingClass();
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"access_token": "sForceTest1"},{"expires_in": "600"}]',
                                                 null);
                                                 
		Test.setMock(HttpCalloutMock.class, fakeResponse);
		
        obj.getAllAddress('test Token','test postcode');
        
        
    }
    
    private static testMethod void testgetProductHoldingByAddressId() {

        newProductHoldingClass obj = new newProductHoldingClass();
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"access_token": "sForceTest1"},{"expires_in": "600"}]',
                                                 null);
                                                 
		Test.setMock(HttpCalloutMock.class, fakeResponse);
		
        obj.getProductHoldingByAddressId('test Token','test address Id');
        
        
    }

}