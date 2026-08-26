
component output="false" alias="mvc.Models.Admin.PlanGroup.vos.PlanGroupMember" 
{
	property name="memberId" type="numeric" default="0";
	property name="typeId" type="numeric" default="0";
	property name="groupId" type="string" default="";
	property name="groupLevelId" type="numeric" default="0";
	property name="groupName" type="string" default="";
	property name="groupNumber" type="string" default="0";
	property name="groupDescription" type="string";
	property name="include" type="boolean" default="0";
	
	//initialize properties
	variables.dao = createObject('component','mvc.Models.Admin.PlanGroup.PlanGroupDAO').init();
	
	this.memberId= 0;
	this.typeId= 0;
	this.groupId = '';
	this.groupLevelId = 0;
	this.groupName = '';
	this.groupNumber= '';
	this.groupDescription = '';
	this.include = 0;
	
	public function init(	memberId= 0,
							typeId= 0,
							groupId = '',
							groupLevelId = 0,
							groupName = '',
							groupNumber = '',
							groupDescription = '',
							include = 0
						)
	 output="false" returntype="mvc.Models.Admin.PlanGroup.vos.PlanGroupMember"
	{
		this.memberId= arguments.memberId;
		this.typeId= arguments.typeId;
		this.groupId = arguments.groupId;
		this.groupLevelId= arguments.groupLevelId;
		this.groupName = arguments.groupName;
		this.groupNumber = arguments.groupNumber;
		this.groupDescription = arguments.groupDescription;
		this.include = arguments.include;
		return this;
	}

}