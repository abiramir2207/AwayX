<cfoutput>
<html>
<head>
<title>Add Quantative Question</title>

<cfparam name="url.formName" default="" />
<cfparam name="form.formName" default="#url.formName#" />
<cfparam name="form.question" default="" />
<cfparam name="form.uomId" default="" />
<cfparam name="form.uotId" default="" />
<cfparam name="form.uomIdSelected" default="" />
<cfparam name="form.uotIdSelected" default="" />
<cfparam name="form.uomSelected" default="" />
<cfparam name="form.uotSelected" default="" />


<!---get lookup data--->
<cfset actTemplMang = CreateObject("component","cm.activity.com.ActivityTemplateManager") /> 
<cfset qGetUom = actTemplMang.getUom() />
<cfset qGetUot = actTemplMang.getUot() />

<!---on submit dump data out to wddx file--->
<cfif isDefined("form.add")>

	<!---read from the data packet--->
	<cfset actvObjData = request.app_general_functions.getWDDXDataFromFile("\temp_files\#form.wddxFile#") />
	
	<!---create arrays--->
	<cfset aUom = ArrayNew(1) />
	<cfset aUot = ArrayNew(1) />
	
	<!---populate arrays from form data--->
	<cfloop index="i" from="1" to="#ListLen(form.uomSelected)#">
		<cfset aUom[i] = ListGetAt(form.uomSelected, i) />
	</cfloop>
	
	<cfloop index="n" from="1" to="#ListLen(form.uotSelected)#">
		<cfset aUot[n] = ListGetAt(form.uotSelected, n) />
	</cfloop>
	
	<cfset stTemp = StructNew() />
	<cfset stTemp.question = form.question />
	<cfset stTemp.uom = aUom />
	<cfset stTemp.uot = aUot />

	<!---add data to the data packet--->
	<cfset ArrayAppend(actvObjData.question.quantitative.questions, stTemp) />

	<!---write saved data to the data packet--->
	<cfset request.app_general_functions.writeWDDXDataToFile(actvObjData , "\temp_files\#form.wddxFile#") />
	
	<script language="JavaScript">
		opener.document.all.<CFOUTPUT>#Form.formName#</CFOUTPUT>.submit();
		window.close();
	</script>
	<cfabort>
	
</cfif>
</head>

<cfif isDefined("form.addUom") and isDefined("form.uomId")>

	<cfloop index="i" list="#form.uomId#">
	
		<cfif not ListFindNoCase(form.uomSelected, i)>
			<cfset form.uomSelected = ListAppend(form.uomSelected, i) />
		</cfif>
		
	</cfloop>
	
</cfif>

<cfif isDefined("form.addUot") and isDefined("form.uotId")>

	<cfloop index="i" list="#form.uotId#">
	
		<cfif not ListFindNoCase(form.uotSelected, i)>
			<cfset form.uotSelected = ListAppend(form.uotSelected, i) />
		</cfif>
		
	</cfloop>
	
</cfif>

<form action="" method="post" name="thisForm">
<table>
	<tr>
		<td>Question:</td>
		<td><input name="question" type="text" value="#form.question#" /></td>
	</tr>
	<tr>
		<td valign="top">Add Unit Of Measure:</td>
		<td valign="top">
			<select name="uomId" multiple>
				<cfloop query="qGetUom">
					<cfif not ListFindNoCase(form.uomSelected, CM_QA_UOM_ID)>
						<option value="#CM_QA_UOM_ID#">#QA_UOM_Abbr#</option>
					</cfif>
				</cfloop>
			</select>
			<input type="submit" name="addUom" value="Add" />
		</td>
		<td valign="top">
			<select name="uomIdSelected" multiple>
				<cfloop query="qGetUom">
					<cfif ListFindNoCase(form.uomId, CM_QA_UOM_ID) or ListFindNoCase(form.uomIdSelected, CM_QA_UOM_ID)>
						<option value="#CM_QA_UOM_ID#" selected>#QA_UOM_Abbr#</option>
					</cfif>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td valign="top">Add Unit Of Time:</td>
		<td valign="top">
			<select name="uotId" multiple>
				<cfloop query="qGetUot">
					<cfif not ListFindNoCase(form.uotSelected, CM_QA_UOT_ID)>
						<option value="#CM_QA_UOT_ID#">#QA_UOT_Abbr#</option>
					</cfif>
				</cfloop>
			</select>
			<input type="submit" name="addUot" value="Add" />
		</td>
		<td valign="top">
			<select name="uotIdSelected" multiple>
				<cfloop query="qGetUot">
					<cfif ListFindNoCase(form.uotId, CM_QA_UOT_ID) or ListFindNoCase(form.uotIdSelected, CM_QA_UOT_ID)>
						<option value="#CM_QA_UOT_ID#" selected>#QA_UOT_Abbr#</option>
					</cfif>
				</cfloop>
			</select>
		</td>
	</tr>
</table>
	
<input type="submit" name="add" value="Add" />

<input type="hidden" name="wddxFile" />
<input name="uomSelected" type="hidden" value="#ListSort(form.uomSelected, "Numeric")#" />
<input name="uotSelected" type="hidden" value="#ListSort(form.uotSelected, "Numeric")#" />

</form>
<script language="JavaScript">
	
	document.thisForm.wddxFile.value = opener.document.all.<CFOUTPUT>#Form.formName#</CFOUTPUT>.wddxFile.value;
	
</script>

</html>
</cfoutput>