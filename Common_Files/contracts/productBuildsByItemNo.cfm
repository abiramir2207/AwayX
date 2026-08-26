<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfparam NAME="form.itemListVal" DEFAULT="">
<html>
<head>
	<title>Products Selection</title>
</head>

<body>
	<cfif form.itemListVal NEQ "">
		<CFQUERY NAME="getProductLists" DATASOURCE="#application.datasource#">
			SELECT	dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID Item_ID
			FROM	dbo.BSA_Foodservice_Items_Master
			WHERE     			
				BSA_Foodservice_Items_Master.Item IN (#PreserveSingleQuotes(form.itemListVal)#)			
		</CFQUERY>
		<cfset productList = #ValueList(getProductLists.Item_ID, ",")#>
	</cfif>
	<cfoutput>
	<BR>
	<FORM METHOD="post" NAME="productBuildsByItemNoForm" ID="productBuildsByItemNoForm" STYLE="DISPLAY:INLINE">
		<!--- test area to enter the items needed --->
		<table ALIGN="center" CELLPADDING="5" CELLSPACING="">
			<tr>
				<td>
					<span ID="searchItemLabel" STYLE="color:navy;"><B>Enter Item No followed by enter key</B></span>
				</td>
			</tr>
			<tr>
				<td>
					<textarea ID="itemList" NAME="itemList"  ROWS="10" COLS="30" STYLE="width:250"> </textarea>
				</td>
			</tr>
			<tr>
				<td>
					<input TYPE="Hidden" NAME="itemListVal" ID="itemListVal" VALUE="#form.itemListVal#">
				</td>
			</tr>
			<tr>
				<td ALIGN="center">
					<CF_button
						button_name		=	""
						button_caption	=	"Submit"
						button_action	=	"dataCheck(document.all.productBuildsByItemNoForm.itemList.value);"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					> 
				</td>
			</tr>
			<tr>
				<td>
					<HR>
						<span ID="searchItemLabel" STYLE="color:red;font-style:italic;font-weight:bold">The only valid characters are Numeric and Alpha</span>
					<HR>
				</td>
			</tr>
			
		</table>
	 <!--- <INPUT TYPE="Button" NAME="Submit"  VALUE="Submit" ONCLICK="eventHandler();" STYLE="font-size: 12px;font-weight: bold;">	--->
	</FORM>
	</cfoutput>
</body>
</html>

<script>
	var varsOnly;
	function dataCheck(currItemList) {
		//retrieve the data
		//validate each line -- allowing only line feed, number and character
		//if the validation passes through, return back the itemlist
		var currItemList = trim(currItemList);	
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
			currList[count++] = "'" + removeNull(trim(varsOnly)) + "'";
		 }
		 
		 if (error > 0) {
		 	alert("The following items no are invalid: " + invalidItemList.join(",") + "!" + "\n" + " Please re-enter the item no and try it again.");
			return false;
		}
		 itemList = currList.join(",");
		 //retrive the product list based on the item no
		 //send over the itemList along with the flag
		 callerWindowObj = dialogArguments;
		 callerWindowObj.document.all.SearchForm.passed_form.value = "productBuildsByItemNoForm";
		 callerWindowObj.document.all.SearchForm.itemList.value = itemList;
		 callerWindowObj.document.all.SearchForm.submit();
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
	     return a.replace(/null$/, '');
	}
	
</script>
