<cfcomponent hint="Deduction Manager" extends="components.Base">

	<cfset this.Deduction_Info = "" />

	<cffunction name="init" output="false" returntype="components.deduction.DeductionLinkManager">

		<cfreturn this />

	</cffunction>


	<cffunction name="getDeductionInfo" output="false" returntype="query">

		<cfreturn this.Deduction_Info />

	</cffunction>

	<cffunction name="setDeductionInfo" output="false" returntype="void">
		<cfargument name="deductionInfo" required="true" type="query" />

		<cfset this.Deduction_Info = arguments.deductionInfo />

	</cffunction>

	<cffunction name="loadDeductionInfo" output="false" returntype="query">
		<cfargument name="deductionId" required="true" type="string" />

		<!---- if we already have the query for current deduction, don't query again '----->
		<cfif IsQuery("this.Deduction_Info")>
			<cfif this.Deduction_Info.Deduction_ID eq arguments.deductionId>
				<cfreturn this.Deduction_Info />
			</cfif>
		</cfif>

		<CFQUERY NAME="this.Deduction_Info" DATASOURCE="#Application.Datasource#">
			SELECT 	*
			FROM 	Deductions
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>

		<cfreturn this.Deduction_Info />

	</cffunction>


<!---
common filters
- should not be a parent deduction
- ReOpenLogic_ShowLinks
<CFIF 	DisableIfParent.RecordCount EQ 0
		AND ReOpenLogic_ShowLinks EQ 1
		AND LockStatus EQ 1
		AND Deduction_Info.Is_Write_Off EQ 0
		AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
		AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
		>

write off - extra filters
<CFIF appSettings.getDDAllowWriteOff()
	AND (Deduction_Info.DD_Status EQ 2 OR Deduction_Info.DD_Status EQ 8)>

billback - extra filters

<CFIF DeductionSettings.Billback IS 1
		AND Deduction_Info.DD_Status LT 3>

credit - extra filters
<CFIF Appsettings.getDDAllowNegativeAmountCredits()
		AND Deduction_Info.DD_Status LT 3>

deduction - extra filters
<CFIF Appsettings.getDDAllowNegativeAmountCredits()
		AND Deduction_Info.DD_Status EQ 8
		AND Deduction_Info.Is_Credit EQ 1>

-------------------------------------------------------------------------------------------------
For write off link
<CFIF DisableIfParent.RecordCount EQ 0>
<CFIF appSettings.getDDAllowWriteOff() EQ 1>
<CFIF ReOpenLogic_ShowLinks EQ 1
		AND Deduction_Info.Is_Write_Off NEQ 1
		AND (Deduction_Info.DD_Status EQ 2 OR Deduction_Info.DD_Status EQ 8)
		AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
		AND LockStatus EQ 1
		AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
		AND ((CheckForChild.RecordCount EQ 0 AND Deduction_Info.DD_ISParent EQ 1) OR Deduction_Info.DD_Ischild EQ 1)>

-------------------------------------------------------------------------------------------------
For billback link
<CFIF Deduction_Info.Is_Write_Off EQ 0
		AND ReOpenLogic_ShowLinks EQ 1
		AND LockStatus EQ 1
		AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
		AND DisableIfParent.RecordCount EQ 0>
		AND	DeductionSettings.Billback IS 1
		AND Deduction_Info.DD_Status LT 3
		AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>

-------------------------------------------------------------------------------------------------
For Credit link
<CFIF Deduction_Info.Is_Write_Off EQ 0
		AND ReOpenLogic_ShowLinks EQ 1
		AND LockStatus EQ 1
		AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
		AND DisableIfParent.RecordCount EQ 0>
		AND Deduction_Info.DD_Status LT 3
		AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
<CFIF Appsettings.getDDAllowNegativeAmountCredits()>

-------------------------------------------------------------------------------------------------
For deduction link from credit
<CFIF Deduction_Info.Is_Write_Off EQ 0
		AND ReOpenLogic_ShowLinks EQ 1
		AND LockStatus EQ 1
		AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
		AND DisableIfParent.RecordCount EQ 0>
		AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1>
<CFIF Appsettings.getDDAllowNegativeAmountCredits()>
<CFIF Deduction_Info.DD_Status EQ 8 AND Deduction_Info.Is_Credit EQ 1>
-------------------------------------------------------------------------------------------------

---->
	<cffunction name="canUserChangeClosureType" output="false" returntype="boolean">
		<cfargument name="deductionId" required="true" type="string" />
		<cfargument name="fromMatchCentral" required="false" type="numeric" default="0" />

		<cfset var Deduction_Info = loadDeductionInfo(deductionId = arguments.deductionId) />
		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

		<cfset Deduction_ID = arguments.deductionId />
		<cfset fromMatchCentral = arguments.fromMatchCentral />
		<cfinclude template="/deductions/Get_Lock_Status.cfm">

		<CFQUERY NAME="DisableIfParent" DATASOURCE="#Application.Datasource#">
			SELECT 	TOP 1 *
			FROM 	Deductions
			WHERE 	DD_Parent_ID = <cfqueryparam value="#arguments.deductionId#" cfsqltype="CF_SQL_VARCHAR">
			AND 	Deleted = 0
		</CFQUERY>

		<CFSET ReOpenLogic_ShowLinks = 0>

<CFIF
            (Deduction_Info.ReOpened EQ 1 AND Deduction_Info.DD_Reopened_Sent EQ 1 AND Deduction_Info.Ack_received_Reopen EQ 1) OR
            <!---D42284 :: Rebill vs closed deduction reopened --->
            <!--- D44454:: Re opened DD/Anand Rao/21-Aug-2014/Changed the application setting to check for  ON --->
            (Deduction_Info.ReOpened EQ 1 AND appSettings.getDD_Reopen_Interface() EQ 1) OR
            (Deduction_Info.ReOpened EQ 0 AND Deduction_Info.DD_Reopened_Sent EQ 0 AND Deduction_Info.Ack_received_Reopen EQ 0)>
            <CFSET ReOpenLogic_ShowLinks = 1>
</CFIF>

		<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
			SELECT *
			FROM 	Deductions_Profiles_Settings
			WHERE 	Profiles_ID = <cfqueryparam value="#request.AccessStructure.Profiles_ID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<!------------------ see if user can change the closure type of this deduction - start --------------------->
		<CFIF 	DisableIfParent.RecordCount EQ 0
			AND ReOpenLogic_ShowLinks EQ 1
			AND LockStatus NEQ 2
			AND Deduction_Info.Is_Write_Off EQ 0
			AND len(trim(Deduction_Info.DD_Closure_ID)) EQ 0
			AND DeductionsProfilesSettings.DD_ACCESS_LEVEL GT 1
			>
			<cfreturn true />
		</CFIF>
		<!------------------ see if user can change the closure type of this deduction - end --------------------->

		<cfreturn false />

	</cffunction>


	<cffunction name="isWriteOffAvailable" output="false" returntype="boolean">
		<cfargument name="deductionId" required="true" type="string" />

		<!------------------ see if user can change the closure type of this deduction --------------------->
		<cfif canUserChangeClosureType(deductionId = arguments.deductionId)>

			<cfset Deduction_Info = loadDeductionInfo(deductionId = arguments.deductionId) />
			<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

			<!------------------ see if user can do write off --------------------->
			<CFIF appSettings.getDDAllowWriteOff()
				AND (Deduction_Info.DD_Status EQ 2 OR Deduction_Info.DD_Status EQ 8)>

				<cfreturn true />

			</CFIF>

		</cfif>

		<cfreturn false />

	</cffunction>

	<cffunction name="isAssocToBillbackAvailable" output="false" returntype="boolean">
		<cfargument name="deductionId" required="true" type="string" />
		
		

		<!------------------ see if user can change the closure type of this deduction --------------------->
		<cfif canUserChangeClosureType(deductionId = arguments.deductionId)>

			<cfset Deduction_Info = loadDeductionInfo(deductionId = arguments.deductionId) />
			<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

			<!------------------ see if user can associate to billback --------------------->
			<CFIF Deduction_Info.DD_Status LT 3>

				<cfreturn true />

			</CFIF>

		</cfif>

		<cfreturn false />

	</cffunction>

	<cffunction name="isCreditAssocToDeductionAvailable" output="false" returntype="boolean">
		<cfargument name="deductionId" required="true" type="string" />
		<cfargument name="fromMatchCentral" required="false" type="numeric" default="0" />

		<!------------------ see if user can change the closure type of this deduction --------------------->
		<cfif canUserChangeClosureType(deductionId = arguments.deductionId, fromMatchCentral = arguments.fromMatchCentral)>

			<cfset Deduction_Info = loadDeductionInfo(deductionId = arguments.deductionId) />
			<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

			<!------------------ see if user can associate to billback --------------------->
			<CFIF appSettings.getDDAllowNegativeAmountCredits()
				AND Deduction_Info.DD_Status EQ 8
				AND Deduction_Info.Is_Credit EQ 1>

				<cfreturn true />

			</CFIF>

		</cfif>

		<cfreturn false />

	</cffunction>

</cfcomponent>