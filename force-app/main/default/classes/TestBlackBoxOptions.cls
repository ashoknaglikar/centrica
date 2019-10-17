@isTest
private class TestBlackBoxOptions {

	@isTest
	public static void testDefaultBlackBoxOptions() {
		// Check these is a Search Parameter object with Type of DEFAULT. If not, set one up.
		
		Phase3TestHelper.createSearchParameters();
		BlackBoxOptions bo = new BlackBoxOptions();
	}
	
	@isTest
	public static void testJobBlackBoxOptions1() {
		// Check these is a Search Parameter object with Type of DEFAULT. If not, set one up.
		Phase3TestHelper.createSearchParameters();
		
		// TODO: Assertions
		Job__c j = Phase3TestHelper.createJob1();
		BlackBoxOptions bo = new BlackBoxOptions(j);
	}
	
	@isTest
	public static void testJobBlackBoxOptions2() {
		// Check these is a Search Parameter object with Type of DEFAULT. If not, set one up.
		Phase3TestHelper.createSearchParameters();
		
		// TODO: Assertions
		Job__c j = Phase3TestHelper.createJob2();
		BlackBoxOptions bo = new BlackBoxOptions(j);
	}
	
	@isTest
	public static void testJobBlackBoxOptions3() {
		// Check these is a Search Parameter object with Type of DEFAULT. If not, set one up.
		Phase3TestHelper.createSearchParameters();
		
		// TODO: Assertions
		Job__c j = Phase3TestHelper.createJob3();
		j.Override_Gap_Size_Tolerance__c = 1;
		cls_IsRun.generalTriggerSwitch = true;	
		update j;
		BlackBoxOptions bo = new BlackBoxOptions(j);
	}
}