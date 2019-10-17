trigger updateQuote on order__c (after Insert, after update) {
 /*
   Skill Hours Are framed in this Order.
      0 -> mechanical_Hours
      1 -> Electrical_Hours
      2 -> PowerFlush_Hours
      3 -> RoofWork_Hours
      4 -> Building_Hours
      5 -> OtherSkill_Hours;
  Trigger to calculate the Actual Mechanical,Electrical,Powerflush etc of Quote when change in order Active_Line_Item.
 
 */
 //List<order__c> POList = new List<order__c>();
 List<Id> JobList = new list<Id>();
 list<ID> oppList = new List<ID>();
 Map<string,Map<string,string>> SkillMap;
 Map<String,String> WorkMap;
 Map<String,String> MatMap;
 Map<String,String> TotalCharges ;
  for(order__c PO: Trigger.new){
     if(Trigger.isUpdate){
         if(PO.Active_Line_Item_Value__c!=null && PO.Active_Line_Item_value__c <> trigger.oldmap.get(PO.id).Active_Line_Item_Value__c){
             if(PO.Opportunity__c!='' && PO.Opportunity__c!=null)
             OppList.add(PO.Opportunity__c);
         }
     }
     if(Trigger.isInsert){
       //if(PO.Active_Line_Item_Value__c!=null)
       if(PO.Opportunity__c!='' && PO.Opportunity__c!=null)
       OppList.add(PO.Opportunity__c);
     }
   
  }
  
  
 system.debug('----------->'+OppList);
 if(OppList.size()>0){
 List<Job__c> JobQuery = [select id,name,CHI_Lead__c,Actual_Labour_Charges__c,Actual_Material_Charges__c,(select id,name,Job__c,Status__c,Mechanical_Hours__c,Electrical_Hours__c,Powerflush_Hours__c,Roof_Work_Hours__c,Building_Hours__c,Other_Skill_Hours__c,Type__c,Active_Line_Item_Value__c, Total_Rebate__c from Purchase_Orders__r where Status__c!='Cancelled') from Job__c where CHI_Lead__c=:OppList];
  if(JobQuery.size()>0){
     
     //String JobPOHours;
     //String JobWMCharges;
     SkillMap = new Map<String,Map<String,String>>();
     WorkMap = new Map<String,String>();
     MatMap = new Map<String,String>();
     TotalCharges = new Map<String,String>();
     for(Job__c Job: JobQuery){
         Double mechanical_Hours = 0.0;
         Double Electrical_Hours = 0.0;
         Double PowerFlush_Hours = 0.0;
         Double RoofWork_Hours = 0.0;
         Double Building_Hours = 0.0;
         Double OtherSkill_Hours = 0.0;
         Double MaterialHours = 0.0;
         Double LabourCharges = 0.0;
         Double MaterialCharges = 0.0;
         double materialRebate = 0.0;
         map<string,string> WMMap = new Map<string,string>();
         for(Order__c ord: Job.Purchase_Orders__r){
           //system.debug('----->OUTSIDE:'+Ord.Type__c);
           if(ord.Type__c == 'Itinerary')
           ord.Type__c = 'Work';
           
           if(WorkMap.Containskey(ord.Type__c)){
             string Skillvalues = workMap.get(ord.Type__c);
             string[] skillHours = Skillvalues.split(':');  
               if(ord.Type__c=='Work' || Ord.Type__c == 'Itinerary'){
                 mechanical_Hours = Ord.Mechanical_Hours__c + Double.Valueof(skillHours[0]);
                 Electrical_Hours = Ord.Electrical_Hours__c + Double.Valueof(skillHours[1]);
                 PowerFlush_Hours = Ord.Powerflush_Hours__c + Double.Valueof(skillHours[2]);
                 RoofWork_Hours = Ord.Roof_Work_Hours__c + Double.Valueof(skillHours[3]);
                 Building_Hours = Ord.Building_Hours__c + Double.Valueof(skillHours[4]);
                 OtherSkill_Hours = Ord.Other_Skill_hours__c + Double.Valueof(skillHours[5]);
                 LabourCharges = Ord.Active_Line_Item_Value__c + Double.Valueof(skillHours[6]);
                 String JobPOHours = mechanical_Hours+':'+Electrical_Hours+':'+PowerFlush_Hours+':'+RoofWork_Hours+':'+Building_Hours+':'+OtherSkill_Hours+':'+LabourCharges;
                 WorkMap.put(Ord.Type__c,JobPoHours);
                 WMMap.put(Ord.Type__c,JobPoHours);
                 system.debug('------------>'+JobPOHours);
               }
                             
           }else{
              if(ord.Type__c=='Work' || Ord.Type__c == 'Itinerary'){
                 //system.debug('___>INSIDE ELSE:'+Ord.Type__c);
                 mechanical_Hours = mechanical_Hours + Ord.Mechanical_Hours__c;
                 Electrical_Hours = Electrical_Hours + Ord.Electrical_Hours__c;
                 PowerFlush_Hours = PowerFlush_Hours + Ord.Powerflush_Hours__c;
                 RoofWork_Hours = RoofWork_Hours + Ord.Roof_Work_Hours__c;
                 Building_Hours = Building_Hours + Ord.Building_Hours__c;
                 OtherSkill_Hours = OtherSkill_Hours + Ord.Other_Skill_hours__c;
                 LabourCharges = LabourCharges + Ord.Active_Line_Item_Value__c;
                 String JobPOHours = mechanical_Hours+':'+Electrical_Hours+':'+PowerFlush_Hours+':'+RoofWork_Hours+':'+Building_Hours+':'+OtherSkill_Hours+':'+LabourCharges;
                 WorkMap.put(Ord.Type__c,JobPoHours); 
                 WMMap.put(Ord.Type__c,JobPoHours);   
                 system.debug('---->Else'+JObPOHours);         
              }
             
           }
           
           if(MatMap.containsKey(Ord.Type__c)){
              string[] MatCharg = MatMap.get(Ord.Type__c).split(':');
              
              MaterialCharges = Ord.Active_Line_Item_Value__c + Double.valueof(MatCharg[0]);
              materialRebate =  Ord.Active_Line_Item_Value__c + Double.valueof(MatCharg[1]);
              MatMap.put(Ord.Type__c,string.valueof(MaterialCharges)+':'+string.valueof(materialRebate));
              WMMap.put(Ord.Type__c,string.valueof(MaterialCharges)+':'+string.valueof(materialRebate));
           }else if(Ord.Type__c =='Material'){
              MaterialCharges = MaterialCharges + Ord.Active_Line_Item_Value__c;
              materialRebate = materialRebate + Ord.Total_Rebate__c;
              MatMap.put(Ord.Type__c,string.valueof(MaterialCharges)+':'+string.valueof(materialRebate));
              WMMap.put(Ord.Type__c,string.valueof(MaterialCharges)+':'+string.valueof(materialRebate));  
           }
             
         }
         
         SkillMap.put(Job.CHI_Lead__c,WMMap);
         System.debug('$$$$$$$$$$$$$$$$$$$'+WMMAP);
         system.debug('AAAAAAAAAAAAAAAAAAAAA'+job.Actual_Labour_Charges__c+' '+job.Actual_Material_Charges__c);
         /*if(TotalCharges.containskey(Job.CHI_Lead__c)){
           string WMatCharges = TotalCharges.get(Job.CHI_Lead__c);
           string[] WMatValues = WMatCharges.split(':');
           LabourCharges = job.Actual_Labour_Charges__c + Double.valueof(WMatValues[0]);
           MaterialCharges = job.Actual_Material_Charges__c + Double.valueof(WMatValues[1]);
           string JobWMCharges = LabourCharges+':'+MaterialCharges; 
           TotalCharges.put(job.CHI_Lead__c,JobWMCharges);

         }else{
            system.debug('----->'+LabourCharges);
            LabourCharges = labourCharges + job.Actual_Labour_Charges__c;
            MaterialCharges = MaterialCharges + job.Actual_Material_Charges__c;
            String JobWMCharges = LabourCharges+':'+MaterialCharges; 
            TotalCharges.put(job.CHI_Lead__c,JobWMCharges);
         }*/
         
     }
     
  }
  
  List<BigMachines_Quote__c> QuoteList = new List<BigMachines_Quote__c>();
  for(BigMachines_Quote__c BGQ:[select id,name,Billed__c,Actual_Building_Work_Cost__c,Actual_Electrical_Cost__c,Actual_Labour_Cost__c,All_Other_skills_Actual_Cost__c,Actual_Material_Cost__c,Actual_Powerflush_Cost__c,Actual_Roof_Work_Cost__c,Acual_Mechanical_Cost__c,Average_Labour_Cost_Quote__c,Average_Material_Cost_Quote__c,Opportunity__c from BigMachines_Quote__c where Opportunity__c=:OppList AND stage__c=:'Quote Finalised - Accepted' AND Is_Primary__c=:TRUE]){
    
    if(SkillMap.containskey(BGQ.Opportunity__c)){
        String skillValues = SkillMap.get(BGQ.Opportunity__c).get('Work');
        
        if(skillValues!=null){
        String[] skillHours = skillValues.split(':');
        
       /* if(TotalCharges.containsKey(BGQ.Opportunity__c)){
          String WMValues = TotalCharges.get(BGQ.Opportunity__c);
          String[] WMCharges = WMValues.split(':');
          BGQ.Actual_Labour_Cost__c = Double.valueof(WMCharges[0]);
          BGQ.Actual_Material_Cost__c = Double.valueof(WMCharges[1]);
        }*/
        
        BGQ.Acual_Mechanical_Cost__c = Double.valueof(skillHours[0]);
        BGQ.Actual_Electrical_Cost__c = Double.valueof(skillHours[1]);
        BGQ.Actual_Powerflush_Cost__c = Double.valueof(skillHours[2]);
        BGQ.Actual_Roof_Work_Cost__c = Double.valueof(skillHours[3]);
        BGQ.Actual_Building_Work_Cost__c = Double.valueof(skillHours[4]);
        BGQ.All_Other_skills_Actual_Cost__c = Double.valueof(skillHours[5]);
        BGQ.Actual_Labour_Cost__c = Double.valueof(skillHours[6]);
        }
        if(SkillMap.ContainsKey(BGQ.Opportunity__c) && SkillMap.get(BGQ.Opportunity__c).ContainsKey('Material'))
        {
            String[] MatVal = SkillMap.get(BGQ.Opportunity__c).get('Material').split(':');
            system.debug('??????????'+MatVal);
            if(MatVal !=null)
            {
                BGQ.Actual_Material_Cost__c = Double.valueof(MatVal[0]);
                BGQ.Actual_Rebate_Total__c = Double.valueof(MatVal[1]);
            
            }
        }
        QuoteList.add(BGQ);
    }
    
  }
  
  if(QuoteList.size()>0)
  update QuoteList;
  
 } 
 
}