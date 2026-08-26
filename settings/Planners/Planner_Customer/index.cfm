<!----------------------------------------------------------------------------------
Name         :	index.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	04/20/2016
Created By   : 	Anand Rao
Description  :
---------------------------------------------------------------------------------->
<cfparam name="form.action" default="">
<cfscript>
	variables.noty         = {};
	variables.noty.message = [];
	variables.noty.timeout = [];
	variables.lock_main_id = 'Planner_Customer_Settings';
	variables.lock_cfc     = createObject("component", "components.general.lock");
</cfscript>
 <!--- Locking the page Read Only/Edit --->
<cfif cgi.request_method eq "post">
	<cfif form.action eq "edit">
		<!--- attempt to lock it --->
		<cfset variables.lock_success = lock_cfc.lock( variables.lock_main_id )>
		<!--- locking was failed --->
		<cfif not variables.lock_success>
			<!--- stay in read only mode --->
			<cfscript>
				form.action = "readonly";
			</cfscript>
		</cfif>
	<!--- switching from edit to readonly --->
	<cfelseif form.action eq "readonly">
		<cfset variables.unlock_success = lock_cfc.unlockByID( variables.lock_main_id )>
	<cfelseif form.action eq "save">
		<cfset saveSettings()>
 		<cfset form.action = "edit" />
	</cfif>
</cfif>
<cfscript>
	variables.lock_status = lock_cfc.getStatus( variables.lock_main_id );
	// Check to see if the Main_ID exists in the Lock table if it does not then Insert the Main_ID into the Lock table
	if (variables.lock_status.RecordCount EQ 0)
	{
		variables.insLock = lock_cfc.insertLock( variables.lock_main_id );
		variables.lock_status = lock_cfc.getStatus(variables.lock_main_id);
	}

	// <!--- switch to edit mode if page is locked by current user --->
	if ( variables.lock_status.is_Locked and variables.lock_status.Locked_By_User_ID eq request.AccessStructure.User_ID )
		form.action = 'edit';
	if (form.action eq 'edit') {
		variables.disabled = '';
	}
	else {
		variables.disabled = 'disabled';
	}
	variables.nbsp = '&nbsp;';
	labels_manager  = createObject("component", "components.settings.labels.labels").init();
	customer_labels = labels_manager.getPlannerLabels("customer");
</cfscript>

<html lang="en">
<head>
    <cfoutput><title>#Application.PlannerLabel# #customer_labels.planner_labels_singular#</title></cfoutput>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
 <style>
	.right { float: right; }
	.header1 { margin: 10px 0; width: 100%; }
	div.header2 { margin-bottom:10px; }
	.header2 a { margin-right: 25px; }
	.info { margin-left:30px; font-weight:bold; font-size:1em; color:black; padding:5px 20px; letter-spacing:0.75px; border: 3px solid orange; height: 100%; }
	div#msg55 { font-size: 1.15em; letter-spacing:0.9px; }
	div#msg55 p { font-size: 1.35em; margin:20px; padding:20px; background-color: #BDE5F8; letter-spacing:0.9px; }
	button { cursor: pointer; }
	span.mode1, span.mode2 { font-size: 0.9em; font-weight: normal; }
	span.mode1 { color: #ffce84; }
	span.mode2 { color: white; }
	table.datagrid { table-layout: fixed; }
	table.datagrid td { height: 20px; overflow: hidden; }
	th, td { overflow:hidden; }
	td.dollar { text-align: right; }
	th.center2, td.center { text-align: center; }
	thead th { text-align:left; }
	thead th.nobar { border-left:2px solid #FFCE84 !important; }   /* hide left border */
	thead input, thead select, tfoot input { width: 98%; }
    </style>
	<cfset jQueryUI.version = "1.8.23">
 	<script language="JavaScript">
		function selectAll(bCheck)
		{
			event.returnValue = false;
			var ObjGroups = eval("document.all.CustomerGroupChecked");
			var i, groupLen;
			if(ObjGroups)
			{
				groupLen = ObjGroups.length;
				if(groupLen)
				{
					for(i=0;i<groupLen;i++)
					{
						if(!ObjGroups[i].disabled)
						{
							ObjGroups[i].checked = bCheck;
						}
					}
				}
				else
				{
					if(!ObjGroups.disabled)
					{
						ObjGroups.checked = bCheck;
					}
				}
			}
		}
	</script>
</head>
<body>
<cfset pagetitle = "#Application.PlannerLabel#: " & customer_labels.planner_labels_singular & " Group Selection">
<cfinclude template="/settings/settings_title.cfm">
<cfinclude template="/common_files/jQuery.cfm">
<script src="/script/javascript/jquery.noty.packaged.min.js"></script>

<form  method="post" name="frmCustomerGroup" id="frmCustomerGroup">
<cfsavecontent variable="variables.body">
<div id="msg55"></div>
	<cfoutput>
		<input type="hidden" name="action" value="#form.action#">
		<div class="header1">
			<!--- read only/edit button --->
			<cfif form.action eq 'edit'>
				<button class="edit" title="Click for Read Only" id="page_mode" value="edit"> <b>Edit</b> <span class="mode2">(click for read only) </span></button>
			<cfelse>
				<cfif len(variables.lock_status.Locked_By_User_Name)>
					<button class="readonly" title="   Read Only   " id="page_mode" value="readonly" style="cursor:default;" disabled > <b>Read Only</b></button>
					<span class="info">#Application.PlannerLabel# #customer_labels.planner_labels_singular# is currently locked by  #variables.lock_status.Locked_By_User_Name# </span>
				<cfelse>
					<button class="readonly" title="Click to Edit" id="page_mode" value="readonly"> <b>Read Only</b><span class="mode1">(click to edit)</span></button>
				</cfif>
			</cfif>
		</div> <!--- class="header1" --->

	<cfparam name="FORM.sort_by" default="PG_Customer_Category_Name">
	<cfparam name="FORM.sort_Order" default="ASC">
	<cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() />
	<cfset plannerSettingsManagerCFC = createObject("component", "mvc.Models.Planner.PlannerSettingsManager") />
	<cfset PlannerCustomerGroups = plannerSettingsManagerCFC.getCustomerGroups() />
	<cfset qryGetActiveCustomerCategory   = PGManager.fnGetActiveCustomerCategory(FORM.sort_by,FORM.sort_Order) />

	<cfset maxCols = 3 />
	<cfset tdWidth = 100/maxCols />
	<cfif !(FORM.sort_by EQ "PG_Customer_Category_Code" OR FORM.sort_by EQ "PG_Customer_Category_Name" OR FORM.sort_by EQ "PG_Type_Name" OR FORM.sort_by EQ "Include_In_Other_PG" OR FORM.sort_by EQ "Business_Unit_Desc")>
	  <cfset FORM.sort_by = "PG_Customer_Category_Name" />
	</cfif>
	<br>
	<SPAN STYLE="font-size:14px; font-weight:bold; text-align: left; color:3300cc; padding:7px 0 15px 0;">#customer_labels.planner_labels_singular# Selection</SPAN><br><br>


	<cfif form.action eq "edit">
		<div class="actions">
			<a href="##" class="save" style="margin-right:30px;" title="Save the changes on this page">#application.util.string.actionLinkFormat("save")#</a>
			<a href="##" class="cancel" title="Cancel the changes made and reload this page">#application.util.string.actionLinkFormat("cancel")#</a>
		</div>  <br>
	</cfif>
	</cfoutput>
	<br>

	<table cellpadding="2" cellspacing="0" width="100%" border="0" align="center">
		<!--- header --->
		<cfif qryGetActiveCustomerCategory.recordcount GT 0>
			<tr bgcolor="FFCE8" style="height:20px">
				<td width="100%" style="border-bottom:1px solid ##93BEE2;">&nbsp;&nbsp;<strong>
			 		Retail Planning Groups
					</strong>
					<span id="Err_Component">&nbsp;</span>
				</td>
				<td nowrap style="border-bottom:1px solid ##93BEE2;">
					<cfif form.action eq "edit">
						<CF_smallLink
							title = "select all"
							url = "##"
							parameters = "onClick=""javascript: selectAll(true);return false;"""
						>
						<CF_smallLink
							title = "deselect all"
							url = "##"
							parameters = "onClick=""javascript: selectAll(false);return false;"""
						>
					</cfif>
				</td>
			</tr>
			<!--- List the rows --->
			<tr>
				<td colspan="100%" style="border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;border-bottom:1px solid ##93BEE2;">
					<table cellpadding="1" cellspacing="0" width="100%" border="0">
						<tr>
							<cfparam name="colsCount" default = 0>
							<cfoutput query="qryGetActiveCustomerCategory">
								<cfset GroupSelected = 0 />
								<cfloop query="PlannerCustomerGroups">
									<cfif qryGetActiveCustomerCategory.PG_Customer_Category_ID EQ PlannerCustomerGroups.Planning_Group_ID>
										<cfset GroupSelected = 1 />
									</cfif>
								</cfloop>
								<td width="#tdWidth#%"><input type="checkbox" name="CustomerGroupChecked" value="#PG_Customer_Category_ID#" <cfif GroupSelected EQ 1>checked</cfif>>#qryGetActiveCustomerCategory.PG_Customer_Category_Name#(#qryGetActiveCustomerCategory.PG_Customer_Category_Code#)</td>
								<cfset colsCount = colsCount + 1 />
								<cfif colsCount GTE maxCols>
									</tr><tr>
									<cfset colsCount = 0 />
								</cfif>
							</cfoutput>
							<cfloop from="#colsCount#" to="#maxCols#" index="i" >
								<td width="#tdWidth#%"></td>
							</cfloop>
						</tr>
					</table>
				</td>
			</tr>
		<cfelse>
			<tr>
				<td>No Records Found!!!</td>
			</tr>
		</cfif>
	</table><br>
	<cfif form.action eq "edit">
		<div class="actions">
			<cfoutput><a href="##" class="save" style="margin-right:30px;" title="Save the changes on this page">#application.util.string.actionLinkFormat("save")#</a></cfoutput>
			<cfoutput><a href="##" class="cancel" title="Cancel the changes made and reload this page">#application.util.string.actionLinkFormat("cancel")#</a></cfoutput>
		</div>
	</cfif>
	</form>
</cfsavecontent>
	<!--- remove extra white spaces prior to displaying on the page --->
	<cfoutput>#application.util.string.compress( variables.body )#</cfoutput>

	<cffunction name="saveSettings" output="false">
		<cfscript>
			vars = {};
			vars.plannerSettingsManagerCFC = createObject("component", "mvc.Models.Planner.PlannerSettingsManager");
	  		vars.calendarInfoSetting = vars.plannerSettingsManagerCFC.saveCustomerGroups();
		</cfscript>
	</cffunction>
	<script>
	    $(".cancel").on("click", function() { window.location.href="index.cfm"; });
	    $(".save").on("click", function() {
			$('input[name=action]').val('save');
			$("form[name=frmCustomerGroup]").submit();
		 });
		$('#page_mode').click(function() {
			var customerForm = $("form[name='frmCustomerGroup']");
			var current_mode = $(this).val();
			$('input[name=action]').val(current_mode == 'readonly' ? 'edit' : 'readonly');
			customerForm.hide();
			$("#msg55").append("<p>Processing, please wait...</p>");
			customerForm.submit();
		});
	</script>
</body>
</html>