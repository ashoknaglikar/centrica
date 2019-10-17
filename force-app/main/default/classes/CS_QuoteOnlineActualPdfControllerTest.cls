@isTest
public class CS_QuoteOnlineActualPdfControllerTest {
	private static testMethod void testCS_QuoteOnlineActualPdfController() {

        //Create a Basket
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c();
        prodBasket.Name = 'BasketTest';
        insert prodBasket;
        
        Id basketId = prodBasket.id;

        // create an attachment
        Attachment att = new Attachment();
        att.ParentId = basketId;
        att.Body = Blob.valueOf('test page content');
        att.Name = CS_QuoteOnlineTemplateController.TEMP_ONLINE_QUOTE_ATT_NAME;
        upsert att;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(prodBasket);
        ApexPages.currentPage().getParameters().put('pageAttId', att.id);
        CS_QuoteOnlineActualPdfController controller;

        try {
            controller = new CS_QuoteOnlineActualPdfController(sc);
        } catch (Exception ex) {
            system.assert(false, 'The pdf has not been rendered properly');
        }

		// we should now have one attachment
		List<Attachment> aList = [Select Id, Name, Body, ParentId from Attachment where ParentId = :basketId and Name = :CS_QuoteOnlineTemplateController.TEMP_ONLINE_QUOTE_ATT_NAME];
        System.assertEquals(1, aList.size());

		// which must be deleted        
        controller.deleteTempAttachment();
        List<Attachment> aListEmpty = [Select Id, Name, Body, ParentId from Attachment where ParentId = :basketId and Name = :CS_QuoteOnlineTemplateController.TEMP_ONLINE_QUOTE_ATT_NAME];
        
        System.assertEquals(0, aListEmpty.size());
	}
}