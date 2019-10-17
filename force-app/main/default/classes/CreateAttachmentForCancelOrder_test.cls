@isTest
private class CreateAttachmentForCancelOrder_test 
{
	static testmethod void CreateAttachmentForCancelOrderMethods()
	{
	    CreateAttachmentForCancelOrder CAFCO = new CreateAttachmentForCancelOrder();
	    Messaging.inboundEmail email = new Messaging.inboundEmail();
	    Messaging.inboundEmail.Binaryattachment attach = new Messaging.inboundEmail.Binaryattachment();
	    attach.Body = Blob.valueOf('test');
	    email.subject = 'test mail\\|test';
	    email.BinaryAttachments = new List<Messaging.inboundEmail.Binaryattachment>();
	    email.BinaryAttachments.Add(attach);
	    
	    Messaging.InboundEnvelope env;
	    CAFCO.handleInboundEmail(email, env);
    }
}