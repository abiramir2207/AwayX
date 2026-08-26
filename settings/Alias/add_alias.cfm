<!--- Make sure that the ranking is set --->
<cfinclude template="initial_check.cfm">

<cfparam name="form.ExistingProductList" default="">
<cfparam name="form.DeleteProductList" default="">
<cfparam name="form.Product_List" default="">
<cfparam name="form.Distributor_List" default="">
<cfparam name="form.Distributor_level" default="">
<cfparam name="form.Family_Name" default="0">
<cfparam name="form.Buying_Group" default="0">
<cfparam name="form.page" default="">

<!--- Make sure the request is from this page only, else set the form values to blank --->
<cfif form.page neq "AddAlias">
   <cfset form.Distributor_level = "">
   <cfset form.distributor_list = "">
   <cfset form.Family_Name = "0">
   <cfset form.Buying_Group = "0">
   <cfset form.Product_List = "">
</cfif>

<cfoutput>
<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Add/Edit Product Alias Management</LEGEND>
<table border="0" align="center">
<tr>
<td>
<!--- DISTRIBUTOR LEVEL --->
<b>Select #DistributorSingularLabel# level:<b>
<select name="Distributor_level" id="Distributor_level_id" OnChange="showDistributorSearch()">
    <option value="">NONE SELECTED</option>
    <option value="0" <cfif form.Distributor_level eq 0>selected</cfif>>#DistributorSingularLabel#</option>
    <cfloop query="variables.qgetDistributorGroupLevels">
	<option value="#Distributor_Group_Level_ID#" <cfif form.Distributor_level eq Distributor_Group_Level_ID> selected</cfif>>#Group_Level_Desc#</option>
    </cfloop>
</select>
</td>
</tr>

<tr>
<td>
<!--- SEARCH DISTRIBUTOR --->
<span id="Distributor_ID" <cfif len(trim(form.distributor_list)) GT 0 AND form.Distributor_level eq 0>style="display:block;"<cfelse>style="display:none;"</cfif>>
<CF_smallLink
	title = "search #DistributorSingularLabel#"
	url = "##"
	parameters = "onClick=""showDistributorSearchWindow();return false;""">

<!--- SELECTED DISTRIBUTOR --->
<cfif len(trim(form.distributor_list)) GT 0 AND form.Distributor_level eq 0>
	<strong>Selected #DistributorSingularLabel#:</strong>

	<cfquery name="variables.GetDistributorInfo" datasource="#application.datasource#">
	select name, shr_ship_to
	FROM BSA_Foodservice_Customers
	WHERE BSA_Foodservice_Customers_ID = <cfqueryparam value="#form.distributor_list#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	#variables.GetDistributorInfo.name# (#variables.GetDistributorInfo.shr_ship_to#)
</cfif>
</span>

<!--- SEARCH FAMILY --->
<span id="Family_ID" <cfif trim(form.Family_Name) neq 0 AND form.Distributor_level eq 2>style="display:block;"<cfelse>style="display:none;"</cfif>>
<cfmodule template="/Customtags/DistributorGroupDropDown.cfm"
	groupLevelType = "2"
	dropDownName = "Family_Name"
	selectedValue = "#form.Family_Name#"
	cachedwithin="#APPLICATION.masterDataCacheSpan#"
	usepopup="0"
	OnChange = "showDistributorSearch()"
	/>
</span>

<!--- SEARCH BUYING GROUP --->
<span id="Buying_Group_ID" <cfif trim(form.Buying_Group) neq 0  AND form.Distributor_level eq 3>style="display:block;"<cfelse>style="display:none;"</cfif>>
<cfmodule template="/Customtags/DistributorGroupDropDown.cfm"
	groupLevelType = "3"
	dropDownName = "Buying_Group"
	selectedValue = "#form.Buying_Group#"
	cachedwithin="#APPLICATION.masterDataCacheSpan#"
	usepopup="0"
	OnChange = "showDistributorSearch()"
	/>
</span>
</td>
</tr>

<tr>
<td>
<!--- SEARCH PRODUCTS --->
<span id="Search_Products_ID" <cfif len(trim(form.distributor_list)) GT 0 OR trim(form.Family_Name) neq 0 OR trim(form.Buying_Group) neq 0>style="display:block;"<cfelse>style="display:none;"</cfif>>
<CF_smallLink
	title = "search products"
	url = "##"
	parameters = "onClick=""showProductSearchWindow();return false;""">
</span>
</td>
</tr>
</table>

<cfif form.Distributor_level eq 0>
	<cfset variables.Distributor_ID = form.Distributor_List>
<cfelseif form.Distributor_level eq 2>
	<cfset variables.Distributor_ID = form.Family_Name>
<cfelseif form.Distributor_level eq 3>
	<cfset variables.Distributor_ID = form.Buying_Group>
</cfif>

<!--- WHEN THE PRODUCTS ARE SELECTED --->
<cfif len(trim(form.Product_List)) GT 0>
<cfquery name="GetProductInfo" datasource="#application.datasource#">
SELECT bfim.item,bfim.bsa_foodservice_items_master_id,amp.Distributor_Product_Number
FROM bsa_foodservice_items_master bfim
LEFT JOIN Alias_Management_Products amp
ON bfim.bsa_foodservice_items_master_id = amp.Product_ID
AND amp.Distributor_Group_Level_ID = <cfqueryparam value="#form.Distributor_Level#" cfsqltype="CF_SQL_INTEGER">
AND  amp.Distributor_ID = <cfqueryparam value="#variables.Distributor_ID#" cfsqltype="cf_sql_varchar">
WHERE bfim.bsa_foodservice_items_master_ID IN (<cfqueryparam value="#form.Product_List#" cfsqltype="CF_SQL_VARCHAR" list="yes">)
ORDER BY Item Desc
</cfquery>

<table align="center" border="0" cellspacing="0">
<tr>
 <td>
  <img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" title="delete all products in this page" border="0" onClick="if(confirm('Please confirm that you would like to DELETE all checked products!')){deleteAll('chk_');}" style="cursor: pointer;">
  <input type="checkbox" name="chkAll" id="chkAll" onClick="selectAll();" title="Click here to select all products">
 </td><br>
 <td><b>Item</b></td>
 <td><b>#DistributorSingularLabel# Product Number</b></td>
</tr>

<cfloop query="GetProductInfo">
<tr>
 <td>
  <img bDelete="true" id="theImage" name="IMG_Delete_Scissor" style="cursor: pointer;" onClick="deleteProduct('#bsa_foodservice_items_master_id#');" src="/Images/scissor.gif" width="14" height="9" title="Remove entry" border="0">
  <input type="checkbox" name="chk_#bsa_foodservice_items_master_id#" id="chk_#bsa_foodservice_items_master_id#" onClick="selectAll('#bsa_foodservice_items_master_id#');">
 </td>
 <td><input type="text" name="Item_#item#" value="#item#" size="30" disabled="true"></td>
 <td>
  <span id="error_Distributor_Product_Number_#bsa_foodservice_items_master_id#"></span>
  <input type="text" name="Distributor_Product_Number_#bsa_foodservice_items_master_id#" id="Distributor_Product_Number_#bsa_foodservice_items_master_id#" value="#Distributor_Product_Number#" size="60" maxlength="50">
 </td>
</tr>
</cfloop>
</table>
</cfif>

<INPUT NAME="Distributor_List" TYPE="hidden"  value="#form.Distributor_List#">
<!--- List of products to be deleted --->
<INPUT NAME="DeleteProductList" TYPE="hidden"  value="#form.DeleteProductList#">
<!--- "ExistingProductList" is required for the product pop up window --->
<INPUT NAME="ExistingProductList" TYPE="hidden"  value="#form.Product_List#">
<INPUT NAME="Product_List" TYPE="hidden"  value="#form.Product_List#">
<INPUT NAME="Page" TYPE="hidden"  value="AddAlias">

<table align="center">
<tr>
<td>
<span id="Save_ID"<cfif len(trim(form.product_list)) GT 0>style="display:block;"<cfelse>style="display:none;"</cfif>>
<CF_button
	button_name		=	"save"
	button_caption	=	"save"
	button_action	=	"javascript:AddAliasCompletion('Add');"
	button_type		= "javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>
</span>
</td>
</tr>
<tr>
 <td colspan="100%" align="center" ID="Updating" style="display:none;color:red">
  <b>UPDATING...</b>
 </td>
</tr>
</table>
</FIELDSET>
</cfoutput>
