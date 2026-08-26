<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\budget_display.cfm
      Date:     July 29, 2011
      Author:   Chris Nguyen
      Purpose:  Assign budgets for a program

      Notes:    This page is called from 2 places:

                A. LH panel:
                    - This template is called from a JS popup function
                    - Page content is displayed on a stand-alone popup window
                    - Program summary is the parent opener window
                    - When users are done, this window is closed & parent data handler function is called

                B. RFA process:
                    - This template is included in the RFA main template
                    - There is no parent opener window
                    - Users are redirected to the appropriate pages (specified in url.cancel_page & url.save_page)
                      when done
----------------------------------------------------------------------------------------------------------------------->
<html>
<head>
<title>Program - Budgets</title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/impromptu.css">
<style type="text/css">
#actp727 { margin-top:10px; text-align:center }
#budget_form { margin-top:10px; }
#cancel729 { margin-left:30px; }
#fs727 { margin:0; padding:0 0px 0 0; border:0 none; border-top:1px solid; width:100%; clear:both; }
#fs727 legend { margin:3px 0 0 0; padding:0 5px; font:bold 16px; }
#hdr727 { font:bold 20px "Times New Roman"; color:red; margin:0; float:left;}
#tp727 { font:normal 12px; float:right; position:relative; top:10px; }
</style>
</head>
<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->
<body>

<!---save passing url parameters from parent template into form--->
<cfset structAppend(form, url)>

<cfparam name="form.Program_ID"    default="0">
<cfparam name="form.data_handler"  default="">      <!---callback function for refreshing info on parent window--->
<cfparam name="form.save_page"     default="">      <!---URL to go to after clicking save action--->
<cfparam name="form.cancel_page"   default="">      <!---URL to go to after clicking cancel action--->
<cfparam name="form.reassign"      default="0">     <!---called from reassign option--->
<cfparam name="form.clicked_save"  default="">
<cfparam name="form.previousupdatecommitteddollar"  default="0"> <!---  D50326 --->
<cfparam name="form.CurrentUpdateCommitteddollar" default="0"> <!---  D50326 --->
<cfparam name="UpdateCommittedToActual" default="0"> <!---  D50326 --->
<cfparam name="CommittedToActualChangeFromNoToYes" default="0"> <!---  D50326 --->
<cfparam name="url.fromprogram" default="0">
<cfoutput>

<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<!---get program info--->
<cfset program = CreateObject("component", "components.programs.Program") />
<cfset qGetProgramInfo = program.getProgramInfo(form.Program_ID) />
<cfset qGetProgramCompleteSpan = program.getProgramCompleteSpan(form.Program_ID, qGetProgramInfo.Contract_Number) />

<!----- Save form into the database, close window or redirect----->
<cfif form.clicked_save eq "1">

  <!---  D50326 :: Tru-up to Actuals Button in Program Start--->
  <cfif qGetProgramInfo.Manual_Committed_Equal_Actual>
  	<cfquery name="UpdateCommited" datasource="#application.datasource#">
	  	UPDATE Contract_Main_Aux_Data
		SET    Set_Committed_Equal_Actual =  #form.CurrentUpdateCommitteddollar#, Set_Committed_Actual_Updated_By= '#request.AccessStructure.User_ID#',Set_Committed_Actual_Updated_Date= #now()#
		FROM   Contract_Main_Aux_Data 
		INNER JOIN Contract_Main 
		ON Contract_Main.Contract_Main_ID =  Contract_Main_Aux_Data.Contract_Main_ID
		WHERE contract_number = '#qGetProgramInfo.Contract_Number#'
		AND Contract_Main.Deleted = 0
  	</cfquery>
  </cfif>
  <cfif form.previousupdatecommitteddollar NEQ form.CurrentUpdateCommitteddollar>
	  <cfset UpdateCommittedToActual =1>
  </cfif>
    <cfif form.previousupdatecommitteddollar EQ 0 AND form.CurrentUpdateCommitteddollar>
	  <cfset CommittedToActualChangeFromNoToYes =1>
  </cfif>
  <!---  D50326 :: Tru-up to Actuals Button in Program END--->

  <!--- contains fn save_budgets_all_versions() --->
  <cfinclude template="budget_save_functions.cfm" />

  <cfset save_budgets_all_versions(form.Program_ID, buildBudgetArray(),UpdateCommittedToActual,CommittedToActualChangeFromNoToYes)>
  <script type="text/javascript">
    <cfif len(form.data_handler)>
      <!---send the selected budgets to the opener window for refresh--->
      window.opener.#FORM.data_handler#( '#FORM.selected_budgets#' );
    </cfif>
    <cfif len(form.save_page)>
      window.location = '#form.save_page#';
    <cfelse>
      window.close();
    </cfif>
  </script>
</cfif>



<!---get budgets info--->
<cfstoredproc procedure="Adv_Budget_Get_Pgm_Budget_List"
    dataSource="#application.datasource#"
    returnCode="Yes"
    debug="Yes">
   <cfprocresult name=vars.qBudgets>
   <cfprocparam type="in" cfsqltype = cf_sql_integer value="#form.program_id#" dbVarName = @program_id>
   <cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @user_position_id>
   <cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @new_template_id>
   <cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @new_business_segment_id>
   <cfprocparam type="in" cfsqltype = cf_sql_integer value="#application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetSelectionRequired()#" dbVarName = @budget_required_complete_span>
</cfstoredproc>

<!---gather year type on revised from program--->
<cfquery name="vars.orig_budget_program_selection" datasource="#application.datasource#">
	SELECT TOP 1 bc.is_fiscal, bc.partial_year
	FROM Contract_Main a
	INNER JOIN Budget_Program_Selection c ON c.Program_ID = a.Revision_Of_Contract_Main_Id
	INNER JOIN Budget b ON b.Budget_ID = c.Budget_ID
	INNER JOIN Budget_Class bc ON b.Budget_Class_ID = bc.Budget_Class_ID
	WHERE a.Contract_Main_ID = <cfqueryparam value="#form.program_id#" cfsqltype="cf_sql_integer">
	AND a.Is_A_Revision = 1
</cfquery>

<!---gather selected budgets--->
<cfquery name="vars.budget_program_selection" datasource="#application.datasource#">
	SELECT a.Budget_ID, bc.Is_Fiscal, bc.partial_year
	FROM Budget_Program_Selection a
	INNER JOIN Budget b ON b.Budget_ID = a.Budget_ID
	INNER JOIN Contract_Main m ON m.Contract_Main_ID = a.Program_ID
	LEFT JOIN Budget_Class bc ON b.Budget_Class_ID = bc.Budget_Class_ID
	WHERE Program_ID = <cfqueryparam value="#form.program_id#" cfsqltype="cf_sql_integer">
</cfquery>
<!---heading--->
<div id="hdr727">#application.returned_customer_setting.company_name#</div>
<div id="tp727"><b>Template:</b> #qGetProgramInfo.Created_Type#</div>
  <!---  D50326 :: Tru-up to Actuals Button in Program START--->
<!---gather last updated by INFO--->
<cfquery name="Get_Editor_Info" datasource="#application.datasource#">
	Select U.Name_First+' '+U.Name_Last AS Name
	From _users  U
	Where U.user_id ='#qGetProgramInfo.Set_Committed_Actual_Updated_By#'
</cfquery>
<CFIF Get_Editor_Info.RecordCount GT 0>
<br/><br/>
<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="3" ALIGN="CENTER" STYLE="border:2px orange solid;" >
	<TR>
	<TD STYLE="font-weight:bold;font-size:13px;">This setting was last updated on #DateFormat(qGetProgramInfo.Set_Committed_Actual_Updated_Date, "mm/dd/yyyy")# #TimeFormat(qGetProgramInfo.Set_Committed_Actual_Updated_Date, "hh:mm:ss tt")# by #Get_Editor_Info.Name#</TD>
	</TR>
</TABLE>
</CFIF>
  <!---  D50326 :: Tru-up to Actuals Button in Program END--->
<fieldset id="fs727">
<legend Style="font-weight:bold;font-size:13px;padding-top:5px;">#qGetProgramInfo.Contract_Number# - #qGetProgramInfo.Contract_Title#</legend>

<!---collect url variables and include them in action attribute--->
<cfset vars.query_string = "">
<cfloop collection="#url#" item="vars.piece">
	<cfset vars.query_string = vars.query_string
																& "&"
																& vars.piece
																& "="
																& urlencodedformat( url[ vars.piece ] )>
</cfloop>
<form id="budget_form" action="budget_display.cfm?#vars.query_string#" method="post">
<!---count number of year types--->
<cfquery name="vars.qYearType" dbtype="query">
	SELECT DISTINCT is_fiscal, partial_year FROM vars.qBudgets
</cfquery>

<cfset year_type_displayed = 0 />
<!---there is only one year type, do not display year type dropdown--->
<cfif vars.qYearType.recordCount lt 2>
	<cfscript>
		form.is_fiscal = vars.qYearType.is_fiscal;
		form.partial_year = vars.qYearType.partial_year;
	</cfscript>
<!---get original year type for revised program--->
<cfelseif vars.orig_budget_program_selection.recordcount>
	<cfscript>
		form.is_fiscal = vars.orig_budget_program_selection.is_fiscal;
		form.partial_year = vars.orig_budget_program_selection.partial_year;
	</cfscript>
<cfelse>
	<!---budget was previously selected & saved, choose the same year type on first time this page is displayed (form.is_fiscal does not exist)--->
	<cfif vars.budget_program_selection.recordCount and not structkeyexists(form, "is_fiscal")>
		<cfscript>
		  form.is_fiscal = vars.budget_program_selection.is_fiscal;
			form.partial_year = vars.budget_program_selection.partial_year;
		</cfscript>
	</cfif>

	<cfparam name="form.is_fiscal"    default="9">
	<cfparam name="form.partial_year" default="0">
	
	<cfset year_type_displayed = 1 />
	<!---display year type dropdown if fiscal & calendar exist--->
	<div style="margin-bottom:12px;">
		<label style="margin-right:7px;"><b>Budget Year Type:</b></label>
		<input type="hidden" name="partial_year" id="partial_year">
		<select name="is_fiscal" id="year_type">
			<option <cfif form.is_fiscal eq "9">selected=selected</cfif> value="9">Select option</option>
			<option <cfif form.is_fiscal eq "1" and form.partial_year eq "0">selected=selected</cfif> value="1">Fiscal</option>
			<option <cfif form.is_fiscal eq "0">selected=selected</cfif> value="0">Calendar</option>
			<option <cfif form.is_fiscal eq "1" and form.partial_year eq "1">selected=selected</cfif> value="1">Fiscal (partial year)</option>
		</select>
	</div>
</cfif>
</cfoutput>
<!---datagrid--->
<div id="datatable">
<cfoutput>
<input type="hidden" id="Program_Start" value="#Dateformat(qGetProgramCompleteSpan.Program_Start, 'mm/dd/yyyy')#">
<input type="hidden" id="Program_End" value="#Dateformat(qGetProgramCompleteSpan.Program_End, 'mm/dd/yyyy')#">
</cfoutput>
<table id="budgets" class="datagrid">
<thead>
<tr>
 <th>Budget Class</th>
 <th>Budget Description (Type)</th>
</tr>
</thead>
<tbody>
<cfif form.is_fiscal eq "0" or form.is_fiscal eq "1">
	<cfoutput query="vars.qBudgets" group="Budget_Class_Desc">
			<!---filter out budgets with different year type--->
			<cfif vars.qBudgets.is_fiscal eq form.is_fiscal and vars.qBudgets.partial_year eq form.partial_year>
				<!---count number of budgets in the current class--->
				<cfquery name="vars.qCount" dbtype="query">
				  SELECT COUNT(*) AS Result
				    FROM vars.qBudgets
				   WHERE Budget_Class_Desc = '#vars.qBudgets.Budget_Class_Desc#'
				         AND partial_year = '#form.partial_year#'
				</cfquery>
				<tr>
				 <td>#vars.qBudgets.Budget_Class_Desc#</td>
				 <!---if there is more than one budget in the class users would have to make the selection otherwise check the radio button automatically--->
				 <td><cfoutput><cfif vars.qBudgets.Budget_Id neq "">
				  <cfquery name="vars.qExists" dbtype="query">
				    SELECT 1
				      FROM vars.Budget_Program_Selection
				     WHERE Budget_Id = #vars.qBudgets.Budget_Id#
				  </cfquery>
				  <input <cfif form.partial_year eq "1">
				  			   name="C_PARTIAL_YEAR"
				  			   id="C_PARTIAL_YEAR"
				  				 <cfif (vars.qExists.RecordCount gt 0)>checked=checked</cfif>
				  			 <cfelse>
				  				 name="C_#vars.qBudgets.Budget_Class_ID#"
				  				 <cfif (vars.qCount.Result eq 1) or (vars.qExists.RecordCount gt 0)>checked=checked</cfif>
				  			 </cfif>
				  			type="radio" value="#vars.qBudgets.Budget_ID#"><span class="descr">#vars.qBudgets.Budget_Desc#</span> (#vars.qBudgets.Contribution_Factor_Type#)<br/>
				  <input type="hidden" id="Start_Date_#vars.qBudgets.Budget_ID#" value="#DateFormat(vars.qBudgets.Start_Date, 'mm/dd/yyyy')#">
				  <input type="hidden" id="End_Date_#vars.qBudgets.Budget_ID#" value="#DateFormat(vars.qBudgets.End_Date, 'mm/dd/yyyy')#">
				</cfif></cfoutput></td>
				</tr>
			</cfif>
	</cfoutput>
</cfif>
</tbody>
<!---  D50326 :: Tru-up to Actuals Button in Program START--->
<cfoutput>
<cfif qGetProgramInfo.Manual_Committed_Equal_Actual AND url.fromprogram>
	<cfquery name="dollaramount" datasource="#application.datasource#">
		DECLARE @Committed_Dollar decimal(20, 4),
		            @Actual_Dollar decimal(20, 4)

		SELECT @Committed_Dollar = SUM(pg.Committed_Dollar), 
		           @Actual_Dollar = SUM(pg.Actual_Dollar)
		FROM  Budget_Position_Program pg
		WHERE pg.Contract_Number = '#qGetProgramInfo.Contract_Number#'

		SELECT  @Committed_Dollar = ISNULL(@Committed_Dollar, 0) + ISNULL(SUM(pg.Committed_Dollar), 0), 
		             @Actual_Dollar = ISNULL(@Actual_Dollar, 0) + ISNULL(SUM(pg.Actual_Dollar), 0)
		FROM  Budget_Distributor_Program pg
		WHERE pg.Contract_Number = '#qGetProgramInfo.Contract_Number#'

		SELECT @Committed_Dollar as Committed_Dollar, @Actual_Dollar as Actual_Dollar	
	</cfquery>
<tfoot>
	<tr>
		<th colspan="2">Set Committed $ to equal Actual $</th>
	</tr>
	<tr>
		<td colspan="2">
			<div style="width:100%;padding-top:5px;">Committed $&nbsp;:&nbsp; #dollarformat(dollaramount.Committed_Dollar)#</div>
			<div style="width:100%;padding-top:5px;">Current actual $&nbsp;:&nbsp; #dollarformat(dollaramount.Actual_Dollar)#</div>
			<div style="width:100%;padding-top:5px;">Update Committed $ to Actual $ <input type="checkbox" name="CurrentUpdateCommitteddollar" value="1" <cfif qGetProgramInfo.Set_Committed_Equal_Actual>CHECKED</cfif>/></div>
			<input type="hidden" name="previousUpdateCommitteddollar" value="#qGetProgramInfo.Set_Committed_Equal_Actual#" />
		</td>		
	</tr>
</tfoot>
</cfif>
</cfoutput>
<!---  D50326 :: Tru-up to Actuals Button in Program END--->
</table>
</div>   <!---datatable--->

<cfoutput>
<div id="actp727">
 <!---display save option when year type is not "Select option"--->
 <cfif form.is_fiscal neq "9">
 	<a href="##" id="save_budgets">#LCase(ActionText("save"))#</a>
 </cfif>
 <a href="##" id="cancel729">#LCase(ActionText("close window"))#</a>
</div>
<input type="hidden" name="clicked_save" id="clicked_save">
<input type="hidden" name="selected_budgets" id="selected_budgets">
</cfoutput>
</form>
</fieldset>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="buildBudgetArray" output="true" returntype="Array">
  <cfset var vars = {}>

  <!--- start - scan thru all selected budgets and build an array of struct --->
  <cfset vars.arBudgetList = ArrayNew(1) />
  <cfloop collection="#form#" item="vars.item">
    <cfif Left(vars.item, 2) eq "C_">
    	<cfif vars.item neq "C_PARTIAL_YEAR">
    		<cfset vars.Budget_Class_ID = Right(vars.item, Len(vars.item) - 2)>
    	<cfelse>
    		<!--- grap budget class id from db for partial year --->
	      <cfset vars.useLakebaseForBudgetClass = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget")>
	      <cfif vars.useLakebaseForBudgetClass>
	      	<cftry>
	      		<cfset vars.budget_class = application.oLakebase.toQuery(
	      			application.oLakebase.selectRows("budget", { "select" = "budget_class_id", "budget_id" = "eq.#form[vars.item]#" })
	      		)>
	      		<cfcatch type="any">
	      			<cfset vars.useLakebaseForBudgetClass = false>
	      		</cfcatch>
	      	</cftry>
	      </cfif>
	      <cfif NOT vars.useLakebaseForBudgetClass>
	      	<cfquery name="vars.budget_class" datasource="#application.datasource#">
	      		SELECT Budget_Class_ID
	      		  FROM Budget
	      		 WHERE Budget_ID = <cfqueryparam value="#form[vars.item]#" cfsqltype="cf_sql_integer">
					</cfquery>
				</cfif>
				<cfset vars.Budget_Class_ID = vars.budget_class.Budget_Class_ID>
			</cfif>
		<cfset vars.stBudgetSelection = StructNew() />
		<cfset vars.stBudgetSelection.BudgetClassID = vars.Budget_Class_ID />
		<cfset vars.stBudgetSelection.BudgetID = form[vars.item] />
		<cfset ArrayAppend(vars.arBudgetList, vars.stBudgetSelection) />
    </cfif>
  </cfloop>
  <!--- end - scan thru all selected budgets and build an array of struct --->

  <cfreturn vars.arBudgetList />

</cffunction>


<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery-impromptu.3.1.min.js"></script>
<script type="text/javascript">
var datagrid = $('table.datagrid').dataTable({
	 "bAutoWidth": false
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 't'
  ,"sScrollXInner": "100%"
  ,"aaSorting": [[ 0, "asc" ]]
  ,"aoColumns": [
                    {"sWidth": "30%", "bSortable":true, "bSearchable":false}
                  , {"sWidth": "70%", "bSortable":false, "bSearchable":false}
                ]
});
$('#datagrid tr').hover (
  function() { $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);
<!---$.prompt.setDefaults({ prefix:'cleanblue', top:'25%' });   <!---default to blue style on all prompts--->--->
<!---events for cancel action----------------------------------------------------------------------------------------->
$('#cancel729').click(function(e) {
 e.preventDefault();
 <cfoutput>
 <cfif len(form.cancel_page)>
  window.location = '#form.cancel_page#';
 <cfelse>
  window.close();
 </cfif>
 </cfoutput>
});
<!---partial year(): returns 1 when partial year is selected otherwise returns 0 ------------------------------------>
partial_year = function() {
	<cfif year_type_displayed eq 0 AND form.partial_year EQ 1>
	return 1;
	<cfelse>
	return ($('#year_type option:selected').text().toUpperCase().indexOf('PARTIAL') > 0 ? 1 : 0) ;
	</cfif>
}
<!---events for save action----------------------------------------------------------------------------------------->
$('#save_budgets').click(function(e) {
 var error_count = 0, budgets = '', selected_budgets_count = 0, selected_partial_budget_id = 0;
 e.preventDefault();

var budget_required = <cfoutput>#(application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetSelectionRequired() ? 1 : 0)#</cfoutput>;

<!---scan thru each row (budget class), make sure there is one checked radio button--->
 $('.datagrid tbody tr').each( function() {
  var $this = $(this);
  selected_budgets_count += $this.find('input:checked').length;  
  if ( budget_required && !partial_year() && $this.find('input[type=radio]:checked').length == 0 ) {
  	<!---found one row (budget class) without checked radio button--->
    $.prompt( 'Please select the appropriate budget for ' + $(this).find('td:eq(0)').text() );
    ++error_count;
  }
  else {
    <!---collect all selected budgets--->
	var checkedObj = $(this).find('input:checked');
    budgets = budgets + checkedObj.next().text() + '<br>';
    if ( partial_year() && checkedObj.length != 0 ){
    	selected_partial_budget_id = checkedObj.val();
    }
  }
 });


//Above we are not validating for partial year budget selection
if (budget_required && error_count == 0 && selected_budgets_count == 0) {
	$.prompt( 'Please select a budget');
    ++error_count;
}

//
if (partial_year() && selected_partial_budget_id != 0) {
	var partial_budget_start = new Date($('#Start_Date_' + selected_partial_budget_id).val());
	var partial_budget_end = new Date($('#End_Date_' + selected_partial_budget_id).val());
	var program_start = new Date($('#Program_Start').val());
	var program_end = new Date($('#Program_End').val());
	if(budget_required && partial_budget_start > program_start || partial_budget_end < program_end){
		$.prompt( 'Budget selection is required for entire program period');
    	++error_count;
	}
}

 if ( error_count == 0 ) {
  $('#selected_budgets').val(budgets);   <!---save selected budgets in the posting form--->
  $('#clicked_save').val("1");
  $('#budget_form').submit();
 }
});
/*reload the page with selected year type*/
$('#year_type').change(function() {
	// populate partial year based on selected year type
	$('#partial_year').val( partial_year() );
	$('#budget_form').submit();
});
</script>
</body>
</html>

<!---need to cfabort here, if we don't in RFA process this page would be closed--->
<cfabort>