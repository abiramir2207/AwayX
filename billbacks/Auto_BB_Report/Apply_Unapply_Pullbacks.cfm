<!---
	Copyright (c)2013 Blacksmith Applications, Inc.
	Filename:		C:\Work\base\AwayX\billbacks\Auto_BB_Report\Apply_Unapply_Pullbacks.cfm
	Created:		9/11/2013
	Developer:		drachala
	Description:	<brief description of what the file is used for>
	Usage:			<templates that depend on this file>
	Tip:			<gotchas>
--->
<cfparam name="url.type" 	default="0" >
<cfparam name="url.BB_ID" 	default=" " >

<cfset filename = "Pullbacks_"&#replace(request.AccessStructure.user_id,'-','_','ALL')#&".txt">
<cfset filepath = "#Application.Doc_Path#\Temp_Files\Billback\AutoPayPullbacks\#filename#">
<cfif FileExists("#filepath#")>
<cffile action = "delete"   file = "#filepath#">
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfinclude template="/get_access_profile.cfm">

<CFQUERY DATASOURCE="#application.datasource#" NAME="qGetBBDetails">
    SELECT  BB_Code
    FROM    Billback
    WHERE   Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.BB_ID#">
</CFQUERY>

<cfif url.type>
	<cfset PageTitle = "un-apply #appsettings.getPullbackLabelLower()# for billback #qGetBBDetails.BB_Code#">
<cfelse>
	<cfset PageTitle = "apply #appsettings.getPullbackLabelLower()# for billback #qGetBBDetails.BB_Code#">
</cfif>
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<table style="border:none;width:75%;float:right;">
	<tr>
		<td align="right"><b><cfif url.type>Applied<cfelse>Available</cfif> Recapture Amount&nbsp;:&nbsp;</b></td>
		<td class="Total">$0.00</td>
		<td align="right"><b>Remaining Recapture Amount&nbsp;:&nbsp;</b></td>
		<td class="Remaining">$0.00</td>
		<td align="right"><b>Selected Amount&nbsp;:&nbsp;</b></td>
		<td class="Applied">$0.00</td>
	</tr>
</table>

<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<form method="post" name="applyunapplypullbacksaction" id="applyunapplypullbacksaction" style="display:inline">
<table class="datagrid">
				<col width="1%">
 				<col width="20%">
				<col width="10%">
				<col width="10%">
 				<col width="5%">
 				<col width="5%">
				<col width="20%">
				<col width="15%">
				<col width="15%">
  <thead>
	<th style="width:25px;"><input type="checkbox" name="pullback_all_billback_ids" id="pullback_all_billback_ids" value="1" onClick="javaScript: selectAll(this, 'pullback_billback_growth_ids');applyamount($('.Total').text().replace('$',''),this,1);selectpullback(0,this,1);"></th>
	<th class="header" nowrap><b>Operator&nbsp;&nbsp;&nbsp;&nbsp;</b></th>
	<th class="header" nowrap><b>Dollars&nbsp;&nbsp;&nbsp;&nbsp;</b></th>
	<th class="header" nowrap><b>Cases&nbsp;&nbsp;&nbsp;&nbsp;</b></th>
	<th class="header" nowrap><b>BB Start&nbsp;&nbsp;&nbsp;&nbsp;</b></th>
	<th class="header" nowrap><b>BB End&nbsp;&nbsp;&nbsp;&nbsp;</b></th>
	<th class="header" nowrap><b>Program Title&nbsp;&nbsp;&nbsp;&nbsp;<br>Number&nbsp;&nbsp;&nbsp;&nbsp;</b></th>
	<th class="header" nowrap><b>Distributor&nbsp;&nbsp;&nbsp;&nbsp;</b></th>
	<th class="header" nowrap><b>Billback ID&nbsp;&nbsp;&nbsp;&nbsp;<br>Reference&nbsp;&nbsp;&nbsp;&nbsp;</b></th>
  </thead>

 <tbody></tbody>

</table>
</form>


<cfoutput>
<div style="width:100%;">
		<cfif Get_Profile_Settings.BB_UnApply_Pullback>
				<div style="width:50%;float:left;text-align:right;color:blue;font-weight:bold;cursor:pointer;display:block;" onclick="update()" id="submit">#application.util.string.actionLinkFormat(PageTitle)#</div>
				<div style="width:50%;float:left;text-align:right;color:grey;font-weight:bold;cursor:none;display:none;" id="inactive">#application.util.string.actionLinkFormat('Updating....please wait')#</div>
				<div style="width:50%;float:left;text-align:right;color:grey;font-weight:bold;cursor:none;display:none;" id="Checkboxselection">#application.util.string.actionLinkFormat('Please wait...')#</div>
		<cfelse>
				<div style="border:none;color:grey;font-weight:bold;cursor:none;" >#application.util.string.actionLinkFormat(PageTitle)#</div>
		</cfif>
		<div style="width:49%;float:right;color:blue;font-weight:bold;cursor:pointer;display:block;" onclick="window.close();">	#application.util.string.actionLinkFormat('Close')#</div>
</div>
</cfoutput>


<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script>
oTable = $('.datagrid').dataTable( {
  				 "bServerSide": true
			    , "bProcessing": true
			    , "bSortClasses": false
				, "bAutoWidth": false
			    , "iDisplayLength": 20
				 , "oLanguage": {"sSearch": "<b>Search:</b>"}
				 //,"sServerMethod": "POST"
			    , "sAjaxSource": "ajax/Apply_UnApply_Pullbacks_Query.cfm?<cfoutput>BB_ID=#url.BB_ID#&type=#url.type#</cfoutput>&random="+Math.random().toString(36).slice(2)
				,"fnServerData": function ( sSource, aoData, fnCallback )
															{
																$.getJSON( sSource, aoData, function (json) {
																						$('.Total').text(json.STOTAL).prepend("$");
																						var total = $('.Total').text().replace('$','');
																						var applied = $('.Applied').text().replace('$','');
																						if (json.STOTALTYPE == 1) {
																							var total = total.replace('-', '')
																							var remaining = Number(applied) - Number(total);
																						}
																						else{
																							var remaining = Number(total) - Number(applied)
																						}
																						$('.Remaining').text(remaining).prepend( "$" );
																						fnCallback(json)
																				} );
															}
			    , "sDom": "fprti"
			    , "aaSorting": [[ 1, "asc" ]]
			    , "aoColumns": [
										{"bSearchable": false,  "bSortable":false}
				                    ,	{"bSearchable": false, 	"bSortable":true}
				                    ,	{"bSearchable": false, 	"bSortable":true, "sType": "currency" }
									,	{"bSearchable": false,  "bSortable":true, "sType": "numeric"}
				                    ,	{"bSearchable": false, 	"bSortable":true}
				                    ,	{"bSearchable": false, 	"bSortable":true}
									,	{"bSearchable": true,  "bSortable":true}
				                    ,	{"bSearchable": true, 	"bSortable":true}
				                    ,	{"bSearchable": true, 	"bSortable":true}
				                 ]

} );
function selectpullback(cid,id,all){
		if (id.checked) {
			var sStatus = 1
		}
		else{
			var sStatus = 0
			document.getElementById("pullback_all_billback_ids").checked=false
		}
		var sAll = all;
		var sData = cid;
				$.ajax({
							type: "POST",
							url: "ajax/savecheckboxvalues.cfm",
							<cfoutput>data:{CheckboxValue: sData, status:sStatus, all:sAll, BB_ID:'#url.bb_id#', type:'#url.type#'}  </cfoutput>,
							success:function(){
															document.getElementById("submit").style.display = 'block';
															document.getElementById("Checkboxselection").style.display = 'none';
															$('input[type=checkbox]').removeAttr('disabled');
														  },
							error: function(){
														alert("Failed")
													}

							});
	}
function selectAll(thisObj, objToChk)
	{
			document.getElementById("submit").style.display = 'none';
			document.getElementById("Checkboxselection").style.display = 'block';
			$('input[type=checkbox]').attr('disabled','true');

		var chObjs = eval("document.all." + objToChk);
		var bCheck = thisObj.checked;
		var i;
		if(chObjs)
		{
			if(chObjs.length)
			{
				for(i=0;i<chObjs.length;i++)
				{
					chObjs[i].checked = bCheck;
				}
			}
			else
			{
				chObjs.checked = bCheck;
			}
		}
	}
function PopupProgram(cid){
				window.open('/Scorecard/program_display.cfm?CID='+cid,'ProgramSummary','width=800,height=650,scrollbars=1')
				}
function PopupOperators(CMID){
				window.open('Operators_display.cfm?cmid='+CMID,'Operators','width=300,height=400,scrollbars=1')
}
function update(){
	var error = 0;
	var massapply = document.applyunapplypullbacksaction.pullback_all_billback_ids.checked;
	var checkboxs = $("input:checkbox:checked").length;

	if((( !massapply ) && (checkboxs > 0)) || (massapply))
	{
		 error = 1;
	}

 	if (error == 1)
		{
			oTable.fnFilter("");
			document.getElementById("submit").style.display = 'none';
			document.getElementById("inactive").style.display = 'block';
			$.ajax({
			type: "POST",
			url: "Apply_Unapply_Pullbacks_Action.cfm",
			<cfoutput>data:{unapplypullbacks:'#url.type#',BB_ID:'#url.bb_id#'}  </cfoutput>,
			success:function(){
											opener.location.reload(true);
											self.close();
										  },
			error: function(){
										alert("Something went wrong...")
									}

			});
		}
	else{
		alert("Please select atleast one billback to apply recapture")
	}
}
function applyamount(amt, ths, massapply){
				var CRA = $('.Remaining').text().replace('$', '');

				if (massapply)
				{
					$('.Remaining').text(amt).prepend('$');
					$('.Applied').text(0).prepend('$');
						if (ths.checked) {
									$('.Applied').text(amt).prepend('$');
									$('.Remaining').text(0).prepend('$');
							}
				}
				if((massapply == 0) && (ths.checked)){
						var ncra =  (Number(CRA) - Number(amt)).toFixed(2) ;
											$('.Remaining').text(ncra).prepend('$');
						var ara = $('.Applied').text().replace('$','');
						var nara = (Number(ara) + Number(amt)).toFixed(2);
											$('.Applied').text(nara).prepend('$');
				}
			 	if((massapply == 0) && (! ths.checked)){
					var ncra = (Number(CRA) + Number(amt)).toFixed(2);
										$('.Remaining').text(ncra).prepend('$');
					var ara = $('.Applied').text().replace('$','');
					var nara = (Number(ara) - Number(amt)).toFixed(2);
										$('.Applied').text(nara).prepend('$');
			}
	}
</script>