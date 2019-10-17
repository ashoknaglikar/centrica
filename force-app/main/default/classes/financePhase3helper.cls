// helper class to hold helper methods for barcalays phase 3

public class financePhase3helper {
    
    public final static date financeLaunchDate = date.Valueof(system.label.Finance2019StartDate);
    
    public final static map<string, integer> dayWeekMap = new Map<string, integer> {'Mon' =>1 , 'Tue' => 2, 'Wed' => 3, 'Thu' => 4, 'Fri' => 5 , 'Sat'=> 6 , 'Sun' => 7};
    
    public static void nextLenderWithFinanceProduct(Finance_Application__c fApp)
    {
        system.debug('Before Derving the lender -->'+fApp);
        /*`
        string[] data = fApp.Finance_Options__c.split('-');
        
        if(data[0].trim()!= '0%')
        {
            // IBC
            return ([Select Id, Name, Lender__c, ApplicationPer__c from Finance_Product__c where Lender__c = 'Barcalys' && Finance_Option__c = :fApp.Finance_Options__c);
        }else
        */
        
       
        map<string, decimal> lenderPropotion = new map<string, decimal>();
        map<string, Finance_Product__c> lenderProductMap = new map<string, Finance_Product__c>();
        
        for(Finance_Product__c lender  : [Select Id, Name, Lender__c, ApplicationPer__c, Payment_Options__c, Selling_Type__c from Finance_Product__c where Finance_Options__c = :fApp.Finance_Options__c and New_Product__c = true order by Lender__c])
        {
            lenderPropotion.put(lender.Lender__c, lender.ApplicationPer__c);
            lenderProductMap.put(lender.Lender__c, lender);
            
        }
        string lenderName = 'Barclays';
        system.debug(lenderPropotion);
        system.debug(lenderProductMap);
        
        if((fApp.Email__c == null && fApp.Confirm_Email__c == null )||fApp.Type_of_Finance__c == 'Manual Finance')
        {
            lenderName = 'Honeycomb';
        }else
        {
        
            //IFC
            integer totalCount = 0;
            list<aggregateresult> aggr = [Select Count(Id)c,  Lender_Text__c  from Finance_Application__c where Valid_New_Application__c = true and Finance_Product__r.New_Product__c = true and Lender_Text__c != null Group by Lender_Text__c  ];
            for(aggregateresult a: aggr)
            {
                totalCount += integer.valueof(a.get('c'));
            }
            
            if(totalCount >0)
            {
                for(aggregateresult a: aggr)
                {
                    decimal percentRequired = lenderPropotion.get(string.valueof(a.get('Lender_Text__c')))*100;
                    if(percentRequired>0)
                    {
                        decimal percentUptoNow = (integer.valueof(a.get('c'))/percentRequired)*100;
                        if(percentUptoNow<=percentRequired)
                        {
                            lenderName =  (string.valueof(a.get('Lender_Text__c')));
                            
                        }
                    }
                }
                
            }else if(lenderProductMap.size()>0)
            {
                
                Datetime dt = System.now();
                string dayOfWeek = dt.format('EEE');
                
                //if(math.mod(dayWeekMap.get(dayOfWeek),2)>0)
                integer i = math.mod(dayWeekMap.get(dayOfWeek),lenderProductMap.size());
                lenderName =  new list<string>(lenderProductMap.keySet())[i];
               
            }
        }
        
        if(lenderProductMap.containskey(lenderName))
        {
        fApp.Finance_Product__c = lenderProductMap.get(lenderName).Id;
        fApp.Payment_Options__c = lenderProductMap.get(lenderName).Payment_Options__c;
        fApp.Selling_Type__c = lenderProductMap.get(lenderName).Selling_Type__c;
        }
        if(fApp.Finance_Product__c == null)
        fApp.adderror('No Valid Finance Products retruned');
       
                
    }
    
    public static string decidePhaseOfApplication()
    {
        if(system.now()>=financeLaunchDate)
        return 'phase3';
        else 
        return 'phase2';
    }

}