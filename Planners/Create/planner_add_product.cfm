<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Create/planner_add_product.cfm
	Created Date:  2017 Dec
	  Created By:  Deepa Kunnath
	 Description:  When new products/groups are added, ask user for default volume
--------------------------------------------------------------------------------------------------------------------------------------------------------------->

<cfparam name="form.plannerID" 						default="0">
<cfparam name="form.product_list"           		default="">
<cfparam name="form.ExistingProductList"           	default="">


<cfinclude template="/planners/create/planner_volume_constants.cfm">

<cfif form.action eq "save_products" or form.action is "remove_products">
    <cfif form.action contains "remove">
        <cfset plannerManager.deletePlannerProducts( form )>
    <cfelse>
        <!---  save products into volume plan --->
        <cfset plannerManager.savePlannerProducts( form.plannerID, form.product_list, form.product_group_level_id, form ) />
    </cfif>

	<!--- close the window --->
	<cfoutput>
	<script>
		opener.show_loader();
		opener.$("form[name=topnav]").submit();
		window.close();
	</script>
	</cfoutput>
	<cfabort>
</cfif>

<cfif form.product_group_level_id eq "">
	<cfquery name="local.getProducts" datasource="#application.datasource#">
		SELECT	t.bsa_FoodService_Items_Master_ID as Product_ID, t.Item as Product_Number, t.Description as Product_Name
		FROM	bsa_FoodService_Items_Master t
		WHERE	t.bsa_FoodService_Items_Master_ID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.product_list#" list="true">)
		<cfif form.ExistingProductList neq "">
		AND		t.bsa_FoodService_Items_Master_ID NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.ExistingProductList#" list="true">)
		</cfif>
	</cfquery>
<cfelse>
	<cfquery name="local.getProducts" datasource="#application.datasource#">
		SELECT	t.Group_GUID as Product_ID, t.Group_Number as Product_Number, t.Group_Desc as Product_Name
		FROM	All_Product_Group_Types t
		WHERE	t.Group_GUID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.product_list#" list="true">)
		<cfif form.ExistingProductList neq "">
		AND		t.Group_GUID NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.ExistingProductList#" list="true">)
		</cfif>
	</cfquery>
</cfif>
<cfset form.product_list = ValueList(local.getProducts.Product_ID) />


<!DOCTYPE HTML>
<HTML>
<head>
	<title>Volume forecast</title>

	<cfset jQueryUI.widgets = "tooltip,datepicker">
	<cfinclude template="/common_files/jQuery.cfm">

	<cfset include_files = [
		   					 "/Script/javascript/gridviewScroll.min.js"
							,"/script/javascript/jquery.cfjs.min.js"
							,"/script/javascript/numeral.min.js"
							,"/script/javascript/date_functions.js"
							,"/script/javascript/jquery.noty.packaged.min.js"
		   					,"/common_files/datatable.css"
						]>
	<cf_include files=#arrayToList(include_files)#>

  	<cfinclude template="/common_files/jqueryui_icons.cfm">
  	<style>
		#actions { text-align: left;}
		#actions > a {
  			margin: 0 15px;
  			cursor: pointer;
  		}
  		i.ui-icon { position:relative; top:3px; }
		input { width: 70px; }
		input.date  { width: 60px; }
  	</style>
</head>
<body>
Enter weekly Forecast information and save to complete the import<br><br>
<form name="add_products" method="post">
<cfoutput>
<input type="hidden" name="action" value="save_products">
<input type="hidden" name="product_list" value="#form.product_list#">
<input type="hidden" name="product_group_level_id" value="#form.product_group_level_id#">
<input type="hidden" name="plannerID" value="#form.plannerID#">
<input type="hidden" name="mode" value="#form.mode#">
</cfoutput>
<cfsavecontent variable="uncompressed">
<table cellpadding="2" cellspacing="0" width="100%" class="MainTable datagrid" id="datagrid"  style='table-layout:fixed;'>
  	<col width="20%">
  	<col width="50%">
	<col width="15%">
	<col width="5%">
	<col width="10%">
	<thead>
    	<tr>
	      	<th>ID</th>
	      	<th>Description</th>
			<th>Weekly Forecast</th>
			<th>UOM</th>
			<th>Start Date</th>
	    </tr>
	</thead>
    <tfoot>
    	<tr>
    		<th colspan="5" id="actions">
				<cfoutput>
				<a class="save_button">#application.util.string.linkFormat("save")#</a>
				</cfoutput>
			</th>
   		</tr>
	</tfoot>
	<tbody>
	    <cfloop query="local.getProducts">
			<cfset postfix = Replace(Product_ID, "-", "_", "ALL") />
		    <tr>
				<cfoutput>
		      	<td>#Product_Number#</td>
				<td>#Product_Name#</td>
				<td><input type="text" name="Forecast_Val_#postfix#" class="autoselect forecast"></td>
				<td><select name="Forecast_UOM_#postfix#">
                        <!--- bring get_UOM() in from udf.cfc --->
                        <cfset structAppend(url, createObject( "component", "components.udf" ))>

                        <cfif getPlanner.UOM_CS><option value="1" <cfif getPlanner.UOM_Default EQ 1>selected</cfif>>#get_UOM( 1 ).Abbreviation#</option></cfif>
                        <cfif getPlanner.UOM_LB><option value="2" <cfif getPlanner.UOM_Default EQ 2>selected</cfif>>#get_UOM( 2 ).Abbreviation#</option></cfif>
					</select>
				</td>
				<td><input type="text" class="date" name="Forecast_Start_Date_#postfix#"> </td>
				</cfoutput>
		    </tr>
	    </cfloop>
	 	</tbody>
</table>
</cfsavecontent>
<cfoutput>
#application.util.string.compress( uncompressed )#
</cfoutput>
</form>


<script>

	(function($){
		numeral.defaultFormat('(0,0)');     <!--- default to integer format --->

		$.fn.forceNumeric = function () {
			return this.each(function () {
			$(this).keydown(function (e) {
				var key = e.which || e.keyCode;
				/* navigate to the next forecast input on enter key */
				if (key == 13) {
					/* $(':input.lfc:eq(' + ($(':input.lfc').index(this) + 1) + ')').focus(); */
					return false;
				}
				if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
				 ( key >= 48 && key <= 57 ) ||    <!---numbers--->
				 ( key >= 96 && key <= 105 ) ||   <!---Numeric keypad--->
				 key == 190 || key == 188 || key == 109 ||  key == 189 || <!---comma, period and minus--->
				 key == 8 || key == 9 || key == 13 ||  <!---Backspace and Tab and Enter--->
				 key == 35 || key == 36 ||             <!---Home and End--->
				 ( key >= 37 && key <= 40 ) ||         <!---left, up and right, down arrows--->
				 key == 110 ||                         <!---Decimal point on numeric keypad--->
				 key == 46 || key == 45 ||
				 key == 17 || key == 86				   <!---ctlr v. allow values to be pasted. If the value is not a number then the checkForecastValid() function will clean it up --->
				 ) {             <!---Del and Ins--->
				  return true;
				}
				return false;
			});
		 });
		}
	})(jQuery);

	$("input.forecast").forceNumeric();

    jQuery("input.date")
    	.datepicker({
			dateFormat: "m/d/yy",
			changeMonth: true,
			changeYear: true,
	        minDate: "<cfoutput>#DateFormat(getPlanner.Planner_Start_Date, "mm/dd/yyyy")#</cfoutput>",
	        maxDate: "<cfoutput>#DateFormat(getPlanner.Planner_End_Date, "mm/dd/yyyy")#</cfoutput>"
		});


	$(".save_button").click(function() {

		if(validate_form()){
			$("input[name=action]").val( "save_products" );
			$("form[name=add_products]").submit();
		}
	});


	$("input.forecast").change(function() {
		checkForecastValid($(this));
	});

	$("input.date").change(function() {
		checkStartDateValid($(this));
	});

	function checkForecastValid(obj) {
		var thisVal = obj.val();

		//if the value is not a number then remove it and flag the input with the attention class
		if(isNaN(thisVal)){
			obj.val('');
			thisVal = "";
		}
		
		if((thisVal == "")){
			obj.addClass( "attention" );
			return 1;
		}
		else {
			obj.removeClass( "attention" );
			return 0;
		}
	}

	function checkStartDateValid(obj) {
		var thisVal = obj.val();

		<cfoutput>
		var plannerStartDate = new Date("#DateFormat(getPlanner.Planner_Start_Date, "mm/dd/yyyy")#");
		var plannerEndDate = new Date("#DateFormat(getPlanner.Planner_End_Date, "mm/dd/yyyy")#");
		</cfoutput>

		var sDate = new Date();

		if(thisVal != "") {
			sDate = new Date(thisVal);
		}

		if((thisVal == "")){
			obj.addClass( "attention" );
			return 1;
		}
		else if(sDate < plannerStartDate || sDate > plannerEndDate){
			obj.addClass( "attention" );
			return 1;
		}
		else {
			obj.removeClass( "attention" );
			return 0;
		}
	}


	function validate_form() {
		var errors = [];
		var forecastError = 0;
		var startDateError = 0;

		// Validate forecast field
		$("input.forecast").each(function(){
			forecastError += checkForecastValid($(this));
		});

		// Validate start date field
		$("input.date").each(function(){
			startDateError += checkStartDateValid($(this));
		});

		if(forecastError) {
			errors.push('Please enter a Forecast for all records.');
		}
		if(startDateError) {
			errors.push('Please enter a Start Date within <CFOUTPUT>#Application.PlannerLabel#</CFOUTPUT> dates for all records.');
		}


		if (errors.length) {
			alert( errors.join("\n") );
			return false;
		}

		return true;
	}

</script>
<cfinclude template="/common_files/focus.cfm">
</body>
</html>
