<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\exportBudget.cfm
      Date:     Aug 5, 2011
      Author:   Chris Nguyen
      Purpose:  Export fixed budget to Excel file

			Required Parameters:
			  - url.budget_id: integer

			Optional parameter:
			  - url.excel_file: full path of the export Excel file

			Notes: ID values are hidden, they are defined under hidden column (vars.hidden_column).
			         1. First row: Budget_ID
			         2. Second row: nothing
			         3. Third row & subsequent rows: User_Position_ID or Bsa_FoodService_Customers_Id
			       We use the hidden ID values in the importBudget.cfm.
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title></title>
 <style>
 .center { text-align:center; margin:30px; }
 .center a { margin:20px; }
 </style>
</head>
<body>
<cfscript>
  vars = {};
  const = {};
  const.customers = 4;
</cfscript>

<cfoutput>
<cfquery name="vars.qBudget" datasource="#application.datasource#">
    SELECT Budget_desc
           , Budget_Code
           , Budget_Dollar
           , Allocation_Position_Level
           , Budget_Id
      FROM Budget
     WHERE Budget.Budget_Id = <cfqueryparam value="#url.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif StructKeyExists(url, "excel_file")>
  <cffile action="readBinary" file="#url.excel_file#" variable="vars.excel_content">
	<!--- Give users option to save or open the Excel report --->
	<cfheader name="Content-Disposition" value="attachment; filename=Budget_#replace(vars.qBudget.Budget_Code,' ','_','all')#.xls"  />
	<cfcontent type="application/vnd.ms-excel" variable="#vars.excel_content#"  />
	<cfabort>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->
<cfscript>
  createExcelFile();
</cfscript>

<fieldset id="mainfieldset" style="padding:10px; border:1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Export to Excel</legend>

<!---display heading--->
<div style="margin-top:5px" >
<table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr>
    <td><font size=2>Code: <b>#vars.qBudget.budget_code#</b></font></td>
    <td align=right><font size=2>Budget Description: <b>#vars.qBudget.budget_desc#</b></font></td>
  </tr>
</table>
<hr width=100%/>
</div>

<div class="center">
Your budget has been exported to an Excel file.  Please click the download link to open it.
</div>

<div class="center">
 <a href="exportBudget.cfm?excel_file=#vars.excel_file#&budget_id=#url.budget_id#">#LCase(ActionText("download"))#</a>
 <cfset local.query_string = []>
 <cfloop collection="#url#" item="local.item">
    <cfif local.item neq "budget_id">
        <cfset arrayAppend(local.query_string, lcase(local.item) & "=" & url[ local.item ])>
    </cfif>
 </cfloop>
 <cfset local.query_string = arrayToList(local.query_string,'&')>
 <a onclick="window.location='index.cfm?#local.query_string#'">#LCase(ActionText("return to budgets list"))#</a>
</div>
</fieldset>
</body>
</html>

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="createExcelFile" output="false">
<cfscript>
  if ( vars.qBudget.allocation_position_level eq const.customers ) {
   vars.allocation_type = "Customer";
   const.not_released_id = "00000000-0000-0000-0000-000000000000";
   vars.last_column = 7;
   vars.first_numeric_column = 3;
  }
  else {
   vars.allocation_type = "Position";
   const.not_released_id = "0";
   vars.last_column = 6;
   vars.first_numeric_column = 2;
  }
  vars.hidden_column = 9;
</cfscript>

<!--- Get data --->
<cfquery name="vars.qEntries" Datasource="#application.datasource#">
  <cfif vars.qBudget.Allocation_Position_Level eq const.customers>
    SELECT Name = CASE
                      WHEN bda.Bsa_FoodService_Customers_Id = '#const.not_released_id#' THEN 'Not Released'
                      ELSE Customer.Name
                  END
           , Customer.Shr_Ship_To    <!--- 47143 --->
	         , Address = Customer.Address_1 + ' ' + Customer.City + ' ' + Customer.State + ' ' + Customer.ZipCode
           , Budget_Dollar = bda.Budget_Dollar
           , Committed_Dollar = bda.Committed_Dollar
           , Committed_Balance = (bda.Budget_Dollar - bda.Committed_Dollar)
           , Actual_Dollar = bda.Actual_Dollar
           , Actual_Balance = (bda.Budget_Dollar - bda.Actual_Dollar)
           , Row_Id = bda.Bsa_FoodService_Customers_Id
      FROM Budget_Distributor_Allocation bda
      LEFT JOIN Bsa_FoodService_Customers Customer ON bda.Bsa_FoodService_Customers_Id = Customer.Bsa_FoodService_Customers_Id
     WHERE Budget_Id = <cfqueryparam value="#url.Budget_Id#" cfsqltype="cf_sql_integer">
  <cfelse>
    SELECT Name = CASE
                      WHEN bPa.User_Position_ID = <cfoutput>#const.not_released_id#</cfoutput> THEN 'Not Released'
                      ELSE Up.Position_Label
                  END
           , Budget_Dollar = bpa.Budget_Dollar
           , Committed_Dollar = bpa.Committed_Dollar
           , Committed_Balance = (bpa.Budget_Dollar - bpa.Committed_Dollar)
           , Actual_Dollar = bpa.Actual_Dollar
           , Actual_Balance = (bpa.Budget_Dollar - bpa.Actual_Dollar)
           , Foo = ' '             <!---dummy field--->
           , Bar = ' '             <!---dummy field--->
           , Row_Id = bpa.User_Position_ID
      FROM Budget_Position_Allocation bpa
      LEFT JOIN User_Positions Up ON Up.User_Positions_ID = bpa.User_Position_ID
     WHERE Budget_Id = <cfqueryparam value="#url.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfif>
</cfquery>

<!--- Create new spreadsheet --->
<cfscript>
 vars.xls_object = SpreadsheetNew();
 // show budget code/description
 SpreadsheetAddRow(vars.xls_object, "Budget Code: #vars.qBudget.Budget_Code#,,Description: #vars.qBudget.Budget_Desc#");
 SpreadsheetFormatRow(vars.xls_object, {bold=TRUE, fgcolor="white", color="dark_blue", fontsize="11"}, 1);

 SpreadsheetMergeCells(vars.xls_object, 1, 1, 1, 2);
 SpreadsheetMergeCells(vars.xls_object, 1, 1, 3, vars.last_column);

 // save budget_id into hidden cell on row 1
 SpreadsheetSetCellValue(vars.xls_object, url.budget_id, 1, vars.hidden_column);

 SpreadsheetFormatCell(vars.xls_object, {alignment="right"}, 1, 3);

 // show columns heading
 if ( vars.qBudget.allocation_position_level eq const.customers ) {
   SpreadsheetAddRow(vars.xls_object, "Customer,Customer_Number,Address,Budget_Dollar,Committed_Dollar,Committed_Balance,Actual_Dollar,Actual_Balance");
 }
 else {
   SpreadsheetAddRow(vars.xls_object, "Position,Budget_Dollar,Committed_Dollar,Committed_Balance,Actual_Dollar,Actual_Balance");
 }

 SpreadsheetFormatRow(vars.xls_object, {bold=true, fontsize="10", alignment="right", fgcolor="light_blue", color="white"}, 2);
 SpreadsheetFormatCell(vars.xls_object, {alignment="left"}, 2, 1);

 if ( vars.qBudget.allocation_position_level eq const.customers ) {
   SpreadsheetFormatCell(vars.xls_object, {alignment="left"}, 2, 3);
 }

 // Add entries from query
 SpreadsheetAddRows(vars.xls_object, vars.qEntries);

 // Format amount columns as currency
 for ( vars.idx = vars.first_numeric_column; vars.idx lte vars.last_column; ++vars.idx ) {
 	SpreadsheetFormatColumn(vars.xls_object, {dataformat="$##,####0.00"}, vars.idx);
 }

 // hide all IDs in hidden column
 SpreadsheetFormatColumn(vars.xls_object, {dataformat=";;;"}, vars.hidden_column);
</cfscript>

<!--- Save it --->
<cfset vars.excel_file = budgetFolder() & "\budget_" & replace(vars.qBudget.Budget_ID,' ','_','all') & ".xls">
<cfspreadsheet action="write"
		name = "vars.xls_object"
		filename = #vars.excel_file#
		overwrite = "true">

<cfreturn vars.excel_file>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="budgetFolder" output="false" hint="Creates/returns Excel statement output folder.">
  <cfset var common = ExpandPath('/common_documents/temp_files/')>
  <cfset var xlsFolder = common & 'budgets'>

  <!---create new folder to store Excel budgets--->
  <cfif not DirectoryExists(xlsFolder)>
    <cfdirectory directory = #xlsFolder# action = "create">
  </cfif>

  <cfreturn xlsFolder>
</cffunction>

</cfoutput>
