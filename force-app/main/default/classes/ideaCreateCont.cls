public class ideaCreateCont{

    
    public idea newidea {get;set;}
    public boolean showSub {get;set;}
    public boolean aftPub{get;set;}
    public string message{get;set;}
    Utilities util = new Utilities();
    public Attachment attachment {
        get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
        }
      set;
      }

    public ideaCreateCont()
    {
        newidea = new idea();
        newidea.On_Behalf_Of__c = userinfo.getUserId();
    }    
    
    public pagereference post()
    {
      
       try {
            newidea.Status = 'Submitted';
            string contentype = 'image/jpeg';
            
           if(attachment.body!=null)
           {
           	if(attachment.Name.contains('.doc')||attachment.Name.contains('.dox'))
            {
            	contentype = 'application/msword';
			}else if(attachment.Name.contains('.pdf'))
            {
            	contentype = 'application/pdf';
            }
            newIdea.AttachmentBody = attachment.body;
            newIdea.AttachmentName   = attachment.Name;
            newIdea.AttachmentContentType   = contentype;
           } 
            insert newidea;
            showSub = false;
            aftPub = true;
            message = 'Sucessfully Posted';
            util.setErrorMsg(false, message);
            newidea = new Idea();
        }catch (Exception e){
            message = 'Oops.... Somethinng went wrong!';
            util.setErrorMsg(false, message);
        }
        return null;
    }
    
    public void draft()
    {
        showSub = true;
        aftPub = true;
        newidea.Status = 'Draft';
        insert newidea;
    }
        
}