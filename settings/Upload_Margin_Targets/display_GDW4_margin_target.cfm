

<cfset qGetGDW4Info = uploadmargintargetManager.GetGDW4Info()>
<cfset qgetCurrentActiveProcess = uploadmargintargetManager.getCurrentActiveProcess(1)>

<CFPARAM NAME="URL.StartRow" DEFAULT="1">
<CFPARAM NAME="URL.frompage" DEFAULT="1">

<CFPARAM NAME="FORM.StartRow" DEFAULT="#URL.StartRow#">
<CFPARAM NAME="FORM.frompage" DEFAULT="#URL.frompage#">

<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>
<cf_Number_of_Rows maxrows=20>
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

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="800">
<cfif qgetCurrentActiveProcess.recordcount GT 0>
	<TR>
	<CFOUTPUT>	<TD><B><FONT SIZE="2" COLOR="Navy">This file was uploaded by #qgetCurrentActiveProcess.Name_First#&nbsp;#qgetCurrentActiveProcess.Name_Last# on #Dateformat(qgetCurrentActiveProcess.created_date,"mmmm dd,yyyy")#</CFOUTPUT> </FONT></B></TD>
</cfif>
<SCRIPT language="JavaScript">			
	function ViewFile(file)
	{
		var file_name;
		file_name = file;
		NewWindow('<CFOUTPUT>#application.HTTPVar##CGI.server_name#</CFOUTPUT>/GetDocument.cfm?FilePath=Data_Files/uploaded/Settings/Upload_Margin_Targets/' + file_name, 'namewwwwww', '800', '600', 'Yes', 'Yes');	
	}	
</SCRIPT>

	<cfoutput><TD align="right" colspan="100%">
<font size="2"><A href="javascript: ViewFile('#qgetCurrentActiveProcess.Generic_Files_Uni_Name#');"><b>View Uploaded file</b></A></font>
</TD></cfoutput>
	</TR>
</TABLE>

<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" width="100%" CLASS="UnderLine" align="center">
	<TR bgcolor="CC3300">
		<TD><B>Description</B></TD>
		<TD><B>Target Margin</B></TD>
		<TD><B>Proxy Delivered Cost</B></TD>
	</TR>
	<CFOUTPUT QUERY="qGetGDW4Info"  startrow="#StartRow#" maxrows="#MaxRows#">
	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<TD STYLE="font-size:10px">#Type_Code_Desc#&nbsp;</TD>
		<TD STYLE="font-size:10px">#trim(numberformat(Target_Margin,'_-___,___,___,___,___.__'))#&nbsp;</TD>
		<TD STYLE="font-size:10px">#trim(numberformat(Proxy_Del_Cost,'_-___,___,___,___,___.__'))#&nbsp;</TD>
	</TR>
	</CFOUTPUT>
</TABLE>

<TABLE>
<TR>
<TD>
<CFIF qGetGDW4Info.recordcount GT 0>
<CF_Next_Previous_For_Forms
	formname="MyForm"
	query="qGetGDW4Info"
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
<td>
<CFOUTPUT>	<TD><B><FONT SIZE="2" COLOR="Navy">There<CFIF qGetGDW4Info.recordcount EQ 0> Are No #application.returned_customer_setting.type_code_label_singular#'s <CFELSEIF qGetGDW4Info.recordcount EQ 1> Is A <CFELSE> Are #qGetGDW4Info.recordcount# #application.returned_customer_setting.type_code_label_singular#'s.</CFIF></CFOUTPUT> </FONT></B>
</td>
</TR>
</TABLE>
<FORM ACTION="#CGI.SCRIPT_NAME#" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<INPUT TYPE="Hidden" NAME="title" VALUE="#title#">
<INPUT TYPE="Hidden" NAME="currentProgramList" VALUE="#form.currentProgramList#">
</FORM>
<SCRIPT LANGUAGE="javaScript">
	function getthisPage(thisObj)
	{
		thisObj.submit();
		return false;
	}</SCRIPT>
</BODY>
</HTML>