<!------ clause_category.cfm ----->
<cfoutput>

<cfset formName = "frmClauseCategory" />

<cfparam name="form.state" 	default="0">
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">


<cfset clauseCategoryManager = CreateObject("component", "components.clause_library.ClauseCategoryManager").init() />

<cfif form.state>
	
	<cfparam name="form.requireAll" 	default="0">
	<cfparam name="form.requireApproval" 	default="0">
	<cfparam name="form.applyToExistingPrograms" 	default="0">
	
	<cfset clauseCategory = clauseCategoryManager.get(0) />
	<cfset clauseCategory.setId(form.id) />
	<cfset clauseCategory.setTitle(form.clause_category_title) />
	<cfset clauseCategory.setRequireAll(form.requireAll) />
	<cfset clauseCategory.setApplyToExisting(form.applyToExistingPrograms) />
	<cfset clauseCategory.setRequireApproval(form.requireApproval) />
	<cfset clauseCategory.setCreatedBy(request.AccessStructure.User_Id) />
	<cfset clauseCategory.setUpdatedBy(request.AccessStructure.User_Id) />	
	<cfset clauseCategoryManager.save_ComplexClauses() />
	
	<cflocation addtoken="No" url="#thisPage#?command=sClauseCategory" />
	<cfabort>
<cfelse>
	<cfset clauseCategory = clauseCategoryManager.get(form.id) />
</cfif>

<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<script language="JavaScript">
	function submitForm(formName, sCommand)
	{
		var oForm = eval("document." + formName);
		if(oForm)
		{
			if(validate(oForm))
			{
				oForm.command.value = sCommand;
				oForm.submit();
			}
		}
		return false;
	}
	
	function validate(oForm)
	{
		var retVal = true;
		if(isSpace(oForm.clause_category_title.value))
		{
			retVal = false;
			alert("Clause category title cannot be empty");
		}
		return retVal;
	}
</script>

<form method="post" name="#formName#">
	<table align="center" cellpadding="5" cellspacing="0" border="0" style="border:2px solid ##dddddd;" width="70%">
	<tr>
		<td><B>Category Name</B></td>
		<td><input type="text" style="width:300px;" name="clause_category_title" value="#clauseCategory.getTitle()#"></td>
		<td rowspan="100%" align="center" valign="bottom">
		<cf_smallLink
			title="save"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#','svClauseCategory');"""
			>
		</td>
	</tr>
	<tr>
		<td colspan="2">
		<CF_SmallHelp width="500">
			<table cellpadding="0" cellspacing="0">
			<tr>
			<td>
			<B>Required for all programs</B> - If you select the option 'Required for all programs', the default clause of this clause category will be added to all available program templates.
			</td>
			</tr>
			<tr>
			<td>
			<B>Apply To Existing Programs</B> - If you select the option 'Required for all programs' and 'Apply To Existing Programs', the default clause of this clause category will be added to all programs which are not yet approved.
			</td>
			</tr>
			</table>
		</CF_SmallHelp>
		<cfif clauseCategory.getDefaultClauseId() NEQ "" AND clauseCategory.getDefaultClauseId() NEQ 0>
		<input name="requireAll" type="checkbox" value="1" <cfif clauseCategory.getRequireAll()>checked</cfif>>Required for all programs&nbsp;
		<input name="applyToExistingPrograms" type="checkbox" value="1" <cfif clauseCategory.getApplyToExisting()>checked</cfif>>Apply To Existing Programs&nbsp;
		<cfelse>
		<input name="requireAll" type="hidden" value="0">
		<input name="applyToExistingPrograms" type="hidden" value="0">

		<input type="checkbox" disabled>Required for all programs&nbsp;
		<input type="checkbox" disabled>Apply To Existing Programs&nbsp;
		</cfif>
		<input name="requireApproval" type="checkbox" value="1" <cfif clauseCategory.getRequireApproval()>checked</cfif>>Revisions Require Approval&nbsp;
		<cfif clauseCategory.getDefaultClauseId() NEQ "" AND clauseCategory.getDefaultClauseId() NEQ 0>
		<cfelse><br><font color="red">You can make the category required only after you add a default clause</font></cfif>
		</td>
	</tr>
	</table>
	<input type="hidden" name="id" value="#clauseCategory.getId()#">
	<input type="hidden" name="state" value="1">
	<input type="hidden" name="command" value="#form.command#">
</form>

<cfif form.id>
	<cfset clauseLibraryManager = CreateObject("component", "components.clause_library.ClauseLibraryManager").init() />
	<cfset stSearch = StructNew() />
	<cfset stSearch.categoryId = clauseCategory.getId() />
	<cfset qGetClause = clauseLibraryManager.search(stSearch) />
	
	<blockquote>
	<span class="Title2">Clauses</span>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<cf_smallLink
				title="add clause"
				url="#thisPage#?command=ceClause&catId=#clauseCategory.getId()#"
				>
	<hr color="navy">	
	<cfif qGetClause.recordCount>
	<ul>
	<cfloop query="qGetClause">
		<li><cfif Clause_Library_ID EQ clauseCategory.getDefaultClauseId()><font color="red"><B>[default]</B></font></cfif>
		<a href="#thisPage#?command=ceClause&id=#Clause_Library_ID#">#Clause_Library_Body#</a>
		</li>
	</cfloop>
	</ul>
	<cfelse>
		<font color="red"><B>No clause found</B></font>
	</cfif>
	</blockquote>
</cfif>
	
</cfoutput>