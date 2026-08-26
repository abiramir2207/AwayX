<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body onLoad="document.all.DD_Rebill_Reason.focus();">
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="0">
	
<CFIF FORM.FormSubmitted EQ 1>
 	
	<cfset useLakebaseForRebillInsert = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill_status")>
	<cfif useLakebaseForRebillInsert>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_rebill_status", {
				"deduction_id" = Deduction_ID,
				"is_rebilled" = 1,
				"transferred_reason" = FORM.DD_Rebill_Reason,
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
								1,
								'#FORM.DD_Rebill_Reason#',
								'#request.AccessStructure.User_ID#'	)		
	</CFQUERY>
	</cfif>
	
	<cfset useLakebaseForUpdateRebill = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUpdateRebill>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{
					"is_last_status_rebill" = 1,
					"rebill_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"dd_status" = 7
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateRebill = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateRebill>
	<CFQUERY NAME="UpdateRebill" DATASOURCE="#Application.Datasource#">
		UPDATE 	Deductions
		SET 	Is_Last_Status_Rebill = 1,
				rebill_date = getdate(),
				DD_Status = 7			
		WHERE 	Deduction_ID = '#Deduction_ID#' 
	</CFQUERY>
	</cfif>
	<BR><BR><BR><BR>
	
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">This Deduction status has been changed to rebill.</FONT></B></TD>
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
	<FORM NAME="RebillDD" ACTION="DD_Open_To_Rebill.cfm" METHOD="POST">
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Deduction_ID" VALUE="#deduction_ID#">
	</CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="FormSubmitted" VALUE="0">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><BR><BR><B><FONT COLOR="Navy" SIZE="2">Rebill Deduction</FONT></B><HR COLOR="Orange"><BR><BR></TD>
		</TR>
		<TR>
			<TD><B>Rebill Reason:</B></TD>		
		</TR>
		<TR>
			<TD><TEXTAREA NAME="DD_Rebill_Reason" COLS="80" ROWS="4" onPaste="javaScript: return textareaChecklength('1000', this);"  onkeyPress="javaScript: return textareaChecklength('1000', this);"></TEXTAREA></TD>
		</TR>
		<TR>
			<TD ALIGN="Center"><BR><BR> 
				<CF_button
					button_name	=	""
					button_caption	=	"Rebill"
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
		if (document.RebillDD.DD_Rebill_Reason.value == "")
		{
			alert("Please enter the Rebilling Reason.")
			document.RebillDD.DD_Rebill_Reason.focus()
		}
		else
		{
				document.all.FormSubmitted.value=1;
				document.all.RebillDD.submit()
		}
	}
	</SCRIPT>
</CFIF>
</body>
</html>
