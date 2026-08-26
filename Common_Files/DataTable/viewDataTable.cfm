<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\DataTable\viewDataTable.cfm
      Date:     Dec 2012
      Author:   Chris Nguyen
      Purpose:  Reusable code for displaying table using DataTable plugin

      Parameters:
        dt.tableID   =  your unique table ID (required)
        dt.aoColumns =  optional, array of columns settings (see detail at http://www.datatables.net/usage/columns)

      Example of usage from \settings\Rebate_Components\_rebate_component_display.cfm:
        <cfscript>
          dt.tableId = "rebateDataTable";
          dt.aoColumns = [  '"bSearchable":false, "bSortable":false'
                           ,'"bSearchable":true,  "bSortable":true'
                           ,'"bSearchable":true,  "bSortable":true'
                           ,'"bSearchable":false, "bSortable":false'
                           ,'"bSearchable":false, "bSortable":false'
                           ,'"bSearchable":false, "bSortable":false'
                           ,'"bSearchable":false, "bSortable":false'
                           ,'"bSearchable":false, "bSortable":false'
                         ];
        </cfscript>

        <cfinclude template="\common_files\datatable\viewDataTable.cfm">

      Setup prior to including this template:
        1.  Add an unique id to table
        2.  Add class=”datagrid” to table
        3.  Add <thead></thead> to heading
        4.  Replace <td> with <th> in heading section
        5.  Remove all valign=”top” in heading section
        6.  Add <tbody></tbody> to table body
        7.  Remove css classes, background colors assigned to <table>, <tr>, <td>
        8.  Add dt.tableId, dt.aoColumns (optional) assignments
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="dt.trHover" default="on">           <!---  tr hovering setting  --->
<cfparam name="dt.tableHeight" default="0.75">     <!---  height percentage setting ( 1 = 100% ) --->
<cfparam name="dt.sDom" default="fptip">


<cfsavecontent variable="moreCss">
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
</cfsavecontent>
<cfhtmlhead text="#moreCss#">

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js?foo"></script>

<script type="text/javascript">
  var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? <cfoutput>#dt.tableHeight#</cfoutput> : .55) * windowHeight;

  var oTable = $(<cfoutput>'###dt.tableId#'</cfoutput>).dataTable({
       "aaSorting": []
      <cfif structKeyExists(dt, "aoColumns")>
        ,"aoColumns": [ <cfset cnt=0>
                       <cfloop array="#dt.aoColumns#" index="item">
                         <cfset cnt++> <cfif cnt gt 1>,</cfif>{ <cfoutput>#item#</cfoutput> }
                       </cfloop>
                     ]
      </cfif>
      ,"bAutoWidth": false
      ,"bPaginate": true
      ,"bScrollCollapse": true
      ,"bSortClasses": false
			,"iDisplayLength": 500
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"sDom": <cfoutput>'#dt.sDom#'</cfoutput>
      ,"sScrollY": sScrollY         <!--- data grid height --->
    })
    .fnSetFilteringDelay()
    ;

  <!--- tr hovering background color switching --->
  <cfif dt.trHover neq "off">
    $(<cfoutput>'###dt.tableId# tbody'</cfoutput>).on('hover', 'tr', function() { $(this).toggleClass("over"); });
  </cfif>

  $("thead th").each( function ( i ) {
    if ( $(this).html().length && $(this).hasClass("columnfilter") ) {
        // build select tag dynamically if "addselect" class is found
        if ( $(this).hasClass("addselect") ) {
           $(this).html( $(this).html() + '<br/>' + fnCreateSelect( oTable.fnGetColumnData(i) ) );
        }
        $('select', this).change( function () {
            oTable.fnFilter( $(this).val(), i );
        } );
    }
  } );
</script>
