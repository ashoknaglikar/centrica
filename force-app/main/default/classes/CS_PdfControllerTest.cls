@isTest
private class CS_PdfControllerTest {
    
    static Id basketId {get; set;}

	private static testMethod void controllerTest() {

        //Create a Basket
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c();
        prodBasket.Name = 'BasketTest';
        insert prodBasket;
        
        basketId = prodBasket.id;
        
        // create an attachment
        Attachment att = new Attachment();
        att.ParentId = basketId;
        att.Body = Blob.valueOf('test page content');
        att.Name = 'PDF_TEMP_ATTACHMENT.txt';
        upsert att;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(prodBasket);
        ApexPages.currentPage().getParameters().put('id', basketId);
        CS_PdfController controller;
        try {
            controller = new CS_PdfController(sc);
        } catch (Exception ex) {
            system.assert(false, 'The pdf has not been rendered properly');
        }
        
        controller.deleteTempAttachment();
        List<Attachment> aList = [Select Id, Name, Body, ParentId from Attachment where ParentId = :basketId and Name = 'PDF_TEMP_ATTACHMENT.txt'];
        
        System.assertEquals(0, aList.size());
	}

}