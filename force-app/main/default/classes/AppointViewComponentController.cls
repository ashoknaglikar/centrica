public class AppointViewComponentController {

    List<Appointment__c> appointList= new List<Appointment__c>();

    public List<Appointment__c> getAppointments(){
        return appointList;
    }
    public void setAppointments(List<Appointment__c> appList){
        this.appointList=appList;
    }       
}