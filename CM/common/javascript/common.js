//common javascript functions

function showDistributorSearchWindow(formName) 
{
	NewWindow("/cm/search/PM_select_distributors.cfm?Formname=" + formName, "distributorwindow", 800, 600, "yes", "yes");
	return false;
}

function showOperatorSearchWindow(formName) 
{
	NewWindow("/cm/search/PM_select_operators.cfm?Formname=" + formName, "distributorwindow", 800, 600, "yes", "yes");
	return false;
}

function showProductSearchWindow(formName) 
{
	NewWindow("/cm/search/product_Select_V1.cfm?Formname=" + formName, "productwindow", 800, 600, "yes", "yes");
	return false;
}

function showWindow(file,formName) 
{
	NewWindow(file + "?formName=" + formName, "window", 800, 600, "yes", "yes");
	return false;
}

function submitForm(formObj,command) 
{
	
	formObj.command.value = command;

}