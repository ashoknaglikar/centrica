public class tokenClass 
{
    public boolean succeeded;
    public string result;
    public list<errorClass> errors;
    public static tokenClass parse(String json){
	return (tokenClass) System.JSON.deserialize(json, tokenClass.class);
    }
    
    public class errorClass{
        public string code;
        public string message;
        public string codeAndDescription;
    }
}