package com.Billback.Search.vos
{
	import flash.events.EventDispatcher;
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBFilterParams")]
	/**
	 * @author Milan
	 */
	public class BBFilterParams extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var BBCodeKeyword : String;
		public var BBNumberKeyword : String;
		public var programKeyword : String;
		public var checkNoKeyword : String;		
		public var amountTypeSelect : String;
		public var amountCriteriaSelect : String;
		public var amountValueKeyword : Number;
		public var dateRangeStartTypeSelect : String;
		public var dateRangeStartCriteriaSelect : String;
		public var dateRangeStartValueKeyword : Date;	
		public var dateRangeEndTypeSelect : String;
		public var dateRangeEndCriteriaSelect : String;
		public var dateRangeEndValueKeyword : Date;
		public var entitySelect : String;	
		public var entityKeyword : String;
		public var historySelect : String;
		public var historyUsernameSelect : Array = new Array();
		public var actionSelect :String;
		public var conditionSelect : String;
		public var statusListSelect : Array = new Array();
		public var closingMethodSelect : Array = new Array();
		public var typeListSelect : Array = new Array();
		public var analystListSelect : Array = new Array();
		public var bSearchDateRangeStart:Boolean;
		public var bSearchDateRangeEnd:Boolean;
		public var bSearchAmount:Boolean;
		public var payeeKeyword:String;
		public var userBillbackListId:int;
		public var userId:String;
		public var listName:String;	
		public var currentIncludingPaid:Boolean;
		public var reassignBBUserSelect:Array = new Array();
		public var clearRecords:Boolean;
		public var BBIDIntList : Array = new Array();
		public var bChkDuplicate:Boolean;
		
		/*-.........................................Constructor..........................................*/
		public function BBFilterParams(								
			BBCodeKeyword:String = '',
			BBNumberKeyword:String = '',
			programKeyword:String = '',
			checkNoKeyword:String = '',
			amountTypeSelect:String = '',
			amountCriteriaSelect:String = '',
			amountValueKeyword:Number  = 0,
			dateRangeStartTypeSelect:String = '',
			dateRangeStartCriteriaSelect:String = '',
			dateRangeStartValueKeyword:Date= null,
			dateRangeEndTypeSelect:String = '',
			dateRangeEndCriteriaSelect:String = '',
			dateRangeEndValueKeyword:Date= null,
			entitySelect:String = '',
			entityKeyword:String = '',
			historySelect:String = '',
			historyUsernameSelect:Array = null,
			actionSelect:String = '',
			conditionSelect:String = '',
			statusListSelect:Array = null,
			closingMethodSelect:Array = null,
			typeListSelect:Array = null,
			analystListSelect:Array = null,
			bSearchDateRangeStart:Boolean = false,
			bSearchDateRangeEnd:Boolean = false,
			bSearchAmount:Boolean = false,
			payeeKeyword:String = '',  
			userBillbackListId:int = 0,
			userId:String = '',
			listName:String = '',
			currentIncludingPaid:Boolean = false,
			bChkDuplicate:Boolean = false,
			reassignBBUserSelect:Array = null,
			clearRecords:Boolean = false,
			BBIDIntList:Array = null
			
		)
		{			
			/* When calling the constructor with the "new" keyword, the properties (for some reason) do not exist and so we have a conditional statement here
			for some properties which prevents it to be set to null and sets it to new Array(). This is useful when using "reset" on multi-select combobox 
			as when this constructor called, the selected checkboxes are unselected as needed.
			*/
			this.BBCodeKeyword = BBCodeKeyword;
			this.BBNumberKeyword = BBNumberKeyword;
			this.programKeyword = programKeyword;
			this.checkNoKeyword = checkNoKeyword;
			this.amountTypeSelect = amountTypeSelect;
			this.amountCriteriaSelect = amountCriteriaSelect;
			this.amountValueKeyword = amountValueKeyword;
			this.dateRangeStartTypeSelect = dateRangeStartTypeSelect;
			this.dateRangeStartCriteriaSelect = dateRangeStartCriteriaSelect;
			this.dateRangeStartValueKeyword = dateRangeStartValueKeyword;
			this.dateRangeEndTypeSelect = dateRangeEndTypeSelect;
			this.dateRangeEndCriteriaSelect = dateRangeEndCriteriaSelect;
			this.dateRangeEndValueKeyword = dateRangeEndValueKeyword;
			this.entitySelect = entitySelect;
			this.entityKeyword = entityKeyword;
			this.historySelect = historySelect;
			if(historyUsernameSelect)
				this.historyUsernameSelect = historyUsernameSelect;
			this.actionSelect = actionSelect;
			this.conditionSelect = conditionSelect;
			if(statusListSelect)
				this.statusListSelect = statusListSelect;
			if(closingMethodSelect)
				this.closingMethodSelect = closingMethodSelect;
			if(typeListSelect)
				this.typeListSelect = typeListSelect;
			if(analystListSelect)
				this.analystListSelect = analystListSelect;
			this.bSearchDateRangeStart = bSearchDateRangeStart;
			this.bSearchDateRangeEnd = bSearchDateRangeEnd;
			this.bSearchAmount = bSearchAmount;
			this.payeeKeyword = payeeKeyword;
			this.userBillbackListId = userBillbackListId;
			this.userId = userId;
			this.listName = listName;
			this.currentIncludingPaid = currentIncludingPaid;
			this.bChkDuplicate = bChkDuplicate;
			this.reassignBBUserSelect = reassignBBUserSelect;
			this.clearRecords = clearRecords;
			if(BBIDIntList)
				this.BBIDIntList = BBIDIntList;			
		}
		
	}
}
