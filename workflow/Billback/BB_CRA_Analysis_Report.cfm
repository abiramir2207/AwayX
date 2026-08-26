<!---
	File: BB_CRA_Analysis_Report.cfm
	Created by: Anand Rao
	Created on: Mar 16, 2012
	Label for creation: D28386: BB CRA Analysis Report
	Lowest build available: 7.0
	
	This page will allow the users to select from a list of users provided and then request for the CRA Analysis report. 
	This page will be available from the workflow link within the Billback.
	The link to this page will be displayed only to users with profile access.
--->

<html>
<head>
	<title>Workflow</title>
	<script type="text/javascript" src="/script/javascript/sortable.js"></script>
</head>

<body RIGHTMARGIN="8" LEFTMARGIN="8">

<style>
TABLE.sortable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
TABLE.sortable TH 
{
	border-bottom:solid #93BEE2 1px; font-size:11px; font:bold; text-align:left; 
}

.odd {background-color: #FFFFFF;}
.even {background-color: #CCFFCC;}
image{border:none}
</style>

<cfparam name="url.Billback_ID" default="0" />
<cfparam name="url.caller" default="cf" />

<cfparam name="Form.Sort_By" default="Position" />
<cfparam name="Form.User_ID_List" default="" />

<cfset objBBWorkflowManager = createObject("component", "components.workflow.BillbackWorkFlowManager") />
<cfset objBillback = createObject('component','components.Match_Central.MatchCentral').init() />
<cfset BBDAO = createObject('component','mvc.Models.Billback.BillbackDAO')/>
<cfif (url.caller EQ "FLEX")>
	<cfset URL.Billback_ID = BBDAO.getBillbackUUID(URL.Billback_ID) />
</cfif>



<cfset qGetBillbackData = objBillback.getBBInfo(url.Billback_ID) />

<cfset qGetUsersAboveProgram = objBBWorkflowManager.getUsersAboveBillback(url.Billback_ID, Form.Sort_By) />
<cfset displayAuthoritySequence = objBBWorkflowManager.displayAuthoritySequence() />

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<script language="javascript">

function submitForm()
{
	if(!Any_Object_Checked(document.all.User_ID_List))
	{
		alert("Please select atleast one user");
		return;
	}
	document.all.frmCRAUserSelect.submit();
}

function includeAllUsers()
{
	CHSelectAll("User_ID_List", true);
	submitForm();
}


function changeSort()
{
	document.all.frmCRAUserSelect.action = "";
	document.all.frmCRAUserSelect.submit();
}

</script>


<cfoutput>
	
<table border="0" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="100%" bgcolor="">
			<cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
			#application.returned_customer_setting.company_name#</DIV>
			<B><font size="+1" color="Navy">[#qGetBillbackData.BB_Code#] - #qGetBillbackData.BB_Title#</FONT></B>
		</td>
		<td align="right" valign="top">
			<CF_smallLink 
				title = "workflow" 
				url = "BB_Workflow.cfm?Billback_ID=#url.Billback_ID#"
				parameters = ""
			>
			<CF_smallLink 
				title = "close window" 
				url = "JavaScript:window.close();"
				parameters = ""
			>
		</td>
	</tr>	
</table>
<BR>
<TABLE cellpadding="0" cellspacing="0" border="0" width="100%">
	<TR>
		<TD><B><FONT SIZE="2" COLOR="Navy">CRA ANALYSIS REPORT</FONT></B>
		&nbsp;&nbsp;&nbsp;
		</TD>		
	</TR>	
</TABLE>
<HR COLOR="Navy">

<form name="frmCRAUserSelect" method="post" action="BB_CRA_Analysis_Report_Action.cfm" style="display:inline;">
	
<TABLE cellpadding="0" cellspacing="0" border="0" width="100%">
	<TR>
		<TD>
		<b>
		Select the users that need to be included in the report
		</b>
		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

			<CF_smallLink 
				title = "run report for selected users" 
				url = "JavaScript:submitForm();"
				parameters = ""
			>			
		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

			<CF_smallLink 
				title = "run report for all users" 
				url = "JavaScript:includeAllUsers();"
				parameters = ""
			>
		<!---
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		
		Sort By:
		<select name="Sort_By" onChange="JavaScript:changeSort();">
			<option value="Position" <cfif Form.Sort_By EQ "Position">selected</cfif>>Position</option>
			<option value="Name" <cfif Form.Sort_By EQ "Name">selected</cfif>>Name</option>
			<option value="Profile" <cfif Form.Sort_By EQ "Profile">selected</cfif>>Profile</option>
		</select>
		--->	
		</TD>
	</TR>	
</TABLE>
<br>
</cfoutput>

<!---
<table border="0" width="100%" cellpadding="0" cellspacing="1">
<tr valign="top">
	<cfoutput query="qGetUsersAboveProgram">
	<td bgcolor="F2F2F2">
		<input type="checkbox" name="User_ID_List" value="#user_id#" <cfif ListFindNoCase(Form.User_ID_List, User_ID)>checked</cfif>> 
		#position_label# <cfif len(authority_sequence_name)>/ #authority_sequence_name#</cfif>
		<br>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#user_full_name# (#profiles_desc#)
	</td>
	<CFIF qGetUsersAboveProgram.CURRENTROW MOD 3><CFELSE></tr><tr valign="top"></CFIF>
	</cfoutput>
</tr>
</table>
--->
<cfset tdWidth = "32%" />
<cfif displayAuthoritySequence>
	<cfset tdWidth = "24%" />
</cfif>
<cfoutput>
<table border="0" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="sortabletable">
	<THEAD BGCOLOR="FFCE84">
		<TH class="unsortable">
			<input type="checkbox" onClick="javascript: CHSelectAll('User_ID_List', this.checked);">
		</TH>
		<TH width="#tdWidth#">
			<b>User</b>
		</TH>
		<TH width="#tdWidth#">
			<b>Position</b>
		</TH>
		<TH width="#tdWidth#">
			<b>Profile</b>
		</TH>
		<cfif displayAuthoritySequence>
		<TH width="#tdWidth#">
			<b>Authority Sequence</b>
		</TH>
		</cfif>
	</THEAD>
</cfoutput>
<cfoutput query="qGetUsersAboveProgram">
	<tr <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
		<td><input type="checkbox" name="User_ID_List" value="#user_id#" <cfif ListFindNoCase(Form.User_ID_List, User_ID)>checked</cfif>> </td>
		<td>#user_full_name#</td>
		<td>#position_label#</td>
		<td>#profiles_desc#</td>
		<cfif displayAuthoritySequence>
		<td><cfif len(trim(Authority_Sequence_Name))>#Authority_Sequence_Name#<cfelse>N/A</cfif></td>
		</cfif>
	</tr>
</cfoutput>
</table>

<cfoutput>
<input type="hidden" name="Billback_ID" value="#url.Billback_ID#">
</cfoutput>

<br>
<TABLE cellpadding="0" cellspacing="0" border="0" width="100%">
	<TR>
		<TD>
		
			<CF_smallLink 
				title = "run report for selected users" 
				url = "JavaScript:submitForm();"
				parameters = ""
			>			
		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

			<CF_smallLink 
				title = "run report for all users" 
				url = "JavaScript:includeAllUsers();"
				parameters = ""
			>

		</TD>
	</TR>	
</TABLE>
</form>


</body>
</html>
