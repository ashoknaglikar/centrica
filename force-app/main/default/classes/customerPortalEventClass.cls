global class customerPortalEventClass {
    
    public date   eventDate;
    public date   eventEndDate;
    public string eventStartTime;
    public string eventEndTime;
    public string eventName;
    public string eventId;
    public string eventDescription;
    public string employeeName;
    public string employeeContactNumber;
    // added employee picture id
    public string employeePictureId;
    public boolean show;
    public string recordId ;
    public list<cutomerPortalEventChildClass> childEvents;
    
    public class cutomerPortalEventChildClass
    {
        public boolean show;
        public date childEventDate;
        public date childEventEndDate;
        public string childEventStartTime;
        public string childEventEndTime;
        public string childEventName;
        public string childEventId;
        public string childEventDescription;
        public string childEmployeeName;
        public string childEmployeeContactNumber;
    }

}