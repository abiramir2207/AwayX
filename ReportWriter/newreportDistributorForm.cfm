<CFSET rStatus="-1">
<CFSET rBusinessSegment = "-1">
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
<CFSET rOperators="">
<CFSET startdate = "">
<CFSET enddate = "">
<CFSET rColumnHeaderID = "">

<!--- <cfoutput>#fProgramColumnHeaderID#
#vProgramColumnHeaderID#</cfoutput> --->
<CFSET rReportOutputType="h">
<!--- <CFSET rColumnHeaderID=ListAppend(fProgramColumnHeaderID,vProgramColumnHeaderID,",")> --->

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
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

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
	<CFSET startdate = Form.StartDate>
	<CFSET enddate = Form.EndDate>
	
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
	

<FORM ACTION="<cfoutput>#reportActionPage#</cfoutput>" TARGET="_self" METHOD="post" NAME="rProgramSummaryForm" ID="rProgramSummaryForm" style="display:inline;">
	
  <TABLE BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="90%">
    <tr valign="top"> 
      <td width="19%" rowspan="5" valign="top"><strong>Status</strong><br>
	  	<SELECT size="5" name="rStatus" multiple>
          <OPTION VALUE="-1"<cfif ListFindNoCase(rStatus,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
          <CFOUTPUT QUERY="q_getStatus"> 
            <OPTION<cfif ListFindNoCase(rStatus,q_getStatus.Contract_Status_Type_ID,",")> SELECTED</cfif> VALUE="#q_getStatus.Contract_Status_Type_ID#">#q_getStatus.Contract_Status_Type_Desc#</OPTION>
          </CFOUTPUT>
		</SELECT>
	  </td>
	  
	  <cfif businessSegEnabled>
      <td width="25%" rowspan="5">	  
	  <cfset qGetBusSegments = businessSegManager.getActive() />
	  <strong><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></strong><br>
	  <SELECT size="5" name="rBusinessSegment" multiple>
	  <OPTION VALUE="-1"<cfif ListFindNoCase(rBusinessSegment,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</OPTION>
	  	<cfoutput query="qGetBusSegments">
			<option value="#Business_Segment_ID#">#Business_Unit_Desc#</option>
		</cfoutput>
      </SELECT>
	  <cfelse>
	  <td width="15%" rowspan="5">
	  </cfif>
	  &nbsp;</td>
      <td colspan="2" valign="top"><span id="error_rFilter"></span>&nbsp;<strong>Geographic 
        Filter</strong></td>
    </tr>
    <tr> 
      <td width="14%" valign="top"><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="zone"<cfif rFilter EQ "zone"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');"> 
        <CFOUTPUT>#application.returned_customer_setting.zone_label_singular#</CFOUTPUT> 
        <!--- Zone --->
      </td>
      <td width="61%" valign="top"><cfset selFound=false> <DIV ID="rFilterDIVzone"> 
          <SELECT size="1" name="rZones">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1"<cfif rZones EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- 
            All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getZones"> 
              <OPTION<cfif rZones EQ q_getZones.Service_Zone_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getZones.Service_Zone_ID#">#q_getZones.Zone_Name#</OPTION>
            </CFOUTPUT> 
            <cfif NOT selFound AND rZones NEQ "-1" AND rZones NEQ "">
              <CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
              Select sz.Zone_Name,sz.Deleted ,(SELECT count(cfb1.Broker_Name) 
              FROM Service_Zones sz1,BSA_Foodservice_Brokers cfb1,Line_Of_Business 
              lob1 WHERE cfb1.Service_Zone_ID=sz1.Service_Zone_ID AND cfb1.Line_Of_Business_ID 
              = lob1.Line_Of_Business_ID AND cfb1.Deleted=0 AND cfb1.Active_Code='A' 
              AND lob1.Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, 
              "'", ",")#) AND sz1.Service_Zone_ID=sz.Service_Zone_ID) AS BROKERCOUNT 
              From Service_Zones sz Where sz.Service_Zone_ID='#rZones#' 
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
              <CFOUTPUT> 
                <OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION>
              </CFOUTPUT> 
            </cfif>
          </SELECT>
        </DIV></td>
    </tr>
    <tr> 
      <td width="14%" valign="top"><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="region"<cfif rFilter EQ "region"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');"> 
        <CFOUTPUT>#application.returned_customer_setting.region_label_singular#</CFOUTPUT> 
        <!--- Region --->
      </td>
      <td width="71%" valign="top"><cfset selFound=false> <DIV ID="rFilterDIVregion"> 
          <SELECT size="1" name="rRegions">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1"<cfif rRegions EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- 
            All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getRegions"> 
              <OPTION<cfif rRegions EQ q_getRegions.Service_Region_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getRegions.Service_Region_ID#">#q_getRegions.Region_Name#</OPTION>
            </CFOUTPUT> 
            <cfif NOT selFound AND rRegions NEQ "-1" AND rRegions NEQ "">
              <CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
              Select sr.Region_Name,sr.Deleted ,(SELECT count(cfb1.Broker_Name) 
              FROM Service_Regions sr1,BSA_Foodservice_Brokers cfb1,Line_Of_Business 
              lob1 WHERE cfb1.Service_Region_ID=sr1.Service_Region_ID AND cfb1.Line_Of_Business_ID 
              = lob1.Line_Of_Business_ID AND cfb1.Deleted=0 AND cfb1.Active_Code='A' 
              AND lob1.Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, 
              "'", ",")#) AND sr1.Service_Region_ID=sr.Service_Region_ID) AS BROKERCOUNT 
              From Service_Regions sr Where sr.Service_Region_ID='#rRegions#' 
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
              <CFOUTPUT> 
                <OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION>
              </CFOUTPUT> 
            </cfif>
          </SELECT>
        </DIV></td>
    </tr>
    <tr> 
      <td width="14%" valign="top"><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="broker"<cfif rFilter EQ "broker"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');"> 
        <CFOUTPUT>#application.returned_customer_setting.broker_label_singular#</CFOUTPUT> 
        <!--- Broker --->
      </td>
      <td width="71%" valign="top"><DIV ID="rFilterDIVbroker"> <CFOUTPUT> 
            <INPUT TYPE="HIDDEN" ID="rBrokers" NAME="rBrokers" VALUE="#rBrokers#"><IFRAME NAME="Broker_Frame" STYLE="WIDTH:250px;HEIGHT:20px;" ATOMICSELECTION="false" SRC="ShowBrokers.cfm?rBrokers=#rBrokers#" FRAMEBORDER="0" style="border: 0px none ##000000;" SCROLLING="No"></IFRAME> 
          </CFOUTPUT></DIV></td>
    </tr>
    <tr> 
      <td width="14%" valign="top"><INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="none"<cfif rFilter EQ "none"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');">
        None</td>
      <td width="71%" valign="top">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4" valign="top" style="border-top:1px solid Orange">&nbsp;</td>
    </tr>
    <tr valign="top"> 
      <td width="19%" rowspan="5" valign=""><strong>Program Generic Types</strong><br> 
        <select size="5" name="rGenericTypes" multiple>
          <option value="-1"<cfif ListFindNoCase(rGenericTypes,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</option>
          <cfoutput query="q_getGenericTypes"> 
            <option<cfif ListFindNoCase(rGenericTypes,Generic_Type_ID,",")> SELECTED</cfif> value="#Generic_Type_ID#">#ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label)#</option>
          </cfoutput> 
		</select>
	  </td>
	  
	  <cfif discountIdentifierManager.discountIdentifierOn()>	  
      <td width="25%" rowspan="5"><strong>Discount Identifier</strong><br>
	  <cfset qGetDiscountIdentifiers = discountIdentifierManager.getActive() />
	 <select size="5" name="rDiscountIdentifier" multiple>
           <option value="-1"<cfif ListFindNoCase(rDiscountIdentifier,"-1",",")> SELECTED</cfif>>-- All -----------------------------------------</option>
          <cfoutput query="qGetDiscountIdentifiers"> 
		  	<option<cfif ListFindNoCase(rDiscountIdentifier,Discount_Identifier_ID,",")> SELECTED</cfif> value="#Discount_Identifier_ID#">#Discount_Identifier_Desc#</option>
          </cfoutput>
		</select>
	  <cfelse>
      <td width="15%" rowspan="5">
	  </cfif>
	  &nbsp;</td>
      <td colspan="2"><span id="error_rFilterItems"></span>&nbsp;<strong>Customer 
        Filter (This field will be used for primary grouping)</strong></TD>
    </tr>
    <tr> 
      <td width="16%" valign="top"><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="family"<cfif rFilterItems EQ "family"> CHECKED</cfif> onClick="javascript:setReportFilterCustomer(this.value);"> 
        <CFOUTPUT>#application.returned_customer_setting.family_name_label_singular#</CFOUTPUT> 
        <!--- Family --->
      </td>
      <td width="65%" valign="top"><cfset selFound=false> <DIV ID="rFilterItemDIVfamily"> 
          <SELECT size="1" name="rFamilys">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1"<cfif rFamilys EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- 
            All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getFamilys">
              <OPTION<cfif rFamilys EQ q_getFamilys.family_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getFamilys.family_ID#">#q_getFamilys.family_Name#</OPTION>
            </CFOUTPUT> 
            <cfif NOT selFound AND rFamilys NEQ "-1" AND rFamilys NEQ "">
              <CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
              Select f.Family_Name,f.Deleted From Distributor_Family f Where f.family_ID='#rFamilys#' 
              </CFQUERY>
              <CFIF q_getThisFilter.recordCount GT 0>
                <CFSET thisFilter=q_getThisFilter.Family_Name>
                <CFIF q_getThisFilter.Deleted>
                  <CFSET thisFilter="DELETED - #thisFilter#">
                </CFIF>
                <CFELSE>
                <CFSET thisFilter="---Family NOT FOUND---">
              </CFIF>
              <CFOUTPUT>
                <OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION>
              </CFOUTPUT> 
            </cfif>
          </SELECT>
        </DIV></td>
    </tr>
    <tr> 
      <td width="16%" valign="top"><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="buyinggroup"<cfif rFilterItems EQ "buyingGroup"> CHECKED</cfif> onClick="javascript:setReportFilterCustomer(this.value);"> 
        <CFOUTPUT>#application.returned_customer_setting.buying_group_label_singular#</CFOUTPUT> 
        <!--- Buying Group --->
      </td>
      <td width="65%" valign="top"><cfset selFound=false> <DIV ID="rFilterItemDIVbuyinggroup"> 
          <SELECT size="1" name="rBuyingGroups">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1"<cfif rBuyingGroups EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- 
            All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getBuyingGroups">
              <OPTION<cfif rBuyingGroups EQ q_getBuyingGroups.Buying_Group_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getBuyingGroups.Buying_Group_ID#">#q_getBuyingGroups.Buying_Group_Name#</OPTION>
            </CFOUTPUT> 
            <cfif NOT selFound AND rBuyingGroups NEQ "-1" AND rBuyingGroups NEQ "">
              <CFQUERY NAME="q_getThisFilter" datasource="#application.datasource#">
              Select bg.Buying_Group_Name,bg.Deleted,bg.active_code From Distributor_Buying_Groups 
              bg Where bg.buying_group_ID='#rBuyingGroups#' 
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
              <CFOUTPUT>
                <OPTION SELECTED VALUE="" style="background-color=ff0000">#thisFilter#</OPTION>
              </CFOUTPUT> 
            </cfif>
          </SELECT>
        </DIV></td>
    </tr>
    <tr> 
      <td width="16%" valign="top"><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="distributor"<cfif rFilterItems EQ "distributor"> CHECKED</cfif> onClick="javascript:setReportFilterCustomer(this.value);"> 
        <CFOUTPUT>#application.returned_customer_setting.distributor_label_singular#</CFOUTPUT> 
        <!--- Distributor --->
      </td>
      <td width="65%" valign="top"><DIV ID="rFilterItemDIVdistributor"> <CFOUTPUT> 
            <INPUT TYPE="HIDDEN" ID="rDistributors" NAME="rDistributors" VALUE="#rDistributors#"><IFRAME NAME="Distributor_Frame" STYLE="WIDTH:250px;HEIGHT:20px;" ATOMICSELECTION="false" SRC="ShowDistributors.cfm?rDistributors=#rDistributors#" FRAMEBORDER="0" style="border: 0px none ##000000;" SCROLLING="No"></IFRAME> 
          </CFOUTPUT></DIV></td>
    </tr>
    <tr> 
      <td width="16%" valign="top"><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="operator"<cfif rFilterItems EQ "operator"> CHECKED</cfif> onClick="javascript:setReportFilterCustomer(this.value);"> 
        <CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT> 
        <!--- Distributor --->
      </td>
      <td width="65%" valign="top"><DIV ID="rFilterItemDIVoperator"> <CFOUTPUT> 
            <INPUT TYPE="HIDDEN" ID="rOperators" NAME="rOperators" VALUE="#rOperators#"><IFRAME NAME="Operator_Frame" STYLE="WIDTH:250px;HEIGHT:20px;" ATOMICSELECTION="false" SRC="ShowOperators.cfm?rOperators=#rOperators#" FRAMEBORDER="0" style="border: 0px none ##000000;" SCROLLING="No"></IFRAME> 
          </CFOUTPUT></DIV></td>
    </tr>
    <tr>
      <td valign="">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top"><input type="radio" id="radio16" name="rFilterItems" value="none"<cfif rFilterItems EQ "none"> CHECKED</cfif> onClick="javascript:setReportFilterCustomer(this.value);">
        None</td>
      <td valign="top">&nbsp;</td>
    </tr>
  </table>
  <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="1" WIDTH="90%">
    <TR> 
      <TD COLSPAN="4" VALIGN="TOP"> <HR COLOR="Orange" SIZE="1"> </TD>
    </TR>
    <TR> 
      <TD width="176" VALIGN="TOP"><strong>Start Date :</strong><span id="Report_Start_Date"></span><CF_EASYDATE FORMNAME="rProgramSummaryForm" FIELDNAME="StartDate" FORMAT="mm/dd/yyyy" REQUIRED="yes" DEFAULT=#StartDate#> 
        &nbsp; </TD>
      <TD width="205" VALIGN="TOP">&nbsp;<strong>End Date :<span id="Report_End_Date"></span></strong> 
        <CF_EASYDATE FORMNAME="rProgramSummaryForm" FIELDNAME="EndDate" FORMAT="mm/dd/yyyy" REQUIRED="yes" DEFAULT=#EndDate#> 
      </TD>
      <TD width="122" VALIGN="TOP"> <strong>Group By</strong></TD>
      <TD width="478" VALIGN="TOP"> <SELECT SIZE="1" NAME="rSortBy">
          <OPTION VALUE="-1"<cfif ListFindNoCase(rSortBy,"-1",",") EQ 1> SELECTED</cfif>>--Select ----</OPTION>
          <OPTION VALUE="status"<cfif ListFindNoCase(rSortBy,"status",",") EQ 1> SELECTED</cfif>>Status</OPTION>
          <OPTION VALUE="programtype"<cfif ListFindNoCase(rSortBy,"programtype",",") EQ 1> SELECTED</cfif>>Program 
          Types</OPTION>
        </SELECT> <BR> <SELECT SIZE="1" NAME="rSortBy">
          <OPTION VALUE="-1"<cfif ListFindNoCase(rSortBy,"-1",",") EQ 2> SELECTED</cfif>>--Select ----</OPTION>
          <OPTION VALUE="status"<cfif ListFindNoCase(rSortBy,"status",",") EQ 2> SELECTED</cfif>>Status</OPTION>
          <OPTION VALUE="programtype"<cfif ListFindNoCase(rSortBy,"programtype",",") EQ 2> SELECTED</cfif>>Program 
          Types</OPTION>
        </SELECT> </TD>
    </TR>
    <TR> 
      <TD colspan="2" VALIGN="TOP"> <strong>Report output Type</strong> <br> <input type="radio" id="radio" name="rReportOutputType" value="h"<cfif rReportOutputType EQ "h"> CHECKED</cfif>>
        HTML 
        <input type="radio" id="radio" name="rReportOutputType" value="e"<cfif rReportOutputType EQ "e"> CHECKED</cfif>>
        Excel 
        <input type="radio" id="radio" name="rReportOutputType" value="c"<cfif rReportOutputType EQ "c"> CHECKED</cfif>>
        CSV </TD>
    </TR>
    <TR> 
      <TD COLSPAN="4" ALIGN="LEFT" VALIGN="TOP"> <HR COLOR="Orange" SIZE="1"> 
	  	<cfif ListLen(fProgramColumnHeaderID,",") GT 0>
			<cfif ListLen(fProgramColumnHeaderID,",") GTE ListLen(fProgramColumnHeaders,",")>
				<CFSET colLen=4>								
				<cfoutput>	
	          	<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" WIDTH="100%">
	            <COLGROUP>
	            <COL SPAN="#colLen#" WIDTH="20%"></COL>
	            </COLGROUP>
	            <TR> 
	            <TD height="21" COLSPAN="100%"> <span id="perror_ColumnHeader"></span>&nbsp;<strong>Select 
	                Column Headers</strong> </TD>
	             <cfset j=Val(1)>
	             <cfif ListLen(vProgramColumnHeaderID,",") GTE ListLen(vProgramColumnHeaders,",")>
				 	<cfloop index="i" list="#vProgramColumnHeaderID#" delimiters=",">
						 <cfif (j MOD colLen) EQ 1>
			            	</TR>
			            	<TR> 
						  </cfif>
			              <TD> <INPUT TYPE="radio" ID="rColumnHeaderID" NAME="rColumnHeaderID" VALUE="#i#"<cfif ListFindNoCase(rColumnHeaderID,i,",")> CHECKED</cfif>>
			                #ListGetAt(vProgramColumnHeaders,ListFindNoCase(vProgramColumnHeaderID,i,","),",")# 
			              </TD>
			              <cfset j=j+1>
					 </cfloop>
					 <TD><INPUT TYPE="radio" ID="rColumnHeaderID" NAME="rColumnHeaderID" VALUE=""<cfif rColumnHeaderID EQ ""> CHECKED</cfif>>None</TD>
				  </cfif>
	            </TR>
	          	</TABLE>
	        	</cfoutput> 
			</cfif>
		</cfif> <INPUT TYPE="hidden" ID="rReportType" NAME="rReportType" VALUE="<CFOUTPUT>#reportType#</CFOUTPUT>"> 
      </TD>
    </TR>
  </TABLE>
 <INPUT type="Hidden" name="GenerateEmail" value="Email">
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
		<CFSET thisFormName="rProgramSummaryForm"> 
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
