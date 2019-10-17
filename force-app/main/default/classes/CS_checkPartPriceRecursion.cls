public with sharing class CS_checkPartPriceRecursion {
    private static boolean run = true;
    
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
    //this method is used int tests only
    public static void setTrue(){
        run = true;
    }
}