

<CFSET URL.PageTitle="DEDUCTIONS: MANAGE #application.returned_customer_setting.operator_label_singular# FOR REASON CODE OF ACCRUAL">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.RID" DEFAULT="">
<cfset useLakebaseForGet_Operator = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_operator")>
<cfif useLakebaseForGet_Operator>
	<cftry>
		<cfset Get_Operator = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_operator", {
				"order" = "dd_operator_name.asc"
			}),
			"dd_operator_id,dd_operator_name,deleted"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Operator = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator>
<CFQUERY NAME="Get_Operator" datasource="#application.datasource#">
	Select		*
	From		DD_Operator
	Order by	DD_Operator_Name
</CFQUERY>
</cfif>

<TABLE>
	<TR>
	<td width="20%"><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"></td>
	<!--- <CFIF IsDefined("getUserName")>
	<TD>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<tr><td>
	<FONT SIZE="2"><B>This <cfif url.RID NEQ 0>file <cfelse> setting</cfif> was last updated on <CFOUTPUT>#dateformat(Get_LastUpdated_Details.PM_LastUpdated, 'm/d/yyy')# #timeformat(Get_LastUpdated_Details.PM_LastUpdated, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT></td></tr></table>
	</TD>
	</CFIF> --->
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
					<CFOUTPUT QUERY="Get_Operator">
					<TR>
						<TD NOWRAP><A HREF="create_Operator.cfm?RID=#DD_Operator_ID#">#DD_Operator_Name#</A></TD>
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


<CFPARAM NAME="Get_Item.DD_Operator_Name" DEFAULT="">
<CFPARAM NAME="Get_Item.DD_Operator_Address" DEFAULT="">
<CFPARAM NAME="Get_Item.DD_Operator_Address2" DEFAULT="">
<CFPARAM NAME="Get_Item.DD_City" DEFAULT="">
<CFPARAM NAME="Get_Item.DD_State" DEFAULT="">
<CFPARAM NAME="Get_Item.DD_ZipCode" DEFAULT="">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="">

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		DD_Operator
	Where		DD_Operator_ID	like	'#URL.RID#'
</CFQUERY>

<!--- Delete record --->
<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT language="JavaScript">
function validate()
{
	var validateStr = "";
	var submit_OK = 1;
	if (document.all.DD_Operator_Name.value == "")
	{
		validateStr = "Name;";	
		submit_OK = 0;			
	}
	if (document.all.DD_Operator_Address.value == "")
	{
		validateStr = validateStr + " Address 1;";
		submit_OK = 0;
	}	
	if (document.all.DD_City.value == "")
	{
		validateStr = validateStr + " City;";
		submit_OK = 0;
	}
	if (document.all.DD_State.value == "")
	{
		validateStr = validateStr + " State;";
		submit_OK = 0;
	}
	if (document.all.DD_ZipCode.value == 0)
	{
		validateStr = validateStr + " Postal Code;";
		submit_OK = 0;
	}
	
	if (submit_OK == 1)
	{
		document.MyForm.submit();
	}
	else
	{
		alert("Please enter " +validateStr+ " and try again.");
	}
}
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
			<FORM ACTION="save_Operator.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Name:</B></TD>
						<!--- <TD VALIGN="top" ROWSPAN="100%" BGCOLOR="Orange">&nbsp;</TD> --->
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="DD_Operator_Name" VALUE="#Get_Item.DD_Operator_Name#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="DD_Operator_ID" VALUE="#URL.RID#">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Address 1</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="DD_Operator_Address" VALUE="#Get_Item.DD_Operator_Address#" MAXLENGTH="50">
								<!--- <INPUT SIZE="45" NAME="PM_priority_Definition" VALUE="#Get_Item.PM_priority_Definition#" MAXLENGTH="500"> --->
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Address 2</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="DD_Operator_Address2" VALUE="#Get_Item.DD_Operator_Address2#" MAXLENGTH="50">
								<!--- <INPUT SIZE="45" NAME="PM_priority_Definition" VALUE="#Get_Item.PM_priority_Definition#" MAXLENGTH="500"> --->
							</CFOUTPUT>
						</TD>
					</TR>
					<CFQUERY NAME="getStates" datasource="#application.datasource#">
						Select s.*, c.Country_Sort_Order
						from _states s
						join _country c on s.Country_ID = c.Country_ID
						ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
					</CFQUERY>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>City/State/Postal</B></TD>
						<TD VALIGN="top">						
							<CFOUTPUT>
								<INPUT TYPE="Text" NAME="DD_City" VALUE="#Get_Item.DD_City#">
								<SELECT NAME="DD_State">
									<OPTION VALUE="" SELECTED></OPTION>
									<CFLOOP QUERY="getStates">
										<OPTION VALUE="<CFOUTPUT>#getStates.State_Code#</CFOUTPUT>" <CFIF Trim(getStates.State_Code) EQ Trim(Get_Item.DD_State)> SELECTED</CFIF>><CFOUTPUT>#getStates.State_Code#</CFOUTPUT></OPTION>
									</CFLOOP>
								</SELECT>&nbsp;
								<INPUT TYPE="text" NAME="DD_ZipCode" SIZE="4" VALUE="#Get_Item.DD_ZipCode#" MAXLENGTH="10">   <!--- ONKEYUP="clenseText(this,'0123456789')" --->
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
						<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive#>Inactive
						</CFOUTPUT>
						</TD>
					</TR>										
					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: validate()"><B>save data</B></A>
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
	<A HREF="create_Operator.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>


