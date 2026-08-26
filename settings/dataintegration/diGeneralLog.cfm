<CFIF NOT isDefined("DI_IncludeFile")>
	<CFINCLUDE template="diLog_Include.cfm">
</CFIF>
<CFPARAM NAME="anyRecord" DEFAULT="anyRecord">
<CFPARAM NAME="k" DEFAULT=1>

<!-----------Show dataIntegration_log statistics---------------------------------------->
		<CFQUERY NAME="q_diLogData" datasource="#application.datasource#">
			SELECT count(Data_Integration_Log_ID) as logEntryCount
		    FROM Data_Integration_Log
			Where Data_Integration_MsgType='user'
		</CFQUERY>
		<cfoutput>
		<CFIF q_diLogData.recordCount GT 0>
				<cfif q_diLogData.logEntryCount GT 0>
					<cfif NOT anyRecord>
						<TR BGCOLOR="FFCE84">
						<TD><b>##</b></TD>
						<TD><b>Log Item</b></TD>
						<TD><b>Start Date</b></TD>
						<TD><b>Count</b></TD>
						</TR>
					</cfif>
					<a href="#diGeneralLogDetailsPage#">
					<TR<cfif (k mod 2) NEQ 1> BGCOLOR="ccffcc"</cfif> style="cursor:pointer">
						<TD>#k#.</TD>
						<TD><font class="captions_blue">Data Integration General Log</font></TD>
						<TD>
						<CFQUERY NAME="q_diThisLogDate" DBTYPE="query">
						SELECT 	Created_Date
						FROM	q_diLogDate
						WHERE	category='GeneralLog'
						</CFQUERY>
						<CFIF q_diThisLogDate.recordCount GT 0>
						#DateFormat(q_diThisLogDate.Created_Date,"mm/dd/yyyy")# #TimeFormat(q_diThisLogDate.Created_Date,"hh:mm:ss tt")#
						</CFIF>
						</TD>
						<TD>&nbsp;&nbsp;&nbsp; #q_diLogData.logEntryCount#</TD>				
					</TR>
					</a>
					<cfset anyRecord=true>
					<cfset k=k+1>
				</cfif>
		</CFIF>
		</cfoutput>
		<!-----------Show dataIntegration_log statistics---------------------------------------->