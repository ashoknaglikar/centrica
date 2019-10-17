trigger ApprovalRequest on Compensation__c (after insert,after update) {

List<Compensation__c> compforApproval=new List<Compensation__c> ();
List<Compensation__c> compfinalApproval = new List<Compensation__c>();
List<Id> compOwner=new List<Id> (); 
List<String> ProfileNames = new List<string>();              
map<id,decimal> AMap = new map<id,decimal>();
map<string,decimal> AMap1 = new map<string,decimal>();   
map<Id,string> usrMap = new Map<id,String>();  
   
   for(Compensation__c comp: trigger.new){
     
      if(comp.Approver__c!=null){
         if(Trigger.isInsert){
          compforApproval.add(comp); 
          compOwner.add(comp.Approver__c);
          
         }
         else if(Trigger.isUpdate && comp.Approval_Status__c==null){
           compforApproval.add(comp); 
           compOwner.add(comp.Approver__c);
           
           //system.debug('----------Trigger is Update'+CompforApproval);
         }
         
      }
      
   }
   
   List<User> UsrProfile = [select id,name,Profile.Name from User where id in: compOwner];
   if(UsrProfile.size()>0){
      //ProfileNames = new List<String>(); 
      //usrMap = new map<Id,string>(); 
      for(user Usr : UsrProfile){
         ProfileNames.add(Usr.Profile.Name);
         usrMap.put(Usr.Id,Usr.Profile.Name);      
      }
   }
   
   //system.debug('-------->'+ProfileNames);
      
   List<Approval_Request__c> AQuery = [select id,name,Max_Authorization__c,User__c,Profile_Name__c from Approval_Request__c where User__c in: compOwner OR Profile_Name__c in: ProfileNames];
   
   if(AQuery.size()>0){
     for(Approval_Request__c AR: AQuery){
        if(AR.User__c == null) //TO KNOW PROFILE MAX VALUE
        AMap1.put(AR.Profile_Name__c ,AR.Max_Authorization__c);
        else
        AMap.put(AR.User__c,AR.Max_Authorization__c);
        
     }
     //system.debug('==========Amap'+AMAP);
     set<id> setIds = new set<id>();
     for(Compensation__c comp1: compforApproval){
       if(AMap.containskey(comp1.Approver__c)){
        if(comp1.Value_Compensated__c > AMap.get(comp1.Approver__c)){
            Comp1.addError('Maximum Limit Exceeded For Approver: Approval MAX LIMIT: £'+AMap.get(comp1.Approver__c));
            break;
          }else{
            CompfinalApproval.add(comp1);
            setIds.add(comp1.id);
          }
       }
       
      //system.debug('=========================>'+AMap1); 
       if(AMap1.containskey(usrMap.get(comp1.Approver__c)) && !setIds.contains(comp1.id)){
          if(comp1.Value_Compensated__c > AMap1.get(usrMap.get(comp1.Approver__c))){
            Comp1.addError('Maximum Limit Exceeded For Approver: Approval MAX LIMIT: £'+AMap1.get(usrMap.get(comp1.Approver__c)));
            break;
          }else{
            CompfinalApproval.add(comp1);
          }
       }
     
     }
   }
     
    for(compensation__c compARcmpr: compforApproval){
        if(!AMap.containskey(compARcmpr.Approver__c) && !AMap1.containskey(usrMap.get(compARcmpr.Approver__c))){
           compARcmpr.addError('The user or user profile is not listed with an approval value.');
           break;
        }
    
    }     
     
    
     if(CompfinalApproval!=null){
      for(Compensation__c FinalApproval: CompfinalApproval){
         
          // create the new approval request to submit
          Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
          req.setComments('Submitted for approval. Please approve.');
          req.setObjectId(FinalApproval.Id);
          req.setNextApproverIds(new Id[] {FinalApproval.Approver__c});
          // submit the approval request for processing
          Approval.ProcessResult result = Approval.process(req);
          // display if the reqeust was successful
          System.debug('Submitted for approval successfully: '+result.isSuccess());
       
      } 
     
     }
         
   

}