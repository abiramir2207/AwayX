<cfoutput>
	<cfparam name="Attributes.RevisionStatus" default="0">
	<cfparam name="Attributes.RevisionSettings" default="1">

	<!---handle for persisted data. this data comes from contract_create_1_form.cfm--->
	<cfparam name="form.Date_Method" default="0" /> 	<!-- This is depricated but the field is used/passed in certain calls/pages so defaulting it -->

	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="300">
		<TR>
			<TD nowrap>
				Year:<br>
				<span id="error_ContractFiscalYear"></span>
				<select name="fiscal_year" id="fiscal_year" style="width:90px" <cfif Attributes.RevisionStatus eq 1 AND Attributes.RevisionSettings eq 2>DISABLED STYLE="font-size:10pt; background-color: cccccc"</cfif>>
					<option>Year</option> <!--- other values will be pushed in by jquery below --->
				</select>
			</TD>

			<TD nowrap>
				From:<br>
				<span id="error_ContractStartDateValidity"></span>
				<select name="start_date" id="start_date" style="width:90px" <cfif Attributes.RevisionStatus eq 1 AND Attributes.RevisionSettings eq 2>DISABLED STYLE="font-size:10pt; background-color: cccccc"</cfif>>
					<option>Start Date</option> <!--- other values will be pushed in by jquery below --->
					<option value="#form.start_date#" selected>#form.start_date#</option>
				</select>
			</TD>

			<TD nowrap>
				To:<br>
				<span id="error_ContractEndDateValidity"></span>
				<select name="end_date" id="end_date" style="width:90px" <cfif Attributes.RevisionStatus eq 1 AND Attributes.RevisionSettings eq 2>DISABLED STYLE="font-size:10pt; background-color: cccccc"</cfif>>
					<option>End Date</option> <!--- other values will be pushed in by jquery below --->
					<option value="#form.end_date#" selected>#form.end_date#</option>
				</select>
			</TD>
		</TR>
	</TABLE>
	
	<!-- On revision form fields are disabled, so send hidden values  -->
	<cfif Attributes.RevisionStatus eq 1 AND Attributes.RevisionSettings eq 2>		
		<input name="fiscal_year" type="hidden" value="#form.fiscal_year#">
		<input name="start_date" type="hidden" value="#form.start_date#">
		<input name="end_date" type="hidden" value="#form.end_date#">
	</cfif>

	<cfinclude template="/common_files/jQuery.cfm">
	<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>
	<script>
	$(document).ready(function() {
		// If template revision settings dont allow date changes, dont allow user to change dates.
		<cfif  NOT(Attributes.RevisionStatus eq 1 AND Attributes.RevisionSettings eq 2)>
			// query for the fiscal yr dropdown
			$.getJSON("/mvc/Models/Settings/fiscalPeriodManager.cfc?method=getFiscalYears&returnformat=json", function(result) {
					// get the list of column names and position in the query, in case the order of the columns changes
					var yrCols = [];
					$.each( result.COLUMNS, function(i, field) {
						yrCols[field] = i;
					});

					// get the list of years
					var fiscalYears = "";
					$.each( result.DATA, function(i, field) {
						fiscalYears 	+= '<option value="' + result.DATA[i][yrCols["FISCAL_YEAR"]] +'"'+ (result.DATA[i][yrCols["FISCAL_YEAR"]] === "#form.fiscal_year#" ? " selected ":"") + '>' + result.DATA[i][yrCols["FISCAL_YEAR"]] + '</option>';
					});

					// append the start and end dates to DD
					$("##fiscal_year").children().end().append(fiscalYears);
					$( "##fiscal_year" ).trigger( "change" );
			});
			
			// first, detect when DD changes
			$("##fiscal_year").change(function() {
				// get the year selected, if blank dont do anything
				var selected = $("option:selected",this).val();
				if(selected == "" || selected == "Year") return;

				// clear the date DDs on year change.
				$("##start_date option:not(:first-child)").remove();
				$("##end_date option:not(:first-child)").remove();
				
				// query for new date options
				$.getJSON("/mvc/Models/Settings/fiscalPeriodManager.cfc?method=getFiscalPeriodsforYear&returnformat=json",{"fiscalYear":selected}, function(result) {

					// get the list of column names and position in the query, in case the order of the columns changes
					var cols = [];
					$.each( result.COLUMNS, function(i, field) {
						cols[field] = i;
					});

					// get the list of dates based on the column position in the query
					var startDates = "";
					var endDates = "";
					$.each( result.DATA, function(i, field) {
						startDates 	+= '<option value="' + result.DATA[i][cols["STARTDATE"]] +'"'+ (result.DATA[i][cols["STARTDATE"]] === "#form.start_date#" ? " selected ":"") + '>' + result.DATA[i][cols["STARTDATE"]] + '</option>';
						endDates 		+= '<option value="' + result.DATA[i][cols["ENDDATE"]] +'"'+ (result.DATA[i][cols["ENDDATE"]] === "#form.end_date#" ? " selected ":"") + '>' + result.DATA[i][cols["ENDDATE"]] + '</option>';
					});

					// append the start and end dates to DD
					$("##start_date").children().end().append(startDates);
					$("##end_date").children().end().append(endDates);
				});

			</cfif>
		});
	})
	</script>
	
</cfoutput>