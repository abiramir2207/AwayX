<!------ documents ----->
<cfoutput>
<!------ set defaults ----->
<cfset formName = "dataForm">
<cfparam name="form.state" default="0" />
<cfparam name="form.sort_by" 	default="Date">
<cfparam name="form.sort_order" 	default="ASC">
<cfparam name="form.Attachment_List" 	default="">

<!---initialize the components we need--->
<cfset documentManager = CreateObject("component", "components.futures_pricing.DocumentManager") />

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////// Controller Section //////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<!---if the command is sNote then save and relocate--->
<cfif form.command eq "sDocuments">
	
	<cfset documentManager.saveRequestDocuments(form.id, form.Attachment_List) />
	<cflocation addtoken="No" url="handler.cfm?id=#form.id#&command=ceDocuments" />
	<cfabort>
	
<cfelseif NOT form.state>
	
	<cfset qDocument =  documentManager.getRequestDocuments(form.id, form.sort_by, form.sort_order) />
	<cfset form.Attachment_List = ValueList(qDocument.Doc_ID) />
	
<cfelse>

	<cfset qDocument =  documentManager.getDocumentsFromList(form.Attachment_List, form.sort_by, form.sort_order) />
	
</cfif>

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////// End Controller Section //////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<SCRIPT>
	
	function submitForm(formName, command) 
	{
		var formName = eval("document." + formName);

		//close the window if the command is close
		if (command == 'close')
		{
			window.close();
			return false;
		}
		else
		{			
			formName.command.value = command;
			formName.submit();
			return false;
		}
	}
	
	function submitForm(thisForm, sCommand) 
	{
		thisForm.command.value = sCommand;
		thisForm.submit();
		return false;
	}
	
	function gotoview()
	{
		spinnerwind.close();
	}
	
</SCRIPT>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<form action="#thisPageUrl#" method="post" name="#formName#">

	<span class="Title2">Documents</span>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<CF_smallLink 
		title = "search documents" 
		url = "/common_files/Documents/Attach_Document.cfm?Form_Name=#formName#"
		parameters = "onClick=""JavaScript: NewWindow(this.href,'documents','800','600','Yes', 'No');return false;"""
	>
	<hr color="Navy">
	
	<table cellpadding="2" cellspacing="0" class="MainTable" width="100%">
		<thead>
			<tr bgcolor="##ffce84" valign="top">
				<CF_Sort_Column_Headers
						formName  = "#formName#"
						sortByFieldName = "sort_by"
						sortOrderFieldName = "sort_order"
						currentSortBy = "#form.sort_by#"
						currentSortOrder = "#form.sort_order#"
						sortByList = "&nbsp;"
						>
				<td>
				<table cellpadding="0" cellspacing="0" class="NotMainTable">
				<tr>
					<CF_Sort_Column_Headers
						formName  = "#formName#"
						sortByFieldName = "sort_by"
						sortOrderFieldName = "sort_order"
						currentSortBy = "#form.sort_by#"
						currentSortOrder = "#form.sort_order#"
						sortByList = "Date:Date"
						>
				</tr>
				<tr>
					<CF_Sort_Column_Headers
						formName  = "#formName#"
						sortByFieldName = "sort_by"
						sortOrderFieldName = "sort_order"
						currentSortBy = "#form.sort_by#"
						currentSortOrder = "#form.sort_order#"
						sortByList = "Name:Name"
						>
				</tr>
				</table>
				</td>
				<CF_Sort_Column_Headers
						formName  = "#formName#"
						sortByFieldName = "sort_by"
						sortOrderFieldName = "sort_order"
						currentSortBy = "#form.sort_by#"
						currentSortOrder = "#form.sort_order#"
						sortByList = "File:File"
						>
				<td>
				<table cellpadding="0" cellspacing="0" class="NotMainTable">
				<tr>
					<CF_Sort_Column_Headers
						formName  = "#formName#"
						sortByFieldName = "sort_by"
						sortOrderFieldName = "sort_order"
						currentSortBy = "#form.sort_by#"
						currentSortOrder = "#form.sort_order#"
						sortByList = "Title:Title"
						>
				</tr>
				<tr>
					<CF_Sort_Column_Headers
						formName  = "#formName#"
						sortByFieldName = "sort_by"
						sortOrderFieldName = "sort_order"
						currentSortBy = "#form.sort_by#"
						currentSortOrder = "#form.sort_order#"
						sortByList = "Description:Description"
						>
				</tr>
				</table>
				</td>
				<CF_Sort_Column_Headers
						formName  = "#formName#"
						sortByFieldName = "sort_by"
						sortOrderFieldName = "sort_order"
						currentSortBy = "#form.sort_by#"
						currentSortOrder = "#form.sort_order#"
						sortByList = "Type:Type"
						>
			</tr>
			
		</thead>
		<cfloop query="qDocument">
			<tr valign="top">
				<td>&nbsp;</td>
				<td>
				#DateFormat(Uploaded_Date, "mm/dd/yyyy")#
				<br>#UploadedByName#
				&nbsp;</td>
				<td title="File Name: #Doc_File_Name#">
				<a href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">#showRestrictedLength(Doc_File_Name, 100)#&nbsp;</a>
				<br>#numberformat(Doc_size_KB,"_.___")# KB
				&nbsp;</td>				
				<td>
				#Doc_Title#
				<br>#showRestrictedLength(Doc_Description, 100)#
				&nbsp;</td>
				<td>#Doc_Type#&nbsp;</td>
			</tr>
		</cfloop>
	</table>
	
	<input type="hidden" name="Attachment_List" value="#form.Attachment_List#">
	<input type="hidden" name="state" value="1">
	<input type="hidden" name="sort_by" value="#form.sort_by#">	
	<input type="hidden" name="sort_order" value="#form.sort_order#">
	<INPUT NAME="command" TYPE="Hidden" VALUE="#form.command#" />
	<br><br>
	<div align="center">
	<CF_smallLink 
		title = "close window" 
		url = "##"
		parameters = "onClick=""JavaScript: window.close();return false;"""
	>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<CF_smallLink 
		title = "save" 
		url = "##"
		parameters = "onClick=""JavaScript: return submitForm(document.#formName#,'sDocuments');"""
	>
	</div>
</form>


</cfoutput>