<!---Gets data about deduction--->
<cfinclude template="/deductions/sql_Deduction_Info.cfm">

<cfquery name="GetClauses" datasource="#application.datasource#">
SELECT * FROM DD_Rebill
WHERE Deleted = 0
AND (DD_Rebill.DD_Classification_ID = '#Deduction_Info.DD_Classification_ID#' OR DD_Rebill.DD_Classification_ID = 0 OR DD_Rebill.DD_Classification_ID IS Null)
ORDER BY Clause_Order, Created_Date
</cfquery>

<cfoutput>
<table>
<form action="edit_letter.cfm" method="post" name="CreateLetter">
<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">


<tr><th colspan="2" align="left">Clauses:</th></tr>
<cfloop query="GetClauses">
	<tr>
		<td><input type="checkbox" name="DD_Rebill_ID" value="#DD_Rebill_ID#" <cfif Is_Mandatory IS 1>disabled checked</cfif>>
		<Cfif is_Mandatory Is 1><input type="hidden" name="DD_Rebill_ID" value="#DD_Rebill_ID#"></CFIF>	
		</td>
		<td>#left(trim(DD_Rebill_Text), 50)#<cfif len(DD_Rebill_Text) GT 50>...</cfif></td>
	</tr>
</cfloop>

<!---Hard coded options --->
<tr><th colspan="2" align="left">Deduction Information:</th></tr>

<tr><td colspan="2"><strong>Send to:</strong></td></tr>
<!--- Ship To Address --->
<cfif len(trim(Deduction_Info.Distributor_ID)) GT 0>
<tr>
	<td><input type="radio" name="Address" value="1"></td>
	<td>Ship To address</td>
</tr>
</cfif>

<!--- Bill To Address --->
<cfif len(trim(Deduction_Info.Distributor_Bill_To_ID)) GT 0>
<tr>
	<td><input type="radio" name="Address" value="2"></td>
	<td>Bill To address</td>
</tr>
</cfif>

<!---Broker Address --->
<tr>
	<td><input type="radio" name="Address" value="3" checked></td>
	<td>Broker address</td>
</tr>

<!---Deduction Date --->
<tr>
	<td><input type="checkbox" name="DD_Date" value="1"></td>
	<td>Deduction Date</td>
</tr>

<!---Deduction Amount --->
<tr>
	<td><input type="checkbox" name="DD_Amount" value="1"></td>
	<td>Deduction Amount</td>
</tr>

<!---Customer Reference --->
<tr>
	<td><input type="checkbox" name="DD_Customer_RefNo" value="1"></td>
	<td>Customer Reference</td>
</tr>

<!---Deduction Reference --->
<tr>
	<td><input type="checkbox" name="DD_Reference" value="1"></td>
	<td>Deduction Reference</td>
</tr>

<!---Deduction Check # --->
<tr>
	<td><input type="checkbox" name="DD_Check_Number" value="1"></td>
	<td>Deduction Check Number</td>
</tr>

<!---Rebill Reason --->
<tr>
	<td><input type="checkbox" name="Transferred_Reason" value="1"></td>
	<td>Rebill Reason</td>
</tr>

<!---User Position --->
<tr>
	<td><input type="checkbox" name="User_Position" value="1"></td>
	<td>User Position</td>
</tr>

<tr><td>&nbsp; </td><td>
<input type="submit" value="View Letter">
</td></tr>
</form>
</table>


</cfoutput>