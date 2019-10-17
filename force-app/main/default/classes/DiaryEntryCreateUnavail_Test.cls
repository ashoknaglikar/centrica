//This is test class for DiaryEntryCreateUnavail apex class
@isTest
public class DiaryEntryCreateUnavail_Test
{

static Employee__c firstEmp;
 static Week__c week;
 static  Diary_Entry__c dairyEntry;
 static  Shift_Pattern__c sPattern ;
 static  Supplier__c supplier;
 static  Region__c testReg;
 static  District__c testDistrict;      
 public static void createData(){
  
  testReg=new Region__c(Name = 'Test northeast', Code__c = '001', Type__c = 'Sales');  
  insert  testReg;
  testDistrict = new District__c(Type__c='Sales', Name='SalesDistrict', Code__c='xxxxxxxx',region__c=testReg.id);
  insert testDistrict;   
  supplier = new Supplier__c(Supplier_Num__c = '111b');
  insert supplier;
  firstEmp  = new Employee__c(Name = 'Test111', First_Name__c = 'unavailable1', Last_Name__c = 'scenario1', 
                                                                              Pool_Diary__c = false, Phone_No__c = '07222222223', 
                                                                              Employee_Number__c = '1234995', Resource_Type__c = 'Installer',Supplier__c=Supplier.id);
       
  Database.insert(firstEmp);
        
  week = new Week__c(Employee__c=firstEmp.Id,Week_Commencing__c=system.today());
  insert week;
  dairyEntry= new Diary_Entry__c(week__c = week.Id, Start__c = datetime.now(), End__c = datetime.now().addhours(1),RecordtypeId= RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability'),Sub_Type__c='NWD - Working');
  insert dairyEntry;
}
public static testMethod void testCreateUnavail()
  {
  createData();
  Test.startTest();
  PageReference pageRef = Page.DiaryEntryCreateUnavail ;
  Test.setCurrentPage(pageRef);

  apexpages.currentpage().getparameters().put('entryId',dairyEntry.id);
  apexpages.currentpage().getparameters().put('area',testDistrict.id);
  ApexPages.StandardController controller=new ApexPages.StandardController(dairyEntry);
  DiaryEntryCreateUnavail dEntry=new DiaryEntryCreateUnavail(controller);
  dEntry.CreateUnavailability();
  Test.stopTest();
  }
  public static testMethod void testDiaryView()
  {
  createData();
  Test.startTest();
  PageReference pageRef = Page.DiaryEntryCreateUnavail ;
  Test.setCurrentPage(pageRef);
  apexpages.currentpage().getparameters().put('entryId',dairyEntry.id);
  apexpages.currentpage().getparameters().put('area',testDistrict.id);
  ApexPages.StandardController controller=new ApexPages.StandardController(dairyEntry);
  DiaryEntryCreateUnavail dEntry=new DiaryEntryCreateUnavail(controller);
  dEntry.DiaryView();
  Test.stopTest();
  }
  
}