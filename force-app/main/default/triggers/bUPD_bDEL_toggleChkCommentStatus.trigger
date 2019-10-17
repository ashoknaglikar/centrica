trigger bUPD_bDEL_toggleChkCommentStatus on CaseComment (before update,before delete) {
    
    CaseComment[] oldCaseObj = Trigger.old;
    Integer count =0;
    Map<String,String> userMap = new Map<String,String>();
    User[] inclUpdate = [select id,name from User where name in  ('Dave Rigby','Ann Ord','Andrew Kennedy','Jane Hill','Michael Furneaux','Paul Hancock')];
    
    for(User usr : inclUpdate)
        userMap.put(usr.id,usr.Name);
    System.debug('@    usrmap   @ '+userMap);
    if(Trigger.isUpdate){
        for(CaseComment cases: Trigger.new){        
            CaseComment oldObj = oldcaseObj[count];
            if(!(cases.IsPublished) && (oldObj.isPublished)){
                if(!(userMap.containsKey(UserInfo.getUserId()))){
                    cases.addError('Not Authorized to make the comment private');
                }   
            } 
        }
     }  
     else{
        for(Casecomment cm : Trigger.old){
            if(!(userMap.containsKey(UserInfo.getUserId()))){
                cm.addError('Not Authorized to delete comment');
            } 
        }
    }
  
}