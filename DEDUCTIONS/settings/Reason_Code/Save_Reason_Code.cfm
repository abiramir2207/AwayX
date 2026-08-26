
<CFPARAM NAME="FORM.Show_Operator" DEFAULT="0">
<CFPARAM NAME="Form.Is_Default" DEFAULT="0">
<CFPARAM NAME="Form.Is_BB_Default" DEFAULT="0">

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseForAnyDD_WithThisRC = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForAnyDD_WithThisRC>
		<cftry>
			<cfset AnyDD_WithThisRC = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"select" = "deduction_id",
					"dd_resolution_code" = "eq.#Form.DD_Reason_Code_ID#",
					"deleted" = "eq.0",
					"limit" = "1"
				}),
				"deduction_id"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForAnyDD_WithThisRC = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForAnyDD_WithThisRC>
	<CFQUERY NAME="AnyDD_WithThisRC" datasource="#application.datasource#">
		SELECT 	TOP 1 Deduction_ID 
		FROM 	Deductions 
		WHERE 	DD_Resolution_Code = '#Form.DD_Reason_Code_ID#' AND Deleted = 0
	</CFQUERY>
	</cfif>
	
	<CFIF AnyDD_WithThisRC.RecordCount GT 0>
		<BR><BR><BR><BR>
		
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD>
					<B><FONT COLOR="Red" SIZE="2">
						Cannot delete this reason code as there are deductions assigned with this reason code.
					</FONT></B>
				
				</TD>
			</TR>
		</TABLE>
		<SCRIPT language="JavaScript">
		function relocateThis()
		{
			window.location.href = "create_Reason_Code.cfm"
		}
		window.setTimeout('relocateThis()', 3000);	
		</SCRIPT>
		
	<CFELSE>
		<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
		<cfif useLakebaseFordelete_Data>
			<cftry>
				<cfset application.oLakebase.deleteRows("dd_reason_code", { "dd_reason_code_id" = "eq.#Form.DD_Reason_Code_ID#" })>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseFordelete_Data = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseFordelete_Data>
		<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
			DELETE FROM DD_Reason_Code  
			WHERE		DD_Reason_Code_ID			=	'#Form.DD_Reason_Code_ID#'
		</CFQUERY>
		</cfif>
		<CFLOCATION URL="create_Reason_Code.cfm" ADDTOKEN="No">
	</CFIF>	
	<CFABORT>
</CFIF>

<cfset useLakebaseForIsThereDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
<cfif useLakebaseForIsThereDefault>
	<cftry>
		<cfset IsThereDefault = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_reason_code", {
				"is_default" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForIsThereDefault = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsThereDefault>
<cfquery name="IsThereDefault" datasource="#application.datasource#">
	SELECT * FROM DD_Reason_Code WHERE Is_Default = 1 AND Deleted = 0
</cfquery>
</cfif>

<cfset useLakebaseForIsThereBBDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
<cfif useLakebaseForIsThereBBDefault>
	<cftry>
		<cfset IsThereBBDefault = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_reason_code", {
				"is_bb_default" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForIsThereBBDefault = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsThereBBDefault>
<cfquery name="IsThereBBDefault" datasource="#application.datasource#">
	SELECT * FROM DD_Reason_Code WHERE Is_BB_Default = 1 AND Deleted = 0
</cfquery>
</cfif>

<!---See if something is already set as default--->
<cfparam name="SetAsDefault" default="0">
<cfif IsThereDefault.RecordCount IS 0>
	<cfset SetAsDefault = 1>
	<cfset Form.Is_Default = 1>
</cfif>

<!---See if something is already set as default--->
<cfparam name="SetAsBBDefault" default="0">
<cfif IsThereBBDefault.RecordCount IS 0>
	<cfset SetAsBBDefault = 1>
	<cfset Form.Is_BB_Default = 1>
</cfif>


<!--- remove the default from another entry if necessary --->
<cfif Form.Is_Default IS 1>
	<cfset useLakebaseForRemoveDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
	<cfif useLakebaseForRemoveDefault>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_reason_code",
				{ "is_default" = "eq.1" },
				{ "is_default" = 0 }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForRemoveDefault = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForRemoveDefault>
	<cfquery name="RemoveDefault" datasource="#application.datasource#">
	UPDATE DD_Reason_Code
	Set Is_Default = 0
	WHERE Is_Default = 1
	</cfquery>
	</cfif>
</cfif>

<cfif Form.Is_BB_Default IS 1>
	<cfset useLakebaseForRemoveBBDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
	<cfif useLakebaseForRemoveBBDefault>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_reason_code",
				{ "is_bb_default" = "eq.1" },
				{ "is_bb_default" = 0 }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForRemoveBBDefault = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForRemoveBBDefault>
	<cfquery name="RemoveBBDefault" datasource="#application.datasource#">
	UPDATE DD_Reason_Code
	Set Is_BB_Default = 0
	WHERE Is_BB_Default = 1
	</cfquery>
	</cfif>
</cfif>




<CFIF Form.DD_Reason_Code_ID EQ "">
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		DD_Reason_Code
						(DD_Reason_Code,DD_Reason_Code_Description,Deleted,Show_Operator,Closing_Method,GL_Account_Code,Is_Default,Display_In,Is_BB_Default)
		Values			('#FORM.DD_Reason_Code#','#Form.DD_Reason_Code_Description#',#Form.Deleted#,#FORM.Show_Operator#,<CFIF IsDefined("FORM.Closing_Method")>#FORM.Closing_Method#<CFELSE>NULL</CFIF>,<CFIF IsDefined("FORM.gl_account_code")>'#Form.gl_account_code#'<CFELSE>NULL</CFIF>,#Form.Is_Default#,#Display_In#,#Is_BB_Default#)
	</CFQUERY>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		DD_Reason_Code
		
		SET 		DD_Reason_Code				=	'#FORM.DD_Reason_Code#',
					DD_Reason_Code_Description 	=	'#Form.DD_Reason_Code_Description#',
					Deleted						=	#Form.Deleted#,
					Show_Operator				=	#FORM.Show_Operator#,
					Closing_Method				=	<CFIF IsDefined("FORM.Closing_Method")>#FORM.Closing_Method#<CFELSE>NULL</CFIF>,
					GL_Account_Code             =   <CFIF IsDefined("FORM.gl_account_code")>'#Form.gl_account_code#'<CFELSE>NULL</CFIF>,
					Is_Default					= 	#Form.IS_Default#,
          Display_In = #FORM.Display_In#,
          Is_BB_Default = #FORM.Is_BB_Default#
		WHERE		DD_Reason_Code_ID			=	'#Form.DD_Reason_Code_ID#'
	</CFQUERY>
</CFIF>

<!--- D23133 : Change Request - Bagcraft - Component level exclusions 
If the application switch CreditTypeIsDDReasonCode is ON
Call the routine to refresh the whole table from reason code table
It was easier to just refresh the whole table instead of updating the single record as we want to make sure all records from DD_Reason_Code are in Credit_Type table
This table doesn't usually have many records. 
--->
<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getCreditTypeIsDDReasonCode()>
	<cfstoredproc procedure="Refresh_Credit_Type_From_Reason_Code" datasource="#application.datasource#">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@DD_Reason_Code_ID" null="yes" />
		<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@DD_Reason_Code" null="yes" />
		<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@DD_Reason_Code_Description" null="yes" />
		<cfprocparam type = "In" CFSQLType ="CF_SQL_BIT" dbVarName = "@Refresh_All" null="no" value="1">     
    </cfstoredproc>
</cfif>

<CFLOCATION URL="create_Reason_Code.cfm" ADDTOKEN="No">