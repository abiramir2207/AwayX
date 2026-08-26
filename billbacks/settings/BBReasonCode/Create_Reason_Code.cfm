<!--- 
##	codeType rquired  -- defaults to dd.  Pass other types in url
##	dd = DD_reason_code table -- Deductions and Billback reason codes live in this table
##	PC = PC_reason_code table -- Profit Center codes and descs
##	GL = GL_Reason_Code table -- General Ledger codes and descs
## 
## this form could be ussed in place of the Deductions/settings/create_reason_code.cfm version as long as a codeType is supplied.
## it is a modified version of that file
## mws 9-14-04
--->
<STYLE>
TD.foreground
	{
		border-left :		1px solid Gray;
		border-right :		1px solid Gray;
		border-top :		1px solid Gray;
		color: 				Red;
	}
TD.background
	{
		border-left:		1px solid Gray;
		border-right:		1px solid Gray;
		border-top :		1px solid Gray;
		border-bottom:		1px solid Gray;
		color: 				White;
		cursor:				pointer;
	}
TD.Filler
	{
		border-left:		1px solid White;
		border-bottom:		1px solid Gray;
		color: 				White;
	}
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
</STYLE>

<cfparam name="codeType" default="dd">
<cfswitch expression="#codetype#">
	<cfcase value="dd">
		<CFSET URL.PageTitle="Deductions/BillBacks: Reason Code Manager">
	</cfcase>
	<cfcase value="bb">
		<CFSET URL.PageTitle="Deductions/BillBacks: Reason Code Manager"><cfset codeType = "dd"><!--- dd and bb use same codes --->
	</cfcase>
	<cfcase value="pc">
		<CFSET URL.PageTitle="Profit Center: Code Manager">
	</cfcase>
	<cfcase value="gl">
		<CFSET URL.PageTitle="General Ledger: Code Manager">
	</cfcase>
	<cfdefaultcase>
		<CFSET URL.PageTitle="REASON CODE MANAGEMENT">
		Invalid Code Type!  Please try again.<br>Code Type = <cfoutput>#codetype#</cfoutput><cfabort>
	</cfdefaultcase>
</cfswitch>

<CFSET hWidth=150>
<CFOUTPUT>
<!--- Line it up --->
<table align="center">
<tr>
	<td>

<TABLE border="0" width="775" cellspacing="0" cellpadding="1">
	<TR>
		<CFIF codeType EQ "dd" or codeType EQ "BB">
			<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>Deduction/BB Codes</nobr></font></B></TD>
		<CFELSE>
			<A HREF="create_Reason_Code.cfm?codeType=dd" CLASS="tablink_back"><TD WIDTH="#hWidth#" CLASS="background" BGCOLOR="B9DCFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><A HREF="create_Reason_Code.cfm?codeType=dd" CLASS="tablink_back"><nobr>Deduction/BB Codes</nobr></A></B></TD></A>
		</CFIF>
		<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		
		<CFIF codeType EQ "PC">
			<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>Profit Center Codes</nobr></font></B></TD>
		<CFELSE>
			<A HREF="create_Reason_Code.cfm?codeType=pc" CLASS="tablink_back"><TD WIDTH="#hWidth#" CLASS="background" BGCOLOR="B9DCFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><A HREF="create_Reason_Code.cfm?codeType=pc" CLASS="tablink_back"><nobr>Profit Center Codes</nobr></A></B></TD></A>
		</CFIF>
		<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		
		<CFIF codeType EQ "GL">
			<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>General Ledger Codes</nobr></font></B></TD>
		<CFELSE>
			<A HREF="create_Reason_Code.cfm?codeType=gl" CLASS="tablink_back"><TD WIDTH="#hWidth#" CLASS="background" BGCOLOR="B9DCFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><A HREF="create_Reason_Code.cfm?codeType=gl" CLASS="tablink_back"><nobr>General Ledger Codes</nobr></A></B></TD></A>
		</CFIF>
		<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		<TD WIDTH="90%" CLASS="Filler">&nbsp;</TD>
	</TR>		
</TABLE>	
</CFOUTPUT>	

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFINCLUDE TEMPLATE="/settings/settings_title.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Data" datasource="#application.datasource#">
	Select		#codeType#_Reason_Code as Reason_Code, 
				#codeType#_Reason_Code_Description as Reason_Code_Description,
				#codeType#_Reason_Code_id as Reason_Code_id,
				Need_Approval,
				Deleted,
				Created_Date,
				Show_Operator
				
	From		#codeType#_Reason_Code
	Order by	#codeType#_Reason_Code_Description
</CFQUERY>	

<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top" width="50%">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">

				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="90%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
						<!--- <TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Needs Approval</B></SPAN></TD> --->
					</TR>
					<CFOUTPUT QUERY="Get_Data">
					<TR>
						<TD><A HREF="create_Reason_Code.cfm?RID=#Reason_Code_ID#&codeType=#codeType#">#Reason_Code_Description# &nbsp;&nbsp;(#Reason_Code#)</A></TD>
						<TD>							
							<CFIF Deleted EQ 0>
							<IMG SRC="/images/yes_small.gif" TITLE="active record...">
							<CFELSE>
							<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
							</CFIF>										
						
							<CFIF Need_Approval NEQ 0>
								<img src="/Images/alert_icon_small.gif" title="Needs approval" width="10" height="10" border="0">
							</CFIF>
									
						</TD>
					</TR>
					</CFOUTPUT>
				</TABLE>

				<BR>

				<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record
				
			</TD>
						<FORM ACTION="save_Reason_Code.cfm" METHOD="post" NAME="MyForm">
			<TD VALIGN="top" width="50%">
				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">
			
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
<CFPARAM NAME="URL.RID" DEFAULT="0">
<CFPARAM NAME="Reason_Code" DEFAULT="">
<CFPARAM NAME="Reason_Code_Description" DEFAULT="">
<CFPARAM NAME="Get_Item.Reason_Code_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Need_Approval" DEFAULT="0">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">
<CFPARAM NAME="Get_Item.Show_Operator" DEFAULT="0">

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		#codeType#_Reason_Code as Reason_Code, 
				#codeType#_Reason_Code_Description as Reason_Code_Description,
				#codeType#_Reason_Code_id as Reason_Code_id,
				Need_Approval,
				Deleted,
				Created_Date,
				Show_Operator
	From		#codeType#_Reason_Code
	Where		#codeType#_Reason_Code_ID	like	'#URL.RID#'
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
	if (document.all.Reason_Code.value == "")
	{
		alert("Please enter a reason code for this description.");
		document.all.DD_Reason_Code.focus();
		Submit_OK=0;	
		return;	
	}
	if (document.all.Reason_Code_Description.value == "")
	{
		alert("Please enter some descrption.")
		document.all.Reason_Code_Description.focus()
		Submit_OK=0;
		return;
	}
	
	if (Submit_OK == 1)
	{	
		document.all.MyForm.submit()
	}	
}
</SCRIPT>

				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" colspan="2"><B><cfif codeType is "pc">
															Profit Center Code
														<cfelseif codeType is "gl">
															General Ledger Code
														<cfelse>
															Reason code
														</cfif></B></TD>
					</TR>
					<TR>
						<TD VALIGN="top" colspan="2">
					         <CFOUTPUT>
								<INPUT SIZE="55" NAME="Reason_Code" VALUE="#Get_Item.Reason_Code#" MAXLENGTH="50">								
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" colspan="2"><B>Description</B></TD>
					</TR>
					<TR>
					<TD VALIGN="top" colspan="2">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Reason_Code_Description" VALUE="#Get_Item.Reason_Code_Description#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="Reason_Code_ID" VALUE="#Get_Item.Reason_Code_ID#">
							</CFOUTPUT>
						</TD>
					
					</TR>
					<CFIF application.returned_customer_setting.DD_Show_Operator_For_RC_Of_Accrual EQ 1>
					<CFSET CheckThis = "">
					<CFIF Get_Item.Show_Operator EQ 1>
						<CFSET CheckThis = "Checked">
					</CFIF>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Show <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Table</B></TD>
						<TD VALIGN="top"><CFOUTPUT><INPUT TYPE="CheckBox" NAME="Show_Operator" VALUE="1" #CheckThis#></CFOUTPUT>
								
					</TR>
					</CFIF>
					<cfif codeType is "dd">
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
					</TR>
					<cfelse>
						<input type="Hidden" name="Need_Approval" value="0">
					</cfif>
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
							<!--- <CFIF Get_Item.Deleted EQ 1>
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF> --->							
						</TD>
					</TR>
				</TABLE>
				
				<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
			     <cfoutput><INPUT TYPE="hidden" NAME="codeType" VALUE="#codeType#"></cfoutput>
			     </FORM>
				
			</TD>
		</TR>
	</TABLE>

<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<cfoutput><A HREF="create_Reason_Code.cfm?codeType=#codeType#"><B>create new entry</B></A></cfoutput>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
</td>
</tr>
</table>
