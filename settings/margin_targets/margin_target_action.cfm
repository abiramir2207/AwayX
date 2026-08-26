<cfsilent>
<!---FILENAME: 	/settings/margin_targets/margin_target_action.cfm
CREATED: 	??/??/200? - ???
EDITED:		12/08/2008 - RBL [D17683]
FUNCTIONALITY:- This action page updates the DB with user input margin target data and subsequently makes them available to the calling page.
--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="costvariablessequence" default="">
<cfparam name="form.Global_Target_UOM" default="1">
<cfset dataArray = arraynew(1)>

<cfset expectedFieldLen = 43>
<cfset preCursorString1 = "target_">
<cfset preCursorString2 = "spend_">
<cfset preCursorString3 = "opr_target_">
<cfset preCursorString4 = "list_price_">
	
<cfset expectedFieldLen1 = 42>
<cfparam name="costvariablessequence" default="">

</cfsilent>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif appSettings.getlocalcostvariables() eq 1>
<cfset useLakebaseForgetcostvariables = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cost_sequence")>
<cfif useLakebaseForgetcostvariables>
	<cftry>
		<cfset getcostvariables = application.oLakebase.toQuery(
			application.oLakebase.selectRows("cost_sequence", {
				"deleted" = "eq.0",
				"order" = "cost_sequence_order.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetcostvariables = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetcostvariables>
<cfquery name="getcostvariables" datasource="#application.datasource#">
	SELECT *
	FROM cost_sequence
	WHERE	Deleted = 0
	ORDER BY Cost_Sequence_Order
</cfquery>
</cfif>
<cfif getcostvariables.recordcount GT 0>
<cfset costvariableslist = valuelist(getcostvariables.cost_sequence_id)>
<cfset costvariablessequence = valuelist(getcostvariables.cost_sequence_order)>
</cfif>
</cfif>

<cfset maxStaticColIndex = 7 />
 <cfloop index="x" list="#Form.Fieldnames#">
 <cfif len(x) GTE expectedFieldLen>
	<cfif lcase(left(x, len(preCursorString1))) EQ preCursorString1>
		<cfset group_id = mid(x, len(preCursorString1)+1, expectedFieldLen-len(preCursorString1))>
		<cfset dataArray[arraylen(dataArray)+1][1] 	= replace(group_id, "_", "-", "ALL")>
		<!--- target --->
		<cfset dataArray[arraylen(dataArray)][2]		= evaluate("form.#x#")>
		<!--- spend dollar --->
		<cfif appSettings.getApprovalStandardOn()>
			 <cfset dataArray[arraylen(dataArray)][3]		= evaluate("form.spend_#group_id#")>
		<cfelse>
			 <cfset dataArray[arraylen(dataArray)][3]		= 0 />
		</cfif>
		<!--- targets case rate --->
		<cfif appSettings.getApprovalMarginType() eq 2>
			 <cfset dataArray[arraylen(dataArray)][4]		= trim(evaluate("form.case_rate_#group_id#"))>
			 <cfset dataArray[arraylen(dataArray)][5]		= trim(evaluate("form.case_rate_uom_#group_id#"))>
				 <cfif not isnumeric(dataArray[arraylen(dataArray)][4])>
					<cfset dataArray[arraylen(dataArray)][4] = 0.0>
					<cfset dataArray[arraylen(dataArray)][5] = 1>
				</cfif>
		<cfelse>
			 <cfset dataArray[arraylen(dataArray)][4]		= 0 />
			 <cfset dataArray[arraylen(dataArray)][5]		= 0 />
		</cfif>
		<!--- cost fields --->
		<CFSET F_Counter = 1>
		<cfif listlen(costvariablessequence) GT 0>
		<cfloop list="#costvariablessequence#" index="i">
			<cfset dataArray[arraylen(dataArray)][maxStaticColIndex + F_Counter] = evaluate("form.#i#_#group_id#")>
			<cfset dataArray[arraylen(dataArray)][maxStaticColIndex + listlen(costvariablessequence) + F_Counter] = evaluate("form.#i#_#group_id#_uom")>
			<!--- validation and formating --->
			<cfif isnumeric(dataArray[arraylen(dataArray)][2])>
            		<!--- D17683 [begin] RBL added [,'__.__'] 12/08/08 --->
				<cfset dataArray[arraylen(dataArray)][maxStaticColIndex + F_Counter] = trim(dataArray[arraylen(dataArray)][maxStaticColIndex + F_Counter])>
                	<!--- D17683 [end] --->
			<cfelse>
				<cfset dataArray[arraylen(dataArray)][maxStaticColIndex + F_Counter] = 0.0>
			</cfif>
			<cfset F_Counter = F_Counter + 1>
		</cfloop>
		</cfif>
		<!--- validation and formating --->
		<cfif isnumeric(dataArray[arraylen(dataArray)][2])>
          	<!--- D17683 [begin] RBL added [,'___.____'] 12/08/08 --->
			<cfset dataArray[arraylen(dataArray)][2] = trim(dataArray[arraylen(dataArray)][2])>
              <!--- D17683 [end] --->
		<cfelse>
			<cfset dataArray[arraylen(dataArray)][2] = 0.0>
		</cfif>
		<!--- validation and formating --->
		<cfif isnumeric(dataArray[arraylen(dataArray)][3])>
          	<!--- D17683 [begin] RBL added [,'__.__'] 12/08/08 --->
			<cfset dataArray[arraylen(dataArray)][3] = trim(dataArray[arraylen(dataArray)][3])>
              <!--- D17683 [end] --->
		<cfelse>
			<cfset dataArray[arraylen(dataArray)][3] = 0.0>
		</cfif>
	<cfelseif lcase(left(x, len(preCursorString3))) EQ preCursorString3>
		<!--- target operator--->
		<cfset dataArray[arraylen(dataArray)][6]		= evaluate("form.#x#")>
	<cfelseif lcase(left(x, len(preCursorString4))) EQ preCursorString4>
		<!--- list price--->
		<cfset dataArray[arraylen(dataArray)][7]		= evaluate("form.#x#")>
	</cfif>
</cfif>
</cfloop>
<cfset approvalGroupType = CreateObject("component", "components.settings.ApprovalGroupManager").getGroupTypeInfo() />
<cfquery name="delete_group_costs" datasource="#application.datasource#">
	delete from group_local_costs
</cfquery>
<cfloop index="x" from="1" to="#arraylen(dataArray)#">
	<cfquery name="update_targets" datasource="#application.datasource#">
		UPDATE #approvalGroupType.tableName#
		SET	Target_Margin = '#dataArray[x][2]#',
			Target_Margin_Operator = '#dataArray[x][6]#',
			spend_dollar = '#dataArray[x][3]#',
			Target_Case_Rate = '#dataArray[x][4]#',
			Target_Case_Rate_UOM = '#dataArray[x][5]#',
		  Target_Margin_ListPrice = '#dataArray[x][7]#'
		WHERE #approvalGroupType.IDField#  = '#dataArray[x][1]#'
	</cfquery>
<cfoutput>
	<cfquery name="insert_group_costs" datasource="#application.datasource#">
		INSERT INTO group_local_costs (Group_id 
																														<cfif listlen(costvariablessequence) GT 0>
																															<cfloop list="#costvariablessequence#" index="i">
																																,cost#i#_Rate
																																,cost#i#_UOM
																															</cfloop>
																														</cfif>
																													)
		values ('#dataArray[x][1]#'
								<cfif listlen(costvariablessequence) GT 0>
									<cfset z = 1>
									<cfloop list="#costvariablessequence#" index="i">
										,'#evaluate(dataArray[x][maxStaticColIndex+Z])#'
										,'#evaluate(dataArray[x][maxStaticColIndex+Z+listlen(costvariablessequence)])#'
										<cfset z = z + 1>
									</cfloop>
								</cfif>
								)
	</cfquery>
</cfoutput>
</cfloop>

<cfquery name="update_feature_Status" datasource="#application.datasource#">
	UPDATE General_Settings
	SET program_margin_target_enabled = '<cfif isdefined("form.mt_status")>1<cfelse>0</cfif>',
		Global_Target_UOM = #form.Global_Target_UOM#,
		PM_LastUpdated_Date = getdate(),
		PM_LastUpdated_UserId = '#request.AccessStructure.User_Id#'
</cfquery>

<script>
	window.location.href = "index.cfm";
</script>