public with sharing class bg_Diary_Spawn_Extension {
    Job__c job  {get;set;}
    public bg_Diary_Spawn_Extension(ApexPages.StandardController controller) {
        job = [select Installation_Date__c, District__c from job__c where id = :controller.getId()];
    }
    
    public string getWeekBegining() {
        DateTime dt;
        if(job.Installation_Date__c != null) {
            dt = job.Installation_Date__c;
        } else {
            dt = DateTime.Now();
        }
        DateTime beginningOfTheWeek;
		System.debug('Cameron job.Installation_Date__c [' +job.Installation_Date__c+ ']');
		System.debug('Cameron dt [' +dt+ ']');
        for(integer i = 0 ; i > -8; i--) {
			DateTime dtTemp = datetime.newInstance(dt.year(), dt.month(), dt.day());
			System.debug('Cameron format comparison [' +string.valueOf(dtTemp.addDays(i).format('EEEE') == 'Monday')+ ']');
			System.debug('Cameron format [' +dtTemp.addDays(i).format('EEEE')+ ']');
			System.debug('Cameron beginningOfTheWeek [' +beginningOfTheWeek+ ']');
            if(dtTemp.addDays(i).format('EEEE') == 'Monday' && beginningOfTheWeek == null) {
                beginningOfTheWeek = date.newInstance(dtTemp.addDays(i).year(), dtTemp.addDays(i).month(), dtTemp.addDays(i).day());
            }
        }
		if(beginningOfTheWeek == null) {beginningOfTheWeek = DateTime.Now();}

		String month = beginningOfTheWeek.month() < 10? '0' + string.valueOf(beginningOfTheWeek.month()): string.valueOf(beginningOfTheWeek.month());
		String day = beginningOfTheWeek.day() < 10? '0' + string.valueOf(beginningOfTheWeek.day()): string.valueOf(beginningOfTheWeek.day());
        string returndate = day + '/' + month + '/' + beginningOfTheWeek.year();
        return returndate;
    }
    
    public string getDistrict() {
        return job.District__c;
    }

}