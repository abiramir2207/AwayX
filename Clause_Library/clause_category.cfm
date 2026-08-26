<!------ clause_category.cfm ----->
<cfoutput>

<cfset formName = "frmClauseCategory" />

<cfparam name="form.state" 	default="0">
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">


<cfset clauseCategoryManager = CreateObject("component", "components.clause_library.ClauseCategoryManager").init() />

<cfif form.state>

	<cfparam name="form.requireAll" 	default="1">
	<cfparam name="form.requireApproval" 	default="0">
	<cfparam name="form.applyToExistingPrograms" 	default="2">

	<cfset clauseCategory = clauseCategoryManager.get(0) />
	<cfset clauseCategory.setId(form.id) />
	<cfset clauseCategory.setTitle(form.clause_category_title) />
	
	<cfset clauseCategory.setRequireAll(form.requireAll) />
	<cfset clauseCategory.setApplyToExisting(form.applyToExistingPrograms) />
	<cfset clauseCategory.setRequireApproval(form.requireApproval) />

	<cfset clauseCategory.setCreatedBy(request.AccessStructure.User_Id) />
	<cfset clauseCategory.setUpdatedBy(request.AccessStructure.User_Id) />	
	<cfset Category_ID = clauseCategoryManager.save() />

	<cflocation addtoken="No" url="#thisPage#?command=sClauseCategory&Update=1" />
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
			alert("Clause title cannot be empty");
		}
		return retVal;
	}
</script>
<div style="margin:10px;">
<form method="post" name="#formName#">
	<FIELDSET STYLE="width: 500px;; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfif NOT form.id>Clause Library Create<cfelse>Clause Name Edit</cfif></LEGEND>
	<table align="left" cellpadding="5" cellspacing="0" border="0">
	<tr>
		<td><B>Clause Name</B></td>
		<td><input type="text" style="width:300px;" name="clause_category_title" value="#clauseCategory.getTitle()#"></td>
		<td>
		<cf_smallLink
			title="save"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#','svClauseCategory');"""
			>
		</td>
	</tr>
	</table>
	<input name="applyToExistingPrograms" type="hidden" value="2">
	<input name="requireAll" type="hidden" value="0">
	<input type="hidden" name="id" value="#clauseCategory.getId()#">
	<input type="hidden" name="state" value="1">
	<input type="hidden" name="command" value="#form.command#">
	</FIELDSET>
</form>

<cfif form.id>
	<cfset clauseLibraryManager = CreateObject("component", "components.clause_library.ClauseLibraryManager").init() />
	<cfset stSearch = StructNew() />
	<cfset stSearch.categoryId = clauseCategory.getId() />
	<cfset qGetClause = clauseLibraryManager.search(stSearch) />
<!---	<blockquote>--->
	<span class="Title2">Clauses</span>
	<cfif qGetClause.recordCount eq 0>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<cf_smallLink
				title="add clause"
				url="#thisPage#?command=ceClause&catId=#clauseCategory.getId()#"
				>
	</cfif>
	<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START    
    What  I did: Added EDIT icon to edit clauses instead of clicking on CLAUSE--->
	<hr color="navy">
	<table border="0" cellpadding="2" cellspacing="2">
		<cfif qGetClause.recordCount>

			<cfloop query="qGetClause">
				<tr>
					<td rowspan="2" valign="top">
						<a href="#thisPage#?command=ceClause&id=#Clause_Library_ID#">
							<img src="/images/edit_icon.png" border="0">
						</a>
					</td>
					<td valign="top">	#trim(Clause_Library_Body)#	</td>
				</tr>
				<cfif bFrenchClause >
					<tr> <!--- above TR has rowspan = 2 --->
						<td valign="top">
							<hr style="border:0px; border-bottom: 1px solid navy;">
							<span class="Title2">French</span><br/>
							#trim(Clause_Library_Body_French)#
						</td>
					</tr>
				</cfif>
			</cfloop>
		
		<cfelse>
			<tr><td colspan="2">	
			<font color="red"><B>No clause found</B></font>
			</td></tr>
		</cfif>
	
	</table>
	<!--- End Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  --->
<!---	</blockquote>--->
</cfif>
</div>
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