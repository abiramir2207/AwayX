<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<CFSET URL.PageTitle="CREATE TAX RECORD">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<CFPARAM NAME="URL.RID" DEFAULT="0">
 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Data" datasource="#application.datasource#">
	SELECT BB_Tax_Main_ID,Tax_Allowance_Code, Description, Deleted
	FROM BB_Tax_Main
	Order by	Description
</CFQUERY>

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
					</TR>
					<CFOUTPUT QUERY="Get_Data">
					<TR>
						<TD NOWRAP><A HREF="create_tax_record.cfm?RID=#BB_Tax_Main_ID#">#Description# &nbsp;&nbsp;(#Tax_Allowance_Code#)</A></TD>
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
        <cfif URL.RID EQ 0>
          <SPAN CLASS="title2">Add Record</SPAN>
        <cfelse>
				  <SPAN CLASS="title2">Edit Record</SPAN>
				</cfif>
        <HR COLOR="Blue" SIZE="1">
			
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		BB_Tax_Main
	Where		BB_Tax_Main_ID	=	'#URL.RID#'
</CFQUERY>
<link rel="stylesheet" type="text/css" media="screen" href="/Script/javascript/Ajax_JS/jquery.suggest.css" />
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<SCRIPT language="JavaScript">
function alert_and_delete(){
	var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
	if (confirmdelete == true){
		document.all.DeleteRecord.value=1;
		document.MyForm.submit();
	}
}	

function Validate(){
	var Submit_OK = 1;
	if (document.all.Tax_Allowance_Code.value == ""){
		alert("Please enter a tax code for this description.");
		document.all.Tax_Allowance_Code.focus();
		Submit_OK=0;	
		return;	
	}
	if (document.all.Description.value == ""){
		alert("Please enter some descrption.")
		document.all.Description.focus()
		Submit_OK=0;
		return;
	}
	if (Submit_OK == 1){	
		document.all.MyForm.submit()
	}	
}
</SCRIPT>			

			<FORM ACTION="save_tax_record.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0" border="0">
					<TR>
						<TD VALIGN="top" ALIGN="right" nowrap><B>Tax Code</B></TD>
						<TD VALIGN="top"  colspan="3">						
								<INPUT SIZE="55" NAME="Tax_Allowance_Code" VALUE="<CFOUTPUT>#Get_Item.Tax_Allowance_Code#</CFOUTPUT>" MAXLENGTH="50">												
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Description</B></TD>
						<TD VALIGN="top" colspan="3">
								<INPUT SIZE="55" NAME="Description" VALUE="<CFOUTPUT>#Get_Item.Description#</CFOUTPUT>" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="BB_Tax_Main_ID" VALUE="<CFOUTPUT>#Get_Item.BB_Tax_Main_ID#</CFOUTPUT>">
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
						<TD VALIGN="top" colspan="3">
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
						<TD VALIGN="top" colspan="3">
							<CFOUTPUT>
								<A HREF="javascript: Validate()">#application.util.string.actionLinkFormat("save data")#</A>				
								<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
							<CFIF Get_Item.Deleted EQ 1>
								<A HREF="javascript: alert_and_delete();">#application.util.string.actionLinkFormat("delete data")#</A>
							</CFIF>			
						</CFOUTPUT>
						</TD>
					</TR>
				</TABLE>
			</FORM>
			</TD>
		</TR>
	</TABLE>
<CFOUTPUT>
	<A HREF="create_Reason_Code.cfm">#application.util.string.actionLinkFormat("create new entry")#</A>
</CFOUTPUT>