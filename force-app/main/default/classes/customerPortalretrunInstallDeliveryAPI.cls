@RestResource(urlMapping='/returnDeliveryOptions/*')
global class customerPortalretrunInstallDeliveryAPI {
    
    @HttpPost    
    global static bookJobResponse returnDeliveryInstallDate(string leadId,
                                          string quoteId, 
                                          string jobId,
                                          date installDateSelected,
                                          String installTimeSelected,
                                          String optionIDSelected,
                                          boolean bringForwardJob,
                                          string deliveryNotes,
                                          string installNotes,
                                          boolean confirmFlag,
                                          string safePlaceFlag,
                                          string restrictionFlag
                                         )
  {
      
        //String oppId = CustomerPortalHelper.getOpportunityId(leadId); 
        
        bookJobResponse objResponse = new bookJobResponse();        
                
        objResponse.jobId=jobId;
        objResponse.leadId=leadId;
      
        objResponse.quoteId=quoteId;
        
        boolean sameDayDelivery = false;
        
        objResponse.installDate = installDateSelected;
        objResponse.installTime = installTimeSelected;
        objResponse.callBack = false;
        system.debug('safePlaceFlag -'+safePlaceFlag);
        system.debug('restrictionFlag - '+restrictionFlag);
        if(label.sameDayDelivery == 'yes' ||(safePlaceFlag == 'Yes' &&  restrictionFlag == 'Yes'))
        {
            sameDayDelivery = true;
            
        }else if(safePlaceFlag == 'Yes' &&  restrictionFlag == 'No')
        {
            
            //check  if Install is happening on monday, if yes than same day deliver
            if(installDateSelected!=null)
            {
                Time dummyTime = time.newInstance(0, 0, 0, 0);
                datetime installDateTime = datetime.newInstance(installDateSelected, dummyTime);
                if(installDateTime.format('EEE') == 'Mon')
                {
                    sameDayDelivery = true;
                }else
                {
                    // check if the day before is bank Holiday
                    date provisionalDeliveryDate = installDateSelected.addDays(-1);
                    sameDayDelivery = new Utilities().isTodayBankHoliday(provisionalDeliveryDate);
                    
                    
                }
            }
            
            
        }
        
        else if(safePlaceFlag == 'No')
        {
            objResponse.callBack = true;
            return objResponse;
        } 
        system.debug('Same Day Delivery -->'+sameDayDelivery);
        if(installDateSelected!=null)
        {
            if(sameDayDelivery)
            {
                objResponse.deliveryDate= installDateSelected;
                objResponse.deliverySlot =CustomerPortalHelper.getdeliverySlot(installTimeSelected);
            }else
            {
                objResponse.deliveryDate= installDateSelected.adddays(-1);
                objResponse.deliverySlot ='13:00 - 17:00';
            }
        }
        
        system.debug('Same Day Delivery -->'+json.serializePretty(objResponse));
        return objResponse;
         
      
  }
    
}