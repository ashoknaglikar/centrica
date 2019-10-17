/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class BasketViewerControllerTest {

    static testMethod void myUnitTest() {
    	//
    	cscfga__Product_Definition__c prod1 = new cscfga__Product_Definition__c(Name='Heating Hot Water Solution', cscfga__Description__c='Heating Hot Water Solution');
    	cscfga__Product_Definition__c prod2 = new cscfga__Product_Definition__c(Name='Flue Packs', cscfga__Description__c='Flue Packs');
    	cscfga__Product_Definition__c prod3 = new cscfga__Product_Definition__c(Name='Pack C', cscfga__Description__c='Pack C');
    	cscfga__Product_Definition__c prod4 = new cscfga__Product_Definition__c(Name='Pack X', cscfga__Description__c='Pack X');
    	cscfga__Product_Definition__c prod5 = new cscfga__Product_Definition__c(Name='Radiator', cscfga__Description__c='Radiator');
    	insert prod1;
    	insert prod2;
    	insert prod3;
    	insert prod4;
    	insert prod5;
    	//
    	cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
    	insert basket;
    	//
    	cscfga__Product_Configuration__c prodConfig1 = new cscfga__Product_Configuration__c(name='test',cscfga__Product_Definition__c=prod1.Id,cscfga__Product_Basket__c=basket.Id);
    	cscfga__Product_Configuration__c prodConfig2 = new cscfga__Product_Configuration__c(name='test',cscfga__Product_Definition__c=prod2.Id,cscfga__Product_Basket__c=basket.Id);
    	cscfga__Product_Configuration__c prodConfig3 = new cscfga__Product_Configuration__c(name='test',cscfga__Product_Definition__c=prod3.Id,cscfga__Product_Basket__c=basket.Id);
    	cscfga__Product_Configuration__c prodConfig4 = new cscfga__Product_Configuration__c(name='test',cscfga__Product_Definition__c=prod4.Id,cscfga__Product_Basket__c=basket.Id);
    	cscfga__Product_Configuration__c prodConfig5 = new cscfga__Product_Configuration__c(name='test',cscfga__Product_Definition__c=prod5.Id,cscfga__Product_Basket__c=basket.Id);
    	insert prodConfig1;
    	insert prodConfig2;
    	insert prodConfig3;
    	insert prodConfig4;
    	insert prodConfig5;
    	//
    	ApexPages.Standardcontroller sc = new ApexPages.StandardController(basket);
        BasketViewerController basketController = new BasketViewerController(sc);
        //
        BasketViewerController.getMainProduct(basket.Id);
    }
}