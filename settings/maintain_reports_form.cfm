<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFSET URL.PageTitle="SETTINGS: REPORTS MANAGEMENT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.RID" DEFAULT="9999">

<CFQUERY NAME="Get_Report_List" datasource="#application.datasource#">
	Select *, report_groups.group_label 
	From view_full_report_data inner join report_groups on view_full_report_data.report_group = report_groups.group_id
	Order By	report_group, report_name ASC
</CFQUERY>


<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
	Select		TOP 1 LastUpdated, Updated_UserID
	From		Reports
	<CFIF URL.RID NEQ 9999>
	Where		Report_ID = '#URL.RID#'
	</CFIF>
	Order by	LastUpdated Desc
</CFQUERY>

<CFIF Get_LastUpdated_Details.Recordcount GT 0>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
	SELECT _Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
	FROM _Users
	WHERE User_ID = '#Get_LastUpdated_Details.Updated_UserId#'
</CFQUERY>
</CFIF>

<TABLE>
	<TR>
	<td width="20%"><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"></td>
	<CFIF IsDefined("getUserName") AND len(Get_LastUpdated_Details.Updated_UserID) GT 0>
	<TD>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<tr><td>
	<FONT SIZE="2"><B>This <cfif url.RID NEQ 0>file <cfelse> setting</cfif> was last updated on <CFOUTPUT>#dateformat(Get_LastUpdated_Details.LastUpdated, 'm/d/yyy')# #timeformat(Get_LastUpdated_Details.LastUpdated, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT></td></tr></table>
	</TD>
	</CFIF>
	</TR>
</TABLE>


	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">

				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="250" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Report Name</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Report Group</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_Report_List">
					<TR>
						<TD NOWRAP><A HREF="maintain_reports_form.cfm?RID=#report_id#">#Report_Name#</A></TD>
						<TD NOWRAP>#Group_Label#</TD>
					</TR>
					</CFOUTPUT>
				</TABLE>
			</TD>
			<TD VALIGN="top">
				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">

				
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				

<CFPARAM NAME="Get_Item.Report_Name" default="">
<CFPARAM NAME="Get_Item.Report_ID" default="9999">
<CFPARAM NAME="Get_Item.Report_Desc" default="">
<CFPARAM NAME="Get_Item.Report_Url" default="">
<CFPARAM NAME="Get_Item.Report_Author" default="">
<CFPARAM NAME="Get_Item.Report_Group" default="">
<CFPARAM NAME="Get_Item.Level_Code" default="">
<CFPARAM NAME="Get_Item.Report_Url_Jscript" default="">
<CFPARAM NAME="Get_Item.Report_Url_Options" default="">
<CFPARAM NAME="Get_Item.Active" default="1">
<CFPARAM NAME="URL.MAINT" default="1">

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		report_id, report_name, report_desc, report_url, active,
				report_author, report_group, created_date, level_code, 
				description, status, custom, report_url_jscript, report_url_options
	From		view_full_report_data
	Where		report_id	like	'#URL.RID#'
</CFQUERY>

<CFQUERY NAME="Get_Report_Groups" datasource="#application.datasource#">
	select group_id, group_label from report_groups where deleted <> 1 order by group_id ASC
</CFQUERY>

<cfset useLakebaseForGet_Report_Access_Levels = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_access_levels")>
<cfif useLakebaseForGet_Report_Access_Levels>
	<cftry>
		<cfset Get_Report_Access_Levels = application.oLakebase.toQuery(
			application.oLakebase.selectRows("report_access_levels", {
				"order" = "level_code.asc",
				"select" = "level_code,description"
			}), "level_code,description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Report_Access_Levels = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Report_Access_Levels>
<CFQUERY NAME="Get_Report_Access_Levels" datasource="#application.datasource#">
	select level_code, description from report_access_levels order by level_code ASC
</CFQUERY>
</cfif>

<!--- Delete record --->
<SCRIPT language="JavaScript">
function alert_and_delete()
{
	var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
	if (confirmdelete == true)
	{
		document.all.DeleteRecord.value=1;
		document.MyForm.submit();
	}			
}	
</SCRIPT>
			<FORM ACTION="maintain_reports_form_action.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right" nowrap><B>Report Name</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Report_Name" VALUE="#Get_Item.Report_Name#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="Report_ID" VALUE="#Get_Item.Report_ID#">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" nowrap><B>Report URL</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Report_URL" VALUE="#htmlEditFormat(Get_Item.Report_URL)#" MAXLENGTH="256">
							</CFOUTPUT>
						</TD>
					</TR>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" Title="Enter URL Options (Target, etc) - 256 VarChar Limit" nowrap><B>URL Options</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Report_URL_Options" VALUE="#htmlEditFormat(Get_Item.Report_URL_Options)#" MAXLENGTH="256">
							</CFOUTPUT>
						</TD>
					</TR>

					<TR>
						<TD VALIGN="top" ALIGN="right" Title="Enter Javascript and Event Handler - 256 VarChar Limit" nowrap><B>URL JavaScript</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Report_Url_Jscript" VALUE="#htmlEditFormat(Get_Item.Report_Url_Jscript)#" MAXLENGTH="256">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" Title="" nowrap><B>Report Status</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<CFIF len(Get_Item.Active) EQ 0>
								<INPUT TYPE="radio" NAME="Active" VALUE="0"> InActive 
								<INPUT TYPE="radio" NAME="Active" VALUE="1" checked> Active 
								<CFELSE>
								<INPUT TYPE="radio" NAME="Active" VALUE="0" <cfif Get_Item.Active EQ 0>Checked</cfif> > InActive
								<INPUT TYPE="radio" NAME="Active" VALUE="1" <cfif Get_Item.Active EQ 1>Checked</cfif> > Active
								</CFIF>
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" nowrap><B>Report Description</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<TEXTAREA ROWS="4" COLS="60" NAME="Report_Desc" WRAP="virtual">#Get_Item.Report_Desc#</TEXTAREA>
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" nowrap><B>Report Author</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Report_Author" VALUE="#Get_Item.Report_Author#" MAXLENGTH="50">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" nowrap><B>Report Group</B></TD>
						<TD VALIGN="top">
							<SELECT NAME="Report_Group">
							<CFOUTPUT Query="Get_Report_Groups">
								<OPTION VALUE="#Get_Report_Groups.Group_ID#" MAXLENGTH="50" <CFIF Get_Item.Report_Group EQ Get_Report_Groups.Group_ID>Selected</CFIF> >#Get_Report_Groups.Group_Label#</OPTION>
							</CFOUTPUT>
							</SELECT>
						</TD>
					</TR>
				<TR>
						<TD VALIGN="top" ALIGN="right" nowrap><B>Report Access Level</B></TD>
						<TD VALIGN="top">
							<SELECT NAME="Level_Code">
							<CFOUTPUT Query="Get_Report_Access_Levels">
								<OPTION VALUE="#Get_Report_Access_Levels.Level_Code#" MAXLENGTH="50" <CFIF Get_Item.Level_Code EQ Get_Report_Access_Levels.Level_Code>Selected</CFIF> >#Get_Report_Access_Levels.Description#</OPTION>
							</CFOUTPUT>
							</SELECT>
						</TD>
					</TR>
					<TR>
						<TD Colspan="2" Align="right" VALIGN="top">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: document.MyForm.submit()"><B>save data</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							&nbsp;&nbsp;
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="app_settings.cfm?command=Settings5"><B>close</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
						</TD>
					</TR>
				</TABLE>
			</FORM>
				
			</TD>
		</TR>
	</TABLE>

<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
<A HREF="maintain_reports_form.cfm"><B>Register New Report</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
