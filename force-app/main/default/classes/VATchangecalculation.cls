public with sharing class VATchangecalculation {
    
    // PRB00010300 cding starts
    public static void CalculateNewAndOldVAT(Map<String,Decimal> map_VAT){
        Decimal NewVat1;
        Decimal NewVat4;
        Decimal OldVat1;
        Decimal OldVat4;
        String overwritestring = System.Label.VAT_Change_Date;
        Date overwrite = date.valueOf(overwritestring);
        /************************************   Fetching the all the Active VAT code   *****************************************
        ************************************************************************************************************************/
        List<VAT_Codes__c> lstVAT = [Select Vat_Code_1_Value__c,Vat_Code_4_Value__c,VAT_Code_1__c,VAT_Code_4__c,Status__c,start_date__c,
                                    end_date__c from VAT_Codes__c];
        for(VAT_Codes__c objvat:lstVAT){
            if(objvat.start_date__c >=overwrite){
                NewVat1 = objvat.Vat_Code_1_Value__c;
                NewVat4 = objvat.Vat_Code_4_Value__c;
            }else if (objvat.start_date__c <overwrite){
                OldVat1 = objvat.Vat_Code_1_Value__c;
                OldVat4 = objvat.Vat_Code_4_Value__c;
            }
       }
       map_VAT.put('NewVat1',NewVat1);
       map_VAT.put('NewVat4',NewVat4);
       map_VAT.put('OldVat1',OldVat1);
       map_VAT.put('OldVat4',OldVat4);
       
       System.debug('VATchangecalculation +++++ (After) NewVat1-->'+map_VAT.get('NewVat1'));
       System.debug('VATchangecalculation +++++ (After) NewVat4-->'+map_VAT.get('NewVat4'));
       System.debug('VATchangecalculation +++++ (After) OldVat1-->'+map_VAT.get('OldVat1'));
       System.debug('VATchangecalculation +++++ (After) OldVat4-->'+map_VAT.get('OldVat4'));
       
    }
    // PRB00010300 coding ends
    
    public static void updatePCN(job__c j, Payment_Collection__c obj_Payment,Map<String,Decimal> map_VAT){
        /*
        *******************************   Defining all the vatiables so that it can be used in whole method.
        
        */
        Double Temp = 0.0;
        Double temp1 = 0.0;
        Double tasprem = 0.0;
        Double taspadd = 0.0;
        Double taspdis =0.0;
        Double aspadd = j.ASP_Addition__c;
        Double asprem = j.ASP_Removal__c;
        Double aspdis = j.ASP_Discount__c;
        Double frozenBM = j.Original_Quote_Value__c;
        Double Quotenet = 0.0;
        Double VAT1 = j.VAT1_Amount__c;
        Double VAT4 = j.VAT2_Amount__c;
        Double newnetcontract = j.New_Net_Contract_Price__c;
        Decimal pricemis = j.Price_Mismatch__c;
        Double finance = j.Financed_Amount__c;
        Double balance = j.BalanceOutstanding__c;
        Double newbalance = 0.0;
        Decimal indiffe = j.In_Difference_Value__c;
        Date installdate = j.Installation_Date__c;
        Double Allwance = j.discountsTotalOnPricing__c;
        Double sumpayment = j.Sum_of_Payments__c;
        String overwritestring = System.Label.VAT_Change_Date;
        Date quotecreated = j.closeDate__c;
        Date overwrite = date.valueOf(overwritestring);
        string billperiod = j.VAT_Override_Period__c;
        boolean oldquote = false;
        /************************************   Fetching the all the Active VAT code   *****************************************
        ************************************************************************************************************************/
        
        //commmented for too many soql PR - PRB00010300 by BGSAMS
        /*List<VAT_Codes__c> lstVAT = [Select Vat_Code_1_Value__c,Vat_Code_4_Value__c,VAT_Code_1__c,VAT_Code_4__c,Status__c,start_date__c,
                                    end_date__c from VAT_Codes__c];
        for(VAT_Codes__c objvat:lstVAT){
            if(objvat.start_date__c >=overwrite){
                NewVat1 = objvat.Vat_Code_1_Value__c;
                NewVat4 = objvat.Vat_Code_4_Value__c;
            }else if (objvat.start_date__c <overwrite){
                OldVat1 = objvat.Vat_Code_1_Value__c;
                OldVat4 = objvat.Vat_Code_4_Value__c;
            }
       }
       System.debug('NewVat1-->'+NewVat1);
       System.debug('NewVat4-->'+NewVat4);
       System.debug('OldVat1-->'+OldVat1);
       System.debug('OldVat4-->'+OldVat4);*/
       
       // PRB00010300 coding starts
       Decimal NewVat1 = map_VAT.get('NewVat1');
       Decimal NewVat4 = map_VAT.get('NewVat4');
       Decimal OldVat1 = map_VAT.get('OldVat1');
       Decimal OldVat4 = map_VAT.get('OldVat4');
       
       System.debug('VATchangecalculation After conversion ******************** NewVat1-->'+NewVat1);
       System.debug('VATchangecalculation After conversion ******************** NewVat4-->'+NewVat4);
       System.debug('VATchangecalculation After conversion ******************** OldVat1-->'+OldVat1);
       System.debug('VATchangecalculation After conversion ******************** OldVat4-->'+OldVat4);
       // PRB00010300 coding ends
       /******************************************* END:  Assigned the VAT to MAP  ***************************************************/
       system.debug('quotecreated--->'+quotecreated);
       
       if(j.Job_Type__c=='GDF'|| j.Job_Type__c=='Green Deal')
         {try{
           system.debug('******j.Job_Type__c'+j.Job_Type__c);         
           Green_Deal_Reconsilliation__c gd= [select id,CC_Amount__c,CHI_UniqueId__c,Opportunity__c,Sales_Appointment__c,Green_Deal_Appointment__c from Green_Deal_Reconsilliation__c where Job__c =:j.id];
           system.debug('******gd'+gd);
           
           obj_Payment.Customer_Contribution__c=gd.CC_Amount__c;
           
           system.debug('******gd.CC_Amount__c'+gd.CC_Amount__c);
           system.debug('******obj_Payment.Customer_Contribution__c'+obj_Payment.Customer_Contribution__c);
           //update obj_Payment;
         	}
         	catch(Exception e)
         	{
         		
         	}
         }
       if(quotecreated <= overwrite){
        oldquote = true;
       }
       if(oldquote){
        system.debug('Inside Old Quote');
        

            if(billperiod != 'Before 04/01'){
                system.debug('overwrite-->'+overwrite);
                system.debug('installdate-->'+installdate);
                if(installdate >= overwrite){
                

        /***************************************  Calculating the Quote value based on 20% VAT because quote is having the price   ****
        ************************************** with 17.5% VAT. We need to update the PCN with the new Value  *************************/
                    Temp = (VAT1/(1+OldVat1)).setscale(2); 
                    system.debug('Temp-->'+temp);
                    VAT1 = (Temp + (Temp*NewVat1)).setscale(2);
                    system.debug('oldVAT1-->'+VAT1);
                    pricemis = pricemis.setscale(2);
                    system.debug('Old IS diff-->'+indiffe);
                    temp1 = (indiffe/(1+OldVat1)).setscale(2); 
                    indiffe = (temp1 + (temp1*NewVat1)).setscale(2);
                    system.debug('new IS diff-->'+indiffe);
                        if(VAT1 >0){
                            if(pricemis !=null && pricemis!=0.00){
                                if(indiffe !=null && indiffe!=0.00){
                                    VAT1 = VAT1 + pricemis + indiffe;
                                }else{
                                    VAT1 = VAT1 + pricemis;
                                }
                            }else if (indiffe !=null && indiffe!=0.00){
                                 VAT1 = VAT1 + indiffe;
                            }else{
                                  VAT1=   VAT1 ;
                            }
                        }
                        System.debug('newVAT1-->'+VAT1);
                        VAT4 = VAT4;
                        FrozenBM = VAT1+VAT4;
                        System.debug('FrozenBM-->'+FrozenBM);
                     if(aspadd!=null && aspadd >0.00){
                            taspadd = (aspadd/(1+OldVat1)).setscale(2);
                            aspadd = taspadd+(taspadd*NewVat1).setscale(2);
                      }
                      if(asprem!=null && asprem >0.00){
                        tasprem = (asprem/(1+OldVat1)).setscale(2);
                        asprem = tasprem+(tasprem*NewVat1).setscale(2);
                        }
                    if(aspdis!=null && aspdis <0.00){
                        taspdis = (aspdis/(1+OldVat1)).setscale(2);
                        aspdis = taspdis+(taspdis*NewVat1).setscale(2);
                        }
                    Quotenet = (FrozenBM +aspdis)-(Allwance);
                    System.debug('Quotenet-->'+Quotenet);
                    if(finance !=null && finance>0.00){
                        newbalance = Quotenet- (finance +sumpayment) ;
                    }else{
                    newbalance = Quotenet - sumpayment;
                    }
    /******************   All the calulcation has been completed in Above block; now we are updating the PCN    *****************/
                    System.debug('newbalance-->'+newbalance);
                    obj_Payment.Opportunity__c=j.CHI_Lead__c;
                    obj_Payment.Account__c=j.Account_Id__c;
                    obj_Payment.ContactAddress__c=j.Address__c;
                    obj_Payment.Job__c=j.Id;
                    obj_Payment.ContactName__c=j.Customer_Name__c;
                    obj_Payment.Contact__c=j.Primary_Contact__c;
                    obj_Payment.Job_Special_ID__c = j.Id + 'PC';
                    obj_Payment.Balance_Outstanding__c=newbalance;
                    obj_Payment .District__c = j.District_Name__c;
                    obj_Payment .Job_Installation_Date__c = j.Installation_Date__c;
                    obj_Payment.Installer_Name__c=j.InstallerAliasName__c;
                    obj_Payment.Sum_of_Payments__c = sumpayment;
                    obj_Payment.ASP_Addition__c = j.ASP_Addition__c;
                    obj_Payment.ASP_Discount__c = j.ASP_Discount__c;
                    obj_Payment.ASP_Removal__c  = j.ASP_Removal__c;
                    obj_Payment.Original_Quote_Value__c = newnetcontract;
                    obj_Payment.Quote_Nett_Amount__c = Quotenet;
                    obj_Payment.Payment_Collection_Status__c='Pending';
                    obj_Payment.Financed_Amount__c = finance;
                    obj_Payment.discountsTotalOnPricing__c = Allwance;  
                    System.debug('@@@@@@@@@change1@@@@@@@@@@@@@@@');
                }
      /*******************  IF installation date is less than 4/01/2011 then PCN will be caluculated with normal Process
      ********************      ***********************************************************/
                else{
                    System.debug('INside install Else');
                    obj_Payment.Opportunity__c=j.CHI_Lead__c;
                    obj_Payment.Account__c=j.Account_Id__c;
                    obj_Payment.ContactAddress__c=j.Address__c;
                    obj_Payment.Job__c=j.Id;
                    obj_Payment.ContactName__c=j.Customer_Name__c;
                    obj_Payment.Contact__c=j.Primary_Contact__c;
                    obj_Payment.Job_Special_ID__c = j.Id + 'PC';
                    obj_Payment.Balance_Outstanding__c=j.BalanceOutstanding__c;
                    obj_Payment.District__c = j.District_Name__c;
                    obj_Payment.Job_Installation_Date__c = j.Installation_Date__c;
                    obj_Payment.Installer_Name__c=j.InstallerAliasName__c;
                    obj_Payment.Sum_of_Payments__c = j.Sum_of_Payments__c;
                    obj_Payment.ASP_Addition__c = j.ASP_Addition__c;
                    obj_Payment.ASP_Discount__c = j.ASP_Discount__c;
                    obj_Payment.ASP_Removal__c  = j.ASP_Removal__c;
                    obj_Payment.Original_Quote_Value__c = j.Original_Quote_Value__c;
                    obj_Payment.Quote_Nett_Amount__c = j.Quote_Nett_Amount__c;
                    obj_Payment.Payment_Collection_Status__c='Pending';
                    obj_Payment.Financed_Amount__c = j.Financed_Amount__c;
                    obj_Payment.discountsTotalOnPricing__c = j.discountsTotalOnPricing__c;
                    System.debug('@@@@@@@@@change2@@@@@@@@@@@@@@@'); 
                }
          }
      /*******************  IF user has selected that thay will bill the customer with 17.5% VAT even if Installation date is after
      ********************  4/1/2011 then value will remain same.      ***********************************************************/
         else{
            System.debug('INside old Else');
            obj_Payment.Opportunity__c=j.CHI_Lead__c;
                obj_Payment.Account__c=j.Account_Id__c;
                obj_Payment.ContactAddress__c=j.Address__c;
                obj_Payment.Job__c=j.Id;
                obj_Payment.ContactName__c=j.Customer_Name__c;
                obj_Payment.Contact__c=j.Primary_Contact__c;
                obj_Payment.Job_Special_ID__c = j.Id + 'PC';
                obj_Payment.Balance_Outstanding__c=j.BalanceOutstanding__c;
                obj_Payment.District__c = j.District_Name__c;
                obj_Payment.Job_Installation_Date__c = j.Installation_Date__c;
                obj_Payment.Installer_Name__c=j.InstallerAliasName__c;
                obj_Payment.Sum_of_Payments__c = j.Sum_of_Payments__c;
                obj_Payment.ASP_Addition__c = j.ASP_Addition__c;
                obj_Payment.ASP_Discount__c = j.ASP_Discount__c;
                obj_Payment.ASP_Removal__c  = j.ASP_Removal__c;
                obj_Payment.Original_Quote_Value__c = j.Original_Quote_Value__c;
                obj_Payment.Quote_Nett_Amount__c = j.Quote_Nett_Amount__c;
                obj_Payment.Payment_Collection_Status__c='Pending';
                obj_Payment.Financed_Amount__c = j.Financed_Amount__c;
                obj_Payment.discountsTotalOnPricing__c = j.discountsTotalOnPricing__c;
                System.debug('@@@@@@@@@change3@@@@@@@@@@@@@@@');
         }
     }
     /*******************  IF Quote data comes after 4/01/2010 then PCN calculation will follow the normal calcualtion
      ********************       ***********************************************************/
     else{
            System.debug('INside new Else');
           obj_Payment.Opportunity__c=j.CHI_Lead__c;
                obj_Payment.Account__c=j.Account_Id__c;
                obj_Payment.ContactAddress__c=j.Address__c;
                obj_Payment.Job__c=j.Id;
                obj_Payment.ContactName__c=j.Customer_Name__c;
                obj_Payment.Contact__c=j.Primary_Contact__c;
                obj_Payment.Job_Special_ID__c = j.Id + 'PC';
                obj_Payment.Balance_Outstanding__c=j.BalanceOutstanding__c;
                obj_Payment.District__c = j.District_Name__c;
                obj_Payment.Job_Installation_Date__c = j.Installation_Date__c;
                obj_Payment.Installer_Name__c=j.InstallerAliasName__c;
                obj_Payment.Sum_of_Payments__c = j.Sum_of_Payments__c;
                obj_Payment.ASP_Addition__c = j.ASP_Addition__c;
                obj_Payment.ASP_Discount__c = j.ASP_Discount__c;
                obj_Payment.ASP_Removal__c  = j.ASP_Removal__c;
                obj_Payment.Original_Quote_Value__c = j.Original_Quote_Value__c;
                obj_Payment.Quote_Nett_Amount__c = j.Quote_Nett_Amount__c;
                obj_Payment.Payment_Collection_Status__c='Pending';
                obj_Payment.Financed_Amount__c = j.Financed_Amount__c;
                obj_Payment.discountsTotalOnPricing__c = j.discountsTotalOnPricing__c;  
                System.debug('@@@@@@@status@@@@@@@@@'+j.Payment_Collection_Status__c);
                System.debug('@@@@@@@@@change4@@@@@@@@@@@@@@@');
     }
  }
  /**********************  Method end :-   Update PCN from JOb while replanning        *******************************************/
    public static void updatePCNASP(Opportunity o, Payment_Collection__c obj_Payment){
    /*
        *******************************   Defining all the vatiables so that it can be used in whole method.
        
        */
        Double VAT4 = o.VAT2_Amount__c;
        Decimal pricemis = o.Price_Mismatch__c;
        Date quotecreated = o.closeDate__c;
        Double finance = o.Finance_Amount__c;
        Double balance = o.Balance_Outstanding__c;
        Double newbalance = 0.0;
        Decimal indiffe = o.InDifference_Value__c;
        Date installdate = obj_Payment.Job_Installation_Date__c;
        Double Allwance = o.discountsTotalOnPricing__c;
        Double sumpayment = o.Sum_of_Payments__c;
        String overwritestring = System.Label.VAT_Change_Date;
        Date overwrite = date.valueOf(overwritestring);
        Double newnetcontract = o.New_Net_Contract_Price__c;
        Decimal NewVat1;
        Decimal NewVat4;
        Decimal OldVat1;
        Decimal OldVat4;
        Double tasprem = 0.0;
        Double taspadd = 0.0;
        Double taspdis =0.0;
        Double Temp = 0.0;
        Double temp1 = 0.0;
        Double VAT1 = o.VAT1_Amount__c;
        Double aspadd = o.ASP_Addition__c;
        Double asprem = o.ASP_Removal__c;
        Double aspdis = o.ASP_Discount__c;
        Double Quotenet = 0.0;
        boolean oldquote = false;
        string billperiod = o.Bill_Period__c;
        Double frozenBM = o.Original_Quote_Value__c;
        /************************************   Fetching the all the Active VAT code   *****************************************
        ************************************************************************************************************************/
        List<VAT_Codes__c> lstVAT = [Select Vat_Code_1_Value__c,Vat_Code_4_Value__c,VAT_Code_1__c,VAT_Code_4__c,Status__c,start_date__c,
                                    end_date__c from VAT_Codes__c];
        for(VAT_Codes__c objvat:lstVAT){
            if(objvat.start_date__c >=overwrite){
                NewVat1 = objvat.Vat_Code_1_Value__c;
                NewVat4 = objvat.Vat_Code_4_Value__c;
                
            }else if (objvat.start_date__c <overwrite){
                OldVat1 = objvat.Vat_Code_1_Value__c;
                OldVat4 = objvat.Vat_Code_4_Value__c;
            }
       }
       /******************************************* END:  Assigned the VAT to MAP  ***************************************************/
       system.debug('installdate-->'+installdate);
       system.debug('overwrite-->'+overwrite);
       system.debug('quotecreated-->'+quotecreated);
      
      Green_Deal_Reconsilliation__c gd = new Green_Deal_Reconsilliation__c();
      try
      {
        gd= [select id,CC_Amount__c,CHI_UniqueId__c,Opportunity__c,Sales_Appointment__c,Green_Deal_Appointment__c from Green_Deal_Reconsilliation__c where Opportunity__c =:o.id];
        if(gd.CC_Amount__c!=null)
        obj_Payment.Customer_Contribution__c=gd.CC_Amount__c;
      }Catch (Exception e){}
      
      
       if(quotecreated <= overwrite){
        oldquote = true;
       }
       if(oldquote){
        system.debug('Inside Old Quote');
        if(billperiod != 'Before 04/01'){
            if(installdate >= overwrite){
        /***************************************  Calculating the Quote value based on 20% VAT because quote is having the price   ****
        ************************************** with 17.5% VAT. We need to update the PCN with the new Value  *************************/
                    Temp = (VAT1/(1+OldVat1)).setscale(2); 
                    system.debug('Temp-->'+temp);
                    VAT1 = Temp + (Temp*NewVat1).setscale(2);
                    system.debug('oldVAT1-->'+VAT1);
                    pricemis = pricemis.setscale(2);
                    system.debug('Old IS diff-->'+indiffe);
                    temp1 = (indiffe/(1+OldVat1)).setscale(2); 
                    indiffe = (temp1 + (temp1*NewVat1)).setscale(2);
                    system.debug('new IS diff-->'+indiffe);
                    if(VAT1 >0){
                        if(pricemis !=null && pricemis!=0.00){
                            if(indiffe !=null && indiffe!=0.00){
                                VAT1 = VAT1 + pricemis + indiffe;
                            }
                            else{
                                VAT1 = VAT1 + pricemis;
                            }
                        }else if (indiffe !=null && indiffe!=0.00){
                            VAT1 = VAT1 + indiffe;
                        }
                        else{
                            VAT1=   VAT1 ;
                        }
                    }
                    System.debug('newVAT1-->'+VAT1);
                
                    VAT4 = VAT4;
                    FrozenBM = VAT1+VAT4;
                    System.debug('FrozenBM-->'+FrozenBM);
                    if(aspadd!=null && aspadd >0.00){
                    taspadd = (aspadd/(1+OldVat1)).setscale(2);
                    System.debug('taspadd-->'+taspadd);
                    aspadd = taspadd+(taspadd*NewVat1).setscale(2);
                    }
                    System.debug('aspadd-->'+aspadd);
                    if(asprem!=null && asprem >0.00){
                        tasprem = (asprem/(1+OldVat1)).setscale(2);
                        System.debug('tasprem-->'+tasprem);
                        asprem = tasprem+(tasprem*NewVat1).setscale(2);
                    }
                    if(aspdis!=null && aspdis >0.00){
                        taspdis = (aspdis/(1+OldVat1)).setscale(2);
                        aspdis = taspdis+(taspdis*NewVat1).setscale(2);
                    }
                    
                    Quotenet = (FrozenBM+aspdis) -(Allwance);
                    System.debug('Quotenet-->'+Quotenet);
                    if(finance !=null && finance>0.00){
                        newbalance = Quotenet- (finance +sumpayment) ;
                    }else{
                    newbalance = Quotenet - sumpayment;
                    }
                    /******************   All the calulcation has been completed in Above block; now we are updating the PCN    *****************/
                    System.debug('newbalance-->'+newbalance);
                    obj_Payment.Balance_Outstanding__c = newbalance;
                    obj_Payment.ASP_Addition__c = o.ASP_Addition__c;
                    obj_Payment.ASP_Discount__c = o.ASP_Discount__c;
                    obj_Payment.ASP_Removal__c = o.ASP_Removal__c;
                    obj_Payment.Sum_of_Payments__c = o.Sum_of_Payments__c;
                    obj_Payment.Original_Quote_Value__c = newnetcontract;
                    obj_Payment.Quote_Nett_Amount__c = Quotenet;
                    obj_Payment.Financed_Amount__c = o.Finance_Amount__c;
                    obj_Payment.discountsTotalOnPricing__c = o.discountsTotalOnPricing__c;
                    obj_Payment.BGS_Payment_Reference_Num__c = o.Payment_Reference_Number__c;
                }
     /*******************  IF installation date is less than 4/01/2011 then PCN will be caluculated with normal Process
      ********************      ***********************************************************/
                else{
                    obj_Payment.Balance_Outstanding__c = o.Balance_Outstanding__c;
                    obj_Payment.ASP_Addition__c = o.ASP_Addition__c;
                    obj_Payment.ASP_Discount__c = o.ASP_Discount__c;
                    obj_Payment.ASP_Removal__c = o.ASP_Removal__c;
                    obj_Payment.Sum_of_Payments__c = o.Sum_of_Payments__c;
                    obj_Payment.Original_Quote_Value__c = o.Original_Quote_Value__c;
                    obj_Payment.Quote_Nett_Amount__c = o.Amount;
                    obj_Payment.Financed_Amount__c = o.Finance_Amount__c;
                    obj_Payment.discountsTotalOnPricing__c = o.discountsTotalOnPricing__c;
                    obj_Payment.BGS_Payment_Reference_Num__c = o.Payment_Reference_Number__c;
                }
            }
         /*******************  IF user has selected that thay will bill the customer with 17.5% VAT even if Installation date is after
      ********************  4/1/2011 then value will remain same.      ***********************************************************/
         else{
            obj_Payment.Balance_Outstanding__c = o.Balance_Outstanding__c;
            obj_Payment.ASP_Addition__c = o.ASP_Addition__c;
            obj_Payment.ASP_Discount__c = o.ASP_Discount__c;
            obj_Payment.ASP_Removal__c = o.ASP_Removal__c;
            obj_Payment.Sum_of_Payments__c = o.Sum_of_Payments__c;
            obj_Payment.Original_Quote_Value__c = o.Original_Quote_Value__c;
            obj_Payment.Quote_Nett_Amount__c = o.Amount;
            obj_Payment.Financed_Amount__c = o.Finance_Amount__c;
            obj_Payment.discountsTotalOnPricing__c = o.discountsTotalOnPricing__c;
            obj_Payment.BGS_Payment_Reference_Num__c = o.Payment_Reference_Number__c;
         }
            
       }
        /*******************  IF Quote data comes after 4/01/2010 then PCN calculation will follow the normal calcualtion
      ********************       ***********************************************************/
       else{
            obj_Payment.Balance_Outstanding__c = o.Balance_Outstanding__c;
            obj_Payment.ASP_Addition__c = o.ASP_Addition__c;
            obj_Payment.ASP_Discount__c = o.ASP_Discount__c;
            obj_Payment.ASP_Removal__c = o.ASP_Removal__c;
            obj_Payment.Sum_of_Payments__c = o.Sum_of_Payments__c;
            obj_Payment.Original_Quote_Value__c = o.Original_Quote_Value__c;
            obj_Payment.Quote_Nett_Amount__c = o.Amount;
            obj_Payment.Financed_Amount__c = o.Finance_Amount__c;
            obj_Payment.discountsTotalOnPricing__c = o.discountsTotalOnPricing__c;
            obj_Payment.BGS_Payment_Reference_Num__c = o.Payment_Reference_Number__c;
       }
        
   }
  /**********************  Method end :-   Update PCN from CHI Lead while ASP        *******************************************/
    
   
}