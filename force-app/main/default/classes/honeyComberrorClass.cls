public class honeyComberrorClass
{
    public string applicationId;
    
    public list<string> errors ;
    
    public static honeyComberrorClass parse(string json)
    {
        return (honeyComberrorClass) System.JSON.deserialize(json, honeyComberrorClass.class);
    }
    
    
}