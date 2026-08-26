
<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/OPP/GPO_Distributors_Form.cfm
   Author: Mark Saunderss
   Date: 3/8/2019
 
   Usage: basic Info module for One Page Program Creation.  Custom feature.
   		  Called from  /Common_Files/contracts/OPP/GPO_One_Page_Programm.cfm
       
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
--->
</cfsilent>
<cfparam name="form.FinalItemList"	default="">
<cfparam name="form.excludeDistributor"		default="">
<cfparam name="form.finishedselectingitems"	default="0">

<cfparam name="form.editcurrentweight"	default="0">
<cfparam name="form.autoApplyWeight"	default="0">
<cfparam name="form.LoadSavedDistributors"	default="0">
<cfparam name="form.finishedselectingitems"	default="0">
<cfparam name="form.updateFinalItemListFrompopup"	default="0">
<cfparam name="form.Is_Group"	default="1">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

 <cfscript>
 		oOPP		= CreateObject("component", "mvc.Models.Program.OnePageProgramManager");
 		qStrat	= oOPP.isStrategic(variables.ContractMainID);
		isStrat	= qStrat.strategic;
		//writedump(var=qStrat,output='c:\dump.log');
		sStrat  = 'Non-Strategic';
		if(isStrat){
			sStrat  = 'Strategic';
		}
</cfscript>
<cfquery name="CheckForExistingDistributors" datasource="#application.datasource#">
		SELECT CD.*,C.Name + ' (' + C.Ship_to + ')' as cust, L.Group_Level_Desc as type,ISNULL(strat.Distributor_Type_C,'Non-Strategic') AS Strat,Distributor_Group_Id
	FROM 	Contract_Distributors CD
	LEFT JOIN BSA_Foodservice_Customers C ON C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
	LEFT JOIN Distributor_Group_Level L ON L.Distributor_Group_Level_ID = CD.Distributor_Group_Level_ID
	LEFT JOIN (
				SELECT Distinct tc.Distributor_Type_C,CFam.Family_ID FROM BSA_Foodservice_Customers CFam
				LEFT join Distributor_Type_C tc 
				on		tc.Distributor_Type_C_ID = cFam.Distributor_Type_C_ID
				where	tc.Distributor_Type_C LIKE 'STRATEGIC%'
					) AS Strat ON Strat.Family_ID = C.BSA_Foodservice_Customers_ID
	WHERE 	Contract_Main_ID = '#variables.ContractMainID#'
	AND 	CD.Deleted = 0
	AND		CD.Is_Group = 1
</cfquery>
<!---  <cfscript>
		writedump(var=CheckForExistingDistributors,output='c:\dump.log');
</cfscript> --->
<CFSET FORM.FinalItemList = valuelist(CheckForExistingDistributors.BSA_Foodservice_Customers_ID)>
 <cfscript>
        q = CheckForExistingDistributors;
</cfscript>

<h5 class="sectionHeader">AUTHORIZED DISTRIBUTOR(S)</h5>
<div class="sectionContents">
    <button type="button" class="button" onclick="submitSelectedEntries(1);return false;">Search Distributors</button>
    <!--- SAMPLE GRID --->
    <div id="Distributors_Grid" style="width: 505px; height: 70px;" class="ag-theme-balham ml-2 mt-2"></div>
</div>
<br>

<FORM ACTION="/Common_Files/contracts/select_distributors_programs_popup.cfm?CID=<cfoutput>#URL.CID#</cfoutput>" METHOD="post" NAME="DistForm" ID="DistForm" Target="formpopup">
	<CFOUTPUT>
		<input type="hidden" name="FinalItemList" value="#form.FinalItemList#">
		<input type="hidden" name="User_Selection_Group_Or_Dist" value="1">
		<input type="hidden" name="Is_Group"  value="1">
		<input type="hidden" name="target"  value="formpopup">
		<input type="Hidden" name="ExcludeDistributor" value="#request.app_general_functions.listRemoveDupes(form.ExcludeDistributor,',')#">
	</CFOUTPUT>
</FORM>

<FORM ACTION="javascript:saveMyForm();" METHOD="post" NAME="MyForm" ID="MyForm">
	<CFOUTPUT>
		<input type="hidden" name="FinalItemList" id="FinalItemList" value="#form.FinalItemList#">
		<input type="hidden" name="finishedselectingitems" id="finishedselectingitems" value="#form.finishedselectingitems#">
		<input type="hidden" name="editcurrentweight" id="editcurrentweight" value="#form.editcurrentweight#">
		<input type="hidden" name="updateFinalItemListFrompopup" id="updateFinalItemListFrompopup" value="#form.updateFinalItemListFrompopup#">
		<input type="hidden" name="autoApplyWeight" id="autoApplyWeight" value="#form.autoApplyWeight#">
		<input type="hidden" name="LoadSavedDistributors" id="LoadSavedDistributors" value="#form.LoadSavedDistributors#">
		<input type="hidden" name="Is_Group" id="Is_Group" value="1">
		<input type="Hidden" name="ExcludeDistributor" id="ExcludeDistributor" value="#request.app_general_functions.listRemoveDupes(form.ExcludeDistributor,',')#">
	</CFOUTPUT>
</FORM>

		
<SCRIPT>
	// GPO Distributor test data
	var columnDefs_GPO_Distributors = [
	    {headerName: "Name", field: "cust",  width:300, checkboxSelection: true},
	    {headerName: "Type", field: "type",  width:100},
	    {headerName: "Strategic", field: "strat",  width:100},
	];
	var rowData_GPO_Distributors = <cfoutput>#application.util.query.toAgGridJSON(q, 'cust, type, strat,distributor_group_Id')#</cfoutput>;
	var Distributors_GridOptions = {};
	function Build_GPODistributorsGrid() {
	    // Init GPO Distributors grid
	    Distributors_GridOptions = {
	        columnDefs: columnDefs_GPO_Distributors
	        ,rowData: rowData_GPO_Distributors
	        ,rowModelType: "clientSide"     // TODO change to server-side
	        ,cacheBlockSize: 2000
			// ,domLayout: "autoHeight"
	        ,onGridReady: function () {
				setGridHeight(Distributors_GridOptions, "#Distributors_Grid", rowData_GPO_Distributors.length);
	        }
	        ,onRowSelected: function(event) {
	        	//console.log(event);
	        	if(event.node.selected == false){
	        		console.log(event.data);
	        		deleteCustomer(event.data);
	        	}
		       // alert('onCellValueChanged: ' + event.colDef.field + ' = ' + event.newValue);
		    }
	    };
	    ag_grid_default(Distributors_GridOptions);		// set up default features
	    init_ag_grid( Distributors_GridOptions, "#Distributors_Grid", false );   // setup as client side TODO change to server-side
	    Distributors_GridOptions.api.selectAll();
	}

	function submitSelectedEntries(type){
			//popupInCenter('about:blank', "formpopup", 1000, 650);
			//alert('OK11 :: ' +  document.DistForm.FinalItemList.value );
			window.open('about:blank', 'formpopup', 'toolbars=no,scrollbars=yes,resizable=yes,left=0,top=0,width=1250,height=620');
			$('#DistForm').submit();
	}

	function saveMyForm(){
		//popupInCenter('about:blank', "formpopup", 1000, 650);
		show_loader('Saving Customer Data...');
		var frm = $('#MyForm');
		var fields = frm.serializeArray();
		var data = JSON.stringify(fields);
		var grpList = frm.FinalItemList;
		//console.log(data);
		//return false;
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									arrData: data,
									method: "saveCustomerGroup" }
						//,dataType: "json"
						,success: function (data) {
							rowData_GPO_Distributors = data;
							Distributors_GridOptions.api.setRowData(rowData_GPO_Distributors);
							Distributors_GridOptions.api.selectAll();
							setGridHeight(Distributors_GridOptions, "#Distributors_Grid", data.length);

						   // console.log(fields);
						    //console.log($('#FinalItemList').val());
						    //$('#DistForm').FinalItemList.val() = $('#MyForm').FinalItemList.val();
						    $('#DistForm').find('input[name="FinalItemList"]').val($('#FinalItemList').val().toUpperCase());
						    //  $('#FinalItemList').val($('#FinalItemList').val().toUpperCase()); //$('input[name=FinalItemList]').val( );
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

	function getCustomers(){
		//alert(data);
		//return false;
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	ContractMainID: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getCustomers" }
						//,dataType: "json"
						,success: function (data) {
						//	console.log(data);
							rowData_GPO_Distributors = data;
							Distributors_GridOptions.api.selectAll();
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function deleteCustomer(data){
		//popupInCenter('about:blank', "formpopup", 1000, 650)
		var custId = '';
		//alert(data);
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	ContractMainID: <cfoutput>#variables.ContractMainID#</cfoutput>,
									custId: data.distributor_group_id,
									method: "deleteCustomer" }
						//,dataType: "json"
						,success: function (data) {
							rowData_GPO_Distributors = data;
							Distributors_GridOptions.api.setRowData(rowData_GPO_Distributors);
							Distributors_GridOptions.api.selectAll();
							$('#FinalItemList').val('');
							var i = 1;
							$.each(data, function (key, entry) {
				              // console.log(entry);
				              if(i == 1){
				              	$('#DistForm').find('input[name="FinalItemList"]').val(entry.distributor_group_id.toUpperCase());
				              }
				              else{
				              	$('#DistForm').find('input[name="FinalItemList"]').val($('#DistForm').find('input[name="FinalItemList"]').val() + ',' +entry.distributor_group_id.toUpperCase());
				              }
			                 	i++;	    
							 });
							console.log($('#DistForm').find('input[name="FinalItemList"]').val());
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	document.addEventListener("DOMContentLoaded", function () {
        Build_GPODistributorsGrid();
    });
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


