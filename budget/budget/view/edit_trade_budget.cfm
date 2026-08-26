<!------ 
	Name:          	edit_trade_budget.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/11/2006
	Created By:    	Deepa Kunnath
	Description:   	This page will have the display for edit basic info for budget
	Parameters:    	BudgetBasicInfo - an instance of Budget Basic Info object
	Usage:         	
----->

<cfoutput>
<table cellpadding="2" cellspacing="0" border="0" width="700" class="BasicInfo">
<caption align="left">Trade Basic Information - #BudgetBasicInfo.budgetName#</caption>
<colgroup>
<col width="250px"></col>
</colgroup>
<tr>
	<td>Budget Code</td>
	<td colspan="3"><input type="Text" name="Budget_Code" value="#BudgetBasicInfo.budgetCode#" class="LONGINPUT" /></td>
</tr>
<tr>
	<td>Budget Name</td>
	<td colspan="3"><input type="Text" name="Budget_Name" value="#BudgetBasicInfo.budgetName#" class="LONGINPUT" /></td>
</tr>
<tr>
	<td>Budget Dates</td>
	<td>
	<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="Budget_Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.budgetStartDate#">
	</td>
	<td align="right">
	<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="Budget_End_Date" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.budgetEndDate#">
	</td>
	<td width="10">&nbsp;</td>
	
</tr>
<tr>
	<td>Planning Tolerance</td>
	<td colspan="3"><input type="Text" name="Planning_Tolerance" value="#BudgetBasicInfo.planningTolerance#" /> <b>%</b></td>
</tr>
<tr>
	<td>Settlement Tolerance</td>
	<td colspan="3"><input type="Text" name="Settlement_Tolerance" value="#BudgetBasicInfo.settlementTolerance#" /> <b>%</b></td>
</tr>
<tr>
	<td>Control Level 1</td>
	<td colspan="3">
	<select name="levelSelection1">
		<option value="0">none</option>
		<cfloop query="strBudgetSettings.budgetTradeCustomerGroupMaster">
			<option value="#Budget_Group_Level_ID#" <cfif BudgetBasicInfo.controlLevel1 EQ Budget_Group_Level_ID>SELECTED</CFIF>>#Group_Level_Desc#</option>		
		</cfloop>
		<cfloop query="strBudgetSettings.budgetTradeSalesGroupMaster">
			<option value="#Budget_Group_Level_ID#" <cfif BudgetBasicInfo.controlLevel1 EQ Budget_Group_Level_ID>SELECTED</CFIF>>#Group_Level_Desc#</option>		
		</cfloop>
	</select>
	</td>
</tr>
<!------ Filter Data for Level 1 ----->
<tr>
	<td align="right">filter data?</td>
	<td>
	<input type="Checkbox" name="Control_Level_1_Filter_On" value="1" <cfif BudgetBasicInfo.controlLevel1FilterOn eq 1>checked</cfif>
		onclick="showHideFilterSelection(this.checked, 1);"
		/>
	<input type="hidden" name="levelSelection1_filter" value="#BudgetBasicInfo.controlLevel1_filterlist#">
	</td>
	<td id="levelSelection1_filter_link" <cfif BudgetBasicInfo.controlLevel1FilterOn neq 1>style="display:none;"</cfif>>
		<cfset extraParameter = " onClick=""javascript: return showSearchWindow('/budget/group_attribute_search.cfm', '#BudgetBasicInfo.controlLevel1#', document.all.levelSelection1, 'levelSelection1_filter', document.all.levelSelection1_filter);""" />
 		<CF_smallLink 
			title = "select"
			url = "##"
			parameters = "#extraParameter#"
			>
	</td>
</tr>
<cfif isQuery(BudgetBasicInfo.controlLevel1_filterListValues) AND BudgetBasicInfo.controlLevel1_filterListValues.recordCount GT 0>
<tr id="levelSelection1_filter_values">
	<td>&nbsp;</td>
	<td colspan="2" bgcolor="ffdead">	
	<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
	<cfloop query="BudgetBasicInfo.controlLevel1_filterListValues">
	<td>#Group_Name#</td>
	<cfif currentRow mod 2 eq 0 and BudgetBasicInfo.controlLevel1_filterListValues.recordCount GT currentRow></tr><tr></cfif>
	</cfloop>
	</tr>
	</table>	
	</td>	
</tr>
</cfif>
<tr>
	<td>Control Level 2</td>
	<td colspan="3">
	<select name="levelSelection2">
		<option value="0">none</option>
		<cfloop query="strBudgetSettings.budgetTradeProductGroupMaster">
			<option value="#Budget_Group_Level_ID#" <cfif BudgetBasicInfo.controlLevel2 EQ Budget_Group_Level_ID>SELECTED</CFIF>>#Group_Level_Desc#</option>		
		</cfloop>
	</select>
	</td>
</tr>
<!------ Filter Data for Level 2 ----->
<tr>
	<td align="right">filter data?</td>
	<td>
	<input type="Checkbox" name="Control_Level_2_Filter_On" value="1" <cfif BudgetBasicInfo.controlLevel2FilterOn eq 1>checked</cfif>
		onclick="showHideFilterSelection(this.checked, 2);"
		/>
	<input type="hidden" name="levelSelection2_filter" value="#BudgetBasicInfo.controlLevel2_filterlist#">
	</td>
	<td id="levelSelection2_filter_link" <cfif BudgetBasicInfo.controlLevel2FilterOn neq 1>style="display:none;"</cfif>>
		<cfset extraParameter = " onClick=""javascript: return showSearchWindow('/budget/group_attribute_search.cfm', '#BudgetBasicInfo.controlLevel2#', document.all.levelSelection2, 'levelSelection2_filter', document.all.levelSelection2_filter);""" />
 		<CF_smallLink 
			title = "select"
			url = "##"
			parameters = "#extraParameter#"
			>
	</td>
</tr>
<cfif isQuery(BudgetBasicInfo.controlLevel2_filterListValues) AND BudgetBasicInfo.controlLevel2_filterListValues.recordCount GT 0>
<tr id="levelSelection2_filter_values">
	<td>&nbsp;</td>
	<td colspan="2" bgcolor="ffdead">
	<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
	<cfloop query="BudgetBasicInfo.controlLevel2_filterListValues">
	<td>#Group_Name#</td>
	<cfif currentRow mod 2 eq 0 and BudgetBasicInfo.controlLevel2_filterListValues.recordCount GT currentRow></tr><tr></cfif>
	</cfloop>
	</tr>
	</table>	
	</td>
</tr>
</cfif>
<tr>
	<td>Claim Allocation Method</td>
	<td colspan="3">
	<cfset arLen = ArrayLen(arClaimAllocationMethods) />
	<select name="Claim_Allocation_Method">
	<cfloop from="1" to="#arLen#" index="i">
		<cfset ClaimAllocationMethod = arClaimAllocationMethods[i] />
		<option value="#ClaimAllocationMethod.claimAllocationMethodId#" <cfif BudgetBasicInfo.claimAllocationMethod eq ClaimAllocationMethod.claimAllocationMethodId>selected</cfif>>#ClaimAllocationMethod.claimAllocationMethodName#</option>
	</cfloop>
	</select>
	</td>
</tr>

<tr>
	<td colspan="4" class="subheader">Allocation Types</td>
</tr>

<!------ get the list of active allocation types from the settings panel ----->
<cfset arActiveAllocationTypes = StrBudgetSettings.budgetTradeAllocationType />
<cfset activeAllocationTypeLen = ArrayLen(arActiveAllocationTypes) />

<!------ loop thru the allocation types and show them ----->
<cfloop index="i" from="1" to="#activeAllocationTypeLen#">
	<cfset oAllocationType = arActiveAllocationTypes[i] />
	<tr>
		<td colspan="4" class="allocationtype">
		<input type="radio" name="allocation_type" value="#oAllocationType.id#" onPropertyChange="javascript:setVisibility(this,document.all.allocation_type_#oAllocationType.id#)"  <cfif BudgetBasicInfo.allocation_type.id EQ oAllocationType.id>CHECKED</CFIF>>
		#oAllocationType.desc#</td>
	</tr>
	<tbody style="border-top:1px solid black;" id="allocation_type_#oAllocationType.id#" <cfif BudgetBasicInfo.allocation_type.id NEQ oAllocationType.id>style="display:none;"</CFIF>>
	<cfswitch expression="#oAllocationType.id#">
		<!----********************************************** Top-Down *******************************************************---->
		<cfcase value="1">
			<tr>
				<td rowspan="6" valign="top"></td>
				<td>Dollars</td>
				<td colspan="2"><input type="text" name="td_dollars" value="#BudgetBasicInfo.BudgetValue#"></td>
			</tr>
			<tr>
				<td>Allocation all levels or one at a time?</td>
				<td colspan="2">
					<select name="td_levels">
						<option <cfif BudgetBasicInfo.Allocation_Type.Calculation_Method.Levels EQ 1>SELECTED</CFIF> value="1">One Level At A Time</option>
						<option <cfif BudgetBasicInfo.Allocation_Type.Calculation_Method.Levels EQ 2>SELECTED</CFIF> value="2">Both At Same Time</option>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="3" width="600px"><b>Calculation Method</b></td>
			</tr>
			<tr>
				<td class="calcMethod"><input type="radio" name="td_calc_method" value="1" <cfif BudgetBasicInfo.Allocation_Type.id EQ 1 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 1>CHECKED</cfif> >Invoiced Sales Dollars</td>
				<td>
					<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="td_Start_Date_1" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.Allocation_Type.Calculation_Method.start_date#">
				</td>
				<td>
					<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="td_End_Date_1" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.Allocation_Type.Calculation_Method.end_date#">
				</td>
			</tr>
			<tr>
				<td class="calcMethod"><input type="radio" name="td_calc_method" value="2"  <cfif BudgetBasicInfo.Allocation_Type.id EQ 1 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 2>CHECKED</cfif>>Invoiced Volume</td>
				<td>
					<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="td_Start_Date_2" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.Allocation_Type.Calculation_Method.start_date#">
				</td>
				<td>
					<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="td_End_Date_2" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.Allocation_Type.Calculation_Method.end_date#">
				</td>
			</tr>
			<tr>
				<td class="calcMethod"><input type="radio" name="td_calc_method" value="3"  <cfif BudgetBasicInfo.Allocation_Type.id EQ 1 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 3>CHECKED</cfif>>Prior Budget
				</td>
				<td colspan="2" >
					<select name="td_prior_budget">
						<cfloop from="1" to="#ArrayLen(arBudgetGroups)#" step="1" index="budget_group_index">
							<cfloop from="1" to="#ArrayLen(arBudgetGroups[budget_group_index].budgetgroupmembers)#" step="1" index="budget_index">
								<cfif arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode NEQ BudgetBasicInfo.budgetCode>
									<option value="#arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode#" <cfif BudgetBasicInfo.allocation_type.calculation_method.budgetreference EQ arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode>SELECTED</cfif> >
										#arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetname#
									</option>
								</cfif>
							</cfloop>
						</cfloop>
					</select>
				</td>
			</tr>
		</cfcase>
		
		<!----********************************************** Bottom-Up *******************************************************---->
		<cfcase value="2">
			<tr><td rowspan="3" valign="top"></td>
				<td colspan="3" width="600px"><b>Calculation Method</b></td>
			</tr>
			<tr>
				<td class="calcMethod"><input type="radio" name="bu_calc_method" value="1"  <cfif BudgetBasicInfo.Allocation_Type.id EQ 2 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 1>CHECKED</cfif>>Prior Budget</td>
				<td colspan="2">
					<select name="bu_prior_budget">
						<cfloop from="1" to="#ArrayLen(arBudgetGroups)#" step="1" index="budget_group_index">
							<cfloop from="1" to="#ArrayLen(arBudgetGroups[budget_group_index].budgetgroupmembers)#" step="1" index="budget_index">
								<cfif arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode NEQ BudgetBasicInfo.budgetCode>
									<option value="#arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode#" <cfif BudgetBasicInfo.allocation_type.calculation_method.budgetreference EQ arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode>SELECTED</cfif> >
										#arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetname#
									</option>
								</cfif>
							</cfloop>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="3" class="calcMethod"><input type="radio" name="bu_calc_method" value="2"  <cfif BudgetBasicInfo.Allocation_Type.id EQ 2 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 2>CHECKED</cfif>>Manual</td>
			</tr>
		</cfcase>

		<!----********************************************** Accrual *******************************************************---->
		<cfcase value="3">
			<tr><td rowspan="3" valign="top"></td>
				<td colspan="3" width="600px"><b>Calculation Method</b></td>
			</tr>
			<tr>
				<td class="calcMethod"><input type="radio" name="ac_calc_method" value="1"  <cfif BudgetBasicInfo.Allocation_Type.id EQ 3 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 1>CHECKED</cfif>>Invoiced Volume</td>
				<td>
					<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="ac_Start_Date_1" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.Allocation_Type.Calculation_Method.start_date#">
				</td>
				<td>
					<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="ac_End_Date_1" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.Allocation_Type.Calculation_Method.end_date#">
				</td>
			</tr>
			<tr>
				<td class="calcMethod"><input type="radio" name="ac_calc_method" value="2"  <cfif BudgetBasicInfo.Allocation_Type.id EQ 3 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 2>CHECKED</cfif>>Prior Budget</td>
				<td colspan="2" >
					<select name="ac_prior_budget">
						<cfloop from="1" to="#ArrayLen(arBudgetGroups)#" step="1" index="budget_group_index">
							<cfloop from="1" to="#ArrayLen(arBudgetGroups[budget_group_index].budgetgroupmembers)#" step="1" index="budget_index">
								<cfif arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode NEQ BudgetBasicInfo.budgetCode>
									<option value="#arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode#" <cfif BudgetBasicInfo.allocation_type.calculation_method.budgetreference EQ arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode>SELECTED</cfif> >
										#arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetname#
									</option>
								</cfif>
							</cfloop>
						</cfloop>
					</select>
				</td>		
			</tr>
		</cfcase>
		
		<!----********************************************** Rate * Volume *******************************************************---->
		<cfcase value="4">
			<tr>
				<td rowspan="3" valign="top"></td>
				<td colspan="3" width="600px"><b>Calculation Method</b></td></tr>
			<tr>
				<td class="calcMethod"><input type="radio" name="rv_calc_method" value="1"  <cfif BudgetBasicInfo.Allocation_Type.id EQ 4 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 1>CHECKED</cfif>>Invoiced Volume</td>
				<td>
					<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="rv_Start_Date_1" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.Allocation_Type.Calculation_Method.start_date#">
				</td>
				<td>
					<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="rv_End_Date_1" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.Allocation_Type.Calculation_Method.end_date#">
				</td>
			</tr>
			<tr>
				<td class="calcMethod"><input type="radio" name="rv_calc_method" value="2"  <cfif BudgetBasicInfo.Allocation_Type.id EQ 1 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 2>CHECKED</cfif>>Prior Budget</td>
				<td colspan="2" >
					<select name="rv_prior_budget">
						<cfloop from="1" to="#ArrayLen(arBudgetGroups)#" step="1" index="budget_group_index">
							<cfloop from="1" to="#ArrayLen(arBudgetGroups[budget_group_index].budgetgroupmembers)#" step="1" index="budget_index">
								<cfif arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode NEQ BudgetBasicInfo.budgetCode>
									<option value="#arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode#" <cfif BudgetBasicInfo.allocation_type.calculation_method.budgetreference EQ arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode>SELECTED</cfif> >
										#arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetname#
									</option>
								</cfif>
							</cfloop>
						</cfloop>
					</select>
				</td>		
			</tr>
		</cfcase>
				
		<!----********************************************** Historical Percentage of Revenue *******************************************************---->
		<cfcase value="5">
			<tr>
				<td rowspan="3" valign="top">
				<td colspan="3" width="600px"><b>Calculation Method</b></td></tr>
			<tr>
				<td class="calcMethod"><input type="radio" name="hp_calc_method" value="1"  <cfif BudgetBasicInfo.Allocation_Type.id EQ 5 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 1>CHECKED</cfif>>Historical Percent of Revenue</td>
				<td>
					<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="hp_Start_Date_1" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.Allocation_Type.Calculation_Method.start_date#">
				</td>
				<td>
					<CF_EASYDATE FORMNAME="frmBudget" FIELDNAME="hp_End_Date_1" FORMAT="mm/dd/yyyy" DEFAULT="#BudgetBasicInfo.Allocation_Type.Calculation_Method.end_date#">
				</td>
			</tr>
			<tr>
				<td class="calcMethod"><input type="radio" name="hp_calc_method" value="2"  <cfif BudgetBasicInfo.Allocation_Type.id EQ 5 AND  BudgetBasicInfo.Allocation_Type.Calculation_Method.id EQ 2>CHECKED</cfif>>Prior Budget</td>
				<td colspan="2" >
					<select name="hp_prior_budget">
						<cfloop from="1" to="#ArrayLen(arBudgetGroups)#" step="1" index="budget_group_index">
							<cfloop from="1" to="#ArrayLen(arBudgetGroups[budget_group_index].budgetgroupmembers)#" step="1" index="budget_index">
								<cfif arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode NEQ BudgetBasicInfo.budgetCode>
									<option value="#arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode#" <cfif BudgetBasicInfo.allocation_type.calculation_method.budgetreference EQ arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetcode>SELECTED</cfif> >
										#arBudgetGroups[budget_group_index].budgetgroupmembers[budget_index].budgetname#
									</option>
								</cfif>
							</cfloop>
						</cfloop>
					</select>
				</td>		
			</tr>
		</cfcase>
	</cfswitch>
	</tbody>

</cfloop>
		

<!---- Navigation & Action Links ---->
	<tr>
		<td><cf_button name="linkView" 
		  			   button_type="link" 
		  			   button_caption="Generate" 
		  			   button_action="index.cfm?command=generateBudgetAllocation&id=#form.id#">
		</td>
		<td><cf_button name="linkView" 
		  			   button_type="link" 
		  			   button_caption="Allocate" 
		  			   button_action="index.cfm?command=editBudgetAllocation&id=#form.id#">
		</td>
		<td><cf_button name="linkView" 
		  			   button_type="link" 
		  			   button_caption="Cancel" 
		  			   button_action="index.cfm?command=listActiveBudgetGroup">
		</td>
		<td><cf_button name="linkView" 
		  			   button_type="javascript_link" 
		  			   button_caption="Save" 
		  			   button_action="document.forms[0].command.value='saveTradeBudget';document.forms[0].submit();">
		</td>
		<!----
		<td><cf_button name="linkView" 
		  			   button_type="javascript_link" 
		  			   button_caption="Save and Continue" 
		  			   button_action="document.forms[0].submit();">
		</td>
		---->
	</tr>
</table>
<input type="hidden" name="id" value="#form.id#" />
<!--- End Allocation Type --->

</cfoutput>