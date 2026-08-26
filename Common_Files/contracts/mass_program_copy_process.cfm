<!---
	FILENAME:	mass_program_copy_process.cfm
	Copyright:	(c) 2008 Blacksmith Applications, Inc.
	CREATED BY:	Tim Ford
--->

<CFTHREAD ACTION="RUN" NAME="MPC_#variables.massProgramCopyID#">
<cfstoredproc procedure="USP_Mass_Copy" datasource="#Application.Datasource#">
	<cfprocparam type="In" cfsqltype="CF_SQL_INTEGER" variable="@@Mass_Program_Copy_ID" null="no" value="#variables.massProgramCopyID#" />
	<cfprocparam type="In" cfsqltype="CF_SQL_INTEGER" variable="@@Program_ID" 			null="no" value="#form.Program_ID#" />
	<cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" variable="@@Created_By" 			null="no" value="#request.accessstructure.User_ID#" />
</cfstoredproc>


<cfoutput>

<cfquery name="qGetMassCopyData" datasource="#application.datasource#">
	SELECT	Created_Date,
			_Users.Name_First + ' ' + _Users.Name_Last AS Mass_Copy_Created_By,
			_Users.User_Email
	FROM	Mass_Program_Copy
			INNER JOIN _Users ON
			_Users.User_ID = Mass_Program_Copy.Created_By
	WHERE	Mass_Program_Copy_ID = #variables.massProgramCopyID#
</cfquery>


<cfquery name="qGetMassCopiedPrograms" datasource="#application.datasource#">
	SELECT	Mass_Program_Copy_Distributor.Program_Number,
			Mass_Program_Copy_Distributor.Program_Title,
			Mass_Program_Copy_Distributor.Program_Start_Date,
			Mass_Program_Copy_Distributor.Program_End_Date,
			Contract_Status_Types.Contract_Status_Type_Desc,
			Contract_Main.Contract_Main_ID
	FROM	Mass_Program_Copy_Distributor
			INNER JOIN Contract_Main ON
			Contract_Main.Contract_Main_ID = Mass_Program_Copy_Distributor.Program_ID
			INNER JOIN Contract_Status_Types ON
			Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
	WHERE	Mass_Program_Copy_ID = #variables.massProgramCopyID#
	AND		Copied = 1
</cfquery>

<cfquery name="qGetSystemAdmin" datasource="#application.datasource#">
	SELECT	TOP 1 User_Email
	FROM 	_Users
	WHERE 	Is_System_Administrator = 1
	AND		Deleted = 0
</cfquery>

<!---Loop over Mass Copied Programs and send out RFA emails--->
<cfloop query="qGetMassCopiedPrograms">
	<cfset Contract_Main_ID = qGetMassCopiedPrograms.Contract_Main_ID />
	<cfinclude template="/ANYTHING_AUTOMATED/EMAIL/rfa_program_emailer.cfm">	
</cfloop>
	
	<cfsavecontent variable="variables.massProgramCopy">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<style>
		.tableheaders
		{
			font-size:13px;
			font-weight:bold;
			border-bottom:thin ##FFFFFF 0px; 
				
		}	
		BODY, TD, .normal
		{
			font-family : Arial;
			font-size : 8pt;
			color : Black;
		}
		TABLE.Maintable TD 
		{
			border-bottom:solid ##93BEE2 1px; font-size : 10px;
		}
		.normal
		{
			font-family : Arial;
			font-size : 8pt;
			color : Black;
		}	
	</style>
	<title>Mass Program Copy</title>
	</head>
	<body>
		<p>
			<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'">
				The following programs were created on #dateFormat(qGetMassCopyData.Created_Date, "mm/dd/yyyy")# at #timeFormat(qGetMassCopyData.Created_Date, "full")# by #qGetMassCopyData.Mass_Copy_Created_By#
			</span>
		</p>
		<table cellspacing="0" cellpadding="0" width="100%">
			<tr>
				<td><span class="tableheaders">Program Number</span></td>
				<td><span class="tableheaders">Program Title</span></td>
				<td><span class="tableheaders">Program Start Date</span></td>
				<td><span class="tableheaders">Program End Date</span></td>
				<td><span class="tableheaders">Program Status</span></td>
			</tr>
			<cfloop query="qGetMassCopiedPrograms">
				<tr>
					<td>#Program_Number#</td>
					<td>#Program_Title#</td>
					<td>#dateFormat(Program_Start_Date, "mm/dd/yyyy")#</td>
					<td>#dateFormat(Program_End_Date, "mm/dd/yyyy")#</td>
					<td nowrap="nowrap">#Contract_Status_Type_Desc#</td>
				</tr>
			</cfloop>
		</table>	
	</body>
	</html>
	</cfsavecontent>

	<CF_EMAILWRAPPER  	
		TO 			= "#qGetMassCopyData.User_Email#"
		FROM		= "#qGetSystemAdmin.User_Email#"
		SUBJECT		= "Mass Program Copy"
		TYPE		= "html" 
		messagetype	= "1" 
		generatedby	= "1"
		appArea		= "1"
	>
		#variables.massProgramCopy#
	</CF_EMAILWRAPPER>
</cfoutput>
</CFTHREAD>