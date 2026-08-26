<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<cfsavecontent variable="head_content">
		<title>Duplicate Programs by Product</title>
		<cf_include files="/common_files/datatable.css, /common_Files/jQuery.cfm, /common_Files/dataTables2.cfm">
		<style>
			p {
				font-size: 13px;
				padding-bottom: 5px;
				/* border-bottom: 1px solid #CCC; */
			}
			th { font-size: 12px; }
			td.right {
				text-align: right;
			}
			.page_title1 {
				padding-top: 5px;
			}
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<cfscript>
	param name="form.uom" default="0";

	uom_text = "/ " & (form.uom eq "2" ? "LBS" : "CS");
	dupTemplateManager    = createObject("component","components.programs.duplicate_program.DuplicateProgramManager");
	qGetDuplicateProducts = dupTemplateManager.getDuplicatesByProduct(form.ProgramID, form.DuplicateProgramIDList, form.is_component_checked, form.is_rate_checked, 'Level1','', 0, form.uom);
</cfscript>

<cfif (isDefined("qGetDuplicateProducts.qDuplicatesByProducts.recordcount") AND qGetDuplicateProducts.qDuplicatesByProducts.recordCount GTE 1)>
	<cfquery dbtype="query" name="getUOM">
		SELECT Distinct UOM FROM qGetDuplicateProducts.qDuplicatesByProducts
	</cfquery> 
	<cfif ((getUOM.recordCount EQ 1) AND (FORM.uom EQ 0))>
		<cfset FORM.uom = getUOM.UOM />
	<cfelseif ((getUOM.recordCount EQ 1) AND (FORM.uom NEQ 0))>
		<cfset FORM.uom = FORM.uom />
	<cfelse>
		<cfset FORM.uom = 1 />
	</cfif>
</cfif>

<!---
<cfloop collection="#qGetDuplicateProducts#" item="key">
     <cfoutput>
     <cfdump var="#qGetDuplicateProducts[key]#">
     </cfoutput>
</cfloop>
<cfdump var="#qGetDuplicateProducts#" abort="true">--->

<body>
<p class="page_title1">LEVEL 1 - DUPLICATE PROGRAMS BY PRODUCT</p>

<p style="font-size:10px;color:red;">Click on item to view level 2 - Duplicate Programs per Product</p>

<cfoutput>
<table class="datagrid" style="width: 99%;">
<thead>
	<tr>
		<th>Overlapping <br>Programs</th>
		<th style="text-align:center">Min Fixed<br>Price</th>
		<th style="text-align:center">Rebate<br>[Aggregate]</th>
		<th style="text-align:center">Growth<br>[Aggregate]</th>
		<th style="text-align:center">Lumpsum<br>[Aggregate]</th>
		<th>Item</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
<cfloop query="#qGetDuplicateProducts.qDuplicatesByProducts#">
	<tr>
		<td>#Overlap_Count#</td>
		<td style="text-align:right">#NumberFormat(Min_Fixed_Price,'$(9.99999)')#</td>
		<td style="text-align:right">#NumberFormat(Sum_Rebate,'$(9.99999)')#</td>
		<td style="text-align:right">#NumberFormat(Sum_Growth,'$(9.99999)')#</td>
		<td style="text-align:right">#NumberFormat(Sum_Lumpsum,'$(9.99999)')#</td>
		<td><a class="level2" id="#BSA_Foodservice_Items_Master_ID#">#Item#</a></td>
		<td>#Description#</td>
	</tr>
</cfloop>
</tbody>
</table>

<div style="width: 100%;clear: both;text-align:center;margin-top:10px">
	<a href="javascript:self.close()">#application.util.string.actionLinkFormat2('close window')#</a>
</div>

<form id="dup_program_per_product" method="post" action="dup_program_per_product.cfm" target="dup_program_per_product">
	<input type="hidden" name="DuplicateProgramIDList" value="#form.DuplicateProgramIDList#">
	<input type="hidden" name="ContractControlID" value="#form.ContractControlID#">
	<input type="hidden" name="ProgramID" value="#form.ProgramID#">
	<input type="hidden" name="is_component_checked" value="#form.is_component_checked#">
	<input type="hidden" name="is_rate_checked" value="#form.is_rate_checked#">
	<input type="hidden" name="filter_distributor" value="0">
	<input type="hidden" name="reportType" value="Level2">
	<input type="hidden" name="productID" value="">
	<input type="hidden" name="uom" value="#form.uom#">
	<input type="hidden" name="TemplateID" value="#form.TemplateID#">
</form>

<form name="dup_program_by_product" method="post">
	#application.util.struct.convertToHiddenInput(form, "uom")#
	<input type="hidden" name="uom" value="">
</form>
</cfoutput>
<style>
div.uom { float:right; margin-left:20px; }
</style>
<cfsavecontent variable="uom">
<input style="margin-left:20px;" type="radio" name="uom" value="1"<cfif form.uom eq "1" or form.uom neq "2">checked</cfif> onclick="uomChange(1);">Physical Case<input type="radio" name="uom" value="2" <cfif form.uom eq "2">checked</cfif> onclick="uomChange(2);">Pounds
</cfsavecontent>
<script>
	var oTable = $('table.datagrid').DataTable({
		"columnDefs": [
							{"targets": [0],"sortable":true,  	"searchable":true }
						, 	{"targets": [1],"sortable":true,  	"searchable":true }
						, 	{"targets": [2],"sortable":true, 	"searchable":true }
						, 	{"targets": [3],"sortable":true, 	"searchable":true }
						, 	{"targets": [4],"sortable":true, 	"searchable":true }
						, 	{"targets": [5],"sortable":true, 	"searchable":true }
						, 	{"targets": [6],"sortable":true,  	"searchable":false}
		]
		,"bPaginate": true
		,"pagingType": "simple"
		,"sDom": "f<'uom'>tip"
		,"scrollY": Math.floor(jQuery(window).height()) - 200
		,"scrollX": true
		,"scrollCollapse": true
		,"iDisplayLength": 1000
		,"drawCallback": function( settings ) {
				$('a.level2').click( function() {
					/* assign product ID parameter */
					$('input[name=productID]').val( $(this).attr("id") );
					/* create a popup */
					popupInCenter('', "dup_program_per_product", 1000, 600);
					/* post a form there */
					$('form[id=dup_program_per_product]').submit();
				});
   		 }
	})

	/* The default minimum scrollable height of a datagrid is around "300px". We need to reduce the minimum height, so that
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
		$('.dataTables_scrollBody').css('min-height', '30px');
		$('.dataTables_wrapper').css('min-height', '30px');
		$('.DTFC_ScrollWrapper').css('height', 'auto');
		$('.DTFC_LeftBodyLiner').css('height', 'auto');
		$('.DTFC_LeftBodyLiner').css('overflow', 'hidden');
		$('.DTFC_LeftBodyWrapper').css('height', 'auto');



	<cfoutput>
	$('div.uom').html('#application.util.string.compress(uom)#');
	</cfoutput>
	function uomChange(uom){
		$("input[name=uom][type=hidden]").val(uom);
		$("form[name=dup_program_by_product]").submit();
	}
</script>
</body>
</html>