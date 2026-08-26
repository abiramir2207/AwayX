<CFSET rStatus=-1>
<CFSET rProgramTypes="-1">
<CFSET rFilter="zone">
<CFSET rZones="-1">
<CFSET rRegions="-1">
<CFSET rBrokers="-1">
<CFSET rSortBy="status,programtype">

<CFSET rFilterItems="typegroup">

<CFSET rTypeGroups="-1">
<CFSET rQBrands="-1">
<CFSET rTypeCodes="-1">
<CFSET rBrands="-1">

<CFSET rReportOutputType="h">
<CFSET rColumnHeaderID=programColumnHeaderID>

<!----------- Get a new report name --------------------->
<CFQUERY NAME="q_reportName" datasource="#application.datasource#">
	SELECT Max(Report_Type_ID) as maxReport_Type_ID
	FROM Report_Type
</CFQUERY>
<CFIF q_reportName.recordCount GT 0>
	<CFIF q_reportName.maxReport_Type_ID EQ "">
		<CFSET rName="Program Report 1">
	<CFELSE>
		<CFSET rName="Program Report #Evaluate(q_reportName.maxReport_Type_ID+1)#">
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
	<CFSET rProgramTypes=Form.rProgramTypes>
	<CFSET rFilter=Form.rFilter>
	<CFSET rZones=Form.rZones>
	<CFSET rRegions=Form.rRegions>
	<CFSET rBrokers=Form.rBrokers>
	<CFSET rSortBy=Form.rSortBy>
	
	<CFSET rFilterItems=Form.rFilterItems>
	
	<CFSET rTypeGroups=Form.rTypeGroups>
	<CFSET rQBrands=Form.rQBrands>
	<CFSET rTypeCodes=Form.rTypeCodes>
	<CFSET rBrands=Form.rBrands>
	
	<CFSET rReportOutputType=Form.rReportOutputType>
	<CFSET rColumnHeaderID=Form.rColumnHeaderID>
	
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
	</cfif>
	
	<FORM ACTION="<cfoutput>#reportActionPage#</cfoutput>" TARGET="_self" METHOD="post" NAME="rProgramSummaryForm" ID="rProgramSummaryForm">	
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="1" WIDTH="700">
	<TR>
		<TD VALIGN="TOP" ROWSPAN="5"></TD>
		<TD ROWSPAN="5" VALIGN="TOP">
		<strong>Status</strong><br>
		<SELECT size="5" name="rStatus" multiple>
				<OPTION VALUE="-1"<cfif ListFindNoCase(rStatus,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getStatus"><OPTION<cfif ListFindNoCase(rStatus,q_getStatus.Contract_Status_Type_ID,",")> SELECTED</cfif> VALUE="#q_getStatus.Contract_Status_Type_ID#">#q_getStatus.Contract_Status_Type_Desc#</OPTION></CFOUTPUT>
		</SELECT>
		</TD>
	</TR>
	
	<TR>		
		<TD COLSPAN="2"><span id="error_rFilterItems"></span>&nbsp;<strong>Geographic Filter (This field will be used for primary grouping)</strong></TD>
	</TR>
	<TR>	
			<TD><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="zone"<cfif rFilter EQ "zone"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');">Zone</TD>
			<TD>
		<cfset selFound=false>
		<DIV ID="rFilterDIVzone">		
		<SELECT size="1" name="rZones">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rZones EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getZones"><OPTION<cfif rZones EQ q_getZones.Service_Zone_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getZones.Service_Zone_ID#">#q_getZones.Zone_Name#</OPTION></CFOUTPUT>
				<cfif NOT selFound AND rZones NEQ "-1" AND rZones NEQ "">
				<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
				Select	sz.Zone_Name,sz.Deleted
				From	Service_Zones sz
				Where	sz.Service_Zone_ID='#rZones#'
				</CFQUERY>
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Zone_Name>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
				<CFELSE>
					<CFSET thisFilter="---ZONE NOT FOUND---">
				</CFIF>
				<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
				</cfif>
		</SELECT>
		</DIV>
		</TD>
	</TR>
	
	<TR>
		<TD><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="region"<cfif rFilter EQ "region"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');">Region </TD>
		<TD>
		<cfset selFound=false>
		<DIV ID="rFilterDIVregion">
		<SELECT size="1" name="rRegions">				
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rRegions EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getRegions"><OPTION<cfif rRegions EQ q_getRegions.Service_Region_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getRegions.Service_Region_ID#">#q_getRegions.Region_Name#</OPTION></CFOUTPUT>
				<cfif NOT selFound AND rRegions NEQ "-1" AND rRegions NEQ "">
				<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
				Select	sr.Region_Name,sr.Deleted
				From	Service_Regions sr
				Where	sr.Service_Region_ID='#rRegions#'
				</CFQUERY>
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Region_Name>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
				<CFELSE>
					<CFSET thisFilter="---REGION NOT FOUND---">
				</CFIF>
				<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
				</cfif>
		</SELECT>
		</DIV>
		</TD>
		</TR>
		<TR>
		<TD><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="broker"<cfif rFilter EQ "broker"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');">Broker</TD>
		<TD>
		<cfset selFound=false>
		<DIV ID="rFilterDIVbroker">
		<SELECT size="1" name="rBrokers">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rBrokers EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getBrokers"><OPTION<cfif rBrokers EQ q_getBrokers.BSA_Foodservice_Brokers_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getBrokers.BSA_Foodservice_Brokers_ID#">#q_getBrokers.Broker_Name#</OPTION></CFOUTPUT>
				<cfif NOT selFound AND rBrokers NEQ "-1" AND rBrokers NEQ "">
				<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
				Select	cfb.Broker_Name,cfb.Active_Code,cfb.Deleted,lob.Line_Of_Business
				From 	BSA_Foodservice_Brokers cfb,Line_Of_Business lob
				Where
				cfb.Line_Of_Business_ID = lob.Line_Of_Business_ID
				and cfb.BSA_Foodservice_Brokers_ID='#rBrokers#'
				</CFQUERY>				
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Broker_Name>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
					<CFIF ListFindNoCase(application.returned_customer_setting.Line_Business_Default, q_getThisFilter.Line_Of_Business, ",") EQ 0>
						<CFSET thisFilter="LOB(#q_getThisFilter.Line_Of_Business#) - #thisFilter#">
					</CFIF>
					<CFIF q_getThisFilter.Active_Code NEQ "A">
						<CFSET thisFilter="NOT ACTIVE - #thisFilter#">
					</CFIF>
				<CFELSE>
					<CFSET thisFilter="---BROKER NOT FOUND---">
				</CFIF>
				<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
				</cfif>
		</SELECT>
		</DIV>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="2"><HR COLOR="Orange" SIZE="1"></TD>
		<TD COLSPAN="2"><HR COLOR="Orange" SIZE="1"></TD>
	</TR>
		
	<TR>
		<TD VALIGN="TOP"></TD>
		<TD VALIGN="TOP">
		<strong>Program Types</strong><br>
		<SELECT size="5" name="rProgramTypes" multiple>
				<OPTION VALUE="-1"<cfif ListFindNoCase(rProgramTypes,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getProgramTypes"><OPTION<cfif ListFindNoCase(rProgramTypes,q_getProgramTypes.ProgramControl_Panel_Options_ID,",")> SELECTED</cfif> VALUE="#q_getProgramTypes.ProgramControl_Panel_Options_ID#">#q_getProgramTypes.Created_Type#</OPTION></CFOUTPUT>
		</SELECT>		
		</TD>	
		<TD VALIGN="TOP"><strong>Group By</strong></TD>
		<TD VALIGN="TOP">
		<SELECT SIZE="1" NAME="rSortBy">
		<OPTION VALUE="-1"<cfif ListFindNoCase(rSortBy,"-1",",") EQ 1> SELECTED</cfif>>--Select ----</OPTION>		
		<OPTION VALUE="status"<cfif ListFindNoCase(rSortBy,"status",",") EQ 1> SELECTED</cfif>>Status</OPTION>
		<OPTION VALUE="programtype"<cfif ListFindNoCase(rSortBy,"programtype",",") EQ 1> SELECTED</cfif>>Program Types</OPTION>
		</SELECT>
		<BR>
		<SELECT SIZE="1" NAME="rSortBy">
		<OPTION VALUE="-1"<cfif ListFindNoCase(rSortBy,"-1",",") EQ 2> SELECTED</cfif>>--Select ----</OPTION>
		<OPTION VALUE="status"<cfif ListFindNoCase(rSortBy,"status",",") EQ 2> SELECTED</cfif>>Status</OPTION>
		<OPTION VALUE="programtype"<cfif ListFindNoCase(rSortBy,"programtype",",") EQ 2> SELECTED</cfif>>Program Types</OPTION>
		</SELECT>		
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="4" ALIGN="LEFT">
		<HR COLOR="Orange" SIZE="1">
		<strong>Report output Type</strong>
		<BR><INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="h"<cfif rReportOutputType EQ "h"> CHECKED</cfif>>HTML
		 <INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="e"<cfif rReportOutputType EQ "e"> CHECKED</cfif>>Excel
		 <INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="c"<cfif rReportOutputType EQ "c"> CHECKED</cfif>>CSV
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="4" ALIGN="LEFT">		
		<cfif ListLen(programColumnHeaderID,",") GT 0>
		<HR COLOR="Orange" SIZE="1">
			<cfif ListLen(programColumnHeaderID,",") GTE ListLen(programColumnHeaders,",")>
				<CFSET colLen=4>								
				<cfoutput>				
				<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" WIDTH="100%">				
				<COLGROUP>
				<COL SPAN="#colLen#" WIDTH="20%"></COL>
				</COLGROUP>
					<TR>
						<TD COLSPAN="100%">
						<span id="rerror_ColumnHeader"></span>&nbsp;<strong>Select Colum Headers</strong>
						</TD>
					<cfset j=Val(1)>					
					<cfloop index="i" list="#programColumnHeaderID#" delimiters=",">						
						<cfif (j MOD colLen) EQ 1>
							</TR>
							<TR>
						</cfif>
						<TD>
						<INPUT TYPE="checkbox" ID="rColumnHeaderID" NAME="rColumnHeaderID" VALUE="#i#"<cfif ListFindNoCase(rColumnHeaderID,i,",")> CHECKED</cfif>> #ListGetAt(programColumnHeaders,j,",")#
						</TD>
						<cfset j=j+1>
					</cfloop>
					</TR>
				</TABLE>
				</cfoutput>
			</cfif>
		</cfif>
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
		<CFSET thisFormName="rProgramSummaryForm">
		<CFSET repType="r">
		<CFINCLUDE TEMPLATE="#reportTemplatePage#">		
		</CF_openLayer><br>
	<DIV ALIGN="center">
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"show report"
			BUTTON_ACTION	=	"javascript:verifyData(document.rProgramSummaryForm,\'r\');"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
		</DIV>
	</FORM>

