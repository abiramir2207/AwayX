<cfparam name="form.Shr_Ship_To" default="">
<cfparam name="form.Item" default="">
<cfparam name="form.Buying_Group" default="">
<cfparam name="form.Family_Name" default="">
<cfparam name="form.sort_by"  default="Item">
<cfparam name="form.page" default="">

<!--- For paging (Start) --->
<cfparam name="form.sort_order"  default="ASC">
<cfparam name="form.startrow"  default="1">
<cfparam name="form.pageLength"  default=25>
<cfparam name="form.frompage"   default="1">
<!--- For paging (End) --->

<!--- Make sure the request is from this page only, else set the form values to blank --->
<cfif form.page neq "SearchAlias">
   <cfset form.Shr_Ship_To = "">
   <cfset form.Family_Name = "0">
   <cfset form.Buying_Group = "0">
</cfif>
   
<cfoutput>
<FIELDSET STYLE="padding:10px; width: 83%; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Search Product Alias Management</LEGEND>
<table border="0" align="center">
<tr>
 <!--- SEARCH ITEM --->
 <td><b>#ItemSingularlabel#<b>
  <input size="10" type="text" name="Item" value="#form.Item#">
 </td>

 <!--- SEARCH SHIP TO --->
 <td><span id="error_Distributor"></span><b>#ShipToSingularlabel#<b>
  <input size="10" type="text" name="Shr_Ship_To" value="#form.Shr_Ship_To#">
 </td>

 <!--- SEARCH FAMILY --->
 <td><span id="error_Family"></span>
	<cfmodule template="/Customtags/DistributorGroupDropDown.cfm"
	groupLevelType = "2"
	dropDownName = "Family_Name"
	selectedValue = "#form.Family_Name#"
	cachedwithin="#APPLICATION.masterDataCacheSpan#"
	usepopup="0"
	/>
</td>

<!--- SEARCH BUYING GROUP --->
<td><span id="error_BuyingGroup"></span>
<cfmodule template="/Customtags/DistributorGroupDropDown.cfm"
	groupLevelType = "3"
	dropDownName = "Buying_Group"
	selectedValue = "#form.Buying_Group#"
	cachedwithin="#APPLICATION.masterDataCacheSpan#"
	usepopup="0"
	/>
</td>
</tr>

<tr>
<td colspan="100%" align="center">
<CF_button
	button_name	=""
	button_caption	="search"
	button_action	="javascript:submitDataFormCommand('Search');"
	button_type	= "javascript_link"
	button_width	="100"
	button_color	="Navy"
	button_tip	=""
	font_color	="White"
	font_size	="12"
	font_weight	="bold"
>
</td>
</tr>
</table>
</FIELDSET>
</cfoutput>

<!--- This is when user visits the page. The query is NULL --->
<cfif Not IsDefined("variables.qgetSearchResults")>
	<cfset variables.qgetSearchResults = QueryNew("Distributor_Product_Number")>
</cfif>

<cfif form.Shr_Ship_To eq "">
 <cfset DistributorLabel = DistributorSingularLabel>
<cfelseif form.Family_Name eq "">
 <cfset DistributorLabel = FamilySingularlabel>
<cfelseif form.Buying_Group eq "">
 <cfset DistributorLabel = BuyingGroupSingularlabel>
</cfif>

<CFIF sort_order eq "ASC">
	<CFSET new_sort_order = "DESC">
	<CFSET sortImage="up_1.gif">
<CFELSE>
	<CFSET sortImage="down_1.gif">
	<CFSET new_sort_order = "ASC">
</CFIF>

<cfoutput>
<input type="hidden" name="sort_by" value="#form.sort_by#">
<input type="hidden" name="sort_order" value="#form.sort_order#">
<input type="hidden" name="startrow" value="#startrow#">
<input type="hidden" name="frompage" value="#frompage#">
</cfoutput>
<INPUT NAME="Page" TYPE="hidden"  value="SearchAlias">


<CFSET startrow=FORM.startrow>
<CFSET frompage=FORM.frompage>
<cf_Number_of_Rows maxrows="#FORM.pageLength#">

<FIELDSET STYLE="padding:10px; width: 83%; border: 1px solid Blue;">

<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF variables.qgetSearchResults.recordcount EQ 1>is <CFELSE>Are</CFIF> <CFOUTPUT>#variables.qgetSearchResults.recordcount#</CFOUTPUT> 
	<CFIF variables.qgetSearchResults.recordcount EQ 1>Alias<CFELSE>Aliases</CFIF> That <CFIF variables.qgetSearchResults.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Supplied Criteria
</LEGEND>

<cfif  variables.qgetSearchResults.recordcount GT 0>
<table width="78%" border="0">

<cfoutput>
  <tr>
   <td width="10%"><a href="##" onClick="return submitDataFormCommandSort('Sort','Item','#new_sort_order#')"><b>#ItemSingularlabel#</b><cfif sort_by eq "Item"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></td>
   <td width="19%"><a href="##" onClick="return submitDataFormCommandSort('Sort','Distributor_Product_Number','#new_sort_order#')"><b>#DistributorSingularLabel# Alias #ItemSingularlabel#</b><cfif sort_by eq "Distributor_Product_Number"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></td>
   <td width="19%"><a href="##" onClick="return submitDataFormCommandSort('Sort','Distributor_Group_Level_ID','#new_sort_order#')"><b>#DistributorSingularLabel# level</b><cfif sort_by eq "Distributor_Group_Level_ID"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></td>
   <td width="30%"><a href="##" onClick="return submitDataFormCommandSort('Sort','Distributor_Name','#new_sort_order#')"><b>Name</b><cfif sort_by eq "Distributor_Name"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></td>
  </tr>
</cfoutput>

<cfoutput query="qgetSearchResults" startrow="#StartRow#" maxrows="#MaxRows#">
  <tr>
   <td>#Item#</td>
   <td>#Distributor_Product_Number#</td>
   <td>#Distributor_Group_Level#</td>
   <td>#Distributor_Name# (#Distributor_ID#)</td>
  </tr>
</cfoutput>

</table>
</cfif>

</FIELDSET>

<!--- PAGING --->
<CFIF variables.qgetSearchResults.recordcount GT 0>
<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
&nbsp;&nbsp;&nbsp;<CF_Next_Previous_For_Forms
	formname="DataForm"
	query="variables.qgetSearchResults"
	maxpages="40"
	previous="<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next="<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries="<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	addparams="">
</DIV>
</cfif>






	
	

