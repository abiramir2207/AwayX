
component alias="mvc.Models.Admin.VolumePlan.vos.VolPlanCustomer" output="false"
{

	property name="typeId" type="numeric" default="0";
	property name="categoryId" type="string" default="";
	property name="customerId" type="string" default="";
	property name="name" type="string" default="";


	//initialize

	/*	this.type= '';
		this.year = 2010;
		this.start= now();
		this.end = now();*/

	function init (typeId = 0,
					categoryId = "",
					customerId = "",
					name = "") output="false" returntype="mvc.Models.Admin.VolumePlan.vos.VolPlanCustomer"
	{
		this.typeId = arguments.typeId;
		this.categoryId = arguments.categoryId;
		this.customerId = arguments.customerId;
		this.name = arguments.name;
		return this;
	}
	
}