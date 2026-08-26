<!--- Make sure that the ranking is set --->
<cfinclude template="initial_check.cfm">

<cfparam name="form.ExistingProductList" default="">
<cfparam name="form.Product_List" default="">
<cfparam name="form.Distributor_List" default="">
<cfparam name="form.Distributor_level" default="">
<cfparam name="form.Family_Name" default="0">
<cfparam name="form.Buying_Group" default="0">
<cfparam name="form.page" default="">
<cfparam name="form.Is_Alias" default="">

<!--- Make sure the request is from this page only, else set the form values to blank --->
<cfif form.page neq "CreateFile">
   <cfset form.Distributor_level = "">
   <cfset form.distributor_list = "">
   <cfset form.Family_Name = "0">
   <cfset form.Buying_Group = "0">
   <cfset form.Product_List = "">
</cfif>

<cfoutput>
<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Create File Product Alias Management</LEGEND>
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
	
	<cfquery name="variables.GetDistributorInfo" datasource="#application.datasource#">
	select name, shr_ship_to
	FROM BSA_Foodservice_Customers
	WHERE BSA_Foodservice_Customers_ID IN(<cfqueryparam value="#form.distributor_list#" cfsqltype="CF_SQL_VARCHAR" list="true">)
	</cfquery>
	
	<cfif variables.GetDistributorInfo.recordcount eq 1>
		<strong>Selected #DistributorSingularLabel#:</strong>:
		#variables.GetDistributorInfo.name# (#variables.GetDistributorInfo.shr_ship_to#)
	<cfelse>
		<strong>Selected #DistributorPluralLabel#:</strong>
		#variables.GetDistributorInfo.recordcount#
	</cfif>
</cfif>
</span>

<!--- SEARCH FAMILY --->
<span id="Family_ID" <cfif form.Distributor_level eq 2>style="display:block;"<cfelse>style="display:none;"</cfif>>
<cfmodule 	template="/Customtags/DistributorGroupDropDown.cfm"
	groupLevelType = "2"
	dropDownName = "Family_Name"
	selectedValue = "#form.Family_Name#"
	cachedwithin="#APPLICATION.masterDataCacheSpan#"
	usepopup="0"
	OnChange = "showDistributorSearch()"
	/>
</span>

<!--- SEARCH BUYING GROUP --->
<span id="Buying_Group_ID" <cfif form.Distributor_level eq 3>style="display:block;"<cfelse>style="display:none;"</cfif>>
<cfmodule 	template="/Customtags/DistributorGroupDropDown.cfm"
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
<span id="Alias_Info" <cfif form.Distributor_level neq "">style="display:block;"<cfelse>style="display:none;"</cfif>>
<b>Alias Exists</b>
   <select name="Is_Alias">
    <option value="0" <cfif form.Is_Alias eq 0>selected</cfif>>Show All</option>
    <option value="1" <cfif form.Is_Alias eq 1>selected</cfif>>No</option>
   </select>
</span>
</td>
</tr>

<tr>
<td>
<!--- SEARCH PRODUCTS --->
<span id="Search_Products_ID" <cfif form.Distributor_level neq "">style="display:block;"<cfelse>style="display:none;"</cfif>>
<CF_smallLink 
	title = "search products" 
	url = "##"
	parameters = "onClick=""showProductSearchWindow();return false;""">
<strong>Selected products:</strong> #ListLen(Product_List)#
</span>
</td>
</tr>
</table>


<INPUT NAME="Distributor_List" TYPE="hidden"  value="#form.Distributor_List#">
<INPUT NAME="ExistingProductList" TYPE="hidden"  value="#form.Product_List#">
<INPUT NAME="Product_List" TYPE="hidden"  value="#form.Product_List#">
<INPUT NAME="Page" TYPE="hidden"  value="CreateFile">

<table align="center">
<tr>
<td>
<span id="Create_CSV_ID" <cfif len(trim(form.product_list)) GT 0>style="display:block;"<cfelse>style="display:none;"</cfif>>
<CF_button
	button_name	=	"save"
	button_caption	=	"Create CSV file"
	button_action	=	"javascript:submitDataFormCommand('Create_File');"
	button_type	=	"javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip	=	""
	font_color	=	"White"
	font_size	=	"12"
	font_weight	=	"bold"
>
</span>
</td>
</tr>
</table>
</FIELDSET>
</cfoutput>