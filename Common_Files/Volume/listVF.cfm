<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\Volume\listVF.cfm
      Date:     2012 July
      Author:   Chris Nguyen
      Purpose:  List volume forecasts

			Parameter:
									URL.byClassIDs = optional, comma-delimited list of VFC classes

----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "volume-forecast">
<!---<cfparam name="url.byClassIDs" default="">    <!--- 36147 --->--->

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" href="/styles/jQueryUI_18/jquery.multiselect.css" type="text/css" />
<link rel="stylesheet" href="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css" type="text/css" />
<style>
#vfclass { font-size:1em; font-weight:bold; margin-right:11px; letter-spacing:0.85px; }
#byClassIDs { height:45px; border:2px solid red; }
.open, .notes { font-size:9px; font-weight:bold; }
.action { text-align:center; }
.vftotal { float:right; margin-right:10px; }
.vftotal button { width:160px; }
.over{background-color:#c6ffc6 !important;}
.products:hover, .customers:hover, #filter:hover  { text-decoration:underline; cursor:pointer; }
.vfclass { margin-left:15px; float:left; }
</style>
<cfscript>
  main = {};
	main.isDevSite     = 1;                                // TODO: change it to 0 prior to deployment
  application.oController.getObject(path="mvc.models.volumeforecast.vfmanager", name="vfmanager", bReload=main.isDevSite);

	// default to show only VF for current year
	if ( not structKeyExists(url, 'byClassIDs') ) {
	  main.currentClasses = application.oVfManager.getClasses( activeOnly=true, currentYearOnly=true );
		url.byClassIDs = valueList( main.currentClasses.vf_Class_ID );
	}

  main.qVFLevels = application.oVfManager.getCurrPositionAndBelowVF( byClassIDs=url.byClassIDs );    // 36147
  main.classes = application.oVfManager.getClasses();    // 36147
</cfscript>

<!--- <fieldset style="padding:7px; width:99%; border:1px solid blue;display:table;">
	<legend style="font: bold 14px sans-serif; color: red;">Volume Forecast List</legend> --->
<div style="margin:10px">
<div style="margin-bottom:3px;display:none;" id="f1">
	<form style="margin:0;" id="vfForm">
		<span id="vfclass">Class:</span>
		<select name="byClassIDs" id="byClassIDs" multiple="multiple">
			<cfoutput query="main.classes">
				<option <cfif url.byClassIDs eq "" or listFindNoCase(url.byClassIDs, main.classes.vf_class_id)>selected=selected</cfif> value="#main.classes.vf_class_id#">#main.classes.vf_class_number# - #main.classes.vf_class_desc#</option>
			</cfoutput>
		</select>
		&nbsp;&nbsp;&nbsp;<a id="filter"><cfoutput>#application.util.string.actionLinkFormat("Filter")#</cfoutput></a>
	</form>
</div>
<table id="listVF" class="datagrid"  style='table-layout:fixed;width:100%;'>
<col width="23%"> <col width="8%"> <col width="8%"> <col width="22%"> <col width="6%"> <col width="13%"> <col width="10%"> <col width="10%">
<thead>
<tr>
    <th>Plan</th>
    <th>Segment</th>
    <th>Class</th>
    <th>Position/Customer</th>
    <th>FC Level</th>
    <th>Last Updated On</th>
    <th>Last Updated By</th>
    <th>Action</th>
</tr>
</thead>
<tbody>

<cfset vars.quarter = 1>
<cfset productsDetail = "<a class='products'>" & application.util.string.actionLinkFormat("detail") & "</a>">
<cfsetting enablecfoutputonly="true">
<cfloop query="main.qVFLevels">
<cfif main.qVFLevels.Forecast_Level eq 4>
	<cfset customersDetail = "">
<cfelse>
	<cfset customersDetail = "<a class='customers'>" & application.util.string.actionLinkFormat("detail") & "</a>">
</cfif>
<cfoutput><tr l143="#main.qVFLevels.VF_Level_ID#" v451="#main.qVFLevels.vf_Plan_Id#"></cfoutput>
 <cfoutput><td>#trim(main.qVFLevels.Plan_Name)# &nbsp;&nbsp;&nbsp;#productsDetail#</td></cfoutput>
 <cfoutput><td>#trim(main.qVFLevels.Segment_Name)#</td></cfoutput>
 <cfoutput><td>#trim(main.qVFLevels.Class_Name)#</td></cfoutput>
 <cfoutput><td>#trim(main.qVFLevels.Level_Name)#  &nbsp;&nbsp;&nbsp;#customersDetail#</td></cfoutput>
 <cfoutput><td><cfif main.qVFLevels.Forecast_Level eq 1>#application.returned_customer_setting.Zone_Label_Singular#<cfelseif main.qVFLevels.Forecast_Level eq 2>#application.returned_customer_setting.Region_Label_Singular#<cfelseif main.qVFLevels.Forecast_Level eq 3>#application.returned_customer_setting.Market_Label_Singular#<cfelseif main.qVFLevels.Forecast_Level eq 4>#application.returned_customer_setting.Distributor_Label_Singular#</cfif></td></cfoutput>
 <cfoutput><td>#application.util.datetime.DateTimeFormat(main.qVFLevels.Last_Updated_On)#</td></cfoutput>
 <cfoutput><td>#main.qVFLevels.Updated_By#</td></cfoutput>
 <cfset vars.fiscal_year = right(main.qVFLevels.Year_Selection, 4)>
 <!--- volume fc for current/past year, open it in 4th quarter --->
 <cfif val(vars.fiscal_year) lte year(now())>
 	 	<cfset vars.quarter = 4>
 <cfelse>
		<!--- volume fc for future year, open it in 1st quarter --->
 	 	<cfset vars.quarter = 1>
 </cfif>
 <cfoutput><td class="action"><button class="open" id="v451=#main.qVFLevels.vf_Plan_Id#&l143=#main.qVFLevels.VF_Level_ID#&q636=#vars.quarter#">Open</button>&nbsp;
 																 <button class="notes" <!---l143="#main.qVFLevels.VF_Level_ID#"--->>Notes</button>
           </td></cfoutput>
<cfoutput></tr></cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false">
</tbody>
</table>
</div>
<!--- </fieldset> --->

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="quarterNumericValue" output="false" hint="I return the quarter number.">
	<cfargument name="baseDate" required="false" type="date" hint="I am the based date.">

	<cfset var l = {}>

	<cfif StructKeyExists(arguments, "baseDate")>
		<cfset l.thisMonth = Month(arguments.baseDate)>
	<cfelse>
		<cfset l.thisMonth = Month(now())>
  </cfif>

	<cfif l.thisMonth gte 6 and l.thisMonth lte 8>
		<cfreturn 1>
	<cfelseif l.thisMonth gte 9 and l.thisMonth lte 11>
		<cfreturn 2>
	<cfelseif l.thisMonth eq 12 or l.thisMonth eq 1 or l.thisMonth eq 2>
		<cfreturn 3>
	<cfelse>
		<cfreturn 4>
	</cfif>

</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfset datatables.version = "1.9.1">

<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"></script>

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<!---<script type="text/javascript" src="/script/javascript/FixedHeader.min.js"></script>--->

<script type="text/javascript">
var windowHeight = $(window).height(), headerHeight = 185, sScrollY = windowHeight - headerHeight;
// adjust column headings & font size to fit small screen
if ($(window).width() < 1400) {
  $("th, td").css("font-size", "0.85em");
}
var oTable = $('#listVF').dataTable({
   "sDom": <cfif main.qVFLevels.recordCount gt 500>'fp<"vftotal">tip'<cfelse>'f<"vftotal">ti'</cfif>
  ,"bSortClasses": false
  ,"bAutoWidth": false            // false for quicker rendering
	,"iDisplayLength": 500
	,"aaSorting": []            // no default sorting for better speed
	,"fnDrawCallback": function() {
			// bind click event to open buttons here instead of outside for better performance
			$('.open').click(function(){
				window.open('g500/vfbymonth.cfm?' + $(this).attr('id')
										, 'workbook'
										, 'left=0, top=0, width=' + screen.width + ', height=' + screen.height + ', toolbar=0, location=yes, menu=yes, scrollbars=yes, resizable=yes');
			});
			$('.notes').click(function(){
				// alert( $(this).parents('tr').attr('l143') );
				NewWindow('/common_files/volume/g500/vfnotes.cfm?l143=' + $(this).parents('tr').attr('l143'),'vfnotes','870','620','Yes', 'No');
			});
	}
  ,"aoColumns": [   {"bSortable":true,  "bSearchable":true}
                  , {"bSortable":false, "bSearchable":true}
                  , {"bSortable":false, "bSearchable":true}
                  , {"bSortable":true,  "bSearchable":true}
                  , {"bSortable":false, "bSearchable":true}
                  , {"bSortable":false, "bSearchable":false}
                  , {"bSortable":false, "bSearchable":false}
                  , {"bSortable":false, "bSearchable":false} ]
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
    ,"sScrollY": sScrollY
}).fnSetFilteringDelay();
<cfif main.qVFLevels.recordCount>
  	$('div.vftotal').html("<button id='vftotal'>Volume Forecast Total</button>");
</cfif>

$('#vftotal').click(function(){
	<cfoutput>window.open('g500/vfTotalbyMonth.cfm?q636=1&user_position_id=all'</cfoutput>
							, 'vftotal'
							, 'left=0, top=0, width=' + screen.width + ', height=' + screen.height + ', toolbar=0, location=yes, menu=yes, scrollbars=yes, resizable=yes');
});
$('.products').click( function() {
									var $parentTR = $(this).parents('tr');
									NewWindow('/common_files/volume/g500/productsDetail.cfm?v451=' + $parentTR.attr('v451')
								                                                    + '&l143=' + $parentTR.attr('l143'),'vfproducts','870','620','Yes', 'No', 'yes', 'no');
								});
$('.customers').click( function() {
									var $parentTR = $(this).parents('tr');
									NewWindow('/common_files/volume/g500/customersDetail.cfm?v451=' + $parentTR.attr('v451')
									                                                     + '&l143=' + $parentTR.attr('l143'),'vfcustomers','870','620','Yes', 'No', 'yes', 'no');
									});
$('#filter').click( function() {
									if ( $('#byClassIDs').val() ) {
										$(this).html('One moment... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">');
										$('#vfForm').submit();
									}
									else {
										alert( 'Please select at least one class.' );
									}
								} );
$("#byClassIDs").multiselect( { minWidth: "200", selectedList: 3 });
$('#f1').show();
$(window).resize(function() {
  $('.dataTables_scrollBody').css('height', ($(window).height() - headerHeight));
  oTable.fnDraw();
} );
</script>
</cfmodule>