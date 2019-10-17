/* BlackBoxIF
	Interface for the SearchBlackBox - anything calling the black box
	should implement this interface.
	
	Implementations of this interface should instantiate an instance
	of the SearchBlackBox class and pass in the Job ID to search
	for to its startSearch method.
	
	This interface may grow in the future as other entry points to the
	SearchBlackBox (or related functionality) are required. 
	
*/

public interface BlackBoxIF {
	List<List<JobResourcingOption>> startSearch(ID jobID);
}