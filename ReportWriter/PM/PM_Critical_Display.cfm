<CFSET PAGE_TITLE="Critical Projects">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">


</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="PM_Critical_Query.cfm">

<CFIF Display_Critical.Recordcount EQ 0>
<BR><BR><BR><BR>
	<TABLE ALIGN="Center">
		<TR>
			<TD><FONT SIZE="3" COLOR="red"><B><I>There are no critical projects.</I></B></FONT></TD>
		</TR>
	</TABLE>
	<CFABORT>
</CFIF>
<style>
	.tableheader
		{
			border-bottom: solid blue 1px;
			font-weight: bold;
		}
	.tdbody	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
</style>
<BLOCKQUOTE>
<FORM NAME="Sort_Form" ACTION="PM_Critical_Display.cfm?Dummy=1<CFIF isdefined("URL.View_Details")>&View_Details=1</CFIF>" METHOD="Post">
	<CFIF not isdefined("URL.View_Details")>
	<cfparam name="FORM.startrow"  default="1">
  	<CFPARAM NAME="FORM.frompage"   DEFAULT="1">
   	<cfparam name="FORM.pageLength"  default=15>
   	<CFSET startrow=FORM.startrow>
   	<CFSET frompage=FORM.frompage>
   	<cf_Number_of_Rows maxrows="#FORM.pageLength#">
   	<CFOUTPUT>
   	
	
   	<INPUT TYPE="hidden" VALUE = "#FORM.frompage#" NAME="frompage">
	<INPUT TYPE="hidden" VALUE = "#FORM.StartRow#" NAME="startrow">	
	</CFOUTPUT>
	<TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2">
		<TR>			
			<TD CLASS="tableheader" COLSPAN="100%"><SPAN CLASS="Title2"><CFOUTPUT>#Display_Critical.recordcount#</CFOUTPUT> records returned - summary view:</SPAN>&nbsp;&nbsp;
			<CFOUTPUT><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="PM_Critical_Display.cfm?View_Details=1" >detailed view / email / print</A>&nbsp;<FONT COLOR="Red">]</FONT></CFOUTPUT>
			<FONT COLOR="Red">[</FONT>&nbsp;<A HREF="/ReportWriter/PM/PM_Glossary.cfm" onclick="NewWindow(this.href,'name','600','500','Yes', 'No');return false;" TITLE="Glossary">glossary</A>&nbsp;<FONT COLOR="Red">]</FONT>
		</TD>
		</TR>
	</TABLE>
	<BR>		
	<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="92%">
		<TR VALIGN="bottom" BGCOLOR="FFCE84" HEIGHT="25">
			<TD CLASS="tableheader">&nbsp;</TD>
			<TD CLASS="tableheader" NOWRAP WIDTH="25%">Acct/Project</TD>
			<TD CLASS="tableheader">&nbsp;</TD>
			<TD CLASS="tableheader" NOWRAP>Priority</TD>
			<TD CLASS="tableheader" NOWRAP>Status</TD>
			<TD CLASS="tableheader" NOWRAP>Pounds</TD>
			<TD CLASS="tableheader" NOWRAP>Dollars</TD>
			<!------<TD CLASS="tableheader">QBrands</TD>----->
			<TD CLASS="tableheader" NOWRAP>Sponsor</TD>
			<TD CLASS="tableheader" NOWRAP>Owner Position</TD>
			<TD CLASS="tableheader" NOWRAP>Modified On&nbsp;&nbsp;</TD>
			<TD CLASS="tableheader" NOWRAP>Modified By</TD>
		</TR>
		<CFOUTPUT QUERY="Display_Critical" startrow="#StartRow#" maxrows="#MaxRows#"> 
		<TR VALIGN="bottom" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" HEIGHT="25">
			<TD CLASS="tdbody">&nbsp;</TD>
			<TD CLASS="tdbody">#PM_Acct_Project#&nbsp;</TD>
			<cfset useLakebaseForCheck_attachments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForCheck_attachments>
	<cftry>
		<cfset Check_attachments = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_attachments", {
				"project_id" = "eq.#PM_Item_Master_ID#",
				"select" = "doc_id"
			}), "doc_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheck_attachments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheck_attachments>
<CFQUERY NAME="Check_attachments" DATASOURCE="#Application.Datasource#">
				SELECT Doc_ID FROM Contract_Attachments WHERE Project_ID = '#PM_Item_Master_ID#'
			</CFQUERY>
</cfif>
					
			<TD CLASS="tdbody"><CFIF Check_attachments.recordcount GT 0><IMG SRC="/images/doc.gif" ALT="This project has #Check_attachments.recordcount# attached document(s)" height="16" width="13"></CFIF>&nbsp;</TD>
	
			<TD CLASS="tdbody" NOWRAP>#PM_Priority_Description#&nbsp;</TD>
			<TD CLASS="tdbody">#PM_Status_Description#&nbsp;</TD>
			<TD CLASS="tdbody" NOWRAP>#NumberFormat(PM_Value_Pounds)#&nbsp;</TD>
			<TD CLASS="tdbody" NOWRAP>#NumberFormat(PM_Value_Dollars)#&nbsp;</TD>
			<!------<TD CLASS="tableheader">QBrands</TD>----->
			<TD CLASS="tdbody" NOWRAP>#PM_Sponsor_Name_First# #PM_Sponsor_Name_Last#&nbsp;</TD>
			<CFQUERY NAME="Get_Position" datasource="#application.datasource#">
				SELECT		Position_Label	
				
				FROM 		PM_Owner_Position
				INNER JOIN 	User_Positions ON User_Positions.User_Positions_ID = PM_Owner_Position.User_Positions_ID
				
				WHERE		PM_Owner_Position.PM_Item_Master_ID = '#PM_Item_Master_ID#'
			</CFQUERY>
			<TD CLASS="tdbody" TITLE="#ValueList(Get_Position.Position_Label, "#chr(13)#")#">
				<CFIF Get_Position.RecordCount GT 1>
				Several ...
				<CFELSE>
				#Get_Position.Position_Label#
				</CFIF>&nbsp;
			</TD>
			<TD CLASS="tdbody">#DateFormat(PM_Date_Modified,"mm/dd/yyyy")#&nbsp;</TD>
			<TD CLASS="tdbody" NOWRAP>#Name_First# #Name_Last#&nbsp;</TD>
		</TR>
		</CFOUTPUT>
		<TR>
			<TD COLSPAN="100%">
				<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    <CF_Next_Previous_For_Forms
			    formname="Sort_Form"
			    query="Display_Critical"
			    maxpages="40"
			    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
			    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
			    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			    addparams="">
			   </DIV>
			</TD>
		</TR>
	</TABLE>
</FORM>
<CFELSE>
<TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2" BORDER="0">
	<TR>
		<TD ALIGN="Right"><B><FONT SIZE="2" COLOR="Red">[</FONT>&nbsp;<A HREF="PM_Critical_Email_Create.cfm" onclick="NewWindow(this.href,'E_ma','600','400','Yes', 'No');return false;" TITLE="Email below details."><FONT SIZE="2">email</FONT></A>&nbsp;<FONT SIZE="2" COLOR="Red">]</FONT></B></TD>
		<TD ALIGN="Right" WIDTH="8%"><B><FONT SIZE="2" COLOR="Red">[</FONT>&nbsp;<A HREF="PM_Critical_Print.cfm?View_Details=1&Print=1" onclick="NewWindow(this.href,'Pt_this','800','600','Yes', 'No');return false;" TITLE="Email below details."><FONT SIZE="2">print</FONT></A>&nbsp;<FONT SIZE="2" COLOR="Red">]</FONT></B>&nbsp;&nbsp;&nbsp;</TD>
	</TR>
</TABLE>
<TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2">
	<TR>
		<TD CLASS="tableheader" COLSPAN="100%"><SPAN CLASS="Title2"><CFOUTPUT>#Display_Critical.recordcount#</CFOUTPUT> records returned  - detail view:</SPAN>&nbsp;&nbsp;
		<CFOUTPUT><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="PM_Critical_Display.cfm">summary view</A>&nbsp;<FONT COLOR="Red">]</FONT>
		<FONT COLOR="Red">[</FONT>&nbsp;<A HREF="/ReportWriter/PM/PM_Glossary.cfm" onclick="NewWindow(this.href,'name','500','400','Yes', 'No');return false;" TITLE="Glossary">glossary</A>&nbsp;<FONT COLOR="Red">]</FONT>
		</TD></CFOUTPUT>			
	</TR>
</TABLE>

<CFINCLUDE TEMPLATE="PM_Critical_Display_Details.cfm">
<CFOUTPUT>#Details#</CFOUTPUT>

<SCRIPT language="JavaScript">
function sendThis()
{
	var newwind	
	newwind = NewWindow("PM_Critical_Email_Create.cfm", 'E_ma', '600', '400', 'Yes', 'No', true);
	
}
function printThis()
{
	var newwind	
	newwind = NewWindow("PM_Critical_Print.cfm?View_Details=1&Print=1", 'Pt_this', '800', '600', 'Yes', 'No', true);
	
}
</SCRIPT>


<TABLE WIDTH="92%" CELLSPACING="0" CELLPADDING="2" BORDER="0">
	<TR>
		<TD ALIGN="Right"><!--- <B><FONT SIZE="2" COLOR="Red">[</FONT><A HREF="PM_Critical_Email.cfm"><FONT SIZE="2">&nbsp;email&nbsp;</FONT></A><FONT SIZE="2" COLOR="Red">]</FONT></B>&nbsp;&nbsp;&nbsp; --->
			<CFOUTPUT>
				<CF_button
					button_name		=	""
					button_caption	=	"email"
					button_action	=	"sendThis()"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
					>
			</CFOUTPUT>
		</TD>
		
		<TD ALIGN="Left"><!--- <B><FONT SIZE="2" COLOR="Red">[</FONT><A HREF="PM_Critical_Email.cfm"><FONT SIZE="2">&nbsp;email&nbsp;</FONT></A><FONT SIZE="2" COLOR="Red">]</FONT></B>&nbsp;&nbsp;&nbsp; --->
			<CFOUTPUT>
				<CF_button
					button_name		=	""
					button_caption	=	"print"
					button_action	=	"printThis()"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
					>
			</CFOUTPUT>
		</TD>
	</TR>
</TABLE>

</CFIF>


</BLOCKQUOTE>
<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
