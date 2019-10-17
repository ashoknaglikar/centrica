/**
    Class Name: OnlinePaymentCollection
    
    This class is used for the Online Payment 
    Collection using Barclay Card Online Payment Portal.
    
    This class fetches the data from the Payment Collection 
    Object based on the Record Id that is been passed through URL 
    when the page "OnlineCPIPayment" is called. 
    This class has webservice call to Barclay Card Encryption Tool.
    For the Encryption, we need to send Client Id,Passphrase,
    Order Id,Charge Type and Total Amount.
    The Order Id has to be unique id, once a Order Id has been 
    successfully transacted successfully that Id cannot be used any more. 
    The Oid sent to the Barclay Card CPI solution is created by suffixing 
    BGS Payment Reference NUmber and number of payments. The number of payments 
    are prefixed with 0 if the number of payment is in single digit.
**/
public class OnlinePaymentCollection {
    public Payment_Collection__c obj_PymtCol{get;set;}
    public Payments__c obj_Payment{get;set;}
    private String str_PayId;
    public String strEPDQFeed{get;set;}
    public String strAddr1{get;set;}
    public String strCity{get;set;}
    public String strCountyProvince{get;set;}
    public String strPostalCode{get;set;}
    public String strState{get;set;}
    public Boolean blnPymtGreater{get;set;}
    public Boolean blnPymtLessZero{get;set;}
    public Boolean blnAmtPymtBlank{get;set;}    
    public Boolean blnState{get;set;}
    public Boolean blnAddressBlock{get;set;}
    private Double intCount;
    private String strBGSReference;
    /* 
        Default Constructor of a class.
        This constructor is used to set data 
        and fetch data from the Payment collection Id
    */
    public OnlinePaymentCollection(){
        blnAddressBlock=false;
        blnPymtGreater=false;
        blnPymtLessZero=false;
        str_PayId=ApexPages.currentPage().getParameters().get('id');
        if (obj_PymtCol==null) {
            obj_PymtCol=[Select Opportunity__r.Account.Primary_Contact__r.MailingStreet,
                         Opportunity__r.Account.Primary_Contact__r.MailingCity,
                         Opportunity__r.Account.Primary_Contact__r.MailingState,
                         Opportunity__r.Account.Primary_Contact__r.MailingPostalCode,
                         ContactName__c, BGS_Payment_Reference_Num__c, Balance_Outstanding1__c,
                         Opportunity__r.Account.Primary_Contact__r.Email__c,Id,
                         Total_Number_of_Collection__c From Payment_Collection__c Where Id=:str_PayId];
            strBGSReference=obj_PymtCol.BGS_Payment_Reference_Num__c ;            
            strAddr1=RemoveCarriageReturn(obj_PymtCol.Opportunity__r.Account.Primary_Contact__r.MailingStreet);
            strCity=RemoveCarriageReturn(obj_PymtCol.Opportunity__r.Account.Primary_Contact__r.MailingCity);
            strCountyProvince=RemoveCarriageReturn(obj_PymtCol.Opportunity__r.Account.Primary_Contact__r.MailingState);
            strPostalCode=RemoveCarriageReturn(obj_PymtCol.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode);
            intCount=obj_PymtCol.Total_Number_of_Collection__c;
            obj_Payment=new Payments__c();
            obj_Payment.Amount_Collected__c=0.0;
        }
    } 
    /*
        Method to return back to payment collection detail page.
    */
    public PageReference BackToPaymentCollection() {
        PageReference paymentPage =new Pagereference('/' + obj_PymtCol.Id);
        paymentPage.setRedirect(true);
        return paymentPage;
    }
    /*
        Method to return back to the payment entry screen. 
        This is required for the user to modify the payment 
        details if required.
    */
    public PageReference AmendDetails() {
        return Page.OnlineCPIPayment;
    }
    /*
        Method to fetch the encrypted code for EPDQ Data. 
        This is required for the user for authentication of the entered data.
        Before the data is send for Barclay Card Encryption, a validation is done on the data.
        Validation :
        1. The amount Paid is not less than £0
        2.Amount Paid is not more than the balance outstanding. 
    */
    public PageReference enterCustomerAddress() {
        System.debug('Test User');
        if (blnAddressBlock==true) {
            blnAddressBlock=false;
        } else {
            blnAddressBlock=true;
        }
        System.debug(blnAddressBlock);
        return null;
    }
    public PageReference PayThroughBarclays(){
        try {
            if (obj_Payment.Amount_Collected__c<=0) {
                blnPymtLessZero=true;
                blnPymtGreater=false;
                blnAmtPymtBlank=false;
                return null;
            }else if (obj_Payment.Amount_Collected__c>obj_PymtCol.Balance_Outstanding1__c) {
                blnPymtGreater=true;
                blnPymtLessZero=false;
                blnAmtPymtBlank=false;
                return null;
            } else if (obj_Payment.Amount_Collected__c==null) {
                blnPymtGreater=false;
                blnPymtLessZero=false;
                blnAmtPymtBlank=true;
                return null;        
            } else {
                blnPymtGreater=false;
                blnPymtLessZero=false;
                blnAmtPymtBlank=false;
                if (blnAddressBlock==false) {
                    strAddr1=RemoveCarriageReturn(obj_PymtCol.Opportunity__r.Account.Primary_Contact__r.MailingStreet);
                    strCity=RemoveCarriageReturn(obj_PymtCol.Opportunity__r.Account.Primary_Contact__r.MailingCity);
                    strCountyProvince=RemoveCarriageReturn(obj_PymtCol.Opportunity__r.Account.Primary_Contact__r.MailingState);
                    strPostalCode=RemoveCarriageReturn(obj_PymtCol.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode);
                }
                Http obj_Http = new Http();
                /*
                    Bug fix : 15/02/12 Cognizant
                    After spring 12 release obj_PymtCol.Total_Number_of_Collection__c started giving us decimal values with "." (like 0.0) which 
                    in turn caused problems in interface. So next line will only get integer value from this field.
                */
                integer paymentCol = (obj_PymtCol.Total_Number_of_Collection__c).intValue();
                String strNoOfPayment=String.valueOf(paymentCol);
                if (strNoOfPayment.length()==1) {
                    strNoOfPayment='0' + strNoOfPayment;
                }
                String strOrderId=strBGSReference + strNoOfPayment;
                // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                HttpRequest http_Req = new HttpRequest();
                /*End Point for Production Credential*/
                http_Req.setEndpoint('https://secure2.epdq.co.uk/cgi-bin/CcxBarclaysEpdqEncTool.e');
                String str_RequestBody='clientid=51989&password=March2010&oid='+ strOrderId +'&chargetype=Auth&currencycode=826&total=' + obj_Payment.Amount_Collected__c;
                /*End Point for Sandbox Credential*/
                //http_Req.setEndpoint('https://secure2.mde.epdq.co.uk/cgi-bin/CcxBarclaysEpdqEncTool.e');
  				//String str_RequestBody='clientid=2187&password=february10&oid='+ strOrderId +'&chargetype=Auth&currencycode=826&total=' + obj_Payment.Amount_Collected__c;              
                                
                http_Req.setBody(str_RequestBody);
                http_Req.setMethod('POST');
                // Send the request, and return a response
                HttpResponse http_Res = obj_Http.send(http_Req);
                strEPDQFeed= http_Res.getBody();
                Integer intPos=strEPDQFeed.indexOf('value="');
                String str_ToRemove='value="';
                Integer intPosY=str_ToRemove.length();
                String strTemp=strEPDQFeed.substring(intPos+ intPosY);
                List<String> lst_Data=strTemp.split('"');
                strEPDQFeed=lst_Data[0];
                return Page.OnlineCPIPaymentConfirmation;
            }
        }catch(Exception ex){
            System.debug('Error :' + ex.getMessage());
            return null;
        }
    }
    /*
        Method to remove the carriage returns from address field.
        This method is useful for removal of any carriage return on any field
    */
    public String RemoveCarriageReturn(String strInput) {
        String strTemp='';
        if (strInput!=null) {
            if (strInput!='') {
                strTemp=strInput.replace('\r\n', ' ');
                return strTemp;
            } else {
                strTemp='';
                return strTemp;
            }
        } else {
            strTemp='';
            return strTemp;
        }
    }
}