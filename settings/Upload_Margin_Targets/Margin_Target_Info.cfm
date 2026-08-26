<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<cfparam name="url.download" default="0" >
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset PAGETITLE = 'Current '&#appSettings.getMarginColHeader26()#>
<cfinclude template="/settings/settings_title.cfm">

<cfset UploadMargins = CreateObject("component","components.settings.upload_margin_Targets.uploadMarginTargets") />
<cfset qMTInfo = UploadMargins.getAllTargets(url.download) />
<cfset qFilters = UploadMargins.ProductFilters() />
<style>
	.options{ 
		float: right; 
		text-align:left;
	}
</style>

<table class="datagrid" style="width: 100%">	
	<thead>
		<tr>
			<th style="width:100px"><cfoutput>#application.returned_customer_setting.item_label# ##</cfoutput></th>
			<th style="width:250px">Description</th>
			<th style="width:75px">Distribution<br>Channel</th>
			<th style="width:250px">
				<select id="productAttributes">
					<option value="0">Filter by Product Attributes</option>
				<CFOUTPUT QUERY="qFilters" GROUP="Category" GROUPCASESENSITIVE="No">
				  <optgroup label="#Category#">
				  	<CFOUTPUT>
				    <option value="[#replace(category,' ','','all')# = #ID#]">#Description#</option>
				    </CFOUTPUT>
				  </optgroup>
				</CFOUTPUT>
				</select>				
			</th>
			<th style="width:150px;text-align:center">Net Sales<br>Target Value</th>
			<th style="width:150px;text-align:center">Net Sales<br>Floor Value</th>
			<th style="width:150px;text-align:center">Gross Margin<br>Target Value</th>
			<th style="width:150px;text-align:center">Gross Margin<br>Floor Value</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="qMTInfo">
		<tr ProdvarA='#Prod_Var_A_ID#', Brand='#Brand_ID#', TypeCode='#Type_Code_Desc_ID#', TypeGroup='#Type_Group_Desc_ID#', QBrand='#Q_Brand_ID#'>
			<td>#item#</td>
			<td>#Description#</td>
			<td>#Distribution_Channel#</td>
			<td>#Type_Code_Desc#</td>
			<td align="right">#NumberFormat(Net_Sales_Target_Value,'$(9.99999)')#</td>
			<td align="right">#NumberFormat(Net_Sales_Floor_Value,'$(9.99999)')#</td>
			<td align="right">#NumberFormat(GM_Target_Value,'$(9.99999)')#</td>
			<td align="right">#NumberFormat(GM_Floor_Value,'$(9.99999)')#</td>
		</tr>
	</cfoutput>
	</tbody>
</table>


<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables2.cfm">

<script>
	var oTable = $('table.datagrid').DataTable({
		"columnDefs": [
								  {"targets": [0],"sortable":true,  "searchable":true }
								, {"targets": [1],"sortable":true,  "searchable":true }
								, {"targets": [2],"sortable":true,  "searchable":true }
								, {"targets": [3],"sortable":false,  "searchable":false }
								, {"targets": [4],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
								, {"targets": [5],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
								, {"targets": [6],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
								, {"targets": [7],"sortable":true,  "searchable":false, "type":"html-num-fmt" }														
		]
		,"lengthChange": false
		,"pageLength": 500
		,"pagingType": "simple"
		,"sDom": 'f<"options">tip'
		,"bFilter": true
		,"scrollY": Math.floor(jQuery(window).height()) - 175
		,"scrollX": true
	})

	<cfoutput>
		$('div.options').html("<a href='javascript:reloadPage(1)'>#application.util.string.actionLinkFormat2('download')#</a>");
	</cfoutput>

$('#productAttributes').change(function() {
	if($(this).val() != 0){
    	$(".datagrid tbody tr").hide().filter($(this).val()).show();
    }else{
    	$(".datagrid tbody tr").show();
    }
}).change(); 
  
$('.dataTables_filter input').attr('title', 'Search against Product, Description, Distributon Channel');	

function reloadPage(download){
		var queryParameters = {}, queryString = location.search.substring(1),
		    re = /([^&=]+)=([^&]*)/g, m;

		// Creates a map with the query string parameters
		while (m = re.exec(queryString)) {
		    queryParameters[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
		}
		queryParameters['download'] = download;
		location.search = $.param(queryParameters); // Causes page to reload
	}
</script>