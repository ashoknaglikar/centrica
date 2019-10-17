@isTest
public class CS_AllBundleComplexPriceTriggerTest {

	static testMethod void BoundsOverlappingTest() {
		CS_AllBundleComplexPriceTriggerHelper.Bound b1 = new CS_AllBundleComplexPriceTriggerHelper.Bound(0.0, 4.0);
		CS_AllBundleComplexPriceTriggerHelper.Bound b2 = new CS_AllBundleComplexPriceTriggerHelper.Bound(2.0, 6.0);

		System.assert(b1.overlaps(b2));

		CS_AllBundleComplexPriceTriggerHelper.Bound b3 = new CS_AllBundleComplexPriceTriggerHelper.Bound(2.0, 4.0);
		CS_AllBundleComplexPriceTriggerHelper.Bound b4 = new CS_AllBundleComplexPriceTriggerHelper.Bound(0.0, 3.0);

		System.assert(b3.overlaps(b4));

		CS_AllBundleComplexPriceTriggerHelper.Bound b5 = new CS_AllBundleComplexPriceTriggerHelper.Bound(2.0, 4.0);
		CS_AllBundleComplexPriceTriggerHelper.Bound b6 = new CS_AllBundleComplexPriceTriggerHelper.Bound(4.0, 6.0);

		System.assert(!b5.overlaps(b6));

		CS_AllBundleComplexPriceTriggerHelper.Bound b7 = new CS_AllBundleComplexPriceTriggerHelper.Bound(0.0, 3.0);
		CS_AllBundleComplexPriceTriggerHelper.Bound b8 = new CS_AllBundleComplexPriceTriggerHelper.Bound(0.0, 2.0);

		System.assert(b7.overlaps(b8));

		CS_AllBundleComplexPriceTriggerHelper.Bound b9  = new CS_AllBundleComplexPriceTriggerHelper.Bound(0.0, 3.0);
		CS_AllBundleComplexPriceTriggerHelper.Bound b10 = new CS_AllBundleComplexPriceTriggerHelper.Bound(0.0, 2.0);

		System.assert(b9.overlaps(b10));

		CS_AllBundleComplexPriceTriggerHelper.Bound b11  = new CS_AllBundleComplexPriceTriggerHelper.Bound(17.0, 18.0);
		CS_AllBundleComplexPriceTriggerHelper.Bound b12 = new CS_AllBundleComplexPriceTriggerHelper.Bound(0.0, 20.0);

		System.assert(b11.overlaps(b12));
	}

	static testMethod void BundleComplexPriceAssociationsShouldNotOverlapIfTheyHareRelatedToSameBudnleAndPart() {

		// create vat record
		CS_VAT_Code__c vat15 = new CS_VAT_Code__c(
			Name = 'VAT TEST 000',
			Percentage__c = 15);
        insert vat15;
    
        // create a bundle record
        CS_Bundle__c bundle = new CS_Bundle__c(Name = 'TEST BUNDLE 000', Type__c = 'Core Bundle');
        insert bundle;

		CS_Part__c part = new CS_Part__c(
			RecordTypeId = Schema.SObjectType.CS_Part__c.RecordTypeInfosByName.get('Complex Price').RecordTypeId,
			Part_Code__c = 'TEST-CODE-000',
			Description__c = 'TEST-DESCRIPTION',
			VAT_Code__c = vat15.Id);
		insert part;

		CS_Part_Price__c pp1 = new CS_Part_Price__c(
			);

		CS_Bundle_Complex_Price_Association__c bcp1 = new CS_Bundle_Complex_Price_Association__c(
			CS_Bundle__c = bundle.Id,
			CS_Part__c = part.Id,
			Lower_Skill_Hours_Limit__c = 4,
			Upper_Skill_Hours_Limit__c = 8);
		insert bcp1;

		CS_Bundle_Complex_Price_Association__c bcp2 = new CS_Bundle_Complex_Price_Association__c(
			CS_Bundle__c = bundle.Id,
			CS_Part__c = part.Id,
			Lower_Skill_Hours_Limit__c = 6,
			Upper_Skill_Hours_Limit__c = 10);
		try {
			insert bcp2;
		} catch (Exception e) {
			System.assert(e.getMessage().contains(CS_AllBundleComplexPriceTriggerHelper.OVERLAPPING_BOUNDS_ERROR));
		}

		CS_Bundle_Complex_Price_Association__c bcp3 = new CS_Bundle_Complex_Price_Association__c(
			CS_Bundle__c = bundle.Id,
			CS_Part__c = part.Id,
			Lower_Skill_Hours_Limit__c = 2,
			Upper_Skill_Hours_Limit__c = 6);
		try {
			insert bcp3;
		} catch (Exception e) {
			System.assert(e.getMessage().contains(CS_AllBundleComplexPriceTriggerHelper.OVERLAPPING_BOUNDS_ERROR));
		}

		CS_Bundle_Complex_Price_Association__c bcp4 = new CS_Bundle_Complex_Price_Association__c(
			CS_Bundle__c = bundle.Id,
			CS_Part__c = part.Id,
			Lower_Skill_Hours_Limit__c = 8,
			Upper_Skill_Hours_Limit__c = 12);
		insert bcp4;

		bcp4.Lower_Skill_Hours_Limit__c = 0;
		bcp4.Lower_Skill_Hours_Limit__c = 12;
		update bcp4;
	}
}