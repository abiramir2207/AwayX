package com.shared.models.PlanGroup.vos
{
	import flash.events.EventDispatcher;
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Admin.PlanGroup.vos.PlanGroupMember")]
	public class PlanGroupMember extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var memberId:Number;
		public var typeId:Number;
		public var groupId:string;
		public var groupLevelId:Number;
		public var groupName:String;
		public var groupNumber:String;
		public var groupDescription:String;
		public var include:Boolean;
		
		/*-.........................................Constructor..........................................*/
		public function PlanGroupMember( planGroup:PlanGroupMember = null )
		{
			if( planGroupMember ) copy( planGroupMember );
		}
		/*-.........................................Methods..........................................*/
		public function copy( planGroupMember:PlanGroupMember ):void
		{
			this.memberId = planGroupMember.memberId;
			this.typeId = planGroupMember.typeId;
			this.groupId = planGroupMember.groupId;
			this.groupLevelId = planGroupMember.groupLevelId;
			this.groupName = planGroupMember.groupName;
			this.groupNumber = planGroupMember.groupNumber;
			this.groupDescription = planGroupMember.groupDescription;
			this.include = planGroupMember.include;
		}
	}
}