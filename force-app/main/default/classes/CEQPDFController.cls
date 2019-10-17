public class CEQPDFController {
    
    public id CEQID {get;set;}
    public CEQ_Header__c CEQHeader{get;set;}
    
    public List<CEQ_Item__c> CEQItem {get;set;}
    public List<CEQ_Item__c> CEQItemCustomer {get;set;}
    public List<CEQ_Item__c> CEQItemInstaller {get;set;}
    public List<CEQ_Item__c> CEQItemSales {get;set;}
    public List<CEQ_Item__c> CEQItemOther {get;set;}
    public List<CEQ_Item__c> CEQItemRQM {get;set;}
    
    public CEQPDFController(){
        
        CEQID = ApexPages.currentPage().getParameters().get('CEQID');
        
        CEQHeader = [select id, name, job__c, job__r.name, job__r.CHI_Lead_Name__c, wip__c, post_install__c, pre_install__c, deep_dive__c, CreatedById,
                    job__r.HSA_Name__c, job__r.mechanical_installer__c, AnswersTotal_Installations__c, AnswerTotal_All__c, AnswerTotal_Sales__c,
                    Installation_Score__c, Overall_Score__c, Sales_Score__c, YesTotal_All__c, YesTotal_Installations__c, YesTotal_Sales__c,CreatedDate, job__r.installation_Date__c
                    from CEQ_Header__c where id =: CEQID];
                    
        CEQItem =   [select name, id, answerpick__c, question_text__c, section__c, order__c, Notes__c
                    from CEQ_Item__c where CEQ_Header__c =: CEQID order by section__c, order__c];
                    
        CEQItemCustomer =   [select name, id, answerpick__c, question_text__c, section__c, order__c, Notes__c
                    from CEQ_Item__c where CEQ_Header__c =: CEQID AND section__c = 'Customer' order by order__c];
                    
        CEQItemInstaller =   [select name, id, answerpick__c, question_text__c, section__c, order__c, Notes__c
                    from CEQ_Item__c where CEQ_Header__c =: CEQID AND section__c = 'Installation' order by order__c];  
                    
        CEQItemSales =   [select name, id, answerpick__c, question_text__c, section__c, order__c, Notes__c
                    from CEQ_Item__c where CEQ_Header__c =: CEQID AND section__c = 'Sales' order by order__c]; 
                    
        CEQItemOther =   [select name, id, answerpick__c, question_text__c, section__c, order__c, Notes__c
                    from CEQ_Item__c where CEQ_Header__c =: CEQID AND section__c = 'Other' order by order__c];
        
        // Added 07/02/19 - Phil Dennison (WP52052)            
        CEQItemRQM =   [select name, id, answerpick__c, question_text__c, section__c, order__c, Notes__c
                    from CEQ_Item__c where CEQ_Header__c =: CEQID AND section__c = 'RQM' order by order__c];
                    
        
    } 

}