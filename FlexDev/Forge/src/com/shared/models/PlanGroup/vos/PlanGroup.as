package com.shared.models.PlanGroup.vos
{	
	import flash.events.EventDispatcher;
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Admin.PlanGroup.vos.PlanGroup")]
	public class PlanGroup extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var categoryId:String;
		public var typeId:Number;
		public var code:String;
		public var name:String;
		public var groupTypeId:Number;
		public var includeInOther:Number;
		public var members:Array;
		
		/*-.........................................Constructor..........................................*/
		public function PlanGroup( planGroup:PlanGroup = null )
		{
			if( planGroup ) copy( planGroup );
		}
		/*-.........................................Methods..........................................*/
		public function copy( planGroup:PlanGroup ):void
		{
			this.categoryId = planGroup.categoryId;
			this.typeId = planGroup.typeId;
			this.code = planGroup.code;
			this.name = planGroup.name;
			this.groupTypeId = planGroup.groupTypeId;
			this.includeInOther = planGroup.includeInOther;
			this.members = planGroup.members;
		}
	}
}