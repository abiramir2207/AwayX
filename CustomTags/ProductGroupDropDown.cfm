<cfsetting enablecfoutputonly="Yes" />
<!---
Document		:	/Customtags/ProductGroupDropDown .cfm
Author			:	Deepa Kunnath
Date Created	:	Jan 26, 2005
Purpose			:	Common file to display the drop down for product groups (Q Brand, Type Code, Type Group, Brand etc.)
Arguments		:	See below
Called from		: 
					/Common_Files/contracts/product_select_v1.cfm

This is how u use it for brand drop down

<cfmodule 	template="/Customtags/ProductGroupDropDown.cfm"
			groupLevelType = "7"
			dropDownName = "Brand_ID"
			selectedValue = "#FORM.Brand_ID#"
			productGroupFilterBusinessSegmentId = "#productGroupFilterBusinessSegmentId#"
			restrictOnProductGroup = "#restrictOnProductGroup#"
			approvalGroupLevelTypeVar = "approvalGroupType.groupLevelType" />

groupLevelType comes from product_group_level table
--->

<cfparam name="attributes.groupLevelType" 	default="0">
<cfparam name="attributes.dropDownName" 	default="">
<cfparam name="attributes.selectedValue" 	default="">
<cfparam name="attributes.productGroupFilterBusinessSegmentId" 	default="0">
<cfparam name="attributes.restrictOnProductGroup" 		default="0">
<cfparam name="attributes.approvalGroupLevelTypeVar" 	default="">
<cfparam name="attributes.cachedwithin" 	default="#CreateTimeSpan(0, 0, 0, 0)#">
<CFPARAM NAME="attributes.FirstParentID" 	Default="0" />
<cfparam name="attributes.groupLevelID" 	default="0">
<cfparam name="attributes.programID" 		default="" />
<cfparam name="attributes.TemplateFiltersID" default="0" />

<cfif ThisTag.ExecutionMode EQ "start" AND thisTag.HasEndTag> 
<cfif attributes.groupLevelType>

	<cfset approvalGroupLevelType = "" />
	<cfset restrictOnProductGroupList = "" />
	<cfif attributes.restrictOnProductGroup AND isDefined("caller.#attributes.approvalGroupLevelTypeVar#")>
		<cfset approvalGroupLevelType = Evaluate("caller.#attributes.approvalGroupLevelTypeVar#") />
		<cfset restrictOnProductGroupList = Evaluate("caller.restrictOnProductGroupList") />
	</cfif>
	
	<cfset restrictOnGroupList = 0 />
	<cfset restrictOnGroupListValue = "" />
	<cfif attributes.restrictOnProductGroup AND approvalGroupLevelType EQ attributes.groupLevelType>
		<cfset restrictOnGroupList = 1 />
		<cfset restrictOnGroupListValue = ListAppend(restrictOnGroupListValue, restrictOnProductGroupList, ",") />
	</cfif>
	
	<cfif isDefined("caller.restrictOnProductGroup_#attributes.groupLevelType#")>
		<cfset restrictOnProductGroup = Evaluate("caller.restrictOnProductGroup_#attributes.groupLevelType#") />	
		<cfset thisArrayProductGroupSelection = caller.arrayProductGroupSelection[restrictOnProductGroup] />
		<cfset restrictOnGroupList = 1 />	
		<cfset restrictOnGroupListValue = ListAppend(restrictOnGroupListValue, thisArrayProductGroupSelection.Group_ID, ",") />
	</cfif>
					
	<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
 
 <cfif attributes.groupLevelID EQ 0>
 <cfset qGroupTypeInfo = ProductGroupAttributeManager.getGroupTypeInfo(groupLevelTypeId = attributes.groupLevelType) /><!---  this was earlier groupLevelTypeId on the LHS in the function argument --->
 <cfelse>
	<cfset qGroupTypeInfo = ProductGroupAttributeManager.getGroupTypeInfo(groupLevelId = attributes.groupLevelId) /><!---  this was earlier groupLevelTypeId on the LHS in the function argument --->
 </cfif> 	 
   
	<cfset GetGroupValues = ProductGroupAttributeManager.getProductGroupValues(
							productGroupType 	= qGroupTypeInfo, 
							groupList 			= restrictOnGroupListValue, 
							restrictOnGroupList = restrictOnGroupList,
							businessSegmentId 	= attributes.productGroupFilterBusinessSegmentId,
							cachedwithin		= attributes.cachedwithin,
              				TemplateID      	= attributes.FirstParentID,
              				programID       	= attributes.programID,
							TemplateFiltersID 	= attributes.TemplateFiltersID) />
	
	<cfoutput><B>#qGroupTypeInfo.Label#</B><BR>
	<select name="#attributes.dropDownName#" id="#attributes.dropDownName#">
		<option value="0">**All** #qGroupTypeInfo.Label#</option>
		<cfloop query="GetGroupValues"><OPTION VALUE="#Group_ID#"<cfif attributes.selectedValue EQ Group_ID> SELECTED</cfif>>#Group_Name#</OPTION></cfloop>
	</select></cfoutput>
</cfif>
</cfif>
<cfsetting enablecfoutputonly="No" />