<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFSET URL.PageTitle="SETTINGS: REPORT ACCESS LEVEL MANAGEMENT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.RID" DEFAULT="9999">
<cfset useLakebaseForGet_RAL_List = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_access_levels")>
<cfif useLakebaseForGet_RAL_List>
	<cftry>
		<cfset Get_RAL_List = application.oLakebase.toQuery(
			application.oLakebase.selectRows("report_access_levels", {
				"editable" = "eq.1",
				"order" = "level_code.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_RAL_List = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_RAL_List>
<CFQUERY NAME="Get_RAL_List" datasource="#application.datasource#">
	Select		*
	From		report_access_levels
	WHERE 	 	editable = 1
	Order by	level_code ASC
</CFQUERY>
</cfif>


<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
	Select		TOP 1 LastUpdated, Updated_UserID
	From		report_access_levels
	<CFIF URL.RID NEQ 9999>
	Where		Level_Code = '#URL.RID#'
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
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Level Code</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;">&nbsp;<B>Status</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_RAL_List">
					<TR>
						<TD NOWRAP><A HREF="maintain_report_access_levels_form.cfm?RID=#Level_Code#">#Level_Code#</A></TD>
						<TD NOWRAP>#description#
						</TD>
						<TD NOWRAP ALIGN="Center">
								<CFIF status EQ "I">INCLUDE
								<CFELSEIF status EQ "E">EXCLUDE
								<CFELSE>N/A								
								</CFIF>
						</TD>
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

<CFPARAM NAME="Get_Item.Description" default="">
<CFPARAM NAME="Get_Item.Level_Code" default="9999">
<CFPARAM NAME="Get_Item.Status" default="">

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		report_access_levels
	Where		level_code	like	'#URL.RID#'
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
			<FORM ACTION="maintain_report_access_levels_form_action.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Level Code</B></TD>
						<!--- <TD VALIGN="top" ROWSPAN="100%" BGCOLOR="Orange">&nbsp;</TD> --->
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Description" VALUE="#Get_Item.Description#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="Level_Code" VALUE="#Get_Item.Level_Code#">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Status</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<select name="status" STYLE="WIDTH: 80px;font-size: 10px;">
									<option value="I" <cfif Get_Item.Status EQ "I">Selected</cfif>>Include</option>
									<option value="E" <cfif Get_Item.Status EQ "E">Selected</cfif>>Exclude</option>
								</select>
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
						Select count(*) as level_code_count from report_central_access where level_code like '#Get_Item.level_code#'
						</CFQUERY>
						
						<CFIF Get_Count.level_code_count EQ 0>
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
						<cfoutput>#Get_Count.level_code_count#</cfoutput> record(s) have a matching report access level.
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
<A HREF="maintain_report_access_levels_form.cfm"><B>create new report access level</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>





