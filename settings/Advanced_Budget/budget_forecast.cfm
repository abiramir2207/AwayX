<!---
	Copyright (c)2017 Blacksmith Applications, Inc.
	Filename:		C:\Users\drachala\Work\Code\_base\AwayX\settings\Advanced_Budget\budget_forecast.cfm
	Created:		3/22/2017
	Developer:		drachala
--->
<!DOCTYPE html>

<cfparam name="form.allowsubmit" default="0">
<cfparam name="TotalForecastBalance" default="0">
<cfparam name="forecastBalance" default="0">
<cfparam name="TotalLastYearVolume" default="0">
<cfparam name="form.finalforecast" default="0">

<cfinclude template="/common_files/jqueryUI_icons.cfm"> <!--- 8.0 only--->

<cfset budgetFunction = createObject("mvc.Models.AdvancedBudget.BudgetClassManager")>
<cfset qClass = budgetFunction.getBudgetClass()>


<cfset pagetitle = "Budget Forecast">
<cfinclude template="/settings/settings_title.cfm">

<!--- "FINAL SAVE START" --->
<cfif form.finalforecast>
<cfloop from="1" to="#form.totalCount#" index="TC">
	<cfset productcategoryid = evaluate('productcategoryid_#TC#')>
	<cfset forecast_growth_percent = evaluate('forecast_growth_percent_#TC#')>
	<cfif len(forecast_growth_percent) and forecast_growth_percent GT 0>
		<cfquery name="qUpdaterecord" datasource="#application.datasource#">
			UPDATE Budget_Forecast_Growth_Percent
			SET   Forecast_Growth_Percent = '#forecast_growth_percent#'
				,Updated_Date  = getdate()
				,Updated_By = '#request.AccessStructure.User_ID#'
			WHERE Budget_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.budgetId#" />
			AND PG_Product_Category_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#productcategoryid#" />
			AND Distributor_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.distributorid#" />
		</cfquery>
	</cfif>
</cfloop>
<script type="text/javascript">
	window.close();
</script>
</cfif>
<!--- "FINAL SAVE START" --->

<cfset jQuery.version ="1.12.4">
<cfset jQueryUI.version ="1.12.1">

<cfinclude template="/Common_Files/jQuery.cfm">
<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">

<script src="/script/javascript/chosen/chosen.jquery.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/styles/chosen/chosen.css">

<cfif form.allowsubmit EQ 0>
	<form name="budget_forecast" method="post" action="budget_forecast.cfm" id="budgetforecast">
	<table width="750" border="0">
		<tr style="font-weight:bold;">
			<td>Class</td>
			<td>Budgets <span id="bgwait" style="display:none;">&nbsp;<img src="/images/ajax-loader-small-red.gif"></span></td>
			<td>Distributors <span id="diswait" style="display:none;">&nbsp;<img src="/images/ajax-loader-small-red.gif"></span></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>
				<select name="budgetClass" id="budgetClass" style="width:250px" data-placeholder="Select a Class..." >
					<option value=""> </option>
				<cfoutput query="qClass">
					<option value="#qClass.Budget_Class_ID#">#qClass.Budget_Class_Number# #qClass.Budget_Class_Desc#</option>
				</cfoutput>
				</select>
			</td>
			<td>
				<select id="budgetslist" name="budgets" style="width:250px" data-placeholder="Select a Budget..." >
					<option value=""> </option>
				</select>
			</td>
			<td>
				<select id="distributorslist" name="distributors" style="width:250px" data-placeholder="Select a Distributor...">
					<option value=""> </option>
				</select>
			</td>
			<td><cfoutput><a href="javascript:submit();">#application.util.string.LinkFormat("go")#</a></cfoutput></td>
		</tr>
		<input type="hidden" name="allowsubmit" value="0" id="allowsubmit">
	</table>
	</form>

	<script type="text/javascript">
		$(document).ready(function(){
		$("#budgetClass").chosen()
		$("#budgetslist").chosen()
		$("#distributorslist").chosen()
		//POPULATE BUDGETS DROP-DOWN
		 $( "#budgetClass" ).change( function( ){
								       		$.ajax( {
													type: "POST",
													url: "/mvc/Models/Advancedbudget/BudgetClassManager.cfc?method=getBudgets&ReturnFormat=json",
													data: ({	budgetClassId: $(this).val()}),
													dataType: 'json',
													success: function(response)
													{
													      for (var i = 0; i < response.DATA.length; i++)
													      {
													      		$('#budgetslist').append('<option value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
													      }
												      		$('#budgetslist').trigger("chosen:updated");
													},
													error: function(xhr, textStatus, errorThrown){ alert('request failed');}
												});
										});
		//POPULATE DISTRIBUTORS DROP-DOWN
		 $( "#budgetslist" ).change( function( ){
								       		$.ajax( {
													type: "POST",
													url: "/mvc/Models/Advancedbudget/BudgetClassManager.cfc?method=getBudgetDistributors&ReturnFormat=json",
													data: ({ budgetId: $(this).val() }),
													dataType: 'json',
													success: function(response)
													{
													      for (var i = 0; i < response.DATA.length; i++)
													      {
													      		$('#distributorslist').append('<option value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
													      }
													      $('#distributorslist').trigger("chosen:updated");
													},
													error: function(xhr, textStatus, errorThrown){ alert('request failed');}
												});
										});
		})
		//SUBMIT FORM
		function submit(){
			var submitForm = 1;
			var errorText = '';

			if($('#budgetClass').val() ==''){
				submitForm = 0;
				var errorText = errorText + 'Please make selection for class \n';
			}
			if($('#budgetslist').val() == ''){
				submitForm = 0;
				var errorText = errorText + 'Please make selection for budgets \n';
			}
			if($('#distributorslist').val() == ''){
				submitForm = 0;
				var errorText = errorText + 'Please make selection for distributors';
			}
			if(submitForm){
				$( "#allowsubmit" ).val('1');
				$( "#budgetforecast" ).submit();
			}else{
				alert(errorText);
			}
		}

	</script>
<cfelse>

<cfset distributorinfo = createObject('components.programs.distributors.Distributor').getDistributor(form.distributors)>
<cfset BudgetsCFC = createObject('mvc.Models.Advancedbudget.BudgetClassManager')>
<cfset BudgetClass = BudgetsCFC.getBudgetClass(form.budgetClass)>
<cfset Budgetinfo = BudgetsCFC.getSpecificBudget(form.budgets)>

<table width="95%">
	<tr>
		<td align="left">
		<cfoutput>
			<B>Class : </B>#BudgetClass.Budget_Class_Desc# ( #trim(BudgetClass.Budget_Class_Number)# )&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<B>Budget : </B>#Budgetinfo.budget_desc# ( #trim(Budgetinfo.budget_code)# ) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<B>Distributor : </B>#distributorinfo.name# ( #trim(distributorinfo.Shr_Ship_To)# )
		 </cfoutput>
		</td>
		<td align="right">
		<cfoutput>
			<a href='javascript:getCSVData();'>#application.util.string.LinkFormat("export to csv")#</a>
			<a href='javascript:goBack();'>#application.util.string.LinkFormat("go back")#</a>
			<a href='javascript:finalSubmit();'>#application.util.string.LinkFormat("save")#</a>
		</cfoutput>
		</td>
	</tr>
</table>

	<cfstoredproc procedure="Budget_Growth_Forecast" datasource="#application.datasource#">
		<cfprocparam value="#form.budgets#" cfsqltype="CF_SQL_INTEGER">
		<cfprocparam value="#form.distributors#" cfsqltype="CF_SQL_VARCHAR">
		<cfprocresult name="budgetDetails" resultset="1">
		<cfprocresult name="budgetSummary" resultset="2">
	</cfstoredproc>

	<cfinclude template="/Common_Files/dataTables2.cfm">
	<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
	<form name="forecast" method="post" action="budget_forecast.cfm" id="forecast">
		<cfoutput>
		<input type="hidden" name="budgetID" value="#form.budgets#">
		<input type="hidden" name="distributorId" value="#form.distributors#">
		</cfoutput>

	<table class="datagrid">
	  <thead>
		<th class="header" align="left">Product Category</th>
		<th class="header" align="left">Rate</th>
		<th class="header" align="left">UOM</th>
		<th class="header" align="left">Last Year Volume</th>
		<th class="header" align="left">Forecast Growth %</th>
		<th class="header" align="left" title="(Rate * last Year Volume) * ((Forecast Growth Percentage/100) + 1)">Forecast Balance</th>
	  </thead>
	  <tbody>
		<cfoutput query="budgetDetails">
			<!--- "LAST YEAR VOLUME" --->
			<cfif rate_uom eq 1><!--- "CASE" --->
				<cfset lastYearVolume = Cases_Invoiced>
			<cfelseif rate_uom eq 2><!--- "POUND" --->
				<cfset lastYearVolume = Pounds_Invoiced>
			<cfelseif rate_uom eq 3><!--- "%" --->
				<cfset lastYearVolume = (Gross_Dollar * 0.01)>
			<cfelse>
				<cfset lastYearVolume = 0>
			</cfif>
			<!--- "FORECAST BALANCE" --->
			<cfif rate_uom eq 1><!--- "CASE" --->
				<cfset forecastBalance = Rate * Cases_Invoiced * ((Forecast_Growth_Percent/100) + 1)>
			<cfelseif rate_uom eq 2><!--- "POUND" --->
				<cfset forecastBalance = Rate * Pounds_Invoiced * ((Forecast_Growth_Percent/100) + 1)>
			<cfelseif rate_uom eq 3><!--- "%" --->
				<cfset forecastBalance = (Rate * Gross_Dollar * 0.01) * ((Forecast_Growth_Percent/100) + 1)>
			<cfelse>
				<cfset forecastBalance = 0>
			</cfif>
		<tr align="left">
			<td>
				#pg_product_category_name#
				<input type="hidden" name="ProductCategoryID_#CurrentRow#" value="#pg_product_category_id#">
				<input type="hidden" name="ProductCategoryCode_#CurrentRow#" value="#pg_product_category_code#">
				<input type="hidden" name="ProductCategoryName_#CurrentRow#" value="#pg_product_category_name#">
			</td>
			<td>#dollarformat(rate)#</td>
			<td>#uom_desc#</td>
			<td>#numberFormat(lastYearVolume,',')#</td>
			<td><input type="text" name="Forecast_Growth_Percent_#CurrentRow#" value="0.00" onkeyup="calFCbalance(#CurrentRow#, #rate#, #lastYearVolume#, this.value);"></td>
			<td id="forecastBalance_#CurrentRow#" class="forecastBalance">#dollarFormat(forecastBalance)#</td>
		</tr>
		<cfset TotalLastYearVolume = TotalLastYearVolume + lastYearVolume>
		<cfset TotalForecastBalance = TotalForecastBalance + forecastBalance>
		</cfoutput>
	  </tbody>
	<tfoot>
		<tr>
		<cfoutput>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
			<th align="left">Total Last Year Volume: #numberFormat(TotalLastYearVolume,',')#</th>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
		</cfoutput>
		</tr>
		<tr>
		<cfoutput>
			<cfset Annual_Balance = TotalForecastBalance + budgetSummary.Budget_Dollar >
			<cfset Available_Balance = TotalForecastBalance + budgetSummary.Budget_Dollar -  budgetSummary.Estimated_Trade>
			<cfset Actual_Balance = TotalForecastBalance + budgetSummary.Budget_Dollar  - budgetSummary.Actual_Dollar>

			<th id="AnnualBalance" align="left">Annual Balance: #dollarFormat(Annual_Balance)#</th>
			<th id="EstimatedTrade" align="left">Estimated Trade: #dollarFormat(budgetSummary.estimated_trade)#</th>
			<th id="AvailableBalance" align="left">Available Balance: #dollarFormat(Available_Balance)#</th>
			<th id="ActualDollar" align="left">Actual Amount: #dollarFormat(budgetSummary.actual_dollar)#</th>
			<th id="ActualBalance" align="left">Actual Balance: #dollarFormat(Actual_Balance)#</th>
			<th id="TotalForecastBalance" align="left">Forecast Balance: #dollarFormat(TotalForecastBalance)#
			<input type="hidden" name="totalCount" value="#budgetDetails.recordcount#">
			<input type="hidden" name="finalforecast" value="1" id="finalforecast">
			</th>
		</cfoutput>
		</tr>
	</tfoot>
	</table>
	</form>
	<!--- "BELOW 9 LINES CODE IS FOR EXPORTING DATA INTO CSV FORMAT" --->
	<cfset name = rereplace(distributorinfo.name,"[^A-Za-z0-9]","","all") />
	<cfset fileName = name &'_Budget_Forecast.csv'>

	<form action="/common_files/csv.cfm" method ="post" id="csv_form" name="csv">
		<input type="hidden" name="csv_text" id="csv_text">
		<input type="hidden" name="csv_file_name" value="<cfoutput>#fileName#</cfoutput>">
	</form>
	<script src="/script/javascript/table2csv.js?d"></script>

	<script>
		var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .85) * windowHeight;
		oTable = $('.datagrid').DataTable( {
							  "bServerSide": false
							, "bProcessing": false
							, "bSortClasses": false
							, "bAutoWidth": false
							, "iDisplayLength": 2000
							<cfif budgetDetails.recordcount GT 20>	, "sScrollY": sScrollY</cfif>
							, "sDom": "rt"
							, "aaSorting": []
							, "aoColumns": [
												{"bSortable":true}
											,	{"bSortable":true}
											,	{"bSortable":true}
											,	{"bSortable":true}
											,	{"bSortable":true}
											,	{"bSortable":true}
											]
		} );
		$('.dataTables_wrapper').css('min-height', '30px');
		//FUNCTION TO CALCULATE FORECAST BALANCE , ANNUAL BALANCE, AVAILABLE BALANCE, ACTUAL BALANCE WHEN USER ENTER FORECAST %
		function calFCbalance(rowID, rate, lyvol, fcpercent){
			var fBalance = (rate * lyvol)* ((fcpercent/100) + 1);
				fBalance = '$'.concat(fBalance.toFixed(2));

			$('#forecastBalance_'+rowID).html(fBalance);
			var sumfBalance = 0;
			// iterate through each td based on class and add the values
			$(".forecastBalance").each(function() {
			    var value = $(this).text();
			    	    value = value.replace('$','');
			    // add only if the value is number
			    if(!isNaN(value) && value.length != 0) {
			        sumfBalance += parseFloat(value);
			    }
			});
			var NewForecastBalance = 'Forecast Balance: $'+sumfBalance.toFixed(2);
				$('tfoot th#TotalForecastBalance').html(NewForecastBalance);
			var Annual_Balance = sumfBalance + <cfoutput>#budgetSummary.Budget_Dollar#</cfoutput>
				Annual_Balance = 'Annual Balance : $' +Annual_Balance.toFixed(2);
				$('tfoot th#AnnualBalance').html(Annual_Balance);
			var Available_Balance = sumfBalance + <cfoutput>#budgetSummary.Budget_Dollar -  budgetSummary.Estimated_Trade#</cfoutput>
				Available_Balance = 'Available Balance : $' +Available_Balance.toFixed(2);
				$('tfoot th#AvailableBalance').html(Available_Balance);
			var Actual_Balance = sumfBalance + <cfoutput>#budgetSummary.Budget_Dollar  - budgetSummary.Actual_Dollar#</cfoutput>
				Actual_Balance = 'Actual Balance : $' +Actual_Balance.toFixed(2);
				$('tfoot th#ActualBalance').html(Actual_Balance);
		}
		// EXPORT TO CSV FUNCTION
		getCSVData = function() {
			var csv_value=$('table.datagrid').table2CSV( {  csvExclude: 'csvExclude' } );
			$("#csv_text").val(csv_value);
			$("#csv_form").submit();
		}
		function goBack () {
			window.location ='/settings/Advanced_Budget/budget_forecast.cfm'
			return false;
		}
		function finalSubmit(){
			$( "#forecast" ).submit();
		}
	</script>
</cfif>