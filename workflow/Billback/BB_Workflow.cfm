<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Billback Workflow</title>
</head>

<body RIGHTMARGIN="8" LEFTMARGIN="8">

<style>
	tr.nobottomborder TD 
	{
		border-bottom:none;
	}
</style>
<cfparam name="url.Billback_ID" default="0" />
 
<cfset objBBWorkflowManager = createObject("component", "components.workflow.BillbackWorkFlowManager") />

<cfset objBillback = createObject('component','components.Match_Central.MatchCentral').init() />

<cfset qBBWorkFlowData = objBBWorkflowManager.getWorkFlowData(url.Billback_ID, 0, 1) />
<cfset qWorkFlowApprovableUsers = objBBWorkflowManager.getApprovableUsers(url.Billback_ID) />
<cfif qWorkFlowApprovableUsers.recordCount>
	<cfset qWorkFlowNextApprovableUsers = objBBWorkflowManager.getNextApprovableUsers(url.Billback_ID) />
</cfif>
<cfset qGetBillbackData = objBillback.getBBInfo(url.Billback_ID) />
<cfset displayAuthoritySequence = objBBWorkflowManager.displayAuthoritySequence() />

<cfinclude template="/get_access_profile.cfm" />
<cfoutput>
<table border="0" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="86%">
			<table border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td colspan="100%" bgcolor="">
						<cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
						#application.returned_customer_setting.company_name#</DIV>
						<B><font size="+1" color="Navy">[#qGetBillbackData.BB_Code#] - #qGetBillbackData.BB_Title#</FONT></B>
					</td>
				</tr>
			</table>
		</td>
		<td align="right" valign="top">
			<table border="0" cellpadding="0" cellspacing="0">
			<cfif Get_Profile_Settings.View_BB_CRA_Analysis_Report eq 1> 
			<tr>
			<td colspan="100%" bgcolor="">
				<CF_smallLink 
					title = "CRA analysis report" 
					url = "BB_CRA_Analysis_Report.cfm?Billback_ID=#url.Billback_ID#"
					parameters = ""
				>
			</td>
			</tr>
			</cfif>
			<cfif Get_Profile_Settings.Auto_Approve_Analysis eq 1>
			<tr>
			<td colspan="100%" bgcolor="">
				<CF_smallLink 
					title = "Auto approve analysis" 
					url = "##"
					parameters = "onClick=""JavaScript:openAutoApprovalInfo('#url.Billback_ID#');"""
				>
			</td>
			</tr>
			</cfif>
			<tr>
			<td colspan="100%" bgcolor="">
			<CF_smallLink 
				title = "close window" 
				url = "JavaScript:window.close();"
				parameters = ""
			>
			</td>
			</tr>
			</table>
		</td>
	</tr>
</table>
</cfoutput>
<br>
<TABLE width="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">WORKFLOW</FONT></B>&nbsp;<HR COLOR="Navy"></CAPTION>

	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;" valign="top">
			<b>Action</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top">
			<b>Name</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top">
			<b>ID</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top">
			<b>Position</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top">
			<b>Profile</b>
		</TD>
		<cfif displayAuthoritySequence>
		<TD STYLE="font-size:11px;" valign="top">
			<b>Authority Sequence</b>
		</TD>
		</cfif>
		<TD STYLE="font-size:11px;" valign="top">
			<b>Date</b>
		</TD>
		
	</TR>
	<CFOUTPUT QUERY="qBBWorkFlowData">
 	<cfif Action_Type eq 3>
		<cfset qGetAgreeReason = objBBWorkflowManager.getBillbackAgreeReason(url.Billback_ID, Action_User_ID) />
	</cfif>  
	<TR <cfif Action_Type eq 3 and qGetAgreeReason.RecordCount>class="nobottomborder"</cfif> <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD>
			#Action#	
		</TD>
		<TD>
			#Name#&nbsp;
		</TD>
		<TD>
			#ID#&nbsp;
		</TD>
		<TD>
			#Position#&nbsp;
		</TD>
		<TD>
			#Profiles_Desc#&nbsp;
		</TD>
		<cfif displayAuthoritySequence>
		<TD>
			<cfif len(trim(Authority_Sequence_Name))>#trim(Authority_Sequence_Name)#<cfelse>N/A</cfif>
		</TD>
		</cfif>
		<TD>
			#DateFormat(Action_Date, "mm/dd/yyyy")#&nbsp;#TimeFormat(Action_Date, "short")#
		</td>
	</tr>
	<cfif Action_Type eq 3 and qGetAgreeReason.RecordCount>
		<TR>
			<td align="left" colspan="100%" <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
				<CF_openLayer
					Border="Yes"
					BorderSize="1"  
					BorderColor="orange"  
					Image="/images/plus2.gif"
					ImageOpen="/images/minus2.gif"
					Title="Agree Reasons"  
					TitleClosed="Agree Reasons"  
					TitleTooltip="Click to Show/Hide"  
					TitleFont="font"  
					TitleColor="Blue"  
					TitleSize="8"  
					IsClosed="Yes"  
					Width="100%">
				<cfloop query="qGetAgreeReason">
					#Agree_Reason#<br>
				</cfloop>
				</CF_openLayer>
			</td>
		</TR>
	</cfif> 
	</CFOUTPUT>
</TABLE>
<br>
<cfif qWorkFlowApprovableUsers.RecordCount>
<!----- CRA ----->
<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">CRA&nbsp;&nbsp;[currently responsible for approval]</FONT></B><HR COLOR="Navy"></CAPTION>
<TABLE width="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Name</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Position</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Profile</b>
		</TD>
		<cfif displayAuthoritySequence>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Authority Sequence</b>
		</TD>
		</cfif>
	</TR>
	<CFOUTPUT QUERY="qWorkFlowApprovableUsers">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD>
			#User_Full_Name#	
		</TD>
		<td>
			#Position_Label#
		</td>
		<TD>
			#Profiles_Desc#
		</TD>
		<cfif displayAuthoritySequence>
		<TD>
			<cfif len(trim(Authority_Sequence_Name))>#trim(Authority_Sequence_Name)#<cfelse>N/A</cfif>
		</TD>
		</cfif>
	</tr>
	</CFOUTPUT>
</TABLE>

<br>
<!----- NRA ----->
<cfif qWorkFlowNextApprovableUsers.RecordCount>
<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">NRA -</B> after the above person(s) take action, below is a list of person(s) that may need to take approval action.</FONT><HR COLOR="Navy"></CAPTION>
<TABLE width="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Name</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Position</b>
		</TD>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Profile</b>
		</TD>
		<cfif displayAuthoritySequence>
		<TD STYLE="font-size:11px;" valign="top" width="25%">
			<b>Authority Sequence</b>
		</TD>
		</cfif>
	</TR>
	<CFOUTPUT QUERY="qWorkFlowNextApprovableUsers">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD>
			#User_Full_Name#	
		</TD>
		<td>
			#Position_Label#
		</td>
		<TD>
			#Profiles_Desc#
		</TD>
		<cfif displayAuthoritySequence>
		<TD>
			<cfif len(trim(Authority_Sequence_Name))>#trim(Authority_Sequence_Name)#<cfelse>N/A</cfif>
		</TD>
		</cfif>
	</tr>
	</CFOUTPUT>
</TABLE>
</cfif>
</cfif>
<br>
<CF_smallLink 
	title = "close" 
	url = "JavaScript:window.close();"
	parameters = ""
>&nbsp;

<SCRIPT>
/* Aut Approval function */
function openAutoApprovalInfo(bb_id)
{
	NewWindow("auto_approval_analysis.cfm?BBID=" + bb_id,"AutoApprovalInfo","800","600","Yes", "No");
	return false;
}
</SCRIPT>
</body>
</html>