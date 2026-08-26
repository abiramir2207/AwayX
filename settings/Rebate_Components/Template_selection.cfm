<!----
	Name: Template Selection
	Copyright (c) 2013 Blacksmith Applications, Inc.
	Description: Used in Rebate Components section to select templates for Alternate Recature Rates.
	Usage: Used in Rebate Components section to select templates for Alternate Recature Rates.
	Created : August 1st 2013
---->
<html>
<head>
<title>Alternate Rate Template Selection</title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
		#createnew-div { margin:0px 0; float:right; position:relative; top:5px; }
		#createnew-div select { margin:0 8px 0 0; }
		#datagrid2 { margin-top:-15px; }
		#generictypefilter { width:225px; }
		.datagrid TBODY TR.even { BACKGROUND-COLOR: #eeffee }
		.action { margin-right:3px; }
		.blank { margin-right:55px; }
	</style>
<script language="javascript" src="rebate_component.js"></script>
</head>
<body>
<cfparam name="url.compid" default="0">
<cfparam name="url.rate" default="0">
<cfparam name="url.templatesid" default="">
<cfparam name="url.fieldname" default="AlternateRateTemplateList">
<cfparam name="url.discountType" default="1">

		<cfscript>
				genericTypes = [ 'Distributor Trade/Shelter' ];
				labels = {};
				labels.select_generic_type = 'Select Generic Type';
				templateManager = CreateObject("component", "components.programs.template.TemplateManager").init();
				Lock_Release = templateManager.ReleaseLocks(request.AccessStructure.User_ID);
				appSettings = application.appSettingsGet;

				if ( appSettings.getDisplayProposal() )
					arrayAppend(genericTypes, 'Bid Request');

				if ( application.appSettingsGet.getBrokerage_Functionality_On() )
					arrayAppend(genericTypes, 'Brokerage');

				if ( application.appSettingsGet.getdirectpricingon() )
					arrayAppend(genericTypes, 'Direct Pricing');

				if ( appSettings.getDisplayDistributorOffInvoice() )
					arrayAppend(genericTypes, 'Distributor Off-Invoice');

				arrayAppend(genericTypes, 'Field Execution');
				arrayAppend(genericTypes, 'LSAutoPay');
				arrayAppend(genericTypes, 'Operator Direct or HQ Programs');
				arrayAppend(genericTypes, 'Operator-Deviated Pricing');

				if ( appSettings.getDisplayUSDANOI() )
					arrayAppend(genericTypes, 'USDA NOI');
		</cfscript>

	<cfquery name="selectedTemplates" datasource="#application.datasource#">
	<cfif url.fieldname EQ 'AlternateRateTemplateList'>
			SELECT  PCPO.First_Parent_ID,PCPO.Created_Type,PCPO.Program_Description
			FROM Alternate_Recapture_Rate_Template ARRT
			INNER JOIN Program_Control_Panel_Options PCPO
			ON PCPO.First_Parent_ID = ARRT.First_Parent_ID
			WHERE Program_Rebates_Component_Name_ID = #url.compid#
			AND Alternate_Recapture_Rate_Index = #url.rate#
			AND PCPO.IsDominant = 1
			AND PCPO.Deleted = 0
			ORDER BY PCPO.Created_Type
	<cfelse>
			SELECT  PCPO.First_Parent_ID,PCPO.Created_Type,PCPO.Program_Description
			FROM Program_Expected_Rate_Template_List PERT
			INNER JOIN Program_Control_Panel_Options PCPO
			ON PCPO.First_Parent_ID = PERT.First_Parent_ID
			WHERE PERT.Program_Component_Name_ID = #url.compid#
			<cfif url.discountType EQ 1>
			AND PERT.Discount_Type_ID = 1
			<cfelse>
			 AND PERT.Discount_Type_ID = 2
			</cfif>
			AND PCPO.IsDominant = 1
			AND PCPO.Deleted = 0
			ORDER BY PCPO.Created_Type
	</cfif>
	</cfquery>
<cfif selectedTemplates.recordcount>
<FIELDSET STYLE="padding:8px; width: 99%; border: 1px solid Blue;">
	<LEGEND>
	<TABLE>
		<TR>
			<TD  STYLE="FONT: BOLD 12PX SANS-SERIF; COLOR: RED;">Currently Selected Templates</TD>
			<TD CLASS="displayTR">
				<CF_button
										button_name		=	""
										button_caption	=	"show"
										button_action	=	"toggle('show')"
										button_type		=	"javascript_link"
										button_width	=	"75"
										button_color	=	"Navy"
										button_tip		=	""
										font_color		=	"White"
										font_size		=	"12"
										font_weight		=	"bold"
									>
			</TD>
			<TD CLASS="hiddenTR" STYLE="DISPLAY:NONE">
								<CF_button
										button_name		=	""
										button_caption	=	"hide"
										button_action	=	"toggle('hide')"
										button_type		=	"javascript_link"
										button_width	=	"75"
										button_color	=	"Navy"
										button_tip		=	""
										font_color		=	"White"
										font_size		=	"12"
										font_weight		=	"bold"
									>
			</TD>
		</TR>
	</TABLE>

	</LEGEND>
		<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="90%" BGCOLOR="white" class="templatesTable" style="display:none;">
							<TR>
					<cfoutput query="selectedTemplates" group="First_Parent_ID">
							<TD STYLE="width:380px;" NOWRAP BGCOLOR="eeeeee">#Created_Type#&nbsp;&nbsp;&nbsp;[&nbsp;#Program_Description#&nbsp;]</TD>
							<cfif (selectedTemplates.currentrow mod 2) IS 0></TR></cfif>
					</cfoutput>
		</table>
</FIELDSET>
</cfif>
<br />
<table class="datagrid" id="datagrid">
		<thead>
			<tr>
				<th width="2%" valign="center"><INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this, 'templates');"></th>
				<cfoutput>
				<th class="columnfilter" align="left">Generic Type<br/><select id="generictypefilter"><option val=''> </option><cfloop array="#genericTypes#" index="genericType"><option>#genericType#</option></cfloop></th>
				</cfoutput>
				<th align="left">Program Type</th>
				<th align="left">Description</th>
			</tr>
		</thead>
		<tbody>
			<cfloop array="#genericTypes#" index="genericType">
			<cfset qTemplates = templateManager.getTemplatesByGenericType(genericType, request.AccessStructure.Company_Main_ID) />
			<cfoutput query="qTemplates" group="First_Parent_ID">

				<cfif ListFind(url.templatesid, First_Parent_ID)>
						<cfset Checked = "Checked">
				<cfelse>
						<cfset Checked ="">
				</cfif>

			<cfif qTemplates.IS_Locked EQ 1> <cfset Locker = templateManager.GetLockerInfo(qTemplates.Locked_By) /> </cfif>
				<tr>
					<td width="2%" valign="center"><input type="checkbox" name="templates" value="#First_Parent_ID#" #Checked#></td>
					<td>#genericType#</td>
					<td>#qTemplates.Created_Type#</td>
					<td>#qTemplates.Program_Description#</td>
				</tr>
			</cfoutput>
			</cfloop>
		</tbody>
</table>
<br>
<cfoutput>
	<div align="center">
					<CF_button
										button_name		=	""
										button_caption	=	"import templates"
										button_action	=	"templateselection(#url.rate#);"
										button_type		=	"javascript_link"
										button_width	=	"75"
										button_color	=	"Navy"
										button_tip		=	""
										font_color		=	"White"
										font_size		=	"12"
										font_weight		=	"bold"
									>
	</div>
</cfoutput>


<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script>
var oTable = $('table#datagrid').dataTable({
     "bAutoWidth": false
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"aoColumns": [
    				  {"sWidth": "2%", "bSortable":false, "bSearchable":false }
    				, {"sWidth": "20%", "bSortable":false, "bSearchable":true }
                    , {"sWidth": "34%", "bSortable":true, "bSearchable":true}
                    , {"sWidth": "44%", "bSortable":true, "bSearchable":true}]
  }).fnSetFilteringDelay();
$('table#datagrid tr').hover (
    function() { $(this).addClass("over"); },
    function() { $(this).removeClass("over"); }
);
$("thead th").each( function ( i ) {
	if ( $(this).hasClass("columnfilter") ) {
      // build select tag dynamically if "addselect" class is found
		  if ( $(this).hasClass("addselect") ) {
				 $(this).html( $(this).html() + '<br/>' + fnCreateSelect( oTable.fnGetColumnData(i) ) );
}
  $('select', this).change( function () {
      oTable.fnFilter( $(this).val(), i );
      if ( $(this).val() )
      	$('#newgenerictype').val( $(this).val() );
      else
      	$('#newgenerictype').val( <cfoutput>'#labels.select_generic_type#'</cfoutput> );
      } );
  }
} );
function templateselection(rate){
	var sData = $('input', oTable.fnGetNodes()).serialize();
	if(rate){
		var mainObj = eval("window.opener.document.all.<cfoutput>#url.fieldname#</cfoutput>" + rate);
	}else{
		var mainObj = eval("window.opener.document.all.<cfoutput>#url.fieldname#</cfoutput>");
	}
			if(mainObj)
			{
				mainObj.value=sData.replace('templates=', "").replace(/\&templates=/g, ",");
			}
			window.close();
}
function toggle(itype){
		if (itype == 'show') {
					$('.hiddenTR').show();
					$('.displayTR').hide();
					$('.templatesTable').show();
		}
		if (itype == 'hide') {
					$('.hiddenTR').hide();
					$('.displayTR').show();
					$('.templatesTable').hide();
		}
 }
</script>
</body>
</html>
