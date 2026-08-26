<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Futures Pricing - Raw materials</title>
</head>

<body>

<CFSET thisPage = CGI.SCRIPT_NAME>
<cfset formName = "frmFPRawMaterialSearch">
<cfparam name="FORM.AlreadySelectedItems" 	default="">
<cfparam name="FORM.FP_Raw_Material_ID" 	default="">
<cfparam name="FORM.FinalItemList" 	default="">
<cfparam name="FORM.FinisedSearching" 	default="0">
<CFPARAM NAME="URL.importType" 	DEFAULT="multiple">
<CFPARAM NAME="FORM.importType" 	DEFAULT="#URL.importType#">
<cfparam name="form.command" 	default="search">

<CFMODULE template="/Search_Screens/Popup_Search.cfm"
				FirstFormNameVariable="URL.FormName"
				FirstFieldNameVariable="URL.FieldName"
				ActionPage="#thisPage#"
				AlreadySelectedItems="#FORM.AlreadySelectedItems#"
				id="#FORM.FP_Raw_Material_ID#"
				FinalItemList="#FORM.FinalItemList#"
				ReturnFinalItemListVariable="FORM.FinalItemList"
				FinisedSearching="#FORM.FinisedSearching#"
				LastFormNameVariable="FORM.Formname"
				LastFieldNameVariable="FORM.FieldName"
				importType="#FORM.importType#"
				>


<cfparam name="pageLength" 	default="10">
<cf_Number_of_Rows maxrows="#pageLength#">

<script language="JavaScript">
	function reset_Form_Fields(searchForm)
	{
		searchForm.reset();
		searchForm.Title.value = "";
		searchForm.Body.value = "";		
	}
	function submitSearch(searchForm)
	{
		searchForm.startrow.value=1;
		searchForm.frompage.value=1;
		searchForm.submit();
		return false;
	}
	function finishedSearching(searchForm)
	{
		searchForm.FinisedSearching.value = 1;
		searchForm.submit();			
	}
	function removeAll(searchForm)
	{
		searchForm.AlreadySelectedItems.value = "";
		searchForm.FinalItemList.value = "";
		if(searchForm.MyCheckAll)
		{
			searchForm.MyCheckAll.checked = true;
			searchForm.MyCheckAll.click();
		}
	}
	
	function addRawMaterial(searchForm, sCommand, itemId)
	{
		//show a confirmation for deactivate
		if (sCommand == "deactivate")
		{
			if (!confirm("This will deactivate this raw material from Future Pricing. Do you want to continue?"))
			return false;
		}
		
		//validate raw material and desc
		if (sCommand == "sRawMaterial" && sCommand != "deactivate")
		{
			//boolean values for number and desc
			var bNumError = false;
			var bDescError = false;
		
			//error spans
			var rawMatNumErrObj = document.all.Err_Sp_RawMat_Number;
			var rawMatDescErrObj = document.all.Err_Sp_RawMat_Desc;
		
			//variables needed
			var rawMatNumber = trim(searchForm.Raw_Material_Number.value);
			var rawMatDesc = trim(searchForm.Raw_Material_Desc.value);
		
			//validate raw materials
			if (!validateRawMaterial(rawMatNumber, "Please provide a Raw Material number.", rawMatNumErrObj))
			{
				bNumError = true;
			}
			
			if (!validateRawMaterial(rawMatDesc, "Please provide a Description.", rawMatDescErrObj))
			{
				bDescError = true;
			}
			
			if (bNumError || bDescError)
			{
				showMessageWindow();
				return false;
			}

		}
		
		searchForm.command.value = sCommand;
		if(itemId)
		{
			searchForm.itemId.value = itemId;
		}
		searchForm.submit();
	}
	
	function validateRawMaterial(val, errorMesg, errorSpan)
	{
		//return value
		var isValid = true;
		
		//check the length of the sting
		if(!val.length)
		{
			queueMessage(errorMesg, errorSpan);
			isValid = false;
		}
		else
		{
			clearQueue(errorSpan);
		}
			
		return isValid;
		
	}

</script>

<CFSET AlreadySelectedItems = "">
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<cfset rawMaterialManager = CreateObject("component", "components.futures_pricing.RawMaterialManager").init() />

<FORM ACTION="#thisPage#" METHOD="post" name="#formName#">
<!---///////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---//////////////////////////////////////Create/Edit Section//////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfif form.command EQ "ceRawMaterial">
	<cfparam name="form.itemId" 	default="0">
	<cfset rawMaterial = rawMaterialManager.get(form.itemId)>
	<table align="center" cellpadding="2" cellspacing="0" border="0">
	<caption>Add / Edit Raw Material</caption>
		<tr>
			<td><span id="Err_Sp_RawMat_Number"></span><b>Number:</b></td>
			<td><input type="Text" name="Raw_Material_Number" value="#rawMaterial.getNumber()#"></td>
		</tr>
		<tr>
			<td><span id="Err_Sp_RawMat_Desc"></span><b>Description:</b></td>
			<td><input size="50" type="Text" name="Raw_Material_Desc" value="#rawMaterial.getDesc()#"></td>
		</tr>
	</table>
	<input type="Hidden" name="id" value="#rawMaterial.getId()#">
	<br>
	<div align="center">
	<cf_smallLink
		title="back to search"
		url="##"
		parameters=" onClick=""javascript: addRawMaterial(document.#formName#, 'search');"""
		>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<cf_smallLink
		title="save raw material"
		url="##"
		parameters=" onClick=""javascript: addRawMaterial(document.#formName#, 'sRawMaterial');"""
		>
	</div>
<cfelseif form.command EQ "sRawMaterial">
	<cfset rawMaterial = rawMaterialManager.get(0)>
	<cfset rawMaterial.setId(form.id)>
	<cfset rawMaterial.setNumber(form.Raw_Material_Number)>
	<cfset rawMaterial.setDesc(form.Raw_Material_Desc)>
	<cfset rawMaterialManager.save()>
<cfelseif form.command EQ "deactivate">
	<cfset rawMaterial = rawMaterialManager.get(0)>
	<cfset rawMaterial.setId(form.itemId)>
	<cfset rawMaterialManager.deactivate()>
<cfelse>
<!---///////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---//////////////////////////////////////////Search Section///////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfset qGetRawMaterials = rawMaterialManager.getAll() />
<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="4" class="MainTable">		
	<TR bgcolor="##FFCE84">
		<TD ID="header">
		<CFIF FORM.importType NEQ "single">
		<INPUT NAME="MyCheckAll" TYPE="checkbox" VALUE="" onClick="javaScript: CHSelectAll('FP_Raw_Material_ID', this.checked);">			
		<CFELSE>&nbsp;</CFIF>
		</TD>
		<TD ID="header"><B>Number</B></TD>
		<TD ID="header"><B>Description</B></TD>
		<TD ID="header">&nbsp;</TD>
		<TD ID="header">&nbsp;</TD>
	</TR>
	<cfloop query="qGetRawMaterials" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
	<tr>
		<td>
		<cfset bChecked = "">
		<CFIF listfind(FORM.FinalItemList, FP_Raw_Material_ID) NEQ 0>
			<cfset bChecked = "CHECKED">
			<CFSET AlreadySelectedItems = listappend(AlreadySelectedItems, FP_Raw_Material_ID, ",")>
		</CFIF>
		<INPUT TYPE="<CFIF FORM.importType NEQ "single">checkbox<CFELSE>radio</CFIF>" NAME="FP_Raw_Material_ID" VALUE="#FP_Raw_Material_ID#" #bChecked#>
		</td>
		<td>#Raw_Material_Number#</td>
		<td>#Raw_Material_Desc#</td>
		<td>
			<cf_smallLink
			title="edit"
			url="##"
			parameters=" onClick=""javascript: addRawMaterial(document.#formName#, 'ceRawMaterial', #FP_Raw_Material_ID#);"""
			>
		</td>
		<td>
			<cf_smallLink
			title="deactivate"
			url="##"
			parameters=" onClick=""javascript: addRawMaterial(document.#formName#, 'deactivate', #FP_Raw_Material_ID#);"""
			>
		</td>
	</tr>
	</cfloop>
</TABLE>
	<DIV STYLE="font-size: 12px; color: Red;">
		<CF_Next_Previous_For_Forms
		formname="#formName#"
		query="qGetRawMaterials"
		maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">
	</DIV>
	
	<div>
	<cf_smallLink
		title="import selected record(s)"
		url="##"
		parameters=" onClick=""javascript: finishedSearching(document.#formName#);"""
		>
	<cf_smallLink
		title="remove selected record(s)"
		url="##"
		parameters=" onClick=""javascript: removeAll(document.#formName#);"""
		>
	<cf_smallLink
		title="add raw material"
		url="##"
		parameters=" onClick=""javascript: addRawMaterial(document.#formName#, 'ceRawMaterial');"""
		>
	</div>	
<!------ Search code ends ----->	
</cfif>
	<INPUT NAME="Formname" TYPE="Hidden" VALUE="#FORM.FormName#">
	<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#FORM.FieldName#">
	<INPUT NAME="FinalItemList" TYPE="Hidden" VALUE="#FORM.FinalItemList#">
	<INPUT NAME="AlreadySelectedItems" TYPE="Hidden" VALUE="#AlreadySelectedItems#">	
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="importType" TYPE="HIDDEN" VALUE="#FORM.importType#">
	<INPUT NAME="command" TYPE="HIDDEN" VALUE="#form.command#">
	<INPUT NAME="itemId" TYPE="Hidden" VALUE="0">
</FORM>
<cf_MessageWindow />
<cfif ListFindNoCase("sRawMaterial,deactivate", form.command)>
	<script language="JavaScript">
		addRawMaterial(document.#formName#, 'search');
	</script>
</cfif>
</body>
</html>

</cfoutput>