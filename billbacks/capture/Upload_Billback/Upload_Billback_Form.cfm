

<CFIF IsDefined("URL.KillProcess")>
	<cfset useLakebaseForUpdateStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_master")>
<cfif useLakebaseForUpdateStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_upload_master",
			{
				"process_status_id" = "eq.2",
				"deleted" = "eq.0"
			},
			{
				"process_status_id" = "3"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateStatus>
<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
		UPDATE Billback_Upload_Master
		SET Process_Status_ID = 3
		WHERE Process_Status_ID = 2 AND Deleted = 0
	</CFQUERY>
</cfif>
	
	<cfset useLakebaseForUpdateAlive = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_master")>
<cfif useLakebaseForUpdateAlive>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_upload_master",
			{
				"alive_upload" = "eq.1",
				"deleted" = "eq.0"
			},
			{
				"alive_upload" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateAlive = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateAlive>
<CFQUERY NAME="UpdateAlive" DATASOURCE="#Application.Datasource#">
		UPDATE Billback_Upload_Master
		SET Alive_Upload = 0
		WHERE Alive_Upload = 1 AND Deleted = 0
	</CFQUERY>
</cfif>
	
	<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
		UPDATE Billback_Upload_Details
		SET D_Process_Status_ID = 3
		WHERE D_Process_Status_ID = 2 AND Deleted = 0
	</CFQUERY>
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">The Outstanding upload Process has been killed.</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function RelocateThis()
	{		
		window.location.href = "index.cfm?Show_Tab=1";
	}
	window.setTimeout('RelocateThis()', 2000);	
	</SCRIPT>
	<CFABORT>
</CFIF> 

<!--- Dev Note: 10747 Milan --->
<CFIF IsDefined("URL.EmptyWebServerInfo")>
<BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD><FONT COLOR="Red" SIZE="3"><B>The web server information is needed for the upload process.</B></FONT></TD>
				</TR>
			</TABLE>
</CFIF>

<CFIF IsDefined("URL.ProcessWait")>

	<CFQUERY NAME="CheckProcessStatus" DATASOURCE="#Application.Datasource#">
		SELECT 	Process_Status_ID,
				Alive_Upload,
				Billback_Upload_Master_ID
				 
		FROM 	Billback_Upload_Master
		
		WHERE 	Billback_Upload_Master_ID = ( SELECT MAX(Billback_Upload_Master_ID) FROM Billback_Upload_Master ) AND 
				Deleted = 0 
	</CFQUERY>
	
	<CFQUERY NAME="CheckProcessStatus2" DATASOURCE="#Application.Datasource#">
		SELECT 	D_Process_Status_ID
				 
		FROM 	Billback_Upload_Details
		
		WHERE 	Billback_Detail_Upload_ID = ( SELECT MAX(Billback_Detail_Upload_ID) FROM Billback_Upload_Details ) AND 
				Deleted = 0 
	</CFQUERY>
	
	<CFSET ShowLog = 0>

	<cfset useLakebaseForCheckForLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_log")>
<cfif useLakebaseForCheckForLog>
	<cftry>
		<cfset CheckForLog = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_upload_log", {
				"script_log" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckForLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckForLog>
<CFQUERY NAME="CheckForLog" DATASOURCE="#Application.Datasource#">
		SELECT 	Top 1 * 
		FROM 	Billback_Upload_Log 
		
		WHERE 	Script_Log = 0 
	</CFQUERY>
</cfif>

	<CFIF CheckForLog.RecordCount GT 0>	
		<CFSET ShowLog = 1>
	</CFIF>

	<BR><BR><BR><BR>
	<TABLE ALIGN="CENTER">
		<TR>
			<TD>
				<B><FONT COLOR="Red" SIZE="3">
					<CFIF CheckProcessStatus.Process_Status_ID EQ 3>						
						Upload failed.
					<CFELSEIF CheckProcessStatus.Process_Status_ID EQ 5 AND CheckProcessStatus.Alive_Upload EQ 0>
						Upload Process completed successfully. 
					<CFELSE>
						Please wait while the file is being uploaded....
					</CFIF>
				</FONT></B>
			</TD>
		</TR>
	</TABLE>	
	
	<SCRIPT language="JavaScript">
	function ReFresh()	
	{	
		var statusID = "<CFOUTPUT>#CheckProcessStatus.Process_Status_ID#</CFOUTPUT>";
		var statusID2 = "<CFOUTPUT>#CheckProcessStatus2.D_Process_Status_ID#</CFOUTPUT>";
		var showLog = "<CFOUTPUT>#ShowLog#</CFOUTPUT>";
		var AlivePro = "<CFOUTPUT>#CheckProcessStatus.Alive_Upload#</CFOUTPUT>";
		
		if (AlivePro == 0)
		{
			if (statusID == 3 || statusID2 == 3)
			{
				if (confirm("Upload failed because of the invalid file format"))
				{
					window.location.href = "index.cfm?Show_Tab=2";
				}
				else
				{
					window.location.href = "index.cfm?Show_Tab=1";
				}
			}
			else if (statusID == 5)
			{
				if (showLog == 1)
				{
					if (confirm("Press OK to see the log of this upload (There is(are) a(some) unseccessful record(s)."))
					{
						window.location.href = "index.cfm?Show_Tab=2";
					}
					else
					{
						window.location.href = "index.cfm?Show_Tab=1";
					}
				}
				else
				{
					window.location.href = "index.cfm?Show_Tab=1";
				}
			}			
		}
		else
		{	
			location.reload();
		}
	}
	window.setTimeout('ReFresh();', 2000);	
	</SCRIPT>
<CFELSE>
	<CFPARAM NAME="URL.RID" DEFAULT="">
	<CFPARAM NAME="FORM.Header_WS_Name" DEFAULT="Sheet1">
	<CFPARAM NAME="FORM.Detail_WS_Name" DEFAULT="Sheet1">
	<CFQUERY NAME="GetAllBB_Upload" DATASOURCE="#Application.Datasource#">
		SELECT 		Billback_Upload_Master.*,
					Name_First,
					Name_last 
		FROM 		Billback_Upload_Master
		INNER JOIN	_Users ON _Users.User_ID = Billback_Upload_Master.Uploaded_By
		ORDER BY Created_Date DESC
	</CFQUERY>
	
	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">
		
				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">
		
				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
					<TR>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>ID</B>&nbsp;&nbsp;</SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Uploaded By</B>&nbsp;&nbsp;</SPAN></TD>					
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN>&nbsp;&nbsp;</TD>
					</TR>
					<CFOUTPUT QUERY="GetAllBB_Upload">
					<TR>				
						<TD NOWRAP><A HREF="index.cfm?Show_Tab=1&RID=#Billback_Upload_Master_ID#">#Billback_Upload_Master_ID#</A></TD>
						<TD NOWRAP><A HREF="index.cfm?Show_Tab=1&RID=#Billback_Upload_Master_ID#">#Name_First# #Name_last# (#DateFormat(Created_Date,"mm/dd/yyyy")#)</A></TD>					
						<TD NOWRAP ALIGN="Center">
								<CFIF Process_Status_ID EQ 5>
								<IMG SRC="/images/yes_small.gif" TITLE="active record...">
								<CFELSE>
								<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
								</CFIF>
						</TD>					
					</TR>
					</CFOUTPUT>
				</TABLE>
		
				<BR>
		
				<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - Uploaded<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - Not Uploaded<BR>			
				
			</TD>
			<TD VALIGN="top">
		
		
				<SPAN CLASS="title2">Upload Billbacks</SPAN>
				<HR COLOR="Blue" SIZE="1">
		
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- Retrieve the data for the ID of the item passed --->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
				<CFPARAM NAME="Get_Item.Title" DEFAULT="">			
				<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
					SELECT		*
					FROM		Billback_Upload_Master				
					WHERE		Billback_Upload_Master_ID	like	'#URL.RID#'
				</CFQUERY>
				<CFPARAM NAME="Get_Item2.D_Title" DEFAULT="">
				<CFQUERY NAME="Get_Item2" DATASOURCE="#Application.Datasource#">
					SELECT		*				
					FROM		Billback_Upload_Details								
					WHERE		Billback_Upload_Master_ID	like	'#URL.RID#'
				</CFQUERY>
				
				<FORM ACTION="Upload_billback_Action.cfm" METHOD="post" NAME="MyForm" ENCTYPE="multipart/form-data">		
				<CFOUTPUT><INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#"></CFOUTPUT>
				<TABLE CELLSPACING="5" CELLPADDING="0">
					
					<CFIF URL.RID EQ "">
					<TR>
						<TD VALIGN="top" NOWRAP><SPAN ID="ERR_FILE"></SPAN>&nbsp;<B>Select Billback Header File:</B></TD>
						<CFOUTPUT>
						<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="Header_File_Path"></TD>						
						</CFOUTPUT>
					</TR>	
					<TR>
						<TD VALIGN="top" NOWRAP>&nbsp;<B>Header WorkSheet Name:</B></TD>
						<TD><CFOUTPUT><INPUT TYPE="Text" NAME="Header_WS_Name" VALUE="#FORM.Header_WS_Name#"></CFOUTPUT></TD>
					</TR>
					<TR>
						<TD VALIGN="top" NOWRAP><SPAN ID="ERR_FILE"></SPAN>&nbsp;<B>Select Billback Detail File:</B></TD>
						<CFOUTPUT>
						<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="Detail_File_Path"></TD>						
						</CFOUTPUT>
					</TR>
					<TR>
						<TD VALIGN="top" NOWRAP>&nbsp;<B>Detail WorkSheet Name:</B></TD>
						<TD><CFOUTPUT><INPUT TYPE="Text" NAME="Detail_WS_Name" VALUE="#FORM.Detail_WS_Name#"></CFOUTPUT></TD>
					</TR>					
					<CFELSE>	
					<TR>
						<TD VALIGN="top" NOWRAP>&nbsp;<B>ID:</B></TD>
						<TD VALIGN="top"><B><CFOUTPUT><FONT SIZE="2" COLOR="Red">#Get_Item.Billback_Upload_Master_ID#</FONT></CFOUTPUT></B></TD>
					</TR>			
					<TR>
						<TD VALIGN="top" NOWRAP>&nbsp;<B>Header File:</B></TD>
						<CFOUTPUT>
						<TD VALIGN="top"><INPUT SIZE="45" NAME="Title" VALUE="#Get_Item.Title#" MAXLENGTH="50" READONLY DISABLED> 	&nbsp;&nbsp;				
						<CFIF Get_Item.Title NEQ "">
							<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
							<A href="#application.HTTPVar##CGI.server_name#/GetDocument.cfm?FilePath=Data_Files\Uploaded\billbacks\capture\Upload_Billback\Data_Files\#Get_Item.Unique_Name#" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Click on this link to view this data"><B>view</b></A>
							<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
							
						</CFIF>
						</TD>	
						</CFOUTPUT>
					</TR>	
					<TR>
						<TD VALIGN="top" NOWRAP>&nbsp;<B>Detail File:</B></TD>
						<CFOUTPUT>
						<TD VALIGN="top"><INPUT SIZE="45" NAME="D_Title" VALUE="#Get_Item2.D_Title#" MAXLENGTH="50" READONLY DISABLED> &nbsp;&nbsp;						
						<CFIF Get_Item2.D_Title NEQ "">
							<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
							<A href="#application.HTTPVar##CGI.server_name#/GetDocument.cfm?FilePath=Data_Files\Uploaded\billbacks\capture\Upload_Billback\Data_Files\#Get_Item2.D_Unique_name#" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Click on this link to view this data"><B>view</b></A>
							<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
						</CFIF>
						</TD>
						</CFOUTPUT>
					</TR>					
					</CFIF>
				<!--- 	<TR>
						<TD VALIGN="top"><B>Activate on:</B></TD>
						<TD VALIGN="top"><CF_EASYDATE FORMNAME="MyForm" FIELDNAME="Activation_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Get_Item.Activation_Date#"></TD>
					</TR>
					<TR>
						<TD VALIGN="top"><B>Fical Year:</B></TD>
						<TD VALIGN="top">
						<CFOUTPUT>
						<CFIF URL.RID EQ "">							
							<SELECT NAME="Fiscal_Year">
								<OPTION VALUE="#YEAR(DateAdd("yyyy",-1,now()))#">#YEAR(DateAdd("yyyy",-1,now()))#</OPTION>
								<OPTION VALUE="#YEAR(now())#" SELECTED>#YEAR(now())#</OPTION>
								<OPTION VALUE="#YEAR(DateAdd("yyyy",1,now()))#">#YEAR(DateAdd("yyyy",1,now()))#</OPTION>
							</SELECT> 									
						<CFELSE>
							#Get_Item.Fiscal_Year#
						</CFIF>
						</CFOUTPUT>										
						</TD>
					</TR>		 --->				
					<!--- <CFIF URL.RID EQ "" OR (URL.RID NEQ "" AND Get_Item.Deleted EQ 0)>
						<CFSET Status = "">							
						<CFIF Get_Item.Activate_Tonight EQ 1>
							<CFSET Status = "Checked">
						</CFIF>
						<TR>
							<TD><B>Activate Tonight:</B></TD>
							<TD><CFOUTPUT><INPUT TYPE="CheckBox" NAME="Activate_Tonight" ONCLICK="Javascript: confirmActivation()" #Status#></CFOUTPUT></TD>
						</TR>
					</CFIF> --->
					
					<TR>
						<TD VALIGN="top">
							<BR><BR>
							<B>	
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
								<A HREF="index.cfm"><B>create new entry</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</B>
						</TD>
						<TD VALIGN="top"><BR><BR>	
							<CFIF URL.RID EQ "">							
								<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
										<A HREF="javascript: validate()"><B>upload data</B></A>
								<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
									
								<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
								<CFIF Get_Item.Deleted EQ 1>
								<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
										<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
								<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
								</CFIF>	
							</CFIF>					
						</TD>						
					</TR>
					<CFQUERY NAME="CheckActiveProcess" DATASOURCE="#Application.Datasource#">
						SELECT * FROM Billback_Upload_Master WHERE (Process_Status_ID = 2 AND Deleted = 0) OR Alive_Upload = 1
					</CFQUERY>
					<CFQUERY NAME="CheckActiveProcess2" DATASOURCE="#Application.Datasource#">
						SELECT * FROM Billback_Upload_Details WHERE D_Process_Status_ID = 2 AND Deleted = 0
					</CFQUERY>
					<CFIF CheckActiveProcess.RecordCount GT 0 OR CheckActiveProcess2.RecordCount GT 0>
					<TR>
						<TD></TD>
						<TD COLSPAN="2" ALIGN="right"><BR><BR><BR><BR>						
						<B>	
						<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
							<A HREF="##" ONCLICK="Javascript: KillProcess();"><B>Kill Outstanding Process</B></A>
						<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
						</B>							
						</TD>
					</TR>
					</CFIF>
				</TABLE>				
				</FORM>				
			</TD>
		</TR>
	</TABLE>
		
	
		
				
	<SCRIPT language="JavaScript">
	function KillProcess()
	{
		if (confirm("Press OK to kill the outstanding another users upload process."))
		{
			window.location.href = "index.cfm?Show_Tab=1&killProcess=1";
		}
	}
	function validate()
	{
		var rid = "<CFOUTPUT>#URL.RID#</CFOUTPUT>";	
		var submit_ok = 1;
		if (rid == "")
		{
			if (document.all.Header_File_Path.value =="")
			{			
				alert("Please select a Spread Sheet with Billback Header Information to upload.");
				document.all.Header_File_Path.focus();
				submit_ok = 0;
				return;
			}
			if (document.all.Header_WS_Name.value == "")
			{
				alert("Please enter the worksheet name of the header file that you selected to upload.")
				document.all.Header_WS_Name.focus();
				submit_ok = 0;
				return;
			}
			if (document.all.Detail_File_Path.value =="")
			{	
				alert("Please select a Spread Sheet with Billback Detail Information to upload.")				
				document.all.Detail_File_Path.focus();
				submit_ok = 0;
				return;
			}
			if (document.all.Detail_WS_Name.value == "")
			{
				alert("Please enter the worksheet name of the Detail file that you selected to upload.")
				document.all.Detail_WS_Name.focus();
				submit_ok = 0;
				return;
			}
			var HeaderfilePath = document.all.Header_File_Path.value;
			var strLength = HeaderfilePath.length;
			var periodPostion = HeaderfilePath.lastIndexOf(".");
			var periodPostion = periodPostion + 1;
			var fileExtension = HeaderfilePath.substr(periodPostion,strLength);
			var lower = fileExtension.toLowerCase()
			if (lower != "xls")
			{
				alert("Please upload Billback Header Information spread sheet(.xls).");
				document.all.Header_File_Path.focus();
				submit_ok = 0;
				return;
			}
				
			var filePath = document.all.Detail_File_Path.value;
			var strLength = filePath.length;
			var periodPostion = filePath.lastIndexOf(".");
			var periodPostion = periodPostion + 1;
			var fileExtension = filePath.substr(periodPostion,strLength);
			var lower = fileExtension.toLowerCase()
			if (lower != "xls")
			{
				alert("Please upload Billback Detail Information spread sheet(.xls).");
				document.all.Detail_File_Path.focus();
				submit_ok = 0;
				return;
			}	
			if (HeaderfilePath == filePath)
			{
				alert("Header and Detail file cannot be the same.");
				document.all.Header_File_Path.focus();
				submit_ok = 0;
				return;			
			}
			if 	(submit_ok == 1)
			{
				if (confirm("Press OK \n 1. if the work sheet name in the files to be uploaded is an exact match of the sheet name entered in the interface. \n 2. And if the files are ready to upload."))
				{					
					document.MyForm.submit()
				}
			}								
		}		
	}
	</SCRIPT>
</CFIF>