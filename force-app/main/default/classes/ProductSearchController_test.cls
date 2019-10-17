@isTest

private with sharing class ProductSearchController_test{
    static Product2 prod = new Product2(); 
    
   
    
    static testmethod void method1(){
        prod = new Product2(Name='PB140',ProductCode='ProductCode');
        insert prod;
        ProductSearchController controller = new ProductSearchController(new ApexPages.StandardController(prod));
        controller.onClickRefresh();
        controller.searchText = 'CBLR';
        controller.SearchProduct();
    }  
}