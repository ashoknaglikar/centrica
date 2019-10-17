global class CreateAttachmentForCancelOrder implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){
    
        // Create an inboundEmailResult object for returning the result of the Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String sOrder=email.subject;
        List<String> orderArr=sOrder.split('\\|');
        System.debug('orderArr : ' + orderArr);
        sOrder=orderArr[1];
        
        try {
        
        List<Attachment> attachmentLst=[Select ParentId, Id From Attachment Where ParentId =:sOrder];
        if (attachmentLst!=null) {
            delete attachmentLst;
        }
        	
        Attachment attachment=new Attachment();
        
        attachment.body=email.BinaryAttachments[0].body;
        attachment.Name='Order Cancellation.pdf';
        attachment.ParentId=sOrder;
        attachment.ContentType='application/pdf';
        insert attachment;
        } catch (exception ex) {
            System.debug('@Exception');
        }
        // Return the result for the Apex Email Service
        return result;
    
    }
}