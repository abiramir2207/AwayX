// JavaScript Document
function dataCheck(theForm) {
	var varsOnly;
	//retrieve the data
	//validate each line -- allowing only line feed, number and character
	//if the validation passes through, return back the itemlist
	//get currItemList
	//get hidden form
	//document.all.comCreateListForm.itemList.value
	var oElem = theForm.item("itemList");
	var currItemList = trim(oElem.value);
	var currForm = trim(theForm.item("hiddenForm").value);	
	var matchWord = new RegExp("\\s*([^a-zA-Z0-9_]*\\w+[^a-zA-Z0-9_]*)\\s*", "g");
	var matched, return_val, itemList = "", count = 0, invalid_count = 0, error = -1;
	var currList = new Array();
	var invalidItemList = new Array();
	
	while ((matched = matchWord.exec(currItemList)) != null) {
		 varsOnly = RegExp.$1;
		 
		 if (isNotValid() >= 0)
		 {
			invalidItemList[invalid_count++] = "'" + trim(varsOnly) + "'";
			error = 1;
		 }
		//currList[count++] = "\'" + removeNull(trim(varsOnly)) + "\'";
		currList[count++] = removeNull(trim(varsOnly));
	 }
	 
	 
	 if (error > 0) {
		alert("The following items no are invalid: " + invalidItemList.join(",") + "!" + "\n" + " Please re-enter the item no and try it again.");
		return false;
	}
	 itemList = currList.join(",");
	 //retrieve the product list based on the item no
	 //send over the itemList along with the flag
	 callerWindowObj = dialogArguments;

	 eval("callerWindowObj.document.all." + currForm + ".passed_form.value = 'comCreateListForm' ");
	 eval("callerWindowObj.document.all." + currForm + ".itemList.value" + "=" + "\'" + itemList + "\'" );
	 eval("callerWindowObj.document.all." + currForm + ".submit()" );
	 window.close();
return true;
}
function isNotValid() {
	//check if any character is not alpahnumeric
	rExp = /[^a-zA-Z0-9_]/gi;
	var isMatched = varsOnly.search(rExp);
	
	if ((isMatched >= 0) && (varsOnly[isMatched] == null)) {
		varsOnly =  varsOnly.substring(0,isMatched)+ varsOnly.substr(isMatched+1);
		while (isMatched >= 0)
		{
		//test if it's null
			if (varsOnly[isMatched] == null ) {
				varsOnly =  varsOnly.substring(0,isMatched)+ varsOnly.substr(isMatched+1);
				isMatched = varsOnly.search(rExp);
				}
			else {
			break;
			}
		}
	 }
	return isMatched;

}

function trim(a){
  return a.replace(/^\s+/,'').replace(/\s+$/,'')
}

function removeNull(a)
{	
	while ( a.charCodeAt(a.length - 1 ) == 160 ) {
		a = a.substr(0, a.length-1);
		}
	 return a;
}
	
