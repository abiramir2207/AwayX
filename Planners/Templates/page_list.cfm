<!----------------------------------------------------------------------------------
Name         :	AwayX/PlgetTemplateStatus =anners/Templates/page_list.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/01/2016
Created By   : 	KAL
Description  : 	Planner Templates
---------------------------------------------------------------------------------->
<cf_layout-bare>
<cfsavecontent variable="head_content">
	<cf_include file_to_include="/common_files/tabnav.css,/common_files/dhx_message.cfm,/styles/css-loader.css,/common_files/dataTable2.css">
	<style>
		a.action {
			display: inline-block;
			width: 48%;
		}
	</style>
</cfsavecontent>
<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
<cfhtmlhead text="#application.util.string.compress( head_content )#">

<cfscript>
	objPlannerTemplateManager = CreateObject("component", "mvc.Models.Planner.PlannerTemplateManager");

	param name="url.iTab"			default="Active";
	param name="FORM.display_type" 	default="Active";
	param name="form.display" 		default="active";
	param name="form.command" 		default="";

	if (form.command eq "deactivate") {
		objPlannerTemplateManager.updateTemplateStatus( form.templates, 0 );
	}
	else if (form.command eq "activate") {
		objPlannerTemplateManager.updateTemplateStatus( form.templates, 1 );
	}

	form.display         = "";
	getTemplateStatus    = (URL.itab EQ "inActive")
		 					? 0
		 					: 1;
	qGetPlannerTemplates = objPlannerTemplateManager.getPlannerTemplates(status=getTemplateStatus);
	pagetitle            = "#Application.PlannerLabel# TEMPLATES: Create & Edit";
</cfscript>

<cfinclude template="/settings/settings_title.cfm">

<div class="nav">
    <ul class="nav">
        <li <cfif URL.itab EQ "Active">class="active"</cfif>>
            <a class="topnav" href="page_list.cfm?itab=active">active</a>
        </li>
        <li <cfif URL.itab EQ "inActive">class="active"</cfif>>
            <a class="topnav" href="page_list.cfm?itab=inactive">inactive</a>
        </li>
    </ul>
</div>
<div style="clear:both"></div>

<form method="post" name="page_list">
	<cfoutput>
	<input name="display" type="hidden" value="#form.display#" />
	<input name="command" type="hidden" value="#form.command#" />
	<input name="templates" type="hidden">

	<div style="margin-bottom:10px">
	    <cfif URL.itab EQ "inActive">
			<a id="activate">#application.util.string.LinkFormat("activate selected")#</a>
		<cfelse>
			<a id="deactivate">#application.util.string.LinkFormat("deactivate selected")#</a>
	    </cfif>
		<a href="index.cfm?id=-1" style="margin-left:40px;">#application.util.string.LinkFormat("create new #Application.PlannerLabel# template")#</a>
	</div>
	</cfoutput>

	<div style="width:80%">
		<table class="material dataTable hover row-border">
			<thead>
				<tr>
					<th>&nbsp;</th>
					<th><cfoutput>#Application.PlannerLabel#</cfoutput> Type</th>
					<th>Description</th>
					<th>Date Range</th>
					<th>Action</th>
				</tr>
			</thead>
			<tbody>
			<cfoutput query="qGetPlannerTemplates">
			<tr>
				<td width="15">
					<input type="checkbox" name="CID" value="#Planner_Template_ID#" class="cb">
				</td>
				<td>
					#Planner_Type#
				</td>
				<td>
					#Planner_Description#
				</td>
				<td>
	                #application.util.datetime.DateSpanFormat( Planner_Start_Date, Planner_End_Date )#
				</td>
				<td>
					<a href="index.cfm?id=#Planner_Template_ID#" class="action">
						#application.util.string.LinkFormat("edit")#
					</a>
					<a href="index.cfm?id=#Planner_Template_ID#&copy=1" class="action">
						#application.util.string.LinkFormat("copy")#
					</a>
				</td>
			</tr>
			</cfoutput>
			</tbody>
		</table>
	</div>
</form>

<script>
$("#deactivate").click(function(){
	var templates = [];
	$("input.cb:checked").each(function(){
		templates.push( $(this).val() );
	});
	if (templates.length == "") {
		dhx_alert("Please select a <cfoutput>#Application.PlannerLabel#</cfoutput> template to deactivate.");
	}
	else {
		dhtmlx.confirm({
		        type:"confirm",
		        text: "Are you sure you want to deactivate?",
		        ok: "DEACTIVATE",
		        callback: function( ok_to_deactivate ){
		            if ( ok_to_deactivate ) {
						show_loader();
						$("input[name=command]").val( "deactivate" );
						$("input[name=templates]").val( templates.join() );
						$("form[name=page_list]").submit();
		            };
		        }
		    });
	}
});

$("#activate").click(function(){
	var templates = [];
	$("input.cb:checked").each(function(){
		templates.push( $(this).val() );
	});
	if (templates.length == 0) {
		dhx_alert("Please select a <cfoutput>#Application.PlannerLabel#</cfoutput> template to activate.");
	}
	else {
			show_loader();
			$("input[name=command]").val( "activate" );
			$("input[name=templates]").val( templates.join() );
			$("form[name=page_list]").submit();
	}
});
</script>
</cf_layout-bare>
