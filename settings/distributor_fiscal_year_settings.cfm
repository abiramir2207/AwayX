<CFQUERY NAME="getDistributorFiscalCalendar" datasource="#application.datasource#" MAXROWS=1>
	SELECT Last_Updated,Last_Updated_By_User_ID
	FROM Distributor_Fiscal_Year
	WHERE Deleted = 0
	AND Last_Updated = 
		(SELECT MAX (Last_Updated)
			FROM Distributor_Fiscal_Year)
</CFQUERY>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Fiscal Year</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "SYSTEM ADMINISTRATION: DISTRIBUTOR FISCAL YEAR">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFSET helpfilenumber=32>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---
<B>
<FONT SIZE="2" COLOR="Red">[</FONT>
<FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/Administration/Fiscal/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;">read me first</A></FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
--->
<p></p>
<CFIF getDistributorFiscalCalendar.recordcount EQ 0>
<CFELSE>
	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#getDistributorFiscalCalendar.Last_Updated_By_User_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT *
		FROM _Users
		WHERE User_ID = '#getDistributorFiscalCalendar.Last_Updated_By_User_ID#'
	</CFQUERY>
</cfif>

	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated By &nbsp;<CFOUTPUT>#getUserName.Name_First# #getUserName.Name_Last#</CFOUTPUT> on <CFOUTPUT>#dateformat(getDistributorFiscalCalendar.Last_Updated, 'm/d/yyy')# 
	#timeformat(getDistributorFiscalCalendar.Last_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
	<cfinclude TEMPLATE="distributor_fiscal_year_settings_saved.cfm">
</CFIF>

<BR><BR>


<cfinclude TEMPLATE="distributor_fiscal_year_settings2.cfm">
<!--- 
<IFRAME SRC="fiscal_year_settings2.cfm" WIDTH="600" HEIGHT="400" MARGINWIDTH="10" MARGINHEIGHT="5" FRAMEBORDER="0"></IFRAME>
 --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



