public class SelectedAppointment{

    public boolean appoinSelected;
    public Appointment__c appointment;
    
    public boolean displayRedTextForCanReasons{get;set;}
    //++ GD Change
    public boolean GreenDeal {get;set;}
    public boolean showIsSelct{get;set;}
    //-- GD Change
    
    public void setappoinSelected(boolean appoinSelected){
        this.appoinSelected=appoinSelected;
    }
    public boolean getappoinSelected(){
        return this.appoinSelected;
    }
    
    public void setappointment(Appointment__c appointment){
        this.appointment=appointment;
    }
    public Appointment__c getappointment(){
        return this.appointment;
    }        
    
}