<!--- get budget labels to display --->
<cfset BudgetManager.loadBudgetLabels() />
<cfset oBudgetClassManager = createObject('component','mvc.Models.AdvancedBudget.BudgetClassManager') />
<cfset qGetBudgetClass = oBudgetClassManager.getBudgetClass() />
<!---

INSERT INTO Simple_Budget_Labels (Budget_Dollar_Label, Committed_Dollar_Label,
Budget_Balance_Label, Approved_Payment_Dollar_Label, Available_Budget_Dollar_Label)
VALUES ('Budget Dollars', 'Committed Dollars', 'Budget Balance', 'Approved Payment Dollars', 'Available Budget Dollars')

--->
<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
.action { font-weight:bold; margin:0 3px 0 3px; }
</style>
</cfsavecontent>

<cfhtmlhead text="#vars.htmlHead#">
<cfoutput>
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Budget Labels - Edit</LEGEND>
	<table width="500">
		<TR>
			<TD ALIGN="right"><B>Budget Dollars:</B></TD>
			<TD width="20">
				<span id="Err_Sp_Budget_Dollar_Label"></span></TD><TD>
				<INPUT NAME="Budget_Dollar_Label" TYPE="text" value="#BudgetManager.getBudgetDollarLabel()#" SIZE="30" MAXLENGTH="50" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Committed Dollars:</B></TD>
			<TD width="20">
				<span id="Err_Sp_Committed_Dollar_Label"></span></TD><TD>
				<INPUT NAME="Committed_Dollar_Label" TYPE="text" value="#BudgetManager.getCommittedDollarLabel()#" SIZE="30" MAXLENGTH="50" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Budget Balance:</B></TD>
			<TD width="20">
				<span id="Err_Sp_Budget_Balance_Label"></span></TD><TD>
				<INPUT NAME="Budget_Balance_Label" TYPE="text" value="#BudgetManager.getBudgetBalanceLabel()#" SIZE="30" MAXLENGTH="50" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Approved Payment Dollars:</B></TD>
			<TD width="20">
				<span id="Err_Sp_Approved_Payment_Dollar_Label"></span></TD><TD>
				<INPUT NAME="Approved_Payment_Dollar_Label" TYPE="text" value="#BudgetManager.getApprovedPaymentDollarLabel()#" SIZE="30" MAXLENGTH="50" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Available Budget Dollars:</B></TD>
			<TD width="20">
				<span id="Err_Sp_Available_Budget_Dollar_Label"></span></TD><TD>
				<INPUT NAME="Available_Budget_Dollar_Label" TYPE="text" value="#BudgetManager.getAvailableBudgetDollarLabel()#" SIZE="30" MAXLENGTH="50" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Class Budget Association Label:</B></TD>
			<TD width="20">
				<span id="Err_Sp_Available_Budget_Dollar_Label"></span></TD><TD>
				<INPUT NAME="Budget_Class_Association_Label" TYPE="text" value="#BudgetManager.getBudgetClassAssociationLabel()#" SIZE="30" MAXLENGTH="50" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
			</TD>
		</TR>
		<tr>
			<td colspan="100%">
				<table class="datagrid">
					<thead>
					<tr>
						<th><b>Code</b></th>
						<th><b>Description</b></th>
						<th><b>Default Filter On</b></th>
					</tr>
					</thead>
					<tbody>
					<cfloop query="qGetBudgetClass">
					<tr>
						<td>#qGetBudgetClass.Budget_Class_Number#</td>
						<td>#qGetBudgetClass.Budget_Class_Desc#</td>
						<td><input name="Default_Filter_#Budget_Class_ID#" type="checkbox" value="1" <cfif qGetBudgetClass.Default_Filter eq 1>checked</cfif> <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>/></td>
					</tr>
					</cfloop>
					</tbody>
				</table>
			</td>
		</tr>
		<TR valign="bottom">
			<TD COLSPAN="100%" ALIGN="center">
			<br><br><br>
			<CFIF qGetCreateBudget.Create_Budget>
					<CF_smallLink
						title = "save"
						url = "##"
						parameters = "onClick=""javascript: return verifyAndsubmitBudgetLabelForm('saveBudgetLabel');"""
					>
			</CFIF>
			</TD>
		</TR>
	</table>
</FIELDSET>
<cf_MessageWindow />
<input name="lBudgetClassIDs" type="hidden" value="#ValueList(qGetBudgetClass.Budget_Class_ID)#" />
</cfoutput>

