/*
* Lists all the messages to be displayed
*/


public class MessageConstants 
{
    public final String ERR_NOOPPORTUNITYSELECTED = 'Select an opportunity to continue.'; 
    public final String ERR_MULTIPLEOPPORTUNITYSELECTED = 'Only one opportunity can be selected.';
    // PRB00013945 - Expired lead PR
    //public final String ERR_INVALIDLEADNUMBER = 'Please enter a valid Lead number.';
    public final String ERR_INVALIDLEADNUMBER = 'The Lead number is either Invalid or Expired.';
    public final String ERR_INVALIDPOSTCODE = 'Please enter a valid postcode.';
    public final String ERR_NOLEADNUMBERADDRESS = 'Please enter Lead number or enter the address of the customer.';
    public final String ERR_NOADDRESS = 'Please enter the address.';
    public final String ERR_INSERTION = 'Error while insertng data--> ';
    public final String ERR_PRIMARYCONTACT = 'Select only one primary contact.';
    public final String ERR_NOREFERRALEMPLOYEE = 'Referral Employee should not be blank.';
    public final String ERR_NOAPPOINTMENTSELECTED = 'Select an appointment to rearrange.';
    public final String ERR_MULTIPLEAPPOINTMENTSELECTED = 'Only one appointment can be rearranged at a time.';
    public final String ERR_NOAPPOINTMENTSAVAILABLE = 'No Appointments selected for rearrange.';
    public final String ERR_PROCESSINGRECORDS = 'Error while processing records.';
    public final String ERR_CONFIRMADDRESS = 'Please confirm the Account address.';
    public final String ERR_TASKCREATED = 'Task has been created successfully.';
    public final String ERR_ONEPRIMARYCONTACT = 'One contact should be primary';
    public final String ERR_NOCONTACT = 'At least one contact should be available.';
    public final String ERR_ENTERTASKINFO = 'Assigned To and Wrap Up call fields are mandatory.';
    public final String ERR_ENTERCAMPAIGN = 'Campaign field is mandatory.';
    public final String ERR_ENTERPRODUCTINTEREST = 'Product Interest field is mandatory.';
    public final String ERR_ENTERREFERRALEMPLOYEE = 'Referral Employee field is mandatory.';
    public final String ERR_PAYMENTDATE = 'Please enter the payment date.'; 
    public final String ERR_PAYMENTVALUE = 'Payment Value field is mandatory.';
    public final String ERR_PAYMENTTYPE = 'Please select valid payment type.';
    public final String ERR_PAYMENTMETHOD= 'Please select valid payment method.';
    public final String ERR_PAYMENTBGREFNUMBER = 'Please enter a BG Ref Number';
    public final String ERR_PAYMENTVALIDBGREFNUMBER = 'Please enter a valid BG Ref Number.';
    public final String ERR_PAYMENTPAYEEREFNUMBER = 'Please enter a Payee Ref Number.';
    public final String ERR_PAYMENTVALIDPAYEEREFNUMBER = 'Please enter a valid Payee Ref Number.';
    public final String ERR_HSANOLEADFORADDRESS = 'No Lead exists for this address, Please enter a valid address.';
    public final String ERR_CANCELAPPOINTMENT = 'Please select an appointment for cancellation.';
    public final String ERR_NOACTIVEOPP = 'All the leads are Closed Lost.Please enter the active lead number.';
    public final String ERR_NOWASTECALLCATEGORY = 'Please enter a Waste Call Catagory.';
    public final String ERR_WASTECALLCATEGORY = 'Please enter a sub catagory as Category selected is \'Referred to other Gas Office\'';
    public final String ERR_CONTACTTYPEREQUIRED = 'Please enter a Type for new contact';
    public final String ERR_NOSTREET = 'Please enter street for the postcode.';
    public final String ERR_CONTACTSALUTATIONREQUIRED = 'Please enter a Title for new contact.';
    public final String ERR_CONTACTFIRSTNAMEREQUIRED = 'Please enter a Firstname for new contact.';
    public final String ERR_CONTACTLASTNAMEREQUIRED = 'Please enter a Surname for new contact.';    
    public final String ERR_ENGINEERREASON = 'Please enter Unsafe Appliance Reason as Engineer Reason is \'Unsafe appliance\'.';
   // This validation message is added for new field added to Opportunity object.
   // This field is named as 'Customer agreed to appointment.
   // This field needs to be mandatory for engineer call.
    public final String ERR_ENGINEERCUSTAGDAPP = 'Please specify whether customer has agreed for an appointment or not.';
    public final String ERR_APPOINTMENTSTATUSREASON = 'Please provide Status reason for Appointment.';
    // ASHOK : CR-001 CHI CP  
    public final String ERR_UNBOOKEDAPPOINTMENT = 'Please provide Unappointed Lead Reason for not Booking Appointment.';
    public final String ERR_CANCAPPOINTMENT = 'Please provide Primary and Secondary Cancellation Reason for Cancelling Appointment.';
   // Ashok End   
    public final String ERR_SURNAME = 'Please enter a Surname.';
    public final String ERR_PHNUMBER = 'Please enter a Phone Number.';
    public final String ERR_PRDTINTREST = 'Please enter a Product Intrest.';
    public final String ERR_PREFFERDDATE = 'Please enter a Prefferd date.';
    public final String ERR_PREFFEREDTIME = 'Please enter a Prefferd Time.';
    public final String ERR_CALLBACKTIME = 'Please enter Call Back Details';
    public final String ERR_CALLNOTES = 'Please Enter Call Notes';
    public final String ERR_CALLBACKTIMES = 'Please select Action for selected Reason Code';
    public final String ERR_REASONCODE = 'Please select Reason code for selected Action';
    public final String ERR_REASONCALLBACKCODE = 'Please select Reason code and Action or OverRide Call Back Date for Lead Prospect';
    public final String ERR_NOTAPROSPECTCODE = 'CHI Lead is not a Prospect so you cannot pick call back date, override date and reason code.';
    public final String ERR_REASON = 'Please select Reason code.'; 
    public final String ERR_NOWASTECALLTYPE = 'Please enter a Waste Call Type.';
    public final String ERR_OVERRIDECALLDATE = 'Please enter a Over Ride Call Back Date.';
    public final String ERR_DELOVERRIDECALLDATE = 'Please Remove Over Ride Call Back Date.';
    public final String ERR_ENTERCUSTINTRESTINECO = 'Please enter Customer Interested In Ecogen.';
    public final String ERR_ENTERPROPOSCHECK = 'Please Check Ecogen Propositioned Checkbox.';
    public final String ERR_ENTERFUSIONCAMP = 'Please select a Fusion Campaign.';
    public final String ERR_ENTEREMAIL = 'Please enter a Eamil Address.';
    public final String ERR_ENTERMOBILE = 'Please enter a Mobile Number.';
    public final String ERR_ENTERBEDROOMS = 'Please enter Number of Bedrooms.';
    
    // ++ Added for Priority Installations CR start
    public final String ERR_DERIVE_CUSTOMER_CATEGORY = 'Please make sure that you derive a defined customer category.';
    public final String ERR_ENTER_VULNERABLE_REASON = 'Please input the proper vulnerable reason.';
    public final String ERR_ENTER_OUT_OF_STANDARD_REASON = 'Please enter service level reason value.';
    public final String ERR_ENTER_APPOINTMENT_REASON = 'You must enter service level value.';
    // -- Added for Priority Installations CR end
    
    // ++ Added for CR#869
    public final String ERR_PREFERRED_OPTIONS = 'Please provide Customer Preferred Day and Time to procced further.';
    // -- Added for CR#869
    
    // ++ Added for PTS CR start
    public final String ERR_PTS_SLOT_NOT_CANCELLED_IN_PTS = 'You have not cancelled slots in PTS system.';
    // ++ Added for PTS CR end
    
    // ++ Added for Gas Council Change start
    public final String ERR_GAS_COUNCIL = 'Please input only numeric characters in Gas Council Number.';
    // -- Added for Gas Council Change end
    public final String ERR_STATELENGTH = 'Please reduce the number of characters to 20 in State Field.';
    public final string ERR_WITH_CUST = 'Please enter reason for why engineer is not with customer.';
    public final string ERR_WITH_unappointedleadsubreason = 'Please enter the Unappointed Sub reason to proceed';
    public final string ERR_workingwith = 'Please enter Customer name,Source Of Call,Reason for Call ';
    public final string Err_No_Contact_Leads = 'Please capture atleast phone, email or Mobile contact for landlord.';
    public final string ERR_InactiveEmp_inList = 'List contains inactive employees and no update has been done ';
    public final string ERR_MarketingConsent = 'Marketing consent and prefernece is mandatory.';
    
}