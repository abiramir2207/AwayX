<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	


</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFIF NOT isDefined("DI_IncludeFile")>
	<CFINCLUDE template="diLog_Include.cfm">
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

<SCRIPT LANGUAGE="Javascript">
</SCRIPT>

<CFSET diThisPage="#diLogPage#">
<CFINCLUDE template="diHeader.cfm">

<B>
	<CFOUTPUT>
		<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">
				<A HREF="#diLogTextFile#">
					create text file
				</A>
		</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
	</CFOUTPUT>

<CFOUTPUT>
<BR>
<CFIF isDefined("sActionErr")>
			<CFSET sPageErr=true>
			 <TABLE BGCOLOR="Red" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
			<TR BGCOLOR="White">
			<TD>		
			<FONT SIZE="2"><B>
			Update failed. Some of the fields are either missing or invalid.
			</B></FONT>
			</TD>
			</TD>
			</TR>
			</TABLE>
<CFELSEIF isDefined("URL.sActionMsg")>
			 <TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
			<TR BGCOLOR="White">
			<TD>		
			<FONT SIZE="2"><B>
			#URL.sActionMsg#
			</B></FONT>
			</TD>
			</TD>
			</TR>
			</TABLE>
</CFIF>
</CFOUTPUT>
<cfform action="#diLogActionPage#" method="POST" name="dataIntegrationLogForm">
<TABLE ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="95%">
<TR>
<TD><span id="error_logDetails"></span></TD>
</TR>
<TR>
<TD>
	<TABLE CELLSPACING="0" CELLPADDING="4" BORDER="0" ALIGN="CENTER" WIDTH="80%">
<cfoutput>
<cfset anyRecord=false>
<cfset j=1>
<cfset k=1>
<CFQUERY NAME="q_diLogDate" datasource="#application.datasource#">
Select Created_Date,'GeneralLog' as category From Data_Integration_Log
Where Data_Integration_Log_ID=
	(
	Select max(Data_Integration_Log_ID) 
	From Data_Integration_Log 
	)
Union

Select Created_Date,LOWER(Data_Integration_Name) as category From Data_Integration_Log
Where Data_Integration_Log_ID=
	(
	Select max(Data_Integration_Log_ID) 
	From Data_Integration_Log 
	Where Data_Integration_Name='Brokers'
	)
Union
 
Select Created_Date,LOWER(Data_Integration_Name) as category From Data_Integration_Log
Where Data_Integration_Log_ID=
	(
	Select max(Data_Integration_Log_ID) 
	From Data_Integration_Log 
	Where Data_Integration_Name='Distributors'
	) 
Union

Select Created_Date,LOWER(Data_Integration_Name) as category From Data_Integration_Log
Where Data_Integration_Log_ID=
	(
	Select max(Data_Integration_Log_ID) 
	From Data_Integration_Log 
	Where Data_Integration_Name='Products'
	) 	
</CFQUERY>

<cfinclude template="#diGeneralLogPage#">
<CFIF (ListLen(logTables,",") EQ ListLen(logItems,",")) AND (ListLen(logTables,",") EQ ListLen(originalDB,","))>	
	<cfloop index="i" list="#logTables#" delimiters=",">		
		<cfset thisRecID=0>
		<cfset idName="Log_#ListGetAt(logItems,j,",")#_id">
		<CFSET logItemName=ListGetAt(logItems,j,",")>
		<CF_DI_CUST_SETTING_NAME 
			DI_keyword="#logItemName#" 
			ReturnField="Cust_Setting_Item_Name">
		<cfset thisListFields=Evaluate("Log#logItemName#ListFields")>
		<!-------------
		<CFQUERY NAME="q_diLogData" datasource="#application.datasource#">
			SELECT *
		    FROM #i#
		</CFQUERY>
		---------->
		
		<!-----------Show logTable statistics---------------------------------------->
		<CFQUERY NAME="q_diLogData" datasource="#application.datasource#">
			SELECT count(#idName#) as logEntryCount
		    FROM #i#
		</CFQUERY>
		<CFIF q_diLogData.recordCount GT 0>
				<!-----<cfif q_diLogData.logEntryCount GT 0>------->
					<cfif NOT anyRecord>
						<TR BGCOLOR="FFCE84">
						<TD><b>##</b></TD>
						<TD><b>Log Item</b></TD>
						<TD><b>Start Date</b></TD>
						<TD><b>Count</b></TD>
						</TR>
					</cfif>
					<cfif q_diLogData.logEntryCount GT 0><a href="#diLogListPage#?logitem=#logItemName#"></cfif>
					<TR<cfif (k mod 2) NEQ 1> BGCOLOR="ccffcc"</cfif><cfif q_diLogData.logEntryCount GT 0> style="cursor:pointer"</cfif>>
						<TD>#k#.</TD>
						<TD><font class="captions_blue">#Cust_Setting_Item_Name#</font></TD>
						<TD>
						<CFQUERY NAME="q_diThisLogDate" DBTYPE="query">
						SELECT 	Created_Date
						FROM	q_diLogDate
						WHERE category='#LCase(ListGetAt(logCategory,j,","))#'
						</CFQUERY>
						<CFIF q_diThisLogDate.recordCount GT 0>
						#DateFormat(q_diThisLogDate.Created_Date,"mm/dd/yyyy")# #TimeFormat(q_diThisLogDate.Created_Date,"hh:mm:ss tt")#
						</CFIF>
						</TD>
						<TD>&nbsp;&nbsp;&nbsp; #q_diLogData.logEntryCount#</TD>						
					</TR>
					<cfif q_diLogData.logEntryCount GT 0></a></cfif>
					<cfset anyRecord=true>
					<cfset k=k+1>
				<!-----</cfif>------->
		</CFIF>
		<!-----------Show logTable statistics---------------------------------------->
		
		<cfset j=j+1>

	</cfloop>
</CFIF>
<CFIF NOT anyRecord>
	<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<FONT SIZE="2"><B>
		No data integration Log entry
		</B></FONT>
		</TD>
		</TD>
		</TR>
	</TABLE>
</CFIF>

</cfoutput>
	</TABLE>	
</TD>
</TR>
</TABLE>
</cfform>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_MessageWindow>
<CFIF isDefined("sPageErr")>
	<SCRIPT LANGUAGE="JavaScript">
		showError();		
	</SCRIPT>
</CFIF>
</BODY>
</HTML>
