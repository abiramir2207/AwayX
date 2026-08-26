
<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/OPP/RFP_Components_Form.cfm
   Author: Mark Saunderss
   Date: 3/25/2020

   Usage: basic Info module for RFP deal (Request For Pricin.  Custom feature.
   		  Called from  /Common_Files/contracts/OPP/RFP.cfm

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--->
<cfscript>
	cfparam(name="oppViewOnly", default=0);
	sEditable = 'true';
	if(oppViewOnly == 1){
		sEditable = 'false';
	}

</cfscript>
	<cfquery name="qGetPayTypes" datasource="#application.datasource#">
		SELECT DISTINCT PT.Payment_Type_Name, PT.Payment_Type_ID, PT.Is_Auto_pay,PT.Restrict_From_Billback,
			ISNULL(NULLIF(CM.ClaimMechanics,0),pcpo.ClaimMechDefaultOption) AS ClaimMechanics
			FROM Contract_Main CM
			INNER JOIN Payment_Template_Mapping PTM ON
				PTM.Template_ID = CM.ProgramType_ID
			INNER JOIN Payment_Type PT
				ON PT.Payment_Type_ID = PTM.Payment_Type_ID
			INNER JOIN Program_Control_Panel_Options pcpo on PCPO.ProgramControl_Panel_Options_Id = PTM.Template_Id
			WHERE CM.Contract_Main_ID = #variables.ContractMainID#
	</CFQUERY>

	<cfquery name="qGetScheduleOptions" datasource="#application.datasource#">
			SELECT DISTINCT FSO.FP_Schedule_Option_ID,
									FSO.Price_Day_Code,
									FSO.Price_Day_Description,
									FSO.Effective_Day,
									FSO.Effective_Day_Description,
									FSO.Notes,
									FSO.Price_Day_Frequency,
									FSO.Price_Day_When,
									FSO.Effective_Day_Type,
									FSO.Effective_Day_When,
									ISNULL(CM.Formula_Price_Rebate_Type,0) AS selectedOptionId,
									ISNULL(CM.Revision_Version,1) AS Revision_Version,
									ISNULL(Is_A_Revision,0) AS Is_A_Revision
							FROM Contract_Main CM
							-- LEFT JOIN Program_Formula_Pricing_Rules PFPR ON
							-- 	PFPR.FP_Schedule_Option_ID = FSO.FP_Schedule_Option_ID and
							-- 	PFPR.Program_ID = '#variables.ContractMainID#' and
							-- 	PFPR.Deleted = 0
							LEFT JOIN FP_Schedule_Options FSO
								ON  FSO.active = 1
							WHERE CM.Contract_Main_Id = '#variables.ContractMainID#'
							ORDER BY price_Day_Frequency desc,Price_Day_When ASC
	</cfquery>
</cfsilent>
<style>
	.container {
	    width:100%;
	    height: 100%;
	    /*border:1px solid #d3d3d3;*/
	}
	.container div {
	    width:100%;
	}
	.container .sectionHeader {
	    /*background-color:#d3d3d3;*/
	    padding: 2px;
	    cursor: pointer;
	/*}*/
	.container .content {
	    /*display: none;*/
	    padding : 5px;
	}
</style>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<div class="container">
 <div class="comp"><h5 class="sectionHeader compText">COMPONENTS (Collapse)</h5></div>

    <div class="sectionContents text-xs">

		<!--- COMPONENTS GRID --->
        <div class="table-row review">
            <button type="button" class="button table-cell review" id="deleteProductComponents" <cfif sEditable>onclick="deleteRFPComponents();return false;" </cfif>style="margin: 5px 0 0 0">Delete All Product Components</button>
        </div>

        <div id="Components_Grid" style="width: 520px;height: 200px;" class="ag-theme-balham ml-2 mt-2 pb-3"></div>

		<!--- </div> --->
		 <CFIF GetSettings.Discount_Formula_Pricing EQ 1>
		 	<div id="ScheduleOptions"  class="table-row" >  <!---style="height: 30px; padding-top: 30 px;"  class="ag-theme-balham ml-2 mt-2 pb-3" --->
		 		<span class="table-cell"  style="height: 0px;"></span>
		 		<br>
			     <label class="opacity-75 pr-1"style="padding-left: 0 px;">Schedule Options:</label>
					<select name="schedule_options" id="schedule_options" class="border rounded">
						<option disabled selected value>-- Select a Formula Schedule --</option>
						<cfoutput query="qGetScheduleOptions">
							<cfset s = ''/>
							<cfif FP_Schedule_Option_ID eq selectedOptionId><cfset s = 'selected'/></cfif>
							<option value="#FP_Schedule_Option_ID#" #s#>#Price_Day_Description# :: #Effective_Day_Description#</option>
						</cfoutput>
					</select>
			</div>
		</CFIF>
    </div>
</div>


<style>
	.ag-body-horizontal-scroll-viewport {
		overflow-x: hidden;
	}
</style>
<SCRIPT>
	// ComponentS test data
	var columnDefs_Components = [
	    {headerName: "Component #", field: "chkbox", width:100, checkboxSelection:true, sortable: false},
	    {headerName: "Name", field: "name", width:250, editable: false, sortable: false},
	    {headerName: "Pay Type", field: "pay_type", width:150,filter: 'agTextColumnFilter',  headerClass:'custom-header' ,headerClass: 'multiline',
	    	valueFormatter: function (params) {
    			if (typeof params.value !== 'undefined'){
		   			return params.value.pay_name;
		   		}
			    return '';
    		}
	    	<cfif sEditable ><cfset i = 1>
	  				// 	,editable:function(params) {
					// 	return params.node.data.selected == 1;
					// }
					,editable: false
				 	,cellEditor : 'agRichSelectCellEditor'
					,cellEditorParams : {
					    values:[
					    <cfoutput query="qGetPayTypes">
					    		{pay_name:'#qGetPayTypes.Payment_Type_Name#', pay_id: '#qGetPayTypes.Payment_Type_ID#'}<cfif i Neq qGetPayTypes.recordcount>,</cfif>
					    		<cfset i = i + 1>
					    </cfoutput>],
					   formatValue: function(value) {
					   		if (typeof value !== 'undefined'){
					   			return value.pay_name;
					   		}
					    	return '-- --';
						},
						cellRenderer: function(params) {
							if (typeof params.value !== 'undefined'){
					   			return params.value.pay_name;
					   		}
						    return '-- Select a Pay Type --';
						}
					}
			</cfif>
		}
	];

	var rowData_Components = [];
	var ComponentCount = 1;

	var editable = 1;
	var Components_GridOptions = {};
	function Build_ComponentsGrid() {
	    // Init Components grid
	    Components_GridOptions = {
	        columnDefs: columnDefs_Components
	        <cfif sEditable>
	        	,rowSelection: 'multiple'
	        </cfif>
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
	        <cfif sEditable>
	        ,onRowSelected: function(event) {
		        if(event.data.selected != event.node.selected){
		        	//if($('#rebate_eligibleRFP').val() != 0){
		        		event.data.selected = event.node.selected;
		        	//}
		        	if(event.data.selected){
		        		saveComponentData(event.data);
		        	}
		        	else{
		        		 if(Components_GridOptions.api.getSelectedRows().length > 0 || $('#massApplyList').children('option').length >= 3){
		        		 	deleteUnSelectedRFPCompFromComp(event.data.compid);
		        		 }
		        		 else{
		        		 	deleteRFPComponents();
		        		 }

		        	}
		        }
		       // alert('onCellValueChanged: ' + event.colDef.field + ' = ' + event.newValue);
		    }
		    ,onCellValueChanged: function(event) {
		        if(event.oldValue != event.newValue){
		        	var s = event.colDef.field;

		        	switch(s) {
					  case 'pay_type':
					    updClaimMechanic(JSON.stringify(event.data), event.colDef.field);
					    break;
					  default:
						console.log(event);
					}
		        }
		    }
		    </cfif>
	    };
	    ag_grid_default(Components_GridOptions);		// set up default features
        <cfif request.page_mode is review_mode>
            disable_editing( Components_GridOptions );
        </cfif>
	    init_ag_grid( Components_GridOptions, "#Components_Grid", false );   // setup as client side

	}

	function refreshCompData(){
		//$("#massApplyList").empty();
		//$("#massApplyList").append($('<option></option>').attr('value', 0).text(' -- select a component -- '));
		getComponents();
	    getRFPCompIdList(); //This is on RFP_Products_Form

	}

	function saveComponentData(svData){
        <cfif request.page_mode is review_mode> return; </cfif>
		data = JSON.stringify(svData);
		show_loader('Creating Components...');
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									Component_Name_ID: svData.compid,
									//data: data,
									Claim_Mechanics: svData.pay_type.pay_id,
									method: "saveRFPFixedComp" }
						//,dataType: "json"
						,success: function (data) {
							//alert(data);
							//rowData_Components = JSON.parse(data);   ///   CONFUSED....NO PARSE NEDED ON SAVE, BUT GET NEEDS IT.  SAME FUNCTION GETS DATA
							rowData_Components = data;
							//saveSelectedRFPProducts(); // ON RFP_Products_Form.cfm
					        //Components_GridOptions.api.setRowData(rowData_Components);
					        //if(editable === 0){
						       refreshCompData();
	      					//}
	      					$("div.loader").hide();
			            }
			            ,error: function (data) {
			               $("div.loader").hide();
			                alert('An error occurred (saveComponentData).  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}

	function getComponents(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getFixedComps" }
						//,dataType: "json"
						,success: function (data) {
				            rowData_Components = JSON.parse(data);

				            rowData_Components.forEach(function(item){
				            	item.pay_type = {pay_id: item.pay_id, pay_name: item.pay_name};
							});

				            Components_GridOptions.api.setRowData(rowData_Components);
				            Components_GridOptions.api.forEachNode( function (node) {
						        if (node.data.selected === 1) {
						        	node.setSelected(true);
						        }
						    });
						    Components_GridOptions.api.doLayout();
			            }
			            ,error: function (data) {
			                alert('An error occurred (getComponents).  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}

	function onRemoveSelected() {
		//show_loader('Removeing Component Data...');
		if(editable === 0){
			alert('Remove not allowed after saving components.');
			return;
		}
	    var selectedData = Components_GridOptions.api.getSelectedRows();
	    var res = Components_GridOptions.api.updateRowData({remove: selectedData});
	    var a = [];
	    res.remove.forEach( function(rowNode) {
            a.push(rowNode.data);
        });
        deleteComponents(JSON.stringify(a));
	}

	function deleteRFPComponents(){
        <cfif request.page_mode is review_mode> return; </cfif>
		show_loader('Deleting Components and Products...');
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "deleteRFPComponents" }
						//,dataType: "json"
						,success: function (data) {
				            refreshCompData();
      						$("div.loader").hide();
			            }
			            ,error: function (data) {
			            	$("div.loader").hide();
			                alert('An error occurred (deleteComponents).  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}

	function createRfpComponents(){
        <cfif request.page_mode is review_mode> return; </cfif>
		//Make sure we have rates
		if(editable == 0){
			alert('Create not allowed after saving components.');
			return;
		}
		show_loader('Creating Components and Products...');
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									//LoyaltyCompId: $("#rfp_loyalty").val(),
									Claim_Mechanics: $('#rebate_eligibleRFP').val(),
									method: "createRfpComponents" }
						//,dataType: "json"
						,success: function (data) {
							refreshCompData();
      						$("div.loader").hide();
			            }
			            ,error: function (data) {
			                $("div.loader").hide();
			                alert('An error occurred (createRfpComponents).  ' + JSON.stringify(data));
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}

	function updClaimMechanic(data, field){
        <cfif request.page_mode is review_mode> return; </cfif>
		var d = JSON.parse(data);
		if(d.prg_comp_id == 0){
			return;
		}
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									stData: data,
									method: "updClaimMechanic" }
						//,dataType: "json"
						,success: function (data) {
							//refresh
							getComponents();
			            }
			            ,error: function (data) {
			                $("div.loader").hide();
			                alert('An error occurred (updClaimMechanic).  ' + JSON.stringify(data));
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}

	function deleteUnSelectedRFPCompFromComp(compId){
        <cfif request.page_mode is review_mode> return; </cfif>
		show_loader('Deleting Selected Rebate Component...');
		//var compId = $("#massApplyList").val();
		$.ajax({
					async: true
					,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
								compId: compId,
								method: "deleteOneRFPComponent" }
					,success: function (data) {
		     			// ON RFP_Components_Form.cfm
		     			refreshCompData();
		        		// ON RFP_Components_Form.cfm
		            	$("div.loader").hide();
		            }
		            ,error: function (data) {
		            	$("div.loader").hide();
		                alert('An error occurred.  ' + JSON.stringify(data) );
		            }
					,type: "post"
					,url: "/mvc/Models/Program/RfpManager.cfc"
		});
	}
	document.addEventListener("DOMContentLoaded", function () {
        Build_ComponentsGrid();
      	getComponents();
      	//getLoyalty();
      	//checkRFPRebateComp();
       // checkRFPComponentCount();
    });

    $(".comp").click(function () {

    $header = $(this);
    //getting the next element
    $content = $header.next();
    //open up the content needed - toggle the slide- if visible, slide up, if not slidedown.
    $content.slideToggle(500, function () {
        //execute this after slideToggle is done
        //change text of header based on visibility of content div
        $(".compText").text(function () {
            //change text based on condition
            return $content.is(":visible") ? "COMPONENTS (Collapse)" : "COMPONENTS (Expand)";
        });
    });

    //in  RFP_Products_Form.cfm
   // setWidthAndHeight('100%');

});

</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"<h5 class="sectionHeader">COMPONENTS (Collapse)</h5>" : "<h5 class="sectionHeader">COMPONENTS (Expand)</h5>"  --->


