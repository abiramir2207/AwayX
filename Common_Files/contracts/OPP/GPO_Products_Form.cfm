
<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/OPP/GPO_Products_Form.cfm
   Author: Mark Saunderss
   Date: 3/12/2019
 
   Usage: basic Info module for One Page Program Creation.  Custom feature.
   		  Called from  /Common_Files/contracts/OPP/GPO_One_Page_Program.cfm
       
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
--->
</cfsilent>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfscript>
	oOPP		= CreateObject("component", "mvc.Models.Program.OnePageProgramManager");
</cfscript>

<FORM ACTION="javascript:saveProducts();" METHOD="post" NAME="ProdForm" ID="ProdForm">
	<CFOUTPUT>
		<input type="hidden" name="Is_Group"  value="1">
		<input type="Hidden" name="ExistingProductList" id="ExistingProductList"  value="">
		<input type="Hidden" name="Product_List"  value=""  id="Product_List">
		<input type="Hidden" name="ExistingProductList_Field_Name"  id="ExistingProductList_Field_Name"  value="ExistingProductList">
		<input type="Hidden" name="Level_1"  value=""  id="Level_1">
		<input type="Hidden" name="GroupLevel_1"  value=""  id="GroupLevel_1">
		<input type="Hidden" name="Level_2"  value=""  id="Level_2">
		<input type="Hidden" name="GroupLevel_2"  value=""  id="GroupLevel_2">
		<input type="Hidden" name="Level_3"  value=""  id="Level_3">
		<input type="Hidden" name="GroupLevel_3"  value=""  id="GroupLevel_3">
	</CFOUTPUT>
</FORM>

<FORM ACTION="javascript:saveProductGroups();" METHOD="post" NAME="ProdGroupForm" ID="ProdGroupForm">
	<CFOUTPUT>
		<input type="hidden" name="Is_Group"  value="1">
		<input type="Hidden" name="ExistingProductList" id="ExistingProductList"  value="">
		<input type="Hidden" name="Product_List"  value=""  id="Product_List">
		<input type="Hidden" name="ExistingProductList_Field_Name"  id="ExistingProductList_Field_Name"  value="ExistingProductList">
		<input type="Hidden" name="Level_1"  value=""  id="Level_1">
		<input type="Hidden" name="GroupLevel_1"  value=""  id="GroupLevel_1">
		<input type="Hidden" name="Level_2"  value=""  id="Level_2">
		<input type="Hidden" name="GroupLevel_2"  value=""  id="GroupLevel_2">
		<input type="Hidden" name="Level_3"  value=""  id="Level_3">
		<input type="Hidden" name="GroupLevel_3"  value=""  id="GroupLevel_3">
	</CFOUTPUT>
</FORM>

<h5 class="sectionHeader">ELIGIBLE PRODUCTS</h5>
    <div class="sectionContents pb-4">
      <!---   <button type="button" class="button" onclick="showGroupSearchWindow();return false;">Select Groups</button> --->
		<button type="button" class="button" onclick="showProductSearch();return false;">Select Products</button>
		<button id="gpoDeleteProdsButton" type="button" class="button ml-4" onclick="deleteGPOProducts();return false;">Delete Selected Products</button>
        <br>
        <!--- Products GRID --->
        <div id="Products_Grid" style="width: 1000px; height: 130px;" class="ag-theme-balham ml-2 mt-2"></div>
    </div>

<SCRIPT>
	// GPO Products test data
	var columnDefs_GPO_Products = [];
	
	function setProdColDefs() {
		columnDefs_GPO_Products = [
		    {headerName: "Item", field: "item",   width:75, filter: 'agTextColumnFilter', sort: 'asc',
		    						checkboxSelection: true,
									headerCheckboxSelection: true,
        							headerCheckboxSelectionFilteredOnly: true },
		    {headerName: "Desc", field: "description",  width:100 ,filter: 'agTextColumnFilter'},
		    // {headerName: "BR", field: "brand",  width:50, filter: 'agTextColumnFilter'},
		    // {headerName: "TC", field: "type_code_desc",  width:50, filter: 'agTextColumnFilter'},
		    // {headerName: "QB", field: "q_brand",  width:50, filter: 'agTextColumnFilter'},
		    {headerName: "Type", field: "type_group_desc",  width:50, filter: 'agTextColumnFilter'}
		];
	}


// ,,,,Q_Brand,,BSA_Foodservice_Items_Master_ID,Contract_Products_Id
	//    {headerName: "TIER 1", field: "t1",  type: "numericColumn", width:60},
	//     {headerName: "TIER 2", field: "t2",  type: "numericColumn", width:60},
	//     {headerName: "TIER 3", field: "t3",  type: "numericColumn", width:60},
	//     {headerName: "TIER 4", field: "t4",  type: "numericColumn", width:60},
	// // var rowData_GPO_Products = [
	//     {br: "CLXHLTH", ean: "10044600303588", desc: "CLXHLTH BLCHGRM WPS 2/110CT", t1:"$47.44", t2:"$44.62", t3:"$43.28", t4:"$40.72"},
	//     {br: "CLXHLTH", ean: "10044600303595", desc: "CLXHLTH BLCHGRM WPS REF 2/110CT", t1:"$43.70", t2:"$41.10", t3:"$39.86", t4:"$37.50"},
	// ];
	var rowData_GPO_Products = [];
	var Products_GridOptions = {};

	function Build_GPOProductsGrid() {
		$("#Products_Grid").empty();
		// Init GPO Products grid
		Products_GridOptions = {
			 defaultColDef: {
			        sortable: true,
			        filter: true
			  }
			,floatingFilter: true
			,columnDefs: columnDefs_GPO_Products
		    ,rowData: rowData_GPO_Products
		    ,rowModelType: "clientSide"
		    ,cacheBlockSize: 2000
		    ,singleClickEdit: true
	        ,stopEditingWhenGridLosesFocus: true
	        ,rowSelection: 'multiple'
		    ,onGridReady: function () {
		        this.api.sizeColumnsToFit();
		    }
		    ,onCellValueChanged: function(event) {
		        //console.log(event);
		        if(event.oldValue != event.newValue){
		        	saveProductOverride(JSON.stringify(event.data), event.colDef.field)
		        }
		    }
		};
		ag_grid_default(Products_GridOptions);		// set up default features
		init_ag_grid( Products_GridOptions, "#Products_Grid", false );   // setup as client side
	}

	function getProducts(){
		
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getProducts" }
						//,dataType: "json"
						,success: function (data) {
			               // console.log('Submission was successful.');
			              rowData_GPO_Products = JSON.parse(data);
			              Products_GridOptions.api.setRowData(rowData_GPO_Products);
			             // console.log(rowData_GPO_Products);
						  //console.log("getProducts "+rowData_GPO_Products.length);

						  setProductsGridHeight(rowData_GPO_Products.length-1);
						  Products_GridOptions.api.setRowData(rowData_GPO_Products);

			              var prodList = '';
			              rowData_GPO_Products.forEach(function(item){
			              	if(prodList == ''){
			              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
			              	}
			              	else{
			              		prodList = prodList.concat(',');
			              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
			              	}
			              });
			              $('#ExistingProductList').val(prodList);
			              $('#Level_1').val(prodList);
			             // console.log($('#ExistingProductList').val());
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function saveProducts(){

		show_loader('Saving Product Data...');
		var frm = $('#ProdForm');
		var fields = frm.serializeArray();
		var data = JSON.stringify(fields);
		//return;
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									arrData: data,
									method: "saveProducts" }
						//,dataType: "json"
						,success: function (data) {
			              //console.log(data);
			              rowData_GPO_Products = JSON.parse(data);
						   //  console.log(rowData_GPO_Products);

						  setProductsGridHeight(rowData_GPO_Products.length-1);
			              Products_GridOptions.api.setRowData(rowData_GPO_Products);
			              var prodList = '';
			              rowData_GPO_Products.forEach(function(item){
			              	if(prodList == ''){
			              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
			              	}
			              	else{
			              		prodList = prodList.concat(',');
			              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
			              	}
			              });
			              $('#ExistingProductList').val(prodList);
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

	function saveProductGroups(){

		show_loader('Saving Product Data...');
		var frm = $('#ProdForm');
		var fields = frm.serializeArray();
		var data = JSON.stringify(fields);
		//console.log(data);
		//return;
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									arrData: data,
									method: "saveProducts" }
						//,dataType: "json"
						,success: function (data) {
			              //console.log(data);
			              rowData_GPO_Products = JSON.parse(data);
						  //console.log("saveProductGroups "+rowData_GPO_Products.length);

						  setProductsGridHeight(rowData_GPO_Products.length-1);
			              Products_GridOptions.api.setRowData(rowData_GPO_Products);
			              var prodList = '';
			              rowData_GPO_Products.forEach(function(item){
			              	if(prodList == ''){
			              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
			              	}
			              	else{
			              		prodList = prodList.concat(',');
			              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
			              	}
			              });
			              $('#ExistingProductList').val(prodList);
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

	function saveProductOverride(data, field){ // Save a single row
		//console.log(field);
		data = JSON.parse(data);
		show_loader('Saving Product Data...');
		data = JSON.stringify(data);
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									stData: data,
									compId: field,
									method: "saveProductOverride" }
						//,dataType: "json"
						,success: function (data) {
			              //console.log(data);
			              rowData_GPO_Products = JSON.parse(data);
						  //console.log("saveProductOverride "+rowData_GPO_Products.length);

						  setProductsGridHeight(rowData_GPO_Products.length-1);
			              Products_GridOptions.api.setRowData(rowData_GPO_Products);
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

	function getCompIdList(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getCompIdList" }
						//,dataType: "json"
						,success: function (data) {
			              //console.log(data); 
			              setProdColDefs();
			              var s = data.replace(/"/g,'');
			              //console.log(s);
			              var arr = s.split(',');
			              var i = 1;
			              arr.forEach(function(item){
			              	if(i == 1){
			              		columnDefs_GPO_Products.push({headerName: "Tier " + i, field: item,  width:30, editable:true, valueFormatter: currencyFormatter, cellClass: 'number-cell', type: 'numericColumn',
											cellStyle: function(params) {
												//console.log(params);
											        if (params.data.override === 1) {
											            //mark police cells as red  , backgroundColor: 'green'
											            return {color: 'red'};
											        } else {
											            return null;
											        }
											    }
			              					});
			              	}
			              	else{
			              		columnDefs_GPO_Products.push({headerName: "Tier " + i, field: item,  width:30, valueFormatter: currencyFormatter, cellClass: 'number-cell', editable:false, type: 'numericColumn'});
			              	}
			              	
			              	i++;
			              });
			   			 //console.log(s);
			   			 if(s != ''){
			   			 	Build_GPOProductsGrid();
			   			  	getProducts();
			   			 }
			   			 
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function deleteGPOProducts() {
		show_loader('Deleting Products...');
		var selectedData = JSON.stringify(Products_GridOptions.api.getSelectedRows());
		$.ajax({
					async: true
					,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
								aData: selectedData,
								method: "deleteGPOProducts" }
					,success: function (data) {
		              //console.log(data); 
		     			getProducts();
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
		setProdColDefs();
		getCompIdList();
	    //Build_GPOProductsGrid();
	    //getProducts();
	 });

	function currencyFormatter(params) {
		return Number(params.value).toLocaleString("en-US", {style:"currency", currency:"USD", minimumFractionDigits: 2});
	}

	function showProductSearch()
	{
		var bSelectedAllProducts = false;
		var groupLevel = 0;

		<cfoutput>
			var sURL = "/Common_Files/contracts/product_Select_V1.cfm?Formname=ProdForm&discountype=1&programId=#variables.ContractMainID#&prgID=#variables.ContractMainID#&LoadExistingProductList=1";
		</cfoutput>
		NewWindowTopLeft(sURL, "productWindow", 1000, 700, "yes", "yes")
		return false;
	
			
	}

	function showGroupSearchWindow(){
		<cfoutput>
			var sURL = "/Common_Files/contracts/Groups/index.cfm?formName=ProdForm&programId=#variables.ContractMainID#";
		</cfoutput>
		NewWindowTopLeft(sURL, "productGroupWindow", 1000, 700, "yes", "yes")
		return false;
	}

	function setProductsGridHeight(len) {
		if (len > 0) {
			setAutoHeight(Products_GridOptions, "#Products_Grid");
		} else {
			setFixedHeight(Products_GridOptions, "#Products_Grid", "130px");
		}
	}

</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


