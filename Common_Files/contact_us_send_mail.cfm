<CFSET PAGE_TITLE="Contact us...">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE><BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save email message to database																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset useLakebaseForSaveEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("email_messages")>
<cfif useLakebaseForSaveEmail>
	<cftry>
		<cfset application.oLakebase.insertRow("email_messages", {
			"email_user_id" = request.AccessStructure.User_ID,
			"email_date_sent" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
			"email_address_from" = Form.From,
			"email_subject" = Form.Subject,
			"email_message" = Form.Message,
			"deleted" = false
		})>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForSaveEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaveEmail>
	<CFQUERY NAME="Save_Email" datasource="#application.datasource#">
	INSERT INTO 	email_messages
					(
					email_user_id,
					email_date_sent,
					email_address_from,
					email_subject,
					email_message
					)
	VALUES
					(
					'#request.AccessStructure.User_ID#',
					#createodbcdatetime(now())#,
					'#Form.From#',
					'#Form.Subject#',
					'#Form.Message#'
					)
	</CFQUERY>
</cfif>

<CFQUERY NAME="GetUserDetails" DATASOURCE="#Application.Datasource#">
	SELECT * FROM _Users WHERE User_ID = '#request.AccessStructure.User_ID#' AND Deleted = 0
</CFQUERY>
 	<!--- 
				Dev Notes: D24468/Anand Rao/17-Aug-10
				URL on email notifications
	--->  
  <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
  
<CFSAVECONTENT VARIABLE="mail_content">
	<CFOUTPUT>
	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="5">
		<TR>
			<TD VALIGN="BOTTOM" ALIGN="RIGHT"><B>Company Name</B></TD>
			<TD WIDTH="400" HEIGHT="20" BGCOLOR="WhiteSmoke">#application.returned_customer_setting.Company_Name# ( <A Href="#siteURL#"><B>#siteURL#</B></A> )</TD>
		</TR>
		<TR>
			<TD VALIGN="BOTTOM" ALIGN="RIGHT"><B>Name</B></TD>
			<TD WIDTH="400" HEIGHT="20" BGCOLOR="WhiteSmoke">#GetUserDetails.Name_First# #GetUserDetails.Name_Last#</TD>
		</TR>		
		<TR>
			<TD VALIGN="BOTTOM" ALIGN="RIGHT"><B>Title</B></TD>
			<TD WIDTH="400" HEIGHT="20" BGCOLOR="WhiteSmoke">#GetUserDetails.Title#</TD>
		</TR>
		<TR>
			<TD VALIGN="Top" ALIGN="RIGHT"><B>Address</B></TD>
			<TD WIDTH="400" HEIGHT="20" BGCOLOR="WhiteSmoke">#GetUserDetails.Work_Address_1# <CFIF GetUserDetails.Work_Address_2 NEQ ""><BR>#GetUserDetails.Work_Address_2#</CFIF><BR>#GetUserDetails.Work_City#,#GetUserDetails.Work_State# - #GetUserDetails.Work_Zip#</TD>
		</TR>
	 	<TR>
			<TD VALIGN="BOTTOM" ALIGN="RIGHT"><B>From</B></TD>
			<TD WIDTH="400" HEIGHT="20" BGCOLOR="WhiteSmoke">#Form.From#</TD>
	  	</TR>
	  	<TR>
			<TD VALIGN="BOTTOM" ALIGN="RIGHT"><B>Subject</B></TD>
			<TD WIDTH="400" HEIGHT="20" BGCOLOR="WhiteSmoke">#Form.Subject#</TD>
	  	</TR>
	  	<TR>
			<TD VALIGN="TOP" ALIGN="RIGHT"><B>Message</B></TD>
			<TD VALIGN="TOP" WIDTH="400" HEIGHT="150" BGCOLOR="WhiteSmoke">#Form.Message#</TD>
	  	</TR>
	</TABLE>
	</CFOUTPUT>
</CFSAVECONTENT>

<CFSAVECONTENT VARIABLE="Confirmation">
<CFOUTPUT>
	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="5">
		<TR>
			<TD VALIGN="BOTTOM" ALIGN="RIGHT"><B>From</B></TD>
			<TD WIDTH="400" HEIGHT="20" BGCOLOR="WhiteSmoke">#Form.From#</TD>
	  	</TR>
	  	<TR>
			<TD VALIGN="BOTTOM" ALIGN="RIGHT"><B>Subject</B></TD>
			<TD WIDTH="400" HEIGHT="20" BGCOLOR="WhiteSmoke">#Form.Subject#</TD>
	  	</TR>
	  	<TR>
			<TD VALIGN="TOP" ALIGN="RIGHT"><B>Message</B></TD>
			<TD VALIGN="TOP" WIDTH="400" HEIGHT="150" BGCOLOR="WhiteSmoke">#Form.Message#</TD>
	  	</TR>
	</TABLE>
</CFOUTPUT>
</CFSAVECONTENT>
<BR><BR>
<BLOCKQUOTE>

<!--- <H4>You have sent us a message with the following information:</H4> --->
<BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Loops through all the form variables and displays both the name and the content of each		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<FIELDSET STYLE="padding:8px; width: 1%; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Thanks for your feedback</LEGEND>


<CFOUTPUT>#Confirmation#</CFOUTPUT>
</FIELDSET>


<BR><BR>

We thank you for your feedback. We'll contact you in case we need more information.<BR>
<BR>

<FONT SIZE="2">
<B><FONT COLOR="#FF0000">[</FONT>&nbsp;&nbsp;<a href="/Manufacturers/home.cfm">home</a>&nbsp;&nbsp;<FONT COLOR="#FF0000">]</FONT></B>
</FONT>


</BLOCKQUOTE>

<!--- <CFMAIL TO="everyone@awayx.com"
	FROM="#Form.From#"
	SUBJECT="#Form.Subject#"	
	TYPE="HTML">
			#mail_content#
</CFMAIL> --->
<cfoutput>
<CF_EMAILWRAPPER 
	TO="feedback@#application.CompanyEmailSuffix#"
	FROM="#Form.From#"
	SUBJECT="#Form.Subject#"	
	TYPE="HTML" 
	messagetype="1" 
	generatedby="3" 
	apparea="5" 
	userid="#request.AccessStructure.user_id#">
			#mail_content#
</CF_EMAILWRAPPER>
</cfoutput>



</BLOCKQUOTE></BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
