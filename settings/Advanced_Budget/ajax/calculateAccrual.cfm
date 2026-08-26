<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\ajax\calculateAccrual.cfm
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:  Returns JSON data to the front-end budget report page

      Required Parameters:
        1. form.allocation_position_level: integer
               - Allocation by Customer (passed value = 4)
               - Allocation by Position (passed value <> 4)
        2. form.budget_id: integer

      Optional parameters:
        1. form.calculate: bit
               - Call stored procedure to calculate (passed value = 1)
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<!-----------------------------------------
	1. Db columns for display, filter & sort
------------------------------------------->
<cfscript>
 const = {};
 const.customers = 4;

 vars = {};

 if ( form.allocation_position_level eq const.customers ) {
  const.not_released_id = "00000000-0000-0000-0000-000000000000";
  vars.aoColumns = [  { name="bfc.Name"         , bSearchable=true , datatype="string"}
 		                , { name="Original_Budget_Dollar", bSearchable=false, datatype="numeric"}
 		                , { name="Adjustment_Dollar"     , bSearchable=false, datatype="numeric"}
 		                , { name="Budget_Dollar"    , bSearchable=false, datatype="numeric"}
 		                , { name="Committed_Dollar" , bSearchable=false, datatype="numeric"}
 		                , { name="Committed_Balance", bSearchable=false, datatype="numeric"}
 		                , { name="Actual_Dollar"    , bSearchable=false, datatype="numeric"}
 		                , { name="Actual_Balance"   , bSearchable=false, datatype="numeric"}
 		               ];
  }
 else {
  const.not_released_id = 0;
  vars.aoColumns = [  { name="Up.Position_Label", bSearchable=true , datatype="string"}
 		                , { name="Original_Budget_Dollar", bSearchable=false, datatype="numeric"}
 		                , { name="Adjustment_Dollar"     , bSearchable=false, datatype="numeric"}
 		                , { name="Budget_Dollar"    , bSearchable=false, datatype="numeric"}
 		                , { name="Committed_Dollar" , bSearchable=false, datatype="numeric"}
 		                , { name="Committed_Balance", bSearchable=false, datatype="numeric"}
 		                , { name="Actual_Dollar"    , bSearchable=false, datatype="numeric"}
 		                , { name="Actual_Balance"   , bSearchable=false, datatype="numeric"}
 		               ];
 }
 vars.filtered_words = [];
</cfscript>

<!---<cfset structAppend(form, form)>--->

<!---form parameters passed from DataTables--->
<cfparam name="form.iDisplayStart"  default="0"  type="integer" />
<cfparam name="form.iDisplayLength" default="1000" type="integer" />
<cfparam name="form.sSearch"        default=""   type="string"  />
<cfparam name="form.sEcho"          default="1"  type="integer" />
<cfparam name="form.iSortingCols"   default="2"  type="integer" />

<!---calculate accrual budget only on first run ( form.sEcho = 1 )--->
<cfif StructKeyExists(form, "calculate") and form.sEcho eq "1">
 <cfstoredproc procedure="Adv_Budget_Accrual_Calculation" datasource="#application.datasource#">
 	<cfprocparam type="in" 	cfsqltype="cf_sql_integer"	dbvarname="@budget_id"		value="#form.budget_id#">
 	<cfprocparam type="in"	cfsqltype="cf_sql_varchar"	dbvarname="@user_id"		  value="#request.AccessStructure.User_ID#">
 </cfstoredproc>
 <cfquery name="qBudget" datasource="#application.datasource#">
    UPDATE Budget
       SET Budget_Status = <cfqueryparam value="calculated" cfsqltype="cf_sql_varchar">
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
 </cfquery>
</cfif>

<!------------------------------------
	2. SQL queries
------------------------------------->
<!--- Data set after filtering --->
<cfquery datasource="#application.datasource#" name="qFiltered" result="result">
 <cfif form.Allocation_Position_Level eq const.customers>
  SELECT   Name = CASE
                    WHEN bda.Bsa_FoodService_Customers_Id = '<cfoutput>#const.not_released_id#</cfoutput>' THEN ' Not Released'
                    ELSE bfc.Name + ' (' + bfc.Shr_Ship_To + ')'
                  END
         , Original_Budget_Dollar = isnull(bda.Original_Budget_Dollar, 0)
         , Adjustment_Dollar      = isnull(bda.Adjustment_Dollar, 0)
         , Budget_Dollar     = isnull(bda.Budget_Dollar, 0)
         , Committed_Dollar  = isnull(bda.Committed_Dollar, 0)
         , Committed_Balance = ( isnull(bda.Budget_Dollar, 0) - isnull(bda.Committed_Dollar, 0) )
         , Actual_Dollar     = isnull(bda.Actual_Dollar, 0)
         , Actual_Balance    = ( isnull(bda.Budget_Dollar, 0) - isnull(bda.Actual_Dollar, 0) )
    FROM Budget_Distributor_Allocation bda
         LEFT JOIN Bsa_FoodService_Customers bfc
           ON bfc.Bsa_FoodService_Customers_Id = bda.Bsa_FoodService_Customers_Id
   WHERE bda.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
 <cfelse>
  SELECT   Position_Label = CASE
                              WHEN bPa.User_Position_ID = <cfoutput>#const.not_released_id#</cfoutput> THEN ' Not Released'
                              ELSE Up.Position_Label
                            END
         , Original_Budget_Dollar = isnull(bPa.Original_Budget_Dollar, 0)
         , Adjustment_Dollar      = isnull(bPa.Adjustment_Dollar, 0)
         , Budget_Dollar     = isnull(bPa.Budget_Dollar, 0)
         , Committed_Dollar  = isnull(bPa.Committed_Dollar, 0)
         , Committed_Balance = ( isnull(bPa.Budget_Dollar, 0) - isnull(bPa.Committed_Dollar, 0) )
         , Actual_Dollar     = isnull(bPa.Actual_Dollar, 0)
         , Actual_Balance    = ( isnull(bPa.Budget_Dollar, 0) - isnull(bPa.Actual_Dollar, 0) )
    FROM Budget_Position_Allocation bPa
         LEFT JOIN User_Positions Up
           ON Up.User_Positions_ID = bpa.User_Position_ID
   WHERE bPa.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
 </cfif>
	  <!---filtering conditions--->
	  <cfif len(trim(form.sSearch))>
			AND (
          <cfset vars.cnt = 0>
          <!---replace all double spaces into single space--->
          <cfset form.sSearch = Replace(Trim(form.sSearch), "  ", " ", "all")>
          <!---replace the middle blank spaces with %s--->
          <cfset form.sSearch = Replace(form.sSearch, " ", "%", "all")>
			    <cfloop array="#vars.aoColumns#" index="vars.thisColumn">
						<cfif vars.thisColumn.bSearchable>
              <cfset vars.cnt = vars.cnt + 1>
		    		  <cfif vars.cnt gt 1> OR </cfif>
		    		  #vars.thisColumn.name# LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#form.sSearch#%" />
			    	</cfif>
			    </cfloop>
		   	  )
		</cfif>
  <!---sorting options--->
	<cfif form.iSortingCols gt 0>
	 ORDER BY <cfloop from="0" to="#form.iSortingCols-1#" index="vars.thisSort">
              <cfif vars.thisSort neq 0>, </cfif>#vars.aoColumns[( form[ "iSortCol_" & vars.thisSort ] + 1 )].name#
							<cfif listFindNoCase( "asc,desc", form[ "sSortDir_" & vars.thisSort ] ) gt 0>#form[ "sSortDir_" & vars.thisSort ]#</cfif>
						</cfloop>
	</cfif>
</cfquery>

<cfquery name="qTotal" dbtype="query">
  SELECT   SUM(Budget_Dollar)    AS Budget_Dollar
         , SUM(Committed_Dollar) AS Committed_Dollar
         , SUM(Actual_Dollar)    AS Actual_Dollar
         , SUM(Original_Budget_Dollar)    AS Original_Budget_Dollar
         , SUM(Adjustment_Dollar)         AS Adjustment_Dollar
    FROM qFiltered
</cfquery>

<!------------------------------------
   Total data set length
------------------------------------->
<!--- filter is specified need to query the db for the total count --->
<cfif len(trim(form.sSearch)) eq 0>
  <!--- filter is NOT specified total count can be calculated from qFiltered w/o accessing the db --->
  <cfquery dbtype="query" name="qCount">
    SELECT COUNT(1) as Total
      FROM qFiltered
  </cfquery>
<cfelseif form.Allocation_Position_Level eq const.customers>
  <cfquery datasource="#application.datasource#" name="qCount">
    SELECT COUNT(1) as Total
      FROM Budget_Distributor_Allocation bda
     WHERE bda.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
<cfelse>
	<cfquery datasource="#application.datasource#" name="qCount">
		SELECT COUNT(1) as Total
      FROM Budget_Position_Allocation bPa
   WHERE bPa.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
	</cfquery>
</cfif>

<!------------------------------------
	Output to pass back to DataTables
------------------------------------->
<cfcontent reset="Yes" />
<cfoutput>
{"sEcho": #val(form.sEcho)#,
"iTotalRecords": #Val(qCount.total)#,
"iTotalDisplayRecords": #qFiltered.recordCount#,
"budget_dollar": "#DollarFormat(Val(qTotal.Budget_Dollar))#",
"original_budget_dollar": "#DollarFormat(Val(qTotal.Original_Budget_Dollar))#",
"adjustment_dollar": "#DollarFormat(Val(qTotal.Adjustment_Dollar))#",
"committed_dollar": "#DollarFormat(Val(qTotal.Committed_Dollar))#",
"committed_balance": "#DollarFormat(Val(qTotal.Budget_Dollar) - Val(qTotal.Committed_Dollar))#",
"actual_dollar": "#DollarFormat(Val(qTotal.Actual_Dollar))#",
"actual_balance": "#DollarFormat(Val(qTotal.Budget_Dollar) - Val(qTotal.Actual_Dollar))#",
"aaData": [
</cfoutput>
<cfsetting enablecfoutputonly="true">
<cfloop query="qFiltered">
  <cfif currentRow gt (form.iDisplayStart+1)>
      <cfoutput>,</cfoutput>
  </cfif>
  <cfoutput>[</cfoutput>
  <cfset vars.display_cnt = 0>
  <cfloop array="#vars.aoColumns#" index="vars.thisColumn">
		<cfscript>
  		vars.display_cnt = vars.display_cnt + 1;
      // remove the alias in the column name (e.g. i.CustomerID would become CustomerID)
      if ( ListLen(vars.thisColumn.name, '.') le 1 )
  		  vars.cfQueryColumnName = vars.thisColumn.name;
      else
        vars.cfQueryColumnName = ListGetAt(vars.thisColumn.name, 2, '.');
    </cfscript>
		<cfif vars.display_cnt gt 1>
      <cfoutput>,</cfoutput>
    </cfif>
		<cfif vars.thisColumn.datatype eq "numeric">
  		<cfoutput>"#DollarFormat(qFiltered[vars.CFQueryColumnName] [qFiltered.currentRow])#"</cfoutput>
		<cfelse>
		  <cfoutput>"#jsStringFormat( Replace(Trim(qFiltered[vars.CFQueryColumnName] [qFiltered.currentRow]), chr(39), '', 'all') )#"</cfoutput>
		</cfif>
	</cfloop>
	<cfoutput>]
</cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false">
]}
