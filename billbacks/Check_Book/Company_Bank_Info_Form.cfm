<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFSET URL.PageTitle="#application.CompanyName#: Company Bank Information">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<cfset useLakebaseForGet_Bank_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_bank_info")>
<cfif useLakebaseForGet_Bank_Info>
	<cftry>
		<cfset Get_Bank_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_bank_info", {
				"order" = "bank_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Bank_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Bank_Info>
<CFQUERY NAME="Get_Bank_Info" datasource="#application.datasource#">
	Select		*
	From		Company_Bank_Info
	Order by	Bank_Name
</CFQUERY>
</cfif>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="765">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">
				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Bank Name</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_Bank_Info">
					<TR>
						<TD NOWRAP><CFIF not isdefined("URL.FromPayment")><A HREF="Company_Bank_Info_Form.cfm?RID=#Bank_Info_ID#">#Bank_Name#</A><CFELSE>#Bank_Name#</CFIF></TD>
						<TD NOWRAP>
								<CFIF Bank_Info_deleted EQ 0>
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
			<TD VALIGN="top" WIDTH="470">


				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
<CFPARAM NAME="URL.RID" DEFAULT="0">

<cfset useLakebaseForGet_Item = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_bank_info")>
<cfif useLakebaseForGet_Item>
	<cftry>
		<cfset Get_Item = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_bank_info", {
				"bank_info_id" = "eq.#URL.RID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Item = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Item>
<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		Company_Bank_Info
	Where		Bank_Info_Id='#URL.RID#'
</CFQUERY>
</cfif>


<CFPARAM NAME="Get_Item.Bank_Name" DEFAULT="">
<CFPARAM NAME="Get_Item.Debit_Account_No" DEFAULT="">				
<CFPARAM NAME="Get_Item.Debit_Account_No" DEFAULT="0">


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

			<FORM ACTION="Save_Company_Bank_Info.cfm" METHOD="post" NAME="MyForm"> 
				<CFOUTPUT><INPUT TYPE="hidden" NAME="Bank_Info_ID" VALUE="#Get_Item.Bank_Info_ID#"></CFOUTPUT>
				<CFIF isdefined("URL.FromPayment")>
					<CFOUTPUT>
					<INPUT TYPE="hidden" NAME="FromPayment" VALUE="#URL.FromPayment#">
					<INPUT TYPE="hidden" NAME="new_bb_check" VALUE="#URL.new_bb_check#">
					<INPUT TYPE="hidden" NAME="Trans_type" VALUE="#URL.Trans_type#">
					<INPUT TYPE="hidden" NAME="CRID" VALUE="#URL.CRID#">
					</CFOUTPUT>
				</CFIF>
				<TABLE CELLSPACING="0" CELLPADDING="2">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Bank Name</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
							<CFIF URL.RID NEQ 0>
								<INPUT SIZE="45" NAME="Bank_Name" VALUE="#Get_Item.Bank_Name#" READONLY>								
							<CFELSE>
								<INPUT SIZE="45" NAME="Bank_Name" VALUE="#Get_Item.Bank_Name#">								
							</CFIF>


							</CFOUTPUT>
						</TD>
					</TR>

					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>Debit Account No</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
							<CFIF URL.RID NEQ 0>
								<INPUT TYPE="password" SIZE="45" NAME="Debit_Account_No" VALUE="#Get_Item.Debit_Account_No#" READONLY>
							<CFELSE>
								<INPUT TYPE="password" SIZE="45" NAME="Debit_Account_No" VALUE="#Get_Item.Debit_Account_No#">
							</CFIF>

							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
						<TD VALIGN="top">

					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- Get the number of projects that have this sponsor: If there is at least 1 project that is active and has this sponsor, then I will not allow the user to delete this sponsor --->
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
						<cfset useLakebaseForDelete_Check = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_bank_info")>
<cfif useLakebaseForDelete_Check>
	<cftry>
		<cfset Delete_Check = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_bank_info", {
				"bank_info_deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Check = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Check>
<CFQUERY NAME="Delete_Check" DATASOURCE="#Application.datasource#">
							SELECT * FROM Company_Bank_Info WHERE Bank_Info_Deleted = 0						
						</CFQUERY>
</cfif>
						<CFIF Delete_Check.recordcount LT 2>
							<CFSET disabled = "DISABLED">
						</CFIF>
						<CFIF Get_Item.Bank_Info_Deleted EQ 1>
							<CFSET disabled = "">
						</CFIF>
						<CFPARAM NAME="Disabled" DEFAULT="">
						
						<!--- Is this record deleted? --->
						<CFIF Get_Item.Bank_Info_Deleted EQ 0 OR Get_Item.Bank_Info_Deleted EQ "">
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>

						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="Bank_Info_Deleted"#active#>Active
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="Bank_Info_Deleted"#inactive# #disabled#>Inactive (*)
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
							<CFIF Get_Item.Bank_Info_Deleted EQ 1>
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF><p></p>

							(*) A disabled "inactive" choice indicates that there is at least one active bank info that has this status. Thus, the user will not be able to make this status inactive.

						</TD>
					</TR>
				</TABLE>
			</FORM>
				
			</TD>
		</TR>
	</TABLE>
<CFIF not isdefined("URL.FromPayment")>
<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="Company_Bank_Info_Form.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>

</CFIF>

</body>
</html>
