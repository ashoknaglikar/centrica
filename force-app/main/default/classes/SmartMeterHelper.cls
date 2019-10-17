/*
	Created By : Cognizant (26/03/12)
	Purpose: This class is helper class for smat metering and used to achieve some extra functionality for the same. 
*/

public with sharing class SmartMeterHelper {
	/*
		This method takes list of jobs and returns CSV string. 
	*/
	/*
	public static string extratctXLS(list<Job__c> selJobList)
	{
		String  excelHeader = 'Job Id, Job Number, Smart Meter Ref. Number, CHI Lead Number, Installation Post Code, Region, CHI Job Status, Customer Phone Number, Smart Meter Install Date, Smart Install Status, Reason for Acknowledgement, Sub-Status\n';
		string finalstring = excelHeader;
		for(Job__c j : selJobList)
		{
			string temp = j.id +','+j.Name+','+j.Smart_meter_reference_number__c+','+j.CHI_Lead_Number_Text__c + ','+j.Install_Postcode__c+ ','+ j.Region__c+ ','+j.Status__c +','+j.Home_Phone__c+','+j.Smart_meter_installation_date__c+','+ j.Smart_meter_installation_status__c+','+j.Reason_for_acknowledgement__c+','+j.Smart_meter_installation_sub_status__c+'\n';
			//trim extra spaces at the begining or end of the string
			finalstring += temp;
		}
		return finalstring;
	} 
	
	*/
	// ++ Added for Smart Meter CR start
	
	/*
		This method takes parameter as Set<Id> quoteIds and insert Smart Meter record
	*/
	public static void createSmartMeterRecord(Set<Id> quoteIds)
	{
		List<Smart_Meter__c> smartmeterList = new List<Smart_Meter__c>(); 
		for(BigMachines_Quote__c quote : [Select b.Opportunity__r.SMStatus__c, b.Opportunity__r.Id, b.Opportunity__c, b.Id,
										  b.Opportunity__r.SM_Number__c,
										 (Select id , Version__c , SM_Installation_Number__c From Smart_Meters__r),
		                                 (Select Id From Jobs__r) From BigMachines_Quote__c b
		                                 where b.id in: quoteIds])
		{
			if(quote.Jobs__r.size() > 0)
			{
				if(quote.Smart_Meters__r.size() == 0)
				{
					Smart_Meter__c smartMeter = new Smart_Meter__c();
					smartMeter.CHI_Lead__c = quote.Opportunity__r.Id;
					smartMeter.Quote__c = quote.id;
					smartMeter.Job__c = quote.Jobs__r[0].id; 
					smartMeter.S_M_Status__c = quote.Opportunity__r.SMStatus__c;
					smartMeter.Eligible__c = populateEligibleValues(String.valueOf(quote.Opportunity__r.SMStatus__c));
					smartMeter.SM_Installation_Number__c = quote.Opportunity__r.SM_Number__c;
					smartMeter.Version__c = 1;
					smartMeter.Name = 'Smart Meter';
					smartmeterList.add(smartMeter);
				}
				else
				{
					Smart_Meter__c smartMeter = new Smart_Meter__c(Id= quote.Smart_Meters__r[0].id);
					smartMeter.Version__c = quote.Smart_Meters__r[0].Version__c + 1;
					smartmeterList.add(smartMeter);
				}
				
			}
		}
		if(smartmeterList.size() > 0)
		{
			try
			{
				upsert smartmeterList;
			}
			catch(Exception ex)
			{
				system.debug('-----Exception occured-------'+ex);
			}
		}
	}
	
	/*
		This method populate 'Eligible' values based on 'S M Status' values
	*/
	public static string populateEligibleValues(String SMStatus)
	{
		if(SMStatus == 'Not Eligible' || SMStatus == 'Eligible Not Dual Fuel' || SMStatus == 'Eligible EnergySmart' || SMStatus == 'Eligible SmartEnergy')
		{
			return 'No';
		}
		else if(SMStatus == 'Eligible')
		{
			return 'Yes';
		}
		else if(SMStatus == 'Unknown BGMO' || SMStatus == 'Unknown or Not BG')
		{
			return 'Unknown';
		}
		else
		{
			return null;
		}
	}
	// -- Added for Smart Meter CR end

}