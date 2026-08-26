<!--- get budget class to display --->
<cfset BudgetManager.loadBudgetLabels() />
<cfif isDefined("saveMessage")>
	<cfset Current_Simple_Budget_Class_Number = Form.Simple_Budget_Class_Number />
	<cfset Current_Simple_Budget_Class_Desc = Form.Simple_Budget_Class_Desc />
	<cfset Current_Simple_Budget_Class_Start_Date = Form.Simple_Budget_Class_Start_Date />
	<cfset Current_Simple_Budget_Class_End_Date = Form.Simple_Budget_Class_End_Date />
	<cfif form.id>
		<cfset sAction = "Edit" />
		<cfset qGetBudgetsAndAssociations = BudgetManager.getBudgetsAndAssociations(classId = form.id, active = 1, includeInactiveIfAssociated = 1) />
	<cfelse>
		<cfset sAction = "Add" />
		<cfset qGetBudgetsAndAssociations = BudgetManager.getBudgetsAndAssociations(classId = -1, active = 1, includeInactiveIfAssociated = 0) />
	</cfif>	
<cfelse>
	<cfif form.id>
		<cfset sAction = "Edit" />
		<cfset qGetBudgetClass = BudgetManager.getBudgetClass(id=form.id) />
		<cfset Current_Simple_Budget_Class_Number = qGetBudgetClass.Simple_Budget_Class_Number />
		<cfset Current_Simple_Budget_Class_Desc = qGetBudgetClass.Simple_Budget_Class_Desc />
		<cfset Current_Simple_Budget_Class_Start_Date = DateFormat(qGetBudgetClass.Start_Date, "mm/dd/yyyy") />
		<cfset Current_Simple_Budget_Class_End_Date = DateFormat(qGetBudgetClass.End_Date, "mm/dd/yyyy") />
		<cfset qGetBudgetsAndAssociations = BudgetManager.getBudgetsAndAssociations(classId = form.id, active = 1, includeInactiveIfAssociated = 1) />
	<cfelse>
		<cfset sAction = "Add" />
		<cfset Current_Simple_Budget_Class_Number = "" />
		<cfset Current_Simple_Budget_Class_Desc = "" />
		<cfset Current_Simple_Budget_Class_Start_Date = "" />
		<cfset Current_Simple_Budget_Class_End_Date = "" />
		<cfset qGetBudgetsAndAssociations = BudgetManager.getBudgetsAndAssociations(classId = -1, active = 1, includeInactiveIfAssociated = 0) />
	</cfif>
</cfif>

<cfoutput>
<FIELDSET STYLE="padding:10px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Class Information - #sAction#</LEGEND>
	
	<CFPARAM NAME="saveMessage" DEFAULT="">
	<cfif saveMessage neq "">
		<br>
		<div align="center" style="color:red;font-weight:bold;">**** #saveMessage# ****</div>
		<br>
	</cfif>
	<table width="700">
		<TR>
			<TD ALIGN="right"><B>Class ID:</B></TD>
			<TD width="20">
				<span id="Err_Sp_Simple_Budget_Class_Number"></span></TD><TD>
				<INPUT NAME="Simple_Budget_Class_Number" TYPE="text" value="#HTMLEditFormat(trim(Current_Simple_Budget_Class_Number))#" SIZE="30" MAXLENGTH="15">
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Class Description:</B></TD>
			<TD><span id="Err_Sp_Simple_Budget_Class_Desc"></span></TD><TD><INPUT NAME="Simple_Budget_Class_Desc" TYPE="text" VALUE="#HTMLEditFormat(trim(Current_Simple_Budget_Class_Desc))#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<TR>
			<TD nowrap ALIGN="right"><B>Start & End Dates:</B></TD>
			<TD><span id="Err_Sp_Simple_Budget_Class_Start_Date"></span><span id="Err_Sp_Simple_Budget_Class_End_Date"></span><span id="Err_Sp_Simple_Budget_Class_Start_End_Date"></span></TD>
			<TD>
				<TABLE cellpadding="0" cellspacing="0">
				<TR>
					<TD><CF_EASYDATE FORMNAME="#formName#" FIELDNAME="Simple_Budget_Class_Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Current_Simple_Budget_Class_Start_Date#"></TD>
					<TD><CF_EASYDATE FORMNAME="#formName#" FIELDNAME="Simple_Budget_Class_End_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Current_Simple_Budget_Class_End_Date#"></TD>
				</TR>
				</TABLE>
			</TD>
		</TR>
		<!----*****************************  Budgets - start *******************************---->
		<cfif qGetBudgetsAndAssociations.recordCount>
		<TR valign="top">
			<TD ALIGN="right"><B>Budgets:</B></TD>
			<TD>&nbsp;</TD>
			<TD>
				<table width="550" cellpadding="2" cellspacing="1" bgcolor="##cccccc">
					<tr style="font-weight:bold;" bgcolor="whitesmoke">
						<td>&nbsp;</td>
						<td>##</td>
						<td>Desc</td>
						<td>#BudgetManager.getBudgetClassAssociationLabel()#</td>
						<td width="10">Budget Active</td>
						<td width="10">Association Active</td>
					</tr>
				<cfparam name="Form.Simple_Budget_ID" default="" />
				<cfloop query="qGetBudgetsAndAssociations">
					<cfset currentID = Simple_Budget_ID />
					<cfparam name="Form.Simple_Budget_Class_Association_Number_#currentID#" default="#Simple_Budget_Class_Association_Number#" />
					<cfset budgetClassNumber = Evaluate("Simple_Budget_Class_Association_Number_#currentID#") />
					<cfset bChecked = 0 />
					<cfset bDisabled = 0 />
					<cfset sTitle = "" />
					<cfif Simple_Budget_Class_Association_ID neq "">
						<cfset bChecked = 1 />
						<cfset bDisabled = 1 />
						<cfset sTitle = "To delete/deactivate this selection please use the ''class budget association' tab" />
					<cfelseif ListFind(Form.Simple_Budget_ID, Simple_Budget_ID)>
						<cfset bChecked = 1 />
						<cfset bDisabled = 0 />
						<cfset sTitle = "selection not yet saved" />
					</cfif>
					<tr style="background-color: expression(this.all.Simple_Budget_ID.checked ? 'ffdead' : 'whitesmoke');">
						<td>
							<input type="checkbox" name="Simple_Budget_ID" value="#currentID#"
									Title="#sTitle#"
									<cfif bChecked>checked</cfif>
									<cfif bDisabled>disabled</cfif>
									>							
						</td>
						<td>#Simple_Budget_Number#</td>
						<td>#Simple_Budget_Desc#</td>
						<td><input type="text" name="Simple_Budget_Class_Association_Number_#currentID#" value="#budgetClassNumber#" size="32" maxlength="30">
						<span id="Err_Sp_Simple_Budget_Class_Association_Number_#currentID#"></span>
						</td>
						<td>
						<cfif Budget_Active>
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
		<!----*****************************  Budgets - end *******************************---->
		<TR valign="bottom">
			<TD COLSPAN="100%" ALIGN="center">
			<br><br>
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return verifyAndsubmitBudgetClassForm('saveBudgetClass', '#form.id#', '', '#BudgetManager.getBudgetClassAssociationLabel()#');"""
			>
			<CF_smallLink 
				title = "cancel" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('listBudgetClass');"""
			>
			</TD>
		</TR>
	</table>
</FIELDSET>
<cf_MessageWindow />
</cfoutput>