

<cfset qGetItemInfo = uploadmargintargetManager.GetItemInfo(form.item_number)>
<cfset qgetCurrentActiveProcess = uploadmargintargetManager.getCurrentActiveProcess(2)>


<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>
<cf_Number_of_Rows maxrows=12>

<HTML>
<HEAD>
<STYLE>
TABLE.UnderLine TD
{
	border-bottom: 1px #93BEE2 solid; 
}
</STYLE>
</HEAD>
<BODY>
<br>
<br>

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
	<cfif qgetCurrentActiveProcess.recordcount GT 0>
	<TR>
	<CFOUTPUT>	<TD><B><FONT SIZE="2" COLOR="Navy">This file was uploaded by #qgetCurrentActiveProcess.Name_First#&nbsp;#qgetCurrentActiveProcess.Name_Last# on #Dateformat(qgetCurrentActiveProcess.created_date,"mmmm dd,yyyy")#</CFOUTPUT> </FONT></B></TD>
	</TR>
</cfif>
	<TR>
		<TD>&nbsp;</TD>
	</TR>
</TABLE>

<FORM ACTION="index.cfm?Show_Tab=3" METHOD="post" NAME="ItemMarginTargets" ID="ItemMarginTargets">
 <TABLE>
<TR>
<TD colspan="100%">
	<strong>&nbsp;</strong>
</TD>
</TR>
<TR>
<TD>
<font size="2"><b>Item Number:</b></font>
</TD>
<TD>
<input name="item_number" type="text" size="20"/>
</TD>
<TD><CF_button
	button_name		=	""
	button_caption	=	"search"
	button_action	=	"ItemMarginTargets.submit();"
	button_type		=	"javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>	</TD>

<SCRIPT language="JavaScript">			
	function ViewFile(file)
	{
		var file_name;
		file_name = file;
		NewWindow('<CFOUTPUT>#application.HTTPVar##CGI.server_name#</CFOUTPUT>/GetDocument.cfm?FilePath=data_files/uploaded/Settings/Upload_Margin_Targets/' + file_name, 'namewwwwww', '800', '600', 'Yes', 'Yes');	
	}	
</SCRIPT>

<cfoutput><TD align="right" colspan="100%">
<font size="2"><A href="javascript: ViewFile('#qgetCurrentActiveProcess.Generic_Files_Uni_Name#');"><b>View Uploaded file</b></A></font> 
</TD></cfoutput>
</TR>
<tr>
<td>&nbsp;</td>
</tr>
</TABLE> 
</form>

<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" width="100%" CLASS="UnderLine" align="center">
	<TR bgcolor="CC3300">
		<TD><B>Item Number</B></TD>
		<TD><B>Description</B></TD>
		<TD><B>FOB Base Price</B></TD>
		<TD><B>FOB Cash Discount</B></TD>
		<TD><B>DEL Base Price</B></TD>
		<TD><B>DEL Cash Discount</B></TD>
		<TD><B>Default Type</B></TD>
		<TD><B>FOB Margin Target</B></TD>
		<TD><B>DEL Margin Target</B></TD>
	</TR>
	<cfif qGetItemInfo.recordcount GT 0>
	<CFOUTPUT QUERY="qGetItemInfo" startrow="#StartRow#" maxrows="#MaxRows#">
	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<TD STYLE="font-size:10px">#ITEM_NUMBER#&nbsp;</TD>
		<TD STYLE="font-size:10px">#DESCRIPTION#&nbsp;</TD>
		<TD STYLE="font-size:10px">#trim(numberformat(ITEM_FOB_BASE_PRICE,'_-___,___,___,___,___.____'))#&nbsp;</TD>
		<TD STYLE="font-size:10px">
<cfif IsNumeric(ITEM_FOB_CASH_DISCOUNT)> #trim(numberformat(ITEM_FOB_CASH_DISCOUNT,'_-___,___,___,___,___.____'))#
<cfelse>
#ITEM_FOB_CASH_DISCOUNT#
</cfif>&nbsp;</TD>
		<TD STYLE="font-size:10px">
		<cfif IsNumeric(ITEM_DEL_BASE_PRICE)>
#trim(numberformat(ITEM_DEL_BASE_PRICE,'_-___,___,___,___,___.____'))#
		<cfelse>
			#ITEM_DEL_BASE_PRICE#
		</cfif>
&nbsp;</TD>
		<TD STYLE="font-size:10px">
<cfif IsNumeric(ITEM_DEL_CASH_DISCOUNT)>
#trim(numberformat(ITEM_DEL_CASH_DISCOUNT,'_-___,___,___,___,___.____'))#
	<cfelse>
	#ITEM_DEL_CASH_DISCOUNT#
	</cfif>&nbsp;</TD>
		<TD STYLE="font-size:10px">#ITEM_DEFAULT_TYPE#&nbsp;</TD>
		<TD STYLE="font-size:10px">
<cfif IsNumeric(FOB_ITEM_OI_TARGET)>
#trim(numberformat(FOB_ITEM_OI_TARGET,'_-___,___,___,___,___.__'))#
<cfelse>#FOB_ITEM_OI_TARGET#
</cfif>&nbsp;</TD>
		<TD STYLE="font-size:10px">
<cfif IsNumeric(DEL_ITEM_OI_TARGET)>#trim(numberformat(DEL_ITEM_OI_TARGET,'_-___,___,___,___,___.__'))#
<cfelse>#DEL_ITEM_OI_TARGET#
</cfif>&nbsp;</TD>
	</TR>
	</CFOUTPUT></cfif>
</TABLE>
<TABLE>
<TR>
<TD>
<CFIF qGetItemInfo.recordcount GT 0>
<CF_Next_Previous_For_Forms
	formname="MyForm"
	query="qGetItemInfo"
	maxpages="30"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
	lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"		
	addparams="">
	</CFIF>
</TD>
<TD>
<TD><B><FONT SIZE="2" COLOR="Navy">There<CFIF qGetItemInfo.recordcount EQ 0> Are No Items <CFELSEIF qGetItemInfo.recordcount EQ 1> Is A Item.<CFELSE> Are <CFOUTPUT>#qGetItemInfo.recordcount#</CFOUTPUT> items.</CFIF> </FONT></B></TD>
</TD>
</TR>
</TABLE>
<cfoutput><FORM ACTION="#CGI.SCRIPT_NAME#?Show_Tab=3" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<!--- <INPUT TYPE="Hidden" NAME="title" VALUE="#title#"> --->
<!--- <INPUT TYPE="Hidden" NAME="currentProgramList" VALUE="#form.currentProgramList#"> --->
</FORM></cfoutput>
<SCRIPT LANGUAGE="javaScript">
	function getthisPage(thisObj)
	{
		thisObj.submit();
		return false;
	}</SCRIPT>
</BODY>
</HTML>
