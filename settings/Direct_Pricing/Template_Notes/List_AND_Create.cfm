
<CFSET URL.PageTitle="Programs: Template Notes MANAGEMENT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.RID" DEFAULT="0">
<cfset useLakebaseForGet_Notes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_notes")>
<cfif useLakebaseForGet_Notes>
	<cftry>
		<cfset Get_Notes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("template_notes", {
				"order" = "template_note_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Notes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Notes>
<CFQUERY NAME="Get_Notes" datasource="#application.datasource#">
	Select		*
	From		Template_Notes
	Order by	Template_Note_Desc ASC
</CFQUERY>
</cfif>

<CFQUERY NAME="Get_LastCreated_Details" datasource="#application.datasource#">
	Select		TOP 1 *
	From		Template_Notes
	<CFIF URL.RID NEQ 0>
	Where		Template_Note_ID = '#URL.RID#'
	</CFIF>
	Order by	Created_Date Desc
</CFQUERY>

<cfset useLakebaseForGet_LastUpdated_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_notes")>
<cfif useLakebaseForGet_LastUpdated_Details>
	<cftry>
		<cfset Get_LastUpdated_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("template_notes", {
				"updated_date" = "not.is.null",
				"order" = "updated_date.desc",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_LastUpdated_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_LastUpdated_Details>
<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
	Select		TOP 1 *
	From		Template_Notes
	
	Where		Updated_Date IS NOT NULL
	
	Order by	Updated_Date Desc
</CFQUERY>
</cfif>
<CFIF URL.RID NEQ 0>
	<CFIF Get_LastCreated_Details.Updated_By NEQ "">
		<CFSET GetUser = "Get_LastCreated_Details.Updated_By">
	<CFELSE>
		<CFSET GetUser = "Get_LastCreated_Details.Created_By">
	</CFIF>
<CFELSE>
	<CFIF Get_LastCreated_Details.Created_Date GT Get_LastUpdated_Details.Updated_Date>
		<CFSET GetUser = "Get_LastCreated_Details.Created_By">
	<CFELSE>
		<CFSET GetUser = "Get_LastUpdated_Details.Updated_By">
	</CFIF>
</CFIF>

<CFIF Get_LastCreated_Details.Recordcount GT 0>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
	SELECT _Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
	FROM _Users
	WHERE User_ID = '#EVALUATE("#GetUser#")#'
</CFQUERY>
</CFIF>

<TABLE>
	<TR>
	<td width="20%"><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"></td>
	<CFIF IsDefined("getUserName")>
	<TD>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<tr><td>
	<FONT SIZE="2"><B>This <cfif url.RID NEQ 0>file <cfelse> setting</cfif> was last updated on <CFOUTPUT>#dateformat(Get_LastUpdated_Details.Updated_Date, 'm/d/yyy')# #timeformat(Get_LastUpdated_Details.Updated_Date, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT></td></tr></table>
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
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>						
					</TR>
					<CFOUTPUT QUERY="Get_Notes">
					<TR>
						<TD NOWRAP><A HREF="List_And_Create.cfm?RID=#Template_Note_ID#">#Template_Note_Desc#</A></TD>
						<TD NOWRAP>
								<CFIF Deleted EQ 0>
								<IMG SRC="/images/yes_small.gif" TITLE="active record...">
								<CFELSE>
								<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
								</CFIF>
						</TD>						
					</TR>
					</CFOUTPUT>
				</TABLE>

				<BR>

				<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record
				
			</TD>
			<TD VALIGN="top">


				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">

				
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				

<CFPARAM NAME="Template_Note_Desc" DEFAULT="">
<CFPARAM NAME="Get_Item.Template_Note_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">


<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		Template_Notes
	Where		Template_Note_ID	like	'#URL.RID#'
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
			<FORM ACTION="save.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Notes</B></TD>
						<!--- <TD VALIGN="top" ROWSPAN="100%" BGCOLOR="Orange">&nbsp;</TD> --->
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Template_Note_Desc" VALUE="#Get_Item.Template_Note_Desc#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="Template_Note_ID" VALUE="#Get_Item.Template_Note_ID#">
							</CFOUTPUT>
						</TD>
					</TR>
					
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
						<TD VALIGN="top">

						<!--- Is this record deleted? --->
						<CFIF Get_Item.Deleted EQ 0 OR Get_Item.Deleted EQ "">
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>

						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="Deleted"#active#>Active
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive#>Inactive (*)
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
							<CFIF Get_Item.Deleted EQ 1>
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF>							
						</TD>
					</TR>
				</TABLE>
			</FORM>
				
			</TD>
		</TR>
	</TABLE>

<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="List_AND_Create.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>


