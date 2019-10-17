public class errorListClass{
    
    public list<ErrorClass> Errors;
    
    public static errorListClass parse(String json)
    {
    return (errorListClass) System.JSON.deserialize(json, errorListClass.class);
    }
    
    public class ErrorClass{
        public string ErrorCode;
        public string ErrorMessage;
        public string ExceptionDetails;
        
        public ErrorClass(string errorCode, String errorMessage) 
        {
            this.ErrorCode = errorCode;
            this.ErrorMessage = errorMessage;
        }
    }
    
    
    
}