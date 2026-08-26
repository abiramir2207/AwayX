package com.shared.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Item.vos.ProductAttr")]
	public class ProductAttr
	{
		/*-.........................................Properties..........................................*/
		
		/*public var ProductGroupLevelID:Number;
		public var GroupLevelDesc:String;
		public var ProductGroupLevelType:Number;
		public var HierarchyLevel:String;
		public var SearchSequenceField:String;
		public var IsGroupCombination:Boolean;
		public var IsPG:Boolean
		public var ListOrder:Number;
		public var searchDp:Array;*/
		
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
		public var productGroupAttributeId:Number;
		public var productGroupAttributeIdField:String;
		public var productGroupAttributeInterfaceField:String;
		public var productGroupAttributeMasterIdField:String;
		public var productGroupAttributeNameField:String;
		public var productGroupAttributeNumberField:String;
		public var productGroupAttributeSearchSequenceField:String;
		public var productGroupAttributeTable:String;
		public var ProductGroupLevelId:Number;
		public var searchDp:Array;
		
		/*public function ProductAttr()
		{
		}*/
	}
}