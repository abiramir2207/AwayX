/* 
	Name:          	budget_basic_info.js
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	09/14/2006
	Created By:    	Deepa Kunnath
	Description:   	This page contains all the client side logic for budget basic info
	Parameters:    	
	Usage:         	
*/

function setVisibility(inputRef,tbodyRef)
{
		if(inputRef.checked)
		{	tbodyRef.style.display = '';
			disableChildren(tbodyRef,'false');
		}
		else
		{	tbodyRef.style.display = 'none';
			disableChildren(tbodyRef,'true');
		}
}	

function disableChildren(objectRef,state)
{
	var elementCollection = objectRef.all.tags("input");
	var elementCollection2 = objectRef.all.tags("select");
	for (var i = 0; i < 0; i++)
		elementCollection[i].disabled = state;
	for (var j = 0; j < 0; j++)
		elementCollection2[j].disabled = state;
}

function showSearchWindow(sUrl, originalBudgetGroupLevelId, budgetGroupLevel, FieldName, valueObj)
{
	if(budgetGroupLevel.value == 0)
	{
		alert("Please select a control level");
		return false;
	}
	if(originalBudgetGroupLevelId != budgetGroupLevel.value)
	{
		if(valueObj.value != "")
		{
			if(window.confirm("If you change the control level selections, previously selected values will be lost. \nDo you want to continue?"))
			{
				valueObj.value = "";
			}
			else
			{
				budgetGroupLevel.value = originalBudgetGroupLevelId;
				return false;
			}
		}
	}
	NewWindow(sUrl + '?FormName=frmBudget&groupLevelId=' + budgetGroupLevel.value + '&FieldName=' + FieldName , 'select_restrict_group_level_value' , 600 , 500 , 'yes' , 'yes');
	return false;		
}

function showHideFilterSelection(bShow, controlLevelIndex)
{
	var tdLinkObj = eval("document.all.levelSelection" + controlLevelIndex + "_filter_link");
	var trValuesObj = eval("document.all.levelSelection" + controlLevelIndex + "_filter_values");
	if(bShow)
	{	
		if(tdLinkObj) tdLinkObj.style.display = '';
		if(trValuesObj) trValuesObj.style.display = '';
	}
	else
	{
		if(tdLinkObj) tdLinkObj.style.display = 'none';
		if(trValuesObj) trValuesObj.style.display = 'none';
	}
}
