<cfoutput>

	<!---custom tag that takes url variables and puts them in the form scope--->
	<cf_URLToForm>

	<!---set default values--->
	<cfparam name="url.catId" 						default="0" />
	<cfparam name="form.catId" 						default="#url.catId#" />
	<cfparam name="form.id" 							default="0" />
	<cfparam name="form.state" 						default="0" />
	<!--- 2 means (it should do it for all programs belonging to a template). I have just kept it for for backward compatibility.--->
	<cfparam name="form.applyToExisting" 	default="2" />
	<cfparam name="form.editFromProgram"	default="0">
	<cfparam name="form.programId" 				default="0">
	<cfparam name="form.submitForm" 			default="">
	<cfparam name="form.command" 					default="">
	<!--- Even though we are not using an defaultcase now, I have kept it for backward compatibility.--->
	<cfparam name="form.defaultClause" 		default="1">

	<cfset clauseLibMang = CreateObject("component","components.clause_library.ClauseLibraryManager").init() />

	<cfif isDefined("form.save")>
		
		<cfset clauseLib = clauseLibMang.getClause(0) />	
		<cfset clauseLib.setId(form.id) />
		<cfset clauseLib.setCategoryId(form.catId) />	
		<cfset clauseLib.setParentId(form.parentId) />
		<cfset clauseLib.setBody(form.Clause_Library_Body) />
		<cfset clauseLib.setBodyFrench(form.Clause_Library_Body_French) />
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
			<cfset clauseLib.setBodyFrench(form.Clause_Library_Body_French) />
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

		<form action="#thisPage#" method="post" name="frmClauseLib" style="display:inline;" id="frmClauseLib">
			<cfif command eq "eClauseProgram"><br><br></cfif>
			<table width="100%" border="0" cellpadding="2" cellspacing="0">
			 	<tr>
					<td style="font-size:14px;">
						&nbsp;<B>Clause Name:</B>
						#clauseLib.getCategory().getTitle()#		
					</td>
				</tr>
				<tr> 
					<td colspan="100%" style="color:Red">If the clause you are editing already exists on programs and templates, the changes will be saved to all the programs and templates that contain the clause.</td>
				</tr>
				<!--- This is the rich text wysiwyg editor --->	
				<tr>
					<td>
		 				<!--- Dev Notes: D24468/Anand Rao/17-Aug-10  URL on email notifications --->  
		  			<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
						<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
						<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START
						What  I did: Comment out CF_ACTIVEEDIT and replace it with TEXTAREA for WYSIWYG tool--->
						<textarea id="textarea" name="Clause_Library_Body" style="width:700px;height:300px;">
							<CFOUTPUT>#clauseLib.getBody()#</CFOUTPUT>
						</textarea>
						<!--- End Dev Note: drachala; D28078:Text Editor tools in Forge not working with Windows 7 END  --->
					</td>
				</tr>
				<!--- Dev Note: Kal; D44629: French Clause section; Displayed only if program label sets in french are defined --->
				<cfif bFrenchClause >
				<tr>
					<td>
						<br/><b>French Clause:</b> French version of the clause for templates with French Label set.
					</td>
				</tr>
				<tr>
					<td>
						<textarea id="textareaFrench" name="Clause_Library_Body_French" style="width:700px;height:300px;">
							<CFOUTPUT>#clauseLib.getBodyFrench()#</CFOUTPUT>
						</textarea>
					</td>
				</tr>
				<cfelse>
					<input type="Hidden" name="Clause_Library_Body_French" value="" />
				</cfif>
			</table>

			<input name="applyToExisting" type="hidden" value="2">
			<input type="Hidden" name="body_content" value="#HTMLEditFormat(clauseLib.getBody())#">
			<input type="Hidden" name="body_content" value="#HTMLEditFormat(clauseLib.getBodyFrench())#">
			<BR>

			<script language="JavaScript">
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
				function saveClause(editFromProgram, editId)
				{
					
						document.frmClauseLib.save.click();
					
				}
				function test(){
					alert("clear");
					alert(document.frmClauseLib.Clause_Library_Body.value);//='';
					document.frmClauseLib.reset();
				}
			</script>
			<!---  common ---->
			<table align="left" border="0" style="margin-left: 600px;">
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
