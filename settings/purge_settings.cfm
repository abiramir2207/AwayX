<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=32>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR><BR>

<FORM ACTION="#" METHOD="post" NAME="MyForm" ID="MyForm">

<SPAN CLASS="title2">Phase I</SPAN>
<HR COLOR="Orange">

Expired contracts are eligible for the purging process only if both of the following criteria are satisfied: [A] there are no unpaid billbacks in the
database associated with the program, and, [B] all associated deductions in the database have been cleared.<BR>
The first phase of the process moves eligible programs and all associated billbacks and deductions to an &quot;inactive&quot; state. Inactive programs and
all associated data remain in the production database but are not available for viewing or reporting.<BR><BR>


<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>Alert me that there are records that meet both criteria [A] and [B]</TD>
	<TD>&nbsp;&nbsp;<INPUT type="checkbox" name="C1" value="ON"></TD>
</TR>
</TABLE>


<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>Set to inactive all records that meet both criteria [A] and [B] and have been expired for more than</TD>
	<TD>
		&nbsp;&nbsp;&nbsp;
		<SELECT size="1" name="D1">
			<OPTION>6 Months</OPTION>
			<OPTION>9 Months</OPTION>
			<OPTION>12 Months</OPTION>
		</SELECT>	
	</TD>
</TR>
</TABLE>

<BR>

<SPAN CLASS="title2">Phase II</SPAN>
<HR COLOR="Orange">
The second phase is -- purging -- actually removes the program and all associated billbacks and deductions from the database. An alert will be sent to
the System Administrator 4 weeks in advance to provide an opportunity to capture the data scheduled for purging on a CD, tape, or other alternative
storage method. Once the data has been purged, it can not be rolled back into the production database.The inactive state is an interim step prior to the
actual purge which provide a painless avenue to &quot;roll back&quot; the records should business needs dictate continued access to the data.<BR><BR>

<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>Alert me that there are records that meet the Phase II criteria</TD>
	<TD><INPUT type="checkbox" name="C1" value="ON"></TD>
</TR>
</TABLE>

<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>Purge from the system all records that have been inactive for more than</TD>
	<TD>
		&nbsp;&nbsp;&nbsp;
		<SELECT size="1" name="D1">
			<OPTION>6 Months</OPTION>
			<OPTION>9 Months</OPTION>
			<OPTION>12 Months</OPTION>
		</SELECT>	
	</TD>
</TR>
</TABLE>

<BR>

<B>
<FONT COLOR="Red">[</FONT>
<A HREF="#">review purge report</A>
<FONT COLOR="Red">]</FONT>
</B>

<BR><BR>

<FONT COLOR="Red">
	Please note that at no time will records be removed or their status changed without the knowledge of the system administrator.<BR>
	Any change of status or data purge process, will require the specific action of the system administrator.
</FONT>
</FORM>


<TABLE BORDER="0" WIDTH="650" CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD WIDTH="33%" ALIGN="center">
		<CF_button
			button_name		=	"MyButton"
			button_caption	=	"save settings"
			button_action	=	"javascript:document.all.MyForm.submit();"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">
	</TD>
	<TD WIDTH="33%" ALIGN="center">
		<CF_button
			button_name		=	"MyButton"
			button_caption	=	"run phase 1"
			button_action	=	"javascript:document.all.MyForm.submit();"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">
	</TD>
	<TD WIDTH="33%" ALIGN="center">
		<CF_button
			button_name		=	"MyButton"
			button_caption	=	"run phase 2"
			button_action	=	"javascript:document.all.MyForm.submit();"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">
	</TD>
</TR>
</TABLE>





<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



