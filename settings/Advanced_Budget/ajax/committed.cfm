<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\ajax\committed.cfm
      Date:     August 16, 2011
      Author:   Chris Nguyen
      Purpose:  Returns JSON data to the front-end budget committed report page

      Required Parameters:
        1. form.Budget_Contribution_Factor_Type_ID: integer
        2. form.budget_id: integer

----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfsilent>
<cfscript>
 const = {};
 const.variable_budget = 3;
 const.customers = 4;
 vars  = {};
</cfscript>

<!---form parameters passed from DataTables--->
<cfparam name="form.iDisplayStart"  default="0"  type="integer" />
<cfparam name="form.iDisplayLength" default="200" type="integer" />
<cfparam name="form.sSearch"        default=""   type="string"  />
<cfparam name="form.sEcho"          default="1"  type="integer" />
<cfparam name="form.iSortingCols"   default="2"  type="integer" />
<cfparam name="form.displayOption"  default="all"/>

<!------------------------------------
	SQL queries
------------------------------------->

<!--- Drop temp table to avoid error due to column mismatch --->
<cfquery datasource="#application.datasource#" name="qDropTempTables">
    IF Object_id( 'tempdb..##tmp_budget_program_committed' ) IS NOT NULL
      DROP TABLE ##tmp_Budget_Program_Committed
</cfquery>

<!--- Data set after filtering --->
<cfquery datasource="#application.datasource#" name="qFiltered">
  <cfif (form.Budget_Contribution_Factor_Type_ID neq const.variable_budget)
     and (form.Allocation_Position_Level eq const.customers)>

    SELECT bsa_FoodService_Customers.bsa_FoodService_Customers_Id AS bsa_FoodService_Customers_Id
           , bsa_FoodService_Customers.shr_Ship_To
           , bsa_FoodService_Customers.Name
           , Sum( Budget_Distributor_Program.Committed_Dollar ) AS Committed_Dollar
           , Sum( Budget_Distributor_Program.Actual_Dollar ) AS Actual_Dollar
           , Max( Contract_Main_Id )                            AS Max_Contract_Main_Id
      INTO ##tmp_Budget_Program_Committed
      FROM Budget_Distributor_Program
           LEFT JOIN bsa_FoodService_Customers
             ON bsa_FoodService_Customers.bsa_FoodService_Customers_Id = Budget_Distributor_Program.bsa_FoodService_Customers_Id
     WHERE Budget_Id = #form.Budget_Id#
     GROUP BY bsa_FoodService_Customers.bsa_FoodService_Customers_Id
              , bsa_FoodService_Customers.shr_Ship_To
              , bsa_FoodService_Customers.Name
              , Budget_Distributor_Program.Contract_Number

    SELECT   Position_Customer = Bsa_FoodService_Customers.Name +'&nbsp;&nbsp;'+ '(' + bsa_FoodService_Customers.shr_Ship_To + ')'
           , Contract_Main.Contract_Number
           , Contract_Main.Contract_Title
           , Contract_Main.Contract_Start_Date
           , Contract_Main.Contract_End_Date
           , Rsp = _Users.Name_First + ' ' + _Users.Name_Last
           , Template = Program_control_panel_options.created_type
           , Committed_Dollar
           , Actual_Dollar
		       , Contract_Main.Manual_Cancel
      FROM ##tmp_Budget_Program_Committed
           LEFT JOIN Contract_Main
             ON Contract_Main.Contract_Main_Id = ##tmp_Budget_Program_Committed.Max_Contract_Main_Id
           LEFT JOIN Bsa_FoodService_Customers
             ON Bsa_FoodService_Customers.bsa_FoodService_Customers_Id = ##tmp_Budget_Program_Committed.bsa_FoodService_Customers_Id
           LEFT JOIN _Users
             ON _Users.User_ID = Contract_Main.Responsible_User_ID
           LEFT JOIN Program_control_panel_options
             ON Program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
     WHERE 1 = 1
     			<cfif form.displayOption eq "cancelOff">
     			AND Contract_Main.Manual_Cancel = 0
     			<cfelseif form.displayOption eq "cancelOnly">
     			AND Contract_Main.Manual_Cancel = 1
     			</cfif>
     			<!--- D33682: Cancel/Purged Programs - Remove when no payments... --->
     			AND (Contract_Main.Manual_Cancel = 0 OR ##tmp_Budget_Program_Committed.Actual_Dollar != 0)
  <cfelse>

		SELECT Budget_Position_Program.User_Position_Id
		       , ISNULL(User_Positions.Position_Label,'') AS Position_Label
		       , Sum( Budget_Position_Program.Committed_Dollar ) AS Committed_Dollar
		       , Sum( Budget_Position_Program.Actual_Dollar ) AS Actual_Dollar
		       , Max( Contract_Main_Id )                         AS Max_Contract_Main_Id
		  INTO ##tmp_Budget_Program_Committed
		  FROM Budget_Position_Program
		       LEFT JOIN User_Positions
		         ON User_Positions.User_Positions_Id = Budget_Position_Program.User_Position_Id
		 WHERE Budget_Id = #form.Budget_Id#
		 GROUP BY Budget_Position_Program.User_Position_Id
		          , User_Positions.Position_Label
		          , Budget_Position_Program.Contract_Number

		SELECT
             Position_Label AS Position_Customer
		       , Contract_Main.Contract_Number
		       , Contract_Main.Contract_Title
		       , Contract_Main.Contract_Start_Date
		       , Contract_Main.Contract_End_Date
           , _Users.Name_First + ' ' + _Users.Name_Last AS Rsp
           , Program_control_panel_options.created_type AS Template
		       , Committed_Dollar
		       , Actual_Dollar
		       , Contract_Main.Manual_Cancel
		  FROM ##tmp_Budget_Program_Committed
		       LEFT JOIN Contract_Main
		         ON Contract_Main.Contract_Main_Id = ##tmp_Budget_Program_Committed.Max_Contract_Main_Id
		       LEFT JOIN _Users
		         ON _Users.User_ID = Contract_Main.Responsible_User_ID
           LEFT JOIN Program_control_panel_options
             ON Program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
     WHERE 1 = 1
     			<cfif form.displayOption eq "cancelOff">
     			AND Contract_Main.Manual_Cancel = 0
     			<cfelseif form.displayOption eq "cancelOnly">
     			AND Contract_Main.Manual_Cancel = 1
     			</cfif>
     			<!--- D33682: Cancel/Purged Programs - Remove when no payments... --->
     			AND (Contract_Main.Manual_Cancel = 0 OR ##tmp_Budget_Program_Committed.Actual_Dollar != 0)
 </cfif>

  <!---filtering conditions--->
  <cfif len(trim(form.sSearch))>
    AND (
        <!---replace all double spaces into single space--->
        <cfset form.sSearch = Replace(Trim(form.sSearch), "  ", " ", "all")>
        <!---replace the middle blank spaces with %s--->
        <cfset form.sSearch = Replace(form.sSearch, " ", "%", "all")>

           Contract_Main.Contract_Number LIKE '%#form.sSearch#%'
        OR Contract_Main.Contract_Title LIKE '%#form.sSearch#%'
        OR Program_control_panel_options.created_type LIKE '%#form.sSearch#%'
        OR _Users.Name_First LIKE '%#form.sSearch#%'
        OR _Users.Name_Last LIKE '%#form.sSearch#%'
        <cfif (form.Budget_Contribution_Factor_Type_ID neq const.variable_budget)
             and (form.Allocation_Position_Level eq const.customers)>
            OR Bsa_FoodService_Customers.Name LIKE '%#form.sSearch#%'
            OR bsa_FoodService_Customers.shr_Ship_To LIKE '%#form.sSearch#%'
        <cfelse>
            OR Position_Label LIKE '%#form.sSearch#%'
        </cfif>
        )
  </cfif>


  <!---sorting options--->
  <cfswitch expression="#FORM.iSortCol_0#">
    <cfcase value='0'> ORDER BY Contract_Main.Contract_Number #FORM.sSortDir_0# </cfcase>
    <cfcase value='1'> ORDER BY Contract_Main.Contract_Title #FORM.sSortDir_0# </cfcase>
    <cfcase value='2'> ORDER BY Program_control_panel_options.created_type #FORM.sSortDir_0# </cfcase>

    <cfcase value='3'> ORDER BY Contract_Main.Contract_Start_Date #FORM.sSortDir_0# </cfcase>
    <cfcase value='4'> ORDER BY Contract_Main.Contract_End_Date #FORM.sSortDir_0# </cfcase>
    <cfcase value='5'> ORDER BY RSP #FORM.sSortDir_0# </cfcase>

    <cfcase value='6'> ORDER BY Position_Customer #FORM.sSortDir_0# </cfcase>
    <cfcase value='7'> ORDER BY Committed_Dollar #FORM.sSortDir_0# </cfcase>
    <cfcase value='8'> ORDER BY Actual_Dollar #FORM.sSortDir_0# </cfcase>
   </cfswitch>



</cfquery>




<cfquery name="qTotal" dbtype="query">
  SELECT SUM(Committed_Dollar) AS Committed_Dollar, SUM(Actual_Dollar) AS Actual_Dollar
    FROM qFiltered
</cfquery>

<!------------------------------------
   Total data set length
------------------------------------->
<!--- filter is NOT specified total count can be calculated from qFiltered w/o accessing the db --->
<cfif len(trim(form.sSearch)) eq 0>
  <cfquery dbtype="query" name="qBeforeFilter">
    SELECT COUNT(1) as rownbr
      FROM qFiltered
  </cfquery>
  <!---  for some unknown reasons temp table got carried over to other sessions
         make it disappeared before returning to the parent code --->
  <cfquery datasource="#application.datasource#" name="qZap">
    DROP TABLE ##tmp_Budget_Program_Committed
  </cfquery>
<cfelse>
<!--- filter is specified need to query the db for the total count --->
  <cfquery datasource="#application.datasource#" name="qBeforeFilter">
      SELECT COUNT(1) AS rownbr
        FROM ##tmp_Budget_Program_Committed
             LEFT JOIN Contract_Main
               ON Contract_Main.Contract_Main_Id = ##tmp_Budget_Program_Committed.Max_Contract_Main_Id
       WHERE 1 = 1
            <cfif form.displayOption eq "cancelOff">
            AND Contract_Main.Manual_Cancel = 0
            <cfelseif form.displayOption eq "cancelOnly">
            AND Contract_Main.Manual_Cancel = 1
            </cfif>
            <!--- D33682: Cancel/Purged Programs - Remove when no payments... --->
            AND (Contract_Main.Manual_Cancel = 0 OR ##tmp_Budget_Program_Committed.Actual_Dollar != 0)

      DROP TABLE ##tmp_Budget_Program_Committed
  </cfquery>
</cfif>


<!------------------------------------
	Output to pass back to DataTables
------------------------------------->
<cfscript>
  variables.page_size    = val(FORM.iDisplayLength);
  variables.start_row    = FORM.iDisplayStart + 1;
  variables.end_row      = min( val(FORM.iDisplayStart) + variables.page_size, qFiltered.recordCount );

  variables.reply        = {};
  variables.reply.aaData = [];
  variables.reply.iTotalRecords        = qBeforeFilter.rownbr;
  variables.reply.iTotalDisplayRecords = qFiltered.recordCount;
</cfscript>

<cfoutput>
  <cfloop query="qFiltered" startRow="#variables.start_row#" endRow="#variables.end_row#">
    <cfscript>
       variables.dArrayTmp = [];

       arrayAppend(variables.dArrayTmp, qFiltered.Contract_Number);
       arrayAppend(variables.dArrayTmp, qFiltered.Contract_Title);
       arrayAppend(variables.dArrayTmp, qFiltered.Template);

       arrayAppend(variables.dArrayTmp, dateFormat(qFiltered.Contract_Start_Date, 'medium'));
       arrayAppend(variables.dArrayTmp, dateFormat(qFiltered.Contract_End_Date, 'medium'));

       arrayAppend(variables.dArrayTmp, qFiltered.RSP);
       arrayAppend(variables.dArrayTmp, qFiltered.Position_Customer);

       arrayAppend(variables.dArrayTmp, dollarFormat(qFiltered.Committed_Dollar));
       arrayAppend(variables.dArrayTmp, dollarFormat(qFiltered.Actual_Dollar));

       arrayAppend(variables.dArrayTmp, qFiltered.Manual_Cancel);

       arrayAppend(variables.reply.aaData, variables.dArrayTmp);
    </cfscript>
  </cfloop>
</cfoutput>

<cfscript>
  variables.reply.sEcho  = javacast('int', FORM.sEcho);

  variables.reply.total = "Grand Total";
  variables.reply.actual_dollar = dollarFormat(Val(qTotal.Actual_Dollar));
  variables.reply.committed_dollar = dollarFormat(Val(qTotal.Committed_Dollar));

  variables.sOut = serializeJSON( variables.reply );

  // Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way
  variables.sOut = replace (variables.sOut, 'SECHO', 'sEcho', 'one');
  variables.sOut = replace (variables.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one');
  variables.sOut = replace (variables.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one');

  variables.sOut = replace (variables.sOut, 'TOTAL', 'total', 'one');
  variables.sOut = replace (variables.sOut, 'ACTUAL_DOLLAR', 'actual_dollar', 'one');
  variables.sOut = replace (variables.sOut, 'COMMITTED_DOLLAR', 'committed_dollar', 'one');

  variables.sOut = replace (variables.sOut, 'AADATA', 'aaData', 'one');
</cfscript>
</cfsilent>
<!---send JSON data back to client--->
<cfoutput>#variables.sOut#</cfoutput>