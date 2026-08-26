<!------ Program_Product_Rate_UOM_Change.cfm ----->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program Product Rate UOM Change</title>
</head>

<body>


<cfif IsDefined("URL.Program_ID") AND isNumeric(URL.Program_ID)>

<cfset ProgramProductRateUOMChangeManager = CreateObject("component", "components.programs.products.ProgramProductRateUOMChangeManager").init() />
<cfset qGetRateUOMChanges = ProgramProductRateUOMChangeManager.getRateUOMChanges(URL.Program_ID) />
<cfset qGetProgramInfo = CreateObject("component", "components.programs.program").getProgramInfo(URL.Program_ID) />

<center>
<font color="red">
<B>*** The rate unit of measure for the following products has changed ***</B>
</font>
<br><br>
</center>
<cfoutput>
<table class="MainTable" cellpadding="2" cellspacing="0" width="90%" align="center">
<caption align="left" style="font-size:12px;font-weight:bold;">
Program: #qGetProgramInfo.Contract_Number# - #qGetProgramInfo.Contract_Title#
</caption>
<tr BGCOLOR="##FFCE84" VALIGN="bottom">
	<td id="header"><B>Discount</B></td>
	<td id="header"><B>Item</B></td>
	<td id="header"><B>Description</B></td>
	<td id="header"><B>Old Price/Allowance</B></td>
	<td id="header"><B>New Price/Allowance</B></td>
	<td id="header"><B>Date</B></td>
</tr>
<cfloop query="qGetRateUOMChanges">
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<td>#Discount_Type_Desc#</td>
	<td>#Item#
	<cfif IsNumeric(Tier_Number)> (Tier #Tier_Number#)</cfif>
	</td>
	<td>#Description#</td>
	<td>#DollarFormat(Old_Price)# / #ProgramProductRateUOMChangeManager.getUOMDesc(Old_UOM_ID)#</td>
	<td>#DollarFormat(New_Price)# / #ProgramProductRateUOMChangeManager.getUOMDesc(New_Price_UOM_ID)#</td>
	<td>#DateFormat(Created_Date, "mm/dd/yyyy")#</td>
</tr>
</cfloop>
</table>


</cfoutput>

</cfif>

<br><br><br>
<div align="center">
<CF_smallLink 
	title = "close window" 
	url = "##"
	parameters = "onClick=""javascript: window.close();return false;"""
>
</div>

</body>
</html>