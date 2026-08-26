<CFSET PAGE_TITLE="Search Payables...">
<CFSET GROUP="payables">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

			
<STYLE TYPE="text/css">
	.red
	{
		font-size:11px;
		width: 300px;
	}
</STYLE>


<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=11>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->


<CENTER>
<FIELDSET STYLE="padding:10px; width: 1%; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">search payables</LEGEND>


<FORM NAME="SearchForm">
  <TABLE border="0" cellspacing="0" cellpadding="3" WIDTH="480">
    <TR>
      <TD valign="top"><SPAN CLASS="title2">Payable Number:</SPAN><BR>
        <INPUT type="text" name="payable_number" size="27"></TD>
      <TD valign="top"><SPAN CLASS="title2"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name:</SPAN><BR>
        <INPUT type="text" name="payable_distributor_name" size="27"></TD>
    </TR>
    <TR>
      <TD valign="top"><SPAN CLASS="title2">Broker:</SPAN><BR>
        <INPUT type="text" name="payable_distributor_broker_name" size="27"></TD>
      <TD valign="top"><SPAN CLASS="title2"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>:</SPAN><BR>
        <INPUT type="text" name="payable_contract_operator_name" size="27"></TD>
    </TR>
    <TR>
      <TD valign="top"><SPAN CLASS="title2">Billback Ref. Number:</SPAN><BR>
        <INPUT type="text" name="billback_ref_number" size="27"></TD>
      <TD valign="top"><SPAN CLASS="title2">Days Old:</SPAN><BR>
        <INPUT type="text" name="payable_age_days" size="6"></TD>
    </TR>
    <TR>
      <TD valign="top" COLSPAN="2">
	  
	  
			<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0">
				<TR>
					<TD COLSPAN="3"><SPAN CLASS="title2">Billback Date falls between...</SPAN></TD>
				</TR>
				<TR>
					<TD>
						<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="billback_creation_date_start" FORMAT="mm/dd/yyyy"></TD>
					<TD ALIGN="center">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						and
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<TD>
						<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="billback_creation_date_end" FORMAT="mm/dd/yyyy">
					</TD>
				</TR>
				<TR>
					<TD COLSPAN="3"><BR><SPAN CLASS="title2">Payment Date falls between...</SPAN></TD>
				</TR>
				<TR>
					<TD>
						<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="payment_date_start" FORMAT="mm/dd/yyyy">
					</TD>
					<TD ALIGN="center">and</TD>
					<TD>
						<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="payment_date_end" FORMAT="mm/dd/yyyy">
					</TD>
				</TR>
			</TABLE>
	</TD>
    </TR>
    <TR>
      <TD valign="top"></TD>
      <TD valign="top"></TD>
    </TR>
    <TR>
      <TD valign="top"><SPAN CLASS="title2">Payable Status:</SPAN><BR>
        <INPUT type="radio" value="1" checked name="payable_status">Work in Progress<BR>
        <INPUT type="radio" value="2" checked name="payable_status">Pre-approved<BR>
        <INPUT type="radio" value="3" checked name="payable_status">Approved</TD>
      <TD valign="top"><BR>
        <INPUT type="radio" value="5" checked name="payable_status">Aging<BR>
        <INPUT type="radio" value="4" checked name="payable_status">Paid<BR>
        <INPUT type="radio" value="6" checked name="payable_status">All Payables</TD>
    </TR>
  </TABLE>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->







<!--- 	<TABLE border="0" cellspacing="10" CELLPADDING="0">
		<TR>
			<TD>
				<B><SPAN CLASS="title2">Payable Number:</SPAN></B><BR>
				<INPUT type="text" name="payable_number" size="32" CLASS="red">
			</TD>
		</TR>
		<TR>

			<TD>
				<B><SPAN CLASS="title2">Billback Number:</SPAN></B><BR>
				<INPUT type="text" name="billback_number" size="32" CLASS="red">
			</TD>
<!--- 
		</TR>

		<TR>
			
			<TD><B><SPAN CLASS="title2">Distributor:</SPAN></B><BR>
				<SELECT size="1" name="distributor" CLASS="red">
					<OPTION VALUE="distributor id goes here">distributor description goes here</OPTION>
					<OPTION VALUE="distributor id goes here">distributor description goes here</OPTION>
					<OPTION VALUE="distributor id goes here">distributor description goes here</OPTION>
					<OPTION VALUE="distributor id goes here">distributor description goes here</OPTION>
					<OPTION VALUE="distributor id goes here">distributor description goes here</OPTION>
					<OPTION VALUE="distributor id goes here">distributor description goes here</OPTION>
					<OPTION VALUE="distributor id goes here">distributor description goes here</OPTION>
				</SELECT>
			</TD>
		</TR>
		<TR>
			<TD>
				<B><SPAN CLASS="title2">Billback Date falls between:</SPAN></B><BR>
				<CFPARAM name="FORM.start_date" 					default="">
				<CFPARAM name="FORM.end_date" 						default="">
				<TABLE>
				<TR>
					<TD></TD>
					<TD><CF_EASYDATE FORMNAME="MyForm" FIELDNAME="start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.start_date#"></TD>
					<TD>and </TD>
					<TD><CF_EASYDATE FORMNAME="MyForm" FIELDNAME="end_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.end_date#"></TD>
				</TR>
				</TABLE>
			</TD>
		</TR>
		<TR>

	
 		</TR>
		<TR>
			<TD>
				<B><SPAN CLASS="title2">Payable Status:</SPAN></B><BR>
				<FONT SIZE="2">
				<INPUT TYPE="radio" NAME="payable_status" VALUE="3" CHECKED>Pre-Approval
				<INPUT TYPE="radio" NAME="payable_status" VALUE="1">Approved
				<INPUT TYPE="radio" NAME="payable_status" VALUE="2">Paid
				<INPUT TYPE="radio" NAME="contract_status" VALUE="0">All Payables
				</FONT>
			</TD>
		</TR>
--->
		<TR>
			<TD COLSPAN="2">
			</TD>
		</TR>
		
	</TABLE>
 --->

<BR> 

	<CF_button
		button_name		=	""
		button_caption	=	"search payables"
		button_action	=	"javascript: opener.transportFormElementsFromPopupToParentPage();"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Click here to search the payables database"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">



<input TYPE="Hidden" NAME="maxrows" VALUE="25">
</FORM>

</FIELDSET>
</CENTER>


</BODY>
</HTML>
<SCRIPT>
	opener.reSelectOptionsInSearchForm()
</SCRIPT>
