<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><cfoutput>#title# Selection</cfoutput></title>
</head>

<body>
<cfif isDefined("blnSubmit")>
	    <cfset DistributorGroupAttributeManager = CreateObject("component", "components.customer.group.DistributorGroupAttributeManager").init() />
		<cfset stGetGroupAttributeInfo = DistributorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = form.groupLevelType) />
		
			<cfif evaluate(form.dropDownName) neq 0>
				<cfset GetTheGroup = DistributorGroupAttributeManager.getDistributorGroupValues(
									DistributorGroupAttributeInfo 	= stGetGroupAttributeInfo,
									businessSegmentId				= form.GROUP_BUSINESS_SEGMENT_ID,
									groupid							= evaluate(form.dropDownName)) />
				<cfset theName = GetTheGroup.Group_Name>
			<cfelse>
				<cfset theName = "**ALL** #stGetGroupAttributeInfo.Label#">
			</cfif>
		<!------ <cfdump var="#getGroupAttributeInfo#"> ----->
		<!--- <cfset GetTheGroup = DistributorGroupAttributeManager.getDistributorGroupValues(
								DistributorGroupAttributeInfo 	= stGetGroupAttributeInfo,
								businessSegmentId				= form.GROUP_BUSINESS_SEGMENT_ID,
								cachedwithin					= APPLICATION.masterDataCacheSpan,
								groupid							= evaluate(form.dropDownName)) />
								
								
	<cfset theName = GetTheGroup.Group_Name> ---><!--- <cfoutput>#theName# :: #form.spanName#</cfoutput><cfabort> --->
	
	<script>
				function ReturnValue(formname, formfield, entryvalue, spanid, entrydesc)
			{	
				var oOpener = window.opener;
				if (oOpener)
				{	
					var formObj = eval("oOpener.document." + formname);
					if (formObj)
					{
						var inpObj = eval("formObj." + formfield);
						if (inpObj)
						{	
							inpObj.value = entryvalue;
						}
						var spanObj = eval("oOpener.document.all." + spanid)
						if (spanObj)
						{
							spanObj.innerText = entrydesc;
							spanObj.focus();
						
						}
					}
				}
			}
			
			<cfoutput>
					ReturnValue("#form.formname#", "#form.dropDownName#", "#evaluate(form.dropDownName)#", "#form.spanName#", "#theName#" );
			</cfoutput>
			
			window.close();
	</script>
	<cfabort>
<cfelse>
	<cfoutput>
	<form name="popupform" action="distributorGroupPopUp.cfm" method="post" id="popupform">
	<table>
	<tr>
		<td>
		<cfmodule template="/Customtags/DistributorGroupDropDown.cfm"
										groupLevelType = "#url.groupLevelType#"
										dropDownName = "#url.dropDownName#"
										selectedValue = "#url.selectedValue#"
										businessSegmentId = "#url.Group_Business_segment_id#"
										cachedwithin="#APPLICATION.masterDataCacheSpan#"
										usepopup="0"
										/>	
		</td>
	</tr>
	<tr>
		<td>
		<CF_button
						button_name		=	""
						button_caption	=	"select search parameter"
						button_action	=	"document.popupform.submit();"
						button_type		=	"javascript_link"
						button_width	=	"120"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
		</td>
	
	</tr>
	</table>
		<input type="hidden" name="formname" value="#url.formname#">
		<input type="hidden" name="groupLevelType" value="#url.groupLevelType#">
		<input type="hidden" name="dropDownName" value="#url.dropDownName#">
		<input type="hidden" name="selectedValue" value="#url.selectedValue#">
		<input type="hidden" name="Group_Business_segment_id" value="#url.Group_Business_segment_id#">
		<input type="hidden" name="spanName" value="span_#url.dropDownName#">
		<input type="hidden" name="title" value="#url.title#">
		<input type="hidden" name="blnSubmit" value="1">
	</form>
	</cfoutput>
</cfif>
</body>
</html>
