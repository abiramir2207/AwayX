
<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_far")>
<cfif useLakebaseFordelete_Data>
	<cftry>
		<cfset application.oLakebase.deleteRows("pm_far", {
			"pm_far_id" = "eq.#Form.PM_Far_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelete_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelete_Data>
<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM PM_Far  
		WHERE		PM_Far_ID			=	'#Form.PM_Far_ID#'  
	</CFQUERY>
</cfif>
	<CFLOCATION URL="create_Far.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of data --->
<CFIF trim(Form.PM_Far_Description) EQ "" OR trim(Form.PM_Far_Description) EQ 0>
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>

<CFIF Form.PM_Far_ID EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_far")>
<cfif useLakebaseForSave_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_far", {
			"pm_far_description" = "#Form.PM_Far_Description#",
			"pm_far_deleted" = "#Form.PM_Far_Deleted#",
			"pm_updated_userid" = "#request.AccessStructure.User_Id#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Data>
<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		PM_Far
						(PM_Far_Description,PM_Far_Deleted,PM_Updated_UserId)
		Values			('#Form.PM_Far_Description#',#Form.PM_Far_Deleted#,'#request.AccessStructure.User_Id#')
	</CFQUERY>
</cfif>
	<CFLOCATION URL="create_Far.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		PM_Far
		SET 		PM_Far_Description 	=	'#Form.PM_Far_Description#',
					PM_Far_Deleted		=	#Form.PM_Far_Deleted#,
					PM_Updated_UserId  	=   '#request.AccessStructure.User_Id#',
					PM_LastUpdated   	=   getdate()
		WHERE		PM_Far_ID			=	'#Form.PM_Far_ID#'
	</CFQUERY>
	<CFLOCATION URL="create_Far.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>
