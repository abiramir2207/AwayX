<cfoutput>
<html>
<head>
<title>Add Question with Options</title>

<cfparam name="url.formName" default="" />
<cfparam name="form.formName" default="#url.formName#" />
<cfparam name="form.question" default="" />
<cfparam name="form.option" default="" />
<cfparam name="form.numbOfOptions" default="0" />

<!---on submit dump data out to wddx file--->
<cfif isDefined("form.add")>

	<!---read from the data packet--->
	<cfset actvObjData = request.app_general_functions.getWDDXDataFromFile("\temp_files\#form.wddxFile#") />
	
	<!---build options array--->
	<cfset aOptions = ArrayNew(1) />
	<cfloop index="i" from="1" to="#form.numbOfOptions#">
		<cfset aOptions[i] = Evaluate("form.option_#i#") />
	</cfloop>
	
	<!---build question struct to append--->
	<cfset stTemp = StructNew() />
	<cfset stTemp.question = form.question />
	<cfset stTemp.answers = aOptions />

	<!---add data to the data packet--->
	<cfset ArrayAppend(actvObjData.question.option.options, stTemp) />
	
	<!---write saved data to the data packet--->
	<cfset request.app_general_functions.writeWDDXDataToFile(actvObjData , "\temp_files\#form.wddxFile#") />
	
	<script language="JavaScript">
		opener.document.all.<CFOUTPUT>#Form.formName#</CFOUTPUT>.submit();
		window.close();
	</script>
	<cfabort>
	
</cfif>
</head>

<form action="" method="post" name="thisForm">
<table>
	<tr>
		<td>Question:</td>
		<td><input name="question" type="text" value="#form.question#" /></td>
	</tr>
	<cfif isDefined("form.addQuestion")>
		
		<cfset form.numbOfOptions = form.numbOfOptions + 1 />
		
		<cfloop index="indx" from="1" to="#form.numbOfOptions#">
		
			<cfparam name="form.option_#indx#" default="" />
			<tr>
				<td>Question Option</td>
				<td><input name="option_#indx#" type="text" value="#Evaluate("form.option_#indx#")#" /></td>
			</tr>
			
		</cfloop>
		
	</cfif>
	<tr>
		<td>&nbsp;</td>
		<td>
			<input type="submit" name="addQuestion" value="Add Question" />
		</td>
	</tr>
</table>

	<input type="submit" name="add" value="Add" />
	
	<input type="hidden" name="wddxFile" />
	<input type="hidden" name="numbOfOptions" value="#form.numbOfOptions#" />
</form>
<script language="JavaScript">
	
	document.thisForm.wddxFile.value = opener.document.all.<CFOUTPUT>#Form.formName#</CFOUTPUT>.wddxFile.value;
	
</script>

</html>
</cfoutput>