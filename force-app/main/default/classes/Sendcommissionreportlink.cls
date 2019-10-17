/*
* CLASS - SendReportLink 
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to be called using the Out of the box force.com Schedular
*           and which in turn will call the batch apex's sendQuoteLink method to send report details
*/
global class Sendcommissionreportlink implements Schedulable {
	/*
    *   Input - SchedulableContext : Defaulted to the current context
    *   Output - None
    *   Purpose - Makes a call to sendAppListLink method in the related Batch Apex 
    */
    global void execute(SchedulableContext sc) {
        SendCommissionreport.sendQuoteLink();
    }
}