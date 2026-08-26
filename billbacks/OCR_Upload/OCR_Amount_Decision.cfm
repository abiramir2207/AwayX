<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/OCR_File_Mover.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  27-Mar-17
Created By   :  Anand Rao
Description  :  This is a popup which gives the user the option to accept the changed 
				amount/abort the OCR Upload
----------------------------------------------------------------------------------> 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Confirm Invoice Amount</title>
	<script language="javascript">
		// window.onbeforeunload = confirmExit;
		function confirmExit()
		{
 
	    	window.opener.location.href= "index.cfm";
	    	return false;
		}
		
		function fnConfirmSubmit(strDecision)
		{
			if (strDecision == '1')
			{
				document.frmConfirm.strAction.value="1";
				document.frmConfirm.strActionDesc.value="Agree to the New amount";
				document.frmConfirm.submit();
			}
			else if (strDecision == '2') 
			{
				document.frmConfirm.strAction.value="2";
				document.frmConfirm.strActionDesc.value="Abort the Upload";
				confirmation =confirm("Are you sure you want to remove this Upload? This will also remove the row from the Status Table? (OK = Yes   Cancel = No)");
				if (confirmation)
				{
					document.frmConfirm.submit();
				}
			}
			else if (strDecision == '3') 
			{
				window.opener.getElementById('selSource').remove();
				window.opener.getElementById('single_file').remove();
				window.opener.getElementById('Amount').remove();
// 				window.opener.location.reload();
				window.opener.location.href= "index.cfm";
				window.close();
				
			}
			else if (strDecision == '4') 
			{
				window.close();
			}
		}
	</script>
</head>
<cfparam name="URL.OCRUploadID" default="0"/>
<cfparam name="FORM.strAction" default="0"/>

<cfif isdefined("FORM.strAction") AND FORM.strAction EQ "1">
	<cfstoredproc datasource="#application.datasource#" procedure="OCR_Update_Amount">
		<cfprocparam type="IN"  dbVarName="@OCR_Upload_ID" value="#URL.OCRUploadID#" cfsqltype="CF_SQL_INTEGER">
		<cfprocparam type="IN"  dbVarName="@User_ID" value="#Request.Accessstructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfstoredproc>
	<p align="center"><br>
		<span style="FONT-SIZE: 9pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
			The Amount selection has been updated. The invoice file will now proceed with processing.
		</span>
	</p><br>
	<br>
	<cfoutput><br>
		<p align="center"><a href="##" onclick="fnConfirmSubmit('4');">#application.util.string.actionLinkFormat("close window")#</a></p>
	</cfoutput>		
	<cfabort>
<cfelseif isdefined("FORM.strAction") AND FORM.strAction EQ "2">
	<cfquery name="qUpdOCRUploadLog" datasource="#application.datasource#">
		UPDATE 
			OCR_Upload_Log
		SET 
			OCR_Step = '404',
			Deleted = 1,
			Deleted_By = '#Request.AccessStructure.User_ID#',
			Deleted_Date = getDate(),
			OCR_Upload_Status = 'Deleted by user'
		WHERE OCR_Upload_ID = '#URL.OCRUploadID#' AND Deleted = 0
	</cfquery>
	<cfoutput>
		<br>
		<p align="center">
			<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
				<p align="center" style="color:red"><strong>Upload ID: <cfoutput>#URL.OCRUploadID# </cfoutput>has been deleted.</strong></p><br>
				<p align="center"><a href="##" onclick="fnConfirmSubmit('4');">#application.util.string.actionLinkFormat("close window")#</a></p>
			</span>
		</p>
	</cfoutput>
	<cfabort>
</cfif>

<cfif URL.OCRUploadID NEQ "0">
	<cfquery name="getOCRUploadLogRecord" datasource="#application.datasource#">
		SELECT  *
		FROM OCR_Upload_log
		WHERE 	OCR_Upload_ID = '#URL.OCRUploadID#'	AND 
				Deleted = 0
	</cfquery>
<cfelse>
		<p align="center">
			<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
				Download Failed!! 
			</span>
		</p>
	<cfabort>
</cfif> 

<body onBeforeUnload="confirmExit();">
	<cfset URL.PageTitle="Invoice Amount Mismatch">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	 
	<cfinclude template="/settings/settings_title.cfm"> 
	<cfif getOCRUploadLogRecord.RecordCount NEQ 0>
		<form name="frmConfirm" action="" method="post">
			<br>
			<cfoutput>
			<font size="2px" >
				Please continue to accept the extracted amount or abort the process.  The amount extracted from the invoice <b>$#getOCRUploadLogRecord.OCR_File_Amount#</b> is <b><cfif getOCRUploadLogRecord.OCR_File_Amount GT getOCRUploadLogRecord.OCR_Amount>more<cfelse>less</cfif></b>
				than expected <b>$#getOCRUploadLogRecord.OCR_Amount#</b>.<br>
			</font>			
				<br><br>
				<br>
				
				<div align="center">
					<nobr><a href="##" onclick="fnConfirmSubmit('1');">#application.util.string.actionLinkFormat("Accept the Amount")#</a>&nbsp;&nbsp;&nbsp;<a href="##" onclick="fnConfirmSubmit('2');">#application.util.string.actionLinkFormat("Abort processing this Invoice")#</a>&nbsp;&nbsp;&nbsp;<a href="##" onclick="fnConfirmSubmit('4');">#application.util.string.actionLinkFormat("close window")#</a></nobr>
				</div>
			</cfoutput>
			<input type="hidden" name="strAction" value="" />
			<input type="hidden" name="strActionDesc" value="" />
			<cfelse>
					<p align="center">
					<span style="font-size: 12pt; font-family: 'Century Gothic'; font-weight:bold">
						Error!! 
					</span>
				</p>
		</form>
	</cfif>		
</body>
</html>
