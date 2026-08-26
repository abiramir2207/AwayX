<cfparam name="url.templateId" default="0">
<cfparam name="url.templateParentId" default="0">

<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
<cfset BudgetManager.loadBudgetLabels() />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset template = templateManager.get(url.templateId)>

<cfset qGetBudgetTemplateMappingHistory = BudgetManager.getBudgetTemplateMappingHistory(templateParentId = url.templateParentId) />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Template - Budget Change History</title>
</head>

<body RIGHTMARGIN="8" LEFTMARGIN="8">

<cfoutput>
<div align="Center" class="labelname">#template.getCreatedType()# (#template.getGenericType()#)</div>

<br>
<table cellpadding="2" cellspacing="1" style="background-color:black;" align="center">
	<tr style="background-color:ffffff">
		<td id="header" align="center"><strong>Budget</strong></td>
		<td id="header" align="center"><strong>#BudgetManager.getBudgetDollarLabel()#</strong></td>
		<td id="header" align="center"><strong>Modified By</strong></td>
		<td id="header" align="center"><strong>Modified On</strong></td>
	</tr>
</cfoutput>
	<cfset chkBudgetId = 0 />
	<cfset chkBudgetDollar = "" />
	<cfoutput query="qGetBudgetTemplateMappingHistory">
		<cfif chkBudgetId neq Simple_Budget_ID or chkBudgetDollar neq Budget_Dollar>
		<tr style="background-color:ffffff">
			<td>#BudgetManager.buildBudgetDescription(Simple_Budget_Class_Number, Simple_Budget_Class_Desc, Simple_Budget_Number, Simple_Budget_Desc)#</td>
			<td>#Dollarformat(Budget_Dollar)#</td>
			<td>#Created_By_User_Name#</td>
			<td>#DateFormat(created_date, "mm/dd/yyyy")# #TimeFormat(created_date, "hh:mm:ss tt")#</td>
		</tr>
		<cfset chkBudgetId = Simple_Budget_ID />
		<cfset chkBudgetDollar = Budget_Dollar />
		</cfif>
	</cfoutput>	
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

	

</body>
</html>
