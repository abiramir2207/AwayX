<CFSET PAGETITLE="Sysco Report - Prior Revisions">


<!---  <cfif blnSubmit IS 1>
<cfdump var="#form#">
<cfabort>
</cfif> --->


<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGETITLE#</CFOUTPUT></TITLE>

	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/billbacks/common/common_js_functions.js"></SCRIPT>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.CID" 	DEFAULT="">
<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "sys"> 
<CFSET FORM.Contract_Main_ID = cryp.value>
	
	<cfquery name="getContractNumber" datasource="#application.datasource#">
	SELECT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = #FORM.Contract_Main_ID#
	</cfquery>


	 <cfquery name="GetRevisedContractInfo" datasource="#application.datasource#">
		SELECT Contract_Main_ID, Contract_Number, Contract_Title, Contract_Reference_Number, Contract_End_Date, Contract_Start_Date, _Users.Name_First, _Users.Name_Last, revision_version, Contract_Main.deleted
		FROM Contract_Main
			INNER JOIN _Users 
			ON _Users.User_ID = Contract_Main.Creator_ID
		WHERE Contract_Number = '#getContractNumber.Contract_Number#'
		ORDER BY Contract_Main_ID
	</cfquery>
	

	<CFINCLUDE TEMPLATE="/includes/header.cfm">
	<cfif application.programlayout EQ 1>
	  <div id="Layer2" style="position:absolute; width: 179px; height: 338px; z-index: 1; left: 10px; top: 0px"> 
	    <CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm"></div>
	 <cfelse>
	<CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm">
	</cfif>
	<BLOCKQUOTE>
	  <cfif application.programlayout EQ 1><div id="Layer1" style="position:relative; height:430px; width:800px; z-index:1; left: 100px; top: 10px;"></cfif>
	 	<!--- <cfinclude template="/common_files/contracts/minimal_contract_info.cfm"> --->
		<CFSET PAGETITLE="Sysco Report  ::  Contract Number  ::  #GetRevisedContractInfo.Contract_Number# :: Prior Revisions">
	 	<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">


<table border="0" cellpadding="2" cellspacing="0">
<tr bgcolor="orange">
	<td>&nbsp; </td>
	<th><strong><font size="2">&nbsp; &nbsp; &nbsp; Revision Title&nbsp; &nbsp; &nbsp; </font></strong></th>
	<th><strong><font size="2">&nbsp; &nbsp; &nbsp; Revision Span&nbsp; &nbsp; &nbsp; </font></strong></th>
	<th><strong><font size="2">&nbsp; &nbsp; &nbsp; Revised By&nbsp; &nbsp; &nbsp; </font></strong></th>
	<th><strong><font size="2">&nbsp; &nbsp; &nbsp; Active&nbsp; &nbsp; &nbsp; </font></strong></th>
	<td>&nbsp; </td>
</tr>
<cfoutput query="GetRevisedContractInfo">

<CF_CRYP type="en" string="#GetRevisedContractInfo.Contract_Main_ID#" key="#request.key#">
<cfset CID = cryp.value>

<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<td STYLE="border-bottom:solid orange 1px;border-left:solid orange 1px;">#Revision_Version#</td>
	<td STYLE="border-bottom:solid orange 1px;border-left:solid orange 1px;">#Contract_Title#</td>
	<td STYLE="border-bottom:solid orange 1px;border-left:solid orange 1px;">#dateformat(contract_start_date, 'mm/dd/yyyy')# - #dateformat(contract_end_date, 'mm/dd/yyyy')#</td>
	<td STYLE="border-bottom:solid orange 1px;border-left:solid orange 1px;">#Name_First# #Name_Last#</td>
	<td STYLE="border-bottom:solid orange 1px;border-left:solid orange 1px;" align="Center"><Cfif Deleted IS 0>X<Cfelse>&nbsp; </CFIF></td>
<td STYLE="border-bottom:solid orange 1px;border-right:solid orange 1px;border-left:solid orange 1px;"><A href="sysco_report_form.cfm?CID=#CID#&FromPriorRevision=1">View Report</A></td>
</tr>
</cfoutput>
</table>
 
 </BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">

</BODY>
</HTML> 