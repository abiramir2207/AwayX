<!---
	Description:
		Component used for claim Reports
	Package List:
	
	note: below is the numeric value of each type
	INT		 	1
	FLOAT	 	2
	STRING   	3
	DATE	  	4
	MONEY		5
	all other	6

--->

<cfcomponent>

<!--- section for property used throughout the component --->
<cfproperty name="claimSSPage" 			type="string"  />
<cfproperty name="claimReportTitles"	type="struct"  />
<cfproperty name="claimDisplayTitle"	type="string"  />
<cfproperty name="claimHeaderList" 		type="string"  />
<cfproperty name="claimFieldList" 		type="string"  />
<cfproperty name="claimFieldTypes" 		type="string"  />
<cfproperty name="claimGroupByFields" 	type="string"  />
<cfproperty name="claimSumFields" 		type="string"  />
<cfproperty name="claimUOMFields" 		type="string"  />
<cfproperty name="countProcessedClaims" type="numeric"  />

<cfset this.countProcessedClaims = 0 />
<cfset this.claimUOMFields= "" />
<cfset this.claimHeaderList = "" />
<cfset this.claimFieldList = "" />
<cfset this.claimFieldTypes = "" />
<cfset this.claimGroupByFields = "" />
<cfset this.claimSumFields = "" />
<cfset this.claimDisplayTitle = "" />
<cfset this.claimReportTitles = structNew() />
<!--- section for functions --->
<!--- collection for set ---->
<!--- list: claimSummary, varietySummary,timeProcSummary,participation,savingCost--->
<cffunction name="setReportSSPage" output="false" access="public">
	<cfargument name="claimReportName" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.claimReportName), 1))#">
		<cfcase value="C">
			<cfset this.claimSSPage = "claimSummary" />
		</cfcase>
		<cfcase value="V">
			<cfset this.claimSSPage = "varietySummary" />
		</cfcase>
		<cfcase value="T">
			<cfset this.claimSSPage = "timeProcessSummary" />
		</cfcase>
		<cfcase value="P">
			<cfset this.claimSSPage = "participation" />
		</cfcase>
		<cfcase value="S">
			<cfset this.claimSSPage = "costSaving" />
		</cfcase>
	</cfswitch>
</cffunction>

<cffunction name="setReportTitles" output="false" access="public">
	<cfargument name="claimReportList" type="string" default="" required="true">
	<cfloop list="#arguments.claimReportList#" index="thisReport" delimiters=",">
		<cfswitch expression="#Ucase(left(trim(thisReport), 1))#">
			<cfcase value="C">
				<cfset claimTitle = "Claim Summary" />
			</cfcase>
			<cfcase value="V">
				<cfset claimTitle = "Variety Summary" />
			</cfcase>
			<cfcase value="T">
				<cfset claimTitle = "Processing Time Summary" />
			</cfcase>
			<cfcase value="P">
				<cfset claimTitle = "Participation" />
			</cfcase>
			<cfcase value="S">
				<cfset claimTitle = "Cost Savings" />
			</cfcase>
		</cfswitch>
		<cfif Not StructKeyExists(this.claimReportTitles, trim(thisReport))>
			<cfset this.claimReportTitles[trim(thisReport)] = trim(claimTitle) />
		</cfif>
	</cfloop>
</cffunction>

<cffunction name="setReportDisplayTitles" output="false" access="public">
	<cfargument name="claimReportName" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.claimReportName), 1))#">
		<cfcase value="C">
			<cfset this.claimDisplayTitle = "Claim Summary Report" />
		</cfcase>
		<cfcase value="V">
			<cfset this.claimDisplayTitle = "Variety Summary" />
		</cfcase>
		<cfcase value="T">
			<cfset this.claimDisplayTitle = "Turn Around Time Detail Report" />
		</cfcase>
		<cfcase value="P">
			<cfset this.claimDisplayTitle = "Participation Report" />
		</cfcase>
		<cfcase value="S">
			<cfset this.claimDisplayTitle = "Cost Savings Detail Report" />
		</cfcase>
	</cfswitch>
</cffunction>

<!--- set header for each report --->
<cffunction name="setReportHeader" output="false" access="public">
	<cfargument name="reportName" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.reportName), 1))#">
		<cfcase value="C">
			<cfset this.claimHeaderList = "Customer <BR>Account,Payee <BR>Name,Reg,Mrkt,End User,End User <BR>Name,Claim <BR>No,Total <BR>Cases,Claim <BR>Total,Reference,Entry <BR>Date,POD <BR>From,POD <BR>To,UserID,Template<BR>Type,Template<BR>Name,Status" />
		</cfcase>
		<cfcase value="V">
			<cfset this.claimHeaderList = "Program ID,Program Name,Claim No,Delivery Period,Dist. ID,Dist. Name,Region,Claim CS,Claim $,Paid CS,Paid $" />
		</cfcase>
		<cfcase value="T">
			<cfset this.claimHeaderList = "Cust. <BR>Acct,Name,Reg.,Market,End User,Name,Claim,Total <BR>Dollars,Total <BR>Cases,Postmark <BR>Date,PD <BR>vs. <BR>RD Variance,Receipt <BR>Date,RD <BR>vs. <BR>ED,Entry <BR>Date,CD <BR>vs. <BR>ED,Check <BR>Date,CD <BR>vs. <BR>PD" />
		</cfcase>
		<cfcase value="P">
			<cfset this.claimHeaderList = "Reg.,Mark.,Dist. <BR>Acc.,Dist. <BR>Name,Item,Desc.,Field <BR>Exec. <BR>Cases,Field <BR>Exec. <BR>Dollars,Bid <BR>Request <BR>Cases,Bid <BR>Request <BR>Dollars,Operator <BR>Direct <BR>or <BR>HQ <BR>Programs <BR>Cases,Operator <BR>Direct <BR>or <BR>HQ <BR>Programs <BR>Dollars,Distributor <BR>Trade/Shelter <BR>Cases,Distributor <BR>Trade/Shelter <BR>Dollars,Operator <BR>Deviated <BR>Pricing <BR>Cases,Operator <BR>Deviated <BR>Pricing <BR>Dollars,Total Cases,Total Dollars" />
		</cfcase>
		<cfcase value="S">
			<cfset this.claimHeaderList = "Acc.,Name,Reg.,Mkt,End User,End <BR>User <BR>Name,Claim,Reference,Credit <BR>Memo,Claim <BR>Dollars,Dist. <BR>Dollars,+/- <BR>Dollars,Claim <BR>Units,Dist. <BR>Units,+/- <BR>Units" />
		</cfcase>
	</cfswitch>
</cffunction>

<cffunction name="setReportFields" output="false" access="public">
	<cfargument name="reportName" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.reportName), 1))#">
		<cfcase value="C">
			<cfset this.claimFieldList = "cust_id,cust_name,region_name,market_name,end_user,end_user_name,claimNo,paidCS,Paid_Amount,BB_Reference,BB_Date,BB_Start_Date,BB_End_Date,UserID,claimTemplateType,claimTemplateName,BB_Status" />
		</cfcase>
		<cfcase value="V">
			<cfset this.claimFieldList = "Program,Program_Title,claimNo,delivery_period,dist_id,dist_name,region_name,ClaimCS,Claim_Amount,PaidCS,Paid_Amount" />
		</cfcase>
		<cfcase value="T">
			<cfset this.claimFieldList = "Cust_ID,Cust_Name,region_name,market_name,operator_id,operator_name,claimNo,Paid_Amount,paidCS,postmark_date,PD_VS_RD_Days,BB_Received_Date,RD_VS_ED_Days,BB_Date,ED_VS_CD_Days,BB_Check_Date,CD_VS_PD_Days"  />
		</cfcase>
		<cfcase value="P">
			<cfset this.claimFieldList = "region_name,market_name,Cust_ID,Cust_Name,Item_Number,Description,Field_Execution_Cases,Field_Execution_Dollars,Bid_Request_Cases,Bid_Request_Dollars,Operator_Direct_or_HQ_Programs_Cases,Operator_Direct_or_HQ_Programs_Dollars,Distributor_Trade_Shelter_Cases,Distributor_Trade_Shelter_Dollars,Operator_Deviated_Pricing_Cases,Operator_Deviated_Pricing_Dollars,total_cases,total_dollars" />
		</cfcase>
		<cfcase value="S">
			<cfset this.claimFieldList = "cust_id,cust_name,region_name,market_name,operator_id,operator_name,claimNo,reference,credit_memo,Paid_Amount,Claim_Amount,Variation$,PaidCS,ClaimCS,VariationCS" />
		</cfcase>
	</cfswitch>
</cffunction>


<cffunction name="setReportFieldTypes" output="false" access="public">
	<cfargument name="reportName" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.reportName), 1))#">
		<cfcase value="C">
			<cfset this.claimFieldTypes = "3,3,3,3,1,1,5,5" />
		</cfcase>
		<cfcase value="V">
			<cfset this.claimFieldTypes = "3,3,3,3,1,1,5,5" />
		</cfcase>
		<cfcase value="T">
			<cfset this.claimFieldTypes = "3,3,3,3,1,1,5,5" />
		</cfcase>
		+
		<cfcase value="P">
			<cfset this.claimFieldTypes = "3,3,3,3,3,1,1,5,5" />
		</cfcase>
		<cfcase value="S">
			<cfset this.claimFieldTypes = "3,3,3,3,3,3,3,3,3,1,1,1,5,5,5" />
		</cfcase>
	</cfswitch>
</cffunction>

<cffunction name="setReportGroupByFields" output="false" access="public">
	<cfargument name="reportName" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.reportName), 1))#">
		<cfcase value="C">
			<cfset this.claimGroupByFields = "1" />
		</cfcase>
		<cfcase value="V">
			<cfset this.claimGroupByFields = "1" />
		</cfcase>
		<cfcase value="T">
			<cfset this.claimGroupByFields = "1" />
		</cfcase>
		<cfcase value="P">
			<!----<cfset this.claimGroupByFields = "1,3" />---->
			<cfset this.claimGroupByFields = "1" />
		</cfcase>
		<cfcase value="S">
			<cfset this.claimGroupByFields = "3" />
		</cfcase>
	</cfswitch>
</cffunction>

<cffunction name="setReportSumFields" output="false" access="public">
	<cfargument name="reportName" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.reportName), 1))#">
		<cfcase value="C">
			<cfset this.claimSumFields = "1" />
		</cfcase>
		<cfcase value="V">
			<cfset this.claimSumFields = "1" />
		</cfcase>
		<cfcase value="T">
			<cfset this.claimSumFields = "1" />
		</cfcase>
		<cfcase value="P">
			<cfset this.claimSumFields = "1,4" />
		</cfcase>
		<cfcase value="S">
			<!---<cfset this.claimSumFields = "1,4,3" />--->
			<cfset this.claimSumFields = "3,4,2" />
		</cfcase>
	</cfswitch>
</cffunction>

<cffunction name="setReportUOMFields" output="false" access="public">
	<cfargument name="reportName" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.reportName), 1))#">
		<cfcase value="C">
			<cfset this.claimUOMFields = "8,9" />
		</cfcase>
		<cfcase value="V">
			<cfset this.claimUOMFields = "8,9,10,11" />
		</cfcase>
		<cfcase value="T">
			<cfset this.claimUOMFields = "8,9,10,11,12,13,14,15,16,17" />
		</cfcase>
		<cfcase value="P">
			<cfset this.claimUOMFields = "7,8,9,10,11,12,13,14,15,16,17,18" />
		</cfcase>
		<cfcase value="S">
			<cfset this.claimUOMFields = "10,11,12,13,14,15" />
		</cfcase>
	</cfswitch>
</cffunction>

<!--- collection for get --->
<cffunction name="getReportSSPage" output="false" returntype="string">
	<cfreturn this.claimSSPage />
</cffunction> 

<cffunction name="getReportUOMFields" output="false" returntype="string">
	<cfreturn this.claimUOMFields />
</cffunction> 
<cffunction name="getReportGroupByFields" output="false" returntype="string">
	<cfreturn this.claimGroupByFields />
</cffunction>

<cffunction name="getReportSumFields" output="false" returntype="string">
	<cfreturn this.claimSumFields />
</cffunction>

<cffunction name="getReportHeader" output="false" returntype="string">
	<cfreturn this.claimHeaderList />
</cffunction>

<cffunction name="getReportFields" output="false" returntype="string">
	<cfreturn this.claimFieldList />
</cffunction>

<cffunction name="getReportFieldTypes" output="false" returntype="string">
	<cfreturn this.claimFieldTypes />
</cffunction>

<cffunction name="getReportFieldType" output="false" returntype="string">
	<cfargument name="thisField" type="numeric" required="true">
	<cfreturn ListGetAt(this.getReportFieldTypes(), arguments.thisField) />
</cffunction>

<cffunction name="getClaimReportTitle" output="false" returntype="string">
	<cfargument name="claimReportName" type="string" default="" required="true">
	<cfreturn this.claimReportTitles[arguments.claimReportName] />
</cffunction>

<cffunction name="getClaimReportDivisions" output="false" returntype="query">
	<CFQUERY NAME="qryGetClaimReportDivisions" DATASOURCE="#application.datasource#">
		SELECT Service_Zone_ID, Zone_Name
		FROM Service_Zones
		WHERE Deleted = 0
		AND len(Zone_Name) > 0
		ORDER BY Zone_Name
	</CFQUERY>
	<cfreturn qryGetClaimReportDivisions />
</cffunction>

<cffunction name="getClaimReportRegions" output="false" returntype="query">
	<CFQUERY NAME="qryGetClaimReportRegions" DATASOURCE="#application.datasource#">
		SELECT Service_Region_ID, Region_Name
		FROM Service_Regions
		WHERE Deleted = 0
		AND len(Region_Name) > 0
		ORDER BY Region_Name
	</CFQUERY>
	<cfreturn qryGetClaimReportRegions />
</cffunction>

<cffunction name="getClaimReportTerritories" output="false" returntype="query">
	<CFQUERY NAME="qryGetClaimReportTerritories" DATASOURCE="#application.datasource#">
		SELECT Service_Market_ID, Market_Name
		FROM Service_Markets
		WHERE Deleted = 0
		AND len(Market_Name) > 0
		ORDER BY Market_Name
	</CFQUERY>
	<cfreturn qryGetClaimReportTerritories />
</cffunction>

<cffunction name="getClaimReportProgramStatus" output="false" returntype="query">
	<CFQUERY NAME="qryGetClaimReportProgramStatus" DATASOURCE="#application.datasource#">
		Select	distinct Billback_Status_ID, BB_Status_Description
		From 	billback_status
		where 	Billback_Status_ID < 6
		Order By Billback_Status_ID
	</CFQUERY>
	<cfreturn qryGetClaimReportProgramStatus />
</cffunction>

<cffunction name="getApprovedClaimProgramStatus" output="false" returntype="query">
	<CFQUERY NAME="qryGetApprovedClaimProgramStatus" DATASOURCE="#application.datasource#">
		Select	distinct Billback_Status_ID, BB_Status_Description
		From 	billback_status
		where 	Billback_Status_ID NOT IN (1,2,8)
		Order By Billback_Status_ID
	</CFQUERY>
	<cfreturn qryGetApprovedClaimProgramStatus />
</cffunction>

<cffunction name="getClaimReportProgramTypes" output="false" returntype="query">
	<CFQUERY NAME="qryGetClaimReportProgramTypes" DATASOURCE="#application.datasource#">
		Select	Generic_Type
		From 	Generic_Type
		Order By Generic_Type
	</CFQUERY>
	<cfreturn qryGetClaimReportProgramTypes />
</cffunction>

<cffunction name="getClaimDisplayTitle" output="false" returntype="string">
	<cfreturn this.claimDisplayTitle />
</cffunction>

<cffunction name="getClaimReportGroupByList" output="false" returntype="string">
	<cfargument name="reportType" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.reportType), 1))#">
		<cfcase value="C">
			<cfreturn 2 />
		</cfcase>
		<cfcase value="V">
			<cfreturn 1 />
		</cfcase>
		<cfcase value="T">
			<cfreturn 3 />
		</cfcase>
		<cfcase value="P">
			<cfreturn "2,3" />
		</cfcase>
		<cfcase value="S">
			<cfreturn 3 />
		</cfcase>
	</cfswitch>
</cffunction>
<!--- D41234 :: Prod Event 4533
function name Property has same name which casued event error, modified function name.
--->
<cffunction name="iCountProcessedClaims" output="false" returntype="boolean">
	<cfargument name="reportName" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.reportName), 1))#">
		<cfcase value="C">
			<cfset this.countProcessedClaims = false />
		</cfcase>
		<cfcase value="V">
			<cfset this.countProcessedClaims = false />
		</cfcase>
		<cfcase value="T">
			<cfset this.countProcessedClaims = true />
		</cfcase>
		<cfcase value="P">
			<cfset this.countProcessedClaims = false />
		</cfcase>
		<cfcase value="S">
			<cfset this.countProcessedClaims = false />
		</cfcase>
	</cfswitch>
	<cfreturn this.countProcessedClaims />
</cffunction>

<cffunction name="IsClaimLegendRequired" output="false" returntype="string">
	<cfargument name="reportType" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.reportType), 1))#">
		<cfcase value="C">
			<cfreturn false />
		</cfcase>
		<cfcase value="V">
			<cfreturn false />
		</cfcase>
		<cfcase value="T">
			<cfreturn true />
		</cfcase>
		<cfcase value="P">
			<cfreturn false />
		</cfcase>
		<cfcase value="S">
			<cfreturn false />
		</cfcase>
	</cfswitch>
</cffunction>

<!---- should we consider second level summary, in other words, customer/distributor level---->
<cffunction name="IsSecondLevelCounted" output="false" returntype="boolean">
	<!--- 	retrieve summary field
			if the length of the summary field is greater than 1, return true
			else return false 
	---->
	<cfif ListLen(this.getReportSumFields()) EQ 1>
		<cfreturn false />
	<cfelse>
		<cfreturn true />
	</cfif> 
</cffunction>

<cffunction name="getLegendInfo" output="false" returntype="string">
	<cfargument name="reportType" type="string" default="" required="true">
	<cfswitch expression="#Ucase(left(trim(arguments.reportType), 1))#">
		<cfcase value="T">
			<cfset this.claimLegendInfo = "Legend:<blockquote>PD vs RD denotes Receipt exceeds 5 days from postmark date.&nbsp;&nbsp;&nbsp;RD vs ED denotes Entry exceeds 20 days from Receipt Date <BR>CD vs ED denotes Check exceeds 3 days from Entry Date.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CD vs PD denotes check exceeds 27 days from Postmark Date</blockquote>" />
		</cfcase>
	</cfswitch>
	<cfreturn this.claimLegendInfo />
</cffunction>

</cfcomponent>