public class PTSFormController 
{
	public String DeliveryDate {get; set;}
	public String DeliveryDateNew {get; set;}
	public Job__c Job {get; set;}
	public Boolean IsPTSEnabled {get; set;}
	public Boolean IsError {get; set;}
	
	public PTSFormController()
	{
		IsError = false;
		String jobId = System.currentPageReference().getParameters().get('id');
		String deliveryDate = System.currentPageReference().getParameters().get('dt');
		Date jobDelDate;
		if(deliveryDate != null && deliveryDate.length() > 0)
		{
			try
			{
				List<String> strDate = deliveryDate.split('/');
				jobDelDate = Date.newInstance(Integer.valueOf(strDate[2]), Integer.valueOf(strDate[1]), Integer.valueOf(strDate[0]));
			}
			catch(Exception ex)
			{
				addMessage('Invalid Job Delivery date.');
				return;
			}
		}
		/*User user = [select id, PTSEnabled__c from User where id =:UserInfo.getUserId()];
		IsPTSEnabled = user.PTSEnabled__c;
		
		if(IsPTSEnabled == false)
		{
			//user is not activated for PTS functioanlity
			addMessage('PTS is not enabled.');
			return;
		}
		else */
		if(jobId == null || jobId == '')
		{
			// invalid job id provided
			addMessage('Invalid Job details provided. Please retry or contact your administrator.');
			return;
		}
		else
		{
			List<Job__c> lstJob = [select id, Name, Delivery_Date__c, Delivery_Notes__c, 	Installation_Address__c,  
				Installation_County__c, Install_City__c, Install_Postcode__c, DeliveryID__c,
				CHI_Lead_Number_Text__c,
				Install_Street__c from Job__c where id =:jobId];
			
			if(lstJob != null && lstJob.size() > 0)
			{
				Job = lstJob[0];
				 
				System.debug('------- jobDelDate = ' + jobDelDate);
				if(jobDelDate == null) jobDelDate = Job.Delivery_Date__c;
				System.debug('------- jobDelDate = ' + jobDelDate); 
				if(jobDelDate != null)
				{
					
					Datetime tmpDT = Datetime.newInstance(jobDelDate.year(), jobDelDate.month(), jobDelDate.day());
					DeliveryDate = tmpDT.format('yyyy-MM-dd');
					DeliveryDateNew = tmpDT.format('yyyy-MM-dd');
					System.debug('------- DeliveryDate = ' + DeliveryDate);
				}
				else
				{
					//delivery date is invalid
					addMessage('Invalid Job Delivery Date. Please provide a valid Delivery date to continue.');
					return;
				}
			}
			else
			{
				//no job retrieved
				addMessage('Error occurred while retrieved Job details. Please retry or contact your administrator.');
				return;
			}
		}
		System.debug('------- DeliveryDate = ' + DeliveryDate);
	}
	
	private void addMessage(String msg)
	{
		apexpages.Message newMSg = new apexpages.Message(ApexPages.Severity.ERROR, msg);
		IsError = true;
		ApexPages.addMessage(newMSg);
	}
	
	
	
}