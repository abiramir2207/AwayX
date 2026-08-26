<!---- budget_program_select.cfm ---->
<cfset tdStyle=" style=""border:none;font-weight:bold;"" nowrap" />
<cfset programGettingApproved = 0 />
<cfif getProgramInfo.Contract_Status_Type_IDX LTE 2>
	<cfset programGettingApproved = 1 />
</cfif>
<cfset qGetTemplateBudgets = BudgetManager.getBudgetTemplateMappingForProgram(
				programId = CONTRACT_MAIN_ID, 
				templateParentId = template.getFirstParentID(),
				userPositionId = getProgramInfo.Creating_User_Position_ID,
				programApproval = programGettingApproved) />
<cfoutput>
		
<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<tr><td colspan="100%"><table cellpadding="2" cellspacing="0" width="100%">
<cfparam name="Budget_Program_Spend" default="0">
<!---<cfset Budget_Program_Spend = Val(Round(Program_Spend)) />--->
<script language="javascript">
	var Budget_Program_Spend = parseFloat("#Budget_Program_Spend#");
	
	function getProgramBudgetAllocation(allocatedPercentInp)
	{
		var allocatedPercent = parseFloat(allocatedPercentInp.value);
		if(isNaN(allocatedPercent)) allocatedPercent = 0;
		
		return allocatedPercent;
	}
	function getProgramBudgetDollar(allocatedPercentInp)
	{
		return getProgramBudgetAllocation(allocatedPercentInp) * 0.01 * Budget_Program_Spend;
	}
	function setBudgetAllocatedDollar(cellID)
	{	
		var allocatedPercentInp = eval('document.all.program_budget_percent_' + cellID);
		var allocatedDollarDiv = eval('document.all.program_budget_dollar_' + cellID);
		var postApprovalBalanceDiv = eval('document.all.post_approval_budget_balance_' + cellID);
		
		if(!isNaN(Budget_Program_Spend) && allocatedPercentInp && allocatedDollarDiv)
		{
			var allocatedDollar = getProgramBudgetDollar(allocatedPercentInp);
			
			// if allocatedDollar is 0, don't show allocated dollar and balance after approval
			if(allocatedDollar == 0)
			{
				allocatedDollarDiv.innerText = "";
				if(postApprovalBalanceDiv)
				{
					postApprovalBalanceDiv.innerText = "";
				}
			}
			else
			{
				allocatedDollarDiv.innerText = formatDollar(allocatedDollar, 2, 1, 3);
				
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
		}
		programBudgetValid();
	}
	
	function programBudgetValidateOnApprove()
	{
		<cfif not qGetTemplateBudgets.recordCount>
			return true;
		</cfif>
		var cellID, allocatedPercentInp, allocatedDollar, currentBudgetBalance, postApprovalBudgetBalance;
		var rowList = document.all.Simple_Budget_Template_Mapping_ID_List.value;
		var arRows = rowList.split(",");
		var rowLen = arRows.length;
		var totalBudgetAllocation = 0;
		
		for(i=0; i<rowLen; i++)
		{
			cellID = arRows[i];
			allocatedPercentInp = eval('document.all.program_budget_percent_' + cellID);
			if(!isNaN(Budget_Program_Spend) && allocatedPercentInp)
			{
				var allocatedPercent = getProgramBudgetAllocation(allocatedPercentInp);
				totalBudgetAllocation = totalBudgetAllocation + allocatedPercent;
			}
		
		}
			
		if(totalBudgetAllocation != 100 && rowLen > 0)//do nto prompt the user if the template does not have a budget at all.
		{
			alert("In order to continue you are required to allocate budget to 100%.");
			return false;
		}
		else
		{
			return true;
		}
	}
	
	function programBudgetValid()
	{
		var cellID, allocatedPercentInp, allocatedDollar, currentBudgetBalance, postApprovalBudgetBalance;
		var rowList = document.all.Simple_Budget_Template_Mapping_ID_List.value;
		var arRows = rowList.split(",");
		var rowLen = arRows.length;
		var allValid = true;
		var totalBudgetAllocation = 0;
		
		for(i=0; i<rowLen; i++)
		{
			cellID = arRows[i];
			allocatedPercentInp = eval('document.all.program_budget_percent_' + cellID);
			if(!isNaN(Budget_Program_Spend) && allocatedPercentInp)
			{
				var allocatedPercent = getProgramBudgetAllocation(allocatedPercentInp);
				// if allocatedPercent is 0, don't validate that row
				if(allocatedPercent > 0)
				{
					totalBudgetAllocation = totalBudgetAllocation + allocatedPercent;
					
					allocatedDollar = getProgramBudgetDollar(allocatedPercentInp);
					
					currentBudgetBalance = parseFloat(allocatedPercentInp.Budget_Balance);
					if(isNaN(currentBudgetBalance)) currentBudgetBalance = 0;
					postApprovalBudgetBalance = currentBudgetBalance - allocatedDollar;
					
					if(postApprovalBudgetBalance < 0)
					{
						allValid = false;
						break;
					}
				}	
			}
		
		}
		
		if(allValid)
		{
			<cfif Get_Profile_Settings.Approve_Pgm_Beyond_Budget EQ 0>
			changeApproveAgreeActionBudget(0);
			changeApproveLabel();
			</cfif>
		}
		else
		{
			<cfif Get_Profile_Settings.Approve_Pgm_Beyond_Budget EQ 0>
			changeApproveAgreeActionBudget(1);
			changeApproveLabel();
			</cfif>
		}
	}
	
	function changeApproveAgreeActionBudget(bAgree)
	{
		var objAgreeApproveStatus = document.all.Budget_Agree_Approve_Status;
		var bAgreeApproveStatus = objAgreeApproveStatus.value;
		var spCheckAllProducts, i, chkObj, spApproveAgreeLabel, spObjApproveAgreeLabel;
		if(bAgree)
		{
			if(bAgreeApproveStatus == "0") // if the program was not changed to agree, change to agree
			{
				spCheckAllProducts = document.all.checkAllProducts;
				if(spCheckAllProducts)
				{
					if(spCheckAllProducts.length)
					{
						for(i=0;i<spCheckAllProducts.length;i++)
						{
							chkObj = spCheckAllProducts[i].firstChild;
							if(chkObj && chkObj.original_name && chkObj.idToken)
							{
								re = /Approve/g; 
								chkObj.name = chkObj.original_name.replace(re, "Agree");
								
								
								spObjApproveAgreeLabel = eval("document.all.approve_agree_label_" + chkObj.idToken);
								if(spObjApproveAgreeLabel && spObjApproveAgreeLabel.original_approve_agree_label && spObjApproveAgreeLabel.original_approve_agree_label != 'Approved')
								{
									spObjApproveAgreeLabel.innerText = "Agree";							
								}			
							}
						}
					}
					else
					{
							chkObj = spCheckAllProducts.firstChild;
							if(chkObj && chkObj.original_name && chkObj.idToken)
							{
								re = /Approve/g; 
								chkObj.name = chkObj.original_name.replace(re, "Agree");
								
								spObjApproveAgreeLabel = eval("document.all.approve_agree_label_" + chkObj.idToken);
								if(spObjApproveAgreeLabel && spObjApproveAgreeLabel.original_approve_agree_label && spObjApproveAgreeLabel.original_approve_agree_label != 'Approved')
								{
									spObjApproveAgreeLabel.innerText = "Agree";							
								}							
							}
					}
				}
					
				// save the current setting
				objAgreeApproveStatus.value = "1";
				document.all.tr_budget_cannot_approve_message.style.display = "";
			}			 
		}
		else
		{
			if(bAgreeApproveStatus == "1") // if the program was ever changed to agree, reset to original
			{
				spCheckAllProducts = document.all.checkAllProducts;
				if(spCheckAllProducts)
				{
					if(spCheckAllProducts.length)
					{
						for(i=0;i<spCheckAllProducts.length;i++)
						{
							chkObj = spCheckAllProducts[i].firstChild;
							if(chkObj && chkObj.original_name && chkObj.idToken)
							{
								chkObj.name = chkObj.original_name;
								
								spObjApproveAgreeLabel = eval("document.all.approve_agree_label_" + chkObj.idToken);
								if(spObjApproveAgreeLabel && spObjApproveAgreeLabel.original_approve_agree_label)
								{
									spObjApproveAgreeLabel.innerText = spObjApproveAgreeLabel.original_approve_agree_label;				
								}							
							}
						}
					}
					else
					{
							chkObj = spCheckAllProducts.firstChild;
							if(chkObj && chkObj.original_name && chkObj.idToken)
							{
								chkObj.name = chkObj.original_name;
								
								spObjApproveAgreeLabel = eval("document.all.approve_agree_label_" + chkObj.idToken);
								if(spObjApproveAgreeLabel && spObjApproveAgreeLabel.original_approve_agree_label)
								{
									spObjApproveAgreeLabel.innerText = spObjApproveAgreeLabel.original_approve_agree_label;				
								}							
							}
					}
				}
				
				// save the current setting
				objAgreeApproveStatus.value = "0";
				document.all.tr_budget_cannot_approve_message.style.display = "none";
			}
		}
	}
</script>
<cfif qGetTemplateBudgets.recordCount>
<tr bgcolor="ffdead">
	<td #tdStyle#>#BudgetManager.getBudgetClassAssociationLabel()#</td>
	<td #tdStyle#>#BudgetManager.getBudgetDollarLabel()#</td>
	<td #tdStyle#>-</td>
	<td #tdStyle#>#BudgetManager.getCommittedDollarLabel()#</td>
	<td #tdStyle#>=</td>
	<td #tdStyle#>#BudgetManager.getBudgetBalanceLabel()#</td>
	<td #tdStyle#>Overall Constraint
	<CF_SmallHelp
		imgPath="/Images/i.gif"
		imgWidth="12"
		imgHeight="11"
		width="200"
		>
		<table>
		<tr>
		<td style="border:none;">
		<center><b>*** Overall Constraint ***</b></center><br>
		The overall constraint represents a higher level budget value beyond the amount allocated.  
		<br>The value displayed represents the balance of dollars available for additional commitments against that macro budget.  
		<br>In some scenarios, the allocated budget balance may be greater than the balance remaining in the overall budget.  
		<br>In that case, additional commitments may require special approval.
		</td>
		</tr>
		</table>
	</CF_SmallHelp>
	</td>
	<td #tdStyle#>Allocated %</td>
	<td #tdStyle#>Allocated $</td>
	<cfif getProgramInfo.Contract_Status_Type_IDX LTE 2>
	<td #tdStyle#>Balance after approval</td>
	</cfif>
</tr>
<cfset programAgreeOnlyForBudgetDollar = 0 /><!--- set this flag so that we can show "agree" link at the bottom --->
<cfloop query="qGetTemplateBudgets">
<cfset rowID = Simple_Budget_Template_Mapping_ID />

<!--- budget level values --->
<cfset Budget_Level_Budget_Dollar = Budget_Dollar />
<cfset Budget_Level_Committed_Dollar = Committed_Dollar />
<cfset Budget_Level_Actual_Dollar = 0 />
<cfset qGetBudgetTemplateActualDollar = BudgetManager.getBudgetTemplateActualDollar(templateMappingId=Simple_Budget_Template_Mapping_ID) />
<cfif qGetBudgetTemplateActualDollar.recordCount>
	<cfset Budget_Level_Actual_Dollar = qGetBudgetTemplateActualDollar.Actual_Dollar />
</cfif>

<!--- Get committed dollar from current program for this budget --->
<cfset iCurrentProgramCommittedDollar = BudgetManager.getBudgetCommittedProgramDollar(BudgetID=Simple_Budget_ID,BudgetClassID=Simple_Budget_Class_ID,contractNumber = getProgramInfo.Contract_Number) />
<cfset Budget_Level_Committed_Dollar = Budget_Level_Committed_Dollar - iCurrentProgramCommittedDollar />

<cfset Budget_Level_Budget_Balance = Budget_Level_Budget_Dollar - Budget_Level_Committed_Dollar />
<cfif Budget_Level_Actual_Dollar GT Budget_Level_Committed_Dollar>
	<cfset Budget_Level_Budget_Balance = Budget_Level_Budget_Dollar - Budget_Level_Actual_Dollar />
</cfif>

<!--- find the real available balance --->
<cfset Row_Budget_Balance = Position_Budget_Balance />
<cfif Budget_Level_Budget_Balance LT Row_Budget_Balance>
	<cfset Row_Budget_Balance = Budget_Level_Budget_Balance />
</cfif>

<cfset Current_Allocation_Percent = Allocation_Percent />
<cfif NOT isNumeric(Current_Allocation_Percent) AND qGetTemplateBudgets.recordCount eq 1>
	<cfset Current_Allocation_Percent = 100 />
</cfif>
<cfif isNumeric(Current_Allocation_Percent)>
	<cfset iProgramBudgetDollar = Current_Allocation_Percent * 0.01 * Budget_Program_Spend />
	<cfset iPostApprovalBudgetBalance = Row_Budget_Balance - iProgramBudgetDollar />
	
	
	<cfset programBudgetDollar = DollarFormat(iProgramBudgetDollar) />
	<cfset postApprovalBudgetBalance = DollarFormat(iPostApprovalBudgetBalance) />
		
	<cfif iPostApprovalBudgetBalance lt 0>
		<cfset postApprovalBudgetBalanceStyle = "color:red;" />
		<cfif Get_Profile_Settings.Approve_Pgm_Beyond_Budget EQ 0>
			<cfset programAgreeOnlyForBudgetDollar = 1 />
		</cfif>
	<cfelse>
		<cfset postApprovalBudgetBalanceStyle = "" />
	</cfif>	
<cfelse>
	<cfset programBudgetDollar = "" />
	<cfset postApprovalBudgetBalance = "" />
	<cfset postApprovalBudgetBalanceStyle = "" />
</cfif>
<tr bgcolor="ffdead">
	<td #tdStyle#>#Simple_Budget_Desc# (#Simple_Budget_Class_Association_Number#)</td>
	<td #tdStyle#>#DollarFormat(Position_Budget_Dollar)#</td>
	<td #tdStyle#>-</td>
	<td #tdStyle#>#DollarFormat(Position_Committed_Dollar)#</td>
	<td #tdStyle#>=</td>
	<td #tdStyle# <cfif Position_Budget_Balance lt 0> style="color:red"</cfif>>#DollarFormat(Position_Budget_Balance)#</td>
	<td #tdStyle# <cfif Row_Budget_Balance lt 0> style="color:red"</cfif>>
	<cfif Position_Budget_Balance GT Row_Budget_Balance>
		#DollarFormat(Row_Budget_Balance)#
	</cfif>
	</td>
	<td #tdStyle#>
		<input type="text" name="program_budget_percent_#rowID#" maxlength="3" size="1"
			onkeypress="javascript:return Allow_Key_List('0123456789');"
			onChange="if(isNumeric(this.value, 0, 1)){this.value = formatToDecimalPlaces(this.value, 0, 0)}else{this.value = ''};setBudgetAllocatedDollar('#rowID#')"
			Budget_Balance="#Row_Budget_Balance#"
			value="#Current_Allocation_Percent#"
			<cfif getProgramInfo.Contract_Status_Type_IDX NEQ 2>disabled</cfif>
			>
	</td>
	<td #tdStyle#><div id="program_budget_dollar_#rowID#">#programBudgetDollar#</div></td>
	<cfif getProgramInfo.Contract_Status_Type_IDX LTE 2>
	<td #tdStyle#><div id="post_approval_budget_balance_#rowID#" style="#postApprovalBudgetBalanceStyle#">#postApprovalBudgetBalance#</div></td>
	</cfif>
</tr>
</cfloop>
<tr id="tr_budget_cannot_approve_message" style="display:none;">
<td colspan="100%" style="color:red;border:none;">You cannot approve programs over the budget balance.</td>
</tr>
</table>
<input type="hidden" name="Budget_Agree_Approve_Status" value="0" />
<input type="hidden" name="Simple_Budget_Template_Mapping_ID_List" value="#ValueList(qGetTemplateBudgets.Simple_Budget_Template_Mapping_ID)#" />
<script language="javascript">
<cfif Get_Profile_Settings.Approve_Pgm_Beyond_Budget EQ 0 and bProgramFinalApprove and programAgreeOnlyForBudgetDollar>
	programBudgetValid();	
</cfif>
</script>
</td></tr>
</cfif>

<cfset stMassApproval.budgetCount = qGetTemplateBudgets.recordCount />
<cfif qGetTemplateBudgets.recordCount EQ 1>
	<cfset stMassApproval.Simple_Budget_Template_Mapping_ID_List = qGetTemplateBudgets.Simple_Budget_Template_Mapping_ID />
	<cfset stMassApproval["program_budget_percent_#qGetTemplateBudgets.Simple_Budget_Template_Mapping_ID#"] = 100 />
</cfif>

</cfoutput>
