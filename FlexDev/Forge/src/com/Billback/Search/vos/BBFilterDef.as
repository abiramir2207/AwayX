package com.Billback.Search.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBFilterDef")]
	/**
	 * @author Milan
	 */
	public class BBFilterDef extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var statusList : Array = new Array();
		public var closingMethodList : Array = new Array();
		public var analystList : Array;
		public var userList : Array;
		public var typeList : Array;
		public var dateTypeList : Array;
		public var amountTypeList : Array;
		public var entityTypeList : Array;
		public var historyTypeList : Array;
		public var criteriaList : Array;		
		public var actionList: Array = new Array();
		public var conditionList: Array = new Array();
		/*-.........................................Constructor..........................................*/
		public function BBFilterDef( 
									/*statusList:Array = null,
									closingMethodList:Array = null,
									analystList:Array = null,
									userList:Array = null,
									typeList:Array = null,
									dateTypeList:Array = null,
									amountTypeList:Array  = null,
									entityTypeList:Array  = null,
									historyTypeList:Array  = null,
									criteriaList:Array  = null,
									actionList:Array  =  null,
									conditionList:Array  = null,*/
					 )
		{
			/*this.statusList = statusList;
			this.closingMethodList = closingMethodList;
			this.analystList = analystList;
			this.userList = userList;
			this.typeList = typeList;
			this.dateTypeList = dateTypeList;
			this.amountTypeList = amountTypeList;
			this.entityTypeList =  entityTypeList;
			this.historyTypeList = historyTypeList;
			this.criteriaList = criteriaList;
			this.actionList = actionList;
			this.conditionList =  conditionList;*/
		}

	}
}
