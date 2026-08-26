<!------

/report_writer/program_pricing_report_display.cfm

---->
<cfparam name="programClaimRateReportFileName" default="Pricing.csv">
<cfparam name="form.Report_Type" default = "0">
<!----
<cfheader name="Content-Disposition" value="attachment;filename=#deviationReportFileName#">
<cfcontent type="text/plain" />
---->
<!--- 
	Report Type = 1 is claim rates report
	Report Type = 2 is pricing report
--->
<!--- Report Header --->
<cfset csvstr = createObject("java","java.lang.StringBuffer")>
	<cfset csvstr.append("PROGRAM NUMBER" & ",")>
	<cfset csvstr.append("PROGRAM TITLE" & ",")>
	<cfset csvstr.append("EFFECTIVE DATE" & ",")>
	<cfset csvstr.append("DISTRIBUTOR ID" & ",")>
	<cfset csvstr.append("DISTRIBUTOR NAME" & ",")>
	<cfset csvstr.append("OPERATOR ID" & ",")>
	<cfset csvstr.append("OPERATOR NAME" & ",")>
	<cfset csvstr.append("START DATE" & ",")>
	<cfset csvstr.append("END DATE" & ",")>
	<cfset csvstr.append("WAREHOUSE NAME" & ",")>
	<cfset csvstr.append("COMPONENT TYPE" & ",")>
	<cfset csvstr.append("COMPONENT NAME" & ",")>
	<cfset csvstr.append("FREIGHT BRACKET DESC" & ",")>
	<cfset csvstr.append("ITEM NUMBER" & ",")>
	<cfset csvstr.append("ITEM DESCRIPTION" & ",")>
	<!--- Just a different header name for the pricing report --->
	<cfset csvstr.append("REBATE RATE PER CASE" & ",")>
	<cfset csvstr.append("FIXED PRICE PER CASE" & ",")>
	<cfset csvstr.append("DEL PRICE PER CASE" & ",")>
	<cfset csvstr.append("PUA PER CASE" & ",")>
	<cfset csvstr.append("FDC PRICE PER CASE" & ",")>
	<cfset csvstr.append("GROSS WEIGHT" & ",")>
	<cfset csvstr.append("NET WEIGHT" & ",")>
	<cfset csvstr.append(Chr(13) & Chr(10))>

<!--- Report Details --->
<cfloop query="qProgramClaimRatesReport">
	<cfset csvstr.append(PROGRAM_NUMBER & ",")>
	<cfset csvstr.append(replace(PROGRAM_TITLE, ",", "") & ",")>
	<cfset csvstr.append(DateFormat(EFFECTIVE_DATE, "mm/dd/yyyy") & ",")>
	<cfset csvstr.append(DISTRIBUTOR_ID & ",")>
	<cfset csvstr.append(replace(DISTRIBUTOR_NAME, ",", "") & ",")>
	<cfset csvstr.append(OPERATOR_ID & ",")>
	<cfset csvstr.append(replace(OPERATOR_NAME, ",", "") & ",")>
	<cfset csvstr.append(DateFormat(START_DATE, "mm/dd/yyyy") & ",")>
	<cfset csvstr.append(DateFormat(END_DATE, "mm/dd/yyyy") & ",")>
	<cfset csvstr.append(replace(WAREHOUSE_NAME, ",", "") & ",")>
	<cfset csvstr.append(COMPONENT_TYPE & ",")>
	<cfset csvstr.append(COMPONENT_NAME & ",")>
	<cfif fixed_component_type eq 1>
		<cfset csvstr.append(FREIGHT_BRACKET_LABEL & ",")>
	<cfelse>
		<cfset csvstr.append('' & ",")>
	</cfif>
	<cfset csvstr.append(ITEM_NUMBER & ",")>
	<cfset csvstr.append(replace(ITEM_DESCRIPTION, ",", "") & ",")>
<!--- The db field name is common for both the reports--->
	<cfset csvstr.append(EXPECTED_REBATE_RATE_PER_CASE & ",")>
	<cfset csvstr.append(PROGRAM_FIXED_PRICE_PER_CASE & ",")>
<!--- Show Delievered and PUA only for Delivered component --->
<cfif fixed_component_type eq 1>
	<cfset csvstr.append(DEL_PRICE_PER_CASE & ",")>
	<cfset csvstr.append(PROGRAM_PUA_PER_CASE & ",")>
<cfelse>
		<cfset csvstr.append('' & ",")>
	<cfset csvstr.append('' & ",")>
</cfif>
	<cfset csvstr.append(FDC_PRICE_PER_CASE & ",")>
	<cfset csvstr.append(GROSS_WEIGHT & ",")>
	<cfset csvstr.append(NET_WEIGHT & ",")>
	<cfset csvstr.append(Chr(13) & Chr(10))>
</cfloop>

<!--- Output the report --->
<CFOUTPUT>#csvstr.toString()#</CFOUTPUT>