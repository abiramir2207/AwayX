<cfset PAGE_TITLE="Email #Application.PlannerPrgLabel# #Application.PlannerLabel#">

<!DOCTYPE HTML PUBLIC "-//W3C//Dtd HTML 4.0 transitional//EN">

<HTML>
<HEAD>

<TITLE><cfoutput>#PAGE_TITLE#</cfoutput></TITLE>

<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<BLOCKQUOTE>

<BR>
	<BR>
    <H4 STYLE="Color: Red;">
		The following Email has been sent...<BR>
		<BR>
    </H4>
	<cfset HTML_File_Path = Form.HTML_File_Path>
    <cfset Display_None_Attachments = 1>

<cfsavecontent variable="Body_Content">
<STYLE TYPE="text/css">
	td
	{
		font-family:	sans-serif;
		font-size:		10px;
	}
</STYLE>

<cfoutput>
	<table cellpadding="1" cellspacing="5" border="0">
		<tr>
			<td valign="top"><B>Date:</B></td>
			<td rowspan="100%" bgcolor="Orange"></td>
			<td>#Form.SenderDate#</td>
		</tr>
		<tr>
			<td valign="top"><B>From:</B></td>
			<td>#Form.Senderaddress#</td>
		</tr>

		<tr>
			<td valign="top"><B>Message:</B></td>
			<td>#Form.Message_Body#</td>
		</tr>
		<tr>
			<td valign="top"><B>Subject:</B></td>
			<td>#Form.Sendersubject#</td>
		</tr>
		<tr>
			<td valign="top">
				<B>#Application.PlannerPrgLabel#</B>
			</td>
			<td>
				<cfif NOT FileExists("#HTML_File_Path#")>
					<cfinclude template="#HTML_File_Path#">
				</cfif>
			</td>
		</tr>
		<tr>
			<td valign="top"></td>
			<td></td>
		</tr>
	</table>
</cfoutput>
</cfsavecontent>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfoutput>#Body_Content#</cfoutput>

<CF_Naming_Email_Attachments
	Title="Planner_Program"
	Relative_Src_File_Path="Temp_Files"
	Relative_Dest_Dir_Path ="Temp_Files"
	Return_Variable_Name="this.attach">

    <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
    <!--- Send email..................																	 --->
    <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfoutput>
<cf_emailwrapper
	TO			=	"#Form.Recipient_Email_Address#"
	FROM		=	"#request.AccessStructure.User_Email#"
	SUBJECT		=	"#Form.Sendersubject#"
	TYPE		=	"html"
	MESSAGETYPE = 	"1"
	generatedBy	=	"3"
	appArea		=	"3"
	userid		=	"#request.AccessStructure.user_id#">

		<table width="100%">
			<tr valign="top">
				<td>
					#Form.Message_Body#
				</td>
			</tr>
		</table>
		<!--- The cfmailparam IS the file being attached --->

		<cf_emailwrapperparam file = "#this.attach#">

</cf_emailwrapper>
</cfoutput>

</BLOCKQUOTE>
</BODY>
</HTML>
