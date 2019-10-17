/**
 * Abstract base class for trigger handlers.
 */
public abstract class TriggerHandler
{
	public enum TriggerOperation {IS_INSERT, IS_UPDATE, IS_DELETE}
	
	protected Map<Id, SObject> oldMap {get; set;}
	protected Map<Id, SObject> newMap {get; set;}
	protected List<SObject> oldList {get; set;}
	protected List<SObject> newList {get; set;}
	protected TriggerOperation operation {get; set;}
	
	// Constructor
	public TriggerHandler(Map<Id, SObject> oldMap, Map<Id, SObject> newMap,
							List<SObject> oldList, List<SObject> newList)
	{
		// store the old and new maps
		this.oldMap = oldMap;
		this.newMap = newMap;
		this.oldList = oldList;
		this.newList = newList;
		
		// determine the trigger operation based on values in the old and new list
		if (oldList == null)
		{
			this.operation = TriggerOperation.IS_INSERT;
		}
		else if (newList == null)
		{
			this.operation = TriggerOperation.IS_DELETE;
		}
		else
		{
			this.operation = TriggerOperation.IS_UPDATE;
		}
	}

	/**
	 * Trigger handler interface to support best practises and bulkification
	 * of triggers.
	 */
	public interface ITrigger 
	{
		// operations performed at trigger invocation for before trigger
		void bulkBefore();
		
		// operations performed at trigger invocation for after trigger
		void bulkAfter();
		
		// operations perfomed 'before' each record insert
		void beforeInsert(SObject so);

		// operations perfomed 'before' each record update
		void beforeUpdate(SObject oldSo, SObject so);

		// operations perfomed 'before' each record delete
		void beforeDelete(SObject so);

		// operations perfomed 'after' each record insert
		void afterInsert(SObject so);

		// operations perfomed 'after' each record update
		void afterUpdate(SObject oldSo, SObject so);

		// operations perfomed 'after' each record delete
		void afterDelete(SObject so);
		
		// processing to perform after all rows have been processed
		void postProcessing();
	}
}