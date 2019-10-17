trigger weekTrigger on Week__c (after update) {
  

map<string, list<Diary_entry__c>> weekIdDiaryEntryMap = new map<string, list<Diary_entry__c>>();
if(trigger.isUpdate && trigger.IsAfter)
{
    for(Week__c w: trigger.new)
    {
        Week__c oldWeekRecord = trigger.oldmap.get(w.Id);
        if(w.Generate_WorkDays__c == true && oldWeekRecord.Generate_WorkDays__c!=w.Generate_WorkDays__c)
        {
            weekIdDiaryEntryMap.put(w.id, new List<Diary_Entry__c>());
            
        }
    }
}

if(weekIdDiaryEntryMap.size()>0 && !lock.workday)
{
        
    diaryEntryTriggerHelper.processDiaryEntry(weekIdDiaryEntryMap);
        
        
}
    

}