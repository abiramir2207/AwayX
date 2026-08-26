<cfparam name="URL.Program_ID" 	default="">
<cfparam name="URL.Discount_Type_ID" 	default="">
<cfparam name="URL.Class_Code_ID" 	default="">

<cfif isNumeric(URL.Program_ID) AND isNumeric(URL.Discount_Type_ID) AND isNumeric(URL.Class_Code_ID)>
<cftry>

<cfset ProgramBudgetManager = CreateObject("component", "components.programs.ProgramBudgetManager").init() />
<cfset qGetDiscountClassCodeGroupBudgetInfo = ProgramBudgetManager.getDiscountClassCodeGroupBudgetInfo(URL.Program_ID, URL.Discount_Type_ID, URL.Class_Code_ID) />


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program Budget Detail</title>
</head>

<body>

<cfoutput>
	<cfset totalValue = 0 />
	<table cellpadding="2" cellspacing="0" border="0" width="95%" align="center">
	<caption style="font-weight:bold;border-bottom:2px solid black;" align="left">
	#qGetDiscountClassCodeGroupBudgetInfo.Class_Code_Desc# (#qGetDiscountClassCodeGroupBudgetInfo.Discount_Type_Desc#)
	</caption>
	<tr bgcolor="F5F092" style="font-size:12px;">
		<th align="left">Group</th>
		<th align="right">Allocation</th>
		<th align="right">Eff. Allocation</th>
		<th align="right">Sales</th>
		<th align="right">Trade Amount</th>
	</tr>
	<cfloop query="qGetDiscountClassCodeGroupBudgetInfo">
	
	<tr>
		<td>#Description#</td>
		<td align="right">#Real_Breakout_Percentage#%</td>
		<td align="right">#Group_Breakout_Percentage#%</td>		
		<td align="right">#DollarFormat(Expected_Sales)#</td>
		<td align="right">#DollarFormat(Group_Amount)#</td>
	</tr>
		<cfset totalValue = totalValue + Group_Amount />
	</cfloop>
	
	<tr>
		<td colspan="4" align="right" style="font-weight:bold;border-top:2px solid black;">Total:</td>		
		<td align="right" style="font-weight:bold;border-top:2px solid black;">#DollarFormat(totalValue)#</td>
	</tr>
	
	</table>

</cfoutput>

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