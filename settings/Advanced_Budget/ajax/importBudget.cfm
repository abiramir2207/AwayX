<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\importBudget.cfm
      Date:     Aug 11, 2011
      Author:   Chris Nguyen
      Purpose:  Import budget dollars for positions/customers from an Excel file (fixed budget)

      Required Parameters:
        - url.budget_id: integer

      Notes:  This template returns a JSON structure with 2 elements:
                - STATUS:  200 (success)  500 (failure)
                - MESSAGE:  Error message
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="No">
<cfscript>
  main = {};
  const = {};
  const.customers = 4;
</cfscript>

<cftry>
  <cffile action="upload" destination="#budgetFolder()#" nameconflict="overwrite" result="main.upload"/>

  <cfquery name="main.qBudget" datasource="#application.datasource#">
      SELECT Budget_desc
             , Budget_Code
             , Budget_Dollar
             , Allocation_Position_Level
             , Budget_Id
        FROM Budget
       WHERE Budget.Budget_Id = <cfqueryparam value="#url.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfset LoadValidateExcelFile()>
  <cfset UpdateDatabase()>

  <!---send success status back--->
  <cfoutput>#serializeJSON({STATUS=200, MESSAGE="Done"})#</cfoutput>
<cfcatch type="any" >
  <cfset RaiseException( cfcatch.detail )>
</cfcatch>
</cftry>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="budgetFolder" output="false" hint="Creates/returns Excel statement upload folder.">
  <cfset var common = ExpandPath('/common_documents/data_files/uploaded/')>
  <cfset var xlsFolder = common & 'budgets'>

  <!---create new folder to upload Excel budgets--->
  <cfif not DirectoryExists(xlsFolder)>
    <cfdirectory directory = "#xlsFolder#" action = "create">
  </cfif>

  <cfreturn xlsFolder>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="NumericValue" output="false" hint="I return the numeric value of a string.">
  <cfargument name="numericString" required="true" hint="I am the numeric string.">
  <cfset arguments.numericString = Replace(arguments.numericString, '$', '', 'all')>
  <cfset arguments.numericString = Replace(arguments.numericString, ',', '', 'all')>

  <cfif Len(Trim( arguments.numericString )) eq 0>
    <cfreturn 0>
  <cfelseif IsNumeric( arguments.numericString )>
    <cfreturn arguments.numericString>
  <cfelse>
    <cfreturn 0>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="IsDollar" output="false" hint="I return true if passing argument is a dollar amount.">
  <cfargument name="dollar_string" type="string" required="true">
  <!---remove dollar sign--->
  <cfset arguments.dollar_string = Replace(arguments.dollar_string, '$', '', 'all')>
  <!---remove commas--->
  <cfset arguments.dollar_string = Replace(arguments.dollar_string, ',', '', 'all')>

  <cfreturn IsNumeric(arguments.dollar_string)>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="RaiseException" output="true" hint="I handle exceptions.">
  <cfargument name="detail_message" type="string" default="Unexpected errors have occurred.">
  <cfoutput>#serializeJSON({STATUS=500, MESSAGE=JSStringFormat(arguments.detail_message)})#</cfoutput>
  <cfabort>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="LoadValidateExcelFile" output="true">
  <cfscript>
     var vars = {};
     vars.bad_row_ids = [];
     vars.non_numeric_rows = [];
     vars.error_message = "";
  </cfscript>

  <cftry>
    <!--- budget dollar column = 3 (customer type) or 2 (position type)--->
    <cfset vars.budget_dollar_column = ((main.qBudget.Allocation_Position_Level eq const.customers) ? 4 : 2)>   <!--- 47143 --->
    <cfset vars.hidden_ids_column = 9>

    <!--- load excel content into a query --->
    <cfspreadsheet action="read"
          src = "#(main.upload.serverDirectory & '\' & main.upload.serverFileName & '.' & main.upload.serverFileExt)#"
          query = "main.qExcelEntries"
          headerrow = "2"
          excludeHeaderRow = "true"
          columns = "#vars.budget_dollar_column#,#vars.hidden_ids_column#"
          columnnames = "budget_dollar,row_id">

    <!---validate budget id--->
    <cfif main.qExcelEntries.row_id neq main.qBudget.budget_id>
      <cfset RaiseException( "The selected Excel file is not for this budget." )>
    </cfif>

    <!--- validate all rows --->
    <cfloop query="main.qExcelEntries" startrow="2">
      <cfif not IsDollar(main.qExcelEntries.Budget_Dollar)>
        <cfset ArrayAppend(vars.non_numeric_rows, main.qExcelEntries.CurrentRow)>
      </cfif>
      <!---validate for empty row id--->
      <cfif len(trim(main.qExcelEntries.row_id)) eq 0>
        <cfset ArrayAppend(vars.bad_row_ids, main.qExcelEntries.CurrentRow)>
      <!---validate customer row id--->
      <cfelseif main.qBudget.Allocation_Position_Level eq const.customers>
        <cfif not IsValid("guid", main.qExcelEntries.row_id )>
          <cfset ArrayAppend(vars.bad_row_ids, main.qExcelEntries.CurrentRow)>
        </cfif>
      <!---validate position row id--->
      <cfelseif not IsNumeric(main.qExcelEntries.row_id)>
        <cfset ArrayAppend(vars.bad_row_ids, main.qExcelEntries.CurrentRow)>
      </cfif>
    </cfloop>


    <cfif arrayLen(vars.bad_row_ids)>
      <cfset vars.error_message = "Missing/invalid row IDs in the selected Excel file">
    <cfelseif arrayLen(vars.non_numeric_rows)>
      <cfset vars.error_message = "Invalid budget dollars on row" & ((arrayLen(vars.non_numeric_rows) gt 1) ? "s " : " ") & arrayToList(vars.non_numeric_rows)>
    </cfif>

    <cfif len(vars.error_message)>
      <cfset RaiseException( vars.error_message )>
    </cfif>
  <cfcatch type="any">
    <cfset RaiseException( cfcatch.detail )>
  </cfcatch>
  </cftry>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="UpdateDatabase" output="false" hint="I take the Excel data and put them in the database.">
  <cfscript>
     var vars = {};
  </cfscript>
  <cfloop query="main.qExcelEntries" startrow="2">
    <cfquery name="vars.saveCustomer" datasource="#application.datasource#">
      <cfif main.qBudget.Allocation_Position_Level eq const.customers>
        UPDATE Budget_Distributor_Allocation
           SET Budget_Dollar = <cfqueryparam value="#NumericValue(main.qExcelEntries.budget_dollar)#" cfsqltype="cf_sql_decimal" scale=2>
         WHERE Budget_Id = <cfqueryparam value="#main.qBudget.Budget_Id#" cfsqltype="cf_sql_integer">
               AND Bsa_FoodService_Customers_Id = <cfqueryparam value="#main.qExcelEntries.row_id#" cfsqltype="cf_sql_varchar">
      <cfelse>
        UPDATE Budget_Position_Allocation
           SET Budget_Dollar = <cfqueryparam value="#NumericValue(main.qExcelEntries.budget_dollar)#" cfsqltype="cf_sql_decimal" scale=2>
         WHERE Budget_Id = <cfqueryparam value="#main.qBudget.Budget_Id#" cfsqltype="cf_sql_integer">
               AND User_Position_ID = <cfqueryparam value="#main.qExcelEntries.row_id#" cfsqltype="cf_sql_integer">
      </cfif>
    </cfquery>
  </cfloop>
</cffunction>

