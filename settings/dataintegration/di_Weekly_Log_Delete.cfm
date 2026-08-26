
<CFPARAM NAME="FORM.Log" 	DEFAULT="">
<CFPARAM NAME="FORM.ID" 	DEFAULT="">
<CFPARAM NAME="FORM.Delete_All" 	DEFAULT="0">


<CFINCLUDE template="di_weekly_Log_System_Admin.cfm">

<CFIF Current_User_Is_SysAdmin>
	<CFIF NOT isDefined("DI_IncludeFile")>
		<CFINCLUDE template="diLog_Include.cfm">
	</CFIF>
	
	<CFIF Len(Trim(FORM.Log)) GT 0>
		<CFSET logIndex = ListFindNoCase(logItems, FORM.Log, ",")>
		<CFSET logItemName = FORM.Log>
		<CFIF logIndex Gt 0>
			<CFSET IDField = Evaluate("Original_DB_ID_#logItemName#")>
				
			<CFSET weeklyLogTable = ListGetAt(originalDB, logIndex, ",")>
			<CFIF FORM.Delete_All EQ 1>
				<CFQUERY NAME="Q_Weekly_log_Entry_Detail" DATASOURCE="#application.datasource#">
					UPDATE	#weeklyLogTable#
					SET		Deleted = 1
					WHERE
							Weekly_Check >= #Weekly_log_Max_Count#
				</CFQUERY>
			<CFELSE>
			
				<CFINCLUDE template="Paging_Retain_Old_Values.cfm">				
				
				<CFLOOP INDEX="ThisID" LIST="#FORM.EXISTING_ID#" DELIMITERS=",">
				<CFQUERY NAME="Q_Weekly_log_Entry_Detail" DATASOURCE="#application.datasource#">
					UPDATE	#weeklyLogTable#
					SET		Deleted = 1
					WHERE
							#IDField# = '#ThisID#'					
							AND
							Weekly_Check >= #Weekly_log_Max_Count#
				</CFQUERY>
				</CFLOOP>
			</CFIF>
		</CFIF>
	</CFIF>
</CFIF>	

<CFPARAM NAME="FORM.startrow" 	DEFAULT="1">
<CFPARAM NAME="FORM.frompage" 	DEFAULT="1">
<CFOUTPUT>
<FORM ACTION="di_Weekly_log_Details_Step1.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#FORM.startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#FORM.frompage#">
<INPUT TYPE="Hidden" NAME="Log" VALUE="#FORM.Log#">
</FORM>


<SCRIPT LANGUAGE="JavaScript">
	document.MyForm.submit();
</SCRIPT>
</CFOUTPUT>

