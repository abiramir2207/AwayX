<!--- all you need to do is pass this --->

<cfparam name="cost_product_item_number " default="">

<cfset cost_ActualCommodityCost = "">

<cfif len(cost_product_item_number ) EQ 0>You Need To Supply An Item Number<cfabort></cfif>

<cfset cost_commodity_range_date_start = now()>
<cfset cost_commodity_range_date_end = "">
<cfset cost_commodity_symbol  = "">
<cfset cost_calc_process = "">

<!--- get all the rules --->
<cfset useLakebaseForgetCommodityRuleForProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("commodity_pricing_rules")>
<cfif useLakebaseForgetCommodityRuleForProduct>
	<cftry>
		<cfset getCommodityRuleForProduct = application.oLakebase.toQuery(
			application.oLakebase.selectRows("commodity_pricing_rules", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCommodityRuleForProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCommodityRuleForProduct>
<cfquery name="getCommodityRuleForProduct" datasource="#application.datasource#">
	SELECT *
	FROM Commodity_Pricing_Rules
	WHERE Deleted = 0
</cfquery>
</cfif>


<!--- loop through the rules inorder to loop through the products of the rule --->
<cfloop query="getCommodityRuleForProduct">
	<cfset positionInListOfItemNumber = listfind(getCommodityRuleForProduct.Products,cost_product_item_number , ",")>
	
	<!--- if the item is found --->
	<cfif positionInListOfItemNumber NEQ 0>
			
		<cfset cost_commodity_symbol  = getCommodityRuleForProduct.Commodity>
		<cfset cost_calc_process = lcase(getCommodityRuleForProduct.calc_process)>

		
		<!--- find correct date for start of week --->
		<cfset DayOfWeekToTest = DateFormat(now(), 'mm/dd/yyyy')>
		<cfloop condition="DayOfWeek(DayOfWeekToTest) NEQ 2">
			<cfset DayOfWeekToTest = DateAdd('d',-1,DayOfWeekToTest)>
		</cfloop>
		
<!--- <br> --->

		<!--- find how many days to go back in time --->
		<cfif lcase(getCommodityRuleForProduct.Time_UOM_point_in_time) EQ "weeks">
			<!--- multiply Point_in_time * 7 to find how many days  --->
			<cfset HowManyDaysToMoveBackToFindEndOfSamplePeriod = getCommodityRuleForProduct.Point_in_time*7>
		<cfelse>
			<!--- just use the database days  --->
			<cfset HowManyDaysToMoveBackToFindEndOfSamplePeriod = getCommodityRuleForProduct.Point_in_time>
		</cfif>
		<cfset HowManyDaysToMoveBackToFindEndOfSamplePeriod = (HowManyDaysToMoveBackToFindEndOfSamplePeriod)*-1>


		
		<!--- set earliest start of week moving backwards --->
		<cfset cost_commodity_range_date_end = createodbcdatetime(Dateformat(DayOfWeekToTest, 'mm/dd/yyyy'))>
		<cfset cost_commodity_range_date_end = DateAdd('d', HowManyDaysToMoveBackToFindEndOfSamplePeriod,cost_commodity_range_date_end)>
		


		<!--- find how many days to go back in time from end date for sample period--->
		<cfif lcase(getCommodityRuleForProduct.Time_UOM_sample_size) EQ "weeks">
			<!--- multiply * 7 to find how many days  --->
			<cfset HowManyDaysToMoveBackToFindSTARTOfSamplePeriod = getCommodityRuleForProduct.sample_size*7>
		<cfelse>
			<!--- just use the database days  --->
			<cfset HowManyDaysToMoveBackToFindSTARTOfSamplePeriod = getCommodityRuleForProduct.sample_size>
		</cfif>
		<cfset HowManyDaysToMoveBackToFindSTARTOfSamplePeriod = (HowManyDaysToMoveBackToFindSTARTOfSamplePeriod+1)*-1 >
		
		<cfset cost_commodity_range_date_start = DateAdd('s',-1,DateAdd('d',HowManyDaysToMoveBackToFindSTARTOfSamplePeriod,cost_commodity_range_date_end))>
		
		
		<!--- get the appropiate commodities --->
		<cfquery name="getCommodityListings" datasource="#application.datasource#">
			SELECT *
			FROM Commodities
			WHERE Comm_Symbol = '#cost_commodity_symbol #'
			AND Comm_Datetime > #cost_commodity_range_date_start# AND Comm_Datetime < #cost_commodity_range_date_end#
		</cfquery>
		
		<cfset listofcommodityprices ="">
		<cfloop query="getCommodityListings">
			<cfset listofcommodityprices = listappend(listofcommodityprices,evaluate("#round(getCommodityListings.Comm_Last*1000)#/1000"))>
		</cfloop>

		<!--- <cfset listofcommodityprices = valuelist(getCommodityListings.Comm_Last)> --->
		<cfset listofcommodityprices = listtoarray(listofcommodityprices)>
		<cfswitch expression="#cost_calc_process#">
			<cfcase value="average">
				<cfset averageofcommodity = ArrayAvg(listofcommodityprices)>	
			</cfcase>
			
			<cfdefaultcase>
				Danger Will Robinson. Step Away From That Electrical Outlet With That Paper Clip!
				<cfabort>
			</cfdefaultcase>
		</cfswitch>
		
		<cfset seed = averageofcommodity>
		
		<CFSET localCPTotal = seed>
		<!--- do the compound goodies --->
		<cfloop index="LoopCount" from="1" to="4" step="1">
			<cfset localCPAmount = evaluate("getCommodityRuleForProduct.CP_amount_calc#LoopCount#")>
			<cfset locationOfPercentSign = findnocase("%",localCPAmount,1)>
			<cfif len(trim(localCPAmount)) GT 0>
				<!--- No percent --->
				<cfif locationOfPercentSign EQ 0>
					<CFSET localCPTotal = localCPTotal + localCPAmount>
				<cfelse>
					<cfset percentage = trim(listgetat(localCPAmount,1,"%"))>
					<cfset percentage = percentage/100>
					<CFSET localCPTotal = localCPTotal + (localCPTotal*percentage)>
				</cfif>
			</cfif>
		</cfloop>
		
		
		<CFSET localINTotal = 0>
		<!--- do the individual goodies --->
		<cfloop index="LoopCount" from="1" to="4" step="1">
			<cfset localINAmount = evaluate("getCommodityRuleForProduct.IN_amount_calc#LoopCount#")>
			<cfset locationOfPercentSign = findnocase("%",localINAmount,1)>
			<cfif len(trim(localINAmount)) GT 0>
				<!--- No percent --->
				<cfif locationOfPercentSign EQ 0>
					<CFSET localINTotal = localINTotal + localINAmount>
				<cfelse>
					<cfset percentage = trim(listgetat(localINAmount,1,"%"))>
					<cfset percentage = percentage/100>
					<CFSET localINTotal = localINTotal + (seed*percentage)>
				</cfif>
			</cfif>
		</cfloop>

		<cfset cost_ActualCommodityCost = localCPTotal + localINTotal>
		
	</cfif>
</cfloop>



