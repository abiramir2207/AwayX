<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>


<CFOUTPUT>
<CFQUERY NAME = "Check_label" DATASOURCE = "#Application.Datasource#">
	SELECT column_name FROM information_schema.columns 
	WHERE table_name = 'Group_Labels' AND column_name like 'approval_group_count_%_label'
	ORDER BY Column_Name 
</CFQUERY>
<CFSET ch_recordcount = Check_label.recordcount>
<CFSET ch_recordcount_less = ch_recordcount - 1>

<CFIF FORM.Approval_Group_Count GT Check_label.recordcount>
		<CFSET FROMVALUE = Check_label.recordcount + 1>
		<CFLOOP INDEX = "loopcount" FROM = "#FROMVALUE#" TO = "#FORM.Approval_Group_Count#">
			<CFIF loopcount GT 99>
				<CFSET LABEL = "Approval_Group_Count_#loopcount#_Label">
			<CFELSEIF loopcount GT 9>
				<CFSET LABEL = "Approval_Group_Count_0#loopcount#_Label">
			<CFELSE>
				<CFSET LABEL = "Approval_Group_Count_00#loopcount#_Label">
			</CFIF>

			<CFQUERY NAME = "add_column" DATASOURCE = "#Application.Datasource#">
				ALTER TABLE Group_Labels ADD #LABEL# nvarchar(50)
			</CFQUERY>   
		</CFLOOP>
	</CFIF>


	


<CFIF FORM.Group_ID EQ "">
	<CFQUERY NAME = "Sava_data" DATASOURCE = "#Application.Datasource#">
		INSERT INTO GROUP_LABELS
			(		<CFLOOP INDEX = "loopcount" FROM = "1" TO = "#FORM.Approval_Group_Count#">
						<CFIF loopcount GT 99>
							<CFSET LABEL = "Approval_Group_Count_#loopcount#_Label">
						<CFELSEIF loopcount GT 9>
							<CFSET LABEL = "Approval_Group_Count_0#loopcount#_Label">
						<CFELSE>
							<CFSET LABEL = "Approval_Group_Count_00#loopcount#_Label">
						</CFIF>
						#LABEL#,
					</CFLOOP>	
					Approval_Group_Count, LastUpdated_UserId)
			
		VALUES
			(		<CFLOOP INDEX = "loopcount" FROM = "1" TO = "#FORM.Approval_Group_Count#">
						<CFIF loopcount GT 99>
							<CFSET LABEL = "Approval_Group_Count_#loopcount#_Label">
						<CFELSEIF loopcount GT 9>
							<CFSET LABEL = "Approval_Group_Count_0#loopcount#_Label">
						<CFELSE>
							<CFSET LABEL = "Approval_Group_Count_00#loopcount#_Label">
						</CFIF>
						<CFSET Label_value = #Evaluate("FORM.#Label#")#>
						'#Label_Value#',
					</CFLOOP>	
					#FORM.Approval_Group_Count#, '#request.AccessStructure.User_Id#')	
	</CFQUERY>
	
<CFELSE>

	<CFQUERY NAME = "Update_to_null" DATASOURCE = "#Application.Datasource#">
		UPDATE GROUP_LABELS 
		SET 	<CFLOOP INDEX = "loopcount" FROM = "1" TO = "#ch_recordcount#">
						<CFIF loopcount GT 99>
							<CFSET LABEL = "Approval_Group_Count_#loopcount#_Label">
						<CFELSEIF loopcount GT 9>
							<CFSET LABEL = "Approval_Group_Count_0#loopcount#_Label">
						<CFELSE>
							<CFSET LABEL = "Approval_Group_Count_00#loopcount#_Label">
						</CFIF>
						#LABEL# = NULL,
					</CFLOOP>	
					Approval_Group_Count = NULL,
					LastUpdated_UserId  		=   '#request.AccessStructure.User_Id#',
					LastUpdated_Date     		=   getdate()
		WHERE Group_ID = #FORM.Group_ID#					
	</CFQUERY>	


	<CFQUERY NAME = "Update_data" DATASOURCE = "#Application.Datasource#">
		UPDATE GROUP_LABELS
		SET
					<CFLOOP INDEX = "loopcount" FROM = "1" TO = "#FORM.Approval_Group_Count#">
						<CFIF loopcount GT 99>
							<CFSET LABEL = "Approval_Group_Count_#loopcount#_Label">
						<CFELSEIF loopcount GT 9>
							<CFSET LABEL = "Approval_Group_Count_0#loopcount#_Label">
						<CFELSE>
							<CFSET LABEL = "Approval_Group_Count_00#loopcount#_Label">
						</CFIF>
						<CFSET Label_value = #Evaluate("FORM.#Label#")#>
						#LABEL# = '#Label_Value#',
					</CFLOOP>	
					Approval_Group_Count = '#FORM.Approval_Group_Count#',
					LastUpdated_UserId  		=   '#request.AccessStructure.User_Id#',
					LastUpdated_Date   		=   getdate()
		WHERE Group_ID = #FORM.Group_ID#	
			
	</CFQUERY>
</CFIF>

<CFSET loop = 1>
<CFLOOP INDEX = "CountLoop" FROM = "#ch_recordcount#" TO = "1" STEP = "-1">
	<CFIF CountLoop GT 99>
		<CFSET LABEL = "Approval_Group_Count_#CountLoop#_Label">
	<CFELSEIF CountLoop GT 9>
		<CFSET LABEL = "Approval_Group_Count_0#CountLoop#_Label">
	<CFELSE>
		<CFSET LABEL = "Approval_Group_Count_00#CountLoop#_Label">
	</CFIF>
	
	<CFQUERY NAME = "CheckExtra" DATASOURCE = "#Application.Datasource#">
		SELECT *
		FROM Group_Labels 
		WHERE #Label# is not null	
	</CFQUERY>
	<CFIF CheckExtra.recordcount EQ 0>
		<CFQUERY NAME = "Deleteextra" DATASOURCE = "#Application.Datasource#">
			ALTER TABLE Group_Labels DROP COLUMN #Label#
		</CFQUERY>
		<CFSET loop = 1>
	<CFELSE>
		<CFSET loop = 0>
	</CFIF> 
	<CFIF loop EQ 0>
		<CFBREAK>
	</CFIF>
</CFLOOP>
</CFOUTPUT>

<BR><BR><BR><BR><BR>

<TABLE ALIGN = "center">
	<TR>
		<TD>Wait while the record is being saved...</TD>
	</TR>
</TABLE>

<SCRIPT LANGUAGE="JavaScript">
function goBackToOtherPage()
{
		window.location.href = "group_details.cfm";
}
window.setTimeout('goBackToOtherPage()', 2000);
</SCRIPT>


<!--- <CFLOCATION url="Group_details.cfm" addtoken="No"> --->
</body>
</html>
<cfinclude template="/settings/CUSTOMER_SETTINGS/Memory_Data/render_files.cfm">
