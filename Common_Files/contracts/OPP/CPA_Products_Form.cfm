
<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/OPP/CPA_Products_Form.cfm
   Author: Mark Saunderss
   Date: 3/12/2019
 
   Usage: basic Info module for One Page Program Creation.  Custom feature.
   		  Called from  /Common_Files/contracts/OPP/CPA_One_Page_Program.cfm
       
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
--->
</cfsilent>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfscript>
	oPlannerProgram 		= CreateObject("component", "mvc.Models.Planner.PlannerProgramManager");
	gGetProductGroupType  = oPlannerProgram.getProgramProductGroupType(variables.ContractMainID);
	cfparam(name="oppViewOnly", default=0);
	sEditable = 'true';
	if(oppViewOnly == 1){
		sEditable = 'false';
	}
</cfscript>
<style>
	.twoDecimalPlaces{
        text-align: right;
    }
    .twoDecimalPlacesPerc{
        text-align: right;
    }
</style>
<FORM ACTION="javascript:saveSelectedCPAProducts();" METHOD="post" NAME="ProdForm" ID="ProdForm">
	<CFOUTPUT>
		<input type="hidden" name="Is_Group"  value="1">
		<input type="Hidden" name="ExistingProductList" id="ExistingProductList"  value="">
		<input type="Hidden" name="Product_List"  value=""  id="Product_List">
		<input type="Hidden" name="ExistingProductList_Field_Name"  id="ExistingProductList_Field_Name"  value="ExistingProductList">
	</CFOUTPUT>
</FORM>
<cfif oppViewOnly EQ 0>
<h5 class="sectionHeader">ELIGIBLE PRODUCTS</h5>
</cfif>
	<div class="sectionContents text-xs">
		<cfif oppViewOnly EQ 0>
		<div class="ml-2" style="width: 100%;height: 100px;">
			<button id="cpaSelectProdsButton" type="button" class="button ml-4" onclick="showCPAProductSearch();return false;">Select Products</button>
			<button id="cpaDeleteProdsButton" type="button" class="button ml-4" onclick="deleteCPAProducts();return false;">Delete Selected Products</button>
			<!--- <button type="button" class="button" onclick="getCPAProducts();return false;">Get Products</button> --->

			<label class="opacity-75 pr-1" style="padding-left: 100px"><span id="rateText">Rate:</span></label>
			<INPUT type="number" MAXLENGTH="8" NAME="massrate" id="massrate" VALUE="0" style="width: 60px" class="border text-right"/>
			<select name="massApplyList" id="massApplyList" class="border ml-4 pl-1 rounded" style="width: 250px">
				<option value="0"> -- select a component -- </option>
			</select>
			<button type="button" class="button" onclick="massApplyRates();return false;">Apply</button>
			<button type="button" class="button table-cell" id="deleteComponent" onclick="deleteSelectedCPAComponent();return false;" style="margin: 10px 0 0 0">Delete Selected Component</button>
        </div>
		</cfif>
		
        <!--- PRODUCTS GRID --->
        <div id="CPA_Products_Grid" style="width: 100%;height: 100px;" class="ag-theme-balham m-2"></div>
        <button onclick="onBtExport()" style="height: 25px; cursor: pointer" type="button" class="button ml-4">Export to Excel</button>
    </div>

<SCRIPT>

	$("#massApplyList").change(function(){
		var s = $("#massApplyList option:selected").text();
		if(s.includes('%')){

			$("#rateText").text('Rate: %');
		}
		else{
			$("#rateText").text('Rate: $');
		}
	    //savePriceList($( this ).val(),'NON');
	});
	// CPA Products test data
	var columnDefs_CPA_Products = [];
	var excelColKeys = [];
	
	function setCPAProdColDefs() {
		$("#CPA_Products_Grid").empty();
		columnDefs_CPA_Products = [
			{headerName: "CPA #", field: "contract_reference_number",  width:25, filter: 'agTextColumnFilter', hide: true},
			{headerName: "GPO Key", field: "gpo_key",  width:40, 
			<cfif oppViewOnly EQ 0>	checkboxSelection: true,
									headerCheckboxSelection: true,
        							headerCheckboxSelectionFilteredOnly: true, </cfif>
        							filter: 'agTextColumnFilter'},
			{headerName: "Price List", field: "price_list_id",  width:30, filter: 'agTextColumnFilter'},
		    {headerName: "Item", field: "item",   width:40, filter: 'agTextColumnFilter', sort: 'asc', cellClass: 'textFormat'},
		    {headerName: "Desc", field: "description",  width:75 ,filter: 'agTextColumnFilter'},
		    {headerName: "Start Date", field: "contract_start_date",  width:25, filter: 'agTextColumnFilter', hide: true},
		    {headerName: "End Date", field: "contract_end_date",  width:25, filter: 'agTextColumnFilter', hide: true},
		    {headerName: "List Price", field: "list_price",  width:25, filter: 'agNumberColumnFilter', valueFormatter: currencyFormatter, cellClass: 'twoDecimalPlaces', type: 'numericColumn'},
		    {headerName: "GPO Price", field: "gpo_price",  width:25, filter: 'agNumberColumnFilter', valueFormatter: currencyFormatter, cellClass: 'twoDecimalPlaces', type: 'numericColumn'},
		   // ,{headerName: "comp1", field: "comp1",  width:50, filter: 'agTextColumnFilter'} contract_start_date
		];
	}

	var rowData_CPA_Products = [];
	var CPA_Products_GridOptions = {};

	function Build_CPAProductsGrid() {
		
		// Init CPA Products grid
		CPA_Products_GridOptions = {
			 defaultColDef: {
			        sortable: true,
			        filter: true
			  }
			,floatingFilter: true
			,columnDefs: columnDefs_CPA_Products
		    ,rowData: rowData_CPA_Products
		    ,rowModelType: "clientSide"     // TODO change to server-side
		    ,cacheBlockSize: 2000
		    ,singleClickEdit: true
	        ,stopEditingWhenGridLosesFocus: true
	        ,rowSelection: 'multiple'
		    ,onGridReady: function () {
		        this.api.sizeColumnsToFit();
		    }
		    <cfif oppViewOnly EQ 0>
		    ,onCellValueChanged: function(event) {
		        if(event.oldValue != event.newValue){
		        	saveCPAProductOverride(JSON.stringify(event.data), event.colDef.field)
		        }
		    }
		    </cfif>
		    ,getRowNodeId: function(data) {
			    return data.contract_products_id;
			}
			 ,excelStyles: [
		        {
		            id: 'textFormat',
            		dataType: 'string'
		        }
		     , {
	            id: 'twoDecimalPlaces',
	            numberFormat: {
	                format: '$#,##0.00'
	            }},
	         	{
	            id: 'twoDecimalPlacesPerc',
	            numberFormat: {
	                format: '#.00%'
	            }},
	            {
	            alignment: {
	            	 horizontal: 'Right'
	            }
	        }]
		};
		ag_grid_default(CPA_Products_GridOptions);		// set up default features
		init_ag_grid( CPA_Products_GridOptions, "#CPA_Products_Grid", false );   // setup as client side TODO change to server-side
	}

	function getCPAProducts(){
		
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getCPAProducts" }
						//,dataType: "json"
						,success: function (data) {
			              rowData_CPA_Products = JSON.parse(data);
			             // console.log(rowData_CPA_Products);
			              var prodList = '';
			              rowData_CPA_Products.forEach(function(item){
			              	if(prodList == ''){
			              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
			              	}
			              	else{
			              		prodList = prodList.concat(',');
			              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
			              	}
			              });
			              $('#ExistingProductList').val(prodList);
			              CPA_Products_GridOptions.api.setRowData(rowData_CPA_Products);
			              var eGridDiv = document.querySelector('#CPA_Products_Grid');
					      eGridDiv.style.height = '400px';
					      CPA_Products_GridOptions.api.doLayout();
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function saveSelectedCPAProducts(){

		show_loader('Saving Product Data...');
		var frm = $('#ProdForm');
		var fields = frm.serializeArray();
		var data = JSON.stringify(fields);
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									arrData: data,
									method: "saveSelectedCpaProducts" }
						//,dataType: "json"
						,success: function (data) {
			              getCPAProducts();
			              $("div.loader").hide();
			            }
			            ,error: function (data) {

			                $("div.loader").hide();
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function saveCPAProductOverride(data, field){ // Save a single rows
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									stData: data,
									compId: field,
									method: "saveCPAProductOverRide" }
						//,dataType: "json"
						,success: function (data) {
						  var aData = JSON.parse(data);
						  var rowData = aData[0];
						  var rowNode = CPA_Products_GridOptions.api.getRowNode(rowData.contract_products_id);
						  rowNode.setData(rowData);
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function getCPACompIdList(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getCPACompIdList" }
						//,dataType: "json"
						,success: function (data) {
			              var comps = JSON.parse(data);
			              setCPAProdColDefs();
			              comps.forEach(function(item){
			              		<cfoutput>
			              		if(item.compname.indexOf('%') != -1){//different valueformatters
			              			columnDefs_CPA_Products.push({headerName: item.compname, field: 'rate_'+item.compid,  width:25, valueFormatter: percentFormatter, cellClass: 'twoDecimalPlacesPerc', editable:#sEditable#, type: 'numericColumn'});
			              		}
			              		else{
			              			columnDefs_CPA_Products.push({headerName: item.compname, field: 'rate_'+item.compid,  width:25, valueFormatter: currencyFormatter, cellClass: 'twoDecimalPlaces', editable:#sEditable#, type: 'numericColumn'});
			              		}
			              		</cfoutput>
			              });
			   			 columnDefs_CPA_Products.push({headerName: 'End User Price', field: 'fixed_price_value_end_user', valueFormatter: currencyFormatter, cellClass: 'twoDecimalPlaces', width:25, editable:false, type: 'numericColumn'});
			   			 columnDefs_CPA_Products.push({headerName: 'Distributor Price', field: 'fixed_price_value_customer', valueFormatter: currencyFormatter, cellClass: 'twoDecimalPlaces', width:25, editable:false, type: 'numericColumn'}); 
			   			 if(comps.length){
			   			 	Build_CPAProductsGrid();
			   			  	getCPAProducts();
			   			 }
			   			 else{
			   			 	  $("#CPA_Products_Grid").empty();
			   			 	  //CPA_Products_GridOptions.api.setRowData([]);
				              //var eGridDiv = document.querySelector('#CPA_Products_Grid');
						      //eGridDiv.style.height = '75px';
						      //CPA_Products_GridOptions.api.doLayout();
			   			 }
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function currencyFormatter(params) {
		if(params.value == 0){
			return '';
		}
		else{
			return Number(params.value).toLocaleString("en-US", {style:"currency", currency:"USD", minimumFractionDigits: 2});
		}
	}
	function numberFormatter(params) {
		return Number(params.value).toFixed(2).toLocaleString("en-US");
	}
	function percentFormatter(params) {
		if(params.value == 0){
			return '';
		}
		else{
			var s = Number(params.value).toFixed(2).toLocaleString("en-US");
			return s + '%';
		}
	}
	
	function deleteCPAProducts() {
		show_loader('Deleting Products...');
		var selectedData = JSON.stringify(CPA_Products_GridOptions.api.getSelectedRows());
		$.ajax({
					async: true
					,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
								aData: selectedData,
								method: "deleteCPAProducts" }
					,success: function (data) {
		              //console.log(data); 
		     			getCPAProducts();
		            	$("div.loader").hide();  
		            }
		            ,error: function (data) {
		            	$("div.loader").hide();
		                alert('An error occurred.  ' + JSON.stringify(data) );
		            }
					,type: "post"
					,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
		});
	}
	function massApplyRates() {
		show_loader('Mass Applying Rates...');
		var selectedData = JSON.stringify(CPA_Products_GridOptions.api.getSelectedRows());
		var compId = $("#massApplyList").val();
		var rate = $("#massrate").val();
		$.ajax({
					async: true
					,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
								aData: selectedData,
								compId: compId,
								rate: rate,
								method: "updateCPACompRates" }
					,success: function (data) {
		              //console.log(data); 
		     			getCPAProducts();
		            	$("div.loader").hide();  
		            }
		            ,error: function (data) {
		            	$("div.loader").hide();
		                alert('An error occurred.  ' + JSON.stringify(data) );
		            }
					,type: "post"
					,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
		});
	}
	function deleteSelectedCPAComponent() {
		if(Components_GridOptions.api.getSelectedRows().length > 0 || $('#massApplyList').children('option').length >= 2 ){
			show_loader('Deleting Selected Rebate Component...'); //and fall through to delete 1
		}
		else{ // Delete All
			deleteCPAComponents(); ///ON CPA_Components_Form -> Delete All
			return;
		}
		var sMethod = 'deleteOneCPAComponent'; //Delete One
		var compId = $("#massApplyList").val();
		if($('#massApplyList').children('option').length <= 2){
			sMethod = 'deleteCpaComponents'; //Delete All
		}

		$.ajax({
					async: true
					,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
								compId: compId,
								method: sMethod	 }
					,success: function (data) {
		              //console.log(data); 
		     			// ON CPA_Components_Form.cfm
		     			refreshCompData();
		        		// ON CPA_Components_Form.cfm
		            	$("div.loader").hide();  
		            }
		            ,error: function (data) {
		            	$("div.loader").hide();
		                alert('An error occurred.  ' + JSON.stringify(data) );
		            }
					,type: "post"
					,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
		});
	}
	document.addEventListener("DOMContentLoaded", function () {
		setCPAProdColDefs();
		getCPACompIdList();
	    //Build_CPAProductsGrid();
	    //getProducts();
	 });

	function showCPAProductSearch(){
		var bSelectedAllProducts = false;
		var groupLevel = 0;
		<cfoutput>
			var sURL = "/Common_Files/contracts/product_Select_V1.cfm?Formname=ProdForm&discountype=1&programId=#variables.ContractMainID#&prgID=#variables.ContractMainID#&LoadExistingProductList=1";
		</cfoutput>
		NewWindowTopLeft(sURL, "productWindow", 1000, 700, "yes", "yes")
		return false;		
	}

	function onBtExport() {
		excelColKeys = [];
		columnDefs_CPA_Products.forEach(function(item){
			if(item.field != 'price_list_id'){
				excelColKeys.push(item.field);
			}
		});

	    var params = {
	        allColumns: false,
	        columnKeys: excelColKeys
	       // onlySelected: getBooleanValue('#onlySelected'),
	        //fileName: 'export.xlsx',
	        //sheetName: ''
	    };

        params.processCellCallback = function(params) {
           //console.log(params);
           switch (params.column.colDef.type) {
			  case 'numericColumn':
			    if(params.value == 0){
			    	return '';
			    }
			    else if(params.column.userProvidedColDef.headerName.includes('%')){
			    	return numberFormatter(params)/100;	
			    }
			    else{
			    	return numberFormatter(params);
			    }
			    break;
			  default:
			    return params.value;
			}
        };

	    CPA_Products_GridOptions.api.exportDataAsExcel(params);
	}

</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


