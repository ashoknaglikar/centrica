public with sharing class BasketViewerController {
	//
	private cscfga__Product_Basket__c productBasket;
	public cscfga__Product_Configuration__c mainProductConfig {get; set;}
	public List<cscfga__Product_Configuration__c> productConfigList {get; set;}
	//
	public BasketViewerController(ApexPages.StandardController stdController) {
        this.productBasket = (cscfga__Product_Basket__c)stdController.getRecord();
        //
        productConfigList = [select Id, Name, cscfga__Parent_Configuration__c,
        							(select Id, Name, cscfga__value__c,cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__r.Name,
        									cscfga__Attribute_Definition__r.cscfga__Screen_Section__r.Name
        							     from cscfga__Attributes__r 
        							 order by cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Screen_Section__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Row__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Column__c) 
        					   from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :this.productBasket.id];
		//
	}
	//
	@RemoteAction
	public static ProductConfigurationCollection getMainProduct(String basketId) {
		List<cscfga__Product_Configuration__c> condensateProductConfigList = new List<cscfga__Product_Configuration__c>();
		List<cscfga__Product_Configuration__c> fluePackProductConfigList = new List<cscfga__Product_Configuration__c>();
		List<cscfga__Product_Configuration__c> packCProductConfigList = new List<cscfga__Product_Configuration__c>();
		List<cscfga__Product_Configuration__c> packXProductConfigList = new List<cscfga__Product_Configuration__c>();
		List<cscfga__Product_Configuration__c> radiatorProductConfigList = new List<cscfga__Product_Configuration__c>();
		cscfga__Product_Configuration__c mainProductConfig = 
							[select Id, Name, 
        							(select Id, Name, cscfga__value__c,cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__r.Name,
        									cscfga__Attribute_Definition__r.cscfga__Screen_Section__r.Name, cscfga__Attribute_Definition__r.cscfga__Row__c, 
        									cscfga__Attribute_Definition__r.cscfga__Column__c
        							     from cscfga__Attributes__r 
        							 order by cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__r.cscfga__Index__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Screen_Section__r.cscfga__Index__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Row__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Column__c) 
        					   from cscfga__Product_Configuration__c 
        					  where cscfga__Product_Basket__c = :basketId 
        					    and cscfga__Parent_Configuration__c = '' 
        					    and cscfga__Product_Definition__r.Name = 'Heating Hot Water Solution'];
		//
		/****List<cscfga__Attribute__c> mainAttributeList = [select Id, Name, cscfga__value__c,cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__r.Name,
			        									   cscfga__Attribute_Definition__r.cscfga__Screen_Section__r.Name
			        							      from cscfga__Attribute__c 
			        							     where id in :mainProductConfig.cscfga__Attributes__r
			        							  order by cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__c, 
			        							 		   cscfga__Attribute_Definition__r.cscfga__Screen_Section__c, 
			        							 		   cscfga__Attribute_Definition__r.cscfga__Row__c, 
			        							 		   cscfga__Attribute_Definition__r.cscfga__Column__c];*****/
		//
		condensateProductConfigList = 
							[select Id, Name, 
        							(select Id, Name, cscfga__value__c,cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__r.Name,
        									cscfga__Attribute_Definition__r.cscfga__Screen_Section__r.Name
        							     from cscfga__Attributes__r 
        							 order by cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Screen_Section__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Row__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Column__c) 
        					   from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId and cscfga__Product_Definition__r.Name = 'Condensate'];
		//        					   
		fluePackProductConfigList = 
							[select Id, Name, 
        							(select Id, Name, cscfga__value__c,cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__r.Name,
        									cscfga__Attribute_Definition__r.cscfga__Screen_Section__r.Name
        							     from cscfga__Attributes__r 
        							 order by cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Screen_Section__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Row__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Column__c) 
        					   from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId and cscfga__Product_Definition__r.Name = 'Flue Packs'];
		//
		packCProductConfigList = 
							[select Id, Name, 
        							(select Id, Name, cscfga__value__c,cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__r.Name,
        									cscfga__Attribute_Definition__r.cscfga__Screen_Section__r.Name
        							     from cscfga__Attributes__r 
        							 order by cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Screen_Section__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Row__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Column__c) 
        					   from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId and cscfga__Product_Definition__r.Name = 'Pack C'];
		//
		packXProductConfigList = 
							[select Id, Name, 
        							(select Id, Name, cscfga__value__c,cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__r.Name,
        									cscfga__Attribute_Definition__r.cscfga__Screen_Section__r.Name
        							     from cscfga__Attributes__r 
        							 order by cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Screen_Section__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Row__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Column__c) 
        					   from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId and cscfga__Product_Definition__r.Name = 'Pack X'];
		//
		radiatorProductConfigList = 
							[select Id, Name, 
        							(select Id, Name, cscfga__value__c,cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__r.Name,
        									cscfga__Attribute_Definition__r.cscfga__Screen_Section__r.Name
        							     from cscfga__Attributes__r 
        							 order by cscfga__Attribute_Definition__r.cscfga__Configuration_Screen__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Screen_Section__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Row__c, 
        							 		  cscfga__Attribute_Definition__r.cscfga__Column__c) 
        					   from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId and cscfga__Product_Definition__r.Name = 'Radiator'];
		//
		ProductConfigurationCollection prodConfigCollection = new ProductConfigurationCollection(mainProductConfig,
																								 condensateProductConfigList,
																								 fluePackProductConfigList,
																								 packCProductConfigList,
																								 packXProductConfigList,
																								 radiatorProductConfigList);
		//
		return prodConfigCollection;
	}
    //
    public class ProductConfigurationCollection {
        public cscfga__Product_Configuration__c  mainProductConf {get; set;}
        public List<cscfga__Product_Configuration__c> condensateProductConfigList {get; set;}
        public List<cscfga__Product_Configuration__c> fluePackProductConfigList {get; set;}
        public List<cscfga__Product_Configuration__c> packCProductConfigList {get; set;}
        public List<cscfga__Product_Configuration__c> packXProductConfigList {get; set;}
        public List<cscfga__Product_Configuration__c> radiatorProductConfigList {get; set;}
        
        public ProductConfigurationCollection(cscfga__Product_Configuration__c  mProdConfig,
        					 		   		  List<cscfga__Product_Configuration__c> CondensateList,
        					 		   		  List<cscfga__Product_Configuration__c> fluePackList,
        					 		   		  List<cscfga__Product_Configuration__c> packCList,
        					 		   		  List<cscfga__Product_Configuration__c> packXList,
        					 		   		  List<cscfga__Product_Configuration__c> radiatorList) {
	        mainProductConf           = mProdConfig;
	        condensateProductConfigList = CondensateList;
	        fluePackProductConfigList = fluePackList;
	        packCProductConfigList    = packCList;
	        packXProductConfigList    = packXList;
	        radiatorProductConfigList = radiatorList;
        }
    }
}