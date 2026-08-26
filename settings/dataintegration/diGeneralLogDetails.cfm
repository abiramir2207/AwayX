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
<CFSET helpfilenumber=38>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT LANGUAGE="Javascript">
</SCRIPT>

<CFSET diThisPage="#diGeneralLogDetailsPage#">
<CFINCLUDE template="diHeader.cfm">

<CFPARAM NAME="URL.thisPage" DEFAULT=1>

	<CFOUTPUT>
		<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">
				<A HREF="#diLogPage#">
					back
				</A>
		</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
	</CFOUTPUT>

<TABLE ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="95%">
<TR>
<TD><span id="error_logDetails"></span></TD>
</TR>
<TR>
<TD>
	<TABLE CELLSPACING="0" CELLPADDING="4" BORDER="0" ALIGN="CENTER" WIDTH="90%">
<cfoutput>
<cfset anyRecord=false>
		
		<!---------------Show the whole list of entry in tables------------------>
		<cfset useLakebaseForq_diLogData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_log")>
<cfif useLakebaseForq_diLogData>
	<cftry>
		<cfset q_diLogData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("data_integration_log", {
				"data_integration_msgtype" = "eq.user"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForq_diLogData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForq_diLogData>
<CFQUERY NAME="q_diLogData" datasource="#application.datasource#">
			SELECT *
		    FROM Data_Integration_Log
			Where Data_Integration_MsgType='user'
		</CFQUERY>
</cfif>
		<CFIF q_diLogData.recordCount GT 0>
			<cfset pageLen=50>
			<cfset thisPage=Val(URL.thisPage)>
			<cfset lStartRow=((thisPage-1)*pageLen)+1>			
			<cfif lStartRow GT q_diLogData.recordCount>
				<cfset thisPage=1>
				<cfset lStartRow=1>
			</cfif>
			<cfset lEndRow=thisPage*pageLen>
		
			<cfset pageCount=(q_diLogData.recordCount \ pageLen) + 1>
			<CFIF pageCount GT 1>
			<TABLE ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="1">
				<TR>
					<TD>
					<cfloop index="j" from="1" to="#pageCount#">
						<cfif thisPage EQ j>
							&nbsp;<b>#j#</b>&nbsp;
						<cfelse>
							&nbsp;<a href="#diGeneralLogDetailsPage#?logitem=#logItemName#&thisPage=#j#">#j#</a>&nbsp;
						</cfif>
					</cfloop>
					</TD>
				</TR>
			</TABLE>
			</CFIF>
			
			<BR>
			<TABLE ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="100%">
			<caption><b>Data Integration General Log</b></caption>
			<TR BGCOLOR="##FFCE84">
			<TD>##</TD>			
			<TD ALIGN="LEFT"><b>Message</b></TD>
			<TD ALIGN="LEFT"><b>Date</b></TD>
			</TR>
			
			<cfloop query="q_diLogData" startrow="#lStartRow#" endrow="#lEndRow#">
				<TR<cfif (q_diLogData.currentRow mod 2) NEQ 0> BGCOLOR=ccffcc</cfif>>
				<TD style="color:blue">#q_diLogData.currentRow#</TD>
				<TD style="color:blue" VALIGN="TOP">#Data_Integration_Message# <b>(#Data_Integration_Name#)</b></TD>
				<TD style="color:blue" VALIGN="TOP">#Created_Date#</TD>
				</TR>
				<cfset anyRecord=true>
			</cfloop>
			</TABLE>
		</CFIF>		
		<!---------------Show the whole list of entry in tables------------------>
<CFIF NOT anyRecord>
	<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<FONT SIZE="2"><B>
		No Data Integration General Log entry
		</B></FONT>
		</TD>
		</TD>
		</TR>
	</TABLE>
</CFIF>

</cfoutput>
	</TABLE>	
</TD>
</TR>
</TABLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_MessageWindow>
<CFIF isDefined("sPageErr")>
	<SCRIPT LANGUAGE="JavaScript">
		showError();		
	</SCRIPT>
</CFIF>
</BODY>
</HTML>
