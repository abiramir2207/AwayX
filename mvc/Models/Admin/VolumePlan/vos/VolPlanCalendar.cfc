
component alias="mvc.Models.Admin.VolumePlan.vos.VolPlanCalendar" output="false"
{

	property name="type" type="string" default="";
	property name="year" type="string" default="";
	property name="start" type="date" default="";
	property name="end" type="date" default="";

	//initialize

	/*	this.type= '';
		this.year = 2010;
		this.start= now();
		this.end = now();*/

	function init (type = "fiscal",
					year = "2010",
					start = now(),
					end = now()) output="false" returntype="mvc.Models.Admin.VolumePlan.vos.VolPlanCalendar"
	{
		this.type = arguments.type;
		this.year = arguments.year;
		this.start = arguments.start;
		this.end = arguments.end;
		return this;
	}
	
}