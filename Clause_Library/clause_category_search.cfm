<cfoutput>
<cfset clauseCategoryManager = CreateObject("component", "components.clause_library.ClauseCategoryManager").init() />
<cfset qGetCat = clauseCategoryManager.getAll() />

<br><br>
<table cellpadding="2" cellspacing="0" class="MainTable" width="40%" border="0">
	<tr bgcolor="FFCE84">
		<td id="header">&nbsp;</td>
		<td id="header"><B>Clause</B></td>
		<td id="header">&nbsp;</td>
	</tr>
<cfloop query="qGetCat">
	<tr>
		<td>&nbsp;</td>
		<td>
		<a href="#thisPage#?command=ceClauseCategory&id=#Clause_Category_ID#">#Clause_Category_Name#</a>
		</td>
		<td>
		<img name="IMG_Delete_Scissor" src="/images/scissor.gif" title="click here to delete this clause" border="0" onclick="return alertDelete('#Clause_Category_ID#')" style="cursor: pointer;">
		</td>
	</tr>	
</cfloop>
</table>
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