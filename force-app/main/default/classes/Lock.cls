/* Lock class

    A class containing static variables, usually these are used as
    "Locks" that can be used to communicate, for example, between
    a before trigger and an after trigger, or an insert trigger and 
    an update trigger. Other static variables are also kept here for
    similar reasons. 
    
*/

public class Lock {
    public static boolean workday = false;
    public static map<string, TOA2__Workforce2_ActivityMessage__c> idStatus = new map<string, TOA2__Workforce2_ActivityMessage__c>();
    public static map<string, TOA2__Workforce2_ActivityMessage__c> cancelStatus = new map<string, TOA2__Workforce2_ActivityMessage__c>();
      
    public static boolean lock = false;
    public static boolean apptReassignedLock = false;
    public static boolean evntReassignedLock = false;
    public static boolean apptCancelled = false;
    public static boolean isReallyInsert = false;
    public static Map<String, List<Appointment_History__c>> appHistories = 
            new Map<String, List<Appointment_History__c>>();
    public static boolean updatingOverbooked = false;
    public static boolean immediateReturn = false;
    public static boolean insertedCapacity = false;
    public static boolean triggerUpdatingOpps = false;
    public static boolean userIsNotDataLoader = true;
    // CR MC011, MC012, MC014
    public static boolean callCentreBooking = false;
    public static boolean populatedPAH = false;
    public static Map<ID, Boolean> reassigned = new Map<ID, Boolean>();
    // End CR MC011, MC014
    public static boolean httpCancellationCallOutToBigMachinesMade = false;
    public static boolean appointmentReassignmentIsLocked = false;
    public static boolean insertJBH = true;
    public static boolean abitrg = false;
    public static boolean emailSendSingle = false;
    public static boolean smInstDateLock = false;
    //code fix done by BGSAMS Support  as part of PRB00009436 - starts
    public static boolean jobTriggerSwitch = false;
    public static boolean aUPDCheckReplanning = false;
    public static boolean createJCD = false; 
    public static boolean cancelJob = false;
    public static boolean suspendJob = false;
    public static boolean unsuspendJob = false;
    public static boolean setNetCustomerPriceOnQuote = false;
    //code fix done by BGSAMS Support  as part of PRB00009436 - ends
    public static boolean DiaryEntryBeforeInsertUpdate = false;
    
    public static boolean calBalancingSkill = false;
    
    public static boolean employeeTrigger = false;
    public static boolean callHistory = false;
  
   //code added to fix invoking trigger twice issue in job skill history
    public static boolean blnAlreadyDone = false; 

    public static boolean cchContactOppRecursiveStopper = false;
    public static boolean cchApiRecursiveStopper= false;
    public static boolean cchRecursiveStopper = false;
    
    public static boolean jobAfterInsertSetDistrict = false;
    
    public static void setJobAfterInsertSetDistrict()
    {
        jobAfterInsertSetDistrict = true;
    }
    
    public static boolean hasAlreadyDone(){ 
        return blnAlreadyDone; 
    }
    public static void setAlreadyDone() {
        blnAlreadyDone = true;
    } 
    
    public static boolean isTestRunner = false;
  // BM Trigger switches Start
/*public static boolean BMQuoteInsJobRecon = false;
    public static void setBMQuoteInsJobRecon()
    {
        BMQuoteInsJobRecon = true;
    }
    
    public static boolean ensurePrimary = false;
    
    public static void setensurePrimary()
    {
        ensurePrimary = true;
    }
    
    public static boolean AutocanApptQuote = false;
    
    public static void setAutocanApptQuote()
    {
        AutocanApptQuote = true;
    }
    // BM Trigger switches end 
*/   
    
    public static void setsmInstDateLock()
    {
        smInstDateLock = true;
    }
    public static void setemailSendSingle()
    {
        emailSendSingle = true;
    }
    
    public static void setabitrg()
    {
        abitrg = true;
    }
    
    /* clearAll()
        Resets all the variables in this class to their original value. This
        is mainly used for testmethods, as static variables maintain their
        values in a testmethod where they wouldn't in real usage of the
        system.
    */
    public static void clearAll() {
        lock = false;
        apptReassignedLock = false;
        evntReassignedLock = false;
        apptCancelled = false;
        isReallyInsert = false;
        updatingOverbooked = false;
        immediateReturn = false;
        insertedCapacity = false;
        triggerUpdatingOpps = false;
        userIsNotDataLoader = true;
        callCentreBooking = false;
        // CR MC011, MC012, MC014
        populatedPAH = false;
        appHistories.clear();
        reassigned.clear();
        // End CR MC011, MC012, MC014
        appointmentReassignmentIsLocked = false;
    }
    
    public static boolean isCCHuser()
    {
        return (userinfo.getuserid().contains(system.label.cchUser));
    }
}