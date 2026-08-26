<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<!---------------------------------------------------------------------------------------------------------------------
			Template: \Common_Files\Volume\g500\vfTotalByYear.cfm
			Date:     Nov 6, 2012
			Author:   Chris Nguyen
			Purpose:  GM YTD/Annual Volume Forecast Total
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
	//class.ly_vol       = 'ly_vol';
	//class.ly_perc      = 'ly_perc';
	//class.ty_vol       = 'ty_vol';
	//class.ty_perc      = 'ty_perc';
	//class.delta_vol    = 'delta_vol';
	//class.delta_perc   = 'delta_perc';
	//class.pgm_ny       = 'pgm_ny';
	//class.pgm_delta_amt  = 'pgm_delta_amt';
	//class.pgm_delta_perc = 'pgm_delta_perc';
	//class.ybly_vol     = 'ybly_vol';
	//class.input_amt    = 'i_amt';
	//class.input_perc   = 'i_perc';
	//class.mass_update  = 'massupdate';

	main.isDevSite     = 1;
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
	<link rel="stylesheet" type="text/css" href="workbook.css?v=2011-10-24">

	<style>
	<cfoutput>
	.ty { background-color:##A5BAFF; }
	.delta { color:blue; font-weight:bold; }
	.inactive { background-color:white; font-weight:normal; color:gray; }
	##pagetitle { background-color:##4169E1; color:white; font-size:17px; font-weight:bold; height:50px; margin:0; text-align:center; vertical-align:middle; width:100%; padding-top:3px;}
	</cfoutput>
	.bcolor2 { background-color:#A5BAFF; }
	.hdr1{width:80px;padding:4px;}
	.pos { color:black; }
	.neg { color:green; }
	td { height:30px; }
	th { height:35px; }
	</style>
</head>

<cfquery name="main.qPlanIDs" dbtype="query">
		SELECT DISTINCT vf_plan_id
			FROM main.qVFLevels
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->
<cfscript>
	main.vf_plan_ids = valueList(main.qPlanIDs.vf_plan_id);
	qProductPG       = application.oVfManager.getProductCategories( main.vf_plan_ids );
	qLevel           = application.oVfManager.getLevels( vf_id=main.vf_plan_ids );
  qPositions       = application.oVfManager.getPositions( vf_id=main.vf_plan_ids );

  // if user position id parameter is invalid change it to 'all'
  if ( (url.user_position_id neq 'all') 
  			and (listFindNocase(valueList(qPositions.user_position_id), url.user_position_id) eq 0) ) {
  	url.user_position_id = 'all';
  }
  
	if ( application.oVfManager.isHeadQuarters() ) {
		qForecastDetail  = application.oVfManager.getDetail( vf_id=main.vf_plan_ids, level='', user_position_id=url.user_position_id );
	}
	else {
		qForecastDetail  = application.oVfManager.getDetail( vf_id=main.vf_plan_ids, level=valueList(qLevel.VF_Level_ID), user_position_id=url.user_position_id );
	}
	
	qActualPeriods  = application.oVfManager.getPeriodsbyStatus( vf_id=main.vf_plan_ids, actual=1 );
	qToGoPeriods    = application.oVfManager.getPeriodsbyStatus( vf_id=main.vf_plan_ids, actual=0 );

	const.working_year = Right(qLevel.Year_Selection, 2);                               
	const.ty_label     = "F" & const.working_year;         // working year column label
	const.ly_label     = "F" & (const.working_year - 1);   // previous year column label
	const.ybly_label   = "F" & (const.working_year - 2);   // year before previous year column label
</cfscript>
<!--- 
<cfmail to="cnguyen@bigredflame.com" from="cnguyen@bigredflame.com" subject="cfdump from #cgi.server_name# vf by year" type="html"> 
  <cfdump var="#qForecastDetail#" label="qForecastDetail" format="html" showudfs="false" metainfo="true" > 
</cfmail>
 --->
<!--------------------------------------------------------------------------------------------------------------------->

<body style="overflow:hidden;margin:0px; display:block;">
<cfset vars.queryString = "">
<cfoutput>
<div id="pagetitle" style="padding-bottom:6px;">
	<cfset selectedPosition = 'All'>
	<span style="position:relative; top:15px;"> Volume Forecast Total - YTD / Annual For 

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
	
	&nbsp;<button id="refresh" style="visibility:hidden;">Refresh</button>
	</span>
</div>
</cfoutput>
<div id="pageinfo">
</div>
<cfhtmlhead text="<title>Volume Forecast Total YTD Annual For #selectedPosition#</title>">
<form name="workbook" id="workbookform" method="post" <cfoutput>action="#cgi.script_name#?#cgi.query_string#"</cfoutput>>
<input name="windowNewLocation" id="windowNewLocation" type="hidden">
<div id="tbl-container" onscroll="keepHeaderFixed(this.scrollTop-1,scrollLeft);">

	<table class="tbl" style="margin-top:50px;margin:auto;" id="vftable" cellspacing="0">

<!------------------------------------------------------- COLUMN HEADERS ---------------------------------------------------------->
		<thead id="tbl_head">
			<tr id="tr_period">
				<th class="locked stay headerTopAndLeft" name="bufferTD">&nbsp;</th>

				<th class="header2 hdr1 headerTop">&nbsp;</th>
				<th class="header2 hdr1 headerTop">&nbsp;</th>
				<th class="header2 hdr1 headerTop">Actual</th>
				<th class="header2 hdr1 headerTop">&nbsp;</th>
				<th class="header2 header3 hdr1 headerTop">&nbsp;</th>
				<th class="divider headerTop">&nbsp;</th>

				<th class="header2 header4 hdr1 headerTop">&nbsp;</th>
				<th class="header2 hdr1 headerTop">&nbsp;</th>
				<th class="header2 hdr1 headerTop">To Go</th>
				<th class="header2 hdr1 headerTop">&nbsp;</th>
				<th class="header2 header3 hdr1 headerTop">&nbsp;</th>
				<th class="divider headerTop">&nbsp;</th>

				<th class="header2 header4 hdr1 headerTop">&nbsp;</th>
				<th class="header2 hdr1 headerTop">&nbsp;</th>
				<th class="header2 hdr1 headerTop">Annual</th>
				<th class="header2 hdr1 headerTop">&nbsp;</th>
				<th class="header2 header3 hdr1 headerTop">&nbsp;</th>
			</tr>

<!---------------------------------------------------------- PRODUCT ------------------------------------------------------------->
			<cfoutput>
			<tr id="tr_colhdr">
				<th class="locked stay headerTopAndLeft" id="td_product" style="text-align:left;padding:7px;" name="bufferTD">PRODUCT</th>
				<!---01---> <th class="hdr1 headerTop">#const.ty_label# ACT EQCs</th>
				<!---02---> <th class="hdr1 bcolor2 headerTop">ACT +/- #const.ly_label# EQCs</th>
				<!---03---> <th class="hdr1 bcolor2 headerTop">ACT %<br/>+/- #const.ly_label#</th>
				<!---04---> <th class="hdr1 headerTop">ACT +/- PGM</th>
				<!---05---> <th class="hdr1 headerTop">ACT %<br/>+/- PGM</th>
										<th class="divider">&nbsp;</th>

				<!---01---> <th class="hdr1 headerTop">#const.ty_label# TG EQCs</th>
				<!---02---> <th class="hdr1 bcolor2 headerTop">TG +/- #const.ly_label# EQCs</th>
				<!---03---> <th class="hdr1 bcolor2 headerTop">TG %<br/>+/- #const.ly_label#</th>
				<!---04---> <th class="hdr1 headerTop">TG +/- PGM</th>
				<!---05---> <th class="hdr1 headerTop">TG %<br/>+/- PGM</th>
										<th class="divider headerTop">&nbsp;</th>

				<!---01---> <th class="hdr1 headerTop">#const.ty_label# ANN EQCs</th>
				<!---02---> <th class="hdr1 bcolor2 headerTop">ANN +/- #const.ly_label# EQCs</th>
				<!---03---> <th class="hdr1 bcolor2 headerTop">ANN %<br/>+/- #const.ly_label#</th>
				<!---04---> <th class="hdr1 headerTop">ANN +/- PGM</th>
				<!---05---> <th class="hdr1 headerTop">ANN %<br/>+/- PGM</th>
			</tr>

<!------------------------------------------------------- GRAND TOTAL ------------------------------------------------------------->
			<tr id="tr_gtotal">
				<th class="locked stay headerTopAndLeft" style="text-align:right;" name="bufferTD">GRAND TOTAL</th>

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
					<cfquery name="qActual" datasource="#application.datasource#">
					 SELECT   0 AS ly_volume
									, 0 AS ty_Volume
									, 0 AS ty_pgm
									, 0 AS actual_Volume
					</cfquery>
				</cfif>

				<!---01---> <cfoutput>#displayCell( class="gtotal headerTop", value=NumberFormat(qActual.actual_Volume, const.volumeFormat), tag="th")#</cfoutput>
				<!---02---> <cfoutput>#displayCell( class="gtotal bcolor2 headerTop", value=deltaValue(ty=qActual.actual_Volume, ly=qActual.ly_Volume, percentage=0), tag="th")#</cfoutput>
				<!---03---> <cfoutput>#displayCell( class="gtotal bcolor2 headerTop", value=deltaValue(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=1), tag="th")#</cfoutput>
				<!---04---> <cfoutput>#displayCell( class="gtotal headerTop", value=deltaValue(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=0), tag="th")#</cfoutput>
				<!---05---> <cfoutput>#displayCell( class="gtotal headerTop", value=deltaValue(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=1), tag="th")#</cfoutput>
										<th class="divider headerTop">&nbsp;</th>
					
<!------------------------------------------------------- TO GO SECTION ---------------------------------------------------------->				
				<cfif qToGoPeriods.recordCount eq 0>
					<cfset qToGo = queryNew('foo')>
				<cfelse>
					<cfquery name="qToGo" dbtype="query">
						 SELECT  SUM(ly_Volume) AS ly_Volume
									 , SUM(ty_Volume) AS ty_Volume
									 , SUM(ty_pgm) AS ty_pgm
									 , SUM(actual_Volume) AS Actual_Volume
							 FROM qForecastDetail
							WHERE VF_Period_ID in (<cfqueryparam value="#ValueList(qToGoPeriods.VF_Period_ID)#" cfsqltype="cf_sql_integer" list="yes">)
					</cfquery>
				</cfif>
				<cfif qToGo.recordCount eq 0>
					<cfquery name="qToGo" datasource="#application.datasource#">
					 SELECT   0 AS ly_volume
									, 0 AS ty_Volume
									, 0 AS ty_pgm
									, 0 AS actual_Volume
					</cfquery>
				</cfif>

				<!---01---> <cfoutput>#displayCell( class="gtotal headerTop", value=NumberFormat(qToGo.ty_volume, const.volumeFormat), tag="th")#</cfoutput>
				<!---02---> <cfoutput>#displayCell( class="gtotal bcolor2 headerTop", value=deltaValue(ty=qToGo.ty_volume, ly=qToGo.ly_Volume, percentage=0), tag="th")#</cfoutput>
				<!---03---> <cfoutput>#displayCell( class="gtotal bcolor2 headerTop", value=deltaValue(ty=qToGo.ty_volume, ly=qToGo.ly_volume, percentage=1), tag="th")#</cfoutput>
				<!---04---> <cfoutput>#displayCell( class="gtotal headerTop", value=deltaValue(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=0), tag="th")#</cfoutput>
				<!---05---> <cfoutput>#displayCell( class="gtotal headerTop", value=deltaValue(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=1), tag="th")#</cfoutput>
										<th class="divider headerTop">&nbsp;</th>
					
<!------------------------------------------------------- ANNUAL SECTION ---------------------------------------------------------->				
				<cfquery name="qAnnual" dbtype="query">
					 SELECT  SUM(ly_Volume) AS ly_Volume
								 , SUM(ty_pgm) AS ty_pgm
						 FROM qForecastDetail
				</cfquery>
				<cfif qAnnual.recordCount eq 0>
					<cfquery name="qAnnual" datasource="#application.datasource#">
					 SELECT   0 AS ly_volume
									, 0 AS ty_pgm
					</cfquery>
				</cfif>

				<cfset annual_volume = qActual.actual_volume + qToGo.ty_volume>
				<!---01---> <cfoutput>#displayCell( class="gtotal headerTop", value=NumberFormat(annual_volume, const.volumeFormat), tag="th")#</cfoutput>
				<!---02---> <cfoutput>#displayCell( class="gtotal bcolor2 headerTop", value=deltaValue(ty=annual_volume, ly=qAnnual.ly_Volume, percentage=0), tag="th")#</cfoutput>
				<!---03---> <cfoutput>#displayCell( class="gtotal bcolor2 headerTop", value=deltaValue(ty=annual_volume, ly=qAnnual.ly_volume, percentage=1), tag="th")#</cfoutput>
				<!---04---> <cfoutput>#displayCell( class="gtotal headerTop", value=deltaValue(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=0), tag="th")#</cfoutput>
				<!---05---> <cfoutput>#displayCell( class="gtotal headerTop", value=deltaValue(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=1), tag="th")#</cfoutput>

			</tr>
			</cfoutput>

		</thead>

<!---------------------------------------------------------- TBODY ---------------------------------------------------------------->
		<tbody id="tbl_body">
		<cfsetting enablecfoutputonly="true">
		<cfloop query="qProductPG">
			<cfoutput><tr <cfif (qProductPG.currentRow mod 2) neq 0>style="background-color:##FFDEAD"</cfif>></cfoutput>
				<cfoutput><td nowrap class="locked headerLeft" style="height:35px;">#qProductPG.pg_Product_Category_Name#</td></cfoutput>

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
					<cfquery name="qActual" datasource="#application.datasource#">
						 SELECT 0 AS ly_volume
										, 0 AS ybly_volume
										, 0 AS ty_volume
										, 0 AS ty_pgm
										, 0 AS actual_Volume
					</cfquery>
				</cfif>

				<!---01---> <cfoutput>#displayCell( value=NumberFormat(qActual.actual_Volume, const.volumeFormat) )#</cfoutput>
				<!---02---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=0) )#</cfoutput>
				<!---03---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=1) )#</cfoutput>
				<!---04---> <cfoutput>#displayCell( value=deltaValue(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=0) )#</cfoutput>
				<!---05---> <cfoutput>#displayCell( value=deltaValue(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=1) )#</cfoutput>
										<cfoutput><td class="divider">&nbsp;</td></cfoutput>

<!------------------------------------------------------- TO GO SECTION ---------------------------------------------------------->				
				<cfif qToGoPeriods.recordCount eq 0>
					<cfset qToGo = queryNew('foo')>
				<cfelse>
					<cfquery name="qToGo" dbtype="query">
						 SELECT   SUM(ly_volume) AS ly_volume
										, SUM(ybly_volume) AS ybly_volume
										, SUM(ty_volume) AS ty_volume
										, SUM(ty_pgm) AS ty_pgm
										, SUM(actual_Volume) AS actual_Volume
							 FROM qForecastDetail
							WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
								AND VF_Period_ID in (<cfqueryparam value="#ValueList(qToGoPeriods.VF_Period_ID)#" cfsqltype="cf_sql_integer" list="yes">)
					</cfquery>
				</cfif>
				<cfif qToGo.recordCount eq 0>
					<cfquery name="qToGo" datasource="#application.datasource#">
						 SELECT 0 AS ly_volume
										, 0 AS ybly_volume
										, 0 AS ty_volume
										, 0 AS ty_pgm
										, 0 AS actual_Volume
					</cfquery>
				</cfif>

				<!---01---> <cfoutput>#displayCell( value=NumberFormat(qToGo.ty_volume, const.volumeFormat) )#</cfoutput>
				<!---02---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qToGo.ty_volume, ly=qToGo.ly_volume, percentage=0) )#</cfoutput>
				<!---03---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=qToGo.ty_volume, ly=qToGo.ly_volume, percentage=1) )#</cfoutput>
				<!---04---> <cfoutput>#displayCell( value=deltaValue(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=0) )#</cfoutput>
				<!---05---> <cfoutput>#displayCell( value=deltaValue(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=1) )#</cfoutput>
										<cfoutput><td class="divider">&nbsp;</td></cfoutput>

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
				<cfif qToGo.recordCount eq 0>
					<cfquery name="qAnnual" datasource="#application.datasource#">
						 SELECT 0 AS ly_volume
										, 0 AS ybly_volume
										, 0 AS ty_volume
										, 0 AS ty_pgm
										, 0 AS actual_Volume
					</cfquery>
				</cfif>

				<cfset annual_volume = qActual.actual_volume + qToGo.ty_volume>
				<!---01---> <cfoutput>#displayCell( value=NumberFormat(annual_volume, const.volumeFormat) )#</cfoutput>
				<!---02---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=annual_volume, ly=qAnnual.ly_volume, percentage=0) )#</cfoutput>
				<!---03---> <cfoutput>#displayCell( class="bcolor2", value=deltaValue(ty=annual_volume, ly=qAnnual.ly_volume, percentage=1) )#</cfoutput>
				<!---04---> <cfoutput>#displayCell( value=deltaValue(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=0) )#</cfoutput>
				<!---05---> <cfoutput>#displayCell( value=deltaValue(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=1) )#</cfoutput>
			<cfoutput></tr></cfoutput>
		</cfloop>
		<cfsetting enablecfoutputonly="false">
		</tbody>
	</table>
</div>
</form>

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

<!--------------------------------------------------------------------------------------------------------------------->
<cfset jQueryUI.version = "1.8.23"><!---D37816 :: Unable to export Volume Forecast Annual view --->
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
	<button id="b_qtr4" class="action last">4th Quarter</button>
<form action="/common_files/csv.cfm" method ="post" id="csv_form"> 
<input type="hidden" name="csv_text" id="csv_text">
<input type="hidden" name="csv_file_name"  id="csv_file_name">
</form>
</cfoutput>
</span>
</div>

<!----------------------------------------------Events for buttons -------------------------------------------------------->
<script type="text/javascript">
buttonAction = function( $it, url ) {
	<!---disable the click event--->
	$it.unbind('click').text('One moment...');
	window.location = url;
}
getCSVData = function() {
 var csv_value=$('#vftable').table2CSV({delivery:'value'});
 $("#csv_text").val(csv_value);	
 $("#csv_file_name").val( $('title').text() + ' ' + $.datepicker.formatDate('mm-dd-yy', new Date()) + '.csv' );	
 $("#csv_form").submit();
}

$('button').bind({
	<!---action links hovering--->
	 mouseenter: function() { $(this).addClass("over"); }
	,mouseleave: function() { $(this).removeClass("over"); }
	,click: function(e) {
			var l = {};
					l.thisID = $(this).prop('id');
					l.vfbymonth = 'vfTotalByMonth.cfm?byClassIDs=' + $('#byClassIDs').val() + '&user_position_id=' + $('#marketslist').val();

			e.stopPropagation();
			<cfoutput>
			if ( l.thisID === 'b_close' ) {
				window.close();
			}
			else if ( l.thisID === 'b_excel' ) {
				 getCSVData();
			}
			else if ( l.thisID === 'b_qtr1' ) {
				buttonAction($(this), l.vfbymonth + '&q636=1');
			}
			else if ( l.thisID === 'b_qtr2' ) {
				buttonAction($(this), l.vfbymonth + '&q636=2');
			}
			else if ( l.thisID === 'b_qtr3' ) {
				buttonAction($(this), l.vfbymonth + '&q636=3');
			}
			else if ( l.thisID === 'b_qtr4' ) {
				buttonAction($(this), l.vfbymonth + '&q636=4');
			}
			</cfoutput>
			return false;
	}
});

<!----------------------------------------------Events for markets dropdown------------------------------------------------>
/*$('#marketslist').bind(
		'change', function(e) {
				e.stopPropagation();
				<cfoutput>
				var option = this.options[this.selectedIndex];
				    url = '#cgi.script_name#?' + $(option).attr('id');
				</cfoutput>
				window.location = url;
		}
);
*/
yearAndposition = function() {
	return <cfoutput>'#cgi.script_name#?byClassIDs='</cfoutput> + $('#byClassIDs').val() + '&user_position_id=' + $('#marketslist').val();
}
$('#byClassIDs, #marketslist').change( function() {
	$('#refresh').css("visibility","visible");
});
$('#refresh').click(function() {
	$(this).unbind('click').text('One moment...');
	$('#tbl-container, #div_actions').hide( 700 );
	window.location = yearAndposition();
});
</script>
<script type="text/javascript" src="/Script/javascript/scrollHeader.js"></script>
</body>
</html>

