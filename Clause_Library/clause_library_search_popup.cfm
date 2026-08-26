<!------ clause_library_search.cfm ----->
<cfoutput>
<cfset formName = "frmClauseSearch" />
<cfparam name="form.catId" 	default="">
<cfparam name="form.body" 	default="">
<cfparam name="form.sort_by" 	default="Category">
<cfparam name="form.sort_order" 	default="ASC">

<cfparam name="form.startrow" 	default="1">
<cfparam name="form.frompage" 	default="1">
<cfparam name="form.state" 	default="1">

<!------ popup search ----->
<cfparam name="url.required" 	default="">
<cfparam name="form.required" 	default="#url.required#">
<cfparam name="url.templateId" 	default="">
<cfparam name="form.templateId" 	default="#url.templateId#">
<CFPARAM NAME="FORM.ExcludeList" 	DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">
<CFPARAM NAME="FORM.Clause_Library_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 	DEFAULT="">	
<CFPARAM NAME="FORM.FinisedSearching" 	DEFAULT="0">
<CFPARAM NAME="URL.importType" 	DEFAULT="multiple">
<CFPARAM NAME="FORM.importType" 	DEFAULT="#URL.importType#">
<cfparam name="URL.ExcludeListFieldname" 	default="">

<CFMODULE template="/Search_Screens/Popup_Search.cfm"
			FirstFormNameVariable="URL.FormName"
			FirstFieldNameVariable="URL.FieldName"
			ExcludeListFieldname="#URL.ExcludeListFieldname#"
			ActionPage="#thisPage#"
			AlreadySelectedItems="#FORM.AlreadySelectedItems#"
			id="#FORM.Clause_Library_ID#"
			FinalItemList="#FORM.FinalItemList#"
			ReturnFinalItemListVariable="FORM.FinalItemList"
			FinisedSearching="#FORM.FinisedSearching#"
			LastFormNameVariable="FORM.Formname"
			LastFieldNameVariable="FORM.FieldName"
			importType="#FORM.importType#"
			command="#form.command#"
			templateId="#form.templateId#"
			required="#form.required#">

<cfparam name="pageLength" 	default="10">
<cf_Number_of_Rows maxrows="#pageLength#">

<cfset clauseCategoryManager = CreateObject("component", "components.clause_library.ClauseCategoryManager").init() />
<cfset clauseLibraryManager = CreateObject("component", "components.clause_library.ClauseLibraryManager").init() />
<cfset qGetCat = clauseCategoryManager.getAll() />

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
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
		if(searchForm.AllClause)
		{
			searchForm.AllClause.checked = true;
			searchForm.AllClause.click();
		}
	}
	
	function radioCheck(radioObj, catId)
	{
		if(radioObj.checked)
		{
			var chObj = Get_Object_Property_Match_Collection(document.all.Clause_Library_ID, "categoryId", catId);
			chObj.checked = radioObj.checked;
			chObj.value = radioObj.value;			
		}
	}
	
	function checkboxCheck(chObj, cannotUncheck)
	{
		var catId = chObj.getAttribute('categoryId');
		var defaultLibId = chObj.getAttribute('defaultLibId');
		var radioObjs = document.getElementsByName("Clause_Library_" + catId);
		var i, radioObjLen;
		radioObjLen = radioObjs.length;
		chObj.value = defaultLibId;		
		if(cannotUncheck && !chObj.checked)
		{
			chObj.checked = true;
		}
		else
		{
			for(i=0;i<radioObjLen;i++)
			{
				if(radioObjs[i].value == defaultLibId)
				{
					radioObjs[i].checked = chObj.checked;
				}
				else
				{
					radioObjs[i].checked = false;
				}
			}
		}
	}
	
	function ClauseCHSelectAll(name_start, bCheck)
	{
		var inpColl = document.getElementsByTagName("INPUT");
		var inpCollLen = inpColl.length;
		var thisObj;
		for (var i=0;i<inpCollLen;i++)
		{
			thisObj = inpColl[i];
			if (thisObj.type == 'checkbox') 
			{
				if(thisObj.name.substr(0, name_start.length) == name_start)
				{
					thisObj.checked = bCheck;
					checkboxCheck(thisObj);
				}
			}
		}
	}	
	
</script>

<form action="#thisPage#" method="post" name="#formName#">
<FIELDSET STYLE="padding:8px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">clause library search</LEGEND>
	<TABLE cellpadding="2" cellspacing="0" border="0">
	<TR>
		<TD colspan="2">
		<B>Clause</B><BR>
		<select name="catId" style="width:200px;">
		<option value="">******** Select Clause *******</option>
		<cfloop query="qGetCat">
		<option value="#Clause_Category_ID#" <cfif form.catId eq Clause_Category_ID> selected</cfif>>#Clause_Category_Name#</option>
		</cfloop>
		</select>
		</TD>
		<TD colspan="2">
		<B>Body</B><br>
		<INPUT NAME="Body" TYPE="text" value="#form.body#" CLASS="doubleFixedWidth">
		</TD>
		<TD valign="bottom">
		<cf_smallLink
			title="reset form"
			url="##"
			parameters = "onClick=""JavaScript: return reset_Form_Fields(document.#formName#);"""
			>
			&nbsp;&nbsp;&nbsp;
		<cf_smallLink
			title="search"
			url="##"
			parameters = "onClick=""JavaScript: return submitSearch(document.#formName#);"""
			>
		</TD>
	</TR>
	</TABLE>
</FIELDSET>
</cfoutput>
	<cfif form.state EQ 1>
		<cfoutput>
		<!------ show search result ----->		
		<cfset stSearch = StructNew()>
		<cfset stSearch.categoryId = form.catId>
		<cfset stSearch.body = form.body>
		<cfset stSearch.templateId = form.templateId>
		<cfset stSearch.sortBy = form.sort_by>
		<cfset stSearch.sortOrder = form.sort_order>
		<cfset qClauseSearch = clauseLibraryManager.search(stSearch)>
		
		<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">		
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF qClauseSearch.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#qClauseSearch.recordcount#</CFOUTPUT> <CFIF qClauseSearch.recordcount EQ 1>record<CFELSE>records</CFIF> That <CFIF qClauseSearch.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="4" class="MainTable">
		<TR bgcolor="##FFCE84">
			<cfset sortByList = "">
			
			<TD ID="header">
			<CFIF FORM.importType NEQ "single">
			<INPUT NAME="AllClause" TYPE="checkbox" VALUE="" onClick="javaScript: ClauseCHSelectAll('Clause_Library_ID', this.checked);">			
			<CFELSE>&nbsp;</CFIF>
			</TD>
			
			<cfset sortByList = ListAppend(sortByList, "Clause:Clause", ",")>
			<cfset sortByList = ListAppend(sortByList, "&nbsp;", ",")>
			<cfset sortByList = ListAppend(sortByList, "Body Excerpt...", ",")>
			<CF_Sort_Column_Headers
							formName  = "#formName#"
							sortByFieldName = "sort_by"
							sortOrderFieldName = "sort_order"
							currentSortBy = "#form.sort_by#"
							currentSortOrder = "#form.sort_order#"
							sortByList = "#sortByList#"
							>			
		</TR>
		<CFSET AlreadySelectedItems = "">
		</cfoutput>
		<!------ <cfloop QUERY="qClauseSearch" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#"> ----->
		<cfoutput QUERY="qClauseSearch" startrow="#StartRow#" maxrows="#MaxRows#" group="Clause_Category_ID">
			<cfset bChecked = "">
			<cfset selectedClauseId = "">
			<cfoutput>
				<cfset addRemove = true>
				<CFIF listfind(FORM.FinalItemList, Clause_Library_ID) NEQ 0>
					<cfset bChecked = "CHECKED">
					<cfif selectedClauseId EQ "" OR listfind(form.Clause_Library_ID, selectedClauseId) EQ 0>
						<cfset selectedClauseId = Clause_Library_ID>
						<CFSET AlreadySelectedItems = listappend(AlreadySelectedItems, Clause_Library_ID, ",")>
					</cfif>					
				</CFIF>		
			</cfoutput>
		<cfif ListFindNoCase(form.ExcludeList, Clause_Category_ID, ",")>
			<cfset addRemove = false>
		</cfif>
		<TR valign="top" BGCOLOR="CCFFCC">
			
			<TD>			
			<cfif addRemove>
				<INPUT TYPE="<CFIF FORM.importType NEQ "single">checkbox<CFELSE>radio</CFIF>" NAME="Clause_Library_ID" VALUE="#selectedClauseId#" #bChecked# categoryId="#Clause_Category_ID#" defaultLibId="#Default_Clause_Library_ID#" onClick="javaScript: checkboxCheck(this, <cfif addRemove>0<cfelse>1</cfif>);">
			<cfelse>
				<INPUT TYPE="<CFIF FORM.importType NEQ "single">checkbox<CFELSE>radio</CFIF>" checked disabled>
				<INPUT TYPE="Hidden" NAME="Clause_Library_ID" VALUE="#Clause_Library_ID#" checked="true" categoryId="#Clause_Category_ID#" defaultLibId="#Default_Clause_Library_ID#">
			</cfif>
			</TD>
			<TD colspan="3" WIDTH="150" TITLE="#Clause_Category_Name#">#showRestrictedLength(Clause_Category_Name, 50)#</TD>			
		</TR>			
			<cfoutput>
			<TR valign="top" BGCOLOR="FFFFFF">
				<TD colspan="2" align="right">
				<input type="Radio" name="Clause_Library_#Clause_Category_ID#" value="#Clause_Library_ID#"<cfif selectedClauseId EQ Clause_Library_ID> checked</cfif> onClick="javaSCript: radioCheck(this, '#Clause_Category_ID#');">
				</TD>
				<TD width="10" style="color:red;font-size:8px;">&nbsp;</TD>
				<TD width="">
				<cfset strippedValue = StripHTML(Clause_Library_Body)>
				#showRestrictedLength(strippedValue, 100)#
				</TD>
			</TR>			
			</cfoutput>
		</cfoutput>
		<cfoutput>
		</TABLE>
		</FIELDSET>
		<DIV STYLE="font-size: 12px; color: Red;">
			<CF_Next_Previous_For_Forms
			formname="#formName#"
			query="qClauseSearch"
			maxpages="40"
			previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
			next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
			previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			addparams="">
		</DIV>
		<FONT SIZE="2">
		<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: finishedSearching(document.#formName#)"> import selected record(s) </a><FONT COLOR="##FF0000">]</FONT></B>
		</FONT>
		<FONT SIZE="2">
		<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: removeAll(document.#formName#)"> remove selected record(s) </a><FONT COLOR="##FF0000">]</FONT></B>
		</FONT>
		</cfoutput>
	</cfif>
<cfoutput>	
	<INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#form.startrow#">
	<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#form.frompage#">
	<INPUT NAME="command" TYPE="HIDDEN" VALUE="#form.command#">
	<INPUT NAME="sort_by" TYPE="hidden" value="#form.sort_by#">
	<INPUT NAME="sort_order" TYPE="hidden" value="#form.sort_order#">
	
	<INPUT NAME="Formname" TYPE="Hidden" VALUE="#FORM.FormName#">
	<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#FORM.FieldName#">
	<INPUT NAME="FinalItemList" TYPE="Hidden" VALUE="#FORM.FinalItemList#">
	<INPUT NAME="ExcludeList" TYPE="HIDDEN" VALUE="#FORM.ExcludeList#">
	<INPUT NAME="AlreadySelectedItems" TYPE="Hidden" VALUE="#AlreadySelectedItems#">	
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="importType" TYPE="HIDDEN" VALUE="#FORM.importType#">
	<INPUT NAME="templateId" TYPE="HIDDEN" VALUE="#FORM.templateId#">	
</form>
</cfoutput>
<!--- Dev Note: drachala; D29797: Clause Library  START
Added/Changed: Added Text Area to prevent JS error--->
<div style="display:none;">
<textarea rows="2" cols="20" style="display:none;" id="textarea">
Dont Remove me, if you do so you will get JS error
Message: Object required
Line: 697
Char: 3
Code: 0
URI: http://gm.stage.awayx.com/Script/Editor/scripts/wysiwyg.js
</textarea>
</div>
<!--- End Dev Note: drachala; D29797: Clause Library  --->