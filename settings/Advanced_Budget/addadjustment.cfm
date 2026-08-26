<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\addadjustment.cfm
      Date:     May 29, 2012
      Author:   Chris Nguyen
      Purpose:  Add budget adjustments
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="form.clicked_save" default="0">

<cfquery name="qBudget" datasource="#application.datasource#">
    SELECT Budget_desc
           , Budget_Code
           , Overlays
           , Overlay_Recapture
           , Recapture
           , Budget.Business_Segment_Id
           , bs.Business_Unit_Desc
           , Position_Control_Type
           , Allocation_Position_Level
           , Budget_Owner_Position_ID
           , bc.start_date
           , bc.end_date
		   , bc.Is_Fiscal
		   , bc.year_selection
      FROM Budget
     INNER JOIN Budget_Class bc ON Budget.Budget_Class_ID = bc.Budget_Class_ID
      LEFT JOIN Business_Segment bs ON Budget.Business_Segment_Id = bs.Business_Segment_Id
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif (qBudget.Is_Fiscal EQ 1)>
	<cfset qDateRanges = oBudgetClassManager.getFiscalDates( qBudget.year_selection ) />
<cfelse>
	<cfset qDateRanges = oBudgetClassManager.getCalendarDates ( qBudget.year_selection ) />
</cfif>

<cfif form.clicked_save eq "1">
  <cfset saveData()>
  <script>
  document.forms[budget_form].command.value = "listAdjustments";
  document.forms[budget_form].submit();
  </script>
</cfif>

<cfset vars.oBudgetAdjustmentManager = createObject('component','mvc.Models.AdvancedBudget.BudgetAdjustmentManager') />
<cfinvoke component="components.programs.business_segment.BusinessSegmentManager"
    		     method="isEnabledForBudget"
     returnVariable="busSegMgr.isEnabled">
</cfinvoke>

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" href="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css" type="text/css" />
<style>
#mainfieldset { width:98%; padding:1%; border:1px solid blue;}
#actions { margin:0 0 10px 5px; }
#actions a { margin:0 30px 0 0;}
.even { width:<cfif busSegMgr.isEnabled>33%<cfelse>50%</cfif>; }
.mid { text-align: center; }
div.save { margin-top:10px; }
.item {
	margin:15px;
}
.itemlabel {
	width:120px;
	font-weight:bold;
	text-align:right;
	margin-right:8px;
  display:inline-block;
  vertical-align: top;
}
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<!--------------------------------------------------------------------------------------------------------------------->
<cfset qAdjustmentTypes = vars.oBudgetAdjustmentManager.getBudgetAdjustmentTypes( active=1 ) />
<!--------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<fieldset id="mainfieldset">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Add Fixed Adjustment</legend>

<!---display heading--->
<div style="margin-top:5px" >
<table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr>
    <td class="even"><font size=2>Code: <b>#qBudget.budget_code#</b></font></td>
    <cfif busSegMgr.isEnabled>
      <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
    	<td class="even mid"><font size=2>#appSettings.getbusiness_segment_label()#: <b>#qBudget.Business_Unit_Desc#</b></font></td>
    </cfif>
    <td align=right class="even"><font size=2>Description: <b>#qBudget.budget_desc#</b></font></td>
  </tr>
</table>
<hr width=100%/>
</div>

<div id="actions">
 <a href="##" id="save">#application.util.string.actionLinkFormat("save")#</a>
 <a href="##" id="return">#application.util.string.actionLinkFormat("cancel & return to adjustments list")#</a>
</div>

<input type="hidden" name="selected_ids" id="selected_ids">

<div style="margin:1px">
	<div class="item">
		<label class="itemlabel" for="adjustment_dollar">Adjustment Amount:</label><span></span>
		<input type="text" name="adjustment_dollar" id="adjustment_dollar" class="numberinput">
	</div>
	<div class="item">
		<label class="itemlabel" for="adjustment_type">Adjustment Type:</label>
		<select name="adjustment_type" id="adjustment_type">
			<option value="0">select one</option>
			<cfloop query="qAdjustmentTypes">
				<option value="#qAdjustmentTypes.budget_adjustment_type_id#">#qAdjustmentTypes.description#</option>
			</cfloop>
		</select>
	</div>

  <div class="item">

<!--- <label class="itemlabel" for="start_date">Start:</label><span></span>
    <input type="text" name="start_date" id="start_date" class="itemvalue">
    <label class="itemlabel" for="end_date">End:</label><span></span>
    <input type="text" name="end_date" id="end_date" class="itemvalue">
 --->
 	<label class="itemlabel" for="single_period">Select Single Period:</label>
	<select name="single_period" id="single_period">
			<option value="0">select one</option>
		<cfloop query="qDateRanges">
				<option value="#qDateRanges.periodID#">#qDateRanges.start_Date# - #qDateRanges.end_Date#</option>
		</cfloop>
	</select>
	  <!--- <input type="hidden" name="start_date" id="start_date">
	  <input type="hidden" name="end_date" id="end_date"> --->

	  <input type="hidden" name="frmIsFiscal" id="frmIsFiscal" value="#qBudget.Is_Fiscal#">
	  <input type="hidden" name="frmYearSelection" id="frmYearSelection" value="#qBudget.year_selection#">
  </div>

	<div class="item">
		<label class="itemlabel" for="adjustment_notes">Adjustment Notes:</label>
		<textarea name="adjustment_notes" id="adjustment_notes" rows=2 cols=100></textarea>
	</div>
</div>

<cfif qBudget.Allocation_Position_Level eq "4">
	<cfinclude template="searchcustomers.cfm">
<cfelse>
	<cfinclude template="searchpositions.cfm">
</cfif>
</fieldset>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveData" output="true">
  <cfset var vars = {}>

	<cfif (FORM.frmIsFiscal EQ 1)>
		<cfset qDateRanges = oBudgetClassManager.getFiscalDates("#form.frmYearSelection#") />
	<cfelse>
		<cfset qDateRanges = oBudgetClassManager.getCalendarDates("#form.frmYearSelection#") />
	</cfif>

	<cfset useLakebaseForqFiscalSelected = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qdateranges")>
<cfif useLakebaseForqFiscalSelected>
	<cftry>
		<cfset qFiscalSelected = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qdateranges", {
				"periodid" = "eq.#form.single_period#",
				"select" = "start_date,end_date"
			}), "start_date,end_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqFiscalSelected = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqFiscalSelected>
<cfquery name="qFiscalSelected" datasource="#application.datasource#"  dbtype="query">
		SELECT start_Date, end_Date FROM qDateRanges WHERE periodID = #form.single_period#
	</cfquery>
</cfif>

	<cfloop list="#form.selected_ids#" index="vars.element_id">
		<cftransaction>
			<cfquery name="vars.update_db" datasource="#application.datasource#">
				INSERT Budget_Adjustment
				       ( Budget_Id
				        ,Budget_Adjustment_Type_ID
				        ,Adjustment_Dollar
                ,Start_Date
                ,End_Date
				        ,Adjustment_Notes
				        ,<cfif qBudget.Allocation_Position_Level eq "4">  <!---distributor level---> BSA_Foodservice_Customers_ID <cfelse> User_Positions_ID </cfif>
				        ,Created_By)
				VALUES ( <cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">
				        ,<cfqueryparam value="#form.adjustment_type#" cfsqltype="cf_sql_integer">
				        ,<cfqueryparam value="#form.adjustment_dollar#" cfsqltype="cf_sql_decimal" scale="2">
               			,<cfqueryparam cfsqltype="cf_sql_date" value="#qFiscalSelected.start_date#">
                		,<cfqueryparam cfsqltype="cf_sql_date" value="#qFiscalSelected.end_date#">
				        ,<cfqueryparam value="#form.adjustment_notes#" cfsqltype="cf_sql_varchar">
				        ,<cfqueryparam value="#vars.element_id#" cfsqltype="cf_sql_varchar">
				        ,<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
				        )

			  <!---calculate total of adjustments--->
			  DECLARE @Adjustment_Total DECIMAL
			  SELECT @Adjustment_Total = ISNULL(SUM(Adjustment_Dollar), 0)
	        FROM Budget_Adjustment
	       WHERE Budget_ID = <cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">
							 AND Deleted = 0
							 AND <cfif qBudget.Allocation_Position_Level eq "4">   <!---distributor level---> BSA_Foodservice_Customers_ID <cfelse> User_Positions_ID </cfif>
							 		 = <cfqueryparam value="#vars.element_id#" cfsqltype="cf_sql_varchar">

				<!---apply adjustments to budget allocation--->
				<cfif qBudget.Allocation_Position_Level eq "4">   <!---distributor level--->
					UPDATE Budget_Distributor_Allocation
					   SET Adjustment_Dollar = @Adjustment_Total
					       ,Budget_Dollar = ISNULL(Original_Budget_Dollar,0) + @Adjustment_Total
					 WHERE Budget_ID = <cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">
					       AND BSA_Foodservice_Customers_ID = <cfqueryparam value="#vars.element_id#" cfsqltype="cf_sql_varchar">

				<cfelse>       <!---position level--->
					UPDATE Budget_Position_Allocation
					   SET Adjustment_Dollar = @Adjustment_Total
					       ,Budget_Dollar = ISNULL(Original_Budget_Dollar, 0) + @Adjustment_Total
					 WHERE Budget_ID = <cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">
	               AND User_Position_ID = <cfqueryparam value="#vars.element_id#" cfsqltype="cf_sql_varchar">
				</cfif>
			</cfquery>
		</cftransaction>
	</cfloop>

  <cfquery name="vars.saveRow" datasource="#application.datasource#">
    <cfinclude template="last_update.cfm">       <!--- 36874 --->
  </cfquery>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>
<script>
<!---event for create-------------------------------------------------------------------------------------------------->
$('#save').click(function(){
	var errors = [], todayDate = new Date();;
	var test_value = $.Trim( $('input[name="adjustment_dollar"]').val() );
	if (test_value == '') {
		errors.push('Please enter an adjustment amount.');
	}
	else if ( ! $.IsNumeric( test_value )	) {
		errors.push('Please enter a valid adjustment amount.');
	}

	if ( $('#adjustment_type').val() == 0 ) {
		errors.push('Please select an adjustment type.');
	}

	if ( $('#single_period').val() == 0 ) {
		errors.push('Please select a Period');
	}


 //  var start_date = $.Trim( $('input[name="start_date"]').val() );
  <cfoutput>
  <!--- if (start_date == '') {
    errors.push('Please enter a starting date.');
  }
  else if ( $.DateDiff('d', todayDate, start_date ) > 0 ) {
    errors.push('Starting date cannot be in the future.');
  }
  else if (( $.DateDiff('d', start_date, "#dateFormat(qBudget.start_date,'m/d/yyyy')#" ) > 0 )
           || ( $.DateDiff('d', "#dateFormat(qBudget.end_date,'m/d/yyyy')#", start_date ) > 0 )) {
    errors.push('Starting date cannot be outside of budget date range.');
  }

  var end_date = $.Trim( $('input[name="end_date"]').val() );
  if (end_date == '') {
    errors.push('Please enter an ending date.');
  }
  else if ( $.DateDiff('d', todayDate, end_date ) > 0 ) {
    errors.push('Ending date cannot be in the future.');
  }
  else if ( start_date !== '' && $.DateDiff('d', end_date, start_date ) > 0 ) {
    errors.push('Starting date cannot be later than ending date.');
  }
  else if (( $.DateDiff('d', end_date, "#dateFormat(qBudget.start_date,'m/d/yyyy')#" ) > 0 )
           || ( $.DateDiff('d', "#dateFormat(qBudget.end_date,'m/d/yyyy')#", end_date ) > 0 )) {
    errors.push('Ending date cannot be outside of budget date range.');
  } --->
  </cfoutput>

	if ( $('#adjustment_notes').val().length > 200 ) {
		errors.push('Please limit adjustment notes to 200 characters.');
	}

	if ( $('input:checked', mydatagrid.fnGetNodes()).length == 0 ) {
		errors.push('Please select at least one ' + <cfif qBudget.Allocation_Position_Level eq "4">'distributor.'<cfelse>'position.'</cfif>);
	}

  if ( errors.length ) {
    alert( errors.join('\n') );
	}
	else {
		$('#selected_ids').val( $('input:checked', mydatagrid.fnGetNodes())
																			.map(function() { return this.id } )
																			.get()
																			.join(',') );
	  document.forms[budget_form].command.value = "saveAdjustment";
	  document.forms[budget_form].clicked_save.value = "1";
	  document.forms[budget_form].submit();
	  return false;
	}
});
$('#return').click(function(){
  document.forms[budget_form].command.value = "listAdjustments";
  document.forms[budget_form].submit();
  return false;
});
<!--------------------------------------------------------------------------------------------------------------------->
$( "#start_date" ).datepicker( {  defaultDate: ""
                                 ,changeMonth: true
                                 ,numberOfMonths: 3
                                 <cfoutput>
                                 ,minDate: "#dateFormat(qBudget.start_date,'m/d/yyyy')#"
                                 ,maxDate: "#dateFormat(qBudget.end_date,'m/d/yyyy')#"
                                 </cfoutput>
                                 ,onClose: function( selectedDate ) {
                                    $( "#end_date" ).datepicker( "option", "minDate", selectedDate );
                                  }
                               });
$( "#end_date" ).datepicker( {  defaultDate: ""
                               ,changeMonth: true
                               ,numberOfMonths: 3
                               <cfoutput>
                               ,minDate: "#dateFormat(qBudget.start_date,'m/d/yyyy')#"
                               ,maxDate: "#dateFormat(qBudget.end_date,'m/d/yyyy')#"
                               </cfoutput>
                               ,onClose: function( selectedDate ) {
                                  $( "#start_date" ).datepicker( "option", "maxDate", selectedDate );
                                }
                             });
<!--------------------------------------------------------------------------------------------------------------------->
</script>



