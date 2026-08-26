
<CFSET URL.PageTitle="PROJECTS: STATUS LIST MANAGEMENT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.RID" DEFAULT="0">
<CFQUERY NAME="Get_Status" datasource="#application.datasource#">
	Select		*
	From		PM_Status
	Order by	PM_Status_Description
</CFQUERY>
<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
	Select		TOP 1*
	From		PM_Status
	<CFIF URL.RID NEQ 0>
	Where		PM_Status_ID = '#URL.RID#'
	</CFIF>
	Order by	PM_LastUpdated Desc
</CFQUERY>

<CFIF Get_LastUpdated_Details.Recordcount GT 0>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
	SELECT _Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
	FROM _Users
	WHERE User_ID = '#Get_LastUpdated_Details.PM_Updated_UserId#'
</CFQUERY>
</CFIF>

<TABLE>
	<TR>
	<td width="20%"><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"></td>
	<CFIF IsDefined("getUserName")>
	<TD>
	<TABLE BGCOLOR="White" BORDERCOLOR="Orange" BORDER="1" CELLPADDING="3" CELLSPACING="0">
<tr><td>
	<FONT SIZE="2"><B>This <cfif url.RID NEQ 0>file <cfelse> setting</cfif> was last updated on <CFOUTPUT>#dateformat(Get_LastUpdated_Details.PM_LastUpdated, 'm/d/yyy')# #timeformat(Get_LastUpdated_Details.PM_LastUpdated, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT></td></tr></table>
	</TD>
	</CFIF>
	</TR>
</TABLE>

		
	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">

				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_Status">
					<TR>
						<TD NOWRAP><A HREF="create_status.cfm?RID=#PM_Status_ID#">#PM_Status_Description#</A></TD>
						<TD NOWRAP>

								<CFIF PM_Status_Deleted EQ 0>
								<IMG SRC="/images/yes_small.gif" ALT="active record...">
								<CFELSE>
								<IMG SRC="/images/no_small.gif" ALT="inactive record...">
								</CFIF>
						</TD>
					</TR>
					</CFOUTPUT>
				</TABLE>

				<BR>

				<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record<BR>
				
			</TD>
			<TD VALIGN="top">


				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">

				
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				

<CFPARAM NAME="PM_Status_Description" DEFAULT="">
<CFPARAM NAME="Get_Item.PM_Status_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.PM_Status_Deleted" DEFAULT="0">

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		PM_Status
	Where		PM_Status_ID	like	'#URL.RID#'
</CFQUERY>

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
			<FORM ACTION="save_status.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Description</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="PM_Status_Description" VALUE="#Get_Item.PM_Status_Description#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="PM_Status_ID" VALUE="#Get_Item.PM_Status_ID#">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Definition</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<TEXTAREA NAME = "PM_Status_Definition" ROWS="5" COLS="57">#Get_Item.PM_Status_Definition#</TEXTAREA> 
								<!--- <INPUT SIZE="45" NAME="PM_Status_Definition" VALUE="#Get_Item.PM_Status_Definition#" MAXLENGTH="500"> --->
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
						<TD VALIGN="top">

					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- Get the number of projects that have this status: If there is at least 1 project that is active and has this status, then I will not allow the user to delete this status --->
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

					<CFQUERY NAME="Get_Count" datasource="#application.datasource#">
					Select count(*) as project_count from PM_Item_Master where PM_Status_ID like '#Get_Item.PM_Status_ID#' and PM_Deleted = 0
					</CFQUERY>
					
					<CFIF Get_Count.project_count EQ 0>
						<CFPARAM NAME="disabled" DEFAULT="">
					<CFELSE>
						<CFPARAM NAME="disabled" DEFAULT="disabled">
					</CFIF>	 

						<!--- Is this record deleted? --->
						<CFIF Get_Item.PM_Status_Deleted EQ 0 OR Get_Item.PM_Status_Deleted EQ "">
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>

						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="PM_Status_Deleted"#active#>Active
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="PM_Status_Deleted"#inactive##disabled#>Inactive (*)
						</CFOUTPUT>						

						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: document.MyForm.submit()"><B>save data</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							
						<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
							<CFIF Get_Item.PM_Status_Deleted EQ 1>
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF>
							<P></P>
							(*) A disabled "inactive" choice indicates that there is at least one active project that has this status. Thus, the user will not be able to make this status inactive.

						</TD>
						
						
					</TR>
				</TABLE>
				
				
			</FORM>
				
			</TD>
		</TR>
	</TABLE>

<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="create_status.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>


