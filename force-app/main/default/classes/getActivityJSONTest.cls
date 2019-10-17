//

@IsTest
public with sharing class getActivityJSONTest {
	//

	static testMethod void testParse() {
		String json=		'{'+
		'    "totalResults": 2,'+
		'    "limit": 10,'+
		'    "offset": 0,'+
		'    "items": ['+
		'        {'+
		'            "activityId": 4225371,'+
		'            "resourceId": "33001",'+
		'            "date": "2016-08-31",'+
		'            "status": "pending"'+
		'        },'+
		'        {'+
		'            "activityId": 4225372,'+
		'            "resourceId": "33001",'+
		'            "date": "2016-08-31",'+
		'            "status": "pending"'+
		'        }'+
		'    ],'+
		'    "links": ['+
		'        {'+
		'            "rel": "canonical",'+
		'            "href": "https://api.etadirect.com/rest/ofscCore/v1/activities/custom-actions/search?searchInField=customerName&searchForValue=testCustomerName&dateFrom=2016-08-31&dateTo=2016-08-31&limit=10&offset=0"'+
		'        },'+
		'        {'+
		'            "rel": "describedby",'+
		'            "href": "https://api.etadirect.com/rest/ofscCore/v1/metadata-catalog/activities"'+
		'        }'+
		'    ]'+
		'}'; 
		getActivityJSON obj = getActivityJSON.parse(json);
		System.assert(obj != null);
	}
}