@IsTest
public class bundleRequestClass_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'               \"Address\":{'+
		'                 \"TownCity\":\"LEEDS\",'+
		'                 \"Street\":\"EDINBURGH PLACE\",'+
		'                  \"PostCode\":\"LS12 3RQ\",'+
		'                  \"NameNumber\":\"14\",'+
		'                   \"CountyProvince\":\"\"'+
		'               },'+
		'               \"bundles\":[\"bundle 1\", \"bundle 2\"],'+
		'	\"isHomeCare\":true,'+
		'	\"isPowerFlush\":false,'+
		'	\"hiveReq\":true,'+
		'	\"plumeKitReq\":true,'+
		'	  \"extras\":[] '+
		'}';
		bundleRequestClass.BundleRequest obj = bundleRequestClass.parse(json);
		System.assert(obj != null);
	}
}