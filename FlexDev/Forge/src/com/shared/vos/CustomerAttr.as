package com.shared.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Distributor.vos.CustomerAttr")]
	public class CustomerAttr
	{
		/*-.........................................Properties..........................................*/
		public var active:Boolean;
		public var allowFilter:Boolean;
		public var allowInGroupSearch:Boolean;
		public var allowInSearch:Boolean;
		public var createdDate:String;
		public var groupLevelId:Number;
		public var groupLevelDesc:String;
		public var listOrder:Number;
		public var pgFlag:Boolean;
		public var pgGroupType:Number;
		public var customerGroupAttributeId:Number;
		public var customerGroupAttributeIdField:String;
		public var customerGroupAttributeInterfaceField:String;
		public var customerGroupAttributeMasterIdField:String;
		public var customerGroupAttributeNameField:String;
		public var customerGroupAttributeNumberField:String;
		public var customerGroupAttributeSearchSequenceField:String;
		public var customerGroupAttributeTable:String;
		public var customerGroupLevelId:Number;
		public var searchDp:Array;
		
		
		public function CustomerAttr()
		{
		}
		
	}
}