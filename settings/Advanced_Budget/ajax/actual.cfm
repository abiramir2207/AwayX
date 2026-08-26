<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\ajax\actual.cfm
      Date:     August 16, 2011
      Author:   Chris Nguyen
      Purpose:  Returns JSON data to the front-end budget actual report page

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


<!------------------------------------
	2. SQL queries
------------------------------------->
<!--- Data set after filtering --->
<cfquery datasource="#application.datasource#" name="qFiltered" result="result">
 <cfif (form.Budget_Contribution_Factor_Type_ID neq const.variable_budget)
     and (form.Allocation_Position_Level eq const.customers)>
    	SELECT Position_Customer = Bsa_FoodService_Customers.Name + '&nbsp;&nbsp;'+  '(' + Bsa_FoodService_Customers.shr_Ship_To + ')'
			, Contract_Main.Contract_Number
			, Contract_Main.Contract_Title
			, Billback.BB_Start_Date
			, Billback.BB_End_Date
			, Template = Program_control_panel_options.created_type
			, Budget_Distributor_Billback.Actual_Dollar
			, ISNULL(Billback.BB_Code, 'N/A') as BB_Code
			, CASE Budget_Distributor_Billback.Billback_ID
				WHEN '00000000-0000-0000-0000-000000000000' THEN 'Off-Invoice'
				WHEN '00000000-0000-0000-0000-000000000001' THEN 'Adjustment'
				ELSE Billback.BB_Title
				END as BB_Title
		FROM Budget_Distributor_Billback
		LEFT JOIN Billback
		ON	Billback.Billback_ID = Budget_Distributor_Billback.Billback_ID
		INNER JOIN Contract_Main
		ON	Contract_Main.Contract_Main_ID = Budget_Distributor_Billback.Contract_Main_ID
		LEFT JOIN Program_control_panel_options
             ON Program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
		LEFT JOIN Bsa_FoodService_Customers
		ON	Bsa_FoodService_Customers.Bsa_FoodService_Customers_ID = Budget_Distributor_Billback.Bsa_FoodService_Customers_ID
		WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
  <cfelse>
		SELECT Position_Customer = User_Positions.Position_Label
			, Contract_Main.Contract_Number
			, Contract_Main.Contract_Title
			, Billback.BB_Start_Date
			, Billback.BB_End_Date
           	, Template = Program_control_panel_options.created_type
			, Budget_Position_Billback.Actual_Dollar
			, ISNULL(Billback.BB_Code, 'N/A') as BB_Code
			, CASE Budget_Position_Billback.Billback_ID
				WHEN '00000000-0000-0000-0000-000000000000' THEN 'Off-Invoice'
				WHEN '00000000-0000-0000-0000-000000000001' THEN 'Adjustment'
				ELSE Billback.BB_Title
				END as BB_Title

		FROM Budget_Position_Billback
		LEFT JOIN Billback
		ON	Billback.Billback_ID = Budget_Position_Billback.Billback_ID
		INNER JOIN Contract_Main
		ON	Contract_Main.Contract_Main_ID = Budget_Position_Billback.Contract_Main_ID
		LEFT JOIN Program_control_panel_options
             ON Program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
		LEFT JOIN User_Positions
		ON	User_Positions.User_Positions_Id = Budget_Position_Billback.User_Position_Id
		WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">

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

          OR Billback.BB_Code LIKE '%#form.sSearch#%'
          <cfif (form.Budget_Contribution_Factor_Type_ID neq const.variable_budget)
     and (form.Allocation_Position_Level eq const.customers)>
          OR Bsa_FoodService_Customers.Name LIKE '%#form.sSearch#%'
          OR Bsa_FoodService_Customers.shr_Ship_To LIKE '%#form.sSearch#%'
        <cfelse>
          OR User_Positions.Position_Label LIKE '%#form.sSearch#%'
        </cfif>
          OR Contract_Main.Contract_Title LIKE '%#form.sSearch#%'
          OR Contract_Main.Contract_Title LIKE '%#form.sSearch#%'
          OR Contract_Main.Contract_Title LIKE '%#form.sSearch#%'
		   	  )
		</cfif>

  <!---sorting options--->
  <cfswitch expression="#FORM.iSortCol_0#">
      <cfcase value='0'> ORDER BY Contract_Main.Contract_Number #FORM.sSortDir_0# </cfcase>
      <cfcase value='1'> ORDER BY Contract_Main.Contract_Title #FORM.sSortDir_0# </cfcase>
      <cfcase value='2'> ORDER BY Program_control_panel_options.created_type #FORM.sSortDir_0# </cfcase>

      <cfcase value='3'> ORDER BY BB_Code #FORM.sSortDir_0# </cfcase>
      <cfcase value='4'> ORDER BY BB_Title #FORM.sSortDir_0# </cfcase>
      <cfcase value='5'> ORDER BY Billback.BB_Start_Date #FORM.sSortDir_0# </cfcase>

      <cfcase value='6'> ORDER BY Billback.BB_End_Date #FORM.sSortDir_0# </cfcase>
      <cfcase value='7'> ORDER BY Position_Customer #FORM.sSortDir_0# </cfcase>
      <cfcase value='8'> ORDER BY Actual_Dollar #FORM.sSortDir_0# </cfcase>
  </cfswitch>
</cfquery>

<cfquery name="qTotal" dbtype="query">
  SELECT SUM(Actual_Dollar) AS Actual_Dollar
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
<cfelse>
<!--- filter is specified need to query the db for the total count --->
	<cfquery datasource="#application.datasource#" name="qBeforeFilter">
   <cfif (form.Budget_Contribution_Factor_Type_ID neq const.variable_budget)
       and (form.Allocation_Position_Level eq const.customers)>
    SELECT COUNT(1) as rownbr
      FROM (
			SELECT Position_Customer = Bsa_FoodService_Customers.Name
				, Contract_Main.Contract_Number
				, Contract_Main.Contract_Title
				, Billback.BB_Start_Date
				, Billback.BB_End_Date
				, Template = Program_control_panel_options.created_type
				, Budget_Distributor_Billback.Actual_Dollar
				, Billback.BB_Code
				, Billback.BB_Title
			FROM Budget_Distributor_Billback
			LEFT JOIN Billback
			ON	Billback.Billback_ID = Budget_Distributor_Billback.Billback_ID
			INNER JOIN Contract_Main
			ON	Contract_Main.Contract_Main_ID = Budget_Distributor_Billback.Contract_Main_ID
			LEFT JOIN Program_control_panel_options
	             ON Program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
			LEFT JOIN Bsa_FoodService_Customers
			ON	Bsa_FoodService_Customers.Bsa_FoodService_Customers_ID = Budget_Distributor_Billback.Bsa_FoodService_Customers_ID
			WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
           ) foo
   <cfelse>
    SELECT COUNT(1) as rownbr
      FROM (
			SELECT Position_Customer = User_Positions.Position_Label
				, Contract_Main.Contract_Number
				, Contract_Main.Contract_Title
				, Billback.BB_Start_Date
				, Billback.BB_End_Date
	           	, Template = Program_control_panel_options.created_type
				, Budget_Position_Billback.Actual_Dollar
				, Billback.BB_Code
				, Billback.BB_Title

			FROM Budget_Position_Billback
			LEFT JOIN Billback
			ON	Billback.Billback_ID = Budget_Position_Billback.Billback_ID
			INNER JOIN Contract_Main
			ON	Contract_Main.Contract_Main_ID = Budget_Position_Billback.Contract_Main_ID
			LEFT JOIN Program_control_panel_options
	             ON Program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
			LEFT JOIN User_Positions
			ON	User_Positions.User_Positions_Id = Budget_Position_Billback.User_Position_Id
			WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
           ) foo
   </cfif>
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

       arrayAppend(variables.dArrayTmp, qFiltered.BB_Code);
       arrayAppend(variables.dArrayTmp, qFiltered.BB_Title);

       arrayAppend(variables.dArrayTmp, dateFormat(qFiltered.BB_Start_Date, 'medium'));
       arrayAppend(variables.dArrayTmp, dateFormat(qFiltered.BB_End_Date, 'medium'));
       arrayAppend(variables.dArrayTmp, qFiltered.Position_Customer);
       arrayAppend(variables.dArrayTmp, dollarFormat(qFiltered.Actual_Dollar));

       arrayAppend(variables.reply.aaData, variables.dArrayTmp);
    </cfscript>
  </cfloop>
</cfoutput>

<cfscript>
  variables.reply.sEcho  = javacast('int', FORM.sEcho);

  variables.reply.total = "Grand Total";
  variables.reply.actual_dollar = dollarFormat(Val(qTotal.Actual_Dollar));

  variables.sOut = serializeJSON( variables.reply );

  // Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way
  variables.sOut = replace (variables.sOut, 'SECHO', 'sEcho', 'one');
  variables.sOut = replace (variables.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one');
  variables.sOut = replace (variables.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one');

  variables.sOut = replace (variables.sOut, 'TOTAL', 'total', 'one');
  variables.sOut = replace (variables.sOut, 'ACTUAL_DOLLAR', 'actual_dollar', 'one');

  variables.sOut = replace (variables.sOut, 'AADATA', 'aaData', 'one');
</cfscript>
</cfsilent>
<!---send JSON data back to client--->
<cfoutput>#variables.sOut#</cfoutput>

