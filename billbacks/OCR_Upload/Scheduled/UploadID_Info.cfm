<cfset idDoesNotExist = 0 />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
 
<html>
<head>
	<title>..:: CIA Upload Status ::..</title>
	<style>
#titleFont{
font-family: "Arial Black", Gadget, sans-serif;
font-size: 12px;
word-spacing: 2px;
color: #05034C;
 
text-decoration:  underline;
font-style: normal;
font-variant: normal;
text-transform: uppercase;
}	
	
#settingsFont {
font-family: Tahoma, Geneva, sans-serif;
font-size: 12px;
word-spacing: 2px;
color: #080570;
font-weight: 700;
text-decoration: none;
font-style: normal;
font-variant: normal;
text-transform: none;
}
#uploadDetailsFont{
font-family: "Arial Black", Gadget, sans-serif;
font-size: 12px;
word-spacing: 2px;
color: #5E34EA;
text-decoration: none;
font-style: normal;
font-variant: normal;
}	
	
	
	</style>
</head>

<body>
<cfoutput>
<br>
 
<h2><font color="##000099">CIA Upload Status Indicator:</font></h2><br>

	<form name="frmEasterEgg" action="UploadID_Info.cfm" method="post">
	Enter an CIA Upload ID: 	
	<input type="text" size="8" name="OCRUploadID"/>
	<input type="submit" name="submit" value="Submit">
	</form>
	
<cfif isdefined("URL.UploadID") and URL.UploadID NEQ "">
	<cfset FORM.OCRUploadID = URL.UploadID />
</cfif>	
	
	<cfif (isDefined("FORM.OCRUploadID")	AND FORM.OCRUploadID NEQ "")>
		<cfset useLakebaseForqGetOCRUploadByID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForqGetOCRUploadByID>
	<cftry>
		<cfset qGetOCRUploadByID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_log", {
				"ocr_upload_id" = "eq.#FORM.OCRUploadID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetOCRUploadByID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetOCRUploadByID>
<cfquery name="qGetOCRUploadByID" datasource="#application.datasource#">
			SELECT * FROM OCR_Upload_Log where OCR_Upload_ID = #FORM.OCRUploadID#
		</cfquery>
</cfif>
	
	
	
	<cfif (isDefined("qGetOCRUploadByID") AND qGetOCRUploadByID.RecordCount NEQ 0)>
		<cfset useLakebaseForqGetOCRTemplateSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_template_settings")>
<cfif useLakebaseForqGetOCRTemplateSettings>
	<cftry>
		<cfset qGetOCRTemplateSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_template_settings", {
				"ocr_template_settings_id" = "eq.#qGetOCRUploadByID.OCR_Template_Settings_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetOCRTemplateSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetOCRTemplateSettings>
<cfquery name="qGetOCRTemplateSettings" datasource="#application.datasource#">
			SELECT * FROM OCR_Template_Settings WHERE OCR_Template_Settings_ID = #qGetOCRUploadByID.OCR_Template_Settings_ID#
		</cfquery>
</cfif>
		
<!----  DISPLAY STARTS --->		
		<div id="titleFont">Important Detail about this upload:</div>
<br>
	
			<table cellspacing="0" cellpadding="4" border="1" id="uploadDetailsFont">
				<tr>
					<td>Upload_ID</td><td>#FORM.OCRUploadID#</td>
				</tr>
				<tr><td>File Name:</td><td>#qGetOCRUploadByID.File_name#</td></tr>
				<tr><td>CIA Settings ID:</td><td>#qGetOCRUploadByID.OCR_Template_Settings_ID#</td></tr>
				
				<tr><td>OCR_Step:</td><td>#qGetOCRUploadByID.OCR_Step#</td></tr>
				<tr><td>Debug_Dev_Status: </td><td>#qGetOCRUploadByID.Debug_Dev_Status#</td></tr>
				
				<tr><td>OCR_Upload_Status</td><td>#qGetOCRUploadByID.OCR_Upload_Status#</td></tr>
			 	<tr><td>Document_ID:</td><td>#qGetOCRUploadByID.Document_ID#</td></tr>		
				<cfif qGetOCRUploadByID.Document_ID_2 NEQ "">
					<tr><td>Document_ID 2:</td><td>#qGetOCRUploadByID.Document_ID_2#</td></tr>
				</cfif>																							
			</table><br><br>
			
			<div id="titleFont">CIA Template Settings:</div><br>
			<table cellspacing="0" cellpadding="4" border="1" id="settingsFont">
				<tr><td>Upload_ID:</td><td>#FORM.OCRUploadID#</td></tr>
				<tr><td>Settings ID:</td><td>#qGetOCRTemplateSettings.OCR_Template_Settings_ID#</td></tr>
				<tr><td>Template Name:</td><td>#qGetOCRTemplateSettings.OCR_Template_name#</td></tr>
				<tr><td>Template Description:</td><td>#qGetOCRTemplateSettings.OCR_Template_Description#</td></tr>
					
				<tr><td>Reader Name:</td><td>#qGetOCRTemplateSettings.OCR_Reader_Name#</td></tr>
				<tr><td>OCR_Code:</td><td>#qGetOCRTemplateSettings.OCR_Code#</td></tr>
				<tr><td>Allowable_File_Ext</td><td>#qGetOCRTemplateSettings.Allowable_File_Ext#</td></tr>
				<tr><td>DB_OCR_Source_Code</td><td>#qGetOCRTemplateSettings.DB_OCR_Source_Code#</td></tr>																												
				<tr><td>Is Active?</td><td>#qGetOCRTemplateSettings.Active#</td></tr>	
				<tr><td>Is Deleted?</td><td>#qGetOCRTemplateSettings.Deleted#</td></tr>					
				
				<tr><td>Is OCR Required?</td><td><cfif qGetOCRTemplateSettings.IS_OCR_Required EQ 1>YES<cfelse>NO</cfif></td></tr>
				<tr><td>Is Double Processing ON?</td><td><cfif qGetOCRTemplateSettings.IS_Double_Processing_ON EQ 1>YES<cfelse>NO</cfif> </td></tr>
				<tr><td>Is Triple Processing ON?</td><td><cfif qGetOCRTemplateSettings.Special_Processing_Flag EQ 1>YES<cfelse>NO</cfif> </td></tr>							
				<tr><td>Parser ID:</td><td>#qGetOCRTemplateSettings.Parser_ID#</td></tr>
				<tr><td>Source_Code:</td><td>#qGetOCRTemplateSettings.Source_Code#</td></tr>
			</table>			
			<br><br>
			<strong>Dumps from CF:</strong><br><br>
	<cfdump var="#qGetOCRUploadByID#" />
	<cfdump var="#qGetOCRTemplateSettings#" />
	
		<cfif qGetOCRTemplateSettings.Parser_ID NEQ "" AND qGetOCRUploadByID.Document_ID NEQ "">
			<cfif qGetOCRUploadByID.Document_ID_2 NEQ "">
				<cfset documentID = qGetOCRUploadByID.Document_ID_2 />
			<cfelse>
				<cfset documentID = qGetOCRUploadByID.Document_ID />
			</cfif>
			<cfhttp   method="get"  url = "https://api.docparser.com/v1/results/#qGetOCRTemplateSettings.Parser_ID#"  result="getFileContent"> <!--- /#qGetOCRUploadExtracted.Document_ID# --->
				<cfhttpparam type="header" name="Authorization" value="Basic #qGetOCRTemplateSettings.Account_ID#" />
				<cfhttpparam type="formfield"  name="format" value="object" /> <!--- This will return the result Filecontent as a JSON format --->
				<cfhttpparam type="formfield"  name="remote_id" value="#documentID#"/>
				<cfhttpparam type="formfield"  name="limit" value="9999" />		
				<cfhttpparam type="formfield"  name="include_processing_queue" value="true" />	
				<!--- <cfhttpparam type="formfield"  name="format" value="flat" />  This will give flat format output as Key/Value Pair ---> 
			</cfhttp>
			<cfset structFileContent = deserializeJSON(getFileContent.FileContent) />	
			<br>
			DocParser Output:<br>
			<cfdump var="#structFileContent#" />
			
		</cfif>
	
	<cfelse>
	<br>
		<br>
		<font color="red"><strong>The Upload ID entered is invalid!!</strong></font>
		<cfset idDoesNotExist = 1 />
	</cfif>
</cfif>
	
</cfoutput>
</body>
</html>
<cfif idDoesNotExist EQ "1">
	<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
	<script>
 	noty({
                text: "The Upload ID entered is invalid!!",
                layout: "topCenter",
                type: 'success',
                timeout:3500  });
	</script>
</cfif>	
