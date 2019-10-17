/*Type Name: BookItineraryApp 
Author: Cognizant
Created Date: 12/10/2010
Reason: This class is created to book an Itinerary appointment for all the Job element when one appoitment is booked
        for one Job element.
Change History:
*/
public class BookItineraryApp {

/*
    Future method used as more than 100 DML statements may occur (SFDC Govenor Limit) as trigger 'AppointmentInsert.trigger' also makes 
    DML statements
*/
    @future (callout=false)
    public static void updateelementsAppFuture(Set<Id> elementId,Set<String> appIds,Map<String,String> appJEMap,String Assignedsupplier,String Assingedsupplierbranch,Datetime StartDate,Datetime CompletionDate){
    System.debug('inside create appointment for Job Element');   
    //declare exception variable for reporting  
    Appointment__c[] appointments = [select id,Job__c,Job_Element__c,Assigned_To__r.Supplier__r.Name, Assigned_To__r.Supplier_Branch_Num__c, Assigned_To__c, Start__c, End__c from Appointment__c where id in:appIds];

    
    system.debug('@@@@@appointments'+appointments);
        System.debug('--Apps = '+appointments);
        System.debug('--Assignedsupplier = '+Assignedsupplier);
        System.debug('--Assingedsupplierbranch = '+Assingedsupplierbranch);
        System.debug('--StartDate = '+StartDate);
        System.debug('--CompletionDate = '+CompletionDate);
        List<String> region = System.Label.Trial_For_ESD.split(';');
        Set<String> reg = new Set<String>();
        reg.addAll(region);
        System.debug('=====Priti==='+region );
        List<Job_ELement__c> eleList = [select id,Job__c,Job__r.Name,Type__c,code__c,Job__r.Region__c,Start_Date__c,Employee_Itn__c,Completion_Date__c,P5_IsItinerary__c,Product_ID__c From Job_Element__c where id in :elementId];
        Set<String> jobIds = new Set<String>();
        Map<String,String> jeCodesMap = new Map<String,String>();
        Set<String> codes = new Set<String>();
        List<Pre_Electrical_Work_document__c> PreelecList = new List<Pre_Electrical_Work_document__c>();
        
         
        for(Job_ELement__c je : eleList){           
            jobIds.add(je.Job__c);
            codes.add(je.code__c);
            jeCodesMap.put(je.code__c,je.id);
            
           
        }
        List<Job_ELement__c> eleList2 = [select id,Type__c,code__c,Start_Date__c,Employee_Itn__c, Completion_Date__c From Job_Element__c where id not in :elementId and Job__c in :jobIds and code__c in : codes and Type__c = 'Work'];
        Map<String,List<Job_Element__c>> codeMap = new Map<String,List<Job_Element__c>>();
        for(String code : codes){
            List<Job_Element__c> tempList = new List<Job_Element__c>();      
            for(Job_ELement__c jele : eleList2){
                if(jele.code__c == code){
                    if(codeMap.containsKey(jele.code__c)){
                        tempList = codeMap.get(jele.code__c);
                        tempList.add(jele);
                        codeMap.put(jele.code__c , tempList);
                    }else{
                        tempList.add(jele);
                        codeMap.put(jele.code__c , tempList);
                    }
                }
            }
        }
        system.debug('codeMap-->'+codeMap);
        List<Job_ELement__c> finalJEs = new List<Job_ELement__c>();
        //finalJEs.addAll(eleList);
        //finalJEs.addAll(eleList2);
        
        Map<String,Appointment__c> appMap = new Map<String,Appointment__c>();
        Map<String,Appointment__c> elementMap = new Map<String,Appointment__c>();
        for(Appointment__c app : appointments){
            elementMap.put(app.Job_Element__c,app);
            system.debug('@@@@@@elementMap.put(app.Job_Element__c,app)'+elementMap.put(app.Job_Element__c,app));
            appMap.put(app.id,app);
            Assignedsupplier = app.Assigned_To__r.Supplier__r.Name;
            Assingedsupplierbranch = app.Assigned_To__r.Supplier_Branch_Num__c;
            system.debug('app-->'+app); 
        }
       
        for(Job_ELement__c je : eleList){
        system.debug('@@@@@@je'+je);
        system.debug('@@@@@@eleList'+eleList);
            Pre_Electrical_Work_document__c Preelec = new Pre_Electrical_Work_document__c();
            Set<String> prodIds = new Set<String>();
            List<String> str = System.Label.Pre_Electric_Work_Codes_2.split(',');
            prodIds.addAll(str);
            if(prodIds.contains(JE.Product_ID__c))
           if(JE.P5_IsItinerary__c==true && reg.contains(JE.Job__r.Region__c))           
           { 
             
             system.debug('@@@@@@JE.P5_IsItinerary__c'+JE.P5_IsItinerary__c);
             system.debug('@@@@@@JE.Product_ID__c'+JE.Product_ID__c);
             
             Preelec.Start__c=elementMap.get(JE.id).Start__c;
             system.debug('Preelec.Start__c'+Preelec.Start__c);
             Preelec.End__c=elementMap.get(JE.id).End__c;
             system.debug('Preelec.End__c'+Preelec.End__c);
             Preelec.Job__c=Je.Job__C;
             Preelec.Job_Special_Id__c=Je.Job__r.Name+' Pre Electric Doc';
             system.debug('Preelec.Job_Special_Id__c'+Preelec.Job_Special_Id__c);
             Preelec.Employee__c=elementMap.get(JE.id).Assigned_To__c;
             system.debug('Preelec.Employee__c'+Preelec.Employee__c);
            
             PreelecList.add(Preelec);
             system.debug('@@@@@@PreelecList.add(Preelec)'+PreelecList);
           }
            je.Start_Date__c = StartDate.date();
            je.Completion_Date__c = CompletionDate.date();
            je.Current_Supplier__c = Assignedsupplier;
            je.Current_Supplier_Number__c = Assingedsupplierbranch;
            if(elementMap.containskey(JE.id))
            je.Employee_Itn__c = elementMap.get(JE.id).Assigned_To__c;
            finalJEs.add(je);
            system.debug('finalJEs1--->'+finalJEs);
            if(codeMap != null){
                List<Job_Element__c> tempList = codeMap.get(je.code__c);
                if(tempList != null && tempList.size() > 0){
                    for(Job_Element__c jInner : tempList){
                        jInner.Start_Date__c = je.Start_Date__c;
                        jInner.Completion_Date__c = je.Completion_Date__c;
                        jInner.Current_Supplier__c = je.Current_Supplier__c;
                        jInner.Current_Supplier_Number__c = je.Current_Supplier_Number__c;
                        finalJEs.add(jInner);
                    }
                }
            }
        }
       
        try{
            update finalJEs;
            system.debug('finalJEs2--->'+finalJEs);
            
            if(PreelecList.size()>0)
            system.debug('@@@@@@PreelecList'+PreelecList);
            upsert PreelecList Job_Special_Id__c;
             //upsert PreelecList;
            system.debug('@@@@@@PreelecList Job_Special_Id__c'+PreelecList);
            
            
        }catch(Exception e){
            System.debug('@Exception upodating JE from Appointment : @'+e.getMessage());
        }
  }
  /*
  Update the Job elements when any appointment is deleted for Itineary
  */
  @future (callout=false)
    public static void updateelementsAppdeleteFuture(Set<String> jobIds,Set<String> codes){
    System.debug('inside create appointment for Job Element');   
    //declare exception variable for reporting  
        List<Job_ELement__c> eleList2 = [select id,Type__c,code__c,Start_Date__c,Supplier_Order_Number__c, Completion_Date__c,Status__c,Sub_Status__c From Job_Element__c where Job__c in :jobIds and code__c in : codes and Type__c = 'Work'];
           system.debug('eleList2--------->'+eleList2); 
            for(Job_ELement__c jele : eleList2){
                jele.Start_Date__c = null;
                jele.Completion_Date__c = null;
                jele.Current_Supplier__c = '';
                jele.Current_Supplier_Number__c = '';
                jele.Status__c = 'New';
                jele.Sub_Status__c = 'Awaiting Order';
                jele.Supplier_Order_Number__c = '';
            }
            if(eleList2.size()>0){
            try{
            update eleList2;
            system.debug('eleList2--->'+eleList2);
            }catch(Exception e){
            System.debug('@Exception upodating JE from Appointment : @'+e.getMessage());
            }
         }
    }


}