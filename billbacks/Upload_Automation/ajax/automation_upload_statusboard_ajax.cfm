<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/Upload_Automation/ajax/automation_upload_statusboard_ajax.cfm
Copyright    :  (c) 2020 Blacksmith Applications, Inc.
Created Date :  18-Jun-2020
Created By   :  Anand Rao
Description  :  Ajax statusboard 
---------------------------------------------------------------------------------->

<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">
  <cfsilent>
    <cfparam name="url.iDisplayStart"   default="0">
    <cfparam name="url.iDisplayLength"  default="10">
    <cfparam name="url.sEcho"           default="10">
	<cfparam name="url.iSortCol_0"		default="0">
	<cfparam name="url.sSortDir_0"		default="DESC">
	<cfparam name="url.LockMode"		default="0">
	
<cfparam name="FORM.showSearchForm"	default="0" />
<cfparam name="FORM.Upload_Type"	default="0" />
<cfparam name="FORM.Uploaded_User"	default="0" />
<cfparam name="FORM.Uploaded_Date"	default="" />
<cfparam name="FORM.BB_Code"	default="" />
<cfparam name="FORM.BB_Reference"	default="" />
<cfparam name="FORM.Vendor_ID"	default="" />
<cfparam name="FORM.File_Name"	default="" />
<cfparam name="FORM.BB_Upload_Status"	default="0" />
<cfparam name="FORM.lnkClick"	default="0" />
<cfparam name="FORM.payable_list" 	default="">
<cfparam name="FORM.Reference_Number_list" 	default="">
<cfparam name="FORM.match_type" default="">
	
	
  <cfscript>
      tmp   = structnew();
      reply = structnew();
      tmp.page_size   = val(url.iDisplayLength);
      tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
  </cfscript>
<!--- COLUMNS LIST WHICH SHOULD MATCH TO INFO PULLING FROM BELOW QUERY. USING URL VARIABLE ACTIVE TO DETERMINE WHICH SECTION USER LOOKING--->
	<cfscript>
// 		tmp.columnArray = ["Upload_Automation_Log_ID", "User_ID", "File_Name",  "File_Size", "Upload_Date", "Upload_Status", "Created_User", "UA_Step"];    
		tmp.columnArray = ["File_Name", "Created_User", "Upload_Date", "File_Size", "Action", "Upload_Status", "UA_Step","User_ID"];    
	</cfscript> <!--- "Upload_Automation_Log_ID",  --->

<cfset strOrderby= "UAL.Upload_Date" />
<cfquery name="qGetAutoUploadStatus" datasource="#application.datasource#">
	SELECT 	UAL.Upload_Automation_Log_ID,
			UAL.File_Name,
			U.Name_First + ' ' + U.Name_Last AS Created_User,
			UAL.Upload_Date,
			UAL.File_Size,
			
			UAL.Upload_Status,
			UAL.User_ID,
			USL.UA_Step,
			USL.Description,
			USL.Current_Status,
			USL.Upload_3000_Link, 				/* display upload link at the top */
			USL.Generate_HLV_Report,			/* show Generate HLV report 	*/
			USL.Download_HLV_Report_Link,		/* Show Donwload HLV report link */
			USL.Update_HLV_Report_Link,			/* Upload option to upload the HV */
			USL.Process_Claims_To_Create_BB,	/* start processing the uploaded file in the update hlv report link */
			USL.Cleanup_HP,
			USL.Queued_BB_Creation,
			USL.Generate_BB_Report,
			USL.Download_BB_Report,
			USL.Enable_700_Link,
			USL.Generate_DR_AF_Report,
			USL.Download_DR_AF_Report_Link,
			USL.Developer_Assistance,
			USL.Can_Abort,
			USL.Can_user_Intervene
	FROM 
			Upload_Automation_Log UAL
			LEFT JOIN UA_Status_Lookup USL 
				ON USL.UA_Status_Lookup_ID = UAL.Upload_Status 
			INNER JOIN _users U ON U.User_ID = UAL.User_ID
	WHERE 
			UAL.Deleted = 0		
			<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
			AND ( (UAL.File_name like '%#url.sSearch#%') OR (U.Name_First LIKE '%#url.sSearch#%') OR (U.Name_Last LIKE '%#url.sSearch#%')
			OR (UAL.Upload_Automation_Log_ID like '%#url.sSearch#%')
			)	
			</cfif>
			<cfif StructKeyExists(url, "sSearch_8") and len(trim(url.sSearch_8))>
				AND (UAL.Upload_Status IN (#preservesinglequotes(url.sSearch_8)#))
			</cfif>			
			 ORDER BY #strOrderBy# #url.sSortDir_0#	
			OFFSET #url.iDisplayStart# ROWS
       		FETCH NEXT #tmp.page_size# ROWS ONLY	
</cfquery>
<cfset UploadAutomationLogID = qGetAutoUploadStatus.Upload_Automation_Log_ID />
 
<!--- PGT.PG_Type_Name CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->
 
	<cfset tmp.qGetAutoUploadStatus = QueryNew("File_Name, Created_User, File_Size,  Upload_Date, Upload_Status,  UA_Step, User_ID, Action", "varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar") /> <!--- ---> 

	<cfloop query="qGetAutoUploadStatus">
		<cfset QueryAddRow(tmp.qGetAutoUploadStatus) />
	 	<!---  <cfset QuerySetCell(tmp.qGetAutoUploadStatus, "Checkbox", "#qGetAutoUploadStatus.Checkbox#") /> --->
		<!--- <cfset Upload_Automation_Log_ID = qGetAutoUploadStatus.Upload_Automation_Log_ID /> --->
		<cfset File_Name				= URLEncodedFormat(qGetAutoUploadStatus.File_Name) />
		<cfset Created_User 			= qGetAutoUploadStatus.Created_User />
		<cfset File_Size				= qGetAutoUploadStatus.File_Size />
		<cfset Upload_Date 				= Dateformat(qGetAutoUploadStatus.Upload_Date, 'm/d/yyy') />
		<cfset Upload_Status			= qGetAutoUploadStatus.Upload_Status />
		<cfset UA_Step 					= qGetAutoUploadStatus.UA_Step />
		<cfset User_ID 					= qGetAutoUploadStatus.User_ID />
		<cfset Action					= "" />
	
		<!--- ABORT image construction --->
<cfif (URL.LockMode EQ 1)>
<cfoutput>
	<cfsavecontent variable="actionButtons">
	<td>
			<div class="dropdown">
	  <button class="dropbtn"><img src="/images/ocr/report_dd.png" height="22" width="32"/></button>
	  <div class="dropdown-content">
	  <cfif qGetAutoUploadStatus.Generate_HLV_Report EQ 1>
	  	<a href="/billbacks/Upload_Automation/index.cfm?doAction=generateHLV">
		<img src="/images/ocr/generate24.png" height="16" width="16"> Generate HLV</a> 
	  </cfif>
	   <cfif qGetAutoUploadStatus.Download_HLV_Report_Link EQ 1>
	  	<a href="##" onclick="javascript:PopupCenter('UA_DownloadFile.cfm?fileParam=DownloadHLV','Download','450','200');">
		<img src="/images/ocr/download-24-c406be4.png" height="16" width="16"> Download HLV</a> 
	  </cfif>
	  <cfif (qGetAutoUploadStatus.Update_HLV_Report_Link EQ 1)>
	  	<a href="##" onclick="javascript:PopupCenter('UA_UploadFile.cfm?UploadAutomationLogID=#UploadAutomationLogID#','Upload_HLV','600','180');"><img src="/images/ocr/upload-circle-24-c406be4.png" height="16" width="16"> Upload HLV</a>
	  </cfif>
	  <cfif (qGetAutoUploadStatus.Process_Claims_To_Create_BB EQ 1)>
	  	<a href="/billbacks/Upload_Automation/index.cfm?doAction=startProcess"> 
		<img src="/images/ocr/processBlue.png" height="16" width="16"> Process</a>
	  </cfif>
<!--- 	  <cfif qGetAutoUploadStatus.Generate_BB_Report EQ 1>
	  	<a href="#/billbacks/Upload_Automation/index.cfm?doAction=generateBBReport#">Generate BB Report</a>
	  </cfif>  ---> 
	  <cfif qGetAutoUploadStatus.Download_BB_Report EQ 1>
	  	<a href="##" onclick="javascript:PopupCenter('UA_DownloadFile.cfm?fileParam=DownloadBBReport','Download','450','200');"> 
		<img src="/images/ocr/download-24-c406be4.png" height="16" width="16"> Download BB Report</a>
	  </cfif>

	  <cfif qGetAutoUploadStatus.Generate_DR_AF_Report EQ 1>
	  	<a href="/billbacks/Upload_Automation/index.cfm?doAction=generateDRAFReport">
		<img src="/images/ocr/generate24.png" height="16" width="16"> Generate DR_AF</a>
	  </cfif>
  
	  <cfif qGetAutoUploadStatus.Download_DR_AF_Report_Link EQ 1>
	  	<a href="##" onclick="javascript:PopupCenter('UA_DownloadFile.cfm?fileParam=DownloadDRReport','Download','450','200');">
		<img src="/images/ocr/download-24-c406be4.png" height="16" width="16"> Download DR Report</a>
		<a href="##" onclick="javascript:PopupCenter('UA_DownloadFile.cfm?fileParam=DownloadAFReport','Download','450','200');">
		<img src="/images/ocr/download-24-c406be4.png" height="16" width="16"> Download AF Report</a>		
	  </cfif>  
	  <cfif (qGetAutoUploadStatus.Cleanup_HP EQ 1)>
	  	<a href="/billbacks/Upload_Automation/index.cfm?doAction=cleanupHP" title="cleanup holding pen"> 
		<img src="/images/ocr/cleanup24.png" height="16" width="16">  Cleaup HP</a>
	  </cfif>  
	  </div>
	</div>
	</td>
	</cfsavecontent>
</cfoutput>	
<cfelse>
	<cfset actionButtons = "" />
</cfif>

	<cfif (qGetAutoUploadStatus.Can_Abort EQ 0)>
			<cfset incAbortImage = "" /><!--- <td>&nbsp;<img src='/images/OCR/spacer24.png' id='' width='22' height='22'  />&nbsp;</td> --->
	<cfelse>
			<cfset incAbortImage = "<td>&nbsp;<a href='##' onclick=""javascript:fnAbort('#Upload_Automation_Log_ID#');"" title='Abort processing this invoice file'><img src='/images/ocr/trashcan-24-c406be4.png' width='20' height='20' border='0'/></a>&nbsp;</td>" />
	</cfif>
		
		
<cfset  incRunImage= "" />
	 <!--- Based on the status of the upload build the action buttons that are available for that row --->
		<cfset Action = "<table border='0'><tr>#actionButtons# #incAbortImage#</tr></table>" />
		<cfset Maxlen = 40 /> 
		<cfset FileNameMaxed = Left(File_Name,Maxlen) />
		<cfif (len(File_Name) GT Maxlen)>
			<cfset FileNameMaxed &= "..." />
		</cfif>
		<cfset File_NameSplChReplaced = Replace(Replace(Replace(Replace(Replace(File_Name,"%","%25","ALL"),"&","%26","ALL"),"+","%2B","ALL"),",","%2C","ALL"),"##","%23","ALL") />
		<cfset FileNameNew = "<div align=""left"" title=""FileName: #File_Name#"" style='cursor:help;'><A href='#application.HTTPVar##CGI.server_name#/GetDocument.cfm?FilePath=data_files\uploaded\billbacks\uploadAutomation\#File_NameSplChReplaced#' onclick=""NewWindow(this.href,'ocrUpload','800','600','Yes', 'No');return false;"" TITLE=""download file '#File_Name#'"">#FileNameMaxed#</a></div>" />
		<!--- <cfset QuerySetCell(tmp.qGetAutoUploadStatus, "Upload_Automation_Log_ID", "#Upload_Automation_Log_ID#") /> --->
		<cfset QuerySetCell(tmp.qGetAutoUploadStatus, "File_Name", "#FileNameNew#") />
		<cfset QuerySetCell(tmp.qGetAutoUploadStatus, "Created_User", "#Created_User#") />		
		<cfset QuerySetCell(tmp.qGetAutoUploadStatus, "File_Size", "#File_Size#") />
		<cfset QuerySetCell(tmp.qGetAutoUploadStatus, "Upload_Date", "#Dateformat(Upload_Date, 'm/d/yyy')#") />	 		
		<cfset QuerySetCell(tmp.qGetAutoUploadStatus, "Action", "#Action#") />
		<cfset QuerySetCell(tmp.qGetAutoUploadStatus, "Upload_Status", "#Upload_Status#") />
		<cfset QuerySetCell(tmp.qGetAutoUploadStatus, "UA_Step", "#UA_Step#") />		
		<cfset QuerySetCell(tmp.qGetAutoUploadStatus, "User_ID", "#User_ID#") />		
	</cfloop>
    
	<cfset start = url.iDisplaystart + 1> <!--- added + 1 so that the issue with the display 21 rows will no happen starting from 2nd page --->
	<cfset end 	= url.iDisplaystart + 10>
	<cfif start EQ 0>
		<cfset start = 1>
	</cfif>
	
    <!--- Generate JSON from Query --->
	<cfset tmp.dArray = ArrayNew(1) >
	<cfloop query="tmp.qGetAutoUploadStatus">
		<cfset dArrayTmp = arraynew(1)>
		<cfloop array="#tmp.columnArray#" index="tmp.columnName">
			<cfset ArrayAppend(dArrayTmp, (tmp.qGetAutoUploadStatus[tmp.columnName][tmp.qGetAutoUploadStatus.currentRow]))>
		</cfloop>
		<cfset ArrayAppend(tmp.dArray, dArrayTmp) >
	</cfloop>

    <cfset reply.aaData = tmp.dArray>
    <cfset reply.sEcho  = javacast('int', url.sEcho)>
    <cfset tmp.sOut = SerializeJSON( reply )>
    <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
    <cfset tmp.sOut = Replace (tmp.sOut, 'SECHO', 'sEcho')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALRECORDS', 'iTotalRecords')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'AADATA', 'aaData')>
  </cfsilent>

  <!---send JSON data back to client--->
  <cfoutput>#tmp.sOut#</cfoutput>
</cfprocessingdirective>
 