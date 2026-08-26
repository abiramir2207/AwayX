<!-----------------------------------------------------------------------------

FILE NAME:		uploadFile.cfm
DESCRIPTION:	Upload a file to a location
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	24-Feb-2015 	Created
							
------------------------------------------------------------------------------> 

 <cfparam name="FORM.single_file" default=""/>
 <cfparam name="FORM.submitted" default="0" />
 
 <CFSET URL.PageTitle="HOLDING PEN :: Upload File">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
 
	<cfif FORM.submitted EQ "1">
		<cfset TempDirectoryLocation = GetDirectoryFromPath(form.single_file)>
		<cfset TempFileName = GetFileFromPath(form.single_file)>
		<cfdirectory directory="#TempDirectoryLocation#" filter="#TempFileName#" name="Tempdirectory">

		<cfset destPath = "#Application.Doc_Path#\Data_Files\Created\settings\HOLDING_PEN\Upload" />
		
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

		<!--- Create the temp table to write the data from the file --->
		<cfquery name="Create_Data_Table" datasource="#application.datasource#">
			IF object_id('tempdb..##BB_Upload_Hold_Report_BLK_INS') IS NOT NULL
			BEGIN	
    	    	DROP TABLE ##BB_Upload_Hold_Report_BLK_INS
			END	
                                    
            CREATE TABLE ##BB_Upload_Hold_Report_BLK_INS
			(
				[Upload_ID] [int] NULL,
				[Billback_Upload_III_PH_ID] [int] NULL, 
				[Billback_Upload_III_PD_ID] [int] NULL, 
				[FileName]  [varchar](255) NULL, 
				[Source]  [varchar](255) NULL,
				
				[Claim_Number] [varchar](255) NULL,
				[Claim_Start_Date] [varchar](50) NULL,
				[Claim_End_Date] [varchar](50) NULL,
				[Alias_Distributor] [varchar](255) NULL,
				[Alias_Distributor_Name] [varchar](255) NULL,
				[Xrefed_Shipto] Varchar(255),
				
				[Alias_Associated_Dist] [varchar](255) NULL,
				[Alias_Associated_Dist_Name] [varchar](255) NULL,
				[Xrefed_Associated_Shipto] Varchar(255),
				
				[Alias_Item] [varchar](255) NULL,
				[Alias_Item_Description] [varchar](255) NULL,
				[Xrefed_Item]  Varchar(255),
				
				[Alias_Operator] [varchar](255) NULL,
				[Alias_Operator_Name] [varchar](255) NULL,
				[Xrefed_Operator]  Varchar(255),
				
				[Alias_Program] [varchar](255) NULL,           
				[Alias_Program_Name] [varchar](255) NULL,              
				[Xrefed_Program]  Varchar(255),      
				[Program_Validation] Varchar(50),   
				[Total_Claim_Dollars] [varchar](50) NULL
			)
			
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
		
		<cfstoredproc procedure = "Upload_BB_Hold_Update" dataSource="#application.datasource#">
			<cfprocparam type="IN"  variable="@FilePath" value="#sFullPath#" cfsqltype="CF_SQL_VARCHAR" null="No">
			<cfprocparam type="IN"  variable="@FilenameExt" value="#sFileName#" cfsqltype="CF_SQL_VARCHAR" null="No">
			<cfprocparam type="IN"  variable="@user_ID" value="#userID#" cfsqltype="CF_SQL_VARCHAR" null="No">
			<cfprocresult name = qryResult>
		</cfstoredproc>
		<!--- Query the details from the Success_Failure_Table to display the result of upload --->
		<cfquery name="selSuccessFailureStatus" datasource="#application.datasource#">
			SELECT * FROM ##Success_Failure_Status 	
		</cfquery>
		<br> 
		<cfif (selSuccessFailureStatus.recordCount NEQ 0 AND IsDefined("selSuccessFailureStatus.Status") AND selSuccessFailureStatus.Status EQ 2)>
			<strong><cfoutput>#selSuccessFailureStatus.Message#!!</cfoutput></strong>
		<cfelse>
		 	<strong>Upload Failed!!</strong>
		</cfif>
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
			}
 		}
	</SCRIPT>
	
<form id="uploadFiles" name="uploadFiles" method="post" action="uploadFile.cfm" ENCTYPE="multipart/form-data" target="_self" >
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
 
