<cfparam name="form.Contract_Main_ID" default="0">
<cfparam name="url.Contract_Main_ID" default="#form.Contract_Main_ID#">
<cfparam name="form.Perf_Req_Label" default="">
<cfparam name="url.Perf_Req_Label" default="#form.Perf_Req_Label#">
<cfparam name="form.formsubmit" default="0">

<CFSET URL.PageTitle="#url.Perf_Req_Label#">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<cfquery name="PerformanceRequirementLabels" datasource="#application.datasource#">
		SELECT DISTINCT PPR.Requirement_Name, PPR.Program_Perf_Req_ID, PPRL.Perf_Req_Label_ID, OPPM.checked
		,PCPO.MinPerfRequirementsOn,PCPO.MinPerfRequirements,PCPO.MaxPerfRequirementsOn,PCPO.MaxPerfRequirements
		FROM 	Program_Perf_Mapping PPM
		INNER JOIN Program_Perf_Req PPR
		ON PPR.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
		INNER Join Program_Perf_Req_Labels PPRL
		ON PPRL.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
		AND PPRL.Perf_Req_Label_ID = PPM.Program_Perf_Req_Checked
		INNER JOIN program_control_panel_options PCPO
		ON PCPO.ProgramControl_Panel_Options_ID = PPM.Template_ID	
		LEFT JOIN One_Program_Perf_Mapping OPPM
		ON OPPM.Program_Perf_Req_ID =  PPM.Program_Perf_Req_ID
		AND OPPM.Program_Perf_Req_Label = '#url.Perf_Req_Label#'
		AND OPPM.Contract_Main_ID = #url.Contract_Main_ID#
		WHERE PPM.Template_ID = '#url.ProgramType_ID#'
		AND PPR.List_Features <> 0
		AND PPRL.Perf_Req_Label = '#url.Perf_Req_Label#'
	</cfquery>

	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
		<cfif PerformanceRequirementLabels.MaxPerfRequirementsOn OR PerformanceRequirementLabels.MinPerfRequirementsOn>
			<cfoutput>
				<div style="padding-bottom:  5px;font-size: 12px;color: red">
				You must select 
				<cfif PerformanceRequirementLabels.MinPerfRequirementsOn>minimum #PerformanceRequirementLabels.MinPerfRequirements#</cfif>
				<cfif PerformanceRequirementLabels.MaxPerfRequirementsOn> <cfif PerformanceRequirementLabels.MinPerfRequirementsOn> or </cfif>maximum #PerformanceRequirementLabels.MaxPerfRequirements#</cfif>
				performance requirements.
				</div>	
			</cfoutput>
		</cfif>
	<form name="PR" action="Performance_Requirements.cfm" method="post" id="PR">
		<table id="datagrid" class="datagrid" >
		<thead>
			<tr>
			<th>&nbsp;</th>
			<th>Performance Requirement</th>
			</tr>
		</thead>
		<tbody>	
		<cfoutput query="PerformanceRequirementLabels">
		<tr>
			<td>
				<input type="checkbox" name="Requirement_ID" value="#Program_Perf_Req_ID#" <cfif len(PerformanceRequirementLabels.checked) and PerformanceRequirementLabels.checked>Checked</cfif>>
			</td>
			<td>#replace(Requirement_Name,'&',' and ','all')#</td>
		</tr>		
		</cfoutput>
		</tbody>
		</table>
		<div align="center"><br>
		<cfoutput>
			<input type="hidden" name="formsubmit" value="1">
			<input type="hidden" name="Contract_Main_ID" value="#url.Contract_Main_ID#">
			<input type="hidden" name="Perf_Req_Label" value="#url.Perf_Req_Label#">
			<input type="hidden" name="Perf_Req_Label_ID" value="#PerformanceRequirementLabels.Perf_Req_Label_ID#">
			<input type="hidden" name="Perf_Req_ID" value="#valuelist(PerformanceRequirementLabels.Program_Perf_Req_ID)#">
			<a onclick="validate();">#application.util.string.actionLinkFormat2('import')#</a>
		</cfoutput>
		</div>
</form>
	<cfif PerformanceRequirementLabels.MaxPerfRequirements EQ '*'>
		<cfset PRMaxPerfRequirements = 9999>
	<cfelse>
		<cfset PRMaxPerfRequirements = PerformanceRequirementLabels.MaxPerfRequirements>
	</cfif>	
<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">	
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script>
	var windowHeight = $(window).height(), sScrollY =  ( windowHeight > 200 ? .70 : .55) * windowHeight;
	oTable = $('.datagrid').dataTable( {
														"bServerSide": false
													, "bProcessing": false
													, "bSortClasses": false
													, "bAutoWidth": false
													, "bPaginate": false
													, "oLanguage": {"sSearch": "<b>Search:</b>"} 
													, "sDom": "frt"
													, "sScrollY": sScrollY 
													, "aaSorting": []
													, "aoColumns": [  		
																												{"bSearchable": false,  	"bSortable":false}
																											,	{"bSearchable": true, 	"bSortable":true}
																											]
		} ).fnSetFilteringDelay();
		
	function validate(){
		var minCheckbox = <cfoutput>#PerformanceRequirementLabels.MinPerfRequirements#</cfoutput>;		
		var maxCheckbox = <cfoutput>#PRMaxPerfRequirements#</cfoutput>;
		var numberOfChecked  =$('input:checkbox:checked').length;
		var errormsg = '';
		
		if(numberOfChecked < minCheckbox){
				errormsg = errormsg.concat('Please select minimum '+minCheckbox+' performance requirements.' );
		}
		if(numberOfChecked >maxCheckbox){
				errormsg = errormsg.concat('Please select maximum '+maxCheckbox+' performance requirements.' );
		}
		if(errormsg.length){
			alert(errormsg);
			return;
		}
		else{		
			var cbResults = '';
			var form = document.getElementById('PR');
			for (var i = 0; i < form.elements.length; i++ ) {
				if (form.elements[i].type == 'checkbox') {
					if (form.elements[i].checked == true) {
						cbResults+=form.elements[i].value+ ',';
					}
				}
			}			
				cbResults = cbResults.replace(/^\s+|\s+$/g,'')
				cbResults = cbResults.slice(0, -1);
				 <cfoutput>
				window.opener.document.getElementById('#url.Perf_Req_Label#').value = cbResults;
					</cfoutput>
				window.close();
		}
	}
</script>