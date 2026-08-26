
<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/OPP/CPA_PriceList_Form.cfm
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

<h5 class="sectionHeader">PRICE LIST TIERS</h5>
                
<div class="sectionContents text-xs">

    <form id="PriceListForm" name="PriceListForm">
        <fieldset id="PriceListSection" class="fieldGroup p-2 w-4/5">
            <legend>Price List Tiers</legend>
            <div class="table-row">
                <label class="opacity-75 pr-3 table-cell text-right">GPO Price List:</label>
                <span class="table-cell">
                	<select name="Gpo_Price_List_Id" id="Gpo_Price_List_Id" class="border rounded" style="width: 350px">
                        <option selected value="0"> -- select a GPO Price List -- </option>
                    </select>
                	<!--- <INPUT MAXLENGTH="200" type="text" name="gpoPriceList" id="gpoPriceList" VALUE="" size="50"> --->
                </span>
            </div>
            <div class="table-row">
                <label class="opacity-75 pr-3 table-cell text-right">Non GPO Price List:</label>
                 <span class="table-cell">
                 	<select name="NonGpo_Price_List_Id" id="NonGpo_Price_List_Id" class="border rounded" style="width: 350px">
                        <option selected value="0"> -- select a Non GPO Price List -- </option>
                    </select>
                 	<!--- <INPUT MAXLENGTH="200" type="text" name="nonGpoPriceList" id="nonGpoPriceList" VALUE="" size="50"> --->
                 </span>
            </div>
           
     	</fieldset>
    </form>
</div>
 <!--- GRID --->
 <!---   <div id="Pricelist_Grid" style="width: 640px;height:235px " class="ag-theme-balham ml-2 mt-2"></div> --->
		
<SCRIPT>

	$("#Gpo_Price_List_Id" ).change(function() {
		if(editable === 0){ //editable Var is set on CPA_Components Form
			alert('Price List update allowed after saving components.');
			$("#Gpo_Price_List_Id").val($(this).data('previous'));
			return;
		}
		saveBasicInfo($( this ).val(),$( this ).attr("name")); // THIS IS IN GPO_Basic_Info_Form.cfm
		$("#Gpo_Price_List_Id").data('previous',$(this).val());
	  //savePriceList($( this ).val(),'GPO');
	});

	$("#NonGpo_Price_List_Id").change(function(e) {
		//console.log($(this).data('previous'));
		if(editable === 0){ //editable Var is set on CPA_Components Form
			alert('Price List update not allowed after saving components.');
			//console.log($(this).data('previous'));
			$("#NonGpo_Price_List_Id").val($(this).data('previous'));
			return;
		}
		saveBasicInfo($( this ).val(),$( this ).attr("name")); // THIS IS IN GPO_Basic_Info_Form.cfm
		$("#NonGpo_Price_List_Id").data('previous',$(this).val());
	    //savePriceList($( this ).val(),'NON');
	});

	function getPriceList(){
		//var frm = $('#OperatorSearchForm');
		//var gpoKey = $("#key_type").val();
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getPriceList" }
						//,dataType: "json"
						,success: function (data) {
			             // console.log('Submission was successful.');
			             // console.log(data);
			             var res = JSON.parse(data);
			                 $.each(res, function (key, entry) {
			                 	if(entry.gpo_key.includes('NON')){
			                 		$("#NonGpo_Price_List_Id").append($('<option></option>').attr('value', entry.price_list_header_id).text(entry.gpo_key + ' :: Tier ' + entry.tier + ' :: ' + entry.price_list_id));
			                 	}
			                 	else{
			                 		$("#Gpo_Price_List_Id").append($('<option></option>').attr('value', entry.price_list_header_id).text(entry.gpo_key + ' :: Tier ' + entry.tier + ' :: ' + entry.price_list_id));
			                 	}
							    
							  })
			                 <cfoutput> $("##Gpo_Price_List_Id").val('#FORM.Gpo_Price_List_Id#');
			                 			$("##NonGpo_Price_List_Id").val('#FORM.NonGpo_Price_List_Id#');
			                			$("##Gpo_Price_List_Id").data('previous','#FORM.Gpo_Price_List_Id#');
			                			$("##NonGpo_Price_List_Id").data('previous','#FORM.NonGpo_Price_List_Id#');
			                 </cfoutput>
			              //  $("#Gpo_Price_List_Id").chosen({search_contains: true,enable_split_word_search: true});
	 					//	$("#NonGpo_Price_List_Id").chosen({search_contains: true,enable_split_word_search: true});
			             // rowData_CPA_PriceList = JSON.parse(data);
			             // PriceList_GridOptions.api.setRowData(rowData_CPA_PriceList);
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

	// function savePriceList(selectedData,type){
	// 	var priceListId
	// 	if(type == 'NON'){
	// 		priceListId  = $("#NonGpo_Price_List_Id").val();
	// 	}
	// 	else{
	// 		priceListId  = $("#Gpo_Price_List_Id").val();
	// 	}	
		
	// 	$.ajax({
	// 					async: true
	// 					,data: { 	priceListId: priceListId,
	// 								type: type,
	// 								contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
	// 								method: "savePriceList" }
	// 					//,dataType: "json"
	// 					,success: function (data) {
	// 		              //Operators_GridOptions.api.setRowData(rowData_GPO_Operators);
	// 		              //getOperators(<cfoutput>#variables.ContractMainID#</cfoutput>);

	// 		            }
	// 		            ,error: function (data) {
	// 		                //console.log('An error occurred.');
	// 		               // console.log(data);
	// 		                alert('An error occurred.  ' + data );
	// 		            }
	// 					,type: "post"
	// 					,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
	// 		});
	// }

	document.addEventListener("DOMContentLoaded", function () {
        //Build_CPAPriceListGrid();
        getPriceList();
    });
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


