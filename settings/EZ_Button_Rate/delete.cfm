<!---------------------------------------------------------------------------------------------------------------------
			Template: \settings\Claim_Rates\delete.cfm
			Date:     2013 June
			Author:   Chris Nguyen
			Purpose:  Delete claim rates setting
			
			Parameter: 
					URL.EZ_Button_Rate_ID - required, numeric.
----------------------------------------------------------------------------------------------------------------------->
<cfscript>
	vars = {};
	vars.EZButtonRateCFC = createObject("component", "components.programs.EZButton_ProgramManager");
	vars.EZButtonRateCFC.deleteEZButtonRate( url.EZ_Button_Rate_ID );
</cfscript>

<cflocation url="list.cfm" addtoken="false">
