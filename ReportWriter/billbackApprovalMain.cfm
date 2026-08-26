
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>

<head>
	<title>Billback Approval Report</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<link href="../Common_Files/main_style.css" media="screen" type="text/css" rel="stylesheet" rev="stylesheet">
    <style type="text/css">.page {}</style>
</head>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<BODY TOPMARGIN="0" LEFTMARGIN="0">
<cfset div1Ht= 220>
<cfset div2Ht = 610-div1Ht>
<cfset div2Top = 380>
<CFSET Reportdivlen = 1010>
<cfoutput>
<DIV ID="divApprovalForm" name="divApprovalForm" Style="left:0px;top:0px;height:#div1Ht#px;width:#Reportdivlen#;z-index:2;background-color:white;layer-background-color:white;border:1px none ##000000" >
	<TABLE Name="UNI" Border="0" Style="width:#Reportdivlen#;">
		<TR class="iFrameHeader">
			<TD Align="center" >
			<font color="000080"><b><font face="Arial Black" size="3">Billback Approval Report</font></b></font>
<!--- 				<img border=0 width=220 height=27 src="/images/reports/billbackApproval.gif" alt="Billback Approval Report">
 --->			</TD>
		</TR>
	</TABLE>
	<IFRAME NAME="ifApprovalForm" SRC="billbackApprovalForm.cfm" WIDTH="100%" HEIGHT="#div1Ht#" scrolling="no"></IFRAME>
	<table width="100%" align="center">
		<tr>
			<td align="center">
					<CF_BUTTON
					BUTTON_NAME		=	""
					BUTTON_CAPTION	=	"show report"
					BUTTON_ACTION	=	"javascript:showReport();"
					BUTTON_TYPE		=	"javascript_link"
					BUTTON_WIDTH	=	"150"
					BUTTON_COLOR	=	"Navy"
					BUTTON_TIP		=	""
					FONT_COLOR		=	"White"
					FONT_SIZE		=	"14"
					FONT_WEIGHT		=	"bold">
			</td>
		</tr>
	</table>

</DIV>

<DIV class="page"  ID="divApprovalTable" Style="top:#div2Top#px;">
	<TABLE Width="#Reportdivlen#" Border="0" background="/images/Header_Footer_New/Background_header2.gif">
		<TR class="iFrameHeader" >
			<TD Height="18" Align="center" width="80%">
				<font face="Times New Roman">
					<SPAN STYLE="color: white; font-size: 17px; font-weight: bold; padding: 5px;">
						Display Billback Results
					</span>
				</font>
 			</TD>
 <!--- 			<TD ALIGN="right" BGCOLOR="DDDDDD" style="cursor:pointer;border:2px solid yellow;" NOWRAP width="20%">
				<FONT COLOR="Black" SIZE="2"><B>Click Here To Normalize Window&nbsp;</B></FONT>
			</TD> --->
		<td align="right" valign="middle" id="button">
				<img 	id = "sizeimg"
				src = "/images/reports/maximize.gif"
				onClick = "WinHandler(this.src)"
				border = "0"
				style = "cursor: pointer;"
				title = "Maximize Window">
			</td> 

<!--- 			<td width="2%"  align="right" valign="middle" id="button">
				<img 	id = "closeimg"
				src = "/images/close.gif"
				onClick = "sizeWin(this.src)"
				border = "0"
				style = "cursor: pointer;"
				alt = "Click to Close Window">
			</td> --->
		</TR>
	</TABLE>

	<IFRAME
		ID="ifdivApprovalTable"
		SRC="billbackApprovalTable.cfm"
		NAME="ifdivApprovalTable"
		WIDTH="#Reportdivlen#"
		HEIGHT="#div2Ht#"
		scrolling="auto"
		style="POSITION:relative; TOP:expression(document.getElementById('divApprovalTable').scrollTop);"
	>
	</IFRAME>
</DIV>

</cfoutput>
</html>

<!-------------------------------------------
	Javascript functions
-------------------------------------------->
<script src="billbackApprovalMain.js"></script>	



