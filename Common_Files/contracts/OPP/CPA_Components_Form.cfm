
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
<!--- <cfquery name="qGetLoyalty" datasource="#application.datasource#">
			SELECT DISTINCT PT.Payment_Type_Name, PT.Payment_Type_ID, PT.Is_Auto_pay,PT.Restrict_From_Billback
				FROM Contract_Main CM
				INNER JOIN Payment_Template_Mapping PTM ON
					PTM.Template_ID = CM.ProgramType_ID
				INNER JOIN Payment_Type PT
					ON PT.Payment_Type_ID = PTM.Payment_Type_ID 
				WHERE CM.Contract_Main_ID = #variables.ContractMainID# 
		</CFQUERY> --->
</cfsilent>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


 <h5 class="sectionHeader">COMPONENTS</h5>

    <div class="sectionContents text-xs">
		<div class="ml-2">
        	<label class="opacity-75 pr-1">Rebate Eligibility:</label>
	        	<select name="rebate_eligibleCPA" id="rebate_eligibleCPA" class="border rounded">
	           		<option selected value="0"> -- select Eligibility -- </option>
		        	<cfoutput query="qGetPayTypes">
		        		<cfset s = ''/>
						<cfif claimMechanics eq Payment_Type_ID><cfset s = 'selected'/></cfif>
		            	<option value="#Payment_Type_ID#" #s#>#Payment_Type_Name#</option>
		        	</cfoutput>
	            </select>
		</div>

		<!--- COMPONENTS GRID --->
		<div id="Components_Grid" style="width: 405px; height: 120px;" class="ag-theme-balham ml-2 mt-2 pb-3"></div>

		<!--- <div class="flex-column"> --->
			<div class="table-row">
				<label class="opacity-75 pr-1 table-cell text-right">Loyalty:</label>
				<span class="table-cell">
					<select name="cpa_loyalty" id="cpa_loyalty" class="border rounded" style="width: 300px;">
					</select>
					<button type="button" class="button table-cell" id="saveLoyaltyComponent" onclick="saveLoyaltyComp();return false;" style="margin: 10px 0 0 0">Add Loyalty</button>
				</span>
			</div>
			<div class="table-row">	
				<span class="table-cell"></span> <!--- empty space to line up buttons --->		
				<button type="button" class="button table-cell" id="createProductComponents" onclick="createCpaComponents();return false;" style="margin: 10px 0 0 0">Create Product Components</button>
				<button type="button" class="button table-cell" id="deleteProductComponents" onclick="deleteCPAComponents();return false;" style="margin: 10px 0 0 0">Delete All Product Components</button>
			</div>
		<!--- </div> --->
    </div>

<SCRIPT>
	// ComponentS test data
	var columnDefs_Components = [
	    {headerName: "Component #", field: "chkbox", width:100, checkboxSelection: true, sortable: false},
	    {headerName: "Name", field: "name", width:300, editable: false, sortable: false}
	];

	var rowData_Components = [];

	$("#rebate_eligibleCPA" ).change(function() {
		updClaimMechanic(); 
	});
	var ComponentCount = 1;

	var editable = 1;
	var Components_GridOptions = {};
	function Build_ComponentsGrid() {
	    // Init Components grid
	    Components_GridOptions = {
	        columnDefs: columnDefs_Components
	        ,rowSelection: 'multiple'
	        ,suppressRowClickSelection: true
	        ,defaultColDef: {editable: true,
							  resizable: true}
	        ,singleClickEdit: true
	        ,stopEditingWhenGridLosesFocus: true
	        ,rowData: rowData_Components
	        ,rowModelType: "clientSide" 
	        ,cacheBlockSize: 2000
	        ,onGridReady: function () {
	            // this.api.sizeColumnsToFit();
	        }
	        ,onRowSelected: function(event) {
		        if(event.data.selected != event.node.selected){
		        	if($('#rebate_eligibleCPA').val() != 0){
		        		event.data.selected = event.node.selected;
		        	}
		        	if(event.data.selected){
		        		saveComponentData(event.data);
		        	}
		        	else{
		        		if(Components_GridOptions.api.getSelectedRows().length > 0 || $('#massApplyList').children('option').length >= 3){
		        			deleteUnSelectedCPACompFromComp(event.data.compid);
		        		}
		        		else{
		        			deleteCPAComponents();
		        		}
		        		
		        	}
		        }
		       // alert('onCellValueChanged: ' + event.colDef.field + ' = ' + event.newValue);
		    }
	    };
	    ag_grid_default(Components_GridOptions);		// set up default features
	    init_ag_grid( Components_GridOptions, "#Components_Grid", false );   // setup as client side
	}

	function refreshCompData(){
		$("#massApplyList").empty();
		$("#massApplyList").append($('<option></option>').attr('value', 0).text(' -- select a component -- '));
		$("#cpa_loyalty").empty();
		getComponents();
	    getLoyalty(); 
	    getCPACompIdList(); //This is on CPA_Products_Form
	    checkCPARebateComp();
	}

	function saveLoyaltyComp(){
		var data = {};
		data.compid = $("#cpa_loyalty").val();
		data.selected = true;
		saveComponentData(data);
	}
	function saveComponentData(svData){
		data = JSON.stringify(svData);
		//show_loader('Saving Customer Data...');
		// if(editable === 0){
		// 	alert('Save not allowed after saving components.');
		// 	return;
		// }
		if($('#rebate_eligibleCPA').val() == 0){
			Components_GridOptions.api.deselectAll();
			alert('Please select a Rebate Eligibility option.');
			return;
		}
		//console.log(data);
		show_loader('Creating Components and Products...');
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									data: data,
									Claim_Mechanics: $('#rebate_eligibleCPA').val(),
									method: "saveCPARebateComp" }
						//,dataType: "json"
						,success: function (data) {
							//rowData_Components = JSON.parse(data);   ///   CONFUSED....NO PARSE NEDED ON SAVE, BUT GET NEEDS IT.  SAME FUNCTION GETS DATA
							rowData_Components = data;
					        //Components_GridOptions.api.setRowData(rowData_Components);
					        if(editable === 0){
						       refreshCompData();
	      					}
	      					$("div.loader").hide();
			            }
			            ,error: function (data) {
			               $("div.loader").hide();
			                alert('An error occurred (saveComponentData).  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function getComponents(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getRebateComps" }
						//,dataType: "json"
						,success: function (data) {
				            rowData_Components = JSON.parse(data);  
				            Components_GridOptions.api.setRowData(rowData_Components);
				            Components_GridOptions.api.forEachNode( function (node) {
						        if (node.data.selected === 1) {
						        	//console.log(node);
						        	$("#massApplyList").append($('<option></option>').attr('value', node.data.compid).text(node.data.name));// ON CPA_Components_Form
						        	node.setSelected(true);
						        }
						    });
			            }
			            ,error: function (data) {
			            	// console.log(data);
			                alert('An error occurred (getComponents).  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function getLoyalty(){

		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									isLoyalty: 1,
									method: "getRebateComps" }
						//,dataType: "json"
						,success: function (data) {
				            var loyalty = JSON.parse(data);
				            $("#cpa_loyalty").append($('<option></option>').attr('value', 0).text(' -- select a Loyalty Component -- ')); 
				            $("#cpa_loyalty").val(0);
				               $.each(loyalty, function (key, entry) {
				               	//$("#massApplyList").append($('<option></option>').attr('value', entry.compid).text(entry.name))
			                 		$("#cpa_loyalty").append($('<option></option>').attr('value', entry.compid).text(entry.name));
			                 		if(entry.selected){
			                 			$("#cpa_loyalty").val(entry.compid);
			                 			$("#massApplyList").append($('<option></option>').attr('value', entry.compid).text(entry.name))  //  ON CPA_Components_Form
			                 			$("#saveLoyaltyComponent").hide();
			                 		}		    
							  })
			              //  $("#cpa_loyalty").chosen({search_contains: true, enable_split_word_search: true});
			            }
			            ,error: function (data) {
			            	// console.log(data);
			                alert('An error occurred (getLoyalty).  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function onRemoveSelected() {
		//show_loader('Removeing Component Data...');
		//console.log(editable);
		if(editable === 0){
			alert('Remove not allowed after saving components.');
			return;
		}
	    var selectedData = Components_GridOptions.api.getSelectedRows();
	    //console.log(selectedData);
	    var res = Components_GridOptions.api.updateRowData({remove: selectedData});
	    var a = [];
	    res.remove.forEach( function(rowNode) {
            //console.log('Removed Row Node', rowNode);
            a.push(rowNode.data);
        });
        deleteComponents(JSON.stringify(a));
	    //console.log(Components_GridOptions);
	}

	function checkCPARebateComp(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "checkCPARebateComp" }
						//,dataType: "json"
						,success: function (data) {
						  var oData = JSON.parse(data);
			             // console.log(oData[0]); 
			              if(oData[0].inumber > 0){ //disable button
			              	//$("#createProductComponents").attr("disabled", "disabled");
			              	$("#createProductComponents").hide();
			              	$("#deleteProductComponents").show();
			              	$("#cpaSelectProdsButton").show();
			              	$("#cpaDeleteProdsButton").show();
			              	if($("#cpa_loyalty").val() !=0){
			              		$("#saveLoyaltyComponent").hide();
			              	}
			              	else{
			              		$("#saveLoyaltyComponent").show();
			              	}
			              	editable = 0;
			                 Components_GridOptions.rowselection = false;
			              }
			              else{

			              	$("#createProductComponents").show();
			              	$("#deleteProductComponents").hide();

			              	$("#cpaSelectProdsButton").hide();
			              	$("#cpaDeleteProdsButton").hide();

			              	$("#saveLoyaltyComponent").hide();
			              	editable = 1;
			                Components_GridOptions.rowselection = true;
			              }
			              //console.log(comps);  
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function deleteCPAComponents(){
		show_loader('Deleting Components and Products...');
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "deleteCPAComponents" }
						//,dataType: "json"
						,success: function (data) {
				            refreshCompData();
      						$("div.loader").hide();
			            }
			            ,error: function (data) {
			            	// console.log(data);
			            	$("div.loader").hide();
			                alert('An error occurred (deleteComponents).  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function createCpaComponents(){
		//Make sure we have rates
		if(editable == 0){
			alert('Create not allowed after saving components.');
			return;
		}
		// if($("#NonGpo_Price_List_Id").val()== 0 && $("#Gpo_Price_List_Id").val()== 0){ //Price list selections from CPA_Price_List_Form.CFM
		// 	alert('Please select a Pricelist before creating product components.');
		// 	return;
		// }
		show_loader('Creating Components and Products...');
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									LoyaltyCompId: $("#cpa_loyalty").val(),
									Claim_Mechanics: $('#rebate_eligibleCPA').val(),
									method: "createCpaComponents" }
						//,dataType: "json"
						,success: function (data) {
							refreshCompData();
      						$("div.loader").hide();
      						//console.log(data);
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			                $("div.loader").hide();
			                alert('An error occurred (createCpaComponents).  ' + JSON.stringify(data));
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function updClaimMechanic(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									Claim_Mechanics: $('#rebate_eligibleCPA').val(),
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
	function deleteUnSelectedCPACompFromComp(compId){
		show_loader('Deleting Selected Rebate Component...');
		//var compId = $("#massApplyList").val();
		$.ajax({
					async: true
					,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
								compId: compId,
								method: "deleteOneCPAComponent" }
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
        Build_ComponentsGrid();
      	getComponents();
      	getLoyalty();
      	checkCPARebateComp();
       // checkCPAComponentCount();
    });

</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


