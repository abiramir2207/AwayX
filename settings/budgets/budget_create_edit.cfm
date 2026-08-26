<!--- get budget to display --->
<cfset BudgetManager.loadBudgetLabels() />
<cfif form.id>
	<cfset sAction = "Edit" />
	<cfset qGetBudget = BudgetManager.getBudget(id=form.id) />
	<cfset Current_Simple_Budget_Number = qGetBudget.Simple_Budget_Number />
	<cfset Current_Simple_Budget_Desc = qGetBudget.Simple_Budget_Desc />
	<cfset qGetClassesAndAssociations = BudgetManager.getClassesAndAssociations(budgetId = form.id, active = 1, includeInactiveIfAssociated = 1) />
<cfelse>
	<cfset sAction = "Add" />
	<cfset Current_Simple_Budget_Number = "" />
	<cfset Current_Simple_Budget_Desc = "" />
	<cfset qGetClassesAndAssociations = BudgetManager.getClassesAndAssociations(budgetId = -1, active = 1, includeInactiveIfAssociated = 0) />
</cfif>

<cfoutput>
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Budget Information - #sAction#</LEGEND>
	<table width="500">
		<TR>
			<TD ALIGN="right"><B>Budget ID:</B></TD>
			<TD width="20">
				<span id="Err_Sp_Simple_Budget_Number"></span></TD><TD>
				<INPUT NAME="Simple_Budget_Number" TYPE="text" value="#HTMLEditFormat(trim(Current_Simple_Budget_Number))#" SIZE="30" MAXLENGTH="50">
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Budget Description:</B></TD>
			<TD><span id="Err_Sp_Simple_Budget_Desc"></span></TD><TD><INPUT NAME="Simple_Budget_Desc" TYPE="text" VALUE="#HTMLEditFormat(trim(Current_Simple_Budget_Desc))#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!----*****************************  Classes - start *******************************---->
		<cfif qGetClassesAndAssociations.recordCount>
		<TR valign="top">
			<TD ALIGN="right"><B>Classes:</B></TD>
			<TD>&nbsp</TD>
			<TD>
				<table width="550" cellpadding="2" cellspacing="1" bgcolor="##cccccc">
					<tr style="font-weight:bold;" bgcolor="whitesmoke">
						<td>&nbsp;</td>
						<td>##</td>
						<td>Desc</td>
						<td>#BudgetManager.getBudgetClassAssociationLabel()#</td>
						<td width="10">Class Active</td>
						<td width="10">Association Active</td>
					</tr>
				<cfparam name="Form.Simple_Budget_Class_ID" default="" />
				<cfloop query="qGetClassesAndAssociations">
					<cfset currentID = Simple_Budget_Class_ID />
					<cfparam name="Form.Simple_Budget_Class_Association_Number_#currentID#" default="#Simple_Budget_Class_Association_Number#" />
					<cfset budgetClassNumber = Evaluate("Simple_Budget_Class_Association_Number_#currentID#") />
					<cfset bChecked = 0 />
					<cfset bDisabled = 0 />
					<cfset sTitle = "" />
					<cfif Simple_Budget_Class_Association_ID neq "">
						<cfset bChecked = 1 />
						<cfset bDisabled = 1 />
						<cfset sTitle = "To delete/deactivate this selection please use the ''class budget association' tab" />
					<cfelseif ListFind(Form.Simple_Budget_Class_ID, currentID)>
						<cfset bChecked = 1 />
						<cfset bDisabled = 0 />
						<cfset sTitle = "selection not yet saved" />
					</cfif>
					<tr style="background-color: expression(this.all.Simple_Budget_Class_ID.checked ? 'ffdead' : 'whitesmoke');">
						<td>
							<input type="checkbox" name="Simple_Budget_Class_ID" value="#currentID#"
									Title="#sTitle#"
									<cfif bChecked>checked</cfif>
									<cfif bDisabled>disabled</cfif>
									>							
						</td>
						<td>#Simple_Budget_Class_Number#</td>
						<td>#Simple_Budget_Class_Desc#</td>
						<td><input type="text" name="Simple_Budget_Class_Association_Number_#currentID#" value="#budgetClassNumber#" size="32" maxlength="30">
						<span id="Err_Sp_Simple_Budget_Class_Association_Number_#currentID#"></span>
						</td>
						<td>
						<cfif Budget_Class_Active>
						<img src="/images/yes_small.gif" border="0">
						<cfelse>
						<img src="/images/no_small.gif" border="0" title="this budget is no longer active">
						</cfif>
						</td>
						<td>
						<cfif Simple_Budget_Class_Association_Active eq "1">
						<img src="/images/yes_small.gif" border="0">
						<cfelseif Simple_Budget_Class_Association_Active eq "0">
						<img src="/images/no_small.gif" border="0" title="this class budget association is no longer active">
						<cfelse>&nbsp;
						</cfif>
						</td>
					</tr>
				</cfloop>
				</table>
			</TD>
		</TR>
		</cfif>
		<!----*****************************  Classes - end *******************************---->
		<TR valign="bottom">
			<TD COLSPAN="100%" ALIGN="center">
			<br><br><br>
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return verifyAndsubmitBudgetForm('saveBudget', '#form.id#', '', '#BudgetManager.getBudgetClassAssociationLabel()#');"""
			>
			<CF_smallLink 
				title = "cancel" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('cancel');"""
			>
			</TD>
		</TR>
	</table>
</FIELDSET>
<cf_MessageWindow />
</cfoutput>