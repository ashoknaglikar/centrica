global class bundleRequestClass {
    
	global class Address {
		global String TownCity;
		global String Street;
		global String PostCode;
		global String NameNumber;
		global String CountyProvince;
	}

	global class BundleRequest {
		global Address Address;
		global List<String> bundles;
		global boolean  isHomeCare;
		global boolean isPowerFlush;
		global boolean hiveReq;
		global boolean plumeKitReq;
		global List<Extras> extras;
	}

	global class Extras {
	}

	
	global static BundleRequest parse(String json) {
		return (BundleRequest) System.JSON.deserialize(json, BundleRequest.class);
	}
}