<!---------------------------------------------------------------------------------------------------------------------
      Template: C:\Work\base\AwayX\settings\Advanced_Budget\importActAdjustments.cfm
      Date:     Aug 22 2012
      Author:   Chris Nguyen
      Purpose:  Import actual adjustments from an Excel uploaded file ( stored in FORM.UploadedFileName )

      Related files:
      					Parent: \settings\Advanced_Budget\listActAdjustments.cfm
      					  * Child 1: \settings\Advanced_Budget\uploadActadjustment.cfm
      					     ** Grand child 1:  \settings\Advanced_Budget\ajax\uploadAdjustment.cfm
      					  * Child 2: this template
----------------------------------------------------------------------------------------------------------------------->

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
#mainfieldset { width:98%; padding:1%; border:1px solid blue; }
#actions { margin:10px 0; }
#actions a { margin:0 30px 0 0;}
.error { color:red !important; font-weight:bold; }
.mid { text-align: center; }
div.save { margin-top:10px; }
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
.added { background-color:white !important; }
#hideDiv { margin-bottom:5px; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<!--------------------------------------------------------------------------------------------------------------------->

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

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

<cffunction name="validateProgram" output="false">
	<cfargument name="cellSource" type="string" required="true" hind="Program_Number, adj_date">
  <!--- Remark: changes in this function need to carried over to \mvc\Models\AdvancedBudget\BudgetManager.cfc --->
	<cfoutput>
	<!--- wrap the query in try catch to prevent invalid program number (too many digits, contains alpha characters, etc..) --->
	<cftry>
		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT  cm.Contract_Main_Id
			       ,cm.Contract_Number
			       ,cm.Contract_Title
			       ,cm.Approved
			       ,cm.Manual_Cancel
						 ,cm.business_segment_id
			       ,CASE t.BillBack_Date
			          WHEN 1 THEN Cast( DateAdd( d, t.BillBack_Date_Span, cm.Contract_End_Date ) AS DATETIME )
			          ELSE NULL
			        END                             AS lastDateToClaim
				   ,cm.Contract_Start_Date
				   ,cm.Contract_End_Date
			       ,ls.Program_Lump_Sum_ID
			       ,lsname.Program_Lump_Sum_Name
			       ,ls.Lump_Sum_Amount
			       ,bs.Business_Unit_Desc
			  FROM CONTRACT_MAIN cm
			       INNER JOIN PROGRAM_CONTROL_PANEL_OPTIONS t ON cm.ProgramType_Id = t.ProgramControl_Panel_Options_Id
			       LEFT JOIN PROGRAM_LUMP_SUMS ls ON ls.Program_Id = cm.Contract_Main_Id
			          															AND ls.Deleted = 0
			       LEFT JOIN PROGRAM_LUMP_SUM_NAME lsname ON lsname.Program_Lump_Sum_Name_Id = ls.Program_Lump_Sum_Name_Id
			       LEFT JOIN BUSINESS_SEGMENT bs ON bs.business_segment_id = cm.business_segment_id
			 WHERE 1 = 1
			       AND cm.Deleted = 0
			       AND RIGHT( cm.Contract_Number, 7 ) = '#qExcelEntries.program_number#'
			       ORDER BY cm.Approved DESC, cm.Contract_Main_Id DESC
		</cfquery>
		<cfcatch type="any">
			<!--- oops! error just occurred --->
			<cfset local.query = queryNew( 'foo' )>
		</cfcatch>
	</cftry>
	</cfoutput>

	<!--- perform validations on entered program --->
	<cfscript>
		cell.validation.errors = [];
		cell.validation.Program_Lump_Sum_ID = [];
		cell.validation.lump_sum = [];
		cell.validation.program_not_exist = false;
		if (arguments.cellSource == 'Program_Number')
		{
			if ( local.query.recordCount eq 0 ) {
				cell.validation.program_not_exist = true;
				arrayAppend(cell.validation.errors, 'does not exist' );
			}
			else {
				if ( local.query.manual_cancel neq 0 ) {
					arrayAppend(cell.validation.errors, 'was cancelled' );
				}
				else if ( local.query.approved neq 1 ) {
					arrayAppend(cell.validation.errors, 'not approved' );
				}

				if ( local.query.Program_Lump_Sum_ID eq '' ) {
					arrayAppend(cell.validation.errors, 'no lump sum found' );
				}

				if ( isDate(local.query.lastDateToClaim) and isDate(qExcelEntries.adj_date) and local.query.lastDateToClaim lt qExcelEntries.adj_date ) {
					arrayAppend(cell.validation.errors, 'last claim date is ' & dateFormat(local.query.lastDateToClaim, 'short'));
				}

				if (structKeyExists(request.AccessStructure, "user_business_segments") and ListFind(request.AccessStructure.user_business_segments, local.query.business_segment_id) eq 0) {
					arrayAppend(cell.validation.errors, 'unauthorized ' & local.query.Business_Unit_Desc & ' ' & lcase(appSettings.getbusiness_segment_label()));
				}
			}
		}


	</cfscript>

	<!--- found no errors in validating program, save information from db into Excel query--->
	<cfif ( arrayLen(cell.validation.errors) eq 0 )>
		<cfscript>
			qExcelEntries.Contract_Main_Id = local.query.Contract_Main_Id;
		</cfscript>

		<cfif (arguments.cellSource EQ "adj_date")>
			<cfset qryMain = local.query />
			<cfquery name="qDateRange" datasource="#application.datasource#" dbType="query">
				SELECT MIN(Contract_Start_Date) AS Min_Contract_Start_Date,MAX(Contract_End_Date) As Max_Contract_Start_Date FROM qryMain
			</cfquery>

			<cfset qryDateRange = oBudgetClassManager.getAdjustmentDateRange(qDateRange.Min_Contract_Start_Date,qDateRange.Max_Contract_Start_Date,qExcelEntries.adj_date)  />

			<cfif (qryDateRange.RecordCount NEQ 0)>
				<cfset qExcelEntries.start_date = qryDateRange.Start_Date />
				<cfset qExcelEntries.end_date = qryDateRange.End_Date />
			<cfelse>
					<cfset arrayAppend(cell.validation.errors,"out of program date range/invalid") />
			</cfif>

		</cfif>
		<cfif (arguments.cellSource EQ "Program_Number")>
			<cfloop query="local.query">
				<cfif local.query.contract_main_id eq qExcelEntries.contract_main_id>
				  <cfscript>
						arrayAppend(cell.validation.Program_Lump_Sum_ID, local.query.Program_Lump_Sum_ID);
						// remove all double white spaces into single space
				    arrayAppend(cell.validation.lump_sum, replace(trim(local.query.Program_Lump_Sum_Name),'  ',' ','all'));
					</cfscript>
				</cfif>
			</cfloop>

			<!--- gather distributor information --->
			<cfquery name="local.query" datasource="#application.datasource#">
				SELECT TOP 1
							 C.BSA_Foodservice_Customers_ID
	            ,C.Shr_Ship_To
	            ,C.Name AS Distributor_Name
				  FROM CONTRACT_MAIN cm
								INNER JOIN Contract_Distributors CD ON CD.Contract_Main_ID = cm.Contract_Main_ID
																										AND CD.Deleted = 0
																										AND CD.Is_Group = 0
								INNER JOIN BSA_Foodservice_Customers C ON C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
				 WHERE cm.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qExcelEntries.Contract_Main_Id#">
			</cfquery>

			<cfscript>
				qExcelEntries.BSA_Foodservice_Customers_ID = local.query.BSA_Foodservice_Customers_ID;
			</cfscript>
		</cfif>
	</cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<!--- remember to make similar changes to \settings\Advanced_Budget\addActAdjustment.cfm as well --->
<cffunction name="saveRowsToDB" output="true" hint="I save Excel rows into the database.">
<!---<cfdump var="#qExcelEntries#" abort="true">--->
<cftransaction>
<cfloop query="qExcelEntries">
	<cfquery name="local.save" datasource="#application.datasource#">
		INSERT INTO Budget_Actual_Adjustment
		       ( Adjustment_date
		        ,Start_Date
		        ,End_Date
		        ,Adjustment_dollar
		        ,Adjustment_Notes
		        ,Contract_Main_Id
		        ,Program_Lump_Sum_ID
		        ,Uploaded_File_Name
		        ,Created_By
		        <cfif len(qExcelEntries.BSA_Foodservice_Customers_ID)>
		        	,BSA_Foodservice_Customers_ID
		        </cfif>
		        )
	 VALUES (  <cfqueryparam cfsqltype="cf_sql_date"    value="#qExcelEntries.adj_date#">
	 	        ,<cfqueryparam cfsqltype="cf_sql_date"    value="#qExcelEntries.start_date#">
	 	        ,<cfqueryparam cfsqltype="cf_sql_date"    value="#qExcelEntries.end_date#">
	          ,<cfqueryparam cfsqltype="cf_sql_decimal" value="#qExcelEntries.adj_amount#" scale="2">
	          ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qExcelEntries.adj_notes#">
	          ,<cfqueryparam cfsqltype="cf_sql_integer"     value="#qExcelEntries.contract_main_id#">
	          ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qExcelEntries.lump_sum_id#">
	          ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.UploadedFileName#">
	          ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
		        <cfif len(qExcelEntries.BSA_Foodservice_Customers_ID)>
	          	,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qExcelEntries.BSA_Foodservice_Customers_ID#">
		        </cfif>
		       )
	</cfquery>
</cfloop>
<!--- gather unique program numbers in a query --->
<cfquery name="local.uniquePrograms" dbtype="query">
	SELECT DISTINCT contract_main_id FROM qExcelEntries
</cfquery>
<!--- apply actual adjustments to programs --->
<cfoutput query="local.uniquePrograms">
	<cfstoredproc procedure="ADV_BUDGET_ACTUAL_ADJUSTMENT" datasource="#application.datasource#">
		<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@contract_main_id" value="#local.uniquePrograms.contract_main_id#" null="no">
	</cfstoredproc>
</cfoutput>
</cftransaction>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<fieldset id="mainfieldset">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Import Actual Adjustments</legend>

<div id="actions">
 <span style="margin-right:20px;">#application.util.string.actionLinkFormat("Excel Uploaded File Name: " & FORM.UploadedFileName)#</span>
 <a href="##" id="cancel">#application.util.string.actionLinkFormat("return to adjustments list")#</a>
</div>


<!--- load excel content into a query --->
<cfset fileFailed = false>
<cftry>
	<!--- column names & column order are important:  do not change them --->
	<cfset excelColumnList = "adj_date,program_number,lump_sum,adj_amount,adj_notes">
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
	<!--- fail the whole file when number of columns does not equal to 7 or file has no data --->
	<cfif fileFailed or listLen(qExcelEntries.columnList) lt 5 or qExcelEntries.recordCount eq 0>
		<cfset fileFailed = true>
		<img src="/images/Exclamation_Triangle.gif" alt="" class="exclamation">
		<cfif listLen(qExcelEntries.columnList) lt 5>
			Sorry, there are missing columns in the Excel file.<br/>
			Please include adjustment date, program number, lump sum component name, adjustment amount & adjustment notes in the file.
		<cfelse>
			Sorry, something wasn't right in the selected Excel file. Please check the file and try again.
		</cfif>
	<cfelse>
	  <!--- create additional columns to hold additional program info --->
		<cfset queryAddColumn(qExcelEntries, 'lump_sum_id', 'varchar', arrayNew(1))>
		<cfset queryAddColumn(qExcelEntries, 'Contract_Main_Id', 'varchar', arrayNew(1))>
		<cfset queryAddColumn(qExcelEntries, 'BSA_Foodservice_Customers_ID', 'varchar', arrayNew(1))>
		<cfset queryAddColumn(qExcelEntries, 'start_date', 'varchar', arrayNew(1))>
		<cfset queryAddColumn(qExcelEntries, 'end_date', 'varchar', arrayNew(1))>
	</cfif>
</div>

<cfif not fileFailed>
	<!--- provide ability to hide valid rows --->
	<div id="hideDiv">
		<input type="checkbox" name="hideValidRows" id="hideValidRows"> <b>Hide Valid Rows</b>
	</div>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->
<!--- <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [0.5, 1.5, 1.5, 1.5, 1.5, 2, 1.5, 2, 0.5] )> --->
<table class="datagrid" id="importAdjustments"  style='table-layout:fixed;'>
<col width="7%"> <col width="15%"> <col width="15%">
<col width="21%"> <col width="15%"> <col width="20%">
<col width="7%">
<thead>
<tr>
 <th style="background-color:white;">Row</th>
 <cfset listCnt = 0>
 <cfloop list="#excelColumnList#" index="thisColumn">
	<cfset listCnt++>
	<cfif listCnt gt listLen(qExcelEntries.columnList)>
		<cfbreak>
	</cfif>

 	<th>#application.util.string.CapFirstTitle( replace(thisColumn,'_',' ','all') )#
 			<br/>
 			#chr(listCnt + 64)#   <!---display Excel column headings: A, B, C, ... --->
 	</th>
 </cfloop>
 <th class="added">Status</th>
</tr>
</thead>

<!--------------------------------------------------------------------------------------------------------------------->

<tbody>
<cfset rowsWithErrors = 0>
<cfset rowsWithOutErrors = 0>
<cfsetting enablecfoutputonly="true">
<cfloop query="qExcelEntries">
	<cfoutput><tr></cfoutput>
	<td class="row">#qExcelEntries.currentRow#</td>

	<cfset listCnt = 0>
	<cfset cell.invalidCount = 0>

	<cfscript>
		cell.validation = {};

		cell.validation.Contract_Main_Id = 0;
		cell.validation.Program_Lump_Sum_ID = [];
		cell.validation.lump_sum = [];
		//cell.validation.start_date = '';
		//cell.validation.end_date = '';
	</cfscript>

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

			<cfcase value="adj_date">  <!---validate adj date--->
				<cfif trim(cell.value) eq ''>
					<cfset arrayAppend(cell.validation.errors, "missing")>
				<cfelseif not isDate(cell.value)>
					<cfset arrayAppend(cell.validation.errors, "invalid date")>
				<cfelse>
					<cfset validateProgram("adj_date")>
					<cfset cell.value = dateFormat(cell.value, 'm/d/yyyy')>
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

			<cfcase value="program_number">  <!---validate program number--->
				<cfif trim(cell.value) eq ''>
					<cfset arrayAppend(cell.validation.errors, "missing")>
				<cfelseif not isNumeric(cell.value)>
					<cfset arrayAppend(cell.validation.errors, "invalid number")>
				<cfelse>
					<cfset validateProgram("Program_Number")>
				</cfif>
			</cfcase>

			<cfcase value="lump_sum">  <!---validate lump sum--->
				<cfif trim(cell.value) eq ''>
					<cfset arrayAppend(cell.validation.errors, "missing")>
				<!--- lump sum array is empty due to invalid program number, program does not have lump sum --->
				<cfelseif arrayLen(cell.validation.lump_sum) eq 0>
					<cfif isdefined("cell.validation.program_not_exist") and cell.validation.program_not_exist>
						<cfset arrayAppend(cell.validation.errors, "prg does not exist, invalid component")>
					<cfelse>
						<cfset arrayAppend(cell.validation.errors, "invalid")>
					</cfif>
				<cfelse>
					<!--- remove all double white spaces into single space --->
					<cfset cell.value = replace(trim(cell.value), '  ', ' ', 'all')>
					<cfset ls_index = ArrayFindNoCase(cell.validation.lump_sum, cell.value)>
					<cfif ls_index gt 0>
						<cfset qExcelEntries.lump_sum_id = cell.validation.Program_Lump_Sum_ID[ ls_index ]>
					<cfelse>
						<!--- list out valid lump sum component names --->
						<cfset arrayAppend(cell.validation.errors, "should be " & arrayToList(cell.validation.lump_sum, ", "))>
					</cfif>
				</cfif>
			</cfcase>
		</cfswitch>

		<cfif arrayLen(cell.validation.errors)>
			<cfset cell.class = "error">
		<cfelse>
			<cfset cell.class = "">
		</cfif>

		<cfoutput><td class="#thisColumn# #cell.class#">#cell.value# <cfif arrayLen(cell.validation.errors)>(#arrayToList(cell.validation.errors, ", ")#)</cfif></td></cfoutput>

		<cfif arrayLen(cell.validation.errors)>
			<cfset cell.invalidCount++>
		</cfif>
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

<!---<cfdump var="#qExcelEntries#" label="qExcelEntries" format="html" showudfs="false" metainfo="true" > --->

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">

<cfif qExcelEntries.recordCount gt 0>
	<cfif rowsWithErrors eq 0>
		<!---<script type="text/javascript">
 		  // preload image for quicker display
			var image = $('<img />').attr('src', '/Images/ajax-loader.gif');
  		$('#result').html( 'Saving actual adjustments, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">' );
		</script>--->
		<cfset saveRowsToDB()>
		<script type="text/javascript">
			$('#result').text( 'All actual adjustments from Excel file have been loaded and saved successfully.' );
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
	                ,{"bSortable":false, "bSearchable":false} ]
  ,"sScrollY": ( windowHeight > 800 ? .65 : .45) * windowHeight         <!--- data grid height --->
});
<!---event for cancel-------------------------------------------------------------------------------------------------->
$('#cancel').click(function(){
  document.forms[budget_form].command.value = "listActAdjustment";
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
$('table#importAdjustments tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
</script>