component alias="mvc.Models.Admin.VolumePlan.vos.VolPlanStatus" output="false"
{
	property name="id" type="numeric" default="1";
	property name="description" type="string" default="";

	//initialize
		this.id= 1;
		this.description = "";

	function init (id = 0,
					description = "") output="false" returntype="mvc.Models.Admin.VolumePlan.vos.VolPlanStatus"
	{
		this.id = arguments.id;
		this.description = arguments.description;
		return this;
	}
	
}