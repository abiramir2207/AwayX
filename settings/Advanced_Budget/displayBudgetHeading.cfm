<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\displayBudgetHeading.cfm
      Date:     2014 Feb
      Author:   Chris Nguyen
      Purpose:  This shared include file displays budget heading
----------------------------------------------------------------------------------------------------------------------->

<cffunction name="displayBudgetHeading" output="true">
  <cfargument name="budget_ID" required="true">
  <cfargument name="showHorizontalBar" required="false" default="false">

  <cfquery name="local.qBudget" datasource="#application.datasource#">
      SELECT Budget_desc
             , Budget_Code
             , Overlays
             , Overlay_Recapture
             , Recapture
             , Budget_Status
             , Allocation_Position_Level
             , bc.Budget_Class_Desc
             , bg.Budget_Group_Desc
             , bs.Business_Unit_Desc
        FROM Budget
        LEFT JOIN Budget_Class bc ON bc.Budget_Class_ID = Budget.Budget_Class_ID
        LEFT JOIN Budget_Group bg ON bg.Budget_Group_ID = Budget.Budget_Group_ID
        LEFT JOIN Business_Segment bs ON Budget.Business_Segment_Id = bs.Business_Segment_Id
       WHERE Budget.Budget_Id = <cfqueryparam value="#arguments.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfquery>

  <div id="bHeader" style="padding:5px; font-size:1.38em; font-weight:bold; color:rgb(51,51,51); text-align:center; letter-spacing:0.0525em; line-height:1.5;">
  #local.qBudget.budget_code# &nbsp;&mdash;&nbsp; #application.util.string.capFirstTitle(local.qBudget.budget_desc)# &nbsp;&mdash;&nbsp; #local.qBudget.Budget_Class_Desc# &nbsp;&mdash;&nbsp; #application.util.string.capFirstTitle(local.qBudget.Budget_Group_Desc)#
  <cfif isDefined("request.AccessStructure.User_Business_Segments")>&nbsp;&mdash;&nbsp; #application.util.string.capFirstTitle(local.qBudget.Business_Unit_Desc)#</cfif>
  <cfif arguments.showHorizontalBar><hr/></cfif>
  </div>

</cffunction>