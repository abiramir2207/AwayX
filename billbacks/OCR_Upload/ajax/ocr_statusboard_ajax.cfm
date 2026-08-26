<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/ajax/ocr_statusboard_ajax.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Upload from home page
---------------------------------------------------------------------------------->

<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">
  <cfsilent>
    <cfparam name="url.iDisplayStart"   default="0">
    <cfparam name="url.iDisplayLength"  default="10">
    <cfparam name="url.sEcho"           default="10">
	<cfparam name="url.iSortCol_0"		default="0">
	<cfparam name="url.sSortDir_0"		default="DESC">
  <cfscript>
      tmp   = structnew();
      reply = structnew();
      tmp.page_size   = val(url.iDisplayLength);
      tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
  </cfscript>
<!--- COLUMNS LIST WHICH SHOULD MATCH TO INFO PULLING FROM BELOW QUERY. USING URL VARIABLE ACTIVE TO DETERMINE WHICH SECTION USER LOOKING--->
<!--- <cfif url.active>
	   <cfscript>
            tmp.columnArray = ["Checkbox", "PG_Type_Code", "PG_Type_Name", "PG_Group_Type", "Deactivate", "Remove", "Expand"];    
	   </cfscript>
<cfelse>
      <cfscript>
            tmp.columnArray = ["Checkbox", "PG_Type_Code", "PG_Type_Name", "PG_Group_Type", "Activate", "Remove", "Expand"];
	  </cfscript>   
</cfif>
 --->   
	<cfscript>
		tmp.columnArray = ["OCR_Upload_ID", "File_Name", "Source_Code", "OCR_Amount", "Days_Pending", "Created_User", "OCR_Upload_Status", "Action","OCR_Step"];    
	</cfscript> 

<cfset strOrderby= "OUL.OCR_Upload_Date" />
<cfif tmp.columnArray[url.iSortCol_0 + 1] EQ "OCR_Upload_ID">
	<cfset strOrderby = "OUL.OCR_Upload_ID" />
<cfelseif tmp.columnArray[url.iSortCol_0 + 1] EQ "File_Name">
	<cfset strOrderby = "OUL.File_Name" />
<cfelseif tmp.columnArray[url.iSortCol_0 + 1] EQ "Source_Code">
	<cfset strOrderby = "BBC.Source_Code" />
<cfelseif tmp.columnArray[url.iSortCol_0 + 1] EQ "OCR_Amount">
	<cfset strOrderby = "OCR_Amount_New" />
<cfelseif tmp.columnArray[url.iSortCol_0 + 1] EQ "Days_Pending">
	<cfset strOrderby = "Days_Pending" />
<cfelseif tmp.columnArray[url.iSortCol_0 + 1] EQ "Created_User">
	<cfset strOrderby = "Created_User" />
<cfelseif tmp.columnArray[url.iSortCol_0 + 1] EQ "OCR_Upload_Status">
	<cfset strOrderby = "OSL.OCR_Status_Lookup_ID" />
<cfelseif tmp.columnArray[url.iSortCol_0 + 1] EQ "OCR_Step">
	<cfset strOrderby = "OCR_Step" />
	
</cfif>

<cfquery name="qGetOCRUploadStatus" datasource="#application.datasource#">
 	SELECT 	OUL.OCR_Upload_ID,
			OUL.File_Name,
			OUL.Source_Template,
			OUL.Created_User_ID,
			OUL.OCR_Upload_Date,
			OUL.OCR_Upload_Status,
			OUL.OCR_Amount,
			CASE WHEN OUL.Reprocess = 0
			THEN
				ISNULL(OUL.OCR_Amount,0)
			ELSE	
				ISNULL(OUL.OCR_File_Amount,0)
			END
				AS OCR_Amount_New,	
			OUL.OCR_File_Amount,
			OUL.OCR_Step,
			OUL.Deleted,
			OUL.Deleted_By,
			OUL.Deleted_Date,
			OUL.Reprocess,
			OUL.Reprocess_By,
			OUL.Reprocess_Date,
			OUL.upload_type,
			OUL.BB_Upload_ID,
			OUL.OCR_File_Capture_ID,
			OUL.Pages_Extracted,
			OUL.Error_Tool_Tip,
			OTS.OCR_Template_Settings_ID,	
			OTS.OCR_Template_Name, 
			OTS.OCR_File_Landing_Path,
			OTS.OCR_File_Landing_Path_Processed,
			OTS.OCR_File_PreProcess_Path,
			OTS.OCR_File_PostProcess_Path,
			OTS.OCR_File_PostProcess_Txt_Path,
			OTS.DB_File_Preprocess_Path,
			BBC.Source_Code,
			DATEDIFF(DAY,OUL.OCR_Upload_Date,GETDATE()) AS Days_Pending,
			U.Name_First,
			U.Name_Last,
			U.Name_First + ' ' + U.Name_Last AS Created_User,
			OSL.OCR_Status_Lookup_ID
	FROM 
			OCR_Upload_Log OUL
			LEFT JOIN OCR_Status_Lookup OSL 
				ON OUL.OCR_Step = OSL.OCR_Step 
			LEFT JOIN OCR_Template_Settings OTS ON 
					OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
			INNER JOIN 
				BB_Claim_Source_XREF BBC ON BBC.BB_Claim_Source_XREF_ID	 = OUL.BB_Claim_Source_XREF_ID
			INNER JOIN _users U ON U.User_ID = OUL.Created_User_ID
	WHERE 
			OUL.Deleted = 0		
			<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
			AND ( (OUL.File_name like '%#url.sSearch#%') OR (BBC.Source_Code like '%#url.sSearch#%') OR (U.Name_First LIKE '%#url.sSearch#%') OR (U.Name_Last LIKE '%#url.sSearch#%')
			OR (OUL.OCR_Amount like '%#url.sSearch#%') OR (OUL.OCR_File_Amount like '%#url.sSearch#%') OR (OUL.OCR_Upload_ID like '%#url.sSearch#%')
			)	
			</cfif>
			<cfif StructKeyExists(url, "sSearch_8") and len(trim(url.sSearch_8))>
				AND (OUL.OCR_Step IN (#preservesinglequotes(url.sSearch_8)#))
			</cfif>			
			 ORDER BY #strOrderBy# #url.sSortDir_0#	
			OFFSET #url.iDisplayStart# ROWS
       		FETCH NEXT #tmp.page_size# ROWS ONLY	
</cfquery>

  <!---get total number of records BEFORE filtering--->
  <cfquery name="totalBeforeFilter" datasource="#application.datasource#">
      SELECT COUNT(1) AS rownbr
	FROM 
			OCR_Upload_Log OUL
			LEFT JOIN OCR_Status_Lookup OSL 
				ON OUL.OCR_Step = OSL.OCR_Step 
			LEFT JOIN OCR_Template_Settings OTS ON 
					OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
			INNER JOIN 
				BB_Claim_Source_XREF BBC ON BBC.BB_Claim_Source_XREF_ID	 = OUL.BB_Claim_Source_XREF_ID
			INNER JOIN _users U ON U.User_ID = OUL.Created_User_ID
	WHERE 
			OUL.Deleted = 0
  </cfquery>

   <cfset reply.iTotalRecords        = totalBeforeFilter.rownbr>
  <cfset reply.iTotalDisplayRecords = totalBeforeFilter.rownbr>

  <cfif ( StructKeyExists(url, "sSearch")   and len(trim(url.sSearch)) )>
    <cfquery name="totalAfterFilter" datasource="#application.datasource#">
         SELECT COUNT(1) AS rownbr
			FROM 
					OCR_Upload_Log OUL
					LEFT JOIN OCR_Status_Lookup OSL 
						ON OUL.OCR_Step = OSL.OCR_Step 
					LEFT JOIN OCR_Template_Settings OTS ON 
							OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
					INNER JOIN 
						BB_Claim_Source_XREF BBC ON BBC.BB_Claim_Source_XREF_ID	 = OUL.BB_Claim_Source_XREF_ID
					INNER JOIN _users U ON U.User_ID = OUL.Created_User_ID
			WHERE 
					OUL.Deleted = 0		
					<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
					AND ( (OUL.File_name like '%#url.sSearch#%') OR (BBC.Source_Code like '%#url.sSearch#%') OR (U.Name_First LIKE '%#url.sSearch#%') OR (U.Name_Last LIKE '%#url.sSearch#%')
					OR (OUL.OCR_Amount like '%#url.sSearch#%') OR (OUL.OCR_File_Amount like '%#url.sSearch#%') OR (OUL.OCR_Upload_ID like '%#url.sSearch#%')
					)	
					</cfif>
					<cfif StructKeyExists(url, "sSearch_8") and len(trim(url.sSearch_8))>
						AND (OUL.OCR_Step IN (#preservesinglequotes(url.sSearch_8)#))
					</cfif>	
    </cfquery>
    <!---get total no. of records AFTER filtering--->
    <cfset reply.iTotalDisplayRecords = totalAfterFilter.rownbr>
  </cfif> 
<!--- PGT.PG_Type_Name CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->
<!--- <cfif url.active>
   <cfset tmp.qGetOCRUploadStatus = QueryNew("Checkbox, PG_Type_Code, PG_Type_Name, PG_Group_Type, Deactivate, Remove, Expand", "varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
<cfelse>
   <cfset tmp.qGetOCRUploadStatus = QueryNew("Checkbox, PG_Type_Code, PG_Type_Name, PG_Group_Type, Activate, Remove, Expand", "varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
</cfif> --->
	<cfset tmp.qGetOCRUploadStatus = QueryNew("OCR_Upload_ID, File_Name, Source_Code, OCR_Amount, Days_Pending, Created_User, OCR_Upload_Status, Action, OCR_Step", "varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar") />

	<cfloop query="qGetOCRUploadStatus">
		<cfset QueryAddRow(tmp.qGetOCRUploadStatus) />
	 	<!---  <cfset QuerySetCell(tmp.qGetOCRUploadStatus, "Checkbox", "#qGetOCRUploadStatus.Checkbox#") /> --->
		<cfset OCR_upload_ID 	= qGetOCRUploadStatus.OCR_Upload_ID />
		<cfset Created_User 	= qGetOCRUploadStatus.Created_User />
		<cfset File_Name		= URLEncodedFormat(qGetOCRUploadStatus.File_Name) />
		<cfset Source_Code 		= qGetOCRUploadStatus.Source_Code />
		<cfset OCR_Step 		= qGetOCRUploadStatus.OCR_Step />
		<cfset OCR_Amount_new = qGetOCRUploadStatus.OCR_Amount_New />
		<cfset Days_Pending_new = "<div align=""center"" title=""Uploaded date: #dateformat(qGetOCRUploadStatus.OCR_Upload_Date, 'm/d/yyy')# #timeformat(qGetOCRUploadStatus.OCR_Upload_Date, 'h:mm:ss TT')#"" style='cursor:help;height:100%;width:100%;position:relative;'>#qGetOCRUploadStatus.Days_Pending#</div>" />	  
		<cfinclude template="../OCR_Steps.cfm" />
		<cfset OCR_Upload_Status_new = "#ocr_step_flow#" />

		<!--- RUN/CONTINUE image construction --->
		<cfif (qGetOCRUploadStatus.OCR_Step EQ "7")>
			<cfset strOpenWindow = "window.open('OCR_Amount_Decision.cfm?OCRUploadID=#qGetOCRUploadStatus.OCR_Upload_ID#','OCRAmount','location=0,status=1,scrollbars=1,resizable=1,width=400,height=200');return false;"/>
			<cfset incRunImage = "<a href='##' onclick=""javascript:#strOpenWindow#"" title='Repair to continue processing this invoice'><img src='/images/ocr/repair-24-c406be4.png' width='20' height='20' style=""padding-left:4px"" /></a>&nbsp;&nbsp;" />
		<cfelseif (qGetOCRUploadStatus.OCR_Step EQ "9" OR qGetOCRUploadStatus.OCR_Step EQ "9.DB_Error")>
		<!--- CODING FOR THE ALIAS FIXER WINDOW TO POPUP --->
			<cfset strOpenWindow = "window.open('/settings/Upload_Billback_Utility/AliasFixer.cfm?UploadID=#qGetOCRUploadStatus.BB_Upload_ID#&OCRUploadID=#qGetOCRUploadStatus.OCR_Upload_ID#','AliasFixer','location=0,status=1,scrollbars=1,resizable=1,width=1000,height=800');return false;"/>
			<cfset incRunImage = "<a href='##' onclick=""javascript:#strOpenWindow#"" title='Repair to continue processing this invoice'><img src='/images/ocr/repair-24-c406be4.png' width='20' height='20' style=""padding-left:4px"" /></a>&nbsp;&nbsp;" />	
		<cfelse> 
			<cfset incRunImage = "<img src='/images/OCR/spacer24.png' />&nbsp;&nbsp;" /> 
			<!---  <cfset incRunImage = "<img src='/images/OCR/arrowright24.png'  />&nbsp;&nbsp;" /> ---><!--- class='tdExpand' --->
		</cfif>
		
		<!--- DOWNLOAD image construction --->
		<cfswitch expression = "#qGetOCRUploadStatus.OCR_Step#">
			<cfcase value="5,5.1,6,6.DB_Error,7,8,9,9.DB_Error,9.Time_Out,10,11,12,13" delimiters=",">
				<cfset strDownloadOpenWindow = "window.open('OCR_Download.cfm?fileParam=OCRDownload&OCRUploadID=#qGetOCRUploadStatus.OCR_Upload_ID#&OCRFileCaptureID=#qGetOCRUploadStatus.OCR_File_Capture_ID#','OCR_Download','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;" />
				<cfset incDownloadImage = "<a href='##' onclick=""javascript:#strDownloadOpenWindow#"" title='Download Excel file for correcting and reupload in Upload Payables screen'><img src='/images/ocr/download-24-c406be4.png' width='20' height='20' border='0' /></a>&nbsp;&nbsp;" />
			</cfcase>
			<cfdefaultcase>
				<cfset incDownloadImage = "<img src='/images/OCR/spacer24.png' width='20' height='20' />&nbsp;&nbsp;" />
			</cfdefaultcase>
		</cfswitch>
	
		<!--- ABORT image construction --->
		<cfif (qGetOCRUploadStatus.OCR_Step EQ "12")>
			<cfset incAbortImage = "<img src='/images/OCR/spacer24.png' id='' width='22' height='22'  />" />
		<cfelse>
			<cfset incAbortImage = "<a href='##' onclick=""javascript:fnAbort('#OCR_upload_ID#');"" title='Abort processing this invoice file'><img src='/images/ocr/trashcan-24-c406be4.png' width='20' height='20' border='0'/></a>" />
		</cfif>
	 
	 <!--- Based on the status of the upload build the action buttons that are available for that row --->
		<cfset Action = "<nobr>#incRunImage##incDownloadImage##incAbortImage#</nobr>" />
		<!--- 	 <cfset Action = "<nobr><img src='/images/OCR/arrowright24.png' id='' />&nbsp;<img src='/images/download_report_small.png' width='22' height='22' />&nbsp;<a href='##' onclick=""javascript:fnAbort('#OCR_upload_ID#');""><img src='/images/OCR/abort24.png'/></a></nobr>" /> --->
		<!--- 	 &nbsp;<img src='/images/OCR/arrow24.png'/>
			  <cfif Is_System>&nbsp;<img src='/images/OCR/trash24.png'/>
			  	<cfset PG_Code 	= #qGetOCRUploadStatus.PG_Type_Code# & '*' />
			  	<cfset PG_Name 	= #qGetOCRUploadStatus.PG_Type_Name# />
				  	  <cfelse>
			  	<cfset PG_Code 	= '<a href="index.cfm?type=type&subtype=edit&ID=#qGetOCRUploadStatus.PG_Type_ID#">' & #qGetOCRUploadStatus.PG_Type_Code# & '</a>' />
			  	<cfset PG_Name 	= '<a href="index.cfm?type=type&subtype=edit&ID=#qGetOCRUploadStatus.PG_Type_ID#">' & #qGetOCRUploadStatus.PG_Type_Name# & '</a>' />
			  </cfif>
			  <cfif PG_Group_Type EQ "1">
		        <cfset PGTypeCategory = application.returned_customer_setting.Item_Label />
		      <cfelseif PG_Group_Type EQ "2">
		        <cfset PGTypeCategory = application.returned_customer_setting.distributor_label_singular />
		      <cfelseif PG_Group_Type EQ "3">
		        <cfset PGTypeCategory = application.returned_customer_setting.Operator_Label_Singular  />
		      </cfif>
			  <cfif url.active>
			  <cfset DeActivate = '<img src="/images/cancel.png" style="margin-left:20px" onclick="deactivate('& '''#qGetOCRUploadStatus.PG_Type_ID#''' &' , '& '''#PG_Group_Type#'''&' , '& '''#url.active#''' &');">' />
			  <cfelse>
			  <cfset Activate 	= '<img src="/images/activate.png" style="margin-left:20px" onclick="activate('& '''#qGetOCRUploadStatus.PG_Type_ID#''' &' , '& '''#url.active#''' &');">' />
			  </cfif>
			  <cfset Delete 	= '<img src="/images/trash.png" style="margin-left:20px" onclick="removed('& '''#qGetOCRUploadStatus.PG_Type_ID#''' &' , '& '''#url.active#''' &');">' />
			  <cfset Info	 	= '<img src="/images/info.png" style="margin-left:20px" onclick="info('& '''#qGetOCRUploadStatus.PG_Type_ID#''' &' , '& '''#PG_Group_Type#'''&' , '& '''#url.active#''' &');">'/>
		 --->
		<cfset Maxlen = 40 /> 
		<cfset FileNameMaxed = Left(File_Name,Maxlen) />
		<cfif (len(File_Name) GT Maxlen)>
			<cfset FileNameMaxed &= "..." />
		</cfif>
		<cfset File_NameSplChReplaced = Replace(Replace(Replace(Replace(Replace(File_Name,"%","%25","ALL"),"&","%26","ALL"),"+","%2B","ALL"),",","%2C","ALL"),"##","%23","ALL") />
		<cfset FileNameNew = "<div align=""left"" title=""FileName: #File_Name#"" style='cursor:help;'><A href='#application.HTTPVar##CGI.server_name#/GetDocument.cfm?FilePath=data_files\uploaded\documents\uploaded_doc\#File_NameSplChReplaced#' onclick=""NewWindow(this.href,'ocrUpload','800','600','Yes', 'No');return false;"" TITLE=""download file '#File_Name#'"">#FileNameMaxed#</a></div>" />
		<cfset QuerySetCell(tmp.qGetOCRUploadStatus, "OCR_upload_ID", "#OCR_upload_ID#") />
		<cfset QuerySetCell(tmp.qGetOCRUploadStatus, "Created_User", "#Created_User#") />
		<cfset QuerySetCell(tmp.qGetOCRUploadStatus, "File_Name", "#FileNameNew#") />
		<cfset QuerySetCell(tmp.qGetOCRUploadStatus, "Source_Code", "#Source_Code#") />
		<cfset QuerySetCell(tmp.qGetOCRUploadStatus, "OCR_Amount", "#Dollarformat(OCR_Amount_new)#") />	 
		<cfset QuerySetCell(tmp.qGetOCRUploadStatus, "Days_Pending", "#Days_Pending_new#") />	  
		<cfset QuerySetCell(tmp.qGetOCRUploadStatus, "OCR_Upload_Status", "#OCR_Upload_Status_new#") />
		<cfset QuerySetCell(tmp.qGetOCRUploadStatus, "Action", "#Action#") />
		<cfset QuerySetCell(tmp.qGetOCRUploadStatus, "OCR_Step", "#OCR_Step#") />
	</cfloop>
    
	<cfset start = url.iDisplaystart + 1> <!--- added + 1 so that the issue with the display 21 rows will no happen starting from 2nd page --->
	<cfset end 	= url.iDisplaystart + 10>
	<cfif start EQ 0>
		<cfset start = 1>
	</cfif>
	
    <!--- Generate JSON from Query --->
	<cfset tmp.dArray = ArrayNew(1) >
	<cfloop query="tmp.qGetOCRUploadStatus">
		<cfset dArrayTmp = arraynew(1)>
		<cfloop array="#tmp.columnArray#" index="tmp.columnName">
			<cfset ArrayAppend(dArrayTmp, (tmp.qGetOCRUploadStatus[tmp.columnName][tmp.qGetOCRUploadStatus.currentRow]))>
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
 