


<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_status")>
	<cfif useLakebaseFordelete_Data>
		<cftry>
			<cfset application.oLakebase.deleteRows("dd_status", { "dd_status_id" = "eq.#Form.DD_Status_ID#" })>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseFordelete_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseFordelete_Data>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM DD_Status  
		WHERE		DD_Status_ID			=	'#Form.DD_Status_ID#'
	</CFQUERY>
	</cfif>
	<CFLOCATION URL="create_Status.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>


<CFIF Form.DD_Status_ID EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_status")>
	<cfif useLakebaseForSave_Data>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_status", {
				"dd_status_description" = Form.DD_Status_Description,
				"editable" = FORM.Editable,
				"deleted" = Form.Deleted
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForSave_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSave_Data>
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		DD_Status
						(DD_Status_Description,Editable,Deleted)
		Values			('#Form.DD_Status_Description#','#FORM.Editable#',#Form.Deleted#)
	</CFQUERY>
	</cfif>
	<CFLOCATION URL="create_Status.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_status")>
	<cfif useLakebaseForSave_Data>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_status",
				{ "dd_status_id" = "eq.#Form.DD_Status_ID#" },
				{
					"dd_status_description" = Form.DD_Status_Description,
					"editable" = FORM.Editable,
					"deleted" = Form.Deleted
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForSave_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSave_Data>
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		DD_Status
		SET 		DD_Status_Description 	=	'#Form.DD_Status_Description#',
					Editable				=	'#FORM.Editable#',
					Deleted					=	#Form.Deleted#
		WHERE		DD_Status_ID			=	'#Form.DD_Status_ID#'
	</CFQUERY>
	</cfif>
	<CFLOCATION URL="create_Status.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

