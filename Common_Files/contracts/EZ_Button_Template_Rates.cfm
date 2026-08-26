<!---------------------------------------------------------------------------------------------------------------------
            Template: \ Common_Files\Contracts\EZ_Button_Template_Rates.cfm
            Date:     20-May-2020
            Author:   Dinesh Rachala
            Purpose:  Display EZ Button Items with rates.
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="URL.CID" default="">
<cfparam name="dislayCreateProductRateList" default="1">
<cfparam name="form.lsProdRates" default="">
<cfparam name="form.lsProdUOMs" default="">
<cfparam name="form.lsItemlist" default="">

<cfif len(URL.CID)>
<style>
	#info{
		color:green;
		border:solid;
		border-color:red;
		border-width:1px;
		padding:4px;
		text-align:center;
		font-weight:bold;
		display:none;
	}
</style>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfset Contract_Main_ID = cryp.value>

	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables2.cfm">
<cfinclude template="comparelist.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/string_functions.js"></script>
<script type="text/javascript" src="/billbacks/common/common_js_functions.js"></script>

<cfscript>
	appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
	contract = CreateObject("component", "components.programs.rebates.Contract");
	EZComp = CreateObject("component", "components.programs.EZButton.EZ_Button");
	GetContractInfo = contract.get(Contract_Main_ID);
	EZCompID = EZComp.getEZCompID(Contract_Main_ID);
</cfscript>

<!--- If we don't get an EZ Comp ID entry then we need to create one to prevent an error message when adding EZ Button Products and Groups--->
<cfif EZCompID.recordcount>
	<cfset thisEZCompId = EZCompID.Program_rebates_Component_ID />
<cfelse>
	<cfquery name="qAddEZComp" datasource="#application.datasource#">
		INSERT INTO Program_Rebates_Component(Program_ID, Program_Rebates_Component_Name_ID, Component_Paid_To, Claim_Mechanics, GL_Account_ID)
		VALUES (#Contract_Main_ID#, 0, 0, -1, 0)
	</cfquery>
	<cfset thisEZCompId = EZComp.getEZCompID(Contract_Main_ID) />
</cfif>
	
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
	SELECT First_parent_ID
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
</cfquery>

<FIELDSET class="clBox" STYLE="padding:10px; width: 97%; border: 1px solid Blue; display:table;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">EZ Button</LEGEND>
<cfoutput>
	<a onClick="javascript: return showGroupSearchWindow();" style="cursor:pointer" id="ActiveGroups">#application.util.string.actionLinkFormat("add groups")#</a>
	<a onClick="javascript: return showProductSearchWindow(0);" style="cursor:pointer" id="ActiveItems">#application.util.string.actionLinkFormat("add products")#</a>
	<a onClick="javascript: return showProductListWindow(0);" style="cursor:pointer" id="ActiveProductList">#application.util.string.actionLinkFormat("create product / rate list")#</a>
	<!--- Disable Links --->
	<a onClick="alert('Cannot add more than <cfoutput>#request.AccessStructure.numberOfProductGroupLevels#</cfoutput> levels.');" style="cursor:pointer;display:none;" id="deActiveGroups">#application.util.string.actionLinkFormat("add groups")#</a>
	<a onClick="alert('Cannot add more than <cfoutput>#request.AccessStructure.numberOfProductGroupLevels#</cfoutput> levels.');" style="cursor:pointer;display:none;" id="deActiveItems">#application.util.string.actionLinkFormat("add products")#</a>
	<a onClick="alert('Cannot add more than <cfoutput>#request.AccessStructure.numberOfProductGroupLevels#</cfoutput> levels.');" style="cursor:pointer;display:none;" id="deActiveProductList">#application.util.string.actionLinkFormat("create product / rate list")#</a>
</cfoutput>
</FIELDSET>

<cfsavecontent variable="MassApplyOptions">
	<input name="MassApplyRate" id="MassApplyRate" type="text" onkeyup="clenseText(this,'0123456789.')" value="0.0000" onChange="this.value = formatToDeciamalPlaces(this.value,4);" size=5/>
	&nbsp;
	<select  name="MassApplyUOM" id="MassApplyUOM">
		<option value="1">CS</option>
		<option value="2">LB</option>
	</select>
	&nbsp;
	<a onclick="MassApply();" style="cursor:pointer">
		<b><font color="FF0000">[ </font> Mass Apply <font color="FF0000">]</font></b>
	</a>
</cfsavecontent>
<br>
<div id="info"></div>
<br>

<cfoutput>

	<table id="EZITEMS" class="datagrid" style='table-layout:fixed'>

	<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [0.15, .75, 2, 1.25] )>
	<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
		<col width="#variables.columnPercentage#%">
	</cfloop>

	<thead>
		<tr>
			<th>
				<img bdelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" title="click here to delete all products" onclick = "deleteItems(#contract_main_id#, 0, 0, 0, 'all', 0, 0)" border="0" style="cursor: pointer;">
			</th>
			<th class=mid>Product ##</th>
			<th class=mid>Description</th>
			<th class=mid>Rate &nbsp;#MassApplyOptions#</th>
		</tr>
	</thead>
	<tbody>
	</tbody>
	</table>

<form name="dataForm" method="post"  id="dataForm" action="EZ_Button_Template_Rates.cfm?CID=#CID#&productGroupAdd=1">
	<input type="hidden" name="Product_List" value="">
	<input type="hidden" name="ExistingProductList" value="">
	<input type="hidden" name="IS_Group" value=""> <!--- 0 :: Item & 1 :: Group ---->
	<input type="hidden" name="Allow_Multi_Levels" <cfif appSettings.getAllowMultiLevelGroups()>value="1"<cfelse>value="0"</cfif> />
	<input type="hidden" name="lsProdRates" value="">
	<input type="hidden" name="lsProdUOMs" value="">
	<input type="hidden" name="lsItemlist" value="">

	<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
		<cfparam name="form['Level_#levels#']" default="">
		<input type="hidden" name="Level_#levels#" value="" />
		<!---clean up the group levels--->
		<cfif trim(form["Level_#levels#"]) eq "">
			<cfset 'form.GroupLevel_#levels#' = "" />
		</cfif>
		<input type="hidden" name="GroupLevel_#levels#" value="" />
	</cfloop>
	<input type="hidden" name="hasGroups" value="" />
</form>

</cfoutput>

<cfif isdefined('url.productGroupAdd') >
	<cfset Product_List = uniqueList(Form.Product_List)>
	<cfset NewItems = ListCompare(Product_List,Form.ExistingProductList)>

	<cfif form.IS_Group EQ 1>
		<cfset PricingLevelID =0>
		<cfset TotalLevels = request.AccessStructure.numberOfProductGroupLevels>
		<cfset useLakebaseForcheck4ItemPricingLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForcheck4ItemPricingLevel>
	<cftry>
		<cfset check4ItemPricingLevel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#Contract_Main_ID#",
				"product_type_id" = "eq.2",
				"is_group" = "eq.0",
				"deleted" = "eq.0",
				"captured_from_group" = "eq.0",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheck4ItemPricingLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheck4ItemPricingLevel>
<cfquery name="check4ItemPricingLevel" datasource="#application.datasource#">
			SELECT 1
			FROM Contract_Products
			WHERE Contract_Main_ID = #Contract_Main_ID#
			AND Product_Type_ID = 2
			AND Is_Group = 0
			AND Deleted = 0
			AND Captured_From_Group = 0
		</cfquery>
</cfif>

			<cfif check4ItemPricingLevel.recordCount>
				<cfset TotalLevels = TotalLevels -1>
			</cfif>

		<cfloop from="1" to="#TotalLevels#" index="levels"> <!---LOOP OVER THE NUMBER OF LEVELS--->
			<cfset Product_List = #EVALUATE("FORM.Level_#levels#")#>
			<cfif listlen(Product_List)>
				<cfset NewItems = ListCompare(Product_List,Form.ExistingProductList)>
				<!---LOOP OVER THE  LEVEL LENGTH--->
				<!---thisEZCompId is set at the top--->
				<cfloop list="#NewItems#" index="BSAID" delimiters=",">
					<cfset	EZButtonSave = EZComp.AddProductsRGroups(#Contract_Main_ID#, '#BSAID#', #thisEZCompId#, #levels#, #form.IS_Group#)>
				</cfloop>
				<cfset PricingLevelID = levels+1>
			</cfif>
		</cfloop>

		<cfif check4ItemPricingLevel.recordCount>
			<cfset useLakebaseForupItemPricingLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForupItemPricingLevel>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_products",
			{
				"contract_main_id" = "eq.#Contract_Main_ID#",
				"is_group" = "eq.0",
				"captured_from_group" = "eq.0",
				"deleted" = "eq.0"
			},
			{
				"pricing_level_id" = "#PricingLevelID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupItemPricingLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupItemPricingLevel>
<cfquery name="upItemPricingLevel" datasource="#application.datasource#">
				UPDATE Contract_Products
				SET Pricing_Level_ID = #PricingLevelID#
				WHERE Contract_Main_ID = #Contract_Main_ID#
				AND Is_Group = 0
				AND Captured_From_Group = 0
				AND Deleted = 0
			</cfquery>
</cfif>
		</cfif>

	<cfelse>

			<!--- PRICING LEVEL LOGIC --->
			<cfset PricingLevelID =1>
			<cfquery name="check4PricingLevel" datasource="#application.datasource#">
				SELECT MAX(Pricing_Level_ID) + 1 AS Pricing_Level_ID
				FROM Contract_Products
				WHERE Contract_Main_ID = #Contract_Main_ID#
				AND Is_Group = 1
				AND Deleted = 0
			</cfquery>
			<cfif len(check4PricingLevel.Pricing_Level_ID)>
				<cfset PricingLevelID = check4PricingLevel.Pricing_Level_ID>
			</cfif>

			<!---WE WILL ONLY INSERT NEW ITEMS, INSTEAD OF DELETING WHOLE EZ BUTTON AND INSERT AGAIN---->
			<cfif form.lsItemlist EQ "">		
				<cfloop list="#NewItems#" index="BSAID" delimiters=",">
					<cfset	EZButtonSave = EZComp.AddProductsRGroups(#Contract_Main_ID#, '#BSAID#', #EZCompID.Program_rebates_Component_ID#, #PricingLevelID#, #form.IS_Group# )>
				</cfloop>
			<cfelse>
				<!--- 118090:Add 'create product / rate list' feature to EZ Button settings page   --->
				<!--- This will add only the products with rate and UOM ---> 
				<cfset lsCounter=1 />
				<cfloop list="#NewItems#" index="BSAID" delimiters=",">
					<cfset	EZButtonSave = EZComp.AddProductsRGroups(#Contract_Main_ID#, '#BSAID#', #EZCompID.Program_rebates_Component_ID#, #PricingLevelID#, #form.IS_Group#, listGetAt(form.lsProdRates, lsCounter),  listGetAt(form.lsProdUOMs, lsCounter))>
					<cfset lsCounter = lsCounter + 1 />
				</cfloop>
			</cfif>
	</cfif>
</cfif>

		<script type="text/javascript">
			<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
				var GroupLevel_<cfoutput>#levels#</cfoutput> = '';
				var Level_<cfoutput>#levels#</cfoutput> = '';
			</cfloop>
			var has_activate = null;
			var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .75) * windowHeight;
			var grid = $('#EZITEMS').DataTable({
					"bAutoWidth": false
					,"bPaginate": true
					,"bServerSide": true
					,"bProcessing": true
					,"bSortClasses": false
					,"bScrollCollapse": true
					,"iDisplayLength": 1000
					,"sAjaxSource": <cfoutput>"ajax/getEZRates.cfm?contract_main_id=#trim(Contract_Main_ID)#"</cfoutput>
					,"fnServerData" : function(sSource, aoData, fnCallback) {
                $.ajax({
                    "dataType" : 'json',
                    "type" : "GET",
                    "url" : sSource,
                    "data" : aoData,
                    "success" : fnCallback
								}).success( function(data){
									//console.log(data);
									var maxPriceListID = data.maxPriceListID.toString();
									if(maxPriceListID >= <cfoutput>#request.AccessStructure.numberOfProductGroupLevels#</cfoutput>){
										$('#deActiveGroups').show()
										$('#ActiveGroups').hide()
										$('#deActiveItems').show()
										$('#deActiveItems').hide()
										$('#deActiveProductList').show()
										$('#ActiveProductList').hide()

									}

                                    let grp = {};

									for (i = 0; i < data.aaData.length; i++) {
                                        if ( data.aaData[i][6] ) {  //IF IT'S A GROUP RECORD POPULATE GROUP FIELDS
                                            // populate "Level_*"" elements (i.e. Level_1, Level_2)
                                            grp.name = "Level_" + data.aaData[i][7];

                                            // set up array key to store values if it does not exist (i.e. grp.Level_1[], grp.Level_2[])
                                            if (typeof grp[ grp.name ] === "undefined") {
                                                grp[ grp.name ] = [];
                                            }

                                            // grap the group value from JSON result
                                            grp.value = data.aaData[i][4];
                                            // collect group value if it is not defined in the array (i.e. grp.Level_1[], grp.Level_2[])
                                            if (grp[ grp.name ].indexOf( grp.value ) == -1) {
                                                grp[ grp.name ].push( grp.value );
                                            }
                                            // populate form element based on array key (i.e. grp.Level_1[], grp.Level_2[])
                                            $("input[name=" + grp.name + "]").val( grp[ grp.name ].join() );


                                            // populate "GroupLevel_*"" elements (i.e. GroupLevel_1, GroupLevel_2)
                                            grp.name = "GroupLevel_" + data.aaData[i][7];
                                            // set up array key to store values if it does not exist (i.e. grp.GroupLevel_1[], grp.GroupLevel_2[])
                                            if (typeof grp[ grp.name ] === "undefined") {
                                                grp[ grp.name ] = [];
                                            }

                                            // grap the group value from JSON result
                                            grp.value = data.aaData[i][8];
                                            // collect group value if it is not defined in the array (i.e. grp.GroupLevel_1[], grp.GroupLevel_2[])
                                            if (grp[ grp.name ].indexOf( grp.value ) == -1) {
                                                grp[ grp.name ].push( grp.value );
                                            }
                                            // populate form element based on array key (i.e. grp.GroupLevel_1[], grp.GroupLevel_2[])
                                            $("input[name=" + grp.name + "]").val( grp[ grp.name ].join() );
										}
									}

									var itemList = data.itemList.toString();
									$("input[name=Product_List]").val( itemList );
									$("input[name=ExistingProductList]").val( itemList );

									var hasGroups  = data.hasGroups.toString();
									$("input[name=hasGroups]").val( hasGroups );

								});
							}
					,"sDom": "fprt"
					,"sScrollY": sScrollY         <!--- data grid height --->
					,"aaSorting": [] <!---default sorting on code column--->
					,"aoColumns": [ { "bSortable":false, "bSearchable":false}
																	, { "bSortable":true, "bSearchable":true }
																	, { "bSortable":true, "bSearchable":true }
																	, { "bSortable":false, "bSearchable":false }]
				,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
			});//.fnSetFilteringDelay();
			$('table#EZITEMS tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

function showGroupSearchWindow(){
	$("input[name=IS_Group]").val( '1' );
	NewWindow("Groups/index.cfm?formName=dataForm&programId=<cfoutput>#Contract_Main_ID#</cfoutput>&Discountype=2&EZTemplate=1", "productwindow", 800, 700, "yes", "yes");
}
function showProductSearchWindow(addProductAtLevel){
	$("input[name=IS_Group]").val( '0' );
	var sURL = "product_Select_V1.cfm?Formname=dataForm&discountype=2&EZTemplate=1&programId=<cfoutput>#Contract_Main_ID#&FirstParentID=#GetTemplateInfo.First_parent_ID#&prgID=#Contract_Main_ID#</cfoutput>";
	NewWindowTopLeft(sURL, "productwindow", 1000, 700, "yes", "yes")
}
function deleteItems( contract_main_id, contract_products_id, program_rebates_product_data_id, type, item, ISGroup, pricingLevel){
	$.ajax({
						url: "/components/programs/EZButton/EZ_Button.cfc"
						,type: "POST"
            ,data: {
							method: "deleteItems"
							,Contract_Main_ID: contract_main_id
							,Contract_Products_ID : contract_products_id
							,Program_Rebates_Product_Data_ID : program_rebates_product_data_id
							,Type : type
							,Pricing_Level_ID : pricingLevel
							,IS_Group : ISGroup
						}
            ,success: function(  ) {
							grid.ajax.reload();
							$('#info').show();
							if(type){
								$( "#info" ).text( item +" removed successfully !" );
							}else{
								$( "#info" ).text("All items are removed successfully !" );
							}
							$('#info').delay(3000).hide(0);
            }
            ,error: function(xhr, status, error) { error_handler(xhr, status, error) }
        });
}
function saveRate( Input,type ){
	var CurPrice = $(Input).attr("value");
	var NewPrice = $(Input).attr("price");
	var BSAID = $(Input).attr("bsaid");
	var ID = BSAID.replace(/-/g, "_");
				ID =  "#comp_uom_"+ID
	var UOM =  $(ID+" option:selected" ).val();
	var ITEM = $(Input).attr("item");
	var GROUP = $(Input).attr("group");

	if( CurPrice != NewPrice || type == 2){
				$.ajax({
						url: "/components/programs/EZButton/EZ_Button.cfc"
						,type: "POST"
            ,data: {
							method: "saveRateUom"
							,CMID : <cfoutput>#Contract_Main_ID#</cfoutput>
							,BSAID : BSAID
							,RATE : CurPrice
							,UOM : UOM
							,TYPE : type
							,GROUP : GROUP
						}
            ,success: function( ) {
							grid.ajax.reload();
							$('#info').show();
							$( "#info" ).text( ITEM +" rate / uom updated successfully !" );
							$('#info').delay(3000).hide(0);
            }
            ,error: function(xhr, status, error) { error_handler(xhr, status, error) }
				});
	}
}
function MassApply(){
	$.ajax({
						url: "/components/programs/EZButton/EZ_Button.cfc"
						,type: "POST"
            ,data: {
							method: "massApply"
							,Contract_Main_ID: <cfoutput>#contract_main_id#</cfoutput>
							,Rate : $( "#MassApplyRate" ).val()
							,UOM : $( "#MassApplyUOM" ).val()
							,SEARCH : $('.dataTables_filter input').val()
							,GROUPS : $("input[name=hasGroups]").val( )
						}
            ,success: function(  ) {
							grid.ajax.reload();
							$('#info').show();
							$( "#info" ).text( " mass updated rate / uom successfully !" );
							$('#info').delay(3000).hide(0);
            }
            ,error: function(xhr, status, error) { error_handler(xhr, status, error) }
        });
}


function showProductListWindow(){
	// $("input[name=IS_Group]").val( '1' );
	NewWindow("EZ_Product_List.cfm?formName=dataForm&programId=<cfoutput>#Contract_Main_ID#&FirstParentID=#GetTemplateInfo.First_parent_ID#</cfoutput>&Discountype=2&EZTemplate=1&CID=<cfoutput>#URL.CID#</cfoutput>", "productListwindow", 650, 500, "yes", "yes");

}
</script>

<!---- URL.CID is NULL ---->
<cfelse>
<div align="center" style="color:red; font-weight:bold;">
	Invalid Template.
</div>
</cfif>