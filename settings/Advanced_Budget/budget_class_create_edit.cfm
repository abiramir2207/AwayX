<!---
	Name:          	budget_class_create_edit.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	05/19/2011
	Created By:    	Deepa Kunnath
	Description:   	This page is the UI for creating and editing budget class
	Parameters:
	Usage:
--->
<style>
td.label {
  text-align: right;
  padding-right: 15px;
  font-weight: bold;
}
.partial-date { display:none; }
</style>

<!--- <cfset oBudgetClassManager = createObject('component','mvc.Models.AdvancedBudget.BudgetClassManager') /> --->

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<cfif form.clicked_save eq "1">
	<!---<cfdump var="#form#" abort="true">--->
  <cfscript>
	  oBudgetClass        = oBudgetClassManager.getSingleBudgetClass(0);
	  oBudgetClass.id     = form.budget_class_id;
	  oBudgetClass.number = form.BudgetClassNumber;
	  oBudgetClass.desc   = form.BudgetClassDesc;
	  oBudgetClass.isFiscal = form.IsFiscal;
	  if ( oBudgetClass.isFiscal )
	  	oBudgetClass.year = form.Fiscal_Year;
	  else
	  	oBudgetClass.year = form.Calendar_Year;
	  oBudgetClass.active = form.Active;
	  
	  if ( structKeyExists(form, 'partial_year') and form.partial_year eq 'on' ) {
	  	oBudgetClass.partial_year = 1;
	  	oBudgetClass.startdate   = form.start362;
	  	oBudgetClass.enddate     = form.end362;
	  }
	  oBudgetClassManager.saveBudgetClass(oBudgetClass);
  </cfscript>
	<cflocation url="index.cfm?command=listbudgetclass">

<cfelseif form.command eq "deleteBudgetClass">
  <cfset vars = {}>
  <cfquery name="vars.delete" datasource="#application.datasource#">
    UPDATE Budget_Class
       SET Deleted = 1
     WHERE Budget_Class_Id = <cfqueryparam value="#form.Budget_Class_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
	<cflocation url="index.cfm?command=listbudgetclass">
</cfif>

<cfset oBudgetClass = oBudgetClassManager.getSingleBudgetClass(form.budget_class_id) />
<cfset qFiscalYear = oBudgetClassManager.getFiscalYear() />
<cfset qCalendarYear = oBudgetClassManager.getCalendarYear() />
<cfset qFiscalDates = oBudgetClassManager.getFiscalDates( oBudgetClass.year ) />
<cfoutput>

<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Budget Class - 
			<cfif form.budget_class_id eq "0">
			Add
		<cfelse>
			<cfif ! qGetCreateBudget.Create_Budget>
				View
			<cfelse>
				Edit
			</cfif>
		</cfif>
	</legend>
<div style="margin:15px">
<table cellspacing="5"

	<tr>
		<td class="label">Code:</td>
		<td><input type="text" name="BudgetClassNumber" value="#oBudgetClass.number#" size=10 maxlength=10 <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>></td>
	</tr>

	<tr>
		<td class="label">Description:</td>
		<td><input type="text" name="BudgetClassDesc" value="#oBudgetClass.desc#" size=50 maxlength=50 <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif> ></td>
	</tr>

	<tr>
		<td class="label">Year Type:</td>
		<td>
			<input type="radio" name="IsFiscal" value="1" <cfif oBudgetClass.isFiscal eq 1>checked</cfif> onClick="show_year_type()" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>> Fiscal
			&nbsp;&nbsp;&nbsp;
			<input type="radio" name="IsFiscal" value="0" <cfif oBudgetClass.isFiscal eq 0>checked</cfif> onClick="show_year_type()" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>> Calendar
		</td>
	</tr>

	<tr id="id_fiscal_year">
		<td class="label">Year:</td>
		<td>
			<select name="Fiscal_Year" id="fiscal_year" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
				<option value="">*** Select Fiscal Year ***</option>
				<cfloop query="qFiscalYear">
					<option value="#Fiscal_Year#" <cfif oBudgetClass.year eq Fiscal_Year>selected</cfif>>#Fiscal_Year#</option>
				</cfloop>
			</select>
		</td>
	</tr>

	<tr  id="id_calendar_year">
		<td class="label">Year:</td>
		<td>
			<select name="Calendar_Year" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
				<option value="">*** Select Calendar Year ***</option>
				<cfloop query="qCalendarYear">
					<option value="#year#" <cfif oBudgetClass.year eq year>selected</cfif>>#year#</option>
				</cfloop>
			</select>
		</td>
	</tr>

	<tr id="partial-yr" <cfif oBudgetClass.isFiscal> <cfelse>style="display:none;"</cfif>>
		<td class="label">Partial Year:</td>
		<td>
			<input type="checkbox" name="Partial_Year" id="partial-year-cbox" <cfif oBudgetClass.Partial_Year>checked</cfif> <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>> To create a budget that is less than a fiscal year, check this box.
		</td>
	</tr>

	<tr class="partial-date">
		<td class="label">Start Date:</td>
		<td>
			<select id="start362" name="start362" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
				<option value=''>Select a Date</option>
				<cfloop query="qFiscalDates">
					<option <cfif dateDiff('d', qFiscalDates.start_date, oBudgetClass.startdate) eq 0>selected=selected</cfif>>#qFiscalDates.start_date#</option>
				</cfloop>
			</select>
		</td>
	</tr>

	<tr class="partial partial-date">
		<td class="label">End Date:</td>
		<td>
			<select id="end362" name="end362" <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>>
				<option value=''>Select a Date</option>
				<cfloop query="qFiscalDates">
					<option <cfif dateDiff('d', qFiscalDates.end_date, oBudgetClass.endDate) eq 0>selected=selected</cfif>>#qFiscalDates.end_date#</option>
				</cfloop>
			</select>
		</td>
	</tr>

	<tr>
		<td class="label">Active:</td>
		<td>
			<input type="radio" name="Active" value="1" <cfif oBudgetClass.active eq 1>checked</cfif> <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>> Yes
			&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Active" value="0" <cfif oBudgetClass.active eq 0>checked</cfif> <cfif ! qGetCreateBudget.Create_Budget>disabled</cfif>> No
		</td>
	</tr>

</table>
</div>
</cfoutput>

<!----- Save / Cancel Buttons ----->
<div style="float:left; margin:10px 0 0 20px">
 <cfoutput>
 	 <cfif qGetCreateBudget.Create_Budget>
 		<a href="##" onclick="save_class()">#LCase(ActionText("save"))#</a>
 	</cfif>
 		<a href="javascript:window.location='index.cfm?command=listBudgetClass'" style="margin:30px">#LCase(ActionText("return to budget classes list"))#</a>
 </cfoutput>
</div>
</fieldset>


<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>

<script type="text/javascript">
  function show_year_type(){
	if(document.all.IsFiscal[0].checked){
		document.getElementById('id_fiscal_year').style.display = '';
		document.getElementById('id_calendar_year').style.display = 'none';
	}
	else{
		document.getElementById('id_calendar_year').style.display = '';
		document.getElementById('id_fiscal_year').style.display = 'none';
	}	
  }
  show_year_type();

function save_class() {
	// 35439 - partial year box is checked make sure ending date is later than starting date
	if ( $('#partial-year-cbox').prop('checked') ) {
		if ( $.DateDiff('d', $('#start362').val(), $('#end362').val()) < 0 ) {
			alert( "Ending date must be later than starting date, please make a correction." );
			return false;
		}
	}
	
  document.forms[budget_form].command.value = "saveBudgetClass";
  document.forms[budget_form].clicked_save.value = "1";
  document.forms[budget_form].submit();
}
// $('input').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$("input[name=IsFiscal]").change(function () { 
	// fiscal year is selected show partial year checkbox
	if ( $(this).val() == '1' ) {
		$('#partial-yr').show();
	} 
	else {
		// calendar year is selected hide partial year & start/end date
		$('#partial-yr, .partial-date').hide();
		// change partial year checkbox to NOT checked
		$('#partial-year-cbox').prop('checked', false);
	} 
} );

refreshDates = function() {
	// reset options inside dates dropdown		
	$("#start362, #end362").children().remove().end().append("<option value=\"\">Select a Date</option>");		
	
	// gather period starting dates, ending dates when fiscal year has a value
	if ( $('#fiscal_year').val() ) {
		 $.ajax( {  url: "/mvc/Models/AdvancedBudget/BudgetClassManager.cfc"
		 	         ,dataType: "json"
		 	         ,data: {  method: "getFiscalDates2", fiscal_year: $('#fiscal_year').val() }
		 	         ,success: function( json ) { var newoptions1 = "", newoptions2 = "";
																		        for(var i=0; i<json.length; i++) {
																              newoptions1 += "<option>" + json[i].START_DATE + "</option>";
																              newoptions2 += "<option>" + json[i].END_DATE + "</option>";
																		        }
																		        // load new options into date dropdowns
																		        $("#start362").children().end().append(newoptions1);
																		        $("#end362").children().end().append(newoptions2);
																		      } 
						 } );			
	}
}

// load period dates based on newly selected fiscal year
$('#fiscal_year').change( function() {
	// partial year is checked load new dates
	if ( $('#partial-year-cbox').prop('checked') ) {
		refreshDates();
	}
});

$('#partial-year-cbox').change(function() {
	if ( $(this).prop('checked') ) {
		$('.partial-date').show();
		refreshDates();
	}
	else {
		$('.partial-date').hide();
	}
});
$('form input:visible:enabled:first').focus();

/* existing row with partial year box checked, display partial year & dates */
<cfif oBudgetClass.Partial_Year>
	$('#partial-yr').show();
	$('.partial-date').show();
</cfif>
</script>