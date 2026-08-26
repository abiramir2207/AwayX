<cfsilent>
<!---
	Name:          	program_product_fixed_rebate_paid_to_dup.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	09/23/2011
	Created By:    	Deepa Kunnath
	Description:   	This page is the UI for displaying list of items inside a program that have fixed price and rebate for different paid to
	Parameters:		Program_ID
	Usage:
--->

<CFPARAM NAME="Attributes.Program_ID" DEFAULT="0">
<CFPARAM NAME="Attributes.Contract_Number" DEFAULT="">
<CFPARAM NAME="Attributes.Contract_Title" DEFAULT="">
<CFPARAM NAME="Attributes.CID" DEFAULT="0">
<CFPARAM NAME="Attributes.Item_Fixed_Rebate_Paid_To_Dup_Message" DEFAULT="0">
<CFPARAM NAME="Attributes.thisIsAPopUpWindow" DEFAULT="0">
<CFPARAM NAME="Attributes.continueURL" DEFAULT="">
<CFPARAM NAME="Attributes.ReturnVariable" DEFAULT="">
<cfset bProgramProductsPaidToWithDuplicateDiscountTypes = 0 />
</cfsilent>

<CFIF ThisTag.ExecutionMode EQ "start">
	<cfif Attributes.Program_ID neq "0" and isNumeric(Attributes.Program_ID) and (Attributes.Item_Fixed_Rebate_Paid_To_Dup_Message eq 2 or Attributes.Item_Fixed_Rebate_Paid_To_Dup_Message eq 3)>
		<cfset qGetProgramProductsPaidToWithDuplicateDiscountTypes = CreateObject("component", "components.programs.ProgramManager").getProgramProductsPaidToWithDuplicateDiscountTypes(Attributes.Program_ID) />
		<cfif qGetProgramProductsPaidToWithDuplicateDiscountTypes.recordCount>
			<cfset bProgramProductsPaidToWithDuplicateDiscountTypes = 1 />
			<title>Duplicate Warning Window</title>
			<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
			<style>
			hr { margin: 2px 0 ; }
			#msg55 { font-size: 1.15em; letter-spacing:0.9px; }
			#whole39 { position: relative; top: -25px; }
			#prgheading { width: 100%; background-color: #ffce84; margin: 0; }
			#prgsubhead1, #prgsubhead2 { width: 48%; font-size: 1.15em; letter-spacing: 0.8px; padding: 7px; display: inline-block; }
			#prgsubhead2 { text-align: right; }
			#actions { text-align: center; width: 100%; }
			#actions a { margin-right: 15px; }
			</style>
			<div id="msg55"></div>    <!--- reserve this div for displaying message in long process (e.g. saving changes) --->
			<div id="whole39">
			<!--- display brief program information at the top --->
			<cfquery name="variables.contract" datasource="#application.datasource#">
				SELECT Program_Control_Panel_Options.Created_Type
				       ,Contract_Main.Contract_Start_Date
				       ,Contract_Main.Contract_End_Date
				  FROM Contract_Main
				       INNER JOIN Program_Control_Panel_Options ON Program_Control_Panel_Options.ProgramControl_Panel_Options_Id = Contract_Main.ProgramType_Id
				 WHERE Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#Attributes.Program_ID#">
				       AND Program_Control_Panel_Options.Deleted = 0
			</cfquery>
			<hr width="100%" size="1" color="blue">
			<cfoutput>
			<div id="prgheading">
				<div id="prgsubhead1"><cfoutput><b>#Attributes.Contract_Number#</b><br>#Attributes.Contract_Title#</cfoutput></div>
				<div id="prgsubhead2"><b>Template:</b> #variables.contract.Created_Type#<br>#dateFormat(variables.contract.Contract_Start_Date,'medium')# - #dateFormat(variables.contract.Contract_End_Date,'medium')#</div>
			</div>
			</cfoutput>
			<hr width="100%" size="1" color="blue">

			<div STYLE="color: red; font-size: 13px; letter-spacing:0.7px; padding:10px; font-weight: bold; ">
				<b style="color:blue;">WARNING:</b> Below products have different discount types for same paid to in this program.
			</div>
			<div id="table_container">
				<table border="0" cellspacing="0" width="100%" class="datagrid" id="table_content">
					<thead>
					<tr>
						<th width="15%">Item</th>
						<th width="20%">Description</th>
						<th width="20%">Discount Type</th>
						<th width="20%">Component</th>
						<th width="20%">Paid To</th>
						<th width="20%">Price/Rate</th>
					</tr>
					</thead>
					<tbody>
					<cfoutput query="qGetProgramProductsPaidToWithDuplicateDiscountTypes">
						<tr>
							<td>#item#</td>
							<td>#description#</td>
							<td>#Discount_Type_Desc#</td>
							<td>#Component_Name#</td>
							<td>#Payment_Paid_To_Type_Name#</td>
							<td>#Rate#/#Abbreviation#</td>
						</tr>
					</cfoutput>
					</tbody>
				</table>
			</div>

			<br>
			<cfinclude template="/common_files/jQuery.cfm">
			<cfinclude template="/common_files/dataTables2.cfm">
			<script>
			var windowHeight = $(window).height(), headerHeight = 185, sScrollY = windowHeight - headerHeight;
			function continueToNextPage(sUrl, sTableName) {
				$("#whole39").hide();
				window.location.href = sUrl;
			}
	     	var oTable = $('table.datagrid').show().dataTable({
							       "aaSorting": []
							      ,"aoColumns": [	 {"bSortable":false, "bSearchable":false }
							      					,{"bSortable":false, "bSearchable":false }
							      					,{"bSortable":false, "bSearchable":false }
							      					,{"bSortable":false, "bSearchable":false }
							      					,{"bSortable":false, "bSearchable":false }
							      					,{"bSortable":false, "bSearchable":false }
							      				]
							      ,"bAutoWidth": false            // false for quicker rendering
							      ,"bPaginate": false
							      ,"bScrollCollapse": false
							      ,"bSortClasses": false
							      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
							      ,"sDom": 'tr'
								  ,"sScrollY": sScrollY
		  				});

				// resize method #2: when tfoot does NOT exists
				$(window).resize(function() {
				      $('.dataTables_scrollBody').css('height', ($(window).height() - headerHeight));
				      oTable.fnDraw();
				});
			</script>

			<cfoutput>
			<cfsilent>
			<cfif Attributes.continueURL eq "">
				<cfset Attributes.continueURL = "contract_approve_broker_action.cfm?dupProdPaidToDiscTypeChecked=1">
				<cfloop collection=#url# item="urlvar">
					<cfif not ListFindNoCase("dupProdPaidToDiscTypeChecked,CANCEL_PAGE", urlvar)>
						<cfset Attributes.continueURL="#Attributes.continueURL#&#urlvar#=#URLEncodedFormat(url[urlvar])#">
					</cfif>
				</cfloop>
			</cfif>
			</cfsilent>
			<div id="actions">
				<cfif Attributes.Item_Fixed_Rebate_Paid_To_Dup_Message neq 3>
					<a href="##" onclick="continueToNextPage('#Attributes.continueURL#', 'continueRFA_table')">#application.util.string.actionLinkFormat2("continue")#</a>
				</cfif>
				<cfif Attributes.thisIsAPopUpWindow EQ 1>
					<a href="##" onclick="window.close();">#application.util.string.actionLinkFormat2("cancel")#</a>
				<cfelse>
					<a href="contract_edit_menu.cfm?CID=#Attributes.CID#">#application.util.string.actionLinkFormat2("cancel")#</a>
				</cfif>
			</div>
			</cfoutput>
			</div>  <!--- id="whole39"> --->
		</cfif><!--- <cfif qGetProgramProductsPaidToWithDuplicateDiscountTypes.recordCount> --->
	</cfif> <!--- <cfif Attributes.Program_ID neq "0" and isNumeric(Attributes.Program_ID)> --->

	<cfif Attributes.ReturnVariable NEQ "">
		<cfset "Caller.#Attributes.ReturnVariable#" = bProgramProductsPaidToWithDuplicateDiscountTypes />
	</cfif>
</CFIF> <!--- <CFIF ThisTag.ExecutionMode EQ "start"> --->
