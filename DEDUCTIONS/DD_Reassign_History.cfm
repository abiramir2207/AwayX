<!-----------------------------------------------------------------------------

FILE NAME:		DD_Reassign_History.cfm
DESCRIPTION:	
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	2/27/2018	 

------------------------------------------------------------------------------> 
<cfparam name="url.Deduction_ID" default="0" >
<cfset Deduction_ID = url.Deduction_ID />
<html>
<head>
	<title>Reassign History</title>
</head>

<body>
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" bgcolor="#A7CAF2" WIDTH="100%" HEIGHT="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;">
		<SPAN STYLE="color:white; font-size:14px; font-weight: bold; padding-left:5px;"><CFOUTPUT>Reassign History</CFOUTPUT></SPAN>
	</TD>
</TR>
</TABLE><br>
<br>
 
	<cfinclude template="/deductions/sql_Deduction_Info.cfm">
	<cfquery name="GetReassignInfo" datasource="#application.datasource#">
	SELECT DISTINCT u.Name_First + ' ' + u.Name_Last As FromWho, u1.Name_First + ' ' + u1.Name_Last As ToWho
	 ,u2.Name_First + ' ' + u2.Name_Last As ByWho, dr.Created_Date,
	UP1.Position_Label AS Reassigned_By_Position,
	  	UP2.Position_Label AS Previous_Analyst_Position,
		UP3.Position_Label AS Current_Analyst_Position
		FROM DD_Reassign dr 
			 INNER JOIN _Users u
					ON u.User_ID = dr.From_Analyst
			 INNER JOIN _Users u1
					ON u1.User_ID = dr.To_Analyst
			 INNER JOIN _Users u2
					ON u2.User_ID = dr.By_Analyst
	
			/* Reassigned by */
				LEFT JOIN _USERS RU
				ON RU.User_id = u2.User_ID
				LEFT JOIN user_positions UP1
				ON UP1.User_Positions_ID = (SELECT TOP 1 User_positions_ID FROM User_Position_Holders WHERE User_Position_Type = 'P' AND User_ID = u2.User_ID)
		
				/* Previous Analyst */
				LEFT JOIN _USERS FU
				ON FU.User_id = u.User_ID
				LEFT JOIN user_positions UP2
				ON UP2.User_Positions_ID = (SELECT TOP 1 User_positions_ID FROM User_Position_Holders  WHERE User_Position_Type = 'P' AND User_ID = u.User_ID)
		
				/* Current Analyst */
				LEFT JOIN _USERS TU
				ON TU.User_id = u1.User_ID
				LEFT JOIN user_positions UP3
				ON UP3.User_Positions_ID = (SELECT TOP 1 User_positions_ID FROM User_Position_Holders  WHERE User_Position_Type = 'P' AND User_ID = u1.User_ID)
	 
	  WHERE dr.Deduction_ID =  '#Deduction_ID#'
	 AND dr.Deleted = 0
	 ORDER BY dr.Created_Date DESC
	</cfquery>
	 			
	<TABLE align="center" border="0" width="100%" CELLSPACING="0" cellpadding="2">
			<TR style="font-size:12px;font-weight:bold;height:25px;background-color:ffce84">
				<TD>Ded Number</TD>
				<TD>Previous RSP<br>Previous Position</TD>
				<TD>RSP <br>Position</TD>
				<TD>Reassigned By</TD>
				<TD>Reassigned Date</TD>
			</TR>
		<cfif GetReassignInfo.Recordcount neq 0>
			<!--- <cfset RSP_Previous = "N/A">
			<cfset Position_Label_Previous = "N/A">
			<cfset i= 1> --->
			<cfoutput query="GetReassignInfo" >
			<!--- <cfif i neq 1> --->
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" style="font-size:11px;">
				<TD>#Deduction_Info.DD_DedID_SP_Number#</TD>
				<TD>#FromWho#<br>#Previous_Analyst_Position#</TD>
				<TD>#ToWho#<br>#Current_Analyst_Position#</TD>
				<TD>#ByWho#</TD>
				<TD>#dateformat(Created_Date, 'MM/DD/YYYY') # #timeformat(Created_Date, 'hh:mm tt') #</TD>
			</TR>
				<!---</cfif>
		 <cfset RSP_Previous = #FromWho#>
			<cfset Position_Label_Previous = #Previous_Analyst_Position#>
			<cfset i= i+1>---> 
			</cfoutput>
		<cfelse>
			<TR>
				<TD COLSPAN="100%" align="center"><B>No Reassign History.</B></TD>
			</TR>
		</cfif>
		</TABLE>			
	 
</body>
</html>
