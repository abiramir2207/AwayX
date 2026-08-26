<cfparam name="URL.Status" default="0" >
<cfparam name="URL.UOM_Type" default="2">
<cfparam name="URL.Price_Type" default="1">
<cfparam name="URL.download" default="0"><!---Download Data--->
<cfparam name="URL.attach2program" default="0"><!---Download and attach File to the program--->
<cfparam name="URL.current_Items" default="0"><!---Display Current Items With Margin Targets --->
<cfparam name="URL.FirstParentID" default="0" >
<cfparam name="URL.margin_version" default="">

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<cfset contract_main_id = cryp.value>

<cfset objProgram = CreateObject("component", "components.programs.program") />
<cfset programInfo = CreateObject("component", "components.programs.programManager").getProgramInfoComplete(contract_main_id) />
<cfset PAGETITLE = #programInfo.Contract_Number# &' - '& #appSettings.getMarginColHeader26()#>

<cfinclude template="/settings/settings_title.cfm">

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/styles/fixedColumns.dataTables.min.css">
	
<style>
.options{ 
		float: right; 
		text-align:left;
	}
table{
	margin: 0 auto;
	width: 100%;
	clear: both;
	border-collapse: collapse;
	table-layout: fixed; // ***********add this
	word-wrap:break-word; // ***********and this
	}
</style>

<cfset vars.labelSettings = createObject("component", "components.settings.labels.labels").init() />
<cfset prodlabels = vars.labelSettings.getAllProductAttributes()>

<cfset useLakebaseForgetTypeCodeLabel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("prodlabels")>
<cfif useLakebaseForgetTypeCodeLabel>
	<cftry>
		<cfset getTypeCodeLabel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("prodlabels", {
				"group_internal_label" = "eq.Type Code",
				"select" = "group_level_desc"
			}), "group_level_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetTypeCodeLabel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetTypeCodeLabel>
<cfquery name="getTypeCodeLabel" dbtype="query">
	SELECT Group_level_Desc
	FROM prodlabels
	WHERE Group_Internal_Label = 'Type Code'
</cfquery>
</cfif>

<cfset useLakebaseForgetTypeGroupLabel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("prodlabels")>
<cfif useLakebaseForgetTypeGroupLabel>
	<cftry>
		<cfset getTypeGroupLabel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("prodlabels", {
				"group_internal_label" = "eq.Type Group",
				"select" = "group_level_desc"
			}), "group_level_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetTypeGroupLabel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetTypeGroupLabel>
<cfquery name="getTypeGroupLabel" dbtype="query">
	SELECT Group_level_Desc
	FROM prodlabels
	WHERE Group_Internal_Label = 'Type Group'
</cfquery>
</cfif>

<cfset useLakebaseForgetBrandLabel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("prodlabels")>
<cfif useLakebaseForgetBrandLabel>
	<cftry>
		<cfset getBrandLabel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("prodlabels", {
				"group_internal_label" = "eq.Brand",
				"select" = "group_level_desc"
			}), "group_level_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBrandLabel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBrandLabel>
<cfquery name="getBrandLabel" dbtype="query">
	SELECT Group_level_Desc
	FROM prodlabels
	WHERE Group_Internal_Label = 'Brand'
</cfquery>
</cfif>

<cfset useLakebaseForgetQBrandLabel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("prodlabels")>
<cfif useLakebaseForgetQBrandLabel>
	<cftry>
		<cfset getQBrandLabel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("prodlabels", {
				"group_internal_label" = "eq.Q Brand",
				"select" = "group_level_desc"
			}), "group_level_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetQBrandLabel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetQBrandLabel>
<cfquery name="getQBrandLabel" dbtype="query">
	SELECT Group_level_Desc
	FROM prodlabels
	WHERE Group_Internal_Label = 'Q Brand'
</cfquery>
</cfif>

<cfset useLakebaseForgetProdVarALabel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("prodlabels")>
<cfif useLakebaseForgetProdVarALabel>
	<cftry>
		<cfset getProdVarALabel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("prodlabels", {
				"group_internal_label" = "eq.Prod Var A",
				"select" = "group_level_desc"
			}), "group_level_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProdVarALabel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProdVarALabel>
<cfquery name="getProdVarALabel" dbtype="query">
	SELECT Group_level_Desc
	FROM prodlabels
	WHERE Group_Internal_Label = 'Prod Var A'
</cfquery>
</cfif>

<cfset variables.TypeCodeDesc = replace(getTypeCodeLabel.Group_LeveL_Desc,' ', '', 'All')>
<cfset variables.TypeGroupDesc = replace(getTypeGroupLabel.Group_LeveL_Desc,' ', '', 'All')>
<cfset variables.BrandDesc = replace(getBrandLabel.Group_LeveL_Desc,' ', '', 'All')>
<cfset variables.QBrandDesc = replace(getQBrandLabel.Group_LeveL_Desc,' ', '', 'All')>
<cfset variables.ProdVarADesc = replace(getProdVarALabel.Group_LeveL_Desc,' ', '', 'All')>

<cfset MarginUploadCFC = CreateObject("component","components.settings.upload_margin_Targets.uploadMarginTargets")/>

<!--- Dev Note(79426) - For "blanket bid price" --->
<cfif URL.Price_Type EQ 4>
	<cfset qGetMTData = objProgram.getBlanketBidInfo(contract_main_id,url.uom_type,URL.margin_version,programInfo.contract_Status_Type_IDX)>
	<cfset qFilters = MarginUploadCFC.ProductFilters(contract_main_id, URL.FirstParentID,0) />
<cfelse>
	<cfset qGetMTData = MarginUploadCFC.MarginMatrix(#contract_main_id#,'#programInfo.Contract_Start_Date#','#programInfo.Contract_End_Date#','#programInfo.Contract_Number#',#programInfo.contract_Status_Type_IDX#,#url.Price_Type#,#url.uom_type#,#URL.margin_version#)>
	<cfset qFilters = MarginUploadCFC.ProductFilters(contract_main_id, URL.FirstParentID) />
</cfif>

<table class="datagrid" style="width: 100%;table-layout:fixed;">
<thead>
	<tr>
		<th style="width:100px"><cfoutput>#application.returned_customer_setting.item_label# ##</cfoutput></th>
		<th style="width:225px">Description</th>
		<th class="columnfilter" style="width:250px" >
			<select id="productAttributes" style="margin-left:5px;">
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
	<!--- Dev Note(79426) - For "blanket bid price" --->
	<cfif URL.Price_Type EQ 4>
		<th style="width:65px">Blanket Bid Price</th>
		<th style="width:65px">List Price</th>
		<th style="width:65px">Program Price</th>
		<th style="width:65px">Blanket Variance</th>
		<th style="width:65px">Blanket Variance %</th>
		<th style="width:65px">List Variance</th>
		<th style="width:65px">List Variance %</th>
	<cfelse>
		<cfif URL.Price_Type NEQ 3>
			<th style="width:50px">Type</th>
		</cfif>
			<th style="text-align: center;width:70px">Annual<br>Volume</th>
			<th style="text-align: center;width:70px">Program<br>Volume</th>
		<cfif URL.Price_Type EQ 3>
			<th style="text-align: center;width:100px"><cfoutput>#application.returned_customer_setting.item_label#<br></cfoutput> Net Sales Value</th>
			<th style="text-align: center;width:100px"><cfoutput>#application.returned_customer_setting.item_label#<br></cfoutput> Net Sales Index</th>
		<cfelse>
			<th style="text-align: center;width:100px">Program</th>
			<th style="text-align: center;width:100px">Target</th>
			<th style="text-align: center;width:100px">Target<br>Variance</th>
			<th style="text-align: center;width:100px">Target<br>Variance %</th>
			<th style="text-align: center;width:100px">Floor</th>
			<th style="text-align: center;width:100px">Floor<br>Variance</th>
			<th style="text-align: center;width:100px">Floor<br>Variance %</th>
		</cfif>
	</cfif>
	</tr>
</thead>
<tbody>
<cfoutput query="qGetMTData">
<!--- Dev Note(79426) - For "blanket bid price" --->
<cfif URL.Price_Type EQ 4>
	<cfset bgcolor = 'F8F8F8'>
	<tr style="background-color: ###bgcolor#;" #variables.ProdVarADesc#='#Prod_Var_A_ID#' #variables.BrandDesc#='#Brand_ID#' #variables.TypeCodeDesc#='#Type_Code_Desc_ID#' #variables.TypeGroupDesc#='#Type_Group_Desc_ID#' #variables.QBrandDesc#='#Q_Brand_ID#'>
		<td>#item#</td>
		<td>#description#</td>
		<td><span style="padding-left:5px">#Type_Code_Desc#</span></td>
		<td align="right">#NumberFormat(Blanket_Bid_Price, '(__.__)')#</td>
		<td align="right">#NumberFormat(List_Price, '(__.__)')#</td>
		<td align="right">#NumberFormat(Program_Price, '(__.__)')#</td>
		<td align="right" <cfif Blanket_Variance LT 0>style="color:red"</cfif>>#NumberFormat(Blanket_Variance, '(__.__)')#</td>
		<td align="right" <cfif Blanket_Variance LT 0>style="color:red"</cfif>>#NumberFormat(Blanket_Variance_Percent, '(__.__)')#%</td>
		<td align="right" <cfif List_Variance LT 0>style="color:red"</cfif>>#NumberFormat(List_Variance, '(__.__)')#</td>
		<td align="right" <cfif List_Variance LT 0>style="color:red"</cfif>>#NumberFormat(List_Variance_Percent, '(__.__)')#%</td>
	</tr>
<cfelse>
	<cfif Net_Sales neq "" AND Target_Value neq "" AND Target_Value neq "0.0">
		<cfset TartgetVar = Net_Sales - Target_Value>
		<cfset TartgetVarPer = (( Net_Sales * 100)/Target_Value) - 100>
	<cfelse>
		<cfset TartgetVar = 'N/A'>
		<cfset TartgetVarPer = 'N/A'>
		<cfset Target_Value = 'N/A'>
	</cfif>

	<cfif Net_Sales neq "" AND Floor_Value neq "" AND Floor_Value neq "0.0">
		<cfset FloorVar = Net_Sales - Floor_Value>
		<cfset FloorVarPer = (( Net_Sales * 100)/Floor_Value) - 100>
	<cfelse>
		<cfset FloorVar = 'N/A'>
		<cfset FloorVarPer = 'N/A'>
		<cfset Floor_Value = 'N/A'>
	</cfif>
	
	<cfset bgcolor = 'F8F8F8'>
	<cfif url.price_Type EQ 3>
		<cfif Net_Sales LT Net_Sales_Index>
			<cfset bgcolor = 'ffe9ec'>
		</cfif>
	<cfelse>		
		<cfif isNumeric(TartgetVar) AND TartgetVar LT '0.0'>
			<cfset bgcolor = 'ffe9ec'>
		</cfif>
	</cfif>
	<tr style="background-color: ###bgcolor#;" #variables.ProdVarADesc#='#Prod_Var_A_ID#' #variables.BrandDesc#='#Brand_ID#' #variables.TypeCodeDesc#='#Type_Code_Desc_ID#' #variables.TypeGroupDesc#='#Type_Group_Desc_ID#' #variables.QBrandDesc#='#Q_Brand_ID#'>
		<td style="background-color: ###bgcolor#;">#item#</td>
		<td style="background-color: ###bgcolor#;">#description#</td>
		<td><span style="padding-left:5px">#Type_Code_Desc#</span></td>
	<cfif URL.Price_Type NEQ 3>
		<td>#PriceType#</td>
	</cfif>
		<td align="right">#NumberFormat(Annual_Volume, ',')#</td>
		<td align="right">#NumberFormat(Product_Program_Volume, ',')#</td>
	<cfif URL.Price_Type EQ 3>
		<td align="right" <cfif Net_Sales LT '0.0'> style="color:red"</cfif>>#NumberFormat(Net_Sales,'$(9.99999)')#</td>
		<td align="right" <cfif Net_Sales_Index LT '0'> style="color:red"</cfif>>#NumberFormat(Net_Sales_Index,'(9.99999)')#</td>
	<cfelse>	
		<td align="right">#NumberFormat(Net_Sales,'$(9.99999)')#</td>
		<td align="right"><cfif isNumeric(Target_Value)>#NumberFormat(Target_Value,'$(9.99999)')#<cfelse>#Target_Value#</cfif></td>
		<td align="right"<cfif TartgetVar LT '0.0'> style="color:red"</cfif>><cfif isNumeric(TartgetVar)>#NumberFormat(TartgetVar,'$(9.99999)')#<cfelse>#TartgetVar#</cfif></td>
		<td align="right"<cfif TartgetVarPer LT '0.0'> style="color:red"</cfif> <cfif ! isNumeric(TartgetVarPer)>title='Net Sales is 0'</cfif>><cfif isNumeric(TartgetVarPer)>#NumberFormat(TartgetVarPer,'(9.99999)')# % <cfelse>#TartgetVarPer#</cfif></td>
		<td align="right"><cfif isNumeric(Floor_Value)>#NumberFormat(Floor_Value,'$9.99999')#<cfelse>#Floor_Value#</cfif></td>
		<td align="right"<cfif FloorVar LT '0.0'> style="color:red"</cfif>><cfif isNumeric(FloorVar)>#NumberFormat(FloorVar,'$(9.99999)')#<cfelse>#FloorVar#</cfif></td>
		<td align="right"<cfif FloorVarPer LT '0.0'> style="color:red"</cfif> <cfif ! isNumeric(FloorVarPer)>title='Net Sales is 0'</cfif>><cfif isNumeric(FloorVarPer)>#NumberFormat(FloorVarPer,'(9.99999)')# %<cfelse>#FloorVarPer#</cfif></td>
	</cfif>
	</tr>
</cfif>

</cfoutput>
</tbody>
</table>

<div style="width: 100%;clear: both;text-align:center;margin-top: 10px;">
	<cfoutput>
		<cfif URL.Status LTE 2>
			<!--- Dev Note(79426) - For "blanket bid price" --->
			<cfif URL.Price_Type EQ 4>
			<a href="javascript:exportAll()">#application.util.string.actionLinkFormat2('download')#</a>&nbsp;&nbsp;
			<cfelse>
			<a href="javascript:reloadPage(#UOM_Type#, #Price_Type#, 1, 0)">#application.util.string.actionLinkFormat2('download')#</a>&nbsp;&nbsp;
			</cfif>

			<a href="javascript:reloadPage(#UOM_Type#, #Price_Type#, 0, 1)">#application.util.string.actionLinkFormat2('attach to program')#</a>&nbsp;&nbsp;
		</cfif>
		<a href="javascript:self.close()">#application.util.string.actionLinkFormat2('close window')#</a>
	</cfoutput>
</div>

<cfinclude template="/common_files/jQuery.cfm">
<cfset jQuery.version = "1.12.4">
<cfinclude template="/common_files/dataTables2.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
	var oTable = $('table.datagrid').DataTable({
		"columnDefs": [
								  {"targets": [0],"sortable":true,  "searchable":true }
								, {"targets": [1],"sortable":true,  "searchable":true }
								, {"targets": [2],"sortable":false, "searchable":true }
								<!--- Dev Note(79426) - For "blanket bid price" --->
								<cfif URL.Price_Type EQ 4>
								, {"targets": [3],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
								, {"targets": [4],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
								, {"targets": [5],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
								, {"targets": [6],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
								, {"targets": [7],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
								, {"targets": [8],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
								, {"targets": [9],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
								<cfelse>
									<cfif URL.Price_Type NEQ 3>
									, {"targets": [3],"sortable":true,  "searchable":false}
									</cfif>
									, {"targets": [4],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
									, {"targets": [5],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
									, {"targets": [6],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
									<cfif URL.Price_Type NEQ 3>
									, {"targets": [7],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
									, {"targets": [8],"sortable":true,  "searchable":false, "type":"html-num-fmt" }
									, {"targets": [9],"sortable":true, "searchable":false, "type":"html-num-fmt" }
									, {"targets": [10],"sortable":true, "searchable":false, "type":"html-num-fmt" }
									, {"targets": [11],"sortable":true, "searchable":false, "type":"html-num-fmt" }
									</cfif>
								</cfif>
								]
	//	<cfif URL.Price_Type NEQ 3>,"order": [[ 8, 'desc' ],[ 11, 'desc' ]]</cfif>
		,"Paging": false
		,"sDom": 'f<"options">t'
		,"scrollY": Math.floor(jQuery(window).height()) - 80
		,"scrollX": true
		,"scrollCollapse": true
		,"fixedColumns": {leftColumns: 2}
		,"iDisplayLength": 1000
	})


	<cfoutput>
		$('div.options').html("&nbsp;&nbsp;<B>Type : </B><select id='Price_Type' onchange='reloadPage(#UOM_Type#, $(this).val(), 0, 0);'><option value='1' <cfif URL.Price_Type EQ 1>Selected</cfif>>Net Sales Target/Floor</option><option value='2' <cfif URL.Price_Type EQ 2>Selected</cfif>>GM Target/Floor</option><option value='3' <cfif URL.Price_Type EQ 3>Selected</cfif>>Net Sales Index</option><cfif programInfo.Blanket_Bid_Template eq 1 AND programInfo.Blanket_Bid_Program eq 0><option value='4' <cfif URL.Price_Type EQ 4>Selected</cfif>>Blanket Bid Price</option></cfif></select>&nbsp;&nbsp;&nbsp;&nbsp;<B>UOM :</B><input type='radio' <cfif URL.UOM_Type EQ 1>Checked</cfif> onclick='reloadPage(1, #Price_Type#, 0, 0);'>Cases &nbsp;<input type='radio' <cfif URL.UOM_Type EQ 2>Checked</cfif> onclick='reloadPage(2, #Price_Type#, 0, 0);'>Pound ");
	</cfoutput>


$('#productAttributes').change(function() {
	if($(this).val() != 0){
    	$(".datagrid tbody tr").hide().filter($(this).val()).show();
    }else{
    	$(".datagrid tbody tr").show();
    }
}).change();	
			                             
	/* The default minimum scrollable height of a datagrid is around "300px". We need to reduce the minimum height, so that 
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
		$('.dataTables_scrollBody').css('min-height', '30px');
		$('.dataTables_wrapper').css('min-height', '30px');
		$('.DTFC_ScrollWrapper').css('height', 'auto');
		$('.DTFC_LeftBodyLiner').css('height', 'auto');
		$('.DTFC_LeftBodyLiner').css('overflow', 'hidden');

jQuery('.dataTables_filter input').attr('title', 'Search against Product, Description');	

function reloadPage(uom, price, download, attach){
			/*
		 * queryParameters -> handles the query string parameters
		 * queryString -> the query string without the fist '?' character
		 * re -> the regular expression
		 * m -> holds the string matching the regular expression
		 */
		var queryParameters = {}, queryString = location.search.substring(1),
		    re = /([^&=]+)=([^&]*)/g, m;

		// Creates a map with the query string parameters
		while (m = re.exec(queryString)) {
		    queryParameters[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
		}

		// Add new parameters or update existing ones

			queryParameters['UOM_Type'] = uom;
			queryParameters['Price_Type'] = price;
			queryParameters['download'] = download;
			queryParameters['attach2program'] = attach;

		/*
		 * Replace the query portion of the URL.
		 * jQuery.param() -> create a serialized representation of an array or
		 *     object, suitable for use in a URL query string or Ajax request.
		 */
		location.search = $.param(queryParameters); // Causes page to reload
		}


		exportAll = function() {
		window.open( "/Common_Files/exportAll.cfm?" + "type=getBlanketBidInfo"
										+ "&contract_main_id=<cfoutput>#contract_main_id#</cfoutput>"
										+ "&uom_type=<cfoutput>#uom_type#</cfoutput>"
										+ "&margin_version=<cfoutput>#margin_version#</cfoutput>"
										+ "&contract_status=<cfoutput>#programInfo.contract_Status_Type_IDX#</cfoutput>"

			,"_blank"
			,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
		}
</script>
<!----DOWNLOAD FILE START--->
<cfif url.Download>
		<cfset DownloadFile = MarginUploadCFC.downloadFile(#contract_main_id#,#url.Price_Type#,#url.uom_type#,#URL.margin_version#)>
</cfif>
<!----DOWNLOAD FILE END---->
<!---ATTACH 2 PROGRAM START--->
<cfif attach2program>
		<cfset attach2program = MarginUploadCFC.Attach2Program(#contract_main_id#,#url.Price_Type#,#url.uom_type#,#URL.margin_version#)>
</cfif> 
<!---ATTACH 2 PROGRAM END--->