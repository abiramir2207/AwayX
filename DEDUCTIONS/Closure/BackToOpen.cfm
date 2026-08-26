<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
</head>

<body>

<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="0">
	
<CFIF FORM.FormSubmitted EQ 1>
 	<cfset useLakebaseForAddNotes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_notes")>
	<cfif useLakebaseForAddNotes>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_notes", {
				"deduction_id" = Deduction_ID,
				"dd_note" = "Send back to Open. Reason: #FORM.BackToOpenReason#",
				"dd_note_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
				"dd_note_by" = request.AccessStructure.User_ID,
				"automated_notes" = 1
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForAddNotes = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForAddNotes>
	<CFQUERY NAME="AddNotes" DATASOURCE="#Application.Datasource#">
		INSERT INTO DD_Notes (Deduction_ID,DD_Note,DD_Note_Date,DD_Note_By,Automated_notes)
		VALUES ('#Deduction_ID#','Send back to Open. Reason: #FORM.BackToOpenReason#',getdate(),'#request.AccessStructure.User_ID#',1)
	</CFQUERY>
	</cfif>
	
	<CFQUERY NAME="GetNotesID" DATASOURCE="#Application.Datasource#">
		SELECT DD_Note_ID DD_Notes_ID FROM DD_Notes 
		WHERE Deduction_ID = '#Deduction_ID#' AND DD_Note_By = '#request.AccessStructure.User_ID#' AND
		Deleted = 0 AND 
		DD_Note_Date = (SELECT MAX(DD_Note_Date) FROM DD_Notes WHERE Deduction_ID = '#Deduction_ID#' AND DD_Note_By = '#request.AccessStructure.User_ID#' AND
						Deleted = 0)
	</CFQUERY>
	
	<CFQUERY NAME="UpdateRebill" DATASOURCE="#Application.Datasource#">
		UPDATE 	Deductions
		SET 	DD_Status = CASE WHEN Is_Last_Status_Rebill = 1 THEN 7 ELSE	2 END,
				RFAToOpen_DD_Notes_ID = '#GetNotesID.DD_Notes_ID#',
				DD_Resolution_Code = NULL
		WHERE 	Deduction_ID = '#Deduction_ID#' 
	</CFQUERY>
	<!--- D30009:More issues found with non-trade deduction feature --->	
	<cfset NonTrade = CreateObject("component", "components.deduction.nontrade") />
	<cfscript>
		NonTrade.NonTradeOpen(DeductionID =	#Deduction_ID#);
	</cfscript>
	<!--- D30009:More issues found with non-trade deduction feature --->	
	<BR><BR><BR><BR>
	<cfset useLakebaseForCheckRebill = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForCheckRebill>
		<cftry>
			<cfset CheckRebill = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"deduction_id" = "eq.#Deduction_ID#"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForCheckRebill = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForCheckRebill>
	<CFQUERY NAME="CheckRebill" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Deductions WHERE Deduction_ID = '#Deduction_ID#' 
	</CFQUERY>
	</cfif>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">This Deduction has been set as a <CFIF CheckRebill.Is_Last_Status_Rebill EQ 1>Rebill<CFELSE>regular Open Deduction</CFIF>.</FONT></B></TD>
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
	<FORM NAME="RFAToOpen" ACTION="BackToOpen.cfm" METHOD="POST">
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Deduction_ID" VALUE="#deduction_ID#">
	</CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="FormSubmitted" VALUE="0">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><BR><BR><B><FONT COLOR="Navy" SIZE="2">DisAgree</FONT></B><HR COLOR="Orange"><BR><BR></TD>
		</TR>
		<TR>
			<TD><B>Reason:</B></TD>		
		</TR>
		<TR>
			<TD><TEXTAREA NAME="BackToOpenReason" maxlength="225" COLS="80" ROWS="4"></TEXTAREA></TD>
		</TR>
		<TR>
			<TD ALIGN="Center"><BR><BR> 
				<CF_button
					button_name	=	"disagree"
					button_caption	=	"Disagree"
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
		var submit_ok = 1;
		//if (document.all.BackToOpenReason.value == "") CHROMEFIX
		if (jQuery("textarea[name=BackToOpenReason]").val() == "")
		{
			alert("Please enter a reason for disagreeing to this deduction.")
			submit_ok = 0;
			return;
		}
		if (submit_ok == 1)
		{
				document.all.FormSubmitted.value=1;
				document.all.RFAToOpen.submit()
				disableButton("disagree_table", true, false);
		}	
	}
	</SCRIPT>
</CFIF>
</body>
</html>
