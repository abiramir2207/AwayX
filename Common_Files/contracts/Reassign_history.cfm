<!----
	Name: Reassign_history.cfm
	Copyright (c) 2013 Blacksmith Applications, Inc.
	Description: Used to display Reassign history
	Created On: 06/17/2013
	Label: D37981:Revision of program
---->
<cfparam name="url.contract_number" default="0" >
<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" bgcolor="#A7CAF2" WIDTH="100%" HEIGHT="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;">
		<SPAN STYLE="color:white; font-size:14px; font-weight: bold; padding-left:5px;"><CFOUTPUT>Reassign History</CFOUTPUT></SPAN>
	</TD>
</TR>
</TABLE>

<br>
	<cfquery name="reassign_history" datasource="#Application.Datasource#">
		SELECT CASE WHEN Reassigned_By = '99999999-9999-9999-9999999999999999'
					THEN 'System'
					ELSE ISNULL(U.Name_first +' '+ U.Name_last,'N/A') END AS Name,
			CASE WHEN PO.Responsible_User_ID = '99999999-9999-9999-9999999999999999'
			THEN 'System'
			ELSE ISNULL(RSP.Name_first +' '+ RSP.Name_last,'N/A') END AS RSP_Name,
			ISNULL(UP.Position_Label,'N/A') AS Position_Label,
					PO.Date_Created AS Date, CM.Contract_Title, PO.Contract_Number
		FROM Program_Owner PO
		LEFT JOIN _USERS U
		ON U.User_id = PO.Reassigned_By
		LEFT JOIN _USERS RSP
		ON RSP.User_id = PO.Responsible_User_ID
		LEFT JOIN user_positions UP
		ON UP.User_Positions_ID = PO.Creating_User_position_ID
		INNER JOIN Contract_Main CM
		ON CM.Contract_Main_ID = PO.Contract_Main_ID
		WHERE  PO.Contract_Main_ID =#url.contract_number#
		ORDER BY  PO.Date_Created 
	</cfquery>

		<TABLE align="center" border="0" width="100%" CELLSPACING="0" cellpadding="2">
			<TR style="font-size:12px;font-weight:bold;height:25px;background-color:ffce84">
				<TD>Program</TD>
				<TD>Title[Reference]</TD>
				<TD>Previous RSP<br>Previous Position</TD>
				<TD>RSP <br>Position</TD>
				<TD>Reassigned By</TD>
				<TD>Reassigned Date</TD>
			</TR>
		<cfif reassign_history.recordcount GT 1>

			<cfset i= 1>
			<cfoutput>
				<cfloop from="#reassign_history.recordcount#" to="1" index="RwCount" step="-1">
					<cfif RwCount neq 1>
						<TR BGCOLOR="#IIf(RwCount Mod 2, DE('ffffff'), DE('C6FFC6'))#" style="font-size:11px;">
							<TD>#reassign_history.Contract_Number[RwCount]#</TD>
							<TD>#reassign_history.Contract_Title[RwCount]#</TD>				
							<TD>#reassign_history.RSP_Name[RwCount-1]#<br>#reassign_history.Position_Label[RwCount-1]#</TD>				
							<TD>#reassign_history.RSP_Name[RwCount]#<br>#reassign_history.Position_Label[RwCount]#</TD>
							<TD>#reassign_history.Name[RwCount]#</TD>
							<TD>#dateformat(reassign_history.Date[RwCount], 'MM/DD/YYYY') # #timeformat(reassign_history.Date[RwCount], 'hh:mm tt') #</TD>
						</TR>
					</cfif>
					
				</cfloop>
			</cfoutput>
		<cfelse>
			<TR>
				<TD COLSPAN="100%" align="center"><B>No Reassign History.</B></TD>
			</TR>
		</cfif>
		</TABLE>