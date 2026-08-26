<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Convert_programs.cfm
	Created:	1/4/2012
 	Developer:	drachala
	Copyright (c) 2012 Blacksmith Applications, Inc.

	Description:
		Used to convert Programs from one template to another template
	Usage:
		Settings>>Programs>>Settings
---->
<div style="margin-left:10px;">
<cfparam name="form.control_panel_id" default="0">
<cfparam name="url.control_panel_id" default="#form.control_panel_id#" >
<cfparam name="form.selectBudgets" default="0"><!---D41760 :: GM Stabilization - Template & Segment Reassign --->
<cfparam name=" budget_ids " default=""><!---D41760 :: GM Stabilization - Template & Segment Reassign --->

<cfset Templates = CreateObject("component", "components.programs.template.templatemanager").getAllTemplates(url.control_panel_id) />
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
		.action { font-weight:bold; margin:0 3px 0 3px; }
	</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">
<cfscript>
  vars = StructNew();
</cfscript>

<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">

<table border="0" cellpadding="2" cellspacing="0" width="100%">
	<tr>
		<td align="left" bgcolor="#a7caf2" width="100%" height="25" style="background-image: url(/images/gradient.jpg); background-repeat:no-repeat;">
			<span style="color:white; font-size:14px; font-weight: bold; padding-left:5px;">
				Convert Program To Different Template
			</span>
		</td>
	</tr>
	<tr>
		<td style="padding-top:5px;padding-bottom:5px;">
			<CF_button
				button_name		=	""
				button_caption	=	"back"
				button_action		=	"javascript: history.go(-1);"
				button_type			=	"javascript_link"
				button_width		=	"50"
				button_color			=	"Navy"
				button_tip				=	"execute"
				font_color				=	"White"
				font_size					=	"12"
				font_weight			=	"bold"
			>
		</td>
	</tr>
</table>
<div style="width:98%;border:solid;border-color:red;border-width:2px;padding-bottom:5px;">
	<span style="color:red;font-weight:bold;padding:4px;width:100%;">Rules For Program Conversion</span>
	<span style="padding-left:4px;width:100%;">
	1. Confirm the template you are moving the programs to has similar configuration as the template the program currently resides on.
		Such as:  discount type (e.g. both templates have fixed price or both templates have rebate) and configuration for individual customer/product or groups.
	</span>
	<span style="padding-left:4px;width:100%;">
	2. Program can only be converted to a template that is within the same template category.
		(e.g. you can convert a program that is on a Distributor Trade Shelter template to another Distributor Trade Shelter template.
		Or you can convert a program that is on an Operator Deviated Pricing to another Operator Deviated Pricing template).
	</span>
	<span style="color:red;font-weight:bold;padding:4px;width:100%;">Steps</span>
	<span style="padding-left:4px;width:100%;">1. Click on template name. This will be the template you want to move the program(s) to.</span>
	<span style="padding-left:4px;width:100%;">2. In the program search, select the program(s) to convert.</span>
	<span style="padding-left:4px;width:100%;">3. Confirm the list of program to convert and then click <cfoutput><a>#ActionText("Convert Programs")#</a></cfoutput></span>
</div>

<cfif isdefined("Form.Contract_Number")>
	<cfset url.control_panel_id = form.control_panel_id>
	<cfset diplay_window = 0>
</cfif>

<cfif isdefined("Form.Contract_Number") OR (isdefined("form.main_id") AND len(form.main_id)) OR form.selectBudgets>
	<cfif isdefined("form.main_id") AND len(form.main_id)>
		<cfset Form.Contract_Number = #form.main_id#>
	</cfif>
				<cfquery name="List_program" datasource="#Application.Datasource#">
					SELECT Contract_Main_ID,
								Contract_Reference_Number,
								Contract_Number,
								Contract_Status_Type_Desc,
								Contract_Title,
								Contract_Start_Date,
								Contract_End_Date,
								Responsible_User_ID,
								Business_Segment_ID,
								Creating_User_Position_ID,
								PCPO.Created_Type
					FROM 		Contract_Main
					INNER JOIN 	Contract_Status_Types
					ON 			Contract_Main.Contract_Status_Type_IDX = Contract_Status_Types.Contract_Status_Type_ID
					LEFT JOIN 	Program_Control_Panel_Options PCPO
					ON 			PCPO.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					WHERE 		Contract_Main_ID IN (<cfqueryparam value="#Form.Contract_Number#" cfsqltype="CF_SQL_INTEGER" list="yes" />)
					AND			PCPO.generic_type = '#Templates.generic_type#'
					ORDER BY 	Contract_Number asc
				</cfquery>
</cfif>

<cfset Program = CreateObject("component","components.programs.Program")/>

<!--- This Section is used DB and alert with new information in CFWINDOW START --->
<cfif isdefined("form.main_id") AND len(form.main_id)>
<cfset UserManager = CreateObject("component","components.User.UserManager").getUser(request.AccessStructure.User_ID)/>
<cfset qGetChangeLog = CreateObject("component", "components.programs.program_history").init() />
	<cfscript>
		Program.ConvertProgramsTemplate
		(
			ThisForm 				= form,
			username			= userManager.User_Full_Name,
			newtemplate	= form.newtemplate
		);
	</cfscript>

<cfwindow closable="false" draggable="false" height="150" width="800" name="Update" resizable="false" title="Success Update" modal="true" initshow="true" center="true">
<img src="/images/delete_new2.gif" border="0" style="float:right" onclick="closewindow()">
		<table width="95%" align="center" border="0">
			<tr style="text-align:center;">
				<td colspan=100 style="color:green;font-size: 12px;font-weight:bold;">Successfully Converted The Following Program(s)</td>
			</tr>
			<tr BGCOLOR="#FFCE84" style="font-size: 12px;font-weight: bold;">
				<td>Program</td>
				<td>Title</td>
				<td>Prior Template</td>
				<td>Current Template</td>
			</tr>
			<cfoutput query="List_program">
			<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<td>#contract_number#</td>
				<td>#contract_title#</td>
				<td>#Created_Type#</td>
				<td>#form.newtemplate#</td>
			</tr>
			</cfoutput>
		</table>
</cfwindow>
<script>
	function closewindow(){
		ColdFusion.Window.hide('Update');
		window.location = 'convert_programs.cfm'
	}
</script>
</cfif>
<!--- This Section is used DB and alert with new information in CFWINDOW END --->
<!--- This Section is used to display Selected tempate information START --->
<cfif url.control_panel_id NEQ 0>
<cfparam name="diplay_window" default="1">
<cfoutput>
	<table width="800px" align="center" border="0" style="margin-top:15px;">
		<tr>
			<th colspan=100 align="left">Program(s) will be moved to this template:</th>
		</tr>
		<tr BGCOLOR="##FFCE84" >
			<td style="font-size: 12px;"><b>Template</b></td>
			<td style="font-size: 12px;"><b>Description</b></td>
			<td style="font-size: 12px;"><b>Generic Type</b></td>
		</tr>
		<tr>
			<td>#Templates.created_type#</td>
			<td>#Templates.program_description#</td>
			<td>#Templates.generic_type#</td>
		</tr>
	</table>
	<!--- This Section is used to display Selected tempate information END --->
	<!--- In This Section we check for APP setting for "PROGRAM SEARCH TOOL" based on that value we will open pop-up START --->
<form name="val">
	<input type="hidden" name="control_panel_id" value="#url.control_panel_id#">
</form>

<cfif form.control_panel_id EQ 0>

<script>
<cfif appSettings.getFlexProgramSearch() EQ 1 AND diplay_window EQ 1>
	 NewWindow("/Scorecard/program_Search.cfm", "programswindow", 1000, 600, "yes", "yes");
<cfelseif (appSettings.getFlexProgramSearch() EQ 2 OR appSettings.getFlexProgramSearch() EQ 3) AND diplay_window EQ 1>
	NewWindow("/flex/search/ProgramSearchFx.cfm?Include_work_in_progress_below_me=1&importlist_type=1&userid=#cookie.user_id#&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=1&reassign_type=2", 'pro_search', '1000', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
<cfelseif (appSettings.getFlexProgramSearch() EQ 4 OR appSettings.getFlexProgramSearch() EQ 5) AND diplay_window EQ 1>
	NewWindow("/programs/program_search.cfm?Include_work_in_progress_below_me=1&importlist_type=1&userid=#cookie.user_id#&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=1&reassign_type=2", 'pro_search', '1000', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
</cfif>
</script>

</cfif>
<!--- In This Section we check for APP setting for "PROGRAM SEARCH TOOL" based on that value we will open pop-up END --->
</cfoutput>

	<!--- This JavaScript function is used to collect the Contact_Number from the pop-up child window and assaign those values to form variables and submit form --->
 <script language="javascript" type="text/javascript">
      function ParentWindowFunction(s){
        document.reassign_program.Contract_Number.value = s;
        document.reassign_program.submit();
        return false;
     }
	function selectAll(thisobj){
			var bCheck = thisobj.checked;
			var chObjs = document.all.SelectedITEMS;
			if(chObjs.length){
				var chObjLen = chObjs.length;
				var i;
				for(i=0;i<chObjLen;i++){
					chObjs[i].checked = bCheck;
				}
			}
			else	{
				chObjs.checked = bCheck;
			}
		}
 </script>
<cfparam name="url.control_panel_id" default="" >
<cfoutput>
	<form name="reassign_program" action="Convert_Programs.cfm" method="POST">
		 <input type = "hidden" name="Contract_Number" value="">
		 <input type = "hidden" name="control_panel_id" value="#url.control_panel_id#">
		 <input type = "hidden" name="newtemplate" value="#Templates.created_type#">
	</form>
</cfoutput>
<cfif isdefined("Form.Contract_Number")>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<form name="convertprograms" action="convert_programs.cfm" method="post" id="convertprograms">
	<table width="95%" align="center" border="0">
		<tr>
			<th colspan=100 align="left">Program(s) that will be converted:</th>
		</tr>
		<tr BGCOLOR="#FFCE84">
			<td style="font-size: 12px; width:25px;"><input type="checkbox" name="allbox" onclick="javaScript: selectAll(this);" CHECKED></td>
			<td style="font-size: 12px;"><b>Status</b></td>
			<td style="font-size: 12px;"><b>Program</b></td>
			<td style="font-size: 12px;"><b>Title</b></td>
			<td style="font-size: 12px;"><b>Template</b></td>
			<!---D41760 :: GM Stabilization - Template & Segment Reassign --->
			<cfif businessSegManager.isEnabled()>
			<td style="font-size: 12px;"><b><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></b></td>
			</cfif>
			<cfif appSettings.getBudgetsFunctionalityOn() AND form.selectBudgets>
			<td style="font-size: 12px;"><b>Budgets</b></td>
			</cfif>
			<!---D41760 :: GM Stabilization - Template & Segment Reassign --->
			<td style="font-size: 12px;"><b>Start Date</b></td>
			<td style="font-size: 12px;"><b>End Date</b></td>
		</tr>
			<cfif businessSegManager.isEnabled()>
					<input type="hidden" name="Business_Segment_Enable" value = "1"/>
			<cfelse>
					<input type="hidden" name="Business_Segment_Enable" value = "0"/>
			</cfif>
<cfif List_program.Recordcount>

<cfloop query="List_program">
			<!---D41760 :: GM Stabilization - Template & Segment Reassign --->
			<cfif appSettings.getFilterBusinessSegments()>
				<cfset qGetBusSegments = businessSegManager.getActive(Responsible_User_ID, url.control_panel_id) />
			<cfelse>
				<cfset qGetBusSegments = businessSegManager.getActive(Responsible_User_ID) />
			</cfif>
			<!---D41760 :: GM Stabilization - Template & Segment Reassign --->
			<cfset qGetProgramCompleteSpan = program.getProgramCompleteSpan(List_program.Contract_Main_ID, List_program.Contract_Number) />
<cfoutput>
		<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<td style="width:25px;"><input type="Checkbox" name="SelectedITEMS" VALUE="#Contract_Main_ID#" CHECKED  id="SelectedITEMS">
			<input type="hidden" id="Program_Start_#Contract_Main_ID#" value="#Dateformat(qGetProgramCompleteSpan.Program_Start, 'mm/dd/yyyy')#">
			<input type="hidden" id="Program_End_#Contract_Main_ID#" value="#Dateformat(qGetProgramCompleteSpan.Program_End, 'mm/dd/yyyy')#">
			</td>
			<td>#Contract_Status_Type_Desc#</td>
			<td>#contract_number#</td>
			<td>#Contract_Title#</td>
			<td>#Created_Type#</td>
			<!---D41760 :: GM Stabilization - Template & Segment Reassign --->
                  <cfif businessSegManager.isEnabled()>
                              <cfparam name="form.BusinessSegmentID_#List_program.Contract_Main_ID#" default="#List_program.Business_Segment_ID#" >
                              <cfif qGetBusSegments.recordcount EQ 1>
                                    <cfset "form.BusinessSegmentID_#List_program.Contract_Main_ID#" = qGetBusSegments.Business_Segment_ID>
                              </cfif>
                  <td>
                        <select name="Business_Segment_ID_#List_program.Contract_Main_ID#" onchange="assign(#List_program.Contract_Main_ID#,this.value);" <cfif form.selectBudgets>disabled</cfif>>
                              <option value="0">Choose a #appSettings.getbusiness_segment_label()#</option>
                              <cfloop query="qGetBusSegments">

                                    <cfif isdefined('form.BusinessSegmentID_#List_program.Contract_Main_ID#') AND evaluate( 'form.BusinessSegmentID_#List_program.Contract_Main_ID#' )>
                                                <cfset "form.Business_Segment_ID_#List_program.Contract_Main_ID#" = evaluate('form.BusinessSegmentID_#List_program.Contract_Main_ID#')>
                                          <cfelse>
                                                <cfset "form.Business_Segment_ID_#List_program.Contract_Main_ID#" = 0>
                                    </cfif>

                                    <cfif isdefined('form.Business_Segment_ID_#List_program.Contract_Main_ID#') AND (evaluate( 'form.Business_Segment_ID_#List_program.Contract_Main_ID#' ) EQ #Business_Segment_ID#)>
                                          <cfset select = "selected">
                                    <cfelse>
                                          <cfset select = "">
                                    </cfif>

                                    <option value="#Business_Segment_ID#" #select#>#Business_Unit_Desc#</option>
                              </cfloop>
                        </select>
                        <input type="hidden" name="BusinessSegmentID_#List_program.Contract_Main_ID#" value="#evaluate('form.BusinessSegmentID_#List_program.Contract_Main_ID#')#"/>
              </td>
			  <cfelse>
			  	  <input type="hidden" name="Business_Segment_ID_#List_program.Contract_Main_ID#" value="0"/>
             </cfif>
</cfoutput>
		<cfif appSettings.getBudgetsFunctionalityOn() AND form.selectBudgets>
			<cfif ! isDefined('form.Business_Segment_ID_#Contract_Main_ID#')>
				<cfparam name="form.Business_Segment_ID_#Contract_Main_ID#" default="0" >
			</cfif>
				<cfstoredproc procedure="ADV_BUDGET_GET_PGM_BUDGET_LIST" dataSource="#application.datasource#" returnCode="Yes" debug="Yes">
					<cfprocresult name=qBudgets>
					<cfprocparam type="in" cfsqltype = cf_sql_integer value="#List_program.Contract_Main_ID#" dbVarName = @program_id>
					<cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @user_position_id>
					<cfprocparam type="in" cfsqltype = cf_sql_integer value="#form.control_panel_id#" dbVarName = @new_template_id>
					<cfprocparam type="in" cfsqltype = cf_sql_integer value="#evaluate('form.Business_Segment_ID_#Contract_Main_ID#')#" dbVarName = @new_business_segment_id>
					<cfprocparam type="in" cfsqltype = cf_sql_integer value="#appSettings.getBudgetSelectionRequired()#" dbVarName = @budget_required_complete_span>
				</cfstoredproc>

				<!--- Get distinct class types available for this program --->
				<cfquery name="qGetBudgetClassType" dbtype="query">
					SELECT 	DISTINCT Is_Fiscal, Partial_Year
					FROM	qBudgets
					ORDER BY Is_Fiscal DESC, Partial_Year
				</cfquery>
				<!--- Get the class type already selected in the program --->
				<cfquery name="qGetCurrentProgramBudgetClassType" datasource="#Application.Datasource#">
					SELECT 	DISTINCT Budget_Class.Is_Fiscal, Budget_Class.Partial_Year
					FROM	Budget_Program_Selection
					INNER JOIN Budget_Class
					ON		Budget_Class.Budget_Class_ID = Budget_Program_Selection.Budget_Class_ID
					WHERE	Budget_Program_Selection.Program_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER" />
				</cfquery>
				<!---GET Budgets on the Program --->
				<cfset useLakebaseForpgmBudgets = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_program_selection")>
<cfif useLakebaseForpgmBudgets>
	<cftry>
		<cfset pgmBudgets = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_program_selection", {
				"program_id" = "eq.#List_program.Contract_Main_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForpgmBudgets = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForpgmBudgets>
<cfquery name="pgmBudgets" datasource="#Application.Datasource#">
					SELECT *
					FROM Budget_Program_Selection
					WHERE Program_id = #List_program.Contract_Main_ID#
				</cfquery>
</cfif>
				<cfif pgmBudgets.recordcount>
					<cfset programBudgets = ValueList(pgmBudgets.Budget_ID)>
				<cfelse>
					<cfset programBudgets = "">
				</cfif>

				<!--- If program has budget selection, set that class type as the default --->
				<cfif qGetCurrentProgramBudgetClassType.RecordCount>
					<cfset var_CurrentBudgetClassIsFiscal = qGetCurrentProgramBudgetClassType.Is_Fiscal />
					<cfset var_CurrentBudgetClassPartialYear = qGetCurrentProgramBudgetClassType.Partial_Year />
				<cfelse><!--- If program record not found use the first record from the budget class types available --->
					<cfset var_CurrentBudgetClassIsFiscal = qGetBudgetClassType.Is_Fiscal />
					<cfset var_CurrentBudgetClassPartialYear = qGetBudgetClassType.Partial_Year />
				</cfif>

				<cfset CurrentBudgetClassType = "#var_CurrentBudgetClassIsFiscal#_#var_CurrentBudgetClassPartialYear#" />

			<td style="font-size: 12px;">
			<!--- Display the radio selection for class types --->
			<cfoutput query="qGetBudgetClassType">
				<cfset var_Class_Type_ID =  "0" />
				<cfset var_Class_Type_Desc = "" />
				<!--- class type description is now hard coded --->
				<cfif Is_Fiscal EQ 0>
					<cfset var_Class_Type_Desc = "Calendar" />
				<cfelseif Is_Fiscal EQ 1 AND Partial_Year EQ 0>
					<cfset var_Class_Type_Desc = "Fiscal" />
				<cfelseif Is_Fiscal EQ 1 AND Partial_Year EQ 1>
					<cfset var_Class_Type_Desc = "Fiscal (Partial Year)" />
				</cfif>
				<cfset var_Class_Type_ID =  "#Is_Fiscal#_#Partial_Year#" />

				<cfif var_Class_Type_Desc neq "">
						<input type="radio" objtype="classtypeobj" classtype="#var_Class_Type_ID#"
									programid="#List_program.Contract_Main_ID#" 	id="class_type_#List_program.Contract_Main_ID#"
									name="class_type_#List_program.Contract_Main_ID#" value="#var_Class_Type_ID#"
									<cfif CurrentBudgetClassType eq var_Class_Type_ID OR CurrentRow EQ 1>checked</cfif>>#var_Class_Type_Desc#&nbsp;
				</cfif>
			</cfoutput>
			<!--- Display the class and the budget list per class --->
			<table>
				<cfset budget_class_list_0_0 = "" />
				<cfset budget_class_list_1_0 = "" />
				<cfset budget_class_list_1_1 = "0" /><!--- always ID = 0, we will only allow one budget selected, thus only one drop down --->
			<cfif qBudgets.recordCount eq 0>
				<cfif appSettings.getBudgetSelectionRequired()>
					<tr>
					<td>
					<!--- dummy drop down so that validation will fail --->
					<select name="budget_0_#List_program.Contract_Main_ID#" class="Budgets_#List_program.Contract_Main_ID#"  style="width:250px" id="Budgets_0_#List_program.Contract_Main_ID#">
						<option value="0">Select a Budget</option>
					</select>
					</td>
					</tr>
				</cfif>
			<cfelse>
			<cfoutput query="qBudgets" group="Budget_Class_Desc_New">
				<cfset var_Class_Type_ID = "#Is_Fiscal#_#Partial_Year#" />
				<cfset var_Budget_Class_ID_To_Use = Budget_Class_ID />
				<!--- For partial year we will only allow one budget to select even if there are many classes --->
				<cfif Partial_Year EQ 1>
					<cfset var_Budget_Class_ID_To_Use = 0 />
				</cfif>
				<tr trclasstype="#var_Class_Type_ID#" name="tr_class_type_#var_Class_Type_ID#_#List_program.Contract_Main_ID#">
					<td style="border:none;"><span style="font-weight:bold;font-size:11px;">#qBudgets.Budget_Class_Desc_New#</span><br>
					<select name="budget_#var_Budget_Class_ID_To_Use#_#List_program.Contract_Main_ID#" class="Budgets_#List_program.Contract_Main_ID#"  style="width:250px" id="Budgets_#var_Class_Type_ID#_#List_program.Contract_Main_ID#" programid="#List_program.Contract_Main_ID#" partialBudget="#Partial_Year#">
						<option value="0">Select a Budget</option>
						<cfset tmp_Budget_Class_Desc_New = qBudgets.Budget_Class_Desc_New>
						<!---  count number of budgets within its group  --->
						<cfquery dbtype="query" name="qoqGroup">
							SELECT  *
							FROM 	qBudgets
							WHERE 	Budget_Class_Desc_New = '#tmp_Budget_Class_Desc_New#'
							AND		Budget_ID IS NOT NULL
						</cfquery>
						<cfloop query="qoqGroup">
						<option value="#qoqGroup.Budget_ID#" <cfif (qoqGroup.recordCount eq 1 AND qGetBudgetClassType.recordCount eq 1) OR (listfind(programBudgets, qoqGroup.Budget_ID,","))>selected=selected</cfif>>
							<span class="descr">#qoqGroup.Budget_Desc#</span> (#qoqGroup.Contribution_Factor_Type#)
						</option>
						</cfloop>
					</select>
					<span id="err_budget_#var_Budget_Class_ID_To_Use#_#List_program.Contract_Main_ID#"></span>
					<cfloop query="qoqGroup">
					<input type="hidden" id="Start_Date_budget_#var_Budget_Class_ID_To_Use#_#List_program.Contract_Main_ID#_#qoqGroup.Budget_ID#" value="#DateFormat(qoqGroup.Start_Date, 'mm/dd/yyyy')#">
					<input type="hidden" id="End_Date_budget_#var_Budget_Class_ID_To_Use#_#List_program.Contract_Main_ID#_#qoqGroup.Budget_ID#" value="#DateFormat(qoqGroup.End_Date, 'mm/dd/yyyy')#">
					</cfloop>
					<cfset budget_ids = listappend(budget_ids, var_Budget_Class_ID_To_Use)>
					<cfif Is_Fiscal EQ 0>
						<cfset budget_class_list_0_0 = listappend(budget_class_list_0_0, var_Budget_Class_ID_To_Use)>
					<cfelseif Is_Fiscal EQ 1 AND Partial_Year EQ 0>
						<cfset budget_class_list_1_0 = listappend(budget_class_list_1_0, var_Budget_Class_ID_To_Use)>
					</cfif>
					</td>
				</tr>
			</cfoutput>
			</cfif>
			</table>
			<cfoutput>
				<input type="hidden" name="budgets_#List_program.Contract_Main_ID#" value="#budget_ids#">
				<input type="hidden" name="budget_class_list_0_0_#List_program.Contract_Main_ID#" value="#budget_class_list_0_0#">
				<input type="hidden" name="budget_class_list_1_0_#List_program.Contract_Main_ID#" value="#budget_class_list_1_0#">
				<input type="hidden" name="budget_class_list_1_1_#List_program.Contract_Main_ID#" value="#budget_class_list_1_1#">
			</cfoutput>
			<cfset budget_ids = "">
			</td>
			</cfif>
			<!---D41760 :: GM Stabilization - Template & Segment Reassign --->
			<cfoutput>
			<td>#dateformat(Contract_Start_Date, "mm/dd/yyyy")#</td>
			<td>#dateformat(Contract_End_Date, "mm/dd/yyyy")#</td>
			</cfoutput>
		</tr>
</cfloop>

<cfelse>
		<tr>
			<td colspan="7" align="center" style="color:red;font-weight:bold;font-size:14px;">Program can only be converted to a template that is within the same template category.</td>
		</tr>
</cfif>
		<tr><td colspan=100><br></td></tr>
		<tr>
			<td colspan= 100 align="center">
					<table>
						<tr>
							<td>
								<CF_button
									button_name		=	""
									button_caption	=	"Select Programs"
									button_action	=	"selectprogram()"
									button_type		=	"javascript_link"
									button_width	=	"100"
									button_color	=	"Navy"
									button_tip		=	""
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold"
								>
							</td>
							<!--- Business Segment/Budgets are OFF --->
							<cfif ! appSettings.getBudgetsFunctionalityOn() AND ! businessSegManager.isEnabled()>
								<cfset nextAction = "Convert Programs">
								<cfset nextScript = "change()">
							<!--- Business Segment in ON and Budgets are OFF --->
							<cfelseif businessSegManager.isEnabled() AND ! appSettings.getBudgetsFunctionalityOn() >
								<cfset nextAction = "Convert Programs">
								<cfset nextScript = "checksegment(#List_program.recordcount#)">
							<!--- Business Segment/Budgets are ON and next step is Budgets selection OR Business Segment in OFF and Budgets are ON--->
<!---
	D47672: Control Panel Screen for "Program Conversion" /Anand Rao/20-Jan-2015
		    Changed the Label Select Budget(s) to "Continue"
--->
							<cfelseif (businessSegManager.isEnabled() AND (appSettings.getBudgetsFunctionalityOn() AND ! form.selectBudgets)) OR (! businessSegManager.isEnabled() AND appSettings.getBudgetsFunctionalityOn() AND ! form.selectBudgets)>
								<cfset nextAction = "Continue">
								<cfset nextScript = "checksegment(#List_program.recordcount#)">
							<!--- Business Segment is ON and Budgets are ON Final step --->
							<cfelseif appSettings.getBudgetsFunctionalityOn() AND form.selectBudgets>
								<cfset nextAction = "Convert Programs">
								<cfset nextScript = "budgetselection()">
							</cfif>
							<td>
								<CF_button
									button_name		=	""
									button_caption	=	#nextAction#
									button_action		=	#nextScript#
									button_type			=	"javascript_link"
									button_width		=	"100"
									button_color			=	"Navy"
									button_tip				=	""
									font_color				=	"White"
									font_size					=	"12"
									font_weight			=	"bold"
								>
							</td>
						</tr>
					</table>
			</td>
		</tr>
	</table>
<cfoutput>
	<input type="hidden" name="main_id" value="">
	<input type="hidden" name="control_panel_id" value="#form.control_panel_id#">
	<input type="hidden" name="newtemplate" value="#form.newtemplate#">
	<input type ="hidden"name="contract_number" VALUE="#form.contract_number#">
	<input type="hidden" name="selectBudgets" value="0">
</cfoutput>
</form>

<CF_MessageWindow>

<cfinclude template="/common_files/jQuery.cfm">

<script>
function checksegment(noPrograms){
				var error = 1;
		<cfif businessSegManager.isEnabled()>
				var elem = document.forms.convertprograms.elements;
				var str = elem['contract_number'].value;
				var str = str.substring(0, str.length-1);
				var cmidArray = str.split(',');
		  		for(var i =0; i<cmidArray.length; i++){
		  			if(elem['Business_Segment_ID_' + cmidArray[i]] == 0){
		  				error = 0;
		  			}
		    	}
		</cfif>
					if (error == 0) {
						alert("Please select <cfoutput>#appSettings.getbusiness_segment_label()#(s)</cfoutput> for all programs.");
					}
					else{
						<cfif appSettings.getBudgetsFunctionalityOn()>
							document.convertprograms.selectBudgets.value = 1;
							document.convertprograms.submit();
						<cfelse>
							change();
						</cfif>
					}
}

function budgetselection(){
	var budgetsError = 0;

	$("input[type='checkbox']:checked").each(function(){
		var id = $(this).attr('id');
		var val = $('#SelectedITEMS').is(':checked');
		if (id == 'SelectedITEMS' && val == true) {
			var cmid = $(this).val();
			$(".Budgets_"+cmid).each( function() {
					var error = $(this).val();
					var errObj = $(this).next().get(0);
					var budgetClassError = 0;
			if($(this).is(':visible') && $(this).val() == 0){
					budgetsError = 1;
					budgetClassError = 1;
					if(errObj) {
							queueMessage("Please select a budget to reassign the selected program", errObj);
					}
				}
	 		else {
				 	if($(this).is(':visible')){
				 		var partialBudget = $(this).attr("partialBudget");
				 		if(partialBudget == "1") {
				 			var programId = $(this).attr("programid");
				 			var partialBudgetSelected = $(this).val();
				 			var selName = $(this).attr("name");
				 			var partial_budget_start = new Date($('#Start_Date_' + selName + '_' + partialBudgetSelected).val());
				 			var partial_budget_end = new Date($('#End_Date_' + selName + '_' + partialBudgetSelected).val());
				 			var program_start = new Date($('#Program_Start_' + programId).val());
				 			var program_end = new Date($('#Program_End_' + programId).val());

							if(partial_budget_start > program_start || partial_budget_end < program_end){
				 				queueMessage("Budget selection is required for entire program period", errObj);
				 				budgetsError = 1;
				 				budgetClassError = 1;
				 			}
				 		}
				 	}
			 }
	 	 if(errObj && budgetClassError == 0) {
 			clearQueue(errObj);
 			}
	 });
		}
	});
	if (budgetsError == 0) {
		document.convertprograms.selectBudgets.value = 1;
		change();
	}
	else {
		showMessageWindow();
	}
}
function change(){
  		var pg_id = "";
  	$("input:checkbox[name=SelectedITEMS]:checked").each(function(){
		   pg_id = pg_id.concat($(this).val());
		   pg_id = pg_id.concat(',');
	});
		document.convertprograms.main_id.value = pg_id;
	    document.convertprograms.submit();
  }
function assign(cmid, val){
	var elem = document.forms.convertprograms.elements;
	elem['BusinessSegmentID_' + cmid].value = val;
}
function selectprogram(){
<cfoutput>
	<cfif appSettings.getFlexProgramSearch() EQ 1>
		 NewWindow("/Scorecard/program_Search.cfm", "programswindow", 1000, 600, "yes", "yes");
	<cfelseif appSettings.getFlexProgramSearch() EQ 2 OR appSettings.getFlexProgramSearch() EQ 3>
		NewWindow("/flex/search/ProgramSearchFx.cfm?Include_work_in_progress_below_me=1&importlist_type=1&userid=#cookie.user_id#&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=1&reassign_type=2", 'pro_search', '1000', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
	<cfelseif appSettings.getFlexProgramSearch() EQ 4 OR appSettings.getFlexProgramSearch() EQ 5>
		NewWindow("/programs/program_search.cfm?Include_work_in_progress_below_me=1&importlist_type=1&userid=#cookie.user_id#&Formname=reassign_program&Fieldname=Contract_Number&ReturnFieldname=Contract_Main_ID&AllowImportAll=1&Disable_Locked=1&Display_Deleted_Programs=1&reassign_type=2", 'pro_search', '1000', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
	</cfif>
</cfoutput>
}
$(document).ready(function()
{
	var arClassTypeObj;
	arClassTypeObj = $('[objtype=classtypeobj]');

	//loop through each radio for class type (calendar, fiscal, partial) and add event
	$(arClassTypeObj).each(function()
    {
    	//add onclick event for each class type radio
    	$(this).click(function(e) {
    		//radio has clastype=0_0, 1_0, 1_1
    		var v_classtype = $(this).attr("classtype");
    		var v_programid = $(this).attr("programid");
			//var v_budgetid = "Budgets_"+v_classtype+"_"+v_programid
			//show-hide tr based on which radio was clicked
			//when calendar is clicked, show tr for calendar and hide others
			var objTr;
			objTr = $('[name=tr_class_type_0_0_' + v_programid + ']');
			showHide(objTr, v_classtype);
			objTr = $('[name=tr_class_type_1_0_' + v_programid + ']');
			showHide(objTr, v_classtype);
			objTr = $('[name=tr_class_type_1_1_' + v_programid + ']');
			showHide(objTr, v_classtype);
		 });

		//when the checkbox isn't checked there isn't a attribute called checked.
		//when it is checked there will be a checked="checked" attribute.
		var attrChecked;
		attrChecked = $(this).attr("checked");
		if(attrChecked != "undefined" && attrChecked == "checked"){
			$(this).click();
		}
    })
});
function showHide(obj, classtype){
	$(obj).each(function()
    {
    	//if classtype matches show, otherwise hide
    	if($(this).attr("trclasstype") == classtype){
    		$(this).show();
    	}
    	else{
    		$(this).hide();
    	}

    })
}

</script>


</cfif>

<cfelse>

<table id="Templates" class="datagrid">
<thead>
<tr>
    <th>Template</th>
    <th>Description</th>
</tr>
</thead>
<tbody>

<cfoutput query="Templates">
<tr>
		 <td><a href="convert_programs.cfm?control_panel_id=#ProgramControl_Panel_Options_Id#">#Created_type#</a></td>
		 <td>#Program_Description#</td>
 </tr>
</cfoutput>

</tbody>
</table>


<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
var grid = $('#Templates').dataTable({
			"bAutoWidth": true
			,"bPaginate": false
			,"bSortClasses": false
			,"bScrollCollapse": true
			,"sDom": 'Rlfrtip'
			,"sScrollXInner": "100%"
			,"sScrollY": "400px"
			,"aaSorting": [[ 0, "asc" ]]
			,"aoColumns": [   {"sWidth": "50%"}
							, {"sWidth": "50%"}
							]
}).fnSetFilteringDelay();

$('table#Templates tr').hover (
	function() { $(this).addClass("over"); },
	function() { $(this).removeClass("over"); }
);

$('input,select').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();
</script>
</cfif>
</div>
