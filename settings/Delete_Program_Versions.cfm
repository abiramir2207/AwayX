<!---
	Copyright (c)2017 Blacksmith Applications, Inc.
	Filename:		C:\Users\drachala\Work\Code\_base\AwayX\settings\Delete_Programs.cfm
	Created:		3/7/2017
	Developer:		drachala
	Description:	 This page is used to deleted specific version of the program.
--->
<CFSET URL.PageTitle="Delete Programs Version">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfparam name="form.dContinue" default="0">
<cfparam name="url.ContractMainID" default="0">
<cfparam name="url.RevisionContractMainID" default="0">

<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">


<style>
	.highlighter{background-color: yellow;text-decoration:line-through;}
	td.details-control {
		background: url('/Images/details_open.png') no-repeat center center;
		cursor: pointer;
	}
	tr.shown td.details-control {
		background: url('/Images/details_close.png') no-repeat center center;
	}
</style>

	<cfif form.dContinue>
		<cfset DeleteThisVersion = CreateObject("component", "components.programs.program").deleteProgramVersion(form.ContractNumber,form.ContractMainID,form.parentContractMainID)>
		<script type="text/javascript">
			window.close();
		</script>
	</cfif>

<cfif url.ContractMainID>
	<cfquery name="GetPrograms" datasource="#application.datasource#">
		SELECT Contract_main_id, Contract_Number, revision_version, Contract_Start_Date, Contract_End_Date, Effective_Start_Date, Effective_End_Date
				   ,Contract_Created_Date, CS.Contract_Status_Type_Desc, Revision_of_Contract_Main_ID, Deleted, Contract_Status_Type_IDX
		FROM Contract_Main
		INNER JOIN Contract_Status_Types CS
		ON CS.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
		WHERE 	(Contract_Main_Id = #url.ContractMainID# OR Contract_Main_ID = '#url.RevisionContractMainID#')
		AND Approved = 1
		Order by revision_version
	</cfquery>

	<cfquery name="check4Parent" datasource="#application.datasource#" >
		SELECT Contract_Main_ID, deleted
		FROM Contract_Main
		WHERE Revision_of_Contract_Main_ID = <cfqueryparam value="#url.ContractMainID#" cfsqltype="cf_sql_numeric" >
		AND Contract_Number = <cfqueryparam value="#GetPrograms.Contract_Number#" cfsqltype="cf_sql_varchar" >
		AND Approved = 1
		ORDER BY Parent_Has_Previous_Revision
	</cfquery>

	<cfquery name="check4RFAWIP" datasource="#application.datasource#" >
		SELECT Contract_Number
		FROM Contract_Main
		WHERE Revision_of_Contract_Main_ID = <cfqueryparam value="#url.ContractMainID#" cfsqltype="cf_sql_numeric" >
		AND Contract_Number = <cfqueryparam value="#GetPrograms.Contract_Number#" cfsqltype="cf_sql_varchar" >
		AND Deleted = 0
		AND Approved = 0
		AND Contract_Status_Type_IDX in (1,2)
	</cfquery>

	<table class="datagrid">
	  <thead>
	  <th></th>
	    <th class="header">Program Number</th>
	    <th class="header">Version</th>
	    <th class="header">Start Date</th>
		<th class="header">End Date</th>
	    <th class="header">Eff Start Date</th>
	    <th class="header">Eff End Date</th>
		<th class="header">Status</th>
	  </thead>
	  <tbody>
		<cfoutput query="GetPrograms">
		<cfif url.ContractMainID EQ contract_main_id>
			<cfset CssStyle="highlighter">
		<cfelse>
			<cfset CssStyle="">
		</cfif>
		<cfsavecontent variable="info">
			<cfif check4Parent.recordcount>
				<cfif currentRow EQ 1>
					Effective Dates for this version will be updated.<BR>
				<cfelse>
					We will update this version to have dates from child version and flag this version deleted.<BR>
					<cfif check4RFAWIP.recordcount>
						This version has #check4RFAWIP.recordcount# WIP/RFA program(s) which will get deleted.<BR>
					</cfif>
				</cfif>
			<cfelse>
				<cfif currentRow EQ 1>
					<cfif (len(check4Parent.deleted) AND check4Parent.deleted) OR GetPrograms.Deleted[1]>We will undelete this version.<BR></cfif>
					Effective Dates for this version will be updated.<BR>
				<cfelse>
					We will flag this version deleted.<BR>
					<cfif check4RFAWIP.recordcount>
						This version has #check4RFAWIP.recordcount# WIP/RFA program(s) which will get deleted.<BR>
					</cfif>
				</cfif>
			</cfif>
		</cfsavecontent>
		<tr class="#CssStyle#" data-child-value="#info#"">
			<td class="details-control"></td>
			<td>#Contract_Number#</td>
			<td>#revision_version#</td>
			<td>#dateformat(Contract_Start_Date,'mm/dd/yyyy')#</td>
			<td>#dateformat(Contract_End_Date,'mm/dd/yyyy')#</td>
			<td>#dateformat(Effective_Start_Date,'mm/dd/yyyy')#</td>
			<td>#dateformat(Effective_End_Date,'mm/dd/yyyy')#</td>
			<td>#Contract_Status_Type_Desc#</td>
		</tr>
		</cfoutput>
	  </tbody>
	</table>

	<cfoutput>
		<div align="center" style="padding-top:5px;">
			<a onclick="deleteProgram();">#application.util.string.actionLinkFormat('Continue')#</a>
			<a onclick="">#application.util.string.actionLinkFormat('Close')#</a>
		</div>

		<cfif  GetPrograms.recordcount GT 1>
		<cfset parentRow = GetPrograms.recordcount - 1>
		<cfelse>
			<cfset parentRow = GetPrograms.recordcount >
	</cfif>

		<form name="deletePrograms" action="delete_program_versions.cfm" method="post" id="deletePrograms">
			<input type="hidden" name="dContinue" value="0" id="dContinue">
			<input type="hidden" name="ContractNumber" value="#GetPrograms.Contract_Number#">
			<input type="hidden" name="parentContractMainID" value="#GetPrograms.Contract_main_id[parentRow]#">
			<input type="hidden" name="ContractMainID" value="#url.ContractMainID#">
		</form>
	</cfoutput>

	<cfinclude template="/Common_Files/jQuery.cfm">
	<cfinclude template="/Common_Files/dataTables2.cfm">
	<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
	var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .85) * windowHeight;
	oTable = $('.datagrid').DataTable( {
	      "bServerSide": false
	    , "bProcessing": false
	    , "bSortClasses": false
		, "bAutoWidth": false
	    , "iDisplayLength": 2000
		<cfif GetPrograms.recordcount GT 20>	, "sScrollY": sScrollY</cfif>
	    , "sDom": "rt"
	    , "aaSorting": []
	    , "aoColumns": [
								{"bSortable":false}
							,	{"bSortable":true}
		                    ,	{"bSortable":true}
		                    ,	{"bSortable":true}
		                    ,	{"bSortable":true}
		                    ,	{"bSortable":true}
		                    ,	{"bSortable":true}
							,	{"bSortable":true}
		                 ]
	} );
	$('.dataTables_wrapper').css('min-height', '30px');

      $('.datagrid').on('click', 'td.details-control', function () {
          var tr = $(this).closest('tr');
          var row = oTable.row(tr);

          if (row.child.isShown()) {
              // This row is already open - close it
              row.child.hide();
              tr.removeClass('shown');
          } else {
              // Open this row
              row.child(format(tr.data('child-value'))).show();
              tr.addClass('shown');
          }
      });

  function format(value) {
      return '<div style="color:red;font-size:12px;">' + value + '</div>';
  }

	$(".datagrid").DataTable().rows().every( function () {
	    var tr = $(this.node());
	    this.child(format(tr.data('child-value'))).show();
	    tr.addClass('shown');
	});

	function deleteProgram(){
		document.getElementById('dContinue').value="1";
		document.getElementById('deletePrograms').submit();
	}
</script>
</cfif>