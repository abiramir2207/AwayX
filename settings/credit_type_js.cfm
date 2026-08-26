var arrSelectedCreditTypes = new Array();

<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()>
	function selectAllCreditType(ListCreditType) 
	{
	var arrCreditType = ListCreditType.split(',');
		
		/* check all (checkbox) credit types */
		for (var i = 0; i < DataForm.elements.length; i++ ) {
			if(DataForm.elements[i].name){
				if (DataForm.elements[i].name.indexOf('CreditTypeList') != -1) {

					if (document.getElementById('checkall').checked == true){	
						DataForm.elements[i].checked = true;
					}
					else{
						DataForm.elements[i].checked = false;
					}
				}
			}
		}

		/* Show/Hide the credit types on the main page, i.e. the entries nest to the scissor. */
		for (var i = 0; i < arrCreditType.length; i++ ) {
			showCreditType(arrCreditType[i],document.getElementById('checkall').checked);
		}

		
	}	

	function removeCreditType(arr, item)
	{	
		for(var i = arr.length; i--;) {
			if(arr[i] === item) {
				/* delete the credit type from the array */
				arr.splice(i, 1);
				/* Uncheck the checkbox for the removed credit type */ 
				document.getElementById('CreditTypeList_'+item).checked = false;
			}

		/* The "check All" checkbox should be unchecked as not all credit types are selected. */
		document.getElementById('checkall').checked = false;
		}
	}

	function showCreditType(creditTypeID,checkboxStatus) 
	{
		if(arrSelectedCreditTypes.length == 0)
		{
			/* If there are any saved credit types, then populate the initial list from the "Credit_Type_Select" hidden variable. */
			arrSelectedCreditTypes = document.getElementById('Credit_Type_Select').value.split(',');
		}

		if(checkboxStatus == true){
			/* Show the credit type entry. */
			document.getElementById('ID_Credit_Type_Select_'+creditTypeID).style.display = '';
			/* Add it to the array */
			arrSelectedCreditTypes.push(creditTypeID);
		}
		else{
			/* Hide the credit type entry. */
			document.getElementById('ID_Credit_Type_Select_'+creditTypeID).style.display = 'none';
			/* Remove it from the array */
			removeCreditType(arrSelectedCreditTypes,creditTypeID)
		}
		
		/* The "Credit_Type_Select" hidden value is set here. */
		document.getElementById('Credit_Type_Select').value = arrSelectedCreditTypes.join();
	} 
	</cfif>

	function showHideOptions(){

		var iselectedIndex;

		if(document.all.Growth_Percent_Option){
			iselectedIndex = document.all.Growth_Percent_Option.selectedIndex;
		}
		else if(document.all.Rebate_Percent_Option){
			iselectedIndex = document.all.Rebate_Percent_Option.selectedIndex;
		}
		
		if(iselectedIndex == 0){
			document.getElementById('id_autopay_netdiscount').style.display = '';
			document.getElementById('id_autopay_netfreight').style.display = '';
			document.getElementById('id_autopay_excludecredit').style.display = '';
		}
		else{
			document.getElementById('id_autopay_netdiscount').style.display = 'none';
			document.getElementById('id_autopay_netfreight').style.display = 'none';
			document.getElementById('id_autopay_excludecredit').style.display = 'none';
			
		}

		if(document.all.Auto_Pay_Exclude_Credit_Type[1].checked 
		&& iselectedIndex == 0){
			document.getElementById('id_excludecredit').style.display = '';
		}
		else{
			document.getElementById('id_excludecredit').style.display = 'none';
		}
	}

	showHideOptions(); 
