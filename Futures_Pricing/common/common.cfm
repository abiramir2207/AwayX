<cfset statusCECommandList = "ceInitialRequest,ceRequestMaterials,ceProcurement,cePricing,cePriceInSales" />
<cfset statusDCommandList = "dRequest,dRequestMaterials,dProcurement,dPricing,cePriceInSales" />
<cfscript>
function formatVolume(sVol, bComma)
{
	if(bComma)
	{
		return NumberFormat(sVol, "___,___,___.__");
	}
	else
	{
		return NumberFormat(sVol, "_________.__");
	}
}

</cfscript>
