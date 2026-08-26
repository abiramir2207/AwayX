<cfcomponent
	displayname="ProductGroupAttribute"
	output="false"
	hint="Attribute Bean">

	<!---
	PROPERTIES
	--->
	<cfproperty name="product_group_level_id" type="numeric" required="false" default="0" />
	<cfproperty name="group_internal_label" type="string" required="false" default="" />
	<cfproperty name="group_level_desc" type="string" required="false" default="" />


	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" output="false" returntype="ProductGroupAttribute" 
		hint="Constructor for this CFC.">
		<cfargument name="product_group_level_id" type="numeric" required="false" default="0" />
		<cfargument name="group_internal_label" type="string" required="false" default="" />
		<cfargument name="group_level_desc" type="string" required="false" default="" />

		
		<cfscript>
			setProductGroupId(arguments.product_group_level_id);
			setInternalLabel(arguments.group_internal_label);
			setDescription(arguments.group_level_desc);
		</cfscript>
		
		<cfreturn this />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setProductGroupId" access="public" output="false" returntype="void">
		<cfargument name="product_group_level_id" type="numeric" required="true" />
		<cfset variables.product_group_level_id = arguments.product_group_level_id />
	</cffunction>	
	<cffunction name="getProductGroupId" access="public" output="false" returntype="numeric">
		<cfreturn variables.product_group_level_id />
	</cffunction>

	<cffunction name="setInternalLabel" access="public" output="false" returntype="void">
		<cfargument name="group_internal_label" type="string" required="true" />
		<cfset variables.group_internal_label = Trim(arguments.group_internal_label) />
	</cffunction>	
	<cffunction name="getInternalLabel" access="public" output="false" returntype="string">
		<cfreturn variables.group_internal_label />
	</cffunction>

	<cffunction name="setDescription" access="public" output="false" returntype="void">
		<cfargument name="group_level_desc" type="string" required="true" />
		<cfset variables.group_level_desc = arguments.group_level_desc />
	</cffunction>	
	<cffunction name="getDescription" access="public" output="false" returntype="string">
		<cfreturn variables.group_level_desc />
	</cffunction>

	
</cfcomponent>