<cfparam name="url.defaultmargin" default="">
<cfparam name="url.defaulttype" default="">
<cfparam name="url.defaultfob" default="">
<cfparam name="url.defaultdel" default="">
<cfparam name="url.defaultfobcash" default="">
<cfparam name="url.defaultdelcash" default="">
<cfparam name="url.defaultmargin_fob" default="">
<cfparam name="url.defaultmargin_del" default="">


<TABLE ALIGN="CENTER">
		<TR>
			<TD>
				<B><FONT COLOR="Red" SIZE="3">
				Please wait while the file is being uploaded....
				</FONT></B>
			</TD>
		</TR>
	</TABLE>	

	<cfflush>

 <cfset uploadmargintargetManager = CreateObject("component","components.settings.upload_margin_targets.uploadmargintargetManager") />

<cfset foundit = False>
<cfloop condition = "(NOT foundit)">

<cfflush>
<cfset qCheckProcessStatus = uploadmargintargetManager.CheckProcessStatus(URL.filetype)>
<CFIF qCheckProcessStatus.Generic_Files_Upload_Process_Status_ID EQ 5 OR qCheckProcessStatus.Generic_Files_Upload_Process_Status_ID EQ 3>
	<cfset status_id = qCheckProcessStatus.Generic_Files_Upload_Process_Status_ID>
	
	<cfset foundit = true>
</CFIF>
</cfloop>

	
	<CFSET ShowLog = 0>
	
	<CFIF qCheckProcessStatus.Generic_Files_Upload_Process_Status_ID EQ 5>
		<CFIf URL.filetype EQ 2>
			<cfset qupdatedefaultitemsettings = uploadmargintargetManager.updatedefaultitemsettings(url.defaultmargin_fob,url.defaultmargin_del,url.defaulttype,url.defaultfob,url.defaultdel,url.defaultfobcash,url.defaultdelcash)>
		<CFELSEif url.filetype EQ 1>
			<cfset qupdatedefaultGDW4settings = uploadmargintargetManager.updatedefaultGDW4settings(url.defaultmargin)>
		</CFIF>
		<cfset qCheckForLog =  uploadmargintargetManager.CheckForLog(qCheckProcessStatus.Generic_Files_Upload_ID)>
		<CFIF qCheckForLog.RecordCount GT 0>
			<CFSET ShowLog = 1>
		</CFIF>
	</CFIF>

<BR><BR><BR><BR>
	<TABLE ALIGN="CENTER">
		<TR>
			<TD>
				<B><FONT COLOR="Red" SIZE="3">
					<CFIF qCheckProcessStatus.Generic_Files_Upload_Process_Status_ID EQ 3>
						Upload failed.
					<CFELSEIF qCheckProcessStatus.Generic_Files_Upload_Process_Status_ID EQ 5 AND qCheckForLog.RecordCount EQ 0>
						Upload Process completed successfully.
					<CFELSEIF qCheckProcessStatus.Generic_Files_Upload_Process_Status_ID EQ 5 AND qCheckForLog.RecordCount GT 0>
						Upload Process completed but with some errors.
					<!--- <CFELSE>
						Please wait while the file is being uploaded.... --->
					</CFIF>
				</FONT></B>
			</TD>
		</TR>
	</TABLE>	

<SCRIPT language="JavaScript">
	function ReFresh()	
	{	
		var statusID = "<CFOUTPUT>#qCheckProcessStatus.Generic_Files_Upload_Process_Status_ID#</CFOUTPUT>";
		var showLog = "<CFOUTPUT>#ShowLog#</CFOUTPUT>";
		
		if (statusID == 5)
		{
			if (showLog == 1)
			{
				<cfif url.filetype EQ 1>
					window.location.href = "index.cfm?Show_Tab=5&TempLog=1&Generic_Files_Upload_ID=<CFOUTPUT>#qCheckProcessStatus.Generic_Files_Upload_ID#</CFOUTPUT>";
				<cfelseif url.filetype EQ 2>
				window.location.href = "index.cfm?Show_Tab=6&TempLog=1&Generic_Files_Upload_ID=<CFOUTPUT>#qCheckProcessStatus.Generic_Files_Upload_ID#</CFOUTPUT>";
				</cfif>
			}
			else
			{
					<cfif url.filetype EQ 1>
					window.location.href = "index.cfm?Show_Tab=1";
					<cfelseif url.filetype EQ 2>
					window.location.href = "index.cfm?Show_Tab=2";
					</cfif>
			}
		}
		else if (statusID == 3)
		{
		<cfif url.filetype EQ 1>
					window.location.href = "index.cfm?Show_Tab=5&Generic_Files_Upload_ID=<CFOUTPUT>#qCheckProcessStatus.Generic_Files_Upload_ID#</CFOUTPUT>";
				<cfelseif url.filetype EQ 2>
				window.location.href = "index.cfm?Show_Tab=6&Generic_Files_Upload_ID=<CFOUTPUT>#qCheckProcessStatus.Generic_Files_Upload_ID#</CFOUTPUT>";
		</cfif>
		}
		//else
	//	{	
			//location.reload();
	//	}
	}
	</SCRIPT>

<SCRIPT>
ReFresh();
</SCRIPT>
<CFFLUSH>	
<!--- <CFIF qAnyErrors.recordcount GT 0 AND form.filetype EQ 1>
		<CFLOCATION URL="index.cfm?Show_Tab=5&ProcessWait=1&filetype=#form.filetype#" ADDTOKEN="No">
<CFELSEIF qAnyErrors.recordcount GT 0 AND form.filetype EQ 2>
		<CFLOCATION URL="index.cfm?Show_Tab=6&ProcessWait=1&filetype=#form.filetype#" ADDTOKEN="No">
<CFELSEIF qAnyErrors.recordcount EQ 0 AND form.filetype EQ 1>
		<CFLOCATION URL="index.cfm?Show_Tab=1&ProcessWait=1" ADDTOKEN="No">
<CFELSEIF qAnyErrors.recordcount EQ 0 AND form.filetype EQ 2>
		<CFLOCATION URL="index.cfm?Show_Tab=3&ProcessWait=1" ADDTOKEN="No">
</CFIF> --->