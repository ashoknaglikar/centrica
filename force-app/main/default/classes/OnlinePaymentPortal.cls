global class OnlinePaymentPortal {
	
	/**
		A apex class which stores the payment record based on the payment sfdc id
		refered by the external web service client
		The class is used as an object which stores data of the payment record
	*/    
	global class PaymentRecord {
		webservice String str_Customer; //Stores the Customer Name
		webservice String str_Street; //Stores the Street details of Installation Address
		webservice String str_City; //Stores the City details of Installation Address
		webservice String str_County; //Stores the County details of Installation Address
		webservice String str_PostCode; //Stores the Post Code details of Installation Address
		webservice String str_Country; //Stores the Country details of Installation Address
		webservice String str_PaymentRefNo; //Stores the Payment Reference Number
		webservice Double dbl_OutstandingAmt; // Stores the Outstanding Amount
		webservice String str_MerchantId; //Stores the Merchant Id
		webservice String str_InstallerId; //Stores the Installer Store Id
		webservice Integer int_PaymentType; 
		webservice String str_PaymentSFDCId;
		webservice String str_AuthorizationCode;
		webservice Double dbl_AmtPaid;
		webservice String str_TransactionStatus; 
	}
	
	/**
		The method "fetchPaymentDetails" is the method which is used for fetching
		the payment information from the salesforce.com to the online payment portal.
	*/
    webService static PaymentRecord fetchPaymentDetails (String str_PaymentId) {
    	PaymentRecord obj_PaymentRec=new PaymentRecord();
    	obj_PaymentRec.str_PaymentSFDCId=str_PaymentId;
    	Payment_Collection__c obj_Payment=[select Opportunity__r.Account.Primary_Contact__r.Name, 
    	Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingState,
    	Opportunity__r.Account.BillingPostalCode,Opportunity__r.Account.BillingCountry,
		Opportunity__r.Account.BillingCity,
		Balance_Outstanding__c, BGS_Payment_Reference_Num__c from Payment_Collection__c where Id=:str_PaymentId];
		
		if (obj_Payment<>null) {
			obj_PaymentRec.str_Customer=obj_Payment.Opportunity__r.Account.Primary_Contact__r.Name;
			obj_PaymentRec.str_Street=obj_Payment.Opportunity__r.Account.BillingStreet;
			obj_PaymentRec.str_City=obj_Payment.Opportunity__r.Account.BillingCity;
			obj_PaymentRec.str_County=obj_Payment.Opportunity__r.Account.BillingState;
			obj_PaymentRec.str_PostCode=obj_Payment.Opportunity__r.Account.BillingPostalCode;
			obj_PaymentRec.str_Country=obj_Payment.Opportunity__r.Account.BillingCountry;
			obj_PaymentRec.str_PaymentRefNo=obj_Payment.BGS_Payment_Reference_Num__c;
			obj_PaymentRec.dbl_OutstandingAmt=obj_Payment.Balance_Outstanding__c;
			obj_PaymentRec.str_MerchantId='1';
			obj_PaymentRec.str_InstallerId='2';
		}
    	return obj_PaymentRec;
    }
	/**
		The method "updatePaymentDetails" is the method which is used for update
		the payment information to the salesforce.com from the online payment portal.
		This method updates the Payment Collection object for a single job. This function 
		also inserts record in the Payments record which is the child object.
	*/
    webService static void updatePaymentDetails(PaymentRecord obj_PaymentRec) {
        
        String str_RecordTypeId=RecordTypeIdHelper.getRecordTypeId('Payments__c', 'Card');
        
        Payments__c	obj_PaymentRcvd=new Payments__c	();
        
        if (obj_PaymentRec.str_AuthorizationCode==null) {
        	obj_PaymentRcvd.Amount_Collected__c=0;
        	obj_PaymentRcvd.ePDQ_Authorisation_Code__c='';
        	obj_PaymentRcvd.Status__c='Card Declined';	
        } else {
        	if (obj_PaymentRec.str_AuthorizationCode=='') {
        		obj_PaymentRcvd.Amount_Collected__c=0;
        		obj_PaymentRcvd.ePDQ_Authorisation_Code__c='';
        		obj_PaymentRcvd.Status__c='Card Declined';
        	} else {
        		obj_PaymentRcvd.Amount_Collected__c=obj_PaymentRec.dbl_AmtPaid;
        		obj_PaymentRcvd.ePDQ_Authorisation_Code__c=obj_PaymentRec.str_AuthorizationCode;
        		obj_PaymentRcvd.Status__c='Card Authorised';
        	}
        }
        obj_PaymentRcvd.Is_Online_Payment__c=true;
        obj_PaymentRcvd.Payment_Date__c=System.today();
        if (obj_PaymentRec.int_PaymentType==1) {
        	obj_PaymentRcvd.Payment_Taken_on_Phone_to_Office__c=true;
        } else {
        	obj_PaymentRcvd.Payment_Taken_on_Phone_to_Office__c=false;
        }
        obj_PaymentRcvd.RecordTypeId=str_RecordTypeId;
        obj_PaymentRcvd.Payment_Collection_Notice__c=obj_PaymentRec.str_PaymentSFDCId;
        insert obj_PaymentRcvd; 
    }    
}