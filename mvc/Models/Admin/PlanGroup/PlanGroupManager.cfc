<cfcomponent output="false" alias="mvc.Models.Admin.PlanGroup.PlanGroupManager">

	

	<cffunction name="init" output="false" returntype="mvc.Models.Admin.PlanGroup.PlanGroupManager">
	
		<cfreturn this />
		
	</cffunction>
	
	
	<cffunction name="getPlanGroupTypes" returntype="mvc.Models.Admin.PlanGroup.vos.PlanGroupType" access="remote" >
		<cfargument name="groupTypeId" default="1" />
		<!--- Get list of available PlanGroupType for a specific groupTypeId (1,2, or 3 = prod,cust, or opr) --->
		
	</cffunction>
	
	<cffunction name="getPlanGroups" returntype="array" access="remote" >
		<cfargument name="typeId" default="product" />
		<!--- Get list of available Plan Groups for a PlanGroupType
			return array of mvc.Models.Admin.PlanGroup.vos.PlanGroup
		 --->
		 
	</cffunction>
	
	<cffunction name="getPlanGroupMembers" returntype="array" access="remote" >
		<cfargument name="categoryId" default="product" />
		<!--- Get list Plan Group members for a for a PlanGroup
			return array of mvc.Models.Admin.PlanGroup.vos.PlanGroupMember
		 --->
		 
	</cffunction>
	

</cfcomponent>