public class SubOrdinatesLocationsController 
{
    public Event SearchEvent{get; set;}
    public String dateTimeY
    {
        get
        {
            return SearchEvent.ActivityDate.Year() + '';
        }
    }
    public String dateTimeM
    {
        get
        {
            return SearchEvent.ActivityDate.Month() + '';
        }
    }
    public String dateTimeD
    {
        get
        {
            return SearchEvent.ActivityDate.Day() + '';
        }   
    }
    public SubOrdinatesLocationsController()
    {
        SearchEvent = new Event();
        SearchEvent.ActivityDate = System.today(); //.Adddays(1);
    }
    
    public void displayLocation()
    {
        //do nothing
    }
    
    // Test Methos for  TestMethodSubOrdinatesLocationsController
    
    static testMethod void SubOrdinatesLocationsController_Test(){   
    String s;       
    SubOrdinatesLocationsController  obj = new SubOrdinatesLocationsController(); 
    s = obj.dateTimeY; s = obj.dateTimeM; s = obj.dateTimeD; obj.displayLocation(); }     
   }