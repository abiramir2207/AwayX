<!------ update_entry_status_index.cfm ----->
<CFSET pagetitle = "SYSTEM ADMINISTRATION: UPDATE ENTRY STATUS">
<cfparam name="form.command" 	default="search-form">
<cfparam name="url.complete" 	default="">
<cfset sCurrentPage = "update_entry_status_index.cfm" />
<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
<!------ check if the user have access to change status, if not show message ----->
<cfset ProfileStatusChangeAccess = 0 />
<cfif ProgramPostApprovalStatusManager.getProfileProgramPostApprovalStatusChangeAccess(request.AccessStructure.Profiles_ID, 2) EQ 1>
	<cfset ProfileStatusChangeAccess = 1 />
</cfif>

<cfparam name="Form.Program_Number_List" 	default="">


<cfif form.command EQ "save">
	<cfinclude template="update_entry_status_save.cfm" />
</cfif>

<cfif form.command EQ "search-result" AND Form.Program_Number_List NEQ "">
	<cfinclude template="update_entry_status_search_result.cfm" />
</cfif>

<cfoutput>
<HTML>
<HEAD>
	<TITLE>#pagetitle#</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<script language="JavaScript">
function submitForm(sAction)
{
	var oForm = document.frmUpdateEntryStatus;
	oForm.command.value = sAction;
	oForm.submit();
	return false;
}
</script>


<cfif ProfileStatusChangeAccess EQ 0>
<TABLE style="border-color:Orange;border-style:solid;" CELLPADDING="5" CELLSPACING="0" align="center">
<TR>
<TD nowrap align="center">
	&nbsp;&nbsp;&nbsp;&nbsp;<font color="red"><strong>You do not have permission to update entry status</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;
	</TD>
</TR>
</TABLE>
<cfabort>
</cfif>

<cfif form.command EQ "search-result" AND Form.Program_Number_List EQ "">
<TABLE style="border-color:Orange;border-style:solid;" CELLPADDING="5" CELLSPACING="0" align="center">
<TR>
<TD nowrap align="center">
	&nbsp;&nbsp;&nbsp;&nbsp;<font color="red"><strong>Please enter atleast one program Number</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;
	</TD>
</TR>
</TABLE>
	<cfset form.command = "search-form" />
</cfif>

<cfif url.complete EQ "save">
<TABLE style="border-color:Orange;border-style:solid;" CELLPADDING="5" CELLSPACING="0" align="center">
<TR>
<TD nowrap align="center">
	&nbsp;&nbsp;&nbsp;&nbsp;<font color="green"><strong>The programs have been updated successfully</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;
</TR>
</TABLE>
</cfif>
</table>


<form method="post" name="frmUpdateEntryStatus" action="#sCurrentPage#">

<cfif form.command EQ "search-form">
	<cfinclude template="update_entry_status_search_form.cfm" />
</cfif>

<!------ Display search results ----->
<cfif form.command EQ "search-result">
	<cfinclude template="update_entry_status_search_result_display.cfm" />
</cfif>

<input type="Hidden" value="#form.command#" name="command" />

</form>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>
</cfoutput>