
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
<!--- <FORM ACTION="GPO_Tiers_Form.cfm?CID=<cfoutput>#URL.CID#</cfoutput>" METHOD="post" NAME="DistForm" ID="DistForm">
	<CFOUTPUT>
		<input type="hidden" name="FinalItemList" value="#form.FinalItemList#">
		<input type="hidden" name="User_Selection_Group_Or_Dist" value="1">
		<input type="hidden" name="Is_Group"  value="1">
		<input type="Hidden" name="ExcludeDistributor" value="#request.app_general_functions.listRemoveDupes(form.ExcludeDistributor,',')#">
	</CFOUTPUT>
</FORM> --->

 <h5 class="sectionHeader">TIERS</h5>
    <div class="sectionContents text-xs">
        <!--- <div class="flex-column ml-8"> --->
           <!---  <div class="table-row">
                <label class="opacity-75 pr-3 table-cell text-right">Component UOM:</label>
                <select name="rate_uom" id="rate_uom" class="border rounded">
                   <!---  <option disabled selected value>-- Rate UOM --</option> --->
                    <option value="%" selected>%</option>
                    <option value="$">$</option>
				</select>
               <!---  <span class="table-cell">%</span> --->
            </div>
            <div class="table-row">
                <label class="opacity-75 pr-3 table-cell text-right">Range UOM:</label>
                <select name="range_uom" id="rate_uom" class="border rounded">
                   <!---  <option disabled selected value>-- Rate UOM --</option> --->
                    <option value="%" selected>$</option>
                    <option value="EA">Each</option>
                </select>
                <!--- <span class="table-cell">$</span> --->
			</div>  --->

			<button type="button" class="button" id="tierButton" onclick="addTier();return false;">Add Tier</button>
			<button type="button" class="button" id="removeTierButton" onclick="onRemoveSelected();return false;">Remove Tier</button>
        <!--- </div> --->
        <!--- TIERS GRID --->
		<div id="Tiers_Grid" style="width: 405px; height: 70px;" class="ag-theme-balham ml-2 mt-2 pb-3"></div>
		
		<div class="ml-2">
			<label class="opacity-75 pr-1">Rebate Eligibility:</label>
				<select name="rebate_eligible" id="rebate_eligible" class="border rounded">
					<!---  <option disabled selected value>-- Rate UOM --</option> --->
					<cfoutput query="qGetPayTypes">
						<cfset s = ''/>
						<cfif claimMechanics eq Payment_Type_ID><cfset s = 'selected'/></cfif>
						<option value="#Payment_Type_ID#" #s#>#Payment_Type_Name#</option>
					</cfoutput>
				</select>
			<button type="button" class="button ml-4" id="createProductTiers" onclick="createProductTiers();return false;">Apply Tiers</button>
		</div>
    </div>

<SCRIPT>

	function CurrencyCellRenderer(params) {
		// Input is "*" to signify no upper limit. Let that through as is.
		if (params.value =="*")
			return("*");
		// sometimes we get a string with junk in it instead of the integer we are looking for.  Convert it.
		if (isNaN (params.value) ) {
			// Strip out everything except minus sign, digits, period
			params.value = parseFloat(params.value.replace( /[^-\d+\.\d+]/g, ''));
		}
		return usdFormat.format(params.value);
	}

	// TIERS columns
	var columnDefs_Tiers = [
	    {headerName: "Tier #", field: "t",   width:100, checkboxSelection: true, sortable: false},
	    {headerName: "RANGE FROM", field: "start",  valueFormatter: CurrencyCellRenderer, type: "numericColumn", width:100, editable: true, sortable: false},
	    {headerName: "RANGE TO", field: "end",  valueFormatter: CurrencyCellRenderer, type: "numericColumn", width:100, editable: true, sortable: false},
	    {headerName: "TIER RATE", field: "rate_desc",  type: "numericColumn", width:100, editable: true, sortable: false},
	];

	var rowData_Tiers = [];

	// var rowData_Tiers = [
	//     {t: "TIER 1", start: "$0.00", end: "$99,999.00", rate:"1.00", id:"1", rate_desc:"1.00%", tierNum:"1"},
	//     {t: "TIER 2", start: "$100,000.00", end: "$749,999.00", rate:"4.00", id:"2", rate_desc:"4.00%", tierNum:"2"},
	//     {t: "TIER 3", start: "$750,000.00", end: "$1,500,000.00", rate:"7.00", id:"3", rate_desc:"7.00%", tierNum:"3"},
	//     {t: "TIER 4", start: "$1,500,001.00", end: "*", rate:"10.00", id:"4", rate_desc:"10.00%", tierNum:"4"},
	// ];
	var tierCount = 1;
	function addTier() {
		if(tierCount <= 4){
			//show_loader('Saving Tier Data...');
			setGridHeight(Tiers_GridOptions, "#Tiers_Grid", tierCount-1);
			var newItem = createNewRowData();
	    	var res = Tiers_GridOptions.api.updateRowData({add: [newItem]});
	    	saveTierData(JSON.stringify(newItem),'start');
		}
		else{
			alert('The Maximum Number of Tiers Has Been Reached.');
			$('#tierButton').attr("disabled", "disabled");

		}
	    //printResult(res);
	}
	function createNewRowData() {

	    var tierData = {
	        t: "TIER " + tierCount,
	        start: "$0 ",
	        end: "$0",
	        rate: '0',
	        id: '0',
	        rate_desc: '0%',
	        rate_uom_desc: '%',
	        rate_uom_id: 3,
	        tiernum: + tierCount
	    };
	    tierCount++;
	    return tierData;
	}

	var Tiers_GridOptions = {};
	function Build_TiersGrid() {
	    // Init Tiers grid
	    Tiers_GridOptions = {
	        columnDefs: columnDefs_Tiers
	        ,rowSelection: 'single'
	        ,defaultColDef: {editable: true,
							  resizable: true}
	        ,singleClickEdit: true
	        ,stopEditingWhenGridLosesFocus: true
	        ,rowData: rowData_Tiers
	        ,rowModelType: "clientSide"
	        ,cacheBlockSize: 2000
			// ,domLayout: "autoHeight"
	        ,onGridReady: function () {
				setGridHeight(Tiers_GridOptions, "#Tiers_Grid", rowData_Tiers.length);
	        }
	        ,onCellValueChanged: function(event) {
		        //console.log(event);
		        if(event.oldValue != event.newValue){
		        	saveTierData(JSON.stringify(event.data), event.colDef.field)
		        }
		       // alert('onCellValueChanged: ' + event.colDef.field + ' = ' + event.newValue);
		    }
	    };
	    ag_grid_default(Tiers_GridOptions);		// set up default features
	    init_ag_grid( Tiers_GridOptions, "#Tiers_Grid", false );   // setup as client side
	}


	function saveTierData(data, field){
		//console.log(data);
		//console.log(field);
		data = JSON.parse(data);
		if(field == 'rate_desc'){
			data.rate = data.rate_desc;
            // data.rate_uom_desc = $('#rate_uom').val();
            // if(data.rate_uom_desc == '$'){
            // 	data.rate_uom_id = 4;
            // 	data.rate_desc = $('#rate_uom').val() + data.rate_desc;
            // }
            // else{
            	data.rate_uom_id = 3;
            	data.rate_desc = data.rate_desc + '%';
            // }
            //console.log(data);
		}

		if(field == 'start' || field == 'end'){
            data.range_uom_desc = '$'; //$('#range_uom').val();
            data.range_uom_id = 4;
            // if(data.range_uom_desc == '$'){
            // 	data.range_uom_id = 4;
            // }
            // else{
            // 	data.range_uom_id = 5;
            // }
        }

		data = JSON.stringify(data);
		//var frm = $('#GPO_Tiers_Form');
		//show_loader('Saving Customer Data...');
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									data: data,
									field: field,
									method: "saveTierData" }
						//,dataType: "json"
						,success: function (data) {
							//console.log(data);
							//rowData_Tiers = JSON.parse(data);   ///   CONFUSED....NO PARSE NEDED ON SAVE, BUT GET NEEDS IT.  SAME FUNCTION GETS DATA
							rowData_Tiers = data;
							tierCount = data.length + 1;
							var i = 1;
				            rowData_Tiers.forEach( function(item) {
					            //console.log('Removed Row Node', rowNode);
					            item.t = "TIER " + i;
					            i++;
					        });
						    Tiers_GridOptions.api.setRowData(rowData_Tiers);
						    $("div.loader").hide();
			              // console.log(data);
			            }
			            ,error: function (data) {
			               $("div.loader").hide();
			                alert('An error occurred (saveTierData).  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function getTiers(){

		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getTierData" }
						//,dataType: "json"
						,success: function (data) {
				            rowData_Tiers = JSON.parse(data);
							tierCount = rowData_Tiers.length + 1;
							setGridHeight(Tiers_GridOptions, "#Tiers_Grid", rowData_Tiers.length);
				            var i = 1;
				            rowData_Tiers.forEach( function(item) {
					            //console.log('Removed Row Node', rowNode);
					            item.t = "TIER " + i;
					            i++;
					        });
				            Tiers_GridOptions.api.setRowData(rowData_Tiers);
			            }
			            ,error: function (data) {
			            	// console.log(data);
			                alert('An error occurred (getTiers).  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function onRemoveSelected() {
		//show_loader('Removing Tier Data...');
	    var selectedData = Tiers_GridOptions.api.getSelectedRows();

		if (selectedData.length <1) {
			new Noty({ text:"Please select a Tier to remove"}).show();
		}
		else {

			if(selectedData[0].tiernum != rowData_Tiers.length){
				new Noty({ text:"You may only remove the last tier in the grid (tier" + rowData_Tiers.length.toString() + ")."}).show();
			}
			else{
				var res = Tiers_GridOptions.api.updateRowData({remove: selectedData});
				var a = [];
				res.remove.forEach( function(rowNode) {
					a.push(rowNode.data);
				});
				deleteTiers(JSON.stringify(a));
			}
		
		}
	    //console.log(Tiers_GridOptions);
	}

	function deleteTiers(arr){

		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									arrData: arr,
									method: "deleteTiers" }
						//,dataType: "json"
						,success: function (data) {
				            rowData_Tiers = JSON.parse(data);
				            //console.log(rowData_Tiers);
							tierCount = rowData_Tiers.length + 1;
							if (tierCount < 2) {
								setGridHeight(Tiers_GridOptions, "#Tiers_Grid", 0);
							}
				            var i = 1;
				            rowData_Tiers.forEach( function(item) {
					            //console.log('Removed Row Node', rowNode);
					            item.t = "TIER " + i;
					            i++;
					        });
	
						     $('#tierButton').attr("disabled", false);

				            Tiers_GridOptions.api.setRowData(rowData_Tiers);
				            $("div.loader").hide();
			            }
			            ,error: function (data) {
			            	// console.log(data);
			            	$("div.loader").hide();
			                alert('An error occurred (getTiers).  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function checkFixedCount(){

		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "checkFixedComp" }
						//,dataType: "json"
						,success: function (data) {
							  if(data > 0){
							  	$('#tierButton').attr("disabled", true);
							  	$('#tierButton').hide();
							  	$('#removeTierButton').attr("disabled", true);
							  	$('#removeTierButton').hide();
							  	$('#createProductTiers').attr("disabled", true);
							  	$('#createProductTiers').hide();
							  }
							  else{
							  	$('#tierButton').attr("disabled", false);
							  	$('#tierButton').show();
							  	$('#removeTierButton').attr("disabled", false);
							  	$('#removeTierButton').show();
							  	$('#createProductTiers').attr("disabled", false);
							  	$('#createProductTiers').show();
							  }       
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			            	//console.log(data);
			                alert('An error occurred (checkFixedCount).  ' + JSON.stringify(data));
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}
	function createProductTiers(){
		//Make sure we have rates
		show_loader('Creating Product Tiers...');
		var stop = 0;
		Tiers_GridOptions.api.forEachNode( function (node) {
	        if (node.data.rate === '0' || node.data.rate === '' || node.data.rate === 0 || $.isNumeric( node.data.rate ) == false) {
	            stop = 1;

	        }
	    });
	    if(stop == 1){
	    	alert('Please enter a rate for each tier!');
	    	return;
	    }
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									Claim_Mechanics: $('#rebate_eligible').val(),
									method: "createComponents" }
						//,dataType: "json"
						,success: function (data) {
							//console.log(data);
							//checkFixedCount();
							//  XXXXXXXXXXXXXX     THIS IS ON THE GPO_PRODUCTS_FORM>CFM INCLUDE FILE     XXXXXXXXXXXXXXXXXXXXXXXX
							getCompIdList();   
							//  XXXXXXXXXXXXXX     THIS IS ON THE GPO_PRODUCTS_FORM>CFM INCLUDE FILE     XXXXXXXXXXXXXXXXXXXXXXXX  
							$("div.loader").hide();
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			            	console.log(data);
			                alert('An error occurred (checkFixedCount).  ' + JSON.stringify(data));
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}
$("#rebate_eligible" ).change(function() {
	updClaimMechanicGPO(); 
});
function updClaimMechanicGPO(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									Claim_Mechanics: $('#rebate_eligible').val(),
									method: "updClaimMechanic" }
						//,dataType: "json"
						,success: function (data) {
							console.log(data);
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			                $("div.loader").hide();
			                alert('An error occurred (updClaimMechanic).  ' + JSON.stringify(data));
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}
	document.addEventListener("DOMContentLoaded", function () {
        Build_TiersGrid();
        getTiers();
        //checkFixedCount();
    });

</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


