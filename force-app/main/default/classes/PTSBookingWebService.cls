/*
Description:- Class exposes a webservice for PTS appointment booking integration
Service Methods:-
1. upsertAppointment - inserts/ updates appointment
2. cancelAppointment - cancels an appointment
*/
global class PTSBookingWebService 
{
    global class PTSAppointmentInfo 
    {
        webservice String   JobNumber       = null;
        webservice String   DeliveryId      = null;
        webservice datetime DeliveryDate    = null;
        webservice String   TimeSlot        = null;
        webservice String   DeliveryNotes   = null;
        webservice String BookingStatus     = null;
        webservice String BookingMethod     = null;
    }
    
    global class ActionResult 
    {
        webservice Boolean  Success         = false;
        webservice List<String> Errors      = null;
    }
    
    //ERROR MESSAGE CONSTANTS
    public static string ERR_OBJECTNULL = 'PTSAppointmentInfo object cannot be null.';
    public static string ERR_JOBNUMBERNULL = 'Job Number cannot be null.';
    public static string ERR_JOBNUMBERINVALID = 'Invalid Job Number.';
    public static string ERR_DELIVERYDATENULL = 'Delivery date cannot be null.';
    public static string ERR_BLANKTIMESLOT = 'Timeslot is null or blank';
    public static string ERR_INVALIDTIMESLOT = 'Timeslot is invalid';
    public static string ERR_INVALIDBOOKINGSTATUS = 'Booking Status is null or blank';
    public static string ERR_INVALIDBOOKINGMETHOD = 'Booking Method is null or blank';
    
    public static string JOBSTATUS_CANCELLED = 'Cancelled';

    // Inserts/ Updates an appointment
    // Description:- Updates job's PTS appointment (delivery) fields
    WebService static ActionResult upsertAppointment(PTSAppointmentInfo appInfo)    
    {
        //validate data
        ActionResult validationResult = validateData(appInfo);
        if(!validationResult.Success) return validationResult;
        
        //check for appointment cancellation
        if(appInfo.JobNumber != null && appInfo.JobNumber != '' && 
            appInfo.BookingStatus.equalsIgnoreCase(JOBSTATUS_CANCELLED))
        {
            return cancelAppointment(appInfo);
        }
        
        //retrieve job
        List<Job__c> jobs = [select id, Name, CHI_Lead__c, CHI_Lead__r.AccountID, DeliveryID__c, 
            PTSDeliverySlot__c, Delivery_Notes__c, PTSSlotBookingStatus__c, Delivery_Date__c,
            Quote__r.Delivery_Slot__c, Quote__r.deliveryDate__c,
            CHI_Lead__r.Account.Primary_Contact__c
            from Job__c where Name =: appInfo.JobNumber];
        
        if(jobs != null && jobs.size() > 0)
        {
            System.SavePoint sp = Database.setSavepoint();
            try
            {
                Job__c jobObj = jobs[0];
                //------ update job
                jobObj.PTSDeliverySlot__c = appInfo.TimeSlot;
                jobObj.Delivery_Notes__c = appInfo.DeliveryNotes;
                
                if(jobObj.Delivery_Notes__c != null)
                jobObj.Delivery_Notes__c = jobObj.Delivery_Notes__c.normalizeSpace(); //PRB00029751
                
                jobObj.BookingMethod__c = appInfo.BookingMethod;
                jobObj.PTSSlotBookingStatus__c = appInfo.BookingStatus;
                jobObj.Delivery_Slot__c = appInfo.TimeSlot;
                jobObj.Delivery_Date__c = appInfo.DeliveryDate.date();
                jobObj.DeliveryID__c = appInfo.DeliveryId;
                update jobObj;
                
                BigMachines_Quote__c quote = jobObj.Quote__r;
                if(quote != null)
                {
                    quote.Delivery_Slot__c = appInfo.TimeSlot;
                    quote.deliveryDate__c = jobObj.Delivery_Date__c;
                    // ++ Added for restricting the creation/updation of customer category & history records starts
                    cls_IsRun.setisRestrictCustCategory();
                    // --Added for restricting the creation/updation of customer category & history records starts
                    update quote;
                }
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                validationResult.Success = false;
                validationResult.Errors.Add(ex.getMessage());
            }
        }
        else
        {
            validationResult.Success = false;
            validationResult.Errors.Add(ERR_JOBNUMBERINVALID);
        }
        return validationResult;
    }
    
    // Cancels appointments
    // Description: resets Job's PTS Appointment (Delivery) fields
    WebService static ActionResult cancelAppointment(PTSAppointmentInfo appInfo)    
    {
        ActionResult actionResult = new ActionResult();
        actionResult.Success = true;
        actionResult.Errors = new List<String>();
        
        //Validate Data
        if(appInfo == null)
        {
            actionResult.Success = false;
            actionResult.Errors.add(ERR_OBJECTNULL);
        }
        else
        {
            if(appInfo.JobNumber == null)
            {
                actionResult.Success = false;
                actionResult.Errors.add(ERR_JOBNUMBERNULL);
            }
        }
        
        if(actionResult.Success)
        {
            //Data is valid; proceed with retrieving job
            System.SavePoint sp = Database.setSavepoint();
            try
            {
                Job__c jobObj = [select id, CHI_Lead__c, CHI_Lead__r.AccountID, DeliveryID__c, 
                    PTSDeliverySlot__c, Delivery_Notes__c, PTSSlotBookingStatus__c, Delivery_Date__c,
                    Quote__r.Delivery_Slot__c, Quote__r.deliveryDate__c,
                    CHI_Lead__r.Account.Primary_Contact__c
                    from Job__c where Name =: appInfo.JobNumber];
                
                //reset job fields
                jobObj.PTSDeliverySlot__c = '';
                jobObj.Delivery_Slot__c = null;
                jobObj.BookingMethod__c = null;
                jobObj.PTSSlotBookingStatus__c = null;
                
                //-----------------------------------
                //Modified date:- Oct 17, 2011
                //Description:- Delivery date to be retained on cancellation
                //jobObj.Delivery_Date__c = null;
                //-----------------------------------
                
                jobObj.DeliveryID__c = null;
                jobObj.Delivery_Notes__c = '';
                update jobObj;
                
                BigMachines_Quote__c quote = jobObj.Quote__r;
                if(quote != null)
                {
                    quote.Delivery_Slot__c = null;
                    quote.deliveryDate__c = null;
                    update quote;
                }
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                actionResult.Success = false;
                actionResult.Errors.Add(ex.getMessage());
            }
        }
        return actionResult;
    }
    
    private static ActionResult validateData(PTSAppointmentInfo appInfo)
    {
        ActionResult actionResult = new ActionResult();
        actionResult.Success = true;
        actionResult.Errors = new List<String>();
        if(appInfo == null)
        {
            actionResult.Success = false;
            actionResult.Errors.add(ERR_OBJECTNULL);
        }
        else
        {
            if(appInfo.JobNumber == null)
            {
                actionResult.Success = false;
                actionResult.Errors.add(ERR_JOBNUMBERNULL);
            }
            if(appInfo.DeliveryDate == null)
            {
                actionResult.Success = false;
                actionResult.Errors.add(ERR_DELIVERYDATENULL);
            }
            if(appInfo.BookingStatus == null || appInfo.BookingStatus == '')
            {
                actionResult.Success = false;
                actionResult.Errors.add(ERR_INVALIDBOOKINGSTATUS);
            }
            if(appInfo.BookingMethod == null || appInfo.BookingMethod == '')
            {
                actionResult.Success = false;
                actionResult.Errors.add(ERR_INVALIDBOOKINGMETHOD);
            }
        }
        return actionResult;
    } 
    
}