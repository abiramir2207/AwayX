<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>SAP Reference Numbers</title>
</head>

<body>
<cfparam name="url.CID" default="">
<cfif url.CID NEQ "">
<cfset useLakebaseForgetprogramsapdetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetprogramsapdetails>
	<cftry>
		<cfset getprogramsapdetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#url.CID#",
				"select" = "sent_to_external_client,error_from_external_client,contract_status_type_idx,contract_number"
			}), "sent_to_external_client,error_from_external_client,contract_status_type_idx,contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetprogramsapdetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetprogramsapdetails>
<CFQUERY NAME="getprogramsapdetails" datasource="#application.datasource#">
	select Sent_To_External_Client,error_from_external_client,contract_status_type_idx,contract_number
	from contract_main
	where contract_main_id = #url.CID#
</CFQUERY>
</cfif>
<cfif (getprogramsapdetails.Sent_To_External_Client EQ 1 and getprogramsapdetails.error_from_external_client EQ 0 and getprogramsapdetails.contract_status_type_idx EQ 2) OR (getprogramsapdetails.contract_status_type_idx GT 2)>
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
	select distinct Program_Webservices_Error_Detail.pactiv_program_id,Program_Webservices_Error_Detail.BSA_Program_Id
	from
	Program_Webservices_Error_Detail
	INNER JOIN
	Program_Webservices_Detail
	ON Program_Webservices_Error_Detail.BSA_Program_Id = Program_Webservices_Detail.BSA_Program_Id
	and Program_Webservices_Detail.deleted = 0
	where Program_Webservices_Error_Detail.deleted = 0
	and Program_Webservices_Detail.bsa_program_id LIKE '%#Replace(getprogramsapdetails.contract_number,"-","")#%'
	and Program_Webservices_Error_Detail.message_type = 'S'
</CFQUERY>
	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>SAP Reference Numbers</B></TD>
	</TR>
</TABLE>
	<cfif TheQuery.recordcount GT 0>
		<div align="center">
		<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
		<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Blacksmith Rebate Id</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Pactiv Rebate ID</B></TD>
		</TR>
		<cfloop query="TheQuery">
		<cfoutput><TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#TheQuery.BSA_Program_Id#</TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#TheQuery.pactiv_program_id#</TD>
		</TR></cfoutput>
		</cfloop>
		</table>
		</div>
	<cfelse>
		<div align="center"><font size="2" color="red">No Data.</font> </div>
	</cfif>
<cfelseif getprogramsapdetails.error_from_external_client EQ 1 and getprogramsapdetails.contract_status_type_idx EQ 2>
<div align="center"><font size="2" color="red"><b>Errors In sending Data to SAP</b></font> </div><br><br>
<cfif FileExists(expandPath("/Utils/Output/#url.CID#.html")) is "Yes">
	<cfinclude template = "/Utils/Output/#url.CID#.html">
<cfelse>
	<div align="center"><font size="2" color="red">No Data Received.</font> </div>
</cfif>
</cfif>
<cfelse>
	<div align="center"><font size="2" color="red">No Data.</font> </div>
</cfif>

<HR color="orange">
<div align="center"><B><font color="FF0000">[</font> <a onclick="javascript:window.close()" STYLE="cursor: hand;">Close Window</a> <font color="FF0000">]</font></B></div>
</body>
</html>
