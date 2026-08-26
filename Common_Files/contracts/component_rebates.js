// JavaScript Documentuom_
var formaction = null
//function get's called on all submits

var nRebateProgress = 0;
var nRebateMaxProgress = 1;
var EZTemplateGlobal = 0;
// D55224 [START]
function hidedProgDiv(){
	if(EZTemplateGlobal == 1){
		$( "#dProg" ).css('display', 'none');
		$( "#dProg" ).html('');
		$( "#dProg" ).dialog( "destroy" );
	}
}

//  D55224 we call the dialog box and then the setTimeout call gives a break in the UI thread so the popup gets displayed.
function submitForm(action, disableClickedButton, disableClickedButtonName, EZTemplate, EZButtonDisable, bProfile_EzButtonApproveBeyondMaxRate, bTemplate_EzButtonEnterBeyondMaxRates, EzButtonMaxRate){
	if (EZTemplate == 1) {
		$("#dProg").css('display', 'block');
		$("#dProg").dialog({
			autoOpen: false,
			modal: true,
			title: "Step 1: Validating Rates",
			width: 400,
			height: 100
		});
		$("#dProg").dialog("open");
	}
		var intervalID = setTimeout(function() { submitForm2(action, disableClickedButton, disableClickedButtonName,EZTemplate,EZButtonDisable,bProfile_EzButtonApproveBeyondMaxRate,bTemplate_EzButtonEnterBeyondMaxRates,EzButtonMaxRate); }, 0);



}

/* Earlier, below logic was inside the "submitForm3" function, but needed to be removed, so that the textboxes with a 0 value can be highlighed with yellow color, before the
confirm box pops up - This issue existed on Chrome.
*/
function submitForm2(action, disableClickedButton, disableClickedButtonName,EZTemplate,EZButtonDisable,bProfile_EzButtonApproveBeyondMaxRate,bTemplate_EzButtonEnterBeyondMaxRates,EzButtonMaxRate)
{
	//check for zeros or no values
	if (!checkZeros()) {
		setTimeout( function () {
			if (!confirm("The highlighted fields have either a value of zero or a negative value. Click Cancel to view them. Click OK to accept them.")) {
					// D55224 [START]
					hidedProgDiv();
					return;
			}
			else{
				submitForm3(action, disableClickedButton, disableClickedButtonName,EZTemplate,EZButtonDisable,bProfile_EzButtonApproveBeyondMaxRate,bTemplate_EzButtonEnterBeyondMaxRates,EzButtonMaxRate);
			}

		 }, 100);
	}
	else{
		submitForm3(action, disableClickedButton, disableClickedButtonName,EZTemplate,EZButtonDisable,bProfile_EzButtonApproveBeyondMaxRate,bTemplate_EzButtonEnterBeyondMaxRates,EzButtonMaxRate);

	}
}

// D55224 [END] RENAME submitForm Also
function submitForm3(action, disableClickedButton, disableClickedButtonName,EZTemplate,EZButtonDisable,bProfile_EzButtonApproveBeyondMaxRate,bTemplate_EzButtonEnterBeyondMaxRates,EzButtonMaxRate)
{

  var thisForm = document.dataForm;
 // D28542
	EZTemplateGlobal = EZTemplate;
  var paid_to = false;
 	var ErrorCount =0;

	if(thisForm.Claim_Mech)
	{
	// This variable is set in Component_Information.cfm. If the component/Claim Mech template setting combo returns nothing,
	//   show this message. The value is set to blank in claim_mech_info.cfm
	//
		if(thisForm.Claim_Mech.value == '')
		{
		alert("Please ask your system administrator to review the configuration settings for the component.  This component does not have any claim mechanics to display.");
		// D55224 [START]
		hidedProgDiv();
		return false;
		}
	}
  var bDisplayMsg = 0;
  var elemColctn = document.getElementsByTagName("tr");
  for (var i = 0; i<elemColctn.length; i++)
	{

    if (elemColctn[i].id.indexOf("compRow_") > -1)
    {
      // if(elemColctn[i].style.backgroundColor != "#DDDDDD")
      // D23266/Anand Rao/-May-2010 VOILA! This works for now. But not sure if we might have to revisit this in the future.
      if(elemColctn[i].style.textDecoration.toString() != 'line-through')
      {
        bDisplayMsg = 1;
      }
    }

  }
  if(bDisplayMsg == 1)
  {
  	if(thisForm.bAllowAddComp && thisForm.bAllowAddComp.value == '0')
  		{
  		alert("This program can only have one discount type. Please remove a discount type.");
  	// return false; // This will be a HARD STOP and we only need an information
  		}
   }



	var donotallowproductsDE = eval("thisForm.donotallowaddproductsDE");
	//ADD ALL PRODUCTS
	if(action == 'addAllProducts')
	{

	}
	//REMOVE PRODUCTS
	else if (action == 'remProd')
	{
		var tmpProd = cycleDataForm('prodChkBx',action);
		var checkSelBox = validateCheckBoxes('prodChkBx');
		var tmpProdArray = tmpProd.split(",");

		//if the list length of the product_list is equal to the prodLen hidden value, then we know there were no products selected
		if (trim(checkSelBox) == "")
		{
			alert("At least one product must be selected to remove.");
			// D55224 [START]
			hidedProgDiv();
			return;
		}
		thisForm.Product_List.value = tmpProd;
	}

	//REMOVE COMPONENTS
	else if (action == 'remComp')
	{
		var tmpComp = cycleDataForm('comp',action);

		if (tmpComp == "")
		{
			alert("At least one component must be selected to remove.");
			// D55224 [START]
			hidedProgDiv();
			return;
		}

		thisForm.comps.value = tmpComp;
	}

	//SORT
	else if (action == 'upc' || action == 'item' || action == 'description' || action == 'GroupID')
	{
		var sortBy = thisForm.sortBy;
		var sortOrder = thisForm.sortOrder;

		//SWITCH FOR EACH SORT
		switch(action)
		{
			case 'upc':
				if (sortOrder.value == 'asc' && sortBy.value == 'upc')
					sortOrder.value = 'desc';
				else
					sortOrder.value = 'asc';

				sortBy.value = 'upc';
				break;

			case 'item':
				if (sortOrder.value == 'asc' && sortBy.value == 'item')
					sortOrder.value = 'desc';
				else
					sortOrder.value = 'asc';

					sortBy.value = 'item';
				break;

			case 'description':
				if (sortOrder.value == 'asc' && sortBy.value == 'description')
					sortOrder.value = 'desc';
				else
					sortOrder.value = 'asc';

				sortBy.value = 'description';
				break;

			case 'GroupID':
				if (sortOrder.value == 'asc' && sortBy.value == 'groupNumber')
					sortOrder.value = 'desc';
				else
					sortOrder.value = 'asc';

				sortBy.value = 'groupNumber';
				break;
		}

	}

	//APPLY VOLUME
	else if (action == 'appVol')
	{
		if (thisForm.volume.value == "")
		{
			alert("Enter a volume to apply.");
			// D55224 [START]
			hidedProgDiv();
			return;
		}

		var tmp = cycleDataForm('prodChkBx',action);

		if (tmp == "")
		{
			alert("At least one product must be selected to apply volume to.");
			// D55224 [START]
			hidedProgDiv();
			return;
		}

		thisForm.applyVol.value = tmp;
	}

	//APPLY RATE FOR EACH PRODUCT/COMPONENT COMBINATION

	else if (action == 'appVolComp')
	{
		var tmpProd = cycleDataForm('prodChkBx',action);
		var tmpComp = cycleDataForm('comp',action);
		var tmpARCheck = cycleDataForm('AR_MassApply_',action);//D38846 ::  Recapture changes
		if (tmpProd == "" || (tmpComp == "" && tmpARCheck  == ""))//D38846 ::  Recapture changes
		{
			alert("At least one product and one component must be selected to apply rate/uom to.");
			// D55224 [START]
			hidedProgDiv();
			return;
		}

		if (thisForm.apply_rate.value == "" && thisForm.uom.value == 0){
			alert("Either a rate has to be entered or a UOM selected.");
			// D55224 [START]
			hidedProgDiv();
			return;
		}

		thisForm.applyVol.value = tmpProd;
		thisForm.comps.value = tmpComp;
	}

	//ADDING COMPONENTS
	else if (action == 'comp'){

		var compLen = thisForm.compLen.value;
		var products = thisForm.Product_List.value;

		/*62343 8.0 - Blended Rate, CF START */
		if(document.dataForm.Prg_Has_Blended_Rate_Comp.value ==1){
			alert("You can only have a single component when selecting blended rate component.");
			return false;
		}
		/*62343 8.0 - Blended Rate, CF END */

		//If it is auto pay, and operator or broker, the vendor id is required.
		//		If it is auto pay and includes distributor and doesn't have id, then let them know
		//		about the manual allocation of vendors on the auto billbacks
		//only bother with any of this if it's auto pay
		if(document.dataForm.Auto_Pay_Status.value == 1)	{
			<!--- They didn't pick a payee --->
			if(document.all.Vendor_Master_ID.value == 0){
				 var OperatorOption = 0;
				 var PayeeOption = 0;

				if (document.dataForm.Component_Paid_To){
					// Determine who the payee is
					for (i=0; i<=document.dataForm.Component_Paid_To.length-1; i++) {
						if (document.dataForm.Component_Paid_To[i].checked == true){
						PayeeOption = i;
						}
					}
						if (PayeeOption == 1 || PayeeOption == 3){
						OperatorOption = 1
						}
				}
				//A vendor needs to be selected if "Select a single payee" option is selected, otherwise the vendor
				//	 needs is required ony if the payee is an operator or has an operator (Customer and Operator option).
				//	 document.all.Vendor_Selection.value will be true for "Select a single payee".
				//	 (It comes from claim_mech_info.cfm)
				//
					 if(document.dataForm.Vendor_Selection.value == 'true'){
					 		if(PayeeOption == 0){
								alert("You must select a vendor for the auto payments.")
								// D55224 [START]
								hidedProgDiv();
								return false;
							}
							else{
								alert("You must select a vendor for auto pay components not payable to distributor")
								// D55224 [START]
								hidedProgDiv();
								return false;
							}
					}
					 else{
							if(PayeeOption == 1 || PayeeOption == 3){
								alert("You must select a vendor for auto pay components not payable to distributor")
								// D55224 [START]
								hidedProgDiv();
								return false;
							}
					 }

				}
			}
	/*62343 8.0 - Blended Rate, CF START */
	if(thisForm.Blended_Rate_On.value == 1){
		var toDate = new Date(document.dataForm.to_date.value);
		var todayDate = new Date(document.dataForm.todays_date.value);
		if(toDate > todayDate){
			alert("End Date cannot be in future.");
			return false;
		}
		if(thisForm.from_date.value== "" || thisForm.to_date.value== "" ){
			alert("Enter Start Date / End Date.");
			return false;
		}
	}
	/*62343 8.0 - Blended Rate, CF END */
	/*48162	Create Product/Rate List ENHANCEMENT        8.0 Release
		//check to see if there are any products
		if (products.length == 0 || products == ""){
			alert("You must select products before adding components.");
			// D55224 [START]
			hidedProgDiv();
			return;
		}
	*/
		<!--- Make sure that the GL Code validation is only for components which have a GL Code --->
					if (document.all.RequireGL.value == 1){
						for (var i=0;i<document.dataForm.length;i++){ // loop through all elements
							var name_=dataForm[i].name; // get element name
							var type_=dataForm[i].type; // get element type
							var GL_Account_Control_Name;
								GL_Account_Control_Name = 'Rebate_GL_Account_ID_'+document.dataForm.compNameId.value;

								if(type_ == 'hidden' && name_== GL_Account_Control_Name){
									GL_Account_Control_value = eval('document.dataForm.Rebate_GL_Account_ID_'+document.dataForm.compNameId.value+'.value');

										if(GL_Account_Control_value != '' && document.dataForm.GL_Account_ID.value == "0"){
											alert("You must select a " + glAccountLabel +" for this component.")//D42774
											// D55224 [START]
											hidedProgDiv();
											return false;
										}
								}
						}
					}

// Paid To Validation   D28542
		for(i=0; i<thisForm.length; i++)	{
			if((thisForm.elements[i].type == "radio") && ( thisForm.elements[i].name=='Component_Paid_To'))	{
				if(thisForm.elements[i].checked){
					var paid_to = true;
				}
			}

		}
		if(!paid_to){
			alert("Please select a paid to.")
			// D55224 [START]
			hidedProgDiv();
			return;
		}
		//limit components to 8
		if (compLen >= maxComponentPossible){
			alert("Only a maximum of " + maxComponentPossible + " component(s) may be applied.");
			// D55224 [START]
			hidedProgDiv();
			return;
		}
		//validate component data
		if (thisForm.compNameId.selectedIndex == 0){
			alert("Please select a component.");
			// D55224 [START]
				hidedProgDiv();
			return;
		}

		//Dont allow the user to add the same component more than twice
		// Initial Count
		var ExistsComponent = 0;
		//ID passed to javascript
		var PassedNumber;
		//alert(window.document.dataForm.comp);
		if(window.document.dataForm.comp){
			 if(window.document.dataForm.comp.length > 1){
				for(i=1; i<= window.document.dataForm.comp.length; i++){
					if(eval("thisForm.compNameId_"+[i]+".value") == thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value)	{
						PassedNumber = parseInt(thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value);
						ExistsComponent = parseInt(ExistsComponent) + PassedNumber;
						// Divide the Passed SelectedIndex ID by the previously Selected Number (Chosen twice)
						if(thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value == ExistsComponent/2)	{
							alert("You cannot add the same component more than twice");
							// D55224 [START]
							hidedProgDiv();
							return false;
						}
					}
				}
			}

		}

		var current_rebate_type_id = 0
		var rebate_type = 0;
		var baseppfound =  false;

		//check to make sure there are no components with the same paid to
		var tmpCompId = thisForm.compNameId.options[thisForm.compNameId.selectedIndex].value;
		current_rebate_type_id = thisForm.compNameId.options[thisForm.compNameId.selectedIndex].rebate_type;
		if(current_rebate_type_id == 1){
		baseppfound = true;
		}
		var tmpPaidTo = 0;
		//check to see what paid to selection is made
		if(thisForm.Component_Paid_To.length){
			if (thisForm.Component_Paid_To[0].checked){
				tmpPaidTo = thisForm.Component_Paid_To[0].value;
			}
			else if (thisForm.Component_Paid_To[1].checked){
				tmpPaidTo = thisForm.Component_Paid_To[1].value;
			}
		}
		else{
			tmpPaidTo = thisForm.Component_Paid_To.value;
		}


		for(i=1; i<= compLen; i++){
			cmpNmeId = eval("thisForm.compNameId_"+[i]+".value");
			pdTo = eval("thisForm.compPaidTo_"+[i]+".value");
			rebate_type = eval("thisForm.rebate_type_"+[i]+".value");
			if (rebate_type == 1){
				 baseppfound =  true;
			}
			if(current_rebate_type_id == 1){
				if(current_rebate_type_id == rebate_type){
					alert("Only one Base Price Protection component can be added");
					// D55224 [START]
					hidedProgDiv();
					return;
				}
			}
			if(current_rebate_type_id == 2){
				if(current_rebate_type_id == rebate_type){
					alert("Only one Price Protection Increase component can be added");
					// D55224 [START]
					hidedProgDiv();
					return;
				}
			}

			// if program created from EZ Template page, make sure the same component is not added with the different paid to.
			if ((EZButtonDisable == 1 || EZTemplate == 1) && tmpCompId == cmpNmeId){
				alert("You cannot add the same component more than once.");
				// D55224 [START]
				hidedProgDiv();
				return;
			}
			//if the component and paid to combination already exists then show an alert
			if (tmpCompId == cmpNmeId && tmpPaidTo == pdTo){
				alert("A component with this Paid To already exists. Please change the Paid To or select another component.");
				// D55224 [START]
				hidedProgDiv();
				return;
			}
		}
		//if the component is a PP increase Component...do validate the rate as it should be 0
		if(current_rebate_type_id == 2){
			var ratevalue = trim(thisForm.rate.value);
			if(ratevalue != ""){
				ratevalue = "";
			}
			if(ratevalue != ""){
				alert("PP Increase component cannot have rate other than 0.");
				// D55224 [START]
				hidedProgDiv();
				return;
			}

		}

		//if the component is a PP increase Component...do not validate the rate as it will be 0
		//if the component is a USDA NOI Component...do not validate the rate as it will be empty

		if(thisForm.compNameId.options[thisForm.compNameId.selectedIndex].is_usda_comp == 0 && (current_rebate_type_id != 2) && EZButtonDisable == 0 && thisForm.txtPercentage.value != 'undefined'  && thisForm.txtPercentage.value == "") {

			if (!validateNoVal(thisForm.rate.value, "Please provide a default rate.\n(You can edit rate for each item.)")) {
				// D55224 [START]
				hidedProgDiv();
				return;
			}
		}

		if(compLen == 0)	{
			if (current_rebate_type_id == 2){
				alert("Please add a Base Price Protection Component first");
				// D55224 [START]
				hidedProgDiv();
				return;
			}
		}

		if(compLen > 0){
			if (current_rebate_type_id == 2 && baseppfound == false){
				alert("Please add a Base Price Protection Component first");
				// D55224 [START]
				hidedProgDiv();
				return;
			}
		}

	//	if(current_rebate_type_id == 2) //|| EZButtonDisable == 1 // Check this and revert to this if there is an error in the below condition.
	if(current_rebate_type_id == 2 || ((EZButtonDisable == 1) && (EzButtonMaxRate == 0))){
			thisForm.rate.value = "";
		}

		// validate if a basis code and treatment code is selected
		var treatmentCodeObj = thisForm.Treatment_Code;
		if(treatmentCodeObj)	{
			if(treatmentCodeObj.selectedIndex <= 0){
				alert("Please select a treatment code");
				// D55224 [START]
				hidedProgDiv();
				return;
			}
		}
		var basisCodeObj = thisForm.Basis_Code;
		if(basisCodeObj){
			if(basisCodeObj.selectedIndex <= 0){
				alert("Please select a basis code");
				// D55224 [START]
				hidedProgDiv();
				return;
			}
		}

	}//END ADDING COMPONENTS

	//SAVE
	else if (action == 'save' || action == 'updSave'){
		//get the number of products and components
		var compLen = thisForm.compLen.value;
		var prodLen = thisForm.prodLen.value;
		var currentProdLen = 0;

		/* If a user deletes or undeletes a product using scissors, then "thisForm.Product_List.value" has the updated list of undeleted products.
		The code below is getting the product count.
		 */
		if(thisForm.Product_List.value == ''){
			currentProdLen = 0;
		}
		/* If a user deletes or undeletes a product using scissors, then "currentProdLen" variable will accordingly adjust, as "thisForm.Product_List.value"
		has the updated list of undeleted products. "prodLen" variable does not adjust when a product is deleted or undeleted using scissors.
		*/
		else{
			currentProdLen = listLength(thisForm.Product_List.value,",")
		}

		var baseppfound = false;
		var increaseppfound = false;

		if (!validateGroups()){
			// D55224 [START]
			hidedProgDiv();
			return;
		}
		if (!validateGroupsDefaultCheckBoxes()){
			// D55224 [START]
			hidedProgDiv();
			return;
		}
		if (!validateProductsUnderGroupAtLevel1(document.dataForm)){
			// D55224 [START]
			hidedProgDiv();
			return;
		}

		//check to make sure the sum of a products components isn't zero
		//if (!checkCompSums(prodLen,compLen))
		//{
			//alert("The highlighted items do not have any rates for any components.\nPlease remove the item or provide a rate for at least one component.");
			//alert("Some of the item/component combinations do not have a rate assigned to them.\nPlease remove the item or provide a rate for at least one component.");
			//return;
		//}
		//check to make sure that if a product exists, then a component exists with it... or vice versa.
		if (EZTemplate == 0 && ((compLen == 0 && currentProdLen > 0 ) || (currentProdLen  == 0 && compLen > 0)) && document.getElementsByName("IMG_Delete_Scissor")[0].getAttribute('bDelete') )	{
			alert("The rebate must contain at least one product and one component.");
			// D55224 [START]
			hidedProgDiv();
			return;
		}

		for(i=1; i<= compLen; i++){
		var rebate_type = eval("thisForm.rebate_type_"+[i]+".value");
		if (rebate_type == 1){
				 baseppfound =  true;
			}
		if (rebate_type == 2){
				 increaseppfound =  true;
			}
		}

		//verify component names
		//if (!checkCompNames("Please make sure all components have a name."))
			//return;
		if (!checkAltRecapGtRebate() ){
			alert("Alternate Recapture rates cannot be > the Rebate rate.");
			// D55224 [START]
			hidedProgDiv();
			return;
		}

		if (!checkScanVolume()) {
			// D55224 [START]
			hidedProgDiv();
			return;
		}
		//check to see if rules have to be applied
		if(bApplyRule()){
			if (donotallowproductsDE.value == 1){
				if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))	{
					thisForm.deletedateexclusions.value = 1;
					NewWindow("apply_rebate_rule_popup.cfm?uriLocation=" + thisForm.sessionFile.value + "&contract_Main_Id=" + thisForm.DTPS_Program_ID.value + "&compUUID=" + thisForm.compUUID.value, "productwindow", 800, 600, "yes", "yes");
					// D55224 [START]
					hidedProgDiv();
					return;
				}
			}
			else{
				NewWindow("apply_rebate_rule_popup.cfm?uriLocation=" + thisForm.sessionFile.value + "&contract_Main_Id=" + thisForm.DTPS_Program_ID.value + "&compUUID=" + thisForm.compUUID.value, "productwindow", 800, 600, "yes", "yes");
				// D55224 [START]
				hidedProgDiv();
				return;
			}
		}


	}

	//set the action value then submit
	thisForm.action.value = action;
	formaction = action;

	if (thisForm.action.value == 'save' || action == 'comp'){
	//*************** check payment cycle ********************
	var oPaymentSelect = eval("document.all.PaymentCycle");
		if(oPaymentSelect) {
			oPaymentSelect.value = oPaymentSelect.value;
		} else {
			oPaymentSelect.value = 0;
		}

	if(oPaymentSelect.value == "0") {
			alert("Select a payment cycle");
			// D55224 [START]
			hidedProgDiv();
			return;
		}

	//*************** check payment cycle ********************

	document.all.navigate.value = 0;
	}
	else{
	document.all.navigate.value = 1;
	}

	//alert(donotallowproductsDE.value);
	var shouldSubmitForm = 1;

	if (donotallowproductsDE.value == 1 && (action == 'save' || action == 'updSave' )){

		if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
		{thisForm.deletedateexclusions.value = 1;
		var price_protection = eval("thisForm.Price_Protection_on.value");

		/*
		if(baseppfound == false && price_protection == 1)
		{
			alert("Please add base price protection component");
			return;
		}
		if(increaseppfound == false && price_protection == 1)
		{
			alert("Please add price protection increase component");
			return;
		}
		*/

    	if (!checkMinMax(compLen,prodLen)){
      		if(confirm("Fields highlighted yellow are below the minimum value. Fields highlighted red are above the maximum. Press ok to continue anyway or cancel to fix the entries."))
			{
			  var shouldSubmitForm = 1;
			}
			else{
			  // D55224 [START]
				hidedProgDiv();
			  return;
			}
		}
		else{
			var shouldSubmitForm = 1;
		}
	}
	}
	else{

		var price_protection = eval("thisForm.Price_Protection_on.value");
		/*  25700 Price Protection
		if(baseppfound == false && price_protection == 1)
		{
			alert("Please add base price protection component");
			return;
		}
		*/
		/*  25700 Price Protection
		if(increaseppfound == false && price_protection == 1)
		{
			alert("Please add price protection increase component");
			return;
		}
		else
		{
		*/

		if (!checkMinMax(compLen,prodLen))	{
    		if(confirm("Fields highlighted yellow are below the minimum value. Fields highlighted red are above the maximum. Press ok to continue anyway or cancel to fix the entries.")){
				var shouldSubmitForm = 1;
			}
			else{
				// D55224 [START]
				hidedProgDiv();
				return;
			}
		}
		else{
			var shouldSubmitForm = 1;
		}
    // 21553

	if (thisForm.bDoCheckMaxVal && thisForm.bDoCheckMaxVal.value == 1&& action != "appVolComp"){
  		var compLen = thisForm.compLen.value;
		var prodLen = thisForm.prodLen.value;
    	var tmpltCompLen = thisForm.tmpltCompLen.value;
    	var tmpltProdLen = thisForm.tmpltProdLen.value;
     	var oPageNum = document.getElementById("curPageNum");
     	var prodNumInt = 1;
     /*  this piece of code will clear out all the error message
       before setting them */
      	var aSpans = document.body.getElementsByTagName("span");
       	var strSpanName = "";

      	for (var i = 0; i < aSpans.length; i++){
        	strSpanName = (aSpans[i].id).substring(0,6);
        	if (strSpanName == 'error_')	{
          		clearQueue(aSpans[i]);
          		aSpans[i].style.display = 'none';
        	}
      	}

    	if(oPageNum.value > 1){
		  	prodNumInt	= ((oPageNum.value - 1) * 100) + 1;
		}
  	// var rateVal = eval("thisForm.comp_rate_" + aProdUom[n] + ".value");
    	for (var i = prodNumInt; i<=prodLen; i++){
      		for (var n = 1; n<=compLen; n++){
        		var tmpItemId = i + "_" + n;
        		var tmpTmpltID = i + "_" + n + "_Tmplt";
        		BasisCodeTypeId = 0;
        		var ObjBasisCodeType = document.getElementById("basisCodeType_" + tmpItemId);

        		// clearQueue(eval("document.all.error_" + i +"_" + n));
   				if(ObjBasisCodeType){
					if(ObjBasisCodeType.value != "0"){
					 	BasisCodeTypeId = 1;
				  	}
			  	}

        		if(BasisCodeTypeId == "0"){
				  var oInp = document.getElementById(tmpItemId);
				  if(oInp){
				    var inpVal = parseFloat(document.getElementById(tmpItemId).value);
				    var inpTmpltVal = parseFloat(document.getElementById(tmpTmpltID).value);

					if (bTemplate_EzButtonEnterBeyondMaxRates == 1){
	         			clearQueue(eval("document.all.error_" + i +"_" + n));
              			eval("document.all.error_" + i +"_" + n).style.display = 'none';
					}
            		else{
						if(inpVal > inpTmpltVal){
				            ErrorCount++;
				            clearQueue(eval("document.all.error_" + i +"_" + n));
			  	          	eval("document.all.error_" + i + "_" + n).style.display = '';
			    	        queueMessage("This value is greater than the template Rate of: "+ inpTmpltVal , eval("document.all.error_" + i +"_" + n));
			            }
			            else{
			            	clearQueue(eval("document.all.error_" + i +"_" + n));
			              	eval("document.all.error_" + i +"_" + n).style.display = 'none';
			            }
		            }


          } //  if(oInp)
        } //  if(BasisCodeTypeId == "0")
      }  // for (var n = 1; n<=compLen; n++)
    }    // for (var i = prodNumInt; i<=prodLen; i++)

  } // END if (thisForm.bDoCheckMaxVal.value == 1)

  if(ErrorCount != 0){
	  showMessageWindow();
	// D55224 [START]
	hidedProgDiv();
    return;
  }
  else{
      var shouldSubmitForm = 1;
  }
  // 21553 Ends
 		if (shouldSubmitForm = 1){

			if(typeof enableDisableIncludeComponentLink == 'function'){
				enableDisableIncludeComponentLink(false);
			}
             // D55224 [START]
			hidedProgDiv();
			//disableButton("bSaveRates","true");

				disableButton("pageLink","true");
				disableClass(".bSaveRates","true");
				disableClass(".bAddProdGroups","true");
				disableClass(".contractLinks","true");
				disableClass(".massApplyLink","true");
				disableClass(".imgDeleteScissor","true");

			//disableButton("rebateSave","true");
			if(EZTemplate == 1){
				$( "#dialog" ).dialog({ autoOpen: false,
  							modal: true,
							title: 'Step 2: Saving Data',
							width: 400,
							height:100
							 });

			   $( "#dialog" ).dialog( "open" );
				ColdFusion.ProgressBar.start("rebateSaveProgress");
			}

			// D55224 [END]
		// COMENTED OUT D55224
		//	processingPopUpDisplay('div.customContainer');//D51575
			
			thisForm.submit();
			show_loader( "PLEASE WAIT...");

			if(disableClickedButton){
					disableButton(disableClickedButtonName, true, false);
				}
			}

//		}     25700 Price Protection
/*		thisForm.action.value = action;
		thisForm.submit();
			if(disableClickedButton)
				{
					disableButton(disableClickedButtonName, true, false);
				}
*/
	}

}
//end submitForm function

//function to determine if rules have to be applied
function bApplyRule()
{

	var thisForm = document.dataForm;
	var rApplyRule = false;
	var hasRules = true;
	var compIndx = thisForm.compLen.value;
	var prodIndx = thisForm.prodLen.value;

	for (var i = 1; i<=compIndx; i++)
	{
		var tmpComp = eval("thisForm.compHasRules_" + i + ".value");
		var tmpCompUoms = eval("thisForm.lCompRuleUoms_" + i + ".value");
		var tmpReqRules = eval("thisForm.compRulesReq_" + i + ".value");

		//if a components has rules then we have to check for the uom for that product/components combination
		if (tmpComp == 1 && tmpReqRules == 0)
		{
			var uomSelToCheck = eval("thisForm.uomsToCheck_" + i + ".value");
			var bRequired = eval("thisForm.compRulesReq_" + i + ".value");

			//split the list of product/component combination values
			var aProdUom = uomSelToCheck.split(",");
			var aCompUoms = tmpCompUoms.split(",");

			//now loop through and find if any of the uom's are percent. if they are, then return true
			for (n =0; n<aProdUom.length;n++)
			{

				var rebRule = eval("thisForm.reb_rule_" + aProdUom[n] + ".value");
				var rateVal = eval("thisForm.comp_rate_" + aProdUom[n] + ".value");
				var uomSelected = eval("thisForm.uom_" + aProdUom[n] + ".value");
				//if the uom is in the list, then return true
				for (num=0; num<aCompUoms.length;num++)
				{
					if (uomSelected == aCompUoms[num] && rateVal > 0)
					{
						if(trim(rebRule) == "" && bRequired == 1)
						{
							hasRules = false;
						}

						rApplyRule = true;

					}
				}
			}

		}
	}

	//if rules already exist then give the option to modify
	if(hasRules && rApplyRule)
	{
		if (!confirm("Click OK to modify Business Rules. Click Cancel to continue."))
		{
			rApplyRule = false;
		}
	}

	return rApplyRule;

}//end bApplyRule function


//function to get checkboxes in the rebates dataform
function cycleDataForm(elem,action)
{

	var elemVal = "";
	var elemColctn = document.dataForm.getElementsByTagName("input");

    for (var i = 0; i<elemColctn.length; i++)
	{
		if ((elemColctn[i].name.indexOf(elem) > -1))
		{
			if (action == 'remProd')
			{
          		if (!elemColctn[i].checked)
				{
					elemVal = listAppend(elemVal,elemColctn[i].value);
            	}//end if
			}//end if
			else
			{
				if (elemColctn[i].checked)
				{
					elemVal = listAppend(elemVal,elemColctn[i].value);
            	}//end if
			}//end else
		}//end if
	}//end for

	return elemVal;

}//end cycleDataForm function

//function to check and see if any check boxes are selected for a particular element
function validateCheckBoxes(elem)
{

	var elemVal = "";
	var elemColctn = document.dataForm.getElementsByTagName("input");

    for (var i = 0; i<elemColctn.length; i++)
	{
		if ((elemColctn[i].name.indexOf(elem) > -1))
		{
			if (elemColctn[i].checked)
			{
				elemVal = listAppend(elemVal,elemColctn[i].value);
            }//end if
		}//end else
	}//end for

	return elemVal;

}//end validateCheckBoxes function

//function error checks for the sum of each component
function checkCompSums(prodLen,compLen)
{

	bCompSumValid = true;

	//loop through for each product component combination and sum values for each product
	for (var i = 1; i<=prodLen; i++)
	{
		var compTotl = 0;
		for (var n = 1; n<=compLen; n++)
		{
			var tmpId = i + "_" + n;
			var inpVal=parseFloat(document.getElementById(tmpId).value);
			compTotl = compTotl += inpVal;
		}

		if (!compTotl > 0)
		{
			bCompSumValid = false;
			var compRowId = "compRow_" + i;
			var compRow = document.getElementById(compRowId);
			//compRow.style.backgroundColor = "#FF0000";
		}

	}

	return bCompSumValid;

}//end checkCompSums function

//function error checks for zero or no values in data form
function checkZeros(prodLen,compLen)
{
	var elemColctn = document.dataForm.getElementsByTagName("input");
	var isOk = true;
	var basisCodeType;
	var r = 0;
    for (var i = 0; i<elemColctn.length; i++)
	{
		nRebateProgress = i;
		nRebateMaxProgress = elemColctn.length;
		var n= nRebateProgress/nRebateMaxProgress;
		var s =  (n*100).toPrecision(3) + '%';
		basisCodeType = "0";
		//if ((elemColctn[i].name.indexOf("volume_") > -1) || (elemColctn[i].name.indexOf("comp_rate_") > -1))
    /*
      D23266/Anand Rao/04-May-10 added the condition to also check for the _Tmplt to fix the issue
      so the user won't get alert saying the value is 0 for the hidden input controls.
    */
////D38536  :: Alternate recapture rates per component
		if (((elemColctn[i].name.indexOf("comp_rate_") > -1) || (elemColctn[i].name.indexOf("ARR_") > -1)) && (elemColctn[i].name.indexOf("_Tmplt") == -1))
		{

			if(elemColctn[i].basisCodeType)
			{
				basisCodeType = elemColctn[i].basisCodeType;
			}
			if(elemColctn[i].value <= 0 && basisCodeType == "0")
			{
				if(elemColctn[i].style.backgroundColor != "#dddddd"){
         		   elemColctn[i].style.background = '#FFFF00';
				  isOk = false;
        }
			}
		}
    }

	return isOk;
}//end checkZeros function


function checkAltRecapGtRebate()
{
	var elemColctn = document.dataForm.getElementsByTagName("input");
	var isOk = true;
	var r = 0;
    for (var i = 0; i<elemColctn.length; i++)
	{

////D38536  :: Alternate recapture rates per component
		if (((elemColctn[i].name.indexOf("comp_rate_") > -1) || (elemColctn[i].name.indexOf("ARR_") > -1)) && (elemColctn[i].name.indexOf("_Tmplt") == -1) && (elemColctn[i].name.indexOf("UOM") == -1))
		{
			//store rebate rate to check the Alternate recapture rate
			if (elemColctn[i].name.indexOf("comp_rate_") > -1){
				r = elemColctn[i].value;
			}
			//if it is Alternate, check it

			if (elemColctn[i].name.indexOf("ARR_") > -1 && Number(elemColctn[i].value) > Number(r) && elemColctn[i].value != 0){
				 if (elemColctn[i].style.backgroundColor != "#dddddd") {
				 	elemColctn[i].style.background = 'red';
				 	isOk = false;
				 }
			}
		}
    }

	return isOk;
}//end checkZeros function

 //function error checks for zero or no values in data form
function checkScanVolume(prodLen,compLen)
{

	var elemColctn = document.dataForm.getElementsByTagName("input");
	var isOk = true;
	var isScan;
    for (var i = 0; i<elemColctn.length; i++)
	{
		if (elemColctn[i].name.indexOf("comp_scan_volume_") > -1)
		{
			if(elemColctn[i].value <= 0)
			{
				elemColctn[i].style.background = '#FFFF00';
				isOk = false;
			}
		}
    }
	if (isOk == false)
	{
	alert("Scan volume (highlighted yellow) must be greater than 0 in order to save.")
	}
	return isOk;

}//end checkScanVolume function

//function checks for minimum and maximum values
function checkMinMax(compLen,prodLen)
{
	var isOk = true;
	var BasisCodeTypeId;
	//loop through for each product component combination and sum values for each product
	//Handle for paging.  Only 100 prods at a time are displayed, but the prodlen still equals Total prod count
	var prodNumInt = 1;
	if(document.getElementById("curPageNum"))
	{
		var oPageNum = document.getElementById("curPageNum");
		if(oPageNum.value > 1)
		{
			prodNumInt	= ((oPageNum.value - 1) * 100) + 1;
		}
	}

	var oCompUOM = document.getElementById("c_uom_" + prodNumInt + "_1");

	if (!oCompUOM)
		return isOk;
	for (var i = prodNumInt; i<=prodLen; i++)
	{
		for (var n = 1; n<=compLen; n++)
		{
			var tmpId = i + "_" + n;

			BasisCodeTypeId = 0;
			var ObjBasisCodeType = document.getElementById("basisCodeType_" + tmpId);
			if(ObjBasisCodeType)
			{
				if(ObjBasisCodeType.value != "0")
				{
					BasisCodeTypeId = 1;
				}
			}

			/* if BasisCodeTypeId = 1 means the rebate is buy x get y free, and in this case the rate fiel will be calculated only before doing margin.
			so rate value is not available at this point.*/
			if(BasisCodeTypeId == "0")
			{
				var oInp = document.getElementById(tmpId);
				if(oInp)
				{
				var inpVal = parseFloat(document.getElementById(tmpId).value);
				var inpName = document.getElementById(tmpId);
				var inpUOM = parseFloat(document.getElementById("c_uom_" + tmpId).value);
				var inputNameSuffix = inpName.name;
					   inputNameSuffix = inputNameSuffix.replace(/comp_rate_/g , "");
				var EAConversion = eval("document.all.EAConversion_" + inputNameSuffix + ".value");
				var Sleeves_Per_Case = eval("document.all.Sleeves_Per_Case_" + inputNameSuffix + ".value");
				var inventoryUM = eval("document.all.productInventoryUOM_" + inputNameSuffix + ".value");
				var netWeight = eval("document.all.net_weight_" + inputNameSuffix + ".value");

				//inpName.style.background = 'white';

				if((document.dataForm.ThereisMinorMax.value == 1)  && (inpVal != "NaN") && (inpName.disabled == false))
				{
		/*
				switch (inpUOM)
					{
					case 1:
					if(document.dataForm.Min_Rebate_Case.value != 0 and document.dataForm.Min_Rebate_Case.value != '')
						{
					  if(inpVal < document.dataForm.Min_Rebate_Case.value)
							{
								inpName.style.background = 'yellow'
								isOk = false;
							}
					  else if(inpVal > document.dataForm.Max_Rebate_Case.value)
							{
								inpName.style.background = 'red'
								isOk = false;
							}
						}
					  break
					case 2:
					if(document.dataForm.Min_Rebate_Pound.value != 0 and document.dataForm.Min_Rebate_Pound.value != '')
						{
					  if(inpVal < document.dataForm.Min_Rebate_Pound.value)
							{
								inpName.style.background = 'yellow'
								isOk = false;
							}
					  else if(inpVal > document.dataForm.Max_Rebate_Pound.value)
							{
								inpName.style.background = 'red'
								isOk = false;
							}
						}
					  break
					case 3:
					if(document.dataForm.Min_Rebate_Case.value != 0 and document.dataForm.Min_Rebate_Case.value != '')
						{
					  if(inpVal < document.dataForm.Min_Rebate_Percent.value)
							{
								inpName.style.background = 'yellow'
								isOk = false;
							}
					  else if(inpVal > document.dataForm.Max_Rebate_Percent.value)
							{
								inpName.style.background = 'red'
								isOk = false;
							}
						}
					}*/
/* OLD Logic in If statements*/


					if(inpUOM == 6) { //CWT
						inpUOM = 2;
						inpVal = inpVal / 100.00;
					}
					else if(inpUOM == 5 || inpUOM == 7) { // 76541 Eaches  & 82429
						inpUOM = 1;
						if(inpUOM == 5){
							inpVal = inpVal * EAConversion;
						}else{
							inpVal = inpVal * Sleeves_Per_Case;
						}
						if(inventoryUM == "LB"){
							inpUOM = 2;
							inpVal = inpVal / netWeight;
						}
					}
					
					if(document.dataForm.Min_Rebate_Case.value != 0 && inpUOM == 1)
						{
							if(inpVal < document.dataForm.Min_Rebate_Case.value)
							{
								if(inpName.style.backgroundColor != "#dddddd")
                {
                  inpName.style.background = 'yellow'
								  isOk = false;
                }
							}
						}

						if(document.dataForm.Max_Rebate_Case.value != 0 && inpUOM == 1)
						{

							if(inpVal > document.dataForm.Max_Rebate_Case.value)
							{
                  if(inpName.style.backgroundColor != "#dddddd")
                  {
                    inpName.style.background = 'red'
								    isOk = false;
                  }
							}
						}

					if(document.dataForm.Min_Rebate_Pound.value != 0 && inpUOM == 2)
						{
							if(inpVal < document.dataForm.Min_Rebate_Pound.value)
							{
								if(inpName.style.backgroundColor != "#dddddd")
                {
                  inpName.style.background = 'yellow'
								  isOk = false;
                }
							}
						}

						if(document.dataForm.Max_Rebate_Pound.value != 0  && inpUOM == 2)
						{

							if(inpVal > document.dataForm.Max_Rebate_Pound.value)
							{
								if(inpName.style.backgroundColor != "#dddddd")
                {
								  inpName.style.background = 'red'
  								isOk = false;
                }
							}
						}

					if(document.dataForm.Min_Rebate_Percent.value != 0  && inpUOM == 3)
						{
							if(inpVal < document.dataForm.Min_Rebate_Percent.value)
							{
								if(inpName.style.backgroundColor != "#dddddd")
                {
  								inpName.style.background = 'yellow'
	  							isOk = false;
                }
							}
						}

						if(document.dataForm.Max_Rebate_Percent.value != 0  && inpUOM == 3)
						{
							if(inpVal > document.dataForm.Max_Rebate_Percent.value)
							{
								if(inpName.style.backgroundColor != "#dddddd")
                {
                  inpName.style.background = 'red'
	  							isOk = false;
                }
							}
						}

				}
				}//if oInp exists
			}//basis code type
		}//component
	}//product

	return isOk;
}//end checkMinMax function


//function sets all product checkboxes to checked
function checkAllProd()
{
	var elemColctn = document.dataForm.getElementsByTagName("input");

	for (var i = 0; i<elemColctn.length; i++)
	{
		if ((elemColctn[i].name.indexOf('prodChkBx') > -1))
		{
			if (elemColctn.prodCheck.checked)
				elemColctn[i].checked = true;
			else
				elemColctn[i].checked = false;
        }
    }
}//end checkAllProd function

//function to set all products checkboxes of same type_code to checked
function checkMatchingProd(type_code,header)
{
	var elemColctn2 = document.dataForm.getElementsByTagName("input");
	for (var i = 0; i < elemColctn2.length; i++)
	{
		if (elemColctn2[i].id == type_code)
		{
			if (header.checked)
				elemColctn2[i].checked = true;
			else
				elemColctn2[i].checked = false;
		}
	}
}
//end check checkmatchingProd()



function addGroupsLevelProducts(groupLevel, groupId)
{
	if(window.confirm('Do you want to add all the products?'))
	{
		if(groupLevel != 0)
		{
			var groupIdListObj = eval("document.all.Product_Level_" + groupLevel);
			groupIdListObj.value = groupId;
			submitForm('addGroupProducts');
		}
	}
}

//function error checks null values
function validateNoVal(value,message)
{

	var isValid = true;

	if (trim(value) == "")
	{
		alert(message);
		isValid = false;
	}
	return isValid;
}//end validateNoVal function


//function error checks component names
function checkCompNames(message)
{
	var isNotEmpty = true;
	var elemColctn = document.dataForm.getElementsByTagName("input");

	for (var i = 0; i<elemColctn.length; i++)
	{
		if ((elemColctn[i].name.indexOf("compName_") > -1))
		{
			if (!validateNoVal(elemColctn[i].value,message))
				isNotEmpty = false;
		}
    }

	return isNotEmpty;
}//end checkCompNames function

//listAppend function
function listAppend(list, value)
{

	if (list == "")
	{
		list += value;
		return list;
	}
	else
	{
		list += "," + value;
		return list;
	}
}//end listAppend function

//check navigate
		function resetnavigate()
		{
			document.all.navigate.value = 1;
		}
		function verifyNavigate() {
		if(formaction == null)
		{
			if (document.all.navigate.value == 1 && document.all.stopnavigate.value == 0) {
				{
					event.returnValue="Your changes will not be saved if you click OK";
			}
		}	}
		}

//if the selected component name is a usda compoonent....disable the rate box
function  disableRateBox(oSelect) {
	oOpt = oSelect.options[oSelect.selectedIndex]
	if(oOpt.is_usda_comp == 1) {
		document.all.rate.value = '';
		document.all.rate.readOnly  = true;
	}
	else {
		document.all.rate.readOnly  = false;
	}
}

//if the selected component name is a scan component, then allow EA as a UOM
function  addRemoveUom(oSelect) {
	var oOpt = oSelect.options[oSelect.selectedIndex]
	var uomObj = document.all.uom;
	var EAopt = Get_Object_Property_Match_Collection(uomObj.options, "value", "5")
	if(oOpt.rebate_type == 4) {
		if(EAopt) //object already exist
		{
		}
		else
		{
			EAopt = new Option("EA", "5")
		    uomObj.add(EAopt);
		}

	}
	else {
		if(EAopt) //object already exist
		{
			uomObj.remove(EAopt.index);
		}
	}
}

//validate groups
function  validateGroups()
{

	var thisForm = document.dataForm;
	var numberOfLevels = thisForm.numberOfLevels.value; 
	var level1 = thisForm.Level_1.value;
	var level2 = thisForm.Level_2.value;
	var level3 = thisForm.Level_3.value;

	var bIsValid= true;

	if(numberOfLevels == 3){
		//validate group levels
		//if we have something in level 2 or level 3 make sure something is in level 1
		if (trim(level2) != "" || trim(level3) != "" )
		{
			if(trim(level1) == "")
			{
				alert(Pricing_Level_1_Desc + " cannot be empty if Groups or Products exist in " + Pricing_Level_2_Desc + " or " + Pricing_Level_3_Desc + ".");
				bIsValid = false;
				return bIsValid;
			}
		}

		//if we have something in level 3 make sure something is in level 1 and 2
		if (trim(level3) != "")
		{
			if(trim(level2) == "")
			{
				alert(Pricing_Level_2_Desc + " cannot be empty if Groups or Products exist in " + Pricing_Level_3_Desc + ".");
				bIsValid = false;
				return bIsValid;
			}
			else if(trim(level1) == "")
			{
				alert(Pricing_Level_1_Desc + " cannot be empty if Groups or Products exist in " + Pricing_Level_2_Desc + " or " + Pricing_Level_3_Desc + ".");
				bIsValid = false;
				return bIsValid;
			}
		}

		//if we have something in level 2 make sure something is in level 1
		if (trim(level2) != "")
		{
			if(trim(level1) == "")
			{
				alert(Pricing_Level_1_Desc + " cannot be empty if Groups or Products exist in " + Pricing_Level_2_Desc + ".");
				bIsValid = false;
				return bIsValid;
			}
		}
	} // if(numberOfLevels == 3)

	return bIsValid;
}

function isDefined(item) {
    return (typeof item != 'undefined');
}
