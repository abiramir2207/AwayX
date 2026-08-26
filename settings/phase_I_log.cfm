<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFPARAM NAME="URL.pageTitle" DEFAULT="Personal Settings: Phase Queue">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "SYSTEM ADMINISTRATION: PURGE QUEUE">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=38>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->


<cfparam name="gg" default="">
<CFQUERY NAME="Get_maxSettings" datasource="#application.datasource#">
		Select		max(Purge_Log_Settings_id) as gg
		From		Purge_Log_Settings
		</CFQUERY>
<cfset cont = Get_maxSettings.gg>
<CFQUERY NAME="Get_PreviousSettings" datasource="#application.datasource#">
		Select		* 
		From		Purge_Log_Settings
		where Purge_Log_Settings_id = '#cont#'
		</CFQUERY>
<cfset day_cont = Get_PreviousSettings.Phase_2_Period>

<cfset useLakebaseForget_phaseI_log = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("purge_log")>
<cfif useLakebaseForget_phaseI_log>
	<cftry>
		<cfset get_phaseI_log = application.oLakebase.toQuery(
			application.oLakebase.selectRows("purge_log", {
				"select" = "contract_main_id,contract_number,contract_title,contract_start_date,contract_end_date,system_date"
			}), "contract_main_id,contract_number,contract_title,contract_start_date,contract_end_date,system_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_phaseI_log = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_phaseI_log>
<cfquery name="get_phaseI_log" datasource="#application.datasource#">	
SELECT Contract_Main_ID,CONTRACT_NUMBER,CONTRACT_TITLE,CONTRACT_START_DATE,CONTRACT_END_DATE,SYSTEM_DATE 
 FROM PURGE_LOG
</cfquery>
</cfif>	


<BR><BR>	
<FORM ACTION="Phase_I_log_Action.cfm" METHOD="post" NAME="theForm" ID="theForm">
<CFIF get_phaseI_log.recordCount GT 0>

<TABLE  CELLPADDING="3" CELLSPACING="0" CLASS="maintable" WIDTH="650">
	<TR VALIGN="bottom" BGCOLOR="#FFCE84">
		<TD id="header" width="10">&nbsp;</TD>
		<TD id="header"><b>NUMBER</b></TD>
		<TD id="header"><b>TITLE</b></TD>
		<TD id="header"><b>START DATE</b></TD>
		<TD id="header"><b>END DATE</b></TD>
		<TD id="header"><b>LOG DATE</b></TD>
		<TD id="header"><b>DAY(s) TO PURGE </b></TD>
		<TD id="header"><b>ROLLBACK</b></TD>
	</TR>

<cfoutput>
	<cfloop query="get_phaseI_log">
		<TR deleteassignment="0" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
				<TD id="FlagCell" align="center" valign="middle">&nbsp;</TD>
				<TD>#get_phaseI_log.CONTRACT_NUMBER#</TD>
				<TD>#get_phaseI_log.CONTRACT_TITLE#</TD>
				<TD>#dateformat(get_phaseI_log.CONTRACT_START_DATE, 'm/d/yyy')#</TD>
				<TD>#dateformat(get_phaseI_log.CONTRACT_END_DATE, 'm/d/yyy')#</TD>
				<TD>#dateformat(get_phaseI_log.SYSTEM_DATE, 'm/d/yyy')#</TD>
				<TD>#dateDiff("d", get_phaseI_log.SYSTEM_DATE, dateAdd("m", day_cont, get_phaseI_log.SYSTEM_DATE))#</TD>
				<TD><input NAME="contractrollback" value="#get_phaseI_log.Contract_Main_ID#" type="checkbox" ></TD>				
		</TR>	
	</cfloop>
</cfoutput>
</table>
<CENTER>
	<BR><DIV ALIGN="center">
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"Save List"
			BUTTON_ACTION	=	"javascript:document.theForm.submit();"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
		</DIV>
</CENTER>

<!----<input type="submit" VALUE="save list" >--->
<CFELSE>
	<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		No Phase Queue entry found
		</B></FONT></CFOUTPUT>
		</TD>
		</TD>
		</TR>
	</TABLE>
</CFIF>
		<BR><BR>	


</form>
<!----
<a href="show_textfile.cfm">Show TExt File</a>
---->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>