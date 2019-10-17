global class bundleResponseClass {

	global class OptionalExtra {
		global String name;
		global String amount;
		global String code;
		global String required;
	}

	

	global class BundleResponse {
		global bundleRequestClass.Address Address;
		global String activeLeadExists;
		global String leadReference;
		global List<Bundle> bundles;
	}

	global class Allowance {
		global String name;
		global decimal amount;
		global String code;
		global string sfId;
	}

	global class Bundle {
		global String id;
		global String boilerCode;
		global String boilerName;
		global decimal totalBundlePrice = 0.0;
		global decimal boilerPrice = 0.0;
		global decimal installPrice;
		global decimal totalPriceAfterDiscount;
		global decimal totalAllowance;
		global decimal hivePrice = 0.0;
		global List<OptionalExtra> optionalExtras;
		global List<Allowance> allowances;
	}

	
	global static BundleResponse parse(String json) {
		return (BundleResponse) System.JSON.deserialize(json, BundleResponse.class);
	}
}