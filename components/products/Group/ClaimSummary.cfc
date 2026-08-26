<cfcomponent
	displayname="Claim Summary"
	output="false"
	hint="Claim Summary Bean">

	<!---
	PROPERTIES
	--->
	<cfproperty name="claim_summaryid" type="numeric" required="false" default="0" />
	<cfproperty name="client_label" type="string" required="false" default="" />
	<cfproperty name="deleted" type="numeric" required="false" default="" />


	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" output="false" returntype="ClaimSummary" 
		hint="Constructor for this CFC.">
		<cfargument name="claim_summaryid" type="numeric" required="false" default="0" />
		<cfargument name="client_label" type="string" required="false" default="" />
		<cfargument name="deleted" type="numeric" required="false" default="0" />

		
		<cfscript>
			setClaimSummaryId(arguments.claim_summaryid);
			setSummaryLabel(arguments.client_label);
			setDeleted(arguments.deleted);
		</cfscript>
		
		<cfreturn this />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setClaimSummaryId" access="public" output="false" returntype="void">
		<cfargument name="claim_summaryid" type="numeric" required="true" />
		<cfset variables.claim_summaryid = arguments.claim_summaryid />
	</cffunction>	
	<cffunction name="getClaimSummaryId" access="public" output="false" returntype="numeric">
		<cfreturn variables.claim_summaryid />
	</cffunction>

	<cffunction name="setSummaryLabel" access="public" output="false" returntype="void">
		<cfargument name="client_label" type="string" required="true" />
		<cfset variables.client_label = Trim(arguments.client_label) />
	</cffunction>	
	<cffunction name="getSummaryLabel" access="public" output="false" returntype="string">
		<cfreturn variables.client_label />
	</cffunction>
	
	<cffunction name="setDeleted" access="public" output="false" returntype="void">
		<cfargument name="deleted" type="numeric" required="true" />
		<cfset variables.deleted = arguments.deleted />
	</cffunction>	
	<cffunction name="getDeleted" access="public" output="false" returntype="numeric">
		<cfreturn variables.deleted />
	</cffunction>
	
</cfcomponent>