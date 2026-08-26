<!----------------------------------------------------------------------------------
Name         :	index.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/09/2016
Created By   : 	Anand Rao
Description  : 	Page to create NUC Targets
---------------------------------------------------------------------------------->
<!--- <cfdump var="#form#"> --->
<cfsilent>
<cfscript>
	plannerSettingsManager = createObject("component", "mvc.Models.planner.PlannerSettingsManager");
</cfscript>
</cfsilent>
<!DOCTYPE HTML>
<html>
<head>
	<cfsavecontent variable="head_content">
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<cf_include files="/common_files/datatable.css, /styles/css-loader.css">
		<style>
			.right { float: right; }
			.header1 { margin: 10px 0; width: 100%; box-sizing: border-box;}
			div.header2 { margin-bottom:10px; }
			.header2 a { margin-right: 25px; }
			.locked, .info { margin-left:30px; font-weight2:bold; font-size:1em; color:white; padding:5px 20px;  letter-spacing:0.75px; border:2px solid orange; }
			div#msg55 { font-size: 1.15em; letter-spacing:0.9px; }
			div#msg55 p { font-size: 1.35em; margin:20px; padding:20px; background-color: #BDE5F8; letter-spacing:0.9px; }
			button { cursor: pointer; }
			table.datagrid { table-layout: fixed; width:94%; }
			table.datagrid td { height: 20px; overflow: hidden; }
			thead th { text-align:left; }
			thead th > input { width:70%; }
			body { padding:0; margin:0; }
			form { margin:0; padding:0; border2:1px solid blue;}
			div.header {
			  height: 30px;
			  margin:0;
			  background-image:
			    linear-gradient(
			      to right,
			       #010281, #A7CAF2
			    );
			 	color: white;
				font-size: 14px;
				font-weight: bold;
				letter-spacing: 0.75px;
			 	padding:8px 0 0 8px;
			}
			div.header > button { margin:6px 10px; }
			div.page_title { float2:right; margin:8px;
			 	color: white;
				font-size: 14px;
				font-weight: bold;
				letter-spacing: 0.75px;
			}
			div.action { margin:10px; }
			div.action > a { margin:0 15px; }
			th.case, td.case, th.uom, th.promo, td.uom, td.promo, th.blend, td.blend, th.tmargin, td.tmargin { text-align: right !important; }
			th.cb, td.cb { text-align:center; }
			input.case, input.promo, input.blend, input.tmargin { width:100px; text-align: right; }
			select.uom { width:50px; }
			div#content { margin:10px 5px; border2:1px solid red;}
			div.save { display:inline-block; margin-left: 30px; position: relative; top:-4px; }
			a.default { margin:0 30px; }

			div#loader { font-size:16px; text-align: center; height:100%; margin-top:27%; }
			#saveLink{
				position:fixed;
				right:-23px;
				bottom:5px;
				border2:2px solid red;
			}
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>
<cfset jQueryUI.widgets = "tooltip">
<cfinclude template="/common_files/jQuery.cfm">
<form name="nuc_targets" method="post">
	<input type="hidden" name="action" id="action" value="#form.action#">
	<div class="header">
		NUC TARGETS
	</div>

	<cfif cgi.request_method eq "post">
		<cfif form.action eq "export">
			<cfset export_to_excel()>
		<cfelseif form.action eq "import">
			<cfset import_from_excel()>
		</cfif>
	<cfelse>
		<cfscript>
		</cfscript>
	</cfif>


	<div class="action">
	<cfoutput>
		<a class='action' id="export" href2="export.cfm">#application.util.string.linkFormat('export to excel')#</a>
		<a class='action' id="import" href="import.cfm">#application.util.string.linkFormat('import from excel')#</a>
	</cfoutput>
	</div>
</form>
<!----

	<!--- data table grid --->
	<cfset variables.columnSizes = [1,
									4,
									8,
									3,
									3,
									2,
									3,
									2,
									3
									]>
	<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )>
	<div id=content style="display:none;">
	<cfset mass_apply_help = "click to assign the above value to<br> the selected entries on the left">
	<table class="datagrid">
	<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
		<cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
	</cfloop>
	<thead>
		<tr>
			<th class=cb><input name="checkall" type="checkbox" #disabled#></th>
			<th><b>#getNUCPGLName.Group_Level_Desc#</b></td>
			<th><b>#getNUCPGLName.Group_Level_Desc# Desc</b></td>
			<th class=case>Case Count
				<input type="text" name="mass_case_count" class="case" #disabled#><br>
				<a id=apply_case_count title="#mass_apply_help#" #disabled#>#application.util.string.linkFormat("apply")#</a>
			</th>
			<th class=promo>
				Promoted NUC
				<input type="text" name="mass_promoted_nuc" class="promo" #disabled#><br>
				<a id=apply_promoted_nuc title="#mass_apply_help#" #disabled#>#application.util.string.linkFormat("apply")#</a>
			</th>
			<th class=uom>
				UOM<br>
				<select name="mass_promoted_uom" class="uom" #disabled#>
					<option value="">&nbsp;</option>
					<cfloop query="getUOM">
						<option value="#getUOM.Unit_Of_Measure_ID#">#getUOM.Abbreviation_Singular#</option>
					</cfloop>
				</select><br>
				<a id=apply_promoted_uom title="#mass_apply_help#" #disabled#>#application.util.string.linkFormat("apply")#</a>
			</th>
			<th class=blend>
				Blended NUC<br>
				<input type="text" name="mass_blended_nuc" class=blend #disabled#><br>
				<a id=apply_blended_nuc title="#mass_apply_help#" #disabled#>#application.util.string.LinkFormat("apply")#</a>
			</th>
			<th class=uom>
				UOM<br>
				<select name="mass_blended_uom" class="uom" #disabled#>
					<option value="">&nbsp;</option>
					<cfloop query="getUOM">
						<option value="#getUOM.Unit_Of_Measure_ID#">#getUOM.Abbreviation_Singular#</option>
					</cfloop>
				</select><br>
				<a id=apply_blended_uom title="#mass_apply_help#" #disabled#>#application.util.string.LinkFormat("apply")#</a>
			</th>
			<th class=tmargin>Target Margin
				<input type="text" name="mass_target_margin" class=tmargin #disabled#><br>
				<a id=apply_target_margin title="#mass_apply_help#" #disabled#>#application.util.string.LinkFormat("apply")#</a>
			</th>
		</tr>
	</thead>
	</cfoutput>
	<tbody>
	<!--- <cfoutput query="getNUCTargets" startrow="1" maxrows="100"> --->
	<cfoutput query="getNUCTargets"  startrow="1" maxrows="1">
		<cfscript>
			row_class = "r" & getNUCTargets.currentRow;
		</cfscript>
		<tr>
			<td class=cb>
				<input type="checkbox" class="cb" name="#row_class#" #disabled#>
				<input type="hidden" name="guid_#row_class#" class="guid" value="#getNUCTargets.Group_GUID#">   <!--- this element gets submitted --->
			</td> <!--- this element does NOT get submitted --->
			<td>#getNUCTargets.Group_Number#</td>
			<td>#getNUCTargets.Group_Desc#</td>
			<td class="case">
				<input type="text" name="case_count_#row_class#" class="case #row_class#" value="#getNUCTargets.Case_Count#" #disabled#>
			</td>
			<td class="promo">
				<input type="text" name="promoted_nuc_#row_class#" class="promo #row_class#" value="#trim(numberformat(getNUCTargets.Promoted_NUC, '_-___.____'))#" #disabled#>
			</td>
			<td class="uom">
				<select name="promoted_uom_#row_class#" class="uom promo #row_class#" #disabled#>
					<option value="">&nbsp;</option>
					<cfloop query="getUOM">
						<option value="#getUOM.Unit_Of_Measure_ID#" <cfif getNUCTargets.promoted_NUC_UOM EQ getUOM.Unit_Of_Measure_ID> selected</cfif>>#getUOM.Abbreviation_Singular#</option>
					</cfloop>
				</select>
			</td>
			<td class="blend">
				<input type="text" name="blended_NUC_#row_class#"  class="blend #row_class#" value="#trim(numberformat(getNUCTargets.Blended_NUC, '_-___.____'))#" #disabled#>
			</td>
			<td class="uom">
				<select name="blended_uom_#row_class#" class="uom blend #row_class#" #disabled#>
					<option value="">&nbsp;</option>
					<cfloop query="getUOM">
						<option value="#getUOM.Unit_Of_Measure_ID#" <cfif getNUCTargets.Blended_NUC_UOM EQ getUOM.Unit_Of_Measure_ID> selected</cfif>>#getUOM.Abbreviation_Singular#</option>
					</cfloop>
				</select>
			</td>
			<td class=tmargin>
				<input type="text" name="target_margin_#row_class#"  class="tmargin #row_class#" value="#trim(numberformat(getNUCTargets.target_margin, '_-___.____'))#" #disabled#>
			</td>
	 	</tr>
	</cfoutput>
	</tbody>
	</table>
	<cfif form.action eq "edit">
		<cfoutput><a class='default action' id="saveLink" onclick='submitForm()'>#application.util.string.linkFormat('save')#</a></cfoutput>
	</cfif>
	</div>
</form>
<div id="loader2" class="loader loader-default is-active" half data-text="SAVING CHANGES PLEASE WAIT..." style="display:none;"></div>
</cfsavecontent>
<!--- remove extra white spaces prior to displaying on the page --->
<cfoutput>#application.util.string.compress( variables.body )#</cfoutput>
--->

<cfinclude template="/common_files/dataTables2.cfm">

<script>
	$("#export").click(function(){
		show_loader("EXPORTING NUC TARGETS, PLEASE WAIT...", -3000);
		window.location.href = "export.cfm";
	});
	pageTitle( "NUC Targets" );
</script>
<cfinclude template="/common_files/focus.cfm">     <!--- 47143 --->
</body>
</html>