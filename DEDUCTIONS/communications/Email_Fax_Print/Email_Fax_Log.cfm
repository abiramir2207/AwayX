<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFQUERY NAME="Log_Det" DATASOURCE="#Application.Datasource#">
	SELECT 		Message_Log_ID,
				Message_To,
				Message_From,
				Message_Subject,	
				Message_Log.Created_Date,			
				Name_First,
				Name_Last
	
	FROM 		Message_Log 	
	INNER JOIN	_Users On _Users.User_Id = Message_Log.User_Id
	
	WHERE		<CFIF URL.Type EQ "Email">
					Message_Type_Id = 1 AND 
				<CFELSE>
					Message_Type_Id = 2 AND
				</CFIF>
	
				App_Area_ID = 13 AND 
				App_Area_Identifier = '#Deduction_ID#' 
				
	ORDER BY Message_Log.Created_Date DESC
</CFQUERY>


<STYLE>
TABLE.underline TD 
{
	border-bottom:solid #C0C0C0 1px;
}
</STYLE>

<BR>
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" CLASS="underline" WIDTH="100%">
	<TR>
		<TD COLSPAN="100%" STYLE="Border: None;">
			<FONT SIZE="2"><B>
			<CFIF URL.Type EQ "Email">
				EMAIL LOG
			<CFELSE>
				FAX LOG
			</CFIF>
			</B></FONT>					
		</TD>
	</TR>
	<TR  BGCOLOR="FFE083">
		<TD><B>DATE</B></TD>
		<TD><B>FROM ANALYST</B></TD>				
		<TD><B>TO</B></TD>
		<TD><B>SUBJECT</B></TD>
		<TD><B>ATTACHMENTS</B></TD>
	</TR>
	<CFOUTPUT QUERY="Log_Det">
	<TR  BGCOLOR="#IIf(currentrow Mod 2,DE('ffffff'), DE('C6FFC6'))#">
		<TD VALIGN="Top">#DateFormat(Created_Date,"mm/dd/yyyy")#</TD>
		<TD VALIGN="Top" NOWRAP>#Name_First# #Name_Last#</TD>				
		<TD VALIGN="Top">
		<CFIF URL.Type EQ "Email">
			#Message_To#
		<CFELSE>
			<CFSET search = "~">
			<CFSET Sent_To = Find(search,Message_To)>
			<CFSET Sent_To = Sent_To - 1>
			<CFSET Sent_To = Left(Message_To,Sent_To)>	
			#Sent_To#
		</CFIF>
		
		</TD>
		<TD VALIGN="Top">#Message_Subject#&nbsp;</TD>
		<cfset useLakebaseForGetAttach = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("message_attachment")>
		<cfif useLakebaseForGetAttach>
			<cftry>
				<cfset Get_Attach = application.oLakebase.toQuery(
					application.oLakebase.selectRows("message_attachment", { "select" = "attachment_desc", "message_log_id" = "eq.#Message_Log_ID#", "attachment_desc" = "neq.Cover Sheet" })
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetAttach = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetAttach>
			<cfset useLakebaseForGet_Attach = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("message_attachment")>
<cfif useLakebaseForGet_Attach>
	<cftry>
		<cfset Get_Attach = application.oLakebase.toQuery(
			application.oLakebase.selectRows("message_attachment", {
				"message_log_id" = "eq.#Message_Log_ID#",
				"attachment_desc" = "neq.Cover Sheet",
				"select" = "attachment_desc"
			}), "attachment_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Attach = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Attach>
<CFQUERY NAME="Get_Attach" DATASOURCE="#Application.Datasource#">
				SELECT 	Attachment_Desc
				FROM 	Message_Attachment
				WHERE 	Message_Log_ID = '#Message_Log_ID#' AND Attachment_Desc <> 'Cover Sheet'
			</CFQUERY>
</cfif>
		</cfif>
		<TD VALIGN="Top">
			<CFIF Get_Attach.Recordcount GT 0>
				<CFLOOP QUERY="Get_Attach">
					#Attachment_Desc#<BR>
				</CFLOOP>
			<CFELSE>
				No Attachments
			</CFIF>
		</TD>
	</TR>	
	</CFOUTPUT>	
	
</TABLE>	




		
		

<!--- <CFDUMP VAR="#URL#"> --->


</body>
</html>
