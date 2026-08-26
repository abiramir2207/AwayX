<!---
Name:blendedCalculation.cfm
Copyright (c) 2016 Blacksmith Applications, Inc.
Description: Used to export Blended rate
--->
<!DOCTYPE html>

<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
<cfscript>
	BlendedRatefunc = CreateObject("component", "components.programs.rebates.rebate");
	BlendedRateReport = BlendedRatefunc.BlendedRateCalReport(cryp.value);
</cfscript>

<cfset PAGETITLE = #BlendedRateReport.Contract_Number# & " Blended Rate Calculation">
<cfinclude template="/settings/settings_title.cfm">
<cfinclude template="/Script/cf/string_functions.cfm">
<cfsavecontent variable="exportContent">
	<a onclick="getCSVData();" style="cursor:pointer"><b><font color="FF0000">[ </font> export <font color="FF0000">]</font></b>	</a>
</cfsavecontent>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/styles/rowGroup.dataTables.min.css">

<table class="datagrid" id="datagrid">
	<thead>
		<tr>
			<th style="display:none"></th>
			<th style="font-weight: normal;text-align: center;">Item</th>
			<th style="font-weight: normal;text-align: center;">Description</th>
			<th style="font-weight: normal;text-align: center;">Invoice <br>Vol <cfoutput>#BlendedRateReport.Abbreviation_Singular#</cfoutput></th>
			<th style="font-weight: normal;text-align: center;">Recapture <br>Vol <cfoutput>#BlendedRateReport.Abbreviation_Singular#</cfoutput></th>
			<th style="font-weight: normal;text-align: center;">Base <br>Vol <cfoutput>#BlendedRateReport.Abbreviation_Singular#</cfoutput></th>
			<th style="font-weight: normal;text-align: center;">Base <br>Rate</th>
			<th style="font-weight: normal;text-align: center;">Discount <br>Rate</th>
			<th style="font-weight: normal;text-align: center;">Adjustment <br>Rate</th>
		  <th style="font-weight: normal;text-align: center;">Calculated <br>Rate</th>
			<th style="font-weight: normal;text-align: center;">Rate</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="BlendedRateReport">
		<tr>
			<td style="display: none">#GroupDescription#</td>
			<td>#Item#</td>
			<td>#Description#</td>
			<td align="center"><cfif Invoice_Volume GTE 0>#NumberFormat(Invoice_Volume)# <cfelse> #NegativeFormat(NumberFormat(Replace(Invoice_Volume,'-','')))#</cfif></td>
			<td align="center"><cfif Recapture_Volume GTE 0>#NumberFormat(Recapture_Volume)# <cfelse>#NegativeFormat(NumberFormat(Replace(Recapture_Volume,'-','')))#</cfif></td>
			<td align="center"><cfif Base_Volume GTE 0>#NumberFormat(Base_Volume)#<cfelse>#NegativeFormat(NumberFormat(Replace(Base_Volume,'-','')))#</cfif></td>
			<td align="center">#DollarFormat(Blended_Base_Rate)#</td>
			<td align="center">#DollarFormat(Blended_Disc_Rate)#</td>
			<td align="center">#DollarFormat(Blended_Adj_Rate)#</td>
			<td align="center">#DollarFormat(Blended_Calc_Rate)#</td>
			<td align="center">#DollarFormat(Rate)#</td>
		</tr>
	</cfoutput>
	</tbody>
</table>
<cfset fileName = #BlendedRateReport.Contract_Number#&" Blended Rate Calculation.csv">
<form action="/common_files/csv.cfm" method ="post" id="csv_form">
  <input type="hidden" name="csv_text" id="csv_text">
  <input type="hidden" name="csv_file_name" id="csv_file_name" value="<cfoutput>#fileName#</cfoutput>">
</form>

<cfset colList ='Invoice,Recapture,BaseVol,BaseRate,DiscountRate,AdjRate,CalRate,Rate'>
<cfset colVal = 3>


<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables2.cfm">
<script type="text/javascript" src="/Script/javascript/dataTables.rowGroup.min.js"></script>
<script type="text/javascript" src="/Script/javascript/table2csv.js"></script>
<cfoutput>
<script>
var grid = $('table##datagrid').DataTable({
     "bAutoWidth": false
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": "f<'save'>ti"
    ,"aaSorting": [[ 1, "asc" ]]
    ,"aoColumns": [
				  {"bSearchable": true, 		"bSortable":true}
				,	{"bSearchable": true, 		"bSortable":true}
				, {"bSearchable": true, 		"bSortable":true}
				, {"bSearchable": false, 	"bSortable":true}
				, {"bSearchable": false, 	"bSortable":true}
				, {"bSearchable": false, 	"bSortable":true}
				, {"bSearchable": false, 	"bSortable":true}
				, {"bSearchable": false, 	"bSortable":true}
				, {"bSearchable": false, 	"bSortable":true}
				, {"bSearchable": false, 	"bSortable":true}
				, {"bSearchable": false, 	"bSortable":true}
				]
		,"rowGroup": { startRender: null,
				endRender: function ( rows, group ) {
					
					<cfloop from="1" to="#listlen(colList)#" index="col">
					
                var #listgetat(colList,col)# = rows
                    .data()
                    .pluck(#colVal#)
                    .reduce( function (a, b) {
                        return a + b.replace(/[^\d]/g, '')*1;
                    }, 0) ;
								<cfif col GT 3>
										#listgetat(colList,col)# = $.fn.dataTable.render.number(',', '.', 2, '$').display( #listgetat(colList,col)# ); 
								<cfelse>
										#listgetat(colList,col)# = $.fn.dataTable.render.number(',', '.', 0, '').display( #listgetat(colList,col)# ); 
								</cfif>
                <cfset colVal = colVal + 1>            
          </cfloop>
                    return $('<tr/>')
                    .append( '<td> &nbsp;</td>' )
                    .append( '<td>'+group+'</td>' )
                    <cfloop from="1" to="#listlen(colList)#" index="col">
													.append( '<td align=center> '+ #listgetat(colList,col)#+'</td>' )
                    </cfloop>
            },
            dataSrc: 0
        }
  })
<!--- hovering background color switching --->
$('table##datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

$('div.save').html('#application.util.string.compress(exportContent)#');

getCSVData = function() {
 var csv_value = $('##datagrid').table2CSV({
                                            csvExclude: 'csvExclude'         // filter out elements with csvExclude class
                                         });
// $("##csv_file_name").val("Blended Rate" + '' + $.datepicker.formatDate('mm-dd-yy', new Date()) + '.csv');
 $("##csv_text").val(csv_value);
 $("##csv_form").submit();
}
</script>
</cfoutput>
