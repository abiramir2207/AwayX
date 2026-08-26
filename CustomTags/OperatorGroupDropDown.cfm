<!-----------------------------------------------------------------------------

FILE NAME:		/Customtags/OperatorGroupDropDown.cfm
DESCRIPTION:		Common file to display the drop down for Operator groups (Currently Planning Groups alone)
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		    DESCRIPTION OF CHANGE
Anand Rao	                  08-Feb-2011	Created

------------------------------------------------------------------------------> 

<cfsetting enablecfoutputonly="Yes" />

<cfparam name="attributes.groupLevelType" 	default="0">
<cfparam name="attributes.businessSegmentId" 	default="0">
<cfparam name="attributes.cachedwithin" 	default="#CreateTimeSpan(0, 0, 0, 0)#">
<CFPARAM NAME="attributes.usepopup" DEFAULT="0">
<CFPARAM NAME="attributes.formname" DEFAULT="MyForm">
<CFPARAM NAME="attributes.FirstParentID" Default="0" />

<cfif ThisTag.ExecutionMode EQ "start" AND thisTag.HasEndTag> 
	<cfif attributes.groupLevelType>
		<cfset OperatorGroupAttributeManager = CreateObject("component", "components.operator.group.OperatorGroupAttributeManager").init() />
		<cfset stGetGroupAttributeInfo = OperatorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = attributes.groupLevelType) />
		<cfset GetGroupValues = OperatorGroupAttributeManager.getOperatorGroupValues(
								OperatorGroupAttributeInfo 	= stGetGroupAttributeInfo,
								businessSegmentId				= attributes.businessSegmentId,
								cachedwithin					= attributes.cachedwithin,
                TemplateID            = attributes.FirstParentID) 
                />
		<cfoutput><B>#stGetGroupAttributeInfo.Label#</B>
		<cfif GetGroupValues.recordcount lt 1000 or attributes.usepopup eq 0>
			<select name="#attributes.dropDownName#" style="width: 200px;">
				<option value="0">**ALL** #stGetGroupAttributeInfo.Label#</option>
				<cfloop query="GetGroupValues"><OPTION VALUE="#Group_ID#"<cfif attributes.selectedValue EQ Group_ID> SELECTED</cfif>>#Group_Name#</OPTION></cfloop>
			</select>
		<cfelse>
			<cfif attributes.selectedValue neq 0>
				<cfset GetTheGroup = OperatorGroupAttributeManager.getOperatorGroupValues(
									OperatorGroupAttributeInfo 	= stGetGroupAttributeInfo,
									businessSegmentId				= attributes.businessSegmentId,
									groupid							= attributes.selectedValue,
                  TemplateID            = attributes.FirstParentID) 
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
				NewWindow("/CustomTags/OperatorGroupPopUp.cfm?formname=#attributes.formname#&groupLevelType=#attributes.groupLevelType#&dropDownName=#attributes.dropDownName#&selectedValue=#attributes.selectedValue#&Group_Business_segment_id=#attributes.businessSegmentId#&title=#stGetGroupAttributeInfo.Label#", "searchwindow", 400, 200, "yes", "yes")
			}
			</SCRIPT>
		</cfif>		
		</cfoutput>		
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="No" />