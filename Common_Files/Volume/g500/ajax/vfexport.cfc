<!--------------------------------------------------------------------------------------------------------------------------------------------------------
  Component: \Common_Files\Volume\g500\ajax\vfexport.cfc
  Date:      2013 Jan 17
  Author:    Chris Nguyen
    
  Purposes:  Export volume forecast to an Excel file
  
  Remarks:   GM requested all 4 quarters and YTD/Annual to be included in the export. It may take a while to gather all the data and dump it out to an
             Excel file. Instead of displaying a blank page, I decided to display a "please wait.." message with an animated processing image and call
             this ajax component to create the Excel file.
             
             GenerateExport() function returns 2 pieces of information in json format:
              1. ExcelFileName = full path of the export Excel file name
              2. ExcelFileURL  = Web root relative path of the export Excel file. 
--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="vfExport" output="false" hint="This component handles volume forecast export.">

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="volumeFormat2" output="false" hint="Return volume format/percentage">
  <cfargument name="amt" required="true" hint="I am the volume amount">
  <cfargument name="nullForZero" required="false" type="boolean" default="false" hint="Optional argument, if it is true (default) a blank string is returned when volume amount is zero">
  <cfargument name="percentage" required="false" type="boolean" default="false" hint="Optional argument, if it is false (default) a formatted volume percentage is returned">

  <cfif val(arguments.amt) eq 0>
    <cfif arguments.nullForZero>
      <cfreturn "">
    <cfelseif arguments.percentage>
      <cfreturn NumberFormat(val(arguments.amt), const.percentFormat) <!---& '%'--->>
    <cfelse>
      <cfreturn "0">
    </cfif>
  <cfelse>
    <cfif arguments.percentage>
      <cfreturn NumberFormat(arguments.amt, const.percentFormat) <!---& '%'--->>
    <cfelse>
      <cfreturn NumberFormat(arguments.amt, const.volumeFormat2)>
    </cfif>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="deltaValue2" output="false" returntype="String" access="private" hint="Return delta value/percentage based on this year volume and last year volume">
  <cfargument name="ty" required="true" hint="I am this year volume">
  <cfargument name="ly" required="true" hint="I am last year volume">
  <cfargument name="percentage" required="false" type="boolean" default="false" hint="Optional percentage indicator, if value is true delta percentage is calculated and returned">

  <cfif not arguments.percentage>
    <cfreturn NumberFormat(val(arguments.ty) - val(arguments.ly), const.volumeFormat2)>
  <cfelseif val(arguments.ly) eq 0>
    <cfreturn "100">
  <cfelse>
      <cfreturn NumberFormat((val(arguments.ty) - val(arguments.ly)) / val(arguments.ly) * 100, const.percentFormat)>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="../vfUDF.cfm">        <!---volume forecast functions library--->

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="generateQtrExport" output="false" returnFormat="json" access="remote" hint="">
  <cfargument name="vfc_plan_id" required="true">
  <cfargument name="vfc_level_id" required="true">
  
    <cfscript>
      const.volumeFormat2 = "-999999999";
      const.percentFormat = "-999.00";
    
      main.summary       = (arguments.vfc_level_id eq "summary");
      main.isDevSite     = 1;                                // TODO: change it to 0 prior to deployment
      application.oController.getObject(path="mvc.models.volumeforecast.vfmanager", name="vfmanager", bReload=main.isDevSite);
      qOneRow            = queryNew('foo');
  		queryAddRow( qOneRow );
    </cfscript>

    <cfoutput>
    <cfquery name="qVolumePlan" Datasource="#application.datasource#">
      <cfif main.summary >
        SELECT Plan_Name = vf_Plan.vf_Plan_desc
              ,Forecast_Level
              ,User_Position_Id = 0
          FROM vf_Plan
         WHERE vf_Plan.vf_Plan_Id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.vfc_plan_id#">
      <cfelse>
        SELECT Plan_Name = vf_Plan.vf_Plan_desc
              ,Forecast_Level
              ,vf_Level.User_Position_Id
          FROM vf_Plan
               INNER JOIN vf_Level ON vf_Plan.vf_Plan_Id = vf_Level.vf_Plan_Id and vf_Level.Deleted = 0 and vf_Level.vf_level_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.vfc_level_id#">
         WHERE vf_Plan.vf_Plan_Id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.vfc_plan_id#">
      </cfif>
    </cfquery>
    </cfoutput>

    <cfscript>
      vars             = {};
      result           = {};
      vars.quarter     = 1;
      qProductPG       = application.oVfManager.getProductCategories( arguments.vfc_plan_id );
      qDirectAssignedMarkets = application.oVfManager.getDirectAssignedMarkets( Forecast_Level=qVolumePlan.Forecast_Level );
      qCurrPositionAndBelowMarkets = application.oVfManager.getCurrPositionAndBelowVF( arguments.vfc_plan_id );
      qLevel           = application.oVfManager.getLevels( vf_id=arguments.vfc_plan_id, level=arguments.vfc_level_id );
    
      const.working_year = Right(qLevel.Year_Selection, 2);
      const.ty_label     = "F" & const.working_year;         // working year column label
      const.ly_label     = "F" & (const.working_year - 1);   // previous year column label
      const.ybly_label   = "F" & (const.working_year - 2);   // year before previous year column label
    
      excel = {};
      excel.sheet = SpreadsheetNew( QuarterName(1) );        // create 1st sheet
      
      qDirectAssignedMarkets = application.oVfManager.getDirectAssignedMarkets( Forecast_Level=qVolumePlan.Forecast_Level );
      qCurrPositionAndBelowMarkets = application.oVfManager.getCurrPositionAndBelowVF( arguments.vfc_plan_id );
      qActualPeriods  = application.oVfManager.getPeriodsbyStatus( vf_id=arguments.vfc_plan_id, actual=1 );
      if ( main.summary ) {
         qForecastDetail = application.oVfManager.getDetail( vf_id=arguments.vfc_plan_id, level=valuelist(qCurrPositionAndBelowMarkets.VF_Level_ID) );
      }
      else {
         qForecastDetail = application.oVfManager.getDetail( vf_id=arguments.vfc_plan_id, level=arguments.vfc_level_id );
      }
    </cfscript>

    <!--- export all 4 quarters --->
    <cfloop from="1" to="4" index="vars.quarter">
      <!--- adding additional excel sheets for 2nd qtr, 3rd qtr & 4th qtr --->
      <cfif vars.quarter gt 1>
        <cfset vars.quarterName = QuarterName(vars.quarter)>
        <cfset spreadsheetCreateSheet (excel.sheet, vars.quarterName)>
        <cfset SpreadsheetSetActiveSheet(excel.sheet, vars.quarterName)>
      </cfif>
      
      <cfscript>
        if ( main.summary ) {
          qPeriod = application.oVfManager.getPeriods( vf_id=arguments.vfc_plan_id, quarter=vars.quarter );
          qLevel           = application.oVfManager.getLevels( vf_id=arguments.vfc_plan_id, level=qCurrPositionAndBelowMarkets.VF_Level_ID );
          qForecast3Months = application.oVfManager.getDetail( vf_id=arguments.vfc_plan_id, level=valuelist(qCurrPositionAndBelowMarkets.VF_Level_ID), periods=ValueList(qPeriod.VF_Period_Id) );
        }
        else {
          qPeriod = application.oVfManager.getPeriods( vf_id=arguments.vfc_plan_id, quarter=vars.quarter );
          qForecast3Months = application.oVfManager.getDetail( vf_id=arguments.vfc_plan_id, level=arguments.vfc_level_id, periods=ValueList(qPeriod.VF_Period_Id) );
        }
      </cfscript>
    
      <!---count number of periods became actual--->
      <cfquery name="qBecameActual" dbtype="query">
         SELECT 1
           FROM qPeriod
          WHERE Became_Actual = 1
      </cfquery>
    
      <cfscript>
        vars.aQueryColumn       = [];
        vars.aQueryColumnA      = [];
        vars.aQueryColumnB      = [];
        vars.aExcelColumnLabel  = [];
        vars.aExcelColumnLabelA = [];
        vars.lineFeed           = chr(10);
    
        vars.aQueryColumn[ 1 ] = "ly_vol";                vars.aExcelColumnLabel[ 1 ] = const.ly_label & " EQCs";
        vars.aQueryColumn[ 2 ] = "ly_ybly_delta_perc";    vars.aExcelColumnLabel[ 2 ] = const.ly_label & " %" & vars.lineFeed & "+/- " & const.ybly_label;
        vars.aQueryColumn[ 3 ] = "ty_delta_perc";         vars.aExcelColumnLabel[ 3 ] = const.ty_label & " FC" & vars.lineFeed & "(% +/- " & const.ly_label & ")";
        vars.aQueryColumn[ 4 ] = "ty_vol";                vars.aExcelColumnLabel[ 4 ] = const.ty_label & " Forecast" & vars.lineFeed & "EQCs";
        vars.aQueryColumn[ 5 ] = "ty_ly_delta_amt";       vars.aExcelColumnLabel[ 5 ] = "FC +/- " & const.ly_label & vars.lineFeed & "EQCs";
        vars.aQueryColumn[ 6 ] = "ty_ly_delta_perc";      vars.aExcelColumnLabel[ 6 ] = "FC %" & vars.lineFeed & "+/- " & const.ly_label;
        vars.aQueryColumn[ 7 ] = "ty_pgm";                vars.aExcelColumnLabel[ 7 ] = const.ty_label & " PGM";
        vars.aQueryColumn[ 8 ] = "ty_pgm_delta_amt";      vars.aExcelColumnLabel[ 8 ] = "FC +/- PGM";
        vars.aQueryColumn[ 9 ] = "ty_pgm_delta_perc";     vars.aExcelColumnLabel[ 9 ] = "FC %" & vars.lineFeed & "+/- PGM";
    
        vars.aQueryColumnA[ 1 ] = "sum_actual_Volume";    vars.aExcelColumnLabelA[ 1 ] = const.ty_label & " ACT" & vars.lineFeed & "EQCs";
        vars.aQueryColumnA[ 2 ] = "act_ly_delta_amt";     vars.aExcelColumnLabelA[ 2 ] = "ACT +/- " & vars.lineFeed & const.ly_label & " EQCs";
        vars.aQueryColumnA[ 3 ] = "act_ly_delta_perc";    vars.aExcelColumnLabelA[ 3 ] = "ACT % +/- " & vars.lineFeed & const.ly_label & " EQCs";
        vars.aQueryColumnA[ 4 ] = "act_ty_delta_amt";     vars.aExcelColumnLabelA[ 4 ] = "ACT +/- FC" & vars.lineFeed & "EQCs";
        vars.aQueryColumnA[ 5 ] = "act_ly_delta_perc";    vars.aExcelColumnLabelA[ 5 ] = "ACT %" & vars.lineFeed & "+/- FC";
        vars.aQueryColumnA[ 6 ] = "act_pgm_delta_amt";    vars.aExcelColumnLabelA[ 6 ] = "ACT +/-" & vars.lineFeed & "PGM";
        vars.aQueryColumnA[ 7 ] = "act_pgm_delta_perc";   vars.aExcelColumnLabelA[ 7 ] = "ACT %" & vars.lineFeed & "+/- PGM";
    
        vars.aQueryColumnB[ 1 ] = "product";
        vars.aQueryColumnB[ 2 ] = "ytd_trend";
        vars.aQueryColumnB[ 3 ] = "fiftytwo_wk_trend";
        vars.aQueryColumnB[ 4 ] = "thirteen_wk_trend";
        
        vars.sQueryColumns      = arrayToList( vars.aQueryColumnB );
        vars.sExcelColumnLabels = "Product,YTD TREND,52 WK TREND,13 WK TREND ";
      </cfscript>
      
      <!--- DEFINE QUERY COLUMNS: this query will have the same layout structure as the content on the Excel file. --->
      <!---scan thru all 3 months in quarter--->
      <cfset vars.thisMonth = 0>
      <cfloop query="qPeriod">
        <cfset vars.thisMonth++>
        <cfif qPeriod.Became_Actual>  
          <!---gather column names for the query (actual months)--->
          <cfloop array="#vars.aQueryColumnA#" index="vars.thisMonthColumn">
            <!---append _m1 to 1st month, _m2 to 2nd month and _m3 to 3rd month--->
            <cfset vars.sQueryColumns = vars.sQueryColumns & ", " & vars.thisMonthColumn & "_m" & vars.thisMonth>
          </cfloop>
        <cfelse>
          <!---gather column names for the query (non-actual months)--->
          <cfloop array="#vars.aQueryColumn#" index="vars.thisMonthColumn">
            <!---append _m1 to 1st month, _m2 to 2nd month and _m3 to 3rd month--->
            <cfset vars.sQueryColumns = vars.sQueryColumns & ", " & vars.thisMonthColumn & "_m" & vars.thisMonth>
          </cfloop>
        </cfif>
      </cfloop>
    
      <!---add column names for quarter section--->
      <cfif qBecameActual.recordCount eq 3>
        <cfloop array="#vars.aQueryColumnA#" index="vars.thisMonthColumn">
          <!---append _qtr to column name--->
          <cfset vars.sQueryColumns = vars.sQueryColumns & ", " & vars.thisMonthColumn & "_qtr">
        </cfloop>
      <cfelse>
        <cfloop array="#vars.aQueryColumn#" index="vars.thisMonthColumn">
          <!---append _qtr to column name--->
          <cfset vars.sQueryColumns = vars.sQueryColumns & ", " & vars.thisMonthColumn & "_qtr">
        </cfloop>
      </cfif>
    
    
      <!--- EXCEL COLUMN HEADINGS --->
      <cfset vars.headingDelimeter = repeatString(vars.lineFeed, 2)>
      <cfloop query="qPeriod">
        <cfif qPeriod.Became_Actual>  
          <!---gather excel column headings (actual month)--->
          <cfloop array="#vars.aExcelColumnLabelA#" index="vars.thisMonthColumn">
             <!--- format as name_of_the_month + " [" + column_label + "]" (e.g. June [F12 EQCs]) --->
            <cfset vars.sExcelColumnLabels = vars.sExcelColumnLabels & ", " & qPeriod.Period_Desc & vars.headingDelimeter & vars.thisMonthColumn>
          </cfloop>
        <cfelse>
          <!---gather excel column headings (non-actual month)--->
          <cfloop array="#vars.aExcelColumnLabel#" index="vars.thisMonthColumn">
             <!--- format as name_of_the_month + " [" + column_label + "]" (e.g. June [F12 EQCs]) --->
            <cfset vars.sExcelColumnLabels = vars.sExcelColumnLabels & ", " & qPeriod.Period_Desc & vars.headingDelimeter & vars.thisMonthColumn>
          </cfloop>
        </cfif>
      </cfloop>
      
      <!---add column names for quarter section--->
      <cfloop array="#vars.aExcelColumnLabel#" index="vars.thisMonthColumn">
        <!--- format as "QTR [" + column_label + "]" (e.g. QTR [F12 EQCs]) --->
        <cfset vars.sExcelColumnLabels = vars.sExcelColumnLabels & ", " & QuarterName(vars.quarter) & vars.headingDelimeter & vars.thisMonthColumn>
      </cfloop>
    
      <!--- create dynamic query with columns matching with the export layout --->
      <cfset qExcel = queryNew(vars.sQueryColumns, "VarChar " & repeatString(",VarChar", listLen(vars.sQueryColumns) - 1))> 
    
      <!------------------------------------------------------- GRAND TOTAL ------------------------------------------------------------->
      <cfquery name="qActual" dbtype="query">
           SELECT   SUM(ly_volume)     AS ly_volume
                  , SUM(actual_Volume) AS actual_Volume
             FROM qForecastDetail
            WHERE 1 = 1
              AND <cfif qActualPeriods.recordCount>
                    VF_Period_ID in (<cfqueryparam value="#ValueList(qActualPeriods.VF_Period_ID)#" cfsqltype="cf_sql_integer" list="yes">)
                  <cfelse>
                    1 = 0
                  </cfif>
      </cfquery>
      <cfif qActual.recordCount eq 0>
          <cfquery name="qActual" dbtype="query">
             SELECT  0 AS ly_volume
                   , 0 AS actual_Volume
               FROM qOneRow
          </cfquery>
      </cfif>

      <cfquery name="qSubtotals" dbtype="query">
         SELECT SUM(rolling_52)       AS sum_rolling_52
               , SUM(rolling_prev_52) AS sum_rolling_prev_52
               , SUM(rolling_13)      AS sum_rolling_13
               , SUM(rolling_prev_13) AS sum_rolling_prev_13
           FROM qForecast3Months
      </cfquery>
      <cfif qSubtotals.recordCount eq 0>
	      <cfquery name="qSubtotals" dbtype="query">
	         SELECT  0 AS sum_rolling_52
	               , 0 AS sum_rolling_prev_52
	               , 0 AS sum_rolling_13
	               , 0 AS sum_rolling_prev_13
	           FROM qOneRow
	      </cfquery>
      </cfif>
      
      <cfset queryAddRow(qExcel)>
      <cfset querySetCell(qExcel, vars.aQueryColumnB[ 1 ], "GRAND TOTAL")>
      <cfset querySetCell(qExcel, vars.aQueryColumnB[ 2 ], deltaValue2(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=1))>
      <cfset querySetCell(qExcel, vars.aQueryColumnB[ 3 ], trendValue(ty=qSubtotals.sum_rolling_52, ly=qSubtotals.sum_rolling_prev_52))>
      <cfset querySetCell(qExcel, vars.aQueryColumnB[ 4 ], trendValue(ty=qSubtotals.sum_rolling_13, ly=qSubtotals.sum_rolling_prev_13))>

      <cfset vars.thisMonth = 0>
      <cfloop query="qPeriod">
            <cfset vars.thisMonth++>
            <cfquery name="qSubtotals" dbtype="query">
               SELECT  SUM(ly_Volume)       AS sum_ly_Volume              <!---last year amount--->
                     , SUM(ty_volume)       AS sum_ty_Volume              <!---forecast amount--->
                     , SUM(ty_pgm)          AS sum_ty_pgm                    <!---program amount--->
                     , SUM(ybly_Volume)     AS sum_ybly_Volume          <!---year before last year amount--->
                     , SUM(actual_volume)   AS sum_actual_Volume      <!---actual amount--->
                     , SUM(rolling_52)      AS sum_rolling_52
                     , SUM(rolling_prev_52) AS sum_rolling_prev_52
                     , SUM(rolling_13)      AS sum_rolling_13
                     , SUM(rolling_prev_13) AS sum_rolling_prev_13
                 FROM qForecast3Months
                WHERE VF_Period_Id = <cfqueryparam value="#qPeriod.VF_Period_Id#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfif qSubtotals.recordCount eq 0>
	            <cfquery name="qSubtotals" dbtype="query">
	               SELECT  0 AS sum_ly_Volume              <!---last year amount--->
	                     , 0 AS sum_ty_Volume              <!---forecast amount--->
	                     , 0 AS sum_ty_pgm                    <!---program amount--->
	                     , 0 AS sum_ybly_Volume          <!---year before last year amount--->
	                     , 0 AS sum_actual_Volume      <!---actual amount--->
	                     , 0 AS sum_rolling_52
	                     , 0 AS sum_rolling_prev_52
	                     , 0 AS sum_rolling_13
	                     , 0 AS sum_rolling_prev_13
	                 FROM qOneRow
            	</cfquery>
            </cfif>

           <cfset vars.thisSuffix = "_m" & vars.thisMonth>
            <cfif qPeriod.Became_Actual>
                  <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 1 ] & vars.thisSuffix, NumberFormat(qSubtotals.sum_actual_Volume, const.volumeFormat2))>
                  <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 2 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_volume, percentage=0))>
                  <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 3 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_volume, percentage=1))>
                  <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 4 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_volume, percentage=0))>
                  <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 5 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_volume, percentage=1))>
                  <!---06---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 6 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm, percentage=0))>
                  <!---07---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 7 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm, percentage=1))>
            <cfelse>
                    <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 1 ] & vars.thisSuffix, NumberFormat(qSubtotals.sum_ly_Volume, const.volumeFormat2))>
                    <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 2 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1))>
                    <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 3 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1))>
                    <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 4 ] & vars.thisSuffix, NumberFormat(qSubtotals.sum_ty_Volume, const.volumeFormat2))>
                    <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 5 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_ty_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0))>
                    <!---06---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 6 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1))>
                    <!---07---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 7 ] & vars.thisSuffix, NumberFormat(qSubtotals.sum_ty_pgm, const.volumeFormat2))>
                    <!---08---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 8 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_ty_Volume, ly=qSubtotals.sum_ty_pgm, percentage=0))>
                    <!---09---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 9 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1))>
            </cfif>    <!--- qPeriod.Became_Actual --->
      </cfloop>   <!---query="qPeriod"--->
    
      <cfquery name="qSubtotals" dbtype="query">
             SELECT  SUM(ly_Volume)     AS sum_ly_Volume
                   , SUM(ty_Volume)     AS sum_ty_Volume
                   , SUM(ty_pgm)        AS sum_ty_pgm
                   , SUM(ybly_Volume)   AS sum_ybly_Volume
                   , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
             FROM qForecast3Months
      </cfquery>
      <cfif qSubtotals.recordCount eq 0>
        <cfquery name="qSubtotals" dbtype="query">
             SELECT  0 AS sum_ly_Volume
                   , 0 AS sum_ty_Volume
                   , 0 AS sum_ty_pgm
                   , 0 AS sum_ybly_Volume
                   , 0 AS sum_actual_Volume      <!---actual amount--->
               FROM qOneRow
      	</cfquery>
      </cfif>

      <cfset vars.thisSuffix = "_qtr">
      <cfif qBecameActual.recordCount eq 3>
          <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 1 ] & vars.thisSuffix, NumberFormat(qSubtotals.sum_actual_Volume,const.volumeFormat2))>                                 <!---actual volume--->
          <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 2 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0))>        <!---delta between actual & last year--->
          <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 3 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1))>        <!---delta % between actual & last year--->
          <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 4 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_Volume, percentage=0))>        <!---delta between actual & forecast--->
          <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 5 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1))>        <!---delta % between actual & forecast--->
          <!---06---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 6 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=0))>        <!---delta between actual & program--->
          <!---07---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 7 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=1))>        <!---delta % between actual & program--->
      <cfelse>
          <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 1 ] & vars.thisSuffix, NumberFormat(qSubtotals.sum_ly_Volume,const.volumeFormat2))>
          <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 2 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1))>

          <!---tue 2012/feb/21: Paul changed FC forecast EQC column to be sum of actual volume (months in the past) + sum of forecast (current & future months)--->
          <cfquery name="qFCSubtotals" dbtype="query">
               SELECT  SUM(ly_Volume)     AS sum_ly_Volume
                     , SUM(ty_Volume)     AS sum_ty_Volume
                     , SUM(ty_pgm)        AS sum_ty_pgm
                     , SUM(ybly_Volume)   AS sum_ybly_Volume
                     , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
               FROM qForecast3Months
               WHERE Became_Actual = 0
          </cfquery>
		      <cfif qFCSubtotals.recordCount eq 0>
		        <cfquery name="qFCSubtotals" dbtype="query">
               SELECT  0 AS sum_ly_Volume
                     , 0 AS sum_ty_Volume
                     , 0 AS sum_ty_pgm
                     , 0 AS sum_ybly_Volume
                     , 0 AS sum_actual_Volume      <!---actual amount--->
		               FROM qOneRow
		      	</cfquery>
		      </cfif>
          <cfquery name="qACTSubtotals" dbtype="query">
               SELECT  SUM(ly_Volume)     AS sum_ly_Volume
                     , SUM(ty_Volume)     AS sum_ty_Volume
                     , SUM(ty_pgm)        AS sum_ty_pgm
                     , SUM(ybly_Volume)   AS sum_ybly_Volume
                     , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
               FROM qForecast3Months
               WHERE Became_Actual = 1
          </cfquery>
		      <cfif qACTSubtotals.recordCount eq 0>
		        <cfquery name="qACTSubtotals" dbtype="query">
               SELECT  0 AS sum_ly_Volume
                     , 0 AS sum_ty_Volume
                     , 0 AS sum_ty_pgm
                     , 0 AS sum_ybly_Volume
                     , 0 AS sum_actual_Volume      <!---actual amount--->
		               FROM qOneRow
		      	</cfquery>
		      </cfif>

          <cfset quarter = structnew()>
          <cfset quarter.sum_ty_volume = val(qFCSubtotals.sum_ty_Volume) + val(qACTSubtotals.sum_actual_Volume)>

          <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 4 ] & vars.thisSuffix, NumberFormat(quarter.sum_ty_volume, const.volumeFormat2))>

          <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 5 ] & vars.thisSuffix, deltaValue2(ty=quarter.sum_ty_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0))>
          <!---06---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 6 ] & vars.thisSuffix, deltaValue2(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1))>
          <!---07---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 7 ] & vars.thisSuffix, NumberFormat(qSubtotals.sum_ty_pgm,const.volumeFormat2))>
          <!---08---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 8 ] & vars.thisSuffix, deltaValue2(ty=quarter.sum_ty_Volume, ly=qSubtotals.sum_ty_pgm, percentage=0))>
          <!---09---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 9 ] & vars.thisSuffix, deltaValue2(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1))>
      </cfif>   <!---qBecameActual.recordCount eq 3--->

      <!--------------------------------------------------------- PRODUCT --------------------------------------------------------------->
      <!--- SCAN THRU ALL PRODUCTS --->
      <cfloop query="qProductPG">
        <cfset queryAddRow(qExcel)>
        
        <cfquery name="qForecastMonths" dbtype="query">
            SELECT   SUM(Rolling_52)      AS Rolling_52
                   , SUM(Rolling_Prev_52) AS Rolling_Prev_52
                   , SUM(Rolling_13)      AS Rolling_13
                   , SUM(Rolling_Prev_13) AS Rolling_Prev_13
             FROM qForecast3Months
            WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
        </cfquery>
	      <cfif qForecastMonths.recordCount eq 0>
	        <cfquery name="qForecastMonths" dbtype="query">
	            SELECT   0 AS Rolling_52
	                   , 0 AS Rolling_Prev_52
	                   , 0 AS Rolling_13
	                   , 0 AS Rolling_Prev_13
	              FROM qOneRow
	      	</cfquery>
	      </cfif>
        
        <cfquery name="qActual" dbtype="query">
             SELECT  SUM(ly_volume) AS ly_volume
                    , SUM(actual_Volume) AS actual_Volume
               FROM qForecastDetail
              WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
                AND <cfif qActualPeriods.recordCount>
                      VF_Period_ID in (<cfqueryparam value="#ValueList(qActualPeriods.VF_Period_ID)#" cfsqltype="cf_sql_integer" list="yes">)
                    <cfelse>
                      1 = 0
                    </cfif>
        </cfquery>
        <cfif qActual.recordCount eq 0>
            <cfquery name="qActual" dbtype="query">
               SELECT  0 AS ly_volume
                     , 0 AS actual_Volume
                 FROM qOneRow
            </cfquery>
        </cfif>
        
        <cfset querySetCell(qExcel, vars.aQueryColumnB[ 1 ], qProductPG.pg_Product_Category_Name)>
        <cfset querySetCell(qExcel, vars.aQueryColumnB[ 2 ], deltaValue2(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=1))>
        <cfset querySetCell(qExcel, vars.aQueryColumnB[ 3 ], trendValue(ty=qForecastMonths.Rolling_52, ly=qForecastMonths.Rolling_Prev_52))>
        <cfset querySetCell(qExcel, vars.aQueryColumnB[ 4 ], trendValue(ty=qForecastMonths.rolling_13, ly=qForecastMonths.rolling_prev_13))>
      
        <cfset vars.thisMonth = 0>
        <cfloop query="qPeriod">
    
            <cfset vars.thisMonth++>
            <!---GATHER DATA FOR ONE MONTH--->
            <cfquery name="qForecastMonth" dbtype="query">
                <cfif main.summary>
                    <!--- combine multiple records from different levels into one summary record --->
                    SELECT   SUM(Actual_Volume)   AS Actual_Volume
                           , 0                    AS Became_Actual
                           , 0                    AS Ly_Delta_Percentage
                           , SUM(Ly_Volume)       AS Ly_Volume
                           , SUM(Rolling_52)      AS Rolling_52
                           , SUM(Rolling_Prev_52) AS Rolling_Prev_52
                           , SUM(Rolling_13)      AS Rolling_13
                           , SUM(Rolling_Prev_13) AS Rolling_Prev_13
                           , 0                    AS Ty_Delta_Percentage
                           , SUM(Ty_PGM)          AS Ty_PGM
                           , 0                    AS Ty_PGM_Forecast_Delta
                           , 0                    AS Ty_PGM_Forecast_Delta_Percentage
                           , SUM(Ty_Volume)       AS Ty_Volume
                           , 0                    AS VF_Detail_ID
                           , <cfoutput>#qPeriod.VF_Period_Id#</cfoutput> AS VF_Period_ID
                           , SUM(Ybly_Volume)     AS Ybly_Volume
						        		   , 0                    AS Use_Absolute
                     FROM qForecast3Months
                    WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
                      AND VF_Period_Id = <cfqueryparam value="#qPeriod.VF_Period_Id#" cfsqltype="cf_sql_integer">
                <cfelse>
                    SELECT *
                     FROM qForecast3Months
                    WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
                      AND VF_Period_Id = <cfqueryparam value="#qPeriod.VF_Period_Id#" cfsqltype="cf_sql_integer">
                </cfif>
            </cfquery>
		        <cfif qForecastMonth.recordCount eq 0>
		            <cfquery name="qForecastMonth" dbtype="query">>
                    SELECT   0 AS Actual_Volume
                           , 0 AS Became_Actual
                           , 0 AS Ly_Delta_Percentage
                           , 0 AS Ly_Volume
                           , 0 AS Rolling_52
                           , 0 AS Rolling_Prev_52
                           , 0 AS Rolling_13
                           , 0 AS Rolling_Prev_13
                           , 0 AS Ty_Delta_Percentage
                           , 0 AS Ty_PGM
                           , 0 AS Ty_PGM_Forecast_Delta
                           , 0 AS Ty_PGM_Forecast_Delta_Percentage
                           , 0 AS Ty_Volume
                           , 0 AS VF_Detail_ID
                           , <cfoutput>#qPeriod.VF_Period_Id#</cfoutput> AS VF_Period_ID
                           , 0 AS Ybly_Volume
                      FROM qOneRow
		            </cfquery>
		        </cfif>
        
            <!---enable percentage input when last year volume exist--->
            <cfset main.percentInputEnabled = ( Val(qForecastMonth.ly_Volume) neq 0 and main.summary eq false )>
            <cfif not main.percentInputEnabled or qForecastMonth.use_absolute eq '1'>                       <!---percentage input is off--->
              <cfset main.ty_vol = qForecastMonth.ty_Volume>
            <cfelseif val(qForecastMonth.ly_Volume) neq 0 <!--- and val(qForecastMonth.ty_Delta_Percentage) neq 0 --->>       <!---calculate this year volume based on last year volume and delta %--->
              <cfset main.ty_vol = (qForecastMonth.ly_Volume * ( 1 + (val(qForecastMonth.ty_Delta_Percentage) / 100) ))>
            <cfelse>
              <cfset main.ty_vol = "">                <!---missing values, can't calculate this year volume--->
            </cfif>
            
            <cfset vars.thisSuffix = "_m" & vars.thisMonth>
            <cfif qPeriod.Became_Actual>
                  <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 1 ] & vars.thisSuffix, volumeFormat2(amt=qForecastMonth.actual_Volume, nullForZero=false))>
                  <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 2 ] & vars.thisSuffix, deltaValue2(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ly_volume, percentage=0))>
                  <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 3 ] & vars.thisSuffix, deltaValue2(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ly_volume, percentage=1))>
                  <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 4 ] & vars.thisSuffix, deltaValue2(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_volume, percentage=0))>
                  <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 5 ] & vars.thisSuffix, deltaValue2(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_volume, percentage=1))>
                  <!---06---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 6 ] & vars.thisSuffix, deltaValue2(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_pgm, percentage=0))>
                  <!---07---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 7 ] & vars.thisSuffix, deltaValue2(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_pgm, percentage=1))>
            <cfelse>
                <!---display forecast values normally--->
                <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 1 ] & vars.thisSuffix, volumeFormat2(qForecastMonth.ly_Volume))>
                            <cfif val(qForecastMonth.ybly_volume) eq 0 or val(qForecastMonth.ly_volume) eq 0>
                              <!--- do nothing here --->
                            <cfelse>
                <!---02--->   <cfset querySetCell(qExcel, vars.aQueryColumn[ 2 ] & vars.thisSuffix, deltaValue2(ty = qForecastMonth.ly_volume, ly = qForecastMonth.ybly_volume, percentage=1))>
                            </cfif>
                            <cfif main.percentInputEnabled and qForecastMonth.use_absolute neq '1'>
                <!---03--->   <cfset querySetCell(qExcel, vars.aQueryColumn[ 3 ] & vars.thisSuffix, volumeFormat2(amt=qForecastMonth.ty_Delta_Percentage, percentage=1))>
                            </cfif>
                <!---04---> <cfif val(main.ty_vol) neq 0> <cfset querySetCell(qExcel, vars.aQueryColumn[ 4 ] & vars.thisSuffix, volumeFormat2(main.ty_vol))> </cfif>
                <!---05---> <cfif val(main.ty_vol) neq 0> <cfset querySetCell(qExcel, vars.aQueryColumn[ 5 ] & vars.thisSuffix, NumberFormat(main.ty_vol - val(qForecastMonth.ly_Volume), const.volumeFormat2))> </cfif>
        
                <!---06---> <cfif main.percentInputEnabled>
                <!---06--->   <cfset main.ty_Delta_Percentage = qForecastMonth.ty_Delta_Percentage>
                <!---06---> <cfelse>                                     <!---percentage input is off, calculate the percentage--->
                <!---06--->   <cfset main.ty_Delta_Percentage = deltaValue2(ty = main.ty_vol, ly = qForecastMonth.ly_Volume, percentage=1)>
                <!---06---> </cfif>
                <!---06---> <cfif val(main.ty_vol) eq 0 or val(qForecastMonth.ly_Volume) eq 0>
                            <cfelse>
                              <cfset querySetCell(qExcel, vars.aQueryColumn[ 6 ] & vars.thisSuffix, main.ty_Delta_Percentage)>
                            </cfif>
                <!---07---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 7 ] & vars.thisSuffix, qForecastMonth.ty_PGM)>
                <!---08---> <cfif val(main.ty_vol) eq 0>
                            <cfelse>
                              <cfset querySetCell(qExcel, vars.aQueryColumn[ 8 ] & vars.thisSuffix, NumberFormat(main.ty_vol - val(qForecastMonth.ty_pgm), const.volumeFormat2))>
                            </cfif>
                <!---09---> <cfif val(main.ty_vol) eq 0 or qForecastMonth.ty_PGM eq 0>
                            <cfelse>
                              <cfset querySetCell(qExcel, vars.aQueryColumn[ 9 ] & vars.thisSuffix, deltaValue2(ty = main.ty_vol, ly = qForecastMonth.ty_pgm, percentage=1))>
                            </cfif>
            </cfif>    <!---qPeriod.Became_Actual--->
    
            <!---------------------------------------------------------- QUARTER -------------------------------------------------------------->
            <cfquery name="qSubtotals" dbtype="query">
               SELECT  SUM(ly_Volume)     AS sum_ly_Volume
                     , SUM(ty_Volume)     AS sum_ty_Volume
                     , SUM(ty_pgm)        AS sum_ty_pgm
                     , SUM(ybly_Volume)   AS sum_ybly_Volume
                     , SUM(actual_volume) AS sum_actual_Volume
                 FROM qForecast3Months
                WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
            </cfquery>
		        <cfif qSubtotals.recordCount eq 0>
		            <cfquery name="qSubtotals" dbtype="query">>
			               SELECT  0 AS sum_ly_Volume
			                     , 0 AS sum_ty_Volume
			                     , 0 AS sum_ty_pgm
			                     , 0 AS sum_ybly_Volume
			                     , 0 AS sum_actual_Volume
                      FROM qOneRow
		            </cfquery>
		        </cfif>
    
            <cfset vars.thisSuffix = "_qtr">
            <cfif qBecameActual.recordCount eq 3>
                <!---display actual values--->
                <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 1 ] & vars.thisSuffix, NumberFormat(qSubtotals.sum_actual_Volume,const.volumeFormat2))>
                <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 2 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0))>
                <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 3 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1))>
                <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 4 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_Volume, percentage=0))>
                <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 5 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1))>
                <!---06---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 6 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=0))>
                <!---07---> <cfset querySetCell(qExcel, vars.aQueryColumnA[ 7 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=1))>
            <cfelse>
                <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 1 ] & vars.thisSuffix, NumberFormat(qSubtotals.sum_ly_Volume,const.volumeFormat2))>
                <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 2 ] & vars.thisSuffix, deltaValue2(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1))>
      
                <!---tue 2012/feb/21: Paul changed FC forecast EQC column to be sum of actual volume (months in the past) + sum of forecast (current & future months)--->
                <cfquery name="qFCSubtotals" dbtype="query">
                     SELECT  SUM(ly_Volume)     AS sum_ly_Volume
                           , SUM(ty_Volume)     AS sum_ty_Volume
                           , SUM(ty_pgm)        AS sum_ty_pgm
                           , SUM(ybly_Volume)   AS sum_ybly_Volume
                           , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
                     FROM qForecast3Months
                     WHERE Became_Actual = 0
                           AND PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
                </cfquery>
				        <cfif qFCSubtotals.recordCount eq 0>
				            <cfquery name="qFCSubtotals" dbtype="query">>
		                     SELECT  0 AS sum_ly_Volume
		                           , 0 AS sum_ty_Volume
		                           , 0 AS sum_ty_pgm
		                           , 0 AS sum_ybly_Volume
		                           , 0 AS sum_actual_Volume      <!---actual amount--->
		                      FROM qOneRow
				            </cfquery>
				        </cfif>
				        
                <cfquery name="qACTSubtotals" dbtype="query">
                     SELECT  SUM(ly_Volume)     AS sum_ly_Volume
                           , SUM(ty_Volume)     AS sum_ty_Volume
                           , SUM(ty_pgm)        AS sum_ty_pgm
                           , SUM(ybly_Volume)   AS sum_ybly_Volume
                           , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
                     FROM qForecast3Months
                     WHERE Became_Actual = 1
                       AND PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
                </cfquery>
				        <cfif qACTSubtotals.recordCount eq 0>
				            <cfquery name="qACTSubtotals" dbtype="query">
	                     SELECT  0 AS sum_ly_Volume
	                           , 0 AS sum_ty_Volume
	                           , 0 AS sum_ty_pgm
	                           , 0 AS sum_ybly_Volume
	                           , 0 AS sum_actual_Volume      <!---actual amount--->
		                      FROM qOneRow
				            </cfquery>
				        </cfif>
      
                <cfset quarter.sum_ty_volume = val(qFCSubtotals.sum_ty_Volume) + val(qACTSubtotals.sum_actual_Volume)>
    
                <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 4 ] & vars.thisSuffix, NumberFormat(quarter.sum_ty_Volume,const.volumeFormat2))>
                <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 5 ] & vars.thisSuffix, deltaValue2(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=0))>
                <!---06---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 6 ] & vars.thisSuffix, deltaValue2(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1))>
                <!---07---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 7 ] & vars.thisSuffix, NumberFormat(qSubtotals.sum_ty_pgm,const.volumeFormat2))>
                <!---08---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 8 ] & vars.thisSuffix, deltaValue2(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=0))>
                <!---09---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 9 ] & vars.thisSuffix, deltaValue2(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1))>
            </cfif>
              
        </cfloop>    <!---query="qPeriod"--->
      </cfloop>    <!---query="qProductPG"--->
      
      
      <cfscript>
          spreadsheetAddRow(excel.sheet, vars.sExcelColumnLabels);
          // spreadsheetFormatRow(excel.sheet, { alignment="center", topborder="none", rightborder="thin", bottomborder="thin", leftborder="thin", bold="true", fgcolor="black", color="white", rightbordercolor="white", textwrap="true", verticalalignment="vertical_top" }, 1);
          spreadsheetFormatRow(excel.sheet, { alignment="center", topborder="thick", rightborder="thin", bottomborder="thick", leftborder="thin", bold="true", fgcolor="black", color="white", leftbordercolor="blue_grey", rightbordercolor="blue_grey",  topbordercolor="blue_grey",  bottombordercolor="blue_grey", textwrap="true", verticalalignment="vertical_top" }, 1);
          spreadsheetAddRows(excel.sheet, qExcel);
      </cfscript>
      
    </cfloop>    <!--- quarters --->
    
    
    <cfscript>
      result.excelFileName = application.util.io.tempFileName( prefix='Volume_Forecast' ) & '.xls';
      result.excelFileURL  = '/common_documents/temp_files/any/' & listLast(result.excelFileName, '/');
      SpreadsheetSetActiveSheet(excel.sheet, QuarterName( 1 ));
      spreadsheetWrite(excel.sheet, result.excelFileName, true);
    </cfscript>
    
    <cfreturn result>
</cffunction>
    
<!--------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="trendValue" output="false" returntype="String" access="private" hint="Return trend percentage based on this year volume and last year volume">
  <cfargument name="ty" required="true" hint="I am this year volume">
  <cfargument name="ly" required="true" hint="I am last year volume">

  <cfif val(arguments.ly) eq 0>
    <!---<cfreturn "0%">--->
    <cfreturn "0">
  <cfelse>
    <cfreturn NumberFormat((val(arguments.ty) - val(arguments.ly)) / val(arguments.ly) * 100, const.percentFormat) <!---& '%'--->>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="generateYTDExport" output="false" returnFormat="json" access="remote" hint="">
  <cfargument name="vfc_plan_id" required="true">
  <cfargument name="vfc_level_id" required="true">

  <cfscript>
    const.volumeFormat = "-999,999,999";
    const.volumeFormat2 = "-999999999";
    const.percentFormat = "-999.00";
    main.isDevSite     = 1;
    application.oController.getObject(path="mvc.models.volumeforecast.vfmanager", name="vfmanager", bReload=main.isDevSite);

    vars             = {};
    result           = {};
    qProductPG       = application.oVfManager.getProductCategories( arguments.vfc_plan_id );
    qCurrPositionAndBelowMarkets = application.oVfManager.getCurrPositionAndBelowVF( arguments.vfc_plan_id );
  
    excel = {};
    excel.sheet = SpreadsheetNew( QuarterName(1) );        // create 1st sheet
    
    if ( arguments.vfc_level_id eq "summary" ) {
      qLevel          = application.oVfManager.getLevels( vf_id=arguments.vfc_plan_id, level=qCurrPositionAndBelowMarkets.VF_Level_ID );
      qForecastDetail = application.oVfManager.getDetail( vf_id=arguments.vfc_plan_id, level=valuelist(qCurrPositionAndBelowMarkets.VF_Level_ID) );
    }
    else {
      qLevel          = application.oVfManager.getLevels( vf_id=arguments.vfc_plan_id, level=arguments.vfc_level_id );
      qForecastDetail = application.oVfManager.getDetail( vf_id=arguments.vfc_plan_id, level=arguments.vfc_level_id );
    }

    qActualPeriods = application.oVfManager.getPeriodsbyStatus( vf_id=arguments.vfc_plan_id, actual=1 );
    qToGoPeriods   = application.oVfManager.getPeriodsbyStatus( vf_id=arguments.vfc_plan_id, actual=0 ); 
    
    const.working_year = Right(qLevel.Year_Selection, 2);
    const.ty_label     = "F" & const.working_year;         // working year column label
    const.ly_label     = "F" & (const.working_year - 1);   // previous year column label
    const.ybly_label   = "F" & (const.working_year - 2);   // year before previous year column label
    
    
    vars.aQueryColumn       = [];
    vars.aExcelColumnLabel  = [];
    vars.lineFeed           = chr(10);
    vars.headingDelimeter   = repeatString(vars.lineFeed, 2);

    vars.aQueryColumn[ 1 ] = "act_vol";                   vars.aExcelColumnLabel[ 1 ] = "Actual" & vars.headingDelimeter & const.ty_label & " ACT" & vars.lineFeed & "EQCs";
    vars.aQueryColumn[ 2 ] = "act_ty_ly_delta";           vars.aExcelColumnLabel[ 2 ] = "Actual" & vars.headingDelimeter & "ACT +/- " & const.ly_label & vars.lineFeed & "EQCs";
    vars.aQueryColumn[ 3 ] = "act_ty_ly_delta_perc";      vars.aExcelColumnLabel[ 3 ] = "Actual" & vars.headingDelimeter & "ACT %" & vars.lineFeed & "+/- " & const.ly_label;
    vars.aQueryColumn[ 4 ] = "act_ty_pgm_delta";          vars.aExcelColumnLabel[ 4 ] = "Actual" & vars.headingDelimeter & "ACT +/- PGM";
    vars.aQueryColumn[ 5 ] = "act_ty_pgm_delta_perc";     vars.aExcelColumnLabel[ 5 ] = "Actual" & vars.headingDelimeter & "ACT %" & vars.lineFeed & " +/- PGM";

    vars.aQueryColumn[ 6 ] = "tg_vol";                    vars.aExcelColumnLabel[ 6 ] = "To Go" & vars.headingDelimeter & const.ty_label & " TG" & vars.lineFeed & "EQCs";
    vars.aQueryColumn[ 7 ] = "tg_ty_ly_delta";            vars.aExcelColumnLabel[ 7 ] = "To Go" & vars.headingDelimeter & "TG +/- " & const.ly_label & vars.lineFeed & "EQCs";
    vars.aQueryColumn[ 8 ] = "tg_ty_ly_delta_perc";       vars.aExcelColumnLabel[ 8 ] = "To Go" & vars.headingDelimeter & "TG %" & vars.lineFeed & "+/- " & const.ly_label;
    vars.aQueryColumn[ 9  ] = "tg_ty_pgm_delta";          vars.aExcelColumnLabel[ 9  ] = "To Go" & vars.headingDelimeter & "TG +/- PGM";
    vars.aQueryColumn[ 10 ] = "tg_ty_pgm_delta_perc";     vars.aExcelColumnLabel[ 10 ] = "To Go" & vars.headingDelimeter & "TG %" & vars.lineFeed & " +/- PGM";
                                                                                  
    vars.aQueryColumn[ 11 ] = "ann_vol";                  vars.aExcelColumnLabel[ 11 ] = "Annual" & vars.headingDelimeter & const.ty_label & " ANN" & vars.lineFeed & "EQCs";
    vars.aQueryColumn[ 12 ] = "ann_ty_ly_delta";          vars.aExcelColumnLabel[ 12 ] = "Annual" & vars.headingDelimeter & "ANN +/- " & const.ly_label & vars.lineFeed & "EQCs";
    vars.aQueryColumn[ 13 ] = "ann_ty_ly_delta_perc";     vars.aExcelColumnLabel[ 13 ] = "Annual" & vars.headingDelimeter & "ANN %" & vars.lineFeed & "+/- " & const.ly_label;
    vars.aQueryColumn[ 14 ] = "ann_ty_pgm_delta";         vars.aExcelColumnLabel[ 14 ] = "Annual" & vars.headingDelimeter & "ANN +/- PGM";
    vars.aQueryColumn[ 15 ] = "ann_ty_pgm_delta_perc";    vars.aExcelColumnLabel[ 15 ] = "Annual" & vars.headingDelimeter & "ANN %" & vars.lineFeed & " +/- PGM";
    
    vars.sQueryColumns      = 'Product';
    vars.sExcelColumnLabels = 'Product';

    qOneRow            = queryNew('foo');
		queryAddRow( qOneRow );
  </cfscript>
  
  <cfloop array="#vars.aQueryColumn#" index="vars.thisColumn">
    <cfset vars.sQueryColumns = vars.sQueryColumns & ", " & vars.thisColumn>
  </cfloop>

  <cfloop array="#vars.aExcelColumnLabel#" index="vars.thisColumn">
    <cfset vars.sExcelColumnLabels = vars.sExcelColumnLabels & ", " & vars.thisColumn>
  </cfloop>

  <!--- create dynamic query with columns matching with the export layout --->
  <cfset qExcel = queryNew(vars.sQueryColumns, "VarChar " & repeatString(",VarChar", listLen(vars.sQueryColumns) - 1))> 

  <!------------------------------------------------------- GRAND TOTAL ------------------------------------------------------------->
  <cfset queryAddRow(qExcel)>
  <cfset querySetCell(qExcel, "Product", "GRAND TOTAL")>
  <!------------------------------------------------------- ACTUAL SECTION ---------------------------------------------------------->        
  <cfquery name="qActual" dbtype="query">
     SELECT  SUM(ly_Volume) AS ly_Volume
           , SUM(ty_Volume) AS ty_Volume
           , SUM(ty_pgm) AS ty_pgm
           , SUM(actual_Volume) AS Actual_Volume
       FROM qForecastDetail
      WHERE <cfif qActualPeriods.recordCount>
              VF_Period_ID in (<cfqueryparam value="#ValueList(qActualPeriods.VF_Period_ID)#" cfsqltype="cf_sql_integer" list="yes">)
            <cfelse>
              1 = 0
            </cfif>
  </cfquery>
  <cfif qActual.recordCount eq 0>
    <cfquery name="qActual" dbtype="query">
       SELECT   0 AS ly_volume
              , 0 AS ty_Volume
              , 0 AS ty_pgm
              , 0 AS actual_Volume
        FROM qOneRow
    </cfquery>
  </cfif>

  <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 1 ], NumberFormat(qActual.actual_Volume, const.volumeFormat))>
  <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 2 ], deltaValue2(ty=qActual.actual_Volume, ly=qActual.ly_Volume, percentage=0))>
  <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 3 ], deltaValue2(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=1))>
  <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 4 ], deltaValue2(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=0))>
  <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 5 ], deltaValue2(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=1))>
  
  <!------------------------------------------------------- TO GO SECTION ---------------------------------------------------------->       
  <cfquery name="qToGo" dbtype="query">
     SELECT  SUM(ly_Volume) AS ly_Volume
           , SUM(ty_Volume) AS ty_Volume
           , SUM(ty_pgm) AS ty_pgm
           , SUM(actual_Volume) AS Actual_Volume
       FROM qForecastDetail
      WHERE <cfif qToGoPeriods.RecordCount>
				VF_Period_ID in (<cfqueryparam value="#ValueList(qToGoPeriods.VF_Period_ID)#" cfsqltype="cf_sql_integer" list="yes">)
			<cfelse>
				1 = 0
			</cfif>
  </cfquery>
  <cfif qToGo.recordCount eq 0>
    <cfquery name="qToGo" dbtype="query">
     SELECT   0 AS ly_volume
            , 0 AS ty_Volume
            , 0 AS ty_pgm
            , 0 AS actual_Volume
       FROM qOneRow
    </cfquery>
  </cfif>

  <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 6 ], NumberFormat(qToGo.ty_volume, const.volumeFormat))>
  <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 7 ], deltaValue2(ty=qToGo.ty_volume, ly=qToGo.ly_Volume, percentage=0))>
  <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 8 ], deltaValue2(ty=qToGo.ty_volume, ly=qToGo.ly_volume, percentage=1))>
  <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 9 ], deltaValue2(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=0))>
  <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 10 ], deltaValue2(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=1))>

  <!------------------------------------------------------- ANNUAL SECTION ---------------------------------------------------------->        
  <cfquery name="qAnnual" dbtype="query">
     SELECT  SUM(ly_Volume) AS ly_Volume
           , SUM(ty_pgm)    AS ty_pgm
       FROM qForecastDetail
  </cfquery>
  <cfif qAnnual.recordCount eq 0>
    <cfquery name="qAnnual" dbtype="query">
     SELECT   0 AS ly_volume
            , 0 AS ty_pgm
       FROM qOneRow
    </cfquery>
  </cfif>

  <cfset annual_volume = qActual.actual_volume + qToGo.ty_volume>
  <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 11 ], NumberFormat(annual_volume, const.volumeFormat))>
  <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 12 ], deltaValue2(ty=annual_volume, ly=qAnnual.ly_Volume, percentage=0))>
  <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 13 ], deltaValue2(ty=annual_volume, ly=qAnnual.ly_volume, percentage=1))>
  <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 14 ], deltaValue2(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=0))>
  <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 15 ], deltaValue2(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=1))>

  <!--------------------------------------------------------- PRODUCT --------------------------------------------------------------->
  <cfloop query="qProductPG">
        <cfset queryAddRow(qExcel)>
        <cfset querySetCell(qExcel, "product", qProductPG.pg_Product_Category_Name)>
        <!------------------------------------------------------- ACTUAL SECTION ---------------------------------------------------------->        
        <cfquery name="qActual" dbtype="query">
           SELECT   SUM(ly_volume) AS ly_volume
                  , SUM(ybly_volume) AS ybly_volume
                  , SUM(ty_volume) AS ty_volume
                  , SUM(ty_pgm) AS ty_pgm
                  , SUM(actual_Volume) AS actual_Volume
             FROM qForecastDetail
            WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
              AND <cfif qActualPeriods.recordCount>
                    VF_Period_ID in (<cfqueryparam value="#ValueList(qActualPeriods.VF_Period_ID)#" cfsqltype="cf_sql_integer" list="yes">)
                  <cfelse>
                    1 = 0
                  </cfif>
        </cfquery>
        <cfif qActual.recordCount eq 0>
          <cfquery name="qActual" dbtype="query">
             SELECT 0 AS ly_volume
                    , 0 AS ybly_volume
                    , 0 AS ty_volume
                    , 0 AS ty_pgm
                    , 0 AS actual_Volume
               FROM qOneRow
          </cfquery>
        </cfif>

        <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 1 ], NumberFormat(qActual.actual_Volume, const.volumeFormat))>
        <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 2 ], deltaValue2(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=0))>
        <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 3 ], deltaValue2(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=1))>
        <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 4 ], deltaValue2(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=0))>
        <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 5 ], deltaValue2(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=1))>

        <!------------------------------------------------------- TO GO SECTION ---------------------------------------------------------->       
        <cfquery name="qToGo" dbtype="query">
           SELECT   SUM(ly_volume) AS ly_volume
                  , SUM(ybly_volume) AS ybly_volume
                  , SUM(ty_volume) AS ty_volume
                  , SUM(ty_pgm) AS ty_pgm
                  , SUM(actual_Volume) AS actual_Volume
             FROM qForecastDetail
            WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
			<cfif qToGoPeriods.RecordCount>
				AND VF_Period_ID in (<cfqueryparam value="#ValueList(qToGoPeriods.VF_Period_ID)#" cfsqltype="cf_sql_integer" list="yes">)
			<cfelse>
				AND 1 = 0
			</cfif>
        </cfquery>
        <cfif qToGo.recordCount eq 0>
          <cfquery name="qToGo" dbtype="query">
             SELECT 0 AS ly_volume
                    , 0 AS ybly_volume
                    , 0 AS ty_volume
                    , 0 AS ty_pgm
                    , 0 AS actual_Volume
               FROM qOneRow
          </cfquery>
        </cfif>

        <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 6 ], NumberFormat(qToGo.ty_volume, const.volumeFormat))>
        <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 7 ], deltaValue2(ty=qToGo.ty_volume, ly=qToGo.ly_volume, percentage=0))>
        <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 8 ], deltaValue2(ty=qToGo.ty_volume, ly=qToGo.ly_volume, percentage=1))>
        <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 9 ], deltaValue2(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=0))>
        <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 10 ], deltaValue2(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=1))>

        <!------------------------------------------------------- ANNUAL SECTION ---------------------------------------------------------->        
        <cfquery name="qAnnual" dbtype="query">
           SELECT   SUM(ly_volume) AS ly_volume
                  , SUM(ybly_volume) AS ybly_volume
                  , SUM(ty_volume) AS ty_volume
                  , SUM(ty_pgm) AS ty_pgm
                  , SUM(actual_Volume) AS actual_Volume
             FROM qForecastDetail
            WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfif qAnnual.recordCount eq 0>
          <cfquery name="qAnnual" dbtype="query">
             SELECT 0 AS ly_volume
                    , 0 AS ybly_volume
                    , 0 AS ty_volume
                    , 0 AS ty_pgm
                    , 0 AS actual_Volume
               FROM qOneRow
          </cfquery>
        </cfif>

        <cfset annual_volume = qActual.actual_volume + qToGo.ty_volume>
        <!---01---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 11 ], NumberFormat(annual_volume, const.volumeFormat))>
        <!---02---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 12 ], deltaValue2(ty=annual_volume, ly=qAnnual.ly_volume, percentage=0))>
        <!---03---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 13 ], deltaValue2(ty=annual_volume, ly=qAnnual.ly_volume, percentage=1))>
        <!---04---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 14 ], deltaValue2(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=0))>
        <!---05---> <cfset querySetCell(qExcel, vars.aQueryColumn[ 15 ], deltaValue2(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=1))>

  </cfloop>   <!---query="qProductPG"--->
  
  <cfscript>
      spreadsheetAddRow(excel.sheet, vars.sExcelColumnLabels);
      spreadsheetFormatRow(excel.sheet, { alignment="center", topborder="thick", rightborder="thin", bottomborder="thick", leftborder="thin", bold="true", fgcolor="black", color="white", leftbordercolor="blue_grey", rightbordercolor="blue_grey",  topbordercolor="blue_grey",  bottombordercolor="blue_grey", textwrap="true", verticalalignment="vertical_top" }, 1);
      spreadsheetAddRows(excel.sheet, qExcel);
      result.excelFileName = application.util.io.tempFileName( prefix='Volume_Forecast' ) & '.xls';
      result.excelFileURL  = '/common_documents/temp_files/any/' & listLast(result.excelFileName, '/');
      spreadsheetWrite(excel.sheet, result.excelFileName, true);
  </cfscript>

  <cfreturn result>
</cffunction>

</cfcomponent>
