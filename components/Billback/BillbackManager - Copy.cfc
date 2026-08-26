<!---
Name: 			BillbackManager.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	N/A
Created By:		N/A
Description:	This file is responsible for managing Billback data.
--->

<cfcomponent hint="Billback Manager" extends="components.Base">

	<cfproperty name="BillbackIDs" 			type="string" />
	<cfproperty name="FilteredBillbackIDs" 	type="string" />
	<cfproperty name="programTotal" 		type="struct" />
	<cfproperty name="programSumLevel" 		type="struct" />
	<!---- report headers --->
	<cfproperty name="reportHeaders" 		type="string"/>
	<cfproperty name="reportName" 			type="string"/>
	<cfproperty name="reportHeaderSortByList" type="string"/>

	<cfset variables.reportHeaders = "" />
	<cfset variables.reportName = "" />
	<cfset variables.reportHeadersAttributes = "" />
	<cfset variables.reportHeaderSortByList = "" />

	<cfset this.programTotal = structNew() />
	<cfset this.programSumLevel = structNew() />
	<cfset this.FilteredBillbackIDs = "" />

	<cffunction name="init" output="false" returntype="components.billback.BillbackManager">
		<cfargument name="reportName" required="false">
		<cfif isDefined("arguments.reportName") and arguments.reportName neq "" >
			<cfset setReportName(arguments.reportName) />
			<cfset loadReportHeaders() />
		</cfif>
		<cfset this.BillbackIDs = "" />
		<cfreturn this />
	</cffunction>
	<!--- header sort list --->
	<cffunction name="setReportHeaderSortByList" access="package" returntype="void">
		<cfargument name="reportHeaderSortByList"	type="string" default="" required="true">
		<cfset variables.reportHeaderSortByList = arguments.reportHeaderSortByList />
	</cffunction>

	<cffunction name="getReportHeaderSortByList" access="public" returntype="string">
		<cfreturn variables.reportHeaderSortByList />
	</cffunction>

	<!--- report name ---->
	<cffunction name="setReportName" output="false" access="package">
		<cfargument name="reportName"	type="string" default="" required="true">
		<cfset variables.reportName = arguments.reportName />
	</cffunction>

	<cffunction name="getReportName" access="public" returntype="string">
		<cfreturn variables.reportName>
	</cffunction>

	<!--- for report Headers --->
	<cffunction name="setReportHeaders" output="false" access="package">
		<cfargument name="reportHeaders"	type="string" default="" required="true">
		<cfset variables.reportHeaders = arguments.reportHeaders />
	</cffunction>

	<cffunction name="getReportHeaders" access="public" returntype="string">
		<cfreturn variables.reportHeaders>
	</cffunction>

	<!--- for report Headers mapping db attributes --->
	<cffunction name="setReportHeadersAttributes" output="false" access="package">
		<cfargument name="reportHeadersAttributes"	type="string" default="" required="true">
		<cfset variables.reportHeadersAttributes = arguments.reportHeadersAttributes />
	</cffunction>

	<cffunction name="getReportHeadersAttributes" access="public" returntype="string">
		<cfreturn variables.reportHeadersAttributes>
	</cffunction>


	<cffunction name="setThisClaimSummaryLevel" output="false" access="public">
		<cfargument name="reportName" 		type="string" default="" required="true">
		<!----<cfdump var = #arguments.claimForm#><cfabort>--->
		<cfswitch expression="#Ucase(left(trim(arguments.reportName), 1))#">
			<cfcase value="P">
				<cfset this.setParticipationSummaryLevel() />
			</cfcase>
			<cfcase value="S">
				<cfset this.setParticipationSummaryLevel() />
			</cfcase>
		</cfswitch>
	</cffunction>

	<cffunction name="setParticipationSummaryLevel" output="false" access="public">
		<CFQUERY NAME="qryGetClaimRegionLevelSummary" DATASOURCE="#APPLICATION.DATASOURCE#">
			select region_name, count(*) as region_level_count
			from claim_participation_total
			group by region_name
			order by region_name
		</CFQUERY>
		<cfloop query="qryGetClaimRegionLevelSummary">
			<cfif Not StructKeyExists(programSumLevel, trim(region_name))>
				<cfset programSumLevel[region_name]['Total'] = region_level_count />
			</cfif>
		</cfloop>

		<CFQUERY NAME="qryGetClaimCustLevelSummary" DATASOURCE="#APPLICATION.DATASOURCE#">
			select region_name, cust_name,count(*) AS cust_level_count
			from claim_participation_total
			group by region_name, cust_name
			order by 1
		</CFQUERY>
		<cfloop query="qryGetClaimCustLevelSummary">
			<cfif StructKeyExists(programSumLevel, trim(region_name))>
				<cfset programSumLevel[region_name]['Total'] = StructNew() />
				<cfset programSumLevel[region_name]['Total'][cust_name] = cust_level_count />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="setThisClaimTotal" output="false" access="public">
		<cfargument name="reportName" 		type="string" default="" required="true">
		<!----<cfdump var = #arguments.claimForm#><cfabort>--->
		<cfswitch expression="#Ucase(left(trim(arguments.reportName), 1))#">
			<cfcase value="C">
				<cfset this.setClaimSummaryTotalByCust("cust_id") />
			</cfcase>
			<cfcase value="V">
				<cfset this.setVarietySummaryTotalByProgram("program") />
			</cfcase>
			<cfcase value="T">
				<cfset this.setTimeProcessingSummaryTotalByCustomer("cust_id") />
			</cfcase>
			<cfcase value="P">
				<cfset this.setParticipationSummaryTotal("region_name,cust_name") />
			</cfcase>
			<cfcase value="S">
				<cfset this.setCostSavingTotal("region_name,market_name,cust_name") />
			</cfcase>
		</cfswitch>
	</cffunction>

	<cffunction name="setTimeProcessingSummaryTotalByCustomer" output="false" access="public">
		<cfargument name="groupByField"	type="string" default="" required="true">
		<CFQUERY NAME="qryGetTimeProcessingSummaryTotalByCustomer" DATASOURCE="#APPLICATION.DATASOURCE#">
			select distinct #arguments.groupByField#,count(distinct claimNo) as ProcessedClaims,avg(PD_VS_RD_Days) AS Avg_PD_VS_RD_Days,avg(RD_VS_ED_Days) AS Avg_RD_VS_ED_Days,avg(ED_VS_CD_Days) AS Avg_ED_VS_CD_Days,avg(CD_VS_PD_Days) AS Avg_CD_VS_PD_Days,sum(paid_amount) as paid_amount,sum(claim_amount) as claim_amount,sum(paidCS) as paidCS,sum(claimCS) as claimCS
			from claim_time_summary_report_for_total
			<cfif this.FilteredBillbackIDs NEQ "">
				where billback_id in ( #trim(ListQualify(this.FilteredBillbackIDs,"'",",","ALL"))#  )
			</cfif>
			group by #arguments.groupByField#
		</CFQUERY>
		<cfloop query="qryGetTimeProcessingSummaryTotalByCustomer">
			<cfset setProgramTotal(Cust_ID, Paid_Amount, Claim_Amount, PaidCS, ClaimCS, ProcessedClaims, Avg_PD_VS_RD_Days, Avg_RD_VS_ED_Days, Avg_ED_VS_CD_Days, Avg_CD_VS_PD_Days) />
		</cfloop>
	</cffunction>

	<cffunction name="setVarietySummaryTotalByProgram" output="false" access="public">
		<cfargument name="groupByField"	type="string" default="" required="true">
		<CFQUERY NAME="qryGetVarietySummaryTotalByProgram" DATASOURCE="#APPLICATION.DATASOURCE#">
			select distinct #arguments.groupByField#,sum(paid_amount) as paid_amount,sum(claim_amount) as claim_amount,sum(paidCS) as paidCS,sum(claimCS) as claimCS
			from claim_variety_summary_report_for_total
			<cfif this.FilteredBillbackIDs NEQ "">
				where billback_id in ( #trim(ListQualify(this.FilteredBillbackIDs,"'",",","ALL"))#  )
			</cfif>
			group by #arguments.groupByField#
		</CFQUERY>
		<cfloop query="qryGetVarietySummaryTotalByProgram">
			<cfset setProgramTotal(Program, Paid_Amount, Claim_Amount, PaidCS, ClaimCS) />
		</cfloop>
	</cffunction>
	<!--- for cost saving --->
	<cffunction name="setCostSavingTotal" output="false" access="public">
		<cfargument name="groupByFields"	type="string" default="" required="true">
		<cfset groupByFirstField = ListGetAt(arguments.groupByFields, 1) />
		<cfset groupBySecondField = groupByFirstField & "," & ListGetAt(arguments.groupByFields, 2) />
		<!--- first level by region--->
		<CFQUERY NAME="qryGetCostSavingTotal" DATASOURCE="#APPLICATION.DATASOURCE#">
			select distinct #groupByFirstField#,sum(paid_amount) as paid_amount,sum(claim_amount) as claim_amount,sum(variation$) as variation$,sum(paidCS) as paidCS,sum(claimCS) as claimCS, sum(variationCS) as variationCS
			from claim_cost_saving_total
			<cfif this.FilteredBillbackIDs NEQ "">
				where billback_id in ( #trim(ListQualify(this.FilteredBillbackIDs,"'",",","ALL"))#  )
			</cfif>
			group by #groupByFirstField#
		</CFQUERY>
		<cfloop query="qryGetCostSavingTotal">
			<cfset setProgramTotal(Evaluate(trim(groupByFirstField)), Paid_Amount,Claim_Amount,PaidCS,ClaimCS,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,0,0,0,variation$,variationCS) />
		</cfloop>

		<!---- second level by market --->
		<CFQUERY NAME="qryGetCostSavingTotalForSecondLevel" DATASOURCE="#APPLICATION.DATASOURCE#">
			select distinct #groupBySecondField#,sum(paid_amount) as paid_amount,sum(claim_amount) as claim_amount,sum(variation$) as variation$,sum(paidCS) as paidCS,sum(claimCS) as claimCS, sum(variationCS) as variationCS,SUM(1) AS market_level_count
			from claim_cost_saving_total
			<cfif this.FilteredBillbackIDs NEQ "">
				where billback_id in ( #trim(ListQualify(this.FilteredBillbackIDs,"'",",","ALL"))#  )
			</cfif>
			group by #groupBySecondField#
		</CFQUERY>
		<cfloop query="qryGetCostSavingTotalForSecondLevel">
			<cfset EvalGroupBySecondField = Evaluate(ListGetAt(arguments.groupByFields, 1)) & "|" & Evaluate(ListGetAt(arguments.groupByFields, 2)) />
			<cfset setProgramTotal( EvalGroupBySecondField, Paid_Amount,Claim_Amount,PaidCS,ClaimCS,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,0,0,0,market_level_count,variation$,variationCS) />
		</cfloop>
		<!--- third level by cust --->
		<CFQUERY NAME="qryGetCostSavingTotalForThirdLevel" DATASOURCE="#APPLICATION.DATASOURCE#">
			select distinct #arguments.groupByFields#,sum(paid_amount) as paid_amount,sum(claim_amount) as claim_amount,sum(variation$) as variation$,sum(paidCS) as paidCS,sum(claimCS) as claimCS, sum(variationCS) as variationCS,SUM(1) AS cust_level_count
			from claim_cost_saving_total
			<cfif this.FilteredBillbackIDs NEQ "">
				where billback_id in ( #trim(ListQualify(this.FilteredBillbackIDs,"'",",","ALL"))#  )
			</cfif>
			group by #arguments.groupByFields#
		</CFQUERY>
		<cfloop query="qryGetCostSavingTotalForThirdLevel">
			<cfset EvalGroupByFields = Evaluate(ListGetAt(arguments.groupByFields, 1)) & "|" & Evaluate(ListGetAt(arguments.groupByFields, 2)) & "|" & Evaluate(ListGetAt(arguments.groupByFields, 3))/>
			<cfset setProgramTotal(EvalGroupByFields, Paid_Amount,Claim_Amount,PaidCS,ClaimCS,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,0,0,0,0,variation$,variationCS,cust_level_count) />
		</cfloop>
	</cffunction>

	<cffunction name="setClaimSummaryTotalByCust" output="false" access="public">
		<cfargument name="groupByField"	type="string" default="" required="true">
		<CFQUERY NAME="qryGetClaimSummaryTotalByCust" DATASOURCE="#APPLICATION.DATASOURCE#">
			select distinct #arguments.groupByField#,sum(paid_amount) as paid_amount,sum(claim_amount) as claim_amount,sum(paidCS) as paidCS,sum(claimCS) as claimCS
			from claim_summary_report_for_total
			<cfif this.FilteredBillbackIDs NEQ "">
				where billback_id in ( #trim(ListQualify(this.FilteredBillbackIDs,"'",",","ALL"))#  )
			</cfif>
			group by #arguments.groupByField#
		</CFQUERY>
		<cfloop query="qryGetClaimSummaryTotalByCust">
			<cfset setProgramTotal(Cust_ID, Paid_Amount, Claim_Amount, PaidCS, ClaimCS) />
		</cfloop>
	</cffunction>

	<cffunction name="setParticipationSummaryTotal" output="false" access="public">
		<cfargument name="groupByFields"	type="string" default="" required="true">
		<cfset groupByFirstField = ListGetAt(arguments.groupByFields, 1) />
		<!---<cfargument name="groupByFirstField"	type="string" default="" required="true">--->
		<CFQUERY NAME="qryGetParticipationSummaryTotalBy1stLevel" DATASOURCE="#APPLICATION.DATASOURCE#">
			select	distinct
					#groupByFirstField#,
					sum(1) as cust_level_count,
					SUM(bid_request_cases) AS bid_request_cases,
					SUM(bid_request_dollars) AS bid_request_dollars,
	                   SUM(field_execution_cases) AS field_execution_cases,
					SUM(field_execution_dollars) AS field_execution_dollars,
	                   SUM(distributor_trade_shelter_cases) AS distributor_trade_shelter_cases,
					SUM(distributor_trade_shelter_dollars) AS distributor_trade_shelter_dollars,
	                  	SUM(operator_direct_or_hq_programs_cases) AS operator_direct_or_hq_programs_cases,
					SUM(operator_direct_or_hq_programs_dollars) AS operator_direct_or_hq_programs_dollars, SUM(operator_deviated_pricing_cases) AS operator_deviated_pricing_cases,
	                   SUM(operator_deviated_pricing_dollars) AS operator_deviated_pricing_dollars,
					SUM(total_cases) AS total_cases,
					SUM(total_dollars) AS total_dollars
			from CLAIM_PARTICIPATION_TOTAL
			<cfif this.FilteredBillbackIDs NEQ "">
				where billback_id in ( #trim(ListQualify(this.FilteredBillbackIDs,"'",",","ALL"))#  )
			</cfif>
			group by #groupByFirstField#
		</CFQUERY>
		<cfloop query="qryGetParticipationSummaryTotalBy1stLevel">
			<cfset setProgramTotal(Evaluate(trim(groupByFirstField)),0,0,0,0,0,0,0,0,0,bid_request_cases,bid_request_dollars,
			field_execution_cases,field_execution_dollars,distributor_trade_shelter_cases,
			distributor_trade_shelter_dollars,operator_direct_or_hq_programs_cases,
			operator_direct_or_hq_programs_dollars,operator_deviated_pricing_cases,
			operator_deviated_pricing_dollars,total_cases,total_dollars) />
		</cfloop>
		<!--- handle for the second level, cust level ---->
		<CFQUERY NAME="qryGetParticipationSummaryTotalBySecondLevel" DATASOURCE="#APPLICATION.DATASOURCE#">
			select	distinct
					#groupByFields#,
					SUM(bid_request_cases) AS bid_request_cases,
					SUM(bid_request_dollars) AS bid_request_dollars,
	                   SUM(field_execution_cases) AS field_execution_cases,
					SUM(field_execution_dollars) AS field_execution_dollars,
	                   SUM(distributor_trade_shelter_cases) AS distributor_trade_shelter_cases,
					SUM(distributor_trade_shelter_dollars) AS distributor_trade_shelter_dollars,
	                  	SUM(operator_direct_or_hq_programs_cases) AS operator_direct_or_hq_programs_cases,
					SUM(operator_direct_or_hq_programs_dollars) AS operator_direct_or_hq_programs_dollars, SUM(operator_deviated_pricing_cases) AS operator_deviated_pricing_cases,
	                   SUM(operator_deviated_pricing_dollars) AS operator_deviated_pricing_dollars,
					SUM(total_cases) AS total_cases,
					SUM(total_dollars) AS total_dollars,
					SUM(1) AS cust_level_count
			from claim_participation_basic_report
			<cfif this.FilteredBillbackIDs NEQ "">
				where billback_id in ( #trim(ListQualify(this.FilteredBillbackIDs,"'",",","ALL"))#  )
			</cfif>
			group by #groupByFields#
		</CFQUERY>
		<cfloop query="qryGetParticipationSummaryTotalBySecondLevel">
			<cfset EvalGroupByFields = Evaluate(ListGetAt(groupByFields, 1)) & "|" & Evaluate(ListGetAt(groupByFields, 2)) />
			<cfset setProgramTotal(EvalGroupByFields,0,0,0,0,0,0,0,0,0,bid_request_cases,bid_request_dollars,
			field_execution_cases,field_execution_dollars,distributor_trade_shelter_cases,
			distributor_trade_shelter_dollars,operator_direct_or_hq_programs_cases,
			operator_direct_or_hq_programs_dollars,operator_deviated_pricing_cases,
			operator_deviated_pricing_dollars,total_cases,total_dollars,cust_level_count) />
		</cfloop>
	</cffunction>

	<cffunction name="setProgramTotal" output="false" access="public">
		<cfargument name="Program" 			type="string" 	required="false"  />
		<cfargument name="Paid_Amount" 		type="numeric"	required="false"  />
		<cfargument name="Claim_Amount" 	type="numeric" 	required="false"  />
		<cfargument name="PaidCS"			type="numeric" 	required="false"  />
		<cfargument name="ClaimCS" 			type="numeric" 	required="false"  />
		<cfargument name="ProcessedClaims" 	type="numeric" 	required="false"  />
		<cfargument name="Avg_PD_VS_RD_Days" 	type="numeric" 	required="false"  />
		<cfargument name="Avg_RD_VS_ED_Days" 	type="numeric" 	required="false"  />
		<cfargument name="Avg_ED_VS_CD_Days" 	type="numeric" 	required="false"  />
		<cfargument name="Avg_CD_VS_PD_Days" 	type="numeric" 	required="false"  />
		<cfargument name="Bid_Request_Cases"		type="numeric" 	required="false"  />
		<cfargument name="Bid_Request_Dollars" 		type="numeric"	required="false"  />
		<cfargument name="Field_Execution_Cases" 	type="numeric"	required="false"  />
		<cfargument name="Field_Execution_Dollars" 	type="numeric" 	required="false"  />
		<cfargument name="Distributor_Trade_Shelter_Cases"		type="numeric" 	required="false"  />
		<cfargument name="Distributor_Trade_Shelter_Dollars" 	type="numeric"	required="false"  />
		<cfargument name="Operator_Direct_Or_Hq_Programs_Cases" type="numeric"	required="false"  />
		<cfargument name="Operator_Direct_Or_Hq_Programs_Dollars" type="numeric" required="false"  />
		<cfargument name="Operator_Deviated_Pricing_Cases" 		type="numeric"	required="false"  />
		<cfargument name="Operator_Deviated_Pricing_Dollars" 	type="numeric" 	required="false"  />
		<cfargument name="Total_Cases"		type="numeric"	required="false"  />
		<cfargument name="Total_Dollars" 	type="numeric" 	required="false"  />
		<cfargument name="SecondLevelCount" type="numeric" 	required="false"  />
		<!--- for cost saving --->
		<cfargument name="variation$" 		type="numeric" 	required="false"  />
		<cfargument name="variationCS" 		type="numeric" 	required="false"  />
		<cfargument name="ThirdLevelCount" 	type="numeric" 	required="false"  />
		<!--- test to see if the program is a list with multiple list values ---->
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.Program)) and ListLen(arguments.Program, "|") EQ 1>
			<cfif isDefined("arguments.Paid_Amount") >
				<cfset this.programTotal[trim(arguments.Program)]['Paid_Amount'] = arguments.Paid_Amount />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Paid_Amount'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Claim_Amount") >
				<cfset this.programTotal[trim(arguments.Program)]['Claim_Amount'] = arguments.Claim_Amount />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Claim_Amount'] = 0 />
			</cfif>
			<cfif isDefined("arguments.PaidCS") >
				<cfset this.programTotal[trim(arguments.Program)]['PaidCS'] = arguments.PaidCS />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['PaidCS'] = 0 />
			</cfif>
			<cfif isDefined("arguments.ClaimCS") >
				<cfset this.programTotal[trim(arguments.Program)]['ClaimCS'] = arguments.ClaimCS />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['ClaimCS'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Bid_Request_Cases") >
				<cfset this.programTotal[trim(arguments.Program)]['Bid_Request_Cases'] = arguments.Bid_Request_Cases />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Bid_Request_Cases'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Bid_Request_Dollars") >
				<cfset this.programTotal[trim(arguments.Program)]['Bid_Request_Dollars'] = arguments.Bid_Request_Dollars />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Bid_Request_Dollars'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Field_Execution_Cases") >
				<cfset this.programTotal[trim(arguments.Program)]['Field_Execution_Cases'] = arguments.Field_Execution_Cases />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Field_Execution_Cases'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Field_Execution_Dollars") >
				<cfset this.programTotal[trim(arguments.Program)]['Field_Execution_Dollars'] = arguments.Field_Execution_Dollars />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Field_Execution_Dollars'] = 0 />
			</cfif>
			<!--- for distributor trade and shelter --->
			<cfif isDefined("arguments.Distributor_Trade_Shelter_Cases") >
				<cfset this.programTotal[trim(arguments.Program)]['Distributor_Trade_Shelter_Cases'] = arguments.Distributor_Trade_Shelter_Cases />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Distributor_Trade_Shelter_Cases'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Distributor_Trade_Shelter_Dollars") >
				<cfset this.programTotal[trim(arguments.Program)]['Distributor_Trade_Shelter_Dollars'] = arguments.Distributor_Trade_Shelter_Dollars />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Distributor_Trade_Shelter_Dollars'] = 0 />
			</cfif>

			<cfif isDefined("arguments.Operator_Direct_Or_Hq_Programs_Cases") >
				<cfset this.programTotal[trim(arguments.Program)]['Operator_Direct_Or_Hq_Programs_Cases'] = arguments.Operator_Direct_Or_Hq_Programs_Cases />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Operator_Direct_Or_Hq_Programs_Cases'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Operator_Direct_Or_Hq_Programs_Dollars") >
				<cfset this.programTotal[trim(arguments.Program)]['Operator_Direct_Or_Hq_Programs_Dollars'] = arguments.Operator_Direct_Or_Hq_Programs_Dollars />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Operator_Direct_Or_Hq_Programs_Dollars'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Operator_Deviated_Pricing_Cases") >
				<cfset this.programTotal[trim(arguments.Program)]['Operator_Deviated_Pricing_Cases'] = arguments.Operator_Deviated_Pricing_Cases />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Operator_Deviated_Pricing_Cases'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Operator_Deviated_Pricing_Dollars") >
				<cfset this.programTotal[trim(arguments.Program)]['Operator_Deviated_Pricing_Dollars'] = arguments.Operator_Deviated_Pricing_Dollars />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Operator_Deviated_Pricing_Dollars'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Total_Cases") >
				<cfset this.programTotal[trim(arguments.Program)]['Total_Cases'] = arguments.Total_Cases />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Total_Cases'] = 0 />
			</cfif>
			<cfif isDefined("arguments.Total_Dollars") >
				<cfset this.programTotal[trim(arguments.Program)]['Total_Dollars'] = arguments.Total_Dollars />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Total_Dollars'] = 0 />
			</cfif>
			<cfif Not isDefined("arguments.ProcessedClaims") >
				<cfset this.programTotal[trim(arguments.Program)]['ProcessedClaims'] = 0 />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['ProcessedClaims'] = arguments.ProcessedClaims />
			</cfif>
			<cfif Not isDefined("arguments.Avg_PD_VS_RD_Days") >
				<cfset this.programTotal[trim(arguments.Program)]['Avg_PD_VS_RD_Days'] = 0 />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Avg_PD_VS_RD_Days'] = arguments.Avg_PD_VS_RD_Days />
			</cfif>
			<cfif Not isDefined("arguments.Avg_RD_VS_ED_Days") >
				<cfset this.programTotal[trim(arguments.Program)]['Avg_RD_VS_ED_Days'] = 0 />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Avg_RD_VS_ED_Days'] = arguments.Avg_RD_VS_ED_Days />
			</cfif>
			<cfif Not isDefined("arguments.Avg_ED_VS_CD_Days") >
				<cfset this.programTotal[trim(arguments.Program)]['Avg_ED_VS_CD_Days'] = 0 />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Avg_ED_VS_CD_Days'] = arguments.Avg_ED_VS_CD_Days />
			</cfif>
			<cfif Not isDefined("arguments.Avg_CD_VS_PD_Days") >
				<cfset this.programTotal[trim(arguments.Program)]['Avg_CD_VS_PD_Days'] = 0 />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['Avg_CD_VS_PD_Days'] = arguments.Avg_CD_VS_PD_Days />
			</cfif>
			<!---for cost saving --->
			<cfif Not isDefined("arguments.variation$") >
				<cfset this.programTotal[trim(arguments.Program)]['variation$'] = 0 />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['variation$'] = arguments.variation$ />
			</cfif>
			<cfif Not isDefined("arguments.variationCS") >
				<cfset this.programTotal[trim(arguments.Program)]['variationCS'] = 0 />
			<cfelse>
				<cfset this.programTotal[trim(arguments.Program)]['variationCS'] = arguments.variationCS />
			</cfif>
		<cfelseif ListLen(arguments.Program, "|") GT 1>
			<cfset firstLevelSumFld = ListGetAt(arguments.program, 1, "|") />
			<cfset secondLevelSumFld = ListGetAt(arguments.program,2, "|") />
			<cfif ListLen(arguments.Program, "|") GT 2>
				<cfset thirdLevelSumFld = ListGetAt(arguments.program,3, "|") />
			</cfif>

			<!---- be aware at second level, all key value should be built at the first level ---->
			<cfif StructKeyExists(this.programTotal, trim(firstLevelSumFld)) and Not StructKeyExists(this.programTotal[trim(firstLevelSumFld)], trim(secondLevelSumFld)) >
				<!---<cfset this.programTotal[firstLevelSumFld][secondLevelSumFld]  = structNew() />--->
				<cfif isDefined("arguments.Bid_Request_Cases") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Bid_Request_Cases'] = arguments.Bid_Request_Cases />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Bid_Request_Cases'] = 0 />
				</cfif>
				<cfif isDefined("arguments.Bid_Request_Dollars") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Bid_Request_Dollars'] = arguments.Bid_Request_Dollars />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Bid_Request_Dollars'] = 0 />
				</cfif>
				<cfif isDefined("arguments.Field_Execution_Cases") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Field_Execution_Cases'] = arguments.Field_Execution_Cases />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Field_Execution_Cases'] = 0 />
				</cfif>
				<cfif isDefined("arguments.Field_Execution_Dollars") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Field_Execution_Dollars'] = arguments.Field_Execution_Dollars />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Field_Execution_Dollars'] = 0 />
				</cfif>
				<!--- for distributor trade and shelter --->
				<cfif isDefined("arguments.Distributor_Trade_Shelter_Cases") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Distributor_Trade_Shelter_Cases'] = arguments.Distributor_Trade_Shelter_Cases />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Distributor_Trade_Shelter_Cases'] = 0 />
				</cfif>

				<cfif isDefined("arguments.Distributor_Trade_Shelter_Dollars") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Distributor_Trade_Shelter_Dollars'] = arguments.Distributor_Trade_Shelter_Dollars />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Distributor_Trade_Shelter_Dollars'] = 0 />
				</cfif>

				<cfif isDefined("arguments.Operator_Direct_Or_Hq_Programs_Cases") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Operator_Direct_Or_Hq_Programs_Cases'] = arguments.Operator_Direct_Or_Hq_Programs_Cases />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Operator_Direct_Or_Hq_Programs_Cases'] = 0 />
				</cfif>
				<cfif isDefined("arguments.Operator_Direct_Or_Hq_Programs_Dollars") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Operator_Direct_Or_Hq_Programs_Dollars'] = arguments.Operator_Direct_Or_Hq_Programs_Dollars />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Operator_Direct_Or_Hq_Programs_Dollars'] = 0 />
				</cfif>
				<cfif isDefined("arguments.Operator_Deviated_Pricing_Cases") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Operator_Deviated_Pricing_Cases'] = arguments.Operator_Deviated_Pricing_Cases />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Operator_Deviated_Pricing_Cases'] = 0 />
				</cfif>
				<cfif isDefined("arguments.Operator_Deviated_Pricing_Dollars") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Operator_Deviated_Pricing_Dollars'] = arguments.Operator_Deviated_Pricing_Dollars />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Operator_Deviated_Pricing_Dollars'] = 0 />
				</cfif>
				<cfif isDefined("arguments.Total_Cases") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Total_Cases'] = arguments.Total_Cases />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Total_Cases'] = 0 />
				</cfif>
				<cfif isDefined("arguments.Total_Dollars") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Total_Dollars'] = arguments.Total_Dollars />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['Total_Dollars'] = 0 />
				</cfif>
				<!--- start for cost saving --->
				<cfif isDefined("arguments.Paid_Amount") >
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['Paid_Amount'] = arguments.Paid_Amount />
				<cfelse>
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['Paid_Amount'] = 0 />
				</cfif>
				<cfif isDefined("arguments.Claim_Amount") >
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['Claim_Amount'] = arguments.Claim_Amount />
				<cfelse>
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['Claim_Amount'] = 0 />
				</cfif>
				<cfif isDefined("arguments.PaidCS") >
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['PaidCS'] = arguments.PaidCS />
				<cfelse>
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['PaidCS'] = 0 />
				</cfif>
				<cfif isDefined("arguments.ClaimCS") >
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['ClaimCS'] = arguments.ClaimCS />
				<cfelse>
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['ClaimCS'] = 0 />
				</cfif>
				<cfif Not isDefined("arguments.variation$") >
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['variation$'] = 0 />
				<cfelse>
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['variation$'] = arguments.variation$ />
				</cfif>
				<cfif Not isDefined("arguments.variationCS") >
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['variationCS'] = 0 />
				<cfelse>
					<cfset this.programTotal[trim(arguments.Program)][trim(secondLevelSumFld)]['variationCS'] = arguments.variationCS />
				</cfif>
				<!---- end for cost saving --->
				<cfif isDefined("arguments.SecondLevelCount") >
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['SecondLevelCount'] = arguments.SecondLevelCount />
				<cfelse>
					<cfset this.programTotal[trim(firstLevelSumFld)][trim(secondLevelSumFld)]['SecondLevelCount'] = 0 />
				</cfif>
			</cfif>
		</cfif>
	</cffunction>

	<!---- getAccessibleBillbackIDS are those billback ids that can only be accessible in the current user position --->
	<cffunction name="getAccessibleBillbackIDs" output="false" returntype="string">
		<cfargument name="user_id" 			type="string" required="false"  />
		<cfargument name="positionsBelow" 	type="string" required="false"  />
		<cfargument name="UniqueUserTime" 	type="string" required="false"  />

		<!------ Get application settings ----->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>

		<cfset Temptablename = "####" & arguments.UniqueUserTime>

		<CFQUERY NAME="All_Accessible_Billbacks" DATASOURCE="#APPLICATION.DATASOURCE#">
			create table #Temptablename#
		(
			Billback_ID varchar(36)
		)

			INSERT INTO #Temptablename#
			(
				Billback_ID
			)
			SELECT  CASE WHEN User_Positions.User_Positions_ID IS NULL THEN '' ELSE CAST(bb.Billback_ID AS VARCHAR(36)) END AS Accessible_Billback_ID
			FROM	Billback bb
			LEFT JOIN	(	Billback_Distributor
							LEFT JOIN 	BSA_Foodservice_Customers
									ON 	Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						)
					ON
						(	Billback_Distributor.Billback_ID = bb.Billback_ID
							AND	bb.Billback_Payee_Type_ID = 1
							AND	Billback_Distributor.Deleted = 0
						)
			LEFT JOIN	Billback_Broker
					ON	(	Billback_Broker.Billback_ID = bb.Billback_ID
							AND	bb.Billback_Payee_Type_ID = 3
							AND	Billback_Broker.Deleted = 0
						)
			LEFT JOIN	BSA_Foodservice_Brokers
					ON	(	Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
							<cfif NOT appSettings.getDistributorMultiPosition()>
							OR	BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
							</cfif>
						)
			<cfif appSettings.getDistributorMultiPosition()>
			LEFT JOIN	Market_Distributor
					ON 		Market_Distributor.Deleted = 0
							AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Market_Distributor.Distributor_ID
			</cfif>
			LEFT JOIN	User_Positions
					ON (
							(
								BSA_Foodservice_Brokers.Service_Market_ID = User_Positions.Service_Market_ID
								OR	bb.BB_Creator_User_Position_ID = User_Positions.User_Positions_ID
								<cfif appSettings.getDistributorMultiPosition()>
								OR 	Market_Distributor.Service_Market_ID = User_Positions.Service_Market_ID
								</cfif>
							)
							AND	User_Positions.User_Positions_ID IN (#arguments.positionsBelow#)
						)
			WHERE
			bb.Deleted = 0
		</CFQUERY>


		<cfreturn Temptablename />

		<!---BJF D8930: Creating a temp table holding bb ids instead of creating a list. The list is timing out when there are a lot of billbacks --->

		<!--- <CFIF All_Accessible_Billbacks.recordCount GT 0>
			<cfset this.BillbackIDs = 	listqualify(valuelist(All_Accessible_Billbacks.Accessible_Billback_ID), chr(39))>
		</CFIF>
		<cfreturn this.BillbackIDs /> --->
	</cffunction>
	   <!--- end getAccessibleBillbackIDs --->

	<cffunction name="getThisClaimSummary" output="false" returntype="string">
		<cfargument name="reportName" 		type="string" default="" required="true">
		<cfargument name="Aging_Days"		type="numeric" 	required="true"  />
		<cfargument name="userPosition" 	type="string" 	required="true"  />
		<cfargument name="accessibleBBIds" 	type="string" 	required="true"  />
		<cfargument name="BBIDRecordcounts"	type="numeric" 	required="false"  />
		<cfargument name="UniqueUserTime"	type="string" 	required="false"  />

		<!----<cfdump var = #arguments.claimForm#><cfabort>--->
		<cfswitch expression="#Ucase(left(trim(arguments.reportName), 1))#">
			<cfcase value="C">
				<cfset this.claimSummary = this.getClaimSummaryNew(arguments.Aging_Days, arguments.userPosition, arguments.accessibleBBIds, arguments.BBIDRecordcounts, arguments.UniqueUserTime) />
			</cfcase>
			<cfcase value="V">
				<cfset this.claimSummary = this.getVarietySummary(arguments.Aging_Days, arguments.userPosition, arguments.accessibleBBIds, arguments.BBIDRecordcounts, arguments.UniqueUserTime) />
			</cfcase>
			<cfcase value="T">
				<cfset this.claimSummary = this.getTimeProcessingSummary(arguments.Aging_Days, arguments.userPosition, arguments.accessibleBBIds, arguments.BBIDRecordcounts, arguments.UniqueUserTime) />
			</cfcase>
			<cfcase value="P">
				<cfset this.claimSummary = this.getParticipationSummary(arguments.Aging_Days, arguments.userPosition, arguments.accessibleBBIds, arguments.BBIDRecordcounts, arguments.UniqueUserTime) />
			</cfcase>
			<cfcase value="S">
				<cfset this.claimSummary = this.getCostSavingSummary(arguments.Aging_Days, arguments.userPosition, arguments.accessibleBBIds, arguments.BBIDRecordcounts, arguments.UniqueUserTime) />
			</cfcase>
		</cfswitch>
		<cfreturn this.claimSummary />
	</cffunction>

	<cffunction name="getThisFilteredClaimSummary" output="false" returntype="query">
		<cfargument name="reallyuniquename" 	type="string" required="true" />
		<cfargument name="claimForm" 		type="struct" required="true"  />

		<!--- get the list of billbacks from the given criteria--->
		<!--- Greater_Or_Equal,Equal,Less_Or_Equal---->
		<CFQUERY NAME="qryGetFilteredBillbackIDs" DATASOURCE="#application.datasource#">
			select distinct *
			from (
					select distinct billback.billback_id,
					 CASE 	WHEN Billback.Billback_Payee_Type_ID = 1 THEN BSA_Foodservice_Customers.Name
					 		Else 'Unknown Customer'
					 END AS Customer_Name,
					 ISNull(BB_Approved.BB_Amount, 0) AS Claim_Amount
					from billback
					LEFT JOIN (	Billback_Distributor
								LEFT JOIN BSA_Foodservice_Customers
										ON Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
							   	LEFT JOIN invoice_header
										ON	invoice_header.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
							   			AND invoice_header.deleted = 0
							   	LEFT JOIN BSA_Foodservice_Brokers
										ON BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
							   )
						   ON (	Billback_Distributor.Billback_ID = Billback.Billback_ID
								AND (	Billback.Billback_Payee_Type_ID = 1
										OR Billback.Billback_Payee_Type_ID = 5
									)
								AND Billback_Distributor.Deleted = 0
							   )
					LEFT JOIN	BB_Approved
							ON BB_Approved.Billback_ID = Billback.Billback_ID
					LEFT JOIN  vendor_dist_oper
							ON vendor_dist_oper.Vendor_Dist_Oper_ID = BB_Approved.Vendor_Dist_Oper_ID
					LEFT JOIN ( Billback_Program
								LEFT JOIN Contract_Main ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
							  )
						   ON (	Billback_Program.Billback_ID = Billback.Billback_ID
								AND Billback_Program.Deleted = 0
							  )
					LEFT JOIN Program_Control_Panel_Options
							ON 	Contract_Main.programType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
							AND	Program_Control_Panel_Options.Deleted = 0
					LEFT JOIN	service_zones
							ON service_zones.service_zone_id = BSA_Foodservice_Brokers.service_zone_id
							AND service_zones.deleted = 0
					LEFT JOIN	service_regions
							ON  service_regions.service_region_id = BSA_Foodservice_Brokers.service_region_id
							AND service_regions.deleted = 0
					LEFT JOIN	service_markets
							ON service_markets.service_market_id = BSA_Foodservice_Brokers.service_market_id
							AND service_regions.deleted = 0
					where billback.billback_id in (select Billback_ID FROM #arguments.reallyuniquename#)
					<!-----------------------DATE -------------------->
					<cfif arguments.claimForm.BB_Operator NEQ "">
						and billback.BB_Date <cfif arguments.claimForm.BB_Operator EQ "Greater_Or_Equal"> >= <cfelseif arguments.claimForm.BB_Operator EQ "Less_Or_Equal"> <= <cfelse> = </cfif> '#arguments.claimForm.BB_DATE#'
					</cfif>
					<cfif arguments.claimForm.BB_DELIVERSTART_OPERATOR NEQ "">
						and billback.BB_Start_Date <cfif arguments.claimForm.BB_DELIVERSTART_OPERATOR EQ "Greater_Or_Equal"> >= <cfelseif arguments.claimForm.BB_DELIVERSTART_OPERATOR EQ "Less_Or_Equal"> <= <cfelse> = </cfif> '#arguments.claimForm.BB_DELIVERSTART#'
					</cfif>
					<cfif arguments.claimForm.BB_DELIVEREND_OPERATOR NEQ "">
						and billback.BB_End_Date <cfif arguments.claimForm.BB_DELIVEREND_OPERATOR EQ "Greater_Or_Equal"> >= <cfelseif arguments.claimForm.BB_DELIVEREND_OPERATOR EQ "Less_Or_Equal"> <= <cfelse> = </cfif> '#arguments.claimForm.BB_DELIVEREND#'
					</cfif>
					<!--------- CLAIM STATUS ----------->
					<cfif isDefined("arguments.claimForm.claimStatus") and (arguments.claimForm.claimStatus NEQ "0" or arguments.claimForm.claimStatus NEQ "")>
						and billback.billback_status_id in (#arguments.claimForm.claimStatus#)
					</cfif>
					<cfif isDefined("arguments.claimForm.templateTypes") and (arguments.claimForm.templateTypes NEQ "0" or arguments.claimForm.templateTypes NEQ "")>
						and Program_Control_Panel_Options.Generic_Type in ( #trim(ListQualify(arguments.claimForm.templateTypes,"'",",","ALL"))# )
					</cfif>
					<!---------- CUSTOMER INVOICE ------------>
					<!--- customer invoice# (waiting) --->
					<cfif isDefined("arguments.claimForm.custInvoice") and arguments.claimForm.custInvoice NEQ "">
						and invoice_header.order_number like '%#trim(arguments.claimForm.custInvoice)#%'
					</cfif>
					<!--- check # (waiting) --->
					<!----------- Vendor ID ----------------->
					<cfif isDefined("arguments.claimForm.vendorID") and arguments.claimForm.vendorID NEQ "">
						and vendor_dist_oper.Vendor_ID like '%#arguments.claimForm.vendorID#%'
					</cfif>
					<!--------- GEOGRAPHY  LEVEL ------->
					<!--- zone --->
					<cfif isDefined("arguments.claimForm.Service_Zone_ID") and arguments.claimForm.Service_Zone_ID NEQ 0 >
						and service_zones.service_zone_id like '%#arguments.claimForm.Service_Zone_ID#%'
					</cfif>
					<!--- region --->
					<cfif isDefined("arguments.claimForm.Service_Region_ID") and arguments.claimForm.Service_Region_ID NEQ 0 >
						and service_regions.service_region_id like '%#arguments.claimForm.Service_Region_ID#%'
					</cfif>
					<!--- market --->
					<cfif isDefined("arguments.claimForm.Service_Market_ID") and arguments.claimForm.Service_Market_ID NEQ 0 >
						and service_markets.service_market_id like '%#arguments.claimForm.Service_Market_ID#%'
					</cfif>
					<!---- operator and Distributor ID (Sold To)---->
					<cfif isDefined("arguments.claimForm.soldToNo") and arguments.claimForm.soldToNo NEQ "" >
						and billback.billback_id in (select distinct billback_id from Claim_Payee_IDs where soldToNo like '%#arguments.claimForm.soldToNo#%')
					</cfif>

					<cfif isDefined("arguments.claimForm.operatorNo") and arguments.claimForm.operatorNo NEQ "" >
						and billback.billback_id in (select distinct billback_id from Claim_Payee_IDs where operatorID like '#arguments.claimForm.operatorNo#%')
					</cfif>
					<!--------- OWNERSHIP  LEVEL ------->
					<!--- ownership --->
					<cfset userPosition = 0 />
					<cfif isDefined("arguments.claimForm.User_Position") and arguments.claimForm.User_Position NEQ 0>
						<cfset userPosition = arguments.claimForm.User_Position />
					 <cfelseif isDefined("arguments.claimForm.User_Position_Of") and arguments.claimForm.User_Position_Of NEQ 0>
						<cfset userPosition = arguments.claimForm.User_Position_Of />
					</cfif>
					<cfif userPosition NEQ "" or  arguments.claimForm.SELECTEDUSER NEQ "">
						<CFSWITCH EXPRESSION="#arguments.claimForm.User_Position_Operator#">
							<CFCASE VALUE="Created By">
							<cfif isDefined("arguments.claimForm.SELECTEDUSER") and arguments.claimForm.SELECTEDUSER NEQ "">
								AND Billback.BB_Creator_ID = '#arguments.claimForm.SELECTEDUSER#'
							</cfif>
								AND billback.BB_Creator_User_Position_ID = '#userPosition#'
							</CFCASE>
							<CFCASE VALUE="Requesting Approval By">
							<cfif isDefined("arguments.claimForm.SELECTEDUSER") and arguments.claimForm.SELECTEDUSER NEQ "">
								AND Billback.BB_Request_Approval_User_ID = '#arguments.claimForm.SELECTEDUSER#'
							</cfif>
								AND EXISTS
										(
											SELECT 	User_Positions_ID
											FROM	User_Position_Holders
											WHERE	User_Position_Holders.User_ID = Billback.BB_Request_Approval_User_ID
													AND User_Position_Holders.Deleted = 0
													AND User_Position_Holders.User_Positions_ID = '#userPosition#'
										)
							</CFCASE>
							<CFCASE VALUE="Approved By">
							<cfif isDefined("arguments.claimForm.SELECTEDUSER") and arguments.claimForm.SELECTEDUSER NEQ "">
								AND BB_Approved.User_Approved = '#arguments.claimForm.SELECTEDUSER#'
							</cfif>
								AND EXISTS
										(
											SELECT 	User_Positions_ID
											FROM	User_Position_Holders
											WHERE
													User_Position_Holders.User_ID = BB_Approved.User_Approved
													AND
													User_Position_Holders.Deleted = 0
													AND User_Position_Holders.User_Positions_ID = '#userPosition#'
										)
							</CFCASE>
						</CFSWITCH>
					</cfif>
					<!--- handle discount identifier --->
					<cfif isDefined("arguments.claimForm.Discount_Identifier") and arguments.claimForm.Discount_Identifier NEQ 0>
						and billback.billback_id in
						(
							select distinct billback.billback_id
							from billback
							inner join billback_program
									on billback.billback_id = billback_program.billback_id
									and billback_program.deleted = 0
							INNER JOIN	Contract_Main
									on  Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
							INNER JOIN Program_Control_Panel_Options
									ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
									AND Program_Control_Panel_Options.Discount_Identifier_ID = '#arguments.claimForm.Discount_Identifier#'
						)
					</cfif>

				) AS filteredClaimTable
				where 0 = 0
				<!---------- CUSTOMER NAME ------------->
				<cfif isDefined("arguments.claimForm.custName") and arguments.claimForm.custName NEQ "">
					and Customer_Name like '%#arguments.claimForm.custName#%'
				</cfif>
				<!--------- Amount --------->
				<cfif isDefined("arguments.claimForm.Amount_Operator") and arguments.claimForm.Amount_Operator NEQ "">
					and Claim_Amount <cfif arguments.claimForm.Amount_Operator EQ "Greater_Or_Equal"> >= <cfelseif arguments.claimForm.Amount_Operator EQ "Less_Or_Equal"> <= <cfelse> = </cfif> #arguments.claimForm.claimAmount#
				</cfif>
		</CFQUERY>
		<cfif qryGetFilteredBillbackIDs.recordCount GT 0 >
			<cfset this.FilteredBillbackIDs = valueList(qryGetFilteredBillbackIDs.billback_id) />
		</cfif>
		<!--- select those summary list satisfying the above billbacks ---->
		<cfquery datasource="#application.datasource#" name="queryGetThisFilteredClaimSummary">
			select *
			from #arguments.reallyuniquename#
			where billback_id in ( <cfif qryGetFilteredBillbackIDs.billback_id EQ "">null<cfelse>#trim(ListQualify(valueList(qryGetFilteredBillbackIDs.billback_id),"'",",","ALL"))#</cfif> )
			<!---- operator id---->
			<cfif isDefined("arguments.claimForm.operatorNo") and arguments.claimForm.operatorNo NEQ "" >
				and end_user like '#trim(arguments.claimForm.operatorNo)#%'
			</cfif>
			<!--- operator name --->
			<cfif isDefined("arguments.claimForm.operatorName") and arguments.claimForm.operatorName NEQ "" >
				and end_user_name like '#trim(arguments.claimForm.operatorName)#%'
			</cfif>


		</cfquery>
		<cfreturn queryGetThisFilteredClaimSummary />
	</cffunction>

	<!--- retrieve all the eligible billbacks including those for distributor, broker and operator ---->
	<!--- not considering sorting for now --->
	<cffunction name="getClaimSummaryNew" output="false" returntype="string">
		<!---------------------- required portion --------------------------->
		<cfargument name="Aging_Days"		type="numeric" 	required="true"  />
		<cfargument name="userPosition" 	type="string" 	required="true"  />
		<cfargument name="accessibleBBIds" 	type="string" 	required="true"  />
		<cfargument name="BBIDRecordcounts"	type="numeric" 	required="false"  default="0"/>
		<cfargument name="UniqueUserTime"	type="string" 	required="false"  />

		<!-------------- this portion for generic use ------------------------>

		<cfset TemptablenameCS = "####BB2_" & arguments.UniqueUserTime>

		<CFQUERY NAME="qryGetClaimSummary" DATASOURCE="#application.datasource#">

				select Billback_ID,
					isnull(cust_id, 9999) as cust_id,
					isnull(cust_name,'unknown customer') as cust_name,
					region_name,
					market_name,
					end_user,
					end_user_name,
					claimNo,
					BB_Reference,
					BB_Date,
					BB_Start_Date,
					BB_End_Date,
					UserID,
					Hold,
					BB_Status,
					Paid_Amount,
					PaidCS,
					(select top 1 generic_type from Program_Control_Panel_Options where ProgramControl_Panel_Options_ID in (select top 1 programType_ID from contract_main where contract_main_id in (select top 1 program_id from billback_program where billback_id = X.billback_id) )) as claimTemplateType,
					(select top 1 created_Type from Program_Control_Panel_Options where ProgramControl_Panel_Options_ID in (select top 1 programType_ID from contract_main where contract_main_id in (select top 1 program_id from billback_program where billback_id = X.billback_id) )) as claimTemplateName
	into #TemptablenameCS#
				from (
				SELECT 	distinct
					Claim_Summary_Report.Billback_ID,
					cust_id,
					cust_name,
					region_name,
					market_name,
					end_user,
					end_user_name,
					claimNo,
					BB_Reference,
					BB_Date,
					BB_Start_Date,
					BB_End_Date,
					UserID,
					Hold,
					BB_Status,
					isnull(Paid_Amount, 0) AS Paid_Amount,
					isnull(sum(bb_item_final.item_volume_paid_cs), 0) as PaidCS
				FROM Claim_Summary_Report
				LEFT JOIN BB_Item_Final
					ON  BB_Item_Final.billback_id = Claim_Summary_Report.billback_id
				left join billback_program
					on  billback_program.billback_id = bb_item_final.billback_id
					and billback_program.billback_program_id = bb_item_final.billback_program_id
				WHERE		Claim_Summary_Report.User_Position_ID IN (#arguments.userPosition#)
				<Cfif BBIDRecordcounts IS 0>
				<cfif listlen(arguments.accessibleBBIds) GT 0>
					OR Claim_Summary_Report.Billback_ID IN (#preservesinglequotes(arguments.accessibleBBIds)#)
				</cfif>
			<CFELSE>
				OR cast(Claim_Summary_Report.Billback_ID as varchar(36)) IN (SELECT Billback_ID FROM #arguments.accessibleBBIds#)
			</CFIF>
			group by Claim_Summary_Report.Billback_ID,cust_id,cust_name,region_name,market_name,
				end_user,end_user_name,
				claimNo,BB_Reference,
				BB_Date,BB_Start_Date,BB_End_Date,
				UserID,Hold,BB_Status,Paid_Amount
				) X
			<!--- order by 2,3,8 --->
		</CFQUERY>
		<cfreturn TemptablenameCS />
	</cffunction>

	<cffunction name="getVarietySummary" output="false" returntype="string">
		<!---------------------- required portion --------------------------->
		<cfargument name="Aging_Days"		type="numeric" 	required="true"  />
		<cfargument name="userPosition" 	type="string" 	required="true"  />
		<cfargument name="accessibleBBIds" 	type="string" 	required="true"  />
		<cfargument name="BBIDRecordcounts"	type="numeric" 	required="false"  default="0"/>
		<cfargument name="UniqueUserTime"	type="string" 	required="false"  />
		<!-------------- this portion for generic use ------------------------>
		<cfset TemptablenameV = "####BB2_" & arguments.UniqueUserTime>

		<CFQUERY NAME="qryGetVarietySummary" DATASOURCE="#application.datasource#">
			select distinct Program_Title,
				Program,
				Region_Name,
				Dist_ID,
				Dist_Name,
				End_User,
				End_User_Name,
				X.Billback_ID,
				claimNo,
				Delivery_Period,
				User_Position_ID,
				Paid_Amount,
				Claim_Amount,
				isnull(sum(bb_item_final.item_volume_paid_cs), 0) as PaidCS,
				isnull(sum(bb_item_final.item_bb_volume_cs), 0) as ClaimCS
			into #TemptablenameV#
			from
			(
				SELECT 	distinct
					isnull(claim_variety_summary_report.Program_Title,'Unknown Program') AS Program_Title,
					isnull(claim_variety_summary_report.Program,'Unknown Program') AS Program,
					claim_variety_summary_report.Region_Name,
					claim_variety_summary_report.Cust_ID AS Dist_ID,
					claim_variety_summary_report.Cust_Name AS Dist_Name,
					claim_variety_summary_report.End_User,
					claim_variety_summary_report.End_User_Name,
					claim_variety_summary_report.Billback_ID,
					claim_variety_summary_report.claimNo,
					cast(convert(varchar, claim_variety_summary_report.BB_Start_Date, 101) AS varchar) + ' - ' +
					cast(convert(varchar,claim_variety_summary_report.BB_End_Date, 101) AS varchar) AS Delivery_Period,
					claim_variety_summary_report.User_Position_ID,
					claim_variety_summary_report.Paid_Amount,
					claim_variety_summary_report.Claim_Amount
				FROM claim_variety_summary_report
			) AS X
			LEFT JOIN BB_Item_Final
				ON  BB_Item_Final.billback_id = X.billback_id
			left join billback_program
				on  billback_program.billback_id = bb_item_final.billback_id
				and billback_program.billback_program_id = bb_item_final.billback_program_id
			WHERE	X.User_Position_ID = '#arguments.userPosition#'
					<Cfif BBIDRecordcounts IS 0>
						<cfif listlen(arguments.accessibleBBIds) GT 0>
							OR X.Billback_ID IN (#preservesinglequotes(arguments.accessibleBBIds)#)
						</cfif>
					<CFELSE>
						OR cast(X.Billback_ID as varchar(36)) IN (SELECT Billback_ID FROM #arguments.accessibleBBIds#)
					</CFIF>
			group by  	Program_Title,
					Program,
					Region_Name,
					Dist_ID,
					Dist_Name,
					X.Billback_ID,
					X.End_User,
					X.End_User_Name,
					claimNo,
					Delivery_Period,
					User_Position_ID,
					Paid_Amount,
					Claim_Amount
			 order by 2,7
		</CFQUERY>
		<cfreturn TemptablenameV />
	</cffunction>

	<cffunction name="getParticipationSummary" output="false" returntype="string">
		<!---------------------- required portion --------------------------->
		<cfargument name="Aging_Days"		type="numeric" 	required="true"  />
		<cfargument name="userPosition" 	type="string" 	required="true"  />
		<cfargument name="accessibleBBIds" 	type="string" 	required="true"  />
		<cfargument name="BBIDRecordcounts"	type="numeric" 	required="false"  default="0"/>
		<cfargument name="UniqueUserTime"	type="string" 	required="false"  />
		<!-------------- this portion for generic use ------------------------>
		<cfset TemptablenamePS = "####BB2_" & arguments.UniqueUserTime>

		<CFQUERY NAME="qryGetParticipationSummary" DATASOURCE="#application.datasource#">
			select 	distinct
					region_name,
					market_name,
					cust_id,
					cust_name,
					item_number,
					billback_id,
					claimNo,
					user_position_id,
					description,

					bid_request_cases,
					bid_request_dollars,
					field_execution_cases,
					field_execution_dollars,
					distributor_trade_shelter_cases,
					distributor_trade_shelter_dollars,
					operator_direct_or_hq_programs_cases,
					operator_direct_or_hq_programs_dollars,
					operator_deviated_pricing_cases,
					operator_deviated_pricing_dollars,
					total_cases,
					total_dollars
				into #TemptablenamePS#
			from claim_participation_basic_report
			order by 1,2,4
	</CFQUERY>
		<cfreturn TemptablenamePS />
	</cffunction>

	<cffunction name="getCostSavingSummary" output="false" returntype="string">
		<!---------------------- required portion --------------------------->
		<cfargument name="Aging_Days"		type="numeric" 	required="true"  />
		<cfargument name="userPosition" 	type="string" 	required="true"  />
		<cfargument name="accessibleBBIds" 	type="string" 	required="true"  />
		<cfargument name="BBIDRecordcounts"	type="numeric" 	required="false"  default="0"/>
		<cfargument name="UniqueUserTime"	type="string" 	required="false"  />
		<!-------------- this portion for generic use ------------------------>
		<cfset TemptablenameCS = "####BB2_" & arguments.UniqueUserTime>

		<CFQUERY NAME="qryGetCostSavingSummary" DATASOURCE="#application.datasource#">
			select distinct
					isnull(Cust_Name, 'Not Available') AS Cust_Name,
					Cust_ID,
					claimNo,
					claim_cost_saving_total.billback_id,
					region_name,
					market_name,
					operator_id,
					operator_name,
					reference,
					credit_memo,
					claim_Amount,
					Paid_Amount,
					variation$,
					PaidCS,
					claimCS,
					variationCS
				INTO #TemptablenameCS#
			from claim_cost_saving_total
			WHERE  claim_cost_saving_total.User_Position_ID = '#arguments.userPosition#'
					<Cfif BBIDRecordcounts IS 0>
						<cfif listlen(arguments.accessibleBBIds) GT 0>
							OR claim_cost_saving_total.Billback_ID IN (#preservesinglequotes(arguments.accessibleBBIds)#)
						</cfif>
					<CFELSE>
						OR cast(claim_cost_saving_total.Billback_ID as varchar(36)) IN (SELECT Billback_ID FROM #arguments.accessibleBBIds#)
					</CFIF>
			group by  	Cust_Name, Cust_ID,
						claimNo, claim_cost_saving_total.billback_id,
						region_name, market_name,
						operator_id,operator_name,
						reference,credit_memo,
						claim_Amount,Paid_Amount,variation$,
						PaidCS,claimCS,variationCS
			order by 5,6,2
		</CFQUERY>
		<cfreturn TemptablenameCS />
	</cffunction>

	<cffunction name="getTimeProcessingSummary" output="false" returntype="string">
		<!---------------------- required portion --------------------------->
		<cfargument name="Aging_Days"		type="numeric" 	required="true"  />
		<cfargument name="userPosition" 	type="string" 	required="true"  />
		<cfargument name="accessibleBBIds" 	type="string" 	required="true"  />
		<cfargument name="BBIDRecordcounts"	type="numeric" 	required="false"  default="0"/>
		<cfargument name="UniqueUserTime"	type="string" 	required="false"  />
		<!-------------- this portion for generic use ------------------------>
		<cfset TemptablenameTP = "####BB2_" & arguments.UniqueUserTime>

		<CFQUERY NAME="qryGetTimeProcessingSummary" DATASOURCE="#application.datasource#">
			select distinct
				isnull(Cust_Name, 'Unknown Customer') AS Cust_Name,
				isnull(Cust_ID, '999999999') AS Cust_ID,
				claimNo,
				claim_time_processing_report.billback_id,
				isnull(region_name, 'Unknown Region') AS region_name,
				isnull(market_name, 'Unknown Market') AS market_name,
				operator_id,
				operator_name,
				postmark_date,
				isnull(PD_VS_RD_Days,0) AS PD_VS_RD_Days,
				BB_Received_Date,
				isnull(RD_VS_ED_Days, 0) AS RD_VS_ED_Days,
				BB_Date,
				isnull(ED_VS_CD_Days, 0) AS ED_VS_CD_Days,
				BB_Check_Date,
				isnull(ED_VS_CD_Days, 0) AS CD_VS_PD_Days,
				Paid_Amount,
				claim_Amount,
				isnull(sum(bb_item_final.item_volume_paid_cs), 0) AS PaidCS,
				isnull(sum(bb_item_final.item_bb_volume_cs), 0) AS claimCS
				INTO #TemptablenameTP#
			from claim_time_processing_report
			LEFT JOIN BB_Item_Final
				ON  BB_Item_Final.billback_id = claim_time_processing_report.billback_id
			left join billback_program
				on  billback_program.billback_id = bb_item_final.billback_id
				and billback_program.billback_program_id = bb_item_final.billback_program_id
			WHERE  claim_time_processing_report.User_Position_ID = '#arguments.userPosition#'

			<Cfif BBIDRecordcounts IS 0>
						<cfif listlen(arguments.accessibleBBIds) GT 0>
							OR claim_time_processing_report.Billback_ID IN (#preservesinglequotes(arguments.accessibleBBIds)#)
						</cfif>
					<CFELSE>
						OR cast(claim_time_processing_report.Billback_ID as varchar(36)) IN (SELECT Billback_ID FROM #arguments.accessibleBBIds#)
					</CFIF>
			group by Cust_Name,
				Cust_ID,
				claimNo,
				claim_time_processing_report.billback_id,
				region_name,
				market_name,
				operator_id,
				operator_name,
				postmark_date,
				PD_VS_RD_Days,
				BB_Received_Date,
				RD_VS_ED_Days,
				BB_Date,
				ED_VS_CD_Days,
				BB_Check_Date,
				CD_VS_PD_Days,
				Paid_Amount,
				claim_Amount
			order by 2 asc
		</CFQUERY>
		<cfreturn TemptablenameTP />
	</cffunction>

	<cffunction name="getProgramTotalPaidCS" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfreturn this.programTotal[trim(arguments.programNumber)]['PaidCS'] />
		</cfif>
	</cffunction>

	<cffunction name="getProgramTotalClaimCS" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfreturn this.programTotal[trim(arguments.programNumber)]['ClaimCS'] />
		</cfif>
	</cffunction>

	<cffunction name="getProgramTotalPaidAmount" output="false" returntype="numeric">
		<cfargument name="programNumber" type="string" 	required="true"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfreturn this.programTotal[trim(arguments.programNumber)]['Paid_Amount'] />
		</cfif>
	</cffunction>

	<cffunction name="getProgramTotalProcessed" output="false" returntype="numeric">
		<cfargument name="programNumber" type="string" 	required="true"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfreturn this.programTotal[trim(arguments.programNumber)]['ProcessedClaims'] />
		</cfif>
	</cffunction>

	<cffunction name="getProgramTotalClaimAmount" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfreturn this.programTotal[trim(arguments.programNumber)]['Claim_Amount'] />
		</cfif>
	</cffunction>

	<cffunction name="getProgramAvg_PD_VS_RD_Days" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfreturn this.programTotal[trim(arguments.programNumber)]['Avg_PD_VS_RD_Days'] />
		</cfif>
	</cffunction>

	<cffunction name="getProgramAvg_RD_VS_ED_Days" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfreturn this.programTotal[trim(arguments.programNumber)]['Avg_RD_VS_ED_Days'] />
		</cfif>
	</cffunction>

	<cffunction name="getProgramAvg_ED_VS_CD_Days" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfreturn this.programTotal[trim(arguments.programNumber)]['Avg_ED_VS_CD_Days'] />
		</cfif>
	</cffunction>

	<cffunction name="getProgramAvg_CD_VS_PD_Days" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfreturn this.programTotal[trim(arguments.programNumber)]['Avg_CD_VS_PD_Days'] />
		</cfif>
	</cffunction>

	<cffunction name="getClaimTotalDollars" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Total_Dollars'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Total_Dollars'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimTotalCases" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Total_Cases'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Total_Cases'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimOperatorDeviatedPricingDollars" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Operator_Deviated_Pricing_Dollars'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Operator_Deviated_Pricing_Dollars'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimOperatorDeviatedPricingCases" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Operator_Deviated_Pricing_Cases'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Operator_Deviated_Pricing_Cases'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimOperatorDirectOrHqProgramsDollars" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Operator_Direct_Or_Hq_Programs_Dollars'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Operator_Direct_Or_Hq_Programs_Dollars'] />
			</cfif>

		</cfif>
	</cffunction>

	<cffunction name="getClaimOperatorDirectOrHqProgramsCases" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Operator_Direct_Or_Hq_Programs_Cases'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Operator_Direct_Or_Hq_Programs_Cases'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimDistributorTradeShelterDollars" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Distributor_Trade_Shelter_Dollars'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Distributor_Trade_Shelter_Dollars'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimDistributorTradeShelterCases" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Distributor_Trade_Shelter_Cases'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Distributor_Trade_Shelter_Cases'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimFieldExecutionDollars" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Field_Execution_Dollars'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Field_Execution_Dollars'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimFieldExecutionCases" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />

		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Field_Execution_Cases'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Field_Execution_Cases'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimBidRequestDollars" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Bid_Request_Dollars'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Bid_Request_Dollars'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimBidRequestCases" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Bid_Request_Cases'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Bid_Request_Cases'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimSecondLevelCount" output="false" returntype="numeric">
		<cfargument name="programNumber" type="string" required="false"  />
		<cfargument name="secondLevelSumFld" type="string" required="false"  />
		<cfif StructKeyExists(this.programTotal, trim(arguments.programNumber)) and StructKeyExists(this.programTotal[trim(arguments.programNumber)], trim(arguments.secondLevelSumFld))>
			<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['SecondLevelCount'] />
		<cfelse>
			<cfreturn 0 />
		</cfif>
	</cffunction>

	<!--- for cost saving --->
	<cffunction name="getClaimVariation$" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['Variation$'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['Variation$'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimVariationCS" output="false" returntype="numeric">
		<cfargument name="programNumber"		type="string" 	required="true"  />
		<cfargument name="secondLevelSumFld" 	type="string" 	required="false"  />
		<cfif Not StructKeyExists(this.programTotal, trim(arguments.programNumber))>
			<cfreturn 0 />
		<cfelse>
			<cfif isDefined("arguments.secondLevelSumFld") and arguments.secondLevelSumFld NEQ "" >
				<cfreturn this.programTotal[trim(arguments.programNumber)][trim(arguments.secondLevelSumFld)]['VariationCS'] />
			<cfelse>
				<cfreturn this.programTotal[trim(arguments.programNumber)]['VariationCS'] />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getClaimSummary" output="false" returntype="query">
		<!---------------------- required portion --------------------------->
		<cfargument name="Aging_Days"		type="numeric" 	required="true"  />
		<cfargument name="userPosition" 	type="string" 	required="true"  />
		<cfargument name="accessibleBBIds" 	type="string" 	required="true"  />
		<cfargument name="BBIDRecordcounts"	type="numeric" 	required="false"  default="0"/>
		<!-------------- this portion for generic use ------------------------>
		<cfargument name="Status" 			type="numeric" 	required="false"  default="0"/>
		<cfargument name="UP" 				type="numeric" 	required="false"  default="0"/>
		<cfargument name="PNF" 				type="numeric" 	required="false"  default="0"/>
		<cfargument name="Program_Status" 	type="string" 	required="false"  default="0"/>
		<cfargument name="Generic_Type" 	type="string" 	required="false"  default="0"/>
		<cfargument name="Contract_Number" 	type="string" 	required="false"  default=""/>
		<cfargument name="Broker_ID" 		type="numeric" 	required="false"  default="0"/>
		<cfargument name="Distributor_Name" type="string" 	required="false"  default=""/>
		<cfargument name="Operator_Name" 	type="string" 	required="false"  default=""/>
		<cfargument name="Billback_Number" 	type="string" 	required="false"  default=""/>
		<cfargument name="Payable_Number" 	type="string" 	required="false"  default=""/>
		<cfargument name="Billback_Title" 	type="string" 	required="false"  default=""/>
		<cfargument name="Amount_Operator" 	type="string" 	required="false"  default="0"/>
		<cfargument name="Amount" 			type="numeric" 	required="false"  default="0"/>
		<cfargument name="BB_Aging"			type="numeric" 	required="false"  default="0"/>
		<cfargument name="Date_Operator" 	type="string" 	required="false"  default=""/>
		<cfargument name="Start_Date_Operator" 	type="string" 	required="false"  default=""/>
		<cfargument name="BB_Date" 			type="date" 	required="false"  default="#now()#"/>
		<cfargument name="Start_Date" 		type="date" 	required="false"  default="#now()#">
		<cfargument name="End_Date_Operator" 	type="string" 	required="false"  default=""/>
		<cfargument name="End_Date" 			type="date" 	required="false"  default="#now()#"/>


		<CFQUERY NAME="qryGetClaimSummary" DATASOURCE="#application.datasource#">
			SELECT DISTINCT
					Billback.Billback_ID,
					cast(convert(varchar, Billback.BB_Start_Date, 101) AS varchar) + ' - ' + cast(convert(varchar,Billback.BB_End_Date, 101) AS varchar) AS Delivery_Period,
					Billback.BB_Code As ClaimNo,
					CASE 	WHEN Billback.Billback_Payee_Type_ID=1
								THEN BSA_Foodservice_Customers.Name
							WHEN Billback.Billback_Payee_Type_ID=2
								THEN BSA_Operator.Operator_Name
							WHEN Billback.Billback_Payee_Type_ID=3
								THEN BSA_Foodservice_Brokers.Broker_Name
							WHEN Billback.Billback_Payee_Type_ID=4
								THEN Billback_Unidentified_Payee.BB_UP_Name
							WHEN Billback.Billback_Payee_Type_ID=5
								THEN Billback_Distributor.BB_Distributor_Name
							WHEN Billback.Billback_Payee_Type_ID=6
								THEN Billback_Operator.BB_Operator_Name
							WHEN Billback.Billback_Payee_Type_ID=7
								THEN Billback_Broker.BB_Broker_Name
					END AS Dist_Name,
					CASE 	WHEN Billback.Billback_Payee_Type_ID=1
								THEN BSA_Foodservice_Customers.Ship_To
								ELSE '--'
					END AS Dist_ID,
					ISNull(BB_Approved.Paid_Amount, 0) AS Paid_Amount,
					ISNull(BB_Approved.BB_Amount, 0) AS Claim_Amount
			FROM  		Billback
			LEFT JOIN ( Billback_Broker
						LEFT JOIN  BSA_Foodservice_Brokers
								ON Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
					  )
					ON (
							Billback_Broker.Billback_ID = Billback.Billback_ID
							AND ( 	Billback.Billback_Payee_Type_ID = 3
									OR Billback.Billback_Payee_Type_ID = 7
								)
							AND	Billback_Broker.Deleted = 0
						)
			LEFT JOIN  ( 	Billback_Distributor
							LEFT JOIN BSA_Foodservice_Customers
									ON Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						)
					ON (	Billback_Distributor.Billback_ID = Billback.Billback_ID
							AND	(	Billback.Billback_Payee_Type_ID = 1
									OR	Billback.Billback_Payee_Type_ID = 5
								)
							AND Billback_Distributor.Deleted = 0
						)
			LEFT JOIN (		Billback_Operator
							LEFT JOIN BSA_Operator
									ON	Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID
					  )
					ON (	Billback_Operator.Billback_ID = Billback.Billback_ID
							AND	(	Billback.Billback_Payee_Type_ID = 2
									OR	Billback.Billback_Payee_Type_ID = 6
								)
							AND	Billback_Operator.Deleted = 0
						)
			LEFT JOIN Billback_Unidentified_Payee
					ON	(	Billback_Unidentified_Payee.Billback_ID = Billback.Billback_ID
							AND	Billback.Billback_Payee_Type_ID = 4
							AND	Billback_Unidentified_Payee.Deleted = 0
						)
			LEFT JOIN BB_Approved
					ON	BB_Approved.Billback_ID = Billback.Billback_ID
					AND	Billback.Billback_Status_ID > 2
			WHERE	Billback.Deleted = 0
			AND 	(	Billback.BB_Creator_User_Position_ID = '#arguments.userPosition#'

						<Cfif BBIDRecordcounts IS 0>
						<cfif listlen(arguments.accessibleBBIds) GT 0>
							OR Billback.Billback_ID IN (#preservesinglequotes(arguments.accessibleBBIds)#)
						</cfif>
					<CFELSE>
						OR cast(Billback.Billback_ID as varchar(36)) IN (SELECT Billback_ID FROM #arguments.accessibleBBIds#)
					</CFIF>
					)
			<CFIF arguments.Status NEQ "0" and isDefined("arguments.Status")>
					AND Billback.Billback_Status_ID = #arguments.Status#
			</CFIF>
			<CFIF arguments.UP NEQ "0" and isDefined("arguments.UP")>
				AND Billback.BB_UP = 1
			</CFIF>
			<CFIF arguments.PNF NEQ "0" and isDefined("arguments.PNF")>
				AND Billback.BB_PNF = 1
			</CFIF>
			<CFIF arguments.Program_Status NEQ "0" OR arguments.Generic_Type NEQ "0" OR arguments.Contract_Number NEQ "">
				AND
				EXISTS
				(
					SELECT	TOP 1 Billback_Program.Billback_Program_ID
					FROM	Billback_Program
							INNER JOIN	Contract_Main
							ON
							(
								(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
								<CFIF arguments.Program_Status NEQ "0">
									AND (Contract_Main.Contract_Status_Type_IDX = #arguments.Program_Status#)
								</CFIF>
								<CFIF arguments.Contract_Number NEQ "">
									AND (Contract_Main.Contract_Number LIKE '%#Trim(arguments.Contract_Number)#%')
								</CFIF>
							)
							<CFIF arguments.Generic_Type NEQ "0">
								INNER JOIN Program_Control_Panel_Options
										ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
										AND Program_Control_Panel_Options.Generic_Type = '#arguments.Generic_Type#'
							</CFIF>
					Where
							Billback_Program.Deleted = 0
							AND Billback_Program.Billback_ID = Billback.Billback_ID
				)
			</CFIF>
			<CFIF arguments.Broker_ID NEQ "0">
				AND Billback.Billback_Payee_Type_ID = 3
				AND Billback_Broker.Broker_ID = '#arguments.Broker_ID#'
				AND Billback_Broker.Deleted = 0
			</CFIF>
			<CFIF arguments.Distributor_Name NEQ "">
				AND
				(
					((Billback.Billback_Payee_Type_ID = 1) AND (BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL) AND (BSA_Foodservice_Customers.Name LIKE '%#arguments.Distributor_Name#%'))
					OR
					((Billback.Billback_Payee_Type_ID = 5) AND (Billback_Distributor.Distributor_ID IS NULL) AND (Billback_Distributor.BB_Distributor_Name LIKE '%#arguments.Distributor_Name#%'))
				)
			</CFIF>
			<CFIF arguments.Operator_Name NEQ "">
				AND
				(
					((Billback.Billback_Payee_Type_ID = 2) AND (BSA_Operator.BSA_Operator_ID IS NOT NULL) AND (BSA_Operator.Operator_Name LIKE '%#arguments.Operator_Name#%'))
					OR
					((Billback.Billback_Payee_Type_ID = 6) AND (Billback_Operator.Operator_ID IS NULL) AND (Billback_Operator.BB_Operator_Name LIKE '%#arguments.Operator_Name#%'))
				)
			</CFIF>
			<CFIF arguments.Billback_Number NEQ "">
				AND Billback.BB_Reference LIKE '%#arguments.Billback_Number#%'
			</CFIF>
			<CFIF arguments.Payable_Number NEQ "">
				AND Billback.BB_Code LIKE '%#arguments.Payable_Number#%'
			</CFIF>
			<CFIF arguments.Billback_Title NEQ "">
				AND Billback.BB_Title LIKE '%#arguments.Billback_Title#%'
			</CFIF>
			<CFIF arguments.Amount_Operator NEQ "" AND isNumeric(arguments.Amount)>
				<CFSWITCH EXPRESSION="#arguments.Amount_Operator#">
					<CFCASE VALUE="Greater_Or_Equal">
						AND Billback.BB_Amount >= #arguments.Amount#
					</CFCASE>
					<CFCASE VALUE="Equal">
						AND Billback.BB_Amount = #arguments.Amount#
					</CFCASE>
					<CFCASE VALUE="Less_Or_Equal">
						AND Billback.BB_Amount <= #arguments.Amount#
					</CFCASE>
				</CFSWITCH>
			</CFIF>
			<CFIF arguments.BB_Aging NEQ 0>
				<CFSWITCH EXPRESSION="#arguments.BB_Aging#">
					<CFCASE VALUE="1">
						AND DateDiff(d, Billback.BB_Date, GetDate()) >= #arguments.Aging_Days#
						AND Billback.Billback_Status_ID < 5
					</CFCASE>
					<CFCASE VALUE="2">
						AND
						(
							DateDiff(d, Billback.BB_Date, GetDate()) < #arguments.Aging_Days#
							OR Billback.Billback_Status_ID >= 5
						)
					</CFCASE>
				</CFSWITCH>
			</CFIF>
			<CFIF arguments.Date_Operator NEQ "" AND isDate(arguments.BB_Date) AND (ListFindNOCase("Greater_Or_Equal,Equal,Less_Or_Equal",arguments.Date_Operator,",") GT 0)>
				AND DateDiff(d, '#arguments.BB_Date#', Billback.BB_Date)
				<CFSWITCH EXPRESSION="#arguments.Date_Operator#">
					<CFCASE VALUE="Greater_Or_Equal">
						>=
					</CFCASE>
					<CFCASE VALUE="Equal">
						=
					</CFCASE>
					<CFCASE VALUE="Less_Or_Equal">
						<=
					</CFCASE>
				</CFSWITCH>
				0
			</CFIF>
			<CFIF arguments.Start_Date_Operator NEQ "" AND isDate(arguments.Start_Date) AND (ListFindNOCase("Greater_Or_Equal,Equal,Less_Or_Equal",arguments.Start_Date_Operator,",") GT 0)>
				AND DateDiff(d, '#arguments.Start_Date#', Billback.BB_Start_Date)
				<CFSWITCH EXPRESSION="#arguments.Start_Date_Operator#">
					<CFCASE VALUE="Greater_Or_Equal">
						>=
					</CFCASE>
					<CFCASE VALUE="Equal">
						=
					</CFCASE>
					<CFCASE VALUE="Less_Or_Equal">
						<=
					</CFCASE>
				</CFSWITCH>
				0
			</CFIF>
			<CFIF arguments.End_Date_Operator NEQ "" AND isDate(arguments.End_Date) AND (ListFindNOCase("Greater_Or_Equal,Equal,Less_Or_Equal",arguments.End_Date_Operator,",") GT 0)>
				AND DateDiff(d, '#arguments.End_Date#', Billback.BB_End_Date)
				<CFSWITCH EXPRESSION="#arguments.End_Date_Operator#">
					<CFCASE VALUE="Greater_Or_Equal">
						>=
					</CFCASE>
					<CFCASE VALUE="Equal">
						=
					</CFCASE>
					<CFCASE VALUE="Less_Or_Equal">
						<=
					</CFCASE>
				</CFSWITCH>
				0
			</CFIF>
			AND
				(
					Billback.BB_Creator_User_Position_ID = '#arguments.userPosition#'
					<cfif listlen(arguments.accessibleBBIds) GT 0>
						OR Billback.Billback_ID IN (#preservesinglequotes(arguments.accessibleBBIds)#)
					</cfif>
				)
		</CFQUERY>
		<cfreturn qryGetClaimSummary />
	</cffunction>

	<cffunction name="getClaimCustSummaryLevel" output="false" returntype="numeric">
		<cfargument name="region_name" type="string" required="false"  />
		<cfargument name="cust_name" type="string" required="false"  />
		<cfif StructKeyExists(this.programSumLevel, trim(arguments.region_name)) and StructKeyExists(this.programSumLevel[arguments.region_name]['Total'], trim(arguments.cust_name)) >
			<cfreturn this.programSumLevel[arguments.region_name][arguments.cust_name]/>
		<cfelse>
			<cfreturn 0 />
		</cfif>
	</cffunction>

	<cffunction name="getClaimRegionSummaryLevel" output="false" returntype="numeric">
		<cfargument name="region_name" type="string" required="false"  />
		<cfif StructKeyExists(this.programSumLevel, trim(arguments.region_name)) >
			<cfreturn this.programSumLevel[arguments.region_name]['Total'] />
		<cfelse>
			<cfreturn 0 />
		</cfif>
	</cffunction>

	<cffunction name="getUserPosition" output="false" returntype="string">
		<cfargument name="user_id" type="string" required="false"  />
		<CFQUERY NAME="qryGetUserPosition" DATASOURCE="#application.datasource#">
			SELECT 	distinct User_Positions_ID
			FROM 	User_Position_Holders
			WHERE User_ID = '#arguments.user_id#' AND Deleted = 0 and user_positions_id <> 0
		</CFQUERY>
		<cfreturn ValueList(qryGetUserPosition.User_Positions_ID) />
	</cffunction>

	<cffunction name="deleteApprovalInformation" output="false" returntype="void">
		<cfargument name="billbackId" type="string" required="true"  />
		<cfargument name="userId" type="string" required="false" default="00000000-0000-0000-0000000000000000" />

		<cfset useLakebaseForDelete_Billback_1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_program_exclusion")>
<cfif useLakebaseForDelete_Billback_1>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_program_exclusion",
			{
				"exclusion_deducted_from_bb_id" = "eq.#arguments.billbackId#",
				"applied" = "eq.1"
			},
			{
				"exclusion_deducted_from_bb_id" = javaCast("null",""),
				"applied" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Billback_1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Billback_1>
<CFQUERY NAME="Delete_Billback_1" DATASOURCE="#application.datasource#">
			UPDATE 	BB_Program_Exclusion
			SET		Exclusion_Deducted_From_BB_ID = NULL,
					Applied = 0
			WHERE	Exclusion_Deducted_From_BB_ID = '#arguments.billbackId#'
					AND Applied = 1
		</CFQUERY>
</cfif>
		<cfset useLakebaseForDelete_Billback_2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_adjustment")>
<cfif useLakebaseForDelete_Billback_2>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_adjustment",
			{
				"adjustment_deducted_from_bb_id" = "eq.#arguments.billbackId#",
				"applied" = "eq.1"
			},
			{
				"adjustment_deducted_from_bb_id" = javaCast("null",""),
				"applied" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Billback_2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Billback_2>
<CFQUERY NAME="Delete_Billback_2" DATASOURCE="#application.datasource#">
			UPDATE	BB_Adjustment
			SET		Adjustment_deducted_From_BB_ID = NULL,
					Applied = 0
			WHERE	Adjustment_deducted_From_BB_ID = '#arguments.billbackId#'
					AND	Applied = 1
		</CFQUERY>
</cfif>
		<cfset useLakebaseForDelete_Billback_3 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_adjustment")>
<cfif useLakebaseForDelete_Billback_3>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_adjustment",
			{
				"billback_id" = "eq.#arguments.billbackId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Billback_3 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Billback_3>
<CFQUERY NAME="Delete_Billback_3" DATASOURCE="#application.datasource#">
			UPDATE	BB_Adjustment
			SET		Deleted = 1
			WHERE	Billback_ID = '#arguments.billbackId#'
		</CFQUERY>
</cfif>
		<cfset useLakebaseForDelete_Billback_4 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_approved")>
<cfif useLakebaseForDelete_Billback_4>
	<cftry>
		<cfset application.oLakebase.deleteRows("bb_approved", {
			"billback_id" = "eq.#arguments.billbackId#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Billback_4 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Billback_4>
<CFQUERY NAME="Delete_Billback_4" DATASOURCE="#application.datasource#">
			DELETE
			FROM	BB_Approved
			WHERE	Billback_ID = '#arguments.billbackId#'
		</CFQUERY>
</cfif>
		<CFQUERY NAME="Delete_Billback_5" DATASOURCE="#application.datasource#">
			UPDATE	BB_Exclusion_TPA
			SET		Deleted = 1
			FROM	BB_Exclusion_TPA
			WHERE
				BB_Exclusion_TPA.BB_Product_Exclusion_ID =
				(
					SELECT	BB_Product_Exclusion.BB_Product_Exclusion_ID
					FROM	BB_Product_Exclusion
					WHERE
							BB_Product_Exclusion.BB_Program_Exclusion_ID =
							(
								SELECT	BB_Program_Exclusion.BB_Program_Exclusion_ID
								FROM
									BB_Program_Exclusion
									WHERE
										BB_Program_Exclusion.Billback_ID = '#arguments.billbackId#'
										AND
										BB_Product_Exclusion.BB_Program_Exclusion_ID = BB_Program_Exclusion.BB_Program_Exclusion_ID
							)
							AND
							BB_Exclusion_TPA.BB_Product_Exclusion_ID = BB_Product_Exclusion.BB_Product_Exclusion_ID
				)
		</CFQUERY>
		<CFQUERY NAME="Delete_Billback_6" DATASOURCE="#application.datasource#">
			UPDATE	BB_Product_Exclusion
			SET		Deleted = 1
			FROM	BB_Product_Exclusion
			WHERE
					BB_Product_Exclusion.BB_Program_Exclusion_ID =
					(
						SELECT	BB_Program_Exclusion.BB_Program_Exclusion_ID
						FROM
							BB_Program_Exclusion
							WHERE
								BB_Program_Exclusion.Billback_ID = '#arguments.billbackId#'
								AND
								BB_Product_Exclusion.BB_Program_Exclusion_ID = BB_Program_Exclusion.BB_Program_Exclusion_ID
					)
		</CFQUERY>
		<cfset useLakebaseForDelete_Billback_7 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_program_exclusion")>
<cfif useLakebaseForDelete_Billback_7>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_program_exclusion",
			{
				"billback_id" = "eq.#arguments.billbackId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Billback_7 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Billback_7>
<CFQUERY NAME="Delete_Billback_7" DATASOURCE="#application.datasource#">
			UPDATE	BB_Program_Exclusion
			SET		Deleted = 1
			WHERE	BB_Program_Exclusion.Billback_ID = '#arguments.billbackId#'
		</CFQUERY>
</cfif>
		<!------ Delete BB Item Final, Final Detail, BB_Lump_Sums and Growth table ----->
		<CFQUERY NAME="Delete_Billback_8" DATASOURCE="#application.datasource#">
			UPDATE	BB_Item_Final_Detail
			SET		BB_Item_Final_Detail.Deleted = 1
			FROM	BB_Item_Final_Detail
			INNER JOIN BB_Item_Final
			ON		BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID
			AND		BB_Item_Final.Deleted = 0
			WHERE	BB_Item_Final_Detail.Deleted = 0
			AND		BB_Item_Final.Billback_ID = '#arguments.billbackId#'
		</CFQUERY>
		<cfset useLakebaseForDelete_Billback_9 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_item_final")>
<cfif useLakebaseForDelete_Billback_9>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_item_final",
			{
				"deleted" = "eq.0",
				"billback_id" = "eq.#arguments.billbackId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Billback_9 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Billback_9>
<CFQUERY NAME="Delete_Billback_9" DATASOURCE="#application.datasource#">
			UPDATE	BB_Item_Final
			SET		Deleted = 1
			WHERE	BB_Item_Final.Deleted = 0
			AND		BB_Item_Final.Billback_ID = '#arguments.billbackId#'
		</CFQUERY>
</cfif>
		<cfset useLakebaseForDelete_Billback_10 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_lump_sums")>
<cfif useLakebaseForDelete_Billback_10>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_lump_sums",
			{
				"deleted" = "eq.0",
				"billback_id" = "eq.#arguments.billbackId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Billback_10 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Billback_10>
<CFQUERY NAME="Delete_Billback_10" DATASOURCE="#application.datasource#">
			UPDATE	BB_Lump_Sums
			SET		Deleted = 1
			WHERE	BB_Lump_Sums.Deleted = 0
			AND		BB_Lump_Sums.Billback_ID = '#arguments.billbackId#'
		</CFQUERY>
</cfif>
		<cfset useLakebaseForDelete_Billback_11 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_growth_program")>
<cfif useLakebaseForDelete_Billback_11>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_growth_program",
			{
				"deleted" = "eq.0",
				"billback_id" = "eq.#arguments.billbackId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Billback_11 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Billback_11>
<CFQUERY NAME="Delete_Billback_11" DATASOURCE="#application.datasource#">
			UPDATE	BB_Growth_Program
			SET		Deleted = 1
			WHERE	BB_Growth_Program.Deleted = 0
			AND		BB_Growth_Program.Billback_ID = '#arguments.billbackId#'
		</CFQUERY>
</cfif>
		<cfset useLakebaseForDelete_Billback_12 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_program_lump_sum_distributor")>
<cfif useLakebaseForDelete_Billback_12>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_program_lump_sum_distributor",
			{
				"deleted" = "eq.0",
				"billback_id" = "eq.#arguments.billbackId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Billback_12 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Billback_12>
<CFQUERY NAME="Delete_Billback_12" DATASOURCE="#application.datasource#">
			UPDATE	BB_Program_Lump_Sum_Distributor
			SET		Deleted = 1
			WHERE	BB_Program_Lump_Sum_Distributor.Deleted = 0
			AND		BB_Program_Lump_Sum_Distributor.Billback_ID = '#arguments.billbackId#'
		</CFQUERY>
</cfif>
		<!---- Delete GL code allocation entries ---->
		<cfset useLakebaseForDelete_Billback_Gl_Code_Allocation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_allocation")>
<cfif useLakebaseForDelete_Billback_Gl_Code_Allocation>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_allocation",
			{
				"billback_id" = "eq.#arguments.billbackId#",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Billback_Gl_Code_Allocation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Billback_Gl_Code_Allocation>
<CFQUERY NAME="Delete_Billback_Gl_Code_Allocation" DATASOURCE="#application.datasource#">
			UPDATE 	Gl_Code_Allocation
			SET 	Deleted = 1
			WHERE 	Billback_ID = '#arguments.billbackId#'
			AND		Deleted = 0
		</CFQUERY>
</cfif>
	<!--- 	delete 'Manually configured Auto Pay' Pullbacks --->
		<cfset useLakebaseForunapplyPBLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_auto_report_pb_log")>
<cfif useLakebaseForunapplyPBLog>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_auto_report_pb_log",
			{
				"applied_to_billback_id" = "eq.#arguments.BillbackID#",
				"applied" = "eq.1"
			},
			{
				"applied" = "0",
				"unapplied_by" = "#arguments.userId#",
				"unapplied_date" = "#now()#",
				"applied_to_billback_id" = javaCast("null",""),
				"adjustment_dollars_ineligible_vol" = "0",
				"pb_corp_rate" = "0",
				"net_dollars" = "0",
				"corp_program_id" = javaCast("null",""),
				"corp_program_number" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForunapplyPBLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForunapplyPBLog>
<CFQUERY NAME="unapplyPBLog" DATASOURCE="#application.datasource#">
					Update BB_Auto_Report_PB_Log
					SET Applied = 0,
						Unapplied_by = '#arguments.userId#',
						Unapplied_date = GetDate(),
						Applied_To_Billback_Id = Null,
						Adjustment_Dollars_Ineligible_Vol = 0,
						PB_Corp_Rate = 0,
						Net_Dollars = 0,
						Corp_Program_Id = NULL,
						Corp_Program_number = NULL
					WHERE BB_Auto_Report_PB_Log.Applied_To_Billback_Id = '#arguments.BillbackID#' AND
						  BB_Auto_Report_PB_Log.Applied = 1
		</CFQUERY>
</cfif>
		<cfset useLakebaseForremovePBLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_auto_report_pb_log")>
<cfif useLakebaseForremovePBLog>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_auto_report_pb_log",
			{
				"billback_id" = "eq.#arguments.BillbackID#",
				"applied" = "eq.0"
			},
			{
				"deleted" = "1",
				"deleted_by" = "#arguments.userId#",
				"deleted_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForremovePBLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForremovePBLog>
<CFQUERY NAME="removePBLog" DATASOURCE="#application.datasource#">
					Update BB_Auto_Report_PB_Log
						SET Deleted = 1,
							Deleted_By = '#arguments.userId#',
							Deleted_Date = GetDate()
					WHERE BB_Auto_Report_PB_Log.Billback_Id = '#arguments.BillbackID#' AND
						BB_Auto_Report_PB_Log.Applied = 0
		</cfquery>
</cfif>
		<!--- Remove Broker Pullback Entries --->
		<cfset CreateObject("component","components.Brk_Pullback.Brk_Pullback_Upd").init().BrkPBDelete(arguments.billbackId) />

	</cffunction>

	<cffunction name="getDisagreeDetails" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true"  />

				<cfset useLakebaseForqgetDisagreeDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqgetDisagreeDetails>
	<cftry>
		<cfset qgetDisagreeDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#arguments.billbackId#",
				"select" = "bb_disagree"
			}), "bb_disagree"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetDisagreeDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetDisagreeDetails>
<cfquery name="qgetDisagreeDetails" datasource="#application.datasource#">
					SELECT BB_DisAgree
					FROM Billback
					WHERE Billback_ID = '#arguments.billbackId#'
				</cfquery>
</cfif>

		<cfreturn qgetDisagreeDetails />
	</cffunction>

	<cffunction name="deleteBillback" output="false" returntype="boolean">
		<cfargument name="billbackId" type="string" required="true"  />
		<cfargument name="userId" type="string" required="true"  />

		<cfset var returnValue = 0 />
			<cfset useLakebaseForBB_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForBB_Info>
	<cftry>
		<cfset BB_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#arguments.billbackId#",
				"deleted" = "eq.0",
				"select" = "auto_billback"
			}), "auto_billback"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBB_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBB_Info>
<CFQUERY name="BB_Info" datasource="#Application.Datasource#">
				SELECT	Auto_Billback
				FROM	Billback
				WHERE	Billback.Billback_ID = '#arguments.billbackId#' AND
						Billback.Deleted = 0
			</CFQUERY>
</cfif>
		<CFTRANSACTION ACTION="BEGIN">
			<CFTRY>
				<cfset this.DeleteApprovalInformation(arguments.billbackId,arguments.userId) />
				<cfif BB_Info.Auto_Billback EQ 1>
					<cfset CreateObject("component","components.Billback.BBAutoReportUpdate").deleteBB(arguments.billbackId,arguments.userId) />
				</cfif>

				<CFQUERY NAME="Delete_Billback" datasource="#application.datasource#">
					UPDATE 	Billback
					SET		Billback.Deleted = 1,
							Billback.Deleted_By_User_id = '#arguments.userId#',
							Billback.Deleted_Date = GetDate(),
							Deviation_Ran_Date = NULL,
							Deviation_Ran_By = NULL
					WHERE
							Billback.Billback_ID = '#arguments.billbackId#'
				</CFQUERY>
				<cfstoredproc procedure="Upload_EDI_Dup_Delete" datasource="#application.datasource#">
					<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR"	dbVarName = "@@Billback_ID" value="#arguments.billbackId#" null="false" />
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@Upload_ID" null="true"/>
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@Header_ID" null="true"/>
				</cfstoredproc>
				<!---
					50616 - New Duplicate BB Logic/Anand Rao/17-Jun-2015
				--->
				<cfstoredproc procedure="BB_All_Dup_Delete" datasource="#application.datasource#">
					<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR"	dbVarName = "@@Billback_ID" value="#arguments.billbackId#" null="false" />
				</cfstoredproc>

				<!--- Budget: Remove this billback from actual dollar --->
				<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn()>
					<!--- D30648  - Budget changes on Billback Reset,Reversal/Anand Rao/27-Feb-2012  --->
					<!--- <cfset createobject("component", "components.budgets.BudgetBillbackManager").updateProgramActualDollar(billbackID = arguments.billbackID) /> --->
					<cfset CreateObject("component", "mvc.Models.AdvancedBudget.BudgetManager").addBillbackToBudget(billbackId=arguments.billbackID) />
				</cfif>

				<CFTRANSACTION ACTION="COMMIT" />
				<CFCATCH>
					<CFTRANSACTION ACTION="ROLLBACK" />
					<CFRETHROW>
				</CFCATCH>
			</CFTRY>
		</CFTRANSACTION>
			<cfset returnValue = 1>
		<cfreturn returnValue>
	</cffunction>

	<cffunction name="resetBillback" output="false" returntype="void">
		<cfargument name="billbackId" type="string" required="true"  />
		<cfargument name="userId" type="string" required="true"  />
		<cfargument name="IsApprovedBillback" type="boolean" required="false" default="1"  />
		<cfargument name="DisagreeFlag" type="boolean" required="false" default="0"  />

		<CFTRANSACTION ACTION="BEGIN">
			<CFTRY>
			<cfif IsApprovedBillback eq 1>
				<cfquery name="preserveBBApprovedValues" datasource="#application.datasource#">
					INSERT INTO BB_Reset
					(		Billback_ID, BB_Approved_ID, Paid_Amount, Approved_Amount, BB_Amount, Expected_Amount, Authorized_Amount,
							Date_Approved, User_Approved, Adjustment_Created, Claim_Adjust_Tot,
							Updated_Paid_Amount_For_Claim_Adjust, Approved_Amt_Type, Vendor_Dist_Oper_ID,
							Actual_Approved_Amt, Payment_Notes, Check_Number, Check_Date, Check_Amount, BB_Check_Status
					)
					SELECT 	Billback_ID, BB_Approved_ID, Paid_Amount, Approved_Amount, BB_Amount, Expected_Amount, Authorized_Amount,
							Date_Approved,
							User_Approved, Adjustment_Created, Claim_Adjust_Tot,
							Updated_Paid_Amount_For_Claim_Adjust,
							Approved_Amt_Type,
							Vendor_Dist_Oper_ID,
							Actual_Approved_Amt,
							'',--Payment_Notes,
							Check_Number,
							Check_Date,
							Check_Amount,
							BB_Check_Status
					FROM	BB_Approved
					WHERE	Billback_ID = '#arguments.billbackId#'
							AND BB_Approved_ID NOT IN
							(
							SELECT DISTINCT BB_Approved_ID
							FROM	BB_Reset
							WHERE	Billback_ID = '#arguments.billbackId#'
							)
				</cfquery>

			</cfif>
				<!--- Delete email log so that emails can be sent again (Note: Prior "agree" log emails will be deleted as the bb has been reset.
				The BB needs to go through the approval process again)
				--->
				<cfquery name="delmailLog" datasource="#application.datasource#">
				  DELETE FROM Billback_Agree_Email_Log
				  WHERE	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
				</cfquery>

				<cfquery name="qDeleteBillbackReasonCode" datasource="#application.datasource#">
				 DELETE BB_Reason_Code_Selection
				 WHERE	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
				</cfquery>

				<CFQUERY NAME="Reset_Billback" datasource="#application.datasource#">
					UPDATE 	Billback
					SET		Billback.Billback_Status_ID = 1,
							<cfif (arguments.DisagreeFlag EQ 0)>
								Billback.BB_Reset_User_ID = '#arguments.userId#',
								Billback.BB_Reset_Date = GetDate(),
							</cfif>
							DD_Closure_Sent_On = NULL,
							Deviation_Ran_Date = NULL,
							Deviation_Ran_By = NULL,
							BB_Payment_Request_Sent = 0,
							BB_Payment_Request_Sent_On = NULL,
							Hold = 0
					WHERE	Billback.Billback_ID = '#arguments.billbackId#'
							AND Billback_Status_ID <> 1
				</CFQUERY>

				<!--- Budget: Remove this billback from actual dollar --->
				<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn()>
					<!--- D30648  - Budget changes on Billback Reset,Reversal/Anand Rao/27-Feb-2012  --->
					<!--- <cfset createobject("component", "components.budgets.BudgetBillbackManager").updateProgramActualDollar(billbackID = arguments.billbackID) /> --->
					<cfset CreateObject("component", "mvc.Models.AdvancedBudget.BudgetManager").addBillbackToBudget(billbackId=arguments.billbackID) />
				</cfif>

				<!--- Delete the approval information after calling the budget SP above. The budget SP needs records from the "BB_Item_Final" table and probably other table(s) too --->
				<cfif IsApprovedBillback eq 1>
					<cfset this.DeleteApprovalInformation(arguments.billbackId,arguments.userId) />
					<!--- Remove Broker Pullback Entries --->
				</cfif>

				<CFTRANSACTION ACTION="COMMIT" />
				<CFCATCH>
					<CFTRANSACTION ACTION="ROLLBACK" />
					<CFRETHROW>
				</CFCATCH>
			</CFTRY>
		</CFTRANSACTION>
	</cffunction>

	<cffunction name="unapplyDeletePBAdjustments" access="public">
		<cfargument name="billbackId" type="string" required="true"  />
		<cfargument name="userId" type="string" required="true"  />
		<!---START XXXXX DELETE ADJUSTMENTS/PULLBACKS CREATED BY THIS BB xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
		<CFQUERY NAME="removePrgExclusion" DATASOURCE="#application.datasource#">
					UPDATE BB_Program_Exclusion Ex
					 SET Deleted = 1
					WHERE Ex.Billback_ID = '#arguments.Billback_ID#' AND
						Applied = 0
		</cfquery>
		<CFQUERY NAME="removeBBAdjustment" DATASOURCE="#application.datasource#">
					UPDATE BB_Adjustment BAJ
						SET Deleted = 1,
							Last_Updated_By = '#arguments.userId#',
							Last_Updated_Date = GetDate()
					WHERE BAJ.Billback_ID = '#arguments.Billback_ID#' AND
						Applied = 0
		</cfquery>

		<!---END XXXXX DELETE ADJUSTMENTS/PULLBACKS CREATED BY THIS BB xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

		<!--- START oooooo UNAPPLY ADJUSTMENTS ADJUSTMENTS/PULLBACKS APPLIED O THIS BB oooooooooooooooo --->
		<CFQUERY NAME="unapplyPrgExclusion" DATASOURCE="#application.datasource#">
					UPDATE BB_Program_Exclusion Ex
					 SET Applied = 0
					WHERE Ex.Exclusion_Deducted_From_BB_ID = '#arguments.Billback_ID#' AND
						Applied = 1
		</CFQUERY>
		<CFQUERY NAME="unapplyBBAdjustment" DATASOURCE="#application.datasource#">
					UPDATE BB_Adjustment BAJ
						SET Applied = 0,
							Date_Applied = NULL,
							Last_Updated_By = '#arguments.userId#',
							Last_Updated_Date = GetDate()
					WHERE BAJ.Adjustment_deducted_From_BB_ID = '#arguments.Billback_ID#' AND
						Applied = 1
		</CFQUERY>

		<!--- END   oooooo UNAPPLY ADJUSTMENTS ADJUSTMENTS/PULLBACKS APPLIED O THIS BB oooooooooooooooo --->
	</cffunction>

	<cffunction name="getApprovableUsers" output="true" returntype="query">

		<cfargument name="billbackId" type="string" required="false" default="0"/>
		<cfargument name="bbRemoteApproval" type="numeric" required="false" default="0" />

		<!------
		Different conditions to check for
		- User not in approve forbid list or user in allow list
		- user not in agreed list
		- user has approval rights
		 ----->

		<!------ Get application settings ----->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>

		<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

		<!------ Get Program ----->
		<cfquery name="qGetApprovalbleUsers" datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##tmp_cra_user_list') IS NOT NULL
            DROP TABLE ##tmp_cra_user_list

			SELECT DISTINCT
				   Position_To_Approve.User_Positions_ID,
				   Approve_Authority_Sequence.Authority_Sequence_Name,
				   Approve_Authority_Sequence.Authority_Sequence_ID,
				   _Users.User_ID,
				   _Users.User_Code,
				   _Users.Name_First+' '+_Users.Name_Last as User_Full_Name,
				   LTRIM(RTRIM(_Users.User_Email)) as User_Email,
				   Profiles.Profiles_Desc,
				   Position_To_Approve.Position_Label,
				   <cfif arguments.bbRemoteApproval >
				   	_Users.BB_Remote_Approval_Option,
				   	Billback.Billback_ID_Int, Billback.Billback_ID, Billback.BB_Code, Billback.BB_Title,
				   	Billback.Billback_Status_ID, Billback.Billback_Payee_Type_ID, Billback.BB_Reference, Billback.referenceNum,
				   	convert(varchar(10), Billback.BB_Date, 101) BB_Date,
				   	convert(varchar(10), Billback.BB_Start_Date, 101) BB_Start_Date,
				   	convert(varchar(10), Billback.BB_End_Date, 101) BB_End_Date,
				   	Billback.BB_Amount, Billback.BB_Expected_Amount,
				   	B.Broker_Name, B.Broker_Shard, O.Operator_Name, O.BSA_Operator_ID, C.Name, C.Ship_To,
				   isnull(C.Name,isnull(O.Operator_Name, B.Broker_Name)) Payee,
				   isnull(C.Ship_To,isnull(O.BSA_Operator_ID, B.Broker_Shard)) as Payee_Id,
				   Billback.BB_Amount - Billback.BB_Expected_Amount as Dev_Amount,
				   ((Billback.BB_Amount - Billback.BB_Expected_Amount)*100/nullif(Billback.BB_Expected_Amount,0)) as Dev_Percent,
				   </cfif>
				   convert(varchar(10), getDate(), 101) as now

			INTO 	##tmp_cra_user_list
			FROM   Billback
					LEFT JOIN Billback_Program
					ON	Billback_Program.Deleted = 0
					AND	Billback_Program.Billback_ID = Billback.Billback_ID
					LEFT JOIN Contract_Main
					ON	Contract_Main.Contract_Main_ID = Billback_Program.Program_ID


					INNER JOIN User_Positions Position_To_Approve
					ON 	Position_To_Approve.User_Positions_ID =
					(
						SELECT	TOP 1 User_positions_ID
						FROM	BillbackApprovablePositions
						WHERE	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID
								 AND NOT EXISTS
		                          (	SELECT DISTINCT BB_Agreed_Info.User_Position_ID
		                            FROM       	BB_Agreed_Info
									LEFT JOIN	Authority_Sequence
									ON			Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
		                            WHERE      	BB_Agreed_Info.Billback_ID = Billback.Billback_ID
												AND		BB_Agreed_Info.Deleted = 0
												AND 	User_Position_ID IS NOT NULL
												AND		BillbackApprovablePositions.User_Positions_ID = BB_Agreed_Info.User_Position_ID
												AND		ISNULL(BillbackApprovablePositions.Authority_Sequence_Order, 0) = ISNULL(Authority_Sequence.Authority_Sequence_Order, 0)
								   )
						ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
					)

					INNER JOIN User_Position_Holders
					ON 	User_Position_Holders.Deleted = 0
					AND	User_Position_Holders.User_Positions_ID = Position_To_Approve.User_Positions_ID
					INNER JOIN _Users
					ON	_Users.Deleted = 0
					AND	_Users.User_ID = User_Position_Holders.User_ID

					<!------ User not in forbid list/in allow list ----->
					AND	_Users.Profiles_ID
					<cfif forbidType EQ 1> not </cfif> <!------ forbit type: 1=forbid, 0=allow ----->
					in
					(	select 	distinct profile_id
						from 	Profile_Forbidden_Template
						where 	Deleted = 0
								AND Forbid_Type = #forbidType#
								AND	Forbid_Access_Type = 4 <!------ 4=approve billback ----->
								AND template_id = Contract_Main.ProgramType_ID
					)

					<!------ user not in agreed list ----->
					AND	_Users.User_ID NOT IN
					(
					SELECT	DISTINCT BB_Agreed_Info.User_ID
					FROM	BB_Agreed_Info
					WHERE	BB_Agreed_Info.Billback_ID = Billback.Billback_ID
					AND		BB_Agreed_Info.Deleted = 0
					)

					INNER JOIN Profiles
					ON	Profiles.Profiles_ID = _Users.Profiles_ID

					<!------ D10310: [Deepa] The LEFT JOIN on BB_Analyst was in the wrong place, moved it down from inside the _users join ----->
					<!------ Analyst ----->
					LEFT JOIN BB_Analyst
					ON	BB_Analyst.Deleted = 0
					AND	BB_Analyst.Analyst_User_ID = _Users.User_ID

					INNER JOIN Profiles_Settings
					ON	Profiles_Settings.Deleted = 0
					AND	Profiles_Settings.Profiles_ID = _Users.Profiles_ID

					<!------ user has approval rights ----->
					INNER JOIN BB_Profiles_Settings
					ON	BB_Profiles_Settings.Deleted = 0
					AND	BB_Profiles_Settings.Profiles_ID = _Users.Profiles_ID
					AND	BB_Profiles_Settings.BB_Approve = 1

					LEFT JOIN Authority_Sequence Approve_Authority_Sequence
					ON
					Position_To_Approve.Service_Market_ID IS NULL
					AND Position_To_Approve.Service_Region_ID IS NULL
					AND Position_To_Approve.Service_Zone_ID IS NULL
					AND Approve_Authority_Sequence.Deleted = 0
					AND Approve_Authority_Sequence.Authority_Sequence_Order =
					(
					SELECT	TOP 1 Authority_Sequence_Order
					FROM	BillbackApprovablePositions
					WHERE	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID
							 AND NOT EXISTS
	                          (	SELECT DISTINCT BB_Agreed_Info.User_Position_ID
	                            FROM       	BB_Agreed_Info
								LEFT JOIN	Authority_Sequence
								ON			Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
	                            WHERE      	BB_Agreed_Info.Billback_ID = Billback.Billback_ID
											AND		BB_Agreed_Info.Deleted = 0
											AND 	User_Position_ID IS NOT NULL
											AND		BillbackApprovablePositions.User_Positions_ID = BB_Agreed_Info.User_Position_ID
											AND		ISNULL(BillbackApprovablePositions.Authority_Sequence_Order, 0) = ISNULL(Authority_Sequence.Authority_Sequence_Order, 0)
											/*TODO: AND (Profiles_Settings.RFA_Agreed <> 2 OR Executive_Agreement = 1)*/
							   )
					ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
					)
			<cfif arguments.bbRemoteApproval >
				left join Billback_Distributor
					on Billback.Billback_ID = Billback_Distributor.Billback_ID
					and Billback_Distributor.Deleted = 0
				left join BSA_Foodservice_Customers  C
					on C.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
					and C.Deleted = 0
				left join Billback_Operator
					on Billback.Billback_ID = Billback_Operator.Billback_ID
					and Billback_Operator.Deleted = 0
				left join BSA_Operator  O
					on O.BSA_Operator_ID  = Billback_Operator.Operator_ID
					and O.Deleted = 0
				left join Billback_Broker
					on Billback.Billback_ID = Billback_Broker.Billback_ID
					and Billback_Broker.Deleted = 0
				left join BSA_Foodservice_Brokers  B
					on B.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID
					and B.Deleted = 0
			</cfif>

			WHERE	Billback.Billback_Status_ID = 2 <!--- Only display CRA when billback is in RFA status --->
			<cfif arguments.billbackId >
			AND 	Billback.Billback_ID = '#arguments.billbackId#'
			</cfif>
			<cfif arguments.bbRemoteApproval >
			AND _Users.BB_Remote_Approval_Option = 1
			</cfif>
			AND		(Approve_Authority_Sequence.Authority_Sequence_ID IS NULL OR Approve_Authority_Sequence.Authority_Sequence_ID = _Users.Authority_Sequence_ID)


			<!--- D32585: Approval e-mails sending to all TL's --->
			<cfif appSettings.getCRAConsiderAnalyst() and not arguments.bbRemoteApproval >
				DECLARE @Filter_User_ID NVARCHAR(50)
				SELECT TOP 1 @Filter_User_ID = CASE
												   WHEN an.Is_Supervisor = 1
												   THEN an.Director_ID
												   ELSE an.Supervisor_ID
											   END
				FROM         BB_Agreed_Info a
							 INNER JOIN User_Positions up
								 ON up.User_Positions_ID = a.User_Position_ID
							 INNER JOIN _Users u
								 ON u.User_ID = a.User_ID
							 LEFT JOIN Authority_Sequence seq
								 ON seq.Authority_Sequence_ID = u.Authority_Sequence_ID
							 INNER JOIN BB_Analyst an
								 ON an.Analyst_User_ID = a.User_ID
									AND Is_Director = 0 -- If agreed by director, let the routing using old scheme
				WHERE        a.Deleted = 0
							<cfif not arguments.bbRemoteApproval >
							 AND a.Billback_ID = '#arguments.billbackId#'
							</cfif>
				ORDER BY up.Service_Zone_ID,
						 up.Service_Region_ID,
						 up.Service_Market_ID,
						 seq.Authority_Sequence_Order,
						 a.Created_Date DESC
			</cfif>

			<!--- D32585: Approval e-mails sending to all TL's START--->
			<!--- We want to filter only if
			- app setting is ON
			- and @Filter_User_ID is NOT NULL
			- and if the CRA list contains the user @Filter_User_ID
			- If any of the above is false, we want to return the CRA list without filtering
			 --->
			<cfif appSettings.getCRAConsiderAnalyst() and not arguments.bbRemoteApproval >
				IF @Filter_User_ID IS NOT NULL
					BEGIN
						IF EXISTS
								  (
									  SELECT *
									  FROM   ##tmp_cra_user_list
									  WHERE  User_ID = @Filter_User_ID
								  )
							BEGIN
								SELECT *
								FROM   ##tmp_cra_user_list
								WHERE  User_ID = @Filter_User_ID
							END
							ELSE
							BEGIN
								SELECT * FROM ##tmp_cra_user_list
							END
					END
					ELSE
					BEGIN
						SELECT * FROM ##tmp_cra_user_list
					END
			<cfelse>
				<cfif arguments.bbRemoteApproval >
					SELECT ROW_NUMBER() OVER(PARTITION BY t.Billback_ID ORDER BY bai.created_date DESC) AS rowNum,
						   t.*,
						   bai.User_ID AS lastAgreedUser,
						   u.Name_First+' '+u.Name_Last AS lastAgreedName,
						   bai.Created_Date AS lastAgreeDate,
						   bai.Agreed_Amount
					FROM   ##tmp_cra_user_list t
						   INNER JOIN dbo.BB_Agreed_Info bai
							   ON bai.Billback_ID = t.Billback_ID
								  AND bai.Deleted = 0
						   INNER JOIN dbo._Users u
							   ON bai.User_ID = u.User_ID
								  AND u.Deleted = 0
					ORDER BY t.Billback_ID, bai.created_date DESC
				<cfelse>
					SELECT * FROM ##tmp_cra_user_list
				</cfif>
			</cfif>
			<!--- D32585: Approval e-mails sending to all TL's END--->
		</cfquery>

		<cfreturn qGetApprovalbleUsers />

	</cffunction>

	<cffunction name="setSentEmailtoNextCRA" output="false" returntype="void">
		<cfargument name="billbackId" required="true" type="string" />
		<cfargument name="userId" required="true" type="string" />
		<cfset returnValue = 1>
		<cfquery name="qGetEmailSentForAnyPosition" datasource="#application.datasource#">
			INSERT INTO Billback_Agree_Email_Log
					(Billback_ID, User_Positions_ID, Authority_Sequence_ID, Email_Sent)
			SELECT	Billback.Billback_ID, User_User_Positions.User_Positions_ID, _Users.Authority_Sequence_ID, 1
			FROM	Billback
					INNER JOIN User_Positions
					ON 		User_Positions.User_Positions_ID = BB_Creator_User_Position_ID
					INNER JOIN _Users
					ON 		_Users.User_ID = '#arguments.userId#'
					INNER JOIN User_Position_Holders
					ON 		User_Position_Holders.Deleted = 0
					AND 		User_Position_Holders.User_ID = _Users.User_ID
					INNER JOIN User_Positions User_User_Positions
					ON 		User_User_Positions.Deleted = 0
					AND 	User_User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID
					AND 	(User_User_Positions.Service_Zone_ID = User_Positions.Service_Zone_ID OR User_User_Positions.Service_Zone_ID IS NULL)
					AND 	(User_User_Positions.Service_Region_ID = User_Positions.Service_Region_ID OR User_User_Positions.Service_Region_ID IS NULL)
					AND 	(User_User_Positions.Service_Market_ID = User_Positions.Service_Market_ID OR User_User_Positions.Service_Market_ID IS NULL)
			WHERE	Billback.Billback_ID = '#arguments.billbackId#'
		</cfquery>

	</cffunction>

	<cffunction name="sendEmailtoNextCRA" output="false" returntype="boolean">
		<cfargument name="billbackId" required="true" type="string" />
		<cfargument name="userId" required="true" type="string" />
		<cfset returnValue = 1>
		<cfquery name="qGetEmailSentForAnyPosition" datasource="#application.datasource#">
			SELECT	TOP 1 Billback_Agree_Email_Log.User_Positions_ID
			FROM	_Users
					INNER JOIN User_Position_Holders
					ON 		User_Position_Holders.Deleted = 0
					AND 	User_Position_Holders.User_ID = _Users.User_ID
					INNER JOIN Billback_Agree_Email_Log
					ON	Billback_Agree_Email_Log.Deleted = 0
					AND	Billback_Agree_Email_Log.Email_Sent = 1
					AND	Billback_Agree_Email_Log.Billback_ID = '#arguments.billbackId#'
					AND	Billback_Agree_Email_Log.User_Positions_ID = User_Position_Holders.User_Positions_ID
					AND	(ISNULL(_Users.Authority_Sequence_ID, 0) = 0 OR Billback_Agree_Email_Log.Authority_Sequence_ID = _Users.Authority_Sequence_ID)
			WHERE	_Users.User_ID = '#arguments.userId#'
		</cfquery>
		<cfif qGetEmailSentForAnyPosition.recordCount>
			<cfset returnValue = 0>
		</cfif>
		<cfreturn returnValue />
	</cffunction>

	<cffunction name="loadReportHeaders" access="public" returntype="void">
		<cfif this.getReportName() eq "billbackApproval">
			<cfset  thisHeaderList = "Billback No,Description,Program,Paid Amount,Deviation Amount,Billback Start Date,Billback End Date,Pay-To,Approver" />
			<cfset  thisHeaderAttributeList = "BB_Code,BB_Title,Program_Number,Paid_Amount,Amount_Deviation,BB_Start_Date,BB_End_Date,Cust_Name,UserID" />
			<cfset  thisHeaderSortByList = "Billback No:BB_Code,Description:BB_Title,Program:Program_Number,Paid Amount:Paid_Amount,Deviation<br>Amount:Amount_Deviation,Billback<br>Start<br>Date:BB_Start_Date,Billback<br>EndDate:BB_End_Date,Pay-To:Cust_Name,Approver:UserID" />
			<cfset setReportHeaders(thisHeaderList) />
			<cfset setReportHeadersAttributes(thisHeaderAttributeList) />
			<cfset setReportHeaderSortByList(thisHeaderSortByList) />
		</cfif>
	</cffunction>

	<cffunction name="getBillbackApprovalResultSet" access="public" returntype="query">
		<cfargument name="form" required="false" type="struct">
		<cfquery name="qGetBillbackApprovalResultSet" datasource="#application.datasource#">
			select *
			from (
					select billback.BB_Title,
						BB_PROGRAM_DEVIATION_INFO.Amount_Deviation,
						claim_summary_Report.*,
						Program_ID,
						CASE WHEN Program_ID IS NULL THEN Billback_Program.BB_Program_Title
						ELSE Contract_Main.Contract_Title END AS Program_Title,
						CASE WHEN Program_ID IS NULL THEN Billback_Program.BB_Program_Number
						ELSE Contract_Main.Contract_Number END AS Program_Number
					from claim_summary_Report
					inner join billback
						on billback.billback_id = claim_summary_report.billback_id
						and billback.deleted = 0
					INNER JOIN (	Billback_Program
							LEFT JOIN  Contract_Main
								ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
							LEFT JOIN  program_control_panel_options
								ON Contract_Main.ProgramType_ID = program_control_panel_options.ProgramControl_Panel_Options_ID
							)
						ON Billback_Program.Billback_ID = claim_summary_report.Billback_ID
						AND Billback_Program.Deleted = 0
					inner join bb_approved
						on bb_approved.billback_id = claim_summary_Report.billback_id
					left join BB_PROGRAM_DEVIATION_INFO
						on BB_PROGRAM_DEVIATION_INFO.billback_id = claim_summary_Report.billback_id
						and BB_PROGRAM_DEVIATION_INFO.billback_program_id = Billback_Program.billback_program_id
						and BB_PROGRAM_DEVIATION_INFO.deleted = 0
					where  BB_Approved.user_approved is not null
					and claim_summary_Report.Billback_Status_ID > 2
					) X
			where  1= 1
			<cfif isDefined("arguments.form")>
				<cfif isDefined("arguments.form.programNumber") and arguments.form.programNumber neq "">
					and program_number like '%#trim(arguments.form.programNumber)#%'
				</cfif>
				<cfif isDefined("arguments.form.APPROVER") and arguments.form.APPROVER neq "">
					and UserID like '%#trim(arguments.form.APPROVER)#%'
				</cfif>
				<cfif isDefined("arguments.form.custName") and arguments.form.custName neq "">
					and Cust_Name like '%#trim(arguments.form.custName)#%'
				</cfif>
				<cfif isDefined("arguments.form.custNo") and arguments.form.custNo neq "">
					and cust_id like '%#trim(arguments.form.custNo)#%'
				</cfif>
				<cfif isDefined("arguments.form.BILLBACKNO") and arguments.form.BILLBACKNO neq "">
					and bb_code like '%#trim(arguments.form.BILLBACKNO)#%'
				</cfif>
				<cfif isDefined("arguments.form.billbackTitle") and arguments.form.billbackTitle neq "">
					and BB_Title like '%#trim(arguments.form.billbackTitle)#%'
				</cfif>
				<!--- bb start date --->
				<cfif isDefined("arguments.form.BB_DELIVERSTART") and isDefined("arguments.form.BB_DELIVERSTART_OPERATOR") and arguments.form.BB_DELIVERSTART neq "">
					and BB_Start_Date <cfif arguments.form.BB_DELIVERSTART_OPERATOR eq 'Greater_Or_Equal'>>=<cfelseif arguments.form.BB_DELIVERSTART_OPERATOR eq 'Equal'>=<cfelse><=</cfif> '#trim(arguments.form.BB_DELIVERSTART)#'
				</cfif>
				<!--- bb end date --->
				<cfif isDefined("arguments.form.BB_DELIVEREND") and isDefined("arguments.form.BB_DELIVEREND_OPERATOR") and arguments.form.BB_DELIVEREND neq "">
					and BB_End_Date <cfif arguments.form.BB_DELIVEREND_OPERATOR eq 'Greater_Or_Equal'>>=<cfelseif arguments.form.BB_DELIVEREND_OPERATOR eq 'Equal'>=<cfelse><=</cfif> '#trim(arguments.form.BB_DELIVEREND)#'
				</cfif>
				<!--- bb date --->
				<cfif isDefined("arguments.form.BB_DATE") and isDefined("arguments.form.BB_OPERATOR") and arguments.form.BB_DATE neq "">
					and BB_Date <cfif arguments.form.BB_OPERATOR eq 'Greater_Or_Equal'>>=<cfelseif arguments.form.BB_OPERATOR eq 'Equal'>=<cfelse><=</cfif> '#trim(arguments.form.BB_DATE)#'
				</cfif>
				<!--- paid amount --->
				<cfif isDefined("arguments.form.CLAIMAMOUNT") and isDefined("arguments.form.AMOUNT_OPERATOR") and arguments.form.CLAIMAMOUNT neq "">
					and paid_amount <cfif arguments.form.AMOUNT_OPERATOR eq 'Greater_Or_Equal'>>=<cfelseif arguments.form.AMOUNT_OPERATOR eq 'Equal'>=<cfelse><=</cfif> '#trim(arguments.form.CLAIMAMOUNT)#'
				</cfif>
				<!--- deviation amount --->
				<cfif isDefined("arguments.form.DEVIATIONAMOUNT") and isDefined("arguments.form.DEVIATIONAMOUNTOPERATOR") and arguments.form.DEVIATIONAMOUNT neq "">
					and Amount_Deviation <cfif arguments.form.DEVIATIONAMOUNTOPERATOR eq 'Greater_Or_Equal'>>=<cfelseif arguments.form.DEVIATIONAMOUNTOPERATOR eq 'Equal'>=<cfelse><=</cfif> '#trim(arguments.form.DEVIATIONAMOUNT)#'
				</cfif>
				<!--- claim status --->
				<cfif isDefined("arguments.form.CLAIMSTATUS") and arguments.form.CLAIMSTATUS neq "0">
					and Billback_Status_ID = #trim(arguments.form.CLAIMSTATUS)#
				</cfif>
			</cfif>
			order by UserID
			<cfif isDefined("arguments.form.sort_by") and arguments.form.sort_by neq "" and UCase(arguments.form.sort_by) neq "USERID">,#arguments.form.sort_by# #arguments.form.sort_order#</cfif>
		</cfquery>
		<cfreturn qGetBillbackApprovalResultSet />
	</cffunction>

	<cffunction name="GetGroupItems" access="public" returntype="query">
		<cfargument name="startQuery" 	type="query"  required="true">
		<cfargument name="userID" 		type="string" required="true">
		<cfquery dbtype="query" name="qGetGroupItems">
			select *
			from arguments.startQuery
			where userID = '#arguments.userID#'
		</cfquery>
		<cfreturn qGetGroupItems />
	</cffunction>

	<cffunction name="getBBReferences" access="public" returntype="string">
		<cfargument name="bbID" type="string"  required="true">

		<cfquery name="qGetBBReferences" datasource="#application.datasource#">
			select distinct BB_Reference
			from Billback
			where deleted = 0
			<cfif arguments.bbID neq "NULL">
				and billback_id != '#arguments.bbID#'
			<cfelse>
				and billback_id is not #arguments.bbID#
			</cfif>
			and bb_reference != ''
		</cfquery>
		<cfreturn valueList(qGetBBReferences.BB_Reference) />
	</cffunction>

	<!--- Get Sales Tax Type Information --->
	<cffunction name="getBillbacksSalesTaxInfo" access="public" returntype="query">
		<cfquery name="qGetBillbacksSalesTax" datasource="#application.datasource#">
			SELECT *
			FROM BB_Tax_Main
			WHERE deleted = 0
		</cfquery>
		<cfreturn qGetBillbacksSalesTax />
	</cffunction>

	<!--- Get Sales Tax Amount Information --->
	<cffunction name="getBillbacksSalesTaxAmount" access="public" returntype="query">
	<cfargument name="BillbackID" 	type="string"  required="true" default="">
		<cfquery name="qGetBillbacksSalesTaxAmount" datasource="#application.datasource#">
			SELECT *
			FROM BB_Tax_Info
			WHERE cast(Billback_ID As varchar(100)) = '#arguments.BillbackID#'
			AND deleted = 0
		</cfquery>
		<cfreturn qGetBillbacksSalesTaxAmount />
	</cffunction>

	<!--- TSF: Label 9231 - This method get's the sum of all the voume (cs/lb) entered for each product for a given billback--->
	<cffunction name="getBillbackItemizedVolumeSum" access="public" returntype="query">

		<cfargument name="billbackID" type="string"  required="true">

		<cfquery name="qGetItemizedBillbackVolume" datasource="#application.datasource#">
			SELECT	ISNULL(SUM(ISNULL(CAST(
					CASE
					WHEN Billback_Product.BB_Product_UOM = 2 or  Billback_Product.BB_Product_UOM = 3 THEN
						Billback_Product.BB_Product_Quantity / CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
					ELSE
						Billback_Product.BB_Product_Quantity
					END AS FLOAT), 0.00)), 0.00) AS Volume_CS,
					ISNULL(SUM(ISNULL(CAST(
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						Billback_Product.BB_Product_Quantity * CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
					ELSE
						Billback_Product.BB_Product_Quantity
					END AS FLOAT), 0.00)), 0.00) AS Volume_LB
			FROM	Billback_Product
					INNER JOIN BSA_Foodservice_Items_Master
					ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
			WHERE	Billback_Product.Deleted = 0
			AND		Billback_Product.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
		</cfquery>

		<cfreturn qGetItemizedBillbackVolume />

	</cffunction>

	<!--- DRK: Label D17006 - Match Central--->
	<cffunction name="getBillbackPaidAmountMulti" access="public" output="false" returntype="numeric">

		<cfargument name="billbackIDList" type="string"  required="true">

		<cfset var var_amount = 0.00 />

		<cfquery name="qGetBillbackPaidAmountMulti" datasource="#application.datasource#">
			SELECT	sum(isnull(CAST(BB_Approved.Paid_Amount AS DECIMAL(18,2)), 0.00)) as Paid_Amount
			FROM 	BB_Approved
					INNER JOIN Billback ON
					Billback.Billback_ID = BB_Approved.Billback_ID
					AND Billback.Deleted = 0
			WHERE	BB_Approved.Billback_ID IN (<cfqueryparam value="#arguments.billbackIDList#" cfsqltype="CF_SQL_VARCHAR" list="true" />)
		</cfquery>

		<!---if we get a recordset back then set it to the return variable--->
		<cfif qGetBillbackPaidAmountMulti.RecordCount>
			<cfset var_amount = qGetBillbackPaidAmountMulti.Paid_Amount />
		</cfif>

		<cfreturn var_amount />

	</cffunction>

	<cffunction name="getBillbackDetails" access="public" output="false" returntype="query">

		<cfargument name="billbackID" type="string"  required="true">

		<cfquery name="qGetBillbackDetails" datasource="#application.datasource#">
			SELECT	Billback.*, Paid_Amount
			FROM 	Billback
			LEFT JOIN BB_approved
			ON		Billback.Billback_ID = BB_Approved.Billback_ID
			WHERE	Billback.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
		</cfquery>

		<cfreturn qGetBillbackDetails />

	</cffunction>

	<!--- TSF: Label 9231 - This method get's the paid amount for a given billback--->
	<cffunction name="getBillbackPaidAmount" access="public" output="false" returntype="numeric">

		<cfargument name="billbackID" type="string"  required="true">

		<cfset var var_amount = 0.00 />

		<cfquery name="qGetBillbackPaidAmount" datasource="#application.datasource#">
			SELECT	isnull(cast(BB_Approved.Paid_Amount as decimal(18,2)), 0.00) as Paid_Amount
			FROM 	BB_Approved
					INNER JOIN Billback ON
					Billback.Billback_ID = BB_Approved.Billback_ID
					AND Billback.Deleted = 0
			WHERE	BB_Approved.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
		</cfquery>

		<!---if we get a recordset back then set it to the return variable--->
		<cfif qGetBillbackPaidAmount.RecordCount>
			<cfset var_amount = qGetBillbackPaidAmount.Paid_Amount />
		</cfif>

		<cfreturn var_amount />

	</cffunction>

	<!--- TSF: Label 9231 - This method get's the sum of all the paid voume (cs/lb) for a given billback--->
	<cffunction name="getBillbackPaidVolumeSum" access="public" returntype="query">

		<cfargument name="billbackID" type="string"  required="true">

		<cfset var qGetBillbackPaidVolume = "" />

		<cfquery name="qGetBillbackPaidVolume" datasource="#application.datasource#">
			SELECT	ISNULL(SUM(BB_Item_Final.Item_Volume_Paid_CS), 0.00) AS TotalPaidCS,
					ISNULL(SUM(BB_Item_Final.Item_Volume_Paid_LB), 0.00) AS TotalPaidLB
			FROM 	BB_Item_Final
					INNER JOIN Billback ON
					Billback.Billback_ID = BB_Item_Final.Billback_ID
					AND Billback.Deleted = 0
			WHERE 	BB_Item_Final.Deleted = 0
			AND 	BB_Item_Final.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
		</cfquery>

		<cfreturn qGetBillbackPaidVolume />


	</cffunction>

	<!--- TSF: Label 9469 - This method get's the itemized amount for a given billback--->
	<cffunction name="getBillbackItemizedAmount" access="public" output="false" returntype="numeric">

		<cfargument name="billbackID" type="string"  required="true">

		<cfset var itemizedAmount = 0.00 />

		<cfquery name="qGetBillbackItemizedAmount" datasource="#application.datasource#">
			SELECT	cast(
					ISNULL(SUM(CAST(Billback_Product_Detail.BB_Rate AS DECIMAL(18,2))), 0.00) +
					(
						SELECT	ISNULL(SUM(CAST(Amount AS DECIMAL(18,2))), 0.00)
						FROM	Billback_Program_Lumpsum_Component
						WHERE	Deleted = 0
						AND 	Billback_Program_Lumpsum_Component.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
					)
					AS DECIMAL (18,2)) AS Total
			FROM	Billback_Product_Detail
					INNER JOIN Billback_Product ON
					Billback_Product_Detail.Billback_ID = Billback_Product.Billback_ID AND
					Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
			WHERE	Billback_Product_Detail.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
			AND		Billback_Product.Deleted = 0
			AND 	Billback_Product_Detail.Deleted = 0

		</cfquery>

		<!---if we get a record set back and the value is numeric then set it to the return variable--->
		<cfif qGetBillbackItemizedAmount.RecordCount and isNumeric(qGetBillbackItemizedAmount.Total)>
			<cfset itemizedAmount = qGetBillbackItemizedAmount.Total />
		</cfif>

		<cfreturn itemizedAmount />

	</cffunction>

	<!--- Inserts a payee based on ID and payee type --->
	<cffunction name="InsertBBPayee" access="public" output="true" returntype="string">
		<cfargument name="Billback_ID" required="true">
		<cfargument name="Payee_ID" required="true">
		<cfargument name="Payee_Type_ID" required="true">

		<cfswitch expression="#Payee_Type_ID#">
			<!--- Payee is distributor --->
			<cfcase value="1">
				<cfset useLakebaseForInsertPayee = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor")>
<cfif useLakebaseForInsertPayee>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_distributor", {
			"billback_id" = "#arguments.Billback_ID#",
			"distributor_id" = "#arguments.Payee_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertPayee = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertPayee>
<cfquery name="InsertPayee" datasource="#application.datasource#">
				INSERT INTO Billback_Distributor
				(
					Billback_ID,
					Distributor_ID
				)
				VALUES
				(
					'#arguments.Billback_ID#',
					'#arguments.Payee_ID#'
				)
				SELECT Billback_Distributor_ID AS Billback_Payee_ID FROM Billback_Distributor
				WHERE Billback_ID = '#arguments.Billback_ID#'
				AND Distributor_ID = '#arguments.Payee_ID#'
				</cfquery>
</cfif>
				<cfset Billback_Payee_ID = InsertPayee.Billback_Payee_ID>
			</cfcase>
			<!--- Payee is operator --->
			<cfcase value="2">
				<cfquery name="InsertPayee" datasource="#application.datasource#">
				INSERT INTO Billback_Operator
				(
					Billback_ID,
					Operator_ID
				)
				VALUES
				(
					'#arguments.Billback_ID#',
					'#arguments.Payee_ID#'
				)
				SELECT Billback_Operator_ID AS Billback_Payee_ID FROM Billback_Operator
				WHERE Billback_ID = '#arguments.Billback_ID#'
				AND Operator_ID = '#arguments.Payee_ID#'
				</cfquery>
				<cfset Billback_Payee_ID = InsertPayee.Billback_Payee_ID>
			</cfcase>
			<!--- Payee is broker --->
			<cfcase value="3">
				<cfquery name="InsertPayee" datasource="#application.datasource#">
				INSERT INTO Billback_Broker
				(
					Billback_ID,
					Broker_ID
				)
				VALUES
				(
					'#arguments.Billback_ID#',
					'#arguments.Payee_ID#'
				)
				SELECT Billback_Broker_ID AS Billback_Payee_ID FROM Billback_Broker
				WHERE Billback_ID = '#arguments.Billback_ID#'
				AND Broker_ID = '#arguments.Payee_ID#'
				</cfquery>
				<cfset Billback_Payee_ID = InsertPayee.Billback_Payee_ID>
			</cfcase>
		</cfswitch>

		<cfreturn Billback_Payee_ID />

	</cffunction>

	<cffunction name="getReferencedBillbacks" access="public" returntype="query" output="true">
		<cfargument name="Billback_ID" Required="true">
		<cfset var Get_Affected_Billbacks = "">
		<CFQUERY NAME="Get_Affected_Billbacks" DATASOURCE="#application.datasource#">
					SELECT	DISTINCT B.BB_Code, B.BB_Title, B.BB_Start_Date,
							B.BB_End_Date, B.Billback_Status_ID, BA.Date_Approved,'EX' AS Type
					FROM	BB_Program_Exclusion Ex
					INNER JOIN Billback B ON
							B.Billback_ID = Ex.Exclusion_Deducted_From_BB_ID AND
							Ex.Deleted = 0
					INNER JOIN BB_Approved BA ON
							BA.Billback_ID = B.Billback_ID
					WHERE
							Ex.Billback_ID = '#arguments.Billback_ID#' AND
							Applied = 1

				UNION	 ---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
					SELECT	DISTINCT B.BB_Code, B.BB_Title, B.BB_Start_Date,
							B.BB_End_Date, B.Billback_Status_ID, BAP.Date_Approved,'ADJ' AS Type
					FROM	BB_Adjustment BAJ
					INNER JOIN Billback B ON
							B.Billback_ID = BAJ.Adjustment_deducted_From_BB_ID AND
							BAJ.Deleted = 0
					INNER JOIN BB_Approved BAP ON
							BAP.Billback_ID = B.Billback_ID
					WHERE
							BAJ.Billback_ID = '#arguments.Billback_ID#' AND
							Applied = 1

				UNION	---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
					SELECT	DISTINCT B.BB_Code, B.BB_Title, B.BB_Start_Date,
							B.BB_End_Date, B.Billback_Status_ID, BA.Date_Approved,'PB' AS Type
					FROM	BB_Auto_Report_PB_Log PL
					INNER JOIN Billback B ON
							B.Billback_ID = PL.Applied_To_Billback_Id AND
							PL.Deleted = 0
					INNER JOIN BB_Approved BA ON
							BA.Billback_ID = B.Billback_ID
					WHERE
							PL.Billback_Id = '#arguments.Billback_ID#' AND
							PL.Applied = 1

				UNION	 ---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
					SELECT	DISTINCT B.BB_Code, B.BB_Title, B.BB_Start_Date,
							B.BB_End_Date, B.Billback_Status_ID, BA.Date_Approved,'BrkPB' AS Type
					FROM	dbo.Brk_PB_Log PL
					INNER JOIN Billback B ON
							B.Billback_ID = PL.Applied_To_Billback_Id AND
							PL.Deleted = 0
					INNER JOIN BB_Approved BA ON
							BA.Billback_ID = B.Billback_ID
					WHERE
							PL.Billback_Id = '#arguments.Billback_ID#' AND
							PL.Applied = 1
				</CFQUERY>
		<cfreturn Get_Affected_Billbacks />
	</cffunction>

	<cffunction name="getAffectedBillbacks" access="public" returntype="query">
		<cfargument name="Billback_ID" Required="true">
		<cfargument name="Payee_ID" Required="true">
		<cfargument name="DEVIATION_CONSTANTS_Trade_Shelter" Required="true">
		<cfargument name="DEVIATION_CONSTANTS_Operator_Deviated" Required="true">
		<cfargument name="Billback_Payee_Type_ID" Required="true">
		<cfset var Get_Affected_Billbacks = "">
		<CFQUERY NAME="Get_Affected_Billbacks" DATASOURCE="#application.datasource#">
					SELECT	DISTINCT B2.BB_Code, B2.BB_Title, B2.BB_Start_Date, B2.BB_End_Date, B2.Billback_Status_ID, BA2.Date_Approved
					FROM	Billback B1
							INNER JOIN BB_Approved BA1 ON
								BA1.Billback_ID = B1.Billback_ID
							INNER JOIN Billback_Program BP1 ON
								B1.Billback_ID = BP1.Billback_ID AND
								BP1.Deleted = 0
							INNER JOIN Contract_Main CM1 ON
								CM1.Contract_Main_ID = BP1.Program_ID
							INNER JOIN Program_Control_Panel_Options PT1 ON
								PT1.ProgramControl_Panel_Options_ID  = CM1.ProgramType_ID
							INNER JOIN Billback_Product BPT1 ON
								BP1.Billback_ID = BPT1.Billback_ID AND
								BPT1.Deleted = 0
							INNER JOIN Billback_Product BPT2 ON
								BPT2.Product_ID = BPT1.Product_ID AND
								BPT2.Deleted = 0
							INNER JOIN Billback_Program BP2 ON
								BP2.Billback_Program_ID = BPT2.Billback_Program_ID AND
								BP2.Deleted = 0
							INNER JOIN Contract_Main CM2 ON
								CM2.Contract_Main_ID = BP2.Program_ID AND
								((
									PT1.Generic_Type =  '#arguments.DEVIATION_CONSTANTS_Trade_Shelter#' AND
									CM2.Contract_Number = CM1.Contract_Number
								)
								OR
								(
									PT1.Generic_Type IN (#ListQualify(arguments.DEVIATION_CONSTANTS_Operator_Deviated, "'")#)
								))
							INNER JOIN Program_Control_Panel_Options PT2 ON
								PT2.ProgramControl_Panel_Options_ID  = CM2.ProgramType_ID AND
								(
									PT2.Generic_Type IN  (#ListQualify(arguments.DEVIATION_CONSTANTS_Operator_Deviated, "'")#)
									OR
									CM2.Contract_Number = CM1.Contract_Number
								)
							INNER JOIN Billback B2 ON
								B2.Billback_ID <> B1.Billback_ID AND
								B2.Billback_ID = BP2.Billback_ID AND
								B2.Billback_Payee_Type_ID = 1 AND
								B2.Deleted = 0
							INNER JOIN	Billback_Distributor BD2 ON
								BD2.Billback_ID = B2.Billback_ID AND
								<CFIF Billback_Payee_Type_ID EQ 1>
									BD2.Distributor_ID = '#arguments.Payee_ID#'
								<CFELSE>
									1=2
								</CFIF>	AND
								BD2.Deleted = 0
							INNER JOIN BB_Approved BA2 ON
							BA2.Billback_ID = B2.Billback_ID AND
							(dbo.D_DATEDIFF('ms', BA1.Date_Approved, BA2.Date_Approved) > 0)
					WHERE
							B1.Billback_ID = '#arguments.Billback_ID#' AND
							B1.Deleted = 0
					ORDER BY BA2.Date_Approved
				</CFQUERY>
		<cfreturn Get_Affected_Billbacks />
	</cffunction>

	<!--- Find if the billback has default program on it --->
	<cffunction name="getBillbackDefaultProgram" access="public" returntype="boolean">
		<cfargument name="BillbackID" 	type="string"  required="true" default="">

		<cfset var bReturnValue = 0 />

		<cfset useLakebaseForGetBillbackSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForGetBillbackSettings>
	<cftry>
		<cfset GetBillbackSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "default_program"
			}), "default_program"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBillbackSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBillbackSettings>
<CFQUERY name="GetBillbackSettings" datasource="#application.datasource#">
			SELECT 	Default_Program
			FROM 	Billback_Settings
		</CFQUERY>
</cfif>

		<cfif len(trim(GetBillbackSettings.Default_Program)) GT 0>
			<cfset useLakebaseForIsDefaultProgramOnBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForIsDefaultProgramOnBillback>
	<cftry>
		<cfset IsDefaultProgramOnBillback = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#arguments.BillbackID#",
				"program_id" = "eq.#GetBillbackSettings.Default_Program#",
				"deleted" = "eq.0",
				"select" = "billback_program_id"
			}), "billback_program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsDefaultProgramOnBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsDefaultProgramOnBillback>
<cfquery name="IsDefaultProgramOnBillback" datasource="#application.datasource#">
				SELECT 	Billback_Program_ID
				FROM 	Billback_Program
				WHERE 	Billback_ID = '#arguments.BillbackID#'
				AND 	Program_ID = '#GetBillbackSettings.Default_Program#'
				AND 	Deleted = 0
			</cfquery>
</cfif>
			<cfif IsDefaultProgramOnBillback.Recordcount GT 0>
				<cfset bReturnValue = 1>
			</cfif>
		</cfif>

		<cfreturn bReturnValue />
	</cffunction>

	<cffunction name="getBillbackClosingMethods" access="public" returntype="query">

		<cfset useLakebaseForqgetBillbackClosingMethods = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_closing_methods")>
<cfif useLakebaseForqgetBillbackClosingMethods>
	<cftry>
		<cfset qgetBillbackClosingMethods = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_closing_methods", {
				"deleted" = "eq.0",
				"select" = "ibillback_closing_method_id,vchbillback_closing_method_desc,abbreviation"
			}), "ibillback_closing_method_id,vchbillback_closing_method_desc,abbreviation"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetBillbackClosingMethods = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetBillbackClosingMethods>
<cfquery name="qgetBillbackClosingMethods" datasource="#application.datasource#">
		 SELECT iBillback_Closing_Method_ID,vchBillback_Closing_Method_DESC,Abbreviation
		 FROM Billback_Closing_Methods
		 WHERE 	Deleted = 0
		</cfquery>
</cfif>

		<cfreturn qgetBillbackClosingMethods />
	</cffunction>

	<cffunction name="saveBillbackClosingMethod" access="public" returntype="void">
		<cfargument name="billbackID" required="true" type="string">
		<cfargument name="BBReasonCodeIDList" required="true" type="string">

		<cftransaction action="begin">
			<cftry>
				<cfquery name="qDeleteBillbackReasonCode" datasource="#application.datasource#">
				 DELETE BB_Reason_Code_Selection
				 WHERE	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
				</cfquery>
				<cfloop list="#arguments.BBReasonCodeIDList#" index="reasonCodeId">
					<cfif isNumeric(reasonCodeId) and reasonCodeId neq "0">
					<cfquery name="qInsertBillbackReasonCode" datasource="#application.datasource#">
					 INSERT INTO BB_Reason_Code_Selection (Billback_ID, BB_Reason_Code_ID)
					 VALUES
					 (
					 	<cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />,
					 	<cfqueryparam value="#reasonCodeId#" cfsqltype="cf_sql_integer" />
					 )
					</cfquery>
					</cfif>
				</cfloop>
				<cftransaction action="commit" />

				<cfcatch>
					<cftransaction action="rollback" />
					<cfrethrow />
				</cfcatch>
			</cftry>
		</cftransaction>


	</cffunction>

	<cffunction name="getSavedBillbackClosingMethod" access="public" returntype="query">
		<cfargument name="billbackID" required="true" type="string">

		<cfquery name="qGetBillbackReasonCode" datasource="#application.datasource#">
			SELECT 		DD_Reason_Code_ID, DD_Reason_Code_Description, DD_Reason_Code
			FROM 		DD_Reason_Code
			INNER JOIN 	BB_Reason_Code_Selection
			ON			BB_Reason_Code_Selection.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
			AND			BB_Reason_Code_Selection.BB_Reason_Code_ID = DD_Reason_Code.DD_Reason_Code_ID
			WHERE 		DD_Reason_Code.Deleted = 0
			ORDER BY	DD_Reason_Code_Description
		</cfquery>

		<cfreturn qGetBillbackReasonCode />

	</cffunction>


	<cffunction name="getBillbackDetailsInfo" access="public" output="false" returntype="query">
			<cfargument name="billbackID" type="string"  required="true">

			<cfquery name="qGetBillbackDetails" datasource="#application.datasource#">
				SELECT	Billback.BB_Code,Billback.BB_Start_Date,Billback.BB_End_Date,Billback.BB_Title,
						Billback.BB_parent_ID,Billback.BB_Amount,Billback.Deviation_Ran_Date,
						BB_approved.Paid_Amount,
						Analyst_User.Name_First + ' ' + Analyst_User.Name_Last As Analyst_User,
						Deviation_User.Name_First + ' ' + Deviation_User.Name_Last As Deviation_User,
						BB_Approved.Check_Number,Billback.referenceNum,Billback.BB_Upload_Dup_Group_ID,
						Billback.Cannot_Exceed_Percent,Billback.Cannot_Exceed_Dollar,
						Billback.Auto_Dev_Max_Dollar_Amount,Billback.Auto_Deviated_Percent,
						Billback.Auto_Deviated_Amt
				FROM 	Billback
				LEFT JOIN BB_approved
				ON		Billback.Billback_ID = BB_Approved.Billback_ID
				LEFT JOIN _Users Analyst_User
				ON 	Analyst_User.User_ID = Billback.Analyst_User_ID
				LEFT JOIN _Users Deviation_User
				ON 	Deviation_User.User_ID = Billback.Deviation_Ran_By

				WHERE	Billback.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
			</cfquery>

		<cfreturn qGetBillbackDetails />
	</cffunction>
	<!---D55703 :: Vendor required setting in closing method settings panel START--->
	<cffunction name="setBillbackPendingVendorID" access="public" returntype="numeric">
		<cfargument name="Billback_ID" required="true">
		<cfargument name="Payee_Type_ID" required="true">
		<cfargument name="Vendor_Required" required="true">

		<cfset var Billback_Status_ID = 0>
		<CFSWITCH expression="#arguments.Payee_Type_ID#">
			<CFCASE value="1"><!--- Distributor --->
				<cfquery name="getPayeeData" datasource="#Application.Datasource#">
					SELECT *
					FROM 	Billback_Distributor
					WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Billback_ID#">
					AND 	Deleted = 0
				</cfquery>
			</CFCASE>

			<CFCASE value="2"><!--- Operator --->
				<cfquery name="getPayeeData" datasource="#Application.Datasource#">
					SELECT *
					FROM 	Billback_Operator
					WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Billback_ID#">
					AND 	Deleted = 0
				</cfquery>
			</CFCASE>

			<CFCASE value="3"><!--- Broker --->
				<cfquery name="getPayeeData" datasource="#Application.Datasource#">
					SELECT *
					FROM 	Billback_Broker
					WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Billback_ID#">
					AND 	Deleted = 0
				</cfquery>
			</CFCASE>
		</CFSWITCH>

		<cfif len(getPayeeData.Uploaded_Vendor_ID)>
			<cfquery name="UpdateBBApproved" datasource="#application.datasource#">
				UPDATE 	BB_Approved
				   SET 	BB_Approved.Vendor_Master_ID = Vendor_Master.Vendor_Master_ID
				   FROM BB_Approved
				        INNER JOIN VENDOR_MASTER ON Vendor_Master.Vendor_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getPayeeData.Uploaded_Vendor_ID#">
				 WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Billback_ID#">
			</cfquery>
		</cfif>
		<cfif ! len(getPayeeData.Uploaded_Vendor_ID) AND arguments.Vendor_Required>
			<cfquery name="UpdateBillbackStatus" datasource="#application.datasource#">
				UPDATE 	Billback
				SET 			Billback_Status_ID = 7
				WHERE 	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Billback_ID#">
			</cfquery>
			<cfset Billback_Status_ID= 7>
		</cfif>
		<cfreturn Billback_Status_ID />
	</cffunction>
	<!---D55703 :: Vendor required setting in closing method settings panel END--->

	<!---
	Dev Note: 70354 - Check to see whether billback and deduction is a 'one to one' relationship". If it is, then return the deduction associated to the billback.
	The reason why we look at 'one to one' relationship" is the following -
	- First of all, there cannot be multiple deductions associated to a billback, but there could be multiple billbacks associated to a deduction
	and so when we look for asssociated deductions for a billback which needs to be set to "Manual void", we just cannot unassociate the deduction from the billback
	if there are other billbacks also associated to that deduction. So, to make it simple, we just look for 'one to one' relationship".
	--->
	<cffunction name="getAssociatedDeductionForBillback" returntype="query" access="public">
		<cfargument name="billbackId" type="string" required="yes">

		<cfset var OnetoOneRelationship = 0>

		<cfquery name="qGetAssociatedDeduction" datasource="#application.datasource#">
			SELECT Deduction_ID
			FROM   DD_Closure_Detail
			WHERE  DD_Closure_ID = <cfqueryparam value='#arguments.billbackId#'>
			AND deleted = 0
		</cfquery>

		<cfif qGetAssociatedDeduction.recordcount eq 1>
			<cfquery name="qGetNumberOfAssociatedBillbacks" datasource="#application.datasource#">
				SELECT Count(DD_Closure_Detail_ID) As NumberOfBillbacks
				FROM   DD_Closure_Detail
				WHERE  Deduction_id = <cfqueryparam value='#qGetAssociatedDeduction.Deduction_ID#'>
				AND deleted = 0
			</cfquery>
			<!--- If there is only one billback associated to a deduction --->
			<cfif qGetNumberOfAssociatedBillbacks.NumberOfBillbacks eq 1>
				<cfset OnetoOneRelationship = 1>
			</cfif>
		</cfif>

		<cfquery name="qGetDeductionInfo" datasource="#application.datasource#">
			SELECT Deduction_ID,DD_DedID,DD_Reference,DD_Amount,CONVERT(Char(10),DD_Date,101) As DD_Date,dd_status
			FROM   Deductions
			WHERE  Deduction_id =  <cfqueryparam value='#qGetAssociatedDeduction.Deduction_ID#'>
			<cfif OnetoOneRelationship neq 1>
			AND 1 <> 1
			</cfif>
		</cfquery>

		<cfreturn qGetDeductionInfo>
	</cffunction>

	<cffunction name="setBillbackToApprovedVoid" returntype="void" access="public" hint="Unassociate deduction from billback">
		<cfargument name="billbackId" type="string" required="yes">

			<cfset var qAssociatedDeductionForBillback = getAssociatedDeductionForBillback(arguments.billbackId)>

			<CFTRANSACTION ACTION="Begin">

				<!--- Set the Status to "Approved - Void" --->
				<cfquery name="updReverse" datasource="#application.datasource#">
				UPDATE	Billback
					 SET	Billback_Status_ID	= 8
								,BB_Void_Multiplier	= -1
								,BB_Void_Notification_Sent	= 0
								,BB_Void_Date	= getdate()
								,BB_Reversed	= 1
								,BB_Reversed_By	= <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar" />
								,BB_Reversed_Date	= GETDATE()
				WHERE Billback_ID =  <cfqueryparam value='#arguments.billbackId#'>
				</cfquery>

				<!--- Dev Note: drachala; D27969: BBK in approved void status not removed from budget dollars on program  START
				What  I did: Add Code to call below routine after the reversal--->
						 <cfstoredproc procedure="BUDGET_PROGRAM_ACTUAL_UPDATE" datasource="#application.datasource#">
						 <CFPROCPARAM CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#arguments.billbackId#">
						 </cfstoredproc>
				<!--- End Dev Note: drachala; D27969: BBK in approved void status not removed from budget dollars on program  --->

					<!--- Remove the associated deductions (if any) --->
					<cfif qAssociatedDeductionForBillback.Recordcount GT 0>

						<cfquery name="qGetAssociatedDeduction" datasource="#application.datasource#">
							SELECT Deduction_ID
							FROM   DD_Closure_Detail
							WHERE  DD_Closure_ID = <cfqueryparam value='#arguments.billbackId#'>
							AND deleted = 0
						</cfquery>

						<!--- Set the deduction to "open" status --->
						<cfquery name="qUnAssociateDeduction1" datasource="#application.datasource#">
							UPDATE	Deductions
							SET		DD_Status = 2,
									ReOpened = 0,
									DD_ReOpened_On = getdate(),
									DD_Reopened_Sent = 0,
									DD_Closure_Sent = 0,
									DD_Closure_GL_Sent = 0,
									Ack_Received_Closure = 0,
									Ack_Received_Reopen = 0,
									DD_Closure_Type = NULL,
									DD_Closure_ID = NULL,
									Split_Count = 0,
									DD_Closure_BBPaid = 0
							WHERE   Deduction_ID = <cfqueryparam value='#qGetAssociatedDeduction.Deduction_ID#'>
						</cfquery>

						<cfquery name="qUnAssociateDeduction2" datasource="#application.datasource#">
							UPDATE	DD_Closure_Detail
								SET		Deleted = 1
							WHERE	 DD_closure_ID = <cfqueryparam value='#arguments.billbackId#'>
						</cfquery>

						<cfquery name="getBillbackInfo" datasource="#application.datasource#">
							SELECT BB_Code
								FROM Billback
							WHERE	Billback_ID = <cfqueryparam value='#arguments.billbackId#'>
						</cfquery>

						<!--- Add dd notes entry also as a log --->
						<cfquery name="qInsertLog" datasource="#application.datasource#">
							INSERT INTO DD_Notes(Deduction_ID,DD_Note,DD_Note_Date,DD_Note_By,Automated_Notes)
							VALUES ('#qGetAssociatedDeduction.Deduction_ID#','Deduction unassociated to payable ## #getBillbackInfo.BB_Code# via Manual Void option.',getdate(),'#request.AccessStructure.User_ID#',1)
						</cfquery>

					</cfif>

				<CFTRANSACTION action = "commit">
			</CFTRANSACTION>

	</cffunction>

	</cfcomponent>