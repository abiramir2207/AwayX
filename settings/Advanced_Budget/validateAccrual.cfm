<cfset vars = {}>

<cfquery name="vars.qBudget" datasource="#application.datasource#">
    SELECT   Notification_Threshold_Commitments
           , Notification_Threshold_Actuals
           , Allocation_Position_Level
           , Holdback_Percentage
           , Participation_Required
           , Recapture
           , Net_Contribution
           , Overlays
           , Corporate_And_Local_Rate
           , Overlay_Recapture
           , Budget_Status
      FROM Budget
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="vars.qDistributors" datasource="#application.datasource#">
    SELECT COUNT(*) AS Count
      FROM Budget_Distributor
     WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
           AND Deleted = 0
</cfquery>

<cfquery name="vars.qProducts" datasource="#application.datasource#">
    SELECT *
      FROM Budget_Product_Rate
     WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfscript>
vars.error = "";
if ( vars.qDistributors.Count eq 0 )
  vars.error = vars.error & "100:distributors are missing;";
if ( vars.qProducts.recordCount eq 0 )
  vars.error = vars.error & "140:product planning groups are missing;";
</cfscript>

<!--------------------------------------------------------------------------------
<!---validate base rates--->
<cfquery name="vars.validate" dbtype = "query">
    SELECT COUNT(*) AS Errors
      FROM vars.qProducts
     WHERE Rate = 0 OR Rate_UOM = 0
</cfquery>
<cfif vars.validate.errors gt 0>
  <cfset vars.error = vars.error & "110:base rate/uom are missing;">
</cfif>

<cfif ( vars.qBudget.Recapture eq "1" )>
  <!---validate recapture rates--->
  <cfquery name="vars.validate" dbtype = "query">
      SELECT COUNT(*) AS Errors
        FROM vars.qProducts
       WHERE Recapture_Rate = 0 OR Recapture_Rate_UOM = 0
  </cfquery>
  <cfif vars.validate.errors gt 0>
    <cfset vars.error = vars.error & "120:recapture rate/uom are missing;">
  </cfif>
</cfif>

<cfif ( vars.qBudget.Corporate_And_Local_Rate eq "1" )>
  <!---validate corp rates--->
  <cfquery name="vars.validate" dbtype = "query">
      SELECT COUNT(*) AS Errors
        FROM vars.qProducts
       WHERE Overlay_Purchase_Minimum = 0 OR Overlay_Purchase_Minimum_UOM = 0
  </cfquery>
  <cfif vars.validate.errors gt 0>
    <cfset vars.error = vars.error & "130:overlay rate/uom are missing;">
  </cfif>
</cfif>
---------------------------------------------------------------------------------->
<cfset vars.budget_status = ''>
<cfif len(vars.error) eq 0>
  <cfset vars.budget_status = 'validated'>
</cfif>

<!---is the status changed? if it is, update the db--->
<cfif vars.qBudget.Budget_Status neq vars.Budget_Status>
  <cfquery name="vars.update" datasource="#application.datasource#">
     UPDATE Budget
        SET Budget_Status = '#vars.Budget_Status#'
      WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
</cfif>