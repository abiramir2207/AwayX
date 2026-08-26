<!---
***********************************************************************
Author: Milan Mushran
Filename: Sales_Comparison.cfm
Purpose: For Summary and Detailed Volume Reports
Input Parameters (form):form.Service_Zone_ID,form.Service_Region_ID,form.Service_Market_ID,form.Broker_ID
						,form.Distributor_Shipto,form.Distributor_Name,form.start_date,form.end_date
Output parameters (URL): ErrorMessage
Custom Tag/s: None
Include Files: Utility_functions.cfm
Date Created: 09/30/2004
Modification: Added "Fiscal Period", "Calendar Period" and "OtherPeriod" search criterias for 
Modified By: Milan Mushran	
Modified Date:
***********************************************************************
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Volume Report</title>

<SCRIPT language="JavaScript">
function openNewWindow(CommType,FileName)
{
	if (CommType == 1)
	{
		NewWindow("Email_Create.cfm?FileName="+FileName, 'VolumeReport', '700', '400', 'Yes', 'No', true);
	}
	else if (CommType == 2)
	{
		NewWindow("Fax_Create.cfm?FileName="+FileName, 'VolumeReport', '700', '400', 'Yes', 'No', true);
	}
	else if (CommType == 3)
	{
		NewWindow("Print_Create.cfm?FileName="+FileName, 'VolumeReport', '800', '600', 'Yes', 'No', true);
	}
		
}
</SCRIPT>
</head>

	<cfinclude template="utility_functions.cfm">

<!--- Form variables passed from the search page --->
<cfparam name="form.Service_Zone_ID" default=0>
<cfparam name="form.Service_Region_ID" default=0>
<cfparam name="form.Service_Market_ID" default=0>
<cfparam name="form.Broker_ID" default=0>
<cfparam name="form.Distributor_Shipto" default=''>
<cfparam name="form.Distributor_Name" default=''>
<cfparam name="form.start_date" default="">
<cfparam name="form.end_date" default="">
<cfparam name="form.communicationtype" default="">	 
<cfparam name="form.DateType" default="">
<cfparam name="ReturnDates" default="0">
<cfparam name="Distributor_ID_For_Fiscal_Year" default="">

<!--- Start Error messages --->
 
<!--- Error message  for "No date selection" --->
<cfif CommunicationType EQ "">

	<cfif  IsDate(Form.Start_Date) AND IsDate(Form.End_date)>
	
		<!--- Error message for "search starting date falling after the search ending date" --->
		<cfif DateDiff("d", form.start_date, form.end_date) LT 0>
			<cfset ErrorMessage = "The search Ending Date must be after the search Starting Date.">
			<cflocation url="search_form.cfm?ErrorMessage=#ErrorMessage#">
			
		<!--- Error message for "Date range comprsing more than two years" --->
		<cfelseif Year(Form.End_Date) - Year(Form.Start_date) GT 1>
		<cfset ErrorMessage = "The search period cannot exceed two years">
			<cflocation url="search_form.cfm?ErrorMessage=#ErrorMessage#">
		</cfif> 
	
	<cfelse>
		<cfset ErrorMessage = "You must choose the search Starting Date and the search Ending Date for the Report"> 
		<cflocation url="search_form.cfm?ErrorMessage=#ErrorMessage#">
	</cfif>
	

<!--- End Error Messages --->

	<!--- If the Report type is an Excel File, prompt the user to open or save the file --->
	<cfif rReportType EQ "e">
		<cfcontent type="application/unknown">
		<cfheader name="Content-Disposition" value="attachment;filename=VolumeReport.xls">
	<!---
	<cfelseif rReportType EQ "c">
		<cfcontent type="application/unknown">
		<cfheader name="Content-Disposition" value="attachment;filename=VolumeReport.csv"> 
	--->
	
	</cfif>
	
	<!--- Initialize different arrays for the current year search and the prior year search --->
	<cfset CurrentSearchPeriodArray = ArrayNew(1)>
	<cfset PriorSearchPeriodArray = ArrayNew(1)>
		

	<!--- Get the Months for the Search Start Date and End Date --->
	<cfset Start_Month = Month(form.start_date)>
	<cfset End_Month = Month(form.end_date)>

	<!--- Get the Years for the Search Start Date and End Date --->
	<cfset Start_Year = Year(form.start_date)>
	<cfset Prior_Year = Year(DateAdd('YYYY', -1,form.end_date))>
	
	<!--- Current Year Search Start Date and End Date --->
	<cfset form.Current_Search_Start_Date = form.start_date>
	<cfset form.Current_Search_End_Date = form.end_date>
	

	<!--- Prior Year Search Start Date and End Date --->
	<cfset form.Prior_Search_Start_Date = DateFormat(DateAdd('yyyy',-1,form.Start_Date),"MM/DD/YYYY")>
	<cfset form.Prior_Search_End_Date = DateFormat(DateAdd('yyyy',-1,form.End_Date),"MM/DD/YYYY")>

	<!--- Pass the Current Year Search Start Date (YTD) and Current Year Search End Date (YTD) to get the Fiscal Start Dates
		for both the years --->
	<cfset DateComponent = CreateObject("component","components.Futures_Pricing.DistributedVolumeFactory")> 
	
	<!--- The above component accepts '1' for the Calendar Period and '2' for the Fiscal Period --->
	<cfif form.DateType eq "CalendarPeriod">
		<cfset ReturnDates = 1>
	<cfelseif form.DateType eq "FiscalPeriod" OR form.DateType eq "OtherPeriod">
		<cfset ReturnDates = 2>
	</cfif>

	<cfif form.DateType eq "OtherPeriod">

		<cfset CurrentYearDatePeriods = DateComponent.getDatePeriods(ReturnDates,form.Current_Search_Start_Date,form.Current_Search_End_Date,request.AccessStructure.Company_Main_ID,Distributor_ID_For_Fiscal_Year)>
		<cfset CurrentFiscalYearStart = getFiscalStartPeriod(form.Current_Search_Start_Date,Distributor_ID_For_Fiscal_Year)>
	
	<cfelse>
	
		<cfset CurrentYearDatePeriods = DateComponent.getDatePeriods(ReturnDates,form.Current_Search_Start_Date,form.Current_Search_End_Date,request.AccessStructure.Company_Main_ID)>
		<cfset CurrentFiscalYearStart = getFiscalStartPeriod(form.Current_Search_Start_Date)>
	</cfif>


<!--- Get the distributors based on the search criteris --->
	<cfquery name="selBrokerInfo" datasource="#application.datasource#">
	 SELECT cfc.BSA_Foodservice_Customers_ID, cfb.Broker_Name, cfb.Broker_Shard, cfc.Name, sm.Market_Name, sm.Market_Number
	 <cfif form.Service_Zone_ID neq 0>, sz.Zone_Name</cfif>
	  <cfif form.Service_Region_ID neq 0>, sr.Region_Name</cfif>
	   <cfif form.Distributor_Shipto neq ''>,cfc.Ship_to</cfif>
	 FROM   
	 	BSA_Foodservice_Customers cfc 
			INNER JOIN 
		BSA_Foodservice_Brokers cfb
	 			ON cfb.BSA_Foodservice_Brokers_ID = cfc.BSA_Foodservice_Brokers_ID
	 
	 		INNER JOIN Service_Markets sm
	 			ON sm.Service_Market_ID  = cfb.Service_Market_ID 
	 AND sm.Deleted = 0
	 
	 <cfif form.Service_market_ID neq 0>
	 AND sm.Service_Market_ID = '#Form.Service_Market_ID#'
	 </cfif>
	
	 <cfif form.Service_Region_ID neq 0>
	 		INNER JOIN Service_Regions sr
	 			ON sm.Service_Region_ID = sr.Service_Region_ID
	 AND sr.Deleted = 0
	 AND sr.Service_Region_ID = '#Form.Service_Region_ID#'
	 </cfif>
	 
	 <cfif form.Service_Zone_ID neq 0>
	 		INNER JOIN Service_Zones sz
	 			ON sz.Service_Zone_ID = sz.Service_Zone_ID
	 AND sz.Deleted = 0
	 AND sz.Service_Zone_ID = '#Form.Service_Zone_ID#'
	 </cfif>
	 
	 <cfif form.Broker_ID neq 0>
	 AND cfb.BSA_Foodservice_Brokers_ID = '#Form.Broker_ID#'
	 </cfif>

	 <cfif form.Distributor_Shipto neq ''>
	 AND cfc.Ship_to = '#Ltrim(Rtrim(Form.Distributor_Shipto))#'
	 </cfif>
	 
	 <cfif form.Distributor_Name neq ''>
	 AND cfc.Name = '#Ltrim(Rtrim(Form.Distributor_Name))#'
	 </cfif>
	 
	 WHERE cfb.Deleted = 0
	 AND cfb.Active_Code='A'
	 AND cfc.Deleted = 0
	 AND cfc.Active_Code='A'
	</cfquery> 
	

 <body> 

	<!--- If there are distributors for the search criteria --->
	<cfif selBrokerInfo.Recordcount neq 0>
	

	
		<CFSET PW_Type="1">
	<cfif IsDefined(rReportType) and rReportType EQ "h">
		<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
		 <br><br><br>
		 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		 <br><br><br>
		</SPAN>
		<!--- <CFFLUSH> --->
		<SCRIPT>
		document.all.PleaseWaitMessage.style.display='none';
		</SCRIPT>
	</cfif>
	<!--- Save the Report in a variable --->
	<!---
	<cfsavecontent variable ="VarVolumeReport">
	--->
	<style type="text/css">
	.heading 	
		{
		font-family: verdana,arial,helvetica; 
		font-size: 11px;
		font-weight: bold; 
		background: #FFB062;
		}
	.PageContent 
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:9px;
	}
	
	.PageHeaders 
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:9px;
		font-weight:bold;
	}
	
	.SectionHeaders
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:12px;
		font-weight:bold;
		color:brown;
	}
	TD.UNDERLINED
		{
		border-bottom: 1px solid #7575FF;
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:10px;
		}
	TR.highlight TD.UNDERLINED
		{
		background-color: #EAFFEA;
		}
	TR.nothighlight TD.UNDERLINED  
		{
		border-bottom: 1px solid #7575FF;
		}
	</style>

	<table width="100%" border="0">
	<tr>
		<td width="20%">&nbsp;</td>
		<td style="font-size:12px; font-weight:bold;text-align:center;" width="60%">SALES COMPARISON DETAIL BY SALES PERSON</td>
		<td style="font-size:11px;" align="left" width="20%">RUN DATE: <cfoutput>#DateFormat(now(),'mm/dd/yyyy')#</cfoutput></td>
	</tr>
	</table>


	<table width="100%" border="0" style="text-align:center;">
	<cfoutput>
	<tr>
		<td <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>FOR THE PERIOD ENDING: #Dateformat(form.end_date,'mm/dd/yyyy')#</td>
	</tr>
	<tr>
		<td <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>ZONE NAME:&nbsp;<cfif IsDefined("selBrokerInfo.Zone_Name")>#selBrokerInfo.Zone_Name#<cfelse> N/A</cfif></td>
	</tr>
	
	<tr>
		<td <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>REGION NAME:&nbsp;<cfif IsDefined("selBrokerInfo.Region_Name")>#selBrokerInfo.Region_Name#<cfelse>N/A</cfif></td>
	</tr>
	<tr>
		<td <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>SOLD TO ##:&nbsp;<cfif IsDefined("selBrokerInfo.Ship_to")>#selBrokerInfo.Ship_to#<cfelse> N/A</cfif></td>
	</tr>
	</cfoutput>
	</table>

	<!--- Loop through the distributors --->
	<cfloop query="selBrokerInfo">
	
	<!--- Get the Distributor/Buying Group Info--->
		<cfquery name="selCustomers" datasource="#application.datasource#">
		SELECT dbg.Buying_Group_Name, cfc.Buying_Group_ID, cfc.Ship_to, cfc.Name
			FROM 
				Distributor_Buying_Groups dbg 
					INNER JOIN 
				BSA_Foodservice_Customers cfc
					ON dbg.Buying_Group_ID = cfc.Buying_Group_ID
		WHERE BSA_Foodservice_Customers_ID = '#selBrokerInfo.BSA_Foodservice_Customers_ID#'
		AND cfc.Deleted = 0
		AND cfc.Active_Code='A'
		AND dbg.Deleted = 0
		AND dbg.Active_Code='A'
		</cfquery>
		
	<!--- Start the Summary Report --->	
	<cfoutput>
	<table border="0" class="PageContent" width="100%">
		<tr>
			<td  width="60%" <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>SALESPERSON ## &nbsp;#selBrokerInfo.Market_Number#</td>
			<td width="40%" <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>SALESPERSON  NAME:&nbsp;#selBrokerInfo.Market_Name#</td>
		</tr>
		
		<tr>
			<td width="60%" <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>CUSTOMER ## &nbsp;#selCustomers.Ship_to#</td>
			<td width="40%" <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>CUSTOMER NAME:&nbsp;#selCustomers.Name#</td>
		</tr>
		
		<tr>
			<td width="60%" <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>BROKER ##&nbsp;#selBrokerInfo.Broker_Shard#</td>
			<td width="40%" <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>BROKER NAME:&nbsp;#selBrokerInfo.Broker_Name#</td>
		</tr>
		
		<tr>
			<td  width="60%" <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>BUYING GROUP ##&nbsp;#selCustomers.Buying_Group_ID#</td>
			<td  width="40%" <cfif rReportType eq "e">style="font-size:9px;"<cfelse>style="font-size:11px;"</cfif>>BUYING GROUP NAME:&nbsp;#selCustomers.Buying_Group_Name#</td>
		</tr>
	</table>
	</cfoutput>

<span class="SectionHeaders" style="font-size:14px;width:100%;text-align:center;">SUMMARY SECTION</span>
<table border="0"  style="border:thin groove #000000;"  cellspacing="0" cellpadding="3" align="center">						
							
							<!--- Start Dollars --->
	<tr>
			<td class="SectionHeaders">DOLLARS</td>
		<cfloop from="1" to="#ArrayLen(CurrentYearDatePeriods)#" index="i">
			<td  style="border-right-width:thin; border-right-style:groove; border-right-color:#000000;">&nbsp;</td>
		</cfloop>
	</tr>

	<tr>
	<cfoutput>
		<cfloop from="1" to="#ArrayLen(CurrentYearDatePeriods)#" index="i">

		<cfset CurrentFiscalYear = Year(CurrentYearDatePeriods[i].PeriodStartDate)>

			<cfif i eq 1>
				<td class="PageHeaders"  align="center" style="background: ##FFB062;">#CurrentFiscalYear#</td>
			</cfif>
			<td class="PageHeaders" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000; background: ##FFB062;">

				<cfif i eq 1>
					#DateFormat(CurrentYearDatePeriods[i].StartDate,"MM/DD/YYYY")#<br /> 
				<cfelse>
					#DateFormat(CurrentYearDatePeriods[i].PeriodStartDate,"MM/DD/YYYY")#<br /> 
				</cfif>  
				<cfif i eq ArrayLen(CurrentYearDatePeriods)> 
					#DateFormat(CurrentYearDatePeriods[i].EndDate,"MM/DD/YYYY")#
				<cfelse>
					#DateFormat(CurrentYearDatePeriods[i].PeriodEndDate,"MM/DD/YYYY")#
				</cfif>
	
			</td>
		</cfloop>
	</cfoutput>
	
	<td class="PageHeaders" align="right" style="background:#FFB062;">TOTAL</td>
	</tr>
	
	
	<!--- Initialize 2 dimensional arrays for storing the Dollars and Pounds. The first Dimension is for Dates and the 
		  Second Dimension is for the record number for that Date period --->
	<cfset CurrentYearMTDDollars =ArrayNew(2)>
	<cfset PriorYearMTDDollars =ArrayNew(2)>
	<cfset CurrentYearMTDPounds =ArrayNew(2)>
	<cfset PriorYearMTDPounds =ArrayNew(2)>
	<cfset CurrentYearYTDDollars =ArrayNew(2)>
	<cfset PriorYearYTDDollars  =ArrayNew(2)>
	<cfset CurrentYearYTDPounds =ArrayNew(2)>
	<cfset PriorYearYTDPounds =ArrayNew(2)>

	<!--- Start Current Year Dollars --->
	<tr>
	<td class="PageContent"  align="center">MTD</td>
	
				<!--- Here "InvoiceDetails" is a view --->
		<!--- Get the Sales summary Info (Search Criteria) by looping through the Date Array --->

	<cfloop from="1" to="#ArrayLen(CurrentYearDatePeriods)#" index="i">
	
			<cfquery name="selSummaryMTD" datasource="#application.datasource#">
			SELECT IsNull(sum(Cast(Sales_Dollars as money)),0) As TotalDollars, IsNull(sum(Cast(Pounds_Invoiced as numeric)),0) As TotalPounds
			,Year(Invoice_Date) As ThisYear, Month(Invoice_Date) As ThisMonth
			FROM InvoiceDetails
			WHERE BSA_Foodservice_Customers_ID = '#selBrokerInfo.BSA_Foodservice_Customers_ID#'
			AND Invoice_Date BETWEEN 
				<cfif i eq 1>
					#CreateODBCDate(CurrentYearDatePeriods[i].StartDate)#
				<cfelse>
					#CreateODBCDate(CurrentYearDatePeriods[i].PeriodStartDate)#
				</cfif> 
					AND 
				<cfif i eq ArrayLen(CurrentYearDatePeriods)> 
					#DateAdd('d',1,CreateODBCDate(CurrentYearDatePeriods[i].EndDate))#
				<cfelse>
					#DateAdd('s',-1,DateAdd('d',1,CreateODBCDate(CurrentYearDatePeriods[i].PeriodEndDate)))#
				</cfif>				
			GROUP BY Year(Invoice_Date),  Month(Invoice_Date)	
			ORDER BY Year(Invoice_Date) DESC,  Month(Invoice_Date)
			</cfquery>
	
			<cfquery name="selSummaryYTD" datasource="#application.datasource#">
			SELECT IsNull(sum(Cast(Sales_Dollars as money)),0) As TotalDollars, IsNull(sum(Cast(Pounds_Invoiced as numeric)),0) As TotalPounds
			,Year(Invoice_Date) As ThisYear, Month(Invoice_Date) As ThisMonth
			FROM InvoiceDetails
			WHERE BSA_Foodservice_Customers_ID = '#selBrokerInfo.BSA_Foodservice_Customers_ID#'
			AND Invoice_Date BETWEEN 
				#CreateODBCDate(CurrentFiscalYearStart.Fiscal_Start_Date)#
				AND 
				<cfif i eq ArrayLen(CurrentYearDatePeriods)> 
				#DateAdd('d',1,CreateODBCDate(CurrentYearDatePeriods[i].EndDate))#
				<cfelse>
				#DateAdd('s',-1,DateAdd('d',1,CreateODBCDate(CurrentYearDatePeriods[i].PeriodEndDate)))#
				</cfif>
			GROUP BY Year(Invoice_Date),  Month(Invoice_Date)	
			ORDER BY Year(Invoice_Date) DESC,  Month(Invoice_Date)
			</cfquery>
		
		<!--- Store the MTD Dollar and Pound Info in arrays --->
		<cfloop query="selSummaryMTD">
			<cfset CurrentYearMTDDollars[i][currentrow] = selSummaryMTD.TotalDollars>
			<cfset CurrentYearMTDPounds[i][currentrow] = selSummaryMTD.TotalPounds>
		</cfloop>
		
		<!--- Store the YTD Dollar and Pound Info in arrays --->
		<cfloop query="selSummaryYTD">
			<cfset CurrentYearYTDDollars[i][currentrow] = selSummaryYTD.TotalDollars>
			<cfset CurrentYearYTDPounds[i][currentrow] = selSummaryYTD.TotalPounds>
		</cfloop>

	</cfloop>

	<!--- Initialize the variables to be used below --->
	<cfset TotalMTDDollarsCurrentYear = 0>
	<!---
	<cfset YTDDollarsCurrentYear = 0>
	--->
		
	<!--- "SetNumber"  is a custom function being called. It Puts the Minus sign after the number --->
	<cfoutput>
		<cfloop from="1" to="#Arraylen(CurrentYearDatePeriods)#" index="i">
			<td class="PageContent" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000;">
			#SetNumber(DecimalFormat("#ArraySum(CurrentYearMTDDollars[i])#"))#</td>
			<cfset TotalMTDDollarsCurrentYear = TotalMTDDollarsCurrentYear + ArraySum(CurrentYearMTDDollars[i])>	
		</cfloop>
	
			<td class="PageContent" align="right">#SetNumber(DecimalFormat("#TotalMTDDollarsCurrentYear#"))#</td>
	</cfoutput>
	</tr>

	<tr>
		<td class="PageContent"  align="center">YTD</td>
	<cfoutput>
		<cfloop from="1" to="#Arraylen(CurrentYearDatePeriods)#" index="i">
		<!---
		<cfset YTDDollarsCurrentYear = YTDDollarsCurrentYear + ArraySum(CurrentYearYTDDollars[i])>
		--->
		
			<td class="PageContent" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000;">
			#SetNumber(DecimalFormat("#ArraySum(CurrentYearYTDDollars[i])#"))#</td>
			
		
		<cfif i eq Arraylen(CurrentYearDatePeriods)>
			<td class="PageContent" align="right">#SetNumber(DecimalFormat("#ArraySum(CurrentYearYTDDollars[i])#"))#</td>
		</cfif>
		</cfloop>
		
	</cfoutput>
	</tr>
	
<!--- End Current Year Dollars --->

<!--- Start Prior Year --->

	<tr>
		<cfoutput>
			<cfloop from="1" to="#ArrayLen(CurrentYearDatePeriods)#" index="i">		
				<cfset PriorFiscalYear = Year(DateAdd("YYYY",-1,CurrentYearDatePeriods[i].PeriodStartDate))>

			<cfif i eq 1>
			<td class="PageHeaders"  align="center" style="background: ##FFB062;">#PriorFiscalYear#</td>
			</cfif>
			<td class="PageHeaders" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000; background: ##FFB062;">

				<cfif i eq 1>
					#DateFormat(DateAdd("YYYY",-1,CurrentYearDatePeriods[i].StartDate),"MM/DD/YYYY")#<br /> 
				<cfelse>
					#DateFormat(DateAdd("YYYY",-1,CurrentYearDatePeriods[i].PeriodStartDate),"MM/DD/YYYY")#<br /> 
				</cfif>  
				
				<!--- If it's the last element of the array --->
				<cfif i eq ArrayLen(CurrentYearDatePeriods)> 
				#DateFormat(DateAdd("YYYY",-1,CurrentYearDatePeriods[i].EndDate),"MM/DD/YYYY")#
				<cfelse>
				#DateFormat(DateAdd("YYYY",-1,CurrentYearDatePeriods[i].PeriodEndDate),"MM/DD/YYYY")#
				</cfif>

			</td>
			</cfloop>
		</cfoutput>
		
		<td class="PageHeaders" align="right" style="background:#FFB062;">TOTAL</td>
	</tr>

<!--- Start Prior Year Dollars --->
	<tr>
	<td class="PageContent"  align="center">MTD</td>

<cfloop from="1" to="#ArrayLen(CurrentYearDatePeriods)#" index="i">

		<cfquery name="selSummaryMTD" datasource="#application.datasource#">
		SELECT IsNull(sum(Cast(Sales_Dollars as money)),0) As TotalDollars, IsNull(sum(Cast(Pounds_Invoiced as numeric)),0) As TotalPounds
		,Year(Invoice_Date) As ThisYear, Month(Invoice_Date) As ThisMonth
		FROM InvoiceDetails
		WHERE BSA_Foodservice_Customers_ID = '#selBrokerInfo.BSA_Foodservice_Customers_ID#'
		AND Invoice_Date BETWEEN 

				<!--- If it's the first element of the array --->
				<cfif i eq 1>
				#DateAdd("YYYY",-1,CreateODBCDate(CurrentYearDatePeriods[i].StartDate))#
				<cfelse>
				#DateAdd("YYYY",-1,CreateODBCDate(CurrentYearDatePeriods[i].PeriodStartDate))#
				</cfif> 
				AND 
				<!--- If it's the last element of the array --->
				<cfif i eq ArrayLen(CurrentYearDatePeriods)> 
				#DateAdd('d',1,DateAdd("YYYY",-1,CreateODBCDate(CurrentYearDatePeriods[i].EndDate)))#
				<cfelse>
				#DateAdd('s',-1,DateAdd('d',1,DateAdd("YYYY",-1,CreateODBCDate(CurrentYearDatePeriods[i].PeriodEndDate))))#
				</cfif>
		GROUP BY Year(Invoice_Date),  Month(Invoice_Date)	
		ORDER BY Year(Invoice_Date) DESC,  Month(Invoice_Date)
		</cfquery>
		
		<cfquery name="selSummaryYTD" datasource="#application.datasource#">
		SELECT IsNull(sum(Cast(Sales_Dollars as money)),0) As TotalDollars, IsNull(sum(Cast(Pounds_Invoiced as numeric)),0) As TotalPounds
		,Year(Invoice_Date) As ThisYear, Month(Invoice_Date) As ThisMonth
		FROM InvoiceDetails
		WHERE BSA_Foodservice_Customers_ID = '#selBrokerInfo.BSA_Foodservice_Customers_ID#'
		AND Invoice_Date BETWEEN 
		
				#DateAdd("YYYY",-1,CreateODBCDate(CurrentFiscalYearStart.Fiscal_Start_Date))#
				AND 
				<!--- If it's the last element of the array --->
				<cfif i eq ArrayLen(CurrentYearDatePeriods)> 
				#DateAdd('d',1,DateAdd("YYYY",-1,CreateODBCDate(CurrentYearDatePeriods[i].EndDate)))#
				<cfelse>
				#DateAdd('s',-1,DateAdd('d',1,DateAdd("YYYY",-1,CreateODBCDate(CurrentYearDatePeriods[i].PeriodEndDate))))#
				</cfif>
	
		GROUP BY Year(Invoice_Date),  Month(Invoice_Date)	
		ORDER BY Year(Invoice_Date) DESC,  Month(Invoice_Date)
		</cfquery>

	<cfloop query="selSummaryMTD">
		<cfset PriorYearMTDDollars[i][currentrow] = selSummaryMTD.TotalDollars>
		<cfset PriorYearMTDPounds[i][currentrow] = selSummaryMTD.TotalPounds>
	</cfloop>
	
	<cfloop query="selSummaryYTD">
		<cfset PriorYearYTDDollars[i][currentrow] = selSummaryYTD.TotalDollars>
		<cfset PriorYearYTDPounds[i][currentrow] = selSummaryYTD.TotalPounds>
	</cfloop>
	
</cfloop>



	<cfset TotalMTDDollarsPriorYear = 0>
	<!---
	<cfset YTDDollarsPriorYear = 0>
	--->

		<cfoutput>
			<cfloop from="1" to="#Arraylen(CurrentYearDatePeriods)#" index="i">
					<td class="PageContent" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000;">
					#SetNumber(DecimalFormat("#ArraySum(PriorYearMTDDollars[i])#"))#</td>
					<cfset TotalMTDDollarsPriorYear = TotalMTDDollarsPriorYear + ArraySum(PriorYearMTDDollars[i])>	
			</cfloop>
		<td class="PageContent" align="right">#SetNumber(DecimalFormat("#TotalMTDDollarsPriorYear#"))#</td>
		</cfoutput>
	</tr>


	<tr>
	<td class="PageContent"  align="center">YTD</td>
		<cfoutput>
		<cfloop from="1" to="#Arraylen(CurrentYearDatePeriods)#" index="i">
			<!--- <cfset YTDDollarsPriorYear = YTDDollarsPriorYear + ArraySum(PriorYearYTDDollars[i])> --->
			<td class="PageContent" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000;">
			#SetNumber(DecimalFormat("#ArraySum(PriorYearYTDDollars[i])#"))#</td>
		
		<cfif i eq Arraylen(CurrentYearDatePeriods)>
		<td class="PageContent" align="right">#SetNumber(DecimalFormat("#ArraySum(PriorYearYTDDollars[i])#"))#</td>
		</cfif>
		</cfloop>
		</cfoutput>
	</tr>

<!--- End Prior Year Dollars --->

							<!--- End Dollars --->
							
							<!--- Start Pounds --->

	<tr>
		<td class="SectionHeaders">POUNDS</td>
		<cfloop from="1" to="#ArrayLen(CurrentYearDatePeriods)#" index="i">
		<td  style="border-right-width:thin; border-right-style:groove; border-right-color:#000000;">&nbsp;</td>
		</cfloop>
	</tr>
	
	<tr>
	<cfoutput>
		<cfloop from="1" to="#ArrayLen(CurrentYearDatePeriods)#" index="i">

			<cfset CurrentFiscalYear = Year(CurrentYearDatePeriods[i].PeriodStartDate)>

		<cfif i eq 1>
			<td class="PageHeaders"  align="center" style="background: ##FFB062;">#CurrentFiscalYear#</td>
		</cfif>
			<td class="PageHeaders" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000; background: ##FFB062;">

				<cfif i eq 1>
					#DateFormat(CurrentYearDatePeriods[i].StartDate,"MM/DD/YYYY")#<br /> 
				<cfelse>
					#DateFormat(CurrentYearDatePeriods[i].PeriodStartDate,"MM/DD/YYYY")#<br /> 
				</cfif> 
					
				<cfif i eq ArrayLen(CurrentYearDatePeriods)> 
					#DateFormat(CurrentYearDatePeriods[i].EndDate,"MM/DD/YYYY")#
				<cfelse>
					#DateFormat(CurrentYearDatePeriods[i].PeriodEndDate,"MM/DD/YYYY")#
				</cfif>

		</td>
		</cfloop>
	</cfoutput>
		<td class="PageHeaders" align="right" style="background:#FFB062;">TOTAL</td>
	</tr>


	<cfset TotalMTDPoundsCurrentYear = 0>
	<!---
	<cfset YTDPoundsCurrentYear = 0>
	--->

<!--- Start Current Year Pounds --->

	<tr>
	<td class="PageContent"  align="center">MTD</td>
		
	<cfoutput>
		<cfloop from="1" to="#Arraylen(CurrentYearDatePeriods)#" index="i">
				<td class="PageContent" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000;">
				#SetNumber(NumberFormat("#ArraySum(CurrentYearMTDPounds[i])#"))#</td>
				<cfset TotalMTDPoundsCurrentYear = TotalMTDPoundsCurrentYear + ArraySum(CurrentYearMTDPounds[i])>	
		</cfloop>
	
	<td class="PageContent" align="right">#SetNumber(NumberFormat("#TotalMTDPoundsCurrentYear#"))#</td>
	</cfoutput>
	</tr>
	
	<tr>
		<td class="PageContent"  align="center">YTD</td>
		<cfoutput>
		<cfloop from="1" to="#Arraylen(CurrentYearDatePeriods)#" index="i">
			<td class="PageContent" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000;">
			#SetNumber(NumberFormat("#ArraySum(CurrentYearYTDPounds[i])#"))#</td>
		<cfif i eq Arraylen(CurrentYearDatePeriods)>
		<td class="PageContent" align="right">#SetNumber(NumberFormat("#ArraySum(CurrentYearYTDPounds[i])#"))#</td>
		</cfif>
		</cfloop>
		</cfoutput>
	</tr>
	
<!--- End Current Year Pounds --->	
	
	<tr>
	<cfloop from="1" to="#ArrayLen(CurrentYearDatePeriods)#" index="i">
	<cfoutput>

		<cfset PriorFiscalYear = Year(DateAdd("YYYY",-1,CurrentYearDatePeriods[i].PeriodStartDate))>

	<cfif i eq 1>
		<td class="PageHeaders"  align="center" style="background: ##FFB062;">#PriorFiscalYear#</td>
	</cfif>
		<td class="PageHeaders" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000; background: ##FFB062;">

			<cfif i eq 1>
				#DateFormat(DateAdd("YYYY",-1,CurrentYearDatePeriods[i].StartDate),"MM/DD/YYYY")#<br /> 
			<cfelse>
				#DateFormat(DateAdd("YYYY",-1,CurrentYearDatePeriods[i].PeriodStartDate),"MM/DD/YYYY")#<br /> 
			</cfif> 
			<cfif i eq ArrayLen(CurrentYearDatePeriods)> 
				#DateFormat(DateAdd("YYYY",-1,CurrentYearDatePeriods[i].EndDate),"MM/DD/YYYY")#
			<cfelse>
				#DateFormat(DateAdd("YYYY",-1,CurrentYearDatePeriods[i].PeriodEndDate),"MM/DD/YYYY")#
			</cfif>

		</td>
	</cfoutput>
	</cfloop>
		<td class="PageHeaders" align="right" style="background:#FFB062;">TOTAL</td>
	</tr>


	<cfset TotalMTDPoundsPriorYear = 0>
	<!---
	<cfset YTDPoundsPriorYear = 0>
	--->

<!--- Start Prior Year Pounds --->
	<tr>
	<td class="PageContent"  align="center">MTD</td>
		
	<cfoutput>
		<cfloop from="1" to="#Arraylen(CurrentYearDatePeriods)#" index="i">
				<td class="PageContent" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000;">
				#SetNumber(NumberFormat("#ArraySum(PriorYearMTDPounds[i])#"))#</td>
				<cfset TotalMTDPoundsPriorYear = TotalMTDPoundsPriorYear + ArraySum(PriorYearMTDPounds[i])>	
		</cfloop>
		
		<td class="PageContent" align="right">#SetNumber(NumberFormat("#TotalMTDPoundsPriorYear#"))#</td>
		</cfoutput>
	</tr>

	<tr>
		<td class="PageContent"  align="center">YTD</td>
		<cfoutput>
		<cfloop from="1" to="#Arraylen(CurrentYearDatePeriods)#" index="i">
			<!--- <cfset YTDPoundsPriorYear = YTDPoundsPriorYear + ArraySum(PriorYearYTDPounds[i])> --->
			<td class="PageContent" align="right"  style="border-right-width:thin; border-right-style:groove; border-right-color:##000000;">
			#SetNumber(NumberFormat("#ArraySum(PriorYearYTDPounds[i])#"))#</td>
		<cfif i eq Arraylen(CurrentYearDatePeriods)>
		<td class="PageContent" align="right">#SetNumber(NumberFormat("#ArraySum(PriorYearYTDPounds[i])#"))#</td>
		</cfif>
		</cfloop>
		</cfoutput>
	</tr>

<!--- End Prior Year Pounds --->
</table>

<!--- End Summary Report --->

<!--- Start Detailed Report --->

		<cfquery name="selDistinctItems" datasource="#application.datasource#">
			SELECT DISTINCT Item, Description
			FROM Invoice_Item_Details
			WHERE BSA_Foodservice_Customers_ID = '#selBrokerInfo.BSA_Foodservice_Customers_ID#'
			AND Invoice_Date  
			BETWEEN #CreateODBCDate(DateAdd("YYYY",-1,CurrentFiscalYearStart.Fiscal_Start_Date))#
			AND #DateAdd('d',1,CreateODBCDate(form.Current_Search_Start_Date))#
		</cfquery>

<br /><br />	
<span class="SectionHeaders" style="font-size:14px;width:100%;text-align:center;">DETAIL SECTION</span>

<table border="0" width="100%" cellspacing ="0" cellpadding ="3" style="border:thin groove #000000;" align="center">
	<tr class="PageHeaders">
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="3" class="SectionHeaders">CASES</td>
		<td>&nbsp;</td>
		<td colspan="2">&nbsp;</td>
		<td class="SectionHeaders">POUNDS</td>
		<td colspan="2">&nbsp;</td>
	</tr>
	
	<tr class="PageContent">
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="2">MTD</td>
		<td>&nbsp;</td>
		<td colspan="2">YTD</td>
		<td>&nbsp;</td>
		<td colspan="2">MTD</td>
		<td>&nbsp;</td>
		<td colspan="2">YTD</td>
	</tr>
	
	<tr class="PageHeaders">
		<td class="heading">Item#</td>
		<td class="heading">Item Description</td>
		<td align="right" class="heading"><u>Current</u></td>
		<td align="right" class="heading"><u>PY</u></td>
		<td align="right" class="heading"><u>%Chg</u></td>
		<td align="right" class="heading"><u>Current</u></td>
		<td align="right" class="heading"><u>PY</u></td>
		<td align="right" class="heading"><u>%Chg</u></td>
		<td align="right" class="heading"><u>Current</u></td>
		<td align="right" class="heading"><u>PY</u></td>
		<td align="right" class="heading"><u>%Chg</u></td>
		<td align="right" class="heading"><u>Current</u></td>
		<td align="right" class="heading"><u>PY</u></td>
		<td align="right" class="heading"><u>%Chg</u></td>
	</tr>
		
		<cfset CurrentYearTotalCasesInvoiced = 0>
		<cfset CurrentYearTotalPoundsInvoiced = 0>
		<cfset CurrentMonthTotalCasesInvoiced = 0>
		<cfset CurrentMonthTotalPoundsInvoiced = 0>
		
		<cfset PriorYearTotalCasesInvoiced = 0>
		<cfset PriorYearTotalPoundsInvoiced = 0>
		<cfset PriorMonthTotalCasesInvoiced = 0>
		<cfset PriorMonthTotalPoundsInvoiced = 0>
		
<cfset Customer_ID = selBrokerInfo.BSA_Foodservice_Customers_ID>
	
		<cfoutput query="selDistinctItems">
		<cfquery name="selDetailCurrentMTD" datasource="#application.datasource#">
			SELECT Item, IsNull(SUM(CAST(Cases_Invoiced As numeric)),0)  As CasesInvoiced
			, IsNull(SUM(CAST(Pounds_Invoiced As Numeric)),0)  As PoundsInvoiced, Description
			FROM Invoice_Item_Details
			WHERE BSA_Foodservice_Customers_ID = '#Customer_ID#'
			AND Invoice_Date  BETWEEN 
							#CreateODBCDate(form.Current_Search_Start_Date)#
							AND 		
							#DateAdd('d',1,CreateODBCDate(CurrentYearDatePeriods[ArrayLen(CurrentYearDatePeriods)].EndDate))#
			AND Item = '#selDistinctItems.Item#'
			GROUP BY Item, Description
		</cfquery>
		
		<cfquery name="selDetailPriorMTD" datasource="#application.datasource#">		
			SELECT Item, IsNull(SUM(CAST(Cases_Invoiced As numeric)),0)  As CasesInvoiced
			, IsNull(SUM(CAST(Pounds_Invoiced As Numeric)),0)  As PoundsInvoiced, Description
			FROM Invoice_Item_Details
			WHERE BSA_Foodservice_Customers_ID = '#Customer_ID#'
			AND Invoice_Date  BETWEEN 
							#CreateODBCDate(DateAdd("YYYY",-1,form.Current_Search_Start_Date))#
							AND 		
							#DateAdd('d',1,CreateODBCDate(DateAdd("YYYY",-1,CurrentYearDatePeriods[ArrayLen(CurrentYearDatePeriods)].EndDate)))#
			AND Item = '#selDistinctItems.Item#'
			GROUP BY Item, Description
		</cfquery>
	
		<cfquery name="selDetailCurrentYTD" datasource="#application.datasource#">
			SELECT Item, IsNull(SUM(CAST(Cases_Invoiced As numeric)),0)  As CasesInvoiced
			, IsNull(SUM(CAST(Pounds_Invoiced As Numeric)),0)  As PoundsInvoiced, Description
			FROM Invoice_Item_Details
			WHERE BSA_Foodservice_Customers_ID = '#Customer_ID#'
			AND Invoice_Date  BETWEEN 
							#CreateODBCDate(CurrentFiscalYearStart.Fiscal_Start_Date)#
							AND 		
							#DateAdd('d',1,CreateODBCDate(CurrentYearDatePeriods[ArrayLen(CurrentYearDatePeriods)].EndDate))#
			AND Item = '#selDistinctItems.Item#'
			GROUP BY Item, Description
		</cfquery>
		
		<cfquery name="selDetailPriorYTD" datasource="#application.datasource#">	
			SELECT Item, IsNull(SUM(CAST(Cases_Invoiced As numeric)),0)  As CasesInvoiced
			, IsNull(SUM(CAST(Pounds_Invoiced As Numeric)),0)  As PoundsInvoiced, Description
			FROM Invoice_Item_Details
			WHERE BSA_Foodservice_Customers_ID = '#Customer_ID#'
			AND Invoice_Date  BETWEEN 
							#CreateODBCDate(DateAdd("YYYY",-1,CurrentFiscalYearStart.Fiscal_Start_Date))#
							AND 		
							#DateAdd('d',1,CreateODBCDate(DateAdd("YYYY",-1,CurrentYearDatePeriods[ArrayLen(CurrentYearDatePeriods)].EndDate)))#
			AND Item = '#selDistinctItems.Item#'
			GROUP BY Item, Description
		</cfquery>
		
	<cfset CurrentMonthTotalCasesInvoiced = CurrentMonthTotalCasesInvoiced + val(selDetailCurrentMTD.CasesInvoiced)>
	<cfset PriorMonthTotalCasesInvoiced =	PriorMonthTotalCasesInvoiced + val(selDetailPriorMTD.CasesInvoiced)>
	<cfset CurrentYearTotalCasesInvoiced = CurrentYearTotalCasesInvoiced +  val(selDetailCurrentYTD.CasesInvoiced)>
	<cfset PriorYearTotalCasesInvoiced = PriorYearTotalCasesInvoiced +  val(selDetailPriorYTD.CasesInvoiced)>
	
	<cfset CurrentMonthTotalPoundsInvoiced = CurrentMonthTotalPoundsInvoiced +  val(selDetailCurrentMTD.PoundsInvoiced)>
	<cfset PriorMonthTotalPoundsInvoiced =	PriorMonthTotalPoundsInvoiced +  val(selDetailPriorMTD.PoundsInvoiced)>
	<cfset CurrentYearTotalPoundsInvoiced = CurrentYearTotalPoundsInvoiced +  val(selDetailCurrentYTD.PoundsInvoiced)>
	<cfset PriorYearTotalPoundsInvoiced = PriorYearTotalPoundsInvoiced +  val(selDetailPriorYTD.PoundsInvoiced)>
	
	<cfif CurrentMonthTotalCasesInvoiced neq 0  OR PriorMonthTotalCasesInvoiced  neq 0 OR CurrentYearTotalCasesInvoiced neq 0
		OR PriorYearTotalCasesInvoiced neq 0 OR CurrentMonthTotalPoundsInvoiced neq 0 OR PriorMonthTotalPoundsInvoiced neq 0
		OR CurrentYearTotalPoundsInvoiced neq 0 OR PriorYearTotalPoundsInvoiced neq 0>
		<tr onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">	
		<td align="left" CLASS="UNDERLINED">#selDistinctItems.Item#</td>
		<td align="left" CLASS="UNDERLINED">#selDistinctItems.Description#</td>
		<td align="right" CLASS="UNDERLINED">#SetNumber(NumberFormat(val(selDetailCurrentMTD.CasesInvoiced)))#</td>
		<td align="right" CLASS="UNDERLINED">#SetNumber(NumberFormat(val(selDetailPriorMTD.CasesInvoiced)))#</td>
		
		<td align="right" CLASS="UNDERLINED">
		<cfif val(selDetailPriorMTD.CasesInvoiced) neq 0 AND val(selDetailCurrentMTD.CasesInvoiced) neq 0>#SetNumber(NumberFormat(((val(selDetailCurrentMTD.CasesInvoiced)  - val(selDetailPriorMTD.CasesInvoiced)) / val(selDetailPriorMTD.CasesInvoiced)) * 100,'_.__'))#
		<cfelse>
		<cfif val(selDetailPriorMTD.CasesInvoiced) eq 0 AND val(selDetailCurrentMTD.CasesInvoiced) eq 0>0.00
				<cfelse>
					<cfif val(selDetailCurrentMTD.CasesInvoiced) - val(selDetailPriorMTD.CasesInvoiced) LT 0>100.00-
					<cfelse>
					100.00
					</cfif>
				</cfif>
			 </cfif>
		</td>
	
		<td align="right" CLASS="UNDERLINED">#SetNumber(NumberFormat(val(selDetailCurrentYTD.CasesInvoiced)))#</td>
		<td align="right" CLASS="UNDERLINED">#SetNumber(NumberFormat(val(selDetailPriorYTD.CasesInvoiced)))#</td>
		
		<td align="right" CLASS="UNDERLINED">
		<!---
		<cfif val(selDetailPriorYTD.CasesInvoiced) neq 0>#SetNumber(NumberFormat(((val(selDetailCurrentYTD.CasesInvoiced) - val(selDetailPriorYTD.CasesInvoiced)) / val(selDetailPriorYTD.CasesInvoiced)) * 100,'_.__'))#
		<cfelse>100.00</cfif>
		--->
		<cfif val(selDetailPriorYTD.CasesInvoiced) neq 0 AND val(selDetailCurrentYTD.CasesInvoiced) neq 0>#SetNumber(NumberFormat(((val(selDetailCurrentYTD.CasesInvoiced)  - val(selDetailPriorYTD.CasesInvoiced)) / val(selDetailPriorYTD.CasesInvoiced)) * 100,'_.__'))#
		<cfelse>
		<cfif val(selDetailPriorYTD.CasesInvoiced) eq 0 AND val(selDetailCurrentYTD.CasesInvoiced) eq 0>0.00
				<cfelse>
					<cfif val(selDetailCurrentYTD.CasesInvoiced) - val(selDetailPriorYTD.CasesInvoiced) LT 0>100.00-
					<cfelse>
					100.00
					</cfif>
				</cfif>
		</cfif>
		
		</td>
		
		<td align="right" CLASS="UNDERLINED">#SetNumber(NumberFormat(val(selDetailCurrentMTD.PoundsInvoiced)))#</td>
		<td align="right" CLASS="UNDERLINED">#SetNumber(NumberFormat(val(selDetailPriorMTD.PoundsInvoiced)))#</td>
		<td align="right" CLASS="UNDERLINED">
		<!---
		<cfif val(selDetailPriorMTD.PoundsInvoiced) neq 0>
		#SetNumber(NumberFormat(((val(selDetailCurrentMTD.PoundsInvoiced) - val(selDetailPriorMTD.PoundsInvoiced))/ val(selDetailPriorMTD.PoundsInvoiced)) * 100,'_.__'))#
		<cfelse>100.00</cfif>
		--->
		<cfif val(selDetailPriorMTD.PoundsInvoiced) neq 0 AND val(selDetailCurrentMTD.PoundsInvoiced) neq 0>#SetNumber(NumberFormat(((val(selDetailCurrentMTD.PoundsInvoiced)  - val(selDetailPriorMTD.PoundsInvoiced)) / val(selDetailPriorMTD.PoundsInvoiced)) * 100,'_.__'))#
		<cfelse>
		<cfif val(selDetailPriorMTD.PoundsInvoiced) eq 0 AND val(selDetailCurrentMTD.PoundsInvoiced) eq 0>0.00
				<cfelse>
					<cfif val(selDetailCurrentMTD.PoundsInvoiced) - val(selDetailPriorMTD.PoundsInvoiced) LT 0>100.00-
					<cfelse>
					100.00
					</cfif>
				</cfif>
			</cfif>
		</td>
		<td align="right" CLASS="UNDERLINED">#SetNumber(NumberFormat(val(selDetailCurrentYTD.PoundsInvoiced)))#</td>
		<td align="right" CLASS="UNDERLINED">#SetNumber(NumberFormat(val(selDetailPriorYTD.PoundsInvoiced)))#</td>
		<td align="right" CLASS="UNDERLINED">
		<!---
		<cfif val(selDetailPriorYTD.PoundsInvoiced) neq 0>#SetNumber(NumberFormat(((val(selDetailCurrentYTD.PoundsInvoiced)  - val(selDetailPriorYTD.PoundsInvoiced))/ val(selDetailPriorYTD.PoundsInvoiced)) * 100,'_.__'))#
		<cfelse>100.00</cfif>
		--->
		<cfif val(selDetailPriorYTD.PoundsInvoiced) neq 0 AND val(selDetailCurrentYTD.PoundsInvoiced) neq 0>#SetNumber(NumberFormat(((val(selDetailCurrentYTD.PoundsInvoiced)  - val(selDetailPriorYTD.PoundsInvoiced)) / val(selDetailPriorYTD.PoundsInvoiced)) * 100,'_.__'))#
		<cfelse>
		<cfif val(selDetailPriorYTD.PoundsInvoiced) eq 0 AND val(selDetailCurrentYTD.PoundsInvoiced) eq 0>0.00
				<cfelse>
					<cfif val(selDetailCurrentYTD.PoundsInvoiced) - val(selDetailPriorYTD.PoundsInvoiced) LT 0>100.00-
					<cfelse>
					100.00
					</cfif>
				</cfif>
		</cfif>
		</td>
		</cfif>
	</cfoutput>
	<cfoutput>
	<cfif CurrentMonthTotalCasesInvoiced neq 0  OR PriorMonthTotalCasesInvoiced  neq 0 OR CurrentYearTotalCasesInvoiced neq 0
		OR PriorYearTotalCasesInvoiced neq 0 OR CurrentMonthTotalPoundsInvoiced neq 0 OR PriorMonthTotalPoundsInvoiced neq 0
		OR CurrentYearTotalPoundsInvoiced neq 0 OR PriorYearTotalPoundsInvoiced neq 0>
		<tr class="PageContent" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:11px;">
		<td  colspan="2">CUSTOMER TOTAL</td>
		<td align="right">#SetNumber(NumberFormat(val(CurrentMonthTotalCasesInvoiced)))#</td>
		<td align="right">#SetNumber(NumberFormat(val(PriorMonthTotalCasesInvoiced)))#</td>
		
		<td align="right">
			<cfif val(PriorMonthTotalCasesInvoiced) neq 0 AND val(CurrentMonthTotalCasesInvoiced) neq 0>#SetNumber(NumberFormat(((val(CurrentMonthTotalCasesInvoiced) - val(PriorMonthTotalCasesInvoiced)) / val(PriorMonthTotalCasesInvoiced))* 100, '_.__'))#
			<cfelse>
				<cfif val(PriorMonthTotalCasesInvoiced) eq 0 AND val(CurrentMonthTotalCasesInvoiced) eq 0>0.00
				<cfelse>
					<cfif (CurrentMonthTotalCasesInvoiced - PriorMonthTotalCasesInvoiced) LT 0>100.00-
					<cfelse>
					100.00
					</cfif>
				</cfif>
			 </cfif>
		</td>
		
		<td align="right">#SetNumber(NumberFormat(val(CurrentYearTotalCasesInvoiced)))#</td>
		<td align="right">#SetNumber(NumberFormat(val(PriorYearTotalCasesInvoiced)))#</td>
		
		<td align="right">
			<cfif val(PriorYearTotalCasesInvoiced) neq 0 AND val(CurrentYearTotalCasesInvoiced) neq 0>#SetNumber(NumberFormat(((val(CurrentYearTotalCasesInvoiced) - val(PriorYearTotalCasesInvoiced)) / val(PriorYearTotalCasesInvoiced))* 100, '_.__'))#
			<cfelse>
				<cfif val(PriorYearTotalCasesInvoiced) eq 0 AND val(CurrentYearTotalCasesInvoiced) eq 0>0.00
				<cfelse>
					<cfif (CurrentYearTotalCasesInvoiced - PriorYearTotalCasesInvoiced) LT 0>100.00-
					<cfelse>
					100.00
					</cfif>
				</cfif>
			 </cfif>
		</td>
		
		<td align="right">#SetNumber(NumberFormat(val(CurrentMonthTotalPoundsInvoiced)))#</td>
		<td align="right">#SetNumber(NumberFormat(val(PriorMonthTotalPoundsInvoiced)))#</td>
		
		
		<td align="right">
			<cfif val(PriorMonthTotalPoundsInvoiced) neq 0 AND val(CurrentMonthTotalPoundsInvoiced) neq 0>#SetNumber(NumberFormat(((val(CurrentMonthTotalPoundsInvoiced) - val(PriorMonthTotalPoundsInvoiced)) / val(PriorMonthTotalPoundsInvoiced))* 100, '_.__'))#
			<cfelse>
				<cfif val(PriorMonthTotalPoundsInvoiced) eq 0 AND val(CurrentMonthTotalPoundsInvoiced) eq 0>0.00
				<cfelse>
					<cfif (CurrentMonthTotalPoundsInvoiced - PriorMonthTotalPoundsInvoiced) LT 0>100.00-
					<cfelse>
					100.00
					</cfif>
				</cfif>
			 </cfif>
		</td>
		
		
		<td align="right">#SetNumber(NumberFormat(val(CurrentYearTotalPoundsInvoiced)))#</td>
		<td align="right">#SetNumber(NumberFormat(val(PriorYearTotalPoundsInvoiced)))#</td>
		
		<td align="right">
			<cfif val(PriorYearTotalPoundsInvoiced) neq 0 AND val(CurrentYearTotalPoundsInvoiced) neq 0>#SetNumber(NumberFormat(((val(CurrentYearTotalPoundsInvoiced) - val(PriorYearTotalPoundsInvoiced)) / val(PriorYearTotalPoundsInvoiced))* 100, '_.__'))#
			<cfelse>
				<cfif val(PriorYearTotalPoundsInvoiced) eq 0 AND val(CurrentYearTotalPoundsInvoiced) eq 0>0.00
				<cfelse>
					<cfif (CurrentYearTotalPoundsInvoiced - PriorYearTotalPoundsInvoiced) LT 0>100.00-
					<cfelse>
					100.00
					</cfif>
				</cfif>
			 </cfif>
		</td>
		</tr>
	</cfif>
	</cfoutput>
</table>
<p>
<hr noshade color="brown">
</p>
<!--- End Detailed Report --->
<cfflush>
</cfloop>
<!---
</cfsavecontent>
--->

<CFSET Unique_ID = createUUID()>
<CFSET File_Name = "#Replace(Unique_ID,"-","_","all")#.html">

<!---
<CFFILE ACTION	=	"WRITE"
		FILE	=  	"#APPLICATIONPATH#\Temp_Files\VolumeReportByMonth\#File_Name#"
		OUTPUT	=	"#VarVolumeReport#">
--->

<!---
<cfif rReportType NEQ "e">
	
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="100%">
			<TR>								
				<TD STYLE="Border-bottom: none" ALIGN="Right">									
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: openNewWindow(1,'<cfoutput>#File_Name#</cfoutput>')"><FONT SIZE="2">email</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: openNewWindow(2,'<cfoutput>#File_Name#</cfoutput>')"><FONT SIZE="2">fax</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: openNewWindow(3,'<cfoutput>#File_Name#</cfoutput>')"><FONT SIZE="2">print</FONT></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
				</TD>				
			</TR>
		</TABLE>
</cfif>
--->
	<!---
		<script language ="javascript">
			alert("All the search criteria records have been retrieved");
		</script>
	--->
<!---
	<CFOUTPUT>#VarVolumeReport#</CFOUTPUT>
--->
<cfelse>
	<p align="center" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:10px; color:#FF0000;">
	There are no records for your search criteria
	</p>
</cfif>
	

</body>
</cfif>


</html>
