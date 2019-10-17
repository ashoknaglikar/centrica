@isTest
public class wwwBarclaysPartnerfinanceComMockImpl implements WebServiceMock {
 
 public void doInvoke(
      Object stub,
      Object request,
      Map<String, Object> response,
      String endpoint,
      String soapAction,
      String requestName,
      String responseNS,
      String responseName,
      String responseType) {
       
    System.debug(LoggingLevel.INFO, 'toaCapacityMockImpl.doInvoke() - ' +
      '\n request: ' + request +
      '\n response: ' + response +
      '\n endpoint: ' + endpoint +
      '\n soapAction: ' + soapAction +
      '\n requestName: ' + requestName +
      '\n responseNS: ' + responseNS +
      '\n responseName: ' + responseName +
      '\n responseType: ' + responseType);

    if(request instanceOf wwwBarclaysPartnerfinanceCom.SatisfyChecklistCondition_element) {
      response.put( 'response_x', new wwwBarclaysPartnerfinanceCom.SatisfyChecklistConditionResponse_element());
    }
    else if(request instanceOf wwwBarclaysPartnerfinanceCom.LoadVATInvoice_element) {
      response.put( 'response_x', new wwwBarclaysPartnerfinanceCom.LoadVATInvoiceResponse_element());
    }
    else if(request instanceOf wwwBarclaysPartnerfinanceCom.ApplicationEnquiry_element) {
        wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element respElement = new wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element();
        wwwBarclaysPartnerfinanceCom.ApplicationDataWO app =new wwwBarclaysPartnerfinanceCom.ApplicationDataWO();
        app.ApplicationStatus='Declined';
        app.AgreementNumber='1234';
        respElement.Status='success';
        respElement.Application=app;
        response.put( 'response_x', respElement);
    }
    else if(request instanceOf wwwBarclaysPartnerfinanceCom.SendApplicationDecision_element) {
      response.put( 'response_x', new wwwBarclaysPartnerfinanceCom.SendApplicationDecisionResponse_element());
    }
    else if(request instanceOf wwwBarclaysPartnerfinanceCom.IntroducerResponse_element) {
      response.put( 'response_x', new wwwBarclaysPartnerfinanceCom.IntroducerResponseResponse_element());
    }
     else if(request instanceOf wwwBarclaysPartnerfinanceCom.SubmitDocument_element) {
      response.put( 'response_x', new wwwBarclaysPartnerfinanceCom.SubmitDocumentResponse_element());
    } 
    else if(request instanceOf wwwBarclaysPartnerfinanceCom.ValidateApplication_element) {
      response.put( 'response_x', new wwwBarclaysPartnerfinanceCom.ValidateApplicationResponse_element());
    } 
    else if(request instanceOf wwwBarclaysPartnerfinanceCom.ValidateAddress_element) {
      response.put( 'response_x', new wwwBarclaysPartnerfinanceCom.ValidateAddressResponse_element());
    } 
    else if(request instanceOf wwwBarclaysPartnerfinanceCom.LoadApplication_element) {
        wwwBarclaysPartnerfinanceCom.LoadApplicationResponse_element respElement = new wwwBarclaysPartnerfinanceCom.LoadApplicationResponse_element();
        wwwBarclaysPartnerfinanceCom.ResultWO result = new wwwBarclaysPartnerfinanceCom.ResultWO();
        result.ApplicationStatus='accepted';
        result.Status='success';
        result.ApplicationId=1234;
        respElement.LoadApplicationResult=result;
        response.put('response_x', respElement); 
    } 
    else if(request instanceOf wwwBarclaysPartnerfinanceCom.FinanceQuote_element) {
      response.put( 'response_x', new wwwBarclaysPartnerfinanceCom.FinanceQuoteResponse_element());
    }
    
    return ;
  }
  
  private static testMethod void coverTypes()
    {
        new wwwBarclaysPartnerfinanceCom.IncomeSourceWO();
        new wwwBarclaysPartnerfinanceCom.IncomeWO();
        new wwwBarclaysPartnerfinanceCom.ResultWO();
        new wwwBarclaysPartnerfinanceCom.BrokerChildWO();
        new wwwBarclaysPartnerfinanceCom.ValidateApplicantWO();
        new wwwBarclaysPartnerfinanceCom.InvoiceDetailsWO();
        new wwwBarclaysPartnerfinanceCom.LoadVATInvoiceResultWO();
        new wwwBarclaysPartnerfinanceCom.NoteWO();
        new wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element();
        new wwwBarclaysPartnerfinanceCom.ValidateApplicationResultWO();
        new wwwBarclaysPartnerfinanceCom.FinanceQuoteResponse_element();
        new wwwBarclaysPartnerfinanceCom.AdditionalIncomeSourceWO();
        new wwwBarclaysPartnerfinanceCom.CustomerProofsWO();
        new wwwBarclaysPartnerfinanceCom.SatisfyChecklistConditionResultWO();
        
        new wwwBarclaysPartnerfinanceCom.InvoiceHeaderWO();
        new wwwBarclaysPartnerfinanceCom.FinanceQuoteResultWO();
        new wwwBarclaysPartnerfinanceCom.ContactNameWO();
        new wwwBarclaysPartnerfinanceCom.LoadApplication_element();
        new wwwBarclaysPartnerfinanceCom.EmploymentWO();
        new wwwBarclaysPartnerfinanceCom.ArrayOfChecklistConditionIdentifierWO();
        new wwwBarclaysPartnerfinanceCom.ArrayOfConditionWO();
        new wwwBarclaysPartnerfinanceCom.AssetWO();
        new wwwBarclaysPartnerfinanceCom.FinanceQuote_element();
        new wwwBarclaysPartnerfinanceCom.ArrayOfInvoiceLineWO();
        new wwwBarclaysPartnerfinanceCom.InvoiceLineWO();
        new wwwBarclaysPartnerfinanceCom.IntroducerResponseResponse_element();
        new wwwBarclaysPartnerfinanceCom.IntroducerResponseResultWO();
        new wwwBarclaysPartnerfinanceCom.AliasAssociationWO();
        new wwwBarclaysPartnerfinanceCom.ContactWO();
        new wwwBarclaysPartnerfinanceCom.SubmitDocumentResultWO(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfErrorsWO(); 
        new wwwBarclaysPartnerfinanceCom.LoadVATInvoiceResponse_element(); 
        new wwwBarclaysPartnerfinanceCom.MotorWO();
        new wwwBarclaysPartnerfinanceCom.ArrayOfRetailWO(); 
        new wwwBarclaysPartnerfinanceCom.ErrorsWO(); 
        new wwwBarclaysPartnerfinanceCom.QuotePersonWO(); 
        new wwwBarclaysPartnerfinanceCom.ValidateAddressResultWO(); 
        new wwwBarclaysPartnerfinanceCom.ReturnedValidateAddressWO(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfReturnedAddressWO(); 
        new wwwBarclaysPartnerfinanceCom.ValidateAddress_element(); 
        new wwwBarclaysPartnerfinanceCom.ValidateAddressResponse_element(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfReturnedValidateAddressWO();
        new wwwBarclaysPartnerfinanceCom.IntroducerResponse_element(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfAddressWO(); 
        new wwwBarclaysPartnerfinanceCom.ChecklistConditionIdentifierWO(); 
        new wwwBarclaysPartnerfinanceCom.SendApplicationDecisionResponse_element(); 
        new wwwBarclaysPartnerfinanceCom.AddressWO(); 
        new wwwBarclaysPartnerfinanceCom.ValidateAddressWO(); 
        new wwwBarclaysPartnerfinanceCom.LoadApplicationResponse_element(); 
        new wwwBarclaysPartnerfinanceCom.PersonWO(); 
        new wwwBarclaysPartnerfinanceCom.SubmitDocumentResponse_element(); 
        new wwwBarclaysPartnerfinanceCom.RetailWO(); 
        new wwwBarclaysPartnerfinanceCom.ApplicationDataWO(); 
        new wwwBarclaysPartnerfinanceCom.ResponseNoteWO(); 
        new wwwBarclaysPartnerfinanceCom.SubmitDocument_element(); 
        new wwwBarclaysPartnerfinanceCom.ValidateApplicationResponse_element(); 
        new wwwBarclaysPartnerfinanceCom.ContactPreferenceWO(); 
        new wwwBarclaysPartnerfinanceCom.BankAccountWO(); 
        new wwwBarclaysPartnerfinanceCom.FinanceWO(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfNoteWO(); 
        new wwwBarclaysPartnerfinanceCom.ValidateApplication_element(); 
        new wwwBarclaysPartnerfinanceCom.AdditionalProductWO(); 
        new wwwBarclaysPartnerfinanceCom.SendApplicationDecisionResultWO();
        new wwwBarclaysPartnerfinanceCom.ApplicationWO(); 
        new wwwBarclaysPartnerfinanceCom.SendApplicationDecision_element(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfGuidDetailWO(); 
        new wwwBarclaysPartnerfinanceCom.ChecklistConditionRejections(); 
        new wwwBarclaysPartnerfinanceCom.ChecklistConditionRejection(); 
        new wwwBarclaysPartnerfinanceCom.QuoteWO(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfReturnedAdditionalProductWO(); 
        new wwwBarclaysPartnerfinanceCom.SatisfyChecklistCondition_element(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfCustomerProofsWO(); 
        new wwwBarclaysPartnerfinanceCom.CCADocumentWO(); 
        new wwwBarclaysPartnerfinanceCom.ContactEmailWO(); 
        new wwwBarclaysPartnerfinanceCom.ApplicationEnquiry_element(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfContactPreferenceWO(); 
        new wwwBarclaysPartnerfinanceCom.PhoneNumberWO(); 
        new wwwBarclaysPartnerfinanceCom.LoadVATInvoice_element(); 
        new wwwBarclaysPartnerfinanceCom.ReturnedAdditionalProductWO(); 
        new wwwBarclaysPartnerfinanceCom.ExpenditureWO(); 
        new wwwBarclaysPartnerfinanceCom.GuidDetailWO(); 
        new wwwBarclaysPartnerfinanceCom.ReturnedAddressWO(); 
        new wwwBarclaysPartnerfinanceCom.EmploymentAddressWO(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfAdditionalProductWO(); 
        new wwwBarclaysPartnerfinanceCom.SatisfyChecklistConditionResponse_element(); 
        new wwwBarclaysPartnerfinanceCom.ArrayOfAliasAssociationWO(); 
        new wwwBarclaysPartnerfinanceCom.ConditionWO(); 
       
        
    }
  @isTest  
  private static void coverMethods()
    {   
        System.Test.setMock(WebServiceMock.class, new wwwBarclaysPartnerfinanceComMockImpl());
        
        new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap().SatisfyChecklistCondition(null, null, null, null,null, null);
        new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap().LoadVATInvoice(null,null,null,null,null,null);
        new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap().ApplicationEnquiry(null,null,null,null,null,null);
        new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap().SendApplicationDecision(null,null,null,null,null,null);
        new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap().IntroducerResponse(null,null,null,null,null,null,null);
        new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap().SubmitDocument(null,null,null,null,null,null,null,null,null);
        new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap().ValidateApplication(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
        new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap().ValidateAddress(null,null,null,null,null);
        new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap().LoadApplication(null,null,null,null,null,null,null);
        new wwwBarclaysPartnerfinanceCom.BpfWebServiceSoap().FinanceQuote(null,null,null,null);
        
    
    
    }
}