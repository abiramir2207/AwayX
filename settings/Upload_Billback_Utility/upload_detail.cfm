<!---
Script: 	upload_detail.cfm
Date:		2/15/2007
Author:		Clarence Morse
Label:		11367
--->
<cfparam name="url.upload_id" default="-2">
<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
<cfset getUploads = uploadUtility.getUploadLog(url.upload_id) />
<cfset getUploadHeader = uploadUtility.getUploadHeaderLog(url.upload_id)/>
<cfset lblStyle = "font-weight:bold" />
<br><span class="subheading">Upload Detail</span><br><br>

<script type="text/javascript" language="javascript">
function highlight(thisObj,state)
{
		if(state == 1)
		{
			thisObj.style.backgroundColor = "#FFFFCC";	
		}
		else
		{
			thisObj.style.backgroundColor = "transparent";	
		}	
}
</script>


<table border="1" style='border-collapse:collapse;' width="800px">
<cfoutput query="getUploads">
			<tr><th colspan="100%" style="background-color:RGB(255,204,120);padding-left:5px;">Report Header: #url.upload_id#</th></tr>
			<tr>
				<td width="170px" style="padding-left:6px;"><span style="#lblStyle#">ID:</span> #upload_id#</td>
				<td width="240px"><span style="#lblStyle#">Uploaded By:</span> #user_code# on #dateformat(upload_date,'MM/DD/YYYY')# #timeformat(upload_date,'HH:MM')#</td>
				<td width="240px"><span style="#lblStyle#">Status:</span> #upload_status#</td>
			</tr>
			<tr>
				<td style="padding-left:6px;"><span style="#lblStyle#">Total Header Count:</span> #total_header_count#</td>
				<td><span style="#lblStyle#">Total Header Count Failed:</span> #total_header_count_failed#</td>
				<td><span style="#lblStyle#">Total Header Count Success:</span> #total_header_count_loaded#</td>
			</tr>
			<tr>
				<td style="padding-left:6px;"><span style="#lblStyle#">Total Detail Count:</span> #total_detail_count#</td>
				<td><span style="#lblStyle#">Total Detail Count Failed:</span> #total_detail_count_failed#</td>	
				<td><span style="#lblStyle#">Total Detail Count Success:</span> #total_detail_count_loaded#</td>
			</tr>
</cfoutput>
</table>

<table border="1" style='border-collapse:collapse;' width="800px">
<tr><th colspan="100%"  style="background-color:RGB(255,204,120);padding-left:5px;">Upload File Report:</th></tr>
	<cfif getUploadHeader.RecordCount EQ 0>
		<tr style="background-color:RGB(204,255,204);"><td colspan="100%" style="padding-left:5px;">Header Validation Report</td></tr>
		<tr><td style="padding-left:5px;">The header interface file did not contain any records.</td></tr>
	<cfelse>
		<cfoutput>
		<cfloop query="getUploadHeader">
			<tr style="background-color:RGB(204,255,204);"><td colspan="100%" style="padding-left:5px;">Header Validation Report</td></tr>
			<tr>
			<td style="#lblStyle#;min-width:25px;width:25px;text-align:center;">#bb_header_id#</td>
			<td style="max-width:775px;width=775px;padding-left:5px;"><cfif len(getUploadHeader.err_msg) LT 15>The header file did not contain any errors.<cfelse><cfloop list="#getUploadHeader.err_msg#" index="message">#message#</br></cfloop></cfif></td></tr>
			<cfset getUploadDetail = uploadUtility.getUploadDetailLog(url.upload_id, getUploadHeader.bb_header_id)/>
				<cfif getUploadDetail.RecordCount EQ 0>
					<tr ><td></td><td style="background-color:RGB(200,230,255);">Detail Validation Report</td></tr>
					<tr><td></td></td><td>The detail interface file did not contain any records.</td></tr>
				<cfelse>
					<cfloop query="getUploadDetail">
						<tr ><td></td><td style="background-color:RGB(200,230,255);">Detail Validation Report Row: #getUploadDetail.bb_detail_id#</td></tr>
						<tr>
						<td></td>
						<td style="max-width:775px;width=775px;"><cfif len(getUploadDetail.err_msg) LT 10>The detail file did not contain any errors.<cfelse><cfloop list="#getUploadDetail.err_msg#" index="message">#message#</br></cfloop></cfif></td></tr>
					</cfloop>
				</cfif>
		</cfloop>
		</cfoutput>
	</cfif>
</table>