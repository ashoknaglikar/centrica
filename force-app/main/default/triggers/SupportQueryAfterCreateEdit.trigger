trigger SupportQueryAfterCreateEdit on Support_Query__c (after insert, after update) {
 /*   
    List<id> listID = new list<Id>();
    Map<Id, SET<Id>> supportSubscriberMap = new Map<Id, SET<Id>>();
    List<entitySubscription> eslIST = new List<entitySubscription>();
    
    for (support_query__c sq : trigger.new)       
    {   
        
       if(trigger.isinsert || (trigger.isupdate && trigger.oldmap.get(sq.Id).OwnerId != sq.ownerId)) 
        ListID.add(sq.Id);
        //es.parentID = sq.id;
        //es.SubscriberId = sq.OwnerId;
        
    }
    if(ListID.size()>0)
    {
    for(entitySubscription follower : [select SubscriberID, ParentId FROM entitySubscription WHERE parentID in: listID])    
    {
        set<Id> tempSet = new set<Id>();
        if(supportSubscriberMap.containsKey(follower.ParentId))
        {
            tempSet = supportSubscriberMap.get(follower.ParentId);
        }
        tempset.add(follower.SubscriberID);
        supportSubscriberMap.put(follower.ParentId, tempSet);
    }
    
    for (support_query__c sq : trigger.new)       
    {
        if(supportSubscriberMap.containskey(sq.Id) && !supportSubscriberMap.get(sq.Id).contains(sq.OwnerId)|| !supportSubscriberMap.containskey(sq.Id))
        {
            eslIST.add(new entitySubscription(parentID = sq.id,SubscriberId = sq.OwnerId) );
        }
        
    }
    }
    if(eslIST.size()>0)
    insert eslIST;
    */
}