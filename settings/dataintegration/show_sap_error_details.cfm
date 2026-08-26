<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>SAP Error Details</title>
</head>

<body>
<cfparam name="url.CID" default="">
<cfparam name="url.type" default="R"><!--- rebate --->
<cfif url.CID NEQ "">
<cfif Type EQ "R">
<cfset useLakebaseForTheQuery = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_webservices_error_detail")>
<cfif useLakebaseForTheQuery>
	<cftry>
		<cfset TheQuery = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_webservices_error_detail", {
				"deleted" = "eq.0",
				"bsa_program_id" = "eq.#url.CID#",
				"message_type" = "eq.E",
				"select" = "message_text,bsa_program_id"
			}), "message_text,bsa_program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForTheQuery = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForTheQuery>
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
	select distinct message_text,bsa_program_id
	from
	Program_Webservices_Error_Detail
	where Program_Webservices_Error_Detail.deleted = 0
	and Program_Webservices_Error_Detail.bsa_program_id = '#url.CID#'
	and Program_Webservices_Error_Detail.message_type = 'E'
</CFQUERY>
</cfif>
<cfelse> <!--- it is a settlement --->
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
	select distinct message_text,RESP.Rebate_ID as bsa_program_id
	from
	Settlement_WebService_Response RESP
	where RESP.Rebate_ID = '#url.CID#'
	and RESP.message_type = 'E'
</CFQUERY>
</cfif>
	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Rebate <cfoutput>#url.CID#</cfoutput> Error Details</B></TD>
	</TR>
</TABLE>
	<cfif TheQuery.recordcount GT 0>
		<div align="center">
		<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
		<TR>
			<TD align="center" STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Messages</B></TD>
		</TR>
		<cfloop query="TheQuery">
		<cfoutput><TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#TheQuery.message_text#</TD>
		</TR></cfoutput>
		</cfloop>
		</table>
		</div>
	<cfelse>
		<div align="center"><font size="2" color="red">No Data.</font> </div>
	</cfif>
<cfelse>
	<div align="center"><font size="2" color="red">No Data.</font> </div>
</cfif>

<HR color="orange">
<div align="center"><B><font color="FF0000">[</font> <a onclick="javascript:window.close()" STYLE="cursor: pointer;">Close Window</a> <font color="FF0000">]</font></B></div>
</body>
</html>

