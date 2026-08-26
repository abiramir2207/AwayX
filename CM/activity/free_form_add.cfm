<cfoutput>
<html>
<head>
<title>Add Free Form Question</title>

<cfparam name="url.formName" default="" />
<cfparam name="form.formName" default="#url.formName#" />

<!---on submit dump data out to wddx file--->
<cfif isDefined("form.add")>

	<!---read from the data packet--->
	<cfset actvObjData = request.app_general_functions.getWDDXDataFromFile("\temp_files\#form.wddxFile#") />
	
	<!---add data to the data packet--->
	<cfset ArrayAppend(actvObjData.question.freeForm.questions, form.question) />
	
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
	Question:&nbsp;<input type="text" name="question" /><br>
	<input type="submit" name="add" value="Add" />
	<input type="hidden" name="wddxFile" />
</form>
<script language="JavaScript">
	
	document.thisForm.wddxFile.value = opener.document.all.<CFOUTPUT>#Form.formName#</CFOUTPUT>.wddxFile.value;
	
</script>

</html>
</cfoutput>