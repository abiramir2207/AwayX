<!------ Revise_Type_Check.cfc ----->
<cfcomponent hint="Checks if the Revisions in the program are minor and what type">

	<!--- Please do not change the output to "false". It is needed for the Progress bar --->
	<cffunction name="MinorReviseFieldsCheck" output="true" returntype="any">

		<cfargument name="Parent_Contract_Main_ID" type="numeric" />
		<cfargument name="Child_Contract_Main_ID" type="numeric" />

		<cfset var_A = 0 /> <!--- Revision Type A --->
		<cfset var_B = 0 /> <!--- Revision Type B --->
		<cfset var_C = 0 /> <!--- Revision Type C --->
		<cfset var_Reg = 0 /><!--- Revision Type Regular Approval Routing Scheme --->

		<cfset this.qGetChangeLog = CreateObject("component", "components.programs.ReviseLog").init() />

		<cfset useLakebaseForGetRevisionSettingsData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("revision_settings")>
<cfif useLakebaseForGetRevisionSettingsData>
	<cftry>
		<cfset GetRevisionSettingsData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("revision_settings", {
				"revision_setting_deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetRevisionSettingsData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetRevisionSettingsData>
<CFQUERY NAME="GetRevisionSettingsData" DATASOURCE="#application.datasource#">
			SELECT		*
			FROM		Revision_Settings
			WHERE		Revision_Setting_Deleted = 0
		</CFQUERY>
</cfif>

		<!--- Resetting the Contract_Main_Aux_Data for RevisionTypes, generally useful during testing --->
		<cfset useLakebaseForResetRevisionTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForResetRevisionTypes>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main_aux_data",
			{
				"contract_main_id" = "eq.#arguments.Child_Contract_Main_ID#"
			},
			{
				"revisiontypea" = "0",
				"revisiontypeb" = "0",
				"revisiontypec" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForResetRevisionTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForResetRevisionTypes>
<CFQUERY NAME="ResetRevisionTypes" DATASOURCE="#application.datasource#">
				Update Contract_Main_Aux_Data
				SET		RevisionTypeA = 0,
						RevisionTypeB = 0,
						RevisionTypeC = 0
				WHERE 	Contract_Main_ID = #arguments.Child_Contract_Main_ID#
		</CFQUERY>
</cfif>

		<!--- Inserting an empty record into Program_Revision_Changes table to mark what parameters in a program have changed --->
		<cfquery name="qInsertRevisionChanges" datasource="#application.datasource#">
				Update	Program_Revision_Changes
				SET 	Deleted_On = getdate(),
				 		Deleted	= 1
				WHERE 	Contract_Main_ID = '#arguments.Child_Contract_Main_ID#'
				AND		Deleted	= 0
				Insert Into Program_Revision_Changes
				(Contract_Main_ID)
				Values	(#arguments.Child_Contract_Main_ID#)
		</cfquery>

		<cfset FieldsArray = ArrayNew(1) />
		<cfset ArrayAppend(FieldsArray,  "OperatorCheck") />
		<cfset ArrayAppend(FieldsArray,  "DistributorCheck") />
		<!--- Dev Note: KAL; D17007: Shortcut Routing:
			When the fixed price equal to Price list setting is on then we need to skip the additions to fixed price from the regular product changes check.
			When a fixed price product is removed it should still be captured by ProductCheck even if the the fixed eq pricelist setting is on and product removed setting is on.
			Make the check for the fixed prices eq price list seperately.
		--->
		<cfset ArrayAppend(FieldsArray,  "ProductCheck") />
		<cfif GetRevisionSettingsData.Prod_Add_FixedEqPricelist_Approval eq 1>
			<!--- Make the check for the fixed prices eq price list seperately. --->
			<cfset ArrayAppend(FieldsArray,  "ProductCheckFixedEqPricelist") />
		</cfif>
		<cfset ArrayAppend(FieldsArray,  "ProductRateUOMCheck") />
		<cfset ArrayAppend(FieldsArray,  "programDurationCheck") />



		<!--- Get the total entries of the list of fields. I need the TotalCount to know the progress of the Shortcut Routing. --->
		<cfset TotalCount = ArrayLen(FieldsArray) />

		<cfloop index="Count" from="1" to="#ArrayLen(FieldsArray)#">
			<cfset FieldRevised		= evaluate("this.#FieldsArray[count]#(arguments.Parent_Contract_Main_ID, arguments.Child_Contract_Main_ID, GetRevisionSettingsData)" ) />
			<cfif FieldRevised EQ 4>	<cfset var_C = var_C +1 /> 		</cfif>
			<cfif FieldRevised EQ 3>	<cfset var_B = var_B +1 /> 		</cfif>
			<cfif FieldRevised EQ 2>	<cfset var_A = var_A +1 /> 		</cfif>
			<cfif FieldRevised EQ 1>	<cfset var_Reg = var_Reg +1 /> 	</cfif>

			<!--- Progress bar --->
			<cfset LastPercent = 0>
				<!--- This will return values of 1 through 10 (1 being 10%, 2 being 20%....10 being 100%) --->
				<cfset PercentDone = Int(Ceiling((Count/TotalCount) * 100)/10)>

				<!--- Show the Image based on product count --->
				<cfif LastPercent neq PercentDone>
					<cfset Block = "Block" & PercentDone>
<!--- 						<cfinclude template="/includes/show_progress_bar.cfm"> --->
					<cfset LastPercent = PercentDone>
				</cfif>
		 </cfloop>

		<!--- Other Fields : Call FieldNamesArray function to get the list of other fields to check for change --->
		<cfset OtherFieldsArray = this.FieldNamesArray(arguments.Child_Contract_Main_ID) />

		<!--- Get the total entries of the list of fields. I need the TotalCount to know the progress of the Shortcut Routing. --->
		<cfset TotalCount = ArrayLen(FieldsArray) + ArrayLen(OtherFieldsArray)>

		<cfloop index="Count" from="1" to="#ArrayLen(OtherFieldsArray)#">
			<cfset OthersRevised		= this.OthersCheck(arguments.Parent_Contract_Main_ID, arguments.Child_Contract_Main_ID, GetRevisionSettingsData, "#OtherFieldsArray[Count][1]#", "#OtherFieldsArray[Count][2]#", "#OtherFieldsArray[Count][3]#" ) />
			<cfif OthersRevised EQ 4>	<cfset var_C = var_C +1 /> 		</cfif>
			<cfif OthersRevised EQ 3>	<cfset var_B = var_B +1 /> 		</cfif>
			<cfif OthersRevised EQ 2>	<cfset var_A = var_A +1 /> 		</cfif>
			<cfif OthersRevised EQ 1>	<cfset var_Reg = var_Reg +1 /> 	</cfif>

			<!--- Progress bar --->
			<cfset LastPercent = 0>
			<!--- This will return values of 1 through 10 (1 being 10%, 2 being 20%....10 being 100%). I am adding
				  ArrayLen(FieldsArray) to the count because that much [ArrayLen(FieldsArray)] progress has already been made
				  in the previous loop.
			--->
			<cfset PercentDone = Int(Ceiling(((Count + ArrayLen(FieldsArray))/TotalCount) * 100)/10)>

			<!--- Show the Image based on product count --->
			<cfif LastPercent neq PercentDone>
				<cfset Block = "Block" & PercentDone>
<!--- 					<cfinclude template="/includes/show_progress_bar.cfm"> --->
				<cfset LastPercent = PercentDone>
			</cfif>
		</cfloop>

		<!--- Dev Note: KAL; D17007: Shortcut Routing: Freight Changes
			When the revision settings for freight is turned on and no other changes but just freight changes
			Then set Freight_Approval_Only = 1 flag in Program_Revision_Changes
			Use this flag in the routine Check_program_revision_approval_settings copy over all the approvals
		--->
		<cfset freightApprovalRequired = 0 />
		<cfif GetRevisionSettingsData.Freight_Change_Approval eq 1>
			<cfif var_A EQ 0 and var_B EQ 0 and var_C EQ 0 and var_Reg EQ 0>
				<cfquery name="qFreightApproval" datasource="#application.datasource#">
					SELECT	ProgramType_ID, Freight_Approval_Required, Freight_Approved, Freight_Component_Type
					FROM 	Contract_Main CM
					INNER JOIN 	Contract_Main_Aux_Data CMAD ON CMAD.Contract_Main_ID = CM.Contract_Main_ID
					INNER JOIN 	Program_Control_Panel_Options PCPO ON PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
					WHERE 	CM.Contract_Main_ID = <cfqueryparam value="#arguments.Child_Contract_Main_ID#" cfsqltype="cf_sql_integer" />
				</cfquery>

				<cfif qFreightApproval.Freight_Approval_Required eq 1 AND qFreightApproval.Freight_Approved eq 0 AND (qFreightApproval.Freight_Component_Type eq 1 OR qFreightApproval.Freight_Component_Type eq 4)>
					<cfquery name="qFreightApprovalOnly" datasource="#application.datasource#">
						Update	Program_Revision_Changes
						SET 	Freight_Approval_Only = 1
						WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.Child_Contract_Main_ID#" cfsqltype="cf_sql_integer">
						AND		Deleted	= 0
					</cfquery>
					<cfset freightApprovalRequired = 1 />
				</cfif>
			</cfif>
		</cfif>

		<!--- 	D32785: Shortcut Approval 1010127
				If there are no changes in the program, set the No_Change flag
				Do not set No_Change flag if there are no changes, but freight approval is required
		 --->
		<cfif var_A EQ 0 and var_B EQ 0 and var_C EQ 0 and var_Reg EQ 0 and freightApprovalRequired EQ 0>
			<cfset FlagSet = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "No_Change", GetRevisionSettingsData.No_Changes_Approval_Type) />
			<cfif GetRevisionSettingsData.No_Changes_Approval eq 1>
				<cfif GetRevisionSettingsData.No_Changes_Approval_Type eq 1>		<!--- A --->
					<cfset var_A = var_A + 1 />
				<cfelseif GetRevisionSettingsData.No_Changes_Approval_Type eq 2>	<!--- B --->
					<cfset var_B = var_B + 1 />
				<cfelseif GetRevisionSettingsData.No_Changes_Approval_Type eq 3>	<!--- C --->
					<cfset var_C = var_C + 1 />
				</cfif>
			</cfif>
		</cfif>

		<cfif var_C GT 0>	<cfset FlagSet = this.qGetChangeLog.MinorReviseFlagSet(arguments.Child_Contract_Main_ID, 4) />	</cfif>
		<cfif var_B GT 0>	<cfset FlagSet = this.qGetChangeLog.MinorReviseFlagSet(arguments.Child_Contract_Main_ID, 3) />	</cfif>
		<cfif var_A GT 0>	<cfset FlagSet = this.qGetChangeLog.MinorReviseFlagSet(arguments.Child_Contract_Main_ID, 2) />	</cfif>
		<cfif var_Reg GT 0>	<cfset FlagSet = this.qGetChangeLog.MinorReviseFlagSet(arguments.Child_Contract_Main_ID, 1) />	</cfif> <!--- This should be set last ie after the other 3 --->


		<!--- Shortcut routing is complete --->
        <!---
		<script language="javascript">
		 document.Block10.src = '/images/red_block.gif';
		 document.getElementById('ShowPercentProgress').innerHTML = '100%';
		</script>

        <cfflush> --->
		<cfreturn FlagSet />
	</cffunction>

	<!------ Get operator info ----->
	<cffunction name="OperatorCheck" output="No" returntype="numeric">
		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />
		<cfargument name="GetRevisionSettingsData"	type="query" />

		<cfset FlagSet = 0 >
		<!--- D36904 : Program 1001677 not routing to Area Director START --->
		<cfset FlagSetAdded = 0 >
		<cfset FlagSetRemoved = 0 >
		<!--- D36904 : Program 1001677 not routing to Area Director END --->
			<cfset qGetOperator1 = this.qGetChangeLog.getOperatorsChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID, 0) />
			<cfset qGetOperator2 = this.qGetChangeLog.getOperatorsChanged(arguments.Parent_Contract_Main_ID, arguments.Child_Contract_Main_ID, 1) />

			<cfif qGetOperator1.recordCount OR qGetOperator2.recordCount>
				<cfloop from="1" to="2" index="serialNum">
					<cfset qGetOperator = Evaluate("qGetOperator#serialNum#")>
						<cfquery name="qAnyDeleted" dbtype="query">
							Select 	*
							from 	qGetOperator
							where	1=1
							<cfif (serialNum EQ 1)>	AND Deleted = 1	</cfif>
							<cfif (serialNum EQ 2)> AND Added = 1	</cfif>
						</cfquery> <!--- Query returns any if any operators were Deleted in the revision program --->
						<cfquery name="qAnyAdded" dbtype="query">
							Select 	*
							from 	qGetOperator
							where	1=1
							<cfif (serialNum EQ 1)>	AND Added = 1	</cfif>
							<cfif (serialNum EQ 2)> AND Deleted = 1	</cfif>
						</cfquery> <!--- Query returns any if any operators were Added in the revision program --->
						<cfif qAnyAdded.Recordcount>
							<cfset RevisionType = arguments.GetRevisionSettingsData.Operators_Added_Approval_Type />
							<!--- D36904 : Program 1001677 not routing to Area Director --->
							<cfset FlagSetAdded = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Operators_Added", RevisionType ) />
						</cfif>
						<cfif qAnyDeleted.Recordcount>
						 	<cfset RevisionType = arguments.GetRevisionSettingsData.Operators_Removed_Approval_Type />
							 <!--- D36904 : Program 1001677 not routing to Area Director --->
							<cfset FlagSetRemoved = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Operators_Removed", RevisionType ) />
						</cfif>
				</cfloop>
			</cfif>
			<!--- D51007	Program not short cut routing when distributor is added START --->
			<cfif FlagSetAdded EQ 0>
			<!--- If no Operator is added, look at the remove flag ---->
				<cfset FlagSet = FlagSetRemoved />
			<cfelseif FlagSetRemoved EQ 0>
			<!--- If no Operator is remove, look at the add flag ---->
				<cfset FlagSet = FlagSetAdded />
			<cfelse>
			<!--- Operator is added added and removed ---->
				<cfset FlagSet = min(FlagSetAdded, FlagSetRemoved)>
			</cfif>
			<!--- D51007	Program not short cut routing when distributor is added END --->
		<cfreturn FlagSet />
	</cffunction>

	<!------ Get Distributor info ----->
	<cffunction name="DistributorCheck" output="No" returntype="numeric">
		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />
		<cfargument name="GetRevisionSettingsData"	type="query" />

		<cfset FlagSet = 0 >
		<!--- D36904 : Program 1001677 not routing to Area Director START --->
		<cfset FlagSetAdded = 0 >
		<cfset FlagSetRemoved = 0 >
		<!--- D36904 : Program 1001677 not routing to Area Director END --->
			<cfset qGetDistributor1 = this.qGetChangeLog.getDistributorsChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID, 0) />
			<cfset qGetDistributor2 = this.qGetChangeLog.getDistributorsChanged(arguments.Parent_Contract_Main_ID, arguments.Child_Contract_Main_ID, 1) />

			<cfif qGetDistributor1.recordCount OR qGetDistributor2.recordCount>
				<cfloop from="1" to="2" index="serialNum">
					<cfset qGetDistributor = Evaluate("qGetDistributor#serialNum#")>
						<cfquery name="qAnyDeleted" dbtype="query">
							Select 	*
							from 	qGetDistributor
							where	1=1
							<cfif (serialNum EQ 1)>	AND Deleted = 1	</cfif>
							<cfif (serialNum EQ 2)> AND Added = 1	</cfif>
						</cfquery> <!--- Query returns any if any Distributors were Deleted in the revision program --->
						<cfquery name="qAnyAdded" dbtype="query">
							Select 	*
							from 	qGetDistributor
							where	1=1
							<cfif (serialNum EQ 1)>	AND Added = 1	</cfif>
							<cfif (serialNum EQ 2)> AND Deleted = 1	</cfif>
						</cfquery> <!--- Query returns any if any Distributors were Added in the revision program --->
						<cfif qAnyAdded.Recordcount>
							<cfset RevisionType = arguments.GetRevisionSettingsData.Distributors_Added_Approval_Type />
							<!--- D36904 : Program 1001677 not routing to Area Director --->
							<cfset FlagSetAdded = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Distributors_Added", RevisionType ) />
						</cfif>
						<cfif qAnyDeleted.Recordcount>
						 	<cfset RevisionType = arguments.GetRevisionSettingsData.Distributors_Removed_Approval_Type />
							 <!--- D36904 : Program 1001677 not routing to Area Director --->
							<cfset FlagSetRemoved = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Distributors_Removed", RevisionType ) />
						</cfif>
				</cfloop>
			</cfif>
			<!--- D51007	Program not short cut routing when distributor is added START --->
			<cfif FlagSetAdded EQ 0>
			<!--- If no distributor is added, look at the remove flag ---->
				<cfset FlagSet = FlagSetRemoved />
			<cfelseif FlagSetRemoved EQ 0>
			<!--- If no distributor is remove, look at the add flag ---->
				<cfset FlagSet = FlagSetAdded />
			<cfelse>
			<!--- Distributor is added added and removed ---->
				<cfset FlagSet = min(FlagSetAdded, FlagSetRemoved)>
			</cfif>
			<!--- D51007	Program not short cut routing when distributor is added END --->
		<cfreturn FlagSet />
	</cffunction>

	<!------ Get Products Changed info ----->
	<cffunction name="ProductCheck" output="No" returntype="numeric">
		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />
		<cfargument name="GetRevisionSettingsData"	type="query" />

		<cfset FlagSet = 0 >
		<!--- D36904 : Program 1001677 not routing to Area Director START--->
		<cfset FlagSetAdded = 0 >
		<cfset FlagSetRemoved = 0 >
		<!--- D36904 : Program 1001677 not routing to Area Director END--->

			<cfset qGetProductsChanged1 = this.qGetChangeLog.getProductsChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID, 0) />
			<cfset qGetProductsChanged2 = this.qGetChangeLog.getProductsChanged(arguments.Parent_Contract_Main_ID, arguments.Child_Contract_Main_ID, 1) />

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
							<!--- Dev Note: KAL; D17007: 5.1 Shortcut Changes: - Ignore the Fixed price products added;
								- They will checked in ProductCheckFixedEqPricelist; - We still need to check for deleted products --->
							<cfif GetRevisionSettingsData.Prod_Add_FixedEqPricelist_Approval eq 1> AND Product_Type_ID <> 1 </cfif>
						</cfquery> <!--- Query returns any if any Products were Added in the revision program --->
						<cfif qAnyAdded.Recordcount>
								<cfset RevisionType = arguments.GetRevisionSettingsData.Products_Added_Approval_Type />
							<!--- D36904 : Program 1001677 not routing to Area Director --->
								<cfset FlagSetAdded = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Products_Added", RevisionType ) />
						</cfif>
						<cfif qAnyDeleted.Recordcount>
						 	<cfset RevisionType = arguments.GetRevisionSettingsData.Products_Removed_Approval_Type />
							<!--- D36904 : Program 1001677 not routing to Area Director --->
							<cfset FlagSetRemoved = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Products_Removed", RevisionType ) />
						</cfif>
				</cfloop>
			</cfif>
			<!--- D51007	Program not short cut routing when distributor is added START --->
			<cfif FlagSetAdded EQ 0>
			<!--- If no Products is added, look at the remove flag ---->
				<cfset FlagSet = FlagSetRemoved />
			<cfelseif FlagSetRemoved EQ 0>
			<!--- If no Products is remove, look at the add flag ---->
				<cfset FlagSet = FlagSetAdded />
			<cfelse>
			<!--- Products is added added and removed ---->
				<cfset FlagSet = min(FlagSetAdded, FlagSetRemoved)>
			</cfif>
			<!--- D51007	Program not short cut routing when distributor is added END --->
		<cfreturn FlagSet />
	</cffunction>

 	<!--- Dev Note: KAL; D17007: 5.1 Shortcut Routing Changes: Check if Fixed Price products were added at Pricelist Price, if yes return the string and based on that set the revision type --->
	<!------ Get Only Fixed Price Products added at List Price info ----->
	<cffunction name="ProductCheckFixedEqPricelist" output="No" returntype="numeric">
		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />
		<cfargument name="GetRevisionSettingsData"	type="query" />

		<cfset FlagSet = 0 >
	 	<cfset RevisionType = arguments.GetRevisionSettingsData.Prod_Add_FixedEqPricelist_Approval_Type />
		<cfset sProductsAddedFixedEqPricelist = this.qGetChangeLog.getProductsAddedFixedEqPricelist(arguments.Parent_Contract_Main_ID, arguments.Child_Contract_Main_ID) />

 		<cfif lcase(sProductsAddedFixedEqPricelist) eq lcase("FPnotLP")>
			<!---	If products were added to Fixed Price and price wasnt equal to price list then its not a shortcut routing.
				 	so set revision type = 1, we send 0, so it will be incremented in the function --->
			<cfset FlagSet = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Products_Added_FixedEqPricelist") />
		<cfelseif lcase(sProductsAddedFixedEqPricelist) eq lcase("FPeqLP")>
			<cfset FlagSet = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Products_Added_FixedEqPricelist", RevisionType) />
		</cfif>

		<cfreturn FlagSet />
	</cffunction>

	<!------ Get Products UOM info ----->
	 <cffunction name="ProductRateUOMCheck" output="No" returntype="numeric">
		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />
		<cfargument name="GetRevisionSettingsData"	type="query" />

			<cfset FlagSet = 0 >
		<!--- D36904 : Program 1001677 not routing to Area Director START--->
		<cfset FlagSetIncrease = 0 >
		<cfset FlagSetDecrease = 0 >
		<!--- D36904 : Program 1001677 not routing to Area Director END--->

		 	<cfset getcomponentchangedflag = this.qGetChangeLog.getcomponentchangedflag(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID) />
			<cfset qGetFixedProductsRatesChanged = this.qGetChangeLog.GetFixedProductsRatesUOMChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID, 0) />
			<cfset qGetRebateProductsRatesChanged = this.qGetChangeLog.GetRebateProductsRatesUOMChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID, 0) />
			<cfset qGetLumpsumRatesChanged =  this.qGetChangeLog.getLumpChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID) />

			<cfset rates_changed = 0>
			<cfset UOMs_changed = 0>
			<cfset ClaimMechs_Changed = 0>

			<!--- D34880: Max Rate Easy Button and Short Cut Routing--->
				<cfset rates_change_increase = 0>
				<cfset rates_change_decrease = 0>
			<!--- D34880: Max Rate Easy Button and Short Cut Routing--->

				<!--- D34880: Max Rate Easy Button and Short Cut Routing--->
				<cfquery name="qRateChangedDecrease" dbtype="query">
							Select 	Rate1 ,  Rate2
							from 		qGetRebateProductsRatesChanged
							where  	Rate1 <  Rate2
							UNION
							Select 	Rate1 ,  Rate2
							from 		qGetFixedProductsRatesChanged
							where  	Rate2 <  Rate1<!---Fixed price Increase, Allowance Decrease --->
							UNION
							Select 	Rate1 ,  Rate2
							from 		qGetLumpsumRatesChanged
							where  	Rate2 >  Rate1
				</cfquery>
				<cfif qRateChangedDecrease.recordcount GT 0>
					<cfset rates_change_decrease = rates_change_decrease + 1>
				</cfif>
				<cfquery name="qRateChangedIncrease" dbtype="query">
							Select 	Rate1 ,  Rate2
							from 		qGetRebateProductsRatesChanged
							where   	Rate2 <  Rate1
							UNION
							Select 	Rate1 ,  Rate2
							from 		qGetFixedProductsRatesChanged
							where   	Rate1 <  Rate2<!---Allowance Increase, Fixed price Decrease --->
							UNION
							Select 	Rate1 ,   Rate2
							from 		qGetLumpsumRatesChanged
							where  	Rate1 >  Rate2
				</cfquery>
				<cfif qRateChangedIncrease.recordcount GT 0>
					<cfset rates_change_increase = rates_change_increase + 1>
				</cfif>
				<!--- D34880: Max Rate Easy Button and Short Cut Routing--->


			<cfif qGetFixedProductsRatesChanged.recordCount GT 0>


				<cfset useLakebaseForqAnyRateChanged = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetfixedproductsrateschanged")>
<cfif useLakebaseForqAnyRateChanged>
	<cftry>
		<cfset qAnyRateChanged = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetfixedproductsrateschanged", {
				"rate_change" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqAnyRateChanged = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAnyRateChanged>
<cfquery name="qAnyRateChanged" dbtype="query">
							Select 	*
							from 	qGetFixedProductsRatesChanged
							where 	Rate_Change = 1
				</cfquery>
</cfif>
				<cfif qAnyRateChanged.recordcount GT 0>
					<cfset rates_changed = rates_changed + 1>
				</cfif>
				<cfset useLakebaseForqAnyUOMChanged = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetfixedproductsrateschanged")>
<cfif useLakebaseForqAnyUOMChanged>
	<cftry>
		<cfset qAnyUOMChanged = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetfixedproductsrateschanged", {
				"uom_change" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqAnyUOMChanged = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAnyUOMChanged>
<cfquery name="qAnyUOMChanged" dbtype="query">
							Select 	*
							from 	qGetFixedProductsRatesChanged
							where 	Uom_Change = 1
				</cfquery>
</cfif>
				<cfif qAnyUOMChanged.recordcount GT 0>
					<cfset UOMs_changed = UOMs_changed + 1>
				</cfif>
				<cfset useLakebaseForqAnyClaimMechChanged = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetfixedproductsrateschanged")>
<cfif useLakebaseForqAnyClaimMechChanged>
	<cftry>
		<cfset qAnyClaimMechChanged = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetfixedproductsrateschanged", {
				"claimmech_changed" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqAnyClaimMechChanged = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAnyClaimMechChanged>
<cfquery name="qAnyClaimMechChanged" dbtype="query">
							Select 	*
							from 	qGetFixedProductsRatesChanged
							where 	ClaimMech_Changed = 1
				</cfquery>
</cfif>
				<cfif qAnyClaimMechChanged.recordcount GT 0>
					<cfset ClaimMechs_Changed = ClaimMechs_Changed + 1>
				</cfif>
			</cfif>
			<cfif qGetRebateProductsRatesChanged.recordCount GT 0>

				<cfquery name="qAnyRateChanged" dbtype="query">
							Select 	*
							from 	qGetRebateProductsRatesChanged
							where Rate_Change = 1
				</cfquery>
				<cfif qAnyRateChanged.recordcount GT 0>
				<cfset rates_changed = rates_changed + 1>
				</cfif>
				<cfquery name="qAnyUOMChanged" dbtype="query">
							Select 	*
							from 	qGetRebateProductsRatesChanged
							where Uom_Change = 1
				</cfquery>
				<cfif qAnyUOMChanged.recordcount GT 0>
				<cfset UOMs_changed = UOMs_changed + 1>
				</cfif>
			</cfif>
			<!--- D34880: Max Rate Easy Button and Short Cut Routing
			<cfif qGetLumpsumRatesChanged.recordCount GT 0>--->
			<cfif qGetLumpsumRatesChanged.Rate1 NEQ qGetLumpsumRatesChanged.Rate2>
				<cfset rates_changed = rates_changed + 1>
			</cfif>
			<cfif 	getcomponentchangedflag.rebatecompchanged EQ 1 OR
					getcomponentchangedflag.fixedcompchanged EQ 1 OR
					getcomponentchangedflag.growthcompchanged EQ 1 OR
					getcomponentchangedflag.lumpcompchanged EQ 1 OR
					getcomponentchangedflag.bidcompchanged EQ 1>
				<cfset CompChanged = 1>
			<cfelse>
				<cfset CompChanged = 0>
			</cfif>

			<cfif rates_changed GT 0 OR UOMs_changed GT 0 OR CompChanged GT 0 OR ClaimMechs_Changed GT 0>
				<cfif rates_changed GT 0 OR CompChanged GT 0>
					<cfset RevisionType = arguments.GetRevisionSettingsData.Products_Rates_Changes_Approval_Type />
					<cfset FlagSet = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Products_Rates_Changed", RevisionType ) />
				</cfif>
				<cfif UOMs_changed GT 0>
					<cfset RevisionType = arguments.GetRevisionSettingsData.Products_UOM_Changes_Approval_Type />
					<cfset FlagSet = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Products_UOM_Changed", RevisionType ) />
				</cfif>
				<cfif ClaimMechs_Changed GT 0>
					<cfset RevisionType = arguments.GetRevisionSettingsData.Component_ClaimMech_Change_Approval_Type />
					<cfset FlagSet = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Component_ClaimMech_Changed", RevisionType ) />
				</cfif>
				<!--- D34880: Max Rate Easy Button and Short Cut Routing--->
				<cfif rates_change_increase>
					<cfset RevisionType = arguments.GetRevisionSettingsData.Products_Rates_Changes_Approval_Type />
					<cfset FlagSetIncrease = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Products_Rates_Increase", RevisionType ) />
					<cfset FlagSet = FlagSetIncrease>
				</cfif>

				<cfif rates_change_decrease>
					<cfset RevisionType = arguments.GetRevisionSettingsData.Products_Rates_Decreased_Approval_Type />
					<cfset FlagSetDecrease = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Products_Rates_Decrease", RevisionType ) />
					<cfset FlagSet = FlagSetDecrease>
				</cfif>
				<!--- D34880: Max Rate Easy Button and Short Cut Routing--->

	<!--- D36904 : Program 1001677 not routing to Area Director START--->
		<cfif (FlagSetDecrease NEQ 0) AND (FlagSetIncrease NEQ 0)>
			<cfset FlagSet = min(FlagSetIncrease, FlagSetDecrease)>
		</cfif>
	<!--- D36904 : Program 1001677 not routing to Area Director END--->


			</cfif>

		<cfreturn FlagSet />
	</cffunction>

	<!------ Get Volume Changed info ----->
	<cffunction name="VolumeCheck" output="No" returntype="numeric">
		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />

		<cfset FieldChanged = 1 />	<!--- By defalut assuming field has changed, if not after comparission, then this is set to 0--->

		<CFQUERY NAME="geGetParentProgramInfo" datasource="#application.datasource#">
			SELECT	DateDiff(d, Contract_Start_Date, Contract_End_Date) + 1 as Program_Span
			FROM	Contract_Main
			WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Parent_Contract_Main_ID#" />
		</CFQUERY>

		<CFQUERY NAME="geGetChildProgramInfo" datasource="#application.datasource#">
			SELECT	DateDiff(d, Contract_Start_Date, Contract_End_Date) + 1 as Program_Span
			FROM	Contract_Main
			WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Child_Contract_Main_ID#" />
		</CFQUERY>

		<cfset useLakebaseForGet_Settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForGet_Settings>
	<cftry>
		<cfset Get_Settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#request.AccessStructure.Company_Main_ID#",
				"select" = "volume_uot_id"
			}), "volume_uot_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Settings>
<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
			Select	Volume_UOT_ID
			From	_Users_Settings
			Where	User_ID = '#request.AccessStructure.Company_Main_ID#'
		</CFQUERY>
</cfif>

		<cfset ParentVolQty = CreateObject("component", "components.programs.volume.ProgramVolume").getProgramQty(arguments.Parent_Contract_Main_ID, geGetParentProgramInfo.Program_Span, Get_Settings.Volume_UOT_ID) />
		<cfset ChildVolQty 	= CreateObject("component", "components.programs.volume.ProgramVolume").getProgramQty(arguments.Child_Contract_Main_ID, geGetChildProgramInfo.Program_Span, Get_Settings.Volume_UOT_ID) />

		<cfif application.appSettingsGet.getViewProgramVolumeUOM() EQ 2>
			<cfset Parent_Contract_Quantity = round(ParentVolQty.ProgramQtglbs) />
			<cfset Child_Contract_Quantity = round(ChildVolQty.ProgramQtglbs) />
		<cfelse>
			<cfset Parent_Contract_Quantity = round(ParentVolQty.ProgramQtgCases) />
			<cfset Child_Contract_Quantity = round(ChildVolQty.ProgramQtgCases) />
		</cfif>

		<cfif Parent_Contract_Quantity EQ Child_Contract_Quantity>
			<cfset FieldChanged = 0 />
		</cfif>

		<cfreturn FieldChanged />
	</cffunction>

	<!------ Get Other Changed info ----->
	<cffunction name="OthersCheck" output="No" returntype="numeric">

		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />
		<cfargument name="GetRevisionSettingsData"	type="query" />
		<cfargument name="FieldNameToPass"		type="string" />	<!--- Field name to check for value change in contract_main --->
		<cfargument name="FieldSettingToGet"	type="string" />	<!--- Filed name in the Revision_Settings table to check if its a minor change/requires approval --->
		<cfargument name="FieldNameToSet"		type="string" />	<!--- Filed name in Program_Revision_Changes table to hold the value if its been changed and what type --->

		 	<!--- D32785: Shortcut Approval 1010127
		 	The short cut routing should no longer look at field contract quantity as that field is removed from the Basic Info page.
		 	Instead we should update short cut routing, so it looks at the volume from the Edit Volume page
		 	--->
			<cfif arguments.FieldNameToPass eq "Contract_Quantity">
				<cfset GetFieldChanged = this.VolumeCheck(arguments.Parent_Contract_Main_ID, arguments.Child_Contract_Main_ID) />
			<cfelse>
				<cfset GetFieldChanged = this.qGetChangeLog.getFieldValueChanged(arguments.Parent_Contract_Main_ID, arguments.Child_Contract_Main_ID, arguments.FieldNameToPass) />
			</cfif>

			<cfset RevisionType = 0 />	<!--- The type of revision flag to set, if there is a change, this value is modified below --->
			<cfset FlagSet = 0 >
			 <!--- Field Value has changed then Returned value is 1 --->
			 <cfif GetFieldChanged EQ 1>
			 	<cfif evaluate("arguments.GetRevisionSettingsData.#arguments.FieldSettingToGet#") EQ 1 > <!--- If a minor change value is 1 --->
					<cfset RevisionType = evaluate("arguments.GetRevisionSettingsData.#arguments.FieldSettingToGet#_Type") /> <!--- Get the type of revision - A,B,C --->
				</cfif>

				<cfset FlagSet = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, arguments.FieldNameToSet, RevisionType ) />
				<!--- RevisionType is incremented in the function RevisionChangesFlags, so if RevisionType = 0 then it is 1 and so on --->
			 </cfif>
		<cfreturn FlagSet />

	</cffunction>

	<!--- Function to return the fieldnames to check if they have changed. This array is passed to the OthersCheck function --->
	<cffunction name="FieldNamesArray" output="No" returntype="array">
	<cfargument name="Child_Contract_Main_ID"	type="numeric" />
		<cfset FieldNames = ArrayNew(2) />

			<cfset arlen = 1 />
			<cfset FieldNames[arlen][1] = "Contract_Start_Date" />
			<cfset FieldNames[arlen][2] = "Start_Date_Change_Approval" />
			<cfset FieldNames[arlen][3] = "Start_Date_Changed" />

			<cfset arlen = arlen + 1 />
			<cfset FieldNames[arlen][1] = "Contract_End_Date" />
			<cfset FieldNames[arlen][2] = "End_Date_Change_Approval" />
			<cfset FieldNames[arlen][3] = "End_Date_Changed" />

			<cfset arlen = arlen + 1 />
			<cfset FieldNames[arlen][1] = "Contract_Title" />			<!--- Field name to check for value change in contract_main --->
			<cfset FieldNames[arlen][2] = "Title_Changes_Approval" />	<!--- Filed name in the Revision_Settings table to check if its a minor change/requires approval --->
			<cfset FieldNames[arlen][3] = "Title_Changed" />			<!--- Filed name in Program_Revision_Changes table to hold the value if its been cahnged and what type --->
		<cfset useLakebaseForcheckifproductsadded = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_revision_changes")>
<cfif useLakebaseForcheckifproductsadded>
	<cftry>
		<cfset checkifproductsadded = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_revision_changes", {
				"contract_main_id" = "eq.#arguments.Child_Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "products_added"
			}), "products_added"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckifproductsadded = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckifproductsadded>
<cfquery name="checkifproductsadded" datasource="#application.datasource#">
			SELECT 	Products_Added
			FROM 	Program_Revision_Changes
			WHERE 	Contract_Main_ID = #arguments.Child_Contract_Main_ID#
			AND		Deleted = 0
		</cfquery>
</cfif>
		<cfif checkifproductsadded.Products_Added EQ 0>
			<cfset arlen = arlen + 1 />
			<cfset FieldNames[arlen][1] = "Contract_Quantity" />				<!--- Field name to check for value change in contract_main --->
			<cfset FieldNames[arlen][2] = "Other_Program_Changes_Approval" />	<!--- Filed name in the Revision_Settings table to check if its a minor change/requires approval --->
			<cfset FieldNames[arlen][3] = "Other_Program_BasicInfo_Changes" />	<!--- Filed name in Program_Revision_Changes table to hold the value if its been cahnged and what type --->
		</cfif>
			<cfset arlen = arlen + 1 />
			<cfset FieldNames[arlen][1] = "Contract_Quantity_UOM_IDX" />		<!--- Field name to check for value change in contract_main --->
			<cfset FieldNames[arlen][2] = "Other_Program_Changes_Approval" />	<!--- Filed name in the Revision_Settings table to check if its a minor change/requires approval --->
			<cfset FieldNames[arlen][3] = "Other_Program_BasicInfo_Changes" />	<!--- Filed name in Program_Revision_Changes table to hold the value if its been cahnged and what type --->

		<cfif NOT application.oApplicationAppSettingsManager.getApplicationAppSettings().getPaymentCycleAtDiscountType()>
			<cfset arlen = arlen + 1 />
			<cfset FieldNames[arlen][1] = "PaymentCycle" />						<!--- Field name to check for value change in contract_main --->
			<cfset FieldNames[arlen][2] = "Other_Program_Changes_Approval" />	<!--- Filed name in the Revision_Settings table to check if its a minor change/requires approval --->
			<cfset FieldNames[arlen][3] = "Other_Program_BasicInfo_Changes" />	<!--- Filed name in Program_Revision_Changes table to hold the value if its been cahnged and what type --->
		</cfif>

			<!---
				In label 13399, payment type/claim mechanice was removed from basic information page in 5.0 alone
				So going forward we will not include claim mechanics in the "other basic info changes" for "short cut revision" decision

				<cfset arlen = arlen + 1 />
				<cfset FieldNames[arlen][1] = "ClaimMechanics" />					<!--- Field name to check for value change in contract_main --->
				<cfset FieldNames[arlen][2] = "Other_Program_Changes_Approval" />	<!--- Filed name in the Revision_Settings table to check if its a minor change/requires approval --->
				<cfset FieldNames[arlen][3] = "Other_Program_BasicInfo_Changes" />	<!--- Filed name in Program_Revision_Changes table to hold the value if its been cahnged and what type --->
			 ---->
			<cfset arlen = arlen + 1 />
			<cfset FieldNames[arlen][1] = "contract_reference_number" />					<!--- Field name to check for value change in contract_main --->
			<cfset FieldNames[arlen][2] = "Program_Reference_Number_Changes_Approval" />	<!--- Filed name in the Revision_Settings table to check if its a minor change/requires approval --->
			<cfset FieldNames[arlen][3] = "Program_Reference_Number_Changes" />				<!--- Filed name in Program_Revision_Changes table to hold the value if its been cahnged and what type --->

		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getDisplayNotesFieldOnProgram()>
			<cfset arlen = arlen + 1 />
			<cfset FieldNames[arlen][1] = "Notes" />					<!--- Field name to check for value change in contract_main --->
			<cfset FieldNames[arlen][2] = "Program_Notes_Change_Approval" />	<!--- Filed name in the Revision_Settings table to check if its a minor change/requires approval --->
			<cfset FieldNames[arlen][3] = "Program_Notes_Change" />				<!--- Filed name in Program_Revision_Changes table to hold the value if its been cahnged and what type --->
		</cfif>

		<cfreturn FieldNames />

	</cffunction>

	<!---  Function to return the revision types from Contract_Main_Aux_Data table --->
	<cffunction name="getProgramRevisionTypes" output="false" returntype="query">

		<cfargument name="programId" type="numeric" required="true" />

		<CFQUERY NAME="qGetProgramRevisionTypes" datasource="#application.datasource#">
			SELECT 	Contract_Main_Aux_Data.RevisionTypeA, Contract_Main_Aux_Data.RevisionTypeB, Contract_Main_Aux_Data.RevisionTypeC
			FROM 	Contract_Main_Aux_Data
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>

		<cfreturn qGetProgramRevisionTypes />
	</cffunction>

	<!---  Function to return the revision settings from Revision_Settings table --->
	<cffunction name="getRevisionSettingsData" output="false" returntype="query">

		<CFQUERY NAME="qGetRevisionSettingsData" DATASOURCE="#application.datasource#">
			SELECT		*
			FROM		Revision_Settings
			WHERE		Revision_Setting_Deleted = 0
		</CFQUERY>

		<cfreturn qGetRevisionSettingsData />
	</cffunction>

<!--- D32283 Add Setting for EZ Button Program revisios START--->
	<cffunction name="CheckEZRate" output="false" returntype="Numeric" >
		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />
		<cfargument name="GetRevisionSettingsData"	type="query" />

		<cfset FlagSet = 0 >
<!--- D34880: Max Rate Easy Button and Short Cut Routing
	REMOVED qGetProductsChanged2, CFLOOP
	ADDED qGetRebateProductsRatesChanged, UNION in qAnyAdded
--->
			<cfset qGetProductsChanged1 = this.qGetChangeLog.getProductsChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID, 0) />
			<cfset qGetRebateProductsRatesChanged = this.qGetChangeLog.GetRebateProductsRatesUOMChanged(arguments.Child_Contract_Main_ID, arguments.Parent_Contract_Main_ID, 0) />

			<cfif qGetProductsChanged1.recordCount OR qGetRebateProductsRatesChanged.recordCount>

					<cfset qGetProductsChanged = qGetProductsChanged1>

								<cfquery name="qAnyAdded" dbtype="query">
									Select 	BSA_Foodservice_Items_Master_ID, Is_group
									From 		qGetProductsChanged
									Where	Added = 1
									<cfif GetRevisionSettingsData.Prod_Add_FixedEqPricelist_Approval eq 1> AND Product_Type_ID <> 1 </cfif>
									UNION
									Select		First_ID AS BSA_Foodservice_Items_Master_ID, Is_group
									From		qGetRebateProductsRatesChanged
									Where	Rate1 > Rate2
								</cfquery>
								<cfset useLakebaseForqLumpProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqLumpProducts>
	<cftry>
		<cfset qLumpProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#arguments.Child_Contract_Main_ID#",
				"product_type_id" = "eq.3",
				"deleted" = "eq.0",
				"select" = "bsa_foodservice_items_master_id,is_group"
			}), "bsa_foodservice_items_master_id,is_group"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqLumpProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqLumpProducts>
<cfquery name="qLumpProducts" datasource="#application.datasource#" >
									Select  	BSA_Foodservice_Items_Master_ID, Is_group
									From 		Contract_Products
									Where 	Contract_Main_ID  = #arguments.Child_Contract_Main_ID#
									And 		Product_Type_ID = 3
									And			Deleted = 0
								</cfquery>
</cfif>
								<cfquery name="qAnyItemsAdded" dbtype="query">
									Select  	BSA_Foodservice_Items_Master_ID, Is_group
									From 		qAnyAdded
									UNION
									Select  	BSA_Foodservice_Items_Master_ID, Is_group
									From 		qLumpProducts
								</cfquery>

						<cfif qAnyAdded.Recordcount>
								<!--- D45263 :: Create table to store max rates by template/profile --->
								<CFQUERY NAME="qProductsBeyondEZRate" datasource="#application.datasource#">
									    SELECT	*
										FROM	DBO.UDF_EZ_GET_PROGRAM_PRODUCTS (#arguments.Child_Contract_Main_ID#, 'NOT_WITHIN_EZ_RATE', #request.AccessStructure.Profiles_ID#)
								</cfquery>

											<cfif qProductsBeyondEZRate.recordcount>
														<cfloop query="qAnyItemsAdded" >
																	<cfif Is_group>
																			<cfquery name="qProductCompare" datasource="#application.datasource#" >
																				SELECT *
																				FROM contract_products
																				WHERE Product_group_id = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR"/>
																				AND BSA_Foodservice_Items_Master_ID IN (<cfqueryparam value="#ValueList(qProductsBeyondEZRate.BSA_Foodservice_Items_Master_ID)#" cfsqltype="CF_SQL_VARCHAR" list="yes"/>)
																				AND Contract_Main_ID = #arguments.Child_Contract_Main_ID#
																			</cfquery>

																			   <cfif qProductCompare.Recordcount>
																			   	   <cfset FlagSet = 1>
																					    <cfbreak>
																			   </cfif>

																  	<cfelse>
																  			<cfquery name="qProductsCompare" dbtype="query" >
																			  	SELECT *
																				FROM qProductsBeyondEZRate
																				WHERE BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR"/>
																			</cfquery>

																				<cfif qProductsCompare.Recordcount>
																			   	   <cfset FlagSet = 1>
																					    <cfbreak>
																			    </cfif>
																  	</cfif>
														</cfloop>
											</cfif>
						</cfif>

			</cfif>
		<cfreturn FlagSet />
	</cffunction>
<!--- D32283 Add Setting for EZ Button Program revisios END--->

	<!------ Check Program duration ----->
	<cffunction name="programDurationCheck" output="No" returntype="numeric">
		<cfargument name="Parent_Contract_Main_ID"	type="numeric" />
		<cfargument name="Child_Contract_Main_ID"	type="numeric" />
		<cfargument name="GetRevisionSettingsData"	type="query" />

		<cfset FlagSet = 0 >
		<cfset RevisionType = arguments.GetRevisionSettingsData.Program_Date_Changed_Same_Duration_Type />

		<!--- 	D86748 - Short Cut Approval - add option for duration change		 --->
		<cfquery name="qCheckProgramDurations" datasource="#application.datasource#">
			select	*
			from	Contract_Main cm
					inner join Contract_Main cm2 on cm2.Contract_Number = cm.Contract_Number and cm2.Contract_Main_ID = <cfqueryparam value="#arguments.Child_Contract_Main_ID#" cfsqltype="cf_sql_integer">
			where	cm.Contract_Main_ID = <cfqueryparam value="#arguments.Parent_Contract_Main_ID#" cfsqltype="cf_sql_integer">
			and		datediff(d, cm.Contract_Start_Date, cm.Contract_End_Date) != datediff(d, cm2.Contract_Start_Date, cm2.Contract_End_Date)
		</cfquery>

		<cfif qCheckProgramDurations.RecordCount>
			<cfset FlagSet = this.qGetChangeLog.RevisionChangesFlags(arguments.Child_Contract_Main_ID, "Program_Duration_Changed", RevisionType ) />
		</cfif>

		<cfreturn FlagSet />
	</cffunction>

</cfcomponent>
