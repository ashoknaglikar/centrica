public class productHoldingReponseClass {
	public static void consumeObject(JSONParser parser) {
		Integer depth = 0;
		do {
			JSONToken curr = parser.getCurrentToken();
			if (curr == JSONToken.START_OBJECT || 
				curr == JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == JSONToken.END_OBJECT ||
				curr == JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
    /*
	public class Items_Z {
		public String subcategory {get;set;} 
		public String small_name {get;set;} 
		public String id {get;set;} 
		public String icon {get;set;} 
		public Boolean active {get;set;} 
		public String link {get;set;} 
		public List<Summary> products {get;set;} 

		public Items_Z(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'subcategory') {
							subcategory = parser.getText();
						} else if (text == 'small_name') {
							small_name = parser.getText();
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'icon') {
							icon = parser.getText();
						} else if (text == 'active') {
							active = parser.getBooleanValue();
						} else if (text == 'link') {
							link = parser.getText();
						} else if (text == 'products') {
							products = new List<Summary>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								products.add(new Summary(parser));
							}
						} else {
							System.debug(LoggingLevel.WARN, 'Items_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	*/
	public class ProductHoldings {
		public String category {get;set;} 
		public Boolean activeLeadsExist {get;set;} 
		public List<Items> items {get;set;} 

		public ProductHoldings(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'category') {
							category = parser.getText();
						} else if (text == 'activeLeadsExist') {
							activeLeadsExist = parser.getBooleanValue();
						} else if (text == 'items') {
							items = new List<Items>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								items.add(new Items(parser));
							}
						} else {
							System.debug(LoggingLevel.WARN, 'ProductHoldings consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Meta {
		public List<Services> services {get;set;} 

		public Meta(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'services') {
							services = new List<Services>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								services.add(new Services(parser));
							}
						} else {
							System.debug(LoggingLevel.WARN, 'Meta consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Products {
		public List<AtAddress> atAddress {get;set;} 
		public List<Summary> otherAddress {get;set;} 

		public Products(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'atAddress') {
							atAddress = new List<AtAddress>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								atAddress.add(new AtAddress(parser));
							}
						} else if (text == 'otherAddress') {
							otherAddress = new List<Summary>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								otherAddress.add(new Summary(parser));
							}
						} else {
							System.debug(LoggingLevel.WARN, 'Products consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
/*
    public class Segmentation{
        public string segmentation {get;set;}
		public String moodRing {get;set;} 
		public String productQuote  {get;set;}
		public boolean isVulnerableCustomer {get;set;} 
		public boolean isSpecialNeedGuaranteeSupply {get;set;} 
		
		
		public Segmentation(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'segmentation') {
							segmentation = parser.getText();
						} else if (text == 'moodRing') {
							moodRing = parser.getText();
						} else if (text == 'isVulnerableCustomer') {
							isVulnerableCustomer = parser.getBooleanValue();
						} else if (text == 'isSpecialNeedGuaranteeSupply') {
							isSpecialNeedGuaranteeSupply = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Segmentation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
        
    }
    */
	
	public class Address {
	    public string flatNumber {get;set;}
		public String houseNumber {get;set;} 
		public String houseName  {get;set;}
		public String street {get;set;} 
		public String town {get;set;} 
		public String postcode {get;set;} 
        public string propertyType;
		public Address(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'houseNumber') {
							houseNumber = parser.getText();
						} else if (text == 'street') {
							street = parser.getText();
						} else if (text == 'town') {
							town = parser.getText();
						} else if (text == 'postcode') {
							postcode = parser.getText();
						} else if (text == 'flatNumber') {
							flatNumber = parser.getText();
						} else if (text == 'houseName') {
							houseName = parser.getText();
						} else if (text == 'propertyType') {
							propertyType = parser.getText();
						}else {
							System.debug(LoggingLevel.WARN, 'Address consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public List<Address> address {get;set;} 
	public List<People> people {get;set;} 
	public List<ProductHoldings> combinedProductHoldings {get;set;} 
	public Meta meta {get;set;} 

	public productHoldingReponseClass(JSONParser parser) {
		while (parser.nextToken() != JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != JSONToken.VALUE_NULL) {
					if (text == 'address') {
						address = new List<Address>();
						while (parser.nextToken() != JSONToken.END_ARRAY) {
							address.add(new Address(parser));
						}
					} else if (text == 'people') {
						people = new List<People>();
						while (parser.nextToken() != JSONToken.END_ARRAY) {
							people.add(new People(parser));
						}
					} else if (text == 'combinedProductHoldings') {
						combinedProductHoldings = new List<ProductHoldings>();
						while (parser.nextToken() != JSONToken.END_ARRAY) {
							combinedProductHoldings.add(new ProductHoldings(parser));
						}
					} else if (text == 'meta') {
						meta = new Meta(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class People {
		public String name {get;set;} 
		public String personId {get;set;} 
		public String businessPartnerId {get;set;} 
		public List<Info> info {get;set;} 
		public ContactHistory contactHistory {get;set;} 
		public Complaints complaints {get;set;} 
		public Products products {get;set;} 
		public List<ProductHoldings> productHoldings {get;set;} 
		public Boolean rafRegistered {get;set;} 

		public People(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'personId') {
							personId = parser.getText();
						} else if (text == 'businessPartnerId') {
							businessPartnerId = parser.getText();
						} else if (text == 'info') {
							info = new List<Info>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								info.add(new Info(parser));
							}
						} else if (text == 'contactHistory') {
							contactHistory = new ContactHistory(parser);
						} else if (text == 'complaints') {
							complaints = new Complaints(parser);
						} else if (text == 'products') {
							products = new Products(parser);
						} else if (text == 'productHoldings') {
							productHoldings = new List<ProductHoldings>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								productHoldings.add(new ProductHoldings(parser));
							}
						} else if (text == 'rafRegistered') {
							rafRegistered = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'People consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ContactHistory {
		public List<Summary> summary {get;set;} 
		public List<Summary> calls {get;set;} 
		public List<Summary> engineers {get;set;} 

		public ContactHistory(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'summary') {
							summary = new List<Summary>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								summary.add(new Summary(parser));
							}
						} else if (text == 'calls') {
							calls = new List<Summary>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								calls.add(new Summary(parser));
							}
						} else if (text == 'engineers') {
							engineers = new List<Summary>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								engineers.add(new Summary(parser));
							}
						} else {
							System.debug(LoggingLevel.WARN, 'ContactHistory consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Info {
		public String title {get;set;} 
		public String firstName {get;set;} 
		public String lastName {get;set;} 
		public String phoneNumber {get;set;} 
		public String email {get;set;} 
		public string numberOfExistingProperties;
        public string alternateContactNumber;
		public Info(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'title') {
							title = parser.getText();
						} else if (text == 'firstName') {
							firstName = parser.getText();
						} else if (text == 'lastName') {
							lastName = parser.getText();
						} else if (text == 'phoneNumber') {
							phoneNumber = parser.getText();
						} else if (text == 'email') {
							email = parser.getText();
						}else if (text == 'numberOfExistingProperties') {
							numberOfExistingProperties = parser.getText();
						}else if (text == 'alternateContactNumber') {
							alternateContactNumber = parser.getText();
						}else{
							System.debug(LoggingLevel.WARN, 'Info consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Services {
		public String name {get;set;} 
		public Boolean available {get;set;} 

		public Services(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'available') {
							available = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Services consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Summary {
        public string visitStatus {get;set;} 
        public date visitDate {get;set;}
        public string jobReason {get;set;}
        public string jobDescription {get;set;}
        
		public Summary(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						
					    if (text == 'visitStatus') {
							visitStatus = parser.getText();
						} else if (text == 'visitDate') {
							visitDate = parser.getDateValue();
						} else if (text == 'jobReason') {
							jobReason = parser.getText();
						} else if (text == 'jobDescription') {
							jobDescription = parser.getText();
						} else{
							System.debug(LoggingLevel.WARN, 'Summary consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class AtAddress {
		public String contractAccountNumber {get;set;} 
		public String businessPartnerId {get;set;} 
		public String productId {get;set;} 
		public String mpxn {get;set;} 
		public String serviceOrderReferenceId {get;set;} 
		public String productName {get;set;} 
		public String productDescription {get;set;} 
		public String contractStartDate {get;set;} 
		public String tariffName {get;set;} 
		public String owner {get;set;} 
		public String type_Z {get;set;} // in json: type
		public string boilerGCNumber;
		public string currentHeatingSystem;
		public string lengthOfTimeProductHeld;
		public string electricityAnnualSpend;
		public string electricityMonthlySpend;
		public string electricityPaymentMethod;
		public string gasAnnualSpend;
		public string gasMonthlySpend;
		public string gasPaymentMethod;
		public string boilerAge;
		public date dateOfLastCertification;
		public string productBundleName;

		public AtAddress(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'contractAccountNumber') {
							contractAccountNumber = parser.getText();
						} else if (text == 'businessPartnerId') {
							businessPartnerId = parser.getText();
						} else if (text == 'productId') {
							productId = parser.getText();
						} else if (text == 'mpxn') {
							mpxn = parser.getText();
						} else if (text == 'serviceOrderReferenceId') {
							serviceOrderReferenceId = parser.getText();
						} else if (text == 'productName') {
							productName = parser.getText();
						} else if (text == 'productDescription') {
							productDescription = parser.getText();
						} else if (text == 'contractStartDate') {
							contractStartDate = parser.getText();
						} else if (text == 'tariffName') {
							tariffName = parser.getText();
						} else if (text == 'owner') {
							owner = parser.getText();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'boilerGCNumber') {
							boilerGCNumber = parser.getText();
						} else if (text == 'currentHeatingSystem') {
							currentHeatingSystem = parser.getText();
						} else if (text == 'lengthOfTimeProductHeld') {
							lengthOfTimeProductHeld = parser.getText();
						}else if (text == 'electricityAnnualSpend') {
							electricityAnnualSpend = parser.getText();
						}else if (text == 'electricityMonthlySpend') {
							electricityMonthlySpend = parser.getText();
						}else if (text == 'electricityPaymentMethod') {
							electricityPaymentMethod = parser.getText();
						}else if (text == 'gasAnnualSpend') {
							gasAnnualSpend = parser.getText();
						}else if (text == 'gasMonthlySpend') {
							gasMonthlySpend = parser.getText();
						}else if (text == 'gasPaymentMethod') {
							gasPaymentMethod = parser.getText();
						}else if (text == 'boilerAge') {
							boilerAge = parser.getText();
						}else if (text == 'productBundleName') {
							productBundleName = parser.getText();
						}else if (text == 'dateOfLastCertification') {
						    string tempi = parser.getText();
						    if(tempi!=null)
						    {
						    string[] temp = tempi.split(' ');
						    
							dateOfLastCertification = date.valueof(temp[0]);
						    }
						} else {
							System.debug(LoggingLevel.WARN, 'AtAddress consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Complaints {
		public List<Summary> open {get;set;} 
		public List<Summary> closed {get;set;} 

		public Complaints(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'open') {
							open = new List<Summary>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								open.add(new Summary(parser));
							}
						} else if (text == 'closed') {
							closed = new List<Summary>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								closed.add(new Summary(parser));
							}
						} else {
							System.debug(LoggingLevel.WARN, 'Complaints consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Items {
		public String subcategory {get;set;} 
		public String small_name {get;set;} 
		public String id {get;set;} 
		public String icon {get;set;} 
		public Boolean active {get;set;} 
		public String link {get;set;} 
		public List<AtAddress> products {get;set;} 

		public Items(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'subcategory') {
							subcategory = parser.getText();
						} else if (text == 'small_name') {
							small_name = parser.getText();
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'icon') {
							icon = parser.getText();
						} else if (text == 'active') {
							active = parser.getBooleanValue();
						} else if (text == 'link') {
							link = parser.getText();
						} else if (text == 'products') {
							products = new List<AtAddress>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								products.add(new AtAddress(parser));
							}
						} else {
							System.debug(LoggingLevel.WARN, 'Items consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static productHoldingReponseClass parse(String json) {
		return new productHoldingReponseClass(System.JSON.createParser(json));
	}
}