<CFSET rStatus=-1>

<CFSET rReportOutputType="h">

<!----------- Get a new report name --------------------->
<CFQUERY NAME="q_reportName" datasource="#application.datasource#">
	SELECT Max(Report_Type_ID) as maxReport_Type_ID
	FROM Report_Type
</CFQUERY>
<CFIF q_reportName.recordCount GT 0>
	<CFIF q_reportName.maxReport_Type_ID EQ "">
		<CFSET rName="Product Margin Report 1">
	<CFELSE>
		<CFSET rName="Product Margin Report #Evaluate(q_reportName.maxReport_Type_ID+1)#">
	</CFIF>
</CFIF>

<!----------- Get a new report name --------------------->


<CFSET rStartDate=dateformat(Now(), 'm/d/yyy')>
<CFSET rEndDate=dateformat(Now(), 'm/d/yyy')>
<CFSET rStartTime=thisTime>
<CFSET rInterval="daily">
<CFSET rEmailAddress="">

<cfset showDetails=false>
<cfif isDefined("fromReportSaveAction")>
	<CFSET rStatus=Form.rStatus>
	
	<CFSET rReportOutputType=Form.rReportOutputType>
	
	<CFSET rName=Form.rName>
	<CFSET rStartDate=Form.rStartDate>
	<CFSET rEndDate=Form.rEndDate>
	<CFSET rStartTime=getMilitaryTime(Form.rStartTime)>
	<CFSET rInterval=Form.rInterval>
	<CFSET rEmailAddress=Form.rEmailAddress>	
<cfelseif isDefined("rID")>
	<CFIF IsDefined("q_getReportStructure")>
		<CFLOOP QUERY="q_getReportStructure">
			<CFSET Evaluate("#Report_Structure#=""#Report_Structure_Value#""")>
		</CFLOOP>
		
		<CFIF isDefined("rFilterValue") AND isDefined("rFilter")>
			<CFSET Evaluate("r#rFilter#s=""#rFilterValue#""")>
		</CFIF>
		
		<CFIF isDefined("rFilterItemValue") AND isDefined("rFilterItems")>
			<CFSET Evaluate("r#rFilterItems#s=""#rFilterItemValue#""")>
		</CFIF>
		
		<CFSET rName=q_getReportDetails.Report_Name>
		<CFSET rStartDate=q_getReportDetails.Report_StartDate>
		<CFSET rEndDate=q_getReportDetails.Report_EndDate>
		<!----<CFSET rStartTime=getMilitaryTime(q_getReportDetails.rStartTime)>--->
		<CFSET rStartTime=q_getReportDetails.Report_StartTime>
		<CFSET rInterval=q_getReportDetails.Report_Interval>
		<CFSET rEmailAddress=q_getReportDetails.Report_EmailAddress>		
		<cfset showDetails=true>
	<CFELSE>
		<CFSET rID=0>
	</CFIF>	
</cfif>
	
	<cfif showDetails>
		<SPAN CLASS="title2"><CFOUTPUT>#rName#</CFOUTPUT></SPAN><BR>
	</cfif>
	<B>
<FONT SIZE="2" COLOR="Red">[</FONT>
<FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/Reports/margin.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;">read me first</A></FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
	<cfif isDefined("sErr")>
		<TABLE BGCOLOR="Red" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		Update failed. Some of the fields are either missing or invalid.
		</B></FONT></CFOUTPUT>
		</TD>
		</TD>
		</TR>
		</TABLE>
	<cfelseif isDefined("URL.action")>
		<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		The report was <cfif URL.action EQ "edit">edited<cfelse>added</cfif> successfully.
		</B></FONT></CFOUTPUT>
		</TD>
		</TD>
		</TR>
		</TABLE>
	<cfelseif showDetails>
		<SPAN CLASS="title2"><CFOUTPUT>#rName#</CFOUTPUT></SPAN>
		<CFIF Len(rUserName) GT 0><BR><BR>
		<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
			<TR BGCOLOR="White">
			<TD>		
			<CFOUTPUT><FONT SIZE="2"><B>		
			This Report was last updated on #rEditDate# by #rUserName#		
			</B></FONT></CFOUTPUT>
			</TD>
			</TD>
			</TR>
		</TABLE>
		</CFIF>	
	</cfif>
	<FORM ACTION="<cfoutput>#reportActionPage#</cfoutput>" TARGET="_self" METHOD="post" NAME="mProductMarginForm" ID="mProductMarginForm">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="1" WIDTH="700">
	<TR>
		<TD VALIGN="TOP" ROWSPAN="7"></TD>
		<TD ROWSPAN="7" VALIGN="TOP">
		<strong>Status</strong><br>
		<SELECT size="5" name="rStatus" multiple>
				<OPTION VALUE="-1"<cfif ListFindNoCase(rStatus,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getStatus"><OPTION<cfif ListFindNoCase(rStatus,q_getStatus.Contract_Status_Type_ID,",")> SELECTED</cfif> VALUE="#q_getStatus.Contract_Status_Type_ID#">#q_getStatus.Contract_Status_Type_Desc#</OPTION></CFOUTPUT>
		</SELECT>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="4" ALIGN="LEFT" VALIGN="TOP">
		<HR COLOR="Orange" SIZE="1">
		<INPUT TYPE="hidden" ID="rReportType" NAME="rReportType" VALUE="<CFOUTPUT>#reportType#</CFOUTPUT>">
		</TD>
	</TR>	
	</TABLE>
	<cfif isDefined("rID")>
			<cfif rID GT 0>
				<cfset bTitle="Edit This Report Schedule">
			<cfelse>
				<cfset bTitle="Save As Report Schedule">
			</cfif>
		<cfelse>
			<cfset bTitle="Save As Report Schedule">
		</cfif>
		<cfif isDefined("sErr")><cfset showClosed="No"><cfelse><cfset showClosed="Yes"></cfif>
		<CF_openLayer
	Border="yes"
	BorderSize="1"  
	BorderColor="orange"  
	Image="/images/plus2.gif"
	ImageOpen="/images/minus2.gif"
	Title="#bTitle#"  
	TitleClosed="#bTitle#"  
	TitleTooltip="#bTitle#"  
	TitleFont="font"  
	TitleColor="Blue"  
	TitleSize="9"  
	IsClosed="#showClosed#"  
	Width="100%">
		<CFSET thisFormName="pProductSummaryForm"> 
		<CFSET repType="p">
		<CFINCLUDE TEMPLATE="#reportTemplatePage#">		
		</CF_openLayer><br>
	<DIV ALIGN="center">
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"show report"
			BUTTON_ACTION	=	"javascript:verifyData(document.mProductMarginForm,\'m\');"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
		</DIV>	
	</FORM>
	