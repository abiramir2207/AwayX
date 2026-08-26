<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\select_distributors_grid.cfm
      Date:     2016 August
      Author:   Milan Mushran
      Purpose:  import distributors for auto pay exception report
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Auto pay distributor selection</TITLE>
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
		.right{text-align:right}
		.center{text-align:center !important;}
		div.FilterAllSelected {float:right;}
		div.RemoveFilterAllSelected {float:right;}
	</style>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</HEAD>

<cfparam name="Report_ID" default="0">
<cfparam name="Form.FilterDistributors" default="">
<cfparam name="URL.FilterDistributors" default="">
<cfparam name="ContractMainID" default="">
<cfparam name="Contract_Number" default="">
<cfparam name="Start_Date" default="">
<cfparam name="End_Date" default="">
<cfparam name="form.submitFrm" default="0">

<cfset distDesc = lcase(application.returned_customer_setting.distributor_label_plural)>

<!--- When a user selects distributors on this popup page and then imports the selection and then revisits this popup page
without saving the selected distributors, we need access to the selected distributors, so that those distributors could
be selected ("checked"). That is why we create a form below "frmDist", create hidden values for all the values passed in the URL.
The important hidden variable for which we are doing  all this is "FilterDistributors". We populate "FilterDistributors" by accessing
the FilterDistributors_#URL.ContractMainID# on the opener and then submitting the form. Once the form is submitted, CF has access to the
list of distributors.

NOTE: I did not want to used this technique. I wanted to send the data to this page through a form from the opener, but the issue is that the
opener page (selected_programs.cfm) does not work when I use a "FORM" on that page.
--->
<cfif form.submitFrm eq 0>
	<FORM ACTION="select_distributors_grid.cfm" METHOD="post" NAME="frmDist" ID="frmDist">
	<cfoutput>
		<input type="hidden" name="FilterDistributors" id="FilterDistributors" value="" />
		<input type="hidden" name="ContractMainID" id="ContractMainID" value="#URL.ContractMainID#" />
		<input type="hidden" name="Contract_Number" id="Contract_Number" value="#URL.Contract_Number#" />
		<input type="hidden" name="Start_Date" id="Start_Date" value="#URL.Start_Date#" />
		<input type="hidden" name="End_Date" id="End_Date" value="#URL.End_Date#" />
		<input type="hidden" name="Report_ID" id="Report_ID" value="#URL.Report_ID#" />
		<input type="hidden" name="submitFrm" id="submitFrm" value="1" />
	</cfoutput>
	</FORM>

	<script>
	<cfoutput>
	/* 
	"Temp_FilterDistributors_#URL.ContractMainID#" is used to keep track of entries while the user is on the popup. The user may close the popup without importing the selected
	entries. In that case, when the popup opens again, the value of "Temp_FilterDistributors_#URL.ContractMainID#" variable should be the value of 
	"FilterDistributors_#URL.ContractMainID#" as "FilterDistributors_#URL.ContractMainID#" is the list of distributors whch the user has (imported or saved).
	*/
	window.opener.frmInsPayPeriod.Temp_FilterDistributors_#URL.ContractMainID#.value = window.opener.frmInsPayPeriod.FilterDistributors_#URL.ContractMainID#.value;
	
	/* Update the hidden varible in the above form. Since the form is subnitted, CF now has access to the list of selected distributors which can be used for
	keeping the selectioms checked.
	*/
	document.frmDist.FilterDistributors.value = window.opener.frmInsPayPeriod.FilterDistributors_#URL.ContractMainID#.value;
	</cfoutput>
	document.frmDist.submit();
	</script>
</cfif>

<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">

<cfset oPrgManager = CreateObject("component","components.programs.ProgramManager") />
<cfset oBBAutoReportGet = CreateObject("component","components.Billback.BBAutoReportGet") />

<cfset PrgEffDatesList = oPrgManager.getProgramVersionsWithinEffectiveDates(ContractMainID,Start_Date,End_Date)>
<cfset qryDistList = oBBAutoReportGet.getReportDistributors(Auto_Pay_Contract_ID = ContractMainID, Contract_List = PrgEffDatesList, BBAutoReportID = Report_ID)>

<cfset variables.aaData = []>

<cfloop query="qryDistList">

<cfset selectedDist = qryDistList.Selected_Distributor_ID>

<!--- If a list of distributors is passed to this page, then use that list of sellected distributors  and not the one from the
database. This list which is passed includes the distributors in the db as well as the ones which where selected, but not saved.
Eg: A user opens the popup, selects a few distributors, imports the selected distributors, and then reopens the popup.
--->
<cfif Form.FilterDistributors neq "-1">
	<cfset selectedDist = Form.FilterDistributors>
</cfif>

<cfset Address = Address_1 & "<br />" & City & "," & State>

<cfset variables.aTemp = []>
	
	<cfif ListFindNoCase(selectedDist,BSA_foodservice_customers_ID)>
		<cfset arrayAppend(variables.aTemp,'<input type="checkbox" name="distributor_id" class="cb" value="#BSA_foodservice_customers_ID#" CHECKED ONCLICK="if(!this.checked) document.all.distributor_check_all.checked = false; addRemoveDistributors();">')>
	<cfelse>
		<cfset arrayAppend(variables.aTemp,'<input type="checkbox" name="distributor_id" class="cb" value="#BSA_foodservice_customers_ID#" ONCLICK="if(!this.checked) document.all.distributor_check_all.checked = false; addRemoveDistributors();">')>
	</cfif>

	<!--- data column 1 - Ship To --->
	<cfset arrayAppend(variables.aTemp,Shr_Ship_To)>

	<!--- data column 2 - Distributor name --->
	<cfset arrayAppend(variables.aTemp,Name)>
	
	<!--- data column 3 - Address --->
	<cfset arrayAppend(variables.aTemp,Address)>
	
	<!--- data column 4 - Family --->
	<cfset arrayAppend(variables.aTemp,Family_Name)>
	
	<!--- data column 5 - Buying Group --->
	<cfset arrayAppend(variables.aTemp,Buying_Group_Name)>

	<!--- data column 6 - Placeholder column for filtering on selected records --->
	<cfset arrayAppend(variables.aTemp,"")>

	<!--- entire row data --->
	<cfset arrayAppend(variables.aaData, variables.aTemp)>
</cfloop>

<BODY>

<cfoutput>
<h2>#Contract_Number#: SELECT #ucase(application.returned_customer_setting.distributor_label_plural)# FOR AUTO PAY</h2>

<form name="frmDistributorList" method="post" action="select_distributors_grid.cfm">
<table id="datagrid" class="datagrid" style="table-layout:fixed;">
  <col width="3%"> <col width="15%"> <col width="20%"> <col width="22%"> <col width="20%"> <col width="20%">
  <thead>
  <tr>
    <th><input name="distributor_check_all" class="checkall" type="checkbox"></th>
    <th>#application.returned_customer_setting.shard_ship_to_label#</th>
    <th>#application.returned_customer_setting.distributor_label_singular# Name</th>
    <th>Address</th>
    <th>#application.returned_customer_setting.family_name_label_singular#</th>
    <th>#application.returned_customer_setting.buying_group_label_singular#</th>
  </tr>
  </thead>
  <tbody>
  </tbody>
  <tfoot>
  </tfoot>
</table>
	<input type="hidden" name="ContractMainID" value="#ContractMainID#">
	<input type="hidden" name="distributorList" value="">
</form>

<br />

<table width="900">
	<tr>
		<td align="right"><a href="##" onclick="importDistributors()">#application.util.string.actionLinkFormat2(lcase("import selected #application.returned_customer_setting.distributor_label_plural#"))#</a></td>
		<td align="right"><a href="##" onclick="selectInvoices()">#application.util.string.actionLinkFormat2(lcase("filter by invoices"))#</a></td>
		<td align="right"><a href="##" onclick="removeAllSelected()">#application.util.string.actionLinkFormat2(lcase("remove all selected #application.returned_customer_setting.distributor_label_plural#"))#</a></td>
	</tr>
</table>

</cfoutput>

<!--- This form is used to send list of distributors to the "invoice selection" page, where invoices can be selected based on "distributor selection" on this page. --->
<FORM ACTION="/search_screens/invoice/select_invoices_grid.cfm" METHOD="post" NAME="frmSelectedDist" ID="frmSelectedDist">
<cfoutput>
	<input type="hidden" name="ContractMainID" id="ContractMainID" value="#ContractMainID#" />
	<input type="hidden" name="Contract_Number" id="Contract_Number" value="#Contract_Number#" />
	<input type="hidden" name="Start_Date" id="Start_Date" value="#Start_Date#" />
	<input type="hidden" name="End_Date" id="End_Date" value="#End_Date#" />
	<input type="hidden" name="Report_ID" id="Report_ID" value="#Report_ID#" />
	<input type="hidden" name="distributorList" id="distributorList" />
</cfoutput>
</FORM>

<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/table2csv.js"/>

<script type="text/javascript">
var gridHeightAdjustment =  130;
var jTable = $("#datagrid");
/* "Math.floor($(window).height())" is height of the page.
Math.floor(jTable.offset().top)" is the height from the top of the page to the top of the grid.
*/
var heightDiff = (Math.floor($(window).height()) - Math.floor(jTable.offset().top))

var mydatagrid = jTable.show().dataTable({
	"aaData": <cfoutput>#serializeJSON(variables.aaData)#</cfoutput>
	,"aaSorting": []
	,"aoColumns": [	{"bSortable":false}	/* Col 1 */
					,{"bSortable":true, "bSearchable":true}/* Ship to */
					,{"bSortable":true, "bSearchable":true}	/* Name */
					,{"bSortable":false, "bSearchable":false}	/* Address */
					,{"bSortable":true, "bSearchable":false}	/* Family */
					,{"bSortable":true, "bSearchable":false}	/* Buying group */
					,{"bSortable":false, "bSearchable":true, "bVisible":false} /* Placeholder column for filtering on selected records */
				]
	,"bAutoWidth": false            /* false for quicker rendering */
	,"bDeferRender": true           /* true for quicker rendering */
	,"bProcessing": true            /* true to show processing message in sorting large table */
	,"bScrollCollapse": true        /* true to put the footer of the grid just below the records, when there are a few records only */
	,"bSortCellsTop": true          /* true to inform sorting on first row in thead */
	,"bSortClasses": false
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	,"sDom": 'fp<"RemoveFilterAllSelected"><"FilterAllSelected">tir'
	/* For pagination, set "bPaginate" to true */
	,"bPaginate": true
	/* How many records will show on one page */
	,"iDisplayLength": 500 
	<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
	IT WAS NECESSARY SO THAT THE LINK AT THE BOTTOM OF THIS PAGE CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
	THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
	--->
	,"sScrollY" : (heightDiff - gridHeightAdjustment)<!--- data grid height --->
}).fnSetFilteringDelay();

/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that 
the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
rather than there being a big gap between the two, when there are one or just a few records.
*/
$('.dataTables_scrollBody').css('min-height', '30px');


// "Check/Uncheck all" checkboxes
$('input[name=distributor_check_all]').change(function() {
	$("input.cb").attr("checked", (this.checked ? true : false));
	 addRemoveDistributors();
});


function addRemoveDistributors()
{

	/* The hidden variable on the opener. This variable is always updated. It is especially useful, when
	a user selects a few records, imports the records, then closes and reopens the popup. In this case, we need
	to know the list of selected records.
	That is why this variable is being used to keep track of all the selections, even when a user is paging through
	this popup page.
	*/
	<cfoutput>
	/* Kept it lowercase for being used in case-insensitive search using "$.inArray" */
	var hiddenCBoxes = window.opener.frmInsPayPeriod.Temp_FilterDistributors_#contractMainID#.value.toLowerCase();
	</cfoutput>

	/* convert the list into an array for easy manipulation */
	if (hiddenCBoxes.length == 0)
		var adistributorList = [];
	else
		var adistributorList = hiddenCBoxes.split(",");

	/* scan thru all checkboxes on the page */
	$('input.cb').each( function() {
		/* Kept it lowercase for being used in case-insensitive search using "$.inArray" */
		var distributor_id = $(this).val().toLowerCase();

		if ( $(this).prop('checked') ) {

			 /* checked box is not in the array, add it */
			if($.inArray(distributor_id , adistributorList) == -1)
				adistributorList.push( distributor_id );
		}
		else {
			 /* box is not checked so we need to remove it */
			while($.inArray(distributor_id , adistributorList) != -1) {
				adistributorList.splice($.inArray(distributor_id , adistributorList),1);
			}
		}
	});

	if(adistributorList.length > 1 && adistributorList[0] == '-1'){
		/* Remove first element which has value of "-1" */
		adistributorList.shift();
	}

	/* convert array back to a list for usage in form action */
	hiddenCBoxes = adistributorList.join(",");

	/* Refresh the hidden input with ALL selected rows. 
	All checked rows are saved in a hidden input with a name of 'distributorList'
	*/ 
	$('input[name=distributorList]').val( hiddenCBoxes );

	<cfoutput>
	/* update the temporary hidden variable on the opener page. This variable stores the set of distributors selected and is primarily
	used to keep track of selected entries while paging.
	*/
	window.opener.frmInsPayPeriod.Temp_FilterDistributors_#contractMainID#.value  = $('input[name=distributorList]').val();
	</cfoutput>
}

function importDistributors()
{
	var selectedRecords = 0;
	<cfoutput>
	/* Only if distributors are selected */
	if(window.opener.frmInsPayPeriod.Temp_FilterDistributors_#contractMainID#.value != "-1" && window.opener.frmInsPayPeriod.Temp_FilterDistributors_#contractMainID#.value != ''){
		selectedRecords = window.opener.frmInsPayPeriod.Temp_FilterDistributors_#contractMainID#.value.split(",").length;
	}

	/* update the hidden variable on the opener page. This variable stores the set of distributors selected. */
	window.opener.frmInsPayPeriod.FilterDistributors_#contractMainID#.value  = window.opener.frmInsPayPeriod.Temp_FilterDistributors_#contractMainID#.value;

	/* update the number of distributors on the parent page.*/
	window.opener.document.getElementById('distCount_#contractMainID#').innerHTML = selectedRecords;
	</cfoutput>

	window.close();
}

function selectInvoices()
{
	addRemoveDistributors();

	<cfoutput>
	/* If there is at least one selected distributor */
	if(window.opener.frmInsPayPeriod.Temp_FilterDistributors_#contractMainID#.value != "-1" && window.opener.frmInsPayPeriod.Temp_FilterDistributors_#contractMainID#.value != '')
	{		
		/* Reset the prevously selected invoice list, The invoice list can change based on distributor selection and so we want to remove the previous list. */
		window.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value = '';

		/* Set the "distributorlist" value and submit the form. */
		document.frmSelectedDist.distributorList.value = window.opener.frmInsPayPeriod.Temp_FilterDistributors_#contractMainID#.value;
		window.open('about:blank', 'invoiceList', 'toolbars=no,scrollbars=yes,resizable=yes,left=0,top=0,width=1050,height=650');
		frmSelectedDist.target = 'invoiceList';
		frmSelectedDist.submit();
	}
	else{
		alert('Please select #lcase(application.returned_customer_setting.distributor_label_plural)# first.')
	}
	</cfoutput>
}

function removeAllSelected()
{
	$("input.cb").attr("checked", false);
	$("input.checkall").attr("checked", false);

	/* Only reset the "Temp_FilterDistributors_#contractMainID#" variable. Only when the user imports rhe selections, 
	will the selection list update the "FilterDistributors_#contractMainID#" variable.
	*/
	<cfoutput>
	window.opener.frmInsPayPeriod.Temp_FilterDistributors_#contractMainID#.value = '';
	</cfoutput>
}

function showSelected()
{
	clearFilter();

	/* Clear the search input box*/
	$(".dataTables_filter input").val('')

	var d = new Date();
	var n = d.getMilliseconds();
	
	/* Loop through the grid records. For the selected records, update the "placeholder" column (6th column)
	with a specific search string. Then filter the grid to show those selected records only.
	The issue is that the first column (checkbox) cannot use a string search by using "jTable.fnUpdate".
	That is why a placeholder colimn has been created for string search. 
	*/
	<cfoutput>
	var row_index = -1;
	$(".cb", jTable.fnGetNodes()).each(function(){
		row_index = row_index + 1;

		if ($(this).is(":checked")) {
			jTable.fnUpdate( 's_'+n, row_index, 6 );
		}
	});
	jTable.fnFilter('s_'+n, 6, true, false);
	</cfoutput>
}

function clearFilter()
{	
	jTable.fnFilterClear();
}

<cfoutput>
$('div.FilterAllSelected').html("<a href='javascript:showSelected();'><span style='color:red;font-weight:bold'>[</span>&nbsp;<span style='font-weight:bold'>show selected #distDesc# only</span></a><span style='color:red;font-weight:bold'>&nbsp;]</span>&nbsp;&nbsp;&nbsp;");
$('div.RemoveFilterAllSelected').html("<a href='javascript:clearFilter();'><span style='color:red;font-weight:bold'>[</span>&nbsp;<span style='font-weight:bold'>remove selected #distDesc# filter<span></a><span style='color:red;'font-weight:bold'>&nbsp;]</span>");
</cfoutput>

/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that 
the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
rather than there being a big gap between the two, when there are one or just a few records.
*/
$('.dataTables_scrollBody').css('min-height', '30px');
</script>

</BODY>
</HTML>