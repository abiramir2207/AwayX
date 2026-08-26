<CFSET PAGE_TITLE=	"Profiles">
<CFSET GROUP=		"Profiles">




<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>



<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5">
	<TR>
		<TD VALIGN="top">
			<IMG SRC="/images/icon_people_large.gif" BORDER="0" ALT="">
		</TD>
		<TD BGCOLOR="Navy"></TD>
		<TD VALIGN="top">
			<DIV CLASS="title2">How to manage people and company profiles:</DIV>
<BR>

<table border="0" cellspacing="0" cellpadding="5">
  <tr>
    <td valign="top">
      <p align="right" style="margin-right: 0; margin-bottom: 4"><FONT color="#008000"><B>User
      information:</B></FONT></td>
    <td valign="top">
      <p align="left" style="margin-bottom: 4">Create
      new users by entering their name, address, email address, access rights,
      and preliminary password and user name.&nbsp; Current users can edit or
      update their information from these menus.</td>
  </tr>
  <tr>
    <td valign="top">
      <p align="right" style="margin-right: 0; margin-bottom: 4"><FONT color="#008000"><B>Company
      information:</B></FONT></td>
    <td valign="top">Edit
      and update current company information to ensure the <CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT> product and
      services and in alignment with your needs.&nbsp;</td>
  </tr>
</table>

		</TD>
	</TR>
</TABLE>	

<BR><BR>

<TABLE ALIGN="center">
<TR>
	<TD>
		<CF_button
		button_caption	=	"user maintenance"
		button_action	=	"users/index.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Add A New User/Edit Existing User Information"
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
	<TD>
		<CF_button
		button_caption	=	"company maintenance"
		button_action	=	"companies/index.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Maintain Company Information"
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
</TR>
<TR>
	<TD>
		<CF_button
		button_caption	=	"broker profiles"
		button_action	=	"/profiles/brokers/index.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"View Broker profiles..."
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
	<TD>
		<CF_button
		button_caption	=	"#application.returned_customer_setting.distributor_label_singular# profiles"
		button_action	=	"/profiles/distributors/index.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"View #lcase(application.returned_customer_setting.distributor_label_singular)# profiles..."
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
</TR>
<TR>
	<TD>
		<CF_button
		button_caption	=	"#application.returned_customer_setting.operator_label_singular# profiles"
		button_action	=	"/profiles/operators/index.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"View #application.returned_customer_setting.operator_label_singular# profiles..."
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
	<TD>
		<CF_button
		button_caption	=	"product profiles"
		button_action	=	"/profiles/products/index.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"View Product profiles..."
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
</TR>
<TR>
	<TD>
		<CF_button
		button_caption	=	"freight calculator"
		button_action	=	"/profiles/freight_charges/index.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Claculate freight charges..."
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
	<TD>
	</TD>
</TR>
<TR>
	<TD>
		<HR>
		<CF_button
		button_caption	=	"create broker"
		button_action	=	"/profiles/brokers/Broker_Creation_Entry_Form.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Add A New Broker"
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
	<TD>
		<HR>
		<CF_button
		button_caption	=	"create #application.returned_customer_setting.operator_label_singular#"
		button_action	=	"/profiles/operators/operator_Creation_Entry_Form.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Add A New #application.returned_customer_setting.operator_label_singular#"
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
</TR>
<TR>
	<TD>
		<CF_button
		button_caption	=	"create #application.returned_customer_setting.distributor_label_singular#"
		button_action	=	"/profiles/distributors/distributor_Creation_Entry_Form.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Add A New #application.returned_customer_setting.distributor_label_singular#"
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
	<TD>
		<CF_button
		button_caption	=	"create products"
		button_action	=	"/profiles/products/product_Creation_Entry_Form.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Add A New Product"
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold">
	</TD>
</TR>
</TABLE>





<DIV ALIGN="center">


<BR>
<BR>
</DIV>	


</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
