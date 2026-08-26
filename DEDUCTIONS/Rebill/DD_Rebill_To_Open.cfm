<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="0">
	
<CFIF FORM.FormSubmitted EQ 1>
 	
	<cfset useLakebaseForRebillInsert = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill_status")>
	<cfif useLakebaseForRebillInsert>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_rebill_status", {
				"deduction_id" = Deduction_ID,
				"is_rebilled" = 0,
				"transferred_reason" = FORM.DD_BackToOpen_Reason,
				"transferred_by" = request.AccessStructure.User_ID
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForRebillInsert = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForRebillInsert>
	<CFQUERY NAME="RebillInsert" DATASOURCE="#Application.Datasource#">
		INSERT INTO 
		
		DD_Rebill_Status	(	Deduction_ID,
								Is_Rebilled,
								Transferred_Reason,								
								Transferred_By			)
								
		VALUES				(	'#Deduction_ID#',
								0,
								'#FORM.DD_BackToOpen_Reason#',
								'#request.AccessStructure.User_ID#'	)		
	</CFQUERY>
	</cfif>
	
	<cfset useLakebaseForUpdateStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUpdateStatus>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{ "is_last_status_rebill" = 0, "dd_status" = 2 }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateStatus = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateStatus>
	<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
		UPDATE 	Deductions
		SET 	Is_Last_Status_Rebill = 0,
				DD_Status = 2			
		WHERE 	Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
	</cfif>
	<BR><BR><BR><BR>
	
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">This Deduction status has been changed to Open.</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function relocateThis()
	{
		window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#FORM.Deduction_ID#</CFOUTPUT>"
	}
	window.setTimeout('relocateThis()', 2000);	
	</SCRIPT>

<CFELSE>
	<FORM NAME="DDBackToOpen" ACTION="DD_Rebill_To_Open.cfm" METHOD="POST">
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Deduction_ID" VALUE="#deduction_ID#">
	</CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="FormSubmitted" VALUE="0">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><BR><BR><B><FONT COLOR="Navy" SIZE="2">Send Back To Open</FONT></B><HR COLOR="Orange"><BR><BR></TD>
		</TR>
		<TR>
			<TD><B>Reason for sending back to Open:</B></TD>		
		</TR>
		<TR>
			<TD><TEXTAREA NAME="DD_BackToOpen_Reason" COLS="80" ROWS="4" onPaste="javaScript: return textareaChecklength('1000', this);"  onkeyPress="javaScript: return textareaChecklength('1000', this);"></TEXTAREA></TD>
		</TR>
		<TR>
			<TD ALIGN="Center"><BR><BR> 
				<CF_button
					button_name	=	""
					button_caption	=	"Back to Open"
					button_action	=	"validation()"
					button_type	=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight	=	"bold"
								><BR><BR>				
			</TD>
		</TR>
	</TABLE>
	</FORM>
	
	<SCRIPT language="JavaScript">
	function validation()
	{
		if (document.DDBackToOpen.DD_BackToOpen_Reason.value == "")
		{
			alert("Please enter the Reason for sending back to Open.")
			document.DDBackToOpen.DD_BackToOpen_Reason.focus()
		}
		else
		{
			if(confirm("Press OK to send this deduction to Open."))
			{
				document.all.FormSubmitted.value=1;
				document.all.DDBackToOpen.submit()
			}
		}
	}
	</SCRIPT>
</CFIF>
</body>
</html>
