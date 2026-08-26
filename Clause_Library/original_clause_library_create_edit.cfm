<cfoutput>

<!---custom tag that takes url variables and puts them in the form scope--->
<cf_URLToForm>

<!---set default values--->
<cfparam name="url.catId" 				default="0" />
<cfparam name="form.catId" 				default="#url.catId#" />

<cfparam name="form.id" 				default="0" />
<cfparam name="form.state" 				default="0" />
<cfparam name="form.applyToExisting" 	default="0" />
<cfparam name="form.editFromProgram"	default="0">
<cfparam name="form.programId" 			default="0">
<cfparam name="form.submitForm" 		default="">
<cfparam name="form.command" 			default="">
<cfparam name="form.defaultClause" 		default="0">

<cfset clauseLibMang = CreateObject("component","components.clause_library.ClauseLibraryManager").init() />

<cfif isDefined("form.save")>
	
	<cfset clauseLib = clauseLibMang.getClause(0) />
	
	<cfset clauseLib.setId(form.id) />
	<cfset clauseLib.setCategoryId(form.catId) />	
	<cfset clauseLib.setParentId(form.parentId) />
	<cfset clauseLib.setBody(form.Clause_Library_Body) />
	<cfset clauseLib.setCreatedBy(request.AccessStructure.User_ID) />
	<cfset clauseLib.setUpdatedBy(request.AccessStructure.User_ID) />
	<cfset clauseLib.setApplyToExisting(form.applyToExisting) />
	<cfset clauseLib.setEditFromProgram(form.editFromProgram) />
	<cfset clauseLib.setProgramId(form.programId) />
	<cfset clauseLib.setIsDefault(form.defaultClause) />
	
	
	<cfset newId = clauseLibMang.save() />

	<!---if the command is edit from program then close the window and submit the calling page--->
	<cfif form.command eq "eClauseProgram">
		<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
		<SCRIPT LANGUAGE="JavaScript">
			completeEdit();
			function completeEdit()
			{
				var openerForm = opener.document.#form.submitForm#;
				if(openerForm)
				{
					//opener.document.#form.submitForm#.state.value = 0;
					var oldValue = "#form.id#";					
					var newValue = "#newId#";
					var iCat = "#form.catId#";
					
					//remove old id and add new id to claus elist
					var oldClauseIds = openerForm.lClauseIds.value;
					var clauseIds = oldClauseIds;
					clauseIds = ListDeleteItem(clauseIds, ",", oldValue);
					
					if(clauseIds != oldClauseIds)
					{
						clauseIds = ListAppendItem(clauseIds, ",", newValue)	
					}
					openerForm.lClauseIds.value = clauseIds;
					
					
					//change the values of teh check boxes to new id
					changeCheckValue(openerForm.discType_0, oldValue, newValue, iCat);
					
					var discTypes = openerForm.discTypes.value;
					var discArr = discTypes.split(",");
					var i, arrLen = discArr.length;
					for(i=0;i<arrLen;i++)
					{
						changeCheckValue(eval("openerForm.discType_" + discArr[i]), oldValue, newValue, iCat);
					}
					
					openerForm.submit();
				}
				window.close();
			}
			
			function changeCheckValue(chObj, oldValue, newValue, iCat)
			{
				var chObj = Get_Object_Property_Match_Collection(chObj, "value", oldValue);
				
				if(chObj)
				{
					chObj.value = newValue;
					addHiddenSibling(chObj, newValue, iCat, chObj.form);
				}
			}
			
			function addHiddenSibling(chObj, oValue, iCat, oForm)
			{
				/* Comment the line below. This line does not work on IE 10. */
				/* var oElement = opener.document.createElement("<INPUT TYPE='HIDDEN' NAME='ClauseCategoryId_" + oValue + "' VALUE='" + iCat + "'>"); */
				
				/* This works on all versions of IE. This is the IE 10 fix. */
				var oElement = opener.document.createElement("input");
					oElement.setAttribute("type", "hidden");
					oElement.setAttribute("id", 'ClauseCategoryId_' + ''+oValue+'');
					oElement.setAttribute("name", 'ClauseCategoryId_' + ''+oValue+'');				
					oElement.setAttribute("value", ''+iCat+'');
				oForm.insertBefore(oElement);
			}

		</SCRIPT>
	
	<cfelse>
	
		<cflocation url="#thisPage#?command=ceClauseCategory&id=#form.catId#" />
		
	</cfif>
	
<cfelse>
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
	<cfif form.state>
	
		<!---load from form--->
		<cfset clauseLib = clauseLibMang.getClause(0) />
	
		<cfset clauseLib.setId(form.id) />
		<cfset clauseLib.setParentId(form.parentId) />
		<cfset clauseLib.setTitle(form.Clause_Library_Title) />
		<cfset clauseLib.setBody(form.Clause_Library_Body) />
		<cfset clauseLib.setCreatedBy(request.AccessStructure.User_ID) />
		<cfset clauseLib.setUpdatedBy(request.AccessStructure.User_ID) />
		<cfset clauseLib.setRequireAll(form.requireAll) />
		<cfset clauseLib.setApplyToExisting(form.applyToExisting) />
		<cfset clauseLib.setRequireApproval(form.requireApproval) />
		<cfset clauseLib.setEditFromProgram(form.editFromProgram) />
		<cfset clauseLib.setDiscountTypeId(form.discountTypeId) />
		<cfset clauseLib.setClauseType(form.clauseType) />
		<cfset clauseLib.setIsRequired(form.isRequired) />
		<cfset clauseLib.setProgramId(form.programId) />
	
	<cfelse>
	
		<cfset clauseLib = clauseLibMang.getClause(form.id, form.catId) />
	
	</cfif>
	<form action="#thisPage#" method="post" name="frmClauseLib" style="display:inline;">
	<cfif command eq "eClauseProgram"><br><br></cfif>
	<table width="100%" border="0" cellpadding="2" cellspacing="0">
	 	<tr>
			<td style="font-size:14px;">
				&nbsp;<B>Clause Category Name:</B>
				#clauseLib.getCategory().getTitle()#				
			<cfif command neq "eClauseProgram">
			<CF_SmallHelp width="600">
				<table cellpadding="0" cellspacing="0">
				<tr>
				<td>
				<B>Apply this change to current programs</B> - If you select this option, the change you are making to this particular clause will be propogated to all the programs (not yet approved) which contains this clause.
				</td>
				</tr>
				</table>
			</CF_SmallHelp>
			</cfif>
			</td>
		</tr>
	 
	<cfif command neq "eClauseProgram">
		<tr>
			<td>				
				<cfif form.id>
					<input name="applyToExisting" type="radio" value="1">Apply to None Approved Programs
					<input name="applyToExisting" type="radio" value="2">Apply to All Programs (including approved)
				<cfelse>
				<input name="applyToExisting" type="hidden" value="0">
				<input type="checkbox" disabled>Apply this change to current programs
				</cfif>
				&nbsp;&nbsp;&nbsp;
				<cfif clauseLib.getCategory().getDefaultClauseId() EQ form.id>
				<input type="checkbox" value="1" checked disabled>Set as default clause
				<input name="defaultClause" type="hidden" value="1">
				<cfelse>
				<input name="defaultClause" type="checkbox" value="1">Set as default clause
				</cfif>				
				&nbsp;&nbsp;&nbsp;
				<span id="SP_Clause_Library_Body">&nbsp;</span>
			</td>
		</tr>
	
	</cfif>
		<!--- This is the rich text wysiwyg editor --->	
		<!--- <B>Clause Text:</B>&nbsp;<span id="SP_Clause_Library_Body">&nbsp;</span><BR> --->
		<tr>
			<td>
				<!--- Dev Notes: D24468/Anand Rao/17-Aug-10 URL on email notifications --->  
				<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

				<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />

				<textarea id="textarea" name="Clause_Library_Body" style="width:700px;height:300px;">
					<CFOUTPUT>#clauseLib.getBody()#</CFOUTPUT>
				</textarea>

			</td>
		</tr>
	</table>
	<input type="Hidden" name="body_content" value="#HTMLEditFormat(clauseLib.getBody())#">
	<BR>
	<script language="JavaScript">
	/*
		function saveClause(editFromProgram, editId)
		{
			var thisForm = document.frmClauseLib;
			var anyChanged = 0;
			var canSubmit = true;
			
			if(thisForm.defaultClause)
			{
				anyChanged = anyChanged || anyChange(thisForm.defaultClause);
			}
						
			var i = 1;
			var DHTMLSafe = aeObjects[i];
			var ae_content = ae_onBeforeSave(DHTMLSafe, aeFieldnames[i]);
			anyChanged = anyChanged || (trim(thisForm.body_content.value) != trim(ae_content));		
			
			if(trim(ae_content).length == 0 || trim(ae_content).toLowerCase() == "<p>&nbsp;</p>")
			{
				queueMessage("Body cannot be empty",document.all.SP_Clause_Library_Body)
				canSubmit = false;
			}
			else
			{
				<!------ TODO: ----->
				//clearQueue(document.all.SP_Clause_Library_Body);
			}
			
			
			if(!canSubmit)
			{
				showMessageWindow();
			}
			else if(!anyChanged)
			{
				// queueMessage("None of the properties of the clause has been changed.",document.all.SP_Clause_Library_Title);
				// showMessageWindow();				
				alert("None of the properties of the clause has been changed.");
			}
			else
			{
				document.frmClauseLib.save.click();
			}
		}
	*/	

		function saveClause(editFromProgram, editId)
		{
				document.frmClauseLib.save.click();
		}

		function anyChange(oElement)
		{
			
			if(oElement)
			{
				if(oElement.type == "checkbox")
				{
					return (oElement.defaultChecked != oElement.checked);
				}
				else
				{
					return (oElement.defaultValue != oElement.value);
				}
			}
			return false;		
		}
	</script>
	<!---  common ---->
	<table align="center">
	<tr>
	<td>
	<cfif form.editFromProgram>
	<CF_button
		button_name		=	""
		button_caption	=	"Cancel"
		button_action	=	"window.close();"
		button_type		=	"javascript_link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Cancel"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
		>
	<cfelse>
	<CF_button
		button_name		=	""
		button_caption	=	"cancel"
		button_action	=	"history.back();"
		button_type		=	"javascript_link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Cancel"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
		>
	</cfif>
	</td>
	<td>
	<CF_button
		button_name		=	""
		button_caption	=	"save"
		button_action	=	"saveClause(#form.editFromProgram#, #form.id#);"
		button_type		=	"javascript_link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Save"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
		>
	</td>
	<td>
	<CF_button
		button_name		=	""
		button_caption	=	"reset"
		button_action	=	"javascript:document.frmClauseLib.reset();"
		button_type		=	"javascript_link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Save"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
		>
	
	</td>
	</tr>
	</table>
	<input type="submit" name="save" value="Save" style="visibility:hidden;" />
	<input type="hidden" name="id" value="#clauseLib.getId()#" />
	<input type="hidden" name="catId" value="#clauseLib.getCategoryId()#" />
	<input type="hidden" name="parentId" value="#clauseLib.getParentId()#" />
	<input type="hidden" name="state" value="1" />
	<input type="hidden" name="editFromProgram" value="#form.editFromProgram#" />
	<input type="hidden" name="programId" value="#form.programId#" />
	<input type="hidden" name="submitForm" value="#form.submitForm#" />
	<input type="hidden" name="command" value="#form.command#" />
	
	</form>
	<cf_messagewindow>
</cfif>
</cfoutput>