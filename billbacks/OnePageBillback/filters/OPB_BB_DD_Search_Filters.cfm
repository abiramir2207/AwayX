<!--- FILTERING --->
<cfoutput>
<div id="SearchFilters" class="details-card" style="display: none">
	<div class="card-header">Search Filters</div>
	<div class="card-main" style="width: 100%;">

<input name="FILTERworkItemamount" id="FILTERworkItemamount" type="checkbox" value="true" Checked>Filter By Work Item Amount <br>
<input name="FILTERddAmount" id="FILTERddAmount" type="hidden" value="" >

<!---ONLY FOR DEDUCTION---->
<div style="display:none" id="distributorFilter">
	<input name="FILTERdistributor" id="FILTERdistributor" type="checkbox" value="true" Checked>Filter by #application.returned_customer_setting.distributor_label_singular#<br>
</div>

	<input name="FILTERremainingBalance" id="FILTERremainingBalance" type="checkbox" value="true"
		<cfif appSettings.getDDCloseWithEqualBBAmt()>
			checked
		</cfif>
		<cfif appSettings.getDDCloseWithEqualBBAmt()>
			disabled
		</cfif>>Filter by Remaining Balance<br>
		<input name="FILTERremainingAmt" id="FILTERremainingAmt" type="hidden" value="" >

	<!---ONYL FOR BILLBACK--->
	<div style="display:none" id="refnumberFilter">
		<input name="FILTERrefnumber" id="FILTERrefnumber" type="checkbox" value="true" Checked>Filter By Reference Number<br>
		<input name="FILTERreferencenumber" id="FILTERreferencenumber" type="hidden" value="" >
		&nbsp;
		Filter By <input name="FILTERtype" id="FILTERdistributor1" type="radio" value="1" Checked>Distributor
									<input name="FILTERtype" id="FILTERdistributor2" type="radio" value="2">Family
									<input name="FILTERtype" id="FILTERdistributor3" type="radio" value="0" >None
		<br>
	</div>
	<input type="hidden" name="FILTERDistributorFamilyID" id="FILTERDistributorFamilyID" value="" >
	<input type="hidden" name="MC_Shr_Ship_to" id="MC_Shr_Ship_to" value="">
	<input type="hidden" name="MC_Distributor_Name" id="MC_Distributor_Name" value="">
	<input type="hidden" name="MC_Bill_To_Name" id="MC_Bill_To_Name" value="">
	<input type="hidden" name="MC_Shr_Bill_To" id="MC_Shr_Bill_To" value="">
	<input type="hidden" name="MC_Vendor_ID" id="MC_Vendor_ID" value="">
	<input type="hidden" name="MC_Vendor_Name" id="MC_Vendor_Name" value="">
	<input type="hidden" name="MC_Distributor_Family_ID" id="MC_Distributor_Family_ID" value="" >

	<cfsavecontent variable="BBtoolTip">
			Keyword searches on the following fields:<br />
			<li>#application.returned_customer_setting.shard_ship_to_label# name [Payee]</li>
			<li>#application.returned_customer_setting.shard_ship_to_label# number [Payee]</li>
			<li>Billback Number</li>
			<li>Billback Reference Number</li>
	</cfsavecontent>

	<cfsavecontent variable="DDtoolTip">
			Keyword searches on the following fields:<br />
			<li>#application.returned_customer_setting.shard_ship_to_label# name</li>
			<li>#application.returned_customer_setting.shard_ship_to_label# number</li>
			<li>#application.returned_customer_setting.billto_label# name</li>
			<li>#application.returned_customer_setting.billto_label# number</li>
			<li>Deduction Check Number</li>
			<li>#MCObject.stDeductionLabels["Reference"]#</li>
	</cfsavecontent>

	&nbsp;&nbsp;Filter By Keyword:
	<img src="/images/help_small2.gif" title="#BBtoolTip#" style="cursor:pointer;" id="BBtoolTip">
	<img src="/images/help_small2.gif" title="#DDtoolTip#" style="cursor:pointer;" id="DDtoolTip"><br>&nbsp;
	<input type="text" name="FILTERkeyword" id="FILTERkeyword" size="30" maxlength="40" value="">
	&nbsp;&nbsp;&nbsp;
	<button type="button" id="setFilters" title="Set Filters" class="button recommended">Set Filters</button>
	<br><br>
	</div>
</div>
</cfoutput>

<script>
	$("#setFilters").click(function(){

		if(! $("#FILTERworkItemamount").prop( "checked" )){
			$("#FILTERworkItemamount").val();
		}else{
			$("#FILTERworkItemamount").val('true');
		}
		if(! $("#FILTERdistributor").prop( "checked" )){
			$("#FILTERdistributor").val();
		}else{
			$("#FILTERdistributor").val('true');
		}
		if(! $("#FILTERremainingBalance").prop( "checked" )){
			$("#FILTERremainingBalance").val('');
		}else{
			$("#FILTERremainingBalance").val('true');
		}
		if(! $("#FILTERrefnumber").prop( "checked" )){
			$("#FILTERrefnumber").val('');
		}else{
			$("#FILTERrefnumber").val('true');
		}

		var radioValue = $("input[name='FILTERtype']:checked").val();
		var id = $('#workItemID').val();
		if(radioValue == 2){
			DistributorInfo('DD', id);
			$('#MC_Shr_Ship_to').val('');
			$('#MC_Distributor_Name').val('');
			$('#MC_Bill_To_Name').val('');
			$('#MC_Shr_Bill_To').val('');
			$('#MC_Vendor_ID').val('');
			$('#MC_Vendor_Name').val('');
		}else if(radioValue == 1){
			DistributorInfo('DD', id);
			$("#MC_Distributor_Family_ID").val('');
		}else{
			$('#MC_Shr_Ship_to').val('');
			$('#MC_Distributor_Name').val('');
			$('#MC_Bill_To_Name').val('');
			$('#MC_Shr_Bill_To').val('');
			$('#MC_Distributor_Family_ID').val('');
		}

		if($('#WorkItemType').val() == 'BB'){
			$( "#search" ).val('ded');
			ddLoad();
		}else{
			$( "#search" ).val('bb');
			bbLoad();
		}
	})
</script>