/* 
	Name:          	budget_group.js
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/09/2006
	Created By:    	Deepa Kunnath
	Description:   	This page contains all the client side logic for budget groups
	Parameters:    	
	Usage:         	
*/

function submitAddEditBudgetGroup()
{
	document.frmBudget.command.value = 'saveBudgetGroup';
	document.frmBudget.submit();
	return false;
}

function submitCreateBudget()
{
	document.frmBudget.command.value = 'saveBudget';
	document.frmBudget.submit();
	return false;
}

function addTableRowCreateBudget()
{
	var oCreateBudgetTable = document.all.createBudgetTable;
	var rowLen = oCreateBudgetTable.rows.length;
	var oNewRow = oCreateBudgetTable.insertRow(rowLen);
	var sampleRow = oCreateBudgetTable.rows[1];
	//var sampleRow = oCreateBudgetTable.rows[rowLen-1];
	var i, j, colLen = sampleRow.cells.length;
	var oNewCell, inputCol;
	var sInnerHTML;
	
	for (i=0; i<colLen; i++)
	{
		var oNewCell = oNewRow.insertCell(i);
		sInnerHTML = sampleRow.cells(i).innerHTML;
		oNewCell.innerHTML = changeFieldNames(sInnerHTML, "1", rowLen);
		//oNewCell.innerHTML = incrementName(sInnerHTML, rowLen)
		
		inputCol = oNewCell.getElementsByTagName("input");
		for (j=0; j<inputCol.length; j++)
		{
			if (inputCol[j].type == "text" || inputCol[j].type == "hidden")
			{
				inputCol[j].value = "";
			}
			
			if (inputCol[j].type == "checkbox")
			{
				inputCol[j].checked = false;
			}
		}
		
		inputCol = oNewCell.getElementsByTagName("select");
		for (j=0; j<inputCol.length; j++)
		{
			inputCol[j].selectedIndex = 0;
		}
		if(oNewCell.all.Budget_Count)
		{
			oNewCell.all.Budget_Count.value = rowLen;
		}
	}
	
	return false;
}

function changeFieldNames(checkHTML, checkNumber, replaceNumber)
{
	var newHTML = checkHTML;
	var regExp = new RegExp("_" + checkNumber, "igm");
	newHTML = newHTML.replace(regExp, "_" + replaceNumber);
	return newHTML;
}
