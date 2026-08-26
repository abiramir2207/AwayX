<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\header.cfm
      Date:     June 13, 2011
      Author:   Chris Nguyen
      Purpose:  Budget - Control Panel Settings
----------------------------------------------------------------------------------------------------------------------->
<cf_tabStyle
    selectedBgColor = "##FFE083"
        borderWidth = "2" >

<!---color budget tabs differently--->
<style>
.accrual { background:url('/images/gradhead.png') repeat-x scroll 0 0 #B9C9FE !important; }
</style>

<cfscript>
  headerMenu = [];

	profile = CreateObject("component","components.user.Profile").init();
	Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID);

  ArrayAppend( headerMenu, {title="class", action="listbudgetclass"} );
  ArrayAppend( headerMenu, {title="group", action="listBudgetGroup"} );
  ArrayAppend( headerMenu, {title="labels", action="listBudgetLabel"});
  ArrayAppend( headerMenu, {title="adj types", action="listAdjustmentTypes"});    // 32147
  
  if ( Get_Profile_Settings.Budgets_Actual_Adjustment ) {
  	ArrayAppend( headerMenu, {title="act adj", action="listActAdjustment"} );
  }
  //ArrayAppend( headerMenu, {title="components", action="listComponent"});
  accrualStyle = "";
</cfscript>

<cfif form.budget_id eq 0>
  <cfset ArrayAppend( headerMenu, {title="budget", action="listBudget"} )>
<cfelse>
  <!---query the db to find out the budget type--->
  <cfquery name="qBudgetType" datasource="#application.datasource#">
      SELECT Budget_Contribution_Factor_Type_Id
             , Overlays
             , Overlay_Recapture
             , Recapture
        FROM Budget
       WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
  <!---special handling for accrual budget: add accrual tabs based on the budget type saved
       in the db, do not show these tabs when users switch the budget type to accrual and
       have not clicked the save button (they may click the other tabs w/o clicking save on
       budget page)--->
  <cfif qBudgetType.Budget_Contribution_Factor_Type_ID eq "1">
    <cfset ArrayAppend( headerMenu, {title="budget", action="editFixed"} )>
  <cfelseif qBudgetType.Budget_Contribution_Factor_Type_ID eq "2">
    <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
    <cfscript>
      // assign budget tab to editing accrual budget
      ArrayAppend( headerMenu, {title="budget", action="editAccrual"} );
      ArrayAppend( headerMenu, {title="#lcase(application.returned_customer_setting.Distributor_Label_Plural)#", action="editDistributors"} );
      ArrayAppend( headerMenu, {title="products", action="editProducts"} );
      if ( ( qBudgetType.Recapture eq 1 ) or ( qBudgetType.Overlay_Recapture eq 1 ) or ( qBudgetType.Overlays eq 1 ) )
        //ArrayAppend( headerMenu, {title="#lcase(appsettings.getPullbackLabelLower())#", action="editRecaptures"} );
        ArrayAppend( headerMenu, {title="advanced", action="editRecaptures"} );
      ArrayAppend( headerMenu, {title="accrual adj", action="listAdjustments"} );   // 32147//D34797 :Rename: Budget - Fixed Adjustments
    </cfscript>
  <cfelseif qBudgetType.Budget_Contribution_Factor_Type_ID eq "3">
    <cfset ArrayAppend( headerMenu, {title="budget", action="editVariable"} )>
  </cfif>
  <cfset ArrayAppend( headerMenu, {title="templates", action="templates"} )>
</cfif>

<table border="0" cellspacing="0" cellpadding="1" width="100%">
<cfsetting enablecfoutputonly="true" >
<cfoutput><tr></cfoutput>
<cfoutput><td class="headerspacer">&nbsp;</td></cfoutput>
<cfloop from="1" to="#ArrayLen(headerMenu)#" index="counter">
 <cfset class_name= "headernotselected">
 <cfset menuItem = headerMenu[counter]>
 <!--------------------------------------------------------------------------------------------------------------------->
 <cfif menuItem.title eq "budget">
   <cfif form.command eq "editAccrual"
      or form.command eq "editFixed"
      or form.command eq "editVariable"
      or form.command eq "addBudget"
      or form.command eq "calculateAccrual"
      or form.command eq "listBudget">
     <cfset class_name= "headerselected">
   </cfif>
   <cfset accrualStyle = "accrual">
 <!--------------------------------------------------------------------------------------------------------------------->
 <cfelseif menuItem.title eq "group">
   <cfif form.command contains "group">
     <cfset class_name= "headerselected">
   </cfif>
 <!--------------------------------------------------------------------------------------------------------------------->
 <cfelseif menuItem.title eq "class">
   <cfif form.command contains "class">
     <cfset class_name= "headerselected">
   </cfif>
 <!--------------------------------------------------------------------------------------------------------------------->
 <cfelseif menuItem.title eq "components">
   <cfif form.command contains "assignBudgets"
      or form.command contains "component">
     <cfset class_name= "headerselected">
   </cfif>
 <!--------------------------------------------------------------------------------------------------------------------->
 <cfelseif menuItem.title eq "adj types">        <!---32147--->
   <cfif form.command contains "adjustmenttype" and form.command neq "listAdjustments">
   	<cfset class_name= "headerselected">
   </cfif>
 <!--------------------------------------------------------------------------------------------------------------------->
 <cfelseif menuItem.title eq "adjustments">      <!---32147--->
   <cfif form.command eq "addadjustment" or form.command eq "saveAdjustment" or form.command eq "listAdjustments" or form.command eq "importAdjustments">
   	<cfset class_name= "headerselected">
   </cfif>
 <!--------------------------------------------------------------------------------------------------------------------->
 <cfelseif menuItem.title eq "act adj">     
   <cfif form.command eq "addactadjustment" or form.command eq "saveactAdjustment" 
   		or form.command eq "listActAdjustment" or form.command eq "importActAdjustments">
   	<cfset class_name= "headerselected">
   </cfif>
 <!--------------------------------------------------------------------------------------------------------------------->
 <cfelseif form.command eq menuItem.action>
   <cfset class_name= "headerselected">
 </cfif>
 <cfoutput><td class="#class_name# #accrualStyle#" style="font-size:10px;" width="78" align="center" nowrap onclick="javascript: return clickheader('#menuItem.action#', 0);"><b>#menuItem.title#</b></td></cfoutput>
 <cfoutput><td class="headerspacer"><img src="/images/fill.gif" width="1" height="1"  alt=""></td></cfoutput>
</cfloop>
<cfoutput><td class="headerspacer" width="100%"><img src="/images/fill.gif" width="1" height="1" alt=""></td></cfoutput>
<cfoutput></tr></cfoutput>
<cfsetting enablecfoutputonly="false" >
</table>

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
}
</script>
