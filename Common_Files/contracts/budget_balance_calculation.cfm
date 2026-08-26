<cfparam name="url.Program_ID" default="0">

<cfset program = CreateObject("component", "components.programs.Program") />
<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />

<cfset qGetProgramInfo = program.getProgramInfo(url.Program_ID) />
<cfset BudgetManager.loadBudgetLabels() />

<cfset BudgetDollar = 0 />
<cfset CommittedDollar = 0 />
<cfset BudgetBalance = 0 />


<cfset BudgetBalanceAfterThisProgram = 0 />
<cfset programCurrentCommittedDollarFromExistingVersions = 0 />
<cfset programAdjustedCommittedDollarFromExistingVersions = 0 />
<cfset programDeltaCommittedDollarFromExistingVersions = 0 />
<cfif qGetProgramInfo.Simple_Budget_ID neq "" and qGetProgramInfo.Simple_Budget_ID neq 0><!--- if a budget is selected in the template and associated to this program --->

	<cfset BudgetManager.loadBudgetTemplatePositionAllocation(
				templateParentId = qGetProgramInfo.First_Parent_ID,
				userPositionId = qGetProgramInfo.Creating_User_Position_ID,
				budgetId = qGetProgramInfo.Simple_Budget_ID) />
	
	<cfset BudgetDollar = BudgetManager.getBudgetDollar() />
	<cfset CommittedDollar = BudgetManager.getCommittedDollar() />
	<cfset BudgetBalance = BudgetManager.getBudgetBalance() />

	<cfif qGetProgramInfo.Approved EQ 0>
		<!--- handle for revision --->
		<cfif qGetProgramInfo.Is_A_Revision>
			<cfset programCurrentCommittedDollarFromExistingVersions = BudgetManager.getCommittedProgramDollar(qGetProgramInfo.Contract_Number) />
			<cfset programAdjustedCommittedDollarFromExistingVersions = BudgetManager.getProgramAdjustedCommittedDollar(qGetProgramInfo.Contract_Number, qGetProgramInfo.Contract_Start_Date) />
			<cfset programDeltaCommittedDollarFromExistingVersions = programCurrentCommittedDollarFromExistingVersions - programAdjustedCommittedDollarFromExistingVersions  />
		</cfif>

		<cfset BudgetBalanceAfterThisProgram = BudgetBalance + programDeltaCommittedDollarFromExistingVersions - Round(qGetProgramInfo.Program_Spend) />
		
	</cfif>
</cfif>

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program - #BudgetManager.getBudgetBalanceLabel()# Calculation</title>
</head>

<body RIGHTMARGIN="8" LEFTMARGIN="8">


<table BORDER="0" WIDTH="400" CELLPADDING="0" CELLSPACING="0">
	<TR>
		<TD COLSPAN="100%">
			<B>#qGetProgramInfo.Contract_Number# - #BudgetManager.getBudgetBalanceLabel()# Calculation</B>
		</td>
	</tr>
</table>
<hr color="orange">
<table cellpadding="2" cellspacing="1" bgcolor="black">
	<tr bgcolor="white">
		<td>Template</td>
		
		<td>#qGetProgramInfo.Created_Type#</td>
	</tr>
	<tr bgcolor="white">
		<td>Budget</td>
		
		<td align="right">
		<cfif BudgetManager.getBudgetID()>
			#BudgetManager.getBudgetDescription()#<cfif BudgetManager.getBudgetActive() eq 0> <font color="red">(Inactive)</font></cfif>
		<cfelse>
			Not selected
		</cfif>
		</td>
	</tr>
	<cfif BudgetManager.getBudgetID()>
	<tr bgcolor="white">
		<td>#BudgetManager.getBudgetDollarLabel()#</td>
		
		<td align="right">#DollarFormat(BudgetDollar)#</td>
	</tr>
	<tr bgcolor="white">
		<td>#BudgetManager.getCommittedDollarLabel()#</td>
		
		<td align="right">#DollarFormat(CommittedDollar)#</td>
	</tr>
	<tr bgcolor="white">
		<td>#BudgetManager.getBudgetBalanceLabel()#</td>
		
		<td align="right"<cfif BudgetBalance lt 0> style="color:red"</cfif>>#DollarFormat(BudgetBalance)#</td>
	</tr>
	<cfif qGetProgramInfo.Is_A_Revision>
	<tr bgcolor="white">
		<td>#BudgetManager.getCommittedDollarLabel()# from existing versions</td>
		
		<td align="right">#DollarFormat(programCurrentCommittedDollarFromExistingVersions)#</td>
	</tr>
	<tr bgcolor="white" valign="top">
		<td>#BudgetManager.getCommittedDollarLabel()# from existing versions<br> after this version is approved</td>
		
		<td align="right">#DollarFormat(programAdjustedCommittedDollarFromExistingVersions)#</td>
	</tr>
	<tr bgcolor="white" valign="top">
		<td>Adjusted #LCase(BudgetManager.getCommittedDollarLabel())#</td>
		
		<td align="right">#DollarFormat(BudgetBalance + programDeltaCommittedDollarFromExistingVersions	)#</td>
	</tr>
	</cfif>
	<tr bgcolor="white">
		<td>Current program #LCase(BudgetManager.getCommittedDollarLabel())#</td>
		
		<td align="right">#DollarFormat(qGetProgramInfo.Program_Spend)#</td>
	</tr>
	<tr bgcolor="white">
		<td>#BudgetManager.getBudgetBalanceLabel()# if approved</td>
		
		<td align="right"<cfif BudgetBalanceAfterThisProgram lt 0> style="color:red"</cfif>>#DollarFormat(BudgetBalanceAfterThisProgram)#
		<br>
		(#DollarFormat(BudgetBalance)# <cfif qGetProgramInfo.Is_A_Revision>- #DollarFormat(programCurrentCommittedDollarFromExistingVersions)# + #DollarFormat(programAdjustedCommittedDollarFromExistingVersions)# </cfif>- #DollarFormat(Round(qGetProgramInfo.Program_Spend))#)
		</td>
	</tr>

	</cfif>
</table>
<center>
	<CF_button
		button_name		=	""
		button_caption	=	"close"
		button_action	=	"window.close();"
		button_type		=	"javascript_link"
		button_width	=	"50"
		button_color	=	"Navy"
		button_tip		=	"execute"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</center>				
</cfoutput>
	

</body>
</html>
