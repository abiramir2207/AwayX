
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFSET URL.PageTitle="Payables: Upload Product Group">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF IsDefined("URL.KillProcess")>
	<cfset useLakebaseForUpdateStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_pro_grp_upload")>
<cfif useLakebaseForUpdateStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_pro_grp_upload",
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
		UPDATE GL_Code_Pro_Grp_Upload
		SET GL_Code_Process_Status_ID = 3
		WHERE GL_Code_Process_Status_ID = 2 AND Deleted = 0
	</CFQUERY>
</cfif>
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">The Outstanding upload Process has been killed.</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function RelocateThis()
	{		
		window.location.href = "Upload_Product_Grp.cfm";
	}
	window.setTimeout('RelocateThis()', 2000);	
	</SCRIPT>
	<CFABORT>
</CFIF> 


<CFPARAM NAME="URL.RID" DEFAULT="">
<CFPARAM NAME="FORM.WorkSheetName" DEFAULT="Sheet1">

<CFQUERY NAME="Get_All" datasource="#application.datasource#">
	SELECT		GL_Code_Pro_Grp_Upload.*,
				Name_First,
				Name_last 
				
	FROM		GL_Code_Pro_Grp_Upload 
	INNER JOIN	_Users ON _Users.User_ID = GL_Code_Pro_Grp_Upload.Uploaded_By
	WHERE		(DATEDIFF(d, Created_Date, GetDate())) = 0 OR
				GL_Code_Pro_Grp_Upload.Deleted = 0
	ORDER BY	Created_Date DESC
</CFQUERY>



<BR>
<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
	<TR>
		<TD VALIGN="top">

			<SPAN CLASS="title2">Stored Records</SPAN>
			<HR COLOR="Blue" SIZE="1">

			<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" CLASS="Maintable">
				<TR>
					<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Uploaded By</B>&nbsp;&nbsp;</SPAN></TD>
					<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Fiscal Year</B></SPAN>&nbsp;&nbsp;</TD>
					<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Activate On</B></SPAN>&nbsp;&nbsp;</TD>					
					<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN>&nbsp;&nbsp;</TD>
					<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Active</B></SPAN></TD>
				</TR>
				<CFOUTPUT QUERY="Get_All">
				<TR>
					<TD NOWRAP><A HREF="Upload_Product_Grp.cfm?RID=#GL_Code_Pro_Grp_Upload_ID#">#Name_First# #Name_last# </A></TD>
					<TD ALIGN="Center">#Fiscal_Year#</TD>
					<TD ALIGN="Center">#DATEFORMAT(ProGrp_Activation_Date,"mm/dd/yyyy")#&nbsp;</TD>					
					<TD NOWRAP ALIGN="Center">
							<CFIF Deleted EQ 0>
							<IMG SRC="/images/yes_small.gif" TITLE="active record...">
							<CFELSE>
							<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
							</CFIF>
					</TD>
					<TD ALIGN="Center">
							<cfset useLakebaseForGetActive = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_pro_group_mapping")>
<cfif useLakebaseForGetActive>
	<cftry>
		<cfset GetActive = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_pro_group_mapping", {
				"gl_code_pro_grp_upload_id" = "eq.#GL_Code_Pro_Grp_Upload_ID#",
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
								FROM 	GL_Code_Pro_Group_Mapping
								WHERE 	GL_Code_Pro_Grp_Upload_ID = #GL_Code_Pro_Grp_Upload_ID# AND
										Deleted = 0
							</CFQUERY>
</cfif>
						<CFIF GetActive.Active_Data EQ 1>
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

		
		<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
			SELECT		GL_Code_Pro_Grp_Upload.*, 
						Name_First, 
						Name_Last
						
			FROM		GL_Code_Pro_Grp_Upload
			INNER JOIN	_Users ON _Users.User_ID = GL_Code_Pro_Grp_Upload.Uploaded_By
			
			WHERE		GL_Code_Pro_Grp_Upload_ID	like	'#URL.RID#'
		</CFQUERY>
		
		<FORM ACTION="Upload_Product_Grp_Action.cfm" METHOD="post" NAME="MyForm" ENCTYPE="multipart/form-data">
		<CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
		<INPUT TYPE="Hidden" NAME="Today" VALUE="#DATEFORMAT(now(),"mm/dd/yyyy")#">
		</CFOUTPUT>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="5">
			<CFIF URL.RID EQ "">
			<TR>
				<TD VALIGN="top" NOWRAP><SPAN ID="ERR_FILE"></SPAN>&nbsp;<B>Select the file to Upload:</B></TD>
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
				<TD VALIGN="top"><B>Product Group:</B></TD>								
				<CFOUTPUT>						
				<TD VALIGN="top">
					<INPUT SIZE="40" NAME="Title" <CFIF Get_Item.Title NEQ "">VALUE="#Get_Item.Title#"<CFELSE>VALUE="#DateStampedGLCode#"</CFIF> MAXLENGTH="50" READONLY DISABLED> 
					<INPUT TYPE="hidden" NAME="GL_Code_Title" VALUE="#Get_Item.Title#">					
					<CFIF Get_Item.Title NEQ "">
						<FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
						<A href="#application.HTTPVar##CGI.server_name#/GetDocument.cfm?FilePath=data_files/uploaded/GL_Code/Product_Grp_Data/#Get_Item.Uni_Name#" onclick="NewWindow(this.href,'Proname','800','600','Yes', 'No');return false;" TITLE="Click on this link to view this file"><B>view</b></A>
						<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT>
					</CFIF>
				</CFOUTPUT>
				</TD>
			</TR>
			</CFIF>
			
			<TR>
				<TD VALIGN="top"><B>Activate on:</B></TD>
				<TD VALIGN="top"><CF_EASYDATE FORMNAME="MyForm" FIELDNAME="ProGrp_Activation_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Get_Item.ProGrp_Activation_Date#"></TD>
			</TR>
			<TR>
				<TD VALIGN="top"><B>Fical Year:</B></TD>
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
			<TR>
				<TD VALIGN="top" ALIGN="right">
				<B>	
				<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
					<A HREF="Upload_Product_Grp.cfm"><B>create new entry</B></A>
				<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
				</B>&nbsp;&nbsp;
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
			<cfset useLakebaseForCheckActiveProcess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_pro_grp_upload")>
<cfif useLakebaseForCheckActiveProcess>
	<cftry>
		<cfset CheckActiveProcess = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_pro_grp_upload", {
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
				SELECT * FROM GL_Code_Pro_Grp_Upload WHERE GL_Code_Process_Status_ID = 2 AND Deleted = 0
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
		window.location.href = "Upload_Product_Grp.cfm?killProcess=1";
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
			alert("Please select a Product Group Spread Sheet to upload.")
			submit_ok = 0;
			return;
		}
		if (document.all.WorkSheetName.value == "")
		{
			alert("Worksheet name can't be empty. Please enter the worksheet name.")
			submit_ok = 0;
			document.all.WorkSheetName.focus();
			return;
		}
		
		if (document.all.ProGrp_Activation_Date.value == "")
		{
			alert("Please enter an activation date (greater than today).");
			document.all.ProGrp_Activation_Date.focus();
			submit_ok = 0;
			return;
		}
		else 
		{
			if (checkDate(document.all.Today.value, document.all.ProGrp_Activation_Date.value) < 0)	
			{
			}
			else
			{
				alert("Activation date must be greater than today.")
				document.all.ProGrp_Activation_Date.focus();
				submit_ok = 0;
				return;
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
				alert("Please upload Product Group spread sheet(.xls).")
				return;
			}
			else
			{
				if (confirm("Press OK \n 1. if the sheet name in the file to be uploaded is an exact match of the work sheet name entered in the interface. \n 2. And if the Product Group data file is ready to upload.(This upload will delete previous uploads to be activated on the same date if any)."))
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
		if (document.all.ProGrp_Activation_Date.value == "")
		{
			alert("Please enter an activation date (greater than today).");
			document.all.ProGrp_Activation_Date.focus();
			submit_ok = 0;
			return;
		}
		else 
		{
			if (checkDate(document.all.Today.value, document.all.ProGrp_Activation_Date.value) < 0)	
			{
			}
			else
			{
				alert("Activation date must be greater than today.")
				document.all.ProGrp_Activation_Date.focus();
				submit_ok = 0;
				return;
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
