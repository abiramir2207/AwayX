<cfcomponent output="false" alias="mvc.Models.Admin.VolumePlan.vos.VolumePlan">

	<cfproperty name="volPlanId" type="numeric" default="0">
	<cfproperty name="volPlanMasterId" type="numeric" default="0">
	<cfproperty name="description" type="string" default="">
	<cfproperty name="positions" type="array" default="">
	<cfproperty name="customers" type="array" default="">
	<cfproperty name="adjustments" type="array" default="">
	<cfproperty name="status" type="string" default="">
	<cfproperty name="createdDate" type="date" default="">
	<cfproperty name="createdUser" type="User" default="">

	

	<cfscript>
		//Initialize the CFC with the default properties values.
		variables.volPlanId = 0;
		variables.volPlanMasterId = 0;
		variables.description = "";
		variables.positions = arrayNew(1);//
		variables.customers = arrayNew(1); //mvc.Models.Admin.PlanGroup.vos.PlanGroupType include distinct custs
		variables.adjustments = arrayNew(1);//
		variables.status = "";
		variables.createdDate = now();
		variables.createdUser = "";
		
	</cfscript>

	<cffunction name="init" output="false" returntype="mvc.Models.Admin.VolumePlan.vos.VolPlanStatus">
		<cfreturn this>
	</cffunction>
</cfcomponent>