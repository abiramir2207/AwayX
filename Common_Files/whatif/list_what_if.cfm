<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\whatif\list_what_if.cfm
      Label:    45383
      Date:     2014 October
      Author:   Chris Nguyen
      Purpose:  Manage what if generic ( no program )

      Notes:

----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html>
<head>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  <style>
  #opt947 { margin: 0px 0 8px 0; }
  #opt947 a, .action a { margin: 0 10px 0 0; }
  td { vertical-align: top; }
  .columnfilter { width:99%; }
  form[name=listWhatIF] { margin:0; }
  .btn-primary { background-color:blue; color:white; font-weight:bold; }
  </style>
</head>

<body>
<cfset variables.notifyMessage = "">
<cfif CGI.Request_Method eq "post">
    <cfset variables.whatIfCFC = createObject("component", "components.programs.whatif")>
    <cfif form.action eq "delete">
        <cfset variables.whatIfCFC.zapWhatIf( form.id )>

    <cfelseif form.action eq "edit">
      <!--- attemp to lock record --->
        <cfset variables.notifyMessage = variables.whatIfCFC.updateLock( form.id, form.action )>
        <!--- lock was a success, redirect to next page otherwise stay and display a message --->
        <cfif variables.notifyMessage eq "">
          <cflocation addtoken="false" url="/common_files/whatif/edit_what_if.cfm?id=#form.id#">
        </cfif>
    <cfelseif form.action eq "unlock">
      <!--- attemp to unlock record --->
        <cfset variables.notifyMessage = variables.whatIfCFC.updateLock( form.id, form.action )>
    </cfif>
</cfif>

<div id="opt947">
  <cfoutput>
   <a href="/common_files/whatif/edit_what_if.cfm?id=0">#application.util.string.actionLinkFormat2("create new", "important")#</a>
   <a href="##" onclick="$('body').fadeOut(350); window.location = location.href;">#application.util.string.actionLinkFormat2("refresh")#</a>
   <a href="/Manufacturers/home.cfm">#application.util.string.actionLinkFormat2("return home")#</a>
  </cfoutput>
</div>

<cfscript>
  variables.columnSizes = [1, 2, 1.25, 1.25, 1, 1.25];
  variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes );

  variables.whatIfCFC   = createObject("component", "components.programs.whatif");
  variables.qWhatIf     = variables.whatIfCFC.getWhatIf('all');

  variables.qCreators   = variables.whatIfCFC.getCreators();
</cfscript>

<form name="listWhatIF" method="post">
<input type="hidden" name="id">
<input type="hidden" name="action">
<table id="datagrid" class="datagrid" style='table-layout:fixed;width:100%;'>
  <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
  <cfoutput>
	<thead>
    <tr>
      <th>Title</th>
      <th>Description</th>
      <th>Created By<br>
          <select class="columnfilter" id="creator">
              <option> </option>
              <cfloop query="variables.qCreators">
                  <option <cfif variables.qCreators.created_by eq request.AccessStructure.User_ID>selected</cfif>>#variables.qCreators.Full_Name#</option>
              </cfloop>
          </select>
      </th>
      <th>Last Modified By</th>
      <th>Locked By</th>
      <th>Action</th>
    </tr>
  </thead>
  </cfoutput>

  <!--- stuff the content of tbody into a variable so we can remove extra white space easily --->
  <cfsavecontent variable="variables.tbody">
		<cfoutput query="variables.qWhatIf">
			<tr>
				<td>#variables.qWhatIf.Title#</td>
        <td>#application.util.string.fullLeft(variables.qWhatIf.Description, 100)#</td>
        <!--- <td>#dateFormat(variables.qWhatIf.Created_Date, 'medium')#</td> --->
        <td>#variables.qWhatIf.Creator#</td>
        <!--- <td></td> --->
        <td>#variables.qWhatIf.Modifier# <cfif isDate(variables.qWhatIf.Modified_Date)>on #dateFormat(variables.qWhatIf.Modified_Date, 'medium')#</cfif></td>
        <td>#variables.qWhatIf.Editor#</td>
        <td class="action">
          <a href="/common_files/whatif/edit_what_if_product.cfm?id=#variables.qWhatIf.WhatIf_ID#&ro36=1">#application.util.string.actionLinkFormat2("view")#</a>
          <!--- allow to edit if it is not locked --->
          <cfif variables.qWhatIf.locked_by eq "" or variables.qWhatIf.locked_by eq request.AccessStructure.User_ID>
            <a href="##" onclick="edit11(#variables.qWhatIf.WhatIf_ID#);">#application.util.string.actionLinkFormat2("edit")#</a>
          </cfif>
          <!--- allow to unlock if possible --->
          <cfif variables.qWhatIf.locked_by eq request.AccessStructure.User_ID>
            <a href="##" onclick="unlock11(#variables.qWhatIf.WhatIf_ID#);">#application.util.string.actionLinkFormat2("unlock")#</a>
          </cfif>
          <!--- only creator can delete --->
          <cfif variables.qWhatIf.created_by eq request.AccessStructure.User_ID and variables.qWhatIf.locked_by eq "">
            <a href="##" onclick="zap(#variables.qWhatIf.WhatIf_ID#);">#application.util.string.actionLinkFormat2("delete")#</a>
          </cfif>
        </td>
			</tr>
		</cfoutput>
	</cfsavecontent>
	<tbody>
		<cfoutput>#application.util.string.compress(variables.tbody)#</cfoutput>
	</tbody>
</table>
</form>

<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>

<script>
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .75 : .45) * windowHeight;
$(function() {
  var mydatagrid = $('#datagrid').show().dataTable({
       "aaSorting": []
      ,"aoColumns": [
                       {"bSortable":true, "bSearchable":true}
                      ,{"bSortable":true,  "bSearchable":true}
                      ,{"bSortable":false,  "bSearchable":true}
                      ,{"bSortable":true,  "bSearchable":true}
                      ,{"bSortable":false,  "bSearchable":true}
                      ,{"bSortable":false,  "bSearchable":false}
                    ]
      ,"bAutoWidth": false
      ,"bPaginate": true
      ,"bScrollCollapse": false
      ,"bSortClasses": false
      // ,"bStateSave": true
      ,"iDisplayLength": 250
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"sScrollY": sScrollY         <!--- data grid height --->
      ,"sDom": 'fptipr'
    }).fnSetFilteringDelay();

  $('#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

  /* filter by dropdowns */
  $("thead th").each( function ( i ) {
      if ( $(this).find("select.columnfilter") ) {
          $('select', this).change( function () {
              mydatagrid.fnFilter( $(this).val(), i );
          });
      }
  });

  mydatagrid.fnFilter( $("#creator").val(), 2 );
});

$('#Page_Title', window.parent.frames[0].document).text("What If P&L");

function edit11( id ) {
   $('body').hide();
   $('input[name=id]').val( id );
   $('input[name=action]').val( 'edit' );
   $('body').hide(350);
   $('form[name=listWhatIF]').submit();
}

function unlock11( id ) {
   $('body').hide();
   $('input[name=id]').val( id );
   $('input[name=action]').val( 'unlock' );
   $('body').hide(350);
   $('form[name=listWhatIF]').submit();
}

function zap( id ) {
  noty( { text: "Click <b>Delete</b> to remove the selected record, otherwise click Cancel."
          ,type:'confirm'
          ,layout:'center'
          ,animation: { open: {height: 'toggle'}, close: {height: 'toggle'}, easing: 'swing', speed: 250 }
          ,buttons: [  { text:'Delete', addClass:'btn-primary', onClick:function($noty) {  $noty.close();
                                                                                           $('body').hide();
                                                                                           $('input[name=id]').val( id );
                                                                                           $('input[name=action]').val( 'delete' );
                                                                                           $('body').hide(350);
                                                                                           $('form[name=listWhatIF]').submit();
                                                                                       } }
                      ,{ text:'Cancel', onClick:function($noty) { $noty.close(); } } ]
        });
}

<cfif variables.notifyMessage neq "">
  noty( { text: "<cfoutput>#variables.notifyMessage#</cfoutput>"
          ,type:'information'
          ,timeout: 10000
          ,layout:'bottom'
          ,closeWith: ['click']
        });
</cfif>
</script>
</body>
</html>