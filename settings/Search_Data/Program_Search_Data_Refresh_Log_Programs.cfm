<!---
Program_Search_Data_Refresh_Log_Programs.cfm
--->
<cfif isDefined("form.id") and IsNumeric(form.id)>

	<cfquery name="getProgramSearchDatRefreshLogPrograms" datasource="#application.datasource#">
		SELECT	DISTINCT 
				Contract_Main.Contract_Main_ID, Contract_Number, 
				Replace(Contract_Number, '000-', '') + (CASE WHEN Contract_Status_Type_IDX > 2 THEN '-' + CASE
									WHEN LEN(revision_version) = 4 THEN RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 4)
									WHEN LEN(revision_version) = 5 THEN RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 3)
								END ELSE '' END) as Contract_Number_Display,
				Current_Action
		FROM	Program_Search_Data_Refresh_Process_History
		INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Program_Search_Data_Refresh_Process_History.Contract_Main_ID  
		WHERE	Program_Search_Data_Refresh_Log_Detail_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.id#">
	 </cfquery>
	
	<table cellpadding="2" cellspacing="0" border="0" width="500" CLASS="Maintable" align="center">
		<tr BGCOLOR="FFCE84">
			<td ID="header"><b>Program</b></td>
			<td ID="header"><b>Action</b></td>			
		</tr>
	<cfoutput>
	<cfloop query="getProgramSearchDatRefreshLogPrograms">
		<CFIF currentrow mod 2>
			<CFSET BG_COLOR = "white">
		<CFELSE>
			<CFSET BG_COLOR = "ccffcc">
		</CFIF>
		<tr bgcolor="#BG_COLOR#">
			<td>#Contract_Number_Display#</td>
			<td>#Current_Action#</td>
		</tr>
	</cfloop>
	</cfoutput>

</cfif>