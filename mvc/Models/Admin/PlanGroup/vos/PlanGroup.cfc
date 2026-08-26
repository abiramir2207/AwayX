
component output="false" alias="mvc.Models.Admin.PlanGroup.vos.PlanGroup" 
{
	
	property name="categoryId" type="string" default="";
	property name="typeId" type="numeric" default="0";
	property name="code" type="string";
	property name="name" type="string" default="";
	property name="includeInOther" type="numeric" default="0";
	property name="members" type="array";
	
	//initialize properties
	variables.dao = createObject('component','mvc.Models.Admin.PlanGroup.PlanGroupDAO').init();
	variables.oPlanGroupMember = createObject('component','mvc.Models.Admin.PlanGroup.vos.PlanGroupMember').init();
	
	this.typeId= 0;
	this.categoryId = '';
	this.code= '';
	this.name = '';
	this.includeInOther = 0;
	this.members = arrayNew(1);
	
	public function init(	typeId= 0,
							categoryId = "",
							code = "",
							name = 0,
							includeInOther = 0,
							members = arrayNew(1)
						)
	 output="false" returntype="mvc.Models.Admin.PlanGroup.vos.PlanGroup"
	{
		this.typeId= arguments.typeId;
		this.categoryId = arguments.categoryId;
		this.code= arguments.code;
		this.name = arguments.name;
		this.includeInOther = arguments.includeInOther;
		this.members = arguments.members;
		return this;
	}
	
	public function setMembersFromDB() output="false" returntype="void"
	{
	
		var arrMembers = arrayNew(1);
		var stPlanGroup = '';
		var qData = '';
		qData = variables.dao.getPlanGroupMembers(this.typeId,this.groupTypeId);
		for (	i=1;
				i LTE qData.RecordCount;
				i++) 
				{
					stPlanGroup= variables.oPlanGroupMember.init(	qData['typeId'],
																qData['code'],
																qData['name'],
																qData['groupTypeId']);
					// TODO:  SET PROP qData['members'] in OBJ
					//oPlanGroupMember.setMembers().
					arrayAppend(arrMembers,duplicate(stPlanGroup));
				}
		this.members = arrMembers;
	}

}