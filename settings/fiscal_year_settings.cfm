<cfquery name="getFiscalCalendar" datasource="#application.datasource#" MAXROWS=1>
	SELECT Last_Updated,Last_Updated_By_User_ID
	FROM Fiscal_Year
	WHERE Deleted = 0
	AND	Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
</cfquery>
<cfset CompanyMainID = request.AccessStructure.Company_Main_ID>

<cfif getFiscalCalendar.recordcount GT 0>
	<!--- CHECK TO SEE IF NAME EXISTS ON FISCAL YEAR, IF NOT THEN CREATE IT --->
	<cfquery name="createNameOnNullCheck" datasource="#application.datasource#">
		SELECT MAX(End_Date) AS End_date, Fiscal_Year
		FROM Fiscal_Year
		WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
			AND Deleted = 0
		GROUP BY Fiscal_Year
	</cfquery>

	<cfif createNameOnNullCheck.recordcount EQ 0>
		<cfquery name="createNameOnNullCheck" datasource="#application.datasource#">
			SELECT MAX(End_Date) AS End_date, Fiscal_Year
			FROM Fiscal_Year
			WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
			GROUP BY Fiscal_Year
		</cfquery>
	</cfif>

	<cfif createNameOnNullCheck.fiscal_year EQ "">
		<cfset periodStDt = dateFormat(createNameOnNullCheck.End_date) - 365>
		<cfset FYTitle = "FY_" & dateFormat(createNameOnNullCheck.End_Date,'yyyy')>
		<cfquery name="createNameOnNullAction" datasource="#application.datasource#">
			UPDATE Fiscal_year
			SET Fiscal_Year = '#FYTitle#'
				,Deleted = 0
			WHERE Company_main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
				AND Start_Date > <cfqueryparam cfsqltype="cf_sql_date" value="#periodStDt#">
		</cfquery>
	</cfif>
</cfif>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "SYSTEM ADMINISTRATION: FISCAL YEAR">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFSET helpfilenumber=32>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<p></p>
<CFIF getFiscalCalendar.recordcount EQ 0>
<CFELSE>
	<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT *
		FROM _Users
		WHERE User_ID = '#getFiscalCalendar.Last_Updated_By_User_ID#'
	</CFQUERY>

	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated By &nbsp;<CFOUTPUT>#getUserName.Name_First# #getUserName.Name_Last#</CFOUTPUT> on <CFOUTPUT>#dateformat(getFiscalCalendar.Last_Updated, 'm/d/yyy')#
	#timeformat(getFiscalCalendar.Last_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
	<cfinclude TEMPLATE="fiscal_year_settings_saved.cfm">
</CFIF>

<BR><BR>


<cfinclude TEMPLATE="fiscal_year_settings2.cfm">
<!--- <IFRAME SRC="fiscal_year_settings2.cfm" WIDTH="600" HEIGHT="400" MARGINWIDTH="10" MARGINHEIGHT="5" FRAMEBORDER="0"></IFRAME>
 --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



