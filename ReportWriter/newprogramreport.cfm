
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>


<body>
<CFSET rStatus="-1">
<CFSET rBusinessSegment = "-1">
<CFSET rDiscountIdentifier = "-1">
<CFSET rGenericTypes="-1">
<CFSET rFilterItems="none">
<CFSET rFamilys="">
<CFSET rBuyingGroups="">
<CFSET rDistributors="">
<CFSET pFilter="none">
<CFSET pTypeGroups="-1">
<CFSET pQBrands="-1">
<CFSET pTypeCodes="-1">
<CFSET pBrands="-1">

<CFQUERY NAME="q_getStatus" datasource="#application.datasource#">
Select	Contract_Status_Type_ID,Contract_Status_Type_Desc
From 	Contract_Status_Types
Where	
	Contract_Status_Type_ID > 3
Order By Contract_Status_Type_ID
</CFQUERY>

<cfset useLakebaseForq_getGenericTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("generic_type")>
<cfif useLakebaseForq_getGenericTypes>
	<cftry>
		<cfset q_getGenericTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("generic_type", {
				"order" = "generic_type.asc",
				"select" = "generic_type_id,generic_type"
			}), "generic_type_id,generic_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForq_getGenericTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForq_getGenericTypes>
<CFQUERY NAME="q_getGenericTypes" datasource="#application.datasource#">
Select	Generic_Type_ID, Generic_Type
From 	Generic_Type
Order By Generic_Type
</CFQUERY>
</cfif>
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

<cfinclude template="reportProductLookup.cfm">

<FORM ACTION="newprogramreport_action.cfm" TARGET="_blank" METHOD="post" NAME="InvoiceProgramSummaryForm" ID="InvoiceProgramSummaryForm">
  <table width="100%" border="0">
    <tr> 
      <td width="35%" rowspan="5" valign="top"><strong>Status</strong><br> <SELECT size="5" name="rStatus" multiple>
          <OPTION VALUE="-1" SELECTED> All -----------------------------------------</OPTION>
          <CFOUTPUT QUERY="q_getStatus"> 
            <OPTION VALUE="#q_getStatus.Contract_Status_Type_ID#">#q_getStatus.Contract_Status_Type_Desc#</OPTION>
          </CFOUTPUT> </SELECT> </td>
      <td width="50%" colspan=2><strong>Customer Filter (This field will be used 
        for primary grouping)</strong></td>
    </tr>
    <tr> 
      <td width="10%" nowrap><input type="radio" id="radio8" name="rFilterItems" value="family"<cfif rFilterItems EQ "family"> CHECKED</cfif> onClick="javascript:setInvoiceReportFilterCustomer(this.value);"> 
        <cfoutput>#application.returned_customer_setting.family_name_label_singular#</cfoutput> 
        <!--- Family --->
      </td>
      <td><cfset selFound=false> <DIV ID="rFilterItemDIVfamily"> 
          <SELECT size="1" name="rFamilys">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1"<cfif rFamilys EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- 
            All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getFamilys"> 
              <OPTION<cfif rFamilys EQ q_getFamilys.family_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getFamilys.family_ID#">#q_getFamilys.family_Name#</OPTION>
            </CFOUTPUT> 
          </SELECT>
        </DIV></td>
    </tr>
    <tr> 
      <td><input type="radio" id="radio9" name="rFilterItems" value="buyinggroup"<cfif rFilterItems EQ "buyingGroup"> CHECKED</cfif> onClick="javascript:setInvoiceReportFilterCustomer(this.value);"> 
        <cfoutput>#application.returned_customer_setting.buying_group_label_singular#</cfoutput> 
        <!--- Buying Group --->
      </td>
      <td><cfset selFound=false> <DIV ID="rFilterItemDIVbuyinggroup"> 
          <SELECT size="1" name="rBuyingGroups">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1"<cfif rBuyingGroups EQ "-1"> SELECTED<cfset selFound=true></cfif>>-- 
            All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getBuyingGroups"> 
              <OPTION<cfif rBuyingGroups EQ q_getBuyingGroups.Buying_Group_ID> SELECTED<cfset selFound=true></cfif> VALUE="#q_getBuyingGroups.Buying_Group_ID#">#q_getBuyingGroups.Buying_Group_Name#</OPTION>
            </CFOUTPUT> 
          </SELECT>
        </DIV></td>
    </tr>
    <tr> 
      <td><input type="radio" id="radio10" name="rFilterItems" value="distributor"<cfif rFilterItems EQ "distributor"> CHECKED</cfif> onClick="javascript:setInvoiceReportFilterCustomer(this.value);"> 
        <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> 
        <!--- Distributor --->
      </td>
      <td><DIV ID="rFilterItemDIVdistributor"> <CFOUTPUT> 
            <INPUT TYPE="HIDDEN" ID="rDistributors" NAME="rDistributors" VALUE="#rDistributors#"><IFRAME NAME="Distributor_Frame" STYLE="WIDTH:250px;HEIGHT:20px;" ATOMICSELECTION="false" SRC="ShowDistributors.cfm?rDistributors=#rDistributors#" FRAMEBORDER="0" style="border: 0px none ##000000;" SCROLLING="No"></IFRAME> 
          </CFOUTPUT></DIV></td>
    </tr>
    <tr> 
      <td><input type="radio" id="radio11" name="rFilterItems" value="none" <cfif rFilterItems EQ "none"> CHECKED</cfif> onClick="javascript:setInvoiceReportFilterCustomer(this.value);">
        None</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td rowspan="5" valign="top"><strong>Program Generic Types</strong><br> 
        <select size="5" name="rGenericTypes" multiple>
          <option value="-1" selected>-- All -----------------------------------------</option>
          <cfoutput query="q_getGenericTypes"> 
            <option value="#Generic_Type_ID#">#ReReplaceNoCase(Generic_Type, "trade", 
            application.returned_customer_setting.Trade_Label)#</option>
          </cfoutput> </select> </td>
      <td valign="top" colspan="2"><strong>Product Filter (This field will be 
        used for primary grouping)</strong></td>
    </tr>
    <tr> 
      <td valign="top"><INPUT TYPE="radio" ID="pFilter" NAME="pFilter" VALUE="qbrand" onClick="javascript:setInvoiceReportFilterProduct(this.value);"> 
        <CFOUTPUT>#application.returned_customer_setting.q_brand_label_singular#</CFOUTPUT></td>
      <td> <DIV ID="pFilterItemDIVqbrand"> 
          <SELECT size="1" name="pQBrands">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1">-- All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getQBrands"> 
              <OPTION VALUE="#q_getQBrands.Q_Brand_ID#">#q_getQBrands.Q_Brand#</OPTION>
            </CFOUTPUT> 
          </SELECT>
        </DIV></td>
    </tr>
    <tr> 
      <td><INPUT TYPE="radio" ID="pFilter" NAME="pFilter" VALUE="typegroup" onClick="javascript:setInvoiceReportFilterProduct(this.value);"> 
        <CFOUTPUT>#application.returned_customer_setting.type_group_label_singular#</CFOUTPUT></td>
      <td><DIV ID="pFilterItemDIVtypegroup"> 
          <SELECT size="1" name="pTypeGroups">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1">-- All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getTypeGroups"> 
              <OPTION VALUE="#q_getTypeGroups.Type_Group_Desc_ID#">#q_getTypeGroups.Type_Group_Desc#</OPTION>
            </CFOUTPUT> 
          </SELECT>
        </DIV></td>
    </tr>
    <tr> 
      <td><INPUT TYPE="radio" ID="pFilter" NAME="pFilter" VALUE="typecode" onClick="javascript:setInvoiceReportFilterProduct(this.value);"> 
        <CFOUTPUT>#application.returned_customer_setting.type_code_label_singular#</CFOUTPUT></td>
      <td><DIV ID="pFilterItemDIVtypecode"> 
          <SELECT size="1" name="pTypeCodes">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1">-- All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getTypeCodes"> 
              <OPTION VALUE="#q_getTypeCodes.Type_Code_Desc_ID#">#q_getTypeCodes.Type_Code_Desc#</OPTION>
            </CFOUTPUT> 
          </SELECT>
        </DIV></td>
    </tr>
    <tr> 
      <td><INPUT TYPE="radio" ID="pFilter" NAME="pFilter" VALUE="brand" onClick="javascript:setInvoiceReportFilterProduct(this.value);">
        Brand</td>
      <td><DIV ID="pFilterItemDIVbrand"> 
          <SELECT size="1" name="pBrands">
            <OPTION VALUE=""></OPTION>
            <OPTION VALUE="-1">-- All -----------------------------------------</OPTION>
            <CFOUTPUT QUERY="q_getBrands"> 
              <OPTION VALUE="#q_getBrands.Brand_ID#">#q_getBrands.Brand_Name#</OPTION>
            </CFOUTPUT> 
          </SELECT>
        </DIV></td>
    </tr>
    <tr> 
      <td><strong>Start Date :</strong> <input name="StartDate" type="text" size="10"> 
        &nbsp; </td>
      <td><INPUT TYPE="radio" ID="pFilter" NAME="pFilter" VALUE="none"<cfif pFilter EQ "none"> CHECKED</cfif> onClick="javascript:setInvoiceReportFilterProduct(this.value);">
        None</td>
    </tr>
    <tr> 
      <td><strong>End Date :</strong> &nbsp; <input name="Enddate" type="text" size="10"> 
      </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td> &nbsp; &nbsp; &nbsp; </td>
      <td valign="top"><strong>Group By</strong>: </td>
	  <td><select size="1" name="SortBy">
          <option value="Program" SELECTED>Programs</option>
          <option value="Customer">Customers</option>
        </select> <BR>
		<SELECT SIZE="1" NAME="SortBy">
          <option value="Program" >Programs</option>
          <option value="Customer" SELECTED>Customers</option>
		</SELECT> </td>
    </tr>
    <tr>
      <td>&nbsp; </td>
      <td>&nbsp;</td>
    </tr>
  </table>
<br>
<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"show report"
			BUTTON_ACTION	=	"javascript:InvoiceProgramSummaryForm.submit();"
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
