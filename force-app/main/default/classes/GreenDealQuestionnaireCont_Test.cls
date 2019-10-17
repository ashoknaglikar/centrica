/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GreenDealQuestionnaireCont_Test {

    static testMethod void TestMethod_withBlankValues() {
    	
    	Account Acc = TestClassHelper.createAccout();
    	insert Acc;
    	
    	Opportunity opp = TestClassHelper.createCHILead(Acc);
    	insert opp;
    	
    	Green_Deal_Questions__c gdPq = TestClassHelper.createGDPreQual(null,opp.Id );
		insert   gdPq;
		
		ApexPages.standardController controller_1 = new ApexPages.standardController(new Green_Deal_Questions__c());
		test.setCurrentPage(new pagereference('/apex/GreenDealQuestionnaire?retUrl='+opp.Id));
		GreenDealQuestionnaireCont cont_Gd = new GreenDealQuestionnaireCont(controller_1);
		cont_Gd.AHGDARFunc();
		cont_Gd.awRoute();
		cont_Gd.CGDAAAPOPFunc();
		cont_Gd.checkconsent1();
		cont_Gd.checkconsent2();
		cont_Gd.checkPicCap();
		cont_Gd.disableBenefitSection1();
		cont_Gd.disableBenefitSection2();
		cont_Gd.disableBenefitSection3();
		cont_Gd.disableP_Con();
		cont_Gd.edit();
		cont_Gd.epcfunction();
		cont_Gd.improve();
		cont_Gd.PHAWGDPFunc();
		cont_Gd.showGDString();
		cont_Gd.showlandlordQues();
		cont_Gd.PHGDVFunc();
		cont_Gd.cancel();
		 
        // TO DO: implement unit test
    }
    
    static testMethod void TestMethod_withValues() {
    	
    	Account Acc = TestClassHelper.createAccout();
    	insert Acc;
    	
    	Opportunity opp = TestClassHelper.createCHILead(Acc);
    	insert opp;
    	
    	Green_Deal_Questions__c gdPq = TestClassHelper.createGDPreQual(null,opp.Id );
		insert   gdPq;
		
		ApexPages.standardController controller_1 = new ApexPages.standardController(new Green_Deal_Questions__c());
		test.setCurrentPage(new pagereference('/apex/GreenDealQuestionnaire?retUrl='+opp.Id));
		GreenDealQuestionnaireCont cont_Gd = new GreenDealQuestionnaireCont(controller_1);
		cont_Gd.AHGDAR ='No';
		cont_Gd.AHGDARFunc();
		cont_Gd.A =true;
		cont_Gd.B =true;
		cont_Gd.awRoute();
		cont_Gd.CGDAAAPOP = 'Yes' ;
		cont_Gd.CGDAAAPOPFunc();
		cont_Gd.WCFS = 'No';
		cont_Gd.checkconsent1();
		cont_Gd.WCFTOL = 'No' ; 
		cont_Gd.checkconsent2();
		cont_Gd.checkpicString = 'No';
		cont_Gd.checkPicCap();
		cont_Gd.IBPRAB ='No';
		cont_Gd.disableBenefitSection1();
		cont_Gd.CTCOSPC = 'Yes';
		cont_Gd.disableBenefitSection2();
	
		cont_Gd.disableBenefitSection3();
		cont_Gd.Any_Constraints = 'No';
		cont_Gd.disableP_Con();
		
		
		cont_Gd.epc='No' ;
		cont_Gd.epcfunction();
		cont_Gd.impEPC = 'No';
		cont_Gd.improve();
		cont_Gd.PHAWGDP = 'No';
		cont_Gd.PHAWGDPFunc();
		cont_Gd.elecSuppl ='British Gas';
		cont_Gd.showGDString();
		cont_Gd.WHBPATV ='Landlord';
		cont_Gd.showlandlordQues();
		cont_Gd.PHGDV = 'No';
		cont_Gd.PHGDVFunc();
		cont_Gd.cancel();
		 
        // TO DO: implement unit test
    }
    
    static testMethod void TestMethod_SaveGD() 
    {
    	Account Acc = TestClassHelper.createAccout();
    	insert Acc;
    	
    	Opportunity opp = TestClassHelper.createCHILead(Acc);
    	insert opp;
    	
    	District__c dist = TestClassHelper.createDistrict();
    	insert dist;
    	
    	Job__c job  = TestClassHelper.createJob('Planned', 'Planned',opp.Id,dist.Id);
    	insert job;
		
		ApexPages.standardController controller_1 = new ApexPages.standardController(new Green_Deal_Questions__c());
		test.setCurrentPage(new pagereference('/apex/GreenDealQuestionnaire?retUrl='+job.Id));
		GreenDealQuestionnaireCont cont_Gd = new GreenDealQuestionnaireCont(controller_1);
		cont_Gd.greenDealQues.IBPRAB__c = 'Yes';
		cont_Gd.greenDealQues.CTCOSPC__c = 'No';
		cont_Gd.save();
		cont_Gd.greenDealQues.Benefit_1A_1__c ='test';
		cont_Gd.greenDealQues.Benefit_1B_1__c = 'Test';
		cont_Gd.save();
		cont_Gd.greenDealQues.Yes__c = true;
		cont_Gd.save();
		
		Green_Deal_Questions__c greenDealQues = TestClassHelper.createGDPreQual(job.Id,opp.Id);
		greenDealQues.improvements_due_to_EPC__c= 'No';
		greenDealQues.Energy_Performance_Certificate__c = 'No';
		greenDealQues.WHBPATV__c ='landlord;';
		greenDealQues.IBPRAB__c = 'No';
		greenDealQues.CTCOSPC__c = 'Yes';
		greenDealQues.Any_Constraints__c = 'No';
		greenDealQues.Energy_Performance_Certificate__c='No';
		greenDealQues.Electric_Supplier__c = 'British Gas';
		greenDealQues.PHGDV__c = 'No';
		greenDealQues.AHGDAR__c = 'No';
		greenDealQues.PHAWGDP__c = 'No';
		greenDealQues.CGDAAAPOP__c ='Yes';
		greenDealQues.WCFS__c = 'No';
		greenDealQues.WCFTOL__c = 'No';
		greenDealQues.AYHTP__c= 'No';
		
		insert greenDealQues;
		
		test.setCurrentPage(new pagereference('/apex/GreenDealQuestionnaire?id='+greenDealQues.id+'&retUrl='+greenDealQues.id));
		cont_Gd = new GreenDealQuestionnaireCont(controller_1);
	}
}