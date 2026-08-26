<!---
budget_advanced_display.cfm
--->
<cfparam name="url.Program_ID" default="0">

<cfset program = CreateObject("component", "components.programs.Program") />
<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />

<cfset qGetProgramInfo = program.getProgramInfo(url.Program_ID) />
<cfset BudgetManager.loadBudgetLabels() />

<cfset BudgetDollar = 0 />
<cfset CommittedDollar = 0 />
<cfset BudgetBalance = 0 />
<cfset BudgetConsumed = 0 />
<cfset TimeExpired = 0 />
<cfset PacingIndex = 0 />

<cfset AvgCommittedDollar = 0 />
<cfset CommittedProgramCount = 0 />
<cfset NewAvgCommittedDollar = 0 />
<cfset CommittedDollarCurrentProgramVsAvg = 0 />
<cfset AdditionalProgramLeft = 0 />

<cfset CurrentProgramCommittedDollar = Round(qGetProgramInfo.Program_Spend) />


<cfset BudgetBalanceAfterThisProgram = 0 />
<cfset programCurrentCommittedDollarFromExistingVersions = 0 />
<cfset programAdjustedCommittedDollarFromExistingVersions = 0 />
<cfset programDeltaCommittedDollarFromExistingVersions = 0 />
<cfif qGetProgramInfo.Simple_Budget_ID neq "" and qGetProgramInfo.Simple_Budget_ID neq 0><!--- if a budget is selected in the template and associated to this program --->
	
	<cfset BudgetManager.loadBudgetTemplatePositionAllocation(
				templateParentId = qGetProgramInfo.First_Parent_ID,
				userPositionId = qGetProgramInfo.Creating_User_Position_ID,
				budgetId = qGetProgramInfo.Simple_Budget_ID,
				bAdvanced = 1) />

	<cfset BudgetDollar = BudgetManager.getBudgetDollar() />
	<cfset CommittedDollar = BudgetManager.getCommittedDollar() />
	<cfset BudgetBalance = BudgetManager.getBudgetBalance() />
	<cfset BudgetConsumed = BudgetManager.getBudgetConsumed() />
	<cfset TimeExpired = BudgetManager.getTimeExpired() />
	<cfset PacingIndex = BudgetManager.getPacingIndex() />
	<cfset AvgCommittedDollar = BudgetManager.getAvgCommittedDollar() />
	<cfset CommittedProgramCount = BudgetManager.getCommittedProgramCount() />
	
	<cfset NewAvgCommittedDollar = AvgCommittedDollar />
	
	<cfif qGetProgramInfo.Is_A_Revision>
		<cfset programCurrentCommittedDollarFromExistingVersions = BudgetManager.getCommittedProgramDollar(qGetProgramInfo.Contract_Number) />
		<cfset programAdjustedCommittedDollarFromExistingVersions = BudgetManager.getProgramAdjustedCommittedDollar(qGetProgramInfo.Contract_Number, qGetProgramInfo.Contract_Start_Date) />
		<cfset programDeltaCommittedDollarFromExistingVersions = programCurrentCommittedDollarFromExistingVersions - programAdjustedCommittedDollarFromExistingVersions  />
		<cfif qGetProgramInfo.Approved EQ 0>
			<cfset CurrentProgramCommittedDollar = CurrentProgramCommittedDollar + programAdjustedCommittedDollarFromExistingVersions />
		<cfelse>
			<cfset CurrentProgramCommittedDollar = programAdjustedCommittedDollarFromExistingVersions />
		</cfif>
	</cfif>
	
	<cfset CommitmentImpact = CurrentProgramCommittedDollar />
	
	<cfif qGetProgramInfo.Approved EQ 0>
		<!--- handle for revision --->
		<cfif qGetProgramInfo.Is_A_Revision>
			
			<cfset CommitmentImpact = CurrentProgramCommittedDollar - programCurrentCommittedDollarFromExistingVersions />
			
		</cfif>
		
		<cfset BudgetBalanceAfterThisProgram = BudgetBalance - CommitmentImpact />
		<cfif BudgetBalance NEQ 0>
			<cfset CurrentProgramCommittedDollarOfAvaiable = CommitmentImpact / BudgetBalance />
		</cfif>
		
		<cfif NewAvgCommittedDollar EQ 0>
			<cfset AdditionalProgramLeft = "n/a" />
		<cfelse>
			<cfset AdditionalProgramLeft = BudgetBalance / NewAvgCommittedDollar />
		</cfif>
		
		<!--- neq avg committed dollar = new committed dollar / # of programs --->
		<cfif qGetProgramInfo.Is_A_Revision>
			<cfset NewAvgCommittedDollar = (BudgetDollar - BudgetBalanceAfterThisProgram) / CommittedProgramCount />
		<cfelse>
			<cfset NewAvgCommittedDollar = (BudgetDollar - BudgetBalanceAfterThisProgram) / (CommittedProgramCount + 1) />
		</cfif>
		
	</cfif>
	
	<cfif AvgCommittedDollar eq 0>
		<cfset CommittedDollarCurrentProgramVsAvg = "n/a" />
	<cfelse>
		<cfset CommittedDollarCurrentProgramVsAvg = CurrentProgramCommittedDollar / AvgCommittedDollar />
	</cfif>
	
</cfif>

<cffunction name="NumericRoundDecimal" output="false" returntype="string">
	<cfargument name="iValue" type="numeric" required="true" />
	<cfargument name="iDecimalLen" type="numeric" required="true" />
	<cfset var divVal = 10 ^ arguments.iDecimalLen />
	<cfset var newAmount = arguments.iValue />
	<cfset newAmount = newAmount * divVal />
	<cfset newAmount = Round(newAmount) />
	<cfset newAmount = newAmount / divVal />
	<cfreturn newAmount />	
</cffunction>

<cffunction name="PercentageFormat" output="false" returntype="string">
	<cfargument name="iValue" type="numeric" required="true" />
	<cfargument name="iDecimalLen" type="numeric" required="false" default="2" />
	<cfreturn NumericRoundDecimal(arguments.iValue * 100, arguments.iDecimalLen) & "%" />
</cffunction>
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program - Advanced budget details</title>
</head>

<body RIGHTMARGIN="8" LEFTMARGIN="8">


<table BORDER="0" WIDTH="400" CELLPADDING="0" CELLSPACING="0">
	<TR>
		<TD COLSPAN="100%">
			<B>#qGetProgramInfo.Contract_Number# - Advanced budget details</B>
		</td>
	</tr>
	<tr bgcolor="white">
		<td>Template</td>
		
		<td>#qGetProgramInfo.Created_Type#</td>
	</tr>
	<tr bgcolor="white">
		<td>Budget</td>
		
		<td>
		<cfif BudgetManager.getBudgetID()>
			#BudgetManager.getBudgetDescription()#<cfif BudgetManager.getBudgetActive() eq 0> <font color="red">(Inactive)</font></cfif>
		<cfelse>
			Not selected
		</cfif>
		</td>
	</tr>
</table>
<hr color="orange">
<table cellpadding="2" cellspacing="1" bgcolor="black" align="center">
	
	<cfif BudgetManager.getBudgetID()>
	<tr bgcolor="white">
		<td align="right">#DollarFormat(BudgetDollar)#</td>
		<td>#BudgetManager.getBudgetDollarLabel()#</td>
	</tr>
	<tr bgcolor="white">
		<td align="right">#DollarFormat(CommittedDollar)#</td>
		<td>#BudgetManager.getCommittedDollarLabel()#</td>
	</tr>
	<tr bgcolor="white">
		<td align="right"<cfif BudgetBalance lt 0> style="color:red"</cfif>>#DollarFormat(BudgetBalance)#</td>
		<td>#BudgetManager.getBudgetBalanceLabel()#</td>
	</tr>
	<tr bgcolor="white">
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr bgcolor="white">
		<td align="right">#PercentageFormat(BudgetConsumed, 0)#</td>
		<td>Budget consumed</td>		
	</tr>
	<tr bgcolor="white">
		<td align="right">#PercentageFormat(TimeExpired, 0)#</td>
		<td>Time expired</td>		
	</tr>
	<tr bgcolor="white">
		<td align="right">#NumericRoundDecimal(PacingIndex, 2)#</td>
		<td>Pacing Index</td>		
	</tr>
	<tr bgcolor="white">
		<td colspan="2">&nbsp;</td>
	</tr>
	<cfif qGetProgramInfo.Approved EQ 0 and qGetProgramInfo.Is_A_Revision>
	<tr bgcolor="white">
		<td align="right">#DollarFormat(programCurrentCommittedDollarFromExistingVersions)#</td>
		<td>Program #BudgetManager.getCommittedDollarLabel()# from existing versions</td>		
	</tr>
	<tr bgcolor="white" valign="top">
		<td align="right">#DollarFormat(programAdjustedCommittedDollarFromExistingVersions)#</td>
		<td>#BudgetManager.getCommittedDollarLabel()# from existing versions<br> after this version is approved</td>		
	</tr>
	<tr bgcolor="white">
		<td align="right">#DollarFormat(CurrentProgramCommittedDollar)#</td>
		<td>Program #BudgetManager.getCommittedDollarLabel()# after approval</td>		
	</tr>
	<!---
	<tr bgcolor="white" valign="top">
		<td align="right">#DollarFormat(BudgetBalance + programDeltaCommittedDollarFromExistingVersions)#</td>
		<td>Adjusted #LCase(BudgetManager.getBudgetBalanceLabel())#</td>
	</tr>
	---->
	</cfif>
	<tr bgcolor="white">
		<td align="right">#DollarFormat(CommitmentImpact)#</td>
		<td>commitment impact</td>
	</tr>
	<cfif qGetProgramInfo.Approved EQ 0>
	<tr bgcolor="white">
		<td align="right">#PercentageFormat(CurrentProgramCommittedDollarOfAvaiable, 0)#</td>
		<td>of available budget remaining</td>
	</tr>
	<tr bgcolor="white">
		<td align="right"<cfif BudgetBalanceAfterThisProgram lt 0> style="color:red"</cfif>>#DollarFormat(BudgetBalanceAfterThisProgram)#
		<!---<br>
		(#DollarFormat(BudgetBalance)# <cfif qGetProgramInfo.Is_A_Revision>- #DollarFormat(programCurrentCommittedDollarFromExistingVersions)# + #DollarFormat(programAdjustedCommittedDollarFromExistingVersions)# </cfif>- #DollarFormat(Round(qGetProgramInfo.Program_Spend))#)--->
		</td>
		<td valign="top">#BudgetManager.getBudgetBalanceLabel()# if approved</td>		
	</tr>	
	</cfif>
	<tr bgcolor="white">
		<td colspan="2">&nbsp;</td>
	</tr>
	<!--- TODO: disabled some fields, beased on if the program is at a higher level than the budget allocation --->
	<tr bgcolor="white">
		<td align="right">#DollarFormat(AvgCommittedDollar)#</td>
		<td>average commitment size to date</td>
	</tr>
	<tr bgcolor="white">
		<td align="right">#CommittedProgramCount#</td>
		<td>programs to date</td>
	</tr>
	<cfif qGetProgramInfo.Approved EQ 0>
	<tr bgcolor="white">
		<td align="right">#DollarFormat(NewAvgCommittedDollar)#</td>
		<td>new average commitment size if approved</td>
	</tr>
	</cfif>
	<tr bgcolor="white">
		<td align="right"><cfif isNumeric(CommittedDollarCurrentProgramVsAvg)>#PercentageFormat(CommittedDollarCurrentProgramVsAvg, 0)#<cfelse>#CommittedDollarCurrentProgramVsAvg#</cfif></td>
		<td>this program vs. current average</td>
	</tr>
	<cfif qGetProgramInfo.Approved EQ 0>
	<tr bgcolor="white">
		<td align="right"><cfif isNumeric(AdditionalProgramLeft)>#NumericRoundDecimal(AdditionalProgramLeft, 2)#<cfelse>#AdditionalProgramLeft#</cfif></td>
		<td>potential additional programs if approved</td>
	</tr>
	</cfif>
	</cfif>
</table>
<br>
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
