component alias="mvc.Models.Admin.VolumePlan.vos.VolPlanSource" output="false"
{
	property name="id" type="numeric" default="0";
	property name="description" type="string" default="";
	property name="indirectPlot" type="String" default="";

	//initialize
	
		this.id= 0;
		this.description = "";
		this.indirectPlot = "";


	function init (id = 0,
					description = "",
					indirectPlot = "") output="false" returntype="mvc.Models.Admin.VolumePlan.vos.VolPlanSource"
	{
		this.id = arguments.id;
		this.description = arguments.description;
		this.indirectPlot = arguments.indirectPlot;
		return this;
	}
	
}