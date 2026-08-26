<!---  
       Name:          pending_uploads.cfm           
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  11367
       Description:   
--->
 
<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
<cfset getUploads = uploadUtility.getUploadLog() />

<script type='text/javascript'>
	_ajaxConfig = {'_cfscriptLocation':'/components/billback/BillbackUtilityAjax.cfc','_jsscriptFolder':'/script/javascript/Ajax_JS/','debug':false};
</script>

<script type="text/javascript" src="/script/javascript/Ajax_JS/ajax.js"></script>

<script type="text/javascript" language="Javascript">
	function doPurge(upload_id,inputRef)
	{   	
		DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'purge_upload', upload_id, '<cfoutput>#request.accessstructure.user_code#</cfoutput>', doEcho);
		doClearRow(inputRef);
	}
	
	// This function is required for the execute signature but does nothing but redirect.
	function doClearRow(thisObj){
		/* Get Parent TR tag */
		var rowStyle = thisObj.parentElement.parentElement.style;
		/* Set Parent Style to Invisible */
		rowStyle.display = 'none';
		/* Disable Check Box */
		thisObj.disabled = true;
	}
	
	function doEcho(r){
		var test = "true";
		}
</script>
<script type="text/javascript" language="JavaScript">
	function viewdetails(id)
	{
		window.location.href = 'index.cfm?show_tab=6&tab_title=Upload Detail&upload_id=' + id;	
	}	
</script>

<script type="text/javascript" language="javascript">
	function checkAll(chkObj)
	{
		var check = chkObj.checked;

		if(typeof(frmPendingUploads.elements.length) == 'undefined'){
			return false;	
		}
			for (var i=0;i<frmPendingUploads.elements.length;i++)
			{
				var e = frmPendingUploads.elements[i];
				if ((e.name== 'chk') && (e.type=='checkbox')) {
					  e.checked = check;
				}
			}
	}	

	function deleteSelected()
	{
		
		if(typeof(frmPendingUploads.elements.length) == 'undefined'){
			return false;	
		}

		if (confirm("All selected uploads will be deleted permanently. Do you agree?") == true){
			for (var i=0;i<frmPendingUploads.elements.length;i++)
			{
				var e = frmPendingUploads.elements[i];
				if ((e.name == 'chk') && (e.type=='checkbox')) {
					if(e.checked)
					{
					  doPurge(e.value,e);
					}
				}
			}
		}
	}
</script>
<br><span class="subheading">Pending Uploads</span><br><br>

<form id="frmPendingUploads">

<div align="right" style="width:800px;vertical-align:middle;"><span onclick="deleteSelected()"><img src="/images/delete.gif"> - delete selected uploads</span></div>
<div id="markup"> 
<table>
	<thead>
		<tr>
			<th align="center"><span title="check all"><input type="checkbox" name="chk_all" id="chk_all" onclick="checkAll(this)" <cfif getUploads.recordcount EQ 0>DISABLED</cfif> ></span></th>
			<th width="20px">ID</th>
			<th width="70px">Uploaded By</th>
			<th width="90px">Total Header Count</th>
			<th width="90px">Total Header Count Failed</th>
			<th width="110px">Total Header Count Success</th>	
			<th width="90px">Total Detail Count</th>
			<th width="90px">Total Detail Count Failed</th>	
			<th width="110px">Total Detail Count Success</th>
			<th width="70px">Date</th>
			<th width="120px">Status</th>
		</tr>
	</thead>
	<cfif getUploads.recordcount NEQ 0>
		<tbody>	
				<cfoutput query="getUploads">
					<tr>
						<td align="center"><input type="checkbox" name="chk" id="chk" value="#upload_id#" <cfif getUploads.Upload_Status eq 'Validating'>disabled </cfif>></td>
						<td>#upload_id#</td>
						<td>#user_code#</td>
						<td>#total_header_count#</td>
						<td>#total_header_count_failed#</td>
						<td>#total_header_count_loaded#</td>	
						<td>#total_detail_count#</td>
						<td>#total_detail_count_failed#</td>	
						<td>#total_detail_count_loaded#</td>
						<td>#dateformat(upload_date,'MM/DD/YYYY')#<!---  #timeformat(upload_date,'HH:MM')# ---></td>
						<td><a href="##" title="#upload_status#: click to view upload errors" onclick="viewdetails(#upload_id#);">#upload_status#</a></td>
					</tr>
				</cfoutput>
		</tbody>	
	<cfelse>
		<tbody>
			<tr><td colspan="100%">There are no pending uploads</td></tr>
		</tbody>
	</cfif>	

</table>
</div>

</form>


