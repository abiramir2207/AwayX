<!-----------------------------------------------------------------------------

FILE NAME:		EDIDownload.cfm
DESCRIPTION:	Based on the Type, this page downloads the EDI file.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	02-Apr-2015	

------------------------------------------------------------------------------> 



<cfparam name="URL.Billback_ID" default="">
<cfparam name="URL.Type" default="">

<cfset BillbackID = URL.Billback_ID />
<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />

<cfquery name = "BBInfo" datasource = "#Application.datasource#">
	SELECT BB_Title,BB_Code,BB_Reference FROM Billback WHERE Billback_ID = '#BillbackID#'
</cfquery>
			
<cfif URL.Type EQ 2 AND isDefined("FORM.rdoDownloadData")>
	<cfdump var="#form#" />
</cfif>
<html>
<head>
<cfoutput>
<script language="JavaScript">
	function fnSubmitForm(thisForm, sCommand)
	{
		if (sCommand == '1')
		{
	    	if ((eval("thisForm.rdoDownloadData[0].checked") == false) && (eval("thisForm.rdoDownloadData[1].checked") == false) && (eval("thisForm.rdoDownloadData[2].checked") == false))
			{
				alert('Please pick the data you want to download!!!');
				return false;
			}
			else
			{
				document.getElementById('mainContent').style.display = 'none'
				document.getElementById('downloadLoader').style.display = 'block'
				
				/*	window.open('', 'formpopup', 'width=400,height=400,resizeable,scrollbars');
				    thisForm.target = 'formpopup';
					thisForm.submit();		*/
				  thisForm.submit();
			}
		} // sCommand == '1'
		else if (sCommand == '2')
		{
			thisForm.FileTypeToGet.value="Header";
			document.getElementById('mainContent').style.display = 'none'
			document.getElementById('downloadLoader').style.display = 'block'
			thisForm.submit();
		}
		else if (sCommand == '3')
		{
			thisForm.FileTypeToGet.value="Detail";
			document.getElementById('mainContent').style.display = 'none'
			document.getElementById('downloadLoader').style.display = 'block'
			thisForm.submit();
		}
	}
	
function redirect() 
{
	 window.location.href="EDIDownload.cfm?Billback_ID=#URL.Billback_ID#&Type=#URL.Type#";
}	
</script>
</cfoutput>
</head> 
<CFSET PAGETITLE = "EDI Download - #BBInfo.BB_Title#(#BBInfo.BB_Code#)">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<cfoutput>
<body>

<form name="frmEDIDownload" action="EDIDownloadAction.cfm?Billback_ID=#URL.Billback_ID#&Type=#URL.Type#"  method="post" ><!--- onsubmit="target_popup(this)" --->


<input type="hidden" name="BillbackID" value="#URL.Billback_ID#" />
<input type="hidden" name="Type" value="#URL.Type#" />
<!--- <input type="hidden" name="rdoDownloadData" value="0" /> --->
<input type="hidden" name="FileTypeToGet" value="" />
<input type="hidden" name="HdrFileNameToGet" value="" />
<input type="hidden" name="DtlFileNameToGet" value="" />
<input type="hidden" name="BB_Reference" value="#BBInfo.BB_Reference#" />
 
<div id="mainContent">
<cfif (URL.Billback_ID EQ "" OR URL.Type EQ "")><br>
	<div align="center"><h2><font color="##FF0000">Wrong Parameter passed!!</font></h2>
		<br><br>
		<input type="button" title="Close Window" value="Close Window" onclick="javascript:window.close();"/>
	</div>
	<cfabort>
</cfif> 

<cfif URL.Type EQ 2>
	<!--- --->

	<cfset uploadFilePath = uploadUtility.getUploadPath() />
	<cfset BBUploadDetails = uploadUtility.getUploadDetailsOnBillbackID(billbackID = BillbackID) />
	<strong>Click on the File Name to download:</strong><br><br>
	
	<input type="hidden" name="HdrFileNameToGet" value="#BBUploadDetails.Header_File_Name#" />	
	<input type="hidden" name="DtlFileNameToGet" value="#BBUploadDetails.Detail_File_Name#" />
	
	<table border="2" bordercolor="##339900" cellpadding="5" cellspacing="1" <cfif BBUploadDetails.Header_File_Name NEQ BBUploadDetails.Detail_File_Name>width="650"<cfelse>width="500"</cfif>>
		<tr>
			<td width="100">	
				<strong>Billback Number</strong>
			</td>
			<td>
				<strong>Header File</strong>
			</td>	
			<cfif BBUploadDetails.Header_File_Name NEQ BBUploadDetails.Detail_File_Name>
				<td>
					<strong>Detail File</strong>
				</td>	
			</cfif>
			<td width="90">
				<strong>Uploaded Date</strong>
			</td>
		</tr>
		<tr>
			<td>
				#BBInfo.BB_Code#
			</td>
			<td>	
				<a href="##" onclick="javascript:fnSubmitForm(frmEDIDownload,'2');">#BBUploadDetails.Header_File_Name#</a>

			</td>
			<cfif BBUploadDetails.Header_File_Name NEQ BBUploadDetails.Detail_File_Name>
				<td>
					<a href="##" onclick="javascript:fnSubmitForm(frmEDIDownload,'3');">#BBUploadDetails.Detail_File_Name#</a>
				</td>
			</cfif>
			<td>
				#dateformat(BBUploadDetails.upload_date,'mm/dd/yyyy')# <br>#timeformat(BBUploadDetails.upload_date, 'h:mm:ss TT')#
			</td>
		</tr>
	</table>	
	<br>
	<div align="center">
		<input type="button" value="Close Window" name="Close Window" onclick="javascript:window.close();">
	</div>	
<cfelseif URL.Type EQ 3>

<br>
 
<strong>Pick the data you want to download:</strong><br>

	<input type="radio" name="rdoDownloadData" value="1">Download the Entire Uploaded File <br>
	<input type="radio" name="rdoDownloadData" value="2">Download the details for this BB only<br>
	<input type="radio" name="rdoDownloadData" value="3">Download the compliance report<br>	
	
	<br>
	<div align="left"><input type="button" value="Download" name="Download" onclick="javascript:fnSubmitForm(frmEDIDownload,'1');">
	<input type="button" value="Close Window" name="Close Window" onclick="javascript:window.close();"></div>
</cfif>

</form>
</div> <!--- END div mainContent--->

<div id="downloadLoader" style="display:none">
Downloading... Please wait... <br><br>

<strong>Note:</strong>The download option window will popup shortly, the download time will vary, <br>
based on the size of the file getting downloaded.<br><br>
The File download progress can be seen on the status bar at the bottom of this window.<br>
<br>

<input type="button" value="Close Window" name="Close Window" onclick="javascript:window.close();"> <input type="button" value="Back" name="Back" onclick="redirect();"> 
</div>

</body>
</html>
</cfoutput>

























 