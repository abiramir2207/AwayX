
<!---BJF: they have to approve deletion based on programs using this operator --->
<cfparam name="blnSubmit"	default=0> 

<script>
function printPage()
{

 	window.print();
	return false;
}
</script>

<Cfif blnSubmit IS 1>

<!---Do the deletion and close the window --->
	<cfset useLakebaseForMarkasDeleted = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForMarkasDeleted>
	<cftry>
		<cfset application.oLakebase.updateRows("bsa_operator",
			{
				"bsa_operator_id" = "eq.#BSA_Operator_ID#"
			},
			{
				"deleted" = "1",
				"deleted_by" = "#request.AccessStructure.User_ID#",
				"deleted_date" = "#now()#",
				"display_code" = "N",
				"user_date_edited" = "#now()#",
				"edited_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForMarkasDeleted = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForMarkasDeleted>
<cfquery name="MarkasDeleted" datasource="#application.datasource#">
	UPDATE BSA_Operator
	SET Deleted = 1,
		Deleted_By = '#request.AccessStructure.User_ID#',
		Deleted_Date = #now()#,
		Display_Code = 'N',
		User_Date_Edited	= 	getdate(),
		Edited_By		= 	'#request.AccessStructure.User_ID#'
	WHERE BSA_Operator_ID = #BSA_Operator_ID#
	<!--- AND User_Added = 1 BJF: I had to either disable the link or take out this req. I don't think this serves a valuable purpose so I removed it. --->
	</cfquery>
</cfif>
	
	<cfquery name="DeleteContractOperator" datasource="#application.datasource#">
	UPDATE Contract_Operators
	SET Deleted = 1
	WHERE BSA_Operator_ID = #BSA_Operator_ID#
	AND Contract_Main_ID IN (SELECT Contract_Main_ID FROM Contract_Main WHERE Contract_Status_Type_IDX < 2 AND Deleted = 0)
	</cfquery>
	
	<Script>
			opener.document.all.MyForm.DoSearch.value = 0;
			opener.document.all.MyForm.LoadSavedOperators.value = 1;
			opener.document.all.MyForm.submit()
			window.close();	
	</SCRIPT>
</CFIF>

<cfquery name="GetProgramsforOperator" datasource="#application.datasource#">
SELECT Contract_Title, Contract_Number
FROM Contract_Main
	INNER JOIN Contract_Operators
	ON Contract_Main.Contract_Main_ID = Contract_Operators.Contract_Main_ID
	AND Contract_Operators.BSA_Operator_ID = #BSA_Operator_ID#
</cfquery>

<cfquery name="GetBillbacksforOperator" datasource="#application.datasource#">
SELECT BB_Title, BB_Code
FROM Billback_Operator
	INNER JOIN Billback
	ON Billback.Billback_ID = Billback_Operator.Billback_ID
	AND Billback_Operator.Operator_ID = #BSA_Operator_ID#
</cfquery>


<!---If no programs, just delete it without warnings --->
<cfif GetProgramsforOperator.recordcount LT 1 AND GetBillbacksforOperator.recordcount LT 1>

	<cfoutput>
		<script>
			window.location = "delete_operator.cfm?blnSubmit=1&BSA_Operator_ID=#BSA_Operator_ID#";
		</script>
	
	</cfoutput>
<!---Make sure they know the consequences of deletion --->
<cfelse>


<cfset useLakebaseForOperatorInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForOperatorInfo>
	<cftry>
		<cfset OperatorInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"bsa_operator_id" = "eq.#BSA_Operator_ID#",
				"select" = "operator_name"
			}), "operator_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForOperatorInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForOperatorInfo>
<cfquery name="OperatorInfo" datasource="#application.datasource#">
SELECT Operator_Name
FROM BSA_Operator
WHERE BSA_Operator_ID = #BSA_Operator_ID#
</cfquery>
</cfif>

<HTML>
<HEAD>
	<TITLE>Delete Operator</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
	<style>
	body, table, td
	{
		font-family: Arial;
		font-size: 12px;
	}
	select, TEXTAREA
	{
		width:	200px;
		font-size: 10px;
	}
	TEXTAREA
	{
		width:	400px;
		font-size: 10px;
	}
	</STYLE>
<body>






<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" class="Maintable">

<Tr><Td colspan="2"><SPAN CLASS="title2">Delete <cfoutput>#OperatorInfo.Operator_Name#</cfoutput></Span></TD></TR>


    <TR  BGCOLOR="dddddd">
  		<th>Program Number</th>
		<th>Program Title</th>

	</TR>
	
	<cfoutput query="GetProgramsforOperator">
	<tr>
		<td CLASS="data">#Contract_Number#</td>
		<td CLASS="data">#Contract_Title#</td>

	</tr>
	</cfoutput>
	


    <TR  BGCOLOR="dddddd">
  		<th>Billback Number</th>
		<th>Billback Title</th>

	</TR>
	
		<cfoutput query="GetBillbacksforOperator">
	<tr>
		<td CLASS="data">#BB_Code#</td>
		<td CLASS="data">#BB_Title#</td>

	</tr>
	</cfoutput>
	
	</table>
	
	<table align="Center">

	<Tr><td align="center">
	<CF_smallLink 
	title = "do not delete and close window" 
	url = "##"
	parameters = "onClick=""javascript: window.close();"""
	>  &nbsp; &nbsp; 
	
	<CF_smallLink 
	title = "permanently delete operator" 
	url = "delete_operator.cfm?blnSubmit=1&BSA_Operator_ID=#BSA_Operator_ID#"

	>
	
	<p>
	<CF_smallLink 
	title = "print deletion report" 
	url = "##"
	parameters = "onClick=""javascript: printPage();""" 
	>
	</p>
	</td></TR>
	
</TABLE>

</body>
</html>
<!---Are there programs? --->
</cfif>