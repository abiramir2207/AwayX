<cfif isdefined("FORM.Market_Area_ID")>
	<cfset FORM.Market_Area_ID = replace(FORM.Market_Area_ID,"_","-","ALL")>
</cfif>

<cfset this_table	= "ZONE">
<cfset this_action 	= "NONE">
<cfset this_a_id 	= "">
<cfset this_desc	= "">
<cfset this_region_number = "">

<CFIF isdefined("FORM.DELETE")>
	<cfset this_action 			= "DELETE">
	<cfset this_a_id 			= FORM.Market_Area_ID>
</CFIF>
<CFIF isdefined("FORM.UPDATE")>
	<cfset this_action 			= "UPDATE">
	<cfset this_a_id 			= FORM.Market_Area_ID>
	<cfset this_desc			= FORM.NEW_DESCRIPTION>
	<cfset this_region_number 	= Form.NEW_REGION_NUMBER>
</CFIF>
<CFIF isdefined("FORM.INSERT")>
	<cfset this_action 			= "ADD">
	<cfset this_desc			= FORM.Market_Description>
	<cfset this_region_number 	= Form.Region_Number>
</CFIF>




<cfif this_action NEQ "NONE">
<!--- Dev Note: Milan; 12323. I commented out the dbvarname attribute as it was creating a problem on Mission Prod. I guess it has to do
			with some CF patch. I did not remove it completely so that we can use it to refer to the db vars in the stored procedure. --->
	<cfstoredproc procedure="tree_builder" datasource="#application.datasource#">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_CHAR" 	<!--- dbvarname="ACTION" ---> 		value="#this_action#" 			maxlength="10" 	null="No">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_CHAR" 	<!--- dbvarname="TABLE" ---> 		value="#this_table#" 			maxlength="10" 	null="No">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	<!--- dbvarname="TABLE_ID" ---> 	value="#this_a_id#"				maxlength="50" 	null="No">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	<!--- dbvarname="NUMBER" --->		value="#this_region_number#" 	maxlength="50" 	null="No">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	<!--- dbvarname="A_ID" ---> 		value=""						maxlength="50" 	null="No">
		<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR" 	<!--- dbvarname="NAME" --->		value="#this_desc#"				maxlength="255"	null="No">
		
		<cfprocparam type="Out" cfsqltype="CF_SQL_INTEGER" 	<!--- dbvarname="ERR_NUMBER" ---> 	variable="ERR_NUMBER"  							null="No">
		<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" 	<!--- dbvarname="ERR_MESSAGE" ---> variable="ERR_MESSAGE" 			maxlength="100" null="No">
		<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" 	<!--- dbvarname="ERR_COLUMN" --->	variable="ERR_COLUMN"  			maxlength="255" null="No">
	</cfstoredproc>

	<!--- error codes --->
	<cfset spError.message = ERR_MESSAGE>
	<cfset spError.number = ERR_NUMBER>
	<cfinclude template="/settings/position_tree/sp_error_code.cfm">

	<cfset useLakebaseForsaveLastEditedBy = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_zones_last_edited_by_data")>
<cfif useLakebaseForsaveLastEditedBy>
	<cftry>
		<cfset application.oLakebase.insertRow("service_zones_last_edited_by_data", {
			"user_id" = "#request.AccessStructure.user_id#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveLastEditedBy = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveLastEditedBy>
<CFQUERY NAME="saveLastEditedBy" datasource="#application.datasource#">
		INSERT INTO Service_Zones_Last_Edited_By_Data
		(User_ID)
		VALUES
		('#request.AccessStructure.user_id#')
	</CFQUERY>
</cfif>
</cfif>

<cfset showWaitMessage = 1>
<cfset autoredirectflag = 1>
<cfset autoredirectflag_URL = "/settings/zone_maintenance.cfm">
<cfinclude template="position_tree/buildxml.cfm">