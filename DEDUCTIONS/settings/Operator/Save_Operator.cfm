<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFDUMP VAR="#FORM#">

<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseForDelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_operator")>
	<cfif useLakebaseForDelete_Data>
		<cftry>
			<cfset application.oLakebase.deleteRows("dd_operator", { "dd_operator_id" = "eq.#Form.DD_Operator_ID#" })>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDelete_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDelete_Data>
	<CFQUERY NAME="Delete_Data" datasource="#application.datasource#">
		DELETE FROM DD_operator 
		WHERE		DD_Operator_ID			=	'#Form.DD_Operator_ID#'
	</CFQUERY>
	</cfif>
	<CFLOCATION URL="create_Operator.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

<CFIF Form.DD_Operator_ID EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_operator")>
	<cfif useLakebaseForSave_Data>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_operator", {
				"dd_operator_name" = FORM.DD_Operator_Name,
				"dd_operator_address" = FORM.DD_Operator_Address,
				"dd_operator_address2" = FORM.DD_Operator_Address2,
				"dd_city" = FORM.DD_City,
				"dd_state" = FORM.DD_State,
				"dd_zipcode" = DD_ZipCode,
				"updated_by" = request.AccessStructure.User_Id
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForSave_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSave_Data>
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		DD_operator
		
						(	DD_Operator_Name,
							DD_Operator_Address,
							DD_Operator_Address2,
							DD_City,
							DD_State,
							DD_ZipCode,
							Updated_By				)
							
		Values			(	'#FORM.DD_Operator_Name#',
							'#FORM.DD_Operator_Address#',
							'#FORM.DD_Operator_Address2#',
							'#FORM.DD_City#',
							'#FORM.DD_State#',
							'#DD_ZipCode#',
							'#request.AccessStructure.User_Id#'		)							
	</CFQUERY>
	</cfif>
	<CFLOCATION URL="create_Operator.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>

<!--- Update the record --->
	<cfset useLakebaseForSave_Data2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_operator")>
	<cfif useLakebaseForSave_Data2>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_operator",
				{ "dd_operator_id" = "eq.#FORM.DD_Operator_ID#" },
				{
					"dd_operator_name" = FORM.DD_Operator_Name,
					"dd_operator_address" = FORM.DD_Operator_Address,
					"dd_operator_address2" = FORM.DD_Operator_Address2,
					"dd_city" = FORM.DD_City,
					"dd_state" = FORM.DD_State,
					"dd_zipcode" = DD_ZipCode,
					"updated_by" = request.AccessStructure.User_Id,
					"deleted" = FORM.Deleted
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForSave_Data2 = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSave_Data2>
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		DD_operator
		
		SET 		DD_Operator_Name 		=	'#FORM.DD_Operator_Name#',
					DD_Operator_Address		=	'#FORM.DD_Operator_Address#',
					DD_Operator_Address2	=	'#FORM.DD_Operator_Address2#',
					DD_City  				=   '#FORM.DD_City#',
					DD_State   				=   '#FORM.DD_State#',
					DD_ZipCode				=	'#DD_ZipCode#',
					Updated_By				=	'#request.AccessStructure.User_Id#',
					Deleted 				= 	'#FORM.Deleted#'
					
		WHERE		DD_Operator_ID			=	'#FORM.DD_Operator_ID#'
	</CFQUERY>
	</cfif>
	<CFLOCATION URL="create_Operator.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>
</body>
</html>
