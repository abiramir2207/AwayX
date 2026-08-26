<cfparam NAME="url.typeid" DEFAULT="">
<cfparam NAME="url.volume" DEFAULT="">
<cfparam NAME="url.productid" DEFAULT="">
<cfparam NAME="url.bidruleid" DEFAULT="">

<cfparam NAME="url.priceObjectName" DEFAULT="">
<cfparam NAME="form.FinalPrice" DEFAULT="0">


<cfif len(trim(url.typeid)) GT 0 AND len(trim(url.volume)) GT 0 AND len(trim(url.productid)) GT 0 AND len(trim(url.bidruleid)) GT 0 AND len(trim(url.priceObjectName)) GT 0>
	<cfset useLakebaseForgetProductCurrentCost = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForgetProductCurrentCost>
	<cftry>
		<cfset getProductCurrentCost = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#url.productid#",
				"select" = "curr_cost"
			}), "curr_cost"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProductCurrentCost = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProductCurrentCost>
<CFQUERY NAME="getProductCurrentCost" DATASOURCE="#application.datasource#">
		SELECT Curr_Cost
		FROM BSA_Foodservice_Items_Master
		WHERE BSA_Foodservice_Items_Master_ID = '#url.productid#'
	</CFQUERY>
</cfif>
	
	<cfset form.FinalPrice = getProductCurrentCost.Curr_Cost>
	
	<CFQUERY NAME="This_Overage_Data" DATASOURCE="#application.datasource#">
		SELECT 
			Modifier_Amount AS Amount, 
	
			CASE
			WHEN Modifier_UOM = 1 THEN
				'$'
			ELSE
				'%'
			END AS UOM
		FROM 
			Bid_Rule_Modifiers
		WHERE 
			isindependent = 0
			and
			iscompound = 1
			and
			Deleted = 0
			and
			Bid_Rule_ID = '#url.bidruleid#'
	</CFQUERY>
	
	<CFSET Compounded_Calc_Against = form.FinalPrice>
	<CFSET Compounded_Calc_Add_To = form.FinalPrice>
	<CFSET Independent_Compounded_Calc_Type = 2>
	<CFSET QRY_Overage_Data = This_Overage_Data>
	
	<CFOUTPUT>
	<CFSET Compounded_Calc_Result = Compounded_Calc_Add_To>
	<CFLOOP QUERY="QRY_Overage_Data">				
			<CFIF This_Overage_Data.UOM EQ "%">
				<CFIF Independent_Compounded_Calc_Type EQ 1><!---- independent --->
					<CFSET Operation_Against = Compounded_Calc_Against>
				<CFELSE><!---- componded ---->
					<CFSET Operation_Against = Compounded_Calc_Result>				
				</CFIF>			
				<CFSET thisAvearage = (Operation_Against * This_Overage_Data.Amount)/100>
			<CFELSEIF  This_Overage_Data.UOM EQ "$">
				<CFSET thisAvearage = This_Overage_Data.Amount>
			</CFIF>	
			<CFSET Compounded_Calc_Result = Compounded_Calc_Result + thisAvearage>
		</CFLOOP>	
	</CFOUTPUT>
	<cfset form.FinalPrice = Compounded_Calc_Result>

	
	<CFQUERY NAME="This_Overage_Data" DATASOURCE="#application.datasource#">
		SELECT 
			Modifier_Amount AS Amount, 
	
			CASE
			WHEN Modifier_UOM = 1 THEN
				'$'
			ELSE
				'%'
			END AS UOM
		FROM 
			Bid_Rule_Modifiers
		WHERE 
			isindependent = 1
			and
			iscompound = 0
			and
			Deleted = 0
			and
			Bid_Rule_ID = '#url.bidruleid#'
	</CFQUERY>
	
	<CFSET Compounded_Calc_Against = form.FinalPrice>
	<CFSET Compounded_Calc_Add_To = form.FinalPrice>
	<CFSET Independent_Compounded_Calc_Type = 1>
	<CFSET QRY_Overage_Data = This_Overage_Data>
	
	<CFOUTPUT>
	<CFSET Compounded_Calc_Result = Compounded_Calc_Add_To>
	<CFLOOP QUERY="QRY_Overage_Data">				
			<CFIF This_Overage_Data.UOM EQ "%">
				<CFIF Independent_Compounded_Calc_Type EQ 1><!---- independent --->
					<CFSET Operation_Against = Compounded_Calc_Against>
				<CFELSE><!---- componded ---->
					<CFSET Operation_Against = Compounded_Calc_Result>				
				</CFIF>			
				<CFSET thisAvearage = (Operation_Against * This_Overage_Data.Amount)/100>
			<CFELSEIF  This_Overage_Data.UOM EQ "$">
				<CFSET thisAvearage = This_Overage_Data.Amount>
			</CFIF>	
			<CFSET Compounded_Calc_Result = Compounded_Calc_Result + thisAvearage>
		</CFLOOP>	
	</CFOUTPUT>
	<cfset form.FinalPrice = Compounded_Calc_Result>	
	
</cfif> 

<!--- <!-- get overage for volume range -->
<cfif len(trim(url.typeid)) NEQ 0 OR len(trim(url.volume)) NEQ 0>
	<cfset url.volume = trim(numberformat(url.volume, '_________.___'))>
	<CFQUERY NAME="findRule" DATASOURCE="#application.datasource#">
		SELECT Bid_Rule_ID, Bid_Rule_Item_ID
		FROM Bid_Rule_Items
		WHERE 
			Type_Item_ID = '#url.typeid#'
			AND
			DELETED = 0
	</CFQUERY>
	
	<cfif findRule.recordcount GT 0>
		<CFQUERY NAME="getBidRuleVolumeGroupID" DATASOURCE="#application.datasource#">
			SELECT Bid_Rule_Group_ID, 
				CASE
				WHEN len(Range_Start) = 0 THEN
					-2147483648
				ELSE
					CAST(Range_Start AS Int)
				END AS Range_Start,

				CASE
				WHEN len(Range_End) = 0 THEN
					2147483648
				ELSE
					CAST(Range_End AS Int)
				END AS Range_End

			FROM Bid_Rule_Volume_Groups
			WHERE Deleted = 0
		</CFQUERY>		
		
		<CFQUERY NAME="getBidRuleVolumeGroupID_2" DBTYPE="query">
			SELECT Bid_Rule_Group_ID
			FROM getBidRuleVolumeGroupID
			WHERE Range_Start <= #url.volume# AND Range_End >= #url.volume#
		</CFQUERY>
		
		<cfif getBidRuleVolumeGroupID_2.recordcount EQ 0>
			<CFQUERY NAME="getBidRuleVolumeGroupID_2" DBTYPE="query">
				SELECT Bid_Rule_Group_ID
				FROM getBidRuleVolumeGroupID
				WHERE Range_Start <= #url.volume# AND Range_End <= #url.volume#
			</CFQUERY>
		</cfif>
		
		<cfif getBidRuleVolumeGroupID_2.recordcount GT 0>
			<CFQUERY NAME="getPrice" DATASOURCE="#application.datasource#">
				SELECT Amount
				FROM Bid_Rule_Item_Group_Amounts
				WHERE 
					Bid_Rule_Group_ID = '#getBidRuleVolumeGroupID_2.Bid_Rule_Group_ID#'
					AND
					Bid_Rule_Item_ID = '#findrule.Bid_Rule_Item_ID#'
			</CFQUERY>
			<cfif getPrice.recordcount GT 0>
				<cfset form.FinalPrice = getPrice.Amount>
			</cfif>
		</cfif>
	</cfif>
</cfif> --->






<cfif len(trim(url.priceObjectName)) GT 0>
	<cfoutput>
	<script>
		window.parent.document.all.#url.priceObjectName#.value = '#trim(numberformat(form.FinalPrice, '_________.___'))#'
	</script>
	</cfoutput>
</cfif>
