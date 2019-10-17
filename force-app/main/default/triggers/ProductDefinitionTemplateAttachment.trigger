trigger ProductDefinitionTemplateAttachment on Attachment (before insert, before update, after insert, after update) {

     if (Trigger.isInsert || Trigger.isUpdate) {
        if (Trigger.isBefore) {
            // since custom templates are used, and CSA only accepts a template with
            // the name DefaultScreenFlow-csac__RenderOfflineAppUI, this trigger updates the
            // name of all attachment templates which would otherwise have incorrect names
            for (Attachment a : Trigger.new) {
                if(a.name == 'DefaultScreenFlow-RenderOfflineAppUICustom') {
                    a.name = 'DefaultScreenFlow-csac__RenderOfflineAppUI';
                }
            }
        } else if(Trigger.isAfter) {
            
            List<Attachment> newAttachments = Trigger.new;
            Set<Id> attParentIds = new Set<Id>();
            
            for (Attachment att : newAttachments) {
                attParentIds.add(att.parentId);
            }
            
            // fetch attachments and put them in a map whose key is the parentId which attachment refers to 
            // if there are more than one attachment with the name DefaultScreenFlow-csac__RenderOfflineAppUI
            // per product definition, then all other attachments need to be deleted, and only
            // the latest attachment needs to stay
            
            Map<Id, List<Attachment>> mappedAtts = new Map<Id, List<Attachment>>();
            
            for (Id parId : attParentIds) {
                mappedAtts.put(parId,
                               [SELECT      Id, ParentId 
                                FROM        Attachment 
                                WHERE       Parent.Type = 'cscfga__Product_Definition__c' 
                                    AND     Name = 'DefaultScreenFlow-csac__RenderOfflineAppUI'
                                    AND     ParentId = :parId
                                ORDER BY    LastModifiedDate DESC]);
            }
            
                                            
            Set<Attachment> delSet = new Set<Attachment>();
            List<Id> prodDefIdsForUpdate = new List<Id>();

            // For each of the attachments in our map that have the same parentId, only one will be kept
            // Add others to 'to be deleted' set
            for (Id parId : mappedAtts.keyset()) {
                // add the first one to the list of Ids that need to be updated (we'll just select and update them to modify the 'date updated')
                                
                prodDefIdsForUpdate.add(parId);
                
                // for the others, add them to the delSet that we'll call delete command on
                for (Integer i = 1; i < mappedAtts.get(parId).size(); ++i) {
                    delSet.add(mappedAtts.get(parId)[i]);
                }
            }
                       
            if(delSet.size() > 0) {
                delete new List<Attachment>(delSet);    
            }

            // modify product definition LastModifiedDate - so that the product model/template can get downloaded to the device - sync checks last modified date
            if(prodDefIdsForUpdate.size() > 0) {
                List<cscfga__Product_Definition__c> prodDefsForUpdate = [SELECT Id FROM cscfga__Product_Definition__c WHERE Id IN :prodDefIdsForUpdate];
                update prodDefsForUpdate;
            }
        }
    }
}