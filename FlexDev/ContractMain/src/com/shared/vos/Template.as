package com.shared.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Template.vos.Template")]
	public class Template
	{
		/*-.........................................Properties..........................................*/
		public var templateId:int;
		public var firstParentId:int;
		public var bGroupDeal:Boolean;
		public var bFixedGroupDeal:Boolean;
		public var bRebateGroupDeal:Boolean;
		public var genericType:String = '';
		public var createdType:String = '';
		public var templateFiltersId:int;
		public var claimMechanicChanged:int = 1;
		public var paymentFrequencyChanges:int = 1;
		
	}
}