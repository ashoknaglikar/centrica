trigger IdeasTrigger on Idea (before insert,before update) {
    
    list<vote> votes = new list<vote>();
    map<Id, idea> ideaMap = new Map<Id,Idea>();
    set<id> Pids = new set<id>();
    set<id> Sids = new set<id>();
    map<id,string> statusMap = new Map<id,string>();
    string substatus;
    string status;
    string parentIdea;
    for(Idea i : trigger.new)
    {
        if(trigger.isinsert)
        {
            i.Business_Area__c = 'Office';
            i.CommunityId  = '09a200000000ECB';
            ideaMap.put(userinfo.getuserId(), i);
            i.District__c  = 'Office';
            //change by Ashok G  
            if(i.On_Behalf_Of__c==null)
            {
                i.On_Behalf_Of__c=userinfo.getuserid();
                
            } //END
        }else if(trigger.isupdate && trigger.isbefore)
        {
            if(i.Vote__c)
            {
                votes.add(new vote(ParentId= i.id, Type = 'Up'));
                
                i.No_Of_Votes__c = Integer.valueof((i.VoteTotal/10)+1);
               
                
            }
         }   
            /* Change Done BY ASHOK G
            if(trigger.oldmap.get(i.Id).Parent_Idea__c ==null &&  i.Parent_Idea__c!=null)
            {
                 i.Status ='Closed';
                 i.Sub_Status__c  = 'Duplicate';
                
            }*/
        
    }
    
  
    
    if(votes.size()>0)
    {try{
        insert votes;
    }catch(Exception e){}
    }
    if(ideaMap.keyset().size()>0)
    {
    for(Employee__c emp : [Select Id, Business_Group__c,Salesforce_User__c, District__r.Name, Region__c  from Employee__c where Salesforce_User__c in:ideaMap.keyset()])
    {
        Idea i = ideaMap.get(emp.Salesforce_User__c);
        i.Business_Area__c = emp.Business_Group__c;
        if(emp.District__r.Name !=null)
        {
        i.District__c  = emp.District__r.Name;
        i.Region__c = emp.Region__c;
        
        }
    }
    }
}