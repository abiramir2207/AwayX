<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<!---------------------------------------------------------------------------------------------------------------------
			Template: \Common_Files\Volume\g564\ytdwb.cfm
			Date:     Oct 18 2011
			Author:   Chris Nguyen
			Purpose:  GM Volume Forecast workbook for the whole year

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

	main.isDevSite     = 1;
  application.oController.getObject(path="mvc.models.volumeforecast.vfmanager", name="vfmanager", bReload=main.isDevSite);
</cfscript>

<head>
	<cfinclude template="vfUDF.cfm">        <!---volume forecast functions library--->
	<title>Volume Forecast Workbook</title>
	<link rel="stylesheet" type="text/css" href="/common_files/main_style.css">   <!--TODO: remove this line-->
	<link rel="stylesheet" type="text/css" href="workbook.css?v=2011-10-24">

	<style>
	<cfoutput>
	.ty { background-color:##A5BAFF; }
	.delta { color:blue; font-weight:bold; }
	.inactive { background-color:white; font-weight:normal; color:gray; }
	##pagetitle { background-color:##4169E1; color:white; font-size:17px; font-weight:bold; height:30px; margin:0; text-align:center; vertical-align:middle; width:100%; padding-top:3px;}
	</cfoutput>
	</style>
</head>

<!--------------------------------------------------------------------------------------------------------------------->
<cfscript>
	qProductPG      = application.oVfManager.getProductCategories( url.v451 );
	qMarket         = application.oVfManager.getMarkets( vf_id=url.v451, level=url.l143 );
	qForecastDetail = application.oVfManager.getDetail( vf_id=url.v451, level=url.l143 );

	const.working_year = Right(qMarket.Year_Selection, 2);                               
	const.ty_label     = "F" & const.working_year;         // working year column label
	const.ly_label     = "F" & (const.working_year - 1);   // previous year column label
	const.ybly_label   = "F" & (const.working_year - 2);   // year before previous year column label
</cfscript>
<!--------------------------------------------------------------------------------------------------------------------->

<body style="overflow:hidden;margin:0px; display:block;">
<cfset vars.queryString = "v451=" & url.v451 & "&l143=" & url.l143 & "&r354=" & url.r354>
<cfoutput>
<div id="pagetitle">Year-To-Date Volume Forecast for #marketsList()#</div>
<div id="pageinfo">
		<cfif len(qMarket.LockedByUserName)>
			<span id="LockedBy">Locked by #qMarket.LockedByUserName#</span>
		</cfif>
		<cfif len(qMarket.UpdatedBy)>
			<span id="updatedby">Last Updated on #DateFormat(qMarket.Last_Updated_On, 'medium')# #TimeFormat(qMarket.Last_Updated_On, 'short')# by #qMarket.UpdatedBy#</span>
		</cfif>
</div>
</cfoutput>
<form name="workbook" id="workbookform" method="post" <cfoutput>action="#cgi.script_name#?#cgi.query_string#"</cfoutput>>
<input name="windowNewLocation" id="windowNewLocation" type="hidden">
<div id=tbl-container>

	<table class="tbl" style="TOP: 0px;">

<!------------------------------------------------------- COLUMN HEADERS ---------------------------------------------------------->
		<thead id="tbl_head">
			<tr id="tr_period">
				<th class="locked" style="z-index:40" name="bufferTD">&nbsp;</th>
				<!---Header for 4 quarters--->
				<cfloop from="1" to="4" index="main.quarter">
					<cfif main.quarter eq 1>
						<cfset header4 = "">
					<cfelse>
						<cfset header4 = "header4">
					</cfif>				
					<cfoutput><th class="header2 colhdr_readonly #header4#">Q#main.quarter#</th></cfoutput>
					<th class="header2 colhdr_readonly">&nbsp;</th>
					<th class="header2 colhdr_readonly">&nbsp;</th>
					<th class="header2 colhdr_readonly">&nbsp;</th>
					<th class="header2 colhdr_readonly">&nbsp;</th>
					<th class="header2 colhdr_readonly">&nbsp;</th>
					<th class="header2 colhdr_readonly">&nbsp;</th>
					<th class="header2 colhdr_readonly">&nbsp;</th>
					<th class="header2 colhdr_readonly">&nbsp;</th>
					<th class="header2 header3 colhdr_readonly">&nbsp;</th>
					<th class="divider">&nbsp;</th>
				</cfloop>

				<!---YEAR Total header--->
				<cfoutput><th class="header2 colhdr_readonly">YTD</th></cfoutput>
				<th class="header2 colhdr_readonly">&nbsp;</th>
				<th class="header2 colhdr_readonly">&nbsp;</th>
				<th class="header2 colhdr_readonly">&nbsp;</th>
				<th class="header2 colhdr_readonly">&nbsp;</th>
				<th class="header2 colhdr_readonly">&nbsp;</th>
				<th class="header2 colhdr_readonly">&nbsp;</th>
				<th class="header2 colhdr_readonly">&nbsp;</th>
				<th class="header2 colhdr_readonly">&nbsp;</th>
				<th class="header2 colhdr_readonly">&nbsp;</th>
			</tr>

<!---------------------------------------------------------- PRODUCT ------------------------------------------------------------->
			<cfoutput>
			<tr id="tr_colhdr">
				<th class="locked" id="td_product" style="z-index:40;text-align:left;padding:7px;" name="bufferTD">PRODUCT</th>
				<!---Column Headers for a month--->

					<cfloop from="1" to="4" index="main.quarter">
					<!---01---> <th>#const.ly_label# EQCs</th>
					<!---02---> <th>#const.ly_label# %<br/>+/- #const.ybly_label#</th>
					<!---03---> <th class="ty">#const.ty_label# FC (Enter % +/- #const.ly_label#)</th>
					<!---04---> <th class="ty">#const.ty_label# Forecast EQCs</th>
					<!---05---> <th>FC +/- #const.ly_label# EQCs</th>
					<!---06---> <th>FC %<br/>+/- #const.ly_label#</th>
					<!---07---> <th>#const.ty_label# PGM</th>
					<!---08---> <th>FC +/- PGM</th>
					<!---09---> <th>FC %<br/>+/- PGM</th>
					<!---10---> <th>#const.ybly_label# EQCs</th>
											<th class="divider">&nbsp;</th>
					</cfloop>

				<!---YTD TOTAL Column Headers--->
				<!---01---> <th>#const.ly_label# EQCs</th>
				<!---02---> <th>#const.ly_label# %<br/>+/- #const.ybly_label#</th>
				<!---03---> <th class="ty">#const.ty_label# FC (Enter % +/- #const.ly_label#)</th>
				<!---04---> <th class="ty">#const.ty_label# Forecast EQCs</th>
				<!---05---> <th>FC +/- #const.ly_label# EQCs</th>
				<!---06---> <th>FC %<br/>+/- #const.ly_label#</th>
				<!---07---> <th>#const.ty_label# PGM</th>
				<!---08---> <th>FC +/- PGM</th>
				<!---09---> <th>FC %<br/>+/- PGM</th>
				<!---10---> <th>#const.ybly_label# EQCs</th>
			</tr>

<!------------------------------------------------------- GRAND TOTAL ------------------------------------------------------------->
			<tr id="tr_gtotal">
				<th class="locked" style="z-index:40;text-align:right;" name="bufferTD">GRAND TOTAL</th>
				<!---Column Headers for a quarter--->
				<cfloop from="1" to="4" index="main.quarter">
					<cfset qPeriod = application.oVfManager.getPeriods( vf_id=url.v451, quarter=main.quarter )>
					<cfquery name="qSubtotals" dbtype="query">
						 SELECT  SUM(ly_Volume) AS sum_ly_Volume
									 , SUM(ty_Volume) AS sum_ty_Volume
									 , SUM(ty_pgm) AS sum_ty_pgm
									 , SUM(ybly_Volume) AS sum_ybly_Volume
							 FROM qForecastDetail
							WHERE VF_Period_ID in (<cfqueryparam value="#ValueList(qPeriod.VF_Period_ID)#" cfsqltype="cf_sql_integer" list="yes">)
					</cfquery>
					<cfif qSubtotals.recordCount eq 0>
						<cfquery name="qSubtotals" dbtype="query">
						 SELECT   0 AS sum_ly_volume
										, 0 AS sum_ty_Volume
										, 0 AS sum_ty_pgm
										, 0 AS sum_ybly_Volume
						</cfquery>
					</cfif>

					<!---01---> <th class="gtotal"> #NumberFormat(qSubtotals.sum_ly_Volume, const.volumeFormat)# </th>
					<!---02---> <th class="gtotal"> #deltaValue(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1)# </th>
					<!---03---> <th class="gtotal"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </th>
					<!---04---> <th class="gtotal"> #NumberFormat(qSubtotals.sum_ty_Volume, const.volumeFormat)# </th>
					<!---05---> <th class="gtotal delta"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=0)# </th>
					<!---06---> <th class="gtotal delta"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </th>
					<!---07---> <th class="gtotal"> #NumberFormat(qSubtotals.sum_ty_pgm, const.volumeFormat)# </th>
					<!---08---> <th class="gtotal"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=0)# </th>
					<!---09---> <th class="gtotal"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1)# </th>
					<!---10---> <th class="gtotal"> #NumberFormat(qSubtotals.sum_ybly_Volume, const.volumeFormat)# </th>
											<th class="divider">&nbsp;</th>
				</cfloop>

				<cfquery name="qSubtotals" dbtype="query">
						 SELECT  SUM(ly_Volume) AS sum_ly_Volume
									 , SUM(ty_Volume) AS sum_ty_Volume
									 , SUM(ty_pgm) AS sum_ty_pgm
									 , SUM(ybly_Volume) AS sum_ybly_Volume
						 FROM qForecastDetail
				</cfquery>
				<cfif qSubtotals.recordCount eq 0>
					<cfquery name="qSubtotals" dbtype="query">
					 SELECT   0 AS sum_ly_volume
									, 0 AS sum_ty_Volume
									, 0 AS sum_ty_pgm
									, 0 AS sum_ybly_Volume
					</cfquery>
				</cfif>

				<!---YTD TOTAL Column Headers--->
				<!---01---> <th class="gtotal"> #NumberFormat(qSubtotals.sum_ly_Volume,const.volumeFormat)# </th>
				<!---02---> <th class="gtotal"> #deltaValue(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1)# </th>
				<!---03---> <th class="gtotal"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </th>
				<!---04---> <th class="gtotal"> #NumberFormat(qSubtotals.sum_ty_Volume, const.volumeFormat)# </th>
				<!---05---> <th class="gtotal"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=0)# </th>
				<!---06---> <th class="gtotal"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </th>
				<!---07---> <th class="gtotal"> #NumberFormat(qSubtotals.sum_ty_pgm, const.volumeFormat)# </th>
				<!---08---> <th class="gtotal"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=0)# </th>
				<!---09---> <th class="gtotal"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1)# </th>
				<!---10---> <th class="gtotal"> #NumberFormat(qSubtotals.sum_ybly_Volume, const.volumeFormat)# </th>
			</tr>
			</cfoutput>

		</thead>

<!---------------------------------------------------------- TBODY ---------------------------------------------------------------->
		<tbody id="tbl_body">
		<cfsetting enablecfoutputonly="true">
		<cfloop query="qProductPG">
			<cfoutput><tr id="tr_#qProductPG.CurrentRow#"></cfoutput>
				<cfoutput><td nowrap class="locked" style="height:35px;">#qProductPG.pg_Product_Category_Name#</td></cfoutput>

				<!---Data for quarters--->
				<cfloop from="1" to="4" index="main.quarter">
					<cfset qPeriod = application.oVfManager.getPeriods( vf_id=url.v451, quarter=main.quarter )>
					<cfquery name="qForecastQuarter" dbtype="query">
						 SELECT   SUM(ly_volume) AS ly_volume
										, SUM(ybly_volume) AS ybly_volume
										, SUM(ty_volume) AS ty_volume
										, SUM(ty_pgm) AS ty_pgm
							 FROM qForecastDetail
							WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
								AND VF_Period_ID in (<cfqueryparam value="#ValueList(qPeriod.VF_Period_ID)#" cfsqltype="cf_sql_integer" list="yes">)
					</cfquery>
					<cfif qForecastQuarter.recordCount eq 0>
						<cfquery name="qForecastQuarter" dbtype="query">
							 SELECT 0 AS ly_volume
											, 0 AS ybly_volume
											, 0 AS ty_volume
											, 0 AS ty_pgm
						</cfquery>
					</cfif>

					<!---01---> <cfoutput><td> #NumberFormat(qForecastQuarter.ly_Volume, const.volumeFormat)# </td></cfoutput>
					<!---02---> <cfoutput><td> #deltaValue(ty=qForecastQuarter.ly_volume, ly=qForecastQuarter.ybly_volume, percentage=1)# </td></cfoutput>
					<!---03---> <cfoutput><td class="ty"> #deltaValue(ty=qForecastQuarter.ty_volume, ly=qForecastQuarter.ly_Volume, percentage=1)#&nbsp;</td></cfoutput>
					<!---04---> <cfoutput><td class="ty"> #NumberFormat(qForecastQuarter.ty_Volume, const.volumeFormat)# </td></cfoutput>
					<!---05---> <cfoutput><td class="delta"> #deltaValue(ty=qForecastQuarter.ty_volume, ly=qForecastQuarter.ly_Volume, percentage=0)# </td></cfoutput>
					<!---06---> <cfoutput><td class="delta"> #deltaValue(ty=qForecastQuarter.ty_volume, ly=qForecastQuarter.ly_Volume, percentage=1)# </td></cfoutput>
					<!---07---> <cfoutput><td> #NumberFormat(qForecastQuarter.ty_PGM, const.volumeFormat)# </td></cfoutput>
					<!---08---> <cfoutput><td> #deltaValue(ty=qForecastQuarter.ty_volume, ly=qForecastQuarter.ty_pgm, percentage=0)# </td></cfoutput>
					<!---09---> <cfoutput><td> #deltaValue(ty=qForecastQuarter.ty_volume, ly=qForecastQuarter.ty_pgm, percentage=1)# </td></cfoutput>
					<!---10---> <cfoutput><td> #NumberFormat(qForecastQuarter.ybly_Volume, const.volumeFormat)# </td></cfoutput>
											<cfoutput><td class="divider">&nbsp;</td></cfoutput>
				</cfloop>

<!---------------------------------------------------------- YTD -------------------------------------------------------------->
				<cfquery name="qSubtotals" dbtype="query">
					 SELECT   SUM(ly_volume) AS sum_ly_volume
									, SUM(ybly_volume) AS sum_ybly_volume
									, SUM(ty_volume) AS sum_ty_volume
									, SUM(ty_pgm) AS sum_ty_pgm
						 FROM qForecastDetail
						WHERE PG_Product_Category_ID = <cfqueryparam value="#qProductPG.pg_Product_Category_Id#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif qSubtotals.recordCount eq 0>
					<cfquery name="qSubtotals" dbtype="query">
					 SELECT   0 AS sum_ly_volume
									, 0 AS sum_ybly_volume
									, 0 AS sum_ty_volume
									, 0 AS sum_ty_pgm
					</cfquery>
				</cfif>

				<!---01---> <cfoutput><td> #NumberFormat(qSubtotals.sum_ly_Volume, const.volumeFormat)# </td></cfoutput>
				<!---02---> <cfoutput><td> #deltaValue(ty=qSubtotals.sum_ly_Volume, ly=qSubtotals.sum_ybly_Volume, percentage=1)#</td></cfoutput>
				<!---03---> <cfoutput><td class="ty"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)#</td></cfoutput>
				<!---04---> <cfoutput><td class="ty"> #NumberFormat(qSubtotals.sum_ty_Volume, const.volumeFormat)# </td></cfoutput>
				<!---05---> <cfoutput><td class="delta"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=0)# </td></cfoutput>
				<!---06---> <cfoutput><td class="delta"> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ly_volume, percentage=1)# </td></cfoutput>
				<!---07---> <cfoutput><td> #NumberFormat(qSubtotals.sum_ty_pgm, const.volumeFormat)# </td></cfoutput>
				<!---08---> <cfoutput><td> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=0)# </td></cfoutput>
				<!---09---> <cfoutput><td> #deltaValue(ty=qSubtotals.sum_ty_volume, ly=qSubtotals.sum_ty_pgm, percentage=1)# </td></cfoutput>
				<!---10---> <cfoutput><td> #NumberFormat(qSubtotals.sum_ybly_Volume, const.volumeFormat)# </td></cfoutput>

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
$('#tbl-container').css("height", screen.availHeight - 160);
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
<button id="b_close" class="action">Close Window</button>
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
<!----------------------------------------------Events for markets dropdown------------------------------------------------>
$('#marketslist').bind(
		'change', function(e) {     
				e.stopPropagation();
				<cfoutput>
				var option = this.options[this.selectedIndex];
				    url = '#cgi.script_name#?#removeURLfields('l143')#&l143=' + $(option).attr('id');
				</cfoutput>
				// console.log ( $(option).text() + ' ' + $(option).attr('id') );
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
			</cfoutput>
			return false;
	}
});
$(window).unload( function () { unlock(); } );
</script>
</body>
</html>

