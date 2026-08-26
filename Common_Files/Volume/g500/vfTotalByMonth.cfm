<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<!---------------------------------------------------------------------------------------------------------------------
			Template: \Common_Files\Volume\g500\vfTotalByMonth.cfm
			Date:     Nov 5 2012
			Author:   Chris Nguyen
			Purpose:  GM Volume Forecast Total by months (3 months, 1 quater)

			Notes:    URL parameter names are soundex values so they are not obvious to users (more secure)

			Required Input:
											 1. url.q636: quarter number (numeric) valid values = 1, 2, 3 or 4
----------------------------------------------------------------------------------------------------------------------->
<html>
<cfparam name="url.user_position_id" default="all">  <!---if this is not blank filter VF detail in the same market/territory (vf_level.user_position_id)--->

<cfscript>
	const.volumeFormat = "-999,999,999";
	const.percentFormat = "-999.00";
	const.deltaPrefix  = "delta_";
	const.volumePrefix = "volume_";
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

	main.readonly      = true;     // read only indicator
	main.summary       = false;
	main.isDevSite     = 1;                                // TODO: change it to 0 prior to deployment
  application.oController.getObject(path="mvc.models.volumeforecast.vfmanager", name="vfmanager", bReload=main.isDevSite);

	// default to show only VF for current year
	if ( not structKeyExists(url, 'byClassIDs') ) {
	  main.currentClasses = application.oVfManager.getClasses( activeOnly=true, currentYearOnly=true );
		url.byClassIDs = valueList( main.currentClasses.vf_Class_ID );
	}
  main.classes = application.oVfManager.getClasses();

  main.qVFLevels = application.oVfManager.getCurrPositionAndBelowVF( byClassIDs=url.byClassIDs );
</cfscript>

<head>
	<cfinclude template="vfUDF.cfm">        <!---volume forecast functions library--->

	<link rel="stylesheet" type="text/css" href="workbook.css?v=2012-03-08">

	<style>
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
	.neg { color:green }
	.rolling { width:65px !important; text-align:right !important; }
	td { height:30px; }
	th { height:35px; }
	</cfoutput>
	</style>
</head>

<cfquery name="main.qPlanIDs" dbtype="query">
		SELECT DISTINCT vf_plan_id
			FROM main.qVFLevels
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->
<cfscript>
  // if quarter parameter is invalid change it to 1
  if ( not isNumeric(url.q636)
       or url.q636 lt 1
       or url.q636 gt 4) {
		url.q636 = 1;
  }
  main.vf_plan_ids = valueList(main.qPlanIDs.vf_plan_id);
	qProductPG       = application.oVfManager.getProductCategories( main.vf_plan_ids );
	qPeriod          = application.oVfManager.getPeriods( vf_id=main.vf_plan_ids, quarter=url.q636 );
  qLevel           = application.oVfManager.getLevels( vf_id=main.vf_plan_ids );
  qPositions       = application.oVfManager.getPositions( vf_id=main.vf_plan_ids );

  // if user position id parameter is invalid change it to 'all'
  if ( (url.user_position_id neq 'all')
  			and (listFindNocase(valueList(qPositions.user_position_id), url.user_position_id) eq 0) ) {
  	url.user_position_id = 'all';
  }

	if ( application.oVfManager.isHeadQuarters() ) {
		qForecast3Months = application.oVfManager.getDetail( vf_id=main.vf_plan_ids, level='', periods=ValueList(qPeriod.VF_Period_Id), user_position_id=url.user_position_id );
	}
	else {
		qForecast3Months = application.oVfManager.getDetail( vf_id=main.vf_plan_ids, level=valueList(qLevel.VF_Level_ID), periods=ValueList(qPeriod.VF_Period_Id), user_position_id=url.user_position_id );
	}

	const.working_year = Right(qLevel.Year_Selection, 2);
	const.ty_label     = "F" & const.working_year;         // working year column label
	const.ly_label     = "F" & (const.working_year - 1);   // previous year column label
	const.ybly_label   = "F" & (const.working_year - 2);   // year before previous year column label
</cfscript>
<!--------------------------------------------------------------------------------------------------------------------->
<!---
<cfmail to="cnguyen@bigredflame.com" from="cnguyen@bigredflame.com" subject="cfdump from #cgi.server_name#" type="html">
  <cfdump var="#main.qPlanIDs#" label="main.qPlanIDs" format="html" showudfs="false" metainfo="true" >
  <cfdump var="#qLevel#" label="qLevel" format="html" showudfs="false" metainfo="true" >
</cfmail>
--->

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
<cfset main.editIsAllowed = false>

<body style="overflow:hidden;margin:0px; display:block;">
<cfoutput>
<div id="pagetitle" style="padding-bottom:6px;">
	<cfset selectedPosition = 'All'>
	<span style="position:relative; top:15px;"> Volume Forecast Total For
	<select name="byClassIDs" id="byClassIDs">
		<cfloop query="main.classes">
			<option <cfif url.byClassIDs eq "" or listFindNoCase(url.byClassIDs, main.classes.vf_class_id)>selected=selected</cfif> value="#main.classes.vf_class_id#">#main.classes.vf_class_number# - #main.classes.vf_class_desc#</option>
		</cfloop>
	</select>

	<cfif qPositions.recordCount>
  	Position
  	<select id="marketslist">
			<option <cfif url.user_position_id eq "all">selected="selected"</cfif> value="all">All</option>
			<cfloop query="qPositions">
				<option <cfif url.user_position_id eq qPositions.User_Position_Id>selected="selected"</cfif> value="#qPositions.User_Position_Id#">#trim( qPositions.Position_Label )#</option>
				<cfif url.user_position_id eq qPositions.User_Position_Id>
					<cfset selectedPosition = qPositions.Position_Label>
				</cfif>
			</cfloop>
		</select>
	</cfif>
	#QuarterName(url.q636)#
	&nbsp;<button id="refresh" style="visibility:hidden;">Refresh</button>
	</span>
</div>
<cfhtmlhead text="<title>Volume Forecast Total For #selectedPosition#</title>">
<div id="pageinfo">
</div>
</cfoutput>
<form name="workbook" id="workbookform" method="post" <cfoutput>action="#cgi.script_name#?#cgi.query_string#"</cfoutput>>
<input name="windowNewLocation" id="windowNewLocation" type="hidden">
<div id="tbl-container" onscroll="keepHeaderFixed(this.scrollTop-1,scrollLeft);">

	<table class="tbl" style="TOP:0px;" id="vftable" cellspacing="0">

<!------------------------------------------------------- COLUMN HEADERS ---------------------------------------------------------->
		<thead id="tbl_head">
			<tr id="tr_period">
				<th class="locked stay headerTopAndLeft" name="bufferTD">&nbsp;</th>
				<!---02a---><th class="locked rolling stay headerTopAndLeft">&nbsp;</th>    <!--- 52 wk abs   --->
				<!---02b---><th class="locked rolling stay headerTopAndLeft">&nbsp;</th>    <!--- 52 wk trend --->
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
						<!---04---><th class="header2 colhdr_edit headerTop"><cfif qPeriod.currentRow eq 1 or main.readonly or xPeriod.Became_Actual>&nbsp;<cfelse><button id=<cfoutput>"b_carry_#qPeriod.currentRow#"</cfoutput> class="carry">Carry Forward<br/>Prior Month</button></cfif></th>
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
				<!---02a---><th class="locked rolling stay headerTopAndLeft" style="text-align:center !important;">52 WK ABS</th>      <!--- 52 wk abs   --->
				<!---02b---><th class="locked rolling stay headerTopAndLeft" style="text-align:center !important;">52 WK TREND</th>    <!--- 52 wk trend --->
				<!---Column Headers for a month--->
					<cfloop query="qPeriod">
						<cfif qPeriod.Became_Actual>
							<!---display actual values--->
							<!---01---> <th class="acthdr headerTop">#const.ty_label# ACT EQCs</th>                          <!---actual volume--->
							<!---02---> <th class="acthdr bcolor2 headerTop">ACT +/- #const.ly_label# EQCs</th>              <!---delta between actual & last year--->
							<!---03---> <th class="acthdr bcolor2 headerTop">ACT %<br/>+/- #const.ly_label#</th>             <!---delta % between actual & last year--->
							<!---04---> <th class="acthdr headerTop">ACT +/- FC EQCs</th>                                    <!---delta between actual & forecast--->
							<!---05---> <th class="acthdr headerTop">ACT %<br/>+/- FC</th>                                   <!---delta % between actual & forecast--->
							<!---06---> <th class="acthdr bcolor2 headerTop">ACT +/- PGM</th>                                <!---delta between actual & program--->
							<!---07---> <th class="acthdr bcolor2 headerTop">ACT %<br/>+/- PGM</th>                          <!---delta % between actual & program--->
						<cfelse>
							<!---display forecast values--->
							<!---01---> <th class="headerTop">#const.ly_label# EQCs</th>
							<!---02---> <th class="headerTop">#const.ly_label# %<br/>+/- #const.ybly_label#</th>
							<!---03---> <th class="editable headerTop">#const.ty_label# FC (Enter % +/- #const.ly_label#)<cfif not main.readonly><br/><input type="text" class="#class.mass_update#" id="#class.ty_perc#_#qPeriod.CurrentRow#" value="mass update" style="width:88%">%</cfif></th>
							<!---04---> <th class="editable headerTop">#const.ty_label# Forecast EQCs<!---<cfif not main.readonly><br/><input type="text" class="#class.mass_update#" id="#class.ty_vol#_#qPeriod.CurrentRow#" value="mass update" style="width:100%"></cfif>---></th>
							<!---05---> <th class="headerTop">FC +/- #const.ly_label# EQCs</th>
							<!---06---> <th class="headerTop">FC %<br/>+/- #const.ly_label#</th>
							<!---07---> <th class="headerTop">#const.ty_label# PGM</th>
							<!---08---> <th class="headerTop">FC +/- PGM</th>
							<!---09---> <th class="headerTop">FC %<br/>+/- PGM</th>
							<!---<!---10---> <th class="headerTop">#const.ybly_label# EQCs</th>--->
						</cfif>
						<th class="divider" class="headerTop">&nbsp;</th>
					</cfloop>

				<!---QUARTER Column Headers--->
				<cfif qBecameActual.recordCount eq 3>
					<!---display actual values--->
					<!---01---> <th class="acthdr headerTop">#const.ty_label# ACT EQCs</th>                          <!---actual volume--->
					<!---02---> <th class="acthdr bcolor2 headerTop">ACT +/- #const.ly_label# EQCs</th>              <!---delta between actual & last year--->
					<!---03---> <th class="acthdr bcolor2 headerTop">ACT %<br/>+/- #const.ly_label#</th>             <!---delta % between actual & last year--->
					<!---04---> <th class="acthdr headerTop">ACT +/- FC EQCs</th>                                    <!---delta between actual & forecast--->
					<!---05---> <th class="acthdr headerTop">ACT %<br/>+/- FC</th>                                   <!---delta % between actual & forecast--->
					<!---06---> <th class="acthdr bcolor2 headerTop">ACT +/- PGM</th>                                <!---delta between actual & program--->
					<!---07---> <th class="acthdr bcolor2 headerTop">ACT %<br/>+/- PGM</th>                          <!---delta % between actual & program--->
				<cfelse>
					<!---01---> <th class="headerTop">#const.ly_label# EQCs</th>
					<!---02---> <th class="headerTop">#const.ly_label# %<br/>+/- #const.ybly_label#</th>
					<!---03---> <!---<th class="headerTop">#const.ty_label# FC (Enter % +/- #const.ly_label#)</th>--->
					<!---04---> <th class="headerTop">#const.ty_label# Forecast EQCs</th>
					<!---05---> <th class="headerTop">FC +/- #const.ly_label# EQCs</th>
					<!---06---> <th class="headerTop">FC %<br/>+/- #const.ly_label#</th>
					<!---07---> <th class="headerTop">#const.ty_label# PGM</th>
					<!---08---> <th class="headerTop">FC +/- PGM</th>
					<!---09---> <th class="headerTop">FC %<br/>+/- PGM</th>
					<!---<!---10---> <th class="headerTop">#const.ybly_label# EQCs</th>--->
				</cfif>
			</tr>

<!------------------------------------------------------- GRAND TOTAL ------------------------------------------------------------->
			<tr id="tr_gtotal">
				<th class="locked stay headerTopAndLeft" name="bufferTD">GRAND TOTAL</th>

				<cfset display_rolling_52 = true>
				<!---Column Headers for a month--->
				<cfloop query="qPeriod">
					<cfquery name="qSubtotals" dbtype="query">
						 SELECT  SUM(ly_Volume) AS sum_ly_Volume             <!---last year amount--->
									 , SUM(ty_volume) AS sum_ty_Volume              <!---forecast amount--->
									 , SUM(ty_pgm) AS sum_ty_pgm                    <!---program amount--->
									 , SUM(ybly_Volume) AS sum_ybly_Volume          <!---year before last year amount--->
									 , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
									 , SUM(rolling_52) AS sum_rolling_52
									 , SUM(rolling_prev_52) AS sum_rolling_prev_52
							 FROM qForecast3Months
							WHERE VF_Period_Id = <cfqueryparam value="#qPeriod.VF_Period_Id#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif display_rolling_52>
						<cfset display_rolling_52 = false>
<!---
						<!---02a---><th class="locked rolling headerTopAndLeft">#NumberFormat(qSubtotals.sum_rolling_52, const.volumeFormat)# </th>          <!--- 52 wk abs   --->
						<!---02b---><th class="locked rolling headerTopAndLeft">#trendValue(ty=qSubtotals.sum_rolling_52, ly=qSubtotals.sum_rolling_prev_52)# </th>   <!--- 52 wk trend --->
--->
						<!---02a--->#displayCell( class="locked stay rolling headerTopAndLeft", value=NumberFormat(qSubtotals.sum_rolling_52, const.volumeFormat), tag="th" )#                         <!--- 52 wk abs   --->
						<!---02b--->#displayCell( class="locked stay rolling headerTopAndLeft", value=trendValue(ty=qSubtotals.sum_rolling_52, ly=qSubtotals.sum_rolling_prev_52), tag="th" )# </th>   <!--- 52 wk trend --->
					</cfif>

					<cfif qPeriod.Became_Actual>
						<!---01---> #displayCell( class="headerTop", value=NumberFormat(qSubtotals.sum_actual_Volume, const.volumeFormat), tag="th" )#                                            <!---actual volume--->
						<!---02---> #displayCell( class="bcolor2 headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_volume, percentage=0), tag="th" )#   <!---delta between actual & last year--->
						<!---03---> #displayCell( class="bcolor2 headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_volume, percentage=1), tag="th" )#   <!---delta % between actual & last year--->
						<!---04---> #displayCell( class="headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_volume, percentage=0), tag="th" )#                    <!---delta between actual & forecast--->
						<!---05---> #displayCell( class="headerTop",  value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_volume, percentage=1), tag="th" )#                    <!---delta % between actual & forecast--->
						<!---06---> #displayCell( class="bcolor2 headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=0), tag="th" )#   <!---delta between actual & program--->
						<!---07---> #displayCell( class="bcolor2 headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=1), tag="th" )#   <!---delta % between actual & program--->
					<cfelse>
						<!---Grand total ID template = g_<column_class_name>_<period_row_number>--->
						<!---Grand total ID examples = g_ly_vol_1, g_ly_vol_2, g_ly_vol_3--->

						<!---01---> #displayCell( class="headerTop", value=NumberFormat(qSubtotals.sum_ly_Volume, const.volumeFormat), tag="th" )#
						<!---02---> #displayCell( class="headerTop", value=deltaValue(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1), tag="th" )#
						<!---03---> #displayCell( class="bcolor2 headerTop", value=deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1), tag="th" )#
						<!---04---> #displayCell( class="bcolor2 headerTop", value=NumberFormat(qSubtotals.sum_ty_Volume, const.volumeFormat), tag="th" )#
						<!---05---> #displayCell( class="headerTop", value=deltaValue(ty=qSubtotals.sum_ty_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0), tag="th" )#
						<!---06---> #displayCell( class="headerTop", value=deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1), tag="th" )#
						<!---07---> #displayCell( class="headerTop", value=NumberFormat(qSubtotals.sum_ty_pgm, const.volumeFormat), tag="th" )#
						<!---08---> #displayCell( class="headerTop", value=deltaValue(ty=qSubtotals.sum_ty_Volume, ly=qSubtotals.sum_ty_pgm, percentage=0), tag="th" )#
						<!---09---> #displayCell( class="headerTop", value=deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1), tag="th" )#
					</cfif>
												<th class="divider headerTop">&nbsp;</th>
				</cfloop>

				<cfquery name="qSubtotals" dbtype="query">
						 SELECT  SUM(ly_Volume) AS sum_ly_Volume
									 , SUM(ty_Volume) AS sum_ty_Volume
									 , SUM(ty_pgm) AS sum_ty_pgm
									 , SUM(ybly_Volume) AS sum_ybly_Volume
									 , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
						 FROM qForecast3Months
				</cfquery>

				<!---QUARTER Column Headers--->
				<!---Quarter ID template = q_<column_class_name>--->
				<!---Quarter ID examples = q_ly_vol, g_ly_vol, g_ly_vol--->
				<cfif qBecameActual.recordCount eq 3>
					<!---display actual values--->
					<!---01---> #displayCell( class="headerTop", value=NumberFormat(qSubtotals.sum_actual_Volume,const.volumeFormat), tag="th" )#                                              <!---actual volume--->
					<!---02---> #displayCell( class="bcolor2 headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0), tag="th" )#    <!---delta between actual & last year--->
					<!---03---> #displayCell( class="bcolor2 headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1), tag="th" )#    <!---delta % between actual & last year--->
					<!---04---> #displayCell( class="headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_Volume, percentage=0), tag="th" )#                     <!---delta between actual & forecast--->
					<!---05---> #displayCell( class="headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1), tag="th" )#                     <!---delta % between actual & forecast--->
					<!---06---> #displayCell( class="bcolor2 headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=0), tag="th" )#    <!---delta between actual & program--->
					<!---07---> #displayCell( class="bcolor2 headerTop", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=1), tag="th" )#    <!---delta % between actual & program--->
				<cfelse>
					<!---01---> #displayCell( class="headerTop", value=NumberFormat(qSubtotals.sum_ly_Volume,const.volumeFormat), tag="th" )#
					<!---02---> #displayCell( class="headerTop", value=deltaValue(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1), tag="th" )#

					<!---tue 2012/feb/21: Paul changed FC forecast EQC column to be sum of actual volume (months in the past) + sum of forecast (current & future months)--->
					<cfquery name="qFCSubtotals" dbtype="query">
							 SELECT  SUM(ly_Volume) AS sum_ly_Volume
										 , SUM(ty_Volume) AS sum_ty_Volume
										 , SUM(ty_pgm) AS sum_ty_pgm
										 , SUM(ybly_Volume) AS sum_ybly_Volume
										 , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
							 FROM qForecast3Months
							 WHERE Became_Actual = 0
					</cfquery>
					<cfquery name="qACTSubtotals" dbtype="query">
							 SELECT  SUM(ly_Volume) AS sum_ly_Volume
										 , SUM(ty_Volume) AS sum_ty_Volume
										 , SUM(ty_pgm) AS sum_ty_pgm
										 , SUM(ybly_Volume) AS sum_ybly_Volume
										 , SUM(actual_volume) AS sum_actual_Volume      <!---actual amount--->
							 FROM qForecast3Months
							 WHERE Became_Actual = 1
					</cfquery>

					<cfset quarter = structnew()>
					<cfset quarter.sum_ty_volume = val(qFCSubtotals.sum_ty_Volume) + val(qACTSubtotals.sum_actual_Volume)>

					<!---04---> #displayCell( class="headerTop", value=NumberFormat(quarter.sum_ty_volume, const.volumeFormat), tag="th" )#

					<!---05---> #displayCell( class="headerTop", value=deltaValue(ty=quarter.sum_ty_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0), tag="th" )#
					<!---06---> #displayCell( class="headerTop", value=deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1), tag="th" )#
					<!---07---> #displayCell( class="headerTop", value=NumberFormat(qSubtotals.sum_ty_pgm,const.volumeFormat), tag="th" )#
					<!---08---> #displayCell( class="headerTop", value=deltaValue(ty=quarter.sum_ty_Volume, ly=qSubtotals.sum_ty_pgm, percentage=0), tag="th" )#
					<!---09---> #displayCell( class="headerTop", value=deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1), tag="th" )#
				</cfif>
			</tr>
			</cfoutput>

		</thead>

<!---------------------------------------------------------- TBODY ---------------------------------------------------------------->
		<tbody id="tbl_body">
		<cfsetting enablecfoutputonly="true">
		<cfloop query="qProductPG">
			<cfoutput><tr <cfif (qProductPG.currentRow mod 2) neq 0>style="background-color:##FFDEAD"</cfif>></cfoutput>
				<cfoutput>
					<td nowrap class="locked headerLeft" style="height:35px;"><cfif not main.readonly><input type="checkbox" name="cb_#pg_Product_Category_Id#" class="cb">&nbsp;</cfif>#qProductPG.pg_Product_Category_Name#</td>
				</cfoutput>

				<cfset display_rolling_52 = true>
				<!---Data for a month--->
				<cfloop query="qPeriod">
					<cfquery name="qForecastMonth" dbtype="query">
			 			<!--- combine multiple records from different levels into one summary record --->
			 			SELECT   SUM(Actual_Volume) AS Actual_Volume
			        		 , 0                  AS Became_Actual
			        		 , 0                  AS Ly_Delta_Percentage
			        		 , SUM(Ly_Volume)     AS Ly_Volume
			        		 , SUM(Rolling_52)    AS Rolling_52
			        		 , SUM(Rolling_Prev_52) AS Rolling_Prev_52
			        		 , 0                    AS Ty_Delta_Percentage
			        		 , SUM(Ty_PGM)          AS Ty_PGM
			        		 , 0                  AS Ty_PGM_Forecast_Delta
			        		 , 0                  AS Ty_PGM_Forecast_Delta_Percentage
			        		 , SUM(Ty_Volume)     AS Ty_Volume
			        		 , 0                  AS VF_Detail_ID
			        		 , <cfoutput>#qPeriod.VF_Period_Id#</cfoutput> AS VF_Period_ID
			        		 , SUM(Ybly_Volume)   AS Ybly_Volume
						 FROM qForecast3Months
						WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
							AND VF_Period_Id = <cfqueryparam value="#qPeriod.VF_Period_Id#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif display_rolling_52>
						<cfset display_rolling_52 = false>
						<cfset trend_52 = trendValue(ty=qForecastMonth.Rolling_52, ly=qForecastMonth.Rolling_Prev_52)>

						<!---02a---><cfoutput>#displayCell( class="locked rolling headerLeft", value=volumeFormat(qForecastMonth.Rolling_52) )#</cfoutput>              <!--- 52 wk abs   --->
						<!---02b---><cfoutput>#displayCell( class="locked rolling headerLeft", value=trend_52 )#</cfoutput>                                             <!--- 52 wk trend --->
					</cfif>

					<!---Body cell class template = <column_class_name>_<period_row_number>--->
					<!---Body cell class examples = ly_vol_1, ly_vol_2, ly_vol_3--->

					<!---enable percentage input when last year volume exist--->
					<cfset main.percentInputEnabled = false>

					<cfif not main.percentInputEnabled>                       <!---percentage input is off--->
						<cfset main.ty_vol = qForecastMonth.ty_Volume>
					<cfelseif val(qForecastMonth.ly_Volume) neq 0 <!--- and val(qForecastMonth.ty_Delta_Percentage) neq 0 --->>       <!---calculate this year volume based on last year volume and delta %--->
						<cfset main.ty_vol = (qForecastMonth.ly_Volume * ( 1 + (val(qForecastMonth.ty_Delta_Percentage) / 100) ))>
					<cfelse>
						<cfset main.ty_vol = "">                <!---missing values, can't calculate this year volume--->
					</cfif>

					<cfif qPeriod.Became_Actual>
						<!---01---> <cfoutput>#displayCell( value=volumeFormat(amt=qForecastMonth.actual_Volume, nullForZero=false) )#</cfoutput>                                         <!---actual volume--->
						<!---02---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ly_volume, percentage=0) )#</cfoutput>   <!---delta between actual & last year--->
						<!---03---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ly_volume, percentage=1) )#</cfoutput>   <!---delta % between actual & last year--->
						<!---04---> <cfoutput>#displayCell( value=deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_volume, percentage=0) )#</cfoutput>                    <!---delta between actual & forecast--->
						<!---05---> <cfoutput>#displayCell( value=deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_volume, percentage=1) )#</cfoutput>                    <!---delta % between actual & forecast--->
						<!---06---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_pgm, percentage=0) )#</cfoutput>      <!---delta between actual & program--->
						<!---07---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qForecastMonth.actual_Volume, ly=qForecastMonth.ty_pgm, percentage=1) )#</cfoutput>      <!---delta % between actual & program--->
					<cfelse>
					  <!---display forecast values normally--->
						<cfset td = "td">
						<!---01---> <cfoutput>#displayCell( value=volumeFormat(qForecastMonth.ly_Volume) )#</cfoutput>
						<!---02---> <cfif val(qForecastMonth.ybly_volume) eq 0 or val(qForecastMonth.ly_volume) eq 0>
													<cfoutput>#displayCell( value="&nbsp;" )#</cfoutput>
												<cfelse>
													<cfoutput>#displayCell( value=deltaValue(ty = qForecastMonth.ly_volume, ly = qForecastMonth.ybly_volume, percentage=1) )#</cfoutput>
												</cfif>

						<!---03---> <cfoutput>#displayCell( class="bcolor2", value=volumeFormat(amt=qForecastMonth.ty_Delta_Percentage, percentage=1) )#</cfoutput>

						<!---04---> <!---display blank (not zero) when ty_volume equals to zero or ty_percentage equals to zero--->
						<!---04---> <cfif val(qForecastMonth.ty_Volume) eq 0>
													<cfoutput>#displayCell( class="bcolor2", value="&nbsp;" )#</cfoutput>
												<cfelse>
													<cfoutput>#displayCell( class="bcolor2", value=Trim(NumberFormat(qForecastMonth.ty_Volume,const.volumeFormat)) )#</cfoutput>
												</cfif>

						<!---05---> <!---display blank when ly_vol = 0 or ty_vol = 0--->
						<!---05---> <cfif val(main.ty_vol) eq 0>
													<cfoutput>#displayCell( value="&nbsp;" )#</cfoutput>
												<cfelse>
													<cfoutput>#displayCell( value=NumberFormat(main.ty_vol - val(qForecastMonth.ly_Volume), const.volumeFormat) )#</cfoutput>
												</cfif>

						<!---06---> <!---display blank when ty_volume = 0 or ly_volume = 0--->
						<!---06---> <cfset main.ty_Delta_Percentage = deltaValue(ty = main.ty_vol, ly = qForecastMonth.ly_Volume, percentage=1)>
						<!---06---> <cfif val(main.ty_vol) eq 0 or val(qForecastMonth.ly_Volume) eq 0>
													<cfoutput>#displayCell( value="&nbsp;" )#</cfoutput>
												<cfelse>
													<cfoutput>#displayCell( value=main.ty_Delta_Percentage )#</cfoutput>
												</cfif>

						<!---07---> <cfoutput>#displayCell( value=qForecastMonth.ty_PGM )#</cfoutput>

						<!---08---> <!---display blank when ty_vol = 0 or column #07 = 0--->
						<!---08---> <cfif val(main.ty_vol) eq 0>
													<cfoutput>#displayCell( value="&nbsp;" )#</cfoutput>
												<cfelse>
													<cfoutput>#displayCell( value=NumberFormat(main.ty_vol - val(qForecastMonth.ty_pgm), const.volumeFormat) )#</cfoutput>
												</cfif>
						<!---09---> <cfif val(main.ty_vol) eq 0 or qForecastMonth.ty_PGM eq 0>
													<cfoutput>#displayCell( value="&nbsp;" )#</cfoutput>
												<cfelse>
													<cfoutput>#displayCell( value=deltaValue(ty = main.ty_vol, ly = qForecastMonth.ty_pgm, percentage=1) )#</cfoutput>
												</cfif>
					</cfif>   <!--- qPeriod.Became_Actual --->

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
					<!---01---> <cfoutput>#displayCell( value=NumberFormat(qSubtotals.sum_actual_Volume,const.volumeFormat) )#</cfoutput>                                             <!---actual volume--->
					<!---02---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=0) )#</cfoutput>   <!---delta between actual & last year--->
					<!---03---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1) )#</cfoutput>   <!---delta % between actual & last year--->
					<!---04---> <cfoutput>#displayCell( value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_Volume, percentage=0) )#</cfoutput>                    <!---delta between actual & forecast--->
					<!---05---> <cfoutput>#displayCell( value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ly_Volume, percentage=1) )#</cfoutput>                    <!---delta % between actual & forecast--->
					<!---06---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=0) )#</cfoutput>   <!---delta between actual & program--->
					<!---07---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qSubtotals.sum_actual_Volume, ly=qSubtotals.sum_ty_pgm,    percentage=1) )#</cfoutput>   <!---delta % between actual & program--->
				<cfelse>
					<!---01---> <cfoutput>#displayCell( class=class.ly_vol, value=NumberFormat(qSubtotals.sum_ly_Volume,const.volumeFormat) )#</cfoutput>
					<!---02---> <cfoutput>#displayCell( class=class.ly_perc, value=deltaValue(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1) )# </cfoutput>

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

					<!---04---> <cfoutput>#displayCell( class=class.ty_vol, value=NumberFormat(quarter.sum_ty_Volume,const.volumeFormat) )#</cfoutput>
					<!---05---> <cfoutput>#displayCell( class=class.delta_vol, value=deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=0) )#</cfoutput>
					<!---06---> <cfoutput>#displayCell( class=class.delta_perc, value=deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1) )#</cfoutput>
					<!---07---> <cfoutput>#displayCell( class=class.pgm_ny, value=NumberFormat(qSubtotals.sum_ty_pgm,const.volumeFormat) )#</cfoutput>
					<!---08---> <cfoutput>#displayCell( class=class.pgm_delta_amt, value=deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=0) )#</cfoutput>
					<!---09---> <cfoutput>#displayCell( class=class.pgm_delta_perc, value=deltaValue(ty=quarter.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1) )#</cfoutput>
				</cfif>
			<cfoutput></tr></cfoutput>
		</cfloop>
		<cfsetting enablecfoutputonly="false">
		</tbody>
	</table>
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

<cffunction name="displayCell" output="true">
	<cfargument name="class" required="false" default="">
	<cfargument name="value" required="true">
	<cfargument name="tag" required="false" default="td">

	<cfset arguments.class = trim(arguments.class)>

	<!--- remove blank spaces, $, commas, % --->
	<cfif val( reReplace( arguments.value, "[$%, ]", "", "all" ) )  lt 0>
		<cfset arguments.class = arguments.class & (arguments.class eq "" ? "" : " ") & 'neg'>
	</cfif>

	<cfoutput><#tag# <cfif len(arguments.class)>class="#arguments.class#"</cfif>>#trim(arguments.value)#</#tag#></cfoutput>
</cffunction>

<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->
<cfset jQueryUI.version = "1.8.23" />
<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/table2csv.js?foo"></script>

<script type="text/javascript">
window.moveTo(0,0);
// reduce the table height to allow room for buttons
$('#tbl-container').css("height", screen.availHeight - 195);
window.resizeTo( screen.availWidth, screen.availHeight );
$('#tbl-container').show();
</script>

<!----------------------------------------------FOOTER BUTTONS--------------------------------------------------------->
<div style="margin:0px 20px;" id="div_actions">
<span style="float:left">
<button id="b_close" class="action">Close</button>
<button id="b_excel" class="action">Export</button>
</span>
<span style="float:right" id="quarters">
<cfoutput>
	<button id="b_qtr1" class="action">1st Quarter</button>
	<button id="b_qtr2" class="action">2nd Quarter</button>
	<button id="b_qtr3" class="action">3rd Quarter</button>
	<button id="b_qtr4" class="action">4th Quarter</button>
	<button id="b_ytd"  class="action last">YTD / Annual</button>
<form action="/common_files/csv.cfm" method ="post" id="csv_form">
<input type="hidden" name="csv_text" id="csv_text">
<input type="hidden" name="csv_file_name" id="csv_file_name">
</form>
</cfoutput>
</span>
</div>


<script type="text/javascript">
$(function() {
	buttonAction = function( $it, url ) {
		<!---disable the click event--->
		$it.unbind('click').text('One moment...');
		window.location = url;
	}

	<!----------------------------------------------getCSVData() function------------------------------------------------------>
	getCSVData = function() {
	 var csv_value=$('#vftable').table2CSV({delivery:'value'});
	 $("#csv_text").val(csv_value);
	 $("#csv_file_name").val( $('title').text() + ' ' + $.datepicker.formatDate('mm-dd-yy', new Date()) + '.csv' );
	 $("#csv_form").submit();
	}

	<!----------------------------------------------refreshULR() function------------------------------------------------------>
	refreshURL = function() {
		return <cfoutput>'#cgi.script_name#'</cfoutput>
		       + '?byClassIDs=' + $('#byClassIDs').val()
		       + '&user_position_id=' + $('#marketslist').val();
	}

	<!----------------------------------------------Events for buttons--------------------------------------------------------->
	$('button').not('#pagemode').bind({
		<!---action links hovering--->
	   mouseenter: function() { $(this).addClass("over"); }
	  ,mouseleave: function() { $(this).removeClass("over"); }
		,click: function(e) {
				var l = {};
						l.thisID = $(this).prop('id');
				e.stopPropagation();
				<cfoutput>
				if ( l.thisID === 'b_close' ) {
	        window.close();
				}
				else if ( l.thisID === 'b_excel' ) {
					 getCSVData();
				}
				else if ( l.thisID === 'b_qtr1' ) {
					<cfif url.q636 neq '1'>
						buttonAction($(this), refreshURL() + '&q636=1');
					</cfif>
				}
				else if ( l.thisID === 'b_qtr2' ) {
					<cfif url.q636 neq '2'>
						buttonAction($(this), refreshURL() + '&q636=2');
					</cfif>
				}
				else if ( l.thisID === 'b_qtr3' ) {
					<cfif url.q636 neq '3'>
						buttonAction($(this), refreshURL() + '&q636=3');
					</cfif>
				}
				else if ( l.thisID === 'b_qtr4' ) {
					<cfif url.q636 neq '4'>
						buttonAction($(this), refreshURL() + '&q636=4');
					</cfif>
				}
				else if ( l.thisID === 'b_ytd' ) {
					buttonAction($(this), 'vfTotalByYear.cfm?user_position_id=#url.user_position_id#&byClassIDs=' + $('##byClassIDs').val() );
				}
				</cfoutput>
				return false;
		}
	});

	<!----------------------------------------------Events for refresh button-------------------------------------------------->
	$('#refresh').click(function() {
		$(this).unbind('click').text('One moment...');
		$('#tbl-container, #div_actions').hide( 700 );
		window.location = refreshURL() + <cfoutput>'&q636=#url.q636#'</cfoutput>;
	});

	<!----------------------------------------------Events for year & position------------------------------------------------->
	$('#byClassIDs, #marketslist').change( function() {
		$('#refresh').css("visibility","visible");
	});
});
</script>
<script type="text/javascript" src="/Script/javascript/scrollHeader.js"></script>
</body>
</html>

