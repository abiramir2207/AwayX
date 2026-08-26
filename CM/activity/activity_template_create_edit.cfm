<cfoutput>

<cfset useLakebaseForqTempGet = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cm_activity_template")>
<cfif useLakebaseForqTempGet>
	<cftry>
		<cfset qTempGet = application.oLakebase.toQuery(
			application.oLakebase.selectRows("cm_activity_template", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqTempGet = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqTempGet>
<cfquery name="qTempGet" datasource="#application.datasource#">
	SELECT	* 
	FROM 	CM_Activity_Template
</cfquery>
</cfif>

<cfloop query="qTempGet">
	<a href="/cm/handler.cfm?command=ceActivityTemplate&id=#CM_Activity_Template_ID#">#Activity_Template_Name#</a><br>
</cfloop>

<cfparam name="url.id" default=0 />
<cfparam name="form.id" default="#url.id#" />
<cfparam name="form.hasState" default="0" />
<cfparam name="form.wddxFile" default="0" />
<cfparam name="form.Activity_Name" default="" />
<cfparam name="form.Activity_Notes" default="" />

<cfset actTemplMang = CreateObject("component","cm.activity.com.ActivityTemplateManager") />

<!---call functions to get lookup data--->
<cfset qGetActQuestTypes = actTemplMang.getActivityQuestionType() />

<!----////////////////////////////////// Controller Section ///////////////////////////////////////////////--->

<!---get wddx data packet from file--->
<cfset actvObjData = request.app_general_functions.getWDDXDataFromFile("\temp_files\#form.wddxFile#") />

<!---/////////////// SAVE //////////////////--->
<cfif isDefined("form.save")>
	
	<cfset actTempl = actTemplMang.get(0) />
	<cfset actTempl.setId(form.id) />
	<cfset actTempl.setName(form.Activity_Name) />
	<cfset actTempl.setNotes(form.Activity_Notes) />
	<cfset actTempl.setCreatedBy(request.AccessStructure.user_id) />
	<cfset actTempl.setUpdatedBy(request.AccessStructure.user_id) />
	<cfloop index="i" from="1" to="#ArrayLen(actvObjData.question.freeForm.questions)#">
		<cfset actTempl.setFreeFormQuestions(actvObjData.question.freeForm.questions[i]) />
	</cfloop>
	<cfloop index="i" from="1" to="#ArrayLen(actvObjData.question.option.options)#">
		<cfset actTempl.setOptions(actvObjData.question.option.options[i]) />
	</cfloop>
	<cfloop index="i" from="1" to="#ArrayLen(actvObjData.question.quantitative.questions)#">
		<cfset actTempl.setQuantitativeQuestions(actvObjData.question.quantitative.questions[i]) />
	</cfloop>
	<cfset dataPacket = actTemplMang.getData(actTempl) />
	<cfset actTemplMang.save(dataPacket) />
	<cflocation url="/cm/handler.cfm?command=ceActivityTemplate" />
	
<cfelse>
	
	<!---handle for resubmits--->
	<cfif form.hasState>
		<cfset actTempl = actTemplMang.get(0) />
		<cfset actTempl.setId(form.id) />
		<cfset actTempl.setName(form.Activity_Name) />
		<cfset actTempl.setNotes(form.Activity_Notes) />
		<cfset actTempl.setCreatedBy(request.AccessStructure.user_id) />
		<cfset actTempl.setUpdatedBy(request.AccessStructure.user_id) />
		<cfloop index="i" from="1" to="#ArrayLen(actvObjData.question.freeForm.questions)#">
			<cfset actTempl.setFreeFormQuestions(actvObjData.question.freeForm.questions[i]) />
		</cfloop>
		<cfloop index="i" from="1" to="#ArrayLen(actvObjData.question.option.options)#">
			<cfset actTempl.setOptions(actvObjData.question.option.options[i]) />
		</cfloop>
		<cfloop index="i" from="1" to="#ArrayLen(actvObjData.question.quantitative.questions)#">
			<cfset actTempl.setQuantitativeQuestions(actvObjData.question.quantitative.questions[i]) />
		</cfloop>
		
	<!---first time in--->
	<cfelse>
		<cfset form.wddxFile = CreateUUID() />
		<cfset actTempl = actTemplMang.get(form.id) />
	</cfif>
	
</cfif>

<cfset dataPacket = actTemplMang.getData(actTempl) />
<cfset request.app_general_functions.writeWDDXDataToFile(dataPacket , "\temp_files\#form.wddxFile#") />
<cfset actvObjData = request.app_general_functions.getWDDXDataFromFile("\temp_files\#form.wddxFile#") />

<!----////////////////////////////////// End Controller Section ///////////////////////////////////////////////--->

<form action="#cmHandler#" method="post" name="frm#commandSuffix#">

Name: <input type="text" name="Activity_Name" value="#actTempl.name#" /><br>
Notes: <input type="text" name="Activity_Notes" value="#actTempl.notes#" /><br>
<hr>
<b><font size="4">Questions</font></b><br><br>
<cfloop query="qGetActQuestTypes">
	<b><font size="2">#Activity_QA_Type_Name#</font></b>&nbsp;&nbsp;<a href="void(0)" onClick="return showWindow('/cm/activity/#replace(Activity_QA_Type_Name, " ", "_", "ALL")#_add.cfm', 'frm#commandSuffix#');">(add)</a><br>
	<cfif CM_Activity_QA_Type_ID eq 1>
		<table bgcolor="00CC00">
			<cfloop index="i" from="1" to="#ArrayLen(actvObjData.question.freeForm.questions)#">
				<tr bgcolor="FFFFFF">
					<td><b>Question:</b></td>
					<td>#actvObjData.question.freeForm.questions[i]#</td>
				</tr>
			</cfloop>
		</table>
	<cfelseif CM_Activity_QA_Type_ID eq 2>
		<table bgcolor="00CC00">
			<cfloop index="i" from="1" to="#ArrayLen(actvObjData.question.option.options)#">
				<tr bgcolor="CCCCCC">
					<td><b>Question:</b></td>
					<td>#actvObjData.question.option.options[i].question#</td>
				</tr>
				<cfloop index="n" from="1" to="#ArrayLen(actvObjData.question.option.options[i].answers)#">
					<tr bgcolor="FFFFFF">
						<td><b>Option:</b></td>
						<td>#actvObjData.question.option.options[i].answers[n]#</td>
					</tr>
				</cfloop>
				<tr bgcolor="FFFFFF"><td colspan="4">&nbsp;</td></tr>
			</cfloop>
		</table>
	<cfelseif CM_Activity_QA_Type_ID eq 3>
		<table bgcolor="00CC00">
			<cfloop index="i" from="1" to="#ArrayLen(actvObjData.question.quantitative.questions)#">
				<tr bgcolor="CCCCCC">
					<td><b>Question:</b></td>
					<td>#actvObjData.question.quantitative.questions[i].question#</td>
				</tr>
				<cfloop index="n" from="1" to="#ArrayLen(actvObjData.question.quantitative.questions[i].uom)#">
					<cfset qUomAbbr = actTemplMang.getUom(actvObjData.question.quantitative.questions[i].uom[n]) />
					<tr bgcolor="FFFFFF">
						<td><b>UOM Option:</b></td>
						<td>#qUomAbbr.QA_UOM_Abbr#</td>
					</tr>
				</cfloop>
				<cfloop index="n" from="1" to="#ArrayLen(actvObjData.question.quantitative.questions[i].uot)#">
					<cfset qUotAbbr = actTemplMang.getUot(actvObjData.question.quantitative.questions[i].uot[n]) />
					<tr bgcolor="FFFFFF">
						<td><b>UOT Option:</b></td>
						<td>#qUotAbbr.QA_UOT_Abbr#</td>
					</tr>
				</cfloop>
				<tr bgcolor="FFFFFF"><td colspan="4">&nbsp;</td></tr>
			</cfloop>
		</table>
	</cfif>
	<br>
</cfloop>
<br>
<input type="submit" name="save" value="Save" />
<a href="/cm/handler.cfm?command=ceActivityTemplate">(new)</a>
<input type="hidden" name="id" value="#form.id#" />
<input type="hidden" name="hasState" value="1" />
<input type="hidden" name="wddxFile" value="#form.wddxFile#" />
<input type="hidden" name="command" value="ce#commandSuffix#" />

</form>

</cfoutput>