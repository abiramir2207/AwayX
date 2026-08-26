<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFSET URL.PageTitle="SETTINGS: REPORT GROUPS MANAGEMENT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.RID" DEFAULT="9999">
<cfset useLakebaseForGet_RAL_List = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_groups")>
<cfif useLakebaseForGet_RAL_List>
	<cftry>
		<cfset Get_RAL_List = application.oLakebase.toQuery(
			application.oLakebase.selectRows("report_groups", {
				"order" = "group_id.asc",
				"select" = "group_id,group_label"
			}), "group_id,group_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_RAL_List = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_RAL_List>
<CFQUERY NAME="Get_RAL_List" datasource="#application.datasource#">
	Select		group_id, group_label
	From		report_groups
	Order by	group_id ASC
</CFQUERY>
</cfif>


<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
	Select		TOP 1*
	From		report_groups
	<CFIF URL.RID NEQ 9999>
	Where		group_ID = '#URL.RID#'
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
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Group Name</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_RAL_List">
					<TR>
						<TD NOWRAP><A HREF="maintain_report_groups_form.cfm?RID=#Group_ID#">#Group_Label#</A></TD>		
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

<CFPARAM NAME="Get_Item.Group_Label" default="">
<CFPARAM NAME="Get_Item.Group_ID" default="9999">
<CFPARAM NAME="Get_Item.Icon_Used" default="">
<CFPARAM NAME="Get_Item.Group_Icon" default="">

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		report_groups
	Where		group_id	like	'#URL.RID#'
</CFQUERY>

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
			<FORM ACTION="maintain_report_groups_form_action.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Level Code</B></TD>
						<!--- <TD VALIGN="top" ROWSPAN="100%" BGCOLOR="Orange">&nbsp;</TD> --->
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Group_Label" VALUE="#Get_Item.Group_Label#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="Group_ID" VALUE="#Get_Item.Group_ID#">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" Title="" nowrap><B>ICON USED?</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<CFIF len(Get_Item.Icon_Used) EQ 0>
								<INPUT TYPE="radio" NAME="Icon_Used" VALUE="0" checked> False 
								<INPUT TYPE="radio" NAME="Icon_Used" VALUE="1" > True 
								<CFELSE>
								<INPUT TYPE="radio" NAME="Icon_Used" VALUE="0" <cfif Get_Item.Icon_Used EQ 0>Checked</cfif> > False
								<INPUT TYPE="radio" NAME="Icon_Used" VALUE="1" <cfif Get_Item.Icon_Used EQ 1>Checked</cfif> > True
								</CFIF>
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Group Icon</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Group_Icon" TITLE="RELATIVE PATH TO GROUP ICON" VALUE="#Get_Item.Group_Icon#">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
		<cfsilent>		
						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
						<!--- Get the number of projects that have this priority: If there is at least 1 project that is active and has this priority, then I will not allow the user to delete this priority --->
						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
						<CFQUERY NAME="Get_Count" datasource="#application.datasource#">
						Select count(*) as group_id_count from reports where report_group like '#Get_Item.group_id#'
						</CFQUERY>
						
						<CFIF Get_Count.group_id_count EQ 0>
							<CFPARAM NAME="disabled" DEFAULT="">
						<CFELSE>
							<CFPARAM NAME="disabled" DEFAULT="disabled">
						</CFIF>	 
						
						
						<!--- Is this record deleted? --->
						<!---
						<CFIF Get_Item.PM_priority_Deleted EQ 0 OR Get_Item.PM_priority_Deleted EQ "">
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>

						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="PM_priority_Deleted"#active#>Active
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="PM_priority_Deleted"#inactive##disabled#>Inactive (*)
						</CFOUTPUT>
						--->
						</cfsilent>
						<TD VALIGN="top" Colspan="2" ALIGN="left"><FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
						<cfoutput>#Get_Count.group_id_count#</cfoutput> record(s) have a matching report group.
						<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
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
<A HREF="maintain_report_groups_form.cfm"><B>create new report group</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>




