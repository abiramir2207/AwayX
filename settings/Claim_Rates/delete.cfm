<!---------------------------------------------------------------------------------------------------------------------
			Template: \settings\Claim_Rates\delete.cfm
			Date:     2013 June
			Author:   Chris Nguyen
			Purpose:  Delete claim rates setting
			
			Parameter: 
					URL.Config_ID - required, numeric.
----------------------------------------------------------------------------------------------------------------------->
<cfscript>
		vars = {};
		vars.claimRateCFC = createObject("component", "components.programs.claimRates");
		vars.claimRateCFC.deleteClaimRateConfig( url.config_id );
</cfscript>

<cflocation url="list.cfm" addtoken="false">
