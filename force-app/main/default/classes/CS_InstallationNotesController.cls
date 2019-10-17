public class CS_InstallationNotesController {

    public Id appId {get; set;}
    public Id attId {get;set;}
    public Id oppId {get;set;}
    public String quoteRef {get;set;}
    public String logoType {get;set;}
    public class InputInstallationNotes {
	    public String FooterText {get;set;}
	    public String LogoPng {get;set;}
	    public String CHILeadNumber {get;set;}
	    public String AsbestosIdentified {get;set;}
	    public String AsbestosNotes {get;set;}
	    public String EarthSystem {get;set;}
	    public String VisibleEarth {get;set;}
	    public String Voelcb {get;set;}
	    public String CustomerArrange {get;set;}
	    public String Rdc {get;set;}
	    public String SocketSee {get;set;}
	    public String EarthLocation {get;set;}
	    public String Peb {get;set;}
	    public String Seb {get;set;}
	    public String LadderWork {get;set;}
	    public String Scaffolding {get;set;}
	    public String AccessNotes {get;set;}
	    public String WorkAreas {get;set;}
	    public String RemovalAssistance {get;set;}
	    public String AllNotes {get;set;}
	    public String Radiator {get;set;}
	    public String Flow {get;set;}
	    public String WaterTestPressure {get;set;}
	    public String SystemCharacter {get;set;}
	    public String asbestosConfirmed {get;set;}
	    public String boilerDetailsTable {get;set;}
	    public string connectedProductAdded{get;set;}
	    public string suspectMaterials {get;set;}
	    public string connectedEmail {get;set;}
	    public string visitDate {get;set;}
	    public string customerName{get;set;}
	    public string customerAddress {get;set;}
	    public string quoteReference {get;set;}
	    public string tradingName {get;set;}
	    public string asbestosSample {get;set;}
	    public string jobTitle {get;set;}
	    public string productDefinition {get;set;}
	    
	}
    public InputInstallationNotes inputNotes {get;set;}
    public String logoCSSClass {get;set;}
    public String content;
    
    public static final String TEMP_ATT_NAME = 'TEMP_INSTALLATION_NOTE.txt';
    
    private List<Attachment> attList;

    public CS_InstallationNotesController(ApexPages.StandardController c) {
        attId = ApexPages.currentPage().getParameters().get('attId');
        appId = ApexPages.currentPage().getParameters().get('appId');
        oppId = ApexPages.currentPage().getParameters().get('oppId');  
        quoteRef = ApexPages.currentPage().getParameters().get('quoteRef'); 
        logoType = ApexPages.currentPage().getParameters().get('logoType');  

        if (logoType=='SG') {
            logoCSSClass = 'sg-logo-box';
        } else {
            logoCssClass = 'bg-logo-box';
        }

        
        attList = [Select Id, Name, Body, ParentId from Attachment where Id = :attId and Name = :TEMP_ATT_NAME];
        system.debug(attList);
        
        if (attList.size() > 0) {
            Attachment a = attList[0];
            String content = a.body.toString();

            try {
            	inputNotes = (InputInstallationNotes) JSON.deserialize(content, InputInstallationNotes.class);
            } catch (Exception e) {
            	System.debug('*****Failed to parse input Installation Notes with exception: ' + e);
            }
            
            inputNotes.AsbestosNotes = reformatAsbestosNotesHtml(inputNotes.AsbestosNotes);
        }
        /*
        messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
        String[] toAddresses = new list<string>{'ashokkumar.nagaleekar@centrica.com'};
        //String[] ccAddresses = new String[] {'sfdcsrini@gmail.com'};
        mail.setToAddresses(toAddresses);
        //mail.setCcAddresses(ccAddresses);
        //mail.setReplyTo(toaddress);
        mail.setSenderDisplayName('Name');
        mail.setSubject('Testing email through apex');
        mail.setBccSender(false);
        //mail.setUseSignature(true);
        mail.setPlainTextBody('This is test email body. This mail is being sent from apex code');
        //mail.setHtmlBody('<b> This is HTML body </b>' );
        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        //for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :caseId]){
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(attList[0].Name);
        efa.setBody(attList[0].Body);
        fileAttachments.add(efa);
        //mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
        mail.setFileAttachments(fileAttachments);
        
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    */

    }
    
    public static String reformatAsbestosNotesHtml(String asbNotesHtml) {
        String retVal = '';
        if (asbNotesHtml!=null && asbNotesHtml.contains('class=\'warning\'')) {
            List<String> asbTemp = asbNotesHtml.split('Asbestos Identified</p>');
            List<String> asbPart2 = asbTemp[1].split('</span>');
            
            Pattern regA = Pattern.compile('<p>');
            asbPart2[0] = regA.matcher(asbPart2[0]).replaceAll('<li>');
            
            Pattern regB = Pattern.compile('</p>');
            asbPart2[0] = regB.matcher(asbPart2[0]).replaceAll('</li>');
            
            retVal ='<div class=\'warning\'><p class=\'boldFont\'>Asbestos Identified</p><ol>'+asbPart2[0]+'</ol></div>';
        } else {
            retVal = asbNotesHtml;
        }
        
        return retVal;
    }
    
    public void deleteTempAttachment() {
        if (attList.size() > 0) {
            Attachment a = attList[0];
            delete a;
        }
    }
}