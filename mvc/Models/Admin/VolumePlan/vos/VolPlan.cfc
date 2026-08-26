component 
{
	property name="id" type="numeric" default="0";
	property name="volPlanMasterId" type="numeric" default="0";
	property name="description" type="string";
	property name="positions" type="array";
	property name="customers" type="array";
	property name="pgCustomers" type="array";
	property name="adjustments" type="array";
	property name="status" type="string";
	property name="createdUser" type="mvc.Models.Entity.vos.User";
	property name="createdDate" type="date";
	
	
	//initialize properties
	this.id = '';
	this.volPlanMasterId = 0;
	this.description = '';
	this.positions = arrayNew(1);
	variables.customers = arrayNew(1); //mvc.Models.Admin.PlanGroup.vos.PlanGroupType include distinct custs
	variables.adjustments = arrayNew(1);//
	variables.status = "";
	this.createdUser = '';
	this.createdDate = '';

	
	public function init(	id = 0,
							volPlanMasterId = 0,
							description = '',
							positions = arrayNew(1),
							customers = arrayNew(1),
							pgCustomers = arrayNew(1),
							adjustments = arrayNew(1),
							status = '',
							createdUser = '',
							createdDate = now()
							)
	 output="false" returntype="mvc.Models.Admin.VolumePlan.vos.VolPlan"
	{
		this.id = arguments.id;
		this.volPlanMasterId = arguments.volPlanMasterId;
		this.description = arguments.description;
		this.positions = arguments.positions;
		this.customers = arguments.customers;
		this.pgCustomers = arguments.pgCustomers;
		this.createdUser = arguments.createdUser;
		this.createdDate = arguments.createdDate;
		this.adjustments = arguments.adjustments;
		return this;
	}

}