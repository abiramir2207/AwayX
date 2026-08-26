<CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	
<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></script>

</HEAD>

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET ThisPage = CGI.SCRIPT_NAME>
<cfparam name="URL.mode" 	default="1">
<cfparam name="FORM.mode" 	default="#URL.mode#">
<cfset PAGE_NAME = FORM.mode>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<!------ <SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT> ----->
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<script language="JavaScript">
	function deleteRow(srcInput, sVal, skeyword)
	{
		var srcObj = event.srcElement;		
		var trObj = getParentObject(srcObj, "tr");
		var bDelete = true;
		var srcInputObj = eval("document.all." + srcInput);
		var srcValue = srcInputObj.value;
		var resultString = ListDeleteItem(srcValue, ",", sVal);
		if(resultString == srcValue)
		{
			resultString = ListAppendItem(srcValue, ",", sVal);
			bDelete = false;
		}
		srcInputObj.value = resultString;
		var emptyString = "<img src=\"/Images/fill.gif\" height=\"1\">";
		if(trObj)
		{
			if(bDelete)
			{
				propogateProperty(trObj, "style.backgroundColor", "##DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);
				srcObj.title = "undo delete " + skeyword;
				srcObj.src = undodeleteImg.src;
			}
			else
			{
				var bgCol = "##FFFFFF";
				if(trObj.rowIndex % 2 == 0)
				{
					bgCol = "##C6FFC6";
				}
				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);
				srcObj.title = "delete this " + skeyword;
				srcObj.src = deleteImg.src;
			}
			srcObj.bDelete = !bDelete;
		}		
	}
	//show_please_wait(document.all.Hide_For_Please_Wait);
	function show_please_wait(hideForm)
	{
		document.all.PleaseWaitMessage.style.display = "";
		hideForm.style.display = "none";
	}	
</script>

<cfif IsDefined("form.doAction") AND NOT ListFindNoCase("assignCategoryAction,assignPriorityAction,save,deleteCategory,saveCategory,deletePriority,savePriority", form.doAction, ",")>
	<cfinclude template="/includes/call_please_wait.cfm">
</cfif>

<SPAN ID="Hide_For_Please_Wait">
<cfinclude template="header.cfm">

<br /><br />

<!---switch for mode--->
<cfswitch expression="#form.mode#">
	
	<!---position--->
	<cfcase value="2">
		<cfinclude template="position/Operator_Position.cfm">
	</cfcase>
	
	<!---category--->
	<cfcase value="3">
		<cfinclude template="category/operator_category.cfm">
	</cfcase>
	
	<!---priority--->
	<cfcase value="4">
		<cfinclude template="priority/operator_priority.cfm">
	</cfcase>
	
	<!---default to zip code--->
	<cfdefaultcase>
		<cfinclude template="zipcode/Market_ZipCode_Assign.cfm">
	</cfdefaultcase>
	
</cfswitch>

</SPAN>
<script language="JavaScript">
	function search_popup(sUrl)
	{
		NewWindow(sUrl, 'zipcode_search', '800', '600', 'Yes', 'No', true);
		return false;
	}
</script>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
</CFOUTPUT>