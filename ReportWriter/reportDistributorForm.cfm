<CFSET rStatus="-1">
<CFSET rBusinessSegment="-1">
<CFSET rDiscountIdentifier="-1">
<CFSET rGenericTypes="-1">
<CFSET rFilter="none">
<CFSET rZones="">
<CFSET rRegions="">
<CFSET rBrokers="">
<CFSET rSortBy="status,programtype">

<CFSET rFilterItems="none">

<CFSET rFamilys="">
<CFSET rBuyingGroups="">
<CFSET rDistributors="">
<cfset rOutputStartDate = "">
<cfset rOutputStartDateOperator = "">
<cfset rOutputEndDate = "">
<cfset rOutputEndDateOperator = "">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFSET rReportOutputType="h">
<CFSET rColumnHeaderID=ListAppend(fProgramColumnHeaderID,vProgramColumnHeaderID,",")>

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
	<CFSET rBusinessSegment=Form.rBusinessSegment>
	<CFSET rDiscountIdentifier=Form.rDiscountIdentifier>
	<CFSET rGenericTypes=Form.rGenericTypes>	
	<CFSET rFilter=Form.rFilter>
	<CFSET rZones=Form.rZones>
	<CFSET rRegions=Form.rRegions>
	<CFSET rBrokers=Form.rBrokers>
	<CFSET rSortBy=Form.rSortBy>
	
	<CFSET rFilterItems=Form.rFilterItems>
	
	<CFSET rFamilys=Form.rFamilys>
	<CFSET rBuyingGroups=Form.rBuyingGroups>
	<CFSET rDistributors=Form.rDistributors>
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
	
	<cfset discountIdentifierManager = CreateObject("component","components.programs.discount_identifier.discountidentifier")>
	<CFSET thisFormName="rProgramSummaryForm"> 
	<cfoutput>
	<FORM ACTION="#reportActionPage#" TARGET="_self" METHOD="post" NAME="#thisFormName#" ID="rProgramSummaryForm" style="display:inline;">
	</cfoutput>
	<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="90%">
	<TR valign="top">
		<TD VALIGN="TOP" ROWSPAN="7"></TD>
		<TD ROWSPAN=7" VALIGN="TOP">
		<strong>Status</strong><br>
		<SELECT size="5" name="rStatus" multiple>
				<OPTION VALUE="-1"<cfif ListFindNoCase(rStatus,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getStatus"><OPTION<cfif ListFindNoCase(rStatus,q_getStatus.Contract_Status_Type_ID,",")> SELECTED</cfif> VALUE="#q_getStatus.Contract_Status_Type_ID#">#q_getStatus.Contract_Status_Type_Desc#</OPTION></CFOUTPUT>
		</SELECT>
		</TD>
		<cfif businessSegEnabled>
      <td width="25%" rowspan="7">	  
	  <cfset qGetBusSegments = businessSegManager.getActive() />
	  <strong><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></strong><br>
	  <SELECT size="5" name="rBusinessSegment" multiple>
	  <OPTION VALUE="-1"<cfif ListFindNoCase(rBusinessSegment,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
	  	<cfoutput query="qGetBusSegments">
			<option value="#Business_Segment_ID#">#Business_Unit_Desc#</option>
		</cfoutput>
      </SELECT>
	  <cfelse>
	  <td width="15%" rowspan="7">
	  </cfif>
	  &nbsp;</td>
	</TR>
	<TR>
		<TD COLSPAN=2><span id="error_rFilter"></span>&nbsp;<strong>Geographic Filter</strong></TD>
	</TR>
	<TR>
			<TD><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="zone"<cfif rFilter EQ "zone"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');"><CFOUTPUT>#application.returned_customer_setting.zone_label_singular#</CFOUTPUT><!--- Zone ---></TD>
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
				,(SELECT count(cfb1.Broker_Name) FROM Service_Zones sz1,BSA_Foodservice_Brokers cfb1,Line_Of_Business lob1 WHERE cfb1.Service_Zone_ID=sz1.Service_Zone_ID AND cfb1.Line_Of_Business_ID = lob1.Line_Of_Business_ID AND cfb1.Deleted=0 AND cfb1.Active_Code='A' AND lob1.Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#) AND sz1.Service_Zone_ID=sz.Service_Zone_ID) AS BROKERCOUNT
				From	Service_Zones sz
				Where	sz.Service_Zone_ID='#rZones#'
				</CFQUERY>
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Zone_Name>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
					<CFIF q_getThisFilter.BROKERCOUNT LTE 0>
						<CFSET thisFilter="NO BROKERS - #thisFilter#">
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
		<TD><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="region"<cfif rFilter EQ "region"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');"><CFOUTPUT>#application.returned_customer_setting.region_label_singular#</CFOUTPUT><!--- Region ---> </TD>
		<TD VALIGN="TOP">		
		<cfset selFound=false>
		<DIV ID="rFilterDIVregion">
		<SELECT size="1" name="rRegions">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rRegions EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getRegions"><OPTION<cfif rRegions EQ q_getRegions.Service_Region_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getRegions.Service_Region_ID#">#q_getRegions.Region_Name#</OPTION></CFOUTPUT>
				<cfif NOT selFound AND rRegions NEQ "-1" AND rRegions NEQ "">
				<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
				Select	sr.Region_Name,sr.Deleted
				,(SELECT count(cfb1.Broker_Name) FROM Service_Regions sr1,BSA_Foodservice_Brokers cfb1,Line_Of_Business lob1 WHERE cfb1.Service_Region_ID=sr1.Service_Region_ID AND cfb1.Line_Of_Business_ID = lob1.Line_Of_Business_ID AND cfb1.Deleted=0 AND cfb1.Active_Code='A' AND lob1.Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#) AND sr1.Service_Region_ID=sr.Service_Region_ID) AS BROKERCOUNT
				From	Service_Regions sr
				Where	sr.Service_Region_ID='#rRegions#'
				</CFQUERY>
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Region_Name>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
					<CFIF q_getThisFilter.BROKERCOUNT LTE 0>
						<CFSET thisFilter="NO BROKERS - #thisFilter#">
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
		<TD><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="broker"<cfif rFilter EQ "broker"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');"><CFOUTPUT>#application.returned_customer_setting.broker_label_singular#</CFOUTPUT><!--- Broker ---></TD>
		<TD>
		<DIV ID="rFilterDIVbroker">
		<CFOUTPUT>
		<INPUT TYPE="HIDDEN" ID="rBrokers" NAME="rBrokers" VALUE="#rBrokers#">
		<IFRAME NAME="Broker_Frame" STYLE="WIDTH:250px;HEIGHT:20px;" ATOMICSELECTION="false" SRC="ShowBrokers.cfm?rBrokers=#rBrokers#" FRAMEBORDER="0" style="border: 0px none ##000000;" SCROLLING="No"></IFRAME>
		</CFOUTPUT>
		<!--------
		<cfset selFound=false>
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
					<CFIF q_getThisFilter.Line_Of_Business NEQ 'F'>
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
		---------->
		</DIV>
		</TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="none"<cfif rFilter EQ "none"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');">None</TD>
		<TD></TD>
	</TR>
	<TR>
		<TD COLSPAN="2"><HR COLOR="Orange" SIZE="1"></TD>		
	</TR>
	<TR valign="top">
		<TD VALIGN="TOP" ROWSPAN="6"></TD>
		<TD VALIGN="TOP" ROWSPAN="6">
		<!------<strong>Program Types</strong><br>
		<SELECT size="5" name="rProgramTypes" multiple>
				<OPTION VALUE="-1"<cfif ListFindNoCase(rProgramTypes,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getProgramTypes"><OPTION<cfif ListFindNoCase(rProgramTypes,q_getProgramTypes.ProgramControl_Panel_Options_ID,",")> SELECTED</cfif> VALUE="#q_getProgramTypes.ProgramControl_Panel_Options_ID#">#q_getProgramTypes.Created_Type#</OPTION></CFOUTPUT>
		</SELECT>----->
		<strong>Program Generic Types</strong><br>
		<SELECT size="5" name="rGenericTypes" multiple>
				<OPTION VALUE="-1"<cfif ListFindNoCase(rGenericTypes,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getGenericTypes"><OPTION<cfif ListFindNoCase(rGenericTypes,Generic_Type_ID,",")> SELECTED</cfif> VALUE="#Generic_Type_ID#">#ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label)#</OPTION></CFOUTPUT>
		</SELECT>
		</TD>
		<cfif discountIdentifierManager.discountIdentifierOn()>	  
      <td width="25%" rowspan="7"><strong>Discount Identifier</strong><br>
	  <cfset qGetDiscountIdentifiers = discountIdentifierManager.getActive() />
	 <select size="5" name="rDiscountIdentifier" multiple>
           <option value="-1"<cfif ListFindNoCase(rDiscountIdentifier,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</option>
          <cfoutput query="qGetDiscountIdentifiers"> 
		  	<option<cfif ListFindNoCase(rDiscountIdentifier,Discount_Identifier_ID,",")> SELECTED</cfif> value="#Discount_Identifier_ID#">#Discount_Identifier_Desc#</option>
          </cfoutput>
		</select>
	  <cfelse>
      <td width="15%" rowspan="7">
	  </cfif>
	  &nbsp;</td>
	</TR>
	<TR>
		<TD COLSPAN=2><span id="error_rFilterItems"></span>&nbsp;<strong>Customer Filter (This field will be used for primary grouping)</strong></TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="family"<cfif rFilterItems EQ "family"> CHECKED</cfif> onClick="javascript:setReportFilterCustomer(this.value);"><CFOUTPUT>#application.returned_customer_setting.family_name_label_singular#</CFOUTPUT><!--- Family ---></TD>
			<TD>
		<cfset selFound=false>
		<DIV ID="rFilterItemDIVfamily">
		<SELECT size="1" name="rFamilys">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rFamilys EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getFamilys"><OPTION<cfif rFamilys EQ q_getFamilys.family_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getFamilys.family_ID#">#q_getFamilys.family_Name#</OPTION></CFOUTPUT>
				<cfif NOT selFound AND rFamilys NEQ "-1" AND rFamilys NEQ "">
				<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
				Select 	f.Family_Name,f.Deleted
				From	Distributor_Family f
				Where	f.family_ID='#rFamilys#'
				</CFQUERY>				
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Family_Name>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
				<CFELSE>
					<CFSET thisFilter="---Family NOT FOUND---">
				</CFIF>
				<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
				</cfif>				
		</SELECT>
		</DIV>
		</TD>
	</TR>
	<TR>
			<TD><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="buyinggroup"<cfif rFilterItems EQ "buyingGroup"> CHECKED</cfif> onClick="javascript:setReportFilterCustomer(this.value);"><CFOUTPUT>#application.returned_customer_setting.buying_group_label_singular#</CFOUTPUT><!--- Buying Group ---></TD>
			<TD>
		<cfset selFound=false>
		<DIV ID="rFilterItemDIVbuyinggroup">
		<SELECT size="1" name="rBuyingGroups">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rBuyingGroups EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getBuyingGroups"><OPTION<cfif rBuyingGroups EQ q_getBuyingGroups.Buying_Group_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getBuyingGroups.Buying_Group_ID#">#q_getBuyingGroups.Buying_Group_Name#</OPTION></CFOUTPUT>
				<cfif NOT selFound AND rBuyingGroups NEQ "-1" AND rBuyingGroups NEQ "">
				<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
				Select 	bg.Buying_Group_Name,bg.Deleted,bg.active_code
				From	Distributor_Buying_Groups bg
				Where	bg.buying_group_ID='#rBuyingGroups#'
				</CFQUERY>				
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Buying_Group_Name>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
					<CFIF q_getThisFilter.Active_Code NEQ 'A'>
						<CFSET thisFilter="NOT ACTIVE - #thisFilter#">
					</CFIF>
				<CFELSE>
					<CFSET thisFilter="---BuyingGroup NOT FOUND---">
				</CFIF>				
				<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
				</cfif>				
		</SELECT>		
		</DIV>
		</TD>
		</TR>
		<TR>
			<TD><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="distributor"<cfif rFilterItems EQ "distributor"> CHECKED</cfif> onClick="javascript:setReportFilterCustomer(this.value);"><CFOUTPUT>#application.returned_customer_setting.distributor_label_singular#</CFOUTPUT><!--- Distributor ---></TD>
			<TD>
			<DIV ID="rFilterItemDIVdistributor">
			<CFOUTPUT>
			<INPUT TYPE="HIDDEN" ID="rDistributors" NAME="rDistributors" VALUE="#rDistributors#">
			<IFRAME NAME="Distributor_Frame" STYLE="WIDTH:250px;HEIGHT:20px;" ATOMICSELECTION="false" SRC="ShowDistributors.cfm?rDistributors=#rDistributors#" FRAMEBORDER="0" style="border: 0px none ##000000;" SCROLLING="No"></IFRAME>
			</CFOUTPUT>
			<!-------
		<cfset selFound=false>		
		<SELECT size="1" name="rDistributors">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rDistributors EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getDistributors"><OPTION<cfif rDistributors EQ q_getDistributors.BSA_FoodService_Customers_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getDistributors.BSA_FoodService_Customers_ID#">#q_getDistributors.Name#</OPTION></CFOUTPUT>
				<cfif NOT selFound AND rDistributors NEQ "-1" AND rDistributors NEQ "">
				<CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
				SELECT  cfc.Name,cfc.Active_Code,cfc.Deleted,lob.Line_Of_Business
				FROM    BSA_Foodservice_Customers cfc,Line_Of_Business lob					
				WHERE   cfc.Line_Of_Business_ID = lob.Line_Of_Business_ID
					and cfc.BSA_Foodservice_Customers_ID='#rDistributors#'
				</CFQUERY>
				<CFIF q_getThisFilter.recordCount GT 0>
					<CFSET thisFilter=q_getThisFilter.Name>
					<CFIF q_getThisFilter.Deleted>
						<CFSET thisFilter="DELETED - #thisFilter#">
					</CFIF>
					<CFIF q_getThisFilter.Active_Code NEQ 'A'>
						<CFSET thisFilter="NOT ACTIVE - #thisFilter#">
					</CFIF>
					<CFIF q_getThisFilter.Line_Of_Business NEQ 'F'>
						<CFSET thisFilter="NOT LOB(F) - #thisFilter#">
					</CFIF>
				<CFELSE>
					<CFSET thisFilter="---Distributor NOT FOUND---">
				</CFIF>
				<CFOUTPUT><OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION></CFOUTPUT>
				</cfif>
		</SELECT>
		-------------------->
		</DIV>
		</TD>
		</TR>
		<TR>
			<TD><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="none"<cfif rFilterItems EQ "none"> CHECKED</cfif> onClick="javascript:setReportFilterCustomer(this.value);">None</TD>
			<TD></TD>
		</TR>
	</TABLE>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="1" WIDTH="90%">
	<TR>
		<TD COLSPAN="5" VALIGN="TOP">
		<HR COLOR="Orange" SIZE="1">
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="2" VALIGN="TOP">		
		<strong>Report output Type</strong>
		<BR><INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="h"<cfif rReportOutputType EQ "h"> CHECKED</cfif>>HTML
		 <INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="e"<cfif rReportOutputType EQ "e"> CHECKED</cfif>>Excel
		 <INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="c"<cfif rReportOutputType EQ "c"> CHECKED</cfif>>CSV
		</TD>
		<TD VALIGN="TOP">		
		<cfoutput>
		<table cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td><B>Start Date</B>
			<SELECT NAME="rOutputStartDateOperator" STYLE="WIDTH:45px">
				<CFSET cnt=0>
				<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
					<CFSET cnt=cnt+1>
					<OPTION VALUE="#Trim(thisOperator)#"<CFIF rOutputStartDateOperator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
				</CFLOOP>
			</SELECT>
			<span id="err_Start_Date_End_date"></span>
			</td>
			<td rowspan="2" width="10"></td>
			<td><B>End Date</B>
			<SELECT NAME="rOutputEndDateOperator" STYLE="WIDTH:45px">
				<CFSET cnt=0>
				<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
					<CFSET cnt=cnt+1>
					<OPTION VALUE="#Trim(thisOperator)#"<CFIF rOutputEndDateOperator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
				</CFLOOP>
			</SELECT>
			</td>
		</tr>
		<tr>
			<td>
			<CF_EASYDATE 
				FORMNAME="#thisFormName#" 
				FIELDNAME="rOutputStartDate" 
				FORMAT="mm/dd/yyyy" 
				DEFAULT="#rOutputStartDate#">
			</td>
			<td>
			<CF_EASYDATE 
				FORMNAME="#thisFormName#" 
				FIELDNAME="rOutputEndDate" 
				FORMAT="mm/dd/yyyy" 
				DEFAULT="#rOutputEndDate#">
			</td>
		</tr>
		</table>
		</cfoutput>
		</TD>
		<TD VALIGN="TOP">	
		<strong>Group By</strong></TD>
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
		<TD COLSPAN="5" ALIGN="LEFT" VALIGN="TOP">
		<HR COLOR="Orange" SIZE="1">
		<cfif ListLen(fProgramColumnHeaderID,",") GT 0>		
			<cfif ListLen(fProgramColumnHeaderID,",") GTE ListLen(fProgramColumnHeaders,",")>
				<CFSET colLen=4>								
				<cfoutput>				
				<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" WIDTH="100%">				
				<COLGROUP>
				<COL SPAN="#colLen#" WIDTH="20%"></COL>
				</COLGROUP>
					<TR>
						<TD COLSPAN="100%">
						<span id="perror_ColumnHeader"></span>&nbsp;<strong>Select Colum Headers</strong>
						</TD>
					<cfset j=Val(1)>
						<!-----<TD STYLE="display:none">
					<cfloop index="i" list="#fProgramColumnHeaderID#" delimiters=",">
						<INPUT onClick="javascript:this.checked=true;" TYPE="checkbox" ID="rColumnHeaderID" NAME="rColumnHeaderID" VALUE="#i#" CHECKED>
					</cfloop>
						</TD>------->
					
					<cfif ListLen(vProgramColumnHeaderID,",") GTE ListLen(vProgramColumnHeaders,",")>
						<cfloop index="i" list="#vProgramColumnHeaderID#" delimiters=",">						
							<cfif (j MOD colLen) EQ 1>
								</TR>
								<TR>
							</cfif>
							<TD>
							<INPUT TYPE="checkbox" ID="rColumnHeaderID" NAME="rColumnHeaderID" VALUE="#i#"<cfif ListFindNoCase(rColumnHeaderID,i,",")> CHECKED</cfif>> #ListGetAt(vProgramColumnHeaders,ListFindNoCase(vProgramColumnHeaderID,i,","),",")#
							</TD>
							<cfset j=j+1>
						</cfloop>
					</cfif>
					</TR>
				</TABLE>
				</cfoutput>
			</cfif>
		</cfif>
		<INPUT TYPE="hidden" ID="rReportType" NAME="rReportType" VALUE="<CFOUTPUT>#reportType#</CFOUTPUT>">
		</TD>
	</TR>	
	</TABLE>
	<!------ 
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
		<CFSET repType="r">
		<CFINCLUDE TEMPLATE="#reportTemplatePage#">		
		</CF_openLayer>
		 ----->
	<br>
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
