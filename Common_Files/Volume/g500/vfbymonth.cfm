<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<!---------------------------------------------------------------------------------------------------------------------
			Template: \Common_Files\Volume\g564\vfbymonth.cfm
			Date:     Oct 18 2011
			Author:   Chris Nguyen
			Purpose:  GM Volume Forecast by months (3 months, 1 quater)

			Notes:    URL parameter names are soundex values so they are not obvious to users (more secure)

			Required Input:  1. url.l143: VF Level ID (numeric)
											 2. url.v451: volume Forecast ID (numeric)
											 3. url.q636: quarter number (numeric) valid values = 1, 2, 3 or 4

			Optional Input:  1. url.r354: read-only indicator: pass 'f420' value to allow editing,
																												 pass anything else to prevent changes
----------------------------------------------------------------------------------------------------------------------->
<html>
<cfparam name="url.r354" default="">

<cfscript>
	const.volumeFormat = "-999,999,999";
	const.percentFormat = "-999.00";
	const.deltaPrefix  = "delta_";
	const.volumePrefix = "volume_";
	const.use_absolute = 'abs_';
	const.editing      = 'f420';

	// class for table cells
	class.ly_vol       = 'ly_vol';
	class.ly_perc      = 'ly_perc';
	class.ty_vol       = 'ty_vol';
	class.ty_perc      = 'ty_perc';
	class.delta_vol    = 'delta_vol';
	class.delta_perc   = 'delta_perc';
	class.pgm_ny       = 'pgm_ny';
	class.pgm_delta_amt  = 'pgm_delta_amt';
	class.pgm_delta_perc = 'pgm_delta_perc';
	class.ybly_vol     = 'ybly_vol';
	class.input_amt    = 'i_amt';
	class.input_perc   = 'i_perc';
	class.mass_update  = 'massupdate';
	class.52_abs       = '52_abs';
	class.52_trend     = '52_trend';
	class.use_absolute = 'use_abs';

	main.readonly      = (url.r354 neq const.editing) or (url.l143 eq "summary");     // read only indicator
	main.summary       = (url.l143 eq "summary");
	main.isDevSite     = 1;                                // TODO: change it to 0 prior to deployment

  	application.oController.getObject(path="mvc.models.volumeforecast.vfmanager", name="vfmanager", bReload=main.isDevSite);

  	qOneRow = queryNew( 'foo' );
  	queryAddRow( qOneRow );
</cfscript>

<head>
	<cfinclude template="vfUDF.cfm">        <!---volume forecast functions library--->
	<cfinclude template="/get_access_profile.cfm">

	<title>Volume Forecast</title>
	<link rel="stylesheet" type="text/css" href="workbook.css?v=#application.util.dateTime.fileVersion('workbook.css')#">
	<link rel="stylesheet" type="text/css" href="/common_files/impromptu.css?v=#application.util.dateTime.fileVersion('/common_files/impromptu.css')#">
	<!--- <link rel="stylesheet" href="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css" type="text/css" /> --->

	<style>
	.mediumButton { width:60px; }
	<cfoutput>
	##pagetitle { background-color:##4169E1; color:white; font-size:17px; font-weight:bold; height:50px; margin:0; text-align:center; vertical-align:middle; width:100%; <cfif not main.readonly>padding-top:3px;</cfif>}

		#class.ty_vol#_1 input, td.#class.ty_vol#_2 input, .#class.ty_vol#_3 input
	, .#class.ty_perc#_1 input, .#class.ty_perc#_2 input, .#class.ty_perc#_3 input { background-color:##A5BAFF; margin-top:-2px; }

	.#class.ty_perc#_1 input, .#class.ty_perc#_2 input, .#class.ty_perc#_3 input { width:80%; }
	.#class.ty_vol#_1 input, .#class.ty_vol#_2 input, .#class.ty_vol#_3 input, #class.mass_update# { width:100%; margin-top:-2px; }

		.#class.ty_vol#_1, .#class.ty_vol#_2, .#class.ty_vol#_3
	, .#class.ty_perc#_1, .#class.ty_perc#_2, .#class.ty_perc#_3 { background-color:##A5BAFF; }

		.#class.delta_vol#_1, .#class.delta_vol#_2, .#class.delta_vol#_3
	, .#class.delta_perc#_1, .#class.delta_perc#_2, .#class.delta_perc#_3 { color:blue; font-weight:bold; }

	##tr_gtotal * { text-align:right; padding:3px; }

	.#class.mass_update# { font-weight:bold; }
	.inactive { background-color:white; font-weight:normal; color:gray; }
	.acthdr  { padding:4px; }
	.bcolor2 { background-color:##A5BAFF; }
	.pos { color:black }
	.neg { color:red }
	.rolling { width:65px !important; text-align:right !important; }
	</cfoutput>
	#cfm { margin: 10px 0 0 10px; }
		#cfm label { font-weight: bold; color: blue; }
		#cfm input { margin: 0 0 0 7px; }
		#cfm img { position2:relative; top:2px; }
	</style>
</head>

<cfif cgi.request_method eq "post">
	<cfset application.oVfManager.saveForecast( vf_id=url.v451, level=url.l143, quarter=url.q636 )>
	<!---redirect to a specific page--->
	<cfif StructKeyExists(form, "windowNewLocation") and len(trim(form.windowNewLocation)) gt 0>
		<cflocation url="#form.windowNewLocation#" addtoken="false">
	<cfelse>
		<!---redirect to the next quarter, cycle back to 1st quarter if it was on the last quarter--->
		<!--- <cfset url.q636 = url.q636 + 1>
		<cfif url.q636 gt 4>
			<cfset url.q636 = 1>
		</cfif>
		<cflocation url="#cgi.script_name#?#removeURLfields('q636')#&q636=#url.q636#" addtoken="false"> --->
	</cfif>
</cfif>

<cfoutput>
<cfquery name="qVolumePlan" Datasource="#application.datasource#">
	<cfif main.summary >
		SELECT Plan_Name = vf_Plan.vf_Plan_desc
		      ,Forecast_Level
		      ,User_Position_Id = 0
		      ,uom = CASE WHEN vf_uom = 9 THEN 'EQC' ELSE b.abbreviation END
			FROM vf_Plan
			     LEFT JOIN Units_of_Measure b ON vf_plan.vf_uom = b.unit_of_measure_id
		 WHERE vf_Plan.vf_Plan_Id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#url.v451#">
	<cfelse>
		SELECT Plan_Name = vf_Plan.vf_Plan_desc
		      ,Forecast_Level
		      ,vf_Level.User_Position_Id
		      ,uom = CASE WHEN vf_uom = 9 THEN 'EQC' ELSE b.abbreviation END
			FROM vf_Plan
		 			 INNER JOIN vf_Level ON vf_Plan.vf_Plan_Id = vf_Level.vf_Plan_Id and vf_Level.Deleted = 0 and vf_Level.vf_level_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#url.l143#">
		      LEFT JOIN Units_of_Measure b ON vf_plan.vf_uom = b.unit_of_measure_id
		 WHERE vf_Plan.vf_Plan_Id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#url.v451#">
	</cfif>
</cfquery>
<cfset main.uom = qVolumePlan.uom>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->
<cfset lastPeriodInPrevQuarter = 0>
<cfset qPrevPeriod = application.oVfManager.getPeriods( vf_id=url.v451, quarter=(url.q636 - 1) )>
<!--- determine the last period in previous quarter --->
<cfloop query="qPrevPeriod">
	<cfset lastPeriodInPrevQuarter = qPrevPeriod.VF_Period_Id>
</cfloop>

<cfscript>
	qProductPG       = application.oVfManager.getProductCategories( url.v451 );
	qPeriod          = application.oVfManager.getPeriods( vf_id=url.v451, quarter=url.q636 );
	qDirectAssignedMarkets = application.oVfManager.getDirectAssignedMarkets( Forecast_Level=qVolumePlan.Forecast_Level );
 	qCurrPositionAndBelowMarkets = application.oVfManager.getCurrPositionAndBelowVF( url.v451 );
	qActualPeriods  = application.oVfManager.getPeriodsbyStatus( vf_id=url.v451, actual=1 );

	if ( main.summary ) {
		qLevel           = application.oVfManager.getLevels( vf_id=url.v451, level=qCurrPositionAndBelowMarkets.VF_Level_ID );
		qForecast3Months = application.oVfManager.getDetail( vf_id=url.v451, level=valuelist(qCurrPositionAndBelowMarkets.VF_Level_ID), periods=ValueList(qPeriod.VF_Period_Id) );
		qLastForecastMonth = application.oVfManager.getDetail( vf_id=url.v451, level=url.l143, periods=lastPeriodInPrevQuarter );
		qForecastDetail = application.oVfManager.getDetail( vf_id=url.v451, level=valuelist(qCurrPositionAndBelowMarkets.VF_Level_ID) );
	}
	else {
		qLevel           = application.oVfManager.getLevels( vf_id=url.v451, level=url.l143 );
		qForecast3Months = application.oVfManager.getDetail( vf_id=url.v451, level=url.l143, periods=ValueList(qPeriod.VF_Period_Id) );
		qLastForecastMonth = application.oVfManager.getDetail( vf_id=url.v451, level=url.l143, periods=lastPeriodInPrevQuarter );
		qForecastDetail = application.oVfManager.getDetail( vf_id=url.v451, level=url.l143 );
	}

	const.working_year = Right(qLevel.Year_Selection, 2);
	const.ty_label     = "F" & const.working_year;         // working year column label
	const.ly_label     = "F" & (const.working_year - 1);   // previous year column label
	const.ybly_label   = "F" & (const.working_year - 2);   // year before previous year column label
</cfscript>
<!--------------------------------------------------------------------------------------------------------------------->

<!---count number of periods became actual--->
<cfset useLakebaseForqBecameActual = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qperiod")>
<cfif useLakebaseForqBecameActual>
	<cftry>
		<cfset qBecameActual = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qperiod", {
				"became_actual" = "eq.1",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqBecameActual = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqBecameActual>
<cfquery name="qBecameActual" dbtype="query">
	 SELECT 1
		 FROM qPeriod
		WHERE Became_Actual = 1
</cfquery>
</cfif>

<cfset main.lockedByOther = false>
<!---allow edit mode when market is directly assigned (not a below position market)--->
<!---35751 - Checked new user profile "Edit VFC below me" setting: if it is enabled allow to edit--->
<cfset main.editIsAllowed = ( Get_Profile_Settings.Edit_Volume_FC_Below_Me eq 1 or ListFindNoCase(ValueList(qDirectAssignedMarkets.User_Positions_ID), qVolumePlan.User_Position_Id) ) and qBecameActual.recordCount lt 3>

<cfif main.readonly or not main.editIsAllowed>
	<cfset url.r354	= ''>
	<cfset main.readonly = true>
	<!---read only mode, reset lockedby to blank if needed--->
	<cfif qLevel.LockedbyUserID eq request.AccessStructure.User_ID>
		<cfset application.oVfManager.saveLockedBy( level=url.l143, userID='' )>
	  <cfset qLevel = application.oVfManager.getLevels( vf_id=url.v451, level=url.l143 )>
	</cfif>
<cfelse>
	<!---switch edit mode off because volume forecast is locked by someone else--->
  <cfif len(qLevel.LockedbyUserID) and (qLevel.LockedbyUserID neq request.AccessStructure.User_ID)>
		<cfset url.r354	= ''>
		<cfset main.readonly = true>
		<cfset main.lockedByOther = true>
	<!---switch edit mode off because market is for a below position--->
  <cfelseif not main.editIsAllowed>
		<cfset url.r354	= ''>
		<cfset main.readonly = true>
	<!---lock the VF to prevent changes by others--->
	<cfelseif (qLevel.LockedByUserID eq "")>
		<cfset application.oVfManager.saveLockedBy( level=url.l143, userID=request.AccessStructure.User_ID )>
	  <cfset qLevel = application.oVfManager.getLevels( vf_id=url.v451, level=url.l143 )>
	</cfif>
</cfif>

<body style="overflow:hidden;margin:0px; display:block;">
<cfset vars.queryString = "v451=" & url.v451 & "&l143=" & url.l143 & "&r354=" & url.r354>
<cfoutput>
<div id="pagetitle">
<span <cfif len(qLevel.LockedByUserName) or len(qLevel.UpdatedBy)>style="position:relative; top:2px;"<cfelse>style="position:relative; top:9px;"</cfif>>
<cfif main.readonly><button id="pagemode">Read Only</button></cfif> #qVolumePlan.Plan_Name# #marketsList( url.v451 )# #QuarterName(url.q636)#
</span>
</div>
<div id="pageinfo">
		<cfif len(qLevel.LockedByUserName)>
			<span id="lockedby">Locked by #qLevel.LockedByUserName#</span>
		</cfif>
		<cfif len(qLevel.UpdatedBy)>
			<span id="updatedby">Last Updated on #DateFormat(qLevel.Last_Updated_On, 'medium')# #TimeFormat(qLevel.Last_Updated_On, 'short')# by #qLevel.UpdatedBy#</span>
		</cfif>
</div>
</cfoutput>

<!---<cfdump var="#qOneRow#" abort="true">--->

<form name="workbook" id="workbookform" method="post" <cfoutput>action="#cgi.script_name#?#cgi.query_string#"</cfoutput>>
<input name="windowNewLocation" id="windowNewLocation" type="hidden">
<div id="tbl-container" onscroll="keepHeaderFixed(this.scrollTop-1,scrollLeft);">

	<table class="tbl" style="TOP: 0px;" cellspacing="0">

<!------------------------------------------------------- COLUMN HEADERS ---------------------------------------------------------->
		<thead id="tbl_head">
			<tr id="tr_period">
				<th class="locked stay headerTopAndLeft" name="bufferTD">&nbsp;</th>
				<!---02a---><th class="locked rolling stay headerTopAndLeft">&nbsp;</th>    <!--- YTD trend   --->
				<!---02b---><th class="locked rolling stay headerTopAndLeft">&nbsp;</th>    <!--- 52 wk trend --->
				<!---02c---><th class="locked rolling stay headerTopAndLeft">&nbsp;</th>    <!--- 13 wk trend --->
				<cfset xPeriod.Became_Actual = 0>
				<!---Header for a month--->
				<cfloop query="qPeriod">
					<cfif qPeriod.currentRow eq 1>
						<cfset header4 = "">
					<cfelse>
						<cfset header4 = "header4">
					</cfif>
					<!---01---><cfoutput><th class="header2 colhdr_readonly #header4# headerTop">#Left(qPeriod.Period_Desc,3)#</th></cfoutput>
					<cfif qPeriod.Became_Actual>
						<!---02---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
						<!---03---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
						<!---04---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
						<!---05---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
						<!---06---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
						<!---07---><th class="header2 colhdr_readonly header3 headerTop">&nbsp;</th>
					<cfelse>
						<!---02---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
						<!---03---><th class="header2 colhdr_edit headerTop">&nbsp;</th>
						<!--- 35751 - added carry forward for 1st month (no carry forward on 1st month of 1st quarter) --->
						<!---04---><th class="header2 colhdr_edit headerTop"><cfif ( qPeriod.currentRow eq 1 and url.q636 eq 1 ) or main.readonly or xPeriod.Became_Actual>&nbsp;<cfelse><button id=<cfoutput>"b_carry_#qPeriod.currentRow#"</cfoutput> class="carry">Carry Forward<br/>Prior Month</button></cfif></th>
						<!---05---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
						<!---06---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
						<!---07---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
						<!---08---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
						<!---09---><th class="header2 colhdr_readonly header3 headerTop">&nbsp;</th>
						<!---<!---10---><th class="header2 colhdr_readonly header3 headerTop">&nbsp;</th>--->
					</cfif>
					<th class="divider headerTop">&nbsp;</th>
					<cfset xPeriod.Became_Actual = qPeriod.Became_Actual>
				</cfloop>

				<!---QUARTER header--->
				<cfoutput><th class="header2 colhdr_readonly header4 headerTop">Q#url.q636#</th></cfoutput>
				<cfif qBecameActual.recordCount eq 3>
					<!---02---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<!---03---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<!---04---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<!---05---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<!---06---><th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<!---07---><th class="header2 colhdr_readonly header3 headerTop">&nbsp;</th>
				<cfelse>
					<th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<th class="header2 colhdr_readonly headerTop">&nbsp;</th>
					<!---<th class="header2 colhdr_readonly headerTop">&nbsp;</th>--->
					<!---<th class="header2 colhdr_readonly headerTop">&nbsp;</th>--->
				</cfif>
			</tr>

<!---------------------------------------------------------- PRODUCT ------------------------------------------------------------->
			<cfoutput>
			<tr id="tr_colhdr">
				<th class="locked stay headerTopAndLeft" id="td_product" style="text-align:left;padding:7px;" name="bufferTD"><cfif not main.readonly><input type="checkbox" id="toggle_all">&nbsp;</cfif>PRODUCT</th>
				<!---02a---><th class="locked rolling stay headerTopAndLeft" style="text-align:center !important;">YTD TREND</th>      <!--- ytd trend --->
				<!---02b---><th class="locked rolling stay headerTopAndLeft" style="text-align:center !important;">52 WK TREND</th>    <!--- 52 wk trend --->
				<!---02c---><th class="locked rolling stay headerTopAndLeft" style="text-align:center !important;">13 WK TREND</th>    <!--- 13 wk trend --->
				<!---Column Headers for a month--->
					<cfloop query="qPeriod">
						<cfif qPeriod.Became_Actual>
							<!---display actual values--->
							<!---01---> <th class="acthdr headerTop">#const.ty_label# ACT #main.uom#</th>                  <!---actual volume--->
							<!---02---> <th class="acthdr bcolor2 headerTop">ACT +/- #const.ly_label# #main.uom#</th>              <!---delta between actual & last year--->
							<!---03---> <th class="acthdr bcolor2 headerTop">ACT %<br/>+/- #const.ly_label#</th>             <!---delta % between actual & last year--->
							<!---04---> <th class="acthdr headerTop">ACT +/- FC #main.uom#</th>                            <!---delta between actual & forecast--->
							<!---05---> <th class="acthdr headerTop">ACT %<br/>+/- FC</th>                           <!---delta % between actual & forecast--->
							<!---06---> <th class="acthdr bcolor2 headerTop">ACT +/- PGM</th>                                <!---delta between actual & program--->
							<!---07---> <th class="acthdr bcolor2 headerTop">ACT %<br/>+/- PGM</th>                          <!---delta % between actual & program--->
						<cfelse>
							<!---display forecast values--->
							<!---01---> <th class="headerTop">#const.ly_label# #main.uom#</th>
							<!---02---> <th class="headerTop">#const.ly_label# %<br/>+/- #const.ybly_label#</th>
							<!---03---> <th class="editable headerTop">#const.ty_label# FC (Enter % +/- #const.ly_label#)<cfif not main.readonly><br/><input type="text" class="#class.mass_update#" id="#class.ty_perc#_#qPeriod.CurrentRow#" value="mass update" style="width:88%">%</cfif></th>
							<!---04---> <th class="editable headerTop">#const.ty_label# Forecast #main.uom#<!---<cfif not main.readonly><br/><input type="text" class="#class.mass_update#" id="#class.ty_vol#_#qPeriod.CurrentRow#" value="mass update" style="width:100%"></cfif>---></th>
							<!---05---> <th class="headerTop">FC +/- #const.ly_label# #main.uom#</th>
							<!---06---> <th class="headerTop">FC %<br/>+/- #const.ly_label#</th>
							<!---07---> <th class="headerTop">#const.ty_label# PGM</th>
							<!---08---> <th class="headerTop">FC +/- PGM</th>
							<!---09---> <th class="headerTop">FC %<br/>+/- PGM</th>
							<!---<!---10---> <th>#const.ybly_label# #main.uom#</th>--->
						</cfif>
						<th class="divider headerTop">&nbsp;</th>
					</cfloop>

				<!---QUARTER Column Headers--->
				<cfif qBecameActual.recordCount eq 3>
					<!---display actual values--->
					<!---01---> <th class="acthdr headerTop">#const.ty_label# ACT #main.uom#</th>         <!---actual volume--->
					<!---02---> <th class="acthdr bcolor2 headerTop">ACT +/- #const.ly_label# #main.uom#</th>              <!---delta between actual & last year--->
					<!---03---> <th class="acthdr bcolor2 headerTop">ACT %<br/>+/- #const.ly_label#</th>             <!---delta % between actual & last year--->
					<!---04---> <th class="acthdr headerTop">ACT +/- FC #main.uom#</th>                            <!---delta between actual & forecast--->
					<!---05---> <th class="acthdr headerTop">ACT %<br/>+/- FC</th>                           <!---delta % between actual & forecast--->
					<!---06---> <th class="acthdr bcolor2 headerTop">ACT +/- PGM</th>                                <!---delta between actual & program--->
					<!---07---> <th class="acthdr bcolor2 headerTop">ACT %<br/>+/- PGM</th>                          <!---delta % between actual & program--->
				<cfelse>
					<!---01---> <th class="headerTop">#const.ly_label# #main.uom#</th>
					<!---02---> <th class="headerTop">#const.ly_label# %<br/>+/- #const.ybly_label#</th>
					<!---03---> <!---<th>#const.ty_label# FC (Enter % +/- #const.ly_label#)</th>--->
					<!---04---> <th class="headerTop">#const.ty_label# Forecast #main.uom#</th>
					<!---05---> <th class="headerTop">FC +/- #const.ly_label# #main.uom#</th>
					<!---06---> <th class="headerTop">FC %<br/>+/- #const.ly_label#</th>
					<!---07---> <th class="headerTop">#const.ty_label# PGM</th>
					<!---08---> <th class="headerTop">FC +/- PGM</th>
					<!---09---> <th class="headerTop">FC %<br/>+/- PGM</th>
					<!---<!---10---> <th>#const.ybly_label# #main.uom#</th>--->
				</cfif>
			</tr>

<!------------------------------------------------------- GRAND TOTAL ------------------------------------------------------------->
			<tr id="tr_gtotal">
				<th class="locked stay headerTopAndLeft" name="bufferTD">GRAND TOTAL</th>

				<cfquery name="qActual" dbtype="query">
					 SELECT  SUM(ly_Volume)     AS ly_Volume
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
					  SELECT    0 AS ly_volume
						 			  , 0 AS actual_Volume
						 			  FROM qOneRow
					</cfquery>
				</cfif>

				<cfquery name="qSubtotals" dbtype="query">
					 SELECT  SUM(rolling_52)      AS sum_rolling_52
								 , SUM(rolling_prev_52) AS sum_rolling_prev_52
								 , SUM(rolling_13)      AS sum_rolling_13
								 , SUM(rolling_prev_13) AS sum_rolling_prev_13
						 FROM qForecast3Months
				</cfquery>
				<cfif qSubtotals.recordCount eq 0>
					<cfquery name="qSubtotals"  dbtype="query">
						 SELECT  0 AS sum_rolling_52
									 , 0 AS sum_rolling_prev_52
									 , 0 AS sum_rolling_13
									 , 0 AS sum_rolling_prev_13
							FROM qOneRow
					</cfquery>
				</cfif>

				<!---02a---><th class="locked rolling stay headerTopAndLeft"> #deltaValue(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=1)# </th>   <!--- ytd trend --->
				<!---02b---><th class="locked rolling stay headerTopAndLeft"> #trendValue(ty=qSubtotals.sum_rolling_52, ly=qSubtotals.sum_rolling_prev_52)# </th>   <!--- 52 wk trend --->
				<!---02c---><th class="locked rolling stay headerTopAndLeft"> #trendValue(ty=qSubtotals.sum_rolling_13, ly=qSubtotals.sum_rolling_prev_13)# </th>   <!--- 52 wk trend --->

				<!---Column Headers for a month--->
				<cfloop query="qPeriod">
					<cfquery name="qSubtotals" dbtype="query">
						 SELECT  SUM(ly_Volume)       AS sum_ly_Volume          <!---last year amount--->
									 , SUM(ty_volume)       AS sum_ty_Volume          <!---forecast amount--->
									 , SUM(ty_pgm)          AS sum_ty_pgm             <!---program amount--->
									 , SUM(ybly_Volume)     AS sum_ybly_Volume        <!---year before last year amount--->
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
						 SELECT  0 AS sum_ly_Volume          <!---last year amount--->
									 , 0 AS sum_ty_Volume          <!---forecast amount--->
									 , 0 AS sum_ty_pgm             <!---program amount--->
									 , 0 AS sum_ybly_Volume        <!---year before last year amount--->
									 , 0 AS sum_actual_Volume      <!---actual amount--->
									 , 0 AS sum_rolling_52
									 , 0 AS sum_rolling_prev_52
									 , 0 AS sum_rolling_13
									 , 0 AS sum_rolling_prev_13
							 FROM qOneRow
						</cfquery>
					</cfif>

					<cfif qPeriod.Became_Actual>
						<!---01---> <th class="headerTop">#NumberFormat(qSubtotals.sum_actual_Volume, const.volumeFormat)#</th>                           <!---actual volume--->
						<!---02---> <th class="bcolor2 headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_volume, percentage=0)#</th>   <!---delta between actual & last year--->
						<!---03---> <th class="bcolor2 headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_volume, percentage=1)#</th>   <!---delta % between actual & last year--->
						<!---04---> <th class="headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_volume, percentage=0)#</th>   <!---delta between actual & forecast--->
						<!---05---> <th class="headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_volume, percentage=1)#</th>   <!---delta % between actual & forecast--->
						<!---06---> <th class="bcolor2 headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=0)#</th>   <!---delta between actual & program--->
						<!---07---> <th class="bcolor2 headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=1)#</th>   <!---delta % between actual & program--->
					<cfelse>
						<!---Grand total ID template = g_<column_class_name>_<period_row_number>--->
						<!---Grand total ID examples = g_ly_vol_1, g_ly_vol_2, g_ly_vol_3--->

						<!---01---> <th id="g_#class.ly_vol#_#qPeriod.CurrentRow#" class="headerTop"> #NumberFormat(qSubtotals.sum_ly_Volume, const.volumeFormat)# </th>
						<!---02---> <th id="g_#class.ly_perc#_#qPeriod.CurrentRow#" class="headerTop"> #deltaValue(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1)# </th>
						<!---03---> <th id="g_#class.ty_perc#_#qPeriod.CurrentRow#" class="headerTop"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </th>
						<!---04---> <th id="g_#class.ty_vol#_#qPeriod.CurrentRow#" class="headerTop"> #NumberFormat(qSubtotals.sum_ty_Volume, const.volumeFormat)# </th>
						<!---05---> <th id="g_#class.delta_vol#_#qPeriod.CurrentRow#" class="headerTop"> #deltaValue(ty=qSubtotals.sum_ty_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0)# </th>
						<!---06---> <th id="g_#class.delta_perc#_#qPeriod.CurrentRow#" class="headerTop"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </th>
						<!---07---> <th id="g_#class.pgm_ny#_#qPeriod.CurrentRow#" class="headerTop"> #NumberFormat(qSubtotals.sum_ty_pgm, const.volumeFormat)# </th>
						<!---08---> <th id="g_#class.pgm_delta_amt#_#qPeriod.CurrentRow#" class="headerTop"> #deltaValue(ty=qSubtotals.sum_ty_Volume, ly=qSubtotals.sum_ty_pgm, percentage=0)# </th>
						<!---09---> <th id="g_#class.pgm_delta_perc#_#qPeriod.CurrentRow#" class="headerTop"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1)# </th>
						<!---<!---10---> <th id="g_#class.ybly_vol#_#qPeriod.CurrentRow#" class="headerTop"> #NumberFormat(qSubtotals.sum_ybly_Volume, const.volumeFormat)# </th>--->
					</cfif>
						<th class="divider headerTop">&nbsp;</th>
				</cfloop>

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

				<!---QUARTER Column Headers--->
				<!---Quarter ID template = q_<column_class_name>--->
				<!---Quarter ID examples = q_ly_vol, g_ly_vol, g_ly_vol--->
				<cfif qBecameActual.recordCount eq 3>
					<!---display actual values--->
					<!---01---> <th class="bcolor2 headerTop">#NumberFormat(qSubtotals.sum_actual_Volume,const.volumeFormat)#</th>                             <!---actual volume--->
					<!---02---> <th class="bcolor2 headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0)#</th>    <!---delta between actual & last year--->
					<!---03---> <th class="bcolor2 headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1)#</th>    <!---delta % between actual & last year--->
					<!---04---> <th class="headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_Volume, percentage=0)#</th>    <!---delta between actual & forecast--->
					<!---05---> <th class="headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1)#</th>    <!---delta % between actual & forecast--->
					<!---06---> <th class="bcolor2 headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=0)#</th>    <!---delta between actual & program--->
					<!---07---> <th class="bcolor2 headerTop">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=1)#</th>    <!---delta % between actual & program--->
				<cfelse>
					<!---01---> <th id="q_#class.ly_vol#" class="headerTop">  #NumberFormat(qSubtotals.sum_ly_Volume,const.volumeFormat)# </th>
					<!---02---> <th id="q_#class.ly_perc#" class="headerTop"> #deltaValue(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1)# </th>

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

					<!---03---> <!---<th id="q_#class.ty_perc#"> #deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </th>--->
					<!---04---> <th id="q_#class.ty_vol#" class="headerTop"> #NumberFormat(quarter.sum_ty_volume, const.volumeFormat)# </th>

					<!---05---> <th id="q_#class.delta_vol#" class="headerTop"> #deltaValue(ty=quarter.sum_ty_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0)# </th>
					<!---06---> <th id="q_#class.delta_perc#" class="headerTop"> #deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </th>
					<!---07---> <th id="q_#class.pgm_ny#" class="headerTop"> #NumberFormat(qSubtotals.sum_ty_pgm,const.volumeFormat)# </th>
					<!---08---> <th id="q_#class.pgm_delta_amt#" class="headerTop"> #deltaValue(ty=quarter.sum_ty_Volume, ly=qSubtotals.sum_ty_pgm, percentage=0)# </th>
					<!---09---> <th id="q_#class.pgm_delta_perc#" class="headerTop"> #deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1)# </th>
					<!---<!---10---> <th id="q_#class.ybly_vol#" class="headerTop"> #NumberFormat(qSubtotals.sum_ybly_Volume,const.volumeFormat)# </th>--->
				</cfif>
			</tr>
			</cfoutput>

		</thead>

<!---------------------------------------------------------- TBODY ---------------------------------------------------------------->
		<tbody id="tbl_body">
		<cfsetting enablecfoutputonly="true">
		<cfloop query="qProductPG">
			<cfoutput><tr id="tr_#qProductPG.CurrentRow#"></cfoutput>
			<cfoutput><td nowrap class="locked headerLeft" style="height:35px;"><cfif not main.readonly><input type="checkbox" name="cb_#pg_Product_Category_Id#" class="cb">&nbsp;</cfif>#qProductPG.pg_Product_Category_Name#</td></cfoutput>

      <cfquery name="qForecastMonths" dbtype="query">
          SELECT  SUM(Rolling_52)       AS Rolling_52
                 , SUM(Rolling_Prev_52) AS Rolling_Prev_52
                 , SUM(Rolling_13)      AS Rolling_13
                 , SUM(Rolling_Prev_13) AS Rolling_Prev_13
           FROM qForecast3Months
						WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
      </cfquery>
      <cfif qForecastMonths.recordCount eq 0>
        <cfquery name="qForecastMonths" dbtype="query">
            SELECT   0  AS Rolling_52
                   , 0  AS Rolling_Prev_52
                   , 0  AS Rolling_13
                   , 0  AS Rolling_Prev_13
						  FROM qOneRow
        </cfquery>
      </cfif>

			<cfquery name="qActual" dbtype="query">
					 SELECT   SUM(ly_volume)     AS ly_volume
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
						 SELECT   0 AS ly_volume
										, 0 AS actual_Volume
							FROM qOneRow
					</cfquery>
			</cfif>

			<!---02a---><cfoutput><td class="locked rolling headerLeft">#deltaValue(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=1)#</td></cfoutput>   <!--- ytd trend --->
			<!---02b---><cfoutput><td class="locked rolling headerLeft">#trendValue(ty=qForecastMonths.Rolling_52, ly=qForecastMonths.Rolling_Prev_52)#</td></cfoutput>      <!--- 52 wk trend --->
			<!---02c---><cfoutput><td class="locked rolling headerLeft">#trendValue(ty=qForecastMonths.Rolling_13, ly=qForecastMonths.Rolling_Prev_13)#</td></cfoutput>      <!--- 13 wk trend --->

				<!---Data for a month--->
				<cfloop query="qPeriod">
					<cfquery name="qForecastMonth" dbtype="query">
						 	<cfif main.summary>
						 			<!--- combine multiple records from different levels into one summary record --->
						 			SELECT   SUM(Actual_Volume) AS Actual_Volume
						        		 , 0                  AS Became_Actual
						        		 , 0                  AS Ly_Delta_Percentage
						        		 , SUM(Ly_Volume)     AS Ly_Volume
						        		 , SUM(Rolling_52)    AS Rolling_52
						        		 , SUM(Rolling_Prev_52) AS Rolling_Prev_52
						        		 , SUM(Rolling_13)    AS Rolling_13
						        		 , SUM(Rolling_Prev_13) AS Rolling_Prev_13
						        		 , 0                    AS Ty_Delta_Percentage
						        		 , SUM(Ty_PGM)          AS Ty_PGM
						        		 , 0                  AS Ty_PGM_Forecast_Delta
						        		 , 0                  AS Ty_PGM_Forecast_Delta_Percentage
						        		 , SUM(Ty_Volume)     AS Ty_Volume
						        		 , 0                  AS VF_Detail_ID
						        		 , <cfoutput>#qPeriod.VF_Period_Id#</cfoutput> AS VF_Period_ID
						        		 , SUM(Ybly_Volume)   AS Ybly_Volume
						        		 , 0                  AS Use_Absolute
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

					<cfquery name="qPrevForecastMonth" dbtype="query">
							<!---locate prior month values from previous quarter--->
							<cfif qPeriod.CurrentRow eq 1>
					 			SELECT *
								  FROM qLastForecastMonth
								 WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
							<cfelse>
								<!---locate prior month values from previous month in the same quarter--->
					 			SELECT *
								  FROM qForecast3Months
								 WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
										AND VF_Period_Id = <cfqueryparam value="#xPeriod.VF_Period_Id#" cfsqltype="cf_sql_integer">
							</cfif>
					</cfquery>

					<!--- keep track of previous period ID --->
					<cfset xPeriod.VF_Period_Id = qPeriod.VF_Period_Id>

					<!---Body cell class template = <column_class_name>_<period_row_number>--->
					<!---Body cell class examples = ly_vol_1, ly_vol_2, ly_vol_3--->

					<!---enable percentage input when last year volume exist--->
					<cfset main.percentInputEnabled = ( Val(qForecastMonth.ly_Volume) neq 0 and main.summary eq false)>

					<cfif not main.percentInputEnabled or qForecastMonth.use_absolute>    <!---percentage input is off or use_absolute is on 36348--->
						<cfset main.ty_vol = qForecastMonth.ty_Volume>
					<cfelseif val(qForecastMonth.ly_Volume) neq 0 <!--- and val(qForecastMonth.ty_Delta_Percentage) neq 0 --->>       <!---calculate this year volume based on last year volume and delta %--->
						<cfset main.ty_vol = (qForecastMonth.ly_Volume * ( 1 + (val(qForecastMonth.ty_Delta_Percentage) / 100) ))>
					<cfelse>
						<cfset main.ty_vol = "">                <!---missing values, can't calculate this year volume--->
					</cfif>

					<cfif qPeriod.Became_Actual>
						<!---01---> <cfoutput><td class="#class.ty_vol#_#qPeriod.CurrentRow#" style="background-color:white;">#volumeFormat(amt=qForecastMonth.actual_Volume, nullForZero=false)#</td></cfoutput>                        <!---actual volume--->
						<!---02---> <cfoutput><td class="bcolor2">#deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ly_volume, percentage=0)#</td></cfoutput>   <!---delta between actual & last year--->
						<!---03---> <cfoutput><td class="bcolor2">#deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ly_volume, percentage=1)#</td></cfoutput>   <!---delta % between actual & last year--->
						<!---04---> <cfoutput><td>#deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_volume, percentage=0)#</td></cfoutput>   <!---delta between actual & forecast--->
						<!---05---> <cfoutput><td>#deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_volume, percentage=1)#</td></cfoutput>   <!---delta % between actual & forecast--->
						<!---06---> <cfoutput><td class="bcolor2">#deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_pgm, percentage=0)#</td></cfoutput>      <!---delta between actual & program--->
						<!---07---> <cfoutput><td class="bcolor2">#deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_pgm, percentage=1)#</cfoutput>           <!---delta % between actual & program--->
						<!---hide forecast values by converting all td tags into span tags and wrap inside a hidden span tag--->
						<cfoutput><span style="display:none"></cfoutput>
						<cfset td = "span">
					<cfelse>
					  <!---display forecast values normally--->
						<cfset td = "td">
					</cfif>

					<!---01---> <cfoutput><#td# class="#class.ly_vol#_#qPeriod.CurrentRow#">#volumeFormat(qForecastMonth.ly_Volume)#</#td#></cfoutput>
					<!---02---> <cfoutput><#td# class="#class.ly_perc#_#qPeriod.CurrentRow#"><cfif val(qForecastMonth.ybly_volume) eq 0 or val(qForecastMonth.ly_volume) eq 0>&nbsp;<cfelse>#deltaValue(ty = qForecastMonth.ly_volume, ly = qForecastMonth.ybly_volume, percentage=1)#</cfif></#td#></cfoutput>

					<!---03---> <!---display blank when percentage equals to zero or is disabled--->
					<!---03---> <cfoutput><#td# class="#class.ty_perc#_#qPeriod.CurrentRow#"> <input type="hidden" class="#(class.use_absolute & '_' & qPeriod.CurrentRow)#" name="#(const.use_absolute & qForecastMonth.VF_Detail_ID)#" id="#(const.use_absolute & qForecastMonth.VF_Detail_ID)#" value="#qForecastMonth.Use_Absolute#"> </cfoutput>
					<!---03---> <cfif main.percentInputEnabled>
					<!---03---> 	<cfif main.readonly>
													<cfif qForecastMonth.Use_Absolute eq '0'>   <!--- 36348 --->
					<!---03--->				<cfoutput>#volumeFormat(amt=qForecastMonth.ty_Delta_Percentage, percentage=1)#</cfoutput>
													</cfif>
					<!---03--->		<cfelse>
													// save prior month value (pulled from db) into a custom 'priorMonth' attribute  (35751)
													// when users click on carry forward button we would copy this prior month value
													// this copying action should be carried out only for the FIRST period
													// for 2nd period and 3rd period we will copy the values displayed on the screen
													<cfset priorMonth = "priorMonth=" & trim(NumberFormat(qPrevForecastMonth.ty_Delta_Percentage,const.percentFormat))>
					<!---03--->   	<cfoutput><input class="#class.ty_perc#_#qPeriod.CurrentRow# #class.input_perc#" #priorMonth# month="#Left(qPeriod.Period_Desc,3)#" name="#const.deltaPrefix##qForecastMonth.VF_Detail_ID#" <cfif qForecastMonth.Use_Absolute eq '0'>value="#Trim(NumberFormat(qForecastMonth.ty_Delta_Percentage,const.percentFormat))#"</cfif> type="text"><span class="percent">%</span></cfoutput>
					<!---03--->   </cfif>
					<!---03---> <cfelse>
					<!---03--->   <cfoutput>&nbsp;</cfoutput>
					<!---03---> </cfif>
					<!---03---> <cfoutput></#td#></cfoutput>

					<!---04---> <!---display blank (not zero) when ty_volume equals to zero or ty_percentage equals to zero--->
					<!---04---> <cfoutput><#td# class="#class.ty_vol#_#qPeriod.CurrentRow#"></cfoutput>
					<!---04---> <cfif main.readonly>
					<!---04---> 	<cfoutput><cfif val(qForecastMonth.ty_Volume) eq 0>&nbsp;<cfelse>#Trim(NumberFormat(qForecastMonth.ty_Volume,const.volumeFormat))#</cfif></cfoutput>
					<!---04--->	<cfelse>
												// save prior month value (pulled from db) into a custom 'priorMonth' attribute  (35751)
												// when users click on carry forward button we would copy this prior month value
												// this copying action should be carried out only for the FIRST period
												// for 2nd period and 3rd period we will copy the values displayed on the screen
												<cfif val(qPrevForecastMonth.ty_Volume) eq 0>
													<cfset priorMonth = "">
												<cfelse>
													<cfset priorMonth = "priorMonth=" & trim(NumberFormat(qPrevForecastMonth.ty_Volume,const.volumeFormat))>
												</cfif>
												<!--- 'priorMonth'   attribute exists when prior month value exists
												      generic class for all 3 months = class.input_amt variable ( see actual value defined at the top ) --->
					<!---04---> 	<cfoutput><input class="#class.ty_vol#_#qPeriod.CurrentRow# #class.input_amt#" #priorMonth# month="#Left(qPeriod.Period_Desc,3)#" name="#const.volumePrefix##qForecastMonth.VF_Detail_ID#" <cfif val(qForecastMonth.ty_Volume) neq 0>value="#Trim(NumberFormat(qForecastMonth.ty_Volume,const.volumeFormat))#"</cfif> type="text"></cfoutput>
					<!---03---> </cfif>
					<!---04---> <cfoutput></#td#></cfoutput>

					<!---05---> <!---display blank when ly_vol = 0 or ty_vol = 0--->
					<!---05---> <cfoutput><#td# class="#class.delta_vol#_#qPeriod.CurrentRow#"><cfif val(main.ty_vol) eq 0>&nbsp;<cfelse>#NumberFormat(main.ty_vol - val(qForecastMonth.ly_Volume), const.volumeFormat)#</cfif></#td#></cfoutput>

					<!---06---> <!---display blank when ty_volume = 0 or ly_volume = 0--->
					<!---06---> <cfif main.percentInputEnabled>
					<!---06--->   <cfset main.ty_Delta_Percentage = qForecastMonth.ty_Delta_Percentage & "%">
					<!---06---> <cfelse>                                     <!---percentage input is off, calculate the percentage--->
					<!---06--->   <cfset main.ty_Delta_Percentage = deltaValue(ty = main.ty_vol, ly = qForecastMonth.ly_Volume, percentage=1)>
					<!---06--->   <!--- <cfif len(main.ty_Delta_Percentage)> --->
					<!---06--->   	<!--- <cfset main.ty_Delta_Percentage = main.ty_Delta_Percentage & '%'> --->
					<!---06---> 	<!--- </cfif> --->
					<!---06---> </cfif>
					<!---06---> <cfoutput><#td# class="#class.delta_perc#_#qPeriod.CurrentRow#"><cfif val(main.ty_vol) eq 0 or val(qForecastMonth.ly_Volume) eq 0>&nbsp;<cfelse>#main.ty_Delta_Percentage#</cfif></#td#></cfoutput>

					<!---07---> <cfoutput><#td# class="#class.pgm_ny#_#qPeriod.CurrentRow#">#qForecastMonth.ty_PGM#</#td#></cfoutput>

					<!---08---> <!---display blank when ty_vol = 0 or column #07 = 0--->
					<!---08---> <cfoutput><#td# class="#class.pgm_delta_amt#_#qPeriod.CurrentRow#"><cfif val(main.ty_vol) eq 0>&nbsp;<cfelse>#NumberFormat(main.ty_vol - val(qForecastMonth.ty_pgm), const.volumeFormat)#</cfif></#td#></cfoutput>
					<!---09---> <cfoutput><#td# class="#class.pgm_delta_perc#_#qPeriod.CurrentRow#"><cfif val(main.ty_vol) eq 0 or qForecastMonth.ty_PGM eq 0>&nbsp;<cfelse>#deltaValue(ty = main.ty_vol, ly = qForecastMonth.ty_pgm, percentage=1)#</cfif></#td#></cfoutput>
					<!---<!---10---> <cfoutput><#td# class="#class.ybly_vol#_#qPeriod.CurrentRow#"><cfif val(qForecastMonth.ybly_volume) eq 0>&nbsp;<cfelse>#NumberFormat(qForecastMonth.ybly_Volume,const.volumeFormat)#</cfif></#td#></cfoutput>--->

					<cfif qPeriod.Became_Actual>
							<!---close the hidden span tag and td tag--->
							<cfoutput></span></td></cfoutput>
					</cfif>
											<cfoutput><td class="divider">&nbsp;</td></cfoutput>
				</cfloop>  <!---query="qPeriod"--->

<!---------------------------------------------------------- QUARTER -------------------------------------------------------------->
				<cfquery name="qSubtotals" dbtype="query">
					 SELECT  SUM(ly_Volume) AS sum_ly_Volume
								 , SUM(ty_Volume) AS sum_ty_Volume
								 , SUM(ty_pgm) AS sum_ty_pgm
								 , SUM(ybly_Volume) AS sum_ybly_Volume
								 , SUM(actual_volume) AS sum_actual_Volume
						 FROM qForecast3Months
						WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
				</cfquery>

					<!---Quarter cell class template = <column_class_name>--->
					<!---Quarter cell class examples = ly_vol, ly_vol, ly_vol--->

				<cfif qBecameActual.recordCount eq 3>
					<!---display actual values--->
					<!---01---> <cfoutput><td>#NumberFormat(qSubtotals.sum_actual_Volume,const.volumeFormat)#</td></cfoutput>                            <!---actual volume--->
					<!---02---> <cfoutput><td class="bcolor2">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0)#</td></cfoutput>   <!---delta between actual & last year--->
					<!---03---> <cfoutput><td class="bcolor2">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1)#</td></cfoutput>   <!---delta % between actual & last year--->
					<!---04---> <cfoutput><td>#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_Volume, percentage=0)#</td></cfoutput>   <!---delta between actual & forecast--->
					<!---05---> <cfoutput><td>#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1)#</td></cfoutput>   <!---delta % between actual & forecast--->
					<!---06---> <cfoutput><td class="bcolor2">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=0)#</td></cfoutput>   <!---delta between actual & program--->
					<!---07---> <cfoutput><td class="bcolor2">#deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=1)#</td></cfoutput>   <!---delta % between actual & program--->
				<cfelse>
					<!---01---> <cfoutput><td class="#class.ly_vol#"> #NumberFormat(qSubtotals.sum_ly_Volume,const.volumeFormat)# </td></cfoutput>
					<!---02---> <cfoutput><td class="#class.ly_perc#"> #deltaValue(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1)# </td></cfoutput>

					<!---tue 2012/feb/21: Paul changed FC forecast EQC column to be sum of actual volume (months in the past) + sum of forecast (current & future months)--->
					<cfquery name="qFCSubtotals" dbtype="query">
							 SELECT  SUM(ly_Volume) AS sum_ly_Volume
										 , SUM(ty_Volume) AS sum_ty_Volume
										 , SUM(ty_pgm) AS sum_ty_pgm
										 , SUM(ybly_Volume) AS sum_ybly_Volume
										 , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
							 FROM qForecast3Months
							 WHERE Became_Actual = 0
							       AND PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfquery name="qACTSubtotals" dbtype="query">
							 SELECT  SUM(ly_Volume) AS sum_ly_Volume
										 , SUM(ty_Volume) AS sum_ty_Volume
										 , SUM(ty_pgm) AS sum_ty_pgm
										 , SUM(ybly_Volume) AS sum_ybly_Volume
										 , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
							 FROM qForecast3Months
							 WHERE Became_Actual = 1
					       AND PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfset quarter.sum_ty_volume = val(qFCSubtotals.sum_ty_Volume) + val(qACTSubtotals.sum_actual_Volume)>

					<!---03---> <!---<cfoutput><td class="#class.ty_perc#"> #deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </td></cfoutput>--->
					<!---04---> <cfoutput><td class="#class.ty_vol#"> #NumberFormat(quarter.sum_ty_Volume,const.volumeFormat)# </td></cfoutput>
					<!---05---> <cfoutput><td class="#class.delta_vol#">  #deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=0)# </td></cfoutput>
					<!---06---> <cfoutput><td class="#class.delta_perc#"> #deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </td></cfoutput>
					<!---07---> <cfoutput><td class="#class.pgm_ny#"> #NumberFormat(qSubtotals.sum_ty_pgm,const.volumeFormat)# </td></cfoutput>
					<!---08---> <cfoutput><td class="#class.pgm_delta_amt#">  #deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=0)# </td></cfoutput>
					<!---09---> <cfoutput><td class="#class.pgm_delta_perc#"> #deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1)# </td></cfoutput>
					<!---<!---10---> <cfoutput><td class="#class.ybly_vol#"> #NumberFormat(qSubtotals.sum_ybly_Volume,const.volumeFormat)# </td></cfoutput>--->
				</cfif>
			<cfoutput></tr></cfoutput>
		</cfloop>
		<cfsetting enablecfoutputonly="false">
		</tbody>
	</table>

	<!---
	///////////////////////////////////////////////////////////////////////////
	// carry forward to future months in editing values on quarter 1, 2 and 3
	///////////////////////////////////////////////////////////////////////////
	--->
	<cfif not main.readonly and url.q636 lt 4>
		<div id="cfm">
		<label title="When this setting is YES, forecasted EQC values from latest month will be carried forward to all future months. For example if you are entering a forecast for June, July & August. August is considered the 'latest' month. Steps a user would take: enter forecast EQC values for June, July & August. Put a check mark next to the product groups that should have their value carried forward & click 'save'. For product groups with check marks their August Forecast EQC values will be carried forward.">Carry forward to future months <img src="/images/i.gif" height="12px" width="12px">:</label> &nbsp; <input type="radio" name="carryfuturemonths" value="0" checked="checked"> no <input type="radio" name="carryfuturemonths" value="1"> yes
		</div>
	</cfif>
</div>
</form>

<!--------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="trendValue" output="false" returntype="String" hint="Return trend percentage based on this year volume and last year volume">
	<cfargument name="ty" required="true" hint="I am this year volume">
	<cfargument name="ly" required="true" hint="I am last year volume">

	<cfif val(arguments.ly) eq 0>
		<cfreturn "0%">
	<cfelse>
		<cfreturn NumberFormat((val(arguments.ty) - val(arguments.ly)) / val(arguments.ly) * 100, const.percentFormat) & '%'>
	</cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="inputIsValid" output="false" returntype="boolean" hint="Return true if input values are valid otherwise return false">
	<cfset l = {}>
	<cfloop collection="#form#" item="l.formField">
		<cfif (l.formField contains const.deltaPrefix) or (l.formField contains const.volumePrefix)>
			<cfset l.rowValue = replace(form[ l.formField ], ",", "", "all")>
			<cfif len(trim(l.rowValue)) eq 0>
				<cfset l.rowValue = '0'>
			</cfif>
			<cfif !isNumeric(l.rowValue)>
				<cfreturn false>
			</cfif>
		</cfif>
	</cfloop>
	<cfreturn true>
</cffunction>

<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->
<cfinclude template="/common_files/jQuery.cfm">

<cfif 0>
	<script type="text/javascript" src="/Script/javascript/jquery.cfjs.min.js?v=2011-10-26"></script>
	<script type="text/javascript" src="/Script/javascript/jquery.calculation.min.js?v=2011-10-26"></script>
	<script type="text/javascript" src="/Script/javascript/variable.debugger.js?v=2011-10-26"></script>
	<script type="text/javascript" src="/Script/javascript/jquery-impromptu.3.1.min.js"></script>
	<script type="text/javascript" src="/Script/javascript/math_functions.js"></script>
	<script type="text/javascript" src="/Script/javascript/scrollHeader.js"></script>
<cfelse>
	<!---
	////////////////////////////////////////////////////////////////////////////////////////
	// use the combined/compressed vfbymonth-ugly.js file for best page loading performance
	//	run /script/javascript/vfbymonth.bat to build the vfbymonth-ugly.js
	///////////////////////////////////////////////////////////////////////////////////////
	--->
	<cfoutput>
	<script src="/script/javascript/vfbymonth-ugly.js?v=#application.util.dateTime.fileVersion('/script/javascript/vfbymonth-ugly.js')#"></script>
	</cfoutput>
</cfif>
<script type="text/javascript">
window.moveTo(0,0);
// reduce the table height to allow room for buttons
$('#tbl-container').css("height", screen.availHeight - 195);
$('.tbl tr:odd').css("background-color", "#f5f5f5");
window.resizeTo( screen.availWidth, screen.availHeight );
$('#tbl-container').show();

window.$my = {
	changes : 0
	,opener: window.opener
	<cfif not main.readonly>
		// Initialize all the queries you want to use more than once
		<cfoutput>
		,input_checkbox : $('input:checkbox')
		,input_ty_vol   : [0, $('input.#class.ty_vol#_1'),  $('input.#class.ty_vol#_2'),  $('input.#class.ty_vol#_3') ]
		,input_ty_perc  : [0, $('input.#class.ty_perc#_1'), $('input.#class.ty_perc#_2'), $('input.#class.ty_perc#_3') ]
		,qtr_ty_vol     : $('.#class.ty_vol#')
		</cfoutput>
	</cfif>
};
<!--------------------------------------------------------------------------------------------------------------------->
stringToNumeric = function( str ) {
	var num = parseFloat( $.Replace(str, ',', '', 'all') );
	if ( isNaN(num) ) {
		return 0;
	}
	else {
		return num;
	}
}

function carryFutureMonthsIsValid() {
	if ( $('input[name=carryfuturemonths]:checked').val() == 1 ) {
		if ($('tbody input[type=checkbox]:checked').length == 0) {
			alert("Please put a check mark next to the product groups that should have their value carried forward to future months.");
			return false;
		}
	}
	return true;
}

<!----------------------------------------------Events for markets dropdown------------------------------------------------>
$('#marketslist').bind(
		'change', function(e) {
				e.stopPropagation();
				<cfoutput>
				var option = this.options[this.selectedIndex];
				    url = '#cgi.script_name#?#removeURLfields('v451,l143,r354')#&' + $(option).attr('id');
				</cfoutput>
        unlock();
				// console.log ( $(option).text() + ' ' + $(option).attr('id') );
				if ( $my.changes > 0 ) {
						$.prompt( "You have unsaved changes. Do you wish to save?", {
									buttons: { Save:true, Ignore:false }
									,callback: function(save, m, f){
															if ( save ) {
																if ( carryFutureMonthsIsValid() ) {
																	$('#windowNewLocation').val( url );
																	window.workbook.submit();
																}
														  }
														  else {
																window.location = url;
														  }
										        }
						});
				}
				else {
					window.location = url;
				}
		}
);

<!----------------------------------------------Unlock volume forecast----------------------------------------------------->
  unlock = function() {
  <cfif not main.readonly and not main.summary>
    if (ok2unlock) {
      <cfoutput>
      $.ajax({
          url: "/mvc/models/volumeforecast/vfmanager.cfc"
        , type: "get"
        , data: {
            method: "saveLockedBy"
          , level: "#url.l143#"
          , userID: ""
        }
      });
      </cfoutput>
    }
  </cfif>
}

<!--------------------------------------------------------------------------------------------------------------------->
<cfif main.readonly>
	<!---rows hovering--->
	$('table.tbl tr').hover (
		function() { $(this).addClass("over"); },
		function() { $(this).removeClass("over"); }
	);
<cfelse>
<!--------------------------------------------------------------------------------------------------------------------->
  $(window).unload( function () { window.opener.location.href = window.opener.location.href;
																	unlock(); } );
	<!---forceNumeric() plug-in implementation--->
	$.fn.forceNumeric = function ( auto_jump_next_row ) {
		 return this.each(function () {
				 $(this).keydown(function (e) {
						 var key = e.which || e.keyCode;
						 //alert (key);
						 if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
						 <!---numbers--->( key >= 48 && key <= 57 ) ||
						 <!---Numeric keypad--->( key >= 96 && key <= 105 ) ||
						 <!---comma, period and minus--->key == 190 || key == 188 || key == 189 ||
						 <!---Backspace and Tab and Enter--->key == 8 || key == 9 || key == 13 ||
						 <!---Home and End--->key == 35 || key == 36 ||
						 <!---left, up and right, down arrows--->( key >= 37 && key <= 40 ) ||
						 <!---Del and Ins--->key == 46 || key == 45 ||
						 <!---Decimal point on numeric keypad---> key == 110)
						 {
						 	 if (key == 189) {
						 	 	// do not take another minus sign if there is already one
						 	 	if ( this.value.indexOf("-") != -1 )
						 	 	  return false;
						 	 }
							 if ( auto_jump_next_row ) {
								 <!---go to next row--->
								 if ( key == 13 || key == 40 ) {
								 	 /* do not go to next row if it is an percentage input */
									 if ( $(this).hasClass(<cfoutput>"#class.input_perc#"</cfoutput>) ) {
									 	var inputMonth = $(this).prop('month'),
									 	    $trParent = $(this).closest('tr'),
									 	    $elem = $trParent.find('input[month=' + inputMonth + ']');
									  if ( $elem.length ) $elem[1].focus();
									 	return true;
									 }
									 e.preventDefault();

									 <!---special handling for mass update--->
									 if ( auto_jump_next_row == 2) {
										 <!---focus on different element to trigger the changes to checked rows--->
										 $('#toggle_all').focus();
									 }
									 else {
										 <!---locate the next tr with input text--->
										 var inputMonth = $(this).prop('month'),
										     $trParent = $(this).closest('tr'),
												 <!---locate the input on next row for the same period--->
												 $elem = $trParent.next().find('input[month=' + inputMonth + ']');
										 <!---if found focus the first input--->
										 if ( $elem.length ) $elem[0].focus();
									 }

								 }
								 <!---go to previous row--->
								 else if ( key == 38 ) {

									 <!---locate the prev tr with input text--->
									 var inputMonth = $(this).prop('month'),
									     $trParent = $(this).closest('tr'),
											 <!---locate the input on previous row for the same period--->
												$elem = $trParent.prev().find('input[month=' + inputMonth + ']');

									 <!---if found focus the first input--->
									 if ( $elem.length ) $elem[0].focus();
								 }
							 }
							 return true;
						 }
						 return false;
				 });
		 });
	}
	<!--------------------------------------------------------------------------------------------------------------------->
	/*row calculation*/
	rowCalc = function( $elem ) {
		var l = {};
		l.isVolume = 0;
		l.$trParent = $elem.closest('tr');
		<cfoutput>
		<!---identify the l.period, percent input vs. volume input--->
		for ( l.period = 1; l.period <= 3; l.period++ ) {
			if ( $elem.hasClass('#class.ty_perc#_' + l.period) ) {
				l.isVolume = 0;
				break;
			}
			if ( $elem.hasClass('#class.ty_vol#_' + l.period) ) {
				l.isVolume = 1;
				break;
			}
		}
		if (l.period > 3) {
			alert ( 'Help needed in rowCalc()!' );
			return;
		}

		l.ty_perc = 0;
		l.ly_vol = stringToNumeric( l.$trParent.find('.#class.ly_vol#_' + l.period).html() );

		<!---calculation for volume inputs--->
		if ( l.isVolume ) {
			l.ty_vol = stringToNumeric( $elem.val() );
		}
		<!---calculation for percentage inputs--->
		else {
			<!---update #04---> l.ty_perc = stringToNumeric( $elem.val() ) / 100;
			<!---update #04---> l.ty_vol  = l.ly_vol * (1 + l.ty_perc);
			<!---update #04---> l.$trParent.find('.#class.ty_vol#_' + l.period).val( $._commafy(l.ty_vol.toFixed(0)) );   // 36348
		}

		<!---update #05---> l.delta_vol = l.ty_vol - l.ly_vol;
		<!---update #05---> l.$trParent.find('.#class.delta_vol#_' + l.period).html( $._commafy( l.delta_vol.toFixed(0) ) );

		l.pgm_ny = l.$trParent.find('.#class.pgm_ny#_' + l.period).html();

		if ( l.isVolume ) {
			<!---ly volume not exists, cannot calculate #06--->
		}
		else {
			<!---update #06---> l.$trParent.find('.#class.delta_perc#_' + l.period).html( $elem.val() + '%' );
		}

		<!---update #08---> l.delta_vol = l.ty_vol - stringToNumeric( l.pgm_ny );
		<!---update #08---> l.$trParent.find('.#class.pgm_delta_amt#_' + l.period).html( $._commafy( l.delta_vol.toFixed(0) ) );

		if ( l.pgm_ny !== '0' ) {
			<!---update #09---> l.delta_perc = l.delta_vol / stringToNumeric( l.pgm_ny ) * 100;
			<!---update #09---> l.$trParent.find('.#class.pgm_delta_perc#_' + l.period).html( $._commafy( l.delta_perc.toFixed(2) ) + '%');
		}

		<!------------------------------------------updating quarter's cells------------------------------------------------->
		<!--------------------------------
				l.qtotal[1] = l.ly_vol
				l.qtotal[2] = ly_perc
				l.qtotal[3] = l.ty_perc      (no longer displayed on screen)
				l.qtotal[4] = l.ty_vol
				l.qtotal[5] = l.delta_vol
				l.qtotal[6] = l.delta_perc
				l.qtotal[7] = l.pgm_ny
				l.qtotal[8] = pgm_delta_amt
				l.qtotal[9] = pgm_delta_perc
				-- Ignore the array element at position 0
				-- Array element positions are matched to quarter column numbers (e.g. qtotal[1] is for column 1)
		--------------------------------->
		l.qtotal = [ 0, 0, 0, 0, 0,
								 0, 0, 0, 0, 0,
								 0 ];
		<!---sum up all three periods--->
		for (l.period = 1; l.period <= 3; l.period++) {
			<!---get input value if there is an input element--->
			if ( l.$trParent.find('input.#class.ty_vol#_' + l.period).length ) {
				l.qtotal[4]  = l.qtotal[4]  + stringToNumeric( l.$trParent.find('input.#class.ty_vol#_' + l.period).val() );
			}
			else {
				<!---otherwise just get the html text value (applicable when percentage input exists)--->
				l.qtotal[4]  = l.qtotal[4]  + stringToNumeric( l.$trParent.find('.#class.ty_vol#_' + l.period).html() );
			}
		}

		l.qtotal[1] = stringToNumeric( l.$trParent.find('.#class.ly_vol#').html() );
		l.qtotal[5] = l.qtotal[4] - l.qtotal[1];
		l.qtotal[6] = (l.qtotal[4] - l.qtotal[1]) / l.qtotal[1] * 100;
		l.qtotal[7] = stringToNumeric( l.$trParent.find('.#class.pgm_ny#').html() );
		l.qtotal[8] = l.qtotal[4] - l.qtotal[7];;


		<!---update #4Q---> l.$trParent.find('.#class.ty_vol#').html( $._commafy(l.qtotal[4].toFixed(0)) );
		<!---update #5Q---> l.$trParent.find('.#class.delta_vol#').html( $._commafy(l.qtotal[5].toFixed(0)) );
		<!---update #6Q---> l.$trParent.find('.#class.delta_perc#').html( $._commafy(l.qtotal[6].toFixed(2)) + '%');
		<!---update #8Q---> l.$trParent.find('.#class.pgm_delta_amt#').html( $._commafy(l.qtotal[8].toFixed(0)) );

		if ( l.qtotal[7] !== 0 ) {
			l.qtotal[9] = l.qtotal[8] / l.qtotal[7] * 100;
			<!---update #9Q---> l.$trParent.find('.#class.pgm_delta_perc#').html( $._commafy(l.qtotal[9].toFixed(2)) + '%');
		}
		</cfoutput>
	}

	<!--------------------------------------------------------------------------------------------------------------------->
	/*grand totals calculations*/
	grandTotalCalc = function( $elem ) {
		var l = {};
		l.$tr_gtotal = $('#tr_gtotal');

		<cfoutput>
		<!---identify the period--->
		for ( period = 1; period <= 3; period++ ) {
			if ( $elem.hasClass('#class.ty_vol#_' + period) ) {
				break;
			}
			if ( $elem.hasClass('#class.ty_perc#_' + period) ) {
				break;
			}
		}
		if (period > 3) {
			alert ( 'Help needed in grandTotalCalc()!' );
			return;
		}

		l.ty_vol_input = $my.input_ty_vol[period].sum();
		<!---add this year volume from rows with this year percentage input--->
		l.ty_vol_text = 0;
		// 36348 no need to sum up ty_vol text, they are all defined as input now
		//  $my.input_ty_perc[period].each(function() {
		//  	l.ty_vol_text = l.ty_vol_text + stringToNumeric( $(this).closest('tr').find('.#class.ty_vol#_' + period).val() );  // 36348
		//  });

		l.ty_vol = l.ty_vol_input + l.ty_vol_text;
		l.ly_vol = stringToNumeric( l.$tr_gtotal.find('##g_#class.ly_vol#_' + period).html() );

		if ( l.ly_vol == 0 ) {
			l.ty_perc = 0;
		}
		else {
			l.ty_perc = ((l.ty_vol - l.ly_vol) / l.ly_vol ) * 100;
		}

		<!---update #03---> l.$tr_gtotal.find('##g_#class.ty_perc#_' + period).html( $._commafy(l.ty_perc.toFixed(2)) + '%' );
		<!---update #04---> l.$tr_gtotal.find('##g_#class.ty_vol#_' + period).html( $._commafy(l.ty_vol.toFixed(0)) );

		<!---update #05---> l.result = l.ty_vol - l.ly_vol;
		<!---update #05---> l.$tr_gtotal.find('##g_#class.delta_vol#_' + period).html( $._commafy(l.result.toFixed(0)) );

		if ( l.ly_vol !== 0 ) {
			<!---update #06---> l.result = ( l.ty_vol - l.ly_vol ) / l.ly_vol * 100 ;
			<!---update #06---> l.$tr_gtotal.find('##g_#class.delta_perc#_' + period).html( $._commafy(l.result.toFixed(2)) + '%' );
		}

		<!---update #08---> l.pgm_ny = stringToNumeric( l.$tr_gtotal.find('##g_#class.pgm_ny#' + period).text() );
		<!---update #08---> l.result = ( l.ty_vol - l.pgm_ny );
		<!---update #08---> l.$tr_gtotal.find('##g_#class.pgm_delta_amt#_' + period).html( $._commafy(l.result.toFixed(0)) );

		if ( l.pgm_ny !== 0 ) {
			<!---update #09---> l.result = ( l.ty_vol - l.pgm_ny ) / l.pgm_ny * 100 ;
			<!---update #09---> l.$tr_gtotal.find('##g_#class.pgm_delta_perc#_' + period).html( $._commafy(l.result.toFixed(2)) + '%' );
		}
		<!------------------------------------------updating quarter's cells------------------------------------------------->
		<!--------------------------------
				l.qtotal[1] = l.ly_vol
				l.qtotal[2] = ly_perc
				l.qtotal[3] = l.ty_perc
				l.qtotal[4] = l.ty_vol
				l.qtotal[5] = delta_vol
				l.qtotal[6] = delta_perc
				l.qtotal[7] = l.pgm_ny
				l.qtotal[8] = pgm_delta_amt
				l.qtotal[9] = pgm_delta_perc
				-- Ignore the array element at position 0
				-- Array element positions are matched to quarter column numbers (e.g. qtotal[1] is for column 1)
		--------------------------------->
		l.qtotal = [ 0, 0, 0, 0, 0,
								 0, 0, 0, 0, 0,
								 0 ];

		l.qtotal[1] = stringToNumeric( l.$tr_gtotal.find('##q_#class.ly_vol#').html() );
		l.qtotal[4] = $my.qtr_ty_vol.sum();
		l.qtotal[5] = l.qtotal[4] - l.qtotal[1];
		if ( l.qtotal[1] !== 0 ) {
			l.qtotal[6] = ( l.qtotal[4] - l.qtotal[1] ) / l.qtotal[1] * 100 ;
			<!---update #G3Q---> l.$tr_gtotal.find('##q_#class.ty_perc#').html( $._commafy(l.qtotal[6].toFixed(2)) + '%');
			<!---update #G6Q---> l.$tr_gtotal.find('##q_#class.delta_perc#').html( $._commafy(l.qtotal[6].toFixed(2)) + '%');
		}
		l.qtotal[7] = stringToNumeric( l.$tr_gtotal.find('##q_#class.pgm_ny#').html() );
		l.qtotal[8] = l.qtotal[4] - l.qtotal[7];;

		<!---update #G4Q---> l.$tr_gtotal.find('##q_#class.ty_vol#').html( $._commafy(l.qtotal[4].toFixed(0)) );
		<!---update #G5Q---> l.$tr_gtotal.find('##q_#class.delta_vol#').html( $._commafy(l.qtotal[5].toFixed(0)) );
		<!---update #G8Q---> l.$tr_gtotal.find('##q_#class.pgm_delta_amt#').html( $._commafy(l.qtotal[8].toFixed(0)) );

		if ( l.qtotal[7] !== 0 ) {
			l.qtotal[9] = l.qtotal[8] / l.qtotal[7] * 100;
			<!---update #G9Q---> l.$tr_gtotal.find('##q_#class.pgm_delta_perc#').html( $._commafy(l.qtotal[9].toFixed(2)) + '%');
		}
		</cfoutput>
		refreshColor();
	}
	<!----------------------------------------------Events for checkboxes------------------------------------------------------>
	<!---toggle checkbox on left column click--->
	$('tr td:nth-child(1), #td_product').bind(
		'click', function(event) {
							if (event.target.type !== 'checkbox') {
								$(':checkbox', this).trigger('click');
								<!--- if clicked on toggle all apply checked value to other checkboxes--->
								if ( $(this).attr('id') === 'td_product' ) {
									$my.input_checkbox.prop('checked', ( $('#toggle_all').prop('checked') ) ? true : false );
								}
							}
						}
	);
	<!---toggle all checkboxes--->
	$('#toggle_all').bind(
		'change', function(e) {     <!---listen for the change event on the toggle--->
				$my.input_checkbox.prop('checked', ( this.checked ) ? true : false );
				e.stopPropagation();
		}
	);
	<!----------------------------------------------Events for input text------------------------------------------------------>
	$('input[type=text]')
		 .forceNumeric(1)
		 .bind({
				<!---add diff background color to focused element----------------------------------------------------------------------->
				focus:   function() { $(this).select().addClass('hilight'); }
				,blur:   function() { $(this).removeClass('hilight'); }
				,change: function(e) {
									var thisObj = $(this);
									// 36348 -handling for EQCs input
									if ( thisObj.hasClass( <cfoutput>'#class.input_amt#'</cfoutput> ) ) {
										var detail_id = $.ListLast(thisObj.attr('name'), '_');
										$('#<cfoutput>#const.use_absolute#</cfoutput>' + + detail_id).val( 1 ); // flag use_absolute ON
										$('input[name=delta_' + detail_id + ']').val( '' ); // wipe out percentage
										// console.log ( thisObj.attr('name') + ' | detail_id = ' + detail_id + ' | use_abs = ' + $('#abs_' + detail_id).val() );
									}
									// 36348 -handling for percentage input
									else if ( thisObj.hasClass( <cfoutput>'#class.input_perc#'</cfoutput> ) ) {
										var detail_id = $.ListLast(thisObj.attr('name'), '_');
										$('#<cfoutput>#const.use_absolute#</cfoutput>' + + detail_id).val( 0 ); // flag use_absolute OFF
										// console.log ( thisObj.attr('name') + ' | detail_id = ' + detail_id + ' | use_abs = ' + $('#abs_' + detail_id).val() );
									}
									// if (!$.IsNumeric( this.value )) {
									// 	e.preventDefault();
									// 	alert("Please use a valid numeric value.");
									// }
									if ( !thisObj.hasClass(<cfoutput>'#class.mass_update#'</cfoutput>) ) {
										<!---add diff background color for changed elements--->
										thisObj.css("background-color","#E6B8B7");
										++$my.changes;
										rowCalc( thisObj );
										grandTotalCalc( thisObj );
									}

								}
		 });

	<!----------------------------------------------Events for mass update----------------------------------------------------->
	$(<cfoutput>'##tr_colhdr .#class.mass_update#'</cfoutput>).each(function() {
		$(this)
				.forceNumeric(2)                             <!---filter valid keys for numeric input--->
				.data('default', $(this).val())
				.addClass('inactive')
				.bind({
					focus: function() {
									// remove the form hint
									if ($(this).val() == $(this).data('default') || '') {
										$(this).val('');
									}
									$(this).removeClass('inactive');
								}
					,blur: function(){                    <!---apply mass update value to selected rows--->
					var amt = $(this).val();
					<!---amount entered?--->
					if ( amt ) {
						<!---get the id of massupdate element (being used as class name in input elements in the same column)--->
						var columnClass = $(this).prop('id'), appliedCnt = 0, $checkedElem = 0;
						<!---go thru all checked rows, change the amounts--->
						$my.input_checkbox.filter(':checked').each(function(){

							$checkedElem = $(this).closest('tr')         <!---locate the nearest tr parent--->
															 .find('.' + columnClass)      <!---find element with same class on this checked row--->
															 .find('input[type=text]');    <!---find input element--->

							if ( $checkedElem.length ) {
								if (appliedCnt === 0) {
									$savedElem = $checkedElem;
								}
								$checkedElem.val( amt )                          <!---apply mass amount--->
														.css("background-color","#E6B8B7");  <!---change background color--->
								rowCalc( $checkedElem );
								++appliedCnt;
								++$my.changes;
							}
						});
						if ( appliedCnt ) {
							grandTotalCalc( $savedElem );
						}
					}
					// restore the form hint
					var default_val = $(this).data('default');
					if ($(this).val() == '') {
						$(this).addClass('inactive');
						$(this).val($(this).data('default'));
					}
				}
			});
	});
</cfif>
</script>

<!----------------------------------------------FOOTER BUTTONS--------------------------------------------------------->
<div style="margin:0px 20px;" id="div_actions">
<span style="float:left">
<cfif main.editIsAllowed>
	<cfif main.readonly>
		<cfoutput><button id="b_edit" class="action clickforaction mediumButton"> Edit </button></cfoutput>
	<cfelse>
		<cfoutput><button id="b_readonly" class="action clickforaction">Read Only</button></cfoutput>
	</cfif>
</cfif>
<button id="b_notes"  class="action mediumButton" <cfif main.summary>disabled=disabled</cfif>>Notes</button>
<button id="b_export" class="action mediumButton">Export</button>
<button id="b_close" class="action mediumButton">Close</button>
<cfif not main.readonly>
	<button id="b_save" class="action">Save</button>
</cfif>
</span>
<span style="float:right" id="quarters">
<cfoutput>
	<button id="b_qtr1" class="action">1st Quarter</button>
	<button id="b_qtr2" class="action">2nd Quarter</button>
	<button id="b_qtr3" class="action">3rd Quarter</button>
	<button id="b_qtr4" class="action">4th Quarter</button>
	<button id="b_ytd"  class="action last">YTD / Annual</button>
</cfoutput>
</span>
</div>

<!----------------------------------------------Events for buttons -------------------------------------------------------->
<script type="text/javascript">
ok2unlock = 1;
buttonAction = function( $it, url ) {
	// ask users to save changes (if any)
	if ( $my.changes > 0 ) {
			$.prompt( "You have unsaved changes. Do you wish to save?", {
						buttons: { Save:true, Ignore:false }
						,callback: function(save, m, f){
												if ( save ) {
													if ( carryFutureMonthsIsValid() ) {
														$it.unbind('click').text('Saving...');
														$('#windowNewLocation').val( url );
														window.workbook.submit();
													}
											  }
											  else {
													$it.unbind('click').text('One moment...');
													window.location = url;
											  }
							        }
			});
	}
	else {
		<!---disable the click event--->
		$it.unbind('click').text('One moment...');
		window.location = url;
	}
}
/* this function carries forward values */
<cfoutput>
carryForward = function( toPeriodParam ) {
	var l = {};
	l.fromPeriod = toPeriodParam - 1;
	l.$updated = 0;
	$my.input_ty_vol[ toPeriodParam ].each( function() {
		// if previous period has % FC copy previous % FC when current period has prior year EQCs
    // otherwise just copy previous period EQCs ( wipe out current period % FC if it exists )
    var copiedPercent = 0
 	      , $toPeriodPercent = $(this).closest('tr').find('input.#class.ty_perc#_' + toPeriodParam);
    // this period has percentage input
    if ( $toPeriodPercent.length > 0 ) {
				// locate previous period percentage
				if ( toPeriodParam == 1 ) {
					l.carryValue = $toPeriodPercent.attr('priorMonth');
				}
				else {
					l.carryValue = $(this).closest('tr').find('input.#class.ty_perc#_' + l.fromPeriod).val();
				}
				// if previous period percentage exists copy it
				if ( l.carryValue ) {
    			copiedPercent = 1;
    			// flag the appropriate use_absolute element off
					$toPeriodPercent.closest('tr').find('input.#class.use_absolute#_' + toPeriodParam).val( 0 );
					// update this period percentage
    			$toPeriodPercent.val( l.carryValue ) ;
					++$my.changes;
					rowCalc( $toPeriodPercent );
					if ( l.$updated == 0 ) {
						l.$updated = $toPeriodPercent;
					}
				}
				else {
					// wipe out the current period percentage
					$toPeriodPercent.val( '' );
				}
    }

		if ( copiedPercent == 0 )	{
			// locate the prior month value
			<cfoutput>
			if ( toPeriodParam == 1 ) {
				// need to carry prior month value from previous quarter (not displayed on the screen)
				l.carryValue = $(this).attr('priorMonth');
			}
			else {
				// need to carry prior month value displayed on the screen
				l.carryValue = $(this).closest('tr').find('input.#class.ty_vol#_' + l.fromPeriod).val();
			}
			</cfoutput>
			if ( l.carryValue ) {
   			// flag the appropriate use_absolute element on
				$(this).closest('tr').find('input.#class.use_absolute#_' + toPeriodParam).val( 1 );
				// prior month value exists, copy it
				$(this).val( l.carryValue );
				++$my.changes;
				rowCalc( $(this) );
				if ( l.$updated == 0 ) {
					l.$updated = $(this);
				}
			}
		}
	});
	// update grand totals
	if ( l.$updated !== 0 ) {
		grandTotalCalc( l.$updated );
	}
}
</cfoutput>
var vfnotes = 0, vfexport = 0;
$('button').not('#pagemode').bind({
	<!---action links hovering--->
   mouseenter: function() { $(this).addClass("over"); }
  ,mouseleave: function() { $(this).removeClass("over"); }
	,click: function(e) {
			var l = {};
					l.thisID = $(this).prop('id');
			e.stopPropagation();
			<cfoutput>
			if ( l.thisID === 'b_edit') {
				buttonAction($(this), '#cgi.script_name#?r354=#const.editing#&#removeURLfields('r354')#');
			}
			else if ( l.thisID === 'b_readonly' ) {
				buttonAction($(this), '#cgi.script_name#?#removeURLfields('r354')#');
			}
			else if ( l.thisID === 'b_close' ) {
        window.close();
			}
			else if ( l.thisID === 'b_save' ) {
				var dataIsValid = true;
				// validate all numeric values (except mass update)
				$('input:text').each( function() {
					if (dataIsValid) {
						var it = $(this);
						// ignore mass update inputs
						if (! it.hasClass('#class.mass_update#')) {
							var str = $.Trim( it.val() );
							str = $.Replace(str, ',', '', 'all');
							// fail when it is not empty and it is not numeric
							if ( (str.length) && (! $.IsNumeric( str )) ) {
								dataIsValid = false;
							}
						}
					}
				});
				if (dataIsValid) {
					if ( carryFutureMonthsIsValid() ) {
						// disable the click event
						$(this).unbind('click').text('Please wait...');
						window.workbook.submit();
					}
				}
				else {
					alert("There were problems with the numeric input values, please correct.");
				}
			}

			else if ( l.thisID === 'b_qtr1' ) {
				<cfif url.q636 neq '1'>
					buttonAction($(this), '#cgi.script_name#?#vars.queryString#&q636=1');
				</cfif>
			}
			else if ( l.thisID === 'b_qtr2' ) {
				<cfif url.q636 neq '2'>
					buttonAction($(this), '#cgi.script_name#?#vars.queryString#&q636=2');
				</cfif>
			}
			else if ( l.thisID === 'b_qtr3' ) {
				<cfif url.q636 neq '3'>
					buttonAction($(this), '#cgi.script_name#?#vars.queryString#&q636=3');
				</cfif>
			}
			else if ( l.thisID === 'b_qtr4' ) {
				<cfif url.q636 neq '4'>
					buttonAction($(this), '#cgi.script_name#?#vars.queryString#&q636=4');
				</cfif>
			}

			// 35751 - added carry forward for 1st month
			else if ( l.thisID === 'b_carry_1' ) {
				carryForward( 1 );
			}
			else if ( l.thisID === 'b_carry_2' ) {
				carryForward( 2 );
			}
			else if ( l.thisID === 'b_carry_3' ) {
				carryForward( 3 );
			}

			else if ( l.thisID === 'b_ytd' ) {
       ok2unlock = 0;
				buttonAction($(this), 'vfytd.cfm?#vars.queryString#');
			}
			else if ( l.thisID === 'b_notes' ) {
       vfnotes = NewWindow('/common_files/volume/g500/vfnotes.cfm?l143=<cfoutput>#url.l143#&r354=#url.r354#&v451=#url.v451#</cfoutput>','vfnotes','870','620','Yes', 'No', 'yes', 'no');
			}
			else if ( l.thisID === 'b_export' ) {
       vfexport = NewWindow('/common_files/volume/g500/vfexport.cfm?l143=<cfoutput>#url.l143#&v451=#url.v451#</cfoutput>','vfexport','870','620','Yes', 'No', 'yes', 'no');
			}
			</cfoutput>
			return false;
	}
});
$.prompt.setDefaults( { opacity:'0', prefix:'jqi', top:'35%' } );
<cfif main.lockedByOther>
	<cfoutput>$.prompt( "Volume forecast is locked by #qLevel.lockedByUserName#.<br/>Please try to edit again later." );</cfoutput>
</cfif>

refreshColor = function() {

$('#tr_gtotal th,td').each(function(){
	var val = $(this).text().replace("$", "").replace("%24", "").replace(/\,/g,"").replace(/%2C/g,"").replace(/\%/g,"");
	var n = +val;
	//console.log(n);
  if (!isNaN(n) && /^\s*[+-]/.test(val)) {
    $(this).addClass(val >= 0 ? 'pos' : 'neg').removeClass(val >= 0 ? 'neg' : 'pos');
  }
});
}

refreshColor();

// close vf notes window on leaving
window.onunload = function() {
  if (vfnotes && !vfnotes.closed) {
      vfnotes.close();
  }
  if (vfexport && !vfexport.closed) {
      vfexport.close();
  }
};
</script>
</body>
</html>

