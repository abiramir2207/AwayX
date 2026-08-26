
<CFSET URL.PageTitle="Billback: SHORTPAY REASON CODE">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_shortpay_reason")>
<cfif useLakebaseForGet_Data>
	<cftry>
		<cfset Get_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_shortpay_reason", {
				"order" = "sp_reason_description.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Data>
<CFQUERY NAME="Get_Data" datasource="#application.datasource#">
	Select		*
	From		BB_ShortPay_Reason
	Order by	SP_Reason_Description
</CFQUERY>
</cfif>


<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">

				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
						<!--- <TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Needs Approval</B></SPAN></TD> --->
					</TR>
					<CFOUTPUT QUERY="Get_Data">
					<TR>
						<TD NOWRAP><A HREF="SP_ReasonCode.cfm?RID=#BB_ShortPay_Reason_ID#">#SP_Reason_Description# &nbsp;&nbsp;(#SP_Reason_Code#)</A></TD>
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
<CFPARAM NAME="URL.RID" DEFAULT="">
<CFPARAM NAME="Get_Item.SP_Reason_Code" DEFAULT="">
<CFPARAM NAME="Get_Item.SP_Reason_Description" DEFAULT="">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">


<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		BB_ShortPay_Reason
	Where		BB_ShortPay_Reason_ID	like	'#URL.RID#'
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
function Validate()
{
	var Submit_OK = 1;
	if (document.all.SP_Reason_Code.value == "")
	{
		alert("Please enter a short pay reason code for this description.");
		document.all.SP_Reason_Code.focus();
		Submit_OK=0;	
		return;	
	}
	if (document.all.SP_Reason_Description.value == "")
	{
		alert("Please enter some descrption.")
		document.all.SP_Reason_Description.focus()
		Submit_OK=0;
		return;
	}
	
	if (Submit_OK == 1)
	{	
		document.all.MyForm.submit()
	}	
}
</SCRIPT>			




			<FORM ACTION="SP_ReasonCode_Save.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>ShortPay Reason code</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="SP_Reason_Code" VALUE="#Get_Item.SP_Reason_Code#" MAXLENGTH="50">								
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>ShortPay Description</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="SP_Reason_Description" VALUE="#Get_Item.SP_Reason_Description#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="RID" VALUE="#URL.RID#">
							</CFOUTPUT>
						</TD>
					</TR>
					
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
						<TD VALIGN="top">

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
					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top">
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
	<A HREF="SP_ReasonCode.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>

