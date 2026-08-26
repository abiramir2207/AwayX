

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("holidays")>
<cfif useLakebaseFordelete_Data>
	<cftry>
		<cfset application.oLakebase.deleteRows("holidays", {
			"holiday_id" = "eq.#Form.Holiday_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelete_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelete_Data>
<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM Holidays  
		WHERE		Holiday_ID			=	'#Form.Holiday_ID#'
	</CFQUERY>
</cfif>
	<CFLOCATION URL="create_Holidays.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- Check for the presence of data --->
<CFIF 	trim(Form.Holiday_Desc) EQ "" OR trim(Form.Holiday_Desc) EQ 0
		OR trim(Form.Holiday_Date) EQ "" 
		>
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>



<CFIF Form.Holiday_ID EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("holidays")>
<cfif useLakebaseForSave_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("holidays", {
			"holiday_desc" = "#Form.Holiday_Desc#",
			"holiday_date" = "#Form.Holiday_Date#",
			"deleted" = "#Form.Deleted#",
			"updated_userid" = "#request.AccessStructure.User_Id#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Data>
<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		Holidays
						(Holiday_Desc,Holiday_Date,Deleted,Updated_UserId)
		Values			('#Form.Holiday_Desc#','#Form.Holiday_Date#',#Form.Deleted#, '#request.AccessStructure.User_Id#')
	</CFQUERY>
</cfif>
	<CFLOCATION URL="create_Holidays.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		Holidays
		SET 		Holiday_Desc 	=	'#Form.Holiday_Desc#',
					Holiday_Date	=	'#Form.Holiday_Date#',
					Deleted			=	#Form.Deleted#,
					Updated_UserId  =   '#request.AccessStructure.User_Id#',
					Updated_Date    =   getdate()
		WHERE		Holiday_ID		=	'#Form.Holiday_ID#'
	</CFQUERY>
	<CFLOCATION URL="create_Holidays.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>