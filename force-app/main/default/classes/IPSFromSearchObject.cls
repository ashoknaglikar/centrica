/* IPSFromSearchObject

	Installation Planner Search class that implements the Black Box interface
	(BlackBoxIF). It instantiates an instance of the SearchBlackBox class
	and calls its startSearch method, passing in the job ID to search for.
	
*/

public with sharing class IPSFromSearchObject implements BlackBoxIF {
	public List<List<JobResourcingOption>> startSearch(ID jobID) {
		SearchBlackBox sbb = new SearchBlackBox(jobID);
		return sbb.startSearch();
	}	
}