<!--- first of all, get the whole days span of the current fiscal year --->
<!--- if the invoice date falls into the current fiscal year, --->
<!--- then we don't need to recount the start and end date of the year of invoice date --->
<!--- if the invoice date is later or earlier than the last date of the current fiscal year, --->
<!--- then we need to recount the start or end date of the year of the invoice date, --->
<!---		in other words, we need to locate what's the periods layout for that fiscal year--->
<!--- the way to handle the period layout is as follows: --->
<!--- if invoice date is later than the last date of current fiscal year, --->
<!--- then first locate the current end date of the current fiscal year, --->
<!--- 		plus the days of the many span between, invoice date - end date / days span - 1--->
<!--- if invoice date is earlier than the start date of the current fiscal year, --->
<!--- then locate the end date of current fiscal year, minus the days of the span days --->
<!---=================== test =============---->
<cfif not isDefined("FORM.invoicedate")>
	<cfset FORM.invoicedate = "04/02/2003">
</cfif>
<!---====================end test =========---->
<!--- get given date --->
<cfset todayDate = FORM.invoicedate >
<cfset defaultdate =  DateFormat(now(), "mm/dd/yyyy")>
<CFSET objHandle = CreateObject("component", "components.futures_pricing.DistributedVolumeFactory")>
<cfif Not isDefined("request.AccessStructure.company_main_id") >
	<cfset company_main_id_value = form.company_main_id >
<cfelse>
	<cfset company_main_id_value = request.AccessStructure.company_main_id >
</cfif>

<!--- based on the start date and end date of the current fiscal period, get last year's start and end date of the same fiscal period --->
<CFQUERY NAME="FiscalSpanQuery" DATASOURCE="#application.datasource#">	
	select distinct  min(start_date) as FYSD, max(end_date) as FYED
	from fiscal_year
	where 
		Company_Main_ID = '#company_main_id_value#'
		and deleted = 0
</CFQUERY>
<!--- fiscal year start and end date --->
<cfset FYSD = DateFormat(FiscalSpanQuery.FYSD, "mm/dd/yyyy")>
<cfset FYED = DateFormat(FiscalSpanQuery.FYED, "mm/dd/yyyy")>
<!--- how many days span between start and end --->
<cfset DateSpan = DateDiff("d", FYSD, FYED)>
<!--- get the fiscal period based on the today date --->
<cfset comRS = objHandle.getDatePeriods(2,todayDate,todayDate,company_main_id_value)>
<cfset currFPStart_Date = DateFormat((comRS[1].periodstartdate), "mm/dd/yyyy")>
<cfset currFPEnd_Date = DateFormat((comRS[1].periodenddate), "mm/dd/yyyy")>
<cfset FYPSD = currFPStart_Date >
<cfset FYPED = currFPEnd_Date >
<cfif currFPStart_Date EQ "" or currFPEnd_Date EQ "">
	<cfabort>
</cfif>
<!--- start date for the fiscal period last year, end date for fiscal period last year --->
<cfset LFYPSD = DateFormat(DateAdd("d", DateSpan * -1, currFPStart_Date), "mm/dd/yyyy")>
<cfset LFYPED = DateFormat(DateAdd("d", DateSpan * -1, currFPEnd_Date), "mm/dd/yyyy")>
<!---check todaydate against fiscal year start and end date to determine the FYSD and FYED --->
<!--- need to adjust the fiscal year--->
<cfset invoice_year = DatePart("yyyy", todayDate) >
<cfset FY_Year = DatePart("yyyy", FYSD) >
<cfif todayDate GT FYED or  todayDate LT FYSD>
	<cfset FYSD = DateFormat(DateAdd("yyyy", invoice_year - FY_Year, FYSD), "mm/dd/yyyy") >
	<cfset FYED = DateFormat(DateAdd("d", DateSpan, FYSD), "mm/dd/yyyy")>
</cfif>
<!---to get the start and end date of the fiscal year of last year --->
<cfset LFYSD = DateFormat(DateAdd("d", DateSpan * -1, FYSD), "mm/dd/yyyy")>
<cfset LFYED = DateFormat(DateAdd("d", DateSpan * -1, FYED), "mm/dd/yyyy")> 
<!--- invoice date for last year--->
<cfset LYDD = DateFormat(DateAdd("d", DateSpan * -1, defaultdate), "mm/dd/yyyy")>
<!---to get the start and end date of quarter, LFYQSD, LFYQED--->
<!--- determine which quarter the current period should belong to --->
<cfset FYArray = objHandle.getDatePeriods(2,FYSD,FYED,company_main_id_value)>
<cfscript>
	FYQArray = ArrayNew(1); 
	for (i=1; i LE 12; i = i + 3)
	{
		ArrayAppend(FYQArray, StructNew());
		currFYQStruct = FYQArray[arrayLen(FYQArray)];
		currFYQStruct.start_date = FYArray[i].periodstartdate;
		currFYQStruct.end_date = FYArray[i+2].periodenddate;
	}
</cfscript>	
<cfloop index="i" from="1" to="#ArrayLen(FYQArray)#" Step="1">
     <cfif todayDate GE FYQArray[i].start_date and todayDate LE FYQArray[i].end_date>
	 	<cfset FYQSD = DateFormat(FYQArray[i].start_date,"mm/dd/yyyy")>
		<cfset FYQED = DateFormat(FYQArray[i].end_date,"mm/dd/yyyy")>
		<cfbreak>
	 </cfif>
</cfloop> 
<cfset LFYQSD = DateFormat(DateAdd("d", DateSpan * -1, FYQSD), "mm/dd/yyyy")>
<cfset LFYQED = DateFormat(DateAdd("d", DateSpan * -1, FYQED), "mm/dd/yyyy")> 
<!---reorganize the fiscal date based on the invoice date, default date - defaultdate, and each phrase start and end date--->
<!--- period --->
<cfif (defaultdate LT FYPED and defaultdate GT FYPSD) or (FYPSD GT defaultdate) >
	<cfset FYPED = defaultdate >
</cfif>
<!--- last period --->
<cfif (LYDD LT LFYPED and LYDD GT LFYPSD) or (LFYPSD GT LYDD) >
	<cfset LFYPED = LYDD >
</cfif>
<!--- quarter --->
<cfif (defaultdate LT FYQED and defaultdate GT FYQSD) or (FYQSD GT defaultdate) >
	<cfset FYQED = defaultdate >
</cfif>
<!--- last quarter --->
<cfif (LYDD LT LFYQED and LYDD GT LFYQSD) or (LFYQSD GT LYDD) >
	<cfset LFYQED = LYDD >
</cfif>
<!--- year --->
<cfif (defaultdate LT FYED and defaultdate GT FYSD) or (FYSD GT defaultdate) >
	<cfset FYED = defaultdate >
</cfif>
<!--- last year --->
<cfif (LYDD LT LFYED and LYDD GT LFYSD) or (LFYSD GT LYDD) >
	<cfset LFYED = LYDD >
</cfif>

