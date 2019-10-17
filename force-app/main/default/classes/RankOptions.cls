/* RankOptions
	A class to handle the ranking of customer options. This is basically an 
	implementation of a quicksort algorithm, with a method to determine
	whether one JobResourcingOption is better ("greater") than another.
*/

public with sharing class RankOptions {
	
	// Some static maps to help with determining which geographies and contractors are 
	// better than others
	public static final Map<String, Integer> GEOGRAPHY_RANKINGS = new Map<String, Integer>{'Primary' => 3, 'Away' => 3, 'Secondary' => 2, 
																							'District' => 1, 'Area' => 0};
	/*
	Change: made this more variable on search parameter
	public static final Map<String, Integer> CONTRACTOR_RANKINGS = new Map<String, Integer>{'Contractor Band 1' => 1, 
																							'Contractor Band 2' => 2,
																							'Contractor Band 3' => 3,
																							'Contractor' => 4}; 
	*/
	
	public static final Map<String, Integer> RESOURCE_RANKINGS = SearchBlackBox.optsAndParms.resourceRankingMap;
	// Static Integers used in ranking criteria to determine whether one option is better than another.
	public static final Integer WIN = 0;
	public static final Integer LOSE = 1;
	public static final Integer DRAW = 2;
	
	/* rankOptions(List<JobResourcingOption> jobOptions)
		Public method that takes a list of JobResourcingOptions and returns a sorted version
		of the list, from best option to worst.
	*/
	public List<JobResourcingOption> rankOptions(List<JobResourcingOption> jobOptions) {
		return qSort(jobOptions);
	}
	
	/* qSort(List<JobResourcingOption> resourcingOptions)
		Method to sort the JobResourcingOptions. This is basically an implementation of
		a quick sort method; it recurses over a list, splitting it into 2 and sorting
		those into 2 and so on until the lists is empty or only has one element. */
	private List<JobResourcingOption> qSort(List<JobResourcingOption> resourcingOptions) {
		// If the supplied resourcingOptions is empty or only has one element, there is
		// no sorting required, so return the list as it was passed in
		if(resourcingOptions.isEmpty() || resourcingOptions.size() == 1)
			return resourcingOptions;

		// Pick the JobResoucingOption from the end of the list - this will act as the 
		// "pivot". All other JobResoucingOptions will be compared to this one.
		JobResourcingOption middle = resourcingOptions.remove(resourcingOptions.size()-1);
		
		// We create two lists, "left" and "right" - left holds JobResoucingOptions better
		// than the pivot, right holds the ones the same or worse than the pivot
		List<JobResourcingOption> left = new List<JobResourcingOption>();
		List<JobResourcingOption> right = new List<JobResourcingOption>();
		
		// Loop over the remaining options and store each one in the appropriate list, left
		// if it is "better than" the pivot, right if it is the same or worse. The 
		// "betterThan" method is used to determine which list it should go into
		for(JobResourcingOption jro : resourcingOptions) {
			if(betterThan(jro, middle)) { // better = left, same or worse = right
				left.add(jro);
			} else {
				right.add(jro);
			}
		}
		
		// We now call this method again for each of the lists we have created above
		left = qSort(left);
		right = qSort(right);
		
		// We now store all options in the one list (including the pivot), in order
		left.add(middle);
		left.addAll(right);
		return left;
	} 
	
	/* betterThan(JobResourcingOption first, JobResourcingOption second)
		Compares 2 JobResourcingOptions and returns true is the first is "better than"
		the second. This method calls a series of other methods to determine which is
		better; these are the ranking criteria defined in the functional specs. The
		order in which the criteria are applied can be changed at a later date if required. 
		
		Each of the methods called returns an Integer - if the first option is better,
		a 0 (WIN) is returned; if the second options is better, a 1 (LOSE) is returned.
		In either of these cases, the correct boolean value is returned from this method.
		Otherwise, a 2 (DRAW) is returned from the method called and the next criteria
		is applied. */
	private Boolean betterThan(JobResourcingOption first, JobResourcingOption second) {
		
		Integer result = meetCustomerPreference(first, second);
		if(result == WIN)
			return true;
		else if(result == LOSE)
			return false;
		
		result = largeEnoughGap(first, second);
		if(result == WIN)
			return true;
		else if(result == LOSE)
			return false;
			
		result = geographyType(first, second);
		if(result == WIN)
			return true;
		else if(result == LOSE)
			return false;
			
		result = numberOfSkills(first, second);
		if(result == WIN)
			return true;
		else if(result == LOSE)
			return false;
			
		result = resourceType(first, second);
		if(result == WIN)
			return true;
		else if(result == LOSE)
			return false;
		/*	
		// Changed by Ashok on 08/03/2017.
		// Requested by Gabrieal Sanchez Del Rio && Rebbeca Oaked. 
		// .
		result = remainingGap(first, second);
		if(result == WIN)
			return true;
		else if(result == LOSE)
			return false;
		*/	
		if(IV_Vectors__c.getInstance('Travel Time Rank Switch').Key__c== 'On')
		{
			result = travelTime(first, second);
			if(result == WIN)
				return true;
			else if(result == LOSE)
				return false;	
		}	
		return false;
	}
	
	/* meetCustomerPreference(JobResourcingOption first, JobResourcingOption second)
		A method to compare two JobResourcingOptions on whether they can meet the customer
		preferred date.
	*/
	private Integer meetCustomerPreference(JobResourcingOption first, JobResourcingOption second) {
		System.debug('SearchBlackbox.optsAndParms.customerPreferredDate: ' + SearchBlackbox.optsAndParms.customerPreferredDate);
		System.debug('first.primaryStartDT: ' + first.primaryStartDT);
		System.debug('second.primaryStartDT: ' + second.primaryStartDT);
		if(SearchBlackbox.optsAndParms.customerPreferredDate != null)
		{
			if(first.primaryStartDT.dayOfYear() == SearchBlackbox.optsAndParms.customerPreferredDate.dayOfYear() &&
			second.primaryStartDT.dayOfYear() != SearchBlackbox.optsAndParms.customerPreferredDate.dayOfYear()) {
			return WIN;
			} else if(first.primaryStartDT.dayOfYear() != SearchBlackbox.optsAndParms.customerPreferredDate.dayOfYear() &&
				second.primaryStartDT.dayOfYear() == SearchBlackbox.optsAndParms.customerPreferredDate.dayOfYear()){
				return LOSE;
			}
			else {
			System.debug('draw: ' + first.primaryStartDT.dayOfYear() + ' ' + second.primaryStartDT.dayOfYear());
			return DRAW;
			}
		}
		return null;
		/*if(first.primaryStartDT.dayOfYear() == SearchBlackbox.optsAndParms.customerPreferredDate.dayOfYear() &&
			second.primaryStartDT.dayOfYear() != SearchBlackbox.optsAndParms.customerPreferredDate.dayOfYear()) {
			return WIN;
		} else if(first.primaryStartDT.dayOfYear() != SearchBlackbox.optsAndParms.customerPreferredDate.dayOfYear() &&
			second.primaryStartDT.dayOfYear() == SearchBlackbox.optsAndParms.customerPreferredDate.dayOfYear()){
			return LOSE;
		} else {
			System.debug('draw: ' + first.primaryStartDT.dayOfYear() + ' ' + second.primaryStartDT.dayOfYear());
			return DRAW;
		}*/
	}
	
	/* largeEnoughGap(JobResourcingOption first, JobResourcingOption second)
		A method to compare two JobResourcingOptions on whether they have a large enough
		gap to do all the skills they are able to do on the job. This is determined by
		looking at if the primary resource on the JRO has had skills removed (a boolean
		on the JRO object). If they have had skills removed, their gap was not large 
		enough. e.g. If the first JRO has _not_ had skills removed and the second _has_
		had skills removed, the first JRO is better and the method returns true.
	*/
	private Integer largeEnoughGap(JobResourcingOption first, JobResourcingOption second) {
		if(!first.primaryHasSkillsRemoved && second.primaryHasSkillsRemoved) {
			return WIN;
		} else if(first.primaryHasSkillsRemoved && !second.primaryHasSkillsRemoved) {
			return LOSE;
		} else {
			return DRAW;
		}
	}
	
	/* geographyType(JobResourcingOption first, JobResourcingOption second)
		Compares two JobResourcingOptions on geography type. Geography type is stored
		on the JobResourcingOption as lowestGeography. A value is looked up in the 
		GEOGRAPHY_RANKINGS Map - a higher number is better.
	*/
	private Integer geographyType(JobResourcingOption first, JobResourcingOption second) {
		// Ranking based on list of options
		if(GEOGRAPHY_RANKINGS.get(first.lowestGeography) > GEOGRAPHY_RANKINGS.get(second.lowestGeography)) {
			return WIN;
		} else if(GEOGRAPHY_RANKINGS.get(first.lowestGeography) < GEOGRAPHY_RANKINGS.get(second.lowestGeography)){
			return LOSE;
		} else {
			return DRAW;
		}
	}
	
	/* numberOfSkills(JobResourcingOption first, JobResourcingOption second)
		Compares two JobResourcingOptions on the number of skills the primary options can do. 
		A higher number of skills is better. */
	private Integer numberOfSkills(JobResourcingOption first, JobResourcingOption second) {
		if(first.primarySkillsCount > second.primarySkillsCount) {
			return WIN;
		} else if(first.primarySkillsCount < second.primarySkillsCount) {
			return LOSE;
		} else {
			return DRAW;
		}
	}
	
	/* resourceType(JobResourcingOption first, JobResourcingOption second)
		Compares two JobResourcingOptions on the resource type of the primary resources.*/
	private Integer resourceType(JobResourcingOption first, JobResourcingOption second) {
		/*if(first.getPrimaryResourceType() == SearchBlackBox.OWN_LABOUR && 
			second.getPrimaryResourceType() != SearchBlackBox.OWN_LABOUR) {
			return WIN;
		} else if(second.getPrimaryResourceType() == SearchBlackBox.OWN_LABOUR && 
			first.getPrimaryResourceType() != SearchBlackBox.OWN_LABOUR) {
			return LOSE;
		} else if(first.getPrimaryResourceType() != SearchBlackBox.OWN_LABOUR &&
					second.getPrimaryResourceType() != SearchBlackBox.OWN_LABOUR) {
			if(CONTRACTOR_RANKINGS.get(first.getPrimaryResourceType()) < CONTRACTOR_RANKINGS.get(second.getPrimaryResourceType()))
				return WIN;
			else if(CONTRACTOR_RANKINGS.get(first.getPrimaryResourceType()) > CONTRACTOR_RANKINGS.get(second.getPrimaryResourceType()))
				return LOSE;
			else
				return DRAW;
		}*/
		
		if(RESOURCE_RANKINGS.get(first.getPrimaryResourceType()) < RESOURCE_RANKINGS.get(second.getPrimaryResourceType()))
				return WIN;
			else if(RESOURCE_RANKINGS.get(first.getPrimaryResourceType()) > RESOURCE_RANKINGS.get(second.getPrimaryResourceType()))
				return LOSE;
			else
				return DRAW;
		return DRAW;
	}
	
	/* remainingGap(JobResourcingOption first, JobResourcingOption second)
		Compares two JobResourcingOptions on their remaining gap after the skills they
		can do have been planned. A higher number is better. */
	private Integer remainingGap(JobResourcingOption first, JobResourcingOption second) {
		// Number, higher = better
		if(getRemainingGapScore(first) > getRemainingGapScore(second)) {
			return WIN;
		} else if(getRemainingGapScore(first) < getRemainingGapScore(second)) {
			return LOSE;
		} else {
			return DRAW;
		}
	}
	
	/* getRemainingGapScore(JobResourcingOption jro)
		Rates a JobResourcingOption's remaining gap based on the criteria as defined in the
		functional specification. */
	private Integer getRemainingGapScore(JobResourcingOption jro) {
		Double hoursRemaining = jro.getHoursRemaining();
		
		if(hoursRemaining >= (0 - SearchBlackBox.optsAndParms.gapSizeTolerance) && hoursRemaining <= 0) {
			return 4;
		} else if (hoursRemaining >= SearchBlackBox.optsAndParms.usableGapRemaining) {
			return 3;
		} else if(hoursRemaining >= 0 && hoursRemaining < SearchBlackBox.optsAndParms.usableGapRemaining) {
			return 2;
		} else if(hoursRemaining < (0 - SearchBlackBox.optsAndParms.gapSizeTolerance)) {
			return 1;
		} else {
			return 0;
		}
	}
	
	/*
		travelTime
		Compares the travel time of primary resource and priortises the engineer with less travel time.
	*/
	
	private integer travelTime (JobResourcingOption first, JobResourcingOption second)
	{
		
		// Less Travel Time  = better
		if(first.primaryTravelTime < second.primaryTravelTime) {
			return WIN;
		} else if(first.primaryTravelTime > second.primaryTravelTime) {
			return LOSE;
		} else {
			return DRAW;
		}
		
	}
}