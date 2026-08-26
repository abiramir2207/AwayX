<!---------------------------------------------------------------------------------------------------------------------
      Template: C:\Work\base\AwayX\settings\Advanced_Budget\importAdjustments.cfm
      Date:     Aug 22 2012
      Author:   Chris Nguyen
      Purpose:  Import adjustments from an Excel uploaded file ( stored in FORM.UploadedFileName )

      Related files:
      					Parent: \settings\Advanced_Budget\listAdjustments.cfm
      					  * Child 1: \settings\Advanced_Budget\uploadadjustment.cfm
      					     ** Grand child 1:  \settings\Advanced_Budget\ajax\uploadAdjustment.cfm
      					  * Child 2: this template
----------------------------------------------------------------------------------------------------------------------->

<cfset busSegMgr.obj = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset busSegMgr.isEnabled = busSegMgr.obj.isEnabledForBudget()/>

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
#mainfieldset { width:98%; padding:1%; border:1px solid blue; }
#actions { margin-bottom:10px; }
#actions a { margin:0 30px 0 0;}
.error { color:red !important; font-weight:bold; }
.even { width:<cfif busSegMgr.isEnabled>33%<cfelse>50%</cfif>; }
.mid { text-align: center; }
div.save { margin-top:10px; }
table.datagrid {
/*	table-layout:fixed;*/
}
.row { width:5%; font-weight:bold; text-align:center; background-color:white; }
.adj_amount { width:15%; text-align:right; }
.adj_notes { width:20%; }
.adj_type { width:10%; }
.distributor { width:20%; }
.position { width:20%; }
.status { width:10%; text-align:center;  background-color:white; }
#result { text-align:center; font-size:1.15em; font-weight:bold; color:green; margin:0 0 7px; padding:0; }
.exclamation { position:relative; top:2px; height=20; width=20; margin-right:5px; }
th { text-align:center; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<!--------------------------------------------------------------------------------------------------------------------->

<cfset vars.oBudgetAdjustmentManager = createObject('component','mvc.Models.AdvancedBudget.BudgetAdjustmentManager') />
<cfset qAdjustmentTypes = vars.oBudgetAdjustmentManager.getBudgetAdjustmentTypes() />

<cfquery name="qBudget" datasource="#application.datasource#">
    SELECT Budget_desc
           , Budget_Code
           , Overlays
           , Overlay_Recapture
           , Recapture
           , Budget.Business_Segment_Id
           , bs.Business_Unit_Desc
           , Position_Control_Type
           , Allocation_Position_Level
           , Budget_Owner_Position_ID
		   , bc.Budget_Class_ID
		   , bc.Is_Fiscal
		   , bc.year_selection
      FROM Budget
     INNER JOIN Budget_Class bc ON Budget.Budget_Class_ID = bc.Budget_Class_ID
      LEFT JOIN Business_Segment bs ON Budget.Business_Segment_Id = bs.Business_Segment_Id
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif (qBudget.Is_Fiscal EQ 1)>
	<cfset qryDateRange = oBudgetClassManager.getFiscalDates( qBudget.year_selection ) />
<cfelse>
	<cfset qryDateRange = oBudgetClassManager.getCalendarDates ( qBudget.year_selection ) />
</cfif>

<cfif qBudget.Allocation_Position_Level eq "4">
	<cfinvoke component="mvc.Models.AdvancedBudget.BudgetAdjustmentManager"
	    		     method="getDistributors"
	     returnVariable="qDistributors">
		<cfinvokeargument name="budget_ID" value="#form.budget_ID#">
	</cfinvoke>
<cfelse>
	<!---gather positions in the budget--->
	<cfinvoke component="mvc.Models.AdvancedBudget.BudgetAdjustmentManager"
	    		     method="getPositions"
	     returnVariable="qPositions">
		<cfinvokeargument name="budget_ID" value="#form.budget_ID#">
	</cfinvoke>
</cfif>

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

<!--- remember to make similar changes to \settings\Advanced_Budget\addadjustment.cfm as well --->
<cffunction name="saveRowsToDB" output="true" hint="I save Excel rows into the database.">
<cftransaction>
<cfloop query="qExcelEntries">
	<cfif qBudget.Allocation_Position_Level eq "4">
		<cfset useLakebaseForqValid = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qdistributors")>
<cfif useLakebaseForqValid>
	<cftry>
		<cfset qValid = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qdistributors", {
				"shr_ship_to" = "eq.#qExcelEntries.distributor#",
				"select" = "bsa_foodservice_customers_id"
			}), "bsa_foodservice_customers_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqValid = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqValid>
<cfquery name="qValid" dbtype="query">
			SELECT BSA_Foodservice_Customers_ID
			  FROM qDistributors
			 WHERE Shr_Ship_To = '#qExcelEntries.distributor#'
		</cfquery>
</cfif>
		<cfset vars.element_id = qValid.BSA_Foodservice_Customers_ID>
	<cfelse>
		<cfquery name="qValid" dbtype="query">
			SELECT User_Positions_ID
			  FROM qPositions
			 WHERE Position_Number = '#qExcelEntries.position#'
		</cfquery>
		<cfset vars.element_id = qValid.User_Positions_ID>
	</cfif>

	<cfquery name="vars.update_db" datasource="#application.datasource#">
		INSERT Budget_Adjustment
		       ( Budget_Id
		        ,Budget_Adjustment_Type_ID
		        ,Adjustment_Dollar
		        ,Start_Date
		        ,End_Date
		        ,Adjustment_Notes
		        ,<cfif qBudget.Allocation_Position_Level eq "4">  <!---distributor level---> BSA_Foodservice_Customers_ID <cfelse> User_Positions_ID </cfif>
		        ,Created_By
		        ,Uploaded_File_Name )
		VALUES ( <cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">
		        ,<cfqueryparam value="#qExcelEntries.adj_type#" cfsqltype="cf_sql_integer">
		        ,<cfqueryparam value="#qExcelEntries.adj_amount#" cfsqltype="cf_sql_decimal" scale="2">
	 	        ,<cfqueryparam cfsqltype="cf_sql_date"    value="#qExcelEntries.start_date#">
	 	        ,<cfqueryparam cfsqltype="cf_sql_date"    value="#qExcelEntries.end_date#">
		        ,<cfqueryparam value="#qExcelEntries.adj_notes#" cfsqltype="cf_sql_varchar">
		        ,<cfqueryparam value="#vars.element_id#" cfsqltype="cf_sql_varchar">
		        ,<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
		        ,<cfqueryparam value="#form.UploadedFileName#" cfsqltype="cf_sql_varchar">
		        )

	  <!---calculate total of adjustments--->
	  DECLARE @Adjustment_Total DECIMAL
	  SELECT @Adjustment_Total = ISNULL(SUM(Adjustment_Dollar), 0)
      FROM Budget_Adjustment
     WHERE Budget_ID = <cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">
					 AND Deleted = 0
					 AND <cfif qBudget.Allocation_Position_Level eq "4">   <!---distributor level---> BSA_Foodservice_Customers_ID <cfelse> User_Positions_ID </cfif>
					 		 = <cfqueryparam value="#vars.element_id#" cfsqltype="cf_sql_varchar">

		<!---apply adjustments to budget allocation--->
		<cfif qBudget.Allocation_Position_Level eq "4">   <!---distributor level--->
			UPDATE Budget_Distributor_Allocation
			   SET Adjustment_Dollar = @Adjustment_Total
			       ,Budget_Dollar = ISNULL(Original_Budget_Dollar,0) + @Adjustment_Total
			 WHERE Budget_ID = <cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">
			       AND BSA_Foodservice_Customers_ID = <cfqueryparam value="#vars.element_id#" cfsqltype="cf_sql_varchar">

		<cfelse>       <!---position level--->
			UPDATE Budget_Position_Allocation
			   SET Adjustment_Dollar = @Adjustment_Total
			       ,Budget_Dollar = ISNULL(Original_Budget_Dollar, 0) + @Adjustment_Total
			 WHERE Budget_ID = <cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">
             AND User_Position_ID = <cfqueryparam value="#vars.element_id#" cfsqltype="cf_sql_varchar">
		</cfif>
	</cfquery>
</cfloop>
<cfquery name="vars.saveRow" datasource="#application.datasource#">
  <cfinclude template="last_update.cfm">       <!--- 36874 --->
</cfquery>
</cftransaction>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<fieldset id="mainfieldset">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Import Adjustments</legend>

<!---display heading--->
<div style="margin-top:5px" >
<table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr>
    <td class="even"><font size=2>Code: <b>#qBudget.budget_code#</b></font></td>
    <cfif busSegMgr.isEnabled>
      <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
    	<td class="even mid"><font size=2>#appSettings.getbusiness_segment_label()#: <b>#qBudget.Business_Unit_Desc#</b></font></td>
    </cfif>
    <td align=right class="even"><font size=2>Description: <b>#qBudget.budget_desc#</b></font></td>
  </tr>
</table>
<hr width=100%/>
</div>

<div id="actions">
 <span style="margin-right:20px;">#application.util.string.actionLinkFormat("Excel Uploaded File Name: " & FORM.UploadedFileName)#</span>
 <a href="##" id="cancel">#application.util.string.actionLinkFormat("return to adjustments list")#</a>
</div>


<!--- load excel content into a query --->
<cfset fileFailed = false>
<cftry>
	<cfset excelColumnList = "adj_amount,adj_type,adj_date,adj_notes,distributor,position">
	<cfspreadsheet action="read"
	      src = "#expandPath('/common_documents/data_files/uploaded/budgets')#/#form.uploadedFileName#"
	      query = "qExcelEntries"
	      headerrow = "0"
	      excludeHeaderRow = "false"
	      columnnames = "#excelColumnList#">
<cfcatch type="any">
	<cfset fileFailed = true>
	<cfset qExcelEntries = queryNew( excelColumnList )>
</cfcatch>
</cftry>

<div id="result">
	<cfif fileFailed or listLen(qExcelEntries.columnList) lt 6 or qExcelEntries.recordCount eq 0>
		<cfset fileFailed = true>
		<img src="/images/Exclamation_Triangle.gif" alt="" class="exclamation">
		<cfif listLen(qExcelEntries.columnList) lt 6>
			Sorry, there are missing columns in the Excel file.<br/>
			Please include adjustment amount, adjustment type, adjustment date, adjustment notes, distributor & position in the file.
		<cfelse>
			Sorry, something wasn't right in the selected Excel file. Please check the file and try again.
		</cfif>
	<cfelse>
		<cfset queryAddColumn(qExcelEntries, 'start_date', 'varchar', arrayNew(1))>
		<cfset queryAddColumn(qExcelEntries, 'end_date', 'varchar', arrayNew(1))>
	</cfif>
</div>

<cfif not fileFailed>
	<div id="hideDiv">
		<input type="checkbox" name="hideValidRows" id="hideValidRows"> <b>Hide Valid Rows</b>
	</div>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<!--- <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [0.5, 1.5, 1.5, 1.5, 2, 2, 2, 0.5] )> --->
<table class="datagrid" id="importAdjustments" style='table-layout:fixed;'>
<col width="4%"> <col width="12%"> <col width="13%">
<col width="12%"> <col width="20%">
<col width="16%"> <col width="16%"> <col width="7%">
<thead>
<tr>
 <th style="background-color:white;">Row</th>
 <!---<cfloop list="#qExcelEntries.columnList#" index="thisColumn">--->
 <cfset listCnt = 0>
 <cfloop list="#excelColumnList#" index="thisColumn">
	<cfset listCnt++>
	<cfif listCnt gt listLen(qExcelEntries.columnList)>
		<cfbreak>
	</cfif>

 	<th>#application.util.string.CapFirstTitle( replace(thisColumn,'_',' ','all') )#
 			<br/>
 			#chr(listCnt + 64)#
 	</th>
 </cfloop>
 <th style="background-color:white;">Status</th>
</tr>
</thead>

<!--------------------------------------------------------------------------------------------------------------------->

<tbody>
<cfset rowsWithErrors = 0>
<cfset rowsWithOutErrors = 0>
<cfsetting enablecfoutputonly="true">
<cfloop query="qExcelEntries">
	<cfscript>
		cell.validation = {};
		cell.validation.adj_date = '';
		//cell.validation.start_date = '';
		// cell.validation.end_date = '';
	</cfscript>

	<cfoutput><tr></cfoutput>
	<td class="row">#qExcelEntries.currentRow#</td>

	<cfset listCnt = 0>
	<cfset cell.invalidCount = 0>

	<cfloop list="#excelColumnList#" index="thisColumn">

		<cfset listCnt++>
		<!--- stop after last column in Excel file--->
		<cfif listCnt gt listLen(qExcelEntries.columnList)>
			<cfbreak>
		</cfif>

		<cfscript>
			cell.value = qExcelEntries[thisColumn][qExcelEntries.currentRow];
			// reset previous cell errors
			cell.validation.errors = [];
		</cfscript>

		<cfset cell.invalid = false>
		<cfset cell.missing = false>
		<cfset cell.errormsg = ''>

		<cfswitch expression="#thisColumn#">
			<cfcase value="adj_amount">  <!---validate adj amount--->
				<cfif trim(cell.value) eq ''>
					<cfset arrayAppend(cell.validation.errors, "missing")>
				<cfelseif not IsDollar(cell.value)>
					<cfset arrayAppend(cell.validation.errors, "invalid amount")>
				<cfelse>
					<!--- remove $ and commas --->
					<cfset qExcelEntries.adj_amount = replace(qExcelEntries.adj_amount, '$', '', 'all')>
					<cfset qExcelEntries.adj_amount = replace(qExcelEntries.adj_amount, ',', '', 'all')>
					<cfset cell.value = numberFormat(qExcelEntries.adj_amount, "($,.99")>
				</cfif>
			</cfcase>

			<cfcase value="adj_type">  <!---validate adj type--->
				<cfif trim(cell.value) eq ''>
					<cfset arrayAppend(cell.validation.errors, "missing")>
				<cfelseif not isNumeric(cell.value)>
					<cfset arrayAppend(cell.validation.errors, "invalid ID")>
				<cfelse>
					<cfquery name="qValid" dbtype="query">
						SELECT Active
						  FROM qAdjustmentTypes
						 WHERE qAdjustmentTypes.Budget_Adjustment_Type_Id = #cell.value#
					</cfquery>
					<cfif (qValid.recordCount eq 0)>
					  <cfset arrayAppend(cell.validation.errors, "invalid type")>
					<cfelseif qValid.active neq 1>
					  <cfset arrayAppend(cell.validation.errors, "not active")>
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="adj_date">
				<cfif trim(cell.value) eq ''>
					<cfset arrayAppend(cell.validation.errors, "missing")>
				<cfelseif not isDate(cell.value)>
					<cfset arrayAppend(cell.validation.errors, "invalid date")>
				<cfelse>
					<cfset adjDate = DateFormat(cell.value,"mm/dd/yyyy") />
					<cfquery name="qValidDate" dbtype="query">
 						SELECT Start_Date, End_Date  FROM qryDateRange WHERE '#adjDate#' BETWEEN Start_Date AND  End_Date ORDER BY Start_Date
					</cfquery>
 					<cfif (qValidDate.RecordCount EQ 0)>
						<cfset arrayAppend(cell.validation.errors, "out of valid range")>
					<cfelse>
						<cfset qExcelEntries.start_date = qValidDate.Start_Date />
						<cfset qExcelEntries.end_date = qValidDate.End_Date />
						<cfset cell.validation.adj_date = cell.value>
						<cfset cell.value = dateFormat(cell.value, 'm/d/yyyy')>
					</cfif>
				</cfif>
			</cfcase>

<!---validate start date--->
			<!--- <cfcase value="start_date">
				<cfif trim(cell.value) eq ''>
					<cfset arrayAppend(cell.validation.errors, "missing")>
				<cfelseif not isDate(cell.value)>
					<cfset arrayAppend(cell.validation.errors, "invalid date")>
				<cfelseif dateDiff('d', now(), cell.value) gt 0>
					<cfset arrayAppend(cell.validation.errors, "future date not allowed")>
				<cfelse>
					<cfset cell.validation.start_date = cell.value>
					<cfset cell.value = dateFormat(cell.value, 'm/d/yyyy')>
				</cfif>
			</cfcase> --->
 <!---validate end date--->
			<!--- <cfcase value="end_date">
				<cfif trim(cell.value) eq ''>
					<cfset arrayAppend(cell.validation.errors, "missing")>
				<cfelseif not isDate(cell.value)>
					<cfset arrayAppend(cell.validation.errors, "invalid date")>
				<cfelseif dateDiff('d', now(), cell.value) gt 0>
					<cfset arrayAppend(cell.validation.errors, "future date not allowed")>
				<cfelseif isDate(cell.validation.start_date) and dateDiff('d', cell.value, cell.validation.start_date) gt 0>
					<cfset arrayAppend(cell.validation.errors, "must be later than start date")>
				<cfelse>
					<cfset cell.value = dateFormat(cell.value, 'm/d/yyyy')>
				</cfif>
			</cfcase> --->

			<cfcase value="adj_notes">  <!---validate adj notes--->
				<cfif len(cell.value) gt 200>
					<cfset cell.value = application.util.string.fullLeft(cell.value, 180)>
					<cfset arrayAppend(cell.validation.errors, "exceeded 200 chars")>
				</cfif>
			</cfcase>

			<cfcase value="distributor">  <!---validate distributor--->
				<cfif qBudget.Allocation_Position_Level eq "4">
					<cfif trim(cell.value) eq ''>
						<cfset arrayAppend(cell.validation.errors, "missing")>
					<cfelseif not isNumeric(cell.value)>
						<cfset arrayAppend(cell.validation.errors, "invalid number")>
					<cfelse>
						<cfquery name="qValid" dbtype="query">
							SELECT 1
							  FROM qDistributors
							 WHERE Shr_Ship_To = '#cell.value#'
						</cfquery>
						<cfif (qValid.recordCount eq 0)>
							<cfset arrayAppend(cell.validation.errors, "inappropriate distributor")>
						</cfif>
					</cfif>
				</cfif>
			</cfcase>

			<cfcase value="position">  <!---validate user position--->
				<cfif qBudget.Allocation_Position_Level neq "4">
					<cfif trim(cell.value) eq ''>
						<cfset arrayAppend(cell.validation.errors, "missing")>
						<!--- 83236 :: Budget Accrual Adjustment Upload not working at HQ Level
					<cfelseif not isNumeric(cell.value)>
						<cfset arrayAppend(cell.validation.errors, "invalid number")>---->
					<cfelse>
						<cfquery name="qValid" dbtype="query">
							SELECT 1
							  FROM qPositions
							 WHERE Position_Number = '#cell.value#'
						</cfquery>
						<cfif (qValid.recordCount eq 0)>
							<cfset arrayAppend(cell.validation.errors, "inappropriate position")>
						</cfif>
					</cfif>
				</cfif>
			</cfcase>
		</cfswitch>

		<cfif arrayLen(cell.validation.errors)>
			<cfset cell.invalidCount++>
			<cfset cell.class = "error">
		<cfelse>
			<cfset cell.class = "">
		</cfif>

		<cfoutput><td class="#thisColumn# #cell.class#">#cell.value# <cfif arrayLen(cell.validation.errors)>(#arrayToList(cell.validation.errors, ", ")#)</cfif></td></cfoutput>
	</cfloop>

	<cfif cell.invalidCount or fileFailed>
		<cfset rowsWithErrors++>
		<cfoutput><td class="status error">Invalid</td></cfoutput>
 	<cfelse>
		<cfset rowsWithOutErrors++>
		<cfoutput><td class="status valid">Valid</td></cfoutput>
	</cfif>

	<cfoutput></tr></cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false">
</tbody>
</table>
</fieldset>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">

<cfif qExcelEntries.recordCount gt 0>
	<cfif rowsWithErrors eq 0>
		<cfset saveRowsToDB()>
		<script type="text/javascript">
			$('#result').text( 'All adjustments from Excel file have been loaded and saved successfully.' );
			$('#hideDiv').hide();
		</script>
	<cfelseif not fileFailed>
		<script type="text/javascript">
			<cfif rowsWithOutErrors eq 0>
				$('#hideDiv').hide();
			</cfif>
			$('#result').html( '<img src="/images/Exclamation_Triangle.gif" alt="" class="exclamation">Problems occurred with the cells marked in red. Please correct the mistakes and try again.' );
		</script>
	</cfif>
</cfif>

<script type="text/javascript">
var windowHeight = $(window).height();
var grid = $('#importAdjustments').dataTable({
	 "bPaginate": false
	,"bAutoWidth": false
  	,"bSortClasses": false
  	,"bScrollCollapse": true
  	,"sDom": 'ti'
  	,"aaSorting": []
	,"aoColumns": [  {"bSortable":false, "bSearchable":false}
	                ,{"bSortable":false, "bSearchable":false}
	                ,{"bSortable":false, "bSearchable":false}
	                ,{"bSortable":false, "bSearchable":false}
	                ,{"bSortable":false, "bSearchable":false}
	                ,{"bSortable":false, "bSearchable":false}
	                ,{"bSortable":false, "bSearchable":false}
	                ,{"bSortable":false, "bSearchable":false} ]
  ,"sScrollY": ( windowHeight > 800 ? .61 : .45) * windowHeight         <!--- data grid height --->
});
<!---event for cancel-------------------------------------------------------------------------------------------------->
$('#cancel').click(function(){
  document.forms[budget_form].command.value = "listAdjustments";
  document.forms[budget_form].submit();
  return false;
});
<!---event for hide valid rows----------------------------------------------------------------------------------------->
$('#hideValidRows').change(function(){
	if ($(this).is(':checked')) {
  	$('td.valid').closest('tr').hide();
  }
  else {
  	$('td.valid').closest('tr').show();
  }
});
$('table.datagrid tr').hover (
  function() { $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);
</script>