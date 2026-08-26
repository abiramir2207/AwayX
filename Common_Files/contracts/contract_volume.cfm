<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\contract_volume.cfm
      Date:     2014 Jan
      Author:   Chris Nguyen
      Purpose:  List volume information
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <title>Program - Volume</title>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  <link rel="stylesheet" type="text/css" href="/common_files/TableTools.css">
  <style>
  .action { font-weight:bold; margin:0 3px 0 3px; }
  .right { text-align:right; }
  .even { background-color:#efe; }
  div.head span {
    display: inline-block;
  }
  div.head {
    margin-top:5px;
    font-size:1.15em;
    font-weight:bold;
    color:navy;
  }
  </style>
</head>

<body>
<cfset appSettings = application.appSettingsGet />
<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<!--------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<cfset Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
<cfset Program_Volume.Load_Basic_Information(URL.Program_ID, request.AccessStructure.Company_Main_ID)>
<cfset bidExcludeLostFromVolumeAuto = 0 />
<cfif Program_Volume.BidRequestStatusOn eq 1 AND Program_Volume.ItemMarked_Lost_Program_Volume_Automation eq 0 >
  <cfquery name="ProgramBidRequestStatusID" datasource="#application.datasource#">
    SELECT  TOP 1 Bid_Request_status_ID FROM Program_Bid_Request WHERE Deleted = 0 AND Program_ID = '#URL.Program_ID#'
  </cfquery>
  <cfif ProgramBidRequestStatusID.recordcount GT 0 AND ProgramBidRequestStatusID.Bid_Request_status_ID neq 1>
    <cfset bidExcludeLostFromVolumeAuto = 1 />
  </cfif>
</cfif>

<cfset programDetails = CreateObject("component", "mvc.Models.Program.Volume.VolumeApplicator") />
<cfset qryProgramDetails = programDetails.getProgramDetails(url.Program_ID, request.AccessStructure.User_ID) />

<cfset bidLostItems = ''>
<cfif bidExcludeLostFromVolumeAuto EQ 1>
  <cfquery NAME="getBidLostItems" DATASOURCE="#application.datasource#">
    SELECT DISTINCT PROGRAM_PRODUCT_BID_INFO.Product_Id
      FROM PROGRAM_BID_REQUEST
           INNER JOIN PROGRAM_PRODUCT_BID_INFO ON PROGRAM_PRODUCT_BID_INFO.Program_Id = PROGRAM_BID_REQUEST.Program_Id
                                                  AND PROGRAM_PRODUCT_BID_INFO.Won = 0
                                                  AND PROGRAM_PRODUCT_BID_INFO.Deleted = 0
     WHERE PROGRAM_BID_REQUEST.Program_Id = <cfoutput>#url.program_ID#</cfoutput>
           AND PROGRAM_BID_REQUEST.Bid_Request_Status_Id != 1
           AND PROGRAM_BID_REQUEST.Deleted = 0
  </cfquery>
  <cfset bidLostItems = valueList(getBidLostItems.PRODUCT_ID)>
</cfif>

<table border="0" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td colspan="100%">
      <cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
      #application.returned_customer_setting.company_name#</DIV>
      <B><font size="+1" color="Navy">
          [#Program_Volume.Contract_Number#] - #Program_Volume.Contract_Title#
      </FONT></B>
    </td>
  </tr>
</table>

<div class="head">
  <span style="width:30%;">Program Volume</span>
  <span style="width:69%;text-align:right;">#qryProgramDetails.Contract_Start_Date# - #qryProgramDetails.Contract_End_Date# (#qryProgramDetails.Contract_Span#)</span>
</div>
<HR COLOR="Navy">


<table id="datagrid" class="datagrid" style="table-layout:fixed;">
  <col width="15%"> <col width="33%"> <col width="13%"> <col width="13%"> <col width="13%"> <col width="13%">
  <thead>
  <tr>
  <cfif (appSettings.get_Setting('Display_Item_No') EQ '1')>
    <th>#application.returned_customer_setting.item_label# ##</th>
  <cfelse>
  	<th>#application.returned_customer_setting.upc_label# ##</th>
  </cfif>
    <th>Description</th>
    <th class="right">Annual Volume<br>Case</th>
    <th class="right">Annual Volume<br>Pound</th>
    <th class="right">Program Volume<br>Case</th>
    <th class="right">Program Volume<br>Pound</th>
  </tr>
  </thead>
  <tfoot>
    <tr>
      <th colspan="2" class="right"><b>Total Volume:</b></th>
      <th id="totalAnnualvolumeCS">&nbsp;</th>
      <th id="totalAnnualvolumeLB">&nbsp;</th>
      <th id="totalUOTVolumeCS">&nbsp;</th>
      <th id="totalUOTVolumeLB">&nbsp;</th>
    </tr>
  </tfoot>
  <tbody>
  </tbody>
</table>
<div style="clear:both"></div>
<div style="margin:10px" id="actions">
 <a href="##" id="close">#application.util.string.actionLinkFormat("close")#</a>
 <a href="##" id="print" style="margin-left:15px;">#application.util.string.actionLinkFormat("print")#</a>
 <a href="javascript:exportAll();" style="margin-left: 25px;">#application.util.string.actionLinkFormat("export all")#</a>
</div>

<!--- export to csv form --->
<form action="/common_files/csv.cfm" method ="post" id="csv_form">
		<input type="hidden" name="csv_text" id="csv_text">
		<input type="hidden" name="csv_file_name">
</form>

<cfset csvContract_Title = #REReplace(Program_Volume.Contract_Title,"[^0-9A-Za-z ]","","all")#>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script type="text/javascript">
var windowHeight = $(window).height();
var grid = $('#datagrid').dataTable({
	 "bPaginate": true
  ,"bServerSide": true
  ,"bProcessing": true
  ,"iDisplayLength": 100
  ,"sAjaxSource": <cfoutput>"ajax/contract_volume.cfm?program_id=#url.program_id#"
                                                  + "&contract_span=#qryProgramDetails.Contract_Span#"
                                                  + "&bidLostItems=#bidLostItems#"</cfoutput>
  ,"fnServerData": function ( sSource, aoData, fnCallback ) {
      $.ajax( {   "dataType": 'json'
                , "type": "GET"
                , "url": sSource
                , "data": aoData
                , "success": function(json) { var $tfoot = $('div.dataTables_scrollFootInner');
                                              $tfoot.find('#totalAnnualvolumeCS').text(json.TOTALANNUALVOLUMECS);
                                              $tfoot.find('#totalAnnualvolumeLB').text(json.TOTALANNUALVOLUMELB);
                                              $tfoot.find('#totalUOTVolumeCS').text(json.TOTALUOTVOLUMECS);
                                              $tfoot.find('#totalUOTVolumeLB').text(json.TOTALUOTVOLUMELB);
                                              fnCallback(json); }
      } );
  }
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"bAutoWidth": false
  ,"sDom": 'fptipr'
  ,"aaSorting": []
  ,"sScrollY": ( windowHeight > 800 ? .75 : .55) * windowHeight         <!--- data grid height --->
  ,"aoColumnDefs": [
                     { "aTargets":[0], "bSortable":true }
                    ,{ "aTargets":[1], "bSortable":true }
                    ,{ "aTargets":[2], "bSortable":false, "sClass":"right" }
                    ,{ "aTargets":[3], "bSortable":false, "sClass":"right" }
                    ,{ "aTargets":[4], "bSortable":false, "sClass":"right" }
                    ,{ "aTargets":[5], "bSortable":false, "sClass":"right" }
                   ]
  ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
}).fnSetFilteringDelay();
<!--------------------------------------------------------------------------------------------------------------------->
$('#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
$('#close').click(function() { window.close(); })
$('#print').click(function() { window.print(); })

function exportAll() {
  	<cfoutput>
  	popupInCenter( "/Common_Files/exportAll.cfm?" 	+ "program_id=#url.program_ID#"
													+ "&type=program_volume"
                                              		+ "&contract_span=#qryProgramDetails.Contract_Span#"
												  	+ "&friendlyFileName=#urlEncodedFormat('program_volume')#"
													,"", 800, 200 );
	</cfoutput>
}

</script>

<CFPARAM NAME="URL.Contract_ID" DEFAULT="">
<!--- "URL.Contract_Main_ID" is being passed from "components/volume/volumeApplicator.cfc". This Parameter is
      to show the Retail Page --->
<cfif URL.Contract_ID neq "">
  <script language="javascript">
    <cfquery name="GetSettings" datasource="#application.datasource#">
      SELECT * FROM
      Program_Control_Panel_Options PCPO INNER JOIN Contract_Main CM
      ON PCPO.ProgramControl_Panel_Options_ID = CM.Programtype_ID
      WHERE CM.Contract_Main_ID = '#trim(URL.Contract_ID)#'
    </cfquery>
    <cfif GetSettings.Retailer_Info_On EQ 1>
      <CF_CRYP type="en" string="#URL.Contract_ID#" key="#request.key#">
      NewWindow("/common_files/contracts/contract_retailer_info.cfm?CID=<cfoutput>#cryp.value#</cfoutput>",'RetailPage','800','600','Yes', 'No');
    </cfif>
  </script>
</cfif>
</body>
</html>
