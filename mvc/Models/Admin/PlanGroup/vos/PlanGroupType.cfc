component output="false" alias="mvc.Models.Admin.PlanGroup.vos.PlanGroupType" 
{
	property name="typeId" type="numeric" default="0";
	property name="code" type="string" default="";
	property name="name" type="string";
	property name="groupTypeId" type="numeric" default="0";
	property name="arrPlanGroups" type="array";
	
	//initialize properties
	variables.pgDao = createObject('component','mvc.Models.Admin.PlanGroup.PlanGroupDAO').init();
	variables.oPlanGroup = createObject('component','mvc.Models.Admin.PlanGroup.vos.PlanGroup').init();
	
	this.typeId= 0;
	this.code = "";
	this.name = "";
	this.groupTypeId = 0;//prod = 1,cust=2,opr=3
	this.arrPlanGroups = arrayNew(1);//PlanGroup records
	
	public function init(	typeId= 0,
							code = "",
							name = "",
							groupTypeId = 0,
							arrPlanGroups = arrayNew(1)
						) output="false" returntype="mvc.Models.Admin.PlanGroup.vos.PlanGroupType"
	{
		this.typeId = arguments.typeId;
		this.code = arguments.code;
		this.name = arguments.name;
		this.groupTypeId = arguments.groupTypeId;
		this.arrPlanGroups = arguments.arrPlanGroups;
		return this;
	}
	
	public function setArrPlanGroupsFromDB() output="false" returntype="void"
	{
	
		var arrMembers = arrayNew(1);
		var stPlanGroup = '';
		var qData = queryNew('x');
		qData = variables.pgDao.getPlanGroupTypeCategory(this.typeId,this.groupTypeId);
		for (	i=1;
				i LTE qData.RecordCount;
				i++) 
				{
					stPlanGroup= variables.oPlanGroup.init(	qData['typeId'][i],
															qData['categoryId'][i],
															qData['code'][i],
															qData['name'][i],
															qData['includeInOther'][i]
															);
					// TODO:  SET PROP qData['members'] in OBJ
					//oPlanGroup.setMembers();
					arrayAppend(arrMembers,duplicate(stPlanGroup));
				}
		this.arrPlanGroups = arrMembers;
	}

}