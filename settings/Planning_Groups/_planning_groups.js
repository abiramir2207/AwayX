// JavaScript Document
function exportByGroups( pg_type ) {
	pg_type = $.trim(pg_type);
	pg_type = pg_type.toLowerCase();   // sanitize parameter
	// validate parameter
	if ( (pg_type !== 'product') && (pg_type !== 'distributor') && (pg_type !== 'operator') ) {
		alert( "Unexpected parameter in exportByGroups()." );
		return false;
	}

	// diff checkbox name is used on each tab, case-sensitive so be careful
	var checkBoxName = 'chkPGProductCatID';
	if (pg_type == 'distributor')
		checkBoxName = 'chkPGCustomerCatID';
	else if (pg_type == 'operator')
		checkBoxName = 'chkPGOperatorCatID';

	// validate selected planning groups (at least one must be selected)
	var jSelected = $("form[name=DataForm] input[name=" + checkBoxName + "]:checked");
	if ( jSelected.length == 0 ) {
        alert("Please select at least one planning group.");
		return false;
        // noty( {  text:"Please select at least one planning group."
		//         ,type:'error'
		//         ,modal:true
		//         ,buttons: [  { text:'close', onClick:function($noty) {  $noty.close(); } } ]
		//         ,layout:'center' });
	}
	// post to a popup window
	/*
	var jForm = $("form[name=exportByGroupsForm]");

	var winl     = (screen.width - 850) / 2
	   ,wint     = screen.height - 460
	   ,winprops = 'height=200, width=850, top=' + wint + ', left=' + winl + ', resizable=yes, scrollbars=yes'
	   ,win      = window.open('', 'formpopup', winprops);
	win.window.focus();

	jForm.empty();   // clear out previous inputs
	jSelected.clone().appendTo("form[name=exportByGroupsForm]");   // copy selected checkboxes into hidden form

	// insert actual posting page, pg_type input and input checkbox name
	//jForm.append("<input name=actualPage value=/settings/planning_groups/exportByGroups.cfm> <input name=pg_type value=" + pg_type + "> <input name=checkBoxName value=" + checkBoxName + ">").attr("target", 'formpopup').submit();
	*/
	$("div#whole").hide();
    $("#msg55").append("<p>Gathering information, please wait...</p>");

	$("input[name=pg_type18]").val( pg_type );
	$("input[name=checkBoxName]").val( checkBoxName );
	$("input[name=command]").val( "exportmembers" );

	$("form[name=DataForm]").submit();
}

///////////////////////////////////   Submit //////////////////////////////////////////
function submitEdit(IDtoEdit,EditCategory)
{
// alert("id: " +IDtoEdit + " EditCategory: " +EditCategory);

  var actionFrm = document.DataForm;

  if (EditCategory == 'Type')
  {
  	actionFrm.PGTypeID.value = IDtoEdit;
  }
  else if (EditCategory == 'Product')
  {
  	actionFrm.PGProductCategoryID.value = IDtoEdit;
  }
  else if (EditCategory == 'Customer')
  {
  	actionFrm.PGCustomerCategoryID.value = IDtoEdit;
  }
  else if (EditCategory == 'Operator')
  {
  	actionFrm.PGOperatorCategoryID.value = IDtoEdit;
  }

  actionFrm.returnTo.value = actionFrm.display.value;
  actionFrm.display.value = 'edit';
  actionFrm.display_type.value = EditCategory;
  actionFrm.pageAction2.value = "";
  actionFrm.submit();
	return false;
}


function submitDataForm(action_type, action, compId, editMode)
{
	var actionFrm = document.DataForm;

	//if action is edit set the compId hidden value, then reset the action to the existing state
	if (action == "edit")
	{
		actionFrm.compId.value = compId;
		actionFrm.returnTo.value = actionFrm.display.value;
	}

	/* else if (action == "busRule")
	{
		actionFrm.ruleId.value = compId;
		actionFrm.editMode.value = editMode;
	}
*/
	else if (action == "add")
	{
		if(actionFrm.compExternalID)
		{
			actionFrm.compExternalID.value = "";
		}
		if(actionFrm.compName)
		{
			actionFrm.compName.value = "";
		}
	}

  // alert('before:\ndisplay: ' + action + '\n' + 'display_type = ' + action_type );
  if(action == 'product' || action=='customer' || action == 'type' || action == 'operator')
  {
    actionFrm.display_type.value = action;
    actionFrm.display.value = 'Active';
  }
  else if(action == 'research') // D33532:Planning Group Research tools
	  {
	    actionFrm.display_type.value = action;
	    actionFrm.display.value = 'Membership';
	  }
  else
  {
    actionFrm.display_type.value = action_type;
    actionFrm.display.value = action;
  }
    actionFrm.pageAction2.value = "";
    // alert('after:\ndisplay: ' +  actionFrm.display.value + '\n' + ':: display_type = ' + actionFrm.display_type.value  );
    // alert('actionFrm.pageAction2.value:' +  actionFrm.pageAction2.value);
  actionFrm.submit();
	return false;
}


///////////////////////////////////   Delete Component //////////////////////////////////////////
function deleteTypeRec(PGTypeID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected Record?"))
	{
		actionFrm.PGTypeID.value = PGTypeID;
		actionFrm.command.value = 'delType';
		actionFrm.submit();
		return false;
	}

	return false;
}

///////////////////////////////////   Deactivate Selected List of Components //////////////////////////////////////////
function deactivateSelTypeRecs()
{
	var actionFrm = document.DataForm;

	if(!Any_Object_Checked(DataForm.ChkPGTypeID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected Records?"))
	{
   /// actionFrm.PGTypeID.value = DataForm.ChkPGTypeID;
		actionFrm.command.value = 'deActType';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}

	return false;
}
///////////////////////////////////   Activate Selected List of records //////////////////////////////////////////
function activateSelTypeRecs()
{

	var actionFrm = document.DataForm;

	if(!Any_Object_Checked(DataForm.ChkPGTypeID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to activate the selected Records?"))
	{
		 // actionFrm.PGTypeID.value = DataForm.ChkPGTypeID.checked;
		actionFrm.command.value = 'actType';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}

	return false;
}
///////////////////////////////////   Deactivate Single Record  //////////////////////////////////////////
function deActivateType(PGTypeID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected Record?"))
	{
		actionFrm.PGTypeID.value = PGTypeID;
		actionFrm.command.value = 'deActType';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}

	return false;
}

function activateType(PGTypeID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to activate the selected Record?"))
	{
		actionFrm.PGTypeID.value = PGTypeID;
		actionFrm.command.value = 'actType';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}
	return false;
}


/////////////////////////////////// Deactivate Product Records /////////////////////////////////////////////

function deActivateSelProdRecs()
{
	var actionFrm = document.DataForm;

	if(!Any_Object_Checked(DataForm.chkPGProductCatID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected Records?"))
	{
   /// actionFrm.PGTypeID.value = DataForm.ChkPGTypeID;
		actionFrm.command.value = 'deActProduct';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}

	return false;
}

function activateSelProdRecs()
{

	var actionFrm = document.DataForm;

	if(!Any_Object_Checked(DataForm.chkPGProductCatID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to activate the selected Records?"))
	{
		 // actionFrm.PGTypeID.value = DataForm.ChkPGTypeID.checked;
		actionFrm.command.value = 'actProduct';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}

	return false;
}

function deActivateProductRec(PGProductCatID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected Record?"))
	{
    //alert(PGProductCatID);
		actionFrm.PGProductCatID.value = "<'" + PGProductCatID  + "'>";
		actionFrm.command.value = 'deActProduct';
		actionFrm.display.value = 'active';
    // actionFrm.display_Type.value = 'Product';
		actionFrm.submit();
		return false;
	}

	return false;
}
///Dev Note: drachala; D28611: PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID  START
function CopySelProdRecs(PGProductCatID, Type, Status)
{

	/*
if(confirm("Do you really want to Copy the selected Record?"))
	{
*/
		if(Type == "Product")
		{
			var sURL = "_pg_product_copy.cfm?PGProductCatID=" + PGProductCatID + "&status=" + Status;
  			NewWindow(sURL, 'Copy', 550, 500, 'Yes', 'Yes');
		}
		if(Type == "Distributor")
		{
			var sURL = "_pg_customer_copy.cfm?PGProductCatID=" + PGProductCatID + "&status=" + Status;
  			NewWindow(sURL, 'Copy', 600, 525, 'Yes', 'Yes');
		}
		if(Type == "Operator")
		{
			var sURL = "_pg_operator_copy.cfm?PGProductCatID=" + PGProductCatID + "&status=" + Status;
  			NewWindow(sURL, 'Copy', 550, 500, 'Yes', 'Yes');
		}
	}

/*
	return false;
}
*/
///Dev Note: drachala; D28611: PLANNING GROUPS - COPY - ADD THE ABILITY TO COPY AN EXISTING PLANNING GROUP WITH IDENTICAL PROPERTIES BUT NO NAME OR ID  END

function activateProductRec(PGProductCatID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to activate the selected Record?"))
	{
		actionFrm.PGProductCatID.value = "<'" + PGProductCatID + "'>";
		actionFrm.command.value = 'actProduct';
		actionFrm.display.value = 'active';
    // actionFrm.display_Type.value = 'Product';
		actionFrm.submit();
		return false;
	}
	return false;
}

function deleteProductRec(PGProductCatID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected Record?"))
	{
		actionFrm.PGProductCatID.value = PGProductCatID;
		actionFrm.command.value = 'delProductPG';
  //  actionFrm.display_Type.value = 'Product';
  	actionFrm.display.value = 'active';

		actionFrm.submit();
		return false;
	}

	return false;
}



/////////////////////////////////// Deactivate Customer Record /////////////////////////////////////////////

function deActivateSelCustomerRecs()
{
	var actionFrm = document.DataForm;

	if(!Any_Object_Checked(DataForm.chkPGCustomerCatID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected Records?"))
	{
   /// actionFrm.PGTypeID.value = DataForm.ChkPGTypeID;
		actionFrm.command.value = 'deActCustomer';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}

	return false;
}

function activateSelCustomerRecs()
{

	var actionFrm = document.DataForm;

	if(!Any_Object_Checked(DataForm.chkPGCustomerCatID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to activate the selected Records?"))
	{
		 // actionFrm.PGTypeID.value = DataForm.ChkPGTypeID.checked;
		actionFrm.command.value = 'actCustomer';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
	return false;
}

function deActivateCustomerRec(PGCustomerCatID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected Record?"))
	{
    //alert(PGProductCatID);
		actionFrm.PGCustomerCatID.value = "<'" + PGCustomerCatID + "'>";
		actionFrm.command.value = 'deActCustomer';
		actionFrm.display.value = 'active';
    // actionFrm.display_Type.value = 'Customer';
		actionFrm.submit();
		return false;
	}
	return false;
}

function activateCustomerRec(PGCustomerCatID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to activate the selected Record?"))
	{
		actionFrm.PGCustomerCatID.value = "<'" + PGCustomerCatID + "'>";
		actionFrm.command.value = 'actCustomer';
		actionFrm.display.value = 'inActive';
    // actionFrm.display_Type.value = 'Customer';
		actionFrm.submit();
		return false;
	}
	return false;
}

function deleteCustomerRec(PGCustomerCatID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected Record?"))
	{
		actionFrm.PGCustomerCatID.value = PGCustomerCatID;
		actionFrm.command.value = 'delCustomerPG';
 //   actionFrm.display_Type.value = 'Customer';
		actionFrm.submit();
		return false;
	}

	return false;
}



///////////////////////////////////   Activate Single Component //////////////////////////////////////////
function activateRec(MarginItemExclusionID)
{
	var actionFrm = document.DataForm;
	if(confirm("Do you really want to activate the selected Record?"))
	{
		actionFrm.MarginItemExclusionID.value = MarginItemExclusionID;
		actionFrm.command.value = 'act';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}

	return false;
}


///////////////////////////////////   Select All Checkboxes //////////////////////////////////////////
function selectAll(thisObj, objToChk)
{
	var chObjs = eval("document.all." + objToChk);
	var bCheck = thisObj.checked;
	var i;
	if(chObjs)
	{
		if(chObjs.length)
		{
			for(i=0;i<chObjs.length;i++)
			{
				chObjs[i].checked = bCheck;
			}
		}
		else
		{
			chObjs.checked = bCheck;
		}
	}
}
function selectAllLike(thisObj, objToChk)
{
	//var chObjs = eval("document.all." + objToChk);
	var bCheck = thisObj.checked;
	var i;
/*	var chObjs = eval("document.all." + thisObj);
	if(chObjs)
	{
		if(chObjs.length)
		{
			for(i=0;i<chObjs.length;i++)
			{
				chObjs[i].checked = bCheck;
			}
		}
		else
		{
			chObjs.checked = bCheck;
		}
	}*/

	for (i=0;i<document.DataForm.elements.length;i++)
	{

	// alert(document.DataForm.elements[i].name);
		if ( document.DataForm.elements[i].name != undefined ||  document.DataForm.elements[i].name != null)
		{
			if (document.DataForm.elements[i].name != "undefined" || document.DataForm.elements[i].name != "")
			{
		 		if ((document.DataForm.elements[i].name).indexOf(objToChk,0) != -1)
				{
			 		 document.DataForm.elements[i].checked = bCheck;
				}
		 	}
		}
	}

}

function trim(sStr)
{
	return sStr.replace(/^\s*/ig, "").replace(/\s*$/ig, "");
}

function ListFindItem1(sList, delimiter, findItem)
{
	var resultString = sList;
	var Arr = sList.split(delimiter);
	var i, arrLen;
	arrLen = Arr.length;
	if (sList.length > 0)
	{
	for(i=0;i<arrLen;i++)
	{
		if(trim(Arr[i]) == findItem)
		{
			return i;
		}
	}
	}
	return -1;
}

function ListDeleteItem1(sList, delimiter, deleteItem)
{
	var resultString = sList;
	var Arr = sList.split(delimiter);
	var i, arrLen;
	var iExitOnFirstFind = 1;

	arrLen = Arr.length;
	for(i=arrLen-1;i>=0;i--)
	{
		if(Arr[i] == deleteItem)
		{
			Arr.splice(i, 1);
			if(iExitOnFirstFind == 1)
			{
				resultString = Arr.join(delimiter);
				return trim(resultString);
			}
		}
	}
	resultString = Arr.join(delimiter);
	return resultString;
}


/*     FUNCTION THAT WERE ADDED NEW FOR    */


/*  function showProductSearchWindow()
  {
		var bSelectedAllProducts = false;
		var groupLevel = 0;
    var sURL = "/Flex/search/ItemSearchFx.cfm?Formname=DataForm";

    rdoIncExcLen = document.DataForm.rdoIncExc.length;
   // alert(rdoIncExcLen);
    rdoSelected = 0;
    for (i = 0; i <rdoIncExcLen; i++) {
      if (document.DataForm.rdoIncExc[i].checked)
      {
        rdoSelected = document.DataForm.rdoIncExc[i].value;
      }
    }

if (rdoSelected == '')
  {
    alert("Select Include or Exclude!");
    return false;
  }

		NewWindowTopLeft(sURL, "productwindow", 1000, 715, "yes", "yes")
	}
 */
  function showProductSearchWindow(bsid)
  {
    rdoIncExcLen = document.DataForm.rdoIncExc.length;
    rdoSelected = '';
        //alert(bsid);
    for (i = 0; i <rdoIncExcLen; i++) {
        if (document.DataForm.rdoIncExc[i].checked)
        {
          rdoSelected = document.DataForm.rdoIncExc[i].value
        }
      }

    if (rdoSelected == '')
      {
        alert("Select Include or Exclude!");
        return false;
      }

    if (document.DataForm.selTypeName.selectedIndex == 0)
    {
      alert("Select a Type Name!");
      return false;
    }

	  NewWindowTopLeft("/Common_Files/contracts/product_Select_V1.cfm?Formname=DataForm&Business_Segment_Id="+bsid, "productwindow", 800, 600, "yes", "yes", true)
	}


  function showDistSearchWindow(bsid)
  {

    rdoIncExcLen = document.DataForm.rdoIncExc.length;
    rdoSelected = '';
     // alert(bsid);
    for (i = 0; i <rdoIncExcLen; i++) {
      if (document.DataForm.rdoIncExc[i].checked)
      {
        rdoSelected = document.DataForm.rdoIncExc[i].value;
      }
    }
    if (rdoSelected == '')
    {
      alert("Select Include or Exclude!");
      return false;
    }

	if (document.DataForm.selTypeName.selectedIndex == 0)
    {
      alert("Select a Type Name!");
      return false;
    }

	  NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=DataForm&FieldName=Distributor_List&SelectSingleSearchResultOnly=0&ShowActiveDistributorsOnly=0&AllowImportAll=1&AllowSingleResultAutoSelect=0&Business_Segment_Id="+bsid, "distributorwindow", 850, 600, "yes", "yes");
	}


   function showOperatorSearchWindow()
  {
    rdoIncExcLen = document.DataForm.rdoIncExc.length;
    rdoSelected = '';
       // alert(rdoIncExcLen);
    for (i = 0; i <rdoIncExcLen; i++) {
        if (document.DataForm.rdoIncExc[i].checked)
        {
          rdoSelected = document.DataForm.rdoIncExc[i].value
        }
      }

    if (rdoSelected == '')
      {
        alert("Select Include or Exclude!");
        return false;
      }

	if (document.DataForm.selTypeName.selectedIndex == 0)
    {
      alert("Select a Type Name!");
      return false;
    }

	  NewWindow("/Billbacks/search_Screens/PM_select_Operators.cfm?Formname=DataForm", "Opsearch", 800, 600, "yes", "yes")
	}


  function submitForm(command, subCommand)
  {
  	var thisForm = document.groupDataForm;
  	var grpLevl1 = thisForm.GroupLevel_1.value;

	//handle for get groups
	if(subCommand == 'getGroups')
	{
		var currGrp = thisForm.GroupLevel_1.value;

		var groupCombinationOn = 0;
		var groupCombinationOnObj = eval("thisForm.groupCombinationOn");
		if(groupCombinationOnObj.value == 1)
		{
			groupCombinationOn = 1;
		}

		if(groupCombinationOn == 1)
		{
			var anySelected = checkGroupOfGroupsMemberSelection();
			if(!anySelected)
			{
				alert("Please set a group name");
				return false;
			}
			var selGrp = thisForm.GroupLevel.value;
		}
		else
		{
			var selGrp = thisForm.GroupLevel.options[thisForm.GroupLevel.selectedIndex].value;
		}


		if (currGrp != selGrp && currGrp!= "")
		{
			if(confirm("You will lose your current selection. Do you want to continue?"))
			{
				//thisForm.GroupLevel_1.value = selGrp;
				thisForm.clearLevel.value = 1;
			}
			else
			{
				return;
			}
		}
	}

	if(command == 'import' || command == 'validate_import')
	{
		if(grpLevl1 == "")
		{
			alert("You must add a Group to a pricing level before importing.");
			return;
		}
	}

	//set the action value then submit
	thisForm.command.value = command;
	thisForm.sub_command.value = subCommand;
	thisForm.submit();
}

      function switchlayer(lyrid, title, titleclosed, borderwidth, imagea,imageb, colora,colorb) {
       if (document.all.length) {
        // determine if the layer is currently expanded or collapsed:
        var tmpstatus;
        eval("tmpstatus = document.all.lyrgroup_"+ lyrid +".style.display");
        // ok, then now expand or collapse it...
        if (tmpstatus == 'none') {
         eval("document.all.lyrgroup_"+ lyrid +".style.display='block';");
         eval("document.all.border_"+ lyrid +".style.borderwidth='"+borderwidth+"px';");
         eval("document.all.title_"+ lyrid +".innerhtml='"+title+"';");
         tmpimage = imagea;
         tmpcolor = colora;
        }
        else {
         eval("document.all.lyrgroup_"+ lyrid +".style.display='none'");
         eval("document.all.border_"+ lyrid +".style.borderwidth='0px';");
         eval("document.all.title_"+ lyrid +".innerhtml='"+titleclosed+"';");
         tmpimage = imageb;
         tmpcolor = colorb;
        }
        // if an image is used as the click-control, switch it...
        if ((tmpimage != null) && (imagea != imageb)) {
         eval("document.all.image_"+ lyrid +".src='"+tmpimage+"'");
        }
        // if different title-colors are used, switch them...
        if (tmpcolor != '') {
         eval("document.all.title_"+ lyrid +".style.color='"+tmpcolor+"'");
        }
       }
      }


  function fnDisplayRow(dispElement,imageA,imageB,divImg)
  {
	  var row = document.getElementById(dispElement);

    var tmpStatus;
    eval("tmpstatus= document.all." + dispElement + ".style.display");

    if (tmpstatus== 'none')
    {
//      DXImageTransform.Microsoft.Blinds(direction='up', bands=1)
      eval("document.all." + dispElement + ".style.display='block';");
      tmpImage = imageA;

    }
    else
    {
      eval("document.all." + dispElement + ".style.display='none';");
      tmpImage = imageB;
    }
     if ((tmpImage != null) && (imageA != imageB))
     {
         eval("document.all."+ divImg +".src='"+tmpImage+"'");
     }

    /*if (row.style.display == '')

    {
    row.style.display = 'none';
    }
    else
    {
    row.style.display = '';
    }
    */
   }

    function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
		{
			isSearching = 1;
			var formObj;
			formObj = document.all.DataForm;
			formObj.sort_by.value = thisSortItem;
			formObj.New_Sort_Order.value = thisSortOrder;
			if (thisSortItem == "TYPE")
			{
				formObj.pageAction2.value = "";
				formObj.TypeRefresh.value = '1';
			//alert(formObj.pageAction2.value)
			}
			formObj.submit();
			return false;
		}


  function displayRow(dispElement,srcElement)
  {

	  var row = document.getElementById(dispElement);
    var srcVal = document.getElementById(srcElement);

  	if (srcVal.checked)
    {
      row.style.display = 'none';
    }
    else
    {
     row.style.display = '';
    }
  }

//  function toggleFieldDisplay('bIncludeInOthers','WithPG','WithoutPG')
  function toggleFieldDisplay(srcElement,dispElement1,dispElement2)
  {
    var field1 = document.getElementById(dispElement1);
    var field2 = document.getElementById(dispElement2);
    var srcVal = document.getElementById(srcElement);

  	if (srcVal.checked)
    {
      field1.style.display = 'none';
      field2.style.display = '';
     // document.getElementById('GroupLevel1').disabled = true;
      //document.getElementById('GroupLevel2').disabled = false;
    }
    else
    {
      field1.style.display = '';
      field2.style.display = 'none';
      //document.getElementById('GroupLevel1').disabled = false;
      //document.getElementById('GroupLevel2').disabled = true;

    }
  }

  function saveAddPPG(SEOption, bus_seg)   // SEOption - Save/Exit Option
  {
    var strError = "";
    var actionFrm = document.DataForm;
    // if ((actionFrm.planningGroupName.value.replace(" " , "")) == "") // trim the s

    if ((actionFrm.planningGroupName.value.replace(/^\s+|\s+$/g, "")) == "")
    {
      strError = strError + " "  + "Planning Group Name cannot be empty\n"
    }

    if (actionFrm.selTypeName.selectedIndex == 0)
		{
      strError = strError + " "  + "Select a Type Name\n"
    }

	 if (bus_seg == 1)
	 {
	     if (actionFrm.business_segment.selectedIndex == 0)
		   {
            strError = strError + " "  + "Select a Business Segment\n"
           }
     }

	    if(actionFrm.PG_Effective_Date_ON.value == '1'){
	    	//START DATE
		    if (actionFrm.PG_Effective_Start_Date.value == ''){
		        strError = strError + " "  + "Please establish an effective start date.\n"
		    }else{
				var effDate = new Date(actionFrm.PG_Effective_Start_Date.value);
				var DateToday = new Date()
				DateToday = new Date(DateToday.getFullYear(), DateToday.getMonth(),DateToday.getDate())
				if(DateToday > effDate){
					alert('Please note that the date you are providing is in the past and will impact the membership previously established.')
				}
		    }
	    	//END DATE
		    if (actionFrm.PG_Effective_End_Date.value == ''){
		        strError = strError + " "  + "Please establish an effective end date.\n"
		    }else{
				var startDate = new Date(actionFrm.PG_Effective_Start_Date.value);
				var endDate = new Date(actionFrm.PG_Effective_End_Date.value);
						startDate = startDate.getTime();
						endDate = endDate.getTime();
						
				if(endDate < startDate){
					 strError = strError + " "  + "Effective end date cannot be before effective start date.\n"
				}
		    }  
	    }

  /*  Add more code here for validating all the other fields.  */

    if (strError != "")
    {
      alert("Errors Found: \n\n" + strError);
      document.getElementById('hidelink').style.display = 'none';
			document.getElementById('displaylink').style.display = 'block';
      return false;
    }
    else
    {
      // actionFrm.display.value="save";
      actionFrm.PGTypeID.value = actionFrm.selTypeName.options[actionFrm.selTypeName.selectedIndex].value;
      actionFrm.pageAfterSave.value = SEOption;
      actionFrm.pageAction2.value = "ProductAddSave";
      please_wait();
      actionFrm.submit();
      return true;
    }

  }

function saveEditPPG(SEOption)   // SEOption - Save/Exit Option
  {
    var strError = "";
    var actionFrm = document.DataForm;
    // if ((actionFrm.planningGroupName.value.replace(" " , "")) == "") // trim the s

    if ((actionFrm.planningGroupName.value.replace(/^\s+|\s+$/g, "")) == "")
    {
      strError = strError + " "  + "Planning Group Name cannot be empty\n"
    }

    if (actionFrm.selTypeName.selectedIndex == 0)
		{
      strError = strError + " "  + "Select a Type Name\n"
    }
    if(actionFrm.PG_Effective_Date_ON.value == '1' && actionFrm.PG_Effective_Date_Upload_Download.value != '1'){		
    	//START DATE
	    if (actionFrm.PG_Effective_Start_Date.value == ''){
	        strError = strError + " "  + "Please establish an effective start date.\n"
	    }else{
			var effDate = new Date(actionFrm.PG_Effective_Start_Date.value);
			var DateToday = new Date()
			DateToday = new Date(DateToday.getFullYear(), DateToday.getMonth(),DateToday.getDate())
			if(DateToday > effDate){
				alert('Please note that the date you are providing is in the past and will impact the membership previously established.')
			}
	    } 
    	//END DATE
	    if (actionFrm.PG_Effective_End_Date.value == ''){
	        strError = strError + " "  + "Please establish an effective end date.\n"
	    }else{
			var startDate = new Date(actionFrm.PG_Effective_Start_Date.value);
			var endDate = new Date(actionFrm.PG_Effective_End_Date.value);
					startDate = startDate.getTime();
					endDate = endDate.getTime();

			if(endDate < startDate){
				 strError = strError + " "  + "Effective end date cannot be before effective start date.\n"
			}
	    }  
	  }
  /*  Add more code here for validating all the other fields.*/

    if (strError != "")
    {
      alert("Errors Found: \n\n" + strError)
      document.getElementById('hidelink').style.display = 'none';
			document.getElementById('displaylink').style.display = 'block';
      return false;
    }
    else
    {
      // actionFrm.display.value="save";
      actionFrm.PGTypeID.value = actionFrm.selTypeName.options[actionFrm.selTypeName.selectedIndex].value;
      actionFrm.pageAfterSave.value = SEOption;
      actionFrm.pageAction2.value = "ProductEditSave";
      please_wait();
      actionFrm.submit()
      return true;
    }

  }
/*
  This function will be called from the _pg_customer_add.cfm file to
  validate the form before saving the values.
 */

function saveAddCPG(SEOption, bus_seg, PayeeFromPG)   // SEOption - Save/Exit Option
  {
	var strError = "";
	var autoPayError = 0;
	var actionFrm = document.DataForm;
    // if ((actionFrm.planningGroupName.value.replace(" " , "")) == "") // trim the s

    if ((actionFrm.planningGroupName.value.replace(/^\s+|\s+$/g, "")) == "")
    {
      strError = strError + " "  + "Planning Group Name cannot be empty\n"
    }
     if (actionFrm.selTypeName.selectedIndex == 0)
		{
      strError = strError + " "  + "Select a Type Name\n"
    }
    if (bus_seg == 1)
	 {
	     if (actionFrm.business_segment.selectedIndex == 0)
		   {
            strError = strError + " "  + "Select a Business Segment\n"
           }
     }

    if(actionFrm.PG_Effective_Date_ON.value == '1'){
    	//START DATE
 	    if (actionFrm.PG_Effective_Start_Date.value == ''){
 	        strError = strError + " "  + "Please establish an effective start date\n"
 	    }else{
			var effDate = new Date(actionFrm.PG_Effective_Start_Date.value);
			var DateToday = new Date()
			DateToday = new Date(DateToday.getFullYear(), DateToday.getMonth(),DateToday.getDate())
			if(DateToday > effDate){
				alert('Please note that the date you are providing is in the past and will impact the membership previously established.')
			}
	    }
    	//END DATE
	    if (actionFrm.PG_Effective_End_Date.value == ''){
	        strError = strError + " "  + "Please establish an effective end date.\n"
	    }else{
			var startDate = new Date(actionFrm.PG_Effective_Start_Date.value);
			var endDate = new Date(actionFrm.PG_Effective_End_Date.value);
					startDate = startDate.getTime();
					endDate = endDate.getTime();
					
			if(endDate < startDate){
				 strError = strError + " "  + "Effective end date cannot be before effective start date.\n"
			}
	    }  
     }
    
  /* Add more code here for validating all the other fields.*/
    if (strError != "")
    {
      alert("Errors Found: \n\n" + strError)
       document.getElementById('hidelink').style.display = 'none';
			document.getElementById('displaylink').style.display = 'block';
      return false;
    }
    else
    {	/* If "Establish payee from planning groups" app setting is ON and the "distributor" and/or "vendor" payee has not been assigned for the planning group. */
		if(PayeeFromPG == 1 && (actionFrm.vendor_master_id.value == '' || actionFrm.distributor_id.value == ''))
		{
			autoPayError = 1;

			if(confirm("The configuration for this environment relies upon a Vendor and/or Distributor for Auto Pay processing involving planning groups.  If this planning group will be used for Auto Pay programs, it is recommended that you select both a Vendor and a Customer to identify the Payee of future Auto Pay records."))
			{
				autoPayError = 0;
			}
		}
		if(autoPayError == 0)
		{
		  // actionFrm.display.value="save";
				actionFrm.PGTypeID.value = actionFrm.selTypeName.options[actionFrm.selTypeName.selectedIndex].value;
		  actionFrm.pageAfterSave.value = SEOption;
		  actionFrm.pageAction2.value = "CustomerAddSave";
      please_wait();
		  actionFrm.submit()
		  return true;
		}
		else{
		return false;
		}
    }
  }

/*
  This function will be called from the _pg_customer_Edit.cfm file to
  validate the form before saving the values.
 */

function saveEditCPG(SEOption, PayeeFromPG, disableClickedButtonName)   // SEOption - Save/Exit Option
  {
	var strError = "";
	var autoPayError = 0;
	var actionFrm = document.DataForm;
    // if ((actionFrm.planningGroupName.value.replace(" " , "")) == "") // trim the s

    if ((actionFrm.planningGroupName.value.replace(/^\s+|\s+$/g, "")) == "")
    {
      strError = strError + " "  + "Planning Group Name cannot be empty\n"
    }
     if (actionFrm.selTypeName.selectedIndex == 0)
		{
      strError = strError + " "  + "Select a Type Name\n"
    }

     if(actionFrm.PG_Effective_Date_ON.value == '1' && actionFrm.PG_Effective_Date_Upload_Download.value != '1'){
    	 //START DATE
  	    if (actionFrm.PG_Effective_Start_Date.value == ''){
  	        strError = strError + " "  + "Please establish an effective start date\n"
  	    }else{
			var effDate = new Date(actionFrm.PG_Effective_Start_Date.value);
			var DateToday = new Date()
			DateToday = new Date(DateToday.getFullYear(), DateToday.getMonth(),DateToday.getDate())
			if(DateToday > effDate){
				alert('Please note that the date you are providing is in the past and will impact the membership previously established.')
			}
	    }
    	//END DATE
	    if (actionFrm.PG_Effective_End_Date.value == ''){
	        strError = strError + " "  + "Please establish an effective end date.\n"
	    }else{
			var startDate = new Date(actionFrm.PG_Effective_Start_Date.value);
			var endDate = new Date(actionFrm.PG_Effective_End_Date.value);
					startDate = startDate.getTime();
					endDate = endDate.getTime();
					
			if(endDate < startDate){
				 strError = strError + " "  + "Effective end date cannot be before effective start date.\n"
			}
	    }   
      }
     
    /* Add more code here for validating all the other fields.*/
    if (strError != "")
    {
      alert("Errors Found: \n\n" + strError);
      document.getElementById('hidelink').style.display = 'none';
			document.getElementById('displaylink').style.display = 'block';
      return false;
    }
    else
    {	/* If "Establish payee from planning groups" app setting is ON and the "distributor" and/or "vendor" payee has not been assigned for the planning group. */
		if(PayeeFromPG == 1 && (actionFrm.vendor_master_id.value == '' || actionFrm.distributor_id.value == ''))
		{
			autoPayError = 1;

			if(confirm("The configuration for this environment relies upon a Vendor and/or Distributor for Auto Pay processing involving planning groups.  If this planning group will be used for Auto Pay programs, it is recommended that you select both a Vendor and a Distributor to identify the Payee of future Auto Pay records."))
			{
				autoPayError = 0;
				disableButton(disableClickedButtonName, true);
			}
		}
		if(autoPayError == 0)
		{
		  // actionFrm.display.value="save";
		  actionFrm.PGTypeID.value = actionFrm.selTypeName.options[actionFrm.selTypeName.selectedIndex].value;
		  actionFrm.pageAfterSave.value = SEOption;
		  actionFrm.pageAction2.value = 'CustomerEditSave';
      please_wait();
		  actionFrm.submit()
		  return true;
		}
		else{
			document.getElementById('hidelink').style.display = 'none';
			document.getElementById('displaylink').style.display = 'block';
			return false;
		}
    }
  }

/* functions to save Operator PG */

/*
  This function will be called from the _pg_operator_add.cfm file to
  validate the form before saving the values.
 */

function saveAddOPG(SEOption)   // SEOption - Save/Exit Option
  {
    var strError = "";
    var actionFrm = document.DataForm;
    // if ((actionFrm.planningGroupName.value.replace(" " , "")) == "") // trim the s

    if ((actionFrm.planningGroupName.value.replace(/^\s+|\s+$/g, "")) == "")
    {
      strError = strError + " "  + "Planning Group Name cannot be empty\n"
    }

     if (actionFrm.selTypeName.selectedIndex == 0)
		{
      strError = strError + " "  + "Select a Type Name\n"
    }

     if(actionFrm.PG_Effective_Date_ON.value == '1'){
    	//START DATE 
 	    if (actionFrm.PG_Effective_Start_Date.value == ''){
 	        strError = strError + " "  + "Please establish an effective start date\n"
 	    }else{
			var effDate = new Date(actionFrm.PG_Effective_Start_Date.value);
			var DateToday = new Date()
			DateToday = new Date(DateToday.getFullYear(), DateToday.getMonth(),DateToday.getDate())
			if(DateToday > effDate){
				alert('Please note that the date you are providing is in the past and will impact the membership previously established.')
			}
	    }
    	//END DATE
	    if (actionFrm.PG_Effective_End_Date.value == ''){
	        strError = strError + " "  + "Please establish an effective end date.\n"
	    }else{
			var startDate = new Date(actionFrm.PG_Effective_Start_Date.value);
			var endDate = new Date(actionFrm.PG_Effective_End_Date.value);
					startDate = startDate.getTime();
					endDate = endDate.getTime();
					
			if(endDate < startDate){
				 strError = strError + " "  + "Effective end date cannot be before effective start date.\n"
			}
	    }  
     }
     
     /* Add more code here for validating all the other fields.*/
    if (strError != "")
    {
      alert("Errors Found: \n\n" + strError);
      document.getElementById('hidelink').style.display = 'none';
			document.getElementById('displaylink').style.display = 'block';
      return false;
    }
    else
    {
      // actionFrm.display.value="save";
      actionFrm.PGTypeID.value = actionFrm.selTypeName.options[actionFrm.selTypeName.selectedIndex].value;;
      actionFrm.pageAfterSave.value = SEOption;
      actionFrm.pageAction2.value = "OperatorAddSave";
      please_wait();
      actionFrm.submit()
      return true;
    }
  }

/*
  This function will be called from the _pg_customer_Edit.cfm file to
  validate the form before saving the values.
 */

function saveEditOPG(SEOption)   // SEOption - Save/Exit Option
  {
    var strError = "";
    var actionFrm = document.DataForm;
    // if ((actionFrm.planningGroupName.value.replace(" " , "")) == "") // trim the s

    if ((actionFrm.planningGroupName.value.replace(/^\s+|\s+$/g, "")) == "")
    {
      strError = strError + " "  + "Planning Group Name cannot be empty\n"
    }
     if (actionFrm.selTypeName.selectedIndex == 0)
		{
      strError = strError + " "  + "Select a Type Name\n"
    }

     if(actionFrm.PG_Effective_Date_ON.value == '1' && actionFrm.PG_Effective_Date_Upload_Download.value != '1'){
    	 //START DATE
 	    if (actionFrm.PG_Effective_Start_Date.value == ''){
 	        strError = strError + " "  + "Please establish an effective start date\n"
 	    }else{
			var effDate = new Date(actionFrm.PG_Effective_Start_Date.value);
			var DateToday = new Date()
			DateToday = new Date(DateToday.getFullYear(), DateToday.getMonth(),DateToday.getDate())
			if(DateToday > effDate){
				alert('Please note that the date you are providing is in the past and will impact the membership previously established.')
			}
	    }
    	//END DATE
	    if (actionFrm.PG_Effective_End_Date.value == ''){
	        strError = strError + " "  + "Please establish an effective end date.\n"
	    }else{
			var startDate = new Date(actionFrm.PG_Effective_Start_Date.value);
			var endDate = new Date(actionFrm.PG_Effective_End_Date.value);
					startDate = startDate.getTime();
					endDate = endDate.getTime();
					
			if(endDate < startDate){
				 strError = strError + " "  + "Effective end date cannot be before effective start date.\n"
			}
	    }  
     }
     
    /* Add more code here for validating all the other fields.*/
    if (strError != "")
    {
      alert("Errors Found: \n\n" + strError);
      document.getElementById('hidelink').style.display = 'none';
			document.getElementById('displaylink').style.display = 'block';
      return false;
    }
    else
    {
      // actionFrm.display.value="save";
      actionFrm.PGTypeID.value = actionFrm.selTypeName.options[actionFrm.selTypeName.selectedIndex].value;
      actionFrm.pageAfterSave.value = SEOption;
      actionFrm.pageAction2.value = 'OperatorEditSave';
      please_wait();
      actionFrm.submit();
      return true;
    }
  }



function fnViewMicroMembers(PGType,IDtoView,LSMembers)
{
	//var sURL = "/settings/planning_Groups/dspViewMicroMembers.cfm?Group_ID=" + IDtoView + "&PGType=" + PGType + "&members=" + LSMembers;
	var sURL = "/settings/planning_Groups/dspViewMicroMembers.cfm?Group_ID=" + IDtoView + "&PGType=" + PGType;
	NewWindow(sURL, 'View_Members', 700, 800, 'yes', 'yes');
}


function fnViewMicroOperators(PGType,IDtoView,LSMembers)
{
  var sURL = "/settings/planning_Groups/dspViewMicroOperators.cfm?Group_ID=" + IDtoView + "&PGType=" + PGType + "&members=" + LSMembers;
  NewWindow(sURL, 'View_Members', 750, 800, 'yes', 'yes');
}

var deleteImg = new Image();
deleteImg.src = "/Images/scissor.gif";
var undodeleteImg = new Image();
undodeleteImg.src = "/Images/undo.gif";

function fnDeleteThisPGMemberRecord(IDtoDelete,IDToStrike,IncExcType,skipConfirm)
{
  if (typeof skipConfirm === 'undefined') {
    skipConfirm = 0;
  }
 /*
  IncExcType => 1 - Include
             => 0 - Exclude
             => 2 - Existing Members(Edit only)

 */
  var srcObj = event.srcElement;
  var actionFrm = document.DataForm;
  var lsValsToDel = "";
  var lsValsToDelExc = "";
  var trObj = document.getElementById(IDToStrike);
  var bDelete = true;
  var srcCurrentImage = "";
  var resultString   = "";
  var lsValsToDelExisting = "";
  srcCurrentImage = srcObj.src;
  if (srcCurrentImage.search(/scissor.gif/i) > 0) // image is a scissor image;
  {
    bDelete = true;
  }
  else
  {
    bDelete = false;
  }

 if (!skipConfirm) {
   if (bDelete)
   {
     if(!confirm('Please confirm that you would like to DELETE this Record!'))
     {
      return false;
     }
   }
  else
  {
     if(!confirm('Please confirm that you would like to UNDELETE this Record!'))
     {
      return false;
     }
  }
 }

  lsValsToDelInc = actionFrm.DelMarkedInInclude.value;
  lsValsToDelExc = actionFrm.DelMarkedInExclude.value;
  if(typeof(actionFrm.DelMarkedInExisting) != "undefined")
  {
    lsValsToDelExisting = actionFrm.DelMarkedInExisting.value;
  }
  else
  {
  lsValsToDelExisting = "";
  }

 if (IncExcType == '2')
  {

    if (bDelete)
    {
      resultString = ListAppendItem(lsValsToDelExisting, ",", IDtoDelete);
      actionFrm.DelMarkedInExisting.value = "";
      actionFrm.DelMarkedInExisting.value = resultString;
    }
    else
    {
      resultString = ListDeleteItem(lsValsToDelExisting, ",", IDtoDelete);
      actionFrm.DelMarkedInExisting.value = "";
      actionFrm.DelMarkedInExisting.value = resultString;
    }
  }
 else if (IncExcType == '1')
  {
    if (bDelete)
    {
      resultString = ListAppendItem(lsValsToDelInc, ",", IDtoDelete);
      actionFrm.DelMarkedInInclude.value = "";
      actionFrm.DelMarkedInInclude.value = resultString;
    }
    else
    {
      resultString = ListDeleteItem(lsValsToDelInc, ",", IDtoDelete);
      actionFrm.DelMarkedInInclude.value = "";
      actionFrm.DelMarkedInInclude.value = resultString;
    }
  }
  else if (IncExcType == '0')
  {
    if (bDelete)
    {
      resultString = ListAppendItem(lsValsToDelExc, ",", IDtoDelete);
      actionFrm.DelMarkedInExclude.value = "";
      actionFrm.DelMarkedInExclude.value = resultString;
    }
    else
    {
      resultString = ListDeleteItem(lsValsToDelExc, ",", IDtoDelete);
      actionFrm.DelMarkedInExclude.value = "";
      actionFrm.DelMarkedInExclude.value = resultString;
    }
  }


  if(trObj)
			{
			  if(bDelete)
				{
					trObj.height = trObj.offsetHeight;
          trObj.style.backgroundColor = 'bbbbbb';
          trObj.style.textDecoration = "line-through";
					srcObj.title = "Deleted";
					srcObj.src = undodeleteImg.src;
				}
 				else
				{
          trObj.style.backgroundColor = 'e2e2e2';
          trObj.style.textDecoration = "";
					srcObj.title = "click here to delete this record";
					srcObj.src = deleteImg.src;
			 	}
				srcObj.bDelete = !bDelete;
				trObj.bDelete = (bDelete?1:0);
				} // if (trobj)
    } //function ends



function deActivateSelOprRecs()
{
	var actionFrm = document.DataForm;
	if(!Any_Object_Checked(DataForm.chkPGOperatorCatID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected Records?"))
	{
   /// actionFrm.PGTypeID.value = DataForm.ChkPGTypeID;
		actionFrm.command.value = 'deActOperator';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}

	return false;
}

function activateSelOprRecs()
{

	var actionFrm = document.DataForm;
	if(!Any_Object_Checked(DataForm.chkPGOperatorCatID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to activate the selected Records?"))
	{
		 // actionFrm.PGTypeID.value = DataForm.ChkPGTypeID.checked;
		actionFrm.command.value = 'actOperator';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}

	return false;
}

function deActivateOperatorRec(PGOperatorCatID)
{
	var actionFrm = document.DataForm;
	if(confirm("Do you really want to deactivate the selected Record?"))
	{
    //alert(PGProductCatID);
		actionFrm.PGOperatorCatID.value = "<'" + PGOperatorCatID  + "'>";
		actionFrm.command.value = 'deActOperator';
		actionFrm.display.value = 'active';
    // actionFrm.display_Type.value = 'Operator';
		actionFrm.submit();
		return false;
	}

	return false;
}

function activateOperatorRec(PGOperatorCatID)
{
	var actionFrm = document.DataForm;
	if(confirm("Do you really want to activate the selected Record?"))
	{
		actionFrm.PGOperatorCatID.value = "<'" + PGOperatorCatID + "'>";
		actionFrm.command.value = 'actOperator';
		actionFrm.display.value = 'active';
    // actionFrm.display_Type.value = 'Operator';
		actionFrm.submit();
		return false;
	}
	return false;
}

function deleteOperatorRec(PGOperatorCatID)
{
	var actionFrm = document.DataForm;
	if(confirm("Do you really want to delete the selected Record?"))
	{
		actionFrm.PGOperatorCatID.value = PGOperatorCatID;
		actionFrm.command.value = 'delOperatorPG';
  //  actionFrm.display_Type.value = 'Operator';
  	actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}

	return false;
}


function fnDeleteAllList(IDstoDelete,IDsToStrike,IncExcType)
{
 /*
  IncExcType => 1 - Include
             => 0 - Exclude
             => 2 - Existing Members(Edit only)

 */
  var srcObj = event.srcElement;
  var actionFrm = document.DataForm;
  var lsValsToDel = "";
  var lsValsToDelExc = "";
  var trObj = "";
  var bDelete = true;
  var srcCurrentImage = "";
  var resultString   = "";
  var lsValsToDelExisting = "";
	var IndIDToDelete = new Array();

// alert(IDstoDelete);

	var currentTagTokens = IDstoDelete.split( "," );
  var srcImageChanged = "0";
//  var existingTags = "";

  for ( var i = 0; i < currentTagTokens.length; i++ )
  {
		if (currentTagTokens[i] != "undefined" && currentTagTokens[i] != "")
		{

    	IndIDToDelete[i] = currentTagTokens[i];
			//alert(i + " : " + IndIDToDelete[i]);
		}
  }



	for (var i=0;i < IndIDToDelete.length;i++)
	{

		srcCurrentImage = srcObj.src;

		if (srcImageChanged == "0")
		{
		  if (srcCurrentImage.search(/scissor.gif/i) > 0) // image is a scissor image;
		  {
		    bDelete = true;
		  }
		  else
		  {
		    bDelete = false;
		  }
			srcImageChanged = "1";
		}

 /* if (bDelete)
 {
   if(!confirm('Please confirm that you would like to DELETE this Record!'))
   {
    return false;
   }
 }
else
{
   if(!confirm('Please confirm that you would like to UNDELETE this Record!'))
   {
    return false;
   }
} */

 		trObj = document.getElementById(IDsToStrike + IndIDToDelete[i]);

	  lsValsToDelInc = actionFrm.DelMarkedInInclude.value;
	  lsValsToDelExc = actionFrm.DelMarkedInExclude.value;
	  if(typeof(actionFrm.DelMarkedInExisting) != "undefined")
	  {
	    lsValsToDelExisting = actionFrm.DelMarkedInExisting.value;
	  }
	  else
	  {
	  lsValsToDelExisting = "";
	  }

	 if (IncExcType == '2')
	  {

	    if (bDelete)
	    {
	      resultString = ListAppendItem(lsValsToDelExisting, ",", IndIDToDelete[i]);
	      actionFrm.DelMarkedInExisting.value = "";
	      actionFrm.DelMarkedInExisting.value = resultString;
	    }
	    else
	    {
	      resultString = ListDeleteItem(lsValsToDelExisting, ",", IndIDToDelete[i]);
	      actionFrm.DelMarkedInExisting.value = "";
	      actionFrm.DelMarkedInExisting.value = resultString;
	    }
	  }
	 else if (IncExcType == '1')
	  {
	    if (bDelete)
	    {
	      resultString = ListAppendItem(lsValsToDelInc, ",", IndIDToDelete[i]);
	      actionFrm.DelMarkedInInclude.value = "";
	      actionFrm.DelMarkedInInclude.value = resultString;
	    }
	    else
	    {
	      resultString = ListDeleteItem(lsValsToDelInc, ",", IndIDToDelete[i]);
	      actionFrm.DelMarkedInInclude.value = "";
	      actionFrm.DelMarkedInInclude.value = resultString;
	    }
	  }
	  else if (IncExcType == '0')
	  {
	    if (bDelete)
	    {
	      resultString = ListAppendItem(lsValsToDelExc, ",", IndIDToDelete[i]);
	      actionFrm.DelMarkedInExclude.value = "";
	      actionFrm.DelMarkedInExclude.value = resultString;
	    }
	    else
	    {
	      resultString = ListDeleteItem(lsValsToDelExc, ",", IndIDToDelete[i]);
	      actionFrm.DelMarkedInExclude.value = "";
	      actionFrm.DelMarkedInExclude.value = resultString;
	    }
	  }


	  if(trObj)
				{
				  if(bDelete)
					{
						trObj.height = trObj.offsetHeight;
	          trObj.style.backgroundColor = 'bbbbbb';
	          trObj.style.textDecoration = "line-through";
						srcObj.title = "Deleted";
						srcObj.src = undodeleteImg.src;
					}
	 				else
					{
	          trObj.style.backgroundColor = 'e2e2e2';
	          trObj.style.textDecoration = "";
						srcObj.title = "click here to delete this record";
						srcObj.src = deleteImg.src;
				 	}
					srcObj.bDelete = !bDelete;
					trObj.bDelete = (bDelete?1:0);
					} // if (trobj)

			trObj	= "";

			} // for loop ends


    } //function ends

    function toggleTemplate()
			{
			 	var actionFrm = document.DataForm;
				if (actionFrm.templateExpanded.value == "1")
				{
					actionFrm.templateExpanded.value = 0;
				}
				else
				{
					actionFrm.templateExpanded.value = 1;
				}

			}

	function hideSaveLink(itype){
 			if (itype == 'hide') {
			document.getElementById('displaylink').style.display = 'none';
			document.getElementById('hidelink').style.display = 'block';
			}
		}
    function please_wait() {
        show_loader("Please wait while we are processing your request...");          // 89762 - provide feedbacks to users
    }
    alert_js_error();    // makes JS error visible in an alert popup
