public class ProductSearchController{
     /*---------------------PUBLIC PROPERTIES-------------------------------*/
    public string searchText{get; set;}
    public String Err_msg{get; set;}
    public List<Product2> ProductList{get; set;}
    public Product2 NewProduct{get; set;}
    public Boolean searchMode{get; set;}
     
     
    /*---------------------CONSTRUCTOR-------------------------------------*/
    //Default constructor
    public ProductSearchController(ApexPages.StandardController controller) 
    {
        ProductList= new List<Product2>();
        getAllProducts();
        searchMode = true;
    }
    
    /*---------------------Refresh------------------------------------------*/
    public void onClickRefresh(){
            ProductList= new List<Product2>();
            getAllProducts();
            searchText=null;
            searchMode = true;   
    }
    
    /*---------------------EVENTS------------------------------------------*/
    //Event to handle click event of "Go" button
    public void SearchProduct()
    {
        findProduct();
    }
        
    
    /*---------------------PRIVATE METHODS---------------------------------*/
    //Searches for an product
    private void findProduct() 
    {
        String searchText_dup = searchText;
        
        if(searchText != null)
        {
            err_msg=null;
            searchText_dup=searchText_dup.replace('*','');
            ProductList.clear();
            if(searchText_dup.length()>1)
            {
                try
                {
                    searchText = '';
                    searchText += searchText_dup;
                    searchText += '*';
                    ProductList = (List<Product2>)[FIND :searchText IN ALL FIELDS RETURNING Product2 (ID,Name,ProductCode,Description,Family) LIMIT 300][0];
                }
                catch(Exception e){}
                if(ProductList.size()==0){
                        Product2 obj = new Product2();
                        obj.Name='No Matches Found';
                        ProductList.add(obj);
                }
            }
            else
            {
                
                Product2 obj = new Product2();
                obj.Name='Please Enter text to search';
                ProductList.add(obj);    
            }            
        }
    }
    
    //Gets all products
    private void getAllProducts()
    {
        ProductList= [select ID,Name,ProductCode,Description,Family from Product2 limit 50];
    }
}