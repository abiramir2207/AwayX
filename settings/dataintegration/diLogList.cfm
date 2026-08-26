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
<CFSET helpfilenumber=38>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT LANGUAGE="Javascript">
</SCRIPT>

<CFSET diThisPage="#diLogListPage#">
<CFINCLUDE template="diHeader.cfm">

<CFPARAM NAME="URL.logitem" DEFAULT="">
<CFPARAM NAME="URL.thisPage" DEFAULT=1>


<CFPARAM NAME="StartRow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=20>

	<CFOUTPUT>
		<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">
				<A HREF="#diLogTextFile#?logitem=#URL.logitem#">
					create text file
				</A>
		</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">
				<A HREF="#diLogPage#">
					back
				</A>
		</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
	</CFOUTPUT>

<TABLE ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="100%">
<TR>
<TD><span id="error_logDetails"></span></TD>
</TR>
<TR>
<TD>
	<TABLE CELLSPACING="0" CELLPADDING="4" BORDER="0" ALIGN="CENTER" WIDTH="100%">

<cfset anyRecord=false>
<CFIF (ListLen(logTables,",") EQ ListLen(logItems,",")) AND (ListLen(logTables,",") EQ ListLen(originalDB,","))>
		<cfset logItemName=URL.logitem>
		<cfset thisLogPosition=ListFindNoCase(logItems,logItemName,",")>
		
		<cfif NOT thisLogPosition>
		<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>
		<cfoutput>
		<FONT SIZE="2"><B>
		No data integration Log #logItemName# found
		</B></FONT>
		</cfoutput>
		</TD>
		</TD>
		</TR>
		</TABLE>
			<cfabort>
		</cfif>
		
		<cfset i=ListGetAt(logTables,thisLogPosition,",")>
		<cfset thisRecID=0>
		<cfset idName="Log_#ListGetAt(logItems,thisLogPosition,",")#_id">
		<cfset thisListFields=Evaluate("Log#logItemName#ListFields")>
		
		
		<!---------------Show the whole list of entry in tables------------------>
		<CFQUERY NAME="q_diLogData" datasource="#application.datasource#">
			SELECT #idName#,Err_Number,Err_Message,#thisListFields#
		    FROM #i#
		</CFQUERY>
		<CFIF q_diLogData.recordCount GT 0>
			
			<cfset pageLen=50>
			<cfset thisPage=Val(URL.thisPage)>
			<cfset lStartRow=((thisPage-1)*pageLen)+1>			
			<cfif lStartRow GT q_diLogData.recordCount>
				<cfset thisPage=1>
				<cfset lStartRow=1>
			</cfif>
			<cfset lEndRow=thisPage*pageLen>
		
			<cfset pageCount=(q_diLogData.recordCount \ pageLen) + 1>


	
<HR COLOR="Orange" SIZE="2">
<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
	<CF_Next_Previous_For_Forms
	formname="MyForm"
	query="q_diLogData"
	maxpages="30"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
	lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"		
	addparams="">
</DIV>
<HR COLOR="Orange" SIZE="2">		
			

		<CFQUERY NAME="q_diLogErrors" datasource="#application.datasource#">
		SELECT	DISTINCT Err_Message,Err_NUmber
		FROM	#i#
		WHERE	NOT(Err_Number is NULL)
		</CFQUERY>
		<CFIF q_diLogErrors.recordCount GT 0>
		<CFSET colLen=3>
		<TABLE CELLSPACING="0" CELLPADDING="3" BORDER="0" WIDTH="100%">				
				<COLGROUP>
				<COL SPAN="#colLen#" WIDTH="20%"></COL>
				</COLGROUP>
				<TR>
					<TD COLSPAN="#colLen#">
					<b>Error Description</b>
					</TD>
					<cfset j=Val(0)>
					<cfloop query="q_diLogErrors">
						<cfif (j MOD colLen) EQ 0>
							</TR>
							<TR>
						</cfif>
						<TD>
						<CFOUTPUT><font class="fc_red"><b>#Err_NUmber# - #Err_Message#</b></font></CFOUTPUT>
						</TD>
						<cfset j=j+1>
					</cfloop>
					</TR>
				</TABLE>
		</CFIF>
			
			<CF_DI_CUST_SETTING_NAME 
				DI_keyword="#logItemName#" 
				ReturnField="Cust_Setting_Item_Name">
			<CFOUTPUT>
			<TABLE ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="100%">
			<COLGROUP>
			<COL WIDTH="20">
			</COLGROUP>
			<caption><b>#Cust_Setting_Item_Name#</b></caption>
			<TR BGCOLOR="##FFCE84">
			<TD>##</TD>
				
			<cfif isDefined("q_diLogData.#idName#")>
				<!---<cfloop index="field" list="#q_diLogData.columnList#" delimiters=",">--->
				<cfloop index="field" list="#thisListFields#" delimiters=",">
					<cfif isDefined("q_diLogData.#field#")>
							<cfif ListFindNoCase(thisListFields, field,",")>
								<TD ALIGN="LEFT"><b>#UCase(field)#</b></TD>
							</cfif>						
					</cfif>
				</cfloop>
				<TD ALIGN="LEFT" WIDTH="50"><b>#UCase("Error")#</b></TD>				
			</cfif>			
			</TR>
			</CFOUTPUT>
			<cfoutput query="q_diLogData" startrow="#StartRow#" maxrows="#MaxRows#">
			<!--- <cfloop query="q_diLogData" startrow="#lStartRow#" endrow="#lEndRow#"> --->
			<cfif isDefined("#idName#")>
				<CFSET Err_Number=q_diLogData.Err_Number>
				<CFSET Err_Message=q_diLogData.Err_Message>				
				<cfset thisRecID=Evaluate("#idName#")>				
				<a href="#diLogDetailsPage#?logitem=#logItemName#&logID=#thisRecID#&thisPage=#thisPage#">
				<TR<cfif (q_diLogData.currentRow mod 2) NEQ 0> BGCOLOR=ccffcc</cfif> style="cursor:pointer">
				<TD style="color:blue">#q_diLogData.currentRow#</TD>
				<!---<cfloop index="field" list="#q_diLogData.columnList#" delimiters=",">---->
				<cfloop index="field" list="#thisListFields#" delimiters=",">
					<cfif isDefined("q_diLogData.#field#")>
							<cfif ListFindNoCase(thisListFields, field,",")>
								<!---<TD><a href="#diLogDetailsPage#?logtable=#i#&logID=#thisRecID#">#Evaluate("q_diLogData.#field#")#</a></TD>--->
								<TD style="color:blue" VALIGN="TOP">#Evaluate("q_diLogData.#field#")#</TD>
								<cfset anyRecord=true>
							</cfif>
					</cfif>
				</cfloop>
				<TD TITLE="#Err_Message#"><font class="fc_red">#Err_Number#</font></TD>
				</TR>
				</a>
			</cfif>
			</cfoutput>
			</TABLE>
		</CFIF>		
		<!---------------Show the whole list of entry in tables------------------>
</CFIF>

<CFIF NOT anyRecord>
	<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<FONT SIZE="2"><B>
		<CFOUTPUT>No data integration Log entry for #logItemName#</CFOUTPUT>
		</B></FONT>
		</TD>
		</TD>
		</TR>
	</TABLE>
</CFIF>


	</TABLE>	
</TD>
</TR>
</TABLE>
<CFOUTPUT>
<FORM ACTION="diLogList.cfm?logitem=#URL.logitem#" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">	
</FORM>
</CFOUTPUT>

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
