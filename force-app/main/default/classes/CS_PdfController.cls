public class CS_PdfController {

    public String pageContent {get;set;}
    public Id basketId {get; set;}
    public List<Attachment> attList {get; set;}

    public CS_PdfController(ApexPages.StandardController c) {
        
        basketId = ApexPages.CurrentPage().getParameters().get('id');
        
        system.debug(basketId);
        
        attList = [Select Id, Name, Body, ParentId from Attachment where ParentId = :basketId and Name = 'PDF_TEMP_ATTACHMENT.txt'];
        system.debug(attList);
        
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