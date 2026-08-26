/* Note: Similar code exists on "program_wizard\select_components.cfm".
Code change here may require a code change on that file too.
"program_wizard\select_components.cfm" loops through components and
"program_wizard\component_select_templates_grid_js.js" loops through templates.
This file gets used in the component section for all the discount types.
*/
function checkData(ObjDiscountTypeId, compId)
{

var ObjListPaidToTypes = document.all.listPaidToTypes.value.split(",");
var anyItemChecked,ObjComponents,ObjErr,ObjError,
	anySelected,allGood, i, j

var  ObjListPaidToType, compLen, templateID;
var selectedDefaultOption = 0;
var selectedDefaultCFpagesOption = 0;
var ObjErrorDefPaidTo = 0;
var ObjErrorDefPaidToCFPages = 0;
var selectedComponentPaidTo;
var selectedDefaultComponentPaidTo = 0;

reset_filters();

anyItemChecked = 0;
allGood = true;
ObjComponents = eval("document.all.Template_Select_" + ObjDiscountTypeId);
ObjErr = eval("document.all.Err_template_name_" + ObjDiscountTypeId);
anySelected = Any_Object_Checked(ObjComponents);

	clearQueue(ObjErr);

	if(ObjComponents)
	{
	compLen = ObjComponents.length;
	if(compLen)
	{
	for(j=0;j<compLen;j++)
	{
		templateID = eval("document.all.Template_Select_" + ObjDiscountTypeId)[j].value;
		ObjError = eval("error_Template_Paid_To_Select_" + ObjDiscountTypeId+ "_" + templateID);
		selectedComponentPaidTo = 0;
		selectedDefaultComponentPaidTo = 0;

		/* If the template has been "included". */
		if(eval("document.all.Template_Select_" + ObjDiscountTypeId)[j].checked == true){
			var checkedPaidTo = false;
			var SelectedDefaultPaidToOptionIsOn = false;

			/* If "Default Rates Grid" select box exists  */
			if(typeof(eval("document.all.Template_Paid_To_Default_Rates_Grid_" + ObjDiscountTypeId)) != "undefined"){
				ObjErrorDefPaidTo = eval("error_Template_Paid_To_Default_" + ObjDiscountTypeId+ "_" + templateID);
				selectedDefaultOption = eval("document.all.Template_Paid_To_Default_Rates_Grid_" + ObjDiscountTypeId);
				selectedDefaultComponentPaidTo =  selectedDefaultOption[j].value.split("_")[1];
			}


			if(selectedDefaultComponentPaidTo == 0){
				/* If "Default "discount type" select box exists */
				if(typeof(eval("document.all.Template_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId)) != "undefined"){
					ObjErrorDefPaidTo = eval("error_Template_Paid_To_Default_" + ObjDiscountTypeId+ "_" + templateID);
					selectedDefaultOption = eval("document.all.Template_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId);
					selectedDefaultComponentPaidTo =  selectedDefaultOption[j].value.split("_")[1];
					ObjErrorDefPaidToCFPages = eval("error_Template_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId+ "_" + templateID);
				}
			}

			if(ObjListPaidToTypes){
				ObjListPaidToLen = ObjListPaidToTypes.length;
				for(m=0;m<ObjListPaidToLen;m++){
					ObjListPaidToType = ObjListPaidToTypes[m];

						if(eval("document.all.Template_Paid_To_Select_" + ObjDiscountTypeId + "_" + ObjListPaidToType)[j].disabled == false){
							/* Once any "paid to" checkbox is found checked, set 'checkedPaidTo" to true, so that we know that we do not
							need to ask the user to select at least one "paid to".
							*/
							if(checkedPaidTo == false){
								checkedPaidTo = eval("document.all.Template_Paid_To_Select_" + ObjDiscountTypeId + "_" + ObjListPaidToType)[j].checked;
							}

							/* Once any "paid to" checkbox is found checked, get the "paid_To_ID" (eg: 1 for dist, 2 for oper etc) of ths selcted option. */
							if(eval("document.all.Template_Paid_To_Select_" + ObjDiscountTypeId + "_" + ObjListPaidToType)[j].checked)
							{
								selectedComponentPaidTo = eval("document.all.Template_Paid_To_Select_" + ObjDiscountTypeId + "_" + ObjListPaidToType)[j].name.split("_")[5];
							}

							/* If a "default paid to" is selected (using dropdown) for rates grid and/or CF Pages (discount type pages), then we need to make sure that
							those seleted options are also turned ON using the "paid to" checkboxes.
							eg: We cannot have "Default paid to" as "distributor", if "distributor" paid to checkbox is not ON.
							*/
							if((selectedComponentPaidTo == ObjListPaidToType && selectedComponentPaidTo == selectedDefaultComponentPaidTo) || selectedDefaultComponentPaidTo == 0){
								SelectedDefaultPaidToOptionIsOn = true;
							}
						}

				}

			}

			/* If a template is included, at least one 'paid to' needs to be included. */
			if(checkedPaidTo == false){
				allGood = false;
				queueMessage("Please make at least one 'paid to' selection", ObjError);
			}
			else{
				clearQueue(ObjError);
			}

			if((typeof(eval("document.all.Template_Paid_To_Default_Rates_Grid_" + ObjDiscountTypeId)) != "undefined")
			 || (typeof(eval("document.all.Template_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId)) != "undefined"))
			{
				/* Eg: If a user has selected "distributor" as the default "paid to" for the template's component, but the "distributor" option
				is not selected as the "paid to" for the template's component.
				*/
				if(SelectedDefaultPaidToOptionIsOn == false){
					allGood = false;
					queueMessage("Please make sure that the selected default paid to option is turned ON.", ObjErrorDefPaidTo);
				}
				else{
					clearQueue(ObjErrorDefPaidTo);
				}
			}
			/* Currently, we do not force users to select a default for the template's component, but the users are forced to select a default when
			"Single Component Per Discount Type" is ON.
			*/
			if(typeof(eval("document.all.Template_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId)) != "undefined"
			&& eval("document.all.Single_Component_Per_Discount_Type_" + templateID).value == 1
			&& selectedDefaultComponentPaidTo == 0)
			{
				allGood = false;
				queueMessage("For templates with 'Single Component Per Discount Type' ON, default 'paid to' needs to be selected,  ", ObjErrorDefPaidToCFPages);
			}
			else{
					clearQueue(ObjErrorDefPaidToCFPages);
			}

		}
		else{
			clearQueue(ObjError);
			if((typeof(eval("document.all.Template_Paid_To_Default_Rates_Grid_" + ObjDiscountTypeId)) != "undefined")
			 || (typeof(eval("document.all.Template_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId)) != "undefined"))
			{
				clearQueue(ObjErrorDefPaidTo);
			}
			if(typeof(eval("document.all.Template_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId)) != "undefined")
			{
				clearQueue(ObjErrorDefPaidToCFPages);
			}

		}

	    }
        }
   }
  		if(allGood)
		{
			if(compId != '')
			{
				/* update component data. */
				upadateComp(compId)
				return false;
			}
			else{
				/* add a component. */
				addComp();
				return false;
			}

		}
		else
		{
			showMessageWindow();
			return false;
		}


}