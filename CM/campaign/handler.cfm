<!------ operator.cfm ----->

<CFPARAM NAME="form.command" 	DEFAULT="">

<!---switch case for command--->
<cfswitch expression="#form.command#">

	<!------ Create / Edit / Save Campaign ----->
	<cfcase value="ceCampaign,svCampaign" delimiters=",">
		<cfinclude template="campaign_create_edit.cfm" />
	</cfcase>
	
	<!------ Search Campaign ----->
	<cfcase value="sCampaign" delimiters=",">
		<cfinclude template="campaign_search.cfm" />
	</cfcase>
	
</cfswitch>