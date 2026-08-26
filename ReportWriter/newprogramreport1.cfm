
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>


<body>
<CFSET rStatus="-1">
<CFSET rGenericTypes="-1">
<CFSET rFilterItems="none">
<CFSET rFamilys="">
<CFSET rBuyingGroups="">
<CFSET rDistributors="">
<CFSET rFilter="none">
<CFSET rZones="">
<CFSET rRegions="">
<CFSET rBrokers="">

<CFQUERY NAME="q_getStatus" datasource="#application.datasource#">
Select	Contract_Status_Type_ID,Contract_Status_Type_Desc
From 	Contract_Status_Types
Where	
	Contract_Status_Type_ID > 3
Order By Contract_Status_Type_ID
</CFQUERY>

<CFQUERY NAME="q_getGenericTypes" datasource="#application.datasource#">
Select	Generic_Type_ID, Generic_Type
From 	Generic_Type
Order By Generic_Type
</CFQUERY>
<CFQUERY NAME="q_getFamilys" datasource="#application.datasource#">
Select 	distinct f.family_ID,f.Family_Name
From	Distributor_Family f, customer_lob_active cla
Where	cla.family_ID=f.family_ID
		and f.Deleted=0
Order By f.Family_Name
</CFQUERY>
<CFQUERY NAME="q_getBuyingGroups" datasource="#application.datasource#">
Select 	distinct bg.Buying_Group_ID,bg.Buying_Group_Name
From	Distributor_Buying_Groups bg, customer_lob_active cla
Where	cla.buying_group_ID=bg.buying_group_ID
		and bg.Deleted=0 and bg.active_code='A'
Order By bg.Buying_Group_Name
</CFQUERY>

<CFQUERY NAME="q_getZones" datasource="#application.datasource#">
Select	distinct sz.Service_Zone_ID, sz.Zone_Name
From 	Service_Zones sz,broker_lob_active bla
Where	sz.Deleted=0
		and bla.Service_Zone_ID=sz.Service_Zone_ID
Order By sz.Zone_Name
</CFQUERY>

<CFQUERY NAME="q_getRegions" datasource="#application.datasource#">
Select	distinct sr.Service_Region_ID, sr.Region_Name
From 	Service_Regions sr,broker_lob_active bla
Where	sr.Deleted=0
		and bla.Service_Region_ID=sr.Service_Region_ID
Order By sr.Region_Name
</CFQUERY>

<FORM ACTION="newprogramreport_action.cfm" TARGET="_self" METHOD="post" NAME="rInvoiceProgramSummaryForm" ID="rProgramSummaryForm">
  <table width="100%" border="0">
    <tr> 
      <td rowspan="4" valign="top"><strong>Status</strong><br> <SELECT size="5" name="rStatus" multiple>
          <OPTION VALUE="-1" SELECTED> All -----------------------------------------</OPTION>
          <CFOUTPUT QUERY="q_getStatus"> 
            <OPTION VALUE="#q_getStatus.Contract_Status_Type_ID#">#q_getStatus.Contract_Status_Type_Desc#</OPTION>
          </CFOUTPUT> </SELECT> </td>
      <td>&nbsp;</td>
      <td valign="top" colspan="2"><!--- <strong>Geographic Filter</strong> ---></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><!--- <INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="zone"<cfif rFilter EQ "zone"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');">
        <CFOUTPUT>#application.returned_customer_setting.zone_label_singular#</CFOUTPUT> --->
        <!--- Zone --->
      </TD>
      <TD> <!--- <cfset selFound=false> <DIV ID="rFilterDIVzone"> 
          <SELECT size="1" name="rZones">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1"<cfif rZones EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- 
            All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getZones">
              <OPTION<cfif rZones EQ q_getZones.Service_Zone_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getZones.Service_Zone_ID#">#q_getZones.Zone_Name#</OPTION>
            </CFOUTPUT> 
          </SELECT>
        </DIV> ---></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><!--- <INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="region"<cfif rFilter EQ "region"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');">
        <CFOUTPUT>#application.returned_customer_setting.region_label_singular#</CFOUTPUT> --->
        <!--- Region --->
      </TD>
      <TD VALIGN="TOP"> <!--- <cfset selFound=false> <DIV ID="rFilterDIVregion"> 
          <SELECT size="1" name="rRegions">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1"<cfif rRegions EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- 
            All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getRegions">
              <OPTION<cfif rRegions EQ q_getRegions.Service_Region_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getRegions.Service_Region_ID#">#q_getRegions.Region_Name#</OPTION>
            </CFOUTPUT> 
          </SELECT>
        </DIV> ---></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><!--- <INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="broker"<cfif rFilter EQ "broker"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');">
        <CFOUTPUT>#application.returned_customer_setting.broker_label_singular#</CFOUTPUT> --->
        <!--- Broker --->
      </TD>
      <TD> <!--- <DIV ID="rFilterDIVbroker"> <CFOUTPUT> 
            <INPUT TYPE="HIDDEN" ID="rBrokers" NAME="rBrokers" VALUE="#rBrokers#"><IFRAME NAME="Broker_Frame" STYLE="WIDTH:250px;HEIGHT:20px;" ATOMICSELECTION="false" SRC="ShowBrokers.cfm?rBrokers=#rBrokers#" FRAMEBORDER="0" style="border: 0px none ##000000;" SCROLLING="No"></IFRAME> 
          </CFOUTPUT></DIV> ---></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><!--- <INPUT TYPE="radio" ID="rFilter" NAME="rFilter" VALUE="none"<cfif rFilter EQ "none"> CHECKED</cfif> onClick="javascript:setReportFilter(this.value,'r');">None ---></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td rowspan="4" valign="top"><strong>Program Generic Types</strong><br> 
        <SELECT size="5" name="rGenericTypes" multiple>
          <OPTION VALUE="-1" SELECTED>-- All -----------------------------------------</OPTION>
          <CFOUTPUT QUERY="q_getGenericTypes"> 
            <OPTION VALUE="#Generic_Type_ID#">#ReReplaceNoCase(Generic_Type, "trade", 
            application.returned_customer_setting.Trade_Label)#</OPTION>
          </CFOUTPUT> </SELECT></td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top"><strong>Customer Filter (This field will be 
        used for primary grouping)</strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td valign="top"><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="family"<cfif rFilterItems EQ "family"> CHECKED</cfif> onClick="javascript:setInvoiceReportFilterCustomer(this.value);"><CFOUTPUT>#application.returned_customer_setting.family_name_label_singular#</CFOUTPUT><!--- Family ---></TD>
			<TD>
		<cfset selFound=false>
		<DIV ID="rFilterItemDIVfamily">
		<SELECT size="1" name="rFamilys">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rFamilys EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getFamilys"><OPTION<cfif rFamilys EQ q_getFamilys.family_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getFamilys.family_ID#">#q_getFamilys.family_Name#</OPTION></CFOUTPUT>
		</SELECT>
		</DIV></TD>
      <TD> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="buyinggroup"<cfif rFilterItems EQ "buyingGroup"> CHECKED</cfif> onClick="javascript:setInvoiceReportFilterCustomer(this.value);"><CFOUTPUT>#application.returned_customer_setting.buying_group_label_singular#</CFOUTPUT><!--- Buying Group ---></TD>
			<TD>
		<cfset selFound=false>
		
		<DIV ID="rFilterItemDIVbuyinggroup">
		<SELECT size="1" name="rBuyingGroups">
				<OPTION VALUE=""></OPTION>
				<OPTION VALUE="-1"<cfif rBuyingGroups EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- All -----------------------------------------</OPTION>
				<CFOUTPUT QUERY="q_getBuyingGroups"><OPTION<cfif rBuyingGroups EQ q_getBuyingGroups.Buying_Group_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getBuyingGroups.Buying_Group_ID#">#q_getBuyingGroups.Buying_Group_Name#</OPTION></CFOUTPUT>
		</SELECT>		
		</DIV></TD>
      <TD>
       </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="distributor"<cfif rFilterItems EQ "distributor"> CHECKED</cfif> onClick="javascript:setInvoiceReportFilterCustomer(this.value);"><CFOUTPUT>#application.returned_customer_setting.distributor_label_singular#</CFOUTPUT><!--- Distributor ---></TD>
			<TD>
			<DIV ID="rFilterItemDIVdistributor">
			<CFOUTPUT>
			<INPUT TYPE="HIDDEN" ID="rDistributors" NAME="rDistributors" VALUE="#rDistributors#">
			<IFRAME NAME="Distributor_Frame" STYLE="WIDTH:250px;HEIGHT:20px;" ATOMICSELECTION="false" SRC="ShowDistributors.cfm?rDistributors=#rDistributors#" FRAMEBORDER="0" style="border: 0px none ##000000;" SCROLLING="No"></IFRAME>
			</CFOUTPUT></DIV></TD>
      <TD> </td>
    </tr>
    <tr> 
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top"><INPUT TYPE="radio" ID="rFilterItems" NAME="rFilterItems" VALUE="none" <cfif rFilterItems EQ "none"> CHECKED</cfif> onClick="javascript:setInvoiceReportFilterCustomer(this.value);">None</TD>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <TD VALIGN="TOP">&nbsp;</TD>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</TD>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <TD VALIGN="TOP"><strong>Start Date :</strong> <input name="StartDate" type="text" size="10"> 
        &nbsp; &nbsp; &nbsp; &nbsp; <strong>End Date :</strong> <input name="Enddate" type="text" size="10"></TD>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</TD>
      <td>&nbsp;</td>
    </tr>
  </table>
<br>
<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"show report"
			BUTTON_ACTION	=	"javascript:rInvoiceProgramSummaryForm.submit();"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
</form>
</body>
</html>
