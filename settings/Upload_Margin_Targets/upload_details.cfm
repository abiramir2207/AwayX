<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<br>
<cfsilent>
<cfset getgdw4lastsuccessfuluploaddetails = uploadmargintargetManager.getlastsuccessfuluploaddetails(1)>
<cfset getitemlastsuccessfuluploaddetails = uploadmargintargetManager.getlastsuccessfuluploaddetails(2)>

<cfset getvalidgdw4fromupload = uploadmargintargetManager.getvalidgdw4fromupload()>
<cfset getinvalidgdw4fromupload = uploadmargintargetManager.anyerrors(1,getgdw4lastsuccessfuluploaddetails.Generic_Files_Upload_id,1)>
<cfset gdw4NotFound = uploadmargintargetManager.ItemsNotFound(1,getgdw4lastsuccessfuluploaddetails.Generic_Files_Upload_ID)>
<cfset getgdw4notfromupload = uploadmargintargetManager.getgdw4notfromupload()>


<cfset getvaliditemfromupload = uploadmargintargetManager.getvaliditemfromupload()>
<cfset getinvaliditemfromupload = uploadmargintargetManager.anyerrors(2,getitemlastsuccessfuluploaddetails.Generic_Files_Upload_id,1)>
<cfset ItemsNotFound = uploadmargintargetManager.ItemsNotFound(2,getitemlastsuccessfuluploaddetails.Generic_Files_Upload_ID)>
<cfset getitemnotfromupload = uploadmargintargetManager.getitemnotfromupload()>
</cfsilent>
<cfoutput>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="800">
<tr>
<td width="400" valign="top">
<TABLE>
	<TR>
		<td colspan="2"><B><FONT SIZE="2" COLOR="Navy">#application.returned_customer_setting.type_code_label_singular# Upload Details</FONT></B></TD>
	</TR>
	<tr><td><b>Uploaded By:</b></td>
	<td align="left"><cfif getgdw4lastsuccessfuluploaddetails.recordcount GT 0>
 #getgdw4lastsuccessfuluploaddetails.Name_First#&nbsp;#getgdw4lastsuccessfuluploaddetails.Name_Last# on #Dateformat(getgdw4lastsuccessfuluploaddetails.created_date,"mmmm dd,yyyy")#
</cfif></td></tr>
	<tr>
	<td>
	<b>Valid #application.returned_customer_setting.type_code_label_plural# from the upload:</b>
	</td>
	<td>#getvalidgdw4fromupload.validgdw4count#</td>
	</tr>
	<tr>
	<td>
	<b>InValid #application.returned_customer_setting.type_code_label_plural# from the upload:</b>
	</td>
	<td><cfset gdw4invalidcount = getinvalidgdw4fromupload.recordcount + gdw4NotFound.recordcount>
	#gdw4invalidcount#
	</td>
	</tr>
	<tr>
	<td>
	<b>#application.returned_customer_setting.type_code_label_plural# already in the DB:</b>
	</td>
		<td>#getgdw4notfromupload.recordcount#</td>
	</tr>
	<tr><td>&nbsp;</td></tr>
	<cfif getgdw4notfromupload.recordcount GT 0>
	<tr>
	<td>
	<b>List of #application.returned_customer_setting.type_code_label_plural# already in DB</b></td>
	</tr>
	<cfloop query="getgdw4notfromupload">
	<tr>
	<td colspan="2">
	#getgdw4notfromupload.type_code_desc# (#getgdw4notfromupload.Type_Code_Legacy#)
	</td>
	</tr>
	</cfloop>
	</cfif>
	</table>
</td>
<td width="400" valign="top">
<table><TR>
		<td colspan="2"><B><FONT SIZE="2" COLOR="Navy">Item Upload Details</FONT></B></TD>
	</TR>
	<tr><td><b>Uploaded By:</b></td>
	<td align="left"><cfif getitemlastsuccessfuluploaddetails.recordcount GT 0>
 #getitemlastsuccessfuluploaddetails.Name_First#&nbsp;#getitemlastsuccessfuluploaddetails.Name_Last# on #Dateformat(getitemlastsuccessfuluploaddetails.created_date,"mmmm dd,yyyy")#
</cfif></td></tr>
	<tr>
	<td>
	<b>Valid item count from the upload:</b>
	</td>
	<td>#getvaliditemfromupload.validitemcount#</td>
	</tr>
	<tr>
	<td>
	<b>InValid item count from the upload:</b>
	</td>
	<td><cfset invaliditemcount = ItemsNotFound.recordcount + getinvaliditemfromupload.recordcount>
		#invaliditemcount#</td>
	</tr>
	<tr>
	<td>
	<b>Items already in the DB:</b>
	</td>
		<td>#getitemnotfromupload.recordcount#</td>
	</tr>	<tr><td>&nbsp;</td></tr>
	<cfif getitemnotfromupload.recordcount GT 0>
	<tr>
	<td>
	<b>List of items already in DB</b></td>
	</tr>
	<cfloop query="getitemnotfromupload">
	<tr>
	<td colspan="2">
	#getitemnotfromupload.description# (#getitemnotfromupload.item_number#)
	</td>
	</tr>
	</cfloop>
	</cfif>
	</table>
	</td>
</tr>
</TABLE>
</cfoutput>
</body>
</html>


