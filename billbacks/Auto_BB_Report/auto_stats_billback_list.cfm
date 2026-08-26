<!---------------------------------------------------------------------------------------------------------------------
      Template: \billbacks\Auto_BB_Report\auto_stats_billback_list.cfm
      Date:     2017 March
      Author:   Milan Mushran
      Purpose:  auto billbacks list
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Billback list</TITLE>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
		h2 {
			background-color: #FFCE84;
			height: 26px;
			line-height: 26px;
			border-top:1px solid black;
			border-bottom:1px solid black;
			padding-left: 7px;
			font-size: 1.3em;
		}
		table.datagrid { table-layout: fixed; width: 100%; }
		thead th { text-align:left !important; }		
		.right{text-align:right !important;}
		.center{text-align:center !important;}
	</style>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</HEAD>

<cfparam name="URL.BBAutoProgramPayPeriodID" default="">

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset application.oBBReportGet = CreateObject("component","components.Billback.BBAutoReportGet").init() />
<cfset getBBDetail = application.oBBReportGet.getBBDetail(PayPeriodId= URL.BBAutoProgramPayPeriodID)>

<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">

<cfset variables.aaData = []>

<cfloop query="getBBDetail">

	<cfset qBBInfo = application.oBBReportGet.getBBDetail(BB_Auto_Program_Pay_Period_ID) />
	<cfset BBId = application.oBBReportGet.getBBIds(BB_Auto_Program_Pay_Period_ID).Billback_Id />

	<!--- Handle for re-calc records.--->
	<cfif BBId EQ "">
		<cfset BBId = "0" />
	</cfif>

	<cfset variables.aTemp = []>

	<!--- data column 1 --->
	<cfset arrayAppend(variables.aTemp,'#BB_Code#<a  title="View the line item details for this billback" href="/billbacks/auto_bb_report/index.cfm?Report=#getBBDetail.BB_Auto_Report_id#&disp=ExpView&PP_ID=#BB_Auto_Program_Pay_Period_ID#&BB_ID=#getBBDetail.Billback_ID#"><img src="/images/view.gif" align="middle" border="0" /></a>')>

	<cfset payee ="">
	<CFIF application.oBBReportGet.getBBIds(getBBDetail.BB_Auto_Program_Pay_Period_ID).recordcount GT 1>
		<cfloop query ="qBBInfo">
			<cfset payee = payee & left(Name, 15) & "(" & Ship_To & ")  <br />">
		</cfloop>
	<CFELSE>
		<cfset payee = left(Name, 15) & "(" & Ship_To & ")  <br />">
	</CFIF>

	<!--- data column 2 --->
	<cfset arrayAppend(variables.aTemp, payee)>
	
	<!--- data column 3 --->
	<cfset arrayAppend(variables.aTemp, Contract_Number)>

	<cfif application.oBBReportGet.getAutoPayType() NEQ 2>
		<!--- data column 4 --->
		<cfset arrayAppend(variables.aTemp, Payment_Cycle)>
	</cfif>
	
	<!--- data column 5 --->
	<cfset arrayAppend(variables.aTemp, Payment_Start_Date)>
	
	<!--- data column 6 --->
	<cfset arrayAppend(variables.aTemp, Payment_End_Date)>

	<cfif BBId NEQ 0>
		<cfset GrossAmt = BB_Amount>
	<cfelse><!--- Recalc Record --->
		<cfset GrossAmt = application.oBBReportGet.getDiscountName(discountTypeId = Discount_Type_Id)>
	</cfif>
	
	<!--- data column 7 --->
	<cfset arrayAppend(variables.aTemp, dollarFormat(GrossAmt))>

	<cfif appSettings.getPullbacksOn()>
		<!--- data column 8 --->
		<cfset arrayAppend(variables.aTemp, dollarFormat(Pullback_Applied_Amount))>
	</cfif>
	
	<!--- data column 9 --->
	<cfset arrayAppend(variables.aTemp, dollarFormat(Net_Amount))>
	
	<!--- entire row data --->
	<cfset arrayAppend(variables.aaData, variables.aTemp)>

</cfloop>

<BODY>
<cfoutput>

<br />

<cfset Billback_columnWidth = 11>
<cfset Payee_columnWidth = 20>
<cfset Program_columnWidth = 9>
<cfset StartDate_columnWidth = 8>
<cfset EndDate_columnWidth = 8>
<cfset GrossAmount_columnWidth = 12>
<cfset NetAmount_columnWidth = 12>

<cfif application.oBBReportGet.getAutoPayType() NEQ 2>
	<cfset PayCycle_columnWidth = 8>
</cfif>

<cfif appSettings.getPullbacksOn()>
	<cfset Pullback_columnWidth = 12>
</cfif>


<table id="datagrid" class="datagrid" style="table-layout:fixed;">
	<col width="#Billback_columnWidth#%">  <col width="#Payee_columnWidth#%">  <col width="#Program_columnWidth#%"> 
	<cfif application.oBBReportGet.getAutoPayType() NEQ 2>
		<col width="#PayCycle_columnWidth#%"> 
	</cfif>
		<col width="#StartDate_columnWidth#%"> <col width="#EndDate_columnWidth#%"> <col width="#GrossAmount_columnWidth#%"> 
	<cfif appSettings.getPullbacksOn()>
		<col width="#Pullback_columnWidth#%">
	</cfif>
	<col width="#NetAmount_columnWidth#%">
  <thead>
	<tr>
		<th>Billback</th>
		<th>Payee</th>
		<th>Program</th>
	<cfif application.oBBReportGet.getAutoPayType() NEQ 2>
		<th>Pay Cycle</th>
	</cfif>
		<th>Start</th>
		<th>End</th>
		<th>Gross Amount ($)</th>
	<cfif appSettings.getPullbacksOn()>
		<th nowrap><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> ($)</th>
	</cfif>	
		<th>Final Pymt ($)</th>
	</tr>
  </thead>
  <tbody>
  </tbody>
  <tfoot>
  </tfoot>
</table>

</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in 
"jquery.dataTables-api.js" below and so we need to define it here. 
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 35;
	var mydatagrid = '';
</script>

<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/table2csv.js">

<script type="text/javascript">
	var jTable = $("#datagrid");
	mydatagrid = jTable.dataTable({
	"aaData": <cfoutput>#serializeJSON(variables.aaData)#</cfoutput>
	,"aaSorting": []
	,"aoColumns": [	{"bSortable":true, "bSearchable":true}/* Billback */
					,{"bSortable":true, "bSearchable":true}	/* Payee */
					,{"bSortable":true, "bSearchable":true}	/* Program */
					<cfif application.oBBReportGet.getAutoPayType() NEQ 2>
					,{"bSortable":true, "bSearchable":true}	/* Pay Cycle */
					</cfif>
					,{"bSortable":true, "bSearchable":false}	/* Start Date */
					,{"bSortable":true, "bSearchable":false}	/* End Date */
					,{"bSortable":true, "bSearchable":false,"sType":"dollar"}	/* Gross Amount */
					<cfif appSettings.getPullbacksOn()>
					,{"bSortable":true, "bSearchable":false,"sType":"dollar"}	/* Pullback Amt */
					</cfif>
					,{"bSortable":true, "bSearchable":false, "sType":"dollar"}	/* Final Pymt Amt */
				]
	,"bAutoWidth": false            // false for quicker rendering
	,"bDeferRender": true           // true for quicker rendering
	,"bProcessing": true            // true to show processing message in sorting large table
	,"bScrollCollapse": true        // true to put the footer of the grid just below the records, when there are a few records only
	,"bSortCellsTop": true          // true to inform sorting on first row in thead
	,"bSortClasses": false
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	,"sDom": 'pftir'
	,"iDisplayLength": 100
	,"bPaginate": true
	<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
	IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
	THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
	--->
	,"sScrollY" : 0 <!--- Leave this as 0 for setting datagrid height. --->

	<!--- NOT SHOWING THE COLUMNS TOTAL AS THERE MIGHT BE DIFFERENCE IN THE TOTAL FROM THE MAIN SUMMARY PAGE DUE TO NUMBER FORMATTING. --->
}).fnSetFilteringDelay();


	/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that 
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
	$('.dataTables_scrollBody').css('min-height', '30px');
</script>
</BODY>
</HTML>