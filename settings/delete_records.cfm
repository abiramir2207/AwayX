<!DOCTYPE HTML>
<html>
<head>
	<title>Deletion Links</title>
	<cfsavecontent variable="head_content">
		<cf_include files="/script/javascript/string_functions.js, /common_files/dataTable.css">
		<style>
			td {
				font-size: 11px;
				height: 27px;
				line-height: 20px;
			}
			td:nth-child(1) {
				font-weight: bold;
				letter-spacing: 0.75px;
			}
			tr:hover {
				background-color: #F6F6F6;
			}
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
	<cfinclude template="/common_files/jQuery.cfm">
</head>
<body>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "SYSTEM ADMINISTRATION: Links to delete and purge records">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---Help Files--->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<CFIF ISDEFINED("FORM.Accrual_Delete_Days")>
	<CFQUERY NAME="Update_AD_Days" datasource="#application.datasource#">
		UPDATE General_Settings
		   SET Log_GL_Accrual_Delete_Days = <CFIF FORM.Accrual_Delete_Days NEQ "">#FORM.Accrual_Delete_Days#<CFELSE>NULL</CFIF>
	</CFQUERY>
</CFIF>

<CFQUERY NAME="Get_AD_Days" datasource="#application.datasource#">
	SELECT Log_GL_Accrual_Delete_Days FROM General_Settings
</CFQUERY>

<cfoutput>
<FORM name="Accrual_Maintenance" ACTION="delete_records.cfm" METHOD="Post">
<table cellspacing="0" cellpadding="5" class="material">
	<tr>
		<td>
			Purge WIP Records
		</td>
		<td>
			This allows you to purge work in progress billbacks and programs. These deletions are permanent and unrecoverable.
		</td>
		<td>
			<a href="/settings/Delete_WIP/index.cfm">#application.util.string.actionLinkFormat2("delete wip")#</a>
		</td>
	</tr>
	<tr>	
		<td>
			Cancel Programs
		</td>
		<td>
			Cancelling a program marks it as no longer active and notifies the ERP that it is no longer active.
		</td>
		<td>
			<a href="/settings/cancel_programs.cfm">#application.util.string.actionLinkFormat2("cancel programs")#</a>
		</td>
	</tr>
	<tr>	
		<td>
			Delete Approved Programs
		</td>
		<td>
			This allows you to delete approved programs. These deletions are recoverable using the option: Deleted/Purged Programs.<br><img src="/images/KnobAttention.png" height="20" width="20" style="position:relative;top:4px;"> Please do not use this option to delete specific program versions.  This option deletes all versions.
		</td>
		<td>
			<a href="/settings/delete_approved_programs.cfm">#application.util.string.actionLinkFormat2("delete approved")#</a>
		</td>
	</tr>
	<tr>
		<td>
			Deleted/Purged Programs
		</td>
		<td>
			This is a list of deleted and purged programs that may be reinstated</td>
		<td>
			<a href="/settings/deleted_programs.cfm">#application.util.string.actionLinkFormat2("delete programs")#</a>
		</td>
	</tr>
	<!--- D40664 :: Settings page to show Deleted Billbacks START--->
	<tr>
		<td>
			Deleted Billbacks
		</td>
		<td>
			This is a list of deleted billbacks that may be reinstated
		</td>
		<td>
			<a href="/settings/deleted_billbacks.cfm">#application.util.string.actionLinkFormat2("delete billbacks")#</a>
		</td>
	</tr>
	<!--- D40664 :: Settings page to show Deleted Billbacks END --->
	<tr>
		<td>
			Deleted/Purged Accrual Log Records
		</td>
		<td>
			Delete the Accrual Log table records that are older than&nbsp;
			<INPUT TYPE="text" SIZE="4" NAME="Accrual_Delete_Days" VALUE="#Get_AD_Days.Log_GL_Accrual_Delete_Days#" onKeyUp="clenseText(this, '0123456789')"> days
		</td>
		<td>
			<a href="javascript:document.all.Accrual_Maintenance.submit();">#application.util.string.actionLinkFormat2("save")#</a>
		</td>
	</tr>
</table>
</cfoutput>
</form>
<cfinclude template="/common_files/focus.cfm">
</body>
</html>