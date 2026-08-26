package com.ContractProds.vos
{
	/**
	 * ResultLogItem holds details of user initiated actions.  On initial load, the import components also writes log records.
	 * @author msaunders
	 */
	public class ResultLogItem
	{
		/*-.........................................Properties..........................................*/
		public var componentId : int;
		public var componentName : String;
		public var type : int;
		public var sResult : String;
		
		/*-.........................................Constructor..........................................*/
		public function ResultLogItem( resultLogItem:ResultLogItem = null )
		{
			if( resultLogItem ) copy( resultLogItem );
		}
		/*-.........................................Methods..........................................*/
		public function copy( resultLogItem:ResultLogItem ):void
		{
			componentId 	= resultLogItem.componentId;
			type			= resultLogItem.type;
			componentName	= resultLogItem.componentName;
			sResult			= resultLogItem.sResult;
		}

	}
}