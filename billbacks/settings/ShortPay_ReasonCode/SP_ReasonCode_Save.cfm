
<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_shortpay_reason")>
<cfif useLakebaseFordelete_Data>
	<cftry>
		<cfset application.oLakebase.deleteRows("bb_shortpay_reason", {
			"bb_shortpay_reason_id" = "eq.#Form.RID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelete_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelete_Data>
<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM BB_ShortPay_Reason  
		WHERE		BB_ShortPay_Reason_ID			=	'#Form.RID#'
	</CFQUERY>
</cfif>	
</CFIF>

<CFIF Form.RID EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_shortpay_reason")>
<cfif useLakebaseForSave_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("bb_shortpay_reason", {
			"sp_reason_code" = "#FORM.SP_Reason_Code#",
			"sp_reason_description" = "#Form.SP_Reason_Description#",
			"deleted" = "#Form.Deleted#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Data>
<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		BB_ShortPay_Reason
						(SP_Reason_Code,SP_Reason_Description,Deleted)
		Values			('#FORM.SP_Reason_Code#','#Form.SP_Reason_Description#',#Form.Deleted#)
	</CFQUERY>
</cfif>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		BB_ShortPay_Reason
		
		SET 		SP_Reason_Code			=	'#FORM.SP_Reason_Code#',
					SP_Reason_Description 	=	'#Form.SP_Reason_Description#',
					Deleted					=	#Form.Deleted#
					
		WHERE		BB_ShortPay_Reason_ID		=	'#Form.RID#'
	</CFQUERY>
</CFIF>

<CFLOCATION URL="SP_ReasonCode.cfm" ADDTOKEN="No">
<CFABORT>