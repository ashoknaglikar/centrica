@IsTest
public class createBundleLeadReqResponse_Test {
	
	static testMethod void testParse() {
		String json=		'{'+
		'  "CustomerData": '+
		'    {'+
		'          "customerDetails": {'+
		'                 "Salutation": "Miss",'+
		'                 "LastName": "Mcamullan",'+
		'                 "FirstName": "Catherine "'+
		'            },'+
		'           "contactDetails": {      '+
		'                "MobilePhone": null,'+
		'                "Email": "cmac14@virginmedia.com"      '+
		'            },'+
		'           "Address": {'+
		'                   "TownCity": "LEEDS",'+
		'                   "Street": "EDINBURGH PLACE",'+
		'                   "PostCode": "LS12 3RQ",'+
		'                   "NameNumber": "14",'+
		'                   "CountyProvince": ""'+
		'           },'+
		'         "chiLeadChannel": "Online",'+
		'         "resStatus": "Owner",'+
		'        "productInterest": "Online Boiler",'+
		'         "mediaCode": "ENGI",'+
		'         "marketingPreference": "EMAIL",'+
		'    "isMarketingConsent": "Yes",'+
		'    "asbestosIdentified": "No",'+
		'    "isHomecare" : true,'+
		'    "isPowerflush" : false,'+
		'    "fuelType": "Natural Gas",'+
		'     "homeCareAccountNumber": "911234567890",'+
		'     "hiveReq":true,'+
		'      "plumeKitReq":true'+
		'  },'+
		'  "bundle": '+
		'    {'+
		'      "id" : "001",'+
		'      "boilerCode" : "CBLR0001",'+
		'      "totalGrossPrice": "2599.00",'+
		'      "totalDiscount": "700.00",'+
		'      "totalPriceAfterDicount": "1899.00",'+
		'      "extrasSold": ['+
		'        {'+
		'          "name": "Powerflush",'+
		'          "amount": "260.00",'+
		'          "code": "PF001"'+
		'        }'+
		'      ],'+
		'      "allowancesApplied": ['+
		'        {'+
		'          "name": "£200.00 Homecare loyalty engineer discount",'+
		'          "amount": "200.00",'+
		'          "code": "AW004"'+
		'        },'+
		'        {'+
		'          "name": "£50.00 off your powerflush",'+
		'          "amount": "500.00",'+
		'          "code": "AW002"'+
		'        }'+
		'      ]'+
		'    }'+
		'}'+
		'';
		createBundleLeadRequest obj = createBundleLeadRequest.parse(json);
		System.assert(obj != null);
	}
	
	
	static testMethod void testParseResponse() {
		String json=		'{'+
		'	"leadReference" : "463234182",'+
		'	"redirectLink":"https://orkidlab.com/124343i4i3jsiyue3",'+
		'	"token":"abcd1234",'+
		'	"status":"Success",'+
		'        "errorList":['+
		'	{"errorCode":"10", "errorName": "An active lead exists", "description" :" An active lead exists"}'+
		']'+
		''+
		'}'+
		'';
		createBundleLeadResponse obj = createBundleLeadResponse.parse(json);
		System.assert(obj != null);
	}
}