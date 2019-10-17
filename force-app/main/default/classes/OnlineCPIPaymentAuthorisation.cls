/**
    Class Name: OnlineCPIPaymentAuthorisation
    
    This class is used for the Online Payment 
    Authorisation using Barclay Card Online Payment Portal
    and for redirection to the Payment Collection detail page.
    
    This class fetches the data from the Barclay Card CPI site.
    Barclay Card CPI sends data using Server Request Variable. 
    The Server Variables are sent in specific formats and variables
    The variables that are sent are as follows:
    1. transactionstatus    : Outcome of the authorisation request.
    2. oid  : Text string containing the order identification number. 
    3. clientid : Store Id, assigned by Barclays Card.
    4. total    : Total numeric value presented for authorisation
    5. chargetype   : Text string indicating the chargetype specified for the transaction. 
                        (Either Auth or PreAuth).
    6. datetime : Text string indicating when the order was submitted by the CPI checkout. 
                    The date will always be in this format. e.g. Jan 23 2004 15:45:51
    7. ecistatus    : The Internet Authentication response. 
                        Only provided if you are enrolled in Internet Authentication 
                        and the transaction was Visa, MasterCard or Maestro.
                        
    Process to fetch the Payment Collection Id from OID
    Before the Barclay CPI transaction started, the data was encrypted. 
    During the Encryption, the BGS Reference Number is concanated with 
    the number of child payments taken which is always of 2 digits. 
    A single digit number is always prefix with 0.
    While getting the payment collection id, we need to remove the 
    last 2 digits from oid.
    

**/
public class OnlineCPIPaymentAuthorisation {
    /**
        Method Name : init
        
        This method is used to read through all the details that has been sent using Server Variables.
        Once all the data has been fetched, a new payment record is being created as the child record
        of Payment Collection Note
        The Function also fetches the BGS Reference Number from the Order Id variable.
    **/
    public PageReference init(){
        try {
        String str_TransactionStatus=System.currentPageReference().getParameters().get('transactionstatus');
        String str_Oid=System.currentPageReference().getParameters().get('oid');
        String str_ClientId=System.currentPageReference().getParameters().get('clientid');
        Double dblAmtPaid=Double.valueOf(System.currentPageReference().getParameters().get('total'));
        String strChargeType=System.currentPageReference().getParameters().get('chargetype');
        String strOrderDateTime=System.currentPageReference().getParameters().get('datetime');
        String strECIStatus=System.currentPageReference().getParameters().get('ecistatus');
        Id str_RecordType=RecordTypeIdHelper.getRecordTypeId('Payments__c','Online Card');
        Payments__c obj_Payment=new Payments__c();
        String strBGSRefNum=str_Oid.substring(0, str_Oid.length()-2);
        String strPaymentCollecId=[select Id from Payment_Collection__c where BGS_Payment_Reference_Num__c=:strBGSRefNum].Id;
        obj_Payment.Payment_Collection_Notice__c=strPaymentCollecId;
        obj_Payment.Amount_Collected__c=dblAmtPaid;
        obj_Payment.Payment_Type__c='Balance Payment';
        if (str_TransactionStatus=='Success') {
            obj_Payment.Status__c='Card Authorised';
        } else if (str_TransactionStatus.contains('DECLINED')) {
            obj_Payment.Status__c='Card Declined';
        } else {
            obj_Payment.Status__c='Card Declined';
        }
        obj_Payment.ECI_Status__c=strECIStatus;
        obj_Payment.Is_Online_Payment__c=true;
        obj_Payment.RecordTypeId=str_RecordType;
        obj_Payment.BGS_Special_Reference_ID__c=str_Oid;
        insert obj_Payment;
        return null;
        } catch(Exception ex){
            System.debug('Error : ' + ex.getMessage());
            return null;
        }   
    }

    /**
        Method Name : redirect
        
        This method is used to redirected from the "OnlineCPIPaymentRedirection" to the Payment Collection Notes    
        
    **/    
    public PageReference redirect(){
        String str_Oid=System.currentPageReference().getParameters().get('oid');
        String strBGSRefNum=str_Oid.substring(0, str_Oid.length()-2);
        String strPaymentCollecId=[select Id from Payment_Collection__c where BGS_Payment_Reference_Num__c=:strBGSRefNum].Id;
        PageReference pgRirect=new PageReference('/' +strPaymentCollecId);
        pgRirect.setRedirect(true);
        return pgRirect;
    }
}