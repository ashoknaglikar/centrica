trigger greendeal on Green_Deal_Reconsilliation__c(before insert,before update) 
{
    for(Green_Deal_Reconsilliation__c gd: Trigger.New)
    { 
    	date redEndDate;
    	
        if(gd.Insulation_Installation_Date__c!=null && gd.LU_Installation_Date__c!=null )
        {
        	if(gd.Insulation_Installation_Date__c>gd.LU_Installation_Date__c)
        	{
        		redEndDate = gd.Insulation_Installation_Date__c;
        	}else
        	{
        		redEndDate = gd.LU_Installation_Date__c;
        	}
        	
        }else if(gd.Insulation_Installation_Date__c!=null )
        {
        	redEndDate = gd.Insulation_Installation_Date__c;
        }else if(gd.LU_Installation_Date__c!=null)
        {
        	redEndDate = gd.LU_Installation_Date__c;
        }
        DateTimeHelper dt = new DateTimeHelper();
        time ti = time.newinstance(00,00,00,00);
        if(redEndDate!=null)
        gd.RedeEndDate__c = (dt.addBussinessDays(datetime.newinstance(redEndDate, ti),20)).date();
    } 
   
}