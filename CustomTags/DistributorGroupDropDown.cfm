<cfsetting enablecfoutputonly="Yes" />
<!---
Document		:	/Customtags/DistributorGroupDropDown.cfm
Author			:	Deepa Kunnath
Date Created	:	April 07, 2005
Purpose			:	Common file to display the drop down for distributor groups (Family, Buying Group etc.)
Arguments		:	See below
Called from		: 
					/Common_Files/contracts/select_distributors.cfm
					/customtags/DistributorGroupPopUp.cfm

This is how u use it for family drop down

<cfmodule 	template="/Customtags/DistributorGroupDropDown.cfm"
			groupLevelType = "2"
			dropDownName = "Family_Name"
			selectedValue = "#FORM.Family_Name#"
			usepopup="0"
			/>

groupLevelType comes from distributor_group_level table
** Dev Note :: D8689 [mws] added recordcount check to load the drop down in a popup if more than 1000 records.
** "Usepopup" param (0 or 1)in call will determini if the feature is used or not
--->
<cfparam name="attributes.groupLevelType" 	default="0">
<cfparam name="attributes.businessSegmentId" 	default="0">
<cfparam name="attributes.cachedwithin" 	default="#CreateTimeSpan(0, 0, 0, 0)#">
<CFPARAM NAME="attributes.usepopup" DEFAULT="0">
<CFPARAM NAME="attributes.formname" DEFAULT="MyForm">
<CFPARAM NAME="attributes.FirstParentID" Default="0" />
<CFPARAM NAME="attributes.TemplateFiltersID" Default="0" />

<cfif ThisTag.ExecutionMode EQ "start" AND thisTag.HasEndTag> 
	<cfif attributes.groupLevelType>
		<cfset DistributorGroupAttributeManager = CreateObject("component", "components.customer.group.DistributorGroupAttributeManager").init() />
		<cfset stGetGroupAttributeInfo = DistributorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = attributes.groupLevelType) />
		<cfset GetGroupValues = DistributorGroupAttributeManager.getDistributorGroupValues(
								DistributorGroupAttributeInfo 	= stGetGroupAttributeInfo,
								businessSegmentId				= attributes.businessSegmentId,
								cachedwithin					= attributes.cachedwithin,
                				TemplateID            			= attributes.FirstParentID,
								TemplateFiltersID            	= attributes.TemplateFiltersID) 
                />
		<cfoutput><B>#stGetGroupAttributeInfo.Label#</B><br>
		<cfif GetGroupValues.recordcount lt 1000 or attributes.usepopup eq 0>
			<select name="#attributes.dropDownName#" id="#attributes.dropDownName#" style="width: 200px;">
				<option value="0">**ALL** #stGetGroupAttributeInfo.Label#</option>
				<cfloop query="GetGroupValues"><OPTION VALUE="#Group_ID#"<cfif attributes.selectedValue EQ Group_ID> SELECTED</cfif>>#Group_Name#</OPTION></cfloop>
			</select>
		<cfelse>
			<cfif attributes.selectedValue neq 0>
				<cfset GetTheGroup = DistributorGroupAttributeManager.getDistributorGroupValues(
									DistributorGroupAttributeInfo 	= stGetGroupAttributeInfo,
									businessSegmentId				= attributes.businessSegmentId,
									groupid							= attributes.selectedValue,
									TemplateID            			= attributes.FirstParentID,
									TemplateFiltersID            	= attributes.TemplateFiltersID) 
                  />
				<cfset theName = GetTheGroup.Group_Name>
			<cfelse>
				<cfset theName = "**ALL** #stGetGroupAttributeInfo.Label#">
			</cfif>
			<CFPARAM NAME="Group_ID" DEFAULT="#attributes.selectedValue#">
			<span id="span_#attributes.dropDownName#" style="WIDTH:190px; border:2px solid gray; font-size: 11px; vertical-align: top;">#theName#</SPAN><A HREF="javascript: void(0);" onClick="javaScript: show#attributes.dropDownName#();"><IMG border="0" src="/images/searchtool.gif" title="click to select #stGetGroupAttributeInfo.Label#" <!--- width="20" height="20" --->></A><input type="hidden" name="#attributes.dropDownName#" value="#Group_ID#">
			<SCRIPT LANGUAGE="JavaScript">
			function show#attributes.dropDownName#() 
			{				
				NewWindow("/CustomTags/DistributorGroupPopUp.cfm?formname=#attributes.formname#&groupLevelType=#attributes.groupLevelType#&dropDownName=#attributes.dropDownName#&selectedValue=#attributes.selectedValue#&Group_Business_segment_id=#attributes.businessSegmentId#&title=#stGetGroupAttributeInfo.Label#", "searchwindow", 400, 200, "yes", "yes")
			}
			</SCRIPT>
		</cfif>		
		</cfoutput>		
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="No" />