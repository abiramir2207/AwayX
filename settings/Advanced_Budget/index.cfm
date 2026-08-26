<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\index.cfm
      Date:     June 2011
      Author:   Chris Nguyen
      Purpose:  Landing page for budget settings
----------------------------------------------------------------------------------------------------------------------->
<!---in some scenarios the command & budget_id are passed in the url--->
<cfif StructKeyExists(url, "command") and not StructKeyExists(form, "command")>
  <cfset form.command = url.command>
</cfif>
<cfif StructKeyExists(url, "budget_id") and not StructKeyExists(form, "budget_id")>
  <cfset form.budget_id = url.budget_id>
</cfif>

<cfparam name="form.budget_id"     default="0">
<cfparam name="form.command"       default="listbudget">
<cfparam name="url.byClassIDs"           default="">
<cfparam name="url.byGroupIDs"           default="">
<cfparam name="url.byBudgetTypeIDs"      default="">
<cfparam name="url.bySegmentIDs"      default="">
<cfparam name="url.bySearch"      default="">
<cfparam name="url.byBudgetCodes"      default="">

<cfmodule template="/customTags/layout.cfm"
							layoutID = "budgets"
              				jQueryUI = "1.8.23"
							command = "#form.command#"
							budget_id = "#form.budget_id#" >


<cfset jQueryUI.version = '1.11.4'/>
<cfinclude template="/common_files/jQuery.cfm">
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.1/jquery-ui.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/Script/javascript/jquery-impromptu.3.1.min.js"></script>

	<script type="text/javascript"> var glAccountLabel = '<cfoutput>#Application.GLAccountLabel#</cfoutput>'; </script>
	<script src="/script/javascript/string_functions.js?v=08182020"></script>
	<cf_include files=#arrayToList( [	 "/script/javascript/dom_common.js"
										,"/billbacks/common/common_js_functions.js"
										,"/script/javascript/queue.js"
										,"/script/javascript/format_functions.js"
										,"/script/javascript/dhtml.js"
										,"/common_files/delete_functions.js"
										,"/common_files/contracts/group_functions.js"
										,"/script/javascript/variable.debugger.js"
									])#>
<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment   START
Added/Changed: Added Appsettings Query --->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset oBudgetClassManager = createObject("component","mvc.Models.AdvancedBudget.BudgetClassManager") />
<cfset appSettings = genSettingsManager.get()>
<!--- End Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment --->
<cfset  qGetCreateBudget =  CreateObject("component", "components.user.profile").getCreateViewBudgetSetting(request.Accessstructure.Profiles_ID)>

<cfset form_name = "BudgetForm">
<script language="JavaScript" SRC="/settings/planning_groups/_planning_groups.js"></SCRIPT>
<cfoutput>
<script>
var budget_form = "#form_name#";
</script>
<form method="post" name="#form_name#" style="display:inline;">
</cfoutput>
<cfinclude template="budgetFormVars.cfm">

    <cfset profile = CreateObject("component","components.user.Profile").init()>
    <cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>

<cfset error_id = 0>
<!--------------------------------------------------------------------------------------------------------------------->
<cfswitch expression="#form.command#">
	<cfcase value="activateBudget,deactivateBudget">
		<cfinclude template="changeActivation.cfm" />
	</cfcase>

	<cfcase value="addBudget">
		<cfinclude template="addBudget.cfm" />
	</cfcase>
	
	<cfcase value="actionBudget">
		<cfinclude template="actionBudget.cfm" />
	</cfcase>

	<cfcase value="assignBudgets">
		<cfinclude template="assignBudgets.cfm" />
	</cfcase>

  <!--------------------------------------------------------------------------------------------------------------------->
	<cfcase value="calculateAccrual">
		<cfinclude template="calculateAccrual.cfm" />
	</cfcase>

	<cfcase value="copyBudget">
		<cfinclude template="copyBudget.cfm" />
	</cfcase>

	<cfcase value="deleteBudget">
		<cfinclude template="deleteBudget.cfm" />
	</cfcase>

  <!--------------------------------------------------------------------------------------------------------------------->
	<cfcase value="editAccrual,viewAccrual">
		<cfinclude template="accrualBudget.cfm" />
	</cfcase>

	<cfcase value="editBudgetGroup,addBudgetGroup,deleteBudgetGroup,saveBudgetGroup,viewBudgetGroup">
		<cfinclude template="budget_group_create_edit.cfm" />
	</cfcase>

	<cfcase value="editBudgetClass,addBudgetClass,deleteBudgetClass,saveBudgetClass,viewBudgetclass">
		<cfinclude template="budget_class_create_edit.cfm" />
	</cfcase>

	<cfcase value="editAdjustmentType,addAdjustmentType,deleteAdjustmentType,saveAdjustmentType,viewAdjustmentType">   <!---32147--->
		<cfinclude template="budget_adjustment_type_create_edit.cfm" />
	</cfcase> 

	<cfcase value="editDistributors">
		<cfinclude template="distributors.cfm" />
	</cfcase>

	<cfcase value="editFixed,viewFixed">
		<cfinclude template="fixedBudget.cfm" />
	</cfcase>

	<cfcase value="editVariable,viewVariable">
		<cfinclude template="variableBudget.cfm" />
	</cfcase>
<!---D42242 :: Create links w/in the application for client to run report to see Orphaned BB's and Programs--->
	<cfcase value="research">
		<cfinclude template="Orphaned_Programs_Billbacks.cfm" />
	</cfcase>
<!---D42242 :: Create links w/in the application for client to run report to see Orphaned BB's and Programs--->
	<cfcase value="editProducts">
		<cfinclude template="products.cfm" />
	</cfcase>

	<cfcase value="editRecaptures">
		<cfinclude template="recaptures.cfm" />
	</cfcase>

  <!--------------------------------------------------------------------------------------------------------------------->
  	<cfcase value="listBudget">
		<cfinclude template="listBudget.cfm" />
	</cfcase>

	<cfcase value="listbudgetclass">
		<cfinclude template="listClass.cfm" />
	</cfcase>

	<cfcase value="listbudgetgroup">
		<cfinclude template="listGroup.cfm" />
	</cfcase>

	<cfcase value="listBudgetLabel">
  	<script src="/script/javascript/string_functions.min.js"></script>
    <script type="text/javascript" src="/settings/budgets/budget.js"></script>
    <cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
		<cfinclude template="/settings/budgets/budget_label_edit.cfm" />
	</cfcase>

	<cfcase value="listComponent">
		<cfinclude template="listComponent.cfm" />
	</cfcase>

	<cfcase value="listAdjustmentTypes">                <!---32147--->
		<cfinclude template="listAdjustmentTypes.cfm" />
	</cfcase>

  <!--------------------------------------------------------------------------------------------------------------------->
	<cfcase value="saveAccrual">
	  <cfinclude template="accrualBudget.cfm" />
  </cfcase>

  <!--------------------------------------------------------------------------------------------------------------------->
	<cfcase value="templates">
	  <cfinclude template="templates.cfm" />
  </cfcase>

  <!--------------------------------------------------------------------------------------------------------------------->
	<cfcase value="listAdjustments">
	  <cfinclude template="listAdjustments.cfm" />
  </cfcase>

	<cfcase value="addAdjustment,saveAdjustment">
	  <cfinclude template="addAdjustment.cfm" />
  </cfcase>

	<cfcase value="uploadAdjustment">
	  <cfinclude template="uploadAdjustment.cfm" />
  </cfcase>

	<cfcase value="importAdjustments">
	  <cfinclude template="importAdjustments.cfm" />
  </cfcase>

	<cfcase value="saveBudgetLabel">
    	<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
		<cfset objBudgetClassManager = createObject('component','mvc.Models.AdvancedBudget.BudgetClassManager') />
		<!--- save budget class defaults --->
		<cfset objBudgetClassManager.saveBudgetClassDefault(form) />

		<!--- save budget labels --->
		<cfset form.id = BudgetManager.saveBudgetLabels(
							budgetDollarLabel = form.Budget_Dollar_Label,
							committedDollarLabel = form.Committed_Dollar_Label,
							budgetBalanceLabel = form.Budget_Balance_Label,
							approvedPaymentDollarLabel = form.Approved_Payment_Dollar_Label,
							availableBudgetDollarLabel = form.Available_Budget_Dollar_Label,
							budgetClassAssociationLabel = form.Budget_Class_Association_Label,
							userId = request.AccessStructure.User_ID) />
		<cflocation url="index.cfm" />
	</cfcase>

  <!--------------------------------------------------------------------------------------------------------------------->
	<cfcase value="listActAdjustment">
	  <cfinclude template="listActAdjustment.cfm" />
  </cfcase>

	<cfcase value="addactadjustment,saveactadjustment-saveAddAnother,saveactadjustment-saveReturn">
	  <cfinclude template="addActAdjustment.cfm" />
  </cfcase>

	<cfcase value="importActAdjustments">
	  <cfinclude template="importActAdjustments.cfm" />
  </cfcase>

	<cfdefaultcase>
	  <!--unexpected value in form.command-->
		<cfset error_id = 621>
	</cfdefaultcase>

</cfswitch>
<cfif error_id gt 0>
  Encountered unexpected error <cfoutput>#error_id#.</cfoutput>
</cfif>
</form>
<!--- 35750 --->
<form action="/common_files/csv.cfm" method ="post" id="csv_form">
  <input type="hidden" name="csv_text" id="csv_text">
  <input type="hidden" name="csv_file_name" id="csv_file_name">
</form>

<script type="text/javascript">
function clickheader( nextaction ) {
  if ( nextaction == "listbudgetclass"
    || nextaction == "listBudgetGroup"
    || nextaction == "listBudgetLabel"
    || nextaction == "listAdjustmentTypes"      // 32147
    || nextaction == "listActAdjustment"
    || nextaction == "listComponent" ) {
    document.forms[budget_form].budget_id.value = "0";
    document.forms[budget_form].load_fromdb.value = "0";
  }
  else {
    <!---load data from db on each tab click--->
    document.forms[budget_form].load_fromdb.value = "1";
  }
  document.forms[budget_form].command.value = nextaction;
  document.forms[budget_form].submit();
  return false;
}
</script>
</cfmodule>