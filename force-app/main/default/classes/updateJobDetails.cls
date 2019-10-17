global class updateJobDetails{
    Webservice static String overrideJob(String jobId){
          
        String s_result='';
        // Cognizant - CHI Phase III CR-002 implementation... START 
    
        AddNewSkill ObjNewSkill = new AddNewSkill();
        Job__c job = ObjNewSkill.fetchJobByJobId(jobId);
        //Job__c job = [select Quote__r.skillTotalWaterHeatingFixing__c,Overriden__c,Quote__r.skillTotalUnventedHotWater__c,Quote__r.skillTotalSpecialistBuilding__c,Quote__r.skillTotalScaffolder__c,Quote__r.skillTotalRoofWork__c,Quote__r.skillTotalPaymentCollection__c,Quote__r.skillTotalMechanical__c,Quote__r.skillTotalLPGInstallation__c,Quote__r.skillTotalFireWallHeaterFixing__c,Quote__r.skillTotalElectrical__c,Quote__r.skillTotalContractorInstallation__c,Quote__r.skillTotalConnectSolarPanels__c,Quote__r.skillTotalBuildingWork__c,Quote__r.skillTotalPowerFlush__c,Quote__r.SkillTotalElectricalWorkASP__c,Quote__r.skillTotalAsbestosRemoval__c,Quote__r.skillTotalAsbestosRemovalFixedRate__c,Quote__r.skillTotalSolar__c,Quote__r.installationDate__c,Quote__r.deliveryDate__c,Installation_Date__c,Delivery_Date__c from Job__c where id =:jobId];    
        
        // Cognizant - CHI Phase III CR-002 implementation... END
        
        BigMachinesQuoteInsertJobReconciliation objRecncile = new BigMachinesQuoteInsertJobReconciliation();
        job  = objRecncile.setJobHoursFromQuote(job,job.Quote__r);
        
        boolean entered =false;
        if(job.Quote__r.deliveryDate__c != null && job.Quote__r.installationDate__c != null && job.Quote__r.deliveryDate__c <= job.Quote__r.installationDate__c){
            job.Installation_Date__c = job.Quote__r.installationDate__c;
            job.Delivery_Date__c = job.Quote__r.deliveryDate__c;
            entered = true;
        }
        job.Overriden__c = true; 
        try{
            update job;
            if(entered == false)
                s_result= 'nochange';
            else
                s_result= 'success';
        }catch(Exception e){
            System.debug('## Could not override job details '+e);
            s_result='EXC'+e.getMessage();
        }
        return s_result;
    }
}