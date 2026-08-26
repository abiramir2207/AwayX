
<!----- budget_billback_select_include.cfm ------->
<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
<cfset BudgetBillbackManager = CreateObject("component", "components.budgets.BudgetBillbackManager").init() />
<cfset BudgetManager.loadBudgetLabels() />
<cfset BillbackSummaryManager = CreateObject("component", "components.billback.BillbackSummaryManager") />

<cfif not isDefined("qGetBillbackStatus")>
	<cfset qGetBillbackStatus = BillbackSummaryManager.getBillbackStatus(
						billbackId = Billback_ID) />
</cfif>
<cfset qGetBudgetsForBillback = BudgetBillbackManager.getBudgetsForBillback(
				billbackId = Billback_ID) />

<cfset useLakebaseForqCheckForBudget = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetbudgetsforbillback")>
<cfif useLakebaseForqCheckForBudget>
	<cftry>
		<cfset qCheckForBudget = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetbudgetsforbillback", {
				"simple_budget_class_id" = "not.is.null",
				"simple_budget_id" = "not.is.null"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckForBudget = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckForBudget>
<cfquery name="qCheckForBudget" dbtype="query">
	SELECT	*
	FROM	qGetBudgetsForBillback
	WHERE	Simple_Budget_Class_ID IS NOT NULL
	AND		Simple_Budget_ID IS NOT NULL
</cfquery>
</cfif>
	
<cfif qCheckForBudget.RecordCount>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

	<script language="javascript">
		function validateAndSaveBudgetSelection()
		{
			var allValid = validateBudgetSelection();
				
			if(allValid)
			{
				document.frmBudgetBillbackSelect.submit();
			}
			else
			{
				showMessageWindow();
			}
		}
		
		function validateBudgetSelection()
		{
			var billbackProgramID, cellID;
			var allocatedPercentInp, allocatedDollar, currentBudgetBalance, postApprovalBudgetBalance;
			var billbackProgramBudgetDollarInp, oBillbackProgramBudgetChk, errSpAllocationMatch100;
			var ibillbackProgramBudgetDollar, sBudgetID, allocatedPercent;
			var allValid = true;
			var totalBillbackProgramBudgetAllocation;
			
			var rowList, mainRowList = document.all.Billback_Program_ID_List.value;
			var arMainRowList = mainRowList.split(",");
			var mainRowListLen = arMainRowList.length;

			for(j=0; j<mainRowListLen; j++)
			{
				re = /-/g;
				billbackProgramID = arMainRowList[j].replace(re, "_");
				billbackProgramBudgetDollarInp = eval('document.all.Billback_Program_Dollar_' + billbackProgramID);
				totalBillbackProgramBudgetAllocation = 0;
				if(billbackProgramBudgetDollarInp)
				{
					ibillbackProgramBudgetDollar = parseFloat(billbackProgramBudgetDollarInp.value);
					oBillbackProgramBudgetChk = eval('document.all.Simple_Budget_Class_Association_ID_' + billbackProgramID);
					if(oBillbackProgramBudgetChk)
					{
						if(oBillbackProgramBudgetChk.length)
						{
							for(i=0; i<oBillbackProgramBudgetChk.length; i++)
							{
								if(oBillbackProgramBudgetChk[i].checked)
								{
									sBudgetID = oBillbackProgramBudgetChk[i].value;
									allocatedPercentInp = eval('document.all.billback_budget_percent_' + billbackProgramID + '_' + sBudgetID);
									if(allocatedPercentInp)
									{
										allocatedPercent = parseFloat(allocatedPercentInp.value);
										if(isNaN(allocatedPercent)) allocatedPercent = 0;
										
										totalBillbackProgramBudgetAllocation += allocatedPercent;
									}
								}
							}//loop on each budget check box within this program
						}//if program budget check box is collection
						else
						{
								if(oBillbackProgramBudgetChk.checked)
								{
									sBudgetID = oBillbackProgramBudgetChk.value;
									allocatedPercentInp = eval('document.all.billback_budget_percent_' + billbackProgramID + '_' + sBudgetID);
									if(allocatedPercentInp)
									{
										allocatedPercent = parseFloat(allocatedPercentInp.value);
										if(isNaN(allocatedPercent)) allocatedPercent = 0;
										
										totalBillbackProgramBudgetAllocation += allocatedPercent;
									}
								}
						}//if program budget check box is single
					}//if program budget check box collection found						
				}//if program object found
				
				errSpAllocationMatch100 = eval('document.all.Err_Sp_Allocation_Match_100_' + billbackProgramID);
				
				if(totalBillbackProgramBudgetAllocation != 100)
				{
					allValid = false;
					queueMessage("Budget allocation should add up to 100%", errSpAllocationMatch100);
				}
				else
				{
					clearQueue(errSpAllocationMatch100);
				}
				
				
			}//loop on each program
				
			return allValid;
					
		}
		
		function setBudgetAllocatedDollar(cellID, rowIDPrefix)
		{	
			var allocatedPercentInp = eval('document.all.billback_budget_percent_' + cellID);
			var allocatedDollarDiv = eval('document.all.billback_budget_dollar_' + cellID);
			var postApprovalBalanceDiv = eval('document.all.post_approval_budget_balance_' + cellID);
			var iDollar = eval('document.all.Billback_Program_Dollar_' + rowIDPrefix + '.value');
			var billbackProgramDollar = parseFloat(iDollar);
			var budgetSelected = 1;
			if(!isNaN(billbackProgramDollar) && allocatedPercentInp && allocatedDollarDiv)
			{
				var allocatedPercent = parseFloat(allocatedPercentInp.value);
				if(isNaN(allocatedPercent))
				{
					allocatedPercent = 0;
					budgetSelected = 0;
				}
				if(allocatedPercentInp.disabled)
				{
					allocatedPercent = 0;
					budgetSelected = 0;
				}
	
				if(budgetSelected)
				{
					var allocatedDollar = allocatedPercent * 0.01 * billbackProgramDollar;
					allocatedDollarDiv.innerText = formatDollar(allocatedDollar, 2, 1, 3);
					
					// show balance after apporval
					var currentBudgetBalance = parseFloat(allocatedPercentInp.Budget_Balance);
					if(isNaN(currentBudgetBalance)) currentBudgetBalance = 0;
					var postApprovalBudgetBalance = currentBudgetBalance - allocatedDollar;
					
					if(postApprovalBalanceDiv)
					{
						postApprovalBalanceDiv.innerText = formatDollar(postApprovalBudgetBalance, 2, 1, 3);
						
						if(postApprovalBudgetBalance < 0)
						{
							postApprovalBalanceDiv.style.color = "red";					
						}
						else
						{
							postApprovalBalanceDiv.style.color = "black";					
						}
					}
				}
				else
				{
					allocatedDollarDiv.innerText = " ";
					postApprovalBalanceDiv.innerText = " ";
				}
			}
			programBudgetValid(rowIDPrefix);
			//Sp_Percentage_Left_
		}
		
		function programBudgetValid(billbackProgramID)
		{
			var oBillbackProgramBudgetChk = eval('document.all.Simple_Budget_Class_Association_ID_' + billbackProgramID);
			var sBudgetID, allocatedPercent, allocatedPercentInp, totalBillbackProgramBudgetAllocation;
			
			totalBillbackProgramBudgetAllocation = 0;
			
			if(oBillbackProgramBudgetChk)
			{
				if(oBillbackProgramBudgetChk.length)
				{
					for(i=0; i<oBillbackProgramBudgetChk.length; i++)
					{
						if(oBillbackProgramBudgetChk[i].checked)
						{
							sBudgetID = oBillbackProgramBudgetChk[i].value;
							allocatedPercentInp = eval('document.all.billback_budget_percent_' + billbackProgramID + '_' + sBudgetID);
							if(allocatedPercentInp)
							{
								allocatedPercent = parseFloat(allocatedPercentInp.value);
								if(isNaN(allocatedPercent)) allocatedPercent = 0;
								
								totalBillbackProgramBudgetAllocation += allocatedPercent;							
							}
						}
					}//loop on each budget check box within this program
				}//if program budget check box is collection
				else
				{
						if(oBillbackProgramBudgetChk.checked)
						{
							sBudgetID = oBillbackProgramBudgetChk.value;
							allocatedPercentInp = eval('document.all.billback_budget_percent_' + billbackProgramID + '_' + sBudgetID);
							if(allocatedPercentInp)
							{
								allocatedPercent = parseFloat(allocatedPercentInp.value);
								if(isNaN(allocatedPercent)) allocatedPercent = 0;
								
								totalBillbackProgramBudgetAllocation += allocatedPercent;
							}
						}
				}//if program budget check box is single
			}//if program budget check box collection found						
		
		
			var SpPercentageLeft = eval('document.all.Sp_Percentage_Left_' + billbackProgramID);
			SpPercentageLeft.innerText = 100 - totalBillbackProgramBudgetAllocation;  
					
		}
		
		function budgetCheck(oChk, rowID, rowIDPrefix, bAllowMultiple)
		{
			if(event.propertyName == 'checked')
			{
				var allocatedPercentInp = eval('document.all.billback_budget_percent_' + rowID);
				allocatedPercentInp.disabled = !oChk.checked;
				if(!allocatedPercentInp.disabled && !bAllowMultiple)
					allocatedPercentInp.value = "100";						
				setBudgetAllocatedDollar(rowID, rowIDPrefix);															
			}
		}
		
		function displayProgramBudgetDetails()
		{
			<cfoutput>
			NewWindow('budget_display_billback.cfm?Billback_ID=#Billback_ID#', 'bb_budget_display', 800, 600, 'yes', 'yes');
			</cfoutput>
			return false;
		}
	</script>
<cfset billbackProgramIDList = "" />

<cfoutput>	
<cfset headerStyle = "id=""header"" style=""font-weight:bold;""">


<table cellpadding="3" cellspacing="1" class="MainTable" width="98%">
<caption style="font-weight:bold;font-size:14px;">Select Budget
	<span style="font-size:12px;font-weight:normal;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<CF_smallLink 
		title = "show budget details" 
		url = "##"
		parameters = "onClick=""javascript: return displayProgramBudgetDetails('dataForm');"""
	>
	</span>
	</caption>
<tr bgcolor="ffdead">
	<td>&nbsp;</td>
	<td #headerStyle#>Class / Budget</td>
	<td #headerStyle#>#BudgetManager.getBudgetClassAssociationLabel()#</td>
	<td #headerStyle#>#BudgetManager.getCommittedDollarLabel()#</td>
	<td #headerStyle# align="right">#BudgetManager.getBudgetBalanceLabel()#</td>
	<td #headerStyle#>Allocated %</td>
	<td #headerStyle# align="right">Allocated $</td>
	<td #headerStyle# align="right">Balance after change</td>	
</tr>
</cfoutput>


	<!---------------- loop over programs - starte -------------------------->
	<cfoutput query="qGetBudgetsForBillback" group="Contract_Number">
		
		<cfset useLakebaseForqCheckForThisBudget = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetbudgetsforbillback")>
<cfif useLakebaseForqCheckForThisBudget>
	<cftry>
		<cfset qCheckForThisBudget = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetbudgetsforbillback", {
				"contract_number" = "eq.#Contract_Number#",
				"simple_budget_class_id" = "not.is.null",
				"simple_budget_id" = "not.is.null"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckForThisBudget = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckForThisBudget>
<cfquery name="qCheckForThisBudget" dbtype="query">
			SELECT	*
			FROM	qGetBudgetsForBillback
			WHERE	Contract_Number = '#Contract_Number#'
			AND		Simple_Budget_Class_ID IS NOT NULL
			AND		Simple_Budget_ID IS NOT NULL
		</cfquery>
</cfif>
			
		<cfif qCheckForThisBudget.RecordCount>
		
			<cfset rowIdPrefix = replace(Billback_Program_ID, "-", "_", "all") />
			
			<cfif qGetBillbackStatus.Billback_Status_ID LT 3>
				<cfset Billback_Program_Amount = Billback_Program_Approved_Amount />
			<cfelse>
				<cfset Billback_Program_Amount = Billback_Program_Paid_Amount />
			</cfif>
			
			<cfset useLakebaseForqGetProgramBudgets = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetbudgetsforbillback")>
<cfif useLakebaseForqGetProgramBudgets>
	<cftry>
		<cfset qGetProgramBudgets = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetbudgetsforbillback", {
				"billback_program_id" = "eq.#Billback_Program_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProgramBudgets = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProgramBudgets>
<cfquery name="qGetProgramBudgets" dbtype="query">
				select	*
				from	qGetBudgetsForBillback
				where	Billback_Program_ID = '#Billback_Program_ID#'
			</cfquery>
</cfif>
			
			<tr>
				<td colspan="100%" bgcolor="ccffcc">[#Contract_Number#] #Contract_Title# - <b>#DollarFormat(Billback_Program_Amount)#</b>
				(<span id="Sp_Percentage_Left_#rowIdPrefix#"></span>% to allocate)
				<span id="Err_Sp_Allocation_Match_100_#rowIdPrefix#"></span>
				<input type="hidden" name="Billback_Program_Dollar_#rowIdPrefix#" value="#Billback_Program_Amount#">
				<cfset billbackProgramIDList = ListAppend(billbackProgramIDList, Billback_Program_ID) />
				</td>
			</tr>
			<cfset totalProgramAllocation = 0 />
				<!---------------- loop over budgets - start -------------------------->
				<cfoutput>
				<cfset rowID = rowIdPrefix & "_"& Simple_Budget_Class_Association_ID />
				<cfset Current_Allocation_Percent = Actual_Allocated_Percent />
				<cfset currentChkChecked = 0 />
				<cfset Budget_Balance_Percentage = 0 />
				<cfif Billback_Program_Amount NEQ 0>
					<cfset Budget_Balance_Percentage = Int((Budget_Balance / Billback_Program_Amount) * 100) />
				</cfif>
				<cfif NOT isNumeric(Current_Allocation_Percent) AND qGetProgramBudgets.recordCount eq 1>
					<cfset Current_Allocation_Percent = 100 />
				</cfif>
				<cfset Balanace_After_Change_Style = "color:black;" />
				<cfif IsNumeric(Current_Allocation_Percent)>
					<cfset Allocated_Dollar_Value = Current_Allocation_Percent * 0.01 * Billback_Program_Amount />
					<cfset Allocated_Dollar = DollarFormat(Allocated_Dollar_Value) />
					<cfset currentChkChecked = 1 />
					<cfset Balanace_After_Change_Value = Budget_Balance - Allocated_Dollar_Value />
					<cfset Balanace_After_Change = DollarFormat(Balanace_After_Change_Value) />
					<cfif Balanace_After_Change_Value lt 0>
						<cfset Balanace_After_Change_Style = "color:red;" />
					</cfif>
					<cfset totalProgramAllocation = totalProgramAllocation + Current_Allocation_Percent />
				<cfelse>
					<cfset Allocated_Dollar = "" />
					<cfset Balanace_After_Change = "" />
				</cfif>
				<tr>
					<td><input
							<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBillbackAllowMultipleBudgets()> 
							type="checkbox"
							<cfelse> 
							type="radio"
							</cfif>
							name="Simple_Budget_Class_Association_ID_#rowIdPrefix#" value="#Simple_Budget_Class_Association_ID#"
							<cfif currentChkChecked>checked</cfif>
							onpropertyChange="javascript:budgetCheck(this, '#rowID#', '#rowIdPrefix#', #application.oApplicationAppSettingsManager.getApplicationAppSettings().getBillbackAllowMultipleBudgets()#)"
							></td>
					<td>#Simple_Budget_Class_Desc# (#Simple_Budget_Class_Number#) / #Simple_Budget_Desc# (#Simple_Budget_Number#)</td>
					<td>#Simple_Budget_Class_Association_Number#</td>
					<td align="right">#DollarFormat(Program_Committed_For_Payee)#</td>
					<td align="right" title="#Budget_Balance_Percentage#%">#DollarFormat(Budget_Balance)#</td>
					<td>
					<input type="text" name="billback_budget_percent_#rowID#" maxlength="3" size="1"
						onkeypress="javascript:return Allow_Key_List('0123456789');"
						onChange="if(isNumeric(this.value, 0, 1)){this.value = formatToDecimalPlaces(this.value, 0, 0)}else{this.value = ''};setBudgetAllocatedDollar('#rowID#', '#rowIdPrefix#')"
						Budget_Balance="#Budget_Balance#"
						value="#Current_Allocation_Percent#"
						prev_value="#Current_Allocation_Percent#"
						<cfif not currentChkChecked>disabled</cfif>
						>
					</td>
					<td align="right" id="billback_budget_dollar_#rowID#">#Allocated_Dollar#&nbsp;</td>
					<td align="right" id="post_approval_budget_balance_#rowID#" style="#Balanace_After_Change_Style#">#Balanace_After_Change#&nbsp;</td>
				</tr>
			</cfoutput>
			<!---------------- loop over budgets - end -------------------------->
				
			<script language="javascript">
				document.all.Sp_Percentage_Left_#rowIdPrefix#.innerText = "#100 - totalProgramAllocation#";
			</script>
			
		</cfif>
			
	</cfoutput>
	<!---------------- loop over programs - end -------------------------->
	</table>
	
	<cfoutput>
	<input type="hidden" name="Billback_Program_ID_List" value="#billbackProgramIDList#">
	<input type="hidden" name="Budget_Billback_Payee_Type_ID" value="#qGetBudgetsForBillback.Billback_Payee_Type_ID#">
	<input type="hidden" name="Budget_Billback_Payee_ID" value="#qGetBudgetsForBillback.Payee_ID#">
	</cfoutput>
<cfelse>
	<cfset budgetSelectionOn = false />
</cfif>

