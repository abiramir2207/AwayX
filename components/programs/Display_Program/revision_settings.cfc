<!--- revision settings on the control panel --->
<!--- The settings should take effect on a revision only --->
<cfcomponent hint="Revision Settings">

	<cffunction name="getRevisionSettings" access="public" returntype="query" output="false">

		<cfargument name="templateId" type="numeric" required="true" />
		<cfargument name="profilesID" type="numeric" required="true" />
		<cfargument name="ContractMainID" type="numeric" required="false" default="0"/>
		
		<cfset limitedRevise = 0>

		<!--- We are checking to see if this program is flagged as "Limited Revise" --->
		<cfquery name="checkPRG" datasource="#application.datasource#">
		SELECT Limited_Revise
		FROM Contract_Main
		WHERE Contract_Main_ID  = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfif checkPRG.Limited_Revise eq 1 AND arguments.ContractMainID>
			<cfset limitedRevise = 1>
		<cfelse>
			<!--- When a user clicks on "Revise" from the program summary page, we still want the "Limited Revise" logic to work on 
			the basic info page, i.e.when contract_main_id is 0.
			--->
			<cfif arguments.ContractMainID eq 0>
				<cfquery name="qry_GetProfile" datasource="#application.datasource#">
				SELECT Limited_Revise
				FROM Profiles_Settings
				WHERE Profiles_ID  = <cfqueryparam value="#arguments.profilesID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>

				<cfif qry_GetProfile.Limited_Revise eq 1>
					<cfset limitedRevise = 1>
				</cfif>
			</cfif>
		</cfif>
		
		<cfquery name="qGetRevisionSettings" datasource="#application.datasource#">
					<!---		D38941:: New Limited User Profile Edit Functionality
						Comment This Query and added Below Query
					SELECT 	*
					FROM 	Template_Revision_Settings
					WHERE 	Revision_Setting_Deleted = 0
					AND		Template_ID =  <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">
					--->

				IF OBJECT_ID('tempdb..##tmp_Revision_Settings') IS NOT NULL
				DROP TABLE ##tmp_Revision_Settings

				SELECT 	*, 1 AS Pay_To_Component
				INTO	##tmp_Revision_Settings
				FROM 	Template_Revision_Settings
				WHERE 	Revision_Setting_Deleted = 0
				AND		Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="CF_SQL_INTEGER">

				<!--- If this program is flagged as "Limited Revise"
				The logic is as follows:
				If the "revision" tab on the template for a particular setting is ON and the "Limited Revise" settings also has it ON, then it will be ON, else OFF.
				--->
				<cfif limitedRevise eq 1>
				UPDATE ##tmp_Revision_Settings
				SET 			Title_Changes = (CASE WHEN ((##tmp_Revision_Settings.Title_Changes = 1) AND (isnull(Limited_Revision_Settings.Title_Changes, 1) = 1)) THEN 1 ELSE 2 END),
							Date_Changes = (CASE WHEN ((##tmp_Revision_Settings.Date_Changes = 1) AND (isnull(Limited_Revision_Settings.Date_Changes, 1) = 1)) THEN 1 ELSE 2 END),
							Date_Changes_End = (CASE WHEN ((##tmp_Revision_Settings.Date_Changes_End = 1) AND (isnull(Limited_Revision_Settings.Date_Changes_End, 1) = 1)) THEN 1 ELSE 2 END),
							Start_Date_Change = (CASE WHEN ((##tmp_Revision_Settings.Start_Date_Change = 1) AND (isnull(Limited_Revision_Settings.Start_Date_Change, 1) = 1)) THEN 1 ELSE 2 END),
							End_Date_Change = (CASE WHEN ((##tmp_Revision_Settings.End_Date_Change = 1) AND (isnull(Limited_Revision_Settings.End_Date_Change, 1) = 1)) THEN 1 ELSE 2 END),
							Payment_Frequency_Changes = (CASE WHEN ((##tmp_Revision_Settings.Payment_Frequency_Changes = 1) AND (isnull(Limited_Revision_Settings.Payment_Frequency_Changes, 1) = 1)) THEN 1 ELSE 2 END),
							Require_Public_Notes_Changed = (CASE WHEN ((##tmp_Revision_Settings.Require_Public_Notes_Changed = 1) AND (isnull(Limited_Revision_Settings.Require_Public_Notes_Changed, 1) = 1)) THEN 1 ELSE 2 END),
							Require_Private_Notes_Changed = (CASE WHEN ((##tmp_Revision_Settings.Require_Private_Notes_Changed = 1) AND (isnull(Limited_Revision_Settings.Require_Private_Notes_Changed, 1) = 1)) THEN 1 ELSE 2 END),
							Products_Added = (CASE WHEN ((##tmp_Revision_Settings.Products_Added = 1) AND (isnull(Limited_Revision_Settings.Products_Added, 1) = 1)) THEN 1 ELSE 2 END),
							Products_Removed = (CASE WHEN ((##tmp_Revision_Settings.Products_Removed = 1) AND (isnull(Limited_Revision_Settings.Products_Removed, 1) = 1)) THEN 1 ELSE 2 END),
							Products_Rates_Changes = (CASE WHEN ((##tmp_Revision_Settings.Products_Rates_Changes = 1) AND (isnull(Limited_Revision_Settings.Products_Rates_Changes, 1) = 1)) THEN 1 ELSE 2 END),
							Products_UOM_Changes = (CASE WHEN ((##tmp_Revision_Settings.Products_UOM_Changes = 1) AND (isnull(Limited_Revision_Settings.Products_UOM_Changes, 1) = 1)) THEN 1 ELSE 2 END),
							Growth_Change_Target = (CASE WHEN ((##tmp_Revision_Settings.Growth_Change_Target = 1) AND (isnull(Limited_Revision_Settings.Growth_Change_Target, 1) = 1)) THEN 1 ELSE 2 END),
							Lump_Sum_Changed = (CASE WHEN ((##tmp_Revision_Settings.Lump_Sum_Changed = 1) AND (isnull(Limited_Revision_Settings.Lump_Sum_Changed, 1) = 1)) THEN 1 ELSE 2 END),
							Lump_Sum_Created = (CASE WHEN ((##tmp_Revision_Settings.Lump_Sum_Created = 1) AND (isnull(Limited_Revision_Settings.Lump_Sum_Created, 1) = 1)) THEN 1 ELSE 2 END),
							Lump_Sum_Removed = (CASE WHEN ((##tmp_Revision_Settings.Lump_Sum_Removed = 1) AND (isnull(Limited_Revision_Settings.Lump_Sum_Removed, 1) = 1)) THEN 1 ELSE 2 END),
							Pay_To_Component = (CASE WHEN ((##tmp_Revision_Settings.Pay_To_Component = 1) AND (isnull(Limited_Revision_Settings.Pay_To_Component, 1) = 1)) THEN 1 ELSE 2 END),
							Claim_Mechanic_Changed = (CASE WHEN ((##tmp_Revision_Settings.Claim_Mechanic_Changed = 1) AND (isnull(Limited_Revision_Settings.Claim_Mechanic_Changed, 1) = 1)) THEN 1 ELSE 2 END),
							Distributors_Added = (CASE WHEN ((##tmp_Revision_Settings.Distributors_Added = 1) AND (isnull(Limited_Revision_Settings.Distributors_Added, 1) = 1)) THEN 1 ELSE 2 END),
							Distributors_Removed = (CASE WHEN ((##tmp_Revision_Settings.Distributors_Removed = 1) AND (isnull(Limited_Revision_Settings.Distributors_Removed, 1) = 1)) THEN 1 ELSE 2 END),
							Operators_Added = (CASE WHEN ((##tmp_Revision_Settings.Operators_Added = 1) AND (isnull(Limited_Revision_Settings.Operators_Added, 1) = 1)) THEN 1 ELSE 2 END),
							Operators_Removed = (CASE WHEN ((##tmp_Revision_Settings.Operators_Removed = 1) AND (isnull(Limited_Revision_Settings.Operators_Removed, 1) = 1)) THEN 1 ELSE 2 END)
				FROM 		Limited_Revision_Settings
				WHERE 	DELETED = 0
				</cfif>

				SELECT *
				FROM ##tmp_Revision_Settings

		</cfquery>

		<cfreturn qGetRevisionSettings />

	</cffunction>


	<cffunction name="getRevisionStatus" access="public" returntype="query" output="false">

	<cfargument name="Program_ID" type="string" required="true" />

		<cfquery name="qgetRevisionStatus" datasource="#application.datasource#">
		SELECT
			Revision_Of_Contract_Main_ID,
			CASE WHEN IsExclusionRevision = 0 THEN Is_A_Revision ELSE 0 END As Is_A_Revision,
			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().DontRevise_Untill_SAP_OKack IS 1>
				CASE WHEN Approved =1
					THEN (CASE WHEN IsNull(Contract_Reference_Number, '') <> '' THEN Sent_To_External_Client ELSE 0 END)
					ELSE (CASE WHEN IsNull(Contract_Reference_Number, '') <> '' THEN Sent_To_External_Client ELSE 1 END)
				END As Client_Sent,
			<cfelse>
				1 As Client_Sent,
			</cfif>
			Contract_Reference_Number
		FROM Contract_Main
		WHERE Contract_Main_ID = '#arguments.Program_ID#'
		</cfquery>

	<cfreturn qgetRevisionStatus />
	</cffunction>

	<cffunction name="getRevisionInfo" access="public" returntype="query" output="false">

	<cfargument name="Program_ID" type="string" required="true" />

		<cfquery name="qgetRevisionInfo" datasource="#application.datasource#">
			SELECT	Contract_Main_Aux_Data.Comments,
					Contract_Main.Notes,
					Contract_Main.Contract_Start_Date,
					Contract_Main.Contract_Main_ID
			FROM 	Contract_Main
					INNER JOIN Contract_Main_Aux_Data ON
					Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
		WHERE 		Contract_Main.Contract_Main_ID = '#arguments.Program_ID#'
		</cfquery>

	<cfreturn qgetRevisionInfo />
	</cffunction>

	<cffunction name="setSpecialRevisionFlag" access="public" returntype="void" output="true">

		<cfargument name="programId" type="numeric" required="true" />

		<cfset RevisionStatus = getRevisionStatus(arguments.programId)>
		<cfif RevisionStatus.Is_A_Revision EQ 1  AND RevisionStatus.Contract_Reference_Number neq "">
			<!------ only if the parent is interfaced (Contract_Reference_Number has value) ----->

			<cfset bSpecialRevision = 0 />

			<!------ Set special revision = 1 if products added or removed ----->
			<cfset bSpecialRevision = bSpecialRevision + SpecialRevisionProductCheck(Parent_Contract_Main_ID = RevisionStatus.Revision_Of_Contract_Main_ID, Child_Contract_Main_ID = arguments.programId) />

			<!---TSF - Label 14073: Added component level check for special revision--->
			<cfif not bSpecialRevision>
				<cfset bSpecialRevision = bSpecialRevision + componentCheck(RevisionStatus.Revision_Of_Contract_Main_ID, arguments.programId, 1) />
			</cfif>

			<cfif bSpecialRevision>
				<!------ update the database ----->
				<cfquery name="qUpdateSpecialRevisionFlag" datasource="#application.datasource#">
					UPDATE	Contract_Main
					SET		Special_Revision = 1
					WHERE	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cfif>

		</cfif>

	</cffunction>


	<!------ Get Products Changed info ----->
	<cffunction name="SpecialRevisionProductCheck" output="false" returntype="numeric">
		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />

		<cfstoredproc procedure="PROGRAM_CHECK_PRODUCTS_CHANGED" datasource="#application.datasource#">

			<!--- cfprocparam tags --->
			<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@First_CMID" value="#arguments.Parent_Contract_Main_ID#" null="no">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@Second_CMID" value="#arguments.Child_Contract_Main_ID#" null="no">
			<cfprocparam type = "Out" CFSQLType ="CF_SQL_BIT" variable="Products_Changed" dbVarName = "@Products_Changed" null="no">
			<cfprocparam type = "Out" CFSQLType ="CF_SQL_VARCHAR" variable="Change_Message" dbVarName = "@Change_Message" null="no">

		</cfstoredproc>

		<cfreturn Products_Changed />
	</cffunction>

	<!------ Get Products Changed info ----->
	<cffunction name="ProductCheck" output="No" returntype="numeric">
		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />

		<cfset FlagSet = 0 >

		<cfset oReviseLog = CreateObject("component", "components.programs.ReviseLog").init() />

		<cfset qGetProductsChanged1 = oReviseLog.getProductsChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID, 0) />
		<cfset qGetProductsChanged2 = oReviseLog.getProductsChanged(arguments.Parent_Contract_Main_ID, arguments.Child_Contract_Main_ID, 1) />

		<cfif qGetProductsChanged1.recordCount OR qGetProductsChanged2.recordCount>
			<cfloop from="1" to="2" index="serialNum">
				<cfset qGetProductsChanged = Evaluate("qGetProductsChanged#serialNum#")>
					<cfquery name="qAnyDeleted" dbtype="query">
						Select 	*
						from 	qGetProductsChanged
						where	1=1
						<cfif (serialNum EQ 1)>	AND Deleted = 1	</cfif>
						<cfif (serialNum EQ 2)> AND Added = 1	</cfif>
					</cfquery> <!--- Query returns any if any Products were Deleted in the revision program --->
					<cfquery name="qAnyAdded" dbtype="query">
						Select 	*
						from 	qGetProductsChanged
						where	1=1
						<cfif (serialNum EQ 1)>	AND Added = 1	</cfif>
						<cfif (serialNum EQ 2)> AND Deleted = 1	</cfif>
					</cfquery> <!--- Query returns any if any Products were Added in the revision program --->
					<cfif qAnyAdded.Recordcount>
						<cfset FlagSet = 1 />
					</cfif>
					<cfif qAnyDeleted.Recordcount>
					 	<cfset FlagSet = 1 />
					</cfif>
			</cfloop>
		</cfif>

		<cfreturn FlagSet />
	</cffunction>

	<!------ Get Components Changed ----->
	<cffunction name="componentCheck" output="no" returntype="numeric">

		<cfargument name="parentContractMainID"	type="numeric" />
		<cfargument name="childContractMainID"	type="numeric" />
		<cfargument name="bJustAddedComps"		type="boolean" default="0">

		<cfset var bComponentChanged 	= "" />
		<cfset var revisionLogObject 	= "" />
		<cfset var parentProgramId 		= "" />
		<cfset var childProgramId 		= "" />
		<cfset var qGetComponentChanged = "" />
		<cfset var bCheckJustAddedComps	= 0 />

		<cfset bComponentChanged 	= 0 />
		<cfset revisionLogObject 	= CreateObject("component", "components.programs.ReviseLog").init() />
		<cfset parentProgramId 		= arguments.parentContractMainID />
		<cfset childProgramId 		= arguments.childContractMainID />
		<cfset bCheckJustAddedComps = arguments.bJustAddedComps />

		<cfset qGetComponentChanged = revisionLogObject.getcomponentchangedflag(childProgramId, parentProgramId, bCheckJustAddedComps) />

		<!---If any of the records returned from the getcomponentchangedflag() function equal 1 then set bComponentChanged to 1 --->
		<cfif qGetComponentChanged.rebatecompchanged eq 1 or qGetComponentChanged.fixedcompchanged eq 1 or qGetComponentChanged.growthcompchanged eq 1 or qGetComponentChanged.lumpcompchanged eq 1 or qGetComponentChanged.bidcompchanged eq 1>
			<cfset bComponentChanged = 1 />
		</cfif>

		<cfreturn bComponentChanged />

	</cffunction>

</cfcomponent>