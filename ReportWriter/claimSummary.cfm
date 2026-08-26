<!--- 		border-right:inset #cccccc 1px; --->
<title>Blacksmith Applications Claim Summary Report</title>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>

<cfparam name="headerHeight" default="25">
<html>
<head>
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV">
		<cfsetting enablecfoutputonly="yes" showdebugoutput="no">
		<cfcontent type="application/msexcel">
 		<cfheader name="Content-Disposition" value="attachment;filename=claimSummaryReport.csv">
		<cfset newLine = Chr(13) & Chr(10)> 
	<cfelse>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	</cfif>
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
		<style>
			TR.claimSummaryHeader TD 
			{
				font-family:Arial Narrow, helvetica; 
				background-color:gray;
				color: white;
				font-size:9pt;
				font-weight:bold;
				height:<cfoutput>#headerHeight#</cfoutput>
			}
			TR.claimSummaryDisplayTitle TD, .claimSummaryDisplayTitle
			{
				font-family:Arial Narrow, helvetica; 
				background-color:gray;
				color: white;
				font-size:9pt;
				font-weight:bold;
				height:<cfoutput>#headerHeight#</cfoutput>
			}
			TR.claimLegend TD
			{
				font-family:Arial Narrow, helvetica; 
				background-color:gray;
				color: white;
				font-size:8pt;
			}
			TR.GridMOverRow TD
			{
				font-family:Arial Narrow, helvetica; 
				font-size:8pt;
				color: 003063;
				background-color: cfdce8;
				cursor:pointer;
			}
			TR.GridRow TD
			{
				font-family:Arial Narrow, helvetica; 
				font-size:8pt;	
				color: 003063;
				background-color: ffffff;
				cursor:none;
			}
			TR.claimSummaryData TD  
			{
				font-family:Arial Narrow, helvetica; 
				background-color:ffffff;
				color: black;
				font-size: 8pt;
				border-right:1px solid Gray;
			}
			
			TD.claimSummaryDataWithWhiteASBG 
			{
				font-family:Arial Narrow, helvetica; 
				background-color:f5f5f5;
				color: black;
				font-size:8pt;
			}
			TR.claimGroupHeader TD
			{
				font-family:Arial Narrow, helvetica; 
				background-color:ffe4b5;
				color: black;
				font-size:8pt;
				font-weight:bold;
			}
			TR.claimSumHeader TD
			{
				font-family:Arial Narrow, helvetica; 
				background-color:d3d3d3;
				color: navy;
				font-size:8pt;
				font-weight:bold;
			}
			TR.claimSumSecondaryHeader TD
			{
				font-family:Arial Narrow, helvetica; 
				background-color:lightskyblue;
				color: gray;
				font-size:8pt;
				font-weight:bold;
			}
			.page {overflow:scroll;}
		</style> 
	</cfif>
</head>
<!--- the program has been set from claimDetail --->
<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
	<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
		<br><br><br>
		<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		<br><br><br>
		<cfflush>
	</SPAN>
</cfif>

<body topmargin="0" leftmargin="1" bottommargin="0" rightmargin="1">
<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
	<SCRIPT LANGUAGE="JavaScript">
		document.all.PleaseWaitMessage.style.display='none';
	</SCRIPT>
</cfif>

<cfsilent>
<CFSET cmpHandle = CreateObject("component", "components.reports.claimReport") />
<CFSET claimSummaryHandle = CreateObject("component", "components.Billback.BillbackManager")>
<cfset claimSummaryHandle.init() />

<CFSET GP_Supplied_Position = claimSummaryHandle.getUserPosition(request.AccessStructure.user_id) >
</cfsilent>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
<CFINCLUDE TEMPLATE="\billbacks\scorecard\deduction_age.cfm">

<cfsilent>
<cfif Not isDefined("Aging_Days") or Aging_Days eq "">
	<cfset Aging_Days = 0 >
</cfif>

<!---

Instead of calling the .cfc and getting back a list of billbacks, I'm executing the same query and inserting it into a temp table. Currently, when there are a lot of billbacks the list gets too big and the whole thing times out and throws a SQL error. Temp table should be dropped at the end of this.

BJF: D8930
--->

<cfset FriendlyUID = replace(request.AccessStructure.user_id, '-', '_', "all")>
<cfset FriendlyTime = dateformat(now(), 'mm_ss')>
<cfset UniqueUserTime = FriendlyUID &  "_" & FriendlyTime>
<Cfdump var="#UniqueUserTime#">


<cfset accessibleBBIds = claimSummaryHandle.getAccessibleBillbackIDs(request.AccessStructure.user_id, GP_Position_List_From_My_Position_Down,UniqueUserTime) >

<cfquery name="BBIDRecordcount" datasource="#application.datasource#">
SELECT * FROM #accessibleBBIds#
</cfquery>

<cfset BBIDRecordcounts = BBIDRecordcount.Recordcount>		

<cfset getClaimSummary = claimSummaryHandle.getThisClaimSummary(trim(url.reportType), Aging_Days, GP_Supplied_Position, accessibleBBIds, BBIDRecordcounts,UniqueUserTime) >
<cfset getFilteredClaimSummary = claimSummaryHandle.getThisFilteredClaimSummary(getClaimSummary, form,UniqueUserTime) />
<cfset cmpHandle.setReportHeader(trim(url.reportType)) />
<cfset cmpHandle.setReportSSPage(trim(url.reportType)) />
<cfset cmpHandle.setReportFields(trim(url.reportType)) />
<cfset cmpHandle.setReportGroupByFields(trim(url.reportType)) />
<cfset cmpHandle.setReportSumFields(trim(url.reportType)) />
<cfset cmpHandle.setReportUOMFields(trim(url.reportType)) />
<cfset cmpHandle.setReportDisplayTitles(trim(url.reportType)) />

<!--- retrieve the group by list of the selected report ----->
<cfset thisReportGroupByList = cmpHandle.getReportGroupByFields()/>
<cfset thisReportSumList = cmpHandle.getReportSumFields()/>
<cfset thisReportUOMFieldList = cmpHandle.getReportUOMFields()/>

<cfset isTotalCounted = 0>
<cfif ListGetAt(thisReportSumList,1) NEQ 0>
	<cfset isTotalCounted = 1>
</cfif>

<cfif isTotalCounted EQ 1>
<!--- need to change for generic use --->
	<cfset claimSummaryHandle.setThisClaimTotal(trim(url.reportType)) />
</cfif>
</cfsilent>
<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
<!--- 	<link media="print" href="/reportWriter/<cfoutput>#trim(cmpHandle.getReportSSPage())#</cfoutput>.css" rel="stylesheet">
 --->	<link media="print" href="/reportWriter/claimsummary.css" rel="stylesheet">
</cfif> 
<div id="stuff" class="page" number="2" style="top:1in;left:1in;width:100%;height:8.5in;" >
	<table cellpadding="1" cellspacing="1" border="0"  CLASS="Maintable" >
		<!--- retrieve header of the claim Summary report --->
		<caption align="center" class="claimSummaryDisplayTitle">
			<cfoutput>#cmpHandle.getClaimDisplayTitle()#</cfoutput>
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>, , , , , , , , , , , , , , ,</cfoutput></cfif>
			<div align="right" ><cfoutput>WSID TCO870</cfoutput></div>
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>#newLine#</cfoutput></cfif>
		</caption>
		<!--- legend information --->
		<cfif cmpHandle.IsClaimLegendRequired(trim(url.reportType)) EQ true and isDefined("form.reportType") and Ucase(trim(form.reportType)) eq 'HTML' >
			<tr class="claimLegend">
				<td nowrap colspan="<cfoutput>#ListLen(cmpHandle.getReportHeader())#</cfoutput>" align="left">
					<cfoutput>#cmpHandle.getLegendInfo(trim(url.reportType))#</cfoutput>
				</td>
			</tr>
		</cfif>
		<div id="header" class="header">
			<thead>
				<tr class="claimSummaryHeader" style="POSITION:relative; TOP:expression(document.getElementById('stuff').scrollTop);">		
					<cfloop list="#cmpHandle.getReportHeader()#" index="thisHeader">
						<td align="left" nowrap><cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV"><cfoutput>#thisHeader#</cfoutput><cfelse><cfoutput>#replace(thisHeader, '<BR>', ' ', 'ALL')#</cfoutput></cfif></td>
						<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
					</cfloop>
				</tr> 
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>#newLine#</cfoutput></cfif>
			</thead>
		</div>
		<!--- data section --->
		<cfsilent>
		<cfparam name="rowCount" default="1">
		<cfparam name="columnCount" default="1">
		<cfparam name="secondLevelRowCount" default="1">
		<cfset preGroupByFieldV = "" >
		<cfset preSumFieldV = "" >
		<cfset preSecondLevelFV = "" >
		
		<cfset grandPaidCSTotal = 0 >
		<cfset grandPaidAmountTotal = 0 >
		<cfset grandClaimCSTotal = 0 >
		<cfset grandClaimAmountTotal = 0>
		<!--- cost saving --->
		<cfset grandClaimVariationDollars = 0 >
		<cfset grandClaimVariationCS = 0 >
		<!--- participation --->
		<cfset grandFieldExecutionCases = 0 >
		<cfset grandFieldExecutionDollars = 0 >
		<cfset grandBidRequestCases = 0 >
		<cfset grandBidRequestDollars = 0 >
		<cfset grandOperatorDirectOrHqProgramsCases = 0 >
		<cfset grandOperatorDirectOrHqProgramsDollars = 0 >
		<cfset grandOperatorDeviatedPricingCases = 0 >
		<cfset grandOperatorDeviatedPricingDollars = 0 >
		<cfset grandDistributorTradeShelterCases = 0 >
		<cfset grandDistributorTradeShelterDollars = 0 >
		<cfset grandTotalCases = 0 >
		<cfset grandTotalDollars = 0 >
		<!--- D41234 :: Prod Event 4533
		        function name Property has same name which casued event error, modified function name.
		--->
		<cfset CountProcessedClaims = cmpHandle.iCountProcessedClaims(trim(url.reportType)) />
		</cfsilent>
		<cfloop query="getFilteredClaimSummary">
			<cfif (cmpHandle.IsSecondLevelCounted() EQ true) and secondLevelRowCount GT 1 and (secondLevelRowCount EQ claimSummaryHandle.getClaimSecondLevelCount(trim(preSumFieldV),trim(preSecondLevelFV)) + 1)>
				<cfset secondLevelRowCount = 1 >
				<cfinclude template="/reportWriter/claimReportSecondarySum.cfm">
			</cfif> 
			<!---- section for summary total ---->
			<cfif isTotalCounted EQ 1 and (rowCount GT 1 and trim(Evaluate(ListGetAt(cmpHandle.getReportFields(),ListGetAt(cmpHandle.getReportSumFields(),1)))) NEQ preSumFieldV)>
				<cfset secondLevelRowCount = 1 >
				<cfinclude template="/reportWriter/claimReportFirstLevelSum.cfm">
				
				<Cfsilent>
				<cfset grandPaidCSTotal = grandPaidCSTotal + claimSummaryHandle.getProgramTotalPaidCS(preSumFieldV)  >
				<cfset grandPaidAmountTotal = grandPaidAmountTotal + claimSummaryHandle.getProgramTotalPaidAmount(preSumFieldV) >
				<cfset grandClaimCSTotal = grandClaimCSTotal + claimSummaryHandle.getProgramTotalClaimCS(preSumFieldV)  >
				<cfset grandClaimAmountTotal = grandClaimAmountTotal + claimSummaryHandle.getProgramTotalClaimAmount(preSumFieldV) >
				<!--- cost saving ---->
				<cfif claimSummaryHandle.getClaimVariation$(preSumFieldV) NEQ "">
					<cfset grandClaimVariationDollars = grandClaimVariationDollars + claimSummaryHandle.getClaimVariation$(preSumFieldV) >
				</cfif>
				<cfif claimSummaryHandle.getClaimVariation$(preSumFieldV) NEQ "">
					<cfset grandClaimVariationCS = grandClaimVariationCS + claimSummaryHandle.getClaimVariationCS(preSumFieldV) >
				</cfif>
				<!--- participation ---->
				<cfif claimSummaryHandle.getClaimFieldExecutionCases(preSumFieldV) NEQ "">
					<cfset grandFieldExecutionCases = grandFieldExecutionCases + claimSummaryHandle.getClaimFieldExecutionCases(preSumFieldV) >
				</cfif>
				<cfif claimSummaryHandle.getClaimFieldExecutionDollars(preSumFieldV) NEQ "">
					<cfset grandFieldExecutionDollars = grandFieldExecutionDollars + claimSummaryHandle.getClaimFieldExecutionDollars(preSumFieldV)>
				</cfif>
				<cfif claimSummaryHandle.getClaimBidRequestCases(preSumFieldV) NEQ "">
					<cfset grandBidRequestCases = grandBidRequestCases + claimSummaryHandle.getClaimBidRequestCases(preSumFieldV) >
				</cfif>
				<cfif claimSummaryHandle.getClaimBidRequestDollars(preSumFieldV) NEQ "">
					<cfset grandBidRequestDollars = grandBidRequestDollars +  claimSummaryHandle.getClaimBidRequestDollars(preSumFieldV)>
				</cfif>
				<cfif claimSummaryHandle.getClaimOperatorDirectOrHqProgramsDollars(preSumFieldV) NEQ "">
					<cfset grandOperatorDirectOrHqProgramsDollars = grandOperatorDirectOrHqProgramsDollars + claimSummaryHandle.getClaimOperatorDirectOrHqProgramsDollars(preSumFieldV)>
				</cfif>
				<cfif claimSummaryHandle.getClaimOperatorDirectOrHqProgramsCases(preSumFieldV) NEQ "">
					<cfset grandOperatorDirectOrHqProgramsCases = grandOperatorDirectOrHqProgramsCases + claimSummaryHandle.getClaimOperatorDirectOrHqProgramsCases(preSumFieldV)>
				</cfif>
				<cfif claimSummaryHandle.getClaimOperatorDeviatedPricingCases(preSumFieldV) NEQ "">
					<cfset grandOperatorDeviatedPricingCases = grandOperatorDeviatedPricingCases + claimSummaryHandle.getClaimOperatorDeviatedPricingCases(preSumFieldV)>
				</cfif>
				<cfif claimSummaryHandle.getClaimOperatorDeviatedPricingDollars(preSumFieldV) NEQ "">
					<cfset grandOperatorDeviatedPricingDollars = grandOperatorDeviatedPricingDollars + claimSummaryHandle.getClaimOperatorDeviatedPricingDollars(preSumFieldV)>
				</cfif>
				<cfif claimSummaryHandle.getClaimDistributorTradeShelterCases(preSumFieldV) NEQ "">
					<cfset grandDistributorTradeShelterCases = grandDistributorTradeShelterCases + claimSummaryHandle.getClaimDistributorTradeShelterCases(preSumFieldV)>
				</cfif>
				<cfif claimSummaryHandle.getClaimDistributorTradeShelterDollars(preSumFieldV) NEQ "">
					<cfset grandDistributorTradeShelterDollars = grandDistributorTradeShelterDollars + claimSummaryHandle.getClaimDistributorTradeShelterDollars(preSumFieldV)>
				</cfif>
				<cfif claimSummaryHandle.getClaimTotalCases(preSumFieldV) NEQ "">
					<cfset grandTotalCases = grandTotalCases + claimSummaryHandle.getClaimTotalCases(preSumFieldV)>
				</cfif>
				<cfif claimSummaryHandle.getClaimTotalDollars(preSumFieldV) NEQ "">
					<cfset grandTotalDollars = grandTotalDollars + claimSummaryHandle.getClaimTotalDollars(preSumFieldV)>

				</cfif></CFSILENT>
			</cfif>
			<!----add a new row with identified by group by fields--->
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
			<cfif (rowCount EQ 1) or (trim(Evaluate(ListGetAt(cmpHandle.getReportFields(),ListGetAt(cmpHandle.getReportGroupByFields(),1)))) NEQ trim(preGroupByFieldV))>
				<tr class="claimGroupHeader">
					<cfloop list="#thisReportGroupByList#" index="thisGroupField">
						<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
							<td nowrap colspan="<cfoutput>#ListLen(cmpHandle.getReportHeader())#</cfoutput>">
						</cfif>
							<cfoutput>#Evaluate(ListGetAt(cmpHandle.getReportFields(),thisGroupField))#</cfoutput>
							</td>
						<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
					</cfloop>
				</tr>
			</cfif>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>#newLine#</cfoutput></cfif>
			</cfif>
			<cfsilent>
			<!--- for second level ---->
			<cfif cmpHandle.IsSecondLevelCounted() EQ true and trim(Evaluate(ListGetAt(cmpHandle.getReportSumFields(),2))) NEQ preSecondLevelFV>
				<cfset preSecondLevelFV = trim(Evaluate(ListGetAt(cmpHandle.getReportFields(),ListGetAt(cmpHandle.getReportSumFields(),2))))>
				<!---<cfset secondLevelRowCount = 0 >--->
			</cfif>
			<cfif trim(Evaluate(ListGetAt(cmpHandle.getReportFields(),ListGetAt(cmpHandle.getReportGroupByFields(),1)))) NEQ preGroupByFieldV>
				<cfset preGroupByFieldV = trim(Evaluate(ListGetAt(cmpHandle.getReportFields(),ListGetAt(cmpHandle.getReportGroupByFields(),1))))>
			</cfif>
			<cfif trim(Evaluate(ListGetAt(cmpHandle.getReportFields(),ListGetAt(cmpHandle.getReportSumFields(),1)))) NEQ preSumFieldV>
				<cfset preSumFieldV = trim(Evaluate(ListGetAt(cmpHandle.getReportFields(),ListGetAt(cmpHandle.getReportSumFields(),1))))>
			</cfif>
			<cfif isDefined("Billback_ID") >
				<cfset trID = Billback_ID >
			<cfelse>
				<cfset trID = 'unknown' >
			</cfif>
			<cfif isDefined("end_user") and Lcase(trim(end_user)) NEQ "unknown">
				<cfset trEndUser = end_user >
			<cfelse>
				<cfset trEndUser = "unknown" >
			</cfif>
			</cfsilent>
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<tr id="<cfoutput>#trim(trID)#</cfoutput>" class="claimSummaryData" onmouseover="this.className='GridMOverRow'"
					onmouseout="this.className='claimSummaryData'" <cfif trID NEQ 'unknown'>onClick="javascript:this.className='GridMOverRow';NewWindow('/reportWriter/claimDetail.cfm?billback_id='+this.id+'&end_user=<cfoutput>#trEndUser#</cfoutput>', 'reportInvoiceDetailoutput1', '800','550','Yes', 'Yes');return false;"</cfif>>
			</cfif>
				<cfloop list="#cmpHandle.getReportFields()#" index="thisField">
					<td nowrap>
					<!---<td title="#Evaluate(thisField)#" nowrap> --->
						<cfset maxTitleLength = 15 >
						<cfif thisField EQ "ClaimCS" or thisField EQ "PaidCS" or thisField EQ "Field_Execution_Cases" or thisField EQ "Bid_Request_Cases" or thisField EQ "Operator_Direct_or_HQ_Programs_Cases" or thisField EQ "Operator_Deviated_Pricing_Cases" or thisField EQ "Distributor_Trade_Shelter_Cases" or thisField EQ "total_cases" or thisField EQ "VariationCS">
							<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
								<cfoutput>#NumberFormat(round(Evaluate(thisField)), "_,___,___")#</cfoutput>
							<cfelse>
								<cfoutput>#NumberFormat(round(Evaluate(thisField)), "_______")#</cfoutput>
							</cfif>
						<cfelseif thisField EQ "Claim_Amount" or thisField EQ "Paid_Amount" or thisField EQ "Field_Execution_Dollars" or thisField EQ "Bid_Request_Dollars" or thisField EQ "Operator_Direct_or_HQ_Programs_Dollars" or thisField EQ "Operator_Deviated_Pricing_Dollars" or thisField EQ "Distributor_Trade_Shelter_Dollars" or thisField EQ "total_Dollars" or thisField EQ "Variation$">
							<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
								<cfoutput>#NumberFormat(Evaluate(thisField), "$_,___,___.__")#</cfoutput>
							<cfelse>
								<cfoutput>#NumberFormat(Evaluate(thisField), "$_______.__")#</cfoutput>
							</cfif>
						<cfelseif thisField EQ "BB_Date" or thisField EQ "BB_Start_Date" or thisField EQ "BB_End_Date" or thisField EQ "postmark_date" or thisField EQ "BB_Received_Date" or thisField EQ "BB_Check_Date">
							<cfoutput>#DateFormat(Evaluate(thisField), "mm/dd/yyyy")#</cfoutput>
						<cfelse>
							<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
								<cfoutput>#Left(Evaluate(thisField), maxTitleLength)#</cfoutput>
							<cfelse>
								<cfoutput>#Replace(Evaluate(thisField), ',', '.','ALL')#</cfoutput>
							</cfif>
						</cfif>
						<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
						<!---<cfif len(Evaluate(thisField)) GT maxTitleLength >...</cfif>--->
					</td>
					<cfset columnCount = columnCount + 1 >
				</cfloop>
			</tr> 
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>#newLine#</cfoutput></cfif>
			<cfset rowCount = rowCount + 1 >
			<cfset secondLevelRowCount = secondLevelRowCount + 1 >
		</cfloop>
	<!--- count for the last total and grand total ---->
 		<cfif rowCount GT 1>
			<cfinclude template="/reportWriter/claimReportFirstLevelSum.cfm">
			<cfsilent>
			<cfset grandPaidCSTotal = grandPaidCSTotal + claimSummaryHandle.getProgramTotalPaidCS(preSumFieldV)  >
			<cfset grandPaidAmountTotal = grandPaidAmountTotal + claimSummaryHandle.getProgramTotalPaidAmount(preSumFieldV) >
			<cfset grandClaimCSTotal = grandClaimCSTotal + claimSummaryHandle.getProgramTotalClaimCS(preSumFieldV)  >
			<cfset grandClaimAmountTotal = grandClaimAmountTotal + claimSummaryHandle.getProgramTotalClaimAmount(preSumFieldV) >
			<cfif claimSummaryHandle.getClaimVariation$(preSumFieldV) NEQ "">
				<cfset grandClaimVariationDollars = grandClaimVariationDollars + claimSummaryHandle.getClaimVariation$(preSumFieldV) >
			</cfif>
			<cfif claimSummaryHandle.getClaimVariation$(preSumFieldV) NEQ "">
				<cfset grandClaimVariationCS = grandClaimVariationCS + claimSummaryHandle.getClaimVariationCS(preSumFieldV) >
			</cfif>
			<!--- participation ---->
			<cfif claimSummaryHandle.getClaimFieldExecutionCases(preSumFieldV) NEQ "">
				<cfset grandFieldExecutionCases = grandFieldExecutionCases + claimSummaryHandle.getClaimFieldExecutionCases(preSumFieldV) >
			</cfif>
			<cfif claimSummaryHandle.getClaimFieldExecutionDollars(preSumFieldV) NEQ "">
				<cfset grandFieldExecutionDollars = grandFieldExecutionDollars + claimSummaryHandle.getClaimFieldExecutionDollars(preSumFieldV)>
			</cfif>
			<cfif claimSummaryHandle.getClaimBidRequestCases(preSumFieldV) NEQ "">
				<cfset grandBidRequestCases = grandBidRequestCases + claimSummaryHandle.getClaimBidRequestCases(preSumFieldV) >
			</cfif>
			<cfif claimSummaryHandle.getClaimBidRequestDollars(preSumFieldV) NEQ "">
				<cfset grandBidRequestDollars = grandBidRequestDollars +  claimSummaryHandle.getClaimBidRequestDollars(preSumFieldV)>
			</cfif>
			<cfif claimSummaryHandle.getClaimOperatorDirectOrHqProgramsDollars(preSumFieldV) NEQ "">
				<cfset grandOperatorDirectOrHqProgramsDollars = grandOperatorDirectOrHqProgramsDollars + claimSummaryHandle.getClaimOperatorDirectOrHqProgramsDollars(preSumFieldV)>
			</cfif>
			<cfif claimSummaryHandle.getClaimOperatorDirectOrHqProgramsCases(preSumFieldV) NEQ "">
				<cfset grandOperatorDirectOrHqProgramsCases = grandOperatorDirectOrHqProgramsCases + claimSummaryHandle.getClaimOperatorDirectOrHqProgramsCases(preSumFieldV)>
			</cfif>
			<cfif claimSummaryHandle.getClaimOperatorDeviatedPricingCases(preSumFieldV) NEQ "">
				<cfset grandOperatorDeviatedPricingCases = grandOperatorDeviatedPricingCases + claimSummaryHandle.getClaimOperatorDeviatedPricingCases(preSumFieldV)>
			</cfif>
			<cfif claimSummaryHandle.getClaimOperatorDeviatedPricingDollars(preSumFieldV) NEQ "">
				<cfset grandOperatorDeviatedPricingDollars = grandOperatorDeviatedPricingDollars + claimSummaryHandle.getClaimOperatorDeviatedPricingDollars(preSumFieldV)>
			</cfif>
			<cfif claimSummaryHandle.getClaimDistributorTradeShelterCases(preSumFieldV) NEQ "">
				<cfset grandDistributorTradeShelterCases = grandDistributorTradeShelterCases + claimSummaryHandle.getClaimDistributorTradeShelterCases(preSumFieldV)>
			</cfif>
			<cfif claimSummaryHandle.getClaimDistributorTradeShelterDollars(preSumFieldV) NEQ "">
				<cfset grandDistributorTradeShelterDollars = grandDistributorTradeShelterDollars + claimSummaryHandle.getClaimDistributorTradeShelterDollars(preSumFieldV)>
			</cfif>
			<cfif claimSummaryHandle.getClaimTotalCases(preSumFieldV) NEQ "">
				<cfset grandTotalCases = grandTotalCases + claimSummaryHandle.getClaimTotalCases(preSumFieldV)>
			</cfif>
			<cfif claimSummaryHandle.getClaimTotalDollars(preSumFieldV) NEQ "">
				<cfset grandTotalDollars = grandTotalDollars + claimSummaryHandle.getClaimTotalDollars(preSumFieldV)>
			</cfif>
			</cfsilent>
			<cfinclude template="/reportWriter/claimReportGrandSum.cfm" >
		</cfif> 

		<!--- footer --->
		<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
			<tr id="footerPage" class="claimSummaryHeader" style="POSITION:relative; TOP:expression(document.getElementById('stuff').scrollTop);">		
				<cfloop list="#cmpHandle.getReportHeader()#" index="thisHeader">
					<td align="left" nowrap><cfoutput>#thisHeader#</cfoutput></td>
					<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
				</cfloop>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>#newLine#</cfoutput></cfif>
			</tr> 
		</cfif>
	</table>
	<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" WIDTH="176" HEIGHT="35" BACKGROUND="/images/print_button.gif">
		<TR>
			<!---<TD><A HREF="javascript:void(0);" onClick="javascript:printpage(6);"><IMG SRC="/images/fill.gif" ALT="" WIDTH="176" HEIGHT="35" BORDER="0"></A></TD>--->
			<TD><A HREF="javascript:void(0);" onClick="window.print();//javascript:printpage1(7);"><IMG SRC="/images/fill.gif" ALT="" WIDTH="176" HEIGHT="35" BORDER="0"></A></TD>
		</TR>
	</TABLE>
</div>

</body>
</html>

<script>
	function printpage(v)
	{
		// v = 6 = print
		// v = 7 = print preview
		var w = '<OBJECT ID="x" WIDTH=0 HEIGHT=0 CLASSID="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"></OBJECT>';
		document.body.insertAdjacentHTML('beforeEnd', w); 
		x.ExecWB(v,true);
		//x.ExecWB(6,false);
		x.outerHTML = "";
	}

</script>

<!---Drop temp table with the list of billbacks--->
<cfquery name="DropTheTable" datasource="#application.datasource#">
	DROP TABLE #accessibleBBIds#
	</cfquery> 
	
	<cfquery name="DropTheSecondTable" datasource="#application.datasource#">
	DROP TABLE #getClaimSummary#
	</cfquery> 