<!-----      
		Name: 			pullback_profile_template_action.cfm     
               			Copyright (c) 2006 Blacksmith Applications, Inc.
		Created:
						03/03/2006
						Deepa Kunnath
		Last Modified:
						03/03/2006   
						Deepa Kunnath  
		Description:
                       This page should only be accessed from pullback_profile_template.cfm through a form submit to save the values
		Parameters:
                      form.profileId - the profile id fo which we are saving teh settings
					  form.Pullback_Approve_Template_List - the list of templates that this profile can pullback approve
		Usage:
                      pullback_profile_template_action.cfm
----->
<cfparam name="form.profileId" 	default="">
<cfparam name="form.pullbackApproveTemplateList" 	default="">
<cfif NOT isNumeric(form.profileId) OR form.profileId EQ 0>
	<!------ do nothing ----->
<cfelse>
	<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
	<cfset templateManager.saveProfileTemplates(
					profileId = form.profileId,
					forbidAccessType = 6,
					templateIdList = form.pullbackApproveTemplateList
					) />
</cfif>
<script language="JavaScript">
window.close();
</script>
