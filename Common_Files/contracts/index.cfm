<CFSET PAGE_TITLE="Contract Management">
<CFSET group="contracts">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>



<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5">
	<TR>
		<TD VALIGN="top">
			<IMG SRC="/images/icon_contracts_large.gif" BORDER="0" ALT="">
		</TD>
		<TD BGCOLOR="Navy"></TD>
		<TD VALIGN="top">
			<BLOCKQUOTE>
			<DIV CLASS="title2">Contract Management Overview:</DIV>
			<BR><BR>


	
	
	<table border="0" cellspacing="0" cellpadding="5">
  <tr>
    <td valign="top" align="right">
      <p style="margin-right: 0; margin-bottom: 4"><B><FONT color="#008000">Components:</FONT></B></td>
    <td valign="top">
      <p align="left" style="margin-bottom: 4">Each
      contract contains basic information, eligible <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> and <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput>,
      and products with corresponding rates.&nbsp; Additionally, you can select
      all or some of you brokers and field sales members to communicate with
      regarding the specifics.</td>
  </tr>
  <tr>
    <td valign="top" align="right">
      <p style="margin-right: 0; margin-bottom: 4"><B><FONT color="#008000">Work
      in progress:</FONT></B></td>
    <td valign="top">Once
      you have saved the basic information for a contract, it becomes a work in
      progress that can be reopened and edited at any time.</td>
  </tr>
  <tr>
    <td valign="top" align="right">
      <p style="margin-right: 0; margin-bottom: 4"><B><FONT color="#008000">Pre-Active
      and Active:</FONT></B></td>
    <td valign="top">A
      work in progress must be approved by someone within your company who has
      access rights to do so.&nbsp; Once it is approved, it becomes Preactive,
      meaning it has been approved but is not yet active as the start date has
      not arrived.&nbsp; Once it does, the system will automatically update the
      status.</td>
  </tr>
  <tr>
    <td valign="top" align="right">
      <p style="margin-right: 0; margin-bottom: 4"><B><FONT color="#008000">Expiring:</FONT></B></td>
    <td valign="top">The
      default setting for flagging contract expiration is 90 days -- once a
      contract has only 90 days remaining, the system will automatically change
      the status to Expiring.&nbsp; As this setting is global to your company,
      please contact your company representative to discuss revising it.</td>
  </tr>
  <tr>
    <td valign="top" align="right">
      <p style="margin-right: 0; margin-bottom: 4"><B><FONT color="#008000">Archive/Expired:</FONT></B></td>
    <td valign="top">Once
      the contract has reached the end date, it becomes expired and is placed in
      an archive.</td>
  </tr>
  <tr>
    <td valign="top" align="right">
      <p style="margin-right: 0; margin-bottom: 4"><B><FONT color="#008000">Communication:</FONT></B></td>
    <td valign="top">Throughout
      the process, you have the option of emailing or faxing contracts to your
      brokers, field sales force, and other internal customers.</td>
  </tr>
  <tr>
    <td valign="top" align="right">
      <p style="margin-right: 0; margin-bottom: 4"><B><FONT color="#008000">Templates:</FONT></B></td>
    <td valign="top">These
      tools allow you to create most or all of a contract and save it for future
      use in creating additional new contracts.&nbsp; This is particularly
      helpful if the contracts you are working with contain many of the same
      products as it will eliminate time spent selecting those items in the
      future.</td>
  </tr>
  <tr>
    <td valign="top" align="right">
      <p style="margin-right: 0; margin-bottom: 4"><B><FONT color="#008000">History
      &amp; Revision Tracking:</FONT></B></td>
    <td valign="top">
      <p align="left" style="margin-bottom: 4">Any
      time a contract is edited, the system captures the changes made and
      records the date, time, and user who made the changes.&nbsp; Over time,
      this provides you with a detailed summary of changes made to each
      contract.</td>
  </tr>
</table>
<p>Additionally, you can elect to load a
pre-established template by clicking on &quot;Load from Template&quot; at the
bottom of the page.&nbsp; Selecting the template you wish to use from the
available list will automatically populate the contract you are creating with
the pre-established information.&nbsp; When you have completed the Basic
Information area, click &quot;Save&quot; to continue.&nbsp; Once you have, you
will be able to return to the contract you have begun creating at any time to
complete your work or make revisions.&nbsp;</p>

	
	
	
			
			
			</BLOCKQUOTE>
		</TD>
	</TR>
</TABLE>



	<DIV ALIGN="center">
	<TABLE>
		<TR>
			<TD>
				<CF_button
					button_name		=	""
					button_caption	=	"create contract"
					button_action	=	"contract_create_1_form.cfm"
					button_type		=	"link"
					button_width	=	"160"
					button_color	=	"Navy"
					button_tip		=	"Create a new contract"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold">
			</TD>
			<TD>
				<CF_button
					button_name		=	""
					button_caption	=	"search & view contracts"
					button_action	=	"/common_files/contracts/contract_search.cfm"
					button_type		=	"link"
					button_width	=	"160"
					button_color	=	"Navy"
					button_tip		=	"Click here to search and review contracts"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold">
			</TD>
		</TR>
		<TR>
			<TD>
				<CF_button
					button_name		=	""
					button_caption	=	"product blaster"
					button_action	=	"/common_files/contracts/broadcast_products/select_products.cfm"
					button_type		=	"link"
					button_width	=	"160"
					button_color	=	"Navy"
					button_tip		=	"Create a new contract"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold">
			</TD>
			<TD><CFOUTPUT>
				<CF_button
					button_name		=	""
					button_caption	=	"hq #Application.RebateLabel#s"
					button_action	=	"/common_files/hq_rebates/create_update_component.cfm"
					button_type		=	"link"
					button_width	=	"160"
					button_color	=	"Navy"
					button_tip		=	"Click here to search and review contracts"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold">
				</CFOUTPUT>
			</TD>
		</TR>
	</TABLE>

	</DIV>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
