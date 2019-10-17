public class GeographyChangeReqController{

    public Diary_Change__c diaryChng{get;set;}
    public boolean isSelected{get;set;}
    public boolean isData{get;set;}
    public list<RoleSubPatchWrap> listWrap{get;set;} 
    
    List<id> empIdSet = new List<id>();    
    
    List<Role__c> role = new List<Role__c>();
    list<Role_Sub_Patch__c> subpatchToInsert = new list<Role_Sub_Patch__c>();
    boolean deleteRec;
    public boolean getdeleteRec()
    {
    	return (listWrap.size()>0?true:false);
    }
    public void setdeleteRec(boolean tempdeleteRec)
    {
    	deleteRec= tempdeleteRec;
    }
    public boolean appGeo{get;set;}
   
     
    Utilities util = new Utilities(); 
    String diaryChngID = System.currentPageReference().getParameters().get('var_DCId');   
    Set<id> RoleIdSet = new Set<id>();  
    
    private integer counter=0;
    string LimitString = ' LIMIT : pageSize';
    public   integer pageSize{get;set;}  
    string Offset= ' OFFSET :counter';
    date startDate ; 
    date endDate;
    string roleSubpatchQuery = 'Select id,Name,Role__c,Start_Date__c,End_Date__c,Sub_Patch__c,Status__c,Role__r.Name,Role__r.Employee__r.Name,Sub_Patch__r.Name,Sub_Patch__r.Code__c,Sub_Patch__r.Type__c from Role_Sub_Patch__c'+ 
                                         ' where Role__c IN :RoleIdSet'+
                                         +' AND (Start_Date__c >= :startDate AND End_Date__c <= :endDate) Order By Start_Date__c ' ;
    string finalQuery = roleSubpatchQuery+LimitString+Offset;
    
         
    
    public class RoleSubPatchWrap{        
        public boolean isSelected{get;set;} 
        public Role_Sub_Patch__c roleSubPatch{get;set;}        
        
        public RoleSubPatchWrap(boolean isSelected,Role_Sub_Patch__c roleSubPatch)
        {
           this.isSelected = isSelected;
           this.roleSubPatch = roleSubPatch;             
        }
        
    }
    
    public GeographyChangeReqController(){      
    	pageSize = 30;
    	
    	getRoleSubPatches();     
                              
    }  

    public void getRoleSubPatches(){
           
        listWrap = new list<RoleSubPatchWrap>();
        diaryChng = [Select id,Request_Type__c, RecordTypeId,Employee__c,Employee_Group__c,Start__c,End__c,No_Of_Weeks__c,Week_1__c,Week_2__c,Week_3__c,Week_4__c,Employee__r.Name,Employee_Group__r.Name,Employee__r.Role__c from Diary_Change__c where id = :diaryChngID];
        System.debug('===DiaryChange==='+diaryChng);
        startDate = diaryChng.Start__c;
        endDate = diaryChng.End__c;
        list<string> Type = new list<String>{'HSA', 'Pool'}; 
        if(diaryChng.Employee_Group__c!=null){
            
           
            For(Employee_Group__c e : [Select Employee__c from Employee_Group__c where Group__c =: diaryChng.Employee_Group__c]){
                empIdSet.add(e.Employee__c);
            } 
            
            
            For(Role__c r : [Select id,Start_Date__c,End_Date__c from Role__c where Employee__c IN :empIdSet AND Type__c in :Type]){
                RoleIdSet.add(r.id);
            }                                        
        } 
        else{
            role = [Select id,Start_Date__c,End_Date__c from Role__c 
                                        where Employee__c =: diaryChng.Employee__c AND Type__c in : Type
                                        order by End_Date__c]; 
            if(role.size()>0)                             
            RoleIdSet.add(role[0].id);
            
        }   
        if(RoleIdSet.size()>0)
        appGeo = true;
        
        System.debug('===role==='+role); 
        total_size = Database.Query(roleSubpatchQuery).size(); 
        system.debug('Total Size()-->'+total_size);      
        //roleSubpatchQuery+= LimitString  + Offset;                                        
        runQuery();
      
    }
        
    public void onSelect(){
         isSelected = true;   
    }
    
    public PageReference onClickRefresh(){
        PageReference page = new PageReference('/apex/GeographyChangeReqPage'+'?var_DCId='+diaryChng.id);
        return page;
    } 
                       
    public void onClickDeleteAll(){
        list<Role_Sub_Patch__c> subpatch = new list<Role_Sub_Patch__c>();
        if(total_size<4999)
        {
        	subpatch = database.query(roleSubpatchQuery);
        	try{
            if(subpatch.size()>0)
                delete subpatch;  
                listwrap = new list<RoleSubPatchWrap>();
            }catch (Exception e)
            {
            	
            } 
        }else
        {
        	//DiaryChangeHelperMethods.massDeleteRole(RoleIdSet,startDate,endDate); 
        }
           
                        
        //getRoleSubPatches();         
    }
    
    public void onClickDeleteSelected(){
        list<Role_Sub_Patch__c> subpatch = new list<Role_Sub_Patch__c>();
        
        for(RoleSubPatchWrap wrapObj : listwrap){
           if(wrapObj.isSelected==true)
           subpatch.add(wrapObj.roleSubPatch);
        }
        if(subpatch.size()>0)
            delete subpatch;
        getRoleSubPatches();        
    }
    
    public pagereference onClickBack(){
        return new pagereference('/'+diaryChng.id);
    }
        
    public void onClickGeography(){ 
       DiaryChangeHelperMethods.insertRoleSubpatches(diaryChng.id, RoleIdSet);
      if(diaryChng.Request_Type__c == 'Appointment & Geography Change')
    	diaryChng.Geography_Complete__c = true;
      else
    	diaryChng.Status__c = 'Completed';
       update diaryChng;
       
       appGeo = false;
       
       util.setErrorMsg(false, 'Sucessfully Applied');
       
       //return  null; new pagereference('/'+diaryChng.id);
    }
       /* Pagination Code  
    */
   
  
   
   
    //keeps track of the offset
   
   public integer total_size; //used to show user the total size of the list
   
   public PageReference Beginning() { //user clicked beginning
      counter = 0;
      runQuery();
      return null;
   }
 
   public PageReference Previous() { //user clicked previous button
      counter -= pageSize;
      runQuery();
      return null;
   }
 
   public PageReference Next() { //user clicked next button
      counter += pageSize;
      runQuery();
      return null;
   }
 
   public PageReference End() { //user clicked end
      counter = total_size - math.mod(total_size, pageSize);
      runQuery();
      return null;
   }
 
   public Boolean getDisablePrevious() {
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }
 
   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + pageSize < total_size) return false; else return true;
   }
 
   public Integer getTotal_size() {
      return total_size;
   }
 
   public Integer getPageNumber() {
      return counter/pageSize + 1;
   }
 
   public Integer getTotalPages() {
      if (math.mod(total_size, pageSize) > 0) {
         return total_size/pageSize + 1;
      } else {
         return (total_size/pageSize);
      }
   }
   
   private void runQuery()
   {
   	 	System.debug('========='+finalQuery);
   		List<Role_Sub_Patch__c> roleSubPatch = new list<Role_Sub_Patch__c>();
   		roleSubPatch = database.query(finalQuery);
   		
   		if(!roleSubPatch.isEmpty())  
   		{      
   			listWrap = new list<RoleSubPatchWrap>();                                
	        for(Role_Sub_Patch__c objRs : roleSubPatch ){
	        	if(checkValid(objRs))
	        	{
	        		RoleSubPatchWrap wrapObj = new RoleSubPatchWrap(false,objRs);
	            	listWrap.add(wrapObj); 
	        	}
	        	
	        } 
   		}
       System.debug('========='+listWrap);
       System.debug('===roleSubPatch==='+roleSubPatch);    
       if(listWrap.size()==0)
       {
        isData = false;
     
       }
       else
        isData = true;
   }
   
   public boolean checkValid(Role_Sub_Patch__c objRs)
   {
   		date stDatWk = objRs.Start_Date__c.toStartOfWeek();
	    boolean include = false;
	    integer daysBetween = diaryChng.Start__c.toStartOfWeek().daysbetween(stDatWk);
	    integer weekIdentifier = math.mod(daysBetween,28);
	        	
	        	
    	if(weekIdentifier==0 && diaryChng.Week_1__c)
    	{
             include = true;
    	}else if(weekIdentifier ==7 && diaryChng.Week_2__c)
    	{
    		include = true;
    	}   
    	else if(weekIdentifier ==14 && diaryChng.Week_3__c)
    	{
    		include = true;
    	} 
    	else if(weekIdentifier== 21 && diaryChng.Week_4__c)
    	{
    		include = true;
    	}   
	        	
    	return include;
    	
   }
   
      
}