<!---
<cfdump var="#Form#">
<CFABORT>
--->

<CFPARAM NAME="Form.DeleteRecord" Default="0">
<CFPARAM NAME="FORM.DESCRIPTION" Default="X">

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseForDelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_access_levels")>
<cfif useLakebaseForDelete_Data>
	<cftry>
		<cfset application.oLakebase.deleteRows("report_access_levels", {
			"level_code" = "eq.#Form.Level_Code#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Data>
<CFQUERY NAME="Delete_Data" datasource="#application.datasource#">
		DELETE FROM report_access_levels
		WHERE		level_code		=	'#Form.Level_Code#'
	</CFQUERY>
</cfif>
	<CFLOCATION URL="maintain_report_access_levels_form.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of data --->
<CFIF FORM.DESCRIPTION EQ "X">
	<!--- <SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> --->
	<CFABORT>
</CFIF>


<CFIF Form.Level_Code EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_access_levels")>
<cfif useLakebaseForSave_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("report_access_levels", {
			"description" = "#Form.Description#",
			"status" = "#Form.Status#",
			"updated_userid" = "#request.AccessStructure.User_ID#",
			"lastupdated" = "#now()#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Data>
<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		report_access_levels
						(Description,Status,Updated_UserID,LastUpdated)
		Values			('#Form.Description#','#Form.Status#','#request.AccessStructure.User_ID#',getdate())
	</CFQUERY>
</cfif>
	<CFLOCATION URL="maintain_report_access_levels_form.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		report_access_levels
		SET 		description = '#form.description#',
					status		=	'#Form.Status#',
					Updated_UserID 	=	'#request.AccessStructure.User_ID#',
					LastUpdated = getDate()
		WHERE		level_code			=	'#Form.Level_Code#'
	</CFQUERY>
	<CFLOCATION URL="maintain_report_access_levels_form.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

