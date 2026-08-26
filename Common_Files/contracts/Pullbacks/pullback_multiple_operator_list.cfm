<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\Pullbacks\pullback_multiple_operator_list.cfm
      Date:     2018 May
      Author:   Milan Mushran
      Purpose:  Select operator planning groups for recapture(pullbacks)
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>operator list for recapture</TITLE>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
	<style>
		.links{
			float: right;
			text-align:left;
		}
		</style>
<cfoutput>
	<script>
		function fnViewMicroMembers(PGType,IDtoView){
			var sURL = "/settings/planning_Groups/dspViewMicroMembers.cfm?Group_ID=" + IDtoView + "&PGType=" + PGType + "&hideExport=1";
			NewWindow(sURL, 'View_Members', 600, 800, 'yes', 'yes');
		}

		function backToSummaryPage(){
			window.location.href = "/common_files/contracts/contract_edit_menu.cfm?CID=#URL.CID#";
		}
	</script>
</cfoutput>
</HEAD>

<cfparam name="form.saveData" default="0">
<cfparam name="form.saveAndContinueData" default="0">
<cfparam name="form.PGOperatorCategoryIDList" default="">
<cfparam name="URL.FromRFAPage" default="0">
<cfparam name="URL.FromApprovalPage" default="0">
<cfparam name="URL.DisAllowAccessBasedOnLockStatus" default="0">
<!--- Variables passedForm, dupAction, duplicateprogram are needed so that duplicate check message doesn't show up again  --->
<cfparam name="form.passedForm" default="">
<cfparam name="URL.passedForm" default="#form.passedForm#">
<cfparam name="form.dupAction" default="">
<cfparam name="URL.dupAction" default="#form.dupAction#">
<cfparam name="form.duplicateprogram" default="">
<cfparam name="URL.duplicateprogram" default="#form.duplicateprogram#">
<cfparam name="form.TemplateFirstParentID" default="">

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">

<cfquery name="getContract" datasource="#application.datasource#">
	SELECT 	CM.Contract_Number, CM.Approved,
			PCPO.Market_Price,
			PCPO.Item_Fixed_Rebate_Paid_To_Dup_Message,
			CMAD.Market_Price_Approved,
			PCPO.Disable_Duplicate_Check_For_Revisions
	FROM 	Contract_Main CM
	INNER JOIN Contract_Main_Aux_Data CMAD
	ON		CMAD.Contract_Main_ID = CM.Contract_Main_ID
	INNER JOIN dbo.Program_Control_Panel_Options PCPO
	ON		CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
	WHERE 	CM.Contract_Main_ID = <cfqueryparam value="#cryp.value#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<cfset EditMode = 1>

<cfif getContract.Approved eq 1 OR URL.DisAllowAccessBasedOnLockStatus eq 1>
	<cfset EditMode = 0>
</cfif>

<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">

<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />

<!--- If the user clicks pn "save" or "save and continue" --->
<cfif form.saveData eq 1 or form.saveAndContinueData eq 1>
	<cfset PullbackManager.saveRecaptureOperatorPGlist(getContract.Contract_Number,cryp.value,form.PGOperatorCategoryIDList,request.AccessStructure.User_ID)>
	<cfset PullbackManager.saveRecaptureTemplatelist(getContract.Contract_Number,cryp.value,form.TemplateFirstParentID,request.AccessStructure.User_ID)>

	<cfset qGetRacapturePGOperatorExists = PullbackManager.getRecaptureOperatorPGlistExists(getContract.Contract_Number)>

	<!--- If the user clicks pn "save and continue" while going through the RFA/Approval process --->
	<cfif form.saveAndContinueData eq 1 AND qGetRacapturePGOperatorExists eq 1>

		<cfscript>

			nextPage = "";

			if(URL.FromRFAPage == 1){
				nextPage = "/common_files/contracts/contract_approve_broker_action.cfm?CID=#URL.CID#&passedForm=#URL.passedForm#&dupAction=#URL.dupAction#&duplicateprogram=#URL.duplicateprogram#";
			}

			if(URL.FromApprovalPage == 1){

				//default redirect
				nextPage = "/Common_Files/Contracts/contract_profit_analysis.cfm?CID=#URL.CID#";

				//if it is an Market Price Program Aand MP is Not approved send to MP approval
				if(getContract.Market_Price && !getContract.Market_Price_Approved){
					nextPage = "/flex/program/MarketPriceFX.cfm?CID=#URL.CID#";
				}

				if(getContract.Item_Fixed_Rebate_Paid_To_Dup_Message == "2" || getContract.Item_Fixed_Rebate_Paid_To_Dup_Message == "3"){
					nextPage = "/Common_Files/Contracts/program_product_fixed_rebate_paid_to_dup_check.cfm?CID=#URL.CID#";
				}

			}
		</cfscript>

		<cflocation url="#nextPage#" addtoken="No" />

	</cfif>
	<cfif form.saveData eq 1>
		<script>
			window.opener.location.reload();
			window.close();
		</script>
	</cfif>
</cfif>

<cfset qGetRecaptureOperatorPGlist = PullbackManager.getRecaptureOperatorPGlist(getContract.Contract_Number,cryp.value,EditMode)>
<cfset qGetRecaptureTemplatelist		= PullbackManager.getRecaptureTemplatelist(getContract.Contract_Number,EditMode)>
<cfset qFirstTimeRecaptureTemplatelist = PullbackManager.FirstTimeRecaptureTemplatelist(getContract.Contract_Number,cryp.value,request.AccessStructure.User_ID)>

<BODY>
<cfoutput>

	<form name="frmOperator" style="margin-top:2px;" action="\common_files\contracts\Pullbacks\pullback_multiple_operator_list.cfm?CID=#URL.CID#&FromRFAPage=#URL.FromRFAPage#&FromApprovalPage=#URL.FromApprovalPage#&passedForm=#URL.passedForm#&dupAction=#URL.dupAction#&duplicateprogram=#URL.duplicateprogram#" method="post">
<div class="page_title1"> Operator Recapture List </div>

<table id="datagrid1" class="datagrid" style="table-layout:fixed;">
<cfif EditMode eq 1>
	<col width="3%">  <col width="20%"> <col width="32%"> <col width="35%"> <col width="10%">
<cfelse>
	<col width="20%"> <col width="35%"> <col width="35%"> <col width="10%">
</cfif>
  <thead>
  <tr>
	<cfif EditMode eq 1><th><input name="check_all1" class="checkall" type="checkbox"></th></cfif>
	<th>PG Code</th>
	<th>PG Name</th>
	<th>PG Type</th>
	<th>Members</th>
  </tr>
  </thead>
  <tbody>
	<cfloop query="qGetRecaptureOperatorPGlist">
	<tr>
		<cfif EditMode eq 1>
		<td><input type="checkbox" name="PGOperatorCategoryIDList" class="cb1" value="#PG_Operator_Category_ID#" <cfif qGetRecaptureOperatorPGlist.PG_Exists eq 1>checked</cfif> ONCLICK="if(!this.checked) document.all.check_all_pg.checked = false;"></td>
		</cfif>
		<td>#PG_Operator_Category_Code#</td>
		<td>#PG_Operator_Category_Name#</td>
		<td>#PG_Type_Name#</td>
		<td><img src="/images/on_the_program_item.gif" style="margin-left:20px" onclick="fnViewMicroMembers(3,'#PG_Operator_Category_ID#');"></td>
	</tr>
	</cfloop>
  </tbody>
</table>
<br><br><br>
<div class="page_title1"> Template Recapture List </div>

<table id="datagrid2" class="datagrid" style="table-layout:fixed;">
<cfif EditMode eq 1>
	<col width="3%"> <col width="50%"> <col width="47%">
<cfelse>
	<col width="50%"> <col width="50%">
</cfif>
  <thead>
  <tr>
		<cfif EditMode eq 1><th><input name="check_all2" class="checkall" type="checkbox"></th></cfif>
		<th>Program Type</th>
		<th>Generic Type</th>
  </tr>
  </thead>
  <tbody>
	<cfloop query="qGetRecaptureTemplatelist">
	<tr>
		<cfif EditMode eq 1>
		<td>
			<input type="checkbox" name="TemplateFirstParentID" class="cb2" value="#First_Parent_ID#" <cfif qGetRecaptureTemplatelist.Template_Exists EQ 1>checked</cfif> ONCLICK="if(!this.checked) document.all.check_all_templates.checked = false;">
		</td>
		</cfif>
		<td>#Created_Type#</td>
		<td>#Generic_Type#</td>
	</tr>
	</cfloop>
  </tbody>
</table>
<input type="hidden" name="saveAndContinueData" value="0">
<input type="hidden" name="saveData" value="0">
</form>
</cfoutput>

<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js"/>

<script type="text/javascript">
	<cfloop from="1" to="2" index="i">
		<cfoutput>
var jTable = $('table##datagrid#i#').dataTable({
	"aaSorting": []
	,"aoColumns": [	<cfif EditMode eq 1>{"bSortable":false,"bSearchable":false},</cfif>
					{"bSortable":true,"bSearchable":true}  /* PG Code */
					,{"bSortable":true,"bSearchable":true}	/* PG Name */
					<cfif i EQ 1>
					,{"bSortable":true,"bSearchable":true}	/* PG Type */
					,{"bSortable":false,"bSearchable":false} /* Members */
				</cfif>
				]
	,"bAutoWidth": false            /* false for quicker rendering */
	,"bDeferRender": true           /* true for quicker rendering */
	,"bProcessing": true            /* true to show processing message in sorting large table */
	,"bScrollCollapse": true        /* true to put the footer of the grid just below the records, when there are a few records only */
	,"bSortCellsTop": true          /* true to inform sorting on first row in thead */
	,"bSortClasses": false
	,"bStateSave": false
	/* For pagination use, add "p" in "sDom". We not have a "p" below, as we do not need pagination.
	"f" is for the "search" box .
	*/
	,"sDom": 'f<"links">tr'
	,"bPaginate": false
	, "sScrollY": Math.floor(jQuery(window).height()/2) - 150
	,"iDisplayLength": 1000<!--- There will never be this many records. 1000 is a lot. The goal is to display all the records on one page --->


}).fnSetFilteringDelay();


// "Check/Uncheck all" checkboxes
$('input[name=check_all#i#]').change(function() {
//alert('ff');
	$("input.cb#i#").attr("checked", (this.checked ? true : false));
});


</cfoutput>
</cfloop>

<cfoutput>
	$('div.links').html("&nbsp;&nbsp;<cfif EditMode eq 1><cfif URL.FromRFAPage eq 1><a href='Javascript:formSubmit(1)'>#application.util.string.actionLinkFormat2('save and continue')#</a>&nbsp;&nbsp;<a href='Javascript: backToSummaryPage()'>#application.util.string.actionLinkFormat2('cancel')#</a><cfelseif URL.FromApprovalPage eq 1><a href='Javascript:formSubmit(1)'>#application.util.string.actionLinkFormat2('save and continue')#</a>&nbsp;&nbsp;<a href='Javascript: window.close()'>#application.util.string.actionLinkFormat2('cancel')#</a><cfelse><a href='Javascript:formSubmit(2)'>#application.util.string.actionLinkFormat2('save and continue')#</a>&nbsp;&nbsp;<a href='Javascript: window.close()'>#application.util.string.actionLinkFormat2('close window')#</a></cfif><cfelse><a href='Javascript: window.close()'>#application.util.string.actionLinkFormat2('close window')#</a></cfif>");
</cfoutput>

function formSubmit(typ){
	if(typ == 1){
		document.all.saveAndContinueData.value = 1;
	}else{
		document.all.saveData.value = 1;
	}
	frmOperator.submit();
}
</script>

</BODY>
</HTML>
