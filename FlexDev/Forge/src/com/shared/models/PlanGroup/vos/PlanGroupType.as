package com.shared.models.PlanGroup.vos
{
	import flash.events.EventDispatcher;
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Admin.PlanGroup.vos.PlanGroupType")]
	public class PlanGroupType extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var typeId:Number;
		public var code:String;
		public var name:String;
		public var groupTypeId:Number;
		public var arrPlanGroups:Array;
		
		/*-.........................................Constructor..........................................*/
		public function PlanGroupType( planGroupType:PlanGroupType = null )
		{
			if( planGroupType ) copy( planGroupType );
		}
		/*-.........................................Methods..........................................*/
		public function copy( planGroupType:PlanGroupType ):void
		{
			this.typeId = planGroupType.typeId;
			this.code = planGroupType.code;
			this.name = planGroupType.name;
			this.groupTypeId = planGroupType.groupTypeId;
			this.arrPlanGroups = planGroupType.arrPlanGroups;
		}
	}
}