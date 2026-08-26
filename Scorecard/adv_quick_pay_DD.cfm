	<cfset jQueryUI.widgets = "datepicker">
	<cfset datatables.version = "1.10.15">
	<cfset datatables.extensions = "fixedheader">
	<cfinclude template="/common_files/jQuery.cfm">

 	<cf_include files="/script/javascript/string_functions.js, /script/javascript/numeral.min.js, /common_files/noty.cfm, /Common_Files/dhx_message.cfm">
	<cf_include files=" /script/javascript/default.js, /styles/css-loader.css, /common_files/datatable.css">

	<cfinclude template="/Common_Files/dataTables2.cfm">

	<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />
	<cfset MCObject = createObject("Component","components.Match_Central.MatchCentral").init()>

	<cfset qGetDeduction = DeductionManager.getDeduction(url.Deduction_ID) />
	<cfset variables.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<cfquery name="AutoCloseReason" datasource="#application.datasource#">
		SELECT DD_Reason_Code_ID
		FROM DD_Auto_Close
	</cfquery>

	<cfquery name="ReasonCodes" datasource="#application.datasource#">
		SELECT *
		FROM DD_Reason_Code
		WHERE Deleted = 0
		AND Display_In IN (1,3)
		<CFIF AutoCloseReason.RecordCount GT 0 AND AutoCloseReason.DD_Reason_Code_ID NEQ "">
			AND DD_Reason_Code_ID != #AutoCloseReason.DD_Reason_Code_ID#
		</CFIF>
		<CFIF appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>
			AND Closing_Method = 3
		</CFIF>
		ORDER BY DD_Reason_Code_Description
	</cfquery>

	<cfquery name="GetDDProfileSettings" datasource="#application.datasource#">
		SELECT DD_Match_Central_Write_Off_Amount
		FROM Deductions_Profiles_Settings
		WHERE profiles_id = #request.AccessStructure.Profiles_ID#
		AND Deleted = 0
	</cfquery>

	<cfquery NAME="Get_DD_Closing_Method" datasource="#application.datasource#">
		SELECT Vendor_Required
		FROM  	Billback_Closing_Methods
		WHERE	iBillback_Closing_Method_ID = 2
		AND Hide = 0
		ORDER BY Display_Sequence
	</cfquery>

	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
	.flex-container {
		display: flex;
		flex-flow: row wrap;
		justify-content: left;
		padding: 0;
		margin: 0;
		list-style: none;
	}
	.flex-item {
		width: 160px;
		height: auto;
		padding : 2px;
		margin-left: 5px;
		text-align: left;
	}
	.input{ width:150px; }
	.dollar { text-align: right; }
	.dataTables_wrapper .dataTables_filter { float: left; margin-top:4px;}
	.BBHeader {
		background-color:#ffce84;
		border:1px dotted #CCC;
		padding:4px;
		font-family:"Century Gothic",Verdana,Arial;
		font-size:1.05em;
		font-weight:bold;
		letter-spacing:0.2px;
		text-align:left;
		width:100%;
   	}
	 #SelectHeader{
		background-color:#ffce84;
		border:1px dotted #CCC;
		padding:4px;
		font-family:"Century Gothic",Verdana,Arial;
		font-size:12px;
		font-weight:bold;
		letter-spacing:0.2px;
		text-align:left;"
	 }
	 .CMID{display:none;}
	 <cfif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  NEQ 1 AND variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  NEQ 3>
	 .ABalance{display:none;}
	 </cfif>
	 <cfif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  NEQ 4>
	 .TSpent{display:none;}
	 </cfif>
	 <cfif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  NEQ 2 AND variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  NEQ 3>
	 .BBalance{display:none;}
	 </cfif>
	 .dataTables_wrapper .dataTables_paginate {
		  float: right;
		  text-align: right;
		  padding-top: 0.755em;
		  width: 49%;
	  }
	  .reasonCode{
		  display:none;
	   }
	</style>

<cfif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 1>
	<cfset FilterText = 'Accrual'>
<cfelseif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 2>
	<cfset FilterText = 'Budget'>
<cfelseif variables.appSettings.get_Setting('Advance_Quick_Pay_Control')  EQ 3>
	<cfset FilterText = 'Accrual & Budget'>
<cfelse>
	<cfset FilterText = 'Program Trade Estimate'>
</cfif>

	<cfset objSettingsService = createobject("component", "mvc.models.SettingsService") />
	<cfset stBBLabels = objSettingsService.getBBLabels()>

	<cfset QuickPay = createobject("component", "components.Billback.Quick_Pay") />
	<cfquery name="GetUserPositionID" datasource="#application.datasource#">
		SELECT UPH.User_Positions_ID
		From _users U
		INNER JOIN User_Position_Holders UPH
		ON UPH.User_ID = U.User_ID
		Where U.User_ID = '#request.AccessStructure.User_ID#'
		AND UPH.User_Position_Type = 'P'
	</cfquery>

	<cfset PageTitle = #qGetDeduction.DD_DedID#&' '&'  Advance Quick Pay'&'  '&#lscurrencyformat(qGetDeduction.DD_Amount)#>
	<cfinclude template="/settings/settings_title.cfm">
	<form name="CreateBBform" method="post" id="CreateBBform" action="adv_quick_pay_DD.cfm">
		<!--- SELECTED PROGRAMS --->
		<cfset bDisplayKeepItOpen = 1 />
		<cfset bDisplayWriteOff = 1 />
		<cfif application.appSettingsget.get_Setting('DD_Match_Central_Keep_It_Open') neq '1'>
			<cfset bDisplayKeepItOpen = 0 />
		</cfif>
		<cfif application.appSettingsget.get_Setting('DD_Match_Central_Write_Off') neq '1'>
			<cfset bDisplayWriteOff = 0 />
		</cfif>
		<table class="SelectedPrg" style="display:none;width:100%">
			<thead id="SelectHeader">
				<th width="25">&nbsp;</th>
				<th width="100">Program #</th>
				<th width="100">Title</th>
				<th width="75">Delivery Period Start Date</th>
				<th width="75">Delivery Period End Date</th>
				<th width="75">Billback Date</th>
				<th width="125">Customer</th>
				<th width="125">Bill To</th>
				<th width="50">Allocation $ <img src="/images/no_small.gif" title="Clear Allocation $ box" style="float:right" onclick="ClearAllocation()"></th>
				<th width="150">Payee</th>
				<th width="225">Component</th>
			<!---117446 :: Billback - sales tax code  START--->
			<cfif appSettings.getBillbacksSalesTax() EQ 2>
				<th width="225">Tax Type</th>
			</cfif>
			<!---117446 :: Billback - sales tax code  END--->
			</thead>
			<tbody id="groupLevelFooter"></tbody>
			<cfif bDisplayWriteOff OR bDisplayKeepItOpen>
			<tfoot>
				<tr>
					<td colspan="8">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2" align="left">
						<b>Remaining Balance </b>
						<input type="text" name="Remaining_Balance" id="Remaining_Balance" onKeyUp=javascript:ClenseText(this) value= "0.00">
					</td>
					<td align="left">
						<b>Split Actions </b><br>
						<select name="Split_Action" style="width: 250px" id="Split_Action">
							<option value="0">Select a Split Action</option>
							<cfif bDisplayKeepItOpen>
								<option value="1">Keep Open</option>
							</cfif>
							<cfif bDisplayWriteOff>
								<option value="2"><cfoutput>#MCObject.stDeductionLabels['Write Off']#</cfoutput></option>
							</cfif>
						</select>
					</td>
					<td colspan="2" align="left" class="reasonCode">
						<cfif bDisplayWriteOff>
							<b><cfoutput>#MCObject.stDeductionLabels['Write Off']#</cfoutput> Closure <cfoutput>#MCObject.stDeductionLabels["Reason Code"]#</cfoutput></b><br>
								<select name="Reason_Code" style="width: 250px" id="Reason_Code">
									<option value="0">Select a Reason Code</option>
									<cfoutput query="ReasonCodes">
									<option value="#DD_Reason_Code_ID#">#DD_Reason_Code_Description#</option>
									</cfoutput>
								</select>
							<cfelse>
								<input type="hidden" name="Reason_Code" value="0">
						</cfif>
					</td>
					<td colspan="2" align="left" class="reasonCode">
						<cfif bDisplayWriteOff>
							<b><cfoutput>#MCObject.stDeductionLabels['Write Off']#</cfoutput> Reason</b><br>
								<textarea name="WriteOffReason" id="WriteOffReason" rows="2" cols="40" onkeypress="javaScript: return textareaChecklength('250', this);" onpaste="javaScript: return textareaChecklength('250', this);"></textarea>
							<cfelse>
								<input type="hidden" name="WriteOffReason" value="">
						</cfif>
					</td>
					<td colspan="2" align="left" class="vendorInfo"> 
						<cfif Get_DD_Closing_Method.RecordCount AND Get_DD_Closing_Method.Vendor_Required>
							<b>Vendor</b> 	<a id="vendorSearch"><cfoutput>#application.util.string.actionLinkFormat2('search')#</cfoutput></a>
							<input class="input date-info" type="text" name="Vendor" value="" size="5" id="Vendor" style="width:250px;margin-top:5px;" readonly>
							<input class="input date-info" type="hidden" name="Vendor_ID" value="" size="5" id="Vendor_ID">
							<input class="input date-info" type="hidden" name="Vendor_Master_ID" value="" size="5" id="Vendor_Master_ID">
						<cfelse>
							<input class="input date-info" type="hidden" name="Vendor_ID" value="" size="5" id="Vendor_ID">
							<input class="input date-info" type="hidden" name="Vendor_Master_ID" value="00000000-0000-0000-0000-000000000000" size="5" id="Vendor_Master_ID">						
						</cfif> 
					</td>
				</tr>
				<tr>
					<td colspan="8">&nbsp;</td>
				</tr>
				</tfoot>
			</cfif>
		</table>
		<!--- ALL PROGRAMS --->
<table class="datagrid" style="table-layout:fixed;display:none;" id="allPrograms">
	<thead>
		<th width="25"><input type= "checkbox" onclick=javascript:HeaderClick(this.checked)  id = "PRGcheckall"  name = "PRGcheckall" ></th>
		<th width="25">CMID</th>
		<th width="100">Program #</th>
		<th width="100">Accrual Balance</th>
		<th width="100">Est Trade Balance</th>
		<th width="100">Budget Balance</th>
		<th width="200">Title</th>
		<th width="200">Customer</th>
		<th width="200">Bill To</th>
	</thead>
	<tbody></tbody>
</table>

	<a id="createBB" style="display:none;" onclick="validateInfo();"><cfoutput>#application.util.string.actionLinkFormat2('Create #stBBLabels.Payable#')#</cfoutput></a>
	<a id="dummyCreateBB" style="display:none; color:grey"><cfoutput>#application.util.string.actionLinkFormat2('Create #stBBLabels.Payable#')#</cfoutput></a>
	<a id="reset" style="display:none;"><cfoutput>#application.util.string.actionLinkFormat2('Reset')#</cfoutput></a>

	<input type="hidden" name="Prg_selected" value="" id="Prg_selected" >
	<input type="hidden" name="Prg_Num_selected" value="" id="Prg_Num_selected" >
	<input type="hidden" name="Comp_per_Prg" value="" id="Comp_per_Prg" >
	<input type="hidden" name="remove_Prg" value="" id="remove_Prg" >
	<input type="hidden" name="RemainingAccrual" value="" id="RemainingAccrual" >
	<input type="hidden" name="budgetBalance" value="" id="budgetBalance" >
	<input type="hidden" name="ProgramTradeEstimate" value="" id="ProgramTradeEstimate" >
	<input type="hidden" name="Total_Amount" value="<cfoutput>#qGetDeduction.DD_Amount#</cfoutput>" id="Total_Amount" >
	<input type="hidden" name="Called_From" value="Deductions" >
	<input type="hidden" name="User_Position_ID" value="<cfoutput>#GetUserPositionID.User_Positions_ID#</cfoutput>" >
	<input type="hidden" name="Deduction_ID" value="<cfoutput>#url.Deduction_ID#</cfoutput>">
	<input type="hidden" name="DD_Ded_ID" value="<cfoutput>#qGetDeduction.DD_DedID#</cfoutput>" >
	<input type="hidden" name="DD_Amount" value="<cfoutput>#qGetDeduction.DD_Amount#</cfoutput>" >
	<input type="hidden" name="Reference_Number" value="<cfoutput>#qGetDeduction.DD_Reference#</cfoutput>" >
	<input type="hidden" name="Unique_ID" value="" id="Unique_ID" >
</form>

<cfsavecontent variable="importLink">
	<!--- IMPORT & SEARCH LINKS --->
	<span style="float:right;clear:both;" id="links" >
		<cfoutput>
		<input type="checkbox" name="ExpiredPrograms" value="1" id="ExpiredPrograms" checked onclick="redrawTable()"><b>Hide Expired Programs</b> &nbsp;&nbsp;&nbsp;
		<input type="checkbox" name="ZeroBalance" value="1" id="ZeroBalance" checked onclick="redrawTable()"><b>Hide Programs Without Available Funds</b> &nbsp;&nbsp;&nbsp;
		<input type="checkbox" name="filterB2S2" value="1" id="filterB2S2" checked onclick="showlinks(this.checked)"><b>Filter Bill To / Ship to</b> &nbsp;&nbsp;&nbsp;
		<a id="filterBilltoShipto" onclick ="dis_program()" style="cursor:pointer;display:none;">
			<b><font color="FF0000">[ </font> Search Programs <font color="FF0000">]</font></b>
		</a>
		<a id="importPRG" onclick ="checkProfieSettings()" style="cursor:pointer">
			<b><font color="FF0000">[ </font> Import Programs <font color="FF0000">]</font></b>
		</a>
		</cfoutput>
	</span>
</cfsavecontent>

<script>

/*
	BELOW FUNCTION CHECKS DEDUCTION LOCK STATUS.
	IF DEDUCTION IS NOT LOCKED WE WILL LOCK IT FOR QUICK PAY PROCESS.
	IF DEDUCTION IS LOCKED WE WILL ALERT USER AND CLOSE THE WINDOW.
*/
$( document ).ready(function() {
	//noty({ layout:"center", type:"information",text: "Locking Deduction." }).show();
	lockDD(1);
	window.opener.location.reload();
});
/*
BELOW FUCTION WILL GET ALL PROGRAMS WHICH HAS SAME SHIP-TO OR BILL-TO ON DEDUCTION
*/
function getProgram(exp, aBal){ 
	oTable = $('#allPrograms').DataTable( {
		  "bServerSide": true
		, "filter": true
		, "autoWidth": false
		, "paging": true
		, "pagingType": "numbers"
		, "bProcessing": true
		, "sAjaxSource": "ajax/adv_quick_pay.cfm?type=prg&Deduction_ID=<cfoutput>#url.Deduction_ID#</cfoutput>&ExpiredPrograms="+exp+"&ZeroBalance="+aBal
		, "rowCallback": function( row, data, displayNum ) {
						var CMID = this.fnGetData(displayNum,1);
						var Prg_selected = $('#Prg_selected').val();
						if( Prg_selected.indexOf(CMID) == 0){
							$("#"+CMID).prop( "checked" );
						}
        			}
		, "dom": "<'importPRG'>ftipr"
		, "language": {
			            "lengthMenu": "Display _MENU_ records per page",
			            "zeroRecords": "No programs matchs the criteria.",
			            "info": "<b>Showing _START_ to _END_ of _TOTAL_ records</b>",
			            "infoEmpty": "No programs matchs the criteria.",
			            "infoFiltered": ""
        			}
		, "scrollY": Math.floor(jQuery(window).height()) - 185
		, "pageLength": 100
		, "aaSorting": [[ 1, "asc" ]]
		, "columns": [
		                  {"orderable":false}
				, {"orderable":false , "className":"CMID"}
				, {"orderable":true}
				, {"orderable":true, "className":"ABalance"}
				, {"orderable":true, "className":"TSpent"}
				, {"orderable":true, "className":"BBalance"}
				, {"orderable":true}
				, {"orderable":true}
				, {"orderable":true}
		               ]
		} )
		$('div.importPRG').html(<cfoutput>'#application.util.string.compress(importLink)#'</cfoutput>);
		$('.dataTables_filter input').attr('title', 'Search against Program #, Title, Customer, Bill To.');

		oTable.on( 'draw', function () {
				var Prg_selected = $('#Prg_selected').val();
				$("input[name=Contract_Main_ID]").each(function(){
				if($("#DDcheckall").prop("checked")){
					this.checked=Prg_selected.includes(this.id);
				}
			});
		})
}
$(window).resize( function() {
	oTable.columns.adjust();
} );
function redrawTable(){
	var exp = $('#ExpiredPrograms').prop( "checked" );
	var aBal = $('#ZeroBalance').prop( "checked" );
		oTable.destroy();
		getProgram(exp, aBal);
		$('#ExpiredPrograms').prop( "checked", exp );
		$('#ZeroBalance').prop( "checked", aBal );
}
/*
BELOW FUNCTION TRIGGERS WHEN USER CLICK CHECK BOX.
THIS WILL ADD PROGRAM TO HIDDEN TABLE.
CANNOT IMPORT MORE THAN 10 PROGRAMS
*/
function addPrg(e, CMid, CUSid, BillToID, Customer, BillTo, ContractNumber, Title, Tax){

	var Prg_selected = $('#Prg_selected').val();
	var Prg_Num_selected = $('#Prg_Num_selected').val();
	$.noty.closeAll();

	if(e.length){
		var chk = e.checked;
	}else{
		var chk = true;
	}

	if( ! chk){
		removePRG(CMid, ContractNumber, '0', '0', 1);
		}else {

				var Prg_Selected_Len = Prg_selected.split(',');
					if(Prg_Selected_Len.length >= 50){
						noty( {  text: "Cannot Import More Than 50 Programs"
								,killer: true
                ,type: 'error'
                ,buttons: [  { text:'Close Message', addClass:'btn-primary', onClick:function($noty) {  $noty.close(); } } ]
                ,layout: 'bottom' });
								$('#'+CMid).prop('checked', false);
							return;
					}else{
						if(Prg_selected.length){
							Prg_selected = Prg_selected.concat(','+CMid);
							$('#Prg_selected').val(Prg_selected);
						}else{
							$('#Prg_selected').val(CMid);
						}
						//CONTRACT NUMBER
						if(Prg_Num_selected.length){
							Prg_Num_selected = Prg_Num_selected.concat(','+ContractNumber);
							$('#Prg_Num_selected').val(Prg_Num_selected);
						}else{
							$('#Prg_Num_selected').val(ContractNumber);
						}
					}
			var Compid = CMid+'_CompID';
			var Payeeid = CMid+'_PayeeID';
			var TaxTypeid = CMid+'_TaxType';

			populateDropdowns(CMid, ContractNumber, Title, Customer, BillTo, Compid, Payeeid, TaxTypeid, Tax);
		}
}
function CompInfo(CMID){
	$('#'+CMID+"_CompType").val($( "#"+CMID+"_CompID option:selected" ).attr('data-id'));
	$('#'+CMID+"_CompName").val($( "#"+CMID+"_CompID option:selected" ).attr('data-name'));
}
//BELOW FUNCTION WILL VALIDATE ALLOCATION TEXTBOX ONLY TO ENTER NUMERIC AND .

function ClenseText(ths){
	var val = $('#'+ths.id).val();
    if(isNaN(val)){
         val = val.replace(/[^0-9\.]/g,'');
         if(val.split('.').length>2)
             val =val.replace(/\.+$/,"");
    }
		$('#'+ths.id).val(val);
}
function decimalRestriction(ths){
	var val = $('#'+ths.id).val();
	if(isNaN(val)){
		$('#'+ths.id).val('0.00')
	}else{
		val = parseFloat(val).toFixed(2);
		$('#'+ths.id).val(val);
	}
	recal()
}
	//Write OFF Amount Calculation
function recal(){
	var TotalAllocation = 0;
	var PRGArray = $('#Prg_selected').val().split(',');
	var PRGCompArray = $('#Comp_per_Prg').val().split(',');
	for(i=0; i<PRGCompArray.length; i++){
		var CMid = PRGArray[i];
		var CompLen = PRGCompArray[i];
		for(j=0; j<CompLen; j++){
			if (typeof $('#'+CMid+'_Allocation_'+j).val() !== 'undefined'){
				TotalAllocation = (parseFloat(TotalAllocation)+parseFloat($('#'+CMid+'_Allocation_'+j).val())).toFixed(2);
			}
		}
	}
	var DDAmt = parseFloat( $('#Total_Amount').val() );
	var ReAmt = (DDAmt - TotalAllocation).toFixed(2);
	$('#Remaining_Balance').val(ReAmt);
}
/*
BELOW FUNCTION REMOVES PROGRAM FROM SELECTED LIST
*/
//Contract Main ID, Contract Number, IMG Unique ID, No Of Components On Program, Current Comp Count, Type
function removePRG(CMid, ContractNumber, CompID, CompLength, Type){
	var Prg_selected = $('#Prg_selected').val();
	var Prg_Num_selected = $('#Prg_Num_selected').val();
	var Prg_Comp_Len = $('#Comp_per_Prg').val();
  var pos = Prg_selected.split(',').indexOf(CMid);

	if(Type){
		$( "tr[id*="+CMid+"]" ).remove();
		var remaining = 0;
		$('#'+CMid).prop('checked', false);
	}else{
		$( '#'+CompID).remove();
		var remaining =  $("img[id="+CMid+"]").length;
		recal();
	}
	if(remaining == 0){
			//CONTRACT MAIN ID REMOVE LOGIC
			Prg_selected = Prg_selected.replace(CMid,'');
			var PRGArray = Prg_selected.split(',');

			PRGArray = PRGArray.filter(item => item);
			Prg_selected= PRGArray.toString();
			$('#Prg_selected').val(Prg_selected);

			//CONTRACT NUMBER REMOVE LOGIC
			Prg_Num_selected = Prg_Num_selected.replace(ContractNumber,'');
			var PRGNumArray = Prg_Num_selected.split(',');

			PRGNumArray = PRGNumArray.filter(item => item);
			Prg_Num_selected= PRGNumArray.toString();
			$('#Prg_Num_selected').val(Prg_Num_selected);

			//CONTRACT COMPONENT LENGHT REMOVE LOGIC
			var PRGCompArray = Prg_Comp_Len.split(',');
						PRGCompArray.splice(pos, 1);
			Prg_Comp_Len= PRGCompArray.toString();
			$('#Comp_per_Prg').val(Prg_Comp_Len);
		}
}
function HeaderClick(chk){
	var PRG_selected_ID = [];
		$("input[name=Contract_Main_ID]").each(function(){
			$( "#"+this.id ).prop( "checked", true );
					PRG_selected_ID.push(this.id);

					$( "#"+this.id ).trigger( "click" );
					$( "#"+this.id  ).attr("checked","checked");
		})
}

/*
BELOW FUNCTION WILL POPULATE DISTRIBUTORS DROP DOWN & COMPONENTS DROP DOWN.
*/
function populateDropdowns(CMid, ContractNumber, Title, Customer, BillTo, Compid, Payeeid, TaxTypeid, Tax){
// getPrgComponents
var CompCount = 0;
$.ajax( {
				type: "POST",
				url: "/components/Billback/Quick_Pay.cfc?method=getPrgComponents&ReturnFormat=JSON",
				data: ({	Contract_Main_ID: CMid	}),
				dataType: 'JSON',
				success: function(response){
					//console.log(response)
					if(response.DATA.length){
						CompCount = response.DATA.length;
						for (var i = 0; i < response.DATA.length; i++) {
						var tdID = CMid+'_'+response.DATA[i][0]+'_'+response.DATA[i][2];

						var tr=$('<tr id='+tdID+'></tr>');
						$('<td class=scissor><img src=/images/scissor.gif onclick=javascript:removePRG('+CMid+',\''+ContractNumber+'\',\''+tdID+ '\','+response.DATA.length+','+0+') id='+CMid+' class='+CMid+' data-num='+ContractNumber+'></td>').appendTo(tr);
						$('<td><a onclick=openPRG("'+CMid+'") style= cursor:pointer>'+ ContractNumber +'</a></td>').appendTo(tr);
						$('<td>'+ Title +'</td>').appendTo(tr);
						$('<td><input type=textbox name='+CMid+'_BB_Start_Date_'+i+' id='+CMid+'_BB_Start_Date_'+i+' width=70px value= ></td></td>').appendTo(tr);
						$('<td><input type=textbox name='+CMid+'_BB_End_Date_'+i+' id='+CMid+'_BB_End_Date_'+i+' width=70px value= ></td></td>').appendTo(tr);
						$('<td><input type=textbox name='+CMid+'_Billback_Date_'+i+' id='+CMid+'_Billback_Date_'+i+' width=70px value= ></td></td>').appendTo(tr);
						$('<td>'+ Customer +'</td>').appendTo(tr);
						$('<td>'+ BillTo +'</td>').appendTo(tr);
						$('<td><input type=textbox class= Allocation name='+CMid+'_Allocation_'+i+' id='+CMid+'_Allocation_'+i+' onKeyUp=javascript:ClenseText(this) onfocusout=decimalRestriction(this) width=50px value= ></td>').appendTo(tr);
						$('<td><input type=hidden name='+CMid+'_PayeeNumber_'+i+' id='+CMid+'_PayeeNumber_'+i+' value=><input type=hidden name='+CMid+'_PayeeName_'+i+' id='+CMid+'_PayeeName_'+i+' value=><select style=width:100% name='+CMid+'_PayeeID_'+i+' id='+CMid+'_PayeeID_'+i+'><option value=0>Select a Payee</option></select></td>').appendTo(tr);
						$('<td id='+CMid+'_Comp_'+i+'><input type=hidden name='+CMid+'_CompName_'+i+'  id='+CMid+'_CompName_'+i+' value='+ response.DATA[i][3] +'><input type=hidden name='+CMid+'_Discount_Type_'+i+'  id='+CMid+'_CompType_'+i+' value='+ response.DATA[i][2] + '><input type=hidden name='+CMid+'_CompID_'+i+'  id='+CMid+'_CompID_'+i+' value='+ response.DATA[i][0] +'>'+ response.DATA[i][1] +'</td>').appendTo(tr);
					//117446 :: Billback - sales tax code
					if(<cfoutput>#appSettings.getBillbacksSalesTax()#</cfoutput> == '2' && Tax == '1'){ 
						$('<td><select style=width:100% name='+CMid+'_TaxType_'+i+' id='+CMid+'_TaxType_'+i+'><option value=0>Select a Tax Type</option></select><input type=hidden name='+CMid+'_TaxON_'+i+' id='+CMid+'_TaxON_'+i+' value='+Tax+'></td>').appendTo(tr);
					}else{
						$('<td>N/A<input type=hidden name='+CMid+'_TaxType_'+i+' id='+CMid+'_TaxType_'+i+' value=0><input type=hidden name='+CMid+'_TaxON_'+i+' id='+CMid+'_TaxON_'+i+' value='+Tax+'></td>').appendTo(tr);
					}
						tr.appendTo('#groupLevelFooter');
						populateTaxDropDowns(TaxTypeid, Tax, i);
						}
						DatePicker(CMid, response.DATA.length);
						var PRG_selected_ID= 	$('#Comp_per_Prg').val();
						if(PRG_selected_ID.length){
							PRG_selected_ID = PRG_selected_ID.concat(','+response.DATA.length);
						}else{
							PRG_selected_ID = PRG_selected_ID.concat(response.DATA.length);
						}
						$('#Comp_per_Prg').val(PRG_selected_ID);
				}
				},
				error: function(xhr, textStatus, errorThrown){ noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
			});
	//getPrgDistributors
	$.ajax( {
			type: "POST",
			url: "/components/Billback/Quick_Pay.cfc?method=getPrgDistributors&ReturnFormat=JSON",
			data: ({ ContractNumber: ContractNumber	}),
			dataType: 'JSON',
			success: function(response){
				if(response.DATA.length){
					for (var j = 0; j < $('.SelectedPrg >tbody >tr').length; j++) {
						for (var i = 0; i < response.DATA.length; i++) {
							if(response.DATA[i][3] > '0'){
							$('#'+Payeeid+'_'+j).append("<option value='" + response.DATA[i][3] + "' data-id='D' >" + response.DATA[i][2] + "</option>");
							}else{
							$('#'+Payeeid+'_'+j).append("<option  value='" + response.DATA[i][3] + "' data-id='D' >" + response.DATA[i][2] + "</option>");
							}
						}
					}
				}
			},
			error: function(xhr, textStatus, errorThrown){ noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
		});
		
}
function populateTaxDropDowns(TaxTypeid, Tax, j){
	//117446 :: Billback - sales tax code START
if(<cfoutput>#appSettings.getBillbacksSalesTax()#</cfoutput> == '2' && Tax == '1'){
		//getTaxTypes
		$.ajax( {
				type: "POST",
				url: "/components/Billback/Quick_Pay.cfc?method=getTaxTypes&ReturnFormat=JSON",
				data: ({	Deduction_ID: <cfoutput>'#url.Deduction_ID#'</cfoutput>	}),
				dataType: 'JSON',
				success: function(response){  
					if(response.DATA.length){
							for (var i = 0; i < response.DATA.length; i++) {
								if(response.DATA[i][2] == response.DATA[i][3]){
									$('#'+TaxTypeid+'_'+j).append("<option selected value='" + response.DATA[i][0] + "' data-id='D' >" + response.DATA[i][1] + "</option>");
								}else{
									$('#'+TaxTypeid+'_'+j).append("<option  value='" + response.DATA[i][0] + "' data-id='D' >" + response.DATA[i][1] + "</option>");
								}
							}
					}
		    },
				error: function(xhr, textStatus, errorThrown){ noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
			});
	}
//117446 :: Billback - sales tax code END
}
// RESET THE PAGE
$("#reset").click(function () {
	$.ajax( {
			type: "POST",
			url: "/components/Billback/Quick_Pay.cfc?method=DeleteRecords&ReturnFormat=JSON",
			data: ({	Unique_ID: $('#Unique_ID').val()	}),
			dataType: 'JSON',
			success: function(response){
			},
			error: function(xhr, textStatus, errorThrown){
				//noty({ layout:"center", type:"error", text: "Process Failed" }).show();
			}
	       });
	location.reload();
})
/*
CHECK PROFILE SETTINGS WHEN IMPORTING PROGRAMS.
IF ALL GOOD WE IMPORT THE PROGRAM AND GET DEFUALT PAYEE AND COMPONENT.
*/
function checkProfieSettings(){
	if($('#Prg_selected').val().length == 0){
		noty({ layout:"center", type:"error", timeout: 250, killer: true, text: "Please Select A Program." }).show();
		return;
	}else{
		noty({ layout:"center", type:"info", text:  "Importing Programs....."}).show();
	$.ajax( {
		type: "POST",
		url: "/components/Billback/Quick_Pay.cfc?method=getProgramAmountInfo&ReturnFormat=JSON",
		data: ({
			 Contract_Main_ID: $('#Prg_selected').val()
			,Contract_Number: $('#Prg_Num_selected').val()
		}),
		dataType: 'JSON',
		success: function(response){
		//	console.log(response)
			$('#RemainingAccrual').val(response.ACCRUALAMT);
			$('#budgetBalance').val(response.BUDGETBALANCE);
			$('#ProgramTradeEstimate').val(response.PRGTRADESPEND);
			validate();
		},
		error: function(xhr, textStatus, errorThrown){ noty({ layout:"center", type:"error", text: "Importing Program Process Failed" }).show(); }
		});
}
function validate(){
	var RemainingAccrual = $('#RemainingAccrual').val().split(',');
	var budgetBalance = $('#budgetBalance').val().split(',');
	var ProgramTradeEstimate = $('#ProgramTradeEstimate').val().split(',');
	var ProfileAQPMax= '<cfoutput>#url.Overspend#</cfoutput>';
	var AQPControl = <cfoutput>#variables.appSettings.get_Setting('Advance_Quick_Pay_Control') #</cfoutput>;
	var DDAmount = <cfoutput>#qGetDeduction.DD_Amount#</cfoutput>
	var Contract_Main_ID = $('#Prg_selected').val().split(',');
	var ContractNumber = $('#Prg_Num_selected').val().split(',');

	var errors = [];
	/*
		WHEN variables.appSettings.get_Setting('Advance_Quick_Pay_Control') EQUAL TO "ACCURAL".
		THEN CHECK IF REMAINING ACCURAL AMOUNT ON PROGRAM IS GREATER THAN SUM OF SELECTED DEDUCTION AMOUNT.
		IF NOT ALERT USER
	*/
	var Program = [];

	for(i=0; i<=Contract_Main_ID.length; i++){
			// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "ACCRUAL"
			var ContractMainID = Contract_Main_ID[i];

			if(AQPControl == 1 || AQPControl ==3){
				overPrgAccrual = ((DDAmount / Contract_Main_ID.length) - RemainingAccrual[i]);
				if( ProfileAQPMax != '*' && overPrgAccrual > ProfileAQPMax ){
					if( ! Program.includes(ContractNumber[i])){
						Program.push(ContractNumber[i]);
					}
					var Balancetype = 'Accrual';
					$('#remove_Prg').val(ContractMainID);
					removePRG(ContractMainID, ContractNumber[i], '0', '0', 1);
					$('#'+ContractMainID).prop('checked', false);
				}
			}
			// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "BUDGET"
			if(AQPControl == 2 || AQPControl ==3){
				overPrgBudget = ((DDAmount / Contract_Main_ID.length) - budgetBalance[i]);
				if( ProfileAQPMax != '*' &&overPrgBudget > ProfileAQPMax){
					if( ! Program.includes(ContractNumber[i])){
						Program.push(ContractNumber[i]);
					}
					var Balancetype = 'Budget';
					$('#remove_Prg').val(ContractMainID);
					removePRG(ContractMainID, ContractNumber[i], '0', '0', 1);
					$('#'+ContractMainID).prop('checked', false);
				}
			}

			// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "PROGRAM TRADE ESTIMATE"
			if(AQPControl ==4){
					overPrgTrade = ((DDAmount / Contract_Main_ID.length) - ProgramTradeEstimate[i]);
					if( ProfileAQPMax != '*' && overPrgTrade > ProfileAQPMax){
						if( ! Program.includes(ContractNumber[i])){
						Program.push(ContractNumber[i]);
					}
						var Balancetype = 'Trade estimate';
						$('#remove_Prg').val(ContractMainID);
						removePRG(ContractMainID, ContractNumber[i], '0', '0', 1);
						$('#'+ContractMainID).prop('checked', false);
				}
			}
	}

		if(Program.length){
			Program = Program.toString();
			errors.push(Program +" will not import. Deduction amount is beyond the program's remaining "+Balancetype+" balance.\n");
		}

		var Contract_Main_ID = $('#Prg_selected').val().split(',');
		var TotalAllocation = <cfoutput>#qGetDeduction.DD_Amount#</cfoutput>;
		var allocation = ( TotalAllocation / Contract_Main_ID.length).toFixed(2);
		var TotAssignedAllocation = 0;
		var remainingAllocation = 0;

		for(i=0; i<Contract_Main_ID.length; i++){//PROGRAM LOOP
			var CompLen = $("img[id="+ Contract_Main_ID[i]+"]").length;
			var Compallocation = (allocation/CompLen).toFixed(2);
			for(j=0; j<CompLen; j++){//COMP LOOP
				var AllocationID = Contract_Main_ID[i]+'_Allocation_'+j;
				$('#'+AllocationID).val(Compallocation);
				TotAssignedAllocation = (parseFloat(TotAssignedAllocation)+parseFloat(Compallocation)).toFixed(2);
			}
		}
		remainingAllocation = (parseFloat(TotalAllocation) - parseFloat(TotAssignedAllocation)).toFixed(2);
		if(remainingAllocation > 0){
			var i = Contract_Main_ID.length-1;
			var j = $("img[id="+ Contract_Main_ID[i]+"]").length-1;
			var AllocationID = Contract_Main_ID[i]+'_Allocation_'+j;
			var allocation = $('#'+AllocationID).val();
					allocation = parseFloat(allocation) + parseFloat(remainingAllocation);
					allocation = allocation.toFixed(2)
					$('#'+AllocationID).val(allocation);
		}

			errors = errors.toString();
			//window.opener.close();
			if(errors.length){
				$.noty.closeAll();
				noty( {  text: errors
			                ,type: 'error'
			                ,buttons: [  { text:'Close Message', addClass:'btn-primary', onClick:function($noty) {	$noty.close(); importPrograms();	} } ]
			                ,layout: 'bottom' });
				return;
			}else{
				importPrograms();
			}
		}
	}
/*
BELOW FUNCTION WILL IMPORT PROGRAMS
*/
function importPrograms(){
	var Prg_selected = $('#Prg_selected').val().split(',');
	                   Prg_selected = Prg_selected.filter(Boolean);

	if(Prg_selected.length){
	$.ajax( {
		type: "POST",
		url: "/components/Billback/Quick_Pay.cfc?method=SaveProgramInfo&ReturnFormat=JSON",
		data: ({
				Contract_Main_ID: $('#Prg_selected').val()
				,Contract_Number: $('#Prg_Num_selected').val()
				,Deduction_ID : <cfoutput>'#url.Deduction_ID#'</cfoutput>
				,DD_Ded_ID : <cfoutput>'#qGetDeduction.DD_DedID#'</cfoutput>
				,DD_Amount : <cfoutput>'#qGetDeduction.DD_Amount#'</cfoutput>
				,Reference_Number : <cfoutput>'#qGetDeduction.DD_Reference#'</cfoutput>
			}),
		dataType: 'JSON',
		success: function(response){
			//console.log(response)
			for (var i = 0; i < response.CONTRACTMAINID.length; i++) {
				var CompLen = $("img[id="+response.CONTRACTMAINID[i]+"]").length;
					for (var j = 0; j < CompLen; j++) {
						$('#'+response.CONTRACTMAINID[i]+'_PayeeNumber_'+j).val(response.PAYEENUMBER[i]);
						$('#'+response.CONTRACTMAINID[i]+'_PayeeID_'+j).val(response.PAYEEID[i]);
						$('#'+response.CONTRACTMAINID[i]+'_PayeeName_'+j).val(response.PAYEENAME[i]);
					}
				$('#Unique_ID').val(response.UNIQUEID);
			}
			$.noty.closeAll();

			var table = $('#allPrograms').DataTable();
					table.destroy();
					$('.SelectedPrg').css( "display", "" );
					$('#allPrograms').css( "display", "none" );
					$('#BBOtherFields').css( "display", "" );
					$('#createBB').css( "display", "" );
					$('#reset').css( "display", "" );
					$('#links').css( "display", "none" );
		},
		error: function(xhr, textStatus, errorThrown){ noty({ layout:"center", type:"error", text: "Importing Programs Failed" }).show(); }
	})
	//setTimeout(function(){ $.noty.closeAll(); },10000);
	}
}
/*
BELOW FUNCTION WILL CLEAR ALLOCATION FOR ALL RECORDS.
*/
function ClearAllocation(){
	$(".Allocation").val('') ;
}
/*
BELOW FUNCTION WILL DO FINAL VALIDATION BEFORE STORING DATA TO CREATE BILLBACKS.
*/
function validateInfo(){
//	noty({ layout:"center", type:"info", text: "Validating Data..." }).show();
	var errors = [];
	var DDAmount =<cfoutput>#qGetDeduction.DD_Amount#</cfoutput>;
	var TotAllocation = 0;
	var Prg_selected = $('#Prg_selected').val().split(',');
	var Prg_Num_selected = $('#Prg_Num_selected').val().split(',');
	var CompPerPrg = $('#Comp_per_Prg').val().split(',');

	TotAllocation = parseFloat(TotAllocation) + parseFloat($("#Remaining_Balance").val()) ;
	//$("#CompLength").val(CompLen);

	for(i=0;i<Prg_selected.length;i++){// PROGRAM LOOP
		var CMID = Prg_selected[i];
		var CompPrgLen = $('#Comp_per_Prg').val();
		if(CompPrgLen.length){
			CompPrgLen = CompPrgLen+','+$('.'+CMID).length;
		}else{
			CompPrgLen =$('.'+CMID).length;
		}

		var PrgComp = CompPerPrg[i]; //COMPONENTS PER PROGRAM

		$('#Comp_per_Prg').val(CompPrgLen);

		for(j=0;j<PrgComp;j++){ //COMPONENT LOOP
				/*
				ALLOCATION LOOP :: ONLY VALIDATE IF ALLOCATION HAS A VALUE GREATER THAN 0.
				IF ALLOCATION IS 0 OR EMPTY WE ASSUME USER DON'T WANT THAT PROGRAM AND COMPONENT COMBINATION
				*/
			var fieldExist =  CMID+'_BB_Start_Date_'+j;
			if (document.getElementById(fieldExist)) { //CHECK IF FIELD EXISTS
				if( $("#"+CMID+"_Allocation_"+j).val().length > 0){ //ALLOCATION LOOP
					TotAllocation = (parseFloat(TotAllocation)+parseFloat($("#"+CMID+"_Allocation_"+j).val())).toFixed(2);
					var CompName = $("#"+CMID+'_Comp_'+j).html();
					var DPStartDate= $("#"+CMID+"_BB_Start_Date_"+j).datepicker("getDate");
					var DPEndDate= $("#"+CMID+"_BB_End_Date_"+j).datepicker("getDate");

					if( $("#"+CMID+"_PayeeID_"+j+" option:selected").val() == 0){ // PAYEE DROP DOWN
						errors.push("Please select payee for component ( "+CompName+"  )On "+Prg_Num_selected[i]+".");
					}
					//117446 :: Billback - sales tax code START
					if(<cfoutput>#appSettings.getBillbacksSalesTax()#</cfoutput> == '2' && $("#"+CMID+"_TaxON_"+j).val() == '1'){ 
						if( $("#"+CMID+"_TaxType_"+j+" option:selected").val() == 0){ // TAX TYPE DROP DOWN
							errors.push("Please select tax type for component ( "+CompName+"  )On "+Prg_Num_selected[i]+".");
						} 
					}
					if( ! $("#"+CMID+"_BB_Start_Date_"+j).val().length || ! $("#"+CMID+"_BB_End_Date_"+j).val().length || ! $("#"+CMID+"_Billback_Date_"+j).val().length){ //BILLBACK DATE'S
						errors.push("Please enter date for component ( "+CompName+" ) on "+Prg_Num_selected[i]+".");
					}
					if(  ($("#"+CMID+"_BB_Start_Date_"+j).val().length && $("#"+CMID+"_BB_End_Date_"+j).val().length) && DPStartDate > DPEndDate){
						errors.push("Delivery period end date must be after the delivery period start date for component ( "+CompName+" ) On "+Prg_Num_selected[i]+".");
					}
					if( $("#BB_Payee option:selected").val() == 0){
						errors.push("Please select payee for component ( "+CompName+" ) on "+Prg_Num_selected[i]+".");
					}
				}//ALLOCATION LOOP
			}//CHECK IF FIELD EXISTS
		}//COMPONENT LOOP
	}// PROGRAM LOOP

		if( TotAllocation > DDAmount){
		errors.push("Total allocation is more than 100%.");
		}
		if( TotAllocation < DDAmount){
			errors.push("Total allocation is less than 100%.");
		}

	if($("#Remaining_Balance").val() != 0){
		if(<cfoutput>#variables.appSettings.getDDAllowNegativeAmountCredits()#</cfoutput> == 0 && $("#Remaining_Balance").val() < 0){
			errors.push("Total Allocation amount resulted in a negative balance, which is not allowed based on the current configuration.<br>Please adjust your allocations so there is not a negative balance.");
		}else{
				var RemainingBalance = $("#Remaining_Balance").val();
				if(RemainingBalance < 0){
					RemainingBalance = RemainingBalance * -1;
				}
				if( $("#Split_Action option:selected").val() == 0){
					errors.push("Please select split action.");
				}else if( $("#Split_Action option:selected").val() == 2){
					if( $("#Reason_Code option:selected").val() == 0){
						errors.push("Please select write off closure <cfoutput>#MCObject.stDeductionLabels["Reason Code"]#</cfoutput>.");
					}
					if(RemainingBalance > <cfoutput>#GetDDProfileSettings.DD_Match_Central_Write_Off_Amount#</cfoutput>){
						errors.push("Remaining Balance exceeds your threshold for <cfoutput>#MCObject.stDeductionLabels['Write Off']#</cfoutput>.");
					}
				}
		}
	}
	<cfif Get_DD_Closing_Method.RecordCount AND Get_DD_Closing_Method.Vendor_Required>
		if( ! $("#Vendor").val().length){
			errors.push("Please Enter Vendor");
		}
	</cfif>
	errors = errors.toString();
	errors = errors.replaceAll(',','<br>');
	if(errors.length){
		noty( {  text: errors
			,type: 'error'
			,buttons: [  { text:'Close Message', addClass:'btn-primary', onClick:function($noty) {  $noty.close(); } } ]
			,layout: 'bottom' });
		return;
	}else{
	/*DATE DIFFERENCE CHECK*/
	var DateErrors = ['Please confirm the billback start and end dates are accurate for '];
for(i=0;i<Prg_selected.length;i++){// PROGRAM LOOP
	var CMID = Prg_selected[i];

	var PrgComp = CompPerPrg[i]; //COMPONENTS PER PROGRAM
	for(j=0;j<PrgComp;j++){ //COMPONENT LOOP
			/*
			ALLOCATION LOOP :: ONLY VALIDATE IF ALLOCATION HAS A VALUE GREATER THAN 0.
			IF ALLOCATION IS 0 OR EMPTY WE ASSUME USER DON'T WANT THAT PROGRAM AND COMPONENT COMBINATION
			*/
		var fieldExist =  CMID+'_BB_Start_Date_'+j;
		if (document.getElementById(fieldExist)) { //CHECK IF FIELD EXISTS
			if( $("#"+CMID+"_Allocation_"+j).val() > 0){ //ALLOCATION LOOP
				if( $("#"+CMID+"_BB_Start_Date_"+j).val().length && $("#"+CMID+"_BB_End_Date_"+j).val().length){
					var BBStartDate= $("#"+CMID+"_BB_Start_Date_"+j).datepicker("getDate");
					var BBEndDate= $("#"+CMID+"_BB_Start_Date_"+j).datepicker("getDate");
					var today      = new Date();
					var farpast    = new Date().setDate(today.getDate() - 500);
					var farfuture  = new Date().setDate(today.getDate() + 500);

					days = (BBEndDate- BBStartDate) / (1000 * 60 * 60 * 24);

					if ( days > 500 || (BBStartDate < farpast) || (BBStartDate > farfuture) ) {
						if(DateErrors.indexOf(Prg_Num_selected[i]) == '-1'){
							DateErrors.push(Prg_Num_selected[i]);
						}
					}
				}
			}//ALLOCATION LOOP
		}//CHECK IF FIELD EXISTS
	}//COMPONENT LOOP
}// PROGRAM LOOP

	DateErrors = DateErrors.toString();
	//DateErrors = DateErrors.replaceAll(',','<br>');
	if (! confirm(DateErrors+'\nClick OK to continue. Click Cancel to update the dates.')) {
		return false;
	}

	const form = $( "form" );
	$('#createBB').css( "display", "none" );
	$('#dummyCreateBB').css( "display", "" );
	noty({ layout:"center", type:"info", text: "Billback Creation in Progress." }).show();
	$.ajax({  type    : "post"
		, url     : "/components/Billback/Quick_Pay.cfc?method=CreateQPBillbacks"
		, dataType: "json"
		, data: form.serialize()
		, success : function (response) {
			//console.log(response);
			$.noty.closeAll();
			if(response.BBINFO.length >= 1){
					noty({ layout:"center", type:"info", text: "Below Billback(s) Are Created Successfully "+response.BBINFO }).show();
					setTimeout(function(){BBAutoApprove(response.BBUNIQUEID);},3000);
				}else{
					noty({ layout:"center", type:"info", text:""+response.BBCREATIONSTATUS }).show();
					delayClose();
				}
			}
		,error: function(xhr, status, err) {
			noty({ layout:"center", type:"error", text: "Billback Creation Process Failed" }).show();
		}
		});
	}
}
/*
BELOW FUNCTION WILL AUTO APPROVE BILLBACKS.
*/
function BBAutoApprove(uniqueID){
	lockDD(0);
	$.noty.closeAll();
	noty({ layout:"center", type:"information",text: "Auto Approve Billbacks(s) In Process." }).show();
	$.ajax({  type    : "post"
		, url     : "/components/Billback/Quick_Pay.cfc"
		, dataType: "json"
		, data: { method: "AutoApproveQPBillbacks"
			,uniqueID: uniqueID
			}
		,success : function (response) {
			//console.log(response)
			$.noty.closeAll();
			noty({ layout:"center", type:"info", text: "Auto Approve Process Success." }).show();
			//window.opener.close();
			window.opener.location.reload();
			delayClose();
			}
		,error: function(xhr, status, err) {
			$.noty.closeAll();
			noty({ layout:"center", type:"error", text: "Auto Approve Process Failed" }).show();
		}
	});
}
// JUST TO DELAY POP-UP CLOSE
function delayClose(){
	setTimeout(function(){
	window.opener.close();
	self.close();
	},5000);
}
//OPEN PROGRAM PREVIEW
function openPRG(contract_main_id){
	let win_name = 'winSummary_' + contract_main_id;
	NewWindowTopLeft("/CID_Wrapper.cfm?Program_ID="+contract_main_id+"&Page_Relocate=/common_files/contracts/contract_edit_menu.cfm",win_name,"1345","710","yes","yes");
}
//DATE PICKER
function DatePicker(CMID, CompLen) {
	var Datetype = ["_BB_Start_Date_", "_BB_End_Date_", "_Billback_Date_"]
	for(j=0;j<CompLen;j++){  //Component Loop
		for(i=0;i<Datetype.length;i++){ //Date Type Loop
				var DateFiledID = CMID+Datetype[i]+j;
				$( "#"+DateFiledID ).datepicker({
						dateFormat: "m/d/yy",
						changeMonth: true,
						changeYear: true,
						yearRange: "2016:2026",
						onSelect: function( selected ) {
								let dateName = jQuery(this).attr("name");
								// change date limit based on selected value (if start/end)
								if ( DateFiledID.indexOf("BB_Start_Date") >= 0 )
								jQuery("input[id="+DateFiledID+"]").datepicker("option", "minDate", selected);
								else if ( DateFiledID.indexOf("BB_End_Date") >= 0 )
								jQuery("input[id="+DateFiledID+"]").datepicker("option", "maxDate", selected);
						}
				});
		}
	}
}
// LOCK & UNLOCK DEDUCTION
function lockDD(typ){
	if(typ){
		var fn = 'setDDLock';
	}else{
		var fn = 'DDUnlock';
	}
	$.ajax( {
		type: "POST",
		url: "/components/Billback/Quick_Pay.cfc?ReturnFormat=JSON&method="+fn,
		data: ({
			 Lock_Status : typ
			,Deduction_ID :  <cfoutput>'#url.Deduction_ID#'</cfoutput>
			}),
		dataType: 'JSON',
		success: function(response){
		//	console.log(response)
		$.noty.closeAll();
			if(! response.LOCKED){
				$('#allPrograms').show();
				getProgram('true', 'true');
			}
		},
		error: function(xhr, textStatus, errorThrown){
			noty({ layout:"center", type:"error", text: "Deduction Locking Process Failed" }).show();
		}
	});
}
//FUNCTION TO GET VENDORS
$("#vendorSearch").click(function(){
		window.open('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=CreateBBform&Settlements=1','vendorMaster','width=800,height=500,scrollbars=1');
})
//FUNCTION TO GET VENDOR INFORMATION
function vendorInfo(){
	var vendor = $("#Vendor").val();
if(vendor.length >3){
	$.ajax( {
		type: "POST",
		url: "/components/Billback/Quick_Pay.cfc?method=getVendorInfo&ReturnFormat=JSON",
		data: ({
			vendorID: $("#Vendor").val()
			, AQP: 1
			}),
		dataType: 'JSON',
		success: function(response){
			if(response.DATA.length){ 
				$('#Vendor').val(response.DATA[0][0]);
				$('#Vendor_Master_ID').val(response.DATA[0][1]);
				$('#Vendor_ID').val(response.DATA[0][2]);
			}else{
				$('#Vendor').val('');
				$('#Vendor_Master_ID').val('');
				$('#Vendor_ID').val('');
			}
		},
		error: function(xhr, textStatus, errorThrown){ new Noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
		});
}
}
window.addEventListener("beforeunload", function(){
	$.ajax({
		url: "/components/Billback/Quick_Pay.cfc"
					+ "?method=DDUnlock"
					+ "&Lock_Status=0"
					+ "&Deduction_ID=<cfoutput>#url.Deduction_ID#</cfoutput>"
	});
});
$( "#Split_Action" ).change(function() {
  var Option =  $('#Split_Action option:selected').val();
	if(Option == 1){
		$('.reasonCode').hide();
	}else{
		$('.reasonCode').show();
	}
});
</script>