public class CS_QuoteOnlineActualPdfController {
	public String pageContent {get;set;}
	public String quoteRef {get;set;}
    public List<Attachment> attList {get; set;}
	public String footerCode {get; set;}
	public String pageFooter {get; set;}

    public CS_QuoteOnlineActualPdfController(ApexPages.StandardController c) {
        
        Id attachmentId = ApexPages.CurrentPage().getParameters().get('pageAttId');
		quoteRef = ApexPages.CurrentPage().getParameters().get('quoteRef');
		footerCode =  ApexPages.CurrentPage().getParameters().get('footerCode');

		String companyName = footerCode == 'BG' ? 'British Gas' : 'Scottish Gas';

		pageFooter = companyName + ' is a trading name of British Gas New Heating Limited. Registered in England and Wales (No. 06723244). British Gas New Heating Limited is an Appointed Representative of British Gas Services Limited which is authorised and regulated by the Financial Conduct Authority. Both registered at: Millstream, Maidenhead Road, Windsor, Berkshire SL4 5GD. britishgas.co.uk';
        
        attList = [SELECT Id, Name, Body, ParentId 
					FROM Attachment 
					WHERE Id = :attachmentId 
					AND Name = :CS_QuoteOnlineTemplateController.TEMP_ONLINE_QUOTE_ATT_NAME];
       
        if(attList.size() > 0) {
            Attachment a = attList[0];
            
            if(a != null) {
                pageContent = a.Body.toString();
                
            }
        }
    }
    
    public void deleteTempAttachment() {
        if(attList.size() > 0) {
            Attachment a = attList[0];
            
            delete a;
        }
    }
}