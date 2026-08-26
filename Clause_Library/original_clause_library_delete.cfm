<!------ clause_library_delete.cfm ----->
<cfoutput>
<cfset bCanDelete = false>
<cfset formName = "frmClauseDelete">
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">

<cfif form.id>
	<cfparam name="form.deleteClauseLibrary" 	default="0">
	<cfparam name="form.deleteClauseTemplate" 	default="0">
	<cfparam name="form.deleteClauseProgram" 	default="0">
	
	<cfset clauseLibraryManager = CreateObject("component","components.clause_library.ClauseLibraryManager").init() />
	
	<cfset bCanDelete = form.deleteClauseLibrary>

	<cfif bCanDelete>
		<!------ delete ----->
		<cfset clauseLib = clauseLibraryManager.getClause(form.id) />
		<!------ <cfset clauseLibraryManager.delete(form.deleteClauseTemplate, form.deleteClauseProgram)> ----->
		<!------ delete from template when library is deleted ----->
		<cfset clauseLibraryManager.delete(1, form.deleteClauseProgram)>
		
		<cflocation addtoken="No" url="#form.referer#">
	<cfelse>
		<!------ show form ----->
		<cfset clauseLib = clauseLibraryManager.getClause(form.id)>
		<h3>Clause Category: #clauseLib.getCategory().getTitle()#</h3>
		#clauseLib.getBody()#
		<hr color="Orange">
		<cfif clauseLib.getCategory().getDefaultClauseId() EQ clauseLib.getID()>
		<div align="center" style="color:red;font-size:12px;">This clause is the default clause for this category. You cannot delete the default clause.<br><br>In order to delete this clause, make another clause to be the default and then delete this clause.</div>
		<cfelse>
		<form action="#thisPage#" method="post" name="#formName#">
		<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" ALIGN="CENTER">
		<tr>
			<td nowrap>
				<FONT COLOR="##FF0000" SIZE="+1">Are you sure you want to delete this clause?</FONT>
			</td>
		<script language="JavaScript">
			function delete_Clause()
			{
				var formObj = document.all.#formName#;
				if(formObj.deleteClauseLibrary.checked)
				{
					if(window.confirm("Once you delete this clause, you will not be able to bring it back.\nDo you want to delete anyway?"))
					{
						formObj.submit();
					}
				}
			}
			/*
			function refreshCheckDisabled(thisForm)
			{
				thisForm.deleteClauseTemplate.disabled = !(thisForm.deleteClauseLibrary.checked);
				thisForm.deleteClauseProgram.disabled= !(thisForm.deleteClauseTemplate.checked && !thisForm.deleteClauseTemplate.disabled);
			}
			*/
			function refreshCheckDisabled(thisForm)
			{
				thisForm.deleteClauseProgram.disabled = !(thisForm.deleteClauseLibrary.checked);
			}
		</script>
		
			
			<!------ 
			<TR>
				<TD>
					<INPUT NAME="deleteClauseLibrary" TYPE="checkbox" VALUE="1" onclick="refreshCheckDisabled(this.form);">
					Yes, I want to delete this clause from the clause library !!!
				</TD>
			</TR>			
			<TR>
				<TD>
					<INPUT NAME="deleteClauseTemplate" TYPE="checkbox" VALUE="1" disabled onclick="refreshCheckDisabled(this.form);">
					Yes, I want to delete this clause from all the program templates !!!
				</TD>
			</TR> 
			<TR>
				<TD>
					<INPUT NAME="deleteClauseProgram" TYPE="checkbox" VALUE="1" disabled>
					Yes, I want to delete this clause from all the existing programs that have not been approved !!!
				</TD>
			</TR>
			----->
			<TR>
				<TD nowrap>
					<INPUT NAME="deleteClauseLibrary" TYPE="checkbox" VALUE="1" onclick="refreshCheckDisabled(this.form);">
					Delete from the clause library and program templates.
				</TD>
			</TR>
			<TR>
				<TD nowrap>
					<INPUT NAME="deleteClauseProgram" TYPE="checkbox" VALUE="1" disabled>
					Delete from all the existing programs (not yet approved).
				</TD>
			</TR>
			<TR>
				<TD align="center">
					<br>
					<CF_BUTTON
						BUTTON_NAME		=	""
						BUTTON_CAPTION	=	"delete this clause"
						BUTTON_ACTION	=	"javascript:delete_Clause();"
						BUTTON_TYPE		=	"link"
						BUTTON_WIDTH	=	"125"
						BUTTON_COLOR	=	"Navy"
						BUTTON_TIP		=	""
						FONT_COLOR		=	"White"
						FONT_SIZE		=	"12"
						FONT_WEIGHT		=	"bold">		
				</TD>
			</TR>
			</TABLE>
			
			<input name="id" type="hidden" value="#form.id#">
			<input name="referer" type="hidden" value="#cgi.http_referer#">
			<input name="command" type="hidden" value="#form.command#">
		</form>
		</cfif>
	</cfif>
</cfif>
</cfoutput>