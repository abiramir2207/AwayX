<!--
  * ==================================================================================================== 
  *  @Author: Sharon Harris
  *    @Date: June 2019
  * 
  * @Remarks: Search filter section of the left-side Control panel 
  *			  Used to search for Deductions, Programs, Billbacks
  *
  * 
  *  
  * ==================================================================================================== 
-->
<cf_include files="/script/javascript/multipleselect/1.2/multiple-select_bsa.js, /script/javascript/multipleselect/1.2/multiple-select.css, /Common_Files/dhx_message.cfm">
<style>
	div.filter {
		margin-bottom: 2px;
		width: 100%;
	}
		div.filter > i.label {
			font-style: normal;
			display: inline-block;
			margin-left: 4px;
			width: 37%;
		}
		div.filter > input {
			border: solid 1px #c4c5c7;
			border-radius: 3px;
			height: 16px;
			width: 58%; 
		}
		div.filter > input.date {
			padding-left: 3px;
			width: 61px;
		}

	select[multiple] {
		height: 12px;
		width: 100%;
	}
	/* Customize the multiple select style */
	.ms-drop ul {
    	padding: 0px 8px;	/* default padding: 5px 8px; */
	}
	.ms-choice {
		height: 20px;		/* default 26px */
		line-height: 20px;	/* default 26px */
		color: #343540;
		font-size: 8pt;
	}
	.ms-choice > div {
		height: 19px;		/* default 25px */
		top: -3px;			/* center arrow vertically */
	}
	.ms-choice > span {
		top: 1px;
	}
	.ms-choice > span.placeholder {
		font-size: 8pt;
		color: #343540;
		opacity: 0.5;
	}
	input[type="checkbox" i] {
		margin: 3px 3px 3px 4px;
	}

</style>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfscript>
	appSettings = application.appSettingsGet;

	param name="form.customer_search"		default="";
	param name="form.customer_group_search"	default="";
	param name="form.operator_search"		default="";
	param name="form.program_search"		default="";
	param name="form.item_search"			default="";
	param name="form.item_group_search"		default="";
	// Default dates should be for the past 6 months
	param name="form.from_date"				default="#dateformat(DateAdd('m',-6,now()),'m/d/yyyy')#";
	param name="form.to_date"				default="#dateformat(now(),'m/d/yyyy')#";

	objSearchProgram  = CreateObject("component", "mvc.Models.Program.Search_Program");
	qTemplatesList   = objSearchProgram.getAllTemplate();
</cfscript>



<cfoutput>

<cfsavecontent variable="filter_content">
<!--- For loading data, we do not need to post this form as we use AJAX, but for "download data", we post this form and so we have the action set to "/Common_Files/exportAll.cfm". --->
	<form name="frmSettlements" method="post" action="/Common_Files/exportAll.cfm">

		<!--- INPUT Fields --->
		<div class="filter" title="">
			<i class="label">Customer</i>
			<input type="text" name="customer_search" id="customer_search" size="30" value="#form.customer_search#">
		</div>
		<div class="filter" title="">
			<i class="label">Customer Group</i>
			<input type="text" name="customer_group_search" id="customer_group_search" size="30" value="#form.customer_group_search#">
		</div>
		<div class="filter" title="">
			<i class="label">Operator</i>
			<input type="text" name="operator_search" id="operator_search" size="30" value="#form.operator_search#">
		</div>
		<div class="filter" title="">
			<i class="label">Program</i>
			<input type="text" name="program_search" id="program_search" size="30" value="#form.program_search#">
		</div>
		<div class="filter" title="">
			<i class="label">Item</i>
			<input type="text" name="item_search" id="item_search" size="30" value="#form.item_search#">
		</div>
		<div class="filter" title="">
			<i class="label">Item Group</i>
			<input type="text" name="item_group_search" id="item_group_search" size="30" value="#form.item_group_search#">
		</div>

		<!---  SELECT boxes --->
		<div class="filter mt-1" title="filter: Program Template">
			<select name="template_list" id="template_list" multiple="multiple" style="width:99%;">
				<cfloop query="qTemplatesList">
					<option value="#qTemplatesList.First_Parent_ID#">#qTemplatesList.Created_Type#</option>
				</cfloop>
			</select>
		</div>

		<!---  DATE range --->
		<div class="filter" style="margin-left: 4px; margin-top:5px;">
			Date Range
			<input name="from_date" id="from_date" type="text" class="date" value="#form.from_date#"> to
			<input name="to_date" id="to_date" type="text" class="date" value="#form.to_date#">
		</div>

		<!---  BUTTONS --->
		<div style="margin-top:10px; margin-bottom:5px;">
			<button type="button" onClick="" title="search Programs using the selected filters" class="button recommended" style="margin:0 4px;">Search Programs</button>
			<button type="button" onClick="" title="search Billbacks using the selected filters" class="button disabled" style="margin:0 0 0 5px;">Search Billbacks</button>
		</div>
		<div style="margin-bottom:10px;">
			<button type="button" onClick="" title="search Deductions using the selected filters" class="button alt" style="margin:0 4px;">Search Deductions</button>
			<button type="button" onClick="resetOptions();" title="clear the filters" class="button alt" style="margin:0 4px 0 0;">reset</button>
		</div>
	<!---	
		<input type="hidden" name="searchType" id="searchType" value="MainSearch">
	--->
	</form>
</cfsavecontent>
#application.util.string.compress(filter_content)#

<script>

	<!--- Dropdowns --->

	// Used to configure the multi-select dropdowns
	function ms_config(placeholder, deleteOption, single, dropWidth, position) {
		deleteOption = ( deleteOption || false);
		single       = ( single || false );
		dropWidth   = (dropWidth || '230px');
		position   = (position || 'bottom');
		
		return ({ 	 
					deleteOption: deleteOption
					,filter: true
					,placeholder: placeholder
					,selectAllDelimiter: "[]"
					,selectAllText: placeholder
					,single: single
					,width: '99%'
					,dropWidth : dropWidth
					,maxHeight: '200'
					/* position: 'top' will make sure that the dropdown opens up upwards */
					,position: position
				});
	};
	// Setup each of the multi-select dropdowns
	function activate_multipleSelect() {

		$("select[name=template_list]").multipleSelect( ms_config('Show All Program Templates', false, false, '325px') );

	}



	// Reset the filters (and the grid).  Used for reset button
	function resetOptions() {
		$('##customer_search').val('');
		$('##customer_group_search').val('');
		$('##operator_search').val('');
		$('##program_search').val('');
		$('##item_search').val('');
		$('##item_group_search').val('');
		<!---
		/* Remove the sorting of column on the grid */
		gridOptions.api.setSortModel(null);

		/* Reset the grid */
		gridOptions.api.onFilterChanged();
		--->
	}

	$(".date").datepicker({
		dateFormat: "m/d/yy",
		changeMonth: true,
		changeYear: true,
		onSelect: function( selected ) {
			// change date limit based on selected value
			if ( jQuery(this).attr("name") === "from_date" )
				jQuery("input[name=to_date]").datepicker("option", "minDate", selected);
			else
				jQuery("input[name=from_date]").datepicker("option", "maxDate", selected);
		}
	});

</script>
</cfoutput>