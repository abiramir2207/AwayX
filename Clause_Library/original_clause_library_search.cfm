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

<cfparam name="pageLength" 	default="9">
<cf_Number_of_Rows maxrows="#pageLength#">

<cfset clauseCategoryManager = CreateObject("component", "components.clause_library.ClauseCategoryManager").init() />
<cfset clauseLibraryManager = CreateObject("component", "components.clause_library.ClauseLibraryManager").init() />
<cfset qGetCat = clauseCategoryManager.getAll() />

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
</script>

<form action="#thisPage#" method="post" name="#formName#">
<FIELDSET STYLE="padding:8px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">clause library search</LEGEND>
	<TABLE cellpadding="2" cellspacing="0" border="0">
	<TR>
		<TD colspan="2">
		<B>Category</B><BR>
		<select name="catId" style="width:200px;">
		<option value="">******** Select Category *******</option>
		<cfloop query="qGetCat">
		<option value="#Clause_Category_ID#" <cfif form.catId eq Clause_Category_ID>selected</cfif>>#Clause_Category_Name#</option>
		</cfloop>
		</select>
		</TD>
		<TD colspan="2">
		<B>Body</B><br>
		<INPUT NAME="Body" TYPE="text" value="#form.body#" CLASS="doubleFixedWidth">
		</TD>
		<TD>
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
	<cfif form.state EQ 1>
		
		<!------ show search result ----->		
		<cfset stSearch = StructNew()>
		<cfset stSearch.categoryId = form.catId>
		<cfset stSearch.body = form.body>
		<cfset stSearch.sortBy = form.sort_by>
		<cfset stSearch.sortOrder = form.sort_order>
		<cfset qClauseSearch = clauseLibraryManager.search(stSearch)>
		
		<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">		
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF qClauseSearch.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#qClauseSearch.recordcount#</CFOUTPUT> <CFIF qClauseSearch.recordcount EQ 1>record<CFELSE>records</CFIF> That <CFIF qClauseSearch.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="4" class="MainTable">		
		<caption align="left" style="color:red;font-size:10px;">DEF - Default Clause</caption>
		<TR bgcolor="##FFCE84">
			<cfset sortByList = "">
			
			<cfset sortByList = ListAppend(sortByList, "&nbsp;", ",")>
			<cfset sortByList = ListAppend(sortByList, "&nbsp;", ",")>
			<cfset sortByList = ListAppend(sortByList, "&nbsp;", ",")>
			<cfset sortByList = ListAppend(sortByList, "&nbsp;", ",")>
		
			<cfset sortByList = ListAppend(sortByList, "Category:Category", ",")>
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
		<cfloop QUERY="qClauseSearch" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
		<TR valign="top" BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
			
			<TD width="10"><A HREF="index.cfm?id=#Clause_Library_ID#&command=ceClause"><IMG SRC="/Images/edit.gif" BORDER="0" TITLE=" edit clause "></A></TD>
			<TD width="10"><A HREF="index.cfm?id=#Clause_Library_ID#&command=dClause" onClick="NewWindow(this.href,'name','625','450','Yes', 'Yes');return false;"><IMG SRC="/Images/view.gif" BORDER="0" TITLE="view clause"></A></TD>
			<cfif Clause_Library_ID EQ Default_Clause_Library_ID>
				<TD width="10" title="You cannot delete the default clause" onclick="alert('You cannot delete the default clause');">NA</TD>
			<cfelse>
				<TD width="10"><A HREF="index.cfm?id=#Clause_Library_ID#&command=delClause" onclick="return window.confirm('Do you want to delete this clause?');"><IMG SRC="/Images/delete_2.gif" BORDER="0" TITLE=" delete clause "></A></TD>
			</cfif>			
			<TD width="10" style="color:red;font-size:8px;"><cfif Clause_Library_ID EQ Default_Clause_Library_ID>DEF<cfelse>&nbsp;</cfif></TD>
			<TD WIDTH="150" TITLE="#Clause_Category_Name#">#showRestrictedLength(Clause_Category_Name, 50)#</TD>
			<TD width="">
			<cfset strippedValue = StripHTML(Clause_Library_Body)>
			#showRestrictedLength(strippedValue, 100)#
			</TD>
		</TR>
		</cfloop>		
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
		
	</cfif>
	<INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#form.startrow#">
	<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#form.frompage#">
	<INPUT NAME="command" TYPE="HIDDEN" VALUE="#form.command#">
	<INPUT NAME="sort_by" TYPE="hidden" value="#form.sort_by#">
	<INPUT NAME="sort_order" TYPE="hidden" value="#form.sort_order#">
</form>
</cfoutput>