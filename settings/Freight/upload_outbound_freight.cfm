<cfquery name="getUploadInfo" datasource="#application.datasource#">
 SELECT tbl_1.*,tbl_2.Name_First + ' ' + tbl_2.Name_Last As FullName,tbl_3.ErrorMessage
 ,tbl_1.Outbound_Freight_Upload_ID
 FROM Outbound_Freight_Upload tbl_1
 INNER JOIN _Users tbl_2
 ON tbl_1.Outbound_Freight_Upload_By = tbl_2.User_ID
 LEFT JOIN  Outbound_Freight_Upload_Detail tbl_3
 ON tbl_1.Outbound_Freight_Upload_ID = tbl_3.Outbound_Freight_Upload_ID
 WHERE tbl_1.Deleted = 0
 ORDER BY Outbound_Freight_Upload_Date DESC
</cfquery>

<cfset useLakebaseForgetUncompletedTasks = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("outbound_freight_upload")>
<cfif useLakebaseForgetUncompletedTasks>
	<cftry>
		<cfset getUncompletedTasks = application.oLakebase.toQuery(
			application.oLakebase.selectRows("outbound_freight_upload", {
				"outbound_freight_upload_status" = "eq.1",
				"deleted" = "eq.0",
				"select" = "outbound_freight_upload_id"
			}), "outbound_freight_upload_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUncompletedTasks = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUncompletedTasks>
<cfquery name="getUncompletedTasks" datasource="#application.datasource#">
 SELECT Outbound_Freight_Upload_ID
 FROM Outbound_Freight_Upload
 WHERE Outbound_Freight_Upload_Status = 1
 AND Deleted = 0
</cfquery>
</cfif>

<script language="javascript">
function ErrorCheck()
{

if(document.MyForm.File_Path.value=='')
{
alert("please select a file");
return false;
}
<cfif getUncompletedTasks.Recordcount NEQ 0>
	alert("The previous upload task is incomplete. Please wait for that task to be completed")
	return false;
<cfelse>
	MyForm.submit();
</cfif>
}

function Del_Uploads()
{
	for(i=0;i<=Delfrm.length;i++)
	{
		if(document.Delfrm.delUploads[i].checked)
		{
			Delfrm.submit();return false;
		}
	}
}
</script>

<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="100%">
	<TR>
		<TD VALIGN="TOP">
<cfif getUploadInfo.Recordcount NEQ 0>
	<TABLE ALIGN="LEFT" BORDER="0"  CLASS="Maintable">
		<TR>
			<TD style="border-bottom:0px;border-top:0px;">&nbsp;</TD>
		</TR>
		<TR>
		<TD><SPAN STYLE="font-size: 12px;">&nbsp;</TD>
		<TD><SPAN STYLE="font-size: 12px;"><B>User</B></SPAN></TD>
		<TD><SPAN STYLE="font-size: 12px;"><B>Date</B></SPAN></TD>
		<TD><SPAN STYLE="font-size: 12px;"><B>Upload Status</B></SPAN></TD>
	</TR>
 <form name="Delfrm" method="post" action="upload_outbound_freight_action.cfm">
 	<cfoutput>
		<input type="hidden" name="action" value="#action#">
	</cfoutput>
	<!---	D36633 --->
	<input type="checkbox" name="delUploads" style="display:none;">
	<CFOUTPUT QUERY="getUploadInfo">
	<TR>
		<TD>
		 <input type="checkbox" name="delUploads" value="#Outbound_Freight_Upload_ID#">
		</TD>
		<TD>#FullName#</TD>
		<TD><A href="openExcel.cfm?filename=#Outbound_Freight_Upload_File_Name#">#DateFormat(Created_Date,"MM/DD/YYYY")# #TimeFormat(Created_Date,"hh:mm:ss")#</TD>
		<TD NOWRAP ALIGN="CENTER">
				<CFIF Outbound_Freight_Upload_Status EQ 2>
				<IMG SRC="/images/yes_small.gif" TITLE="successful upload">
				<CFELSE>
				<IMG SRC="/images/no_small.gif" TITLE="#ErrorMessage#">
				</CFIF>
		</TD>
	</TR>
	</CFOUTPUT>
	</form>
	<TR>
		<TD style="border-bottom:0px;border-top:0px;">
		<span style="font-size:11px;font-weight:bold;color:FF0000;">[</font></span>
		<a href="##" onclick="Del_Uploads();return false;"  style="font-size:11px;font-weight:bold;">Delete</a>
		<span style="font-size:11px;font-weight:bold;color:FF0000;"><font color="FF0000">]</font></span>
		</TD>
	</TR>
</TABLE>
</cfif>
	</TD>
	<TD VALIGN="TOP"  ALIGN="RIGHT">
	<CFFORM ACTION="upload_outbound_freight_action.cfm" METHOD="POST" NAME="MyForm" ENCTYPE="multipart/form-data">
	<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0">
		<TR>
			<TD>&nbsp;</TD>
		</TR>
		<TR>
			<TD ALIGN="right" NOWRAP>&nbsp;<B>SELECT UPLOAD FILE</B></TD>
			<TD><INPUT SIZE="45" TYPE="file" NAME="File_Path">&nbsp;&nbsp;&nbsp;&nbsp;
			<INPUT TYPE="SUBMIT" VALUE="Upload" OnClick="return ErrorCheck()"></TD>
		</TR>
		<TR>
			<TD>&nbsp;</TD>
		</TR>
		<TR>
			<TD>&nbsp;</TD>
			<TD><a href="SampleFreightUpload.csv" target="SampleFreightUploadPreview"><img src="/images/doc.gif" border="0"> - &nbsp;Sample File</a>
			</TD>
		</TR>
		<TR>
			<TD>&nbsp;</TD>
		</TR>
		<TR>
			<TD>&nbsp;</TD>
			<TD><b>Instructions:</b>
			<ol>
					<li>File format must be .csv</li>
					<li>The number of freight brackets on the file must match the number of freight brackets on the
						 "Brackets" tab</li>
					<li>Dates on the file should be formatted as dates</li>
					<li>For a sample file, check the above sample file</li>
			</ol>
			</TD>
		</TR>
		<cfif getUncompletedTasks.Recordcount NEQ 0>
		<TR>
			<TD>&nbsp;</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%">
			<cfoutput>
			<span style="color:red;font-size:12px;font-weight:bold;">To upload another file, Please click <a href="upload_outbound_freight_action.cfm?Outbound_Freight_Upload_ID=#getUncompletedTasks.Outbound_Freight_Upload_ID#&ResetUpload=1&Action=#Action#">here</a> to reset the status of the previous upload</span>
			</cfoutput>
			</TD>
		</TR>
		</cfif>
	</TABLE>
	<cfoutput>
		<input type="hidden" name="action" value="#action#">
	</cfoutput>
	</CFFORM>
	</TD>
</TR>
</TABLE>


