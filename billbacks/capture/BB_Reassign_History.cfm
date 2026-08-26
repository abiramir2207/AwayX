<!-----------------------------------------------------------------------------

FILE NAME:		BB_Reassign_History.cfm
DESCRIPTION:		 
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao		8-Feb-2018		Created
------------------------------------------------------------------------------> 

<cfparam name="url.Billback_ID" default="0" >
<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" bgcolor="#A7CAF2" WIDTH="100%" HEIGHT="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;">
		<SPAN STYLE="color:white; font-size:14px; font-weight: bold; padding-left:5px;"><CFOUTPUT>Reassign History</CFOUTPUT></SPAN>
	</TD>
</TR>
</TABLE>

<br>
	<cfquery name="BB_Reassign_History" datasource="#Application.Datasource#">
		SELECT 
			BB.BB_Code,
			BB.BB_Title,
			BB.BB_Reference,
			ISNULL(U.Name_first +' '+ U.Name_last,'N/A') AS Reassigned_By,
			UP1.Position_Label AS Reassigned_By_Position,
			ISNULL(FU.Name_first +' '+ FU.Name_last,'N/A') AS Previous_Analyst,
			UP2.Position_Label AS Previous_Analyst_Position,
			ISNULL(TU.Name_first +' '+ TU.Name_last,'N/A') AS Current_Analyst,
			UP3.Position_Label AS Current_Analyst_Position,
			BBR.Created_Date
			FROM BB_Reassign BBR
	
			/* Reassigned by */
			LEFT JOIN _USERS U
			ON U.User_id = BBR.By_User_ID
			LEFT JOIN user_positions UP1
			ON UP1.User_Positions_ID = (SELECT TOP 1 User_positions_ID FROM User_Position_Holders WHERE User_Position_Type = 'P' AND User_ID = U.User_ID)
	
			/* Previous Analyst */
			LEFT JOIN _USERS FU
			ON FU.User_id = BBR.From_User_ID
			LEFT JOIN user_positions UP2
			ON UP2.User_Positions_ID = (SELECT TOP 1 User_positions_ID FROM User_Position_Holders  WHERE User_Position_Type = 'P' AND User_ID = FU.User_ID)
	
			/* Current Analyst */
			LEFT JOIN _USERS TU
			ON TU.User_id = BBR.To_User_ID
			LEFT JOIN user_positions UP3
			ON UP3.User_Positions_ID = (SELECT TOP 1 User_positions_ID FROM User_Position_Holders  WHERE User_Position_Type = 'P' AND User_ID = TU.User_ID)
	
			INNER JOIN dbo.Billback BB
			ON BB.Billback_ID = BBR.Billback_ID
		WHERE  
			BBR.Billback_ID = '#url.Billback_ID#'
		ORDER BY  
			BBR.Created_Date DESC
	</cfquery>

		<TABLE align="center" border="0" width="100%" CELLSPACING="0" cellpadding="2">
			<TR style="font-size:12px;font-weight:bold;height:25px;background-color:ffce84">
				<TD>Payable</TD>
				<TD>Title</TD>
				<TD>Previous Analyst<br>Previous Position</TD>
				<TD>Analyst<br>Position</TD>
				<TD>Reassigned By</TD>
				<TD>Reassigned Date</TD>
			</TR>
		<cfif BB_Reassign_History.recordcount GTE 1>
			<cfset RSP_Previous = "N/A">
			<cfset Position_Label_Previous = "N/A">
			<cfset i= 1>
			<cfoutput query="BB_Reassign_History" >
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" style="font-size:11px;">
				<TD>#BB_Code#</TD>
				<TD>#BB_Title#</TD>
				<TD>#Previous_Analyst#<br>#Previous_Analyst_Position#</TD>
				<TD>#Current_Analyst#<br>#Current_Analyst_Position#</TD>
				<TD>#Reassigned_By#</TD>
				<TD>#dateformat(Created_Date, 'MM/DD/YYYY') # #timeformat(Created_Date, 'hh:mm tt') #</TD>
			</TR>
			</cfoutput>
		<cfelse>
			<TR>
				<TD COLSPAN="100%" align="center"><B>No Reassign History.</B></TD>
			</TR>
		</cfif>
		</TABLE>