<cfcomponent displayname="ProgramClaimRatesReport" hint="Program Claim Rates Report" extends="components.Base">

	<cffunction name="init" returntype="components.programs.ProgramClaimRatesReport" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="getProgramClaimRatesReport" returntype="query" output="false">
		<cfargument name="programIDList" type="string" required="false" default="">
		<cfargument name="distributorIDList" type="string" required="false" default="">
		<cfargument name="EffectiveDate" type="date" required="true">
		<cfargument name="ReportType" type="numeric" required="true">
		<cfargument name="pays_to" type="numeric" required="true">
		<cfargument name="report_config_id" type="numeric" required="true">
		<cfargument name="IncludeInActive" type="boolean" required="false" default="0"  />


		<cftry>

		<cfquery name="getProgramNumber" datasource="#application.datasource#">
		 SELECT contract_number
		 FROM Contract_Main
		 WHERE Contract_Main_ID IN (#arguments.programIDList#)
		</cfquery>

		<cfquery name="local.qReportConfig" datasource="#application.datasource#">
		  SELECT ISNULL(By_Group, 0) AS By_Group
		    FROM CLAIM_RATES_SETTING
		   WHERE Config_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.report_config_id#">
		</cfquery>


                        <cfquery name="qProgramClaimRatesReportDropTable" datasource="#application.datasource#">
                                    IF EXISTS (SELECT NAME FROM TEMPDB..SYSOBJECTS WHERE NAME = '##tmp_cmid')
                                                drop table ##tmp_cmid

                                    IF EXISTS (SELECT NAME FROM TEMPDB..SYSOBJECTS WHERE NAME = '##tmp_distid')
                                                drop table ##tmp_distid

                                    IF EXISTS (SELECT NAME FROM TEMPDB..SYSOBJECTS WHERE NAME = '##tmp_cp')
                                                drop table ##tmp_cp

                                    IF EXISTS (SELECT NAME FROM TEMPDB..SYSOBJECTS WHERE NAME = '##tmp_cp_detail')
                                                drop table ##tmp_cp_detail
                        </cfquery>


		<cfquery name="qProgramClaimRatesReport" datasource="#application.datasource#">
		if object_id('tempdb..##tmp_cmid') is not null
			drop table ##tmp_cmid

		if object_id('tempdb..##tmp_claim_report_results') is not null
			drop table ##tmp_claim_report_results


			<cfset program_id_list = ValueList(getProgramNumber.contract_number)>

			create table ##tmp_cmid (contract_number varchar(35))

			<cfloop list="#program_id_list#" index="cmid">
				insert into ##tmp_cmid (contract_number) values ('#cmid#')
			</cfloop>

			if object_id('tempdb..##tmp_distid') is not null
			drop table ##tmp_distid

			create table ##tmp_distid (distributor_id varchar(50))

			if object_id('tempdb..##tmp_oprid') is not null
			drop table ##tmp_oprid

			create table ##tmp_oprid (operator_id varchar(50))


			<!--- Dev Note: Kal; D45199: Claim Rates not populating operator report  --->
			<cfif arguments.pays_to eq "1" >
				<cfloop list="#arguments.distributorIDList#" index="distid">
					insert into ##tmp_distid (distributor_id) values ('#distid#')
				</cfloop>
			<cfelse>
				<cfloop list="#arguments.distributorIDList#" index="oprid">
					insert into ##tmp_oprid (operator_id) values ('#oprid#')
				</cfloop>
			</cfif>


			EXEC PROGRAM_CLAIM_RATES_REPORT '#arguments.EffectiveDate#', '#arguments.ReportType#', #arguments.pays_to#, #local.qReportConfig.by_group#, #arguments.IncludeInActive#

			drop table ##tmp_cmid
			drop table ##tmp_distid
		</cfquery>

		<cfcatch>
			<cfquery name="qProgramClaimRatesReportDropTable" datasource="#application.datasource#">
				IF EXISTS (SELECT NAME FROM TEMPDB..SYSOBJECTS WHERE NAME = '##tmp_cmid')
					drop table ##tmp_cmid

				IF EXISTS (SELECT NAME FROM TEMPDB..SYSOBJECTS WHERE NAME = '##tmp_distid')
					drop table ##tmp_distid
			</cfquery>
			<cfrethrow>
		</cfcatch>

		</cftry>

		<cfreturn qProgramClaimRatesReport />

	</cffunction>

	<cffunction name="getClaimRatesProgramsDetails" returntype="query" output="false">
		<cfargument name="effectiveDate" type="date" required="false" />
		<cfargument name="paidTo" type="string" required="true" hint="paid to: distributor or operator selected" />
		<cfargument name="paidToList" type="string" required="true" hint="list of distributors or operators selected" />
		<cfargument name="programIDList" type="string" required="false" default="">

		<cfset var programsList = arguments.programIDList/>
		<cfif NOT(len(programsList))>
			<cfset getClaimRatesPrograms(arguments.effectiveDate, arguments.paidTo) />
		</cfif>

		<cfset useLakebaseForqConfig = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("claim_rates_setting")>
<cfif useLakebaseForqConfig>
	<cftry>
		<cfset qConfig = application.oLakebase.toQuery(
			application.oLakebase.selectRows("claim_rates_setting", {
				"deleted" = "eq.0",
				"default_setting" = "eq.1",
				"order" = "config_id.desc",
				"limit" = "1",
				"select" = "config_id,config_name"
			}), "config_id,config_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqConfig = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqConfig>
<cfquery name="qConfig" datasource="#application.datasource#">
			SELECT TOP 1 Config_ID, Config_Name
			FROM CLAIM_RATES_SETTING
			WHERE Deleted = 0
			AND default_setting = 1
			ORDER BY Config_ID DESC
		</cfquery>
</cfif>

		<cfscript>
		objProgramManager = CreateObject("component","mvc.Models.Program.ProgramManager");
		</cfscript>

		<CFINCLUDE TEMPLATE="/scorecard/access_permissions.cfm">

		<cfset moreAccessPermissionRestriction = objProgramManager.getProgramAccessPermissionCode()>
		<cfset objProgramManager.populateProgramSearchAccessPermissionTables(UserPositionList,HQUser)>

		<cfquery name="qGetClaimRatesProgramsDetails" datasource="#application.datasource#">
			/* get the programs for my positions and for the payyee selected */
			SELECT DISTINCT	Contract_Main.contract_number, Contract_Main.revision_version, Contract_Main.contract_title, Contract_Main.contract_main_id,
							CST.Contract_Status_Type_Desc, PCPO.Created_Type,
							_Users.Name_First + ' ' + Name_Last AS RSP,
							ISNULL(CRS.Config_Id, #qConfig.Config_ID#) AS config_id,
							ISNULL(CRS.ConFig_Name, '#qConfig.Config_Name#') AS config_name
			FROM Contract_Main
			INNER JOIN Contract_Status_Types CST
				ON CST.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
			INNER JOIN Program_Control_Panel_Options PCPO
				ON PCPO.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
				AND ISNULL(PCPO.Claim_Rates_Config_ID, 2) != 0
			LEFT JOIN _Users
				ON Contract_Main.Responsible_User_ID = _Users.User_ID
					AND _Users.Deleted = 0
			LEFT JOIN CLAIM_RATES_SETTING CRS
				ON ISNULL(NULLIF(PCPO.Claim_Rates_Config_ID, 0), 2) = CRS.Config_ID
			<cfif arguments.paidTo eq "operator">
			INNER JOIN Contract_Operators CO
			ON CO.Contract_Main_ID = Contract_Main.Contract_Main_ID
			AND CO.BSA_Operator_ID in (#ListQualify(arguments.paidToList,"'")#)
			AND CO.Deleted = 0
			<cfelse>
			INNER JOIN Contract_Distributors CD
			ON CD.Contract_Main_ID = Contract_Main.Contract_Main_ID
			AND CD.BSA_Foodservice_Customers_ID in (#ListQualify(arguments.paidToList,"'")#)
			AND CD.Deleted = 0
			</cfif>
			INNER JOIN ##Profile_Forbidden_Template
			ON Contract_Main.ProgramType_ID = ##Profile_Forbidden_Template.Template_ID
			<!--- Dev Note: Do not add "cfqueryparam" for "Contract_Main_ID" below.
			It causes this error - Too many parameters were provided in this RPC request. The maximum is 2100.
			--->

			WHERE Contract_Main.Contract_Main_ID IN
			<cfif len(programsList)>
			(#programsList#)
			<cfelse>
			(SELECT Contract_Main_ID FROM ##TMP_PRG_CLAIM_RATES)
			</cfif>
			<cfif NOT HQUser>
			AND
			(
				Contract_Main.Creating_User_Position_ID IN (#preserveSingleQuotes(UserPositionList)#)
				<!--- If HQ user no need to check for position --->
				OR
				(
				Contract_Main.Creating_User_Position_ID IN (#preserveSingleQuotes(GP_Position_List_From_My_Position_Down_SC)#)
				)
				OR EXISTS
				(
				SELECT	1
				FROM	##TmpProgramsWithDistBrokerBelowMe t
				WHERE	t.Contract_Main_ID = Contract_Main.Contract_Main_ID
				)
			)
			</cfif>
			#PreserveSingleQuotes(moreAccessPermissionRestriction)#
			ORDER BY Contract_Main.Contract_Number
		</cfquery>
		<cfreturn qGetClaimRatesProgramsDetails />
	</cffunction>


<cffunction name="getClaimRatesPrograms" returntype="void" output="false">
	<cfargument name="effectiveDate" type="date" required="false" />
	<cfargument name="paidTo" type="string" required="true" />

	<cfif arguments.paidTo eq "operator">
		<cfset var paidToType =	2 >
	<cfelse>
		<cfset var paidToType =	1 >
	</cfif>

	<cfquery name="drpTables" datasource="#application.datasource#">
		if object_id('tempdb..##TMP_PRG_CLAIM_RATES') is not null
		drop table ##TMP_PRG_CLAIM_RATES
	</cfquery>

	<!--- NOTE: DO NOT ADD CFQUERYPARAM TO THE QUERY AS THE BELOW TEMP TABLE IS BEING USED IN A SEPARATE CF FUNCTION. --->
	<cfquery name="qGetClaimRatesPrograms" datasource="#application.datasource#">
		CREATE TABLE ##TMP_PRG_CLAIM_RATES(Contract_Main_ID int)

		INSERT INTO  ##TMP_PRG_CLAIM_RATES(Contract_Main_ID)
		<!---this subquery gathers programs based on pays to type ( distributors vs. operators )--->
		SELECT DISTINCT CM.Contract_Main_ID
		FROM CONTRACT_MAIN CM
		INNER JOIN PROGRAM_REBATES_COMPONENT
			ON PROGRAM_REBATES_COMPONENT.Program_Id = CM.Contract_Main_Id
				AND PROGRAM_REBATES_COMPONENT.Deleted = 0
				AND PROGRAM_REBATES_COMPONENT.Component_Paid_To IN (#paidToType#, 4)
		INNER JOIN PAYMENT_TYPE
			ON PAYMENT_TYPE.Payment_Type_Id = PROGRAM_REBATES_COMPONENT.Claim_Mechanics
				AND IsNull(PAYMENT_TYPE.Include_Claim_Rates_Report, 0) = 1
		WHERE '#arguments.effectiveDate#' >= CM.Effective_Start_Date
			AND	'#arguments.effectiveDate#' <= CM.Effective_End_Date

		UNION

		SELECT DISTINCT CM.Contract_Main_ID
		FROM CONTRACT_MAIN CM
		INNER JOIN PROGRAM_FIXED_COMPONENT
			ON PROGRAM_FIXED_COMPONENT.Program_Id = CM.Contract_Main_Id
				AND PROGRAM_FIXED_COMPONENT.Deleted = 0
				AND PROGRAM_FIXED_COMPONENT.Fixed_Component_Paid_To IN (#paidToType#, 4)
		INNER JOIN PAYMENT_TYPE
			ON PAYMENT_TYPE.Payment_Type_Id = PROGRAM_FIXED_COMPONENT.Claim_Mechanics
				AND IsNull(PAYMENT_TYPE.Include_Claim_Rates_Report, 0) = 1
		WHERE '#arguments.effectiveDate#' >= CM.Effective_Start_Date
			AND	'#arguments.effectiveDate#' <= CM.Effective_End_Date
	</cfquery>

</cffunction>


<cffunction name="IsClaimRatesAvailableOnProgram" returntype="boolean" output="false">
	<cfargument name="programID" type="numeric" required="true" />

	<cfset var bShowClaimRateDate = 0/>

<!--- IF Freight_Component_Type <> 0, then show freight page schtuff... OTHER REQUIREMENTS TOO RBL D16586 --->
<cfquery name="variables.qGetFreightComponentType" datasource="#application.datasource#">
	SELECT	Freight_Component_Type, Include_Claim_Rates_Report
  	FROM	Contract_main_Aux_Data
  	WHERE	Contract_Main_ID = <cfqueryparam value="#arguments.programID#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- Dev Note: KAL; D15961: Add new column for claim rates to letters : Query to find if there is at least one fixed price component on this program that has claim mechanics 'include in claim rate = ON'  --->
<cfif variables.qGetFreightComponentType.Include_Claim_Rates_Report eq 1>
	<cfquery name="variables.qGetFixedComponentPaymentType" datasource="#application.datasource#">
		SELECT 	Count(*) as ComponentClaimRateCount
		FROM 	Program_Fixed_Component
		INNER JOIN Payment_Type
		ON 		Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
		WHERE 	Program_Fixed_Component.Program_ID = <cfqueryparam value="#arguments.programID#" cfsqltype="cf_sql_integer">
		AND 	Program_Fixed_Component.deleted = 0
		AND		Payment_Type.Include_Claim_Rates_Report = 1
	</cfquery>
	<cfif variables.qGetFixedComponentPaymentType.ComponentClaimRateCount and application.appSettingsGet.getProgramClaimRatesReportAvailable()>
		<cfset bShowClaimRateDate = 1/>
	</cfif>
</cfif>

	<cfreturn bShowClaimRateDate />

</cffunction>

</cfcomponent>
