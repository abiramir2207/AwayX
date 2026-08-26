
<CFPARAM NAME="FORM.Show_Operator" DEFAULT="0">
<CFPARAM NAME="Form.Is_Default" DEFAULT="0">

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="qryCanDelete" datasource="#application.datasource#">
		SELECT 	TOP 1 Operator_Type 
		FROM 	BSA_Operator 
		WHERE 	Operator_Type = (SELECT Operator_Type FROM Awayx_Operator_Type WHERE BSA_Operator_Type_ID = #Form.BSA_Operator_Type_ID# AND Deleted = 0) AND Deleted = 0
	</CFQUERY>
 
	<CFIF qryCanDelete.RecordCount GT 0>
		<BR><BR><BR><BR>
		
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD>
					<B><FONT COLOR="Red" SIZE="2">
						Cannot delete this Operator Type as this is associated with an active Operator.
					</FONT></B>
				
				</TD>
			</TR>
		</TABLE>
		<SCRIPT language="JavaScript">
		function relocateThis()
		{
			window.location.href = "select_operators.cfm?tabSetter=2"
		}
		window.setTimeout('relocateThis()', 3000);	
		</SCRIPT>
		
	<CFELSE>
		<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("awayx_operator_type")>
<cfif useLakebaseFordelete_Data>
	<cftry>
		<cfset application.oLakebase.updateRows("awayx_operator_type",
			{
				"bsa_operator_type_id" = "eq.#Form.BSA_Operator_Type_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordelete_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelete_Data>
<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
      UPDATE Awayx_Operator_Type   
      SET Deleted = 1
      WHERE		BSA_Operator_Type_ID			=	'#Form.BSA_Operator_Type_ID#'
		</CFQUERY>
</cfif>
		<CFLOCATION URL="select_operators.cfm?tabSetter=2" ADDTOKEN="No">
	</CFIF>	
	<CFABORT>
</CFIF>
<!--- 
<cfset useLakebaseForIsThereDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("awayx_operator_type")>
<cfif useLakebaseForIsThereDefault>
	<cftry>
		<cfset IsThereDefault = application.oLakebase.toQuery(
			application.oLakebase.selectRows("awayx_operator_type", {
				"is_default" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsThereDefault = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsThereDefault>
<cfquery name="IsThereDefault" datasource="#application.datasource#">
	SELECT * FROM Awayx_Operator_Type WHERE Is_Default = 1 AND Deleted = 0
</cfquery>
</cfif> --->

<!---See if something is already set as default--->
<!--- <cfparam name="SetAsDefault" default="0">
<cfif IsThereDefault.RecordCount IS 0>
	<cfset SetAsDefault = 1>
	<cfset FORM.Is_Default = 1>
</cfif> --->

<!--- remove the default from another entry if necessary --->
<!--- <cfif FORM.Is_Default IS 1>
	<cfset useLakebaseForRemoveDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("awayx_operator_type")>
<cfif useLakebaseForRemoveDefault>
	<cftry>
		<cfset application.oLakebase.updateRows("awayx_operator_type",
			{
				"is_default" = "eq.1"
			},
			{
				"is_default" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForRemoveDefault = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForRemoveDefault>
<cfquery name="RemoveDefault" datasource="#application.datasource#">
	UPDATE Awayx_Operator_Type 
	SET Is_Default = 0
	WHERE Is_Default = 1
	</cfquery>
</cfif>
</cfif> --->


<CFIF ((FORM.BSA_Operator_Type_ID EQ "") OR (FORM.BSA_Operator_Type_ID EQ 0))>
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO	awayX_Operator_Type
		(Operator_Type,
      Business_Segment_ID,
      Active,
      Deleted,
      Created_Date,
      Last_Edited_By
     )
    VALUES ('#FORM.Operator_Type#',1,#FORM.Active#,0,getDate(),'#request.AccessStructure.user_id#'
    )
	</CFQUERY>
	<CFLOCATION URL="select_operators.cfm?tabSetter=2" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		awayX_Operator_Type
		SET 		Operator_Type				=	'#FORM.Operator_Type#',
  					Active						=	#FORM.Active#,
  					Updated_Date				=	getDate(),
            Last_Edited_By      = '#request.AccessStructure.user_id#'
		WHERE		BSA_Operator_Type_ID	=	#FORM.BSA_Operator_Type_ID#
	</CFQUERY>
	<CFLOCATION URL="select_operators.cfm?tabSetter=2" ADDTOKEN="No">
	<CFABORT>
</CFIF>