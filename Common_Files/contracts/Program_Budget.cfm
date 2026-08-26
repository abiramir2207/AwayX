<cfparam name="URL.CID" 	default="">

<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<CFSET URL.Program_ID = cryp.value>

<cfif isNumeric(URL.Program_ID)>
<cftry>

<cfset ProgramBudgetManager = CreateObject("component", "components.programs.ProgramBudgetManager").init() />
<cfset qGetDiscountClassCodeBudgetInfo = ProgramBudgetManager.getDiscountClassCodeBudgetInfo(URL.Program_ID) />

<cfquery name="qGetClassCodeBudgetInfo" dbtype="query">
	SELECT	Class_Code_ID, Class_Code_Desc, SUM(Group_Amount) Group_Amount
	FROM	qGetDiscountClassCodeBudgetInfo
	GROUP BY Class_Code_ID, Class_Code_Desc
	ORDER BY Class_Code_Desc
</cfquery>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program Budget</title>
</head>

<body>


<cfif NOT qGetDiscountClassCodeBudgetInfo.recordCount>
	<br><br><br>
	<center>
	<span style="color:red;font-weight:bold;font-size:14px;">No record found</span>
	</center>
</cfif>

<cfoutput query="qGetDiscountClassCodeBudgetInfo" group="Discount_Type_ID">
	<table cellpadding="2" cellspacing="0" border="0" width="90%" align="center">
	<caption style="font-weight:bold;border-bottom:2px solid black;" align="left">#Discount_Type_Desc#</caption>
	<tr bgcolor="F5F092" style="font-size:12px;">
		<th align="left">Class Code</th>
		<th align="right">Allocation</th>
		<th align="right">Trade Amount</th>
	</tr>
	<cfoutput>
	
	<tr>
		<td><a href="##" onClick="javaScript: NewWindow('Program_Budget_Detail.cfm?Program_ID=#URL.Program_ID#&Discount_Type_ID=#Discount_Type_ID#&Class_Code_ID=#Class_Code_ID#','program_budget_detail','600','500','Yes', 'Yes');return false;">#Class_Code_Desc#</a></td>
		<td align="right">#Real_Breakout_percentage#%</td>
		<td align="right">#DollarFormat(Group_Amount)#</td>
	</tr>
	
	</cfoutput>
	</table>
</cfoutput>

<cfif qGetClassCodeBudgetInfo.recordCount>
<br><br>
	<table cellpadding="2" cellspacing="0" border="0" width="90%" align="center">
	<caption style="font-weight:bold;border-bottom:2px solid black;" align="left">Total</caption>
	<tr bgcolor="F5F092" style="font-size:12px;">
		<th align="left">Class Code</th>
		<th align="right">Amount</th>
	</tr>
	<cfoutput query="qGetClassCodeBudgetInfo">
	
	<tr>
		<td>#Class_Code_Desc#</td>
		<td align="right">#DollarFormat(Group_Amount)#</td>
	</tr>
	
	</cfoutput>
	</table>
</cfif>

<center>
<br><br>
<CF_smallLink 
	title = "close window" 
	url = "##"
	parameters = "onClick=""javascript: window.close();return false;"""
>
</center>

</body>
</html>

	<cfcatch>
	
		<cfrethrow>
	
	</cfcatch>

</cftry>

</cfif>