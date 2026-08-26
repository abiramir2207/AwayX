<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
<cfset lblReasonCode = stDeductionLabels["Reason Code"] />
<cfset lblReasonCodeLower = LCase(lblReasonCode) />
<CFSET URL.PageTitle="#UCase(lblReasonCode)# MANAGEMENT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<CFPARAM NAME="URL.RID" DEFAULT="0">
 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
<cfif useLakebaseForGet_Data>
	<cftry>
		<cfset Get_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_reason_code", {
				"order" = "dd_reason_code_description.asc"
			}),
			"dd_reason_code_id,dd_reason_code_description,dd_reason_code,deleted,need_approval"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Data>
<CFQUERY NAME="Get_Data" datasource="#application.datasource#">
	Select		*
	From		DD_Reason_Code
	Order by	DD_Reason_Code_Description
</CFQUERY>
</cfif>

<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery-1.2.1-min.js"></script>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.dimensions.js"></script>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery.suggest.js"></script>
<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">

				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
            <TD>&nbsp; </TD>	
            <TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Display In</B></SPAN></TD>
						<!--- <TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Needs Approval</B></SPAN></TD> --->
						
					</TR>
					<CFOUTPUT QUERY="Get_Data">
					<TR>
						<TD NOWRAP><A HREF="create_Reason_Code.cfm?RID=#DD_Reason_Code_ID#">#DD_Reason_Code_Description# &nbsp;&nbsp;(#DD_Reason_Code#)</A></TD>
						<TD NOWRAP>							
							<CFIF Deleted EQ 0>
							<IMG SRC="/images/yes_small.gif" TITLE="active record...">
							<CFELSE>
							<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
							</CFIF>										
						
							<CFIF Need_Approval EQ 1>
								<img src="/Images/alert_icon_small.gif" title="Needs approval" width="10" height="10" border="0">
							</CFIF>
									
						</TD>
						<TD>
							<cfif (Display_In EQ 1 AND Is_Default IS 1) OR (Display_In EQ 2 AND Is_BB_Default IS 1) OR (Display_In EQ 3 AND (Is_Default IS 1 OR Is_BB_Default IS 1))>
							default
							<cfelse>
							&nbsp; 
							</cfif>
						</TD>	
            <td align="center">

            <!--- 1=Deduction, 2=Billback, 3=Both --->
              <cfif Display_In EQ 1>
              #appSettings.DeductionNumberPrefix#
              <cfelseif Display_In EQ 2>
               #appSettings.BillbackNumberPrefix#
              <cfelseif Display_In EQ 3>
                Both  
              </cfif>
            </td>
					</TR>
					</CFOUTPUT>
				</TABLE>

				<BR>

				<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record
				
			</TD>
			<TD VALIGN="top">
        <cfif URL.RID EQ 0>
          <SPAN CLASS="title2">Add Record</SPAN>
        <cfelse>
				  <SPAN CLASS="title2">Edit Record</SPAN>
				</cfif>
        <HR COLOR="Blue" SIZE="1">
			
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				

<CFPARAM NAME="DD_Reason_Code" DEFAULT="">
<CFPARAM NAME="DD_Reason_Code_Description" DEFAULT="">
<CFPARAM NAME="Get_Item.DD_Reason_Code_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Need_Approval" DEFAULT="0">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">
<CFPARAM NAME="Get_Item.Show_Operator" DEFAULT="0">
<CFPARAM NAME="Get_Item.Closing_Method" DEFAULT="0">
<cfparam name="form.gl_account_code" default="" />

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		DD_Reason_Code
	Where		DD_Reason_Code_ID	like	'#URL.RID#'
</CFQUERY>
<link rel="stylesheet" type="text/css" media="screen" href="/Script/javascript/Ajax_JS/jquery.suggest.css" />
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

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
<cfoutput>
function Validate()
{
	var Submit_OK = 1;
	if (document.all.DD_Reason_Code.value == "")
	{
		alert("Please enter a #lblReasonCodeLower# for this description.");
		document.all.DD_Reason_Code.focus();
		Submit_OK=0;	
		return;	
	}
	if (document.all.DD_Reason_Code_Description.value == "")
	{
		alert("Please enter some descrption.")
		document.all.DD_Reason_Code_Description.focus()
		Submit_OK=0;
		return;
	}
	<CFIF appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>
	if (!(Any_Object_Checked(document.all.Closing_Method)))	
	{
		alert("Please associate a closing method for this #lblReasonCodeLower#.")
		Submit_OK=0;
		return;
	}
	</CFIF>
	if (Submit_OK == 1)
	{	
		document.all.MyForm.submit()
	}	
	
}

</cfoutput> 
                         jQuery(function() {
$("#gl_account_code").suggest("/components/Deduction/settings/gl_search_ajax.cfc?method=gl_search",{
onSelect: function() {}});
});
</SCRIPT>			


			<FORM ACTION="save_Reason_Code.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0" border="0">
					<TR><CFOUTPUT>
						<TD VALIGN="top" ALIGN="right" nowrap><B>#lblReasonCode#</B></TD>
						<TD VALIGN="top"  colspan="3">
							
								<INPUT SIZE="55" NAME="DD_Reason_Code" VALUE="#Get_Item.DD_Reason_Code#" MAXLENGTH="50">								
							
						</TD></CFOUTPUT>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Description</B></TD>
						<TD VALIGN="top" colspan="3">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="DD_Reason_Code_Description" VALUE="#Get_Item.DD_Reason_Code_Description#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="DD_Reason_Code_ID" VALUE="#Get_Item.DD_Reason_Code_ID#">
							</CFOUTPUT>
						</TD>
					</TR>
					<cfif appsettings.getGL_Account_On()>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B><cfoutput>#Application.GLAccountLabel#</cfoutput> Code</B></TD><!---D42774 --->
						<TD VALIGN="top"  colspan="3">
                          <input size="30" style="position: absolute;" name="gl_account_code" id="gl_account_code"  value="<cfoutput>#Get_Item.GL_Account_Code#</cfoutput>" autocomplete="off" />
                          </TD>
					</TR>
					</cfif>

					<CFIF application.returned_customer_setting.DD_Show_Operator_For_RC_Of_Accrual EQ 1>
					<CFSET CheckThis = "">
					<CFIF Get_Item.Show_Operator EQ 1>
						<CFSET CheckThis = "Checked">
					</CFIF>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Show <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Table</B></TD>
						<TD VALIGN="top" colspan="3"><CFOUTPUT><INPUT TYPE="CheckBox" NAME="Show_Operator" VALUE="1" #CheckThis#></CFOUTPUT>
								
					</TR>
					</CFIF>
					<CFIF appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Closing Method</B></TD>
						<TD VALIGN="top"  colspan="3">
							<CFOUTPUT>
							<INPUT TYPE="radio" VALUE="1" NAME="Closing_Method" <CFIF Get_Item.Closing_Method EQ 1>CHECKED</CFIF>>Billback
							&nbsp;&nbsp;&nbsp;
							<INPUT TYPE="radio" VALUE="2" NAME="Closing_Method" <CFIF Get_Item.Closing_Method EQ 2>CHECKED</CFIF>>Match with Credit
							&nbsp;&nbsp;&nbsp;
							<INPUT TYPE="radio" VALUE="3" NAME="Closing_Method" <CFIF Get_Item.Closing_Method EQ 3>CHECKED</CFIF>>Write off
							&nbsp;&nbsp;&nbsp;
							<INPUT TYPE="radio" VALUE="4" NAME="Closing_Method" <CFIF Get_Item.Closing_Method EQ 4>CHECKED</CFIF>>Rebills							
							&nbsp;&nbsp;&nbsp;
							<INPUT TYPE="radio" VALUE="5" NAME="Closing_Method" <CFIF Get_Item.Closing_Method EQ 5>CHECKED</CFIF>>Reject
							&nbsp;&nbsp;&nbsp;
							<INPUT TYPE="radio" VALUE="6" NAME="Closing_Method" <CFIF Get_Item.Closing_Method EQ 6>CHECKED</CFIF>>Auto Close
							</CFOUTPUT>	
						</TD>
					</TR>
					</CFIF>
					<!--- 
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Need Approval</B></TD>
						<CFIF Get_Item.Need_Approval EQ 0 OR Get_Item.Need_Approval EQ "">
							<CFSET No=" CHECKED">
							<CFSET Yes="">
						<CFELSE>
							<CFSET No="">
							<CFSET Yes=" CHECKED">
						</CFIF>
						<TD VALIGN="top">
							<CFOUTPUT>
							<INPUT TYPE="radio" VALUE="1" NAME="Need_Approval"#Yes#>Yes
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<INPUT TYPE="radio" VALUE="0" NAME="Need_Approval"#No#>No
							</CFOUTPUT>	
						</TD>
					</TR> --->
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
						<TD VALIGN="top" colspan="3">

						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
						<!--- Get the number of projects that have this phase: If there is at least 1 project that is active and has this phase, then I will not allow the user to delete this phase --->
						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
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
          <tr>
          	<td valign="top" align="right"><B>Display In</B></TD>
						<td valign="top" colspan="3">
            <!--- 1=Deduction, 2=Billback, 3=Both  --->
              <cfoutput>
  						  <cfif (appSettings.Show_Reason_Code_On_BB_Approval_Screen EQ 1 OR appSettings.ReasonCodeInBillbackDed EQ 1)>
                  <input type="radio" value="2" name="Display_In" <cfif Get_Item.Display_In EQ 2>checked</cfif>>Billback
    						  &nbsp;&nbsp;&nbsp; 
                </cfif>
    						<input type="radio" value="1" name="Display_In" <cfif ((appSettings.Show_Reason_Code_On_BB_Approval_Screen EQ 0 AND appSettings.ReasonCodeInBillbackDed EQ 0) OR (Get_Item.Display_In EQ 1 OR Get_Item.RecordCount EQ 0))>checked</cfif>>Deduction
                <cfif (appSettings.Show_Reason_Code_On_BB_Approval_Screen EQ 1 OR appSettings.ReasonCodeInBillbackDed EQ 1)>
                  &nbsp;&nbsp;&nbsp;
                  <input type="radio" value="3" name="Display_In" <cfif Get_Item.Display_In EQ 3>checked</cfif>>Both
                </cfif>
						  </cfoutput>
            </td>
            
          </tr>
					<tr>
						<td align="right"><strong>DD Default</strong></td>
						<td valign="top" width="15%">									
							<INPUT TYPE="CheckBox" VALUE="1" NAME="Is_Default" <CFIF Get_Item.Is_Default EQ 1>CHECKED</CFIF>>Yes
            </td>
            <cfif (appSettings.Show_Reason_Code_On_BB_Approval_Screen EQ 1 OR appSettings.ReasonCodeInBillbackDed EQ 1)>
              <td align="right">
                <strong> BB Default</strong>
              </td>
              <td valign="top" width="55%">
                <INPUT TYPE="CheckBox" VALUE="1" NAME="Is_BB_Default" <CFIF Get_Item.Is_BB_Default EQ 1>CHECKED</CFIF>>Yes
  						</td>
            </cfif>
					</tr>
					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top" colspan="3">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: Validate()"><B>save data</B></A>
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
	<A HREF="create_Reason_Code.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>

