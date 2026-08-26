<cfsilent>
<!---
Name: 			program_form_new.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Created Date:	11/13/2006
Created By:		Brenda Flynn    
Description:	This file includes selections for programs, discount types and then includes the page for products on the programs, the discount and volume claimed
--->

<cfparam name="URL.BBID" default="">
<!--- <cfparam name="rebateActionLabel" default="save">
<cfparam name="form.Last_Date_To_Claim" default="0" />
<cfset form.prodUpdate = 0 />
<cfparam name="url.xl" default="0">
<cfset variables.xl = url.xl>
<cfparam name="TotalRebate" default="0" />
<cfparam name="RebateUpdateAllowed" default="0" />
<cfparam name="ListProgramDiscountTypes" default="" /> --->

<cfset billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init() />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset billbackManager = CreateObject("component", "components.billback.BillbackManager").init() />
<cfset objProgram = CreateObject("component", "components.programs.program") />
<cfset appSettings = application.appSettingsGet>

<!--- Get the Billback profile setting --->
	<cfset BB_User_Profile = CreateObject("component", "components.user.profile").getProfileSettings(request.Accessstructure.Profiles_ID)>
<CFIF URL.BBID NEQ "">
	<cfset useLakebaseForCheckCopiedBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForCheckCopiedBB>
	<cftry>
		<cfset CheckCopiedBB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#URL.BBID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckCopiedBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckCopiedBB>
<CFQUERY NAME="CheckCopiedBB" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback WHERE Billback_ID = '#URL.BBID#'
	</CFQUERY>
</cfif>
	
	
	<CFIF CheckCopiedBB.CopiedBB NEQ "" AND CheckCopiedBB.BB_Start_Date EQ "">
		<CFLOCATION URL="basic_information_form.cfm?BBID=#URL.BBID#" ADDTOKEN="No">
	</CFIF>
</CFIF>


<cfset useLakebaseForgetPayeeInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetPayeeInfo>
	<cftry>
		<cfset getPayeeInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "billback_payee_type_id,bb_amount,claim_cases,claim_pounds,negative_billback"
			}), "billback_payee_type_id,bb_amount,claim_cases,claim_pounds,negative_billback"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPayeeInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPayeeInfo>
<cfquery name="getPayeeInfo" datasource="#Application.Datasource#">
	SELECT 	Billback_Payee_Type_ID, 
			BB_Amount,
			Claim_Cases,
			Claim_Pounds,
			Negative_Billback
	FROM 	Billback
	WHERE 	Billback_ID = '#FORM.Billback_ID#'
</cfquery>
</cfif>

<CFSET getPayeeID = QueryNew("Payee_ID")>
<cfswitch expression="#getPayeeInfo.Billback_Payee_Type_ID#">
	<cfcase value="1"><!--- Distributor --->
		<cfset useLakebaseForgetPayeeID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor")>
<cfif useLakebaseForgetPayeeID>
	<cftry>
		<cfset getPayeeID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"deleted" = "eq.0",
				"select" = "distributor_id as payee_id"
			}), "distributor_id as payee_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPayeeID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPayeeID>
<cfquery name="getPayeeID" datasource="#Application.Datasource#">
			SELECT Distributor_ID as Payee_ID
			FROM Billback_Distributor
			WHERE Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0
		</cfquery>
</cfif>
	</cfcase>

	<cfcase value="2"><!--- Operator --->
		<cfquery name="getPayeeID" datasource="#Application.Datasource#">
			SELECT Operator_ID as Payee_ID
			FROM Billback_Operator
			WHERE Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0
		</cfquery>
	</cfcase>

	<cfcase value="3"><!--- Broker --->
		<cfquery name="getPayeeID" datasource="#Application.Datasource#">
			SELECT Broker_ID as Payee_ID
			FROM Billback_Broker
			WHERE Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0
		</cfquery>
	</cfcase>
	
	<cfcase value="4"><!--- Other --->
		<cfquery name="getPayeeID" datasource="#Application.Datasource#">
			SELECT 	Associated_Ship_To as Payee_ID
			FROM 	Billback_Unidentified_Payee
			WHERE 	Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0
		</cfquery>
		<cfif getPayeeID.Payee_ID NEQ "">
			<cfset getPayeeInfo.Billback_Payee_Type_ID = 1 />
		</cfif>
	</cfcase>
</CFSWITCH>

<CFSET PayeeProgramIDList = "">
<CFIF len(trim(getPayeeInfo.Billback_Payee_Type_ID)) NEQ 0 AND len(trim(getPayeeID.Payee_ID))>
	<CFIF trim(getPayeeInfo.Billback_Payee_Type_ID) NEQ 0 AND trim(getPayeeID.Payee_ID) NEQ 0>
		<cfinclude template="build_PayeeProgramIDList.cfm">
	</CFIF>
</CFIF>
<cfset useLakebaseForqCheckSched = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqCheckSched>
	<cftry>
		<cfset qCheckSched = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "scheduled_auto_bb"
			}), "scheduled_auto_bb"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckSched = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckSched>
<cfquery name="qCheckSched" datasource="#Application.Datasource#" maxrows=1>
		SELECT	Scheduled_Auto_BB
		FROM	Billback
		WHERE 	Billback_ID = '#FORM.Billback_ID#'
</cfquery>
</cfif>

<CFIF len(trim(URL.BBID)) GT 0>
	<CFSET FORM.Billback_ID = URL.BBID>

	<cfset useLakebaseForLookForExistingProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForLookForExistingProgram>
	<cftry>
		<cfset LookForExistingProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"deleted" = "eq.0",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLookForExistingProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLookForExistingProgram>
<cfquery name="LookForExistingProgram" datasource="#Application.Datasource#" maxrows=1>
		SELECT	Program_ID
		FROM	Billback_Program
		WHERE 	Billback_ID = '#FORM.Billback_ID#' 
		AND		Deleted = 0
	</cfquery>
</cfif>
	<CFIF LookForExistingProgram.recordcount GT 0>
		<CFSET LoadBillbackID = FORM.Billback_ID>	
		<cfinclude template="load_billback_to_struct.cfm">
	</CFIF>
<cfelse>
	<CFSET URL.BBID = FORM.Billback_ID>
</CFIF>
</cfsilent>

<!--- If there aren't any programs, bring up the program search --->
<cfif LookForExistingProgram.recordcount LT 1>


<!---LookForExistingProgram.recordcount LT 1 --->
<cfelse>


<!--- Programs have been added --->
</cfif>
