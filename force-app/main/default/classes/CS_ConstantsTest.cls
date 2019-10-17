@isTest
public class CS_ConstantsTest {
 static testMethod void constantsTest() {
 
    CS_Constants cs = new CS_Constants();
    System.assertEquals('Standard', CS_Constants.CS_PricebookType_Standard);      
    System.assertEquals('Pricebook3', CS_Constants.CS_PricebookType_Pricebook3);    
    System.assertEquals('Pricebook4', CS_Constants.CS_PricebookType_Pricebook4);    
    System.assertEquals('Low Cost', CS_Constants.CS_PricebookType_LowCost);    
    System.assertEquals('Requires', CS_Constants.CS_PartAssociationRelationship_Requires);    
    System.assertEquals('Cloned', CS_Constants.ProductConfiguration_ClonedStatus);    
    System.assertEquals('Quote Finalised - Accepted', CS_Constants.QuoteStatus_FinalizedAccepted);    
    System.assertEquals('Quote Status', CS_Constants.QuoteStatusAttributeName);    
    System.assertEquals('Quote Reference', CS_Constants.QuoteReferenceAttributeName);
    System.assertEquals('Total Price Payable', CS_Constants.TotalPricePayableAttributeName);    
    System.assertEquals('Cloned', CS_Constants.ProductConfiguration_ClonedStatus);    
    System.assertEquals('partsModel.txt', CS_Constants.PartsModelFileName);    
    System.assertEquals('Quote PDF', CS_Constants.PdfQuoteFileNamePrefix);    
    System.assertEquals('Customer confirmation form', CS_Constants.PdfCustomerConfirmationFormPrefix);
    System.assertEquals('Finance Illustration.pdf', CS_Constants.PdfFinanceIllustrationName);
    System.assertEquals('Installation notes', CS_Constants.InstallationNotesPDF);
  }

}