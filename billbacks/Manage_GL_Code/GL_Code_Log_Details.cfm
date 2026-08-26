<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfset useLakebaseForGetLogDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_activation_log")>
<cfif useLakebaseForGetLogDetails>
	<cftry>
		<cfset GetLogDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_activation_log", {
				"gl_code_activation_log_id" = "eq.#GL_Code_Activation_Log_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLogDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLogDetails>
<CFQUERY NAME="GetLogDetails" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Gl_Code_Activation_Log WHERE GL_Code_Activation_Log_ID = '#GL_Code_Activation_Log_ID#'
</CFQUERY>
</cfif>

<BR>
<CFOUTPUT>
<B><FONT COLOR="red" SIZE="2">[ </FONT><A Href="index.cfm?show_tab=#URL.Show_Tab#">back to log list</A><FONT COLOR="red" SIZE="2"> ]</FONT></B>

<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
	<TR>
		<TD COLSPAN="100%">&nbsp;</TD>
	</TR>
	<TR>		
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<FONT COLOR="Red"><B>Invalid Reason:</B></FONT></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><FONT COLOR="Red"><B>#GetLogDetails.InvalidReason#</B>&nbsp;&nbsp;</FONT></TD>		
	</TR>
	<TR BGCOLOR="C6FFC6">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>A/R:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.A_R#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="ffffff">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>A/R DESCRIPTION:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.A_R_DESCRIPTION#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="C6FFC6">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>APPROP:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.APPROP#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="ffffff">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>Allocation:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.Allocation#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="C6FFC6">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>FIRST SHIP:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.FIRST_SHIP#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="ffffff">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>LAST SHIP:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.LAST_SHIP#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="C6FFC6">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>COMPANY:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.COMPANY#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="ffffff">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>LOCATION:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.LOCATION#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="C6FFC6">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>COST CENTER:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.COST_CENTER#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="ffffff">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>NATURAL ACCT:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.NATURAL_ACCT#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="C6FFC6">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>CHANNEL:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.CHANNEL#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="ffffff">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>PRODUCT GROUP:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.PRODUCT_GROUP#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="C6FFC6">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>IDC:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.IDC#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="ffffff">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>FUND TYPE:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.FUND_TYPE#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="C6FFC6">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>MERCH TYPE:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.MERCH_TYPE#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="ffffff">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>PRO TERM:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.PRO_TERM#&nbsp;&nbsp;</TD>
	</TR>
	<TR BGCOLOR="C6FFC6">	
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>FUND NUMBER:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.FUND_NUMBER#&nbsp;&nbsp;</TD>
	</TR>	
	<TR BGCOLOR="ffffff">
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;&nbsp;<B>DESCRIPTION:</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#GetLogDetails.DESCRIPTION#&nbsp;&nbsp;</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%">&nbsp;</TD>
	</TR>
</TABLE>
</CFOUTPUT>
</body>
</html>
