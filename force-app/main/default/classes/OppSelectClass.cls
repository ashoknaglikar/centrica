/* BGB_CTS: OppSelectClass:
   Description : Used to locate selected opportunity objects form Opportunity list.
   This class is used in ExistingOppComponentController
   Created : 13/10/09 :By Aruna
*/
  
public class OppSelectClass{

    public boolean oppSelected ; //{get; set;}    
    public Opportunity opp; // {get; set;}
    
    public void setOppSelected(boolean oppSelected){
        this.oppSelected=oppSelected;
    }
    public Boolean getOppSelected(){
        return this.oppSelected;
    }
    
    public void setOpp(Opportunity opp){
        this.opp=opp;
    }
    public Opportunity getOpp(){
        return this.opp;
    }

        
}