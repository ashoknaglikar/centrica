Public class WeekLockChange{
   
    private ApexPages.StandardController controller{get;set;}
    public Week__c week{get;set;}
    public string Msg{get;set;}
    public class WeekException extends Exception {}

    public WeekLockChange(ApexPages.StandardController controller)
    {
       this.controller= controller;
       this.week = (Week__c)controller.getRecord();
       //lockandUnlock();
       Msg = Apexpages.currentpage().getparameters().get('Lock');
       if(Msg.equalsIgnoreCase('false'))
       Msg = 'UnLock';
       else
       Msg = 'Lock';
      
    }
    
    public void lockandUnlock(){
     
      list<week__c> updateWeek = new list<week__c>();
    
       List<Week__c> weekQ = [select id,locking_user__c from week__c where id=:week.id];
       for(Week__c wee: WeekQ){
           if(wee.Locking_User__c != null)
           wee.Locking_User__c = null;
           else
           wee.Locking_User__c = userInfo.getUserId(); 
        
        updateWeek.add(wee);          
      
       }
       try{
       update updateWeek;
       }catch(DmlException e){
        throw new WeekException('Week could not be Updated.', e);

       }
      
    }
        
  
}