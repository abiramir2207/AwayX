// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataFormDisplay(action)
{
	var AliasFrm = document.DataForm;
	AliasFrm.display.value = action;
	AliasFrm.command.value = '';
	AliasFrm.submit();
	return false;
}

/* Validation while searching data. It is also used from "Create File" page - just to submit the form */
function submitDataFormCommand(Action)
{
	var AliasFrm = document.DataForm;
	var ErrorCount = 0;
	var CheckCombinations = 0;
	var FieldName;

  /* We can search by just one criteria - Ship_To OR Family OR Buying Group */
  if(Action == 'Search')
  {
	if(AliasFrm.Shr_Ship_To.value != '')
	{
		CheckCombinations = CheckCombinations + 1
	}

	if(AliasFrm.Family_Name.value != '0')
	{
		CheckCombinations = CheckCombinations + 1
	}

	if(AliasFrm.Buying_Group.value != '0')
	{
		CheckCombinations = CheckCombinations + 1
	}

		/* If we are searching by more than 1 criteria */
		if(CheckCombinations > 1)
		{

			if(AliasFrm.Shr_Ship_To.value != '')
			{
				ErrorCount++;
				queueMessage("You can only use one search criteria at a time", document.all.error_Distributor);
			}
			else
			{
				clearQueue(document.all.error_Distributor);
			}

			if(AliasFrm.Family_Name.value != '0')
			{
				ErrorCount++;
				queueMessage("You can only use one search criteria at a time", document.all.error_Family);
			}
			else
			{
				clearQueue(document.all.error_Family);
			}

			if(AliasFrm.Buying_Group.value != '0')
			{
				ErrorCount++;
				queueMessage("You can only use one search criteria at a time", document.all.error_BuyingGroup);
			}
			else
			{
				clearQueue(document.all.error_BuyingGroup);
			}
		}
   }


	<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) {
			AliasFrm.command.value = Action;
			AliasFrm.submit();
			return false;				
			
	}		
	else {
		showMessageWindow();
	}	
}

/* This is for sorting data columns */
function submitDataFormCommandSort(Action,sortBy,sortOrder)
{
	var AliasFrm = document.DataForm;
	AliasFrm.command.value = Action;
	AliasFrm.sort_by.value = sortBy;
	AliasFrm.sort_order.value = sortOrder;
	AliasFrm.submit();
	return false;
}

/* Validation for the "Ranking" page. */
function submitDataFormCommandRanking(Action)
{
	var AliasFrm = document.DataForm;
	var ErrorCount = 0;
	var DistributorRank = AliasFrm.RankOrder_1.value;
	var FamilyRank = AliasFrm.RankOrder_2.value;
	var BuyingGroupRank = AliasFrm.RankOrder_3.value;

	if(DistributorRank == '')
	{
		ErrorCount++;
		queueMessage("Please select a rank", document.all.error_Distributor);
	}
	else if(DistributorRank == FamilyRank || DistributorRank == BuyingGroupRank)
	{
		ErrorCount++;
		queueMessage("You cannot select the same rank twice", document.all.error_Distributor);
	}
	else
	{
		clearQueue(document.all.error_Distributor);
	}

	if(FamilyRank == '')
	{
		ErrorCount++;
		queueMessage("Please select a rank", document.all.error_Family);
	}
	else if(FamilyRank == DistributorRank || FamilyRank == BuyingGroupRank)
	{
		ErrorCount++;
		queueMessage("You cannot select the same rank twice", document.all.error_Family);
	}
	else
	{
		clearQueue(document.all.error_Family);
	}

	if(BuyingGroupRank == '')
	{
		ErrorCount++;
		queueMessage("Please select a rank", document.all.error_BuyingGroup);
	}
	else if(BuyingGroupRank == DistributorRank || BuyingGroupRank == FamilyRank)
	{
		ErrorCount++;
		queueMessage("You cannot select the same rank twice", document.all.error_BuyingGroup);
	}
	else
	{
		clearQueue(document.all.error_BuyingGroup);
	}

	<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) {
			/* On the screen, Distributor (ship To) is the first select box, family is second 
			   and Buying group is third 
			*/
			AliasFrm.Shr_Ship_To.value = AliasFrm.RankOrder_1.value;
			AliasFrm.Family_Name.value = AliasFrm.RankOrder_2.value;
			AliasFrm.Buying_Group.value = AliasFrm.RankOrder_3.value;
			AliasFrm.command.value = Action;
			AliasFrm.submit();
			return false;			
	}		
	else {
		showMessageWindow();
	}
}

/* Used while adding aliases */
function AddAliasCompletion(Action)
{ 

	var AliasFrm = document.forms['DataForm'].elements;
	var elem;
	var FirstPos;
	var LastPos;
	var AliasArray;
	var ErrorCount = 0;
	var Distributor_Product_Number;
	var name_;
	var type_;
	var bsa_foodservice_items_master_id;
	var count = 0;

	for (var i=0, il= AliasFrm.length; i<il; i++)
	{
		elem =	AliasFrm[i];

		name_ = elem.name;
		type_ = elem.type;

	
		if(type_=='text' && name_.indexOf('Distributor_Product_Number_') != -1 && document.getElementById(name_).disabled == false)
		{
			count = count + 1;

			LastPos = name_.lastIndexOf('_') ;/* Last Underscore */
			bsa_foodservice_items_master_id = name_.substring(LastPos+1,name_.length);

			if(elem.value == '')
			{
				
				ErrorCount++;
				queueMessage("You must enter a product alias.", eval(document.getElementById('error_Distributor_Product_Number_'+bsa_foodservice_items_master_id)));
			}
			else
			{
				clearQueue(eval(document.getElementById('error_Distributor_Product_Number_'+bsa_foodservice_items_master_id)));
			}
		}
	}

	<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
			AliasFrm.command.value = Action;
			/*  Show the "Updating" message */
			document.all.Updating.style.display = 'block';
			/* This is used for busy cursor */
			document.body.style.cursor = "wait";
			/* Redirect to the search page */
			AliasFrm.display.value = 'Search';
			AliasFrm.submit();
			return false;				
			
	}		
	else 
	{
		showMessageWindow();
	}	
	
}

/* Select All Checkboxess */
function selectAll(ItemNumber)
{
	var AliasFrm = document.forms['DataForm'].elements;
	
  /* For a specific product's checkbox */
  if(ItemNumber)
  {
	  document.getElementById('Distributor_Product_Number_'+ItemNumber).disabled= document.getElementById('chk_'+ItemNumber).checked
	
  }
  else
  {
	    /* Select All */
		for (var i=0, il= AliasFrm.length; i<il; i++){

		elem =	AliasFrm[i];
		name_ = elem.name;
		type_ = elem.type;

		if(type_=='checkbox' && name_.indexOf('chk_') != -1 && name_ != 'chkAll')
		{	
			elem.checked = AliasFrm.chkAll.checked;
		}

		if(type_=='text' && name_.indexOf('Distributor_Product_Number') != -1)
		{	
			elem.disabled= AliasFrm.chkAll.checked;
		}
	}
			

  }
}

/* Product pop up page */
function showProductSearchWindow() {
		NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=DataForm&SelectSingleSearchResultOnly=0", "productwindow", 800, 600, "yes", "yes");
}

/* Distributor pop up page */
function showDistributorSearchWindow() {
	var AliasFrm = document.forms['DataForm'].elements;
	var SingleSearch = 1;
	
	/* If searching for entries without an alias, allow the user to search for all distributors. It will be useful in creating a 
	   csv file for which aliases need to be created.
	*/
	if(AliasFrm.Is_Alias)
	{
	if(AliasFrm.Is_Alias.value == 1)
	{
		var SingleSearch = 0;
	}
	}

	NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?FormName=DataForm&SelectSingleSearchResultOnly="+SingleSearch, "distributorwindow", 800, 600, "yes", "yes")			
}

/* Upload Alias error details */
function getAliasManagementErrorDetails(Alias_Management_Product_History_ID) {
	NewWindow("upload_file_error_details.cfm?Alias_Management_Product_History_ID="+Alias_Management_Product_History_ID, "errorwindow", 600, 400, "yes", "yes")	;
	return false;
}

/* While adding aliases OR creating a file to add aliases, use logic to show/hide 
   different search criteria.
*/
function showDistributorSearch()
{
	var AliasFrm = document.forms['DataForm'].elements;
	
	// When the first distributor level is selected (Distributor), show distributor search link
	if(document.DataForm.Distributor_level_id.value == '0')
	{
		document.all.Distributor_ID.style.display = 'block';
	}
	else
	{	
		document.all.Distributor_ID.style.display = 'none';
	}

	// When the second distributor level is selected (Family), show Family search select box
	if(document.DataForm.Distributor_level_id.value == '2')
	{
		 document.all.Family_ID.style.display = 'block';
	}
	else
	{
		 document.all.Family_ID.style.display = 'none';
	}

	// When the third distributor level is selected (Buying Group), show Buying Group select box
	if(document.DataForm.Distributor_level_id.value == '3')
	{
		document.all.Buying_Group_ID.style.display = 'block';
	}
	else
	{
		 document.all.Buying_Group_ID.style.display = 'none';
	}

	if(document.DataForm.Distributor_level_id.value == '0' || document.DataForm.Distributor_level_id.value == '2'
	   || document.DataForm.Distributor_level_id.value == '3')
	{
		  if(document.all.Alias_Info)
		{
		document.all.Alias_Info.style.display = 'block';
		}
	}
	else
	{
		document.all.Alias_Info.style.display = 'none';
	}

	showProductSearch();
}


function showProductSearch()
{
	var AliasFrm = document.DataForm;
	var CheckSelected = 0;

	/* When at least one distributor level is selected (Distributor(Ship_To) OR Family OR Buying Group*/
	if(document.DataForm.Distributor_level_id.value == '0' || document.DataForm.Distributor_level_id.value == '2' || document.DataForm.Distributor_level_id.value == '3')
	{
		if(document.DataForm.Family_Name)
		{
			/* If family distributor level is selected */
			if(document.DataForm.Distributor_level_id.value == '2')
			{
				CheckSelected  = 1;
			}
		}
		
		if(CheckSelected == 0)
		{
			if(document.DataForm.Buying_Group)
			{
			 /* If buying group distributor level is selected */
			 if(document.DataForm.Distributor_level_id.value == '3')
			  {
				CheckSelected  = 1;
			  }
			}

		}
	}
	
	/* If Family or buying group distributor level is selected, show "select products" link */
	if(CheckSelected)
	{
		document.all.Search_Products_ID.style.display = 'block';

		// Show "Create text file" or "save" action links too
		if(document.DataForm.Distributor_level_id.value != '' && AliasFrm.Product_List.value != '')
		{
			
			if(document.all.Create_CSV_ID)
			{
			document.all.Create_CSV_ID.style.display = 'block';
			}

			if(document.all.Save_ID)
			{
			document.all.Save_ID.style.display = 'block';
			}
		}
	}
	else
	{
		document.all.Search_Products_ID.style.display = 'none';

		    // Hide "Create CSV file" or "save" action links			
			if(document.all.Create_CSV_ID)
			{
			document.all.Create_CSV_ID.style.display = 'none';
			}

			if(document.all.Save_ID)
			{
			document.all.Save_ID.style.display = 'none';
			}
	}
}

/* Validation while upload Alias file */	
function UploadAliasCompletion(Action,disableClickedButtonName)
{
	var AliasFrm = document.DataForm;
	var filePath = AliasFrm.File_Path.value;
	var strLength = filePath.length;

	/* Get the last three characters of the upload string. We want to know whether the file is a CSV file */
	var fileExtension = filePath.substr(strLength-3,strLength).toLowerCase();

	/* This value comes from index.cfm. One cannot add cf code in a js file */
	var UploadInProgress = Upload_In_Progress;
	
	if(UploadInProgress == 1)
	{
		alert("Upload in progress. Please check back later");
		return false;
	}

	if(filePath=='' || fileExtension != 'csv')
	{
		alert("Please select a CSV file");
		return false;
	}
	else
	{
			if(confirm("This upload will replace the existing data, Are you sure to upload this file?"))
			{
				AliasFrm.command.value = Action;
				AliasFrm.display.value = 'UploadHistory';
				disableButton(disableClickedButtonName,true,false);				
				/*  Show the "Updating" message */
				document.all.Updating.style.display = 'block';
				/* This is used for busy cursor */
				document.body.style.cursor = "wait";
				AliasFrm.submit();
				return false;
			}
			else
			{
				return false;
			}
	}	
}

/* Function used in  Delete/Undelete a single product (below) */
function getParentObject(thisObj, tagName)
{
	if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
	{
		return thisObj;
	}
	else if(thisObj.tagName.toLowerCase() == "body")
	{
		return null;
	}
	else
	{
		return getParentObject(thisObj.parentElement, tagName);
	}
}

/* Delete/Undelete a single product */
function deleteProduct(prodID)
{

	//ListDelete function available in string_functions

	var srcObj = event.srcElement;

	if(prodID == "All")
	{
		var trObj = getParentObject(srcObj, "table");
	}
	else
	{
		var trObj = getParentObject(srcObj, "tr");
	}
	//var trIndex = trObj.rowIndex;
	var FINALITEMLIST = document.all.Product_List.value;
	var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
	
	var bDelete = true;
	
	if(resultString == FINALITEMLIST)
	{
		resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
		bDelete = false;
	}

	document.all.Product_List.value = resultString;

	var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
	if(trObj)
	{
		if(bDelete)
		{
			propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false); 
			propogateProperty(trObj, "style.textDecoration", "line-through", true);

			srcObj.title = "undo product deletion";
			srcObj.src = undodeleteImg.src;

			/* Disable the "Distributor_Product_Number" text box */
			document.getElementById('Distributor_Product_Number_'+prodID).disabled = true;

			/* Disable the product checkbox */
			document.getElementById('chk_'+prodID).disabled = true;

			/* Add to the delete list */
			document.all.DeleteProductList.value = ListAppendItem(document.all.DeleteProductList.value, "," ,prodID);

		}
		else
		{
			propogateProperty(trObj, "style.backgroundColor", "#FFFFFF", false);
			propogateProperty(trObj, "style.textDecoration", "none", false);

			srcObj.title = "delete this product";
			srcObj.src = deleteImg.src;

			/* Enable the "Distributor_Product_Number" text box */
			document.getElementById('Distributor_Product_Number_'+prodID).disabled = false;

			/* Enable the product checkbox */
			document.getElementById('chk_'+prodID).disabled = false;

			/* Remove from the delete list */
			document.all.DeleteProductList.value = ListDeleteItem(document.all.DeleteProductList.value, "," ,prodID);

		}
		srcObj.bDelete = !bDelete;
		trObj.bDelete = (bDelete?1:0);
	}

}