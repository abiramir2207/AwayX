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

		<cfparam name="PageName"		default="Duplicate Program">
		<cfset dupTemplateManager = CreateObject("component","components.programs.template.DuplicateTemplateManager").init(form.TemplateID,trim(PageName)) />
		<cfset currentDuplicateDef = dupTemplateManager.getDupProgramDefinition() >

		<cfquery name="disChecked" dbtype="query">
		 SELECT Ischecked 
		 FROM currentDuplicateDef
		 WHERE Item_Name = 'Distributors'
		</cfquery>

<cfscript>
	param name="form.uom" default="2";

	uom_text = "/ " & (form.uom eq "2" ? "LBS" : "CS");
	dupTemplateManager = createObject("component","components.programs.duplicate_program.DuplicateProgramManager");
	qGetDuplicateProducts = dupTemplateManager.getDuplicatesByProduct(form.ProgramID, form.DuplicateProgramIDList, form.is_component_checked, form.is_rate_checked, 'Level2',form.productID, disChecked.Ischecked, form.uom);
</cfscript>


<!---
<cfloop collection="#qGetDuplicateProducts#" item="key">
     <cfoutput>     	
     <cfdump var="#qGetDuplicateProducts[key]#">
     </cfoutput>
</cfloop>
<cfdump var="#qGetDuplicateProducts#" abort="true">
--->

<body>
	
<style>
	.header{
		Margin-top:10px;
		margin-bottom:10px; 
		padding:5px; 
		font-size:12px;
		background-color:#E8E8E8;
		font-weight:bold
	}
</style>

<p class="page_title1">LEVEL 2 - DUPLICATE PROGRAMS PER PRODUCT </p>

<cfoutput>
<div class="header"> Current Program :&nbsp;&nbsp;&nbsp;&nbsp;#dateformat(qGetDuplicateProducts.qGetCurrentProgram.contract_start_date,'mm/dd/yyyy')# - #dateformat(qGetDuplicateProducts.qGetCurrentProgram.contract_end_date,'mm/dd/yyyy')#</div>

<table style="width: 99%;margin-bottom:20px;">
	<tr style="background-color:##ffce84">
		<th>Base Sales</th>
		<th>Fixed Price</th>
		<th>Rebate</th>
		<th>Growth</th>
		<th>Lumpsum</th>
		<th>Spend</th>
		<th align="center">Item</th>
		<th align="left">Description</th>
	</tr>
	<cfloop query="#qGetDuplicateProducts.qGetCurrentProgram#">	
	<tr>
		<td style="text-align:right"><cfif len(price)>#NumberFormat(price,'$(9.99999)')#<cfelse>N/A</cfif></td>	
		<td style="text-align:right"><cfif len(Fixed_Price)>#NumberFormat(Fixed_Price,'$(9.99999)')#<cfelse>N/A</cfif></td>
		<td style="text-align:right"><cfif len(Rebate)>#NumberFormat(Rebate,'$(9.99999)')#<cfelse>N/A</cfif></td>
		<td style="text-align:right"><cfif len(Growth)>#NumberFormat(Growth,'$(9.99999)')#<cfelse>N/A</cfif></td>
		<td style="text-align:right"><cfif len(Lumpsum)>#NumberFormat(Lumpsum,'$(9.99999)')#<cfelse>N/A</cfif></td>
		<td style="text-align:right"><cfif len(Spend)>#NumberFormat(Spend,'$(9.99999)')#<cfelse>N/A</cfif></td>
		<td align="center">#item#</td>
		<td>#Description#</td>
	</tr>
	</cfloop>
</table>
	
<div class="header"> Overlapping Programs </div>

<table class="datagrid" style="width: 99%;">
	<thead>
		<tr>
			<th>Base Sales</th>
			<th>Fixed Price</th>
			<th>Rebate</th>
			<th>Growth</th>
			<th>Lumpsum</th>
			<th>Spend</th>
			<th>Component</th>
			<th>Customer</th>
			<th>Name</th>
			<th>Program</th>
			<th>Title</th>
			<th>Program Date</th>
		</tr>
	</thead>
	<tbody>
	<cfloop query="#qGetDuplicateProducts.qDuplicatesByProducts#">	
		<tr>
			<td style="text-align:right">#NumberFormat(price,'$(9.99999)')#</td>
			<td style="text-align:right"><cfif len(Fixed_Price)>#NumberFormat(Fixed_Price,'$(9.99999)')#<cfelse>N/A</cfif></td>
			<td style="text-align:right">#NumberFormat(Rebate,'$(9.99999)')#</td>
			<td style="text-align:right">#NumberFormat(Growth,'$(9.99999)')#</td>
			<td style="text-align:right">#NumberFormat(Lumpsum,'$(9.99999)')#</td>
			<td style="text-align:right">#NumberFormat(Spend,'$(9.99999)')#</td>
			<td>#Component#</td>
			<td>#Shr_Ship_To#</td>
			<td>#Name#</td>
			<td>#Contract_Number#</td>
			<td>#Contract_Title#</td>
			<td>#dateformat(contract_start_date,'mm/dd/yyyy')#<br>#dateformat(contract_end_date,'mm/dd/yyyy')#</td>
		</tr>	
	</cfloop>
	</tbody>
</table>

<form name="dup_program_per_product" method="post">
	#application.util.struct.convertToHiddenInput(form, "uom")#
	<input type="hidden" name="uom" value="">
</form>

<style>
div.uom { float:right; margin-left:20px; }
</style>
<cfsavecontent variable="uom">
<input style="margin-left:20px;" type="radio" name="uom" value="1"<cfif form.uom eq "1">checked</cfif> onclick="uomChange(1);">Physical Case<input type="radio" name="uom" value="2" <cfif form.uom neq "1">checked</cfif> onclick="uomChange(2);">Pounds
</cfsavecontent>

<div style="margin:10px 5px">
	<a onclick="window.close();">#application.util.string.linkFormat("close window")#</a>
</div>
</cfoutput>

<script>
	var oTable = $('table.datagrid').DataTable({		
		"columnDefs": [
							{"targets": [0],"sortable":true,  	"searchable":true }
						, 	{"targets": [1],"sortable":true,  	"searchable":true }
						, 	{"targets": [2],"sortable":true, 	"searchable":true }
						, 	{"targets": [3],"sortable":true, 	"searchable":true }
						, 	{"targets": [4],"sortable":true, 	"searchable":true }
						, 	{"targets": [5],"sortable":true,  	"searchable":false}
						,	{"targets": [6],"sortable":true,  	"searchable":true }
						, 	{"targets": [7],"sortable":true,  	"searchable":true }
						, 	{"targets": [8],"sortable":true, 	"searchable":true }
						, 	{"targets": [9],"sortable":true, 	"searchable":true }
						, 	{"targets": [10],"sortable":true, 	"searchable":true }
						, 	{"targets": [11],"sortable":false, 	"searchable":false }
		]
		,"Paging": false
		,"sDom": "f<'uom'>t"
		,"scrollY": Math.floor(jQuery(window).height()) - 80
		,"scrollX": true
		,"scrollCollapse": true
		,"iDisplayLength": 1000
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
		$("form[name=dup_program_per_product]").submit();
	}
</script>
</body>
</html>