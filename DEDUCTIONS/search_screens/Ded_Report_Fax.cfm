<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Send Fax</title>
</head>

<body>
<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">
<CFIF FORM.Form_Submitted EQ "">
	<CFSET URL.From = "Fax">
	<FORM NAME="Comm_Options" ACTION="Ded_Report_Fax.cfm" METHOD="POST">
		<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
		<CFOUTPUT>
			<INPUT TYPE="Hidden" NAME="FileName" VALUE="#URL.FileName#">
		</CFOUTPUT>
		<CFINCLUDE TEMPLATE="/Deductions/Communications/Email_Fax_Print/Email_Body.cfm">
	</FORM>

	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD>
				<CF_button
					button_name		=	""
					button_caption	=	"send fax"
					button_action	=	"confirmCompletion()"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"		>
			</TD>
		</TR>
	</TABLE>
<CFELSE>
	<CFOUTPUT>
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
					&nbsp;</b></font>
				</TD>
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
			        <span style="font-size: 13pt">Deduction Report</span></font></TD>
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
					&nbsp;
				</TD>  
			 </TR>
			</TABLE> 
			<CFINCLUDE TEMPLATE="/Common_Files/Email_Footer.cfm">
		</CFSAVECONTENT>
		</CFOUTPUT>
		<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">
		<CFSET filename_email	=	"#datetimestamp#_#gettickcount()#">
		<CFSET CS_HTML_File_Path="\Temp_Files\deduction\CS_#filename_email#.html">


		<CFFILE action = "write"
				file="#ApplicationPath##CS_HTML_FILE_Path#"
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
			USERID				="#request.AccessStructure.user_id#"	>
			<CF_EMAILWRAPPERPARAM FILE="#ApplicationPath##CS_HTML_FILE_Path#" store="yes" Desc = "Cover Sheet">
			
			<cf_EmailWrapperParam file = "#FORM.FileName#" store="yes" desc="Deduction Report"> 			
		</CF_EMAILWRAPPER> 
		
		<cfset useLakebaseForSenderName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
		<cfif useLakebaseForSenderName>
			<cftry>
				<cfset SenderName = application.oLakebase.toQuery(
					application.oLakebase.selectRows("_users", {
						"select" = "name_first,name_last",
						"user_id" = "eq.#request.AccessStructure.User_ID#"
					}),
					"name_first,name_last"
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForSenderName = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForSenderName>
		<CFQUERY NAME="SenderName" DATASOURCE="#Application.Datasource#">
		SELECT Name_First, Name_last FROM _Users WHERE User_ID = '#request.AccessStructure.User_ID#'
		</CFQUERY>
		</cfif>
	<BR><BR><BR><BR>
	<CFOUTPUT>
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">Wait While Sending Fax with Deduction Report Attached...</FONT></B></TD>			
		</TR>
		<TR>
			<TD>
				<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">
					<TR>
						<TD><B><FONT COLOR="Navy" SIZE="2">From:</FONT></B></TD>
						<TD><B><FONT COLOR="Navy" SIZE="2">#SenderName.Name_First# #SenderName.Name_last#</FONT></B></TD>
					</TR>
					<TR>
						<TD><B><FONT COLOR="Navy" SIZE="2">Subject:</FONT></B></TD>
						<TD><B><FONT COLOR="Navy" SIZE="2">#FORM.SenderSubject#</FONT></B></TD>
					</TR>
					<TR>
						<TD><B><FONT COLOR="Navy" SIZE="2">Attachment:</FONT></B></TD>
						<TD><B><FONT COLOR="Navy" SIZE="2">Deduction Report</FONT></B></TD>
					</TR>
				</TABLE>
			</TD>
		</TR>
	</TABLE>	
	
	</CFOUTPUT>
	<SCRIPT language="JavaScript">	
		window.setTimeout('window.close()', 3000);
	</SCRIPT> 
</CFIF>
<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>

<SCRIPT language="JavaScript">
// Fax Validations
var ErrorCount = 0;
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
