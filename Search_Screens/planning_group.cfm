<!---------------------------------------------------------------------------------------------------------------------
      Template: \Search_Screens\distributor_planning_group.cfm
      Date:     June 22, 2011
      Author:   Chris Nguyen
      Purpose:  Display planning groups, allows users to select & import

      Notes:    Parameters passing to this include are stored in a structure called 'attr'

                attr.pg_group_type:  1 = product, 2 = distributor
                attr.legend       :  the title displayed at the top

                Required URL passed into this template:

                . url.formname
                . url.fieldname
                . url.business_segment_id:  only when business segment is enabled

----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfparam name="url.formname"  default="">
<cfparam name="url.fieldname" default="">
<cfparam name="url.jumpto"    default="">
<html lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title></title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
.tool { position:relative; left:35px; font-size:9pt; font-weight:bold; color:navy; }
.mid { text-align:center; }
</style>
</head>

<body>
<cfif attr.pg_group_type eq "1">        <!---product planning groups--->
  <cfset method_name = "isEnabledForProduct">
<cfelseif attr.pg_group_type eq "2">    <!---distributor planning groups--->
  <cfset method_name = "isEnabledForDistributor">
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<!---retrieve rows to display--->
<cfoutput>
<cfinvoke component = "components.programs.business_segment.BusinessSegmentManager"
    		     method = #method_name#
     returnVariable = "busSegMgr.isEnabled">
</cfinvoke>

<cfquery name="qGroups" datasource="#application.datasource#">
  <cfif attr.pg_group_type eq "1">        <!---product planning groups--->
    SELECT pgt.pg_Type_Id
           , pgt.pg_Type_Code
           , pgt.pg_Type_Name
           , pg_Product_Category_Id     AS Category_ID
           , pg_Product_Category_Code   AS Category_Code
           , pg_Product_Category_Name   AS Category_Name
      FROM pg_Type pgt
           INNER JOIN pg_Product_Category pgpc
             ON pgpc.pg_Type_Id = pgt.pg_Type_Id
                AND pgpc.Active = 1
                AND pgpc.Deleted = 0
               <cfif busSegMgr.isEnabled>
                <cfif url.Business_Segment_Id eq "">
                  AND 1 = 0
                <cfelse>
                  AND pgpc.Business_Segment_Id = #Val(url.Business_Segment_Id)#
                </cfif>
               </cfif>
     WHERE pgt.pg_Group_Type = 1
           AND pgt.Active = 1
           AND pgt.Deleted = 0
  <cfelseif attr.pg_group_type eq "2">    <!---distributor planning groups--->
    SELECT pgt.pg_Type_Id
           , pgt.pg_Type_Code
           , pgt.pg_Type_Name
           , pg_Customer_Category_Id    AS Category_ID
           , pg_Customer_Category_Code  AS Category_Code
           , pg_Customer_Category_Name  AS Category_Name
      FROM pg_Type pgt
           INNER JOIN pg_Customer_Category pgcc
             ON pgcc.pg_Type_Id = pgt.pg_Type_Id
                AND pgcc.Active = 1
                AND pgcc.Deleted = 0
               <cfif busSegMgr.isEnabled>
                <cfif url.Business_Segment_Id eq "">
                  AND 1 = 0
                <cfelse>
                  AND pgcc.Business_Segment_Id = #Val(url.Business_Segment_Id)#
                </cfif>
               </cfif>
     WHERE pgt.pg_Group_Type = 2
           AND pgt.Active = 1
           AND pgt.Deleted = 0
  </cfif>
</cfquery>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;"><cfoutput>#attr.legend#</cfoutput></legend>
<form name="dpg">
<table class="datagrid" id="datagrid">
<thead>
<tr>
 <th class="mid"><input type=checkbox id="toggle_all"></th>
 <th>Planning Group Code</th>
 <th>Name</th>
 <th>Type</th>
</tr>
</thead>
<tbody>
<cfsetting enablecfoutputonly="true" >
<cfloop query="qGroups">
<cfoutput><tr></cfoutput>
  <cfoutput><td class="mid"><input name=g#qGroups.CurrentRow# id=#qGroups.Category_ID# class=cbox type=checkbox <cfif isdefined("url.selected") AND (listfind(url.selected, qGroups.Category_ID))>CHECKED</cfif> /></td></cfoutput>
  <cfoutput><td>#qGroups.Category_Code#</td></cfoutput>
  <cfoutput><td>#qGroups.Category_Name#</td></cfoutput>
  <cfoutput><td>#qGroups.pg_Type_Name#</td></cfoutput>
<cfoutput></tr></cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false" >
</tbody>
</table>

<!---<div style="float:left; width:80px; margin:10px 0 0 330px">--->
<div class="mid">
  <cfoutput><a href="javascript:import_groups();">#Lcase(ActionText("import selected groups"))#</a></cfoutput>
</div>
</form>
</fieldset>

<!--------------------------------------------------------------------------------------------------------------------->

<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.6.1-min.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.datatables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>

<script>
<cfoutput>
if ( window.opener.document.all.#url.formname# == null ) {
  alert("The data needed from the parent form isn't available.\nThis window will close!")
  window.close()
}
</cfoutput>
else {
  var datagrid = $('table#datagrid').dataTable({
  	 "bAutoWidth": true
  	,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"sScrollXInner": "100%"    <!--- value should equal to total of all aoColumns --->
    ,"sScrollY": "370px"         <!--- datagrid height --->
    ,"aaSorting": [[ 1, "asc" ]] <!--- sort on group name column --->
    ,"aoColumns": [   {"sWidth": "10%", "sSortDataType": "dom-checkbox"}
                    , {"sWidth": "30%"}
                    , {"sWidth": "30%"}
                    , {"sWidth": "30%"} ]
  }).fnSetFilteringDelay();
  $('table#datagrid tr').hover (
    function() { $(this).addClass("over"); },
    function() { $(this).removeClass("over"); }
  );
  $(window).resize(function(){
    datagrid.fnAdjustColumnSizing();
  });
  <!---get the list of selected values from parent window--->
  var group_list = <cfoutput>opener.document.all.#url.formname#.#url.fieldname#.value;</cfoutput>
  <!---check the selected rows--->
  $('.cbox').each(function(){
    <!---if this checkbox id is in the parent window list check it--->
    if ( $.ListFind(group_list, $(this).attr('id')) ) {
      $(this).attr('checked', 'checked');
    }
  });
}

<!--------------------------------------------------------------------------------------------------------------------->

<cfoutput>
function import_groups() {
  <!---find all checked nodes (including hidden nodes), gather their ids & join them--->
  opener.document.all.#url.formname#.#url.fieldname#.value = $('.cbox:checked', datagrid.fnGetNodes()).map(function() { return this.id; } ).get().join(',');
  <!---place users at the specified section on the parent page--->
  <cfif len(url.jumpto)>
    opener.document.all.#url.formname#.action = opener.document.all.#url.formname#.action + '###url.jumpto#';
  </cfif>//dr
 <cfif url.formname NEQ "vforecasting">
 opener.document.all.#url.formname#.submit();
 <cfelse>
window.opener.refresh(#url.Business_Segment_Id#);
 </cfif>//dr
  window.close()
}
</cfoutput>

$('#toggle_all').change(function(e){      <!---listen for the change event on the toggle--->
 if ( this.checked )
  $('.cbox').attr('checked','checked');  <!---if checked, select all the checkboxes--->
 else
  $('.cbox').removeAttr('checked');      <!---if not checked, deselect all the checkboxes--->
 e.stopPropagation();
});
$('input,select').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();
</script>
</body>
</html>
