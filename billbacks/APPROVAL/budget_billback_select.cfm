<!----- budget_billback_select.cfm ------->

<cfparam name="url.BBID" default="">
<cfparam name="form.Billback_ID" default="#url.BBID#">
<cfparam name="form.state" default="0">


<cfif form.Billback_ID neq "">

	<cfif form.state eq "1">
		
		<!---- save into db ---->
		<cfset BudgetBillbackManager = CreateObject("component", "components.budgets.BudgetBillbackManager").init() />
		<cfset bSetToPendingFundUpdate = BudgetBillbackManager.saveBudgetBillback(
					billbackId = form.Billback_ID,
					oForm = form,
					userID = request.AccessStructure.user_id) />
		
		<cfif bSetToPendingFundUpdate>
		
			<!----- go to summary page ------>
			<cflocation url="/billbacks/capture/Billback_Summary.cfm?BBID=#form.Billback_ID#">
		
		<cfelse>
		
			<cfset fromBudgetPage = 1 />
			<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
			<cfinclude template="Get_Payment_Next_Page.cfm" />
			
			<cfquery name="GetBillbackInfo" datasource="#application.datasource#">
				SELECT 	*
				FROM 	Billback
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!-----
			<cflocation url="#ActionPage#?Billback_ID=#form.Billback_ID#&new_bb_check=1&PayeeType=#GetBillbackInfo.Billback_Payee_Type_ID#">
			--->
			<cflocation url="/Billbacks/Approval/Payment_Display.cfm?Billback_ID=#form.Billback_ID#&new_bb_check=1&PayeeType=#GetBillbackInfo.Billback_Payee_Type_ID#">
			
		</cfif>
		
		
	</cfif>
	<html>
	<head>
		<title>Billback Budget Selection</title>		
	</head>
	<body>
		
		<!---- the top header ------>
		<CFSET InfoBar_BBID = form.Billback_ID>
		<cfinclude template="../capture/billback_load_infobar.cfm" />
		
		<!---- show billback status ------>
		<cfset BillbackSummaryManager = CreateObject("component", "components.billback.BillbackSummaryManager") />
		<cfset qGetBillbackStatus = BillbackSummaryManager.getBillbackStatus(
					billbackId = form.Billback_ID) />
					
		<cfoutput>
		<cfset headerStyle = "id=""header"" style=""font-weight:bold;""">
		<CFSET StatusDisplay_CELLSPACING	= 4>
		<CFSET StatusDisplay_CELLPADDING	= 0>
		<CFSET StatusDisplay_FONTCOLOR		= "white">
		<CFSET StatusDisplay_CELLBGCOLOR	= "green">
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_DisplayText 	= qGetBillbackStatus.BB_Status_Description />
		<br>
		<TABLE
			BORDER="0"
			CELLSPACING="#StatusDisplay_CELLSPACING#"
			CELLPADDING="#StatusDisplay_CELLPADDING#"
			WIDTH="100%"
			BGCOLOR="#StatusDisplay_BGCOLOR#">
		<TR>
			<TD BGCOLOR="#StatusDisplay_CELLBGCOLOR#" WIDTH="100%"><FONT COLOR="#StatusDisplay_FONTCOLOR#" SIZE="3"><B>#StatusDisplay_DisplayText#</B></FONT>
			</TD>
		</TR>
		</TABLE>
		</cfoutput>
		
		<!---- show the budget selection form ------>
		<form method="post" name="frmBudgetBillbackSelect" action="budget_billback_select.cfm">
		<cfinclude template="budget_billback_select_include.cfm">
		<cfoutput>
		<input type="hidden" name="state" value="1">
		<input type="hidden" name="Billback_ID" value="#form.Billback_ID#">
		</cfoutput>
		</form>
		
		<br><br>
		<center>
		<CF_button
			button_name		=	""
			button_caption	=	"save budget"
			button_action	=	"validateAndSaveBudgetSelection();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"execute"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		</center>
		<br><br><br><br><br>
		<script>
		  var url = '<cfoutput>#cgi.script_name#</cfoutput>';
	        
			if (url == '/Billbacks/common/bb_printer_friendly.cfm')
	        {
	          // do nothing
	        }
			else {
			try { window.parent.dyniframesize(); } catch (err) { };
			}
	   </script>	
		<cf_MessageWindow />
	</body>
	</html>
	
	<!----
	
	<CFSET InfoBar_BBID = Billback_ID>
	<cfinclude template="../capture/billback_load_infobar.cfm" />

	<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
	<cfset BudgetBillbackManager = CreateObject("component", "components.budgets.BudgetBillbackManager").init() />
	<cfset BillbackSummaryManager = CreateObject("component", "components.billback.BillbackSummaryManager") />
	<cfset BudgetManager.loadBudgetLabels() />

	<cfset qGetBudgetsForBillback = BudgetBillbackManager.getBudgetsForBillback(
					billbackId = form.Billback_ID) />
	<cfset qGetBillbackStatus = BillbackSummaryManager.getBillbackStatus(
					billbackId = form.Billback_ID) />
	
	<html>
	<head>
		<title>Billback Payment</title>
		<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
		<cfinclude template="/billbacks/capture/iframe_style.cfm">
		<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
		<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

		<script language="javascript">
			function validateAndSaveBudgetSelection()
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
						queueMessage("Allocation should add up to 100%", errSpAllocationMatch100);
					}
					else
					{
						clearQueue(errSpAllocationMatch100);
					}
					
					
				}//loop on each program
					
				if(allValid)
				{
					document.frmBudgetBillbackSelect.submit();
				}
				else
				{
					showMessageWindow();
				}
				
			}
			
			function setBudgetAllocatedDollar(cellID, rowIDPrefix)
			{	
				var allocatedPercentInp = eval('document.all.billback_budget_percent_' + cellID);
				var allocatedDollarDiv = eval('document.all.billback_budget_dollar_' + cellID);
				var iDollar = eval('document.all.Billback_Program_Dollar_' + rowIDPrefix + '.value');
				var billbackProgramDollar = parseFloat(iDollar);
				if(!isNaN(billbackProgramDollar) && allocatedPercentInp && allocatedDollarDiv)
				{
					var allocatedPercent = parseFloat(allocatedPercentInp.value);
					if(isNaN(allocatedPercent)) allocatedPercent = 0;
					if(allocatedPercentInp.disabled) allocatedPercent = 0;
		
					var allocatedDollar = allocatedPercent * 0.01 * billbackProgramDollar;
					allocatedDollarDiv.innerText = formatDollar(allocatedDollar, 2, 1, 3);
					
					// show balance after apporval
				}
				//programBudgetValid();
			}
			
			function budgetCheck(oChk, rowID, rowIDPrefix)
			{
				if(event.propertyName == 'checked')
				{
					var allocatedPercentInp = eval('document.all.billback_budget_percent_' + rowID);
					allocatedPercentInp.disabled = !oChk.checked;						
					setBudgetAllocatedDollar(rowID, rowIDPrefix);															
				}
			}
			
		</script>
		
	</head>
	<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
	
	<cfoutput>	
	<cfset headerStyle = "id=""header"" style=""font-weight:bold;""">
	<CFSET StatusDisplay_CELLSPACING	= 4>
	<CFSET StatusDisplay_CELLPADDING	= 0>
	<CFSET StatusDisplay_FONTCOLOR		= "white">
	<CFSET StatusDisplay_CELLBGCOLOR	= "green">
	<CFSET StatusDisplay_BGCOLOR		= "green">
	<CFSET StatusDisplay_DisplayText 	= qGetBillbackStatus.BB_Status_Description />
	<TABLE
		BORDER="0"
		CELLSPACING="#StatusDisplay_CELLSPACING#"
		CELLPADDING="#StatusDisplay_CELLPADDING#"
		WIDTH="100%"
		BGCOLOR="#StatusDisplay_BGCOLOR#">
	<TR>
		<TD BGCOLOR="#StatusDisplay_CELLBGCOLOR#" WIDTH="100%"><FONT COLOR="#StatusDisplay_FONTCOLOR#" SIZE="3"><B>#StatusDisplay_DisplayText#</B></FONT>
		</TD>
	</TR>
	</TABLE>
	
	<form name="frmBudgetBillbackSelect" method="post">
	<div align="center" style="font-size:14px;font-weight:bold;">select budget</div>
	<br>
	<table cellpadding="3" cellspacing="1" class="MainTable" align="center">
	<tr bgcolor="ffdead">
		<td>&nbsp;</td>
		<td #headerStyle#>Class / Budget</td>
		<td #headerStyle#>#BudgetManager.getBudgetClassAssociationLabel()#</td>
		<td #headerStyle#>#BudgetManager.getCommittedDollarLabel()#</td>
		<td #headerStyle#>#BudgetManager.getBudgetBalanceLabel()#</td>
		<td #headerStyle#>Allocated %</td>
		<td #headerStyle#>Allocated $</td>
	</tr>
	</cfoutput>
	<cfset billbackProgramIDList = "" />
	<cfoutput query="qGetBudgetsForBillback" group="Contract_Number">
	<cfset rowIdPrefix = replace(Billback_Program_ID, "-", "_", "all") />
	<tr>
		<td colspan="100%" bgcolor="ccffcc">[#Contract_Number#] #Contract_Title# - <b>#DollarFormat(Billback_Program_Paid_Amount)#</b>
		<span id="Err_Sp_Allocation_Match_100_#rowIdPrefix#"></span>
		<input type="hidden" name="Billback_Program_Dollar_#rowIdPrefix#" value="#Billback_Program_Paid_Amount#">
		<cfset billbackProgramIDList = ListAppend(billbackProgramIDList, Billback_Program_ID) />
		</td>
	</tr>
	<cfoutput>	
	<cfset rowID = rowIdPrefix & "_"& Simple_Budget_Class_Association_ID />
	<cfset Current_Allocation_Percent = Allocated_Percent />
	<cfset Budget_Balance = 0 />
	<cfset currentChkChecked = 0 />
	<cfif IsNumeric(Current_Allocation_Percent)>
		<cfset Allocated_Dollar = DollarFormat(Current_Allocation_Percent * 0.01 * Billback_Program_Paid_Amount) />
		<cfset currentChkChecked = 1 />
	<cfelse>
		<cfset Allocated_Dollar = "" />
	</cfif>
	<tr>
		<td><input type="checkbox" name="Simple_Budget_Class_Association_ID_#rowIdPrefix#" value="#Simple_Budget_Class_Association_ID#"
				<cfif currentChkChecked>checked</cfif>
				onpropertyChange="javascript:budgetCheck(this, '#rowID#', '#rowIdPrefix#')"
				></td>
		<td>#Simple_Budget_Desc# (#Simple_Budget_Number#) / #Simple_Budget_Class_Desc# (#Simple_Budget_Class_Number#)</td>
		<td>#Simple_Budget_Class_Association_Number#</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
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
		<td><div id="billback_budget_dollar_#rowID#">#Allocated_Dollar#</div>&nbsp;</td>
	</tr>
	</cfoutput>
	</cfoutput>
		</table>
		<cfoutput>
		<input type="hidden" name="state" value="1">
		<input type="hidden" name="Billback_ID" value="#form.Billback_ID#">
		<input type="hidden" name="Billback_Program_ID_List" value="#billbackProgramIDList#">
		</cfoutput>
	</form>
	
	<center>
		<CF_button
			button_name		=	""
			button_caption	=	"save budget"
			button_action	=	"validateAndSaveBudgetSelection();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"execute"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</center>
	<br><br><br><br><br>
	
	<cfset local_bbid = Billback_ID>
	<cfinclude template="/Billbacks/capture/bb_menu_stats.cfm">
	<!--- BSD 11544 --->
	<script>
	  var url = '<cfoutput>#cgi.script_name#</cfoutput>';
        
		if (url == '/Billbacks/common/bb_printer_friendly.cfm')
        {
          // do nothing
        }
		else {
		try { window.parent.dyniframesize(); } catch (err) { };
		}
   </script>	
<cf_MessageWindow />
</BODY>
</html> 
---->
</cfif>