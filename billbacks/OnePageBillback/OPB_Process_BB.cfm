<!---
* ====================================================================================================
*  @File: \billbacks\OnePageBillback\matches.cfm
*  @Author: Sharon Harris
*  @Date: June 2019
*  @Remarks: OnePageBillback Settlements page - Matches tab content
* ====================================================================================================
--->
<cfset minWriteOff = 0>
<cfset maxWriteOff = 0>
<cfset bDisplayKeepItOpen = 1 />
<cfset bDisplayWriteOff = 1 />
<cfset bAutoReconcile = 0/>
<cfset splitAction = "keepOpen">
<cfset workItemType = 'DD'>
<cfset Deduction_Info.Shr_Ship_To  = ''>

<cfset getDDAutoMatchSettings = MCObject.getDDAutoMatchSettings()>
<!---- WRITE OFF VALUE ---->
<cfset 	writeOffVal = Get_Profile_Settings.DD_Match_Central_Write_Off_Amount>

<cfif writeOffVal EQ "">
	<cfset writeOffVal = 0>
</cfif>

<cfif writeOffVal NEQ "*">
	<cfset minWriteOff = writeOffVal - (writeOffVal * 2)>
	<cfset maxWriteOff = writeOffVal>
</cfif>

<cfif application.appSettingsget.get_Setting('DD_Match_Central_Keep_It_Open') neq '1'>
	<cfset bDisplayKeepItOpen = 0 />
</cfif>
<cfif application.appSettingsget.get_Setting('DD_Match_Central_Write_Off') neq '1'>
	<cfset bDisplayWriteOff = 0 />
</cfif>

<cfif application.appSettingsget.getAuto_Reconcile_Match_Central_BB() AND (workItemType eq "BB" OR getDDAutoMatchSettings.Enabled)>
	<cfset bAutoReconcile = 1/>
</cfif>

<cfset Dollar_Amount_Value = getDDAutoMatchSettings.Dollar_Amount_Value>

<style type="text/css">
	#MatchInformation{
		height:20px;
	}
</style>
<div class="flexContainer process m-1">

	<div class="assign" id="assign">
	<!--- Billback GRID --->
	<div class="bbSection resizable">
		<div class="card-header"> <div style="width: 94%;float: left;"> Billbacks </div></div>
		<div id="billbackGrid" style="height:98%; width:100%; margin-bottom:5px;" class="ag-theme-balham"></div>
	</div>
	<div class="splitter" style="display: none"></div>
	<!--- Deduction GRID --->
	<cfif application.appSettingsGet.getDeduction_Module()>
		<div class="ddSection resizable" style="display: none" id="ddSection">
		<div class="card-header"> <div style="width: 94%;float: left;"> Deductions </div></div>
		<div id="deductionGrid" style="height:98%; width:100%; margin-bottom:5px;" class="ag-theme-balham"></div>
		</div>
	</cfif>
	</div>

	<div class="splitter-horizontal" style="display: none"></div>
	<!--- Matches GRID START--->
	<div class="resizable" style="display: none" id="matchSection">
		<div class="card-header"> <div style="width: 94%;float: left;"> Match </div></div>

		<div id="negativeMessageTable" style="display:none;width:100%;color: red;padding: 4px" align="center">
			At least one of your matches results in a negative balance, which is not allowed based on the current configuration.<br>
			Please adjust your matches accordingly and re-validate your match results.
		</div>

	<form name="matchProcessorForm" id="matchProcessorForm" style="display:inline;">
		<div style="width: 100%;">
			<div style="float:left;width:50%;">
				<table id="matchListGrid" style="width: 100%; border:none;" class="matchgrid">
				<thead>
				<tr>
					<th style="width:10%;border:none;" id="processButton"></th>
					<th style="width:30%;border:none;">
					<div style="width: 100%">
						<div style="float:left;width:75%"  id="MatchID">Deduction/Billback</div>
						<div style="float:right;width:25%" id="MatchAmount"></div>
					</div>
				</th>
				<th style="width:25%;border:none;">
					<select id="ClosureReasonCode" name="ReasonCode" style="height:20px ;border: solid 1px #c4c5c7; border-radius: 3px; width:150px;">
						<option>** Closure <cfoutput>#MCObject.stDeductionLabels["Reason Code"]#</cfoutput>**</option>
					</select>
				</th>
				<th style="width:20%;border:none;">
				<cfif appSettings.getDD_Show_Classification()>
					<select id="ClassificationID" name="ClassificationID" style="height:20px; border: solid 1px #c4c5c7; border-radius: 3px; width:110px;">
						<option>**<cfoutput>#MCObject.stDeductionLabels["Classification"]#</cfoutput>**</option>
					</select>
				<cfelse>
					<input type="hidden" name="ClassificationID" id="ClassificationID" value="0">
				</cfif>
				</th>
				</tr>
				</thead>
				<tbody></tbody>
				<tfoot>
				<tr>
					<td colspan="4" align="right"><b>Remaining Balance</b> <span id="RemainingBalance">$ 0.0000</span>&nbsp;&nbsp;</td>
				</tr>
				</tfoot>
				</table>
			</div>

			<div style="float:right;width:49%;">
				<div style="width:100%;background-color:#ffce84;text-align: left;height:28px;padding-top: 8px;padding-left: 4px;font-weight: bold">
					Remaining Balance Split Actions
				</div>

				<div style="display: flex; flex-flow: row wrap; width: 100%; ">
				 <!--- Split Action ---->
				  <div style="width: 150px;padding-top:5px;" id="splitActionBox">
						<div style="margin-top:2px;margin-bottom:2px;">Split Action</div>
						<select id="WhatToDo" name="whatToDo" style="height:20px; border: solid 1px #c4c5c7; border-radius: 3px; width:110px;">
							<option value="0">Select an option</option>
						</select>
				  </div>
				<!--- Classification ---->
				<cfif appSettings.getDD_Show_Classification()>
					<div style="width: 150px;padding-top:5px">
						<div style="margin-top:2px;margin-bottom:2px;"><cfoutput>#MCObject.stDeductionLabels["Classification"]#</cfoutput></div>
						<cfif appSettings.getDDChangeClassificationBeforeRFA()>
							<!---	<input type="hidden" name="DefaultClassForSplit_1" id="DefaultClassForSplit" value="#getDefaultClass.DD_Classification_ID#">---->
						<cfelse>
							<input type="hidden" name="DefaultClassForSplit" id="DefaultClassForSplit" value="0">
						</cfif>
						<select id="ClassificationIDForSplit" name="ClassificationIDForSplit" style="height:20px; border: solid 1px #c4c5c7; border-radius: 3px; width:110px;">
							<option value="0">Select an option</option>
						</select>
					</div>
				<cfelse>
					<input type="hidden" name="ClassificationIDForSplit" id="ClassificationIDForSplit" value="0">
				</cfif>
				<!--- REBILL ---->
				<div style="width: 150px;padding-top:5px;display:none;" id="RebillPackageBox">
					<div style="margin-top:2px;margin-bottom:2px;">Rebill Package</div>
					<select name="RebillPackage" id="RebillPackage" style="height:20px ;border: solid 1px #c4c5c7; border-radius: 3px; width:110px;">
						<option value="0">Select an option</option>
					</select>
				</div>
				<!--- WRITE OFF REASON CODE---->
				<div style="width: 175px;padding-top:5px;display: none;" id="WRCReasonCodeBox">
					<div style="margin-top:2px;margin-bottom:2px;">Write off Closure <cfoutput>#MCObject.stDeductionLabels["Reason Code"]#</cfoutput></div>
					<select name="ReasonCodeForSplit" id="ReasonCodeForSplit" style="height:20px ;border: solid 1px #c4c5c7; border-radius: 3px; width:110px;">
						<option value="0">Select an option</option>
					</select>
				</div>
				<!--- WRITE OFF REASON ---->
				<div style="width: 300px;padding-top:5px;display: none;" id="WRCReasonBox">
					<div style="margin-top:2px;margin-bottom:2px;">Write Off Reason</div>
					<textarea name="WriteOffReason" id="WriteOffReason" rows="2" cols="50" style="border: solid 1px #c4c5c7; border-radius: 3px;"></textarea>
				</div>
			</div>
		</div>
	</div>

	<input type="hidden" name="workItemID" id="workItemID" value="">
	<input type="hidden" name="matchList" id="matchList" value="">
	<input type="hidden" name="negativeBalanceWhenNoCredit" id="negativeBalanceWhenNoCredit" value="0">
	<input type="hidden" name="splitAction" id="splitAction" value="keepOpen">
	<input type="hidden" name="RemainingAmount" id="RemainingAmount" value="">
	<input type="hidden" name="autoReconcileDollarAmount" id="autoReconcileDollarAmount" value="0">
	<input type="hidden" name="loopCount" id="loopCount" value="1">
	<input type="hidden" name="SplitReason" id="SplitReason" value="match central split">
	<input type="hidden" name="isExactMatch" id="isExactMatch" value="0">
	<input type="hidden" name="SplitRecord" id="SplitRecord" value="">
	<input type="hidden" name="Default_Message" id="Default_Message" value="">
	<input type="hidden" name="RebillMessage" id="RebillMessage" value="">
	<input type="hidden" name="RebillClassIDForSplit" id="RebillClassIDForSplit" value="">
	<input type="hidden" name="RebillRCForSplit" id="RebillRCForSplit" value="">
	<input type="hidden" name="ClearedAmount" id="ClearedAmount" value="">
	</form>
	</div>
	<!--- Matches GRID END--->
</div>

<script>
	function matchDropDowns(){
	var remAmount = $('#RemainingBalance').html().replace(/[^\d.-]/g, '');

		if( <cfoutput>#application.appSettingsget.getAuto_Reconcile_Match_Central_BB()#</cfoutput>){
				if(remAmount > '<cfoutput>#Dollar_Amount_Value#</cfoutput>'){
					$('#autoReconcileDollarAmount').val('1');
				}
		}

	/*REBILL SELECT*/
	if($('#splitAction').val() == 'keepOpen' || $('#splitAction').val() == 'writeOff'||$('#splitAction').val() == ''){
		$('#RebillPackageBox').hide();
	}else{
		$('#RebillPackageBox').show();
	}

	/*WRITE OFF REASON SELECT && WRITE OFF REASON TEXTAREA*/
	if('<cfoutput>#writeOffVal#</cfoutput>' == '*' || (remAmount >= '<cfoutput>#minWriteOff#</cfoutput>' && remAmount <= '<cfoutput>#maxWriteOff#</cfoutput>')){
		if($('#splitAction').val() == 'keepOpen' || <cfoutput>#bAutoReconcile#</cfoutput>){
			$('#WRCReasonCodeBox').hide();
			$('#WRCReasonBox').hide();
		}else{
			$('#WRCReasonCodeBox').show();
			$('#WRCReasonBox').show();
		}
	}
}
	/*RESIZABLE FUNCTION CODE START*/
	  $(".bbSection").resizable({
	   handleSelector: ".splitter",
	   resizeHeight: false
	 });

	 $(".assign").resizable({
	   handleSelector: ".splitter-horizontal",
	   resizeWidth: false
	 });
	 /*RESIZABLE FUNCTION CODE END*/

/*POPULATE BILLBACK GRID*/
 var BillbackGridOptions = {
		columnDefs: [
			 {cellRenderer: CellRender, headerComponent: HeaderComponent, headerComponentParams: { divType: "BB" }, width: 25, floatingFilter: true}
			,{headerName: "Type", field: "Closing_Method_Abb", valueGetter:function(p){return p.data[ 0 ]}, filter: 'text', width: 50, floatingFilter: true}
			,{headerName: "Status", field: "BB_Stauts_Abb"
				,cellRenderer: function(p) {
					let status = p.data[1];
					let link ='';
					let img = '';
					if(p.data[2]=='1'){
							if(p.data[15]=='0'){
								 img =		'<img src="/images/worksheet.gif" border="0" width="12" height="10">';
							}else{
								 img =	'<img src="/images/doubledip2.png" border="0" width="12" height="10">';
							}
								 link ="&nbsp;&nbsp;<a href=javascript:runDeviations('"+p.data[16]+"') title=Click here to run deviation >"+img+ "</a>" ;
					}
							return status.concat(link);
					}
				, valueGetter:function(p){return p.data[ 1 ]}
				, filter: 'text', width: 65, floatingFilter: true}
			,{headerName: "<cfoutput>#stBBLabels.Payable#</cfoutput> ID", field: "Payable_ID"
			,cellRenderer: function(p) {
					var Billback = p.data[ 3 ];
					let img = '';
					let doc = '';
					if(p.data[17]=='1'){
						img =	'&nbsp;<img src="/images/iconmonstr-lock-1-24.png" border="0" width="12" height="12">&nbsp;';
					}
					if(p.data[20] !='0'){
						var title = "This billback has ".concat(p.data[20]).concat(" document(s) attached.");
						doc =	'&nbsp;<img src="/images/doc.gif" border="0" width="12" height="12" title="'+title+'">&nbsp;';
					}

					if(img=='' && doc==''){
						 Billback ="<a onclick=javascript:createDetailTab('"+p.data[16]+"','" +p.data[3]+"') >"+Billback+ "</a>"
						return Billback;
					}
					else{
						Billback ="<a onclick=javascript:createDetailTab('"+p.data[16]+"','" +p.data[3]+"') >"+Billback+ "</a>"
						return Billback.concat(img).concat(doc);
					}
				}
				,valueGetter:function(p){return p.data[ 3 ]}
				, filter: 'text', width: 125, floatingFilter: true}
			,{headerName: "<cfoutput>#stBBLabels.Reference_Number#</cfoutput>", field: "BB_Reference", valueGetter:function(p){return p.data[ 4 ]}, filter: 'text', width: 100, floatingFilter: true}
			,{headerName: "<cfoutput>#stBBLabels.Claimed#</cfoutput> Amt", field: "BB_Amount", valueGetter:function(p){return p.data[5]}, valueFormatter:function (p){return currencyFormat(p.data[5],  '$(0,0.00)');}, filter: 'number', width: 75, floatingFilter: true,cellStyle: function(p) {if (p.data[ 5 ] < 0) {return {color: 'red'};}}}
			,{headerName: "<cfoutput>#stBBLabels.Deviation#</cfoutput> Amt", field: "Deviated_Amount",valueGetter:function(p){return p.data[6]}, valueFormatter:function (p){return currencyFormat(p.data[6],  '$(0,0.00)');}, filter: 'number', width: 75, floatingFilter: true,cellStyle: function(p) {if (p.data[ 6 ] < 0) {return {color: 'red'};}}}
			,{headerName: "Approve Amt", field: "Approved_Amount", valueGetter:function(p){return p.data[7]}, valueFormatter:function (p){return currencyFormat(p.data[7],  '$(0,0.00)');}, filter: 'number', width: 75, floatingFilter: true,cellStyle: function(p) {if (p.data[ 7 ] < 0) {return {color: 'red'};}}}
			,{headerName: "<cfoutput>#stBBLabels.Billback#</cfoutput> Date", field: "BB_Date", valueGetter:function(p){return p.data[8]}, valueFormatter:function(p){return  dateFormat(p.data[ 8 ],  'MM/DD/YYYY')}, filter: 'date', width: 100, floatingFilter: true}
			,{headerName: "<cfoutput>#stBBLabels.Payee#</cfoutput> Name", field: "Payee_Name", valueGetter:function(p){return p.data[ 9 ]}, filter: 'text', width: 100, floatingFilter: true}
			,{headerName: "<cfoutput>#stBBLabels.Payee#</cfoutput> ID", field: "Payee_ID", valueGetter:function(p){return p.data[ 10 ]}, filter: 'text', width: 100, floatingFilter: true}
			,{headerName: "Start Date", field: "Delivery_start_date", valueGetter:function(p){return p.data[11]}, valueFormatter:function(p){return dateFormat(p.data[ 11 ],  'MM/DD/YYYY')}
				, filter: 'date', width: 100, floatingFilter: true}
			,{headerName: "End Date", field: "Delivery_end_date", valueGetter:function(p){return p.data[12]}, valueFormatter:function(p){return dateFormat(p.data[ 12 ],  'MM/DD/YYYY') }
				, filter: 'date', width: 100, floatingFilter: true}
			,{headerName: "Paid To", field: "Paid_To", valueGetter:function(p){return p.data[ 13 ]}, filter: 'text', width: 100, floatingFilter: true}
			,{headerName: "<cfoutput>#stBBLabels.Analyst#</cfoutput>", field: "Analyst", valueGetter:function(p){return p.data[ 14 ]}, filter: 'text', width: 100, floatingFilter: true}
		]
	,rowModelType:   "clientSide"
	//,floatingFilter:"true"
	,defaultColDef: {
        	 sortable: true
        	,floatingFilterComponentParams:{suppressFilterButton:true}
        	,resizable: true
        	,isRowSelectable: function(p) {
        			return p.data[17] ? p.data[17] =='1' : false;
    				}
    	}
    ,suppressRowClickSelection: true
    ,rowSelection: 'single'
	};

/*HEADER CHECKBOX FUNCTION*/
	function HeaderComponent() {}
	// init method for the checkbox header component, used to select all checkboxes in the cells below (not the typical select all rows)
	HeaderComponent.prototype.init = function(params) {
		this.eGui = document.createElement('div');
		var disabled = '';
		var idName = 'BBcheckall';
					 if(params.divType == 'DD'){
					 	idName = 'DDcheckall';
					 }
		var domString = "<input type= 'checkbox' style='display:none;'  onclick=javascript:HeaderClick('"+params.divType+"')  id = "+idName+"  name = "+idName+" >" ;
		this.eGui.innerHTML =  domString;
	};

	HeaderComponent.prototype.getGui = function() {
		return this.eGui;
	};

/*HEADER CHECKBOX CLICK FUNCTION*/
	function HeaderClick(divType) {
		let checkbox = document.getElementById('BBcheckall');
		if(divType == 'DD'){
			checkbox = document.getElementById('DDcheckall');
		}
    if(checkbox.checked == true) {
			if(divType == 'BB'){
				/*BILLBACK CHECK ALL LOGIC*/
				$("input[name=billback]").each(function(){
						this.checked=true;
						var BBcode = $(this).attr('BBcode');
						var BBid = $(this).attr('BBid');
						var Payee = $(this).attr('Payee');
						var PayeeID = $(this).attr('PayeeID');
						var Reference = $(this).attr('Reference');
						var AppAmt = $(this).attr('AppAmt');
						dataTransfer(BBcode, BBid, AppAmt, Payee, PayeeID, Reference, divType)
				})
			}else{
				/*DEDUCTION CHECK ALL LOGIC*/
				$("input[name=deduction]").each(function(){
					this.checked=true;
					var DDid = $(this).attr('DDid');
					var Deduction = $(this).attr('Deduction');
					var DDAmount = $(this).attr('DDAmount');
					dataTransfer(Deduction, DDid, DDAmount,'','','',divType)
				})
			}
	  }else{
			var id = '';
			if(divType == 'BB'){
				$("input[name=billback]").each(function(){
				  this.checked=false;
				  id = $(this).attr('BBid');
				  removeMatchID(id);
				})
			}else{
				$("input[name=deduction]").each(function(){
				  this.checked=false;
				  id = $(this).attr('DDid');
				  removeMatchID(id);
				})
			}
    }
		if(divType == 'BB'){
			BillbackGridOptions.api.refreshCells();
		}else{
			DeductionGridOptions.api.refreshCells();
		}
	};

// ADD RADIO BOX'S
function CellRender (p) {
	var divType = p.colDef.headerComponentParams.divType;
	var boxType ='radio';

	if(divType == 'BB'){
		var payee = p.data[9];
					 payee = payee.replace(/\s+/g, '_');
		var RefNum = p.data[4];
					RefNum = RefNum.toString().replace(/\s+/g, '_');

			if($('#WorkItemType').val() == 'DD'){
				boxType = 'checkbox';
			}
		return input = "<input type= "+boxType+" onclick=javascript:changeType('BB','"+p.data[7]+"','"+p.data[16]+"'),dataTransfer('"+p.data[3]+"','"+p.data[16]+"','"+p.data[7]+"','"+payee+"','"+p.data[19]+"','"+RefNum+"','BB')  value="+p.data[16]+"  BBcode = "+p.data[3]+"  BBid = "+p.data[16]+"  Payee = "+payee+"  PayeeID= "+p.data[19]+"  Reference= "+RefNum+" AppAmt= "+p.data[7]+" id="+p.data[16]+" name=billback>" ;
	}else{
			if($('#WorkItemType').val() == 'BB'){
				boxType = 'checkbox';
			}
				return input = "<input type= "+boxType+" onclick=javascript:changeType('DD','"+p.data[3]+"','"+p.data[9]+"'),dataTransfer('"+p.data[1]+"','"+p.data[9]+"','"+p.data[3]+"','','','"+p.data[4]+"','DD')  value="+p.data[9]+" DDid = "+p.data[9]+"  Deduction = "+p.data[1]+"  DDAmount = "+p.data[3]+" id="+p.data[9]+" name=deduction>" ;
		}
}

//CHANGE RADIO BUTTON TO CHECK BOX FUNCTION
function changeType(type, amt, ID){
	//MatchStartWith
	var changeField = 'billback';
	var  headerCheckBox = 'BBcheckall'
	var MTypeInfo = "Deduction to Billbacks"
	var workType = 'BB'
	$("#DDAmountFilter").val(amt);//FILTER BY WORK ITEM AMOUNT

	if(type=='BB'){
		changeField = 'deduction'
		headerCheckBox = 'DDcheckall'
		MTypeInfo = 'Billback to Deductions';
		workType = 'DD'
	}else{
		$('#splitAction').val('');
	}
	if($('#WorkItemType').val()==''){
		$('#WorkItemType').val(type);
		$("#SearchFilters").show();

		$("input[name="+changeField+"]").prop('type', 'checkbox');
		$('#'+headerCheckBox).css("display", "block");
  }
  $("#MatchInfo").show();
	$("#MTypeInfo").text(MTypeInfo);
  matchDropDowns();
}

function DistributorInfo(type, ID){
	$.ajax( {
			type: "POST",
			url: "/mvc/Models/OnePageBillback/OPBManager.cfc?method=getDistributorInfo&ReturnFormat=json",
			data: ({
								 type: type
								,ID :  ID
					   }),
			dataType: 'json',
			success: function(response){
				//console.log(response)
					$('#MC_Shr_Ship_to').val(response.DATA[0][0]);
					$('#MC_Distributor_Name').val(response.DATA[0][1]);
					$('#MC_Bill_To_Name').val(response.DATA[0][2]);
					$('#MC_Shr_Bill_To').val(response.DATA[0][3]);
					$('#MC_Vendor_ID').val(response.DATA[0][4]);
					$('#MC_Vendor_Name').val(response.DATA[0][5]);
					$('#MC_Distributor_Family_ID').val(response.DATA[0][6]);

					// DISPLAY & APPLY SEARCH FILTERS AND RELOAD BB & DD SECTIONS
					if(type=='BB'){
						$("#distributorFilter").show();
						$("#refnumberFilter").hide();
						$("#BBtoolTip").hide();
						$("#DDtoolTip").show();
						$( "#search" ).val('ded');
						ddLoad();
					}else{
						$("#distributorFilter").hide();
						$("#refnumberFilter").show();
						$("#BBtoolTip").show();
						$("#DDtoolTip").hide();
						$( "#search" ).val('bb');
						bbLoad();
					}

			},
			error: function(xhr, textStatus, errorThrown){
				new Noty({ layout:"center", type:"error", text: "Distributor Information Collection Process Failed" }).show();
			}
		});
}

function dataTransfer(code, id, Amount, Payee, PayeeID, Reference, Type){
	if(typeof Payee == "undefined"){
	  Payee = '';
	} else{
		Payee = Payee.replace(new RegExp('_', 'g'), ' ');
	}
	$('#FILTERddAmount').val(Amount);
	$('#FILTERreferencenumber').val(Reference);

	if(  ($('#WorkItemType').val() !='' && $('#WorkItemType').val() == Type ) ||  $('#WorkItemType').val() =='' ){
		$('#MatchID').html(code);
		$('#MatchAmount').html(currencyFormat(Amount,  '$(0,0.00)'));
		$('#workItemID').val(id);
		updateClosureReasonCode(id); //UPDATE CLOSURE REASON CODE
		calRemainingBalance(id);

		if(Type == 'DD' && Amount < 0){
			$( '#WorkItemType' ).val('CR');
			$( '#MatchItemType' ).val('BB');
		}else if(Type == 'DD' && Amount >=0){
			$( '#WorkItemType' ).val('DD');
			$( '#MatchItemType' ).val('BB');
		}else{
			$( '#WorkItemType' ).val('BB');
			$( '#MatchItemType' ).val('DD');
		}

	 var  split = Type.concat(':'+id)
					$( '#SplitRecord' ).val(split);
	}else if($('#WorkItemType').val() != Type){

		if($('#'+id).is(':checked') == true){
			var existingID = $('#matchList').val();
			    if(existingID.length){
						existingID = existingID.concat(',');
					}
						existingID = existingID.concat(id);
			$('#matchList').val(existingID);
			$("#matchListGrid").append(
				"<tr id='MatchInformation' class="+id+">" +
				"<td id='removeID' style='width:4%'> <img src='/images/no.png' onclick=removeMatchID('"+id+"')> </td>"+
				"<td id='selectedID' style='width:25%;'>"+code+"</td>" +
				"<td id='selectedPayee' style='width:40%;'>"+Payee+"</td>" +
				"<td id='selectedAmount' style='width:30%;'>"+currencyFormat(Amount,  '$(0,0.00)')+"</td>" +
				"</tr>"
			);

			$("#processButton").html('<button type="button" onClick="processMatch();" title="Process" class="button alt" id="matchProcess">Process</button>');
		}else{
			removeMatchID(id)
		}
		calRemainingBalance(id);
	}
	$('#splitAction').css({'display':'block'});

	DistributorInfo(Type, id); //POUPLATE DISTRIBUTOR INFORMATION WHICH WE NEED IN SEARCH FILTERS
}

function processMatch(){
	var RemainingActionerrors = [];
	var negativeBalanceWhenNoCredit = $('#negativeBalanceWhenNoCredit').val();
	/*CLOSURE REASON CODE VALIDATION*/
	if($("#ClosureReasonCode option:selected").val()=='0'){
		RemainingActionerrors.push("Please choose an option for closure reason code.");
	}
	/*SPLIT ACTION VALIDATION*/
	if($("#ClassificationID option:selected").val()=='0'){
		RemainingActionerrors.push("Please choose an option for classification.");
	}
	/*SPLIT ACTION VALIDATION*/
	if($("#WhatToDo option:selected").val()=='0'){
		RemainingActionerrors.push("Please choose an option for split action.");
	}
	/*CLASSIFICATION VALIDATION*/
	if(<cfoutput>#appSettings.getDD_Show_Classification()#</cfoutput> && $("#ClassificationIDForSplit option:selected").val()=='0'){
			RemainingActionerrors.push("Please choose an option for <cfoutput>#lcase(MCObject.stDeductionLabels["Classification"])#</cfoutput>.");
	}
	/*REBILL PACKAGE VALIDATION*/
	if($('#RebillPackageBox').is(':visible') && $("#RebillPackage option:selected").val()=='0'){
			RemainingActionerrors.push("Please choose an option for Rebill Package.");
	}
	/*REASON CODE FOR SPLIT VALIDATION*/
	if($('#WRCReasonCodeBox').is(':visible') && $("#ReasonCodeForSplit option:selected").val()=='0'){
			RemainingActionerrors.push("Please choose an option for Write off Closure <cfoutput>#MCObject.stDeductionLabels["Reason Code"]#</cfoutput>.");
	}
	/*WRITE OFF REASON CODE VALIDATION*/
	if($('#WRCReasonBox').is(':visible') && $('#WriteOffReason').val()==''){
			RemainingActionerrors.push("Please choose an option for Write Off Reason.");
	}
	if (RemainingActionerrors.length) {
		new Noty({ layout:"center", type:"error", text: noty_message(RemainingActionerrors.join("<br>")) }).show();
		return;
	}else{
		var formData = $('#matchProcessorForm').serialize();
			itemListError = function(request){
				new Noty({ layout:"center", type:"error", text: noty_message('! Sorry. There was an error.') }).show();
			}
			processInfo = function(request){
				new Noty({ layout:"center", type:"info", text: noty_message('Processing.....') }).show();
			}

	$.ajax( {
			type: "POST",
			url: "ajax/OPB_Process_Final.cfm",
			data: ({
							// options : formData
								 returnFormat: "json"
								,ClassificationID :  $( "#ClassificationID" ).val()
								,ClassificationIDForSplit : $( "#ClassificationIDForSplit" ).val()
								,ClearedAmount : $( "#ClearedAmount" ).val()
								,Default_Message : $( "#Default_Message" ).val()
								,fromSettlements : 1
								,isExactMatch : $( "#isExactMatch" ).val()
								,matchList : $( "#matchList" ).val()
								,ReasonCode : $( "#ClosureReasonCode" ).val()
								,ReasonCodeForSplit : $( "#ReasonCodeForSplit" ).val()
								,RebillClassIDForSplit : $( "#RebillClassIDForSplit" ).val()
								,RebillMessage : $( "#RebillMessage" ).val()
								,RebillPakID : $( "#RebillPackage" ).val()
								,RebillRCForSplit : $( "#RebillRCForSplit" ).val()
								,RemainingAmount : $( "#RemainingAmount" ).val()
								,splitAction : $( "#splitAction" ).val()
								,SplitReason : $( "#SplitReason" ).val()
								,SplitRecord : $( "#SplitRecord" ).val()
								,whatToDo : $( "#WhatToDo" ).val()
								,workItemID : $( "#workItemID" ).val()
								,WriteOffReason : $( "#WriteOffReason" ).val()
								,WorkWith : $( "#WorkWith" ).val()
								,WorkItemType : $( "#WorkItemType" ).val()
								,MatchItemType : $( "#MatchItemType" ).val()
					   }),
			dataType: 'json',
			success: function(response){
				clearMatch();
				$("input[name=match_deduction][value='1']").prop("checked",true);
				BBvalidate();
				DDvalidate();
				new Noty({ layout:"center", type:"info", text: noty_message('Match process is successful.') }).show();
			},
			error: function(xhr, textStatus, errorThrown){
				new Noty({ layout:"center", type:"error", text: "Match Process Failed" }).show();
			}
		});
	}
}

function removeMatchID(id){
$('.'+id).remove();
	var existingID = $('#matchList').val();
				existingID = existingID.replace(id,'');
				$('#matchList').val(existingID);

$('#'+id).prop( "checked", false );

var amt = $('#MatchAmount').html().replace(/[^\d.-]/g, '');
var Remaining_Balance = 0;
var sMatchAmt = 0;
var Mamt = 0;
var ClearedAmount = 0;

$("table#matchListGrid td#selectedAmount").each(function(i){
	Mamt = $(this).html();
	Mamt = Mamt.replace(/[^\d.-]/g, '');
	sMatchAmt = Number(sMatchAmt) + Number(Mamt);
});

 Remaining_Balance = Number(amt) - Number(sMatchAmt);

 ClearedAmount = Number(amt) - Number(Remaining_Balance);
 $('#ClearedAmount').val(ClearedAmount);

  if(Remaining_Balance <0){
		$('#RemainingBalance').css("color", "red");
	}else{
		$('#RemainingBalance').css("color", "black");
	}

$('#RemainingBalance').html(currencyFormat(Remaining_Balance,  '$(0,0.00)'));
$('#RemainingAmount').val(Remaining_Balance);

	<cfif ! appSettings.getDDAllowNegativeAmountCredits() AND application.appSettingsget.getAuto_Reconcile_Match_Central_BB() NEQ 1>
		if(Remaining_Balance <0){
			$('#negativeMessageTable').show();
			$('#negativeBalanceWhenNoCredit').val('1');
			$('#matchProcess').prop('disabled', true);
		}else{
			$('#negativeMessageTable').hide();
			$('#negativeBalanceWhenNoCredit').val('0');
			$('#matchProcess').prop('disabled', false);
		}
	</cfif>
}

function calRemainingBalance(id){
	var calculated_total_sum = 0;
	var Remaining_Balance = 0;

	$("#matchListGrid #selectedAmount").each(function () {
		var getAmount = $(this).html().replace(/[^\d.-]/g, '');
					getAmount = parseFloat(getAmount);
		if ($.isNumeric(getAmount)) {
			calculated_total_sum += parseFloat(getAmount);
		}
	});
	var matchAmount = $('#MatchAmount').html().replace(/[^\d.-]/g, '');
				matchAmount = parseFloat(matchAmount);
				Remaining_Balance = matchAmount - calculated_total_sum;
				ClearedAmount = Number(matchAmount) - Number(Remaining_Balance);

				$('#remainingBalance').val(Remaining_Balance);
				$('#ClearedAmount').val(ClearedAmount);

	if(Remaining_Balance <0){
		$('#RemainingBalance').css("color", "red");
	}
$('#RemainingAmount').val(Remaining_Balance);
	<cfif ! appSettings.getDDAllowNegativeAmountCredits() AND application.appSettingsget.getAuto_Reconcile_Match_Central_BB() NEQ 1>
		if(Remaining_Balance <0){
			$('#negativeMessageTable').show();
			$('#negativeBalanceWhenNoCredit').val('1');
			$('#matchProcess').prop('disabled', true);
		}else{
			$('#negativeMessageTable').hide();
			$('#negativeBalanceWhenNoCredit').val('0');
			$('#matchProcess').prop('disabled', false);
		}
	</cfif>

/*SPLIT ACTION DROP DOWN*/
var WhatToDo = document.getElementById("WhatToDo");

if(<cfoutput>'#writeOffVal#'</cfoutput>== '*' || ( Remaining_Balance >= <cfoutput>#minWriteOff#</cfoutput>  && Remaining_Balance <= <cfoutput>#maxWriteOff#</cfoutput>) ){

	if(WhatToDo.length == 1){
		if( <cfoutput>#application.appSettingsget.getAuto_Reconcile_Match_Central_BB()#</cfoutput>){
			var option = document.createElement("option");
						option.text = "Auto splitAction";
						option.value = "auto";
						WhatToDo.add(option, WhatToDo[1]);
		}
		if(<cfoutput>#bDisplayKeepItOpen#</cfoutput>){
			var option1 = document.createElement("option");
						option1.text = "Keep it open";
						option1.value = "keepOpen";
						WhatToDo.add(option1, WhatToDo[1]);
		}
		if(<cfoutput>'#workItemType#'</cfoutput> == 'DD' && <cfoutput>#appSettings.getIntegrated_Rebill()#</cfoutput> && <cfoutput>'#Deduction_Info.Shr_Ship_To#'</cfoutput> != ''){
			var option2 = document.createElement("option");
						option2.text = "Rebill";
						option2.value = "Rebill";
						WhatToDo.add(option2, WhatToDo[1]);
		}
		if(<cfoutput>#bDisplayWriteOff#</cfoutput>){
			var option3 = document.createElement("option");
						option3.text = "Write it off";
						option3.value = "writeOff";
						WhatToDo.add(option3, WhatToDo[1]);
		}
	}
}else{
		if(<cfoutput>#bAutoReconcile#</cfoutput>){
			var option1 = document.createElement("option");
						option1.text = "Auto Reconcile";
						option1.value = "Auto";
						WhatToDo.add(option1, WhatToDo[1]);
		}
		if(<cfoutput>#bDisplayKeepItOpen#</cfoutput>){
			var option2 = document.createElement("option");
						option2.text = "Keep it open";
						option2.value = "keepOpen";
						WhatToDo.add(option2, WhatToDo[1]);
	 }
}

/*REBILL DROP DOWN*/
	var RebillPackage = document.getElementById("RebillPackage");
		if(RebillPackage.length == 1){
			updateRebillPackage();
		}

/*CLASSIFICATION DROP DOWN*/
	if(<cfoutput>#appSettings.getDD_Show_Classification()#</cfoutput>){
		if(<cfoutput>#appSettings.getDDChangeClassificationBeforeRFA()#</cfoutput>){
			defaultClass(id);
		}
		updateClassification(id);
	}
	$('#FILTERremainingAmt').val(Remaining_Balance);
	$('#RemainingBalance').html(currencyFormat(Remaining_Balance,  '$(0,0.00)'));
}

function updateClassification(id){
		$.ajax( {
			type: "POST",
			url: "/mvc/Models/OnePageBillback/OPBManager.cfc?method=getAllClasses&ReturnFormat=json",
			data: ({	ID : id	 }),
			dataType: 'json',
			success: function(response){
				$('#ClassificationID').empty();
				$('#ClassificationID').append('<option value=0> **<cfoutput>#MCObject.stDeductionLabels["Classification"]#</cfoutput>** </option>');

				$('#ClassificationIDForSplit').empty();
				$('#ClassificationIDForSplit').append('<option  value=0> Select an option </option>');

				for (var i = 0; i < response.DATA.length; i++){
					$('#ClassificationID').append('<option title="' + response.DATA[i][1] + '"  value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
					$('#ClassificationIDForSplit').append('<option title="' + response.DATA[i][1] + '"  value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
				}

				$('#ClassificationID').prop("disabled", false);
				$('#ClassificationIDForSplit').prop("disabled", false);
			},
			error: function(xhr, textStatus, errorThrown){
				new Noty({ layout:"center", type:"error", text: "Classification Process Failed" }).show();
			}
		});
}
//REASON CODE POPULATE FUNCTION
function updateClosureReasonCode(id){
	$.ajax( {
		type: "POST",
		url: "/mvc/Models/OnePageBillback/OPBManager.cfc?method=getReasonCodes&ReturnFormat=json",
		data: ({	ID : id	 }),
		dataType: 'json',
		success: function(response){
			$('#ClosureReasonCode').empty();
			$('#ClosureReasonCode').append('<option  value=0>** Closure <cfoutput>#MCObject.stDeductionLabels["Reason Code"]#</cfoutput>**</option>');

			$('#ReasonCodeForSplit').empty();
			$('#ReasonCodeForSplit').append('<option  value=0> Select an option </option>');

			for (var i = 0; i < response.DATA.length; i++){
				$('#ClosureReasonCode').append('<option title="' + response.DATA[i][1] + '"  value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
				$('#ReasonCodeForSplit').append('<option title="' + response.DATA[i][1] + '"  value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
			}

			$('#ClosureReasonCode').prop("disabled", false);
			$('#ReasonCodeForSplit').prop("disabled", false);
		},
		error: function(xhr, textStatus, errorThrown){
			new Noty({ layout:"center", type:"error", text: "Reason Code Process Failed" }).show();
		}
	});
}
// DEFAULT CLASS FUNCTION
function defaultClass(id){
	$.ajax( {
		type: "POST",
		url: "/mvc/Models/OnePageBillback/OPBManager.cfc?method=getDefaultClass&ReturnFormat=json",
		data: ({	 ID : id	}),
		dataType: 'json',
		success: function(response){
				$('#DefaultClassForSplit').val(response.DATA[i][0]);
		},
		error: function(xhr, textStatus, errorThrown){
			new Noty({ layout:"center", type:"error", text: "Class Process Failed" }).show();
		}
	});
}
//REBILL PACKAGE POPULATE FUNCTION
function updateRebillPackage(){
	$.ajax( {
		type: "POST",
		url: "/mvc/Models/OnePageBillback/OPBManager.cfc?method=getRebills&ReturnFormat=json",
		data: ({	 }),
		dataType: 'json',
		success: function(response){
			$('#RebillPackage').empty();
			$('#RebillPackage').append('<option  value=0>Select an option</option>');
			for (var i = 0; i < response.DATA.length; i++){
				$('#RebillPackage').append('<option title="' + response.DATA[i][1] + '"  value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
			}

			$('#RebillPackage').prop("disabled", false);
		},
		error: function(xhr, textStatus, errorThrown){
			new Noty({ layout:"center", type:"error", text: "Rebill Process Failed" }).show();
		}
	});
}
//REMOVE MATCH ROWS
function removeMatch(type, ids){
	$('#matchListGrid tr.'+ids).remove();
	if(type=='Billback'){
		$('#MatchListGridInfo #MatchBB').html('');
		$('#MatchListGridInfo #MatchPayee').html('');
		$('#MatchListGridInfo #MatchRef').html('');
		$('#MatchListGridInfo #MatchAppAmt').html('');
	}else{
		$('#MatchListGridInfo #MatchDD').html('');
		$('#MatchListGridInfo #MatchDDAmt').html('');
	}
}

function isEditableCheckbox(params) {
	let isEditable  = true;
	return isEditable;
}

//DEVIATIONS POP-UP OPEN FUNCTION
function runDeviations(bbid){
	NewWindowTopLeft(
				"/flex/Billback/BillbackDevAppFX.cfm?bbid="+bbid+"&userID=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>&caller=BBFlexScoreCard&source=BBFlexScoreCard"
				,"BBDeviation", "location=1,status=1,scrollbars=1,resizable=1,left=0,width=1350,height=800"
				);
}

function Build_BillbacksGrid() {
	bbLoad();
	ag_grid_default (BillbackGridOptions);
	no_data_available(BillbackGridOptions, "hidden");   // suppress no data available message
	init_ag_grid( BillbackGridOptions, "#billbackGrid", false );
}

function bbLoad() {
	if (BillbackGridOptions) {
		if (BillbackGridOptions.api) {
			BillbackGridOptions.api.showLoadingOverlay();
      	no_data_available(BillbackGridOptions, "visible");
		}
	}
		$.ajax({
									type    : "post"
									,url  :  "ajax/OPB_Program_Details.cfm"
									,data: ({
											  returnFormat: "json"
											, match_deduction: $('input[name=match_deduction]:checked').val()
											, payable_search: $( "#payable_search" ).val()
											, billback_search: $( "#billback_search" ).val()
											, bb_program_search: $( "#bb_program_search" ).val()
											, bb_customer_search: $( "#bb_customer_search" ).val()
											, bb_operator_search: $( "#bb_operator_search" ).val()
											, bb_item_search: $( "#bb_item_search" ).val()
											, bb_item_group_search: $( "#bb_item_group_search" ).val()
											, bb_status_list: $("select[name=bb_status_list]").multipleSelect('getSelects').toString()
											, bb_closing_method: $("select[name=bb_closing_method]").multipleSelect('getSelects').toString()
											, billback_analyst: $("select[name=billback_analyst]").multipleSelect('getSelects').toString()
											, bb_template_list: $("select[name=bb_template_list]").multipleSelect('getSelects').toString()
											, bb_component_list: $("select[name=bb_component_list]").multipleSelect('getSelects').toString()
											, bb_paid_to: $("select[name=bb_paid_to]").multipleSelect('getSelects').toString()
											, fromCreate: $( "#fromCreate" ).val()
											, FILTERworkItemamount : $("#FILTERworkItemamount").val()
											, FILTERddAmount : $("#FILTERddAmount").val()
											, FILTERdistributor : $("#FILTERdistributor").val()
											, FILTERremainingBalance : $("#FILTERremainingBalance").val()
											, FILTERremainingAmt : $("#FILTERremainingAmt").val()
											, FILTERrefnumber : $("#FILTERrefnumber").val()
											, FILTERreferencenumber : $("#FILTERreferencenumber").val()
											, FILTERtype : $('input[name="FILTERtype"]:checked').val()
											, FILTERkeyword : $("#FILTERkeyword").val()
											, MC_Shr_Ship_to : $("#MC_Shr_Ship_to").val()
											, MC_Distributor_Name : $("#MC_Distributor_Name").val()
											, MC_Bill_To_Name : $("#MC_Bill_To_Name").val()
											, MC_Shr_Bill_To : $("#MC_Shr_Bill_To").val()
											, MC_Vendor_ID : $("#MC_Vendor_ID").val()
											, MC_Vendor_Name :  $("#MC_Vendor_Name").val()
											, MC_Distributor_Family_ID : $("#MC_Distributor_Family_ID").val()
											, search : $( "#search" ).val()
									})
									,dataType: 'JSON'
									,success : function (response) {
																	if (typeof response === 'string') {
																				response = JSON.parse(response);
																	}
										BillbackGridOptions.api.setRowData( response.ROWS );
										//console.log(response.ROWS)
										$('#BBLoaded').val( response.ROWS.length );
									}
									,error: function(xhr, status, err) {
										new Noty({ layout:"center", type:"error", text: "Process Failed" }).show();
									 }
		});
}

<cfif application.appSettingsGet.getDeduction_Module()>

var DeductionGridOptions = {
	columnDefs: [
			{cellRenderer: CellRender, headerComponent: HeaderComponent, headerComponentParams: { divType: "DD" }, width: 25,floatingFilter:"true"},
			{headerName: "Status", field: "DD_Status_Description", valueGetter:function(p){return p.data[ 0 ]}, filter: 'text', width: 55,floatingFilter:"true"},
			{headerName: "Deduction", field: "DD_DedID", valueGetter:function(p){return p.data[ 1 ]}, filter: 'text', width: 125,floatingFilter:"true"},
			{headerName: "Date", field: "DD_Date", valueGetter:function(p){return dateFormat(p.data[ 2 ],  'MM/DD/YYYY')}, filter: 'date',  width: 100,floatingFilter:"true"},
			{headerName: "Aging", field: "DD_Aging_Label", valueGetter:function(p){return p.data[ 10 ]}, filter: 'text',  width: 100,floatingFilter:"true"},
			{headerName: "Amount", field: "DD_Amount", valueGetter:function(p){return p.data[3]}, valueFormatter:function (p){return currencyFormat(p.data[3],  '$(0,0.00)');}, filter: 'number',  width: 100,floatingFilter:"true"},
			{headerName: "Reference", field: "DD_Reference", valueGetter:function(p){return p.data[ 4 ]}, filter: 'text',  width: 100,floatingFilter:"true"},
			{headerName: "Customer ID", field: "Customer_ID", valueGetter:function(p){return p.data[ 5 ]}, filter: 'text',  width: 100,floatingFilter:"true"},
			{headerName: "Customer Name", field: "Name", valueGetter:function(p){return p.data[ 6 ]}, filter: 'text',  width: 100,floatingFilter:"true"},
			{headerName: "Check", field: "Analyst", valueGetter:function(p){return p.data[ 7 ]}, filter: 'text',  width: 100,floatingFilter:"true"},
			{headerName: "Analyst", field: "BB_Payable_ID", valueGetter:function(p){return p.data[ 8 ]}, filter: 'text',  width: 100,floatingFilter:"true"},
		]
		,rowModelType:   "clientSide"
		//,floatingFilter:"true"
		,defaultColDef: {
						sortable: true
						,floatingFilterComponentParams:{suppressFilterButton:true}
						,resizable: true
				}
	}

function Build_DeductionGrid() {
	ddLoad();
	ag_grid_default (DeductionGridOptions);
	no_data_available(DeductionGridOptions, "hidden");   // suppress no data available message
	init_ag_grid( DeductionGridOptions, "#deductionGrid", false );
}

//DEDUCTION GRID BUILD FUNCTION
function ddLoad() {
	if (DeductionGridOptions) {
		if (DeductionGridOptions.api) {
			DeductionGridOptions.api.showLoadingOverlay();
      	no_data_available(DeductionGridOptions, "visible");
		}
	}

		$.ajax({
									type    : "post"
									,url  :  "ajax/OPB_Program_Details.cfm"
									,data: ({
											  returnFormat: "json"
											, deduction_search: $( "#deduction_search" ).val()
											, reference_search: $( "#reference_search" ).val()
											, check_search: $( "#check_search" ).val()
											, creference_search: $( "#creference_search" ).val()
											, dd_customer_search: $( "#dd_customer_search" ).val()
											, dd_status_list: $("select[name=dd_status_list]").multipleSelect('getSelects').toString()
											, dd_family: $("select[name=dd_family]").multipleSelect('getSelects').toString()
											, dd_analyst: $("select[name=dd_analyst]").multipleSelect('getSelects').toString()
											, FILTERworkItemamount : $("#FILTERworkItemamount").val()
											, FILTERddAmount : $("#FILTERddAmount").val()
											, FILTERdistributor : $("#FILTERdistributor").val()
											, FILTERremainingBalance : $("#FILTERremainingBalance").val()
											, FILTERremainingAmt : $("#FILTERremainingAmt").val()
											, FILTERrefnumber : $("#FILTERrefnumber").val()
											, FILTERreferencenumber : $("#FILTERreferencenumber").val()
											, FILTERtype : $('input[name="FILTERtype"]:checked').val()
											, FILTERkeyword : $("#FILTERkeyword").val()
											, MC_Shr_Ship_to : $("#MC_Shr_Ship_to").val()
											, MC_Distributor_Name : $("#MC_Distributor_Name").val()
											, MC_Bill_To_Name : $("#MC_Bill_To_Name").val()
											, MC_Shr_Bill_To : $("#MC_Shr_Bill_To").val()
											, MC_Vendor_ID : $("#MC_Vendor_ID").val()
											, MC_Vendor_Name :  $("#MC_Vendor_Name").val()
											, MC_Distributor_Family_ID : $("#MC_Distributor_Family_ID").val()
										  , search : $( "#search" ).val()
									})
									,dataType: 'JSON'
									,success : function (response) {
																	if (typeof response === 'string') {
																				response = JSON.parse(response);
																	}
															DeductionGridOptions.api.setRowData( response.ROWS );
									}
									,error: function(xhr, status, err) {
										new Noty({ layout:"center", type:"error", text: "Process Failed" }).show();
									 }
		});
}
</cfif>
//BILLBACK POP TAB FUNCTION
function createDetailTab(bbid, title){
	let BBHref = 'BBiframe.cfm?page=/billbacks/capture/index.cfm?bbid='+bbid+'&id='+bbid;
	let ret=createDynamicTab('navList', bbid, title, BBHref);
	if (ret <0) {
		new Noty({ layout:"center", type:"error", text: "Only 5 detail tabs are allowed" }).show();
	}
}

// wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
document.addEventListener("DOMContentLoaded", function () {
		Build_BillbacksGrid();
		<cfif application.appSettingsGet.getDeduction_Module()>
		Build_DeductionGrid();
		</cfif>
});
</script>