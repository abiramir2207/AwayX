<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\listBudget.cfm
      Date:     June 19, 2011
      Author:   Chris Nguyen
      Purpose:  List budgets
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="url.byClassIDs" default="">    <!--- 36147 --->


<cfinvoke component="components.programs.business_segment.BusinessSegmentManager"
    		     method="isEnabledForBudget"
     returnVariable="busSegMgr.isEnabled">
</cfinvoke>

<cfscript>
  vars = StructNew();
   appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
</cfscript>

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/impromptu.css">
<link rel="stylesheet" href="/styles/jQueryUI_18/jquery.multiselect.css" type="text/css" />
<link rel="stylesheet" href="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css" type="text/css" />
<style type="text/css" media=screen>
#mainfieldset { padding:1%; border: 1px solid blue; width:98%;}
#vfclass { font-size:1em; font-weight:bold; margin-right:11px; letter-spacing:0.85px; }
#actionclass { font-size:1em; font-weight:bold; margin-right:11px; letter-spacing:0.85px; }
#filter130:hover  { text-decoration:underline; cursor:pointer; }
#actions { margin:10px 0 0 0; }
#masscopy { float:right; }
#masscopy a { margin-left:15px; }
.action { font-size: 7pt; font-weight:bold; margin:0 3px 0 3px; }
.mid { text-align: center !important; }
.dollar { text-align:right; }
.activate { background:url('/images/bluechrome.gif') repeat-x; }
.bal { font-weight:bold; }
.pos { color:black; }
.neg { color:red; }
.rpt { font-weight:bold; }
th { text-align: left; }
.export{margin-left:450px;}
</style>
</cfsavecontent>

<cfhtmlhead text="#vars.htmlHead#">
<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.getClassCodesOn()>
	<cfquery name="qBusinessSegmentCount" datasource="#application.datasource#">
		SELECT Class_Code.Business_Segment_ID
	  	FROM User_Class_Code
		INNER JOIN Class_Code ON Class_Code.Class_Code_ID = User_Class_Code.Class_Code_ID
		WHERE User_Id = '#request.AccessStructure.User_ID#'
    	AND User_Class_Code.Deleted = 0
	</cfquery>
<cfelse>
	<cfquery name="qBusinessSegmentCount" datasource="#application.datasource#">
		SELECT *
	  	FROM dbo.User_Business_Segment
		WHERE User_Id = '#request.AccessStructure.User_ID#'
	       AND Deleted = 0
	</cfquery>
</cfif>

<cfset useLakebaseForvars_defaultClasses = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_class")>
<cfif useLakebaseForvars_defaultClasses>
	<cftry>
		<cfset vars.defaultClasses = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_class", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"default_filter" = "eq.1",
				"select" = "budget_class_id"
			}), "budget_class_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvars_defaultClasses = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvars_defaultClasses>
<cfquery name="vars.defaultClasses" datasource="#application.datasource#">
	SELECT	Budget_Class_ID
	FROM 	Budget_Class
	WHERE 	Deleted = 0
	AND 	Active = 1
	AND	Default_Filter = 1
</cfquery>
</cfif>

<cfif url.byClassIDs eq "" >
	<cfset url.byClassIDs = ValueList(vars.defaultClasses.Budget_Class_ID) />
</cfif>

<cfset useLakebaseForvars_classes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_class")>
<cfif useLakebaseForvars_classes>
	<cftry>
		<cfset vars.classes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_class", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "created_date.asc",
				"select" = "budget_class_number,budget_class_desc,budget_class_id,default_filter"
			}), "budget_class_number,budget_class_desc,budget_class_id,default_filter"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvars_classes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvars_classes>
<cfquery name="vars.classes" datasource="#application.datasource#">
	SELECT Budget_Class_Number,Budget_Class_Desc,Budget_Class_ID,Default_Filter
	FROM Budget_Class
	WHERE Deleted = 0
	AND Active = 1
	ORDER BY Created_Date
</cfquery>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<div style="margin:0px">
<fieldset id="mainfieldset">
	<legend style="font: bold 14px sans-serif; color: red;">Budgets - List</legend>
<div id="actions">
<CFIF qGetCreateBudget.Create_Budget eq 0>
#application.util.string.actionTextGrayedOut("create new budget")#
 <span id="masscopy">
  <a href="javascript:exportAll();"><cfoutput>#application.util.string.actionLinkFormat('export all')#</cfoutput></a><!---D60306 --->
 </span>
<CFELSE>
 <a href="javascript:addbudget()">#LCase(ActionText("create new budget"))#</a>
 <span id="masscopy">
  <a href="javascript:exportAll();"><cfoutput>#application.util.string.actionLinkFormat('export all')#</cfoutput></a><!---D60306 --->
 </span>
</CFIF>
</div>

<div style="margin:5px 0;display:none;border-width: 0px; border-style: dotted; border-color: red;" id="f1">
	<div style="width:640px;">
		<div style="width:360px;float:left"> 
			<div style="width:40px;float:left" id="vfclass">Class:</div>
			<div style="width:150px;float:left">
				<select name="byClassIDs" id="byClassIDs" multiple="multiple">
				<cfloop query="vars.classes">
					<option <cfif url.byClassIDs eq "" or listFindNoCase(url.byClassIDs, vars.classes.budget_class_id)>selected=selected</cfif> value="#vars.classes.budget_class_id#">#vars.classes.budget_class_number# - #vars.classes.budget_class_desc#</option>
				</cfloop>
				</select>
			</div>
			<cfoutput><a id="filter130" href="##">#application.util.string.actionLinkFormat("Filter")#</a>&nbsp;&nbsp;&nbsp;<a id="resetfilter130" href="##">#application.util.string.actionLinkFormat("Reset All Filters")#</a></cfoutput>
		</div>
		<div style="width:260px;float:right" id="actionclass">
			Action:
			<select name="selActions" id="selActions">
				<option value="0">**select an action**</option>
				<option value="1">Delete Selected</option>
				<option value="2">Copy Selected</option>
				<option value="3">Copy ALL</option>
				<option value="4">Deactivate Selected</option>
				<option value="5">Activate Selected</option>
			</select>
			<CFIF qGetCreateBudget.Create_Budget eq 0>
				#application.util.string.actionTextGrayedOut("mass apply")#
			<cfelse>
				<a href="##" onclick="javascript:submitAction();">#LCase(ActionText("mass apply"))#</a>
			</cfif>
		</div>
	</div>	<br><br><br>
</div>

	<cfset useLakebaseForCodeTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget")>
<cfif useLakebaseForCodeTypes>
	<cftry>
		<cfset CodeTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget", {
				"deleted" = "eq.0",
				"order" = "budget_code.asc",
				"select" = "budget_code"
			}), "budget_code"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCodeTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCodeTypes>
<cfquery name="CodeTypes" datasource="#application.datasource#">
		SELECT Distinct Budget_Code
		FROM Budget
		WHERE Deleted = 0
		ORDER BY Budget_Code ASC
	</cfquery>
</cfif>

	<cfset useLakebaseForGroupTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_group")>
<cfif useLakebaseForGroupTypes>
	<cftry>
		<cfset GroupTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_group", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "budget_group_desc.asc",
				"select" = "budget_group_desc as gtype,budget_group_id"
			}), "budget_group_desc as gtype,budget_group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGroupTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGroupTypes>
<cfquery name="GroupTypes" datasource="#application.datasource#">
		SELECT Budget_Group_Desc AS GType, Budget_Group_ID
		FROM Budget_Group
		WHERE Deleted = 0
		AND Active = 1
		ORDER BY Budget_Group_Desc ASC
	</cfquery>
</cfif>

	<cfset useLakebaseForBudgetTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_contribution_factor_type")>
<cfif useLakebaseForBudgetTypes>
	<cftry>
		<cfset BudgetTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_contribution_factor_type", {
				"deleted" = "eq.0",
				"order" = "contribution_factor_type.asc",
				"select" = "contribution_factor_type as btype,budget_contribution_factor_type_id"
			}), "contribution_factor_type as btype,budget_contribution_factor_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBudgetTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBudgetTypes>
<cfquery name="BudgetTypes" datasource="#application.datasource#">
		SELECT Contribution_Factor_Type AS BType, Budget_Contribution_Factor_Type_ID
		FROM Budget_Contribution_Factor_Type
		WHERE Deleted = 0
		ORDER BY Contribution_Factor_Type ASC
	</cfquery>
</cfif>

	<cfset useLakebaseForSegmentTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForSegmentTypes>
	<cftry>
		<cfset SegmentTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "business_unit_desc.asc",
				"select" = "business_unit_desc as segment,business_segment_id"
			}), "business_unit_desc as segment,business_segment_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSegmentTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSegmentTypes>
<cfquery name="SegmentTypes" datasource="#application.datasource#">
		SELECT Business_Unit_Desc AS Segment,  Business_Segment_ID
		FROM Business_Segment
		WHERE Deleted = 0
		AND Active = 1
		ORDER BY Business_Unit_Desc ASC
	</cfquery>
</cfif>

<div style="clear:both;">
<table id="budgets" class="datagrid" style='table-layout:fixed'>
<cfif busSegMgr.isEnabled>
  <!--- include segment column --->
  <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [0.28, 1, 2, 0.75, 1.5, 1.05, 1.15, 1, 1, 1, 1.10] )>
<cfelse>
  <!--- do not include segment column --->
  <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [0.28, 1, 2, 1, 1.5, 1.5, 1, 1, 1, 1.15] )>
</cfif>
<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
  <col width="#variables.columnPercentage#%">
</cfloop>
<thead>
<tr>
	<th><input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'chkBudgetID');"></th>
    <th>#columnLabel(formlabels.code)#<br/>
    	<select id="byBudgetCodes" multiple="multiple">
    		<cfloop query="CodeTypes">
    			<option value="#Budget_Code#" <cfif listFindNoCase(url.byBudgetCodes, Budget_Code)>SELECTED</cfif>>#Budget_Code#</option>
    		</cfloop>
    	</select>
    </th>
    <th>#columnLabel(formlabels.desc)#</th>
    <th>#columnLabel(formlabels.class)#</th>
    <th>#columnLabel(formlabels.group)#<br/>
    	<select id="byGroupIDs" multiple="multiple">
    		<cfloop query="GroupTypes">
    			<option value="#Budget_Group_ID#" <cfif listFindNoCase(url.byGroupIDs, Budget_Group_ID)>SELECTED</cfif>>#Gtype#</option>
    		</cfloop>
    	</select>
   </th>
    <th>#columnLabel(formlabels.contribution_factor_type)#<br/>
    	<select id="byBudgetTypeIDs" multiple="multiple">
    		<cfloop query="BudgetTypes">
    			<option value="#Budget_Contribution_Factor_Type_ID#" <cfif listFindNoCase(url.byBudgetTypeIDs, Budget_Contribution_Factor_Type_ID)>SELECTED</cfif>>#BType#</option>
    		</cfloop>
    	</select>
    </th>
    <cfif busSegMgr.isEnabled>
    	<th>#appSettings.getbusiness_segment_label()#<br/>
    		<select id="bySegmentIDs" multiple="multiple">
    			<cfloop query="SegmentTypes">
    				<option value="#Business_Segment_ID#" <cfif listFindNoCase(url.bySegmentIDs, Business_Segment_ID)>SELECTED</cfif>>#Segment#</option>
    			</cfloop>
    		</select>
    	</th>
    </cfif>
    <th class=mid>Budget</th>
    <th class=mid>Committed<br/>&laquo; Comm Balance</th>
    <th class=mid>Actual<br/>&laquo; Act Balance</th>
    <th class="csvExclude">Action</th>
</tr>
</thead>
<tbody>
</tbody>
</table>
</div>
</fieldset>
</div>
</cfoutput>
	<cfif ! busSegMgr.isEnabled><input type="hidden" name ="bySegmentIDs" id="bySegmentIDs" value =""></cfif>
	<input type="hidden" name ="bySearch" id="bySearch" value ="">
<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="columnLabel" output="false">
  <cfargument name="customLabel" required="true">

  <cfreturn Replace(arguments.customLabel, ':', '')>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfset jQueryUI.version = "1.8.23" />
<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery-impromptu.3.1.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.cfjs.min.js"></script>
<script type="text/javascript" src="/Script/javascript/table2csv.js"></script>
<script type="text/javascript" src="/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"></script>

<script type="text/javascript">
$.prompt.setDefaults( { opacity:'0.3', prefix:'jqi', top:'35%' } );

var has_activate = null;
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .45) * windowHeight;
var grid = $('#budgets').dataTable({
	"bAutoWidth": false
	 ,"bPaginate": true
	 ,"bServerSide": true
	 ,"bProcessing": true
	  ,"bSortClasses": false
	 ,"bScrollCollapse": true
	  ,"iDisplayLength": 100
	  ,"sAjaxSource": <cfoutput>"ajax/listBudget.cfm?byClassIDs=#trim(url.byClassIDs)#&segmentIsOn=#(busSegMgr.isEnabled ? 1 : 0)#&userBusinessSegments=#(qBusinessSegmentCount.recordCount gt 0 ? 1 : 0)#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#trim(url.byGroupIDs)#&byBudgetTypeIDs=#trim(url.byBudgetTypeIDs)#&bySegmentIDs=#trim(url.bySegmentIDs)#&bySearch=#trim(url.bySearch)#"</cfoutput>
	  ,"fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
                      <!--- if this budget requires activation change the background color of the tr --->
                      if ( aData[(aData.length - 1)].indexOf("javascript:activate(") >= 0 ) {
                        $('td', nRow).closest('tr').addClass("activate");
                      }
                      return nRow;
                    }
	  ,"sDom": 'fp<"export">tipr'
	  ,"sScrollY": sScrollY         <!--- data grid height --->
	  ,"aaSorting": [] <!---default sorting on code column--->
	  ,"aoColumns": [ { "bSortable":false, "bSearchable":false}
			  				  , { }
			                  , { }
			                  , { "bSearchable":false }
			                  , { "bSortable":false, "bSearchable":false }
			                  , { "bSortable":false, "bSearchable":false }
			                  <cfif busSegMgr.isEnabled>, {"bSortable":false, "bSearchable":false }</cfif>
			                  , { "bSearchable":false, "sClass":"dollar" }
			                  , { "bSearchable":false, "sClass":"dollar" }
			                  , { "bSearchable":false, "sClass":"dollar" }
			                  , { "bSortable":false, "bSearchable":false} ]
  ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
}).fnSetFilteringDelay();
$('table#budgets tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

$(document).ready(function(){
  $("select").change( function () {

  	var byBudgetCodes = $('#byBudgetCodes').val();
		var byGroupIDs = $('#byGroupIDs').val();
		var byBudgetTypeIDs = $('#byBudgetTypeIDs').val();
		var bySegmentIDs = $('#bySegmentIDs').val();
		var bySearch = $('div.dataTables_filter input').val();

		if(byBudgetCodes == null){
			byBudgetCodes='';
		}
		if(byGroupIDs == null){
			byGroupIDs='';
		}
		if(byBudgetTypeIDs == null){
			byBudgetTypeIDs='';
		}
		if(bySegmentIDs == null){
			bySegmentIDs='';
		}
		if(bySearch == null){
			bySearch='';
		}

		if ( byBudgetCodes ||byGroupIDs ||byBudgetTypeIDs ||bySegmentIDs ) {

			window.location = 'index.cfm?byClassIDs=<cfoutput>#trim(url.byClassIDs)#</cfoutput>&byBudgetCodes='+byBudgetCodes+'&byGroupIDs=' +byGroupIDs+'&bySearch='+bySearch+'&byBudgetTypeIDs='+byBudgetTypeIDs+'&bySegmentIDs='+bySegmentIDs;

		}
   } );
} );
// $('table#budgets tr').hover (   function() { has_activate = $(this).hasClass("activate"); $(this).removeClass("activate"); $(this).addClass("over"); },   function() { $(this).removeClass("over"); if (has_activate) $(this).addClass("activate"); } );
<!--------------------------------------------------------------------------------------------------------------------->
function activate( budget_id ) {
    document.forms[budget_form].budget_id.value = budget_id;
    document.forms[budget_form].command.value = 'activatebudget';
    document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function deactivate( budget_id, budget_code, committed_dollar, actual_dollar ) {
	var txt = '';
	if (committed_dollar || actual_dollar) {
		txt = 'ATTENTION:<br>There are programs committed for the selected budget.<br>'
		      + 'Please reassign the programs to a different budget.<br><br>'
		      + 'You cannot deactivate a budget with Committed / Actual.';
		$.prompt( txt );
	}
	else {
		txt = 'Are you sure you want to deactivate budget "' + budget_code + '"?';
		window.scrollTo(0, 0);  // go top of window, otherwise the prompt will not be fully visible on long page
		$.prompt( txt, {
					buttons:{Deactivate:true, Cancel:false}
					,callback: function(v, m, f){
											if ( v ) {
										    document.forms[budget_form].budget_id.value = budget_id;
										    document.forms[budget_form].command.value = 'deactivatebudget';
										    document.forms[budget_form].submit();
										  }
						        }
		});
	}
}

<!--------------------------------------------------------------------------------------------------------------------->
function addbudget() {
  document.forms[budget_form].command.value = 'addbudget';
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function deletebudget( budget_id, budget_code, committed_dollar, actual_dollar ) {
	window.scrollTo(0, 0);  // go top of window, otherwise the prompt will not be fully visible on long page
	var txt = '';
	if (committed_dollar || actual_dollar) {
		txt = 'ATTENTION:<br>There are programs committed for the selected budget.<br>'
		      + 'You will need cancel them to remove the commitments.<br><br>'
		      + 'If actual payments have been made, you cannot delete a budget.';
		$.prompt( txt );
	}
	else {
		txt = txt + 'Are you sure you want to delete budget "' + budget_code + '"?';
		$.prompt( txt, {
					buttons:{Delete:true, Cancel:false}
					,callback: function(v, m, f){
											if ( v ) {
										    document.forms[budget_form].budget_id.value = budget_id;
										    document.forms[budget_form].command.value = 'deletebudget';
										    document.forms[budget_form].submit();
										  }
						        }
		});
	}
}
<!--------------------------------------------------------------------------------------------------------------------->
function copybudget( budget_id ) {
    document.forms[budget_form].budget_id.value = budget_id;
    document.forms[budget_form].command.value = 'copybudget';
    document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function editbudget( budget_id, budget_type ) {
  if ( budget_type == 1)
    document.forms[budget_form].command.value = "editFixed";
  else if ( budget_type == 2)
    document.forms[budget_form].command.value = "editAccrual";
  else if ( budget_type == 3)
  	document.forms[budget_form].command.value = "editVariable";

  document.forms[budget_form].budget_id.value = budget_id;
  document.forms[budget_form].load_fromdb.value = 1;

  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function viewbudget( budget_id, budget_type ) {
  if ( budget_type == 1)
    document.forms[budget_form].command.value = "viewFixed";
  else if ( budget_type == 2)
    document.forms[budget_form].command.value = "viewAccrual";
  else if ( budget_type == 3)
    document.forms[budget_form].command.value = "viewVariable";
  document.forms[budget_form].budget_id.value = budget_id;
  document.forms[budget_form].load_fromdb.value = 1;
  document.forms[budget_form].submit();
}

<!--------------------------------------------------------------------------------------------------------------------->
$('#filter130').click( function() {
											 var byClassIDs = $('#byClassIDs').val();
												if ( byClassIDs ) {
													$(this).html('One moment... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">');
													//$('#vfForm').submit();
													window.location = 'index.cfm?byClassIDs=' + byClassIDs;
												}
												else {
													alert( 'Please select at least one class.' );
												}
											} );

$('#resetfilter130').click( function() {
	$(this).html('One moment... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">');
	window.location = 'index.cfm';
} );
<!--------------------------------------------------------------------------------------------------------------------->
$(document).ready(function(){
		
		$("#byClassIDs").multiselect( { minWidth: "200", selectedList: 3 });

		$("#byBudgetCodes").multiselect( {selectedList: 3});
		$("#byGroupIDs").multiselect( {selectedList: 3 });
		$("#byBudgetTypeIDs").multiselect( {selectedList: 3 });
		<cfif busSegMgr.isEnabled>
		$("#bySegmentIDs").multiselect( {selectedList: 3 });
		</cfif>
	  $('.ui-multiselect').css('width', '90%');
		
  $('#f1').show();
})
<!--------------------------------------------------------------------------------------------------------------------->
function selectAll(thisObj, objToChk)
{
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
<!--------------------------------------------------------------------------------------------------------------------->
function submitAction()
{
	var chObjs = eval("document.all.chkBudgetID");
	var atleastOneRowChecked = false;
	if(chObjs)
	{
		if(chObjs.length)
		{
			for(i=0;i<chObjs.length;i++)
			{
				if (chObjs[i].checked == true)
				{
					atleastOneRowChecked = true;
				}
			}
		}
	}

	if(document.forms[budget_form].selActions[document.forms[budget_form].selActions.selectedIndex].value==0) //	 document.all.showhistory.options[document.all.showhistory.selectedIndex].value; options[window.Products.NewRebate.selectedIndex].value
	{
		alert('Please select an Action');
	}
	else if (atleastOneRowChecked == false && document.forms[budget_form].selActions[document.forms[budget_form].selActions.selectedIndex].value!= 3)
	{
		alert('Please check atleast on row');
	}
	else
	{
		document.forms[budget_form].command.value = "actionBudget";
		document.forms[budget_form].submit();
	}

}
  //D60306 ::Exporting All Pages from Budgets and Volume Forecasts START
  exportAll = function() {
  window.open( "/Common_Files/exportAll.cfm?" + "type=listBudgets"
                                              + "&segmentIsOn=<cfoutput>#(busSegMgr.isEnabled ? 1 : 0)#</cfoutput>"
                                              + "&userBusinessSegments=<cfoutput>#(qBusinessSegmentCount.recordCount gt 0 ? 1 : 0)#</cfoutput>"
                                              + "&byClassIDs=<cfoutput>#trim(url.byClassIDs)#</cfoutput>"
																							+ "&byBudgetCodes=<cfoutput>#trim(url.byBudgetCodes)#</cfoutput>"
																							+ "&byGroupIDs=<cfoutput>#trim(url.byGroupIDs)#</cfoutput>"
																							+ "&byBudgetTypeIDs=<cfoutput>#trim(url.byBudgetTypeIDs)#</cfoutput>"
																							+ "&bySegmentIDs=<cfoutput>#trim(url.bySegmentIDs)#</cfoutput>"
                                              + "&sSearch="+encodeURIComponent($('div.dataTables_filter input').val())
                                              + "&friendlyFileName=<cfoutput>#urlEncodedFormat('Budgets_List')#</cfoutput>"
              ,"_blank"
              ,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
}

  //D60306 ::Exporting All Pages from Budgets and Volume Forecasts END
<cfoutput>
	<cfif appSettings.get_Setting('Accrual_Budgets_Calculation_By_Client') eq '1'>
		$('div.export').html("&nbsp;&nbsp;<a href='javascript:exportDropOffReport();'>#application.util.string.actionLinkFormat('Download Drop Off Report')#</a> &nbsp;");

	  exportDropOffReport = function() {
	 	 window.open( "/Common_Files/exportAll.cfm?type=DropOffReport"
	 	 + "&friendlyFileName=<cfoutput>#urlEncodedFormat('Drop_Off_Report')#</cfoutput>"
	 	 ,"_blank" ,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
		}
	</cfif>
</cfoutput>

	$("#budgets_filter input").on("keyup", function () {
			$("#bySearch").val($('div.dataTables_filter input').val());
	});
	$("#budgets_filter input").val('<cfoutput>#url.bySearch#</cfoutput>');
	grid.fnFilter('<cfoutput>#url.bySearch#</cfoutput>');
</script>