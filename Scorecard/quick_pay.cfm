<cfparam name="Form.bb_number "	default="">
<cfparam name="Form.bb_title"			default="">
<cfparam name="Form.amount"				default="">
<cfparam name="Form.CompID"				default="">
<cfparam name="Form.PayeeType"				default="">
<cfparam name="Form.PayeeID"				default="">
<cfparam name="Form.SubmitForm" 					default="0">
<cfparam name="Form.Discount_Type"				default="">
<cfparam name="Form.CompName"				default="">
<cfparam name="Form.ContractMainID" default="" >
<cfparam name="Form.from_date"				default="#dateformat(Now(),'m/d/yy')#">
<cfparam name="Form.to_date" default="#dateformat(Now(),'m/d/yy')#" >
<cfparam name="url.BB_Code" default="" >


<cfset variables.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset objSettingsService = createobject("component", "mvc.models.SettingsService") />
<cfset stBBLabels = objSettingsService.getBBLabels()>
<cfset QuickPay = createobject("component", "components.Billback.Quick_Pay") />


<!--- WR D80745 - Removed window close on timeout and added close link. Added redirect to prevent billback getting created multiple times in refresh --->
<cfif url.BB_Code neq "">

	<div style="font-size:14px;color:green;text-align:center;padding-top:25px;">
		<cfoutput>#stBBLabels.Payable# #url.BB_Code#</cfoutput> is created successfully.<br>
		<a onclick="window.close();"><cfoutput>#application.util.string.actionLinkFormat2('close')#</cfoutput></a>
	</div>

	<cfabort />
</cfif>

<cfif isdefined('url.cid')>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfset ContractMainID = cryp.value>
<cfelse>
	<cfset ContractMainID = Form.ContractMainID>
</cfif>
<cfquery name="getPrginfo" datasource="#Application.Datasource#">
	SELECT 	Contract_Main.*, pcpo.Retail_Planner, pcpo.Lump_Sum_Allocation_Method
	FROM 	Contract_Main
			INNER JOIN Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	WHERE 	Contract_Main_ID = #contractmainid#
	AND 	Contract_Main.Deleted = 0
</cfquery>
<cfset RemainingAccrual = QuickPay.getAccrualAmount(contractmainid)>
<!---
<cfset PageTitle = ''>
<cfif len(ContractMainID)>
	<cfquery name="getPrginfo" datasource="#Application.Datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = #contractmainid#
		AND Deleted = 0
	</cfquery>
	<cfset PageTitle = #getPrgInfo.Contract_Number#&' '&'Quick Pay'>
</cfif>
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
---->
<cfif Form.SubmitForm>
<!--- SAVE DATA & CREATE BILLBACK --->
	<cfset createBB = QuickPay.CreateBillbacks(form)>

	<cflocation url="quick_pay.cfm?BB_Code=#createBB.BB_Code#" />

	<!---
	<div style="font-size:14px;color:green;text-align:center;padding-top:25px;">
		<cfoutput>#stBBLabels.Payable# #createBB.BB_Code#</cfoutput> is created successfully.
	</div>

	<script>
		setTimeout(function(){  self.close(); },2000);
	</script>
	--->

<cfelse>
<!---CREATE BILLBACK FORM--->

<cfinclude template="/get_access_profile.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/string_functions.js, /common_files/jQuery.cfm">
<cf_include files="/script/javascript/chosen/chosen.jquery.min.js, /styles/chosen/chosen.css">
<cfinclude template="/Common_Files/dataTables.cfm">
<cf_include file_to_include="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css, /script/javascript/ajax_js/jqueryui-1.8.10.min.js, /script/javascript/numeral.min.js, /common_files/datatable.css"/>
 <cf_include files="/script/javascript/default.js, /styles/css-loader.css">

<cfset OnlyDistributorsUnderMe = 1 />
<cfif Get_Profile_Settings.BB_Add_Payee_Any_Position EQ 1>
	<cfset OnlyDistributorsUnderMe = 0 />
</cfif>

<!---If this is a Planner Program and the Lump Sum Allocation Method is Component_Product then we need to get Lump Sum Components by associated product/product groups --->
<cfset bByProduct = 0 />
<cfif getPrginfo.Retail_Planner eq 1 and getPrginfo.Lump_Sum_Allocation_Method eq "Component_Product">
	<cfset bByProduct = 1 />
</cfif>
<cfset getComponents = QuickPay.getComponentsList(#getPrgInfo.Contract_Number#, #bByProduct#)>


<cfoutput>

<form name="CreateBB" method="post" id="CreateBB" action="quick_pay.cfm?CID=#URL.CID#">
<table width="100%" border="0">
	<tr>
		<td width="26%"><b>Billback Number</b></td>
		<td>&nbsp;&nbsp;&nbsp;<input type="text" name="bb_number" value="#Form.bb_number#"id="bb_number" size="50" maxlength="#appSettings.getBB_Ref_Num_Max_Length()#"/></td>
	</tr>
	<tr>
		<td><b>#stBBLabels.Title#</b></td>
		<td>&nbsp;&nbsp;&nbsp;<input type="text" name="bb_title" value="#Form.bb_title#" id="bb_title" size="50"  maxlength="64"/></td>
	</tr>
	<tr>
		<td><b>Delivery Period Start/End</b></td>
		<td>&nbsp;&nbsp;
		<input name="from_date" id="from_date" type="text" class="date" value="#form.from_date#" style="width:75px">
		<b>&nbsp;	to &nbsp;</b>
		<input name="to_date" id="to_date" type="text" class="date" value="#form.to_date#" style="width:75px">
		</td>
	</tr>
	<tr id="rebProd" style="display:none">
		<td colspan="100%">
			<table class="datagrid" style="table-layout:fixed;">
  				<thead>
  					<tr>
						<th style="width:20%;text-align:center">#application.returned_customer_setting.q_brand_label_singular#</th>
						<th style="width:30%;text-align:center">#application.returned_customer_setting.q_brand_label_singular# Description</th>
						<th style="width:10%;text-align:center">Accrued</th>
						<th style="width:10%;text-align:center">Spent</th>
						<th style="width:10%;text-align:center">Remaining Balance</th>
						<th style="width:17%;text-align:center">Amount</th>
					</tr>
				</thead>
				<tbody id="groupLevelFooter">
					<tr>
						<td id="group" align="left"></th>
						<td id="groupDesc" align="left"></th>
						<td id="accrued" align="right"></th>
						<td id="spent" align="right"></th>
						<td id="remainingBalance" align="right"></th>
						<td id="Amount" align="right"></th>
					</tr>
				</tbody>
			</table>
		</td>
	</tr>
	<tr id="lsAmount" style="display:none">
		<td><b>Amount</b></td>
		<td>$&nbsp;<input type="text" name="amount" value="#Form.amount#" id="amount" onBlur="TwoDecimalsOnBlur(this);"/></td>
	</tr>
	<tr>
		<td><b>Component</b></td>
		<td>&nbsp;&nbsp;
			<select name="CompID" id="CompID" data-placeholder="Select a Component..." style="width: 300px;">
					<option value="0" id="0">Select a Component</option>
				<cfloop query="getComponents">
					<option value="#CompID#" id="#PaidTo#" Type = "#Product_Type#" Payment ="#Payment_Type_Name#" AccrualOn="#Accrual_On#" Discount_Comp_ID="#Discount_Comp_ID#" <cfif CompID EQ Form.CompID OR getComponents.recordcount EQ 1>Selected</cfif>>#CompName#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td><b>Display only Payee(s) with accrual dollars</b></td>
		<td>&nbsp;
						<input type="radio" name="Payee_Accrual_Dollars" value="1" checked>Yes
						<input type="radio" name="Payee_Accrual_Dollars" value="0" >No
		</td>
	</tr>
	<tr>
		<td><b>Payee</b></td>
		<td>&nbsp;&nbsp;
			<select name="Payee" id="Payee" data-placeholder="Select a Payee..." style="width:300px;">
				<option value="0" id="0">Select a Payee</option>
			</select>
			<br>
			<span id="PayeeInfo">

			</span>
			<input type="hidden" name="PayeeID" value="" id="PayeeID">
		</td>
	</tr>
	<tr>
		<td><b>Closing Method</b></td>
		<td>&nbsp;
			<input type="radio" name="BB_Closing_Method" value="1">Payment
			<input type="radio" name="BB_Closing_Method" value="2">Deduction
		</td>
	</tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr id="vendor" style="display:none;">
		<td><b>Vendor</b></td>
		<td>&nbsp;&nbsp;
			<a onClick="searchVendor()" style="cursor: pointer;">#application.util.string.actionLinkFormat2('payee search')#</a>
		</td>
	</tr>
	<tr id="vendordetails" style="display:none;">
		<td>&nbsp;</td>
		<td id="VendorInfo" style="padding-left: 10px;"></td>
	</tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr>
		<td colspan="2" align="center"><a onclick="submitForm();">#application.util.string.actionLinkFormat2('Create #stBBLabels.Payable#')#</a></td>
	</tr>
	<input type="hidden" name="Discount_Type" value="#Form.Discount_Type#" id="Discount_Type">
	<input type="hidden" name="CompName" value="#Form.CompName#">
	<input type="hidden" name="PayeeType" value="#Form.PayeeType#" id="PayeeType">
	<input type="hidden" name="ContractMainID" value="#ContractMainID#" id="ContractMainID">
	<input type="hidden" name="vendor_id" value="" id="vendor_id">
	<input type="hidden" name="SubmitForm" value="0">
	<input type="hidden" name="LSAmount" value="0" id="LSAmount">
	<input type="hidden" name="lProductGroup" value="" id="lProductGroup">
	<input type="hidden" name="bIsAccrualOn" value="" id="bIsAccrualOn">
	<input type="hidden" name="ContractNumber" value="#getPrgInfo.Contract_Number#" id="ContractNumber">
	<input type="hidden" name="TopPayeeID" value="" id="TopPayeeID">
	<input type="hidden" name="Discount_Comp_ID" value="" id="Discount_Comp_ID">
</table>

</form>
	<cfset today = #dateformat(Now(),'m/d/yy')#>
	<cfset farfuture = #dateformat(Now()+500,'m/d/yy')#>
	<cfset farpast = #dateformat(Now()-500,'m/d/yy')#>
</cfoutput>
<style type="text/css">
	.chosen-container{
		font-size: 8pt;
		font-family: Arial;
	}
</style>
<script>

	var ContractMainID =<cfoutput>#ContractMainID#</cfoutput>;










	function submitForm(){
		var errorMessage = '';

		if($("#bb_number").val().length == '0'){
			<cfoutput>
			errorMessage = errorMessage.concat('#stBBLabels.Billback# number is required field. \n');
			</cfoutput>
		}
		if($("#bb_title").val().length == '0'){
			<cfoutput>
			errorMessage = errorMessage.concat('#stBBLabels.Billback# title is required field. \n');
			</cfoutput>
		}

		/*
		if($("#amount").val().length == '0'){
			errorMessage = errorMessage.concat('Amount is required field. \n');
		}
		*/
		if($('#CompID option:selected').val() == '0'){
			errorMessage = errorMessage.concat('Component is a required field. \n');
		}
		if($('#PayeeID').val().length == '0' ){
			errorMessage = errorMessage.concat('Payee is a required field. \n');
		}
		if( $('#Discount_Type').val() == 'L' &&  ( Number($("#LSAmount").val()) < Number($("#amount").val()))){
			//if($('#CompID option:selected').attr('AccrualOn')== 1){
				errorMessage = errorMessage.concat('Amount entered exceeds the available lump sum monies.  Remaining lump sum balance is '+$("#LSAmount").val()+'\n')
			//}
		}
		if($('#Discount_Type').val() == 'R'){

			var AccrualRemAmount = <cfoutput>#RemainingAccrual#</cfoutput>;
			var accrAmount = $( "input[name^='accrAmount_']" );
			var accrRemAmount = $( "input[name^='accrRemAmount_']" );
			var amountEnt = $( "input[name^='amount_']" );

			if (document.all.bIsAccrualOn.value == 1){
				accrRemAmount.each(function (){
					var s = $(this).attr("name");
					var n = $(this).attr("id");
					var a = $(this).val();

					amountEnt.each(function (){
						var t = $(this).attr("name");
						var g = $(this).attr("id");
						var b = $(this).val();
						if(g==n){
							if(a.length>0 && b.length>0){
								if (parseFloat(a) < parseFloat(b)){
									errorMessage = errorMessage.concat('Amount is greater than remaining Accrued dollars. Billback cannot be created. \n');
								}
							}
						}

					});
				});
			}
		}

		if( $('#from_date').val() == ''){
			errorMessage = errorMessage.concat('Please enter the delivery period start date. \n')
		}

		if( $('#to_date').val() == ''){
			errorMessage = errorMessage.concat('Please enter the delivery period end date. \n')
		}

		if(! $('input[name=BB_Closing_Method]:radio:checked').val()){
			errorMessage = errorMessage.concat('Closing method is a required field. \n')
		}

		if($("input[name='BB_Closing_Method']:checked").val() == 1 && $('#vendor_id').val() == '' ){
			errorMessage = errorMessage.concat('Vendor is required when closing method is payment. \n')
		}

		var fromdate = $('#from_date').datepicker('getDate');
		var enddate = $('#to_date').datepicker('getDate');

		if( enddate < fromdate){
			errorMessage = errorMessage.concat('The delivery period end date must be after the delivery period start date. \n')
		}

		var days   = (enddate - fromdate)/1000/60/60/24;

		if ( (days > 500)
			|| ($('#from_date').val() < <cfoutput>#farpast#</cfoutput>)
			|| ($('#from_date').val() > <cfoutput>#farfuture#</cfoutput>) ) {
			if (! confirm('Please confirm the billback start and end dates are accurate.\nClick OK to continue.  Click Cancel to update the dates.')) {
				return false;
			}
		}

		if(errorMessage.length){
			alert(errorMessage);
			return;
		}else{
			document.all.SubmitForm.value='1';
			document.getElementById('CreateBB').submit();
		}

	}
//SUBMIT FORM FUNCTION END

	function searchVendor(){
		NewWindow("/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=CreateBB&QuickPay=1", "vendorMaster", 850, 600, "yes", "yes");
	}

	function TwoDecimalsOnBlur(oObject){
		var nf = new NumberFormat();
		nf.setNumber(oObject.value);
		nf.setCommas(false);
		nf.setCurrency(false);
		nf.setPlaces(2);
		oObject.value = nf.toFormatted();
	}

$('#CompID').chosen();
$('#Payee').chosen();

$('#CompID').change( function( ){

		document.all.Discount_Type.value = $('#CompID option:selected').attr('Type');
		document.all.bIsAccrualOn.value = $('#CompID option:selected').attr('AccrualOn');
		document.all.CompName.value = $('#CompID option:selected').text();
		document.all.Discount_Comp_ID.value = $('#CompID option:selected').attr('Discount_Comp_ID');

		if($('#CompID option:selected').attr('Type') == 'L'){
			$.ajax( {
				type: "POST",
				url: "/components/Billback/Quick_Pay.cfc?method=getLSAmount&ReturnFormat=JSON",
				data: ({	<cfoutput>
											ContractMainID: #ContractMainID#
										, ContractNumber: '#getPrgInfo.Contract_Number#'
											</cfoutput>
										}),
				dataType: 'JSON',
				success: function(response){
					var lsamount = response.toFixed(2)
					document.all.LSAmount.value= lsamount;
					$( "#rebProd" ).css( "display", "none" );
					$( "#lsAmount" ).css( "display", "" );
					$("input[name=lProductGroup]").val('');
				},
				error: function(xhr, textStatus, errorThrown){ alert(textStatus);alert('request failed');}
			});
		}

	switch ($('#CompID option:selected').attr('id')) {
		case "1" :
			document.all.PayeeType.value = 'D';
			var funName = 'getDistributors';
		break;
		case "2" :
			document.all.PayeeType.value = 'O';
			var funName = 'getOperators';
		break;
		case "3" :
			document.all.PayeeType.value = 'B';
			var funName = 'getBrokers';
		break;
	}
	switch ($('#CompID option:selected').attr('Type'))	{
			case "F":
				var discountType = 1;
			break;
			case "R" :
				var discountType = 2;
			break;
			case "L" :
				var discountType = 3;
			break;
		}
		$('#Payee option[value!="0"]').remove();
		payeeList(ContractMainID, $("input[name='Payee_Accrual_Dollars']:checked").val(), funName);
		$('#groupLevelFooter').empty();
		/*$('#rebProd').css( "display", "none" );
		QuickPayProductGroupLevel($('#Payee option:selected').val(), discountType);*/
});

$('input:radio[name=Payee_Accrual_Dollars]').change(function() {
	switch ($('#CompID option:selected').attr('id')) {
		case "1" :
			document.all.PayeeType.value = 'D';
			var funName = 'getDistributors';
		break;
		case "2" :
			document.all.PayeeType.value = 'O';
			var funName = 'getOperators';
		break;
		case "3" :
			document.all.PayeeType.value = 'B';
			var funName = 'getBrokers';
		break;
	}
	switch ($('#CompID option:selected').attr('Type'))	{
			case "F":
				var discountType = 1;
			break;
			case "R" :
				var discountType = 2;
			break;
			case "L" :
				var discountType = 3;
			break;
		}
			$('#groupLevelFooter').empty();
			$('#rebProd').css( "display", "none" );
      payeeList(ContractMainID, $("input[name='Payee_Accrual_Dollars']:checked").val(), funName);
      //QuickPayProductGroupLevel($('#Payee option:selected').val(), discountType);
    });

$( "#Payee" ).change( function( ){
		if($('#CompID option:selected').attr('Payment') == 'Billback' || $('#CompID option:selected').attr('Payment') == 'Check'|| $('#CompID option:selected').attr('Payment') == 'Payment'){
			$('#vendor').show();
		}
		var CM = $('#Payee option:selected').attr('CM');
		if(CM){
			$("input[name=BB_Closing_Method][value="+CM+"]").attr('checked', true);
		}
		document.all.Payee.value = $('#Payee option:selected').val();
		switch ($('#CompID option:selected').attr('Type'))	{
			case "F":
				var discountType = 1;
			break;
			case "R" :
				var discountType = 2;
			break;
			case "L" :
				var discountType = 3;
			break;
		}

		$.ajax( {
			type: "POST",
			url: "/components/Billback/Quick_Pay.cfc?method=getInfo&ReturnFormat=JSON",
			data: ({	Type:  document.all.PayeeType.value, PayeeID: $('#Payee option:selected').val()}),
			dataType: 'JSON',
			success: function(response){
				$('#PayeeInfo').html(response.DATA[0][0]);
				document.all.PayeeID.value = response.DATA[0][1];
				$(".datagrid > tbody").empty();
				QuickPayProductGroupLevel($('#Payee option:selected').val(), discountType);
			},
			error: function(xhr, textStatus, errorThrown){ alert('request failed');}
		});
});
// $( "#Payee" ).change END

function vendorInfo(){
	$.ajax( {
				type: "POST",
				url: "/components/Billback/Quick_Pay.cfc?method=getVendorInfo&ReturnFormat=JSON",
				data: ({	vendorID: $("#vendor_id").val()}),
				dataType: 'JSON',
				success: function(response){
					$('#vendordetails').show();
					$('#VendorInfo').append(response.DATA[0][0]);
				},
				error: function(xhr, textStatus, errorThrown){ alert(textStatus);alert('request failed');}
			});
}
// vendorInfo END

$(".date").datepicker({
    dateFormat: "m/d/yy",
    changeMonth: true,
    changeYear: true,
    onSelect: function( selected ) {
        // change date limit based on selected value
        if ( jQuery(this).attr("name") === "from_date" )
            jQuery("input[name=to_date]").datepicker("option", "minDate", selected);
        else
            jQuery("input[name=from_date]").datepicker("option", "maxDate", selected);
    }
});


function QuickPayProductGroupLevel(PayeeID){

	switch ($('#CompID option:selected').attr('Type'))	{
			case "F":
				var discountType = 1;
			break;
			case "R" :
				var discountType = 2;
			break;
			case "L" :
				var discountType = 3;
			break;
		}
	if($('#CompID option:selected').attr('Type') == 'R'){
	show_loader( "UPDATING PROGRAMS, PLEASE WAIT...");
	var filterDistributor = $("input[name='Payee_Accrual_Dollars']:checked").val();
	var payeeType = $('#CompID option:selected').attr('id');
	function currencyFormat(amount, fmt) {
      fmt = fmt || '($ 0,0.00)';
      return numeral( amount.toString() ).format( fmt );
  }


			$.ajax({
					type: "POST",
					url: "/components/Billback/Quick_Pay.cfc?method=getQuickPayProductGroupLevel&filterDistributor="+filterDistributor+"&payeeType="+payeeType+"&ReturnFormat=JSON",
					data: ({ ContractMainID:  ContractMainID, productType: discountType, distributorID: PayeeID}),
					dataType: 'JSON',
					success: function(response){
						if(response.DATA.length == 0){
							$( "#rebProd" ).css( "display", "none" );
						}else{
						var strProdGroupList = '';

						for(var i = 0; i < response.DATA.length; i++) {
							var idKey= response.DATA[i][5].replace(/-/g, '_');
							strProdGroupList = strProdGroupList + ',' + idKey;
							var strDisabled = '';
							if (response.DATA[i][4] == 0.00 && document.all.bIsAccrualOn.value == 1){
								strDisabled = 'disabled';
							}
							if (response.DATA[i][4] <'0.00'){
								color = 'red';
							}else{
								color = '#3D3D3D';
							}
							var tr=$('<tr></tr>');
							$('<td>'+ response.DATA[i][0] +'</td>').appendTo(tr);
							$('<td>'+ response.DATA[i][1] +'</td>').appendTo(tr);
							$('<td align=right>'+ currencyFormat(response.DATA[i][2],  '$ (0,0.00)') +'</td>').appendTo(tr);
							$('<td align=right>'+ currencyFormat(response.DATA[i][3],  '$ (0,0.00)') +'</td>').appendTo(tr);
							$('<td align=right style=color:'+color+'>'+ currencyFormat(response.DATA[i][4],  '$ (0,0.00)') +'</td>').appendTo(tr);
							$('<td align=right> <input style="text-align:right" type="text" name="amount_' +  idKey + '" value="" onBlur="TwoDecimalsOnBlur(this);" ' + strDisabled + ' id="' + idKey + '" /> </td>').appendTo(tr);
							tr.appendTo('#groupLevelFooter');
							$('<input type="hidden" name="groupNumber_' +  idKey + '" value="' + response.DATA[i][0] + '" /> ').appendTo('#groupLevelFooter');
							$('<input type="hidden" name="accrAmount_' +  idKey + '" value="' + response.DATA[i][2] + '" id="' + idKey + '" /> ').appendTo('#groupLevelFooter');
							$('<input type="hidden" name="accrRemAmount_' +  idKey + '" value="' + response.DATA[i][4] + '" id="' + idKey + '" /> ').appendTo('#groupLevelFooter');
						}

						$("input[name=lProductGroup]").val(strProdGroupList);
						$( "#rebProd" ).css( "display", "" );
						$( "#lsAmount" ).css( "display", "none" );
						}
						$(".loader").hide();//HIDE LOADER
					},
					error: function(xhr, textStatus, errorThrown){ alert('request failed');}
				});

		}
}

function 	payeeList(ContractMainID, PayeeAccrualDollars, funName){
	switch ($('#CompID option:selected').attr('Type'))	{
			case "F":
				var discountType = 1;
			break;
			case "R" :
				var discountType = 2;
			break;
			case "L" :
				var discountType = 3;
			break;
		}
	$('#Payee').empty();

	$.ajax({
			type: "POST",
			url: "/components/Billback/Quick_Pay.cfc?method="+funName+"&discountType="+discountType+"&ReturnFormat=JSON",
			data: ({
										ContractMainID:  ContractMainID
									, Payee_Accrual_Dollars : PayeeAccrualDollars
									}),
			dataType: 'JSON',
			success: function(response){
				for (var i = 0; i < response.DATA.length; i++){
					$('#Payee').append('<option title="' + response.DATA[i][1] + '"  value="' + response.DATA[i][0] + '"  CM="' + response.DATA[i][2] + '">' + response.DATA[i][1] + '</option>');
				}
				if (response.DATA.length > 0 )	{
				if (response.DATA.length == 1 )	{
					document.getElementById('Payee').getElementsByTagName('option')[0].selected;
					$("input[name=BB_Closing_Method][value="+response.DATA[0][2]+"]").attr('checked', true);
							//$( "#Payee" ).trigger("change");
						}else{
							$('#TopPayeeID').val(response.DATA[0][0]);
				}
					$('#Payee').trigger("chosen:updated");
					$('#Payee').trigger("change");
				}else{
					$('#Payee').chosen("destroy");
					$('#Payee').chosen();
					$('#Payee').append('<option value="0" id="0">Select a Payee...</option>');
				$('#Payee').trigger("chosen:updated");
					$('#PayeeInfo').empty();
				}
			},
			error: function(xhr, textStatus, errorThrown){ alert('request failed');}
		});

}
<cfif getComponents.recordcount EQ 1>$('#CompID').trigger("change");</cfif>
</script>
</cfif>