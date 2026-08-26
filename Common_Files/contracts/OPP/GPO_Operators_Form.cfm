
<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/OPP/GPO_Operators_Form.cfm
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

<!--- ================================== START/END DAte Logic ======================================= --->
<cfset startDateDisabled = 0 />
<cfset EndDateDisabled = 0 />

<!--- ================================== START/END DAte Logic ======================================= --->

<h5 class="sectionHeader">END USER(S) / OPERATOR(S)</h5>
                
<div class="sectionContents text-xs">
    <form id="OperatorSearchForm" name="OperatorSearchForm" action="javascript:saveSelectedOperators();">
		<fieldset id="OperatorSearchSection" class="fieldGroup p-2">
				
			<legend>Operator Search</legend>

			<div class="flex flex-wrap">
				<!--- <label class="mr-1">Search by:</label>  --->
				<!--- <input type="radio" name="search_by" id="search_by_GPO_key" value="1" checked/><label for="search_by_GPO_key">GPO Key</label> --->
				<div class="mb-2">	<!--- add margin in case of wrap --->
					<label class="ml-1 mr-px">Key:</label> 
					<select name="key_type" id="key_type" class="border rounded">
						<option selected value="0"> -- select a GPO Key -- </option>
					</select>
				</div>
				<div>
					<label class="ml-4 mr-px">Parent Level:</label> 
					<select name="level" id="level" class="border rounded">
						<option selected value="0"> -- select Operator Level -- </option>
						<option value="1">Top Parent Name 1</option>
						<option value="2">Top Parent Name 2</option>
						<option value="3">Direct_Parent_Name_1</option>
						<option value="4">Direct_Parent_Name_2</option>
					</select>
				</div>

				<cfif isGPO EQ 0>
					<div>
						<label class="ml-4 mr-px">Rollup Level:</label> 
						<select name="rollup" id="rollup" class="border rounded">
							<option selected value="0"> -- select Rollup Level -- </option>
							<option value="5">Parent</option>
							<option value="6">Child</option>
						</select>
					</div>
				</cfif>
				<button type="button" class="button alt ml-4" onclick="showOperatorSearchWindow();return false;">Search Operators</button>
			</div>
		   <!---  <button type="button" class="button ml-4" onclick="deleteSelectedOperators();return false;">Delete Selected Operators</button> --->
		</fieldset>
        <INPUT NAME="Operator_List" ID="Operator_List" TYPE="HIDDEN" VALUE="">
        <INPUT NAME="SelectSingleSearchResultOnly" TYPE="HIDDEN" VALUE="0">
    </form>

    <!--- SAMPLE GRID --->
    <div id="Operators_Grid" style="width: 685px; height: 150px;" class="ag-theme-balham ml-2 mt-2"></div>
</div>
		
<SCRIPT>
	// Operator test data
	var init = 1; //on load we don't want to save onRowSelected
	var columnDefs_GPO_Operators = [
	    {headerName: "GPO KEY", field: "key",  width:100, filter: 'agTextColumnFilter', checkboxSelection: true},
	    {headerName: "PARENT/ROLLUP LEVEL", field: "level",  width:130, filter: 'agTextColumnFilter'},
	    {headerName: "PARENT/ROLLUP NAME", field: "name",  width:450, filter: 'agTextColumnFilter'},
	];
	var rowData_GPO_Operators = [];
	var Operators_GridOptions = {};
	<!-------------var rowData_GPO_Distributors = <cfoutput>#application.util.query.toAgGridJSON(q, 'cust, type, strat')#</cfoutput>;  -------->
	function Build_GPOOperatorsGrid() {
	    // Init Operators grid
	    Operators_GridOptions = {
	        columnDefs: columnDefs_GPO_Operators
	        ,floatingFilter: true
	        ,rowSelection: 'single'
	        ,rowData: rowData_GPO_Operators
	        ,rowModelType: "clientSide"     // TODO change to server-side
	        ,cacheBlockSize: 2000
	        ,suppressRowClickSelection: true
	        ,onRowSelected: function(event) {
        		var selectedRows = Operators_GridOptions.api.getSelectedRows();
        		if(selectedRows.length && selectedRows[0].name != currentSelection && event.node.selected === true){
					saveOperator(selectedRows);
				}
				else if(event.node.selected === false && event.data.level === 'End User'){
					deleteSelectedOperator(event.data.key);
				}
				else if(event.node.selected === false && event.data.level != 'End User'){
					deleteOperatorLevel();
				}
		    }

	     //    ,onSelectionChanged: function(event) {
	     //    	var selectedRows = Operators_GridOptions.api.getSelectedRows();
		    //     saveOperator(selectedRows);
		    // }
	        ,onGridReady: function () {
	            // this.api.sizeColumnsToFit();
	        }
	    };
	    ag_grid_default(Operators_GridOptions);		// set up default features
	    init_ag_grid( Operators_GridOptions, "#Operators_Grid", false );   // setup as client side TODO change to server-side
	}

	function setcolDefs(isSelectable) {
		if(isSelectable == 1){
			columnDefs_GPO_Operators = [
			    {headerName: "GPO KEY", field: "key",  width:100, filter: 'agTextColumnFilter', checkboxSelection: true},
			    {headerName: "PARENT/ROLLUP LEVEL", field: "level",  width:130, filter: 'agTextColumnFilter'},
			    {headerName: "PARENT/ROLLUP NAME", field: "name",  width:450, filter: 'agTextColumnFilter'},
			];
		}
		else{
			columnDefs_GPO_Operators = [
			    {headerName: "END USER NUMBER", field: "key",  width:100, filter: 'agTextColumnFilter'},
			    {headerName: "LEVEL", field: "level",  width:130, filter: 'agTextColumnFilter'},
			    {headerName: "END USER NAME", field: "name",  width:450, filter: 'agTextColumnFilter'},
			];
		}
		
	}

	$( "#key_type" ).change(function() {
	  Operators_GridOptions.rowSelection = 'single';
	  getOperators(0,0);
	});

	$( "#level" ).change(function() {
	  Operators_GridOptions.rowSelection = 'single';
	  getOperators(0,1);
	});
	$( "#rollup" ).change(function() {
	  getOperators(0,2);
	});
	function showOperatorSearchWindow() 
   {
		NewWindow("/billbacks/search_screens/PM_select_operators.cfm?FormName=OperatorSearchForm", "operatorwindow", 800, 600, "yes", "yes");
		return false;
	}

	function showOperatorSearchWindow2() {
	   	NewWindow("/cm/search/PM_select_operators.cfm?Formname=OperatorSearchForm", "operatorwindow", 800, 600, "yes", "yes");
	   	return false;
	   }

	var currentSelection = '';
	function getOperators(ContractId,varLev){
		var frm = $('#OperatorSearchForm');
		var gpoKey = $("#key_type").val();
		var gpolevel = $("#level").val();
		var gpoRollup = $("#rollup").val();
		if(gpoKey == '' && ContractId == 0  && gpoRollup =='') {
			//alert('xx');
			return;
		}
		if(varLev == 2 && gpoRollup > 0){
			if(gpoRollup === 6){ //this is the "Child Option" in the Rollup selection
				Operators_GridOptions.rowSelection = 'multiple';
			}
			else{
				Operators_GridOptions.rowSelection = 'single';
			}
			gpolevel = gpoRollup;
			gpoKey = 0;
		}
		$.ajax({
						async: true
						,data: { 	gpoKey: 	gpoKey,
									level:      gpolevel,
									contractId: ContractId,
									method: "getOperatorList" }
						//,dataType: "json"
						,success: function (data) { 
			              rowData_GPO_Operators = JSON.parse(data);
			             //console.log(rowData_GPO_Operators);
			              Operators_GridOptions.api.setRowData(rowData_GPO_Operators);
			              if(rowData_GPO_Operators.length){
				              		if(rowData_GPO_Operators[0].level_id === ''){
				              			 $("#Operators_Grid").empty();
				              			 setcolDefs(1);
				              			 Build_GPOOperatorsGrid();
				              		}
				              		else{
				              			$("#Operators_Grid").empty();
				              			setcolDefs(1);
				              			Build_GPOOperatorsGrid();
				              		}
			              }
			              if(ContractId != 0) {
			              		if(rowData_GPO_Operators.length){
			              			var x = 1;
			              			$('#Operator_List').val('');
									currentSelection = rowData_GPO_Operators[0].name;
									$("#key_type").val(rowData_GPO_Operators[0].gpo_id);
									$("#level").val(rowData_GPO_Operators[0].level_id);
									$("#rollup").val(rowData_GPO_Operators[0].level_id);
									Operators_GridOptions.api.selectAll();
									Operators_GridOptions.api.forEachNode( function (node) {       
								        if(x == 1){
							            	$('#Operator_List').val(node.data.gpo_id);
							            }
							            else{
							            	$('#Operator_List').val($('#Operator_List').val() + ',' + node.data.gpo_id);
							            }
						                x++;
								    });
								}	
							}		
							else{
								//console.log(rowData_GPO_Operators.length);
								Operators_GridOptions.api.forEachNode( function (node) {
							        if (node.data.gpo_id == $("#key_type").val() && node.data.level_id == $("#level").val() && node.data.name == currentSelection && currentSelection != '' ) {
							           node.setSelected(true);
							        }
							    });
							}
							$("div.loader").hide();
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function saveOperator(selectedData){
		show_loader('Saving Operators...');
		$.ajax({
						async: true
						,data: { 	gpoId: 	selectedData[0].gpo_id,
									levelId:      selectedData[0].level_id,
									name: selectedData[0].name,
									contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "saveOperator" }
						//,dataType: "json"
						,success: function (data) {
			              //Operators_GridOptions.api.setRowData(rowData_GPO_Operators);
			              getOperators(<cfoutput>#variables.ContractMainID#</cfoutput>);

			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}
	function deleteSelectedOperator(operatorId){
		$.ajax({
						async: true
						,data: { 	operatorId: operatorId,
									contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "deleteOperator" }
						//,dataType: "json"
						,success: function (data) {
			              //Operators_GridOptions.api.setRowData(rowData_GPO_Operators);
			              getOperators(<cfoutput>#variables.ContractMainID#</cfoutput>);

			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function deleteOperatorLevel(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "deleteOperatorLevel" }
						//,dataType: "json"
						,success: function (data) {
			              //Operators_GridOptions.api.setRowData(rowData_GPO_Operators);
			              $("#level").val(0);
			              $("#key_type").val(0);
			              $("#rollup").val(0);
			              //getOperators(<cfoutput>#variables.ContractMainID#</cfoutput>);
			              Operators_GridOptions.api.setRowData([]);
			              currentSelection = '';
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}
	function getGPOList(){
		var frm = $('#OperatorSearchForm');
		var gpoKey = $("#key_type").val();
		$.ajax({
						async: true
						,data: { 	method: "getGPOList" }
						//,dataType: "json"
						,success: function (data) {
			                var res = JSON.parse(data);
			                //console.log(res);
			                 $.each(res, function (key, entry) {
							    $("#key_type").append($('<option></option>').attr('value', entry.operator_gpo_id).text(entry.gpo_key));
							  })
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function saveSelectedOperators(){
		//popupInCenter('about:blank', "formpopup", 1000, 650);
		show_loader('Saving Selected Operators...');
		var data = $('#Operator_List').val();

		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									oprList: data,
									method: "saveSelectedOperators" }
						//,dataType: "json"
						,success: function (data) {
							//console.log(data);
							getOperators(<cfoutput>#variables.ContractMainID#</cfoutput>);
							// rowData_GPO_Operators = data;
							// Operators_GridOptions.api.setRowData(rowData_GPO_Operators);
						    $("div.loader").hide();

			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			               $("div.loader").hide();
			                alert('An error occurred.  ' + data.toString() );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	document.addEventListener("DOMContentLoaded", function () {
        Build_GPOOperatorsGrid();
        getGPOList();
        getOperators(<cfoutput>#variables.ContractMainID#</cfoutput>,0);
    });
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


