// JavaScript Document

//function get's called on all submits
function submitForm(command, subCommand)
{
	var thisForm	= document.groupDataForm;
	var grpLevl1	= thisForm.GroupLevel_1.value;
	var lProdGroup 	= thisForm.Product_Group_List.value; 
	var passedForm  = thisForm.passed_form.value;
	//handle for get groups
	if(subCommand == 'getGroups'){
		var currGrp = thisForm.GroupLevel_1.value;
		var groupCombinationOn = 0;
		var groupCombinationOnObj = eval("thisForm.groupCombinationOn");
		thisForm.passed_form.value = "";
		thisForm.Product_List.value = "";
		thisForm.itemList.value = "";

		if(groupCombinationOnObj.value == 1){
			groupCombinationOn = 1;
		}

		if(groupCombinationOn == 1){
			var anySelected = checkGroupOfGroupsMemberSelection();
			if(!anySelected){
				alert("Please set a group name");
				return false;
			}
			var selGrp = thisForm.GroupLevel.value;
		}else{
			var selGrp = thisForm.GroupLevel.options[thisForm.GroupLevel.selectedIndex].value;
		}

		if (currGrp != selGrp && currGrp!= "" )//&& lProdGroup != "")D30271:simplifiy product group search
		{
			thisForm.clearLevel.value = 1
			
/*D30271:simplifiy product group search
if(confirm("You will lose your current selection. Do you want to continue?"))
			{
				//thisForm.GroupLevel_1.value = selGrp;
				thisForm.clearLevel.value = 1
			}
			else
			{
				return;
			}

D30271:simplifiy product group search*/
		}
	}

	if(command == 'import' || command == 'validate_import'){
		if(grpLevl1 == "" )  // WR73275: this was lettting the Group form submit without level 1 products        && passedForm != "comCreateListForm"
		{
			alert("You must add a Group to a pricing level before importing.");
			return;
		}
	}

	if(command == 'selectMultiLevelView' && subCommand == 'removeFromPricingLevel'){
		//SELECTED GROUP LENGTH
		var level1= document.getElementById("Level_1_Hidden").value.length;
		var level2= document.getElementById("Level_2_Hidden").value.length;
		var level3= document.getElementById("Level_3_Hidden").value.length;
		//REMOVED GROUP LENGTH
		var Removelevel1= document.getElementById("RemoveFromLevel_1").value.length;
		var Removelevel2= document.getElementById("RemoveFromLevel_2").value.length;
		var Removelevel3= document.getElementById("RemoveFromLevel_3").value.length;

//77408 Product Group sequencing START
if(thisForm.numberOfLevels.value > 3){
	var level4= document.getElementById("Level_4_Hidden").value.length;
	var level5= document.getElementById("Level_5_Hidden").value.length;
	var level6= document.getElementById("Level_6_Hidden").value.length;
	var level7= document.getElementById("Level_7_Hidden").value.length;		
	var level8= document.getElementById("Level_8_Hidden").value.length;		

	var Removelevel4= document.getElementById("RemoveFromLevel_4").value.length;
	var Removelevel5= document.getElementById("RemoveFromLevel_5").value.length;
	var Removelevel6= document.getElementById("RemoveFromLevel_6").value.length;
	var Removelevel7= document.getElementById("RemoveFromLevel_7").value.length;
	var Removelevel8= document.getElementById("RemoveFromLevel_8").value.length;
}

	if(thisForm.numberOfLevels.value == 3){
//Level 2 and Level 3 are not EMPTY and Level 1 is EMPTY
		if((level2 != 0 || level3 != 0) && (Removelevel1 == level1)){
				alert('Level 1 cannot be empty when there are groups in other Levels.');
				return false;
			}
		//Level 3 not EMPTY and Level 2 is EMPTY	
		if((level2 == Removelevel2 )&& level3 != 0){
				alert('Level 2 cannot be empty when there are groups in Level 3.');
				return false;
			}	
}//77408 Product Group sequencing END
}
	//set the action value then submit
	thisForm.command.value = command;
	thisForm.sub_command.value = subCommand;
	thisForm.submit();

}//end submitForm function

//function to see if atleast one group member was selected - group of groups
function checkGroupOfGroupsMemberSelection()
{
	//check if atleast one drop down for group combination members is selected, otherwise the result set might be huge and can affect performance
	var anySelected = 0;
	var oSelect, oSelects = document.getElementsByTagName("SELECT");
	var i, oSelectLen = oSelects.length;
	var selectStartLen, selectStart = "Group_Combination_Member_";
	selectStartLen = selectStart.length;
	for(i=0;i<oSelectLen;i++)
	{
		oSelect = oSelects[i]
		if(oSelect.name.substr(0, selectStartLen) == selectStart)
		{
			if(oSelect.selectedIndex > 0)
			{
				anySelected = 1;
				break;
			}
		}
	}
	return anySelected;
}

//function get's groups for a particular level
function getGroups(level)
{
	var thisForm = document.groupDataForm;
	var bClearLevel = 0;
	var groupLevelSelect = eval("thisForm.GroupLevelSelect_" + level + ".value");
	var currentSearchLevel = eval("thisForm.Current_Search_Level_" + level).value;
	if(isNaN(currentSearchLevel)) currentSearchLevel = 0;
	if(currentSearchLevel !=0 && currentSearchLevel!=groupLevelSelect )
	{
		bClearLevel = 1;
	}
	
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
	}	
	
	var levelField = eval("thisForm.Level_" + level);
	//var groupLevel = eval("thisForm.GroupLevel_" + level);
	
	var parentProdHierId = eval("thisForm.Parent_Product_Hierarchy_ID_" + level);
	
	var clearLevel = eval("thisForm.Clear_Level_" + level);
	if(bClearLevel)
	{
		clearLevel.value = 1;
	}
		
	thisForm.Pricing_Level_ID.value = level;
	
	//flush fields and set values
	//levelField.value = "";
	parentProdHierId.value = "";
	//groupLevel.value = groupLevelSelect.value;
	thisForm.submit();

		
}//end getGroups function

//function get's groups from next hierarchy level
function getNextLevel(level, parentId, childId)
{

	var thisForm = document.groupDataForm;

	var levelField = eval("thisForm.Level_" + level);
	var parentHierarchyIdField = eval("thisForm.Parent_Product_Hierarchy_ID_" + level);
	//var childHierarchyIdField = eval("thisForm.GroupLevel_" + level);
	var childHierarchyIdField = eval("thisForm.GroupLevelSelect_" + level);
	var nextLevel = eval("thisForm.Next_Level_" + level);
	var parentProdHierId = eval("thisForm.Parent_Product_Hierarchy_ID_" + level);
	var clearLevel = eval("thisForm.Clear_Level_" + level);
	clearLevel.value = 1;

	
	//flush fields and set values
	//levelField.value = "";
	parentProdHierId.value = "";
	childHierarchyIdField.value = childId;
	parentHierarchyIdField.value = parentId;
	nextLevel.value = level;
	thisForm.Pricing_Level_ID.value = level;
	thisForm.submit();


}//end getNextLevel function

function add(level, id)
{

	var thisForm = document.groupDataForm;
	var groupLevel = eval("thisForm.GroupLevel_" + level);
	var groupCombinationOn = 0;
	var groupCombinationOnObj = eval("thisForm.groupCombinationOn");
	
	if(groupCombinationOnObj.value == 1)
	{
		groupCombinationOn = 1;
	}
	if(groupCombinationOn == 1)
	{
		var groupLevelSelect = eval("thisForm.GroupLevelSelect_" + level);

	}
	else
	{
		if(id == 1){
		var groupLevelSelect = eval("thisForm.GroupLevelSelect_" + level + ".options[thisForm.GroupLevelSelect_" + level + ".selectedIndex]");
		}else{
			var groupLevelSelect = eval("thisForm.GroupLevelSelect_" + level);
		}
	}
	/*
		76386 :: Ability to add [product group] when items already exist
	if (groupLevel.value != groupLevelSelect.value && groupLevel.value != "")
	{
		alert("Groups must be of the same level. Remove any groups that currently exist at another level.");
		return;
	}*/
	/* To add all the selected groups, remove the datagrid filter, before adding
	products to the "pricing level". This will ensure that all the selected groups are included.
	*/
	if (typeof(datagrid) != "undefined"){
		datagrid.fnFilter('');
	}
	groupLevel.value = groupLevelSelect.value;
	groupLevelSelect.value = "";
	thisForm.Pricing_Level_ID.value = level;
	thisForm.sub_command.value = 'add';

	thisForm.submit();
	//submitForm('import');


}//end add function

function cancelImport()
{
	var thisForm = document.groupDataForm;
	thisForm.command.value = 'selectListView';	
	thisForm.sub_command.value = 'add';	
	thisForm.GroupLevel_1.value = "";
	thisForm.submit();
}//end add function

function enableGroupSelect(groupId, groupType)
{
	
	var thisForm = document.groupDataForm;
	
	var selLevelId = thisForm.Pricing_Level_ID.selectedIndex;
	
	//if pricing level ins't selected then alert for it and return
	if (selLevelId == 0)
	{
		alert("Please select a level.");
		thisForm.Product_Group_Level_ID.selectedIndex = 0;
		return;
	}

	var groupList = thisForm.Product_Group_List.value;
	var level = thisForm.Pricing_Level_ID.value;
	var prodList = thisForm.Product_List.value;
	var prodGrpLevlId = thisForm.Product_Group_Level_ID.value;
	var groupLevelField = eval("thisForm.GroupLevel_" + level);
	var grpLevlId = groupLevelField.value;

	//if it's a hierarchy level, then do tree validation
	if(groupType == 2)
	{
		if (!checkHierarchyLevel(groupId))
		{
			return;
		}
	}

	
	//check to see if a group already exists in this level
	if(grpLevlId != groupId && grpLevlId != "")
	{	
		nextLevel = parseFloat(level) + 1;
		alert("A group already exists in level " + level + ".");
		thisForm.Product_Group_Level_ID.selectedIndex = 0;
		return;
		//check hierarchy level
		if (!checkHierarchyLevel(groupId))
		{
			return;
		}
	}
	
	//create an array out of the list and loop over to see which group to enable
	var aGrpLst = groupList.split(",");

	for(i=0;i<=aGrpLst.length - 1;i++)
	{
		//evaluate for the tr and select objects
		
		var grpListId = aGrpLst[i];

		var trObj = eval("oGroupTR_" + grpListId);
		var selObj = eval("document.all.oGroupSelect_" + grpListId);
		
		//enable the element if the group id equals the one in the list
		if (groupId == grpListId)
		{

			trObj.disabled = false;
			selObj.disabled = false;
		}
		//disable otherwise
		else
		{
			trObj.disabled = true;
			selObj.disabled = true;
		}
	}
}

//function to validate level relationships for groups
function checkLevel(levelId)
{
	//handle for no level id
	if (levelId == "")
	{
		return
	}

	var thisForm = document.groupDataForm;
	
	var groupLevel1 = thisForm.GroupLevel_1.value;
	var groupLevel2 = thisForm.GroupLevel_2.value;
	var groupLevel3 = thisForm.GroupLevel_3.value;
			
	//if level id is 2 then we have to make sure that level 1 is holding a group
	if (levelId == 2)
	{
		//check group level 1
		if(groupLevel1 == "")
		{
			alert("A group needs to be added to level 1 first.");
			thisForm.Pricing_Level_ID.selectedIndex = 0;
		}
		
	}
	//if level id is 3 then we have to make sure that level 1 and level 2 are holding groups
	else if (levelId == 3)
	{
		//check group level 1
		if(groupLevel1 == "")
		{
			alert("Groups need to be added to levels 1 and 2 first.");
			thisForm.Pricing_Level_ID.selectedIndex = 0;
			return;
		}
		
		//check group level 2
		if(groupLevel2 == "")
		{
			alert("Groups need to be added to levels 1 and 2 first.");
			thisForm.Pricing_Level_ID.selectedIndex = 1;
		}
	}
}

//function to validate hierarchy level relationships for groups
function checkHierarchyLevel(groupId)
{
	var bIsValid = true;
	var thisForm = document.groupDataForm;
	var level = thisForm.Pricing_Level_ID.value;
	var groupLevel1 = thisForm.GroupLevel_1.value;
	var groupLevel2 = thisForm.GroupLevel_2.value;
	var groupLevel3 = thisForm.GroupLevel_3.value;
	
	//if level id is 2 then we have to check the hierarchy level
	if (level == 2)
	{
		//check group level 1
		if(groupLevel1 > groupId)
		{
			alert("Product Hierarchy has children that exist in higher levels.");
			thisForm.Product_Group_Level_ID.selectedIndex = 0;
			bIsValid = false;
		}
		
	}
	//if level id is 2 then we have to check the hierarchy level
	else if (level == 3)
	{
		//check group level 1
		if(groupLevel1 > groupId)
		{
			alert("Product Hierarchy has children that exist in higher levels.");
			thisForm.Product_Group_Level_ID.selectedIndex = 0;
			bIsValid = false;
		}
		
		//check group level 2
		if(groupLevel2 > groupId)
		{
			alert("Product Hierarchy has children that exist in higher levels.");
			thisForm.Product_Group_Level_ID.selectedIndex = 0;
			bIsValid = false;
		}
	}
	
	return bIsValid;
}

//function will set the group level fields with the value of the group level selected
function setGroupLevel(prodGroupId)
{
	var thisForm = document.groupDataForm;
	var level = thisForm.Pricing_Level_ID.value;
	var prodGrpLevlId = thisForm.Product_Group_Level_ID.value;

	var groupLevelField = eval("thisForm.GroupLevel_" + level);
	var levelField = eval("thisForm.Level_" + level);
	groupLevelField.value = prodGrpLevlId;
	
	var selObj = eval("document.all.oGroupSelect_" + prodGroupId);
	
	//clear the level field and repopulate with what was selected
	levelField.value = "";
	for(i=0;i<=selObj.length - 1;i++)
	{
		if(selObj[i].selected)
		{
			levelField.value = listAppend(levelField.value, selObj[i].value);
		}
	}
}

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


function removeFromLevel(iLevelIndex, oObj)
{

	if(oObj.type == "checkbox")
	{
		if(!oObj.checked)//if no longer checked
		{
			var sValue = oObj.value;
			var oLevelObj = document.getElementById("Level_" + iLevelIndex + "_Hidden");
			if(oLevelObj)
			{
				var iLevelNewValue, iLevelValue = oLevelObj.value;
				iLevelNewValue = ListDeleteItem(iLevelValue, ",", sValue, 1);
				oLevelObj.value = iLevelNewValue;
			}
		}
	}

}