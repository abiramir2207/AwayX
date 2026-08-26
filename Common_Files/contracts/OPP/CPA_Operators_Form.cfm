
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

    <form id="OperatorSearchForm" name="OperatorSearchForm">
        <fieldset id="OperatorSearchSection" class="fieldGroup p-2">
            <legend>Operator Search</legend>

            <div class="flex">
                <label class="mr-1">Search by:</label> 
                <!--- <input type="radio" name="search_by" id="search_by_GPO_key" value="1" checked/><label for="search_by_GPO_key">GPO Key</label> --->
                <div>
                    <label class="ml-6 mr-1">Key:</label> 
                    <select name="key_type" id="key_type" class="border rounded">
                        <option disabled selected value> -- select a GPO Key -- </option>
                        <option value="A">GPO A</option>
                        <option value="B">GPO B</option>
                        <option value="C">GPO C</option>
                        <option value="D">GPO D</option>
                    </select>
                </div>
                <input type="radio" class="ml-2" name="search_by" id="search_by_rollup" value="2"/><label for="search_by_rollup">End User Rollup</label>
                <input type="radio" class="ml-2" name="search_by" id="search_by_user" value="3"/><label for="search_by_user">End User #</label>

                <div>
                    <label class="ml-6 mr-1">Name:</label> 
                    <input type="text" name="op_name" class="border rounded mr-2 w-64" value="">
                </div>
                <button type="button" class="button ml-4" onclick="showOperatorSearchWindow();return false;">Search Operators</button>

                <br><br>
            </div>
        </fieldset>
        <INPUT NAME="Operator_List" TYPE="HIDDEN" VALUE="">
        <INPUT NAME="SelectSingleSearchResultOnly" TYPE="HIDDEN" VALUE="0">
    </form>

    <!--- SAMPLE GRID --->
    <div id="Operators_Grid" style="width: 635px;" class="ag-theme-balham ml-2 mt-2"></div>
</div>
		
<SCRIPT>
	// Operator test data
	var columnDefs_GPO_Operators = [
	    {headerName: "GPO KEY", field: "key",  width:130},
	    {headerName: "GPO MEMBER PARENT LEVEL", field: "level",  width:250},
	    {headerName: "GPO MEMBER PARENT NAME", field: "name",  width:250},
	];
	var rowData_GPO_Operators = [];
	var Operators_GridOptions = {};
	<!-------------var rowData_GPO_Distributors = <cfoutput>#application.util.query.toAgGridJSON(q, 'cust, type, strat')#</cfoutput>;  -------->
	function Build_GPOOperatorsGrid() {
	    // Init Operators grid
	    Operators_GridOptions = {
	        columnDefs: columnDefs_GPO_Operators
	        ,rowData: rowData_GPO_Operators
	        ,rowModelType: "clientSide"     // TODO change to server-side
	        ,cacheBlockSize: 2000
	        ,onGridReady: function () {
	            // this.api.sizeColumnsToFit();
	        }
	    };
	    ag_grid_default(Operators_GridOptions);		// set up default features
	    init_ag_grid( Operators_GridOptions, "#Operators_Grid", false );   // setup as client side TODO change to server-side
	}

	$( "#key_type" ).change(function() {
	  getOperators();
	});
	function showOperatorSearchWindow() 
   {
		NewWindow("/billbacks/search_screens/PM_select_operators.cfm?FormName=OperatorSearchForm", "operatorwindow", 800, 600, "yes", "yes");
		return false;
	}

	function insertNew(){
		var frm = $('#OperatorSearchForm');
		data = frm.serialize();
		//alert('OK :: ' + data );
		$.ajax({
						async: true
						,data: data
						//,dataType: "json"
						,success: function (data) {
			                console.log('Submission was successful.');
			                console.log(data);
			                var pos = data.indexOf("<");
			                newCid = data.slice(0,pos);
			                document.location.href = '/Common_Files/contracts/xxxx.cfm?CID=' + newCid + '&RO=1&RID=<CFOUTPUT>#createuuid()#</CFOUTPUT>';
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/Common_Files/contracts/xxxxx.cfm"
			});
	}

	function getOperators(){
		var frm = $('#OperatorSearchForm');
		var gpoKey = $("#key_type").val();
		$.ajax({
						async: true
						,data: { 	gpoKey: 	gpoKey,
									contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getOperatorList" }
						//,dataType: "json"
						,success: function (data) {
			               // console.log('Submission was successful.');
			              //  console.log(data);
			              rowData_GPO_Operators = JSON.parse(data);
			              Operators_GridOptions.api.setRowData(rowData_GPO_Operators);
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

	document.addEventListener("DOMContentLoaded", function () {
        Build_GPOOperatorsGrid();
    });
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


