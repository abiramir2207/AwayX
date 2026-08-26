<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\Planning_Groups\PG_Upload_Eff_Dates.cfm
      Date:     05-Sep-2019
      Author:   Anand Rao
      Purpose:  To Upload the member data with corrected effective dates

      Notes:

----------------------------------------------------------------------------------------------------------------------->

<cfparam name="FORM.single_file" default=""/>
<cfparam name="FORM.submitted" default="0" />
<cfparam name="URL.PGType" default=0 />
<cfparam name="URL.PGType" default=0 />
<cfparam name="URL.PG_Category_ID" default=0 />

<cfif URL.PGType EQ "1">
	<cfset PGTypeName = 'Product' />
<cfelseif URL.PGType EQ "2">
	<cfset PGTypeName = 'Distributor' />
<cfelseif URL.PGType EQ "3">
	<cfset PGTypeName = 'Operator' />
</cfif>
 
 <CFSET URL.PageTitle="#PGTypeName# :: Upload File">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<cf_include files="/styles/css-loader.css">
<cfinclude template="/Common_Files/jQuery.cfm">
 
	<cfif FORM.submitted EQ "1">
		<cfset TempDirectoryLocation = GetDirectoryFromPath(form.single_file)>
		<cfset TempFileName = GetFileFromPath(form.single_file)>
		<cfdirectory directory="#TempDirectoryLocation#" filter="#TempFileName#" name="Tempdirectory">

		<cfset destPath = "#Application.Doc_Path#\Data_Files\Created\settings\Planning_groups\Upload" />
		


	    <cfif not DirectoryExists(destPath)>
	        <cfdirectory directory = #destPath# action = "create">
	    </cfif>		
		
   		<cfif FindNoCase("C:", destPath)>
			<cfset destPath  = "\\" & Application.WebServerName & Replace(destPath, "C:", "")>
		<cfelseif FindNoCase("E:", destPath)>
			<cfset destPath  = "\\" & Application.WebServerName & Replace(destPath, "E:", "")>
		<cfelseif FindNoCase("D:", destPath)>
			<cfset destPath  = "\\" & Application.WebServerName & Replace(destPath, "D:", "")>
		<cfelse>
			<cfset destPath  = "\\" & Application.WebServerName & Replace(destPath, "F:", "")>
		</cfif>

<!--- For testing only remove after coding is done: --->	
<!--- <cfset destPath = "\\webssd\InetPub\wwwroot\landolakes.stage.awayx.com\AwayX\common_documents\Data_Files\Created\settings\Planning_groups\Upload"/> --->

		<cffile action = "upload" fileField = "single_file"   
			destination = "#destPath#" nameConflict="OVERWRITE" >		
		<cfset sFileName = Trim(cffile.serverFile) />
		<cfset sFullPath  =  "#destPath#\#sFileName#" />
		<cfset userID	 = request.AccessStructure.user_ID />

<!--- For testing only remove after coding is done: --->	
<!--- <cfset sFullPath = "\\webssd\InetPub\wwwroot\landolakes.stage.awayx.com\AwayX\common_documents\Data_Files\Created\settings\Planning_groups\Upload\"   & "#sFileName#"  /> --->
  
		<!--- Create the temp table to write the data from the file --->
		<cfquery name="Create_Data_Table" datasource="#application.datasource#">
			IF object_id('tempdb..##Success_Failure_Status') IS NOT NULL
			BEGIN	
    	    	DROP TABLE ##Success_Failure_Status
			END	
			 
			CREATE TABLE ##Success_Failure_Status
			(
				[Message]  [varchar](max), 
				[Status]  [varchar](max)
			)			
		</cfquery>
		
		<cfoutput>		
			<cfstoredproc procedure = "USP_PG_MACRO_MEMBERS_UPDATE" dataSource="#application.datasource#">
				<cfprocparam type="IN"  variable="@FilePath" value="#sFullPath#" cfsqltype="CF_SQL_VARCHAR" null="No">
				<cfprocparam type="IN"  variable="@User_ID" value="#userID#" cfsqltype="CF_SQL_VARCHAR" null="No">
				<cfprocparam type="IN"  variable="@Category_ID" value="#URL.PG_Category_ID#" cfsqltype="CF_SQL_VARCHAR" null="No">
				<cfprocresult name = qryResult>
			</cfstoredproc>
			<!--- Query the details from the Success_Failure_Table to display the result of upload --->
			<cfquery name="selSuccessFailureStatus" datasource="#application.datasource#">
				SELECT * FROM ##Success_Failure_Status 	
			</cfquery>
			<br> 
			<cfif (selSuccessFailureStatus.recordCount NEQ 0 AND IsDefined("selSuccessFailureStatus.Status") AND selSuccessFailureStatus.Status EQ 2)>
				<strong>#selSuccessFailureStatus.Message#!!</strong>
				<script language="javascript">
						window.opener.callSpinner();
						window.opener.location.reload();
				</script>
			<cfelse>
			 	<strong>Upload Failed due the below reason:</strong><br>
				<br>
				<font Color="red">
				#selSuccessFailureStatus.Message#<br><br>
				Please correct and reupload the file.
				</font>
			</cfif>
		</cfoutput>		
		<br>
		<br>
				<input type="button" onclick="javascript:window.close();" title="Close window" value="Close window">
		<cfquery name="delSuccessFailureStatus" datasource="#application.datasource#">
			IF object_id('tempdb..##Success_Failure_Status') IS NOT NULL
			BEGIN	
    	    	DROP TABLE ##Success_Failure_Status
			END		
		</cfquery>

		<cfabort>
	</cfif><!--- END: <cfif FORM.submitted EQ "1">  --->
 

	<SCRIPT type="text/javascript">
		function submitForm(submitter)
		{
			var thisForm = document.all.uploadFiles;
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
				callSpinner();
			}
 		}
	function callSpinner(){
		show_loader( "UPLOADING... PLEASE WAIT...", 1000 );
	}		
	</SCRIPT>
<cfoutput>
<form id="uploadFiles" name="uploadFiles" method="post" action="PG_Upload_Eff_Dates.cfm?PGType=#URL.PGType#&PG_Category_ID=#URL.PG_Category_ID#" ENCTYPE="multipart/form-data" target="_self" >
	<table width="80%" border="0">
		<tr>
			<td>
				<strong>Select the File to Upload:</strong>
			</td>
		</tr>
		<tr>
			<td valign="top">
				<input type="file" size="80" name="single_file" /><!--- accept=".txt" --->
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
