<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFIF IsDefined("URL.KillProcess")>
	<cfset useLakebaseForUpdateStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_upload")>
<cfif useLakebaseForUpdateStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_upload",
			{
				"gl_code_process_status_id" = "eq.2",
				"deleted" = "eq.0"
			},
			{
				"gl_code_process_status_id" = "3"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateStatus>
<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
		UPDATE GL_Code_Upload
		SET GL_Code_Process_Status_ID = 3
		WHERE GL_Code_Process_Status_ID = 2 AND Deleted = 0
	</CFQUERY>
</cfif>
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">The Outstanding Upload Process has been killed.</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function RelocateThis()
	{		
		window.location.href = "index.cfm?Show_Tab=3";
	}
	window.setTimeout('RelocateThis()', 2000);	
	</SCRIPT>
	<CFABORT>
</CFIF> 
<CFIF IsDefined("URL.ProcessWait")>

	<CFQUERY NAME="CheckProcessStatus" DATASOURCE="#Application.Datasource#">
		SELECT 	GL_Code_Process_Status_ID,
				GL_Code_Upload_ID
				 
		FROM 	GL_Code_Upload
		
		WHERE 	GL_Code_Upload_ID = ( SELECT MAX(GL_Code_Upload_ID) FROM GL_Code_Upload ) AND 
				Deleted = 0 
	</CFQUERY>
	
	<CFSET ShowLog = 0>
	
	<CFIF CheckProcessStatus.GL_Code_Process_Status_ID EQ 5>
		<CFQUERY NAME="CheckForLog" DATASOURCE="#Application.Datasource#">
			SELECT 	* 
			FROM 	Gl_Code_Activation_Log 
			
			WHERE 	GL_Code_Upload_ID = #CheckProcessStatus.GL_Code_Upload_ID# AND
					Temp_Log IN (1,2) AND
					Script_Log = 0 AND
					Deleted = 0
		</CFQUERY>
		
		<CFIF CheckForLog.RecordCount GT 0>
			<CFSET ShowLog = 1>
		</CFIF>
	</CFIF>
	<BR><BR><BR><BR>
	<TABLE ALIGN="CENTER">
		<TR>
			<TD>
				<B><FONT COLOR="Red" SIZE="3">
					<CFIF CheckProcessStatus.GL_Code_Process_Status_ID EQ 3>
						<cfset useLakebaseForUpdateActivateBit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_upload")>
<cfif useLakebaseForUpdateActivateBit>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_upload",
			{
				"gl_code_upload_id" = "eq.#CheckProcessStatus.GL_Code_Upload_ID#"
			},
			{
				"activate_tonight" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateActivateBit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateActivateBit>
<CFQUERY NAME="UpdateActivateBit" DATASOURCE="#Application.Datasource#">
							UPDATE 	GL_Code_Upload 
							SET 	Activate_Tonight = 0
							WHERE 	GL_Code_Upload_ID = #CheckProcessStatus.GL_Code_Upload_ID#
						</CFQUERY>
</cfif>
						Upload failed.
					<CFELSEIF CheckProcessStatus.GL_Code_Process_Status_ID EQ 5>
						Upload Process completed successfully. This Upload will be activated on the date mentioned.
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
		var statusID = "<CFOUTPUT>#CheckProcessStatus.GL_Code_Process_Status_ID#</CFOUTPUT>";
		var showLog = "<CFOUTPUT>#ShowLog#</CFOUTPUT>";
		
		if (statusID == 3)
		{
			if (confirm("Upload failed because of the invalid file format. Press ok to see the log"))
			{
				window.location.href = "index.cfm?Show_Tab=4&TempLog=1&GL_Code_Upload_ID=<CFOUTPUT>#CheckProcessStatus.GL_Code_Upload_ID#</CFOUTPUT>";
			}
			else
			{
				window.location.href = "index.cfm?Show_Tab=3";
			}
		}
		else if (statusID == 5)
		{
			if (showLog == 1)
			{
				if (confirm("Press OK to see the log of this upload (There is(are) a(some) unseccessful record(s)."))
				{
					window.location.href = "index.cfm?Show_Tab=4&TempLog=1&GL_Code_Upload_ID=<CFOUTPUT>#CheckProcessStatus.GL_Code_Upload_ID#</CFOUTPUT>";
				}
				else
				{
					window.location.href = "index.cfm?Show_Tab=3";
				}
			}
			else
			{
				window.location.href = "index.cfm?Show_Tab=3";
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
	<CFPARAM NAME="FORM.WorkSheetName" DEFAULT="Sheet1">
	<cfset useLakebaseForAnyReadyActivateTonight = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_upload")>
<cfif useLakebaseForAnyReadyActivateTonight>
	<cftry>
		<cfset AnyReadyActivateTonight = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_upload", {
				"activate_tonight" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAnyReadyActivateTonight = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAnyReadyActivateTonight>
<CFQUERY NAME="AnyReadyActivateTonight" DATASOURCE="#Application.Datasource#">
		SELECT * FROM GL_Code_Upload WHERE Activate_Tonight = 1 AND Deleted = 0
	</CFQUERY>
</cfif>
	<CFSET AnyReadyToActivate = 0>
	<CFIF AnyReadyActivateTonight.RecordCount GT 0>
		<CFSET AnyReadyToActivate = 1>
	</CFIF>

	<CFQUERY NAME="Get_Gl_Code" datasource="#application.datasource#">
		SELECT		GL_Code_Upload.*,
					Name_First,
					Name_last 
					
		FROM		GL_Code_Upload 
		INNER JOIN	_Users ON _Users.User_ID = GL_Code_Upload.Uploaded_By
		WHERE		(DATEDIFF(d, Created_Date, GetDate())) = 0 OR
					GL_Code_Upload.Deleted = 0
		ORDER BY	Created_Date DESC
	</CFQUERY>
	<!--- <BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><FONT COLOR="red" SIZE="2"><B>The most recent uploaded version of the below listed file will be committed nightly.</B></FONT></TD>
		</TR>
	</TABLE> --->
	<BR>
	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">
	
				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">
	
				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
					<TR>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Uploaded By</B>&nbsp;&nbsp;</SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Fiscal Year</B></SPAN>&nbsp;&nbsp;</TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Activate On</B></SPAN>&nbsp;&nbsp;</TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN>&nbsp;&nbsp;</TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Active</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_Gl_Code">
					<TR>
						<TD NOWRAP><A HREF="index.cfm?Show_Tab=3&RID=#GL_Code_Upload_ID#">#Name_First# #Name_last# </A></TD>
						<TD	ALIGN="Center">#Fiscal_Year#&nbsp;</TD>
						<TD	ALIGN="Center">#DATEFORMAT(Activation_Date,"mm/dd/yyyy")#&nbsp;</TD>
						<TD NOWRAP ALIGN="Center">
								<CFIF Deleted EQ 0>
								<IMG SRC="/images/yes_small.gif" TITLE="active record...">
								<CFELSE>
								<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
								</CFIF>
						</TD>
						<TD ALIGN="Center">
							<cfset useLakebaseForGetActive = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_activation")>
<cfif useLakebaseForGetActive>
	<cftry>
		<cfset GetActive = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_activation", {
				"gl_code_upload_id" = "eq.#GL_Code_Upload_ID#",
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetActive = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetActive>
<CFQUERY NAME="GetActive" DATASOURCE="#Application.Datasource#">
								SELECT 	Top 1 * 
								FROM 	GL_Code_Activation
								WHERE 	GL_Code_Upload_ID = #GL_Code_Upload_ID# AND
										Deleted = 0
							</CFQUERY>
</cfif>
							<CFIF GetActive.Current_Active_Data EQ 1>
							<img src="/Images/alert_icon_small.gif" alt="" width="10" height="10" border="0">
							<CFELSE>
							&nbsp;
							</CFIF>
							
						</TD>
					</TR>
					</CFOUTPUT>
				</TABLE>
	
				<BR>
	
				<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - Uploaded<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - Not Uploaded<BR>
				<img src="/Images/alert_icon_small.gif" alt="" width="10" height="10" border="0"> - Data from this upload is currently active
				
			</TD>
			<TD VALIGN="top">
	
	
				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">
	
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- Retrieve the data for the ID of the item passed --->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
	
				
	
				<CFPARAM NAME="Get_Item.GL_Code_Title" DEFAULT="">
				<CFPARAM NAME="Get_Item.Deleted" DEFAULT="">
				<CFPARAM NAME="Get_Item.Activate_Tonight" DEFAULT="0">
				<CFPARAM NAME="Get_Item.Activate_On" DEFAULT="">
				
				<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
					SELECT		GL_Code_Upload.*, 
								Name_First, 
								Name_Last
								
					FROM		GL_Code_Upload
					INNER JOIN	_Users ON _Users.User_ID = GL_Code_Upload.Uploaded_By
					
					WHERE		GL_Code_Upload_ID	like	'#URL.RID#'
				</CFQUERY>

				<FORM ACTION="Upload_GL_Code_Action.cfm" METHOD="post" NAME="MyForm" ENCTYPE="multipart/form-data">
					<INPUT TYPE="Hidden" NAME="JustActivateToNight" VALUE="0">
					<INPUT TYPE="Hidden" NAME="ActivateStatus" VALUE="0">
					<CFOUTPUT>
					<INPUT TYPE="Hidden" NAME="Today" VALUE="#DATEFORMAT(now(),"mm/dd/yyyy")#">
					<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
					</CFOUTPUT>
					<TABLE CELLSPACING="5" CELLPADDING="0">
						
						<CFIF URL.RID EQ "">
						<TR>
							<TD VALIGN="top" NOWRAP><SPAN ID="ERR_FILE"></SPAN>&nbsp;<B>Select the file to Uploaded:</B></TD>
							<CFOUTPUT>
							<TD VALIGN="top"><INPUT SIZE="45" TYPE="file" NAME="File_Path"></TD>						
							</CFOUTPUT>
						</TR>	
						<TR>
							<TD VALIGN="top"><B>Work Sheet Name:</B></TD>
							<TD VALIGN="top"><CFOUTPUT><INPUT TYPE="Text" NAME="WorkSheetName" VALUE="#FORM.WorkSheetName#"></CFOUTPUT></TD>
						</TR>					
						<CFELSE>
						<TR>
							<TD VALIGN="top"><B>GL Code:</B></TD>								
							<CFOUTPUT>						
							<TD VALIGN="top">
								<INPUT SIZE="45" NAME="GL_Code_Title" <CFIF Get_Item.GL_Code_Title NEQ "">VALUE="#Get_Item.GL_Code_Title#"<CFELSE>VALUE="#DateStampedGLCode#"</CFIF> MAXLENGTH="50" READONLY DISABLED> 
								<INPUT TYPE="hidden" NAME="GL_Code_Title" VALUE="#Get_Item.GL_Code_Title#"> 						
								<CFIF Get_Item.GL_Code_Title NEQ "">
									<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
									<A href="#application.HTTPVar##CGI.server_name#/GetDocument.cfm?FilePath=data_files/uploaded/GL_Code/GL_Code_Data/#Get_Item.GL_Code_Uni_Name#" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Click on this link to view this document"><B>view</b></A>									
									<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
								</CFIF>
							</CFOUTPUT>
							</TD>
						</TR>
						</CFIF>
						
						<TR>
							<TD VALIGN="top"><B>Activate on:</B></TD>
							<TD VALIGN="top"><CF_EASYDATE FORMNAME="MyForm" FIELDNAME="Activation_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Get_Item.Activation_Date#"></TD>
						</TR>
						<TR>
							<TD VALIGN="top"><B>Fiscal Year:</B></TD>
							<TD VALIGN="top">
							<CFOUTPUT>
							<CFIF URL.RID EQ "">							
								<SELECT NAME="Fiscal_Year">
									<OPTION VALUE="#YEAR(DateAdd("yyyy",-3,now()))#">#YEAR(DateAdd("yyyy",-3,now()))#</OPTION>
									<OPTION VALUE="#YEAR(DateAdd("yyyy",-2,now()))#">#YEAR(DateAdd("yyyy",-2,now()))#</OPTION>
									<OPTION VALUE="#YEAR(DateAdd("yyyy",-1,now()))#">#YEAR(DateAdd("yyyy",-1,now()))#</OPTION>
									<OPTION VALUE="#YEAR(now())#" SELECTED>#YEAR(now())#</OPTION>
									<OPTION VALUE="#YEAR(DateAdd("yyyy",1,now()))#">#YEAR(DateAdd("yyyy",1,now()))#</OPTION>
									<OPTION VALUE="#YEAR(DateAdd("yyyy",2,now()))#">#YEAR(DateAdd("yyyy",2,now()))#</OPTION>
									<OPTION VALUE="#YEAR(DateAdd("yyyy",3,now()))#">#YEAR(DateAdd("yyyy",3,now()))#</OPTION>
								</SELECT> 									
							<CFELSE>
								#Get_Item.Fiscal_Year#
							</CFIF>
							</CFOUTPUT>										
							</TD>
						</TR>						
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
							<TD VALIGN="top" ALIGN="Right">
							<B>	
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
								<A HREF="index.cfm?Show_Tab=3"><B>create new entry</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>&nbsp;&nbsp;
							</B>
							</TD>
							<TD VALIGN="top">								
								<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
										<A HREF="javascript: validate()"><B><CFIF URL.RID EQ "">upload data<CFELSEIF URL.RID NEQ "" AND Get_Item.Deleted EQ 0>save changes</CFIF></B></A>
								<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
									
								<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
								<CFIF Get_Item.Deleted EQ 1>
								<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
										<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
								<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
								</CFIF>							
							</TD>						
						</TR>
						<cfset useLakebaseForCheckActiveProcess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_upload")>
<cfif useLakebaseForCheckActiveProcess>
	<cftry>
		<cfset CheckActiveProcess = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_upload", {
				"gl_code_process_status_id" = "eq.2",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckActiveProcess = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckActiveProcess>
<CFQUERY NAME="CheckActiveProcess" DATASOURCE="#Application.Datasource#">
							SELECT * FROM GL_Code_Upload WHERE GL_Code_Process_Status_ID = 2 AND Deleted = 0
						</CFQUERY>
</cfif>
						<CFIF CheckActiveProcess.RecordCount GT 0>
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
	
	
	<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
	 
	<SCRIPT language="JavaScript">	
	function KillProcess()
	{
		if (confirm("Press OK to kill the outstanding another users upload process."))
		{
			window.location.href = "index.cfm?Show_Tab=3&killProcess=1";
		}
	}
	function checkDate(dateStr1,dateStr2)
	{
	 	var dateSplit; 
	 	var retVal = null;
		dateSplit = dateStr1.split("/"); 
		if(dateSplit.length > 2)
	 	{
	 	 	var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
	  		dateSplit = dateStr2.split("/");
	  		if(dateSplit.length > 2)
	  		{
	   			var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
	   			retVal = days_between(date1, date2, true);
	  		}
	 	}
	 	return retVal;
	}		
	
	function ActivateData()
	{		
		var curBitStatus = "<CFOUTPUT>#Get_Item.Activate_Tonight#</CFOUTPUT>";
		
		document.all.JustActivateToNight.value = 1;
		if (curBitStatus == 0)
		{
			if (document.all.Activate_Tonight.checked == true)
			{
				if(confirm("Data from this spread sheet will be activated tonight"))
				{									
					document.all.ActivateStatus.value = 1;					
					document.MyForm.submit()
				}					
			}
		}	
		else
		{
			if (document.all.Activate_Tonight.checked == true)
			{
				document.all.ActivateStatus.value = 1;
				document.MyForm.submit()
			}
			else
			{
				document.all.ActivateStatus.value = 0;
				document.MyForm.submit()
			}
		}	
		
	}
	/*function confirmActivation()
	{
		var alertUser = "<CFOUTPUT>#AnyReadyToActivate#</CFOUTPUT>";
		var curBitStatus = "<CFOUTPUT>#Get_Item.Activate_Tonight#</CFOUTPUT>";
		var rid = "<CFOUTPUT>#URL.RID#</CFOUTPUT>";
		if (curBitStatus == 1)
		{
			if (document.all.Activate_Tonight.checked == false)
			{
				document.all.ActivateThis.style.textDecoration = "none";		
				document.all.ActivateThis.style.color = "blue";
			}
			else
			{
				document.all.ActivateThis.style.textDecoration = "none";
				document.all.ActivateThis.style.color = "silver";			
			}
		}
		else
		{
			if (document.all.Activate_Tonight.checked == true)
			{
				if (alertUser == 1)
				{
					if (confirm("There is a set of data to be activated tonight. Press OK if you want to make your selection active and not the existing one"))				
					{	
						if (rid != "")
						{	
							document.all.ActivateThis.style.textDecoration = "none";		
							document.all.ActivateThis.style.color = "blue";
						}
					}
					else
					{
						if (rid != "")
						{	
							document.all.ActivateThis.style.textDecoration = "none";
							document.all.ActivateThis.style.color = "silver";
							document.all.Activate_Tonight.checked = false;	
						}
					}
				}
			}
			else
			{
				if (rid != "")
				{
					document.all.ActivateThis.style.textDecoration = "none";
					document.all.ActivateThis.style.color = "silver";
				}
			}
		}
	}*/
	function alert_and_delete()
	{
		var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
		if (confirmdelete == true)
		{
			document.all.DeleteRecord.value=1;
			document.MyForm.submit();
		}			
	}

	function validate()
	{
		var rid = "<CFOUTPUT>#URL.RID#</CFOUTPUT>";	
		var submit_ok = 1;
		if (rid == "")
		{
			if (document.all.File_Path.value =="")
			{			
				alert("Please select a GL Code Spread Sheet to upload.")
				submit_ok = 0;
			}
			if (document.all.Activation_Date.value == "")
			{
				alert("Please enter an activation date (greater than today).");
				document.all.Activation_Date.focus();
				submit_ok = 0;
			}
			else 
			{
				if (checkDate(document.all.Today.value, document.all.Activation_Date.value) < 0)	
				{
				}
				else
				{
					alert("Activation date must be greater than today.")
					document.all.Activation_Date.focus();
					submit_ok = 0;
				}
			}
			
			if (submit_ok ==1)
			{
				var filePath = document.all.File_Path.value;
				var strLength = filePath.length;
				var periodPostion = filePath.lastIndexOf(".");
				var periodPostion = periodPostion + 1;
				var fileExtension = filePath.substr(periodPostion,strLength);
				var lower = fileExtension.toLowerCase()
				if (lower != "xls")
				{
					alert("Please upload GL Code spread sheet(.xls).")
				}
				else
				{
					if (confirm("Press OK \n 1. if the sheet name in the file to be uploaded is an exact match of the work sheet name entered in the interface. \n 2. And if the GL Code data file is ready to upload.(This upload will delete previous uploads to be activated on the same date if any)."))
					{
						/*if (document.all.Activate_Tonight.checked == true)
						{
							document.all.ActivateStatus.value = 1;
						}	*/					
						document.MyForm.submit()
					}
				}
			}	
		}
		else
		{	
			if (document.all.Activation_Date.value == "")
			{
				alert("Please enter an activation date (greater than today).");
				document.all.Activation_Date.focus();
				submit_ok = 0;
			}
			else 
			{
				if (checkDate(document.all.Today.value, document.all.Activation_Date.value) < 0)	
				{
				}
				else
				{
					alert("Activation date must be greater than today.")
					document.all.Activation_Date.focus();
					submit_ok = 0;
				}
			}	
			/*if (document.all.Activate_Tonight.checked == true)
			{
				document.all.ActivateStatus.value = 1;
			}	*/	
			document.MyForm.submit()
		}
	}
	</SCRIPT>
</CFIF>

</body>
</html>
