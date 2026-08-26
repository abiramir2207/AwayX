<!---
	Description:
		Component used for claim Reports
	Package List:
--->

<cfcomponent displayname="ClaimReportManager" hint="this is the container class">
<!--- section for property used throughout the component --->
<cfproperty name="claimReportTitles"	type="struct"  />
<cfset this.claimReportTitles = structNew() />

<!--- init ---->
<cffunction name="init" access="public" returntype="ClaimReportManager" output="false">
	<cfreturn this />
</cffunction>

<!--- methods --->
<cffunction name="isExcelGeneratorEnabled" returntype="boolean" access="public">
	<cfargument name="thisReport" type="Report" required="true">
	<cfreturn arguments.thisReport.isExcelGenerated() />
</cffunction>

<!--- section for functions --->
<!--- collection for set ---->
<!--- list: claimSummary, varietySummary,timeProcSummary,participation,savingCost--->
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


<!--- collection for get --->
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
		Order By Billback_Status_ID
	</CFQUERY>
	<cfreturn qryGetClaimReportProgramStatus />
</cffunction>

<cffunction name="getClaimReportProgramTypes" output="false" returntype="query">
	<CFQUERY NAME="qryGetClaimReportProgramTypes" DATASOURCE="#application.datasource#">
		Select	Generic_Type
		From 	Generic_Type
		Order By Generic_Type
	</CFQUERY>
	<cfreturn qryGetClaimReportProgramTypes />
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
			<cfreturn "2,3" />
		</cfcase>
	</cfswitch>
</cffunction>

<!---- claim report Summary information --->

</cfcomponent>