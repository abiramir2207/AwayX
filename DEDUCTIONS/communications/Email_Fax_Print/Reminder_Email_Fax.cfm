<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
  <script type="text/javascript" src="/script/javascript/string_functions.min.js"></script>  <!--25704-->
</head>

<body>
<!--- <CFDUMP VAR="#URL#"> --->


<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="0">
<CFPARAM NAME="URL.FROM" DEFAULT="">

<CFOUTPUT>
<CFIF FORM.Form_Submitted EQ 0>
	<CFIF URL.From EQ "Email">
		<CFSET Disp = "Send Email">
		<CFSET Func = "confirmCompletionEmail()">
	<CFELSEIF URL.From EQ "Fax">
		<CFSET Disp = "Send Fax">
		<CFSET Func = "confirmCompletion()">
	</CFIF>
	<FORM NAME="Comm_Options" ACTION="Reminder_Email_Fax.cfm?DD_Reminder_ID=#URL.DD_Reminder_ID#&Deduction_ID=#URL.Deduction_ID#&From=#URL.From#" METHOD="Post">
	<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
		<TR>
			<TD><CFINCLUDE TEMPLATE="/DEDUCTIONS/communications/Email_Fax_Print/Email_Body.cfm"></TD>
		</TR>
		<TR>
			<TD ALIGN="Center"><BR>
				<CF_button
					button_name	=	""
					button_caption	=	"#Disp#"
					button_action	=	"#Func#"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight	=	"bold"
								>
			</TD>
		</TR>
	</TABLE>
	</FORM>
<CFELSE>
	<cfset useLakebaseForGetDedDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForGetDedDetails>
		<cftry>
			<cfset Get_Ded_Details = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", { "select" = "dd_dedid,sp_number", "deduction_id" = "eq.#URL.Deduction_ID#" })
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetDedDetails = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetDedDetails>
		<CFQUERY NAME="Get_Ded_Details" DATASOURCE="#Application.Datasource#">
			SELECT DD_DedID,SP_Number
			FROM Deductions
			WHERE Deduction_ID = '#URL.Deduction_ID#'
		</CFQUERY>
	</cfif>
	<CFIF Get_Ded_Details.Sp_Number EQ "">
		<CFSET Get_Ded_Details.Sp_Number = "000">
	</CFIF>

	<cfset useLakebaseForGetReminder = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminders")>
	<cfif useLakebaseForGetReminder>
		<cftry>
			<cfset GetReminder = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_reminders", { "select" = "dd_reminder,dd_reminder_date", "dd_reminder_id" = "eq.#URL.DD_Reminder_ID#" })
			)>
			<cfcatch type="any">
				<cfset useLakebaseForGetReminder = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetReminder>
		<CFQUERY NAME="GetReminder" DATASOURCE="#Application.Datasource#">
			SELECT 	DD_Reminder,
					DD_Reminder_Date
			FROM 	DD_Reminders
			WHERE 	DD_Reminder_ID = '#URL.DD_Reminder_ID#'
		</CFQUERY>
	</cfif>
	
	<CFIF LEN(TRIM(GetReminder.DD_Reminder)) GT 25>
		<CFSET GetReminder.DD_Reminder = "#left(GetReminder.DD_Reminder, 23)#...">
	</CFIF>
	
	<CFSET FromReminderEFC = 1>
	<!--- <CFDUMP VAR="#URL#">
	<CFDUMP VAR="#FORM#"> --->

	<CFSAVECONTENT VARIABLE="DD_Reminders_Cont">
		<CFINCLUDE TEMPLATE="/Deductions/Reminders/Reminder_Details.cfm">
	</CFSAVECONTENT>
	
	<CF_Writing_Email_Attachment
			Naming_Format="Deduction_Reminder_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#"				
			Relative_Path="\Temp_Files\Deduction\"
			Output_Content="#DD_Reminders_Cont#"				
			Return_File_Name="fName">		
	
	
	
	<CFIF URL.From EQ "Email">
		<CF_EMAILWRAPPER 
			TO					=	"#FORM.Send_To#"
	        FROM				=	"#request.AccessStructure.User_Email#"
	        SUBJECT				=	"#Form.Sendersubject#"
			TYPE				=	"html" 
			MESSAGETYPE			="1" 
			GENERATEDBY			="3" 
			APPAREA				="13" 
			USERID				="#request.AccessStructure.user_id#"
			APP_AREA_IDENTIFIER	="#URL.Deduction_ID#" >		
			
			<TABLE WIDTH="100%">
			<TR VALIGN="top">
			<TD>
			#Form.Message_Body#
			</TD>
			</TR>
			<TR>
				<TD><BR><BR><FONT COLOR="Navy"><B><U>Attachment Details:</U></B></FONT></TD>
			</TR>
			<TR>
				<TD><B>Deduction_Reminder_#Get_Ded_Details.DD_DedID#_#Get_Ded_Details.Sp_Number#:</B></TD>
			</TR>
			<TR>
				<TD>This attachment is a reminder from the deduction <B>#Get_Ded_Details.DD_DedID# - #Get_Ded_Details.Sp_Number#</B>.</TD>
			</TR>
			</TABLE>
			<cf_EmailWrapperParam file = "#fName#" store="yes" desc="Reminder Details (#DateFormat(GetReminder.DD_Reminder_Date,"mm/dd/yyyy")# - #GetReminder.DD_Reminder#)"> 			
		</CF_EMAILWRAPPER>
	<CFELSEIF URL.From EQ "Fax">
		<CFSAVECONTENT VARIABLE = "Cover_sheet"> 
			<TABLE CELLPADDING="5" CELLSPACING="15" BORDER="0"  width="95%">
			 <TR>
			  <TD NOWRAP ALIGN="Right" COLSPAN="4">
			  <b>
			  <font face="Arial" size="5">#application.returned_customer_setting.Company_Name#</font></b>  
			  </TD>
			 </TR>
			 <TR>
			  <TD COLSPAN="4" style="border-bottom-style: solid; border-bottom-width: 4" valign="top"></TD>
			 </TR>
			 <TR>
			  <TD STYLE="FONT:72px;" COLSPAN="4" valign="top"><font face="Arial"><b>
			        <br>
			        F a x<br>
			&nbsp;</b></font></TD>
			 </TR>
			 <TR>
			  <TD width="75" rowspan="6" valign="top">&nbsp;</TD> 
			  <TD ROWSPAN="6" valign="top">&nbsp;</TD>
			  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Date:</font></B></TD>
			  <TD WIDTH="100%" STYLE="FONT:16px;" valign="top">
			        <font face="Arial">
			        <span style="font-size: 13pt">#FORM.SenderDate# </span></font></TD>  
			 </TR>
			 <TR>
			  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">From:</font></B></TD>
			  <TD STYLE="FONT:16px;" width="100%" valign="top">
			        <font face="Arial">
			        <span style="font-size: 13pt">#FORM.Senderaddress#</span></font></TD>
			 </TR>
			 <TR>
			 	<TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Deduction:</font></B></TD>
				 <TD STYLE="FONT:16px;" width="100%" valign="top">
			        <font face="Arial">
			        <span style="font-size: 13pt">A reminder from #Get_Ded_Details.DD_DedID# - #Get_Ded_Details.SP_Number#</span></font></TD>
			 </TR>
			 <TR>
			  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Subject:</font></B></TD>
			  <TD STYLE="FONT:16px;" width="100%" valign="top">
			        <font face="Arial">
			        <span style="font-size: 13pt">#FORM.Sendersubject#</span></font></TD>
			 </TR>
			 <TR>
			  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Message:</font></B></TD>
			  <TD STYLE="FONT:16px;" width="100%" valign="top">
			        <font face="Arial">
			        <span style="font-size: 13pt">#Form.Message_Body#</span></font></TD>  
			 </TR>
			
			 <TR>
			  <TD VALIGN="top" STYLE="FONT:16px;">&nbsp;</TD>
			  <TD STYLE="FONT:16px;" width="100%" valign="top"><br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			        <br>
			
			&nbsp;</TD>  
			 </TR>
			</TABLE> 
			<CFINCLUDE TEMPLATE="/Common_Files/Email_Footer.cfm">
		</CFSAVECONTENT>
		<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">
		<CFSET filename_email	=	"#datetimestamp#_#gettickcount()#">
		<CFSET CS_HTML_File_Path="\Temp_Files\deduction\CS_#filename_email#.html">


		<CFFILE action = "write"
				file="#Application.Doc_Path##CS_HTML_FILE_Path#"
				output="#Cover_sheet#">    		
		
		<CFSET Fax_Numbers_List="">
		<CFLOOP INDEX="Item" LIST="#Form.Fax_Number#" DELIMITERS=";">
			<CFSET Fax_Numbers_List=item&"~FR="&AccessStructure.Name_First&"_"&AccessStructure.Name_Last&"@Faxmail.com"&";"&Fax_Numbers_List>
		</CFLOOP>
		
		<CF_EMAILWRAPPER 
			TO					="#Fax_Numbers_List#"
	        FROM				="chainlink@awayx.com" 
			SUBJECT				="#Form.SenderSubject#"
			MESSAGETYPE			="2"
			GENERATEDBY			="3" 
			APPAREA				="13" 
			USERID				="#request.AccessStructure.user_id#"
			APP_AREA_IDENTIFIER	="#Deduction_ID#">
			<CF_EMAILWRAPPERPARAM FILE="#Application.Doc_Path##CS_HTML_FILE_Path#" store="yes" Desc = "Cover Sheet">
			<CF_EMAILWRAPPERPARAM FILE = "#fName#" store="yes" desc="Reminder Details (#URL.DD_Reminder_ID#)"> 			
		</CF_EMAILWRAPPER>  		
	</CFIF>
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD>
				<FONT COLOR="Red" SIZE="3"><B>
				Please wait while sending <CFIF URL.FROM EQ "Email">Email<CFELSE>Fax</CFIF>...
				</B></FONT>
			</TD>
		</TR>
	</TABLE>
	
	<SCRIPT language="JavaScript">
	function Closewind()
	{
		window.close()
	}
	window.setTimeout('Closewind()', 2000);
	</SCRIPT>
</CFIF>
</CFOUTPUT>


<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/script/javascript/string_validations.js"></SCRIPT>

<SCRIPT language="JavaScript">
var ErrorCount = 0;
function confirmCompletionEmail()
{

	var ErrorCount = 0;

	if(document.all.SenderAddress.value.length == 0)	
	{ 
		ErrorCount++;
		queueMessage("You must enter your email address", document.all.error_SenderAddress);
	}	
	else
	{			
		clearQueue(document.all.error_SenderAddress);
	}
	
	if(document.all.SenderSubject.value.length == 0)
	{			
		ErrorCount++;
		queueMessage("You must enter a subject", document.all.error_SenderSubject);
	}
	else
	{			
		clearQueue(document.all.error_SenderSubject);
	}	
	
	//var recipients = combineEmails(document.all.Send_To.value, document.all.Send_To_2.value);
	//ChromeFix
	<cfif application.appSettingsGet.External_Contacts_Option eq 0>
		var recipients_2 = jQuery('input[name=Send_To_2]').val();
    <cfelse>
	    var recipients_2 = jQuery('textarea[name=Send_To_2]').val();
	</cfif>
	var recipients = combineEmails(jQuery("textarea[name=Send_To]").val(),recipients_2); //ChromeFix
	if ( recipients.length == 0 )   /*25704*/
	{
		ErrorCount++;
		queueMessage("You must enter at least one email address", document.all.error_Send_To);
	}
	else
	{
		clearQueue(document.all.error_Send_To);
	}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
  		// hide email recipient input
  		//document.all.Send_To.style.visibility = 'hidden';
	 	// combine int email recipients & ext email recipients
	 	// document.all.Send_To.value = recipients;//ChromeFix
		jQuery("textarea[name=Send_To]").hide().val(recipients);
		//Email.submit()
		document.Comm_Options.Form_Submitted.value = 1;
		document.Comm_Options.submit()
		
	}
	else 
	{
		showMessageWindow()
	}	
}


function confirmCompletion()
{

	var ErrorCount = 0;

		if(document.all.SenderAddress.value.length == 0)	
		{ 
			ErrorCount++;
			queueMessage("You must enter your email address", document.all.error_SenderAddress);
		}
		else
		{			
			clearQueue(document.all.error_SenderAddress);
		}		
			
		
		 if(document.all.SenderSubject.value.length == 0)
		{			
			ErrorCount++;
			queueMessage("You must enter a subject", document.all.error_SenderSubject);
		}
		else
		{			
			clearQueue(document.all.error_SenderSubject);
		}	
		if(document.all.Fax_Number.value.length == 0)
		{
			ErrorCount++;
			queueMessage("You must enter at least one fax number", document.all.error_Fax_Number);
		}
		else
		{
			clearQueue(document.all.error_Fax_Number);
		}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
		//Fax.submit()
	document.Comm_Options.Form_Submitted.value = 1;
	document.Comm_Options.submit()
		
	}
	else 
	{
		showMessageWindow()
	}	
}


</SCRIPT>
<CF_MessageWindow>
	


</body>
</html>
