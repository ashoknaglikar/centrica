@istest
public class vanstockGeneratorTest {

	private static testmethod  void  testscenrioOne()
	{

		Employee__c emp = TestClassHelper.createEmployee();
		insert emp;

		ApexPages.standardController contObj = new ApexPages.standardController(emp);
        pagereference pageref = new pagereference('/apex/vansStockGenerator?id='+emp.id);
        test.setCurrentPage(pageref);
        vanstockGenerator cont_asp = new vanstockGenerator(contObj);
        cont_asp.checkGenerateNewVSNumber();
        cont_asp.checkGenerateNewVSNumber();
        cont_asp.generateNewVanstockNumber();
        cont_asp.checkDeactivateFirst();
        cont_asp.deactivevanStock();

        emp.Van_Stock_Card_Other__c = 'ZZ1287080Z';
        update emp;

        contObj = new ApexPages.standardController(emp);
        pageref = new pagereference('/apex/vansStockGenerator?id='+emp.id);
        test.setCurrentPage(pageref);
        cont_asp = new vanstockGenerator(contObj);
        cont_asp.checkGenerateNewVSNumber();
	}

}