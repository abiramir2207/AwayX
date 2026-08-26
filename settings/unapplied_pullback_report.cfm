
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfparam name="CreateExcel" default="0">
<cfset PageTitle="Unapplied <cfoutput>#appSettings.getPullbackLabel()#</cfoutput> Report">

<script>
function ExportToXL()
{
	var windowLocation = "unapplied_pullback_report.cfm?CreateExcel=1";
	NewWindow(windowLocation, "UnappliedPullbacks", 800, 600, "yes", "yes")
	return false;
}
</script>


<cfif CreateExcel IS 1>
	<!--- Detail query for pullbacks from log --->
<cfquery name="GetUnappliedPullbacks" datasource="#application.datasource#">
SELECT 
Pullbacks_Log.Pullback_Program_Number, Pullbacks_Log.Pullback_From_Program_Number,
BSA_Foodservice_Customers.Name, BSA_Foodservice_Customers.Ship_To,
BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description, Discount_Type.Discount_Type_Desc,
Pullbacks_Log.Product_BB_Volume_LB, Pullbacks_Log.Pullback_Percent, Pullbacks_Log.Pullback_Expected_Dollars
FROM Pullbacks_Log
	INNER JOIN BSA_Foodservice_Items_Master
	ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Pullbacks_Log.Product_ID
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Pullbacks_Log.Customer_ID
	INNER JOIN Discount_Type 
	ON Discount_Type.Discount_Type_ID = Pullbacks_Log.Discount_Type_ID
WHERE Pullbacks_Log.Pullback_Applied = 0
AND Pullbacks_Log.Deleted = 0
ORDER BY cast(Pullback_Expected_Dollars as float) DESC, Pullbacks_Log.Pullback_Program_Number, BSA_Foodservice_Items_Master.Item
</cfquery>

<cfset spacer = " ">
	 	<cfcontent type="application/unknown">
		<cfheader name="Content-Disposition" value="attachment;filename=UnappliedPullbacks.xls">
		<table border="1">
			<cfoutput>
				<tr>
				<th> #appSettings.getPullbackLabel()# Program Number</th>
				<th> #appSettings.getPullbackLabel()# From Program Number</th>
				<th> Distributor Name</th>
				<th> Ship To</th>
				<th> Item Number</th>
				<th> Item Description</th>
				<th> Discount Type</th>
				<th> Pounds</th>
				<th> #appSettings.getPullbackLabel()# Percent</th>
				<th> #appSettings.getPullbackLabel()# Expected Dollars</th>
			</tr>
			</cfoutput>
			<cfoutput query="GetUnappliedPullbacks">
			<tr>
				<td>#Pullback_Program_Number#</td>
				<td>#Pullback_From_Program_Number#</td>
				<td>#Name#</td>
				<td>#Ship_To#</td>
				<td>#Item#</td>
				<td>#Description#</td>
				<td>#Discount_Type_Desc#</td>
				<td>#Product_BB_Volume_LB#</td>
				<td>#Pullback_Percent#</td>
				<td>#Pullback_Expected_Dollars#</td>
			</tr>
			</cfoutput>
		</table>		

<cfabort>



<!--- Create XL or not --->
<cfelse>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<!--- Summary Query --->
<cfquery name="GetUnappliedPullbackSummary" datasource="#application.datasource#">
SELECT 	COUNT(Pullbacks_Log.Pullback_Program_Number) AS Number_Unapplied,
		ISNULL(SUM(cast(Pullback_Expected_Dollars as float)), 0) AS Dollars_Unapplied,
		ISNULL(SUM(cast(Product_BB_Volume_LB as float)), 0) AS Pounds_Unapplied
FROM Pullbacks_Log
WHERE Pullbacks_Log.Pullback_Applied = 0
AND Pullbacks_Log.Deleted = 0
</cfquery>

<!--- End Summary Query --->
<blockquote>
<TABLE BORDER="0" CELLPADDING="0" width="300" >
	<tr><th>Unapplied <cfoutput>#appSettings.getPullbackLabel()#</cfoutput></th></tr>
	<tr><td colspan="2"><hr width="100%" color="orange"></td></tr>
<!--- Number --->
<TR>
	<TD><strong>Number of unapplied:</strong></TD>
	<TD><cfoutput>#Numberformat(GetUnappliedPullbackSummary.Number_Unapplied)#</cfoutput></td>
</tr>
<!--- Dollars ---->
<TR>
	<TD><strong>Dollars unapplied:</strong><br>
	<i>May not be total amount</i>
	</TD>
	<TD><cfoutput>#dollarformat(GetUnappliedPullbackSummary.Dollars_Unapplied)#</cfoutput></td>
</tr>
<!--- Pounds ---->
<TR>
	<TD><strong>Pounds unapplied:</strong></TD>
	<TD><cfoutput>#Numberformat(GetUnappliedPullbackSummary.Pounds_Unapplied)#</cfoutput></td>
</tr>
<!--- Link --->
<tr>
	<td colspan="2" align="center">
	<CF_smallLink 
			title = "export results to XL" 
			url = "##"
			parameters = "onClick=""javascript: return ExportToXL();"""
		>
	</td>
</tr>
</table>
</blockquote>

</body>
<!--- Create XL or not --->
</cfif>
