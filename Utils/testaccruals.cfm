<cfparam name="ActionToTake" default="0">

<cfif ActionToTake IS 1>
	<cfquery name="ExecuteAccruals" datasource="#application.datasource#"> 
	EXEC Update_Accruals 
	</cfquery>
</cfif>
<cfif ActionToTake IS 2>
	<cfquery name="ExecuteAccruals" datasource="#application.datasource#"> 
	Truncate table Accrual_Log
	</cfquery>
</cfif>
<cfif ActionToTake IS 4>
	<cfquery name="ClearPrograms" datasource="#application.datasource#"> 
	Update Contract_Main SET Calculated = 0
	Update Invoice_Detail SET Calculated = 0 WHERE Calculated = 1
	</cfquery>
</cfif>

<form action="testaccruals.cfm" method="post">
<select name="ActionToTake">
	<option value="1">Run accrual updates</option>
	<option value="2">Delete all prior entries in accrual log</option>
	<option value="4">Reset all programs/invoices to not calculated</option>
</select>
<input type="submit" text="Run">
</form>
OR run for one program

<form action="testaccruals.cfm" method="post">
<input type="hidden" name="ActionToTake" value="3">
Program Number: <input type="text" name="Program_Number">
<input type="submit" text="Run">
</form>

Summaries <cfif ActionToTake IS 3> for program number #Program_Number#</cfif>:
<cfquery name="AccrualLogSummary" datasource="#application.datasource#">
SELECT SUM(Amount_Earned) AS Amount_Earned, 
	SUM(Sales_Dollars) AS Sales_Dollars,
	SUM(Cases_Invoiced) AS Cases_Invoiced,
	SUM(Pounds_Invoiced) AS Pounds_Invoiced,
	Contract_Main.Contract_Title,
	Contract_Main.Contract_Number,
	BSA_Foodservice_Customers.Name
FROM Accrual_Log
	INNER JOIN Contract_Main
	ON Contract_Main.Contract_Main_ID = Accrual_Log.Program_ID
	<cfif ActionToTake IS 3>AND Contract_Main.Contract_Number LIKE '%#Program_Number#%'</cfif>
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Accrual_Log.Distributor_ID_Paid
GROUP BY Contract_Main.Contract_Title,
	Contract_Main.Contract_Number,
	BSA_Foodservice_Customers.Name
ORDER BY Contract_Main.Contract_Number, BSA_Foodservice_Customers.Name
</cfquery>
<cfdump var="#AccrualLogSummary#">

<p></p>

<Cfquery name="AccrualLogData" datasource="#application.datasource#">
SELECT * FROM Accrual_Log 
<cfif ActionToTake IS 3>
INNER JOIN Contract_Main
ON Contract_Main.Contract_Main_ID = Accrual_Log.Program_ID
AND Contract_Main.Contract_Number LIKE '%#Program_Number#%'
</cfif>
ORDER BY Program_ID
</CFQUERY>

Details:
<cfdump var="#AccrualLogData#">