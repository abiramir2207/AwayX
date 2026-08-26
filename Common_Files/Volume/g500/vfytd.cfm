<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<!---------------------------------------------------------------------------------------------------------------------
			Template: \Common_Files\Volume\g564\vfytd.cfm
			Date:     Dec 21 2011
			Author:   Chris Nguyen
			Purpose:  GM YTD/Annual Volume

			Notes:    URL parameter names are soundex values so they are not obvious to users (more secure)

			Required Input:  1. url.l143: level ID (numeric)
											 2. url.v451: volume plan ID (numeric)

----------------------------------------------------------------------------------------------------------------------->
<html>
<cfparam name="url.r354" default="">

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
  
  qOneRow = queryNew( 'foo' );
  queryAddRow( qOneRow );
</cfscript>

<head>
	<cfinclude template="vfUDF.cfm">        <!---volume forecast functions library--->
	<title>YTD/Annual Volume</title>
	<link rel="stylesheet" type="text/css" href="workbook.css?v=2011-10-24">

	<style>
	<cfoutput>
	.mediumButton { width:60px; }	
	.ty { background-color:##A5BAFF; }
	.delta { color:blue; font-weight:bold; }
	.inactive { background-color:white; font-weight:normal; color:gray; }
	##pagetitle { background-color:##4169E1; color:white; font-size:17px; font-weight:bold; height:50px; margin:0; text-align:center; vertical-align:middle; width:100%; padding-top:3px;}
	</cfoutput>
	.bcolor2 { background-color:#A5BAFF; }
	.hdr1{width:80px;padding:4px;}
	.pos { color:black; }
	.neg { color:red; }
	</style>
</head>

<cfoutput>
<cfquery name="qVolumePlan" Datasource="#application.datasource#">
	<cfif url.l143 eq "summary">
		SELECT Plan_Name = vf_Plan.vf_Plan_desc
		      ,Forecast_Level
		      ,User_Position_Id = 0
		      ,uom = CASE WHEN vf_uom = 9 THEN 'EQC' ELSE b.abbreviation END
			FROM vf_Plan
		      LEFT JOIN Units_of_Measure b ON vf_plan.vf_uom = b.unit_of_measure_id
		 WHERE vf_Plan.vf_Plan_Id = #url.v451#
	<cfelse>
		SELECT Plan_Name = vf_Plan.vf_Plan_desc
		      ,Forecast_Level
		      ,vf_Level.User_Position_Id
		      ,uom = CASE WHEN vf_uom = 9 THEN 'EQC' ELSE b.abbreviation END
			FROM vf_Plan
		 			 INNER JOIN vf_Level ON vf_Plan.vf_Plan_Id = vf_Level.vf_Plan_Id and vf_Level.Deleted = 0 and vf_Level.vf_level_id = #url.l143#
		      LEFT JOIN Units_of_Measure b ON vf_plan.vf_uom = b.unit_of_measure_id
		 WHERE vf_Plan.vf_Plan_Id = #url.v451#
	</cfif>
</cfquery>
<cfset main.uom = qVolumePlan.uom>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->
<cfscript>
	qProductPG      = application.oVfManager.getProductCategories( url.v451 );
 	qCurrPositionAndBelowMarkets = application.oVfManager.getCurrPositionAndBelowVF( url.v451 );
	
	if (url.l143 eq "summary") {
		qLevel           = application.oVfManager.getLevels( vf_id=url.v451, level=qCurrPositionAndBelowMarkets.VF_Level_ID );
		qForecastDetail = application.oVfManager.getDetail( vf_id=url.v451, level=valuelist(qCurrPositionAndBelowMarkets.VF_Level_ID) );
	}
	else {
		qLevel          = application.oVfManager.getLevels( vf_id=url.v451, level=url.l143 );
		qForecastDetail = application.oVfManager.getDetail( vf_id=url.v451, level=url.l143 );
	}
	
	qActualPeriods  = application.oVfManager.getPeriodsbyStatus( vf_id=url.v451, actual=1 );
	qToGoPeriods    = application.oVfManager.getPeriodsbyStatus( vf_id=url.v451, actual=0 );

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
<cfset vars.queryString = "v451=" & url.v451 & "&l143=" & url.l143 & "&r354=" & url.r354>
<cfoutput>
<div id="pagetitle">
<span <cfif len(qLevel.LockedByUserName) or len(qLevel.UpdatedBy)>style="position:relative; top:2px;"<cfelse>style="position:relative; top:9px;"</cfif>>
#qVolumePlan.Plan_Name# #marketsList( url.v451 )#
</span>
</div>
<div id="pageinfo">
	<cfif url.l143 neq "summary">
		<cfif len(qLevel.LockedByUserName)>
			<span id="LockedBy">Locked by #qLevel.LockedByUserName#</span>
		</cfif>
		<cfif len(qLevel.UpdatedBy)>
			<span id="updatedby">Last Updated on #DateFormat(qLevel.Last_Updated_On, 'medium')# #TimeFormat(qLevel.Last_Updated_On, 'short')# by #qLevel.UpdatedBy#</span>
		</cfif>
	</cfif>
</div>
</cfoutput>
<form name="workbook" id="workbookform" method="post" <cfoutput>action="#cgi.script_name#?#cgi.query_string#"</cfoutput>>
<input name="windowNewLocation" id="windowNewLocation" type="hidden">
<div id="tbl-container" onscroll="keepHeaderFixed(this.scrollTop-1,scrollLeft);">

	<table class="tbl" style="TOP: 0px;" cellspacing="0">

<!------------------------------------------------------- COLUMN HEADERS ---------------------------------------------------------->
		<thead id="tbl_head">
			<tr id="tr_period">
				<th class="locked headerTopAndLeft" style="z-index:40" name="bufferTD">&nbsp;</th>

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
				<th class="locked headerTopAndLeft" id="td_product" style="z-index:40;text-align:left;padding:7px;" name="bufferTD">PRODUCT</th>
				<!---01---> <th class="hdr1 headerTop">#const.ty_label# ACT #main.uom#</th>
				<!---02---> <th class="hdr1 bcolor2 headerTop">ACT +/- #const.ly_label# #main.uom#</th>
				<!---03---> <th class="hdr1 bcolor2 headerTop">ACT %<br/>+/- #const.ly_label#</th>
				<!---04---> <th class="hdr1 headerTop">ACT +/- PGM</th>
				<!---05---> <th class="hdr1 headerTop">ACT %<br/>+/- PGM</th>
										<th class="divider headerTop">&nbsp;</th>

				<!---01---> <th class="hdr1 headerTop">#const.ty_label# TG #main.uom#</th>
				<!---02---> <th class="hdr1 bcolor2 headerTop">TG +/- #const.ly_label# #main.uom#</th>
				<!---03---> <th class="hdr1 bcolor2 headerTop">TG %<br/>+/- #const.ly_label#</th>
				<!---04---> <th class="hdr1 headerTop">TG +/- PGM</th>
				<!---05---> <th class="hdr1 headerTop">TG %<br/>+/- PGM</th>
										<th class="divider headerTop">&nbsp;</th>

				<!---01---> <th class="hdr1 headerTop">#const.ty_label# ANN #main.uom#</th>
				<!---02---> <th class="hdr1 bcolor2 headerTop">ANN +/- #const.ly_label# #main.uom#</th>
				<!---03---> <th class="hdr1 bcolor2 headerTop">ANN %<br/>+/- #const.ly_label#</th>
				<!---04---> <th class="hdr1 headerTop">ANN +/- PGM</th>
				<!---05---> <th class="hdr1 headerTop">ANN %<br/>+/- PGM</th>
			</tr>

<!------------------------------------------------------- GRAND TOTAL ------------------------------------------------------------->
			<tr id="tr_gtotal">
				<th class="locked headerTopAndLeft" style="z-index:40;text-align:right;" name="bufferTD">GRAND TOTAL</th>

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

				<!---01---> <th class="gtotal headerTop"> #NumberFormat(qActual.actual_Volume, const.volumeFormat)# </th>
				<!---02---> <th class="gtotal bcolor2 headerTop"> #deltaValue(ty=qActual.actual_Volume, ly=qActual.ly_Volume, percentage=0)# </th>
				<!---03---> <th class="gtotal bcolor2 headerTop"> #deltaValue(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=1)# </th>
				<!---04---> <th class="gtotal headerTop"> #deltaValue(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=0)# </th>
				<!---05---> <th class="gtotal headerTop"> #deltaValue(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=1)# </th>
										<th class="divider headerTop">&nbsp;</th>
					
<!------------------------------------------------------- TO GO SECTION ---------------------------------------------------------->				
				<cfquery name="qToGo" dbtype="query">
					 SELECT  SUM(ly_Volume) AS ly_Volume
								 , SUM(ty_Volume) AS ty_Volume
								 , SUM(ty_pgm) AS ty_pgm
								 , SUM(actual_Volume) AS Actual_Volume
						 FROM qForecastDetail
						WHERE 	<cfif qToGoPeriods.RecordCount>
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

				<!---01---> <th class="gtotal headerTop"> #NumberFormat(qToGo.ty_volume, const.volumeFormat)# </th>
				<!---02---> <th class="gtotal bcolor2 headerTop"> #deltaValue(ty=qToGo.ty_volume, ly=qToGo.ly_Volume, percentage=0)# </th>
				<!---03---> <th class="gtotal bcolor2 headerTop"> #deltaValue(ty=qToGo.ty_volume, ly=qToGo.ly_volume, percentage=1)# </th>
				<!---04---> <th class="gtotal headerTop"> #deltaValue(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=0)# </th>
				<!---05---> <th class="gtotal headerTop"> #deltaValue(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=1)# </th>
										<th class="divider headerTop">&nbsp;</th>
					
<!------------------------------------------------------- ANNUAL SECTION ---------------------------------------------------------->				
				<cfquery name="qAnnual" dbtype="query">
					 SELECT  SUM(ly_Volume) AS ly_Volume
								 , SUM(ty_pgm) AS ty_pgm
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
				<!---01---> <th class="gtotal headerTop"> #NumberFormat(annual_volume, const.volumeFormat)# </th>
				<!---02---> <th class="gtotal bcolor2 headerTop"> #deltaValue(ty=annual_volume, ly=qAnnual.ly_Volume, percentage=0)# </th>
				<!---03---> <th class="gtotal bcolor2 headerTop"> #deltaValue(ty=annual_volume, ly=qAnnual.ly_volume, percentage=1)# </th>
				<!---04---> <th class="gtotal headerTop"> #deltaValue(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=0)# </th>
				<!---05---> <th class="gtotal headerTop"> #deltaValue(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=1)# </th>

			</tr>
			</cfoutput>

		</thead>

<!---------------------------------------------------------- TBODY ---------------------------------------------------------------->
		<tbody id="tbl_body">
		<cfsetting enablecfoutputonly="true">
		<cfloop query="qProductPG">
			<cfoutput><tr id="tr_#qProductPG.CurrentRow#"></cfoutput>
				<cfoutput><td nowrap class="locked headerLeft">#qProductPG.pg_Product_Category_Name#</td></cfoutput>

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

				<!---01---> <cfoutput><td> #NumberFormat(qActual.actual_Volume, const.volumeFormat)# </td></cfoutput>
				<!---02---> <cfoutput><td class="bcolor2"> #deltaValue(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=0)# </td></cfoutput>
				<!---03---> <cfoutput><td class="bcolor2"> #deltaValue(ty=qActual.actual_volume, ly=qActual.ly_volume, percentage=1)# </td></cfoutput>
				<!---04---> <cfoutput><td> #deltaValue(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=0)# </td></cfoutput>
				<!---05---> <cfoutput><td> #deltaValue(ty=qActual.actual_volume, ly=qActual.ty_pgm, percentage=1)# </td></cfoutput>
										<cfoutput><td class="divider">&nbsp;</td></cfoutput>

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

				<!---01---> <cfoutput><td> #NumberFormat(qToGo.ty_volume, const.volumeFormat)# </td></cfoutput>
				<!---02---> <cfoutput><td class="bcolor2"> #deltaValue(ty=qToGo.ty_volume, ly=qToGo.ly_volume, percentage=0)# </td></cfoutput>
				<!---03---> <cfoutput><td class="bcolor2"> #deltaValue(ty=qToGo.ty_volume, ly=qToGo.ly_volume, percentage=1)# </td></cfoutput>
				<!---04---> <cfoutput><td> #deltaValue(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=0)# </td></cfoutput>
				<!---05---> <cfoutput><td> #deltaValue(ty=qToGo.ty_volume, ly=qToGo.ty_pgm, percentage=1)# </td></cfoutput>
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
				<!---01---> <cfoutput><td> #NumberFormat(annual_volume, const.volumeFormat)# </td></cfoutput>
				<!---02---> <cfoutput><td class="bcolor2"> #deltaValue(ty=annual_volume, ly=qAnnual.ly_volume, percentage=0)# </td></cfoutput>
				<!---03---> <cfoutput><td class="bcolor2"> #deltaValue(ty=annual_volume, ly=qAnnual.ly_volume, percentage=1)# </td></cfoutput>
				<!---04---> <cfoutput><td> #deltaValue(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=0)# </td></cfoutput>
				<!---05---> <cfoutput><td> #deltaValue(ty=annual_volume, ly=qAnnual.ty_pgm, percentage=1)# </td></cfoutput>
			<cfoutput></tr></cfoutput>
		</cfloop>
		<cfsetting enablecfoutputonly="false">
		</tbody>
	</table>
</div>
</form>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="/common_files/jQuery.cfm">

<script type="text/javascript">
window.moveTo(0,0);
// reduce the table height to allow room for buttons
$('#tbl-container').css("height", screen.availHeight - 195);
$('.tbl tr:odd').css("background-color", "#f5f5f5");
window.resizeTo( screen.availWidth, screen.availHeight );
$('#tbl-container').show();
<!---rows hovering--->
$('table.tbl tr').hover (
	function() { $(this).addClass("over"); },
	function() { $(this).removeClass("over"); }
);
</script>

<!----------------------------------------------FOOTER BUTTONS--------------------------------------------------------->
<div style="margin:0px 20px;" id="div_actions">
<span style="float:left">
<button id="b_notes"  class="action mediumButton" <cfif url.l143 eq 'SUMMARY'>disabled=disabled</cfif>>Notes</button>
<button id="b_export" class="action mediumButton">Export</button>
<button id="b_close"  class="action">Close Window</button>
</span>
<span style="float:right" id="quarters">
<cfoutput>
	<button id="b_qtr1" class="action">1st Quarter</button>
	<button id="b_qtr2" class="action">2nd Quarter</button>
	<button id="b_qtr3" class="action">3rd Quarter</button>
	<button id="b_qtr4" class="action last">4th Quarter</button>
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
<!----------------------------------------------Unlock volume forecast----------------------------------------------------->
 unlock = function() {
 	  <cfif url.l143 neq "summary">
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
    </cfif>
}
<!----------------------------------------------Events for markets dropdown------------------------------------------------>
$('#marketslist').bind(
		'change', function(e) {     
				unlock();
				e.stopPropagation();
				<cfoutput>
				var option = this.options[this.selectedIndex];
				    url = '#cgi.script_name#?' + $(option).attr('id');
				</cfoutput>
				window.location = url;
		}
);
$('button').bind({
	<!---action links hovering--->
	 mouseenter: function() { $(this).addClass("over"); }
	,mouseleave: function() { $(this).removeClass("over"); }
	,click: function(e) {
			var l = {};
					l.thisID = $(this).prop('id');
					l.vfbymonth = 'vfbymonth.cfm';

			e.stopPropagation();
			<cfoutput>
			if ( l.thisID === 'b_close' ) {
				window.close();
			}
			else if ( l.thisID === 'b_qtr1' ) {
				buttonAction($(this), l.vfbymonth + '?#vars.queryString#&q636=1');
			}
			else if ( l.thisID === 'b_qtr2' ) {
				buttonAction($(this), l.vfbymonth + '?#vars.queryString#&q636=2');
			}
			else if ( l.thisID === 'b_qtr3' ) {
				buttonAction($(this), l.vfbymonth + '?#vars.queryString#&q636=3');
			}
			else if ( l.thisID === 'b_qtr4' ) {
				buttonAction($(this), l.vfbymonth + '?#vars.queryString#&q636=4');
			}
			else if ( l.thisID === 'b_notes' ) {
       vfnotes = NewWindow('/common_files/volume/g500/vfnotes.cfm?l143=<cfoutput>#url.l143#&r354=#url.r354#</cfoutput>','vfnotes','870','620','Yes', 'No', 'yes', 'no');				
			}
			else if ( l.thisID === 'b_export' ) {
       vfexport = NewWindow('/common_files/volume/g500/vfexport.cfm?l143=<cfoutput>#url.l143#&v451=#url.v451#&ytd=1</cfoutput>','vfexport','870','620','Yes', 'No', 'yes', 'no');				
			}
			</cfoutput>
			return false;
	}
});
$(window).unload( function () { unlock(); } );

refreshColor = function() {
$('th,td').each(function(){
	var val = $(this).text().replace("$", "").replace("%24", "").replace(/\,/g,"").replace(/%2C/g,"").replace(/\%/g,"");
	var n = +val;
	//console.log(n);
  if (!isNaN(n) && /^\s*[+-]/.test(val)) {
    $(this).addClass(val >= 0 ? 'pos' : 'neg').removeClass(val >= 0 ? 'neg' : 'pos');
  }
});
}

refreshColor();
</script>
<script type="text/javascript" src="/Script/javascript/scrollHeader.js"></script>
</body>
</html>

