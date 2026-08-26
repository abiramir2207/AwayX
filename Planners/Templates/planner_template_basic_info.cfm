<!----------------------------------------------------------------------------------
Name         :	AwayX/Planners/Templates/planner_template_basic_info.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/01/2016
Created By   : 	KAL
Description  : 	Planner Templates
---------------------------------------------------------------------------------->
<!--- TODO: LIST -------------------------
	- Validation
	- UI Cleanup
----------------------------------------->

<cfoutput>
<cfparam name="form.Planner_Type"                       default=""  />
<cfparam name="form.Planner_Description"                default=""  />
<cfparam name="form.Planner_Start_Date"                 default=""  />
<cfparam name="form.Planner_End_Date"                   default=""  />
<cfparam name="form.Retroactive_Planner"                default="0" />
<cfparam name="form.Retroactive_Planner_Days"           default=""  />
<cfparam name="form.Retroactive_Revision"               default="0" />
<cfparam name="form.Retroactive_Revision_Days"          default=""  />
<cfparam name="form.Price_List_Header_ID"               default=""  />
<cfparam name="form.Wholesaler_Planner"                 default="0" />
<cfparam name="form.Check_Duplicate_Planner"            default="0" />
<cfparam name="form.Check_Duplicate_Planner_Action"     default="1" />
<cfparam name="form.Include_In_Catalog"                 default="0" />
<cfparam name="form.Output_Before_Approval"             default="0" />
<cfparam name="form.Auto_Generate_Accrual_Program"      default="0" />
<cfparam name="form.Alert_RFA_Programs"                 default="0" />
<cfparam name="form.Alert_RFA_Programs_Days"            default="0" />
<cfparam name="form.Alert_Pending_Accept_Programs"      default="0" />
<cfparam name="form.Alert_Pending_Accept_Programs_Days" default="0" />
<cfparam name="form.Planner_Category"                   default="" />
<cfparam name="form.Inc_all_Accrual_Prgs_in_Planner" 	default="1" />
<cfparam name="form.lsAllPrgTemplateIDs" 				default="" />

<cfif qGetPlannerTemplate.RecordCount>

    <cfscript>
        form.Planner_Type                       = qGetPlannerTemplate.Planner_Type;
        form.Planner_Description                = qGetPlannerTemplate.Planner_Description;
        form.Planner_Start_Date                 = qGetPlannerTemplate.Planner_Start_Date;
        form.Planner_End_Date                   = qGetPlannerTemplate.Planner_End_Date;
        form.Retroactive_Planner                = qGetPlannerTemplate.Retroactive_Planner;
        form.Retroactive_Planner_Days           = qGetPlannerTemplate.Retroactive_Planner_Days;
        form.Retroactive_Revision               = qGetPlannerTemplate.Retroactive_Revision;
        form.Retroactive_Revision_Days          = qGetPlannerTemplate.Retroactive_Revision_Days;
        form.Business_Segment_ID                = qGetPlannerTemplate.Business_Segment_ID;
        form.Price_List_Header_ID               = qGetPlannerTemplate.Price_List_Header_ID;
        form.Wholesaler_Planner                 = qGetPlannerTemplate.Wholesaler_Planner;
        form.Check_Duplicate_Planner            = qGetPlannerTemplate.Check_Duplicate_Planner;
        form.Check_Duplicate_Planner_Action     = qGetPlannerTemplate.Check_Duplicate_Planner_Action;
        form.Include_In_Catalog                 = qGetPlannerTemplate.Include_In_Catalog;
        form.Output_Before_Approval             = qGetPlannerTemplate.Output_Before_Approval;
        form.Auto_Generate_Accrual_Program      = qGetPlannerTemplate.Auto_Generate_Accrual_Program;
        form.Alert_RFA_Programs                 = qGetPlannerTemplate.Alert_RFA_Programs;
        form.Alert_RFA_Programs_Days            = qGetPlannerTemplate.Alert_RFA_Programs_Days;
        form.Alert_Pending_Accept_Programs      = qGetPlannerTemplate.Alert_Pending_Accept_Programs;
        form.Alert_Pending_Accept_Programs_Days = qGetPlannerTemplate.Alert_Pending_Accept_Programs_Days;
        form.Planner_Category                   = qGetPlannerTemplate.Category;
		form.Inc_all_Accrual_Prgs_in_Planner	= qGetPlannerTemplate.Inc_all_Accrual_Prgs_in_Planner;
    </cfscript>

</cfif>
<style>
    ##dataTable td:first-child {
        font-weight: bold;
    }
    ##dataTable td:first-child::after {
        content: ":";
    }
	##dataTable .skipTDcolon td:first-child::after {
        content: "";
    }
	##dataTable .skipTRcolon td:first-child::after {
        content: "";
    }
</style>
<table border="0" cellpadding="3" cellspacing="1" id="dataTable" width="100%">
	<tr>
		<th class="h2">
			Basic Info
		</th>
	</tr>
	<tr>
		<td width="30%">Type</td>
		<td>
			<INPUT NAME="Planner_Type" TYPE="text" SIZE="25" MAXLENGTH="50" value="#form.Planner_Type#">
		</td>
	</tr>
	<tr>
		<td>Description</td>
		<td>
			<INPUT NAME="Planner_Description" TYPE="text" SIZE="25" MAXLENGTH="50" value="#form.Planner_Description#">
		</td>
	</tr>
	<tr>
		<td>Start Date</td>
		<td>
			<CF_EASYDATE FORMNAME="DataForm" FIELDNAME="Planner_Start_Date" FORMAT="mm/dd/yyyy" default="#form.Planner_Start_Date#">
		</td>
	</tr>
	<tr>
		<td>End Date</td>
		<td>
			<CF_EASYDATE FORMNAME="DataForm" FIELDNAME="Planner_End_Date" FORMAT="mm/dd/yyyy" default="#form.Planner_End_Date#">
		</td>
	</tr>
	<cfset appSettings = createObject("component", "components.settings.InternalSettings") />
	<cfif appSettings.get_Setting("Filter_Business_Segments") eq "1" and application.returned_customer_setting.Business_Segments_On eq "1">
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager")>
		<cfset qBusinessSegments = businessSegManager.getActiveClasscodes() />
 		<tr>
			<td>#appSettings.get_Setting("business_segment_label")#</td>
			<td>
				<cfparam name="form.Business_Segment_ID" default="">
				<select name="Business_Segment_ID" style="line-height:20px;height:20px;">
					<option value="0">&nbsp;</option>
					<cfloop query="qBusinessSegments">
						<option value="#qBusinessSegments.Business_Segment_ID#"
							#(qBusinessSegments.Business_Segment_ID eq form.Business_Segment_ID ? "selected" : "")#>#qBusinessSegments.Business_Unit_Desc#</option>
					</cfloop>
				</select>
			</td>
		</tr>
	<cfelse>
		<!--- business segment is disabled --->
		<input type="hidden" name="Business_Segment_ID" value="">
	</cfif>
	<cfquery name="GetPriceList" datasource="#application.datasource#">
		SELECT      Price_List_Header_ID, Price_List_ID + '-' + Price_List_Description as Price_List_Diplay_Desc
		FROM        Price_List_Header
		WHERE       Deleted = 0
		ORDER BY    Price_List_Description
	</cfquery>

	<cfif application.appsettingsget.getPriceListByTemplate()>
	<tr>
		<td>Price List</td>
		<td>
			<SELECT NAME="Price_List_Header_ID" style="line-height:20px;height:20px;">
				<option value="0">&nbsp;</option>
				<cfloop query="GetPriceList">
					<OPTION VALUE="#GetPriceList.price_list_header_id#" <cfif form.Price_List_Header_ID eq GetPriceList.price_list_header_id>selected</cfif>>#GetPriceList.Price_List_Diplay_Desc#</OPTION>
				</cfloop>
			</SELECT>
		</TD>
	</tr>

	<cfelse>
		<input name="Price_List_Header_ID" type="hidden" value="" />
 	</cfif>

	<tr>
		<td>Category</td>
		<td>
			<!--- <INPUT NAME="Wholesaler_Planner" class="whlsPlanner" TYPE="checkbox" value="1" <cfif form.Wholesaler_Planner>checked</cfif>> --->
            <!--- keep the name in lower case, otherwise JS logic would fail - please do not change it --->
            <select name="planner_category">
                <option value="" <cfif form.planner_category eq ''>selected</cfif>></option>
                <option value="Direct" <cfif form.planner_category eq 'direct'>selected</cfif>>Direct</option>
                <option value="Indirect" <cfif form.planner_category eq 'Indirect'>selected</cfif>>Indirect</option>
                <option value="MSA" <cfif form.planner_category eq 'msa'>selected</cfif>>MSA</option>
                <option value="WholeSaler" <cfif form.planner_category eq 'wholesaler'>selected</cfif>>WholeSaler</option>
            </select>
		</td>
	</tr>
	<tr>
		<td>Auto Generate Accrual #Application.PlannerPrgLabel#</td>
		<td>
			<INPUT NAME="Auto_Generate_Accrual_Program" TYPE="checkbox" value="1" <cfif form.Auto_Generate_Accrual_Program>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>Include In Catalog</td>
		<td>
			<INPUT NAME="Include_In_Catalog" TYPE="checkbox" value="1" <cfif form.Include_In_Catalog>checked</cfif>>
		</td>
	</tr>
	<tr>
		<td>Check for Duplicate #Application.PlannerLabel#</td>
		<td>
			<INPUT NAME="Check_Duplicate_Planner" class="CheckDuplicatePlanner" TYPE="checkbox" value="1" <cfif form.Check_Duplicate_Planner>checked</cfif>>
		</td>
	</tr>
	<cfset chkDuplicatePlannerActionHide = "hideElem" />
	<cfif form.Check_Duplicate_Planner>
		<cfset chkDuplicatePlannerActionHide = "" />
	</cfif>
	<tr class="CheckDuplicatePlannerAction #chkDuplicatePlannerActionHide#">
		<td></td>
		<td>
			<input name="Check_Duplicate_Planner_Action" type="radio" value="1" <cfif form.Check_Duplicate_Planner_Action eq 1>checked</cfif>> Allow duplicate #Application.PlannerLabel_Plural#<br>
	    <input name="Check_Duplicate_Planner_Action" type="radio" value="2" <cfif form.Check_Duplicate_Planner_Action eq 2>checked</cfif>> Prevent duplication of #Application.PlannerLabel_Plural#
		</td>
	</tr>
	<tr>
		<td>Allow Output Before #Application.PlannerLabel# Approval</td>
		<td>
			<INPUT NAME="Output_Before_Approval" TYPE="checkbox" value="1" <cfif form.Output_Before_Approval>checked</cfif>>
		</td>
	</tr>
	<!----Notifications Start --->
	<tr>
		<th class="h2">
			Notifications
		</th>
	</tr>
	<tr>
		<td>Provide a notification for #Application.PlannerPrgLabel# that meet the date parameters below</td>
	</tr>
	<tr>
		<td colspan="1">RFA #Application.PlannerPrgLabel# that start in</td>
		<td>
			<INPUT NAME="Alert_RFA_Programs" TYPE="checkbox" value="1" <cfif form.Alert_RFA_Programs>checked</cfif> class="alertrfa">&nbsp;
			<INPUT NAME="Alert_RFA_Programs_Days" TYPE="text" value="#form.Alert_RFA_Programs_Days#" size="5" class="alertdays"> days
		</td>
	</tr>
		<tr>
		<td colspan="1">Pending Accept #Application.PlannerPrgLabel# that start in</td>
		<td>
			<INPUT NAME="Alert_Pending_Accept_Programs" TYPE="checkbox" value="1" <cfif form.Alert_Pending_Accept_Programs>checked</cfif> class="alertpendingaccept">&nbsp;
			<INPUT NAME="Alert_Pending_Accept_Programs_Days" TYPE="text" value="#form.Alert_Pending_Accept_Programs_Days#" size="5" class="alertdays"> days
		</td>
	</tr>
	<!----Notifications End --->

	<tr>
		<th class="h2">Date Rules</th>
	</tr>
	<tr>
		<td colspan="1">Allow Retroactive #Application.PlannerLabel_Plural#</td>
		<td>
			<INPUT NAME="Retroactive_Planner" TYPE="checkbox" value="1" <cfif form.Retroactive_Planner>checked</cfif>>&nbsp;
			<INPUT NAME="Retroactive_Planner_Days" TYPE="text" value="#form.Retroactive_Planner_Days#" size="5"> days
		</td>
	</tr>
		<tr>
		<td colspan="1">Allow Retroactive Revisions</td>
		<td>
			<INPUT NAME="Retroactive_Revision" TYPE="checkbox" value="1" <cfif form.Retroactive_Revision>checked</cfif>>&nbsp;
			<INPUT NAME="Retroactive_Revision_Days" TYPE="text" value="#form.Retroactive_Revision_Days#" size="5"> days
		</td>
	</tr>
	<tr>
		<th class="h2">Accruals</th>
	</tr>
	<tr>
		<td>Include all Accrual  #Application.PlannerPrgLabel#s in #Application.PlannerLabel# Accrual<br>
			<i>[Checked templates will be excluded from the accruals]</i>
		</td> <!--- Include all Accrual prgs in Planner --->
		<td><nobr><input name="Inc_all_Accrual_Prgs_in_Planner" id="Inc_all_Accrual_Prgs_in_Planner" type="radio" value="1" <cfif form.Inc_all_Accrual_Prgs_in_Planner eq 1>checked</cfif>> yes
	    		<input name="Inc_all_Accrual_Prgs_in_Planner" id="Inc_all_Accrual_Prgs_in_Planner" type="radio" value="0" <cfif form.Inc_all_Accrual_Prgs_in_Planner eq 0>checked</cfif>> no
			</nobr>	
		</td>
	</tr>
	<tr class="skipTRcolon" id="AccrualTempSelectionTR" <cfif (form.Inc_all_Accrual_Prgs_in_Planner eq 1)>style="display:none;"</cfif>>
		<td colspan="100%" class="skipTDcolon">
			<cfdiv bind="url:select_templates_accruals.cfm?planner_template_id={planner_template_id}&planner_segment_id={Business_Segment_ID}&selected_templates={Template_Select_Accrual}"/>	
		</td>	
	</tr>
	<tr>
		<th class="h2" class="skipTRcolon">Select Templates</th>
	</tr>

</table>

<cfscript>
	variables.bGetPlannerTemplates	= 1;
	variables.nPlannerTemplateId	= form.id;
</cfscript>
<script>
	function process_all(generic_type, checked) {
		$("input[genericType='" + generic_type + "']").prop("checked", checked);
	};
	function process_all_accrual(generic_type, checked) {
		$("input[genericTypeAcc='" + generic_type + "']").prop("checked", checked);
	}
	
</script>

<!--- create these hidden input to pass to binding call --->
<input type="hidden" name="Template_Select">
<input type="hidden" name="Template_Select_Accrual">
<input type="hidden" name="planner_template_id" value="#form.id#">

<!--- binding to get templates based on planner business_segment --->
<cfdiv bind="url:select_templates.cfm?planner_template_id={planner_template_id}&planner_segment_id={Business_Segment_ID}&selected_templates={Template_Select}"/>
</cfoutput>

<script>
$( "select[name=planner_category]" ).change(function() {
    let category = $(this).val().toLowerCase();
    if (category !== "wholesaler"){
		$(".whlsPlannerSwith").prop( "disabled", true ).prop( "checked", false ).addClass("disabled");
		$(".withLinkItem").css("display", "none");
		$(".withoutLinkItem").css("display", "block");
		$("input[name=lOperatorGroupLevelIDs]").val("");
	}
	else{
		$(".whlsPlannerSwith").prop( "disabled", false ).removeClass("disabled");
	}
});


$( "input.CheckDuplicatePlanner" ).change(function() {
	if($(this).prop("checked") == false){
		$(".CheckDuplicatePlannerAction").css("visibility", "hidden");

	}
	else{
		$(".CheckDuplicatePlannerAction").css("visibility", "visible");
	}
});

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
			 key == 46 || key == 45) {             <!---Del and Ins--->
			  return true;
			}
			return false;
		});
	 });
	}
})(jQuery);

$("input.alertdays").forceNumeric();

$( "input.alertrfa" ).change(function() {
	if($(this).prop("checked") == false){
		$("input[name=Alert_RFA_Programs_Days]").val("0");
	}
});

$( "input.alertpendingaccept" ).change(function() {
	if($(this).prop("checked") == false){
		$("input[name=Alert_Pending_Accept_Programs_Days]").val("0");
	}
});

 
$("input[type='radio'][name='Inc_all_Accrual_Prgs_in_Planner']").click(function(){
	var rdoAccValue = $("input[name='Inc_all_Accrual_Prgs_in_Planner']:checked").val();
    if(rdoAccValue == "1" ){
    	$("#AccrualTempSelectionTR").hide()
	}
	else
	{
		$("#AccrualTempSelectionTR").show()
	}
});
 
 
</script>
