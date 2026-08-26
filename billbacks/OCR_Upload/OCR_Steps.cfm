<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\billbacks\OCR_Upload\OCR_Steps.cfm
      Date:     30-Mar-2017
      Author:   Anand Rao
      Purpose:  Different steps in the flow of the process is shown

      Notes:

-----------------------------------------------------------------------------------------------------------------------> 

<cfparam name="qGetOCRUploadStatus.OCR_Step" default="1">

<cfif  (qGetOCRUploadStatus.BB_Upload_ID NEQ "")>  
	<cfquery name="getBBCount" datasource="#application.datasource#">
			SELECT  u.upload_id , u.Source_Code,COUNT(b.Billback_ID) AS BB_Count
			FROM  OCR_Upload_Log o 
			LEFT JOIN BB_upload_log u
			ON          o.BB_Upload_ID = u.upload_id 
			LEFT JOIN Billback_Txt_Upload_Header_log th
			ON          th.upload_id = u.upload_id 
			AND         th.deleted = 0 
			INNER JOIN Billback b
			ON          b.Billback_ID = th.Billback_ID 
			AND         b.Deleted =0 
			WHERE      1 = 1
			AND o.OCR_Upload_ID = '#OCR_upload_ID#' 
			--and       u.Upload_ID = 56019
			Group by  u.upload_id,u.Source_Code
	</cfquery>
	<cfif ((getBBCount.RecordCount GTE 1) AND (qGetOCRUploadStatus.Pages_Extracted NEQ 0))>
		<cfset strCreationTitle = "Success - Please click here to see the details.  #qGetOCRUploadStatus.Pages_Extracted# pages were extracted to create #getBBCount.BB_Count# billback(s)." />
	<cfelseif ((getBBCount.RecordCount GTE 1) AND (qGetOCRUploadStatus.Pages_Extracted EQ 0))>
		<cfset strCreationTitle = "#getBBCount.BB_Count# billback(s) were created successfully. Please click here to see the details." />
	<cfelseif ((getBBCount.RecordCount EQ 0) AND (qGetOCRUploadStatus.Pages_Extracted NEQ 0))>
		<cfset strCreationTitle = "#getBBCount.BB_Count# billback(s) were created successfully. Please click here to see the details." />	
	<cfelse>
		<cfset strCreationTitle = "The billback was created successfully out of data extracted from #qGetOCRUploadStatus.Pages_Extracted# pages. Please click here to see the details." />
	</cfif>
<cfelse>
	<cfset strCreationTitle = "The billback was created successfully. Please click here to see the details." />
</cfif>

<cfsavecontent variable="ocr_step_flow">
	<cfif qGetOCRUploadStatus.OCR_Step EQ "1" OR qGetOCRUploadStatus.OCR_Step EQ "2">

			<div class="flow-top">
				<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/working24.png" title="Matching the invoice file with the Source and Type" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="The content of the invoice file will be verified." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="The total amount from the file will be matched with the amount entered." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="Distributor, Operator, Program and Product ID(s) from the invoice file will be matched with the known ID(s)." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="The claim will be validated using the active program(s)." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="Billback(s) will be created." style="cursor:help;">&nbsp;</nobr>
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2 curStep">SOURCE</div>		
				<div class="st3">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7">CREATED</div>
			</div>
		</div>
	<cfelseif (qGetOCRUploadStatus.OCR_Step EQ "2.CF_Error" OR qGetOCRUploadStatus.OCR_Step EQ "2.DB_Error" OR qGetOCRUploadStatus.OCR_Step EQ "2.CF_ParseError")>
		<cfset strTitle = "Please try again.  The invoice file did not match the Source or Type." />
		<cfif qGetOCRUploadStatus.Error_Tool_Tip NEQ "">
			<cfset strTitle = qGetOCRUploadStatus.Error_Tool_Tip />
		</cfif>
		<div>
			<div class="flow-top">
				<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/abort24.png" title="<cfoutput>#strTitle#</cfoutput>" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png">&nbsp;</nobr>
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2 curStepRed">SOURCE</div>		
				<div class="st3">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7">CREATED</div>
			</div>

	<cfelseif (qGetOCRUploadStatus.OCR_Step EQ "3" OR qGetOCRUploadStatus.OCR_Step EQ "4" OR qGetOCRUploadStatus.OCR_Step EQ "4.1" OR (qGetOCRUploadStatus.OCR_Step EQ "5" AND qGetOCRUploadStatus.Reprocess EQ 0))>
			<div class="flow-top">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/working24.png" title = "Verifying the content of the invoice file" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="The total amount from the file will be matched with the amount entered." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="Distributor, Operator, Program and Product ID(s) from the invoice file will be matched with the known ID(s)." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="The claim will be validated using the active program(s)." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="Billback(s) will be created." style="cursor:help;">&nbsp;
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2">SOURCE</div>		
				<div class="st3 curStep">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7">CREATED</div>
			</div>

	<cfelseif (qGetOCRUploadStatus.OCR_Step EQ "5.1" AND qGetOCRUploadStatus.Reprocess EQ 1)>	

			<div class="flow-top">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had valid content." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/working24.png" title="Matching the total amount read from the invoice file with the amount entered" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="Distributor, Operator, Program and Product ID(s) from the invoice file will be matched with the known ID(s)." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="The claim will be validated using the active program(s)." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="Billback(s) will be created." style="cursor:help;">&nbsp;
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2">SOURCE</div>		
				<div class="st3">INVOICE</div>
				<div class="st4 curStep">AMOUNT</div>
				<div class="st5">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7">CREATED</div>
			</div>

	<cfelseif (qGetOCRUploadStatus.OCR_Step EQ "4.DB_Error" OR qGetOCRUploadStatus.OCR_Step EQ "6" OR qGetOCRUploadStatus.OCR_Step EQ "6.DB_Error" OR qGetOCRUploadStatus.OCR_Step EQ "6.Time_Out")>
		<cfset strTitle = "Please download the Excel file and reupload it in Upload Payables.  The invoice file did not have all the required content." />
		<cfif qGetOCRUploadStatus.Error_Tool_Tip NEQ "">
			<cfset strTitle = qGetOCRUploadStatus.Error_Tool_Tip />
		</cfif>
			<div class="flow-top">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/abort24.png" title = "<cfoutput>#strTitle#</cfoutput>" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png">&nbsp;
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2">SOURCE</div>		
				<div class="st3 curStepRed">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7">CREATED</div>
			</div>
	<cfelseif qGetOCRUploadStatus.OCR_Step EQ "7">
		<cfoutput>
				<div class="flow-top">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had valid content." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/abort24.png" title="Please repair to continue.   The total amount read from the invoice file did not match the amount entered."  style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png">&nbsp;
				</div>
				<div class="flow-bottom">
					<div class="st1">UPLOAD</div>
					<div class="st2">SOURCE</div>		
					<div class="st3">INVOICE</div>
					<div class="st4 curStepRed">AMOUNT</div>
					<div class="st5">ALIAS</div>
					<div class="st6">VALID</div>
					<div class="st7">CREATED</div>
				</div>

 		</cfoutput>
	<cfelseif qGetOCRUploadStatus.OCR_Step EQ "8">

			<div class="flow-top">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had valid content." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The total amount read from the invoice file matched the amount entered." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/working24.png" title = "Finding the Distributor, Operator, Program, and Product ID(s)" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="The claim will be validated using the active program(s)." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png" title="Billback(s) will be created." style="cursor:help;">&nbsp;
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2">SOURCE</div>		
				<div class="st3">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5 curStep">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7">CREATED</div>
			</div>

	<cfelseif (qGetOCRUploadStatus.OCR_Step EQ "9" OR qGetOCRUploadStatus.OCR_Step EQ "9.DB_Error")>
		<cfset strTitle = "Please repair to continue. The invoice file has unknown Distributor, Operator, Program, or Product ID(s)." />
		<cfif qGetOCRUploadStatus.Error_Tool_Tip NEQ "">
			<cfset strTitle = qGetOCRUploadStatus.Error_Tool_Tip />
		</cfif>
			<div class="flow-top">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had valid content." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The total amount read from the invoice file matched the amount entered." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/abort24.png" title = "<cfoutput>#strTitle#</cfoutput>" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png">&nbsp;
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2">SOURCE</div>		
				<div class="st3">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5 curStepRed">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7">CREATED</div>
			</div>
<cfelseif (qGetOCRUploadStatus.OCR_Step EQ "9.Time_Out")>
		<cfset strTitle = "Validation Timeout" />
		<cfif qGetOCRUploadStatus.Error_Tool_Tip NEQ "">
			<cfset strTitle = qGetOCRUploadStatus.Error_Tool_Tip />
		</cfif>
			<div class="flow-top">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had valid content." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The total amount read from the invoice file matched the amount entered." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/abort24.png" title = "<cfoutput>#strTitle#</cfoutput>" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png"><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png">&nbsp;
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2">SOURCE</div>		
				<div class="st3">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5 curStepRed">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7">CREATED</div>
			</div>
	<cfelseif qGetOCRUploadStatus.OCR_Step EQ "10">

			<div class="flow-top">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had valid content." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The total amount read from the invoice file matched the amount entered." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had known Distributor, Operator, Program and Product ID(s)." style="cursor:help;"><img src="/images/ocr/line.png"><a href="payablesRedirect.cfm?redirectTo=BBVALIDATIONFAIL&Upload_ID=<cfoutput>#qGetOCRUploadStatus.BB_Upload_ID#</cfoutput>"><img src="/images/ocr/abort24.png" title = "Click here for more details.  The claim validation failed." style="cursor:hand;"></a><img src="/images/ocr/line.png"><img src="/images/ocr/empty.png">&nbsp;
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2">SOURCE</div>		
				<div class="st3">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5">ALIAS</div>
				<div class="st6 curStepRed">VALID</div>
				<div class="st7">CREATED</div>
			</div>

	<cfelseif qGetOCRUploadStatus.OCR_Step EQ "11">

			<div class="flow-top">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had valid content." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The total amount read from the invoice file matched the amount entered." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had known Distributor, Operator, Program and Product ID(s)." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The claim has been validated using the active programs." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/working24.png" title = "The billback(s) is/are queued for creation." style="cursor:help;">&nbsp;
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2">SOURCE</div>		
				<div class="st3">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7 curStep">CREATED</div>
			</div>

	<cfelseif qGetOCRUploadStatus.OCR_Step EQ "12">
			<div class="flow-top">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had valid content." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The total amount read from the invoice file matched the amount entered." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had known Distributor, Operator, Program and Product ID(s)." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The claim has been validated using the active programs." style="cursor:help;"><img src="/images/ocr/line.png"><a href="payablesRedirect.cfm?redirectTo=BBDETAILS&Upload_ID=<cfoutput>#qGetOCRUploadStatus.BB_Upload_ID#</cfoutput>"><img src="/images/ocr/checked24.png" title = "<cfoutput>#strCreationTitle#</cfoutput>" style="cursor:hand;" border="0"></a>&nbsp;
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2">SOURCE</div>		
				<div class="st3">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7">CREATED</div>
			</div>
	<cfelseif qGetOCRUploadStatus.OCR_Step EQ "13">
			<cfset strTitle = "The Billback creation Timed out" />
		<cfif qGetOCRUploadStatus.Error_Tool_Tip NEQ "">
			<cfset strTitle = qGetOCRUploadStatus.Error_Tool_Tip />
		</cfif>
			<div class="flow-top">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/images/ocr/checked24.png" title="Uploaded successfully" style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title="The invoice file matched the Source and Type." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had valid content." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The total amount read from the invoice file matched the amount entered." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The invoice file had known Distributor, Operator, Program and Product ID(s)." style="cursor:help;"><img src="/images/ocr/line.png"><img src="/images/ocr/checked24.png" title = "The claim has been validated using the active programs." style="cursor:help;"><img src="/images/ocr/line.png"><a href="payablesRedirect.cfm?redirectTo=BBVALIDATIONFAIL&Upload_ID=<cfoutput>#qGetOCRUploadStatus.BB_Upload_ID#</cfoutput>"><img src="/images/ocr/abort24.png" title = "<cfoutput>#strTitle#</cfoutput>" style="cursor:hand;" border="0"></a>&nbsp;
			</div>
			<div class="flow-bottom">
				<div class="st1">UPLOAD</div>
				<div class="st2">SOURCE</div>		
				<div class="st3">INVOICE</div>
				<div class="st4">AMOUNT</div>
				<div class="st5">ALIAS</div>
				<div class="st6">VALID</div>
				<div class="st7" curStepRed>CREATED</div>
			</div>			
<cfelse>

Generating flow images...

</cfif>
</cfsavecontent>
 
 