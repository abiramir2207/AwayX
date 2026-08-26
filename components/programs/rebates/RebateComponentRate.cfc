<cfcomponent>

	<cffunction name="set" output="false" returntype="struct">

		<cfargument name="rate" type="string" required="true" default=0>
	  <cfargument name="uomID" type="string" required="true" default="">
		<cfargument name="compID" type="string" required="true" default="0">
		<cfargument name="contractProdID" type="string" required="true" default="">
		<cfargument name="ruleId" type="string" required="true" default="0">
		<cfargument name="basisCodeQuantity" type="string" required="false" default="" />
		<cfargument name="basisCodeQuantityUom" type="string" required="false" default="" />
		<cfargument name="basisCodeFreeGoods" type="string" required="false" default="" />
		<cfargument name="effectMarginPercent" type="string" required="false" default="" />
		<cfargument name="scanVolume" type="string" required="false" default="" />
		<cfargument name="Program_Rebates_Component_Data_ID" type="numeric" required="false" default="0" />
 		<cfargument name="maxRate" type="string" required="true" default=0>
		<cfargument name="prodID" type="string" required="true" default="">
		<cfargument name="ProgramID" type="numeric" required="false" default=0>
		<cfargument name="UserSelectedUoM" type="numeric" required="false" default=0><!---63887 --->
		<!--- D38536  :: Alternate recapture rates per component START--->
		<cfargument name="ar_rate" type="array" required="false" default="#ArrayNew(1)#" />
		<cfargument name="ar_uom" type="array" required="false" default="#ArrayNew(1)#" />
		<cfargument name="arUseTempTable" type="boolean" required="false" default="0" />
		<cfargument name="EZTemplate" type="boolean" required="false" default="0" />
		<!--- D38536  :: Alternate recapture rates per component END--->


<cfif ! arguments.EZTemplate>
		<cfquery name="AlternateRateUom" datasource="#application.datasource#">
			<cfif arguments.arUseTempTable EQ 1>
			SELECT rate, UOM
			FROM ##tmpAltRate
			WHERE Program_Rebates_Component_ID = #arguments.compID#
			AND Contract_Products_ID = '#arguments.contractProdID#'
			<cfelse>
			SELECT rate, UOM
			FROM Program_Rebate_Alternate_Recapture_Rate
			WHERE Contract_Main_ID = #arguments.ProgramID#
			AND Program_Rebates_Component_ID = #arguments.compID#
			AND Contract_Products_ID = '#arguments.contractProdID#'
			</cfif>
		</cfquery>

		<cfif AlternateRateUom.recordcount>
			<cfloop from="1" to="#AlternateRateUom.recordcount#" index="AR">
				<cfset #ArrayAppend(ar_rate, "#AlternateRateUom.rate#")# >
				<cfset #ArrayAppend(ar_uom, "#AlternateRateUom.uom#")# >
			</cfloop>
		<cfelse>
				<cfset #ArrayAppend(ar_rate, "0")# >
				<cfset #ArrayAppend(ar_uom, "0")# >
		</cfif>
	</cfif>

		<cfscript>
			tmpStruct = structNew();
			tmpStruct.rate = arguments.rate;
			tmpStruct.uomID = arguments.uomID;
			tmpStruct.compID = arguments.compID;
			tmpStruct.contractProdID = arguments.contractProdID;
			tmpStruct.ruleId = arguments.ruleId;

			tmpStruct.basisCodeQuantity = 0;
			tmpStruct.basisCodeQuantityUom = 0;
			tmpStruct.basisCodeFreeGoods = 0;
			tmpStruct.effectMarginPercent = 100;

			tmpStruct.scanVolume = arguments.scanVolume;
			tmpStruct.Program_Rebates_Component_Data_ID = arguments.Program_Rebates_Component_Data_ID;
			tmpStruct.maxRate = arguments.maxRate;
			tmpStruct.prodID = arguments.prodID;
			tmpStruct.UserSelectedUoM = arguments.UserSelectedUoM;//63887
			//D38536  :: Alternate recapture rates per component START
			tmpStruct.ar_rate = arguments.ar_rate;
			tmpStruct.ar_uom = arguments.ar_uom;
	// D38536  :: Alternate recapture rates per component END

			if(isNumeric(arguments.basisCodeQuantity))
			{
				tmpStruct.basisCodeQuantity = arguments.basisCodeQuantity;
			}
			if(isNumeric(arguments.basisCodeQuantityUom))
			{
				tmpStruct.basisCodeQuantityUom = arguments.basisCodeQuantityUom;
			}
			if(isNumeric(arguments.basisCodeFreeGoods))
			{
				tmpStruct.basisCodeFreeGoods = arguments.basisCodeFreeGoods;
			}
			if(isNumeric(arguments.effectMarginPercent))
			{
				tmpStruct.effectMarginPercent = arguments.effectMarginPercent;
			}
		</cfscript>

		<cfreturn tmpStruct />

   </cffunction>

</cfcomponent>