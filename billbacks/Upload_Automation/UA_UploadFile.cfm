<!-----------------------------------------------------------------------------

FILE NAME:		billbacks/Upload_Automation/UA_UploadFile.cfm
Copyright    :  (c) 2020 Blacksmith Applications, Inc.
Created Date :  18-Jun-2020
Created By   :  Anand Rao
Description  :  Upload the file for the upload automation process
------------------------------------------------------------------------------>

 <cfparam name="URL.UploadAutomationLogID" default="0" />
 <cfparam name="FORM.single_file" default=""/>
 <cfparam name="FORM.submitted" default="0" />

 <CFSET URL.PageTitle="Upload Automation :: Upload HLV File">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

	<cfif FORM.submitted EQ "1">
		<cfset TempDirectoryLocation = GetDirectoryFromPath(form.single_file)>
		<cfset TempFileName = GetFileFromPath(form.single_file)>
		<cfdirectory directory="#TempDirectoryLocation#" filter="#TempFileName#" name="Tempdirectory">

		<cfset destPath = "#Application.Doc_Path#\Data_Files\Uploaded\billbacks\uploadAutomation\Upload" />

   		<cfif FindNoCase("C:", destPath)>
			<cfset destPath  = "\\" & Application.WebServerName & Replace(destPath, "C:", "")>
		<cfelseif FindNoCase("E:", destPath)>
			<cfset destPath  = "\\" & Application.WebServerName & Replace(destPath, "E:", "")>
		<cfelseif FindNoCase("D:", destPath)>
			<cfset destPath  = "\\" & Application.WebServerName & Replace(destPath, "D:", "")>
		<cfelse>
			<cfset destPath  = "\\" & Application.WebServerName & Replace(destPath, "F:", "")>
		</cfif>

		<cffile action = "upload" fileField = "single_file"
			destination = "#destPath#" nameConflict="OVERWRITE" >
		<cfset sFileName = Trim(cffile.serverFile) />
		<cfset sFullPath  =  "#destPath#\#sFileName#" />
		<cfset userID	 = request.AccessStructure.user_ID />

		<cfquery name="getDTSPath" datasource="#application.datasource#">
			SELECT DTSPATH = DTS_Reference_Path+'\Extract'
			FROM   DataInt_Settings
			ORDER BY Dataint_setting_ID
		</cfquery>

		<cfset desDBPath = getDTSPath.DTSPATH & "\" />

		<cffile action = "copy"
		  source = "#sFullPath#"
		  destination = "#desDBPath#"
		  nameconflict="OVERWRITE">

		<cffile action = "rename"
		source = "#desDBPath#\#sFileName#"
		destination = "#desDBPath#\Clorox_3000_Rebate_Intake_Validate_Extract_Update_HLV.xlsx">

		<cfoutput>
		<cfquery name="qUpdFileName" datasource="#application.datasource#">
			UPDATE Upload_Automation_Log SET Update_HLV_FileName = '#sFileName#' WHERE Upload_Automation_Log_ID = #URL.UploadAutomationLogID#
		</cfquery>

	  	<cfstoredproc procedure = "Upload_3000_UA_Log" dataSource="#application.datasource#">
			<cfprocparam type="in" cfsqltype = "cf_sql_varchar"	value="3_0" dbvarname="@Upload_Status">
			<cfprocparam type="in" cfsqltype = "cf_sql_varchar" value="#request.AccessStructure.user_ID#"  dbvarname="@user_ID">
		</cfstoredproc>
		</cfoutput>
		<!--- UPDATE THE upda--->


	<cfthread action="RUN" NAME="CallUploadAndUpdate">
		<cfstoredproc procedure = "CF_3000_Rebate_Update_HLV_Error_Codes" dataSource="#application.datasource#">
		</cfstoredproc>
	</cfthread>
	<cfoutput>
			 <b>File "#sFileName#" has been uploaded. You can view the status in the Status section. </b><br><br>
				<input type="button" onclick="javascript:window.close();" title="Close window" value="Close window">
	</cfoutput>
		<cfabort>
	</cfif><!--- END: <cfif FORM.submitted EQ "1">  --->


	<SCRIPT type="text/javascript">
		function submitForm(submitter)
		{
			var thisForm = document.all.uploadHLVFile;
			var singleFile	= thisForm.single_file;
			var errors = 0;
			if (singleFile.value == "")
			{
				alert("Please select a file to upload!!!");
			}
			else
			{
				thisForm.submitted.value= '1' ;
				thisForm.submit();
			}
 		}
	</SCRIPT>
<cfoutput>
<form id="uploadHLVFile" name="uploadHLVFile" method="post" action="UA_UploadFile.cfm?UploadAutomationLogID=#URL.UploadAutomationLogID#" ENCTYPE="multipart/form-data" target="_self" >
	<table width="80%" border="0">
		<tr>
			<td>
				<strong>Select the File to Upload:</strong>
			</td>
		</tr>
		<tr>
			<td valign="top">
				<input type="file" size="80" name="single_file" accept=".xls,.xlsx" /><!--- accept=".txt" --->
			</td>
		</tr>
		<tr>
			<td align="right">
  				<strong><font color="red">[</font> <a href="##" onclick="javascript:return submitForm(this);">upload files</a> <font color="red">]</font> </strong>
			</td>
		</tr>
	</table>
	<input type="hidden" name="submitted" value="0" />
</form>
</cfoutput>