<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Futures Pricing - Suppliers</title>
	
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

</head>

<body>

<CFSET thisPage = CGI.SCRIPT_NAME>
<cfset formName = "frmFPSupplierSearch">
<cfparam name="FORM.AlreadySelectedItems" 	default="">
<cfparam name="FORM.FP_Supplier_ID" 	default="">
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
				id="#FORM.FP_Supplier_ID#"
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
	function addItem(searchForm, sCommand, itemId)
	{
	
		//show a confirmation for deactivate
		if (sCommand == "deactivate")
		{
			if (!confirm("This will deactivate this supplier from Future Pricing. Do you want to continue?"))
			return false;
		}
		
		//validate supplier name when saving
		if (sCommand == "sSupplier" && sCommand != "deactivate")
		{
		
			//error spans
			var suppNameErrObj = document.all.Err_Sp_Supplier_Name;
		
			//variables needed
			var suppName = trim(searchForm.Supplier_Name.value);
		
			//handle for empty supplier names
			if(!suppName.length)
			{
				queueMessage("Please provide a Supplier Name.", suppNameErrObj);
				showMessageWindow();
				return false;
			}
			else
			{
				clearQueue(suppNameErrObj);
			}
		}
		
		searchForm.command.value = sCommand;
		if(itemId)
		{
			searchForm.itemId.value = itemId;
		}
		searchForm.submit();
	}
</script>
<CFSET AlreadySelectedItems = "">
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<cfset supplierManager = CreateObject("component", "components.futures_pricing.SupplierManager").init() />

<FORM ACTION="#thisPage#" METHOD="post" name="#formName#">
<!---///////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---//////////////////////////////////////Create/Edit Section//////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfif form.command EQ "ceSupplier">
	<cfparam name="form.itemId" 	default="0">
	<cfset supplier = supplierManager.get(form.itemId)>
	<table align="center" cellpadding="2" cellspacing="0" border="0">
	<caption>Add / Edit Supplier</caption>
		<tr>
			<td><span id="Err_Sp_Supplier_Name"><b>Name:</b></td>
			<td><input size="50" type="Text" name="Supplier_Name" value="#supplier.getName()#"></td>
		</tr>
	</table>
	<input type="Hidden" name="id" value="#supplier.getId()#">
	<br>
	<div align="center">
	<cf_smallLink
		title="back to search"
		url="##"
		parameters=" onClick=""javascript: addItem(document.#formName#, 'search');"""
		>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<cf_smallLink
		title="save supplier"
		url="##"
		parameters=" onClick=""javascript: addItem(document.#formName#, 'sSupplier');"""
		>
	</div>
<cfelseif form.command EQ "sSupplier">
	<cfset supplier = supplierManager.get(0)>
	<cfset supplier.setId(form.id)>
	<cfset supplier.setName(form.Supplier_Name)>
	<cfset supplierManager.save()>
<cfelseif form.command EQ "deactivate">
	<cfset supplier = supplierManager.get(0)>
	<cfset supplier.setId(form.itemId)>
	<cfset supplierManager.deactivate()>
<cfelse>
<!---///////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---//////////////////////////////////////////Search Section///////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfset qGetSuppliers = supplierManager.getAll() />
<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="4" class="MainTable">		
	<TR bgcolor="##FFCE84">
		<TD ID="header">
		<CFIF FORM.importType NEQ "single">
		<INPUT NAME="MyCheckAll" TYPE="checkbox" VALUE="" onClick="javaScript: CHSelectAll('FP_Supplier_ID', this.checked);">			
		<CFELSE>&nbsp;</CFIF>
		</TD>
		<TD ID="header"><B>Description</B></TD>
		<TD ID="header">&nbsp;</TD>
		<TD ID="header">&nbsp;</TD>
	</TR>
	<cfloop query="qGetSuppliers" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
	<tr>
		<td>
		<cfset bChecked = "">
		<CFIF listfind(FORM.FinalItemList, FP_Supplier_ID) NEQ 0>
			<cfset bChecked = "CHECKED">
			<CFSET AlreadySelectedItems = listappend(AlreadySelectedItems, FP_Supplier_ID, ",")>
		</CFIF>
		<INPUT TYPE="<CFIF FORM.importType NEQ "single">checkbox<CFELSE>radio</CFIF>" NAME="FP_Supplier_ID" VALUE="#FP_Supplier_ID#" #bChecked#>
		</td>
		<td>#Supplier_Name#</td>
		<td>
			<cf_smallLink
				title="edit"
				url="##"
				parameters=" onClick=""javascript: addItem(document.#formName#, 'ceSupplier', #FP_Supplier_ID#);"""
			>
		</td>
		<td>
			<cf_smallLink
				title="deactivate"
				url="##"
				parameters=" onClick=""javascript: addItem(document.#formName#, 'deactivate', #FP_Supplier_ID#);"""
			>
		</td>
	</tr>
	</cfloop>
</TABLE>
	<DIV STYLE="font-size: 12px; color: Red;">
			<CF_Next_Previous_For_Forms
			formname="#formName#"
			query="qGetSuppliers"
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
			title="add supplier"
			url="##"
			parameters=" onClick=""javascript: addItem(document.#formName#, 'ceSupplier');"""
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
		<INPUT NAME="command" TYPE="HIDDEN" VALUE="search">
		<INPUT NAME="itemId" TYPE="Hidden" VALUE="0">
</FORM>
<cf_MessageWindow />
<!--- <cfif form.command EQ "sSupplier"> --->
<cfif ListFindNoCase("sSupplier,deactivate", form.command)>
	<script language="JavaScript">
		addItem(document.#formName#, 'search');
	</script>
</cfif>
</body>
</html>

</cfoutput>