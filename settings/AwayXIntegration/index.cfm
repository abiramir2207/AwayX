<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>URL.pageTitle</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<STYLE>
.input_di_textbox_input
{
	border: 1px solid rgb(192,192,192);
	font: 12px Arial, Arial;
	font-weight: bold;
	color: Navy;
	background-color: rgb(255, 255, 255);
	text-align: left;
	width:200px;
}
</STYLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFIF NOT isDefined("ADI_IncludeFile")>
	<CFINCLUDE template="adiInclude.cfm">
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!-------------------------------- Set Defaults ------------------------------>
<!-----<CFPARAM NAME="adiFTPServerName" DEFAULT="">
<CFPARAM NAME="adiFTPPath" DEFAULT="">------->
<CFPARAM NAME="adiDestServer" DEFAULT="">
<CFPARAM NAME="adiDestPath" DEFAULT="">
<CFPARAM NAME="adiTime" DEFAULT="">
<CFPARAM NAME="adiFileName" DEFAULT="">
<!-------------------------------- End Set Defaults ------------------------------>


<!-------------------------------- Get Info From Table ------------------------------>

	<CFQUERY NAME="q_Commodity_BasicInfo" datasource="#application.datasource#">
	SELECT *
    FROM Commodity_BasicInfo 
    WHERE Commodity_BasicInfo_ID=
	(	SELECT Max(Commodity_BasicInfo_ID)
		FROM Commodity_BasicInfo
	)
	</CFQUERY>
	<CFIF q_Commodity_BasicInfo.recordCount GT 0>		
		<CFSET adiBasicInfoID=q_Commodity_BasicInfo.Commodity_BasicInfo_ID>
		<!-----<CFSET adiFTPServerName=q_Commodity_BasicInfo.Commodity_FTPServer>
		<CFSET adiFTPPath=q_Commodity_BasicInfo.Commodity_FTPPath>------->
		<CFSET adiDestServer=q_Commodity_BasicInfo.Commodity_Local_Server>
		<CFSET adiDestPath=q_Commodity_BasicInfo.Commodity_Directory>
		<CFSET adiTempTime=q_Commodity_BasicInfo.Commodity_Time>
		<CFSET adiTime=TimeFormat(CreateDateTime(Year(Now()),Month(Now()),Day(Now()),Left(adiTempTime,2),Mid(adiTempTime,4,2),Mid(adiTempTime,7,2)),"hh:mm:ss tt")>
		<CFSET adiFileName=q_Commodity_BasicInfo.Commodity_FileName>
	</CFIF>
	<!-----
	<CFQUERY NAME="q_Comm_Update_Date" datasource="#application.datasource#">
	SELECT     MAX(Comm_Update_Date) as LastUpdateDate
	FROM         Commodities
	</CFQUERY>
	------->
	<CFQUERY NAME="q_Comm_Update_Date" datasource="#application.datasource#">
	SELECT     CAST(DATEPART(month,MAX(Comm_Update_Date)) AS varchar) + '/' + CAST(DATEPART(day,MAX(Comm_Update_Date)) AS varchar) + '/' + CAST(DATEPART(year,MAX(Comm_Update_Date)) AS varchar)  as LastUpdateDate, CAST(DATEPART(hour,MAX(Comm_Update_Date)) AS varchar) + ':' + CAST(DATEPART(minute,MAX(Comm_Update_Date)) AS varchar) + ':' + CAST(DATEPART(second,MAX(Comm_Update_Date)) AS varchar)  as LastUpdateTime
	FROM         Commodities
	</CFQUERY>
	
	<CFIF q_Comm_Update_Date.recordCount GT 0>
		<CFSET adiComm_Update_Date=q_Comm_Update_Date.LastUpdateDate>
		<CFSET adiComm_Update_Time="">
		<CFSET TempTime=q_Comm_Update_Date.LastUpdateTime>
		<cfif ListLen(TempTime,":") GT 0>
			<CFSET adiComm_Update_Time=TimeFormat(CreateDateTime(ListGetat(adiComm_Update_Date,3,"/"),ListGetat(adiComm_Update_Date,1,"/"),ListGetat(adiComm_Update_Date,2,"/"),ListGetat(TempTime,1,":"),ListGetat(TempTime,2,":"),ListGetat(TempTime,3,":")),"hh:mm:ss tt")>
		</cfif>
	</CFIF>
<!-------------------------------- End Get Info From Table ------------------------------>

<!------------------------------- Show Tabs -------------------------------------------------->
<CFSET adiThisPage=mainPage>
<CFINCLUDE template="adiHeader.cfm">
<!------------------------------- End Show Tabs -------------------------------------------------->

<CFOUTPUT>
<BR><BR>
<SPAN CLASS="TITLE2"><b>Basic Information</b></SPAN>
<BR><BR>
<TABLE CELLSPACING="2" CELLPADDING="0" BORDER="0" WIDTH="80%">
	<TR>
		<TD CLASS="labelStyle"></TD>
		<TD ROWSPAN="100%" BGCOLOR="Navy" WIDTH="1"><IMG SRC="/images/fill.gif" ALT="" WIDTH="1" BORDER="0"></TD>
		<TD CLASS="labelStyle"></TD>
	</TR>
		
	<!-----<TR>
		<TD CLASS="labelStyle"><b>FTP Server</b></TD>
		<TD><INPUT TYPE="TEXT" ID="adiFTPServerName" NAME="adiFTPServerName" CLASS="input_di_textbox_input" VALUE="#adiFTPServerName#" READONLY></TD>
	</TR>
	<TR>
		<TD CLASS="labelStyle"><b>FTP Path</b></TD>
		<TD><INPUT TYPE="TEXT" ID="adiFTPPath" NAME="adiFTPPath" CLASS="input_di_textbox_input" VALUE="#adiFTPPath#" READONLY></TD>
	</TR>------->
	<TR>
		<TD CLASS="labelStyle"><b>Destination Server</b></TD>
		<TD><INPUT TYPE="TEXT" ID="adiDestServer" NAME="adiDestServer" CLASS="input_di_textbox_input" VALUE="#adiDestServer#" READONLY></TD>
	</TR>
	<TR>
		<TD CLASS="labelStyle"><b>Destination Path</b></TD>
		<TD><INPUT TYPE="TEXT" ID="adiDestPath" NAME="adiDestPath" CLASS="input_di_textbox_input" VALUE="#adiDestPath#" READONLY></TD>
	</TR>
	<TR>
		<TD CLASS="labelStyle"><b>File Name</b></TD>
		<TD><INPUT TYPE="TEXT" ID="adiFileName" NAME="adiFileName" CLASS="input_di_textbox_input" VALUE="#adiFileName#" READONLY></TD>
	</TR>
	<!-----<TR>
		<TD CLASS="labelStyle">&nbsp;</TD>
		<TD>
		<A HREF="<cfif Left(adiDestPath,2) NEQ "\\">\\#adiDestServer#\#Replace(adiDestPath,":","$")#<cfelse>#adiDestPath#</cfif>" TARGET="_BLANK">Click here to go to the commodity folder</A>
		</TD>
	</TR>------->
	<!-----<TR>
		<TD CLASS="labelStyle"><b>Commodity Process Time</b></TD>
		<TD><INPUT TYPE="TEXT" ID="adiTime" NAME="adiTime" CLASS="input_di_textbox_input" VALUE="#adiTime#" READONLY></TD>
	</TR>------->
	<CFIF IsDefined("adiComm_Update_Date")>
	<TR>
		<TD CLASS="labelStyle"><b>Last Update Date</b></TD>
		<TD><INPUT TYPE="TEXT" ID="adiComm_Update_Date" NAME="adiComm_Update_Date" CLASS="input_di_textbox_input" VALUE="#adiComm_Update_Date# #adiComm_Update_Time#" READONLY></TD>
	</TR>
	</CFIF>	
</TABLE>
</CFOUTPUT>
<FORM ACTION="execCommodity.cfm" METHOD="POST" ID="execForm" NAME="execForm">
</FORM>
	<DIV ALIGN="center">
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"Start Commodity process"
			BUTTON_ACTION	=	"javascript:if(window.confirm(\'This will start the Commodity Process.\nDo u want to continue?\'))document.all.execForm.submit();"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
		</DIV>
<!-----		BUTTON_ACTION	=	"javascript:if(window.confirm('This will start the Commodity Process.\nDo u want to continue?'))document.all.execForm.submit();"------->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_MessageWindow>
</BODY>
</HTML>
