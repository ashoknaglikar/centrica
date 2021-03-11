public class ConsumableSearch {

    
  private String soql {get;set;}
  
  map<string, string> codeImageURLMap;// = new map<string, string>();
  public List<genericClass> getconsumables()
  {
    
    if(stdcon.getrecords().size()>0)
    {
        codeImageURLMap = new map<string, string>();
    	consumables = new list<genericClass>();
    	for(Sobject c :stdcon.getrecords())
	    {
	        Consumables__c con = (Consumables__c) c;
	        codeImageURLMap.put(con.ImageName__c, null);
	       
	    }
	    
	    //buildImageMap(codeImageURLMap);
	    for(Sobject c :stdcon.getrecords())
	    {
	        Consumables__c con = (Consumables__c) c;
	        system.debug('Map contains -->'+con.ImageName__c);
	        system.debug('Map contains -->'+codeImageURLMap.containskey(con.ImageName__c));
	        string url = codeImageURLMap.containskey(con.ImageName__c)?codeImageURLMap.get(con.ImageName__c):'';
	        genericClass genObj = new genericClass(c,url);
	        consumables.add(genObj);
	    }
	    consumables=checkForPreFav( consumables, favlist);
	    system.debug('consumables -->'+consumables);
    }
    return  consumables;  
   }
  /* 
  public void buildImageMap(map<string, string> codeImageURLMap)
  {      
      try{
          if(!test.isrunningTest() && label.sharepointswitch == 'on'){      
          for(items_SharepointVia360__x item : [select id, DisplayUrl,DownloadUrl__c, Name__c from items_SharepointVia360__x where name__c in :codeImageURLMap.keyset()])
            {
                codeImageURLMap.put(item.Name__c, item.DownloadUrl__c);   
            }
          }
      }catch(Exception e){}
    system.debug('-->'+codeImageURLMap);
      
  }
  */
  public boolean bln_error{get;set;}     
  public list<genericClass> selectedConsumables{get;set;}
  public string consumableId{get;set;}
  public string parentId{get;set;}
  public decimal BasketTotal{get;set;}
  public string BasketTotalString {get;set;}
  public integer count {get;set;}
  public integer mode{get;set;}
  public boolean bln_mode{get;set;}
  list<Consumables__c> conList = new list<Consumables__c>();
  public List<genericClass> consumables;
  Employee__c empDetails = new Employee__c();
  public integer newmode {get;set;}
  map<id, genericClass> previousAddedItems = new map<id, genericClass>();
  public string info {get;set;}
  public boolean bln_info {get;set;}
  public boolean checkOutBtn {get;set;}
  public Consumables_Requests__c conReq {get;set;}
  map<Id,Consumable_Items__c> ItemConsMap = new map<Id,Consumable_Items__c>();
  list<FavoriteConsumables__c> favlist = new  list<FavoriteConsumables__c>();
  integer pageSize =25;
  public string category{get;set;}
  public boolean redValue{get;set;}
  // Change: HSA Consumable Change
  public integer userMode {get;set;} // 0=> Installer, 1=> HSA, 2=>Selling Installer
  public string shoppingMode{get;set;}
  
  
  
  public list<selectoption> getcategoryList()
  {
      List<SelectOption> options = new List<SelectOption>();
      options.add(new selectoption('','---None---'));
      for(ProductDescription__c p : loadCategory())
      {
          options.add(new selectoption(p.id,p.name));
      }
      
      return options;
  }
  
  public string Subcategory {get;set;}
  public list<selectoption> SubcategoryList{get;set;}
  
  public ApexPages.StandardSetController stdcon{get{
          if(stdcon==null)
          {
                stdcon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));  
            	stdcon.setPageSize(pageSize);
          }return stdcon;
  } set;
  }
  
  private list<ProductDescription__c> loadCategory()
  {
  	string CategoryQuery= 'Select p.Name, p.IsActive__c, p.Id, p.Code__c From ProductDescription__c p where IsActive__c = true';
  	string Criteria = ' AND Group__c=\'Operations\'';
  	
  	if(userMode==0)
  	{
  	CategoryQuery+=Criteria;
  	}
  	else if(userMode == 1)
  	{
  		Criteria = ' AND Group__c=\'Sales\'';
  		CategoryQuery+=Criteria;
  	}
  	CategoryQuery+=' order by name ASC';
  	return (Database.query(CategoryQuery));
  }
  
  private list<Sub_Product_Description__c> loadSubCategory()
  {
  	string CategoryQuery= 'Select p.Name, p.IsActive__c, p.Id, p.Code__c From Sub_Product_Description__c p where IsActive__c = true and Product_Description__c= :category';
  	string Criteria = ' AND Group__c=\'Operations\'';
  	if(userMode==0)
  	{
  	CategoryQuery+=Criteria;
  	}
  	else if(userMode == 1)
  	{
  		Criteria = ' AND Group__c=\'Sales\'';
  		CategoryQuery+=Criteria;
  	}
  	CategoryQuery+=' order by name ASC';
    return (Database.query(CategoryQuery));
  	
      //return([Select p.Name, p.IsActive__c, p.Id, p.Code__c From Sub_Product_Description__c p where IsActive__c = true and Product_Description__c= :category]);
  }
  string subGroupCriteria = '';
  
  public void populateSubcategory() {
        SubcategoryList = new list<selectoption>();
        SubcategoryList.add(new selectoption('','---None---'));
        for(Sub_Product_Description__c p : loadSubCategory())
        {
            SubcategoryList.add(new selectoption(p.id,p.name));
        }
        Subcategory = null;
        runSearch();
           
    }
    
   public void populateConsumables()
   {
     runSearch();
   }
  
  Utilities util = new Utilities();
  // init the controller and display some sample data when the page loads
  public ConsumableSearch () {
  	
  	//Change: HSA Consumable Change
  	userMode = 0;
  	shoppingMode = 'Installer Catalogue';
  	//Change: HSA Consumable Change
  	
  	soql = 'Select ImageName__c,c.Image_location__c, c.Sub_Product_Description__c,Sub_Product_Description__r.Name, c.Sub_Product_Code_Description__c,Image_URL__c,Static_Resource_Location__c, c.SubProductGroup__c, c.Status__c, c.Short_Name__c, c.ShortDescription__c, c.Product_Group__c, c.Product_Code__c, c.Name, c.Id,ProductGroupDescription__c,Product_Group_Lookup__c,CostPrice__c,Size__c,Unit_Quantity__c,Max_Quantity__c, Sharepoint_URL__c From Consumables__c c where Status__c in :consumableStatuses';
  	subGroupCriteria = '';
    redValue = false;
    bln_info = false;
    id userid = userinfo.getUserId();
    integer mode = integer.valueof((ApexPages.currentPage().getParameters().get('mode'))==null?1:2);
    system.debug('---->'+mode);
    selectedConsumables = new list<genericClass>();
    consumables = new list<genericClass>();
    try
    {
        empDetails = [Select id,Consumable_Subgroup__c, Employee_Number__c, Primary_Role__c,Business_Group__c,Salesforce_User__r.EmployeeNumber,Fav_Consumable_Count__c,District__r.Authorisation_Value__c from Employee__c where Salesforce_User__c = :userid limit 1];
        system.debug(empDetails.Consumable_Subgroup__c);
        if(empDetails.Consumable_Subgroup__c!=null)
        {
            subGroupCriteria =+ ' AND Consumable_Sub_Group__c includes (\''+empDetails.Consumable_Subgroup__c+'\') ';
            soql+=subGroupCriteria;
        }else
        {
            subGroupCriteria =+ ' AND CreatedDate =null ';
            soql+=subGroupCriteria;
        }
        system.debug(soql);
        //Change: HSA Consumable Change
        if(empDetails.Primary_Role__c=='Selling Installer')
        {
        	userMode = 2;
        	shoppingMode = 'Installer & Sales catalogue';
        	soql= soql.replace(subGroupCriteria, ' ');
        }
        
        else if(empDetails.Business_Group__c!=null && empDetails.Business_Group__c.contains(IV_Vectors__c.getInstance('Sales Consumable').Key__c))
        {
        	userMode = 1;
        	shoppingMode = 'Sales catalogue';
        	soql+=' and Group__c =\'Sales\'';
        	soql= soql.replace(subGroupCriteria, ' ');
        	
        }else
        {
        	soql+=' and Group__c =\'Operations\'';
        }
        soql+='order by CreatedDate Desc';
        //Change: HSA Consumable Change
        
        system.debug(empDetails);   
        if(empDetails != null)
        {
            try
            {
                    conReq = [Select c.IsShoppingBasket__c, c.Employee__c,Item_Count__c, c.Employee_ID__c, c.District__c, c.Callidus_Patch_Id__c,Request_Total_Value__c,Capital_Item_Count__c, 
                                     (Select Id, Request__c, Cost_Each__c, Item_Requested__c, Line_Total__c, Quantity__c, Product_Code__c,Item_Requested__r.Max_Quantity__c,Item_Requested__r.ImageName__c From Consumable_Items__r)
                                     From Consumables_Requests__c c where Employee__c = :empDetails.Id and IsShoppingBasket__c = true and Status__c = 'In Progress' limit 1];
                if(conReq != null)
                    {
                        list<id> consuIdList = new list<id>();
                        list<Consumables__c> consuList = new list<Consumables__c>();
                        map<string,string> codeImageURLMapIntermediate = new map<string,string>(); 
                        for(Consumable_Items__c c: conReq.Consumable_Items__r)
                        {
                            consuIdList.add(c.Item_Requested__c);
                            if(!ItemConsMap.containsKey(c.Item_Requested__c))
                            {
                                ItemConsMap.put(c.Item_Requested__c, c);
                                codeImageURLMapIntermediate.put(c.Item_Requested__r.ImageName__c,null);
                            }
                            
                        }
                        
                        //buildImageMap(codeImageURLMapIntermediate);
                        
                        for(Consumables__c c :[Select c.Image_Location__c,ImageName__c, c.Sub_Product_Description__c,Sub_Product_Description__r.Name,Image_URL__c,Static_Resource_Location__c, c.Sub_Product_Code_Description__c, c.SubProductGroup__c, c.Status__c, c.Short_Name__c, c.ShortDescription__c, c.Product_Group__c, c.Product_Code__c, c.Name, c.Id,ProductGroupDescription__c,Product_Group_Lookup__c,CostPrice__c,Size__c ,Unit_Quantity__c,Max_Quantity__c,Sharepoint_URL__c From Consumables__c c where  Status__c = 'Active' and Id in :consuIdList])
                        {
                            string url = codeImageURLMap.containskey(c.ImageName__c)?codeImageURLMap.get(c.ImageName__c):''; 
                            genericClass gen =  new genericClass((sobject)c, url);
                            gen.Quantity =   ItemConsMap.get(c.id).Quantity__c.intvalue();
                            gen.LineCost = ItemConsMap.get(c.id).Line_Total__c;
                            gen.lineCostStng = gen.LineCost.toplainstring();
                            selectedConsumables.add(gen);
                            previousAddedItems.put(c.Id,gen);
                            checkOutBtn = true;
                        }
                            
                        util.setErrorMsg(false, 'You have one Active Basket.' );
                        BasketTotal = conReq.Request_Total_Value__c;
                        if(BasketTotal>empDetails.District__r.Authorisation_Value__c)
                        redValue = true;
                        BasketTotalString = conReq.Request_Total_Value__c.toplainstring();
                        count = conReq.Item_Count__c.intValue();
                    }   
                
                    
            }
            catch(Exception e)
            {
                BasketTotal = 0.0; 
                BasketTotalString= '0.00';   
                count = 0;
            }                
        }                        
     
    
	    if(mode>0)
	    {
	        if(mode == 1)
	        {
	            mode = 1;
	            bln_mode = true;
	        }else
	        {
	            mode = 2;
	            bln_mode = false;
	        }
	        system.debug('---->'+mode);
	       	populateFavoriteList();
	        runQuery();
	    }
    }
    catch (exception e)
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You are not allowed to order Consumables as there is no Employee record. Please Contact your Manager or System Admin.'));
        bln_error = true;
    }     
  }
   
  public void loadfav()
  {
        populateFavoriteList();
  }
  
 
  
  private void populateFavoriteList()
  {
    favlist = [Select Consumable__c From FavoriteConsumables__c f where Employee__c = :empDetails.Id and Consumable__r.Status__c = 'Active' limit 50];
    list<id> consuIdList = new list<id>();
    list<Consumables__c> consuList = new list<Consumables__c>();
    for(FavoriteConsumables__c f:favlist)
    {
        consuIdList.add(f.Consumable__c);
    }
   
    if(consuIdList.size()>0)
    {
        stdcon = new ApexPages.StandardSetController(Database.getQueryLocator([Select c.Image_location__c, c.Sub_Product_Description__c,Sub_Product_Description__r.Name,Image_URL__c,Static_Resource_Location__c, c.Sub_Product_Code_Description__c, c.SubProductGroup__c, c.Status__c, c.Short_Name__c, c.ShortDescription__c, c.Product_Group__c, c.Product_Code__c, c.Name, c.Id,ProductGroupDescription__c,Product_Group_Lookup__c,CostPrice__c,Size__c ,Unit_Quantity__c,Max_Quantity__c,ImageName__c,Sharepoint_URL__c From Consumables__c c where  Status__c = 'Active' and id in :consuIdList ]));  
       
                // sets the number of records in each page set  
        stdcon.setPageSize(pageSize);
            
    }else
    {
        stdcon = null;
    }
  }
  
  
 // runs the actual query
  public void runQuery() {
 
    try 
    {
      stdcon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));  
      stdcon.setPageSize(25);
     } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some thing went Wrong! Please contact Sys Admin'));
    }
 
  }
  list<string> consumableStatuses =new list<string>{'Active','Superceded'};
  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {
 
    String Name = Apexpages.currentPage().getParameters().get('Name');
    
    system.debug('mode--->'+mode+'---'+Name);
   
    soql = 'Select c.Sub_Product_Description__c,Sub_Product_Description__r.Name, c.Sub_Product_Code_Description__c,Image_URL__c,Image_Location__c,Static_Resource_Location__c , c.SubProductGroup__c, c.Status__c, c.Short_Name__c, c.ShortDescription__c, c.Product_Group__c, c.Product_Code__c, c.Name, c.Id,ProductGroupDescription__c,Product_Group_Lookup__c,CostPrice__c,Size__c,Unit_Quantity__c,Max_Quantity__c,ImageName__c,Sharepoint_URL__c  From Consumables__c c where Status__c in :consumableStatuses';
    
    
    if (Name != null && !Name.equals(''))
    soql += ' and Name LIKE \'%'+String.escapeSingleQuotes(Name)+'%\'';
    if(category !=null)
    soql += ' and Sub_Product_Description__r.Product_Description__c = \''+String.escapeSingleQuotes(category)+'\'';
    if(Subcategory!=null)
    soql += ' and Sub_Product_Description__c= \''+String.escapeSingleQuotes(Subcategory)+'\'';
    // run the query again
    if(userMode==0)
    {
        soql += ' and Group__c=\'Operations\'';
        soql+=subGroupCriteria;
    }
    else if(userMode==1)
    soql += ' and Group__c=\'Sales\'';
    runQuery();
    return null;
  }
  
 
  public void addFavorite()
  {
    list<FavoriteConsumables__c> deleteList = [select id from FavoriteConsumables__c where Consumable__r.Status__c = 'Inactive'];
    if(deleteList.size()>0)
    delete deleteList;
    
    empDetails = [Select id,Employee_Number__c,Salesforce_User__r.EmployeeNumber,Fav_Consumable_Count__c,District__r.Authorisation_Value__c  from Employee__c where id = :empDetails.Id limit 1];
    
    
    if(empDetails.Fav_Consumable_Count__c<101)
    {
        system.debug('@@@@@--->'+consumableId);
        FavoriteConsumables__c fav = new FavoriteConsumables__c(Employee__c = empDetails.Id, Consumable__c = consumableId, UniqueKey__c = empDetails.Employee_Number__c+consumableId);
        upsert fav UniqueKey__c;
        empDetails = [Select id,Employee_Number__c,Salesforce_User__r.EmployeeNumber,Fav_Consumable_Count__c,District__r.Authorisation_Value__c  from Employee__c where id = :empDetails.Id limit 1];
        info = 'Sucessfully Added to My Van. Total number of Items in My Van is: '+empDetails.Fav_Consumable_Count__c;
    
    }else
    {
        info = 'Max 100 items are allowed in My Van list. If you wish to add additional item then please first delete an existing item. ';
    }
    favlist = [select id, Consumable__c from FavoriteConsumables__c where Employee__c = :empDetails.Id];
    
    consumables = checkForPreFav(consumables, favList);
  
    
    bln_info= true;
    
    
    //return null;
  }
  private list<genericClass> checkForPreFav(list<genericClass> genclssList, list<FavoriteConsumables__c> favList)
  {
        for(genericClass g: genclssList)
        {
                for(FavoriteConsumables__c f: favList)
                {
                        if(f.Consumable__c == g.consu.id)
                        {
                                g.isalreadyfav = true;
                        }
                }
        }
        return genclssList;
  }
  
  public void removeFavorite()
  {
    FavoriteConsumables__c fav = [select id from FavoriteConsumables__c  where UniqueKey__c = :empDetails.Employee_Number__c+consumableId];
    if (fav != null)
    delete fav ;
    populateFavoriteList();
    //return null;
    bln_info = false;
  }
  
  public pagereference addBasket()
  {
    integer  count1 =0;
    if(conReq == null)
    {
        conReq = new Consumables_Requests__c(Status__c = 'In Progress', IsShoppingBasket__c = true,Employee__c = empDetails.id ,Employee_ID__c=empDetails.Salesforce_User__r.EmployeeNumber);
        insert conReq;
    }
    
    count1 = [select count() from Consumable_Items__c where Request__c = :conReq.id];
    
    //ConsumableSearchCont con = new ConsumableSearchCont();
    list<genericClass> tempselectedConsumables = new list<genericClass>();
    list<Consumable_Items__c> upsertlist = new list<Consumable_Items__c>();
    double TempBasketTotal = 0.0;
   
    
    for(genericClass c : consumables)
    {
        if(c.isSelected)
        {
            system.debug('Sugu 1st debug-->'+c);    
            genericClass consumableItem  = new genericClass((sobject)c.consu, c.url);
            integer previousQuan = 0;
           //if(previousAddedItems.containskey(c.consu.Id))
            if(previousAddedItems.containskey(c.consu.Id)&&ItemConsMap.containsKey(c.consu.Id))
           {
                        system.debug('In if');
                  genericClass consumableItem1 = previousAddedItems.get(c.consu.Id);
                  previousQuan = consumableItem1.Quantity;
                  consumableItem.LineCost = consumableItem1.LineCost +(c.Quantity*c.consu.CostPrice__c.setscale(2));
                  consumableItem.lineCostStng = consumableItem.LineCost.toPlainString();
                  consumableItem.Quantity = previousQuan+c.Quantity;
                  system.debug('~~~~~'+consumableItem.Quantity);
                   
                  upsertlist.add(new Consumable_Items__c(Id= ItemConsMap.get(c.consu.Id).Id,  Quantity__c = consumableItem.Quantity));
                  
           }else
           {
                        system.debug('inelse');
                consumableItem.LineCost = c.Quantity*c.consu.CostPrice__c.setscale(2);
                consumableItem.lineCostStng = consumableItem.LineCost.toPlainString();
                consumableItem.Quantity = c.Quantity;
                upsertlist.add(new Consumable_Items__c( Request__c = conReq.Id, Item_Requested__c = c.consu.Id,  Quantity__c = c.Quantity));
           }
           system.debug('Sugu upsertlist@@@@@-->'+upsertlist);
           c.isSelected = false;
           previousAddedItems.put(consumableItem.consu.Id,consumableItem);
           system.debug('Sugu previousAddedItems-->'+previousAddedItems);
           
           c.Quantity = 1;
        }   
    }
    
    count1 +=upsertlist.size();
    system.debug('New limit--->'+count1);
    if(count1>201)
    {
    	  util.setErrorMsg(true, 'The Maximum number of items allowed on one order is 200 (you are ordering '+count+' items). So please submit this order and create a new one for additional items.');
          return null;
    }
    
    BasketTotal =0.0;
    //BasketTotal += TempBasketTotal ;
    if(upsertlist.size()>0)
    {
        try{
        upsert upsertlist;
        }catch(Exception e)
        {
            if(e.getmessage().Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
            list<string> error = e.getmessage().split(',');
            util.setErrorMsg(true, error[1]);
            }else
            util.setErrorMsg(true, e.getmessage());
            return null;
        }
        //checkOutBtn = true;
    }
    for(Consumable_Items__c c: upsertlist)
    {
        if(!ItemConsMap.containskey(c.Item_Requested__c))
        ItemConsMap.put(c.Item_Requested__c,c);
    }
    selectedConsumables = previousAddedItems.values();
    system.debug('@@@@@-->'+previousAddedItems);
    for(genericClass g : selectedConsumables)
    {
        BasketTotal += g.LineCost;
    }
    BasketTotal.setscale(2);
    if(BasketTotal>empDetails.District__r.Authorisation_Value__c)
    redValue = true;    
    BasketTotalString = BasketTotal.toplainstring();
    count = selectedConsumables.size();
    bln_info = false;
    checkOutBtn= true;
    return null;
  }
  
  /*public class Consumable
  {
      public Boolean isSelected {get;set;}
      public Consumables__c con {get;set;}
      public integer Quantity {get;set;}
      public double LineCost {get;set;}
      public Consumable(Consumables__c c)
      {
          con =c;
          isSelected = false;
          Quantity = 1;
          
      }
  }*/
  
  public void toggleMode()
  {
  	system.debug('Error-->'+mode);
      if (bln_mode)
      {
        populateFavoriteList();
        mode = 2;
        bln_mode= false;
      }else
      {
      	 runQuery();
      	 bln_mode = true;
     	 mode = 1;
      }
      bln_info = false;
  }
  
  public class genericClass
  {
    
    public integer Quantity {get;set;}
    public decimal LineCost {get;set;}
    public string lineCostStng{get;set;}
    public boolean isSelected {get;set;}
    public Consumables__c consu{get;set;}
    public boolean isalreadyfav {get;set;}
    public string Static_Resource_Location {get;set;}
    public string resourceName {get;set;}
    public string url{get;set;}
    public genericClass(sobject sobj, string url)
    {
        
            consu = new Consumables__c();
            this.url = url;
            consu = (Consumables__c)sobj;
            if(consu.Static_Resource_Location__c==null)
            Static_Resource_Location = 'Consumables_1';
            else
            Static_Resource_Location = consu.Static_Resource_Location__c;
            
            if(consu.Image_Location__c == null)
            resourceName = 'Consumables_1';
            else
            resourceName = consu.Image_Location__c;
            
            isSelected = false;
            Quantity = 1;
        
        
        }
  }
  
  
  
 
  public PageReference continue_Btn()
  {
         if(conReq.Id != null)
         {
             system.debug('@@@@@@@@@@@@@@@'+conReq.Id);
             PageReference pageRef = new PageReference('/apex/copyConsumableOrder?crId='+conReq.Id+'&Bas=t');
             pageRef.setRedirect(true);
             return pageRef;
         }else
         {
                util.setErrorMsg(true, 'Please Add Items to CheckOut.');
                return null;
         }
                
  }
  
  
  
  public void Discard()
  {
        if(conReq != null)
        {
                delete conReq;
        }
        selectedConsumables.clear();
       
        conReq =  null;
        previousAddedItems.clear();
        ItemConsMap.clear();
        BasketTotal = 0.0;
        BasketTotalString = '0.00';
        count = 0;
        checkOutBtn = false;
             
  }
  
  public Boolean hasNext  
    {  
        get  
        {  
            return stdcon.getHasNext();  
        }  
        set;  
    }  
   
    //Boolean to check if there are more records before the present displaying records  
    public Boolean hasPrevious  
    {  
        get  
        {  
            return stdcon.getHasPrevious();  
        }  
        set;  
    }  
   
    //Page number of the current displaying records  
    public Integer pageNumber  
    {  
        get  
        {  
            return stdcon.getPageNumber();  
        }  
        set;  
    }  
  
    //Returns the previous page of records  
    public void previous()  
    {  
        stdcon.previous();  
    }  
   
    //Returns the next page of records  
    public void next()  
    {  
        stdcon.next();  
    }
    
}