// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action,compId)
{
	var actionFrm = document.DataForm;
		
	//if action is edit set the compId hidden value, then reset the action to the existing state
	if (action == "edit")
	{
		actionFrm.compId.value = compId;
		actionFrm.returnTo.value = actionFrm.display.value;
	}
	if (action == "add")
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
		
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Add Component //////////////////////////////////////////		
function addComp()
{
	
	var actionFrm = document.DataForm;
		
	//do validation
	if (trim(actionFrm.Clause_Order.value) == "")
	{
		alert("Please enter a clause order");
		return;
	}
		
	//set hidden form fields and submit
	actionFrm.command.value = 'addComp';
	actionFrm.display.value = 'active';
	actionFrm.submit();
	return false;	
}

///////////////////////////////////   Delete Component //////////////////////////////////////////		
function deleteComp(compId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected component?"))
	{
		actionFrm.compId.value = compId;
		actionFrm.command.value = 'delete';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Deactivate Selected List of Components //////////////////////////////////////////		
function deactivateSelComps()
{
	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected components?"))
	{
					
		actionFrm.command.value = 'deactSel';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Deactivate Single Component //////////////////////////////////////////		
function deactivateComp(compId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected component?"))
	{
		actionFrm.compId.value = compId;
		actionFrm.command.value = 'deact';
		actionFrm.display.value = 'active';
			actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Activate Selected List of Components //////////////////////////////////////////	
function activateSelComps()
{

	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to activate the selected names?"))
	{
					
		actionFrm.command.value = 'actSel';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Activate Single Component //////////////////////////////////////////	
function activateComp(compId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to activate the selected name?"))
	{
		actionFrm.compId.value = compId;
		actionFrm.command.value = 'act';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Update Component //////////////////////////////////////////
function upadateComp(compId)
{

	var actionFrm = document.DataForm;

	//do validation
	if (trim(actionFrm.compName.value) == "")
	{
		alert("Please provide a component name");
		return;
	}
		

	actionFrm.compId.value = compId;
	actionFrm.command.value = 'update';
	actionFrm.display.value = actionFrm.returnTo.value;
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Select All Checkboxes //////////////////////////////////////////
function selectAll(thisObj)
{
	var chObjs = document.all.CID;
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

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Rebill Package ///////////////////////////////
///////////////////////////////////////////////////////////////////////////////

//////////////////////////   Add Rebill Package  ////////////////////////////
function fnValidateForm()
{
	var actionFrm = document.DataForm;
  var hasErrors = 0;
  var strErrors = "";
  
  if (trim(actionFrm.title.value) == "")
	{
		hasErrors = 1;
    strErrors = "- Please provide a Title for the Rebill Package";
	}
   
  var rdoReason=document.getElementsByName("Reason_Default");
  var reasonDefaultVal=0;
  for(var i=0;i<rdoReason.length;i++)
  {
    if(rdoReason[i].checked)
    {
      reasonDefaultVal = rdoReason[i].value;
      break; // No need to check the rest since only one can be checked.
    }  
  }
  actionFrm.Selected_Reason_Code_ID.value = reasonDefaultVal;    
   
  var i;
  
  var bChecked = 0;
  var isChecked = 0;
  var reasonDefaultInChecked = 0;
  var bReasonDefaultInChecked = 0;  
  var varReasonList = actionFrm.All_Reason_Code_ID_List.value.split(",");
  actionFrm.Selected_Reason_Code_ID_List.value = "";
  for (i=0;i<varReasonList.length;i++)
  { 
    isChecked = eval("actionFrm." + varReasonList[i] + ".checked");
    if(isChecked == 1)
    {
      bChecked = 1;	
      if (actionFrm.Selected_Reason_Code_ID_List.value == "")
      {
        actionFrm.Selected_Reason_Code_ID_List.value = eval("actionFrm." + varReasonList[i] + ".value")
      } 
      else
      {
        actionFrm.Selected_Reason_Code_ID_List.value = actionFrm.Selected_Reason_Code_ID_List.value + "," + eval("actionFrm." + varReasonList[i] + ".value");
      }
      if(reasonDefaultVal == eval("actionFrm." + varReasonList[i] + ".value"))
      {
        bReasonDefaultInChecked = 1;
      }        
    }
  }
  
  if(bChecked == 0)
  {
    hasErrors = 1;
    if (strErrors == "")
    {
      strErrors = "- Please select a Reason Code";
    }
    else
    {
      strErrors = strErrors + "\n- Please select a Reason Code";
  	}
  }  
  
  if (reasonDefaultVal == 0)  
  {
    hasErrors = 1;
    if (strErrors == "")
    {
      strErrors = "- Please pick a default for Reason Code";
    }
    else
    {
      strErrors = strErrors + "\n- Please pick a default for Reason Code";
  	}
  }

  if (bReasonDefaultInChecked == 0 && reasonDefaultVal != 0)  
  {
    hasErrors = 1;
    if (strErrors == "")
    {
      strErrors = "- Please pick the default from a selected Reason Code";
    }
    else
    {
      strErrors = strErrors + "\n- Please pick the default from a selected Reason Code";
  	}
  }
  /*
	  Dev Notes: D23299/Anand Rao/06-May-10
	  Rebill Integration - Bugs / Modifications
  */

 if(actionFrm.appSetting_getDD_Show_Classification.value == '1')
 {
  var rdoClass=document.getElementsByName("Class_Default");
  var classDefaultVal=0;
  for(var i=0;i<rdoClass.length;i++)
  {
    if(rdoClass[i].checked)
    {
      classDefaultVal = rdoClass[i].value;
      break; // No need to check the rest since only one can be checked.
    }  
  }
  actionFrm.Selected_Classification_ID.value = classDefaultVal;  
 }
  var j;   
  var bChecked = 0;
  var classDefaultInChecked = 0;
  var bClassDefaultInChecked = 0;
  var isChecked = 0;
 if(actionFrm.appSetting_getDD_Show_Classification.value == '1')
 {
    var varClassList = actionFrm.All_DD_Classification_ID_List.value.split(",");
    actionFrm.Selected_Classification_ID_List.value = "";
    for (i=0;i<varClassList.length;i++)
    { 
      isChecked = eval("actionFrm." + varClassList[i] + ".checked");
      if(isChecked == 1)
      {
        bChecked = 1;	
        if (actionFrm.Selected_Classification_ID_List.value == "")
        {
          actionFrm.Selected_Classification_ID_List.value = eval("actionFrm." + varClassList[i] + ".value")
        } 
        else
        {
          actionFrm.Selected_Classification_ID_List.value = actionFrm.Selected_Classification_ID_List.value + "," + eval("actionFrm." + varClassList[i] + ".value");
        }
        
        if(classDefaultVal == eval("actionFrm." + varClassList[i] + ".value"))
        {
          bClassDefaultInChecked = 1;
        }    
      }
    }
    if(bChecked == 0)
    {
      hasErrors = 1;
      if (strErrors == "")
      {
        strErrors = "- Please select a DD Classification";
      }
      else
      {
        strErrors = strErrors + "\n- Please select a DD Classification";
    	}
    }  
    
  
  
    if (classDefaultVal == 0)  
    {
        hasErrors = 1;
        if (strErrors == "")
        {
          strErrors = "- Please pick a default for DD Classification";
        }
        else
        {
          strErrors = strErrors + "\n- Please pick a default for DD Classification";
      	}
    }
    
    if (bClassDefaultInChecked == 0 && classDefaultVal!=0)  
    {
        hasErrors = 1;
        if (strErrors == "")
        {
          strErrors = "- Please pick the default from a selected DD Classification";
        }
        else
        {
          strErrors = strErrors + "\n- Please pick the default from a selected DD Classification";
      	}
    }  
}
   
  if (actionFrm.chkDefaultMessage.checked == true)
  {
    if (trim(actionFrm.rebillMessage.value) == "")
  	{
      hasErrors = 1;
      if (strErrors == "")
      {
        strErrors = "- Please enter Rebill Message";
      }
      else
      {
        strErrors = strErrors + "\n- Please enter Rebill Message";
  		}
  	}
  }
  else
  {
    actionFrm.rebillMessage.value = "";
    actionFrm.chkDefaultMessage.value= 0 ;
  }
 
  if (hasErrors == 1)
  {
  strErrors = "Errors Found:\n" + strErrors;
    alert(strErrors);
    return false;
  }
  return true;
}

////////////////////////////// Add Rebill Package ///////////////////////////

function fnAddRebillPackage()
{
	
	var actionFrm = document.DataForm;
		
	//do validation
	var bReturnVal = fnValidateForm();
  
  if (bReturnVal == false)
  {
    return false;
  }
  	
	//set hidden form fields and submit
	actionFrm.command.value = 'addRebillPackage';
	actionFrm.display.value = 'active';
	actionFrm.submit();
	return false;
}

/////////////////////////////  Delete Rebill Package //////////////////////////

function deleteRebillPackage(DDRebillPackageHdrID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected Rebill Package?"))
	{
		actionFrm.DD_Rebill_Package_Hdr_ID.value = DDRebillPackageHdrID;
		actionFrm.command.value = 'delete';
		actionFrm.submit();
		return false;
	}
		
	return false;
}


//////////////////////////   Deactivate Rebill Package ////////////////////////

function deactivateRebillPackage(DDRebillPackageHdrID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected Package?"))
	{
		actionFrm.DD_Rebill_Package_Hdr_ID.value = DDRebillPackageHdrID;
		actionFrm.command.value = 'deActivate';
		actionFrm.display.value = 'active';
			actionFrm.submit();
		return false;
	}
		
	return false;
}

//////////////////////////  Activate Rebill Package  ///////////////////////////
function activateRebillPackage(DDRebillPackageHdrID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to activate the selected name?"))
	{
		actionFrm.DD_Rebill_Package_Hdr_ID.value = DDRebillPackageHdrID;
		actionFrm.command.value = 'activate';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

//////////////////////////////  Change Default  ////////////////////////////////// 
function changeDefault(Identifier_ID, Identifier_Number)
{
	if(confirm("Are you sure you want to change the default to " + Identifier_Number + "?"))
	{
		Change_Default_ID.New_Default_ID.value = Identifier_ID;
		Change_Default_ID.submit();
		return false;
	}
		
	return false;
}

/////////////////////////////////////////////////////////////

function textCounter(field,cntfield,maxlimit) 
{
	var actionFrm = document.DataForm;
  var variableIDSizeList = actionFrm.iVariableIDSizeList.value;
  var varNameList = "";
  var varFieldLen = field.value.length;
  var varFieldLenMan = 0;
  var varFieldOriginal = field.value;
  var varFieldOriginalTemp ="";
  var varFieldValue = field.value.toLowerCase();
  var varName = "";
  var varSize = 0;
  var strFieldToken = "";
  var strReplaced = "";
  var variableToken = variableIDSizeList.split("|");
 
  for (var i = 0;i < variableToken.length; i++)
  {
    varNameList = variableToken[i].split("_");
    for (var j=0;j<1;j++)
    {
      varName = varNameList[0].toLowerCase();
      varSize = varNameList[1];
      strSubstitute = "";
      for(k = 0;k<varSize;k++)
      {
        strSubstitute = strSubstitute + '^';
      }
      while (varFieldValue.indexOf(varName.toLowerCase()) != -1)
      {
        varFieldValue = varFieldValue.replace(varName,strSubstitute);
        varFieldLenMan = parseInt(varFieldLenMan) - parseInt(varName.length) + parseInt(varSize);
      }
    } 
  }  

  var strFieldTokenOriginal = varFieldOriginal.split(" ");
  var strFieldToken = varFieldValue.split(" ");
  var varFieldOriginalLen = 0;
  var varFieldValueLen = 0;
  var strFieldValueToSet = "";
  if (varFieldOriginal != "") 
  {
    for (i=0;i<strFieldToken.length;i++)
    { 
      varFieldOriginalTempLen = varFieldOriginalLen + strFieldTokenOriginal[i].length + 1;
      varFieldValueLen = varFieldValueLen + strFieldToken[i].length + 1;
      if (varFieldValueLen > maxlimit)
      {
        varFieldValueLen = varFieldValueLen - strFieldToken[i].length - 1;
        break;
      }
      else
      {
        if (strFieldValueToSet == "")
        {
          strFieldValueToSet = strFieldTokenOriginal[i]; 
        }
        else
        {
          strFieldValueToSet = strFieldValueToSet + " " + strFieldTokenOriginal[i];
        }
      }
    }  
  }
 
  if (varFieldValue.length > maxlimit) // if too long...trim it!
  {
    field.value = field.value.substring(0, (maxlimit-varFieldLenMan));
    if (maxlimit - varFieldValue.length == -1)
    {
      cntfield.value =0;
    }
    else
    {
      cntfield.value = maxlimit - varFieldValue.length;
    }
  }
  else
  {
    cntfield.value = maxlimit - varFieldValueLen;
  }
}

function textCounterRebillInt(field,cntfield,maxlimit) 
{
   if (field.value.length> maxlimit)
  {
    field.value = field.value.substring(0, maxlimit-1);
  }
  else
  {
    cntfield.value = maxlimit - field.value.length;
  }
}

function textCountCheck(field,maxlimit) 
{
  var fieldLen = field.value.length;
  if (fieldLen > maxlimit)
  {
    strMessage = "Only " + maxlimit.toString() + " characters allowed. Additional content has been truncated.";
    field.value = field.value.substring(0, maxlimit-1);
    alert(strMessage);
  }
}
 
function changeSelectWidth(selObj)
	{
		var maxSize = 3000;
		var minSize = 4;
		var optLen = selObj.options.length;
		var curSize = selObj.size;		
		if(optLen != curSize)
		{
			if(optLen > maxSize)
			{
				optLen = maxSize;
			}
			else if(optLen < minSize)
			{
				optLen = minSize;
			}
			selObj.size = optLen;
		}		
	}

////////////////////// Update the Rebill Package Record ///////////////////////

function updateRebillPackage(DDRebillPackageHdrID)
{

	var actionFrm = document.DataForm;
  // fnValidateForm();
  // do valiation of Data
  var bReturnVal = fnValidateForm();
  
  if (bReturnVal == false)
  {
    return false;
  }
	actionFrm.DD_Rebill_Package_Hdr_ID.value = DDRebillPackageHdrID;
	actionFrm.command.value = 'update';
	actionFrm.display.value = actionFrm.returnTo.value;
	actionFrm.submit();
	return false;
}
  

///////////////////////////////////   Deactivate Single Package //////////////////////////////////////////		
function deactivatePackage(DDRebillPackageHdrID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to deactivate the selected Rebill Package?"))
	{
		actionFrm.DD_Rebill_Package_Hdr_ID.value = DDRebillPackageHdrID;
		actionFrm.command.value = 'deActivate';
		actionFrm.display.value = 'active';
	  actionFrm.submit();
		return false;
	}
		
	return false;
}
  
///////////////////////////////   Deactivate Selected List of Packages ///////////////////////////////////		
function deactivateSelPackages()
{
	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to deactivate the selected Packages?"))
	{
					
		actionFrm.command.value = 'deactSel';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;
	}
		
	return false;
}
  
///////////////////////////////////   Activate Selected List of Currencies //////////////////////////////////////////	
function activateSelPackages()
{

	var actionFrm = document.DataForm;
		
	if(!Any_Object_Checked(DataForm.CID))
	{
		alert("You haven't selected any items.");
		return false;
	}
	if(confirm("Do you really want to activate the selected Packages?"))
	{
					
		actionFrm.command.value = 'actSel';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}  
  
///////////////////////////////////   Activate Single Package //////////////////////////////////////////	
function activatePackage(DDRebillPackageHdrID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to activate the selected Rebill Package?"))
	{
		actionFrm.DD_Rebill_Package_Hdr_ID.value = DDRebillPackageHdrID;
		actionFrm.command.value = 'activate';
		actionFrm.display.value = 'inActive';
		actionFrm.submit();
		return false;
	}
		
	return false;
}  
  
///////////////////////////////////  Delete  Package   //////////////////////////////////////////		
function deletePackage(DDRebillPackageHdrID)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected Rebill Package?"))
	{
		actionFrm.DD_Rebill_Package_Hdr_ID.value = DDRebillPackageHdrID;
		actionFrm.command.value = 'delete';
		actionFrm.submit();
		return false;
	}
		
	return false;
}
  
  
///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm2(action,DDRebillPackageHdrID)
{
	var actionFrm = document.DataForm;
		
	//if action is edit set the DDRebillPackageHdrID hidden value, then reset the action to the existing state
	if (action == "edit")
	{
		actionFrm.DD_Rebill_Package_Hdr_ID.value = DDRebillPackageHdrID;
		actionFrm.returnTo.value = actionFrm.display.value;
	}
		
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}
 
 
/////////////////////// Show/Hide the message box and table ///////////////////
function fnHideMsg()
{
	if (document.all.chkDefaultMessage)
  {
    if (document.all.chkDefaultMessage.checked == 1)
    {
      document.getElementById('divMsg').style.display = 'block'; 
    }
    else
    {
       document.getElementById('divMsg').style.display = 'none'; 
    }
  }
}


function updateRebillVariables()
{
   	var actionFrm = document.DataForm;
		actionFrm.command.value = 'updVarSize';
		actionFrm.display.value = 'varsize';
		actionFrm.submit();
		return false;

}

function updateRebillSettings()
{
   	var actionFrm = document.DataForm;
		actionFrm.command.value = 'updRebillSettings';
		actionFrm.display.value = 'rebillSettings';
		actionFrm.submit();
		return false;

}

function fnInsertVal(varInsVariable)
{
   	var actionFrm = document.DataForm;
    var txtVal =  actionFrm.rebillMessage.value;
    
    /*
	    Dev Notes: D23299/Anand Rao/06-May-10
	    Rebill Integration - Bugs / Modifications
    */

    if (varInsVariable.indexOf("amount") > -1 || varInsVariable.indexOf("AMOUNT") > -1)   
    {
      varInsVariable = '$' + varInsVariable;
    }

    if (txtVal == '')
    {
      txtVal =  varInsVariable ;
    }
    else
    {
       txtVal =  (txtVal.replace(/^[\s\xA0]+/, "").replace(/[\s\xA0]+$/, "")) + " " + varInsVariable ; // the replace function will trim the leading and trailing white spaces
    }  
    
    actionFrm.rebillMessage.value = txtVal;
}