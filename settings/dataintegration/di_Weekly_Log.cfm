<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	


</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<CFIF NOT isDefined("DI_IncludeFile")>
	<CFINCLUDE template="diLog_Include.cfm">
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR>
<CFSET diThisPage="Weekly_Log">
<CFINCLUDE template="diHeader.cfm">

<CFSET counter=1>
<BR>
<TABLE CELLSPACING="0" CELLPADDING="4" BORDER="0" ALIGN="CENTER" WIDTH="80%">
<CAPTION STYLE="font-size:12px;font-weight:bold;" ALIGN="center">
Weekly Log
</CAPTION>
<CFLOOP LIST="#originalDB#" DELIMITERS="," INDEX="thisTable">
	<CFSET LogItemName=ListGetAt(logItems, counter, ",")>
	<CFIF NOT ListFindNoCase(Weekly_Log_Exclude_list, LogItemName, ",")>
	<CFOUTPUT>
	<!------#Evaluate("DB#LogItemName#Fields")#----->
	<CFSET logItemName=ListGetAt(logItems, counter, ",")>
	<CF_DI_CUST_SETTING_NAME 
			DI_keyword="#logItemName#" 
			ReturnField="Cust_Setting_Item_Name">
	<CFQUERY NAME="Q_Weekly_log_Count" DATASOURCE="#application.datasource#">
		SELECT	count(*) AS Weekly_Log_Exist
		FROM	#thisTable#
		WHERE
				Weekly_Check >= #Weekly_log_Max_Count#
				AND
				Deleted = 0
	</CFQUERY>
	<CFIF Q_Weekly_log_Count.Weekly_Log_Exist GT 0>
	<A HREF="di_Weekly_Log_Details_Step1.cfm?Log=#LogItemName#">
	</CFIF>
	<TR<cfif (counter mod 2) NEQ 1> BGCOLOR="ccffcc"<CFELSE> BGCOLOR="ffffff"</cfif><CFIF Q_Weekly_log_Count.Weekly_Log_Exist GT 0> STYLE="cursor:pointer"</CFIF>>
		<TD>&nbsp;</TD>
		<TD><B>
		<CFIF Q_Weekly_log_Count.Weekly_Log_Exist GT 0><A HREF="di_Weekly_Log_Details_Step1.cfm?Log=#LogItemName#"></CFIF>
		#Cust_Setting_Item_Name#
		<CFIF Q_Weekly_log_Count.Weekly_Log_Exist GT 0></A></CFIF></B></TD>		
		<TD>#Q_Weekly_log_Count.Weekly_Log_Exist#</TD>
	</TR>
	<CFIF Q_Weekly_log_Count.Weekly_Log_Exist GT 0></A></CFIF>
	</CFOUTPUT>
	</CFIF>
	<CFSET counter=counter+1>
</CFLOOP>
</TABLE>

</BODY>
</HTML>
