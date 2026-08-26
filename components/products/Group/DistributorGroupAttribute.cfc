<cfcomponent
	displayname="DistributorGroupAttribute"
	output="false"
	hint="Attribute Bean">

	<!---
	PROPERTIES
	--->
	<cfproperty name="distributor_group_level_id" type="numeric" required="false" default="0" />
	<cfproperty name="group_level_desc_internal" type="string" required="false" default="" />
	<cfproperty name="group_level_desc" type="string" required="false" default="" />


	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" output="false" returntype="DistributorGroupAttribute" 
		hint="Constructor for this CFC.">
		<cfargument name="distributor_group_level_id" type="numeric" required="false" default="0" />
		<cfargument name="group_level_desc_internal" type="string" required="false" default="" />
		<cfargument name="group_level_desc" type="string" required="false" default="" />

		
		<cfscript>
			setDistributorGroupId(arguments.distributor_group_level_id);
			setInternalLabel(arguments.group_level_desc_internal);
			setDescription(arguments.group_level_desc);
		</cfscript>
		
		<cfreturn this />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setDistributorGroupId" access="public" output="false" returntype="void">
		<cfargument name="distributor_group_level_id" type="numeric" required="true" />
		<cfset variables.distributor_group_level_id = arguments.distributor_group_level_id />
	</cffunction>	
	<cffunction name="getDistributorGroupId" access="public" output="false" returntype="numeric">
		<cfreturn variables.distributor_group_level_id />
	</cffunction>

	<cffunction name="setInternalLabel" access="public" output="false" returntype="void">
		<cfargument name="group_level_desc_internal" type="string" required="true" />
		<cfset variables.group_level_desc_internal = Trim(arguments.group_level_desc_internal) />
	</cffunction>	
	<cffunction name="getInternalLabel" access="public" output="false" returntype="string">
		<cfreturn variables.group_level_desc_internal />
	</cffunction>

	<cffunction name="setDescription" access="public" output="false" returntype="void">
		<cfargument name="group_level_desc" type="string" required="true" />
		<cfset variables.group_level_desc = arguments.group_level_desc />
	</cffunction>	
	<cffunction name="getDescription" access="public" output="false" returntype="string">
		<cfreturn variables.group_level_desc />
	</cffunction>

	
</cfcomponent>