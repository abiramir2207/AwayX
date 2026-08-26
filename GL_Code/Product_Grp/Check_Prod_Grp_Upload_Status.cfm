


<CFSET URL.PageTitle="Payables: Upload Product Group">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFQUERY NAME="CheckProcessStatus" DATASOURCE="#Application.Datasource#">
	SELECT 	GL_Code_Process_Status_ID,
			GL_Code_Pro_Grp_Upload_ID
			 
	FROM 	GL_Code_Pro_Grp_Upload
	
	WHERE 	GL_Code_Pro_Grp_Upload_ID = ( SELECT MAX(GL_Code_Pro_Grp_Upload_ID) FROM GL_Code_Pro_Grp_Upload ) AND 
			Deleted = 0 
</CFQUERY>

<CFSET ShowLog = 0>


<BR><BR><BR><BR>
<TABLE ALIGN="CENTER">
	<TR>
		<TD>
			<B><FONT COLOR="Red" SIZE="3">
				<CFIF CheckProcessStatus.GL_Code_Process_Status_ID EQ 3>					
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
		if (confirm("Upload failed because of the invalid file format."))
		{
			window.location.href = "Upload_Product_Grp.cfm";
		}
		else
		{
			window.location.href = "Upload_Product_Grp.cfm";
		}
	}
	else if (statusID == 5)
	{		
		window.location.href = "Upload_Product_Grp.cfm";
	}
	else
	{	
		location.reload();
	}
}
window.setTimeout('ReFresh();', 2000);	
</SCRIPT>