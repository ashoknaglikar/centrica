@IsTest
public class bundleResponse_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'\"Address\":{'+
		'                 \"TownCity\":\"LEEDS\",'+
		'                 \"Street\":\"EDINBURGH PLACE\",'+
		'                  \"PostCode\":\"LS12 3RQ\",'+
		'                  \"NameNumber\":\"14\",'+
		'                   \"CountyProvince\":\"\"'+
		'   },'+
		'  \"activeLeadExists\":\"Yes\",'+
		' \"leadReference\":\"463234182\",'+
		' \"bundles\":['+
		'    {'+
		'        \"id\":\"001\",'+
		'        \"boilecode\":\"CBLR0002\",'+
		'        \"boilerName\":\"Valiant ecoTech plus combi boiler\",'+
		'        \"totalBundlePrice\":\"2599.00\",'+
		'        \"boilerPrice\":\"1149.00\",'+
		'        \"installPrice\":\"1114.00\",'+
		'        \"optionalExtras\":['+
		'          {'+
		'            \"name\":\"Powerflush\",'+
		'            \"amount\":\"260.00\",'+
		'            \"code\":\"PF001\",'+
		'            \"required\":\"false\"'+
		'          }'+
		'        ],'+
		'        \"allowances\":['+
		'          {'+
		'            \"name\":\" £200.00 Homecare loyalty engineer discount\",'+
		'            \"amount\":\"200.00\",'+
		'            \"code\":\"AW004\"'+
		'          },'+
		'          {'+
		'            \"name\":\" £50.00 off your powerflush\",'+
		'            \"amount\":\"50.00\",'+
		'            \"code\":\"AW002\"'+
		'          },'+
		'          {'+
		'            \"name\":\"£50.00 off your magnetic system fiter\",'+
		'            \"amount\":\"50.00\",'+
		'            \"code\":\"AW003\"'+
		'          }'+
		'        ]'+
		'      },'+
		'      {'+
		'        \"id\":\"002\",'+
		'        \"boilecode\":\"CBLR0002\",'+
		'        \"boilerName\":\"Valiant ecoTech plus combi boiler\",'+
		'        \"totalBundlePrice\":\"2599.00\",'+
		'        \"boilerPrice\":\"1149.00\",'+
		'        \"installPrice\":\"1114.00\",'+
		'        \"optionalExtras\":['+
		'          {'+
		'            \"name\":\"Powerflush\",'+
		'            \"amount\":\"260.00\",'+
		'            \"code\":\"PF001\",'+
		'            \"required\":\"false\"'+
		'          }'+
		'        ],'+
		'        \"allowances\":['+
		'          {'+
		'            \"name\":\" £200.00 Homecare loyalty engineer discount\",'+
		'            \"amount\":\"200.00\",'+
		'            \"code\":\"AW004\"'+
		'          },'+
		'          {'+
		'            \"name\":\" £50.00 off your powerflush\",'+
		'            \"amount\":\"50.00\",'+
		'            \"code\":\"AW002\"'+
		'          },'+
		'          {'+
		'            \"name\":\"£50.00 off your magnetic system fiter\",'+
		'            \"amount\":\"50.00\",'+
		'            \"code\":\"AW003\"'+
		'          }'+
		'        ]'+
		'      }'+
		'    '+
		'  ]'+
		'}';
		bundleResponseClass.BundleResponse obj = bundleResponseClass.parse(json);
		System.assert(obj != null);
	}
}