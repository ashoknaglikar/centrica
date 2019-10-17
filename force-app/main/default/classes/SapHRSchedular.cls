/*
* CLASS - SapHRSchedular
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to be called using the Out of the box force.com Schedular
*           and which in turn will call the batch apex's to Activate or deactivate the Employee record
*/
global class SapHRSchedular implements Schedulable {
    /*
    *   Input - SchedulableContext : Defaulted to the current context
    *   Output - None
    *   Purpose - Makes a call to reconcile method in the related Batch Apex 
    */
    global void execute(SchedulableContext sc) {
        Integer iCountUnProcess=0;
        Integer iCountProcess=0;
        SAHRSF_Batch__c objSAPHRBatch=[Select Name, Record_Count__c,Id,Total_Record_Count__c,
                                                        Not_Processed_Child_Record_Count__c,Processed_Child_Record_Count__c 
                                                        From SAHRSF_Batch__c Order By Name DESC Limit 1];
        
        if (objSAPHRBatch!=null) {
            
            if (objSAPHRBatch.Total_Record_Count__c==0)
            {
                scheduleClassMethod();  
            } else {
                if (objSAPHRBatch.Not_Processed_Child_Record_Count__c!=0 && objSAPHRBatch.Total_Record_Count__c<objSAPHRBatch.Record_Count__c)
                {
                    scheduleClassMethod();
                } else if (objSAPHRBatch.Total_Record_Count__c==objSAPHRBatch.Record_Count__c)
                {
                    SAPHREmployee.ActDeact(objSAPHRBatch.Id);
                    scheduleNewDayClassMethod();
                }
            }
        }
        
    }
    private void scheduleClassMethod(){
        DateTime dtNow=System.now();
        dtNow=dtNow.addMinutes(15);
        String sDtNow=dtNow.format();
        String sDay=String.ValueOf(dtNow.day());
        String sMonth=String.ValueOf(dtNow.month());
        String sYear=String.ValueOf(dtNow.year());
        String sHour=String.ValueOf(dtNow.hour());
        String sMinute=String.ValueOf(dtNow.minute());
        String sSecond=String.ValueOf(dtNow.second());
        
        String sTriggerClass='0 ' + sMinute + ' ' + sHour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;
        
        System.schedule('SAPEmployeeProcess' + sDtNow,sTriggerClass , new SapHRSchedular());
    }
    private void scheduleNewDayClassMethod(){
        DateTime dtNow=System.today();
        dtNow=dtNow.addDays(1);
        String sDtNow=dtNow.format();
        String sDay=String.ValueOf(dtNow.day());
        String sMonth=String.ValueOf(dtNow.month());
        String sYear=String.ValueOf(dtNow.year());
                
        String sTriggerClass='0 ' + 0 + ' ' + 0 + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;
        
        System.schedule('SAPEmployeeProcess'+sDtNow,sTriggerClass , new SapHRSchedular());
    }
}