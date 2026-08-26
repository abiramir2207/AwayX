<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFPARAM NAME="URL.TempLog" DEFAULT="0">
<CFPARAM NAME="URL.GL_Code_Upload_ID" DEFAULT="">
<CFIF URL.Show_Tab EQ 3>
	<CFSET URL.TempLog = 0>
<CFELSEIF URL.Show_TAB EQ 5>
	<CFSET URL.TempLog = 1>
</CFIF>
 
<CFQUERY NAME="GetLog" DATASOURCE="#Application.Datasource#">
	SELECT 		Gl_Code_Activation_Log.*,
				Uploaded_By,
				_Users.Name_First,
				_Users.Name_Last 
	
	FROM 		Gl_Code_Activation_Log 
	
	LEFT JOIN	GL_Code_Upload ON GL_Code_Upload.GL_Code_Upload_ID = Gl_Code_Activation_Log.GL_Code_Upload_ID
	LEFT JOIN 	_Users ON _Users.User_ID = GL_Code_Upload.Uploaded_By AND _Users.Deleted = 0
	
	WHERE 		Temp_Log = #URL.TempLog# AND 
				Script_Log <> 1 AND 
				<CFIF URL.GL_Code_Upload_ID NEQ "">
				Gl_Code_Activation_Log.GL_Code_Upload_ID = #URL.GL_Code_Upload_ID# AND
				</CFIF>
				Gl_Code_Activation_Log.Deleted = 0 
				
	ORDER BY 	Gl_Code_Activation_Log.Created_Date DESC
</CFQUERY>



<STYLE>
TABLE.UnderLine TD
{
	border-bottom: 1px #93BEE2 solid; 
}
</STYLE>


<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="98%" CLASS="UnderLine">	
	<TR BGCOLOR="FFE083">
		<TD><B>A/R</B></TD>		
		<TD><B>Invalid Reason</B></TD>
		<TD><B>Uploaded By</B></TD>
		<TD><B>Uploaded On</B></TD>
	</TR>
	<CFOUTPUT QUERY="GetLog">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD><B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="index.cfm?Show_Tab=#URL.Show_Tab#&ShowLogDetails=1&GL_Code_Activation_Log_ID=#GL_Code_Activation_Log_ID#&GL_Code_Upload_ID=#GL_Code_Upload_ID#">#A_R#</A><FONT COLOR="red" SIZE="2"> ]</FONT></B></TD>
			<TD>#InvalidReason#</TD>
			<TD>#Name_First# #Name_Last#</TD>
			<TD>#DATEFORMAT(Created_Date,"mm/dd/yyyy")# #TIMEFORMAT(Created_Date,"HH:mm:ss")#</TD>
		</TR>
	</CFOUTPUT>
</TABLE>

</body>
</html>
