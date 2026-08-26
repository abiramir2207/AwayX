<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="0">

<!--- Dev Note: Clay 9131: Allow Credit Write-Off (labels to match deduction type) --->
<CFPARAM NAME="Deduction_Label" Default="Deduction" />

<!---Gets data about deduction--->
<cfinclude template="/deductions/sql_Deduction_Info.cfm">

<CFIF Deduction_Info.Is_Credit EQ 1>
	<cfset Deduction_Label = "Credit" />
</CFIF>
	
<CFIF FORM.FormSubmitted EQ 1>
 	
	<cfset useLakebaseForUpdateRebill = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUpdateRebill>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{
					"is_write_off" = 0,
					"write_off_by" = javaCast("null", ""),
					"write_off_date" = javaCast("null", ""),
					"write_off_toopen_reason" = FORM.DD_WFToOpen_Reason
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
		SET 	Is_Write_Off = 0,
				Write_Off_By = NULL,
				Write_Off_Date = NULL,
				Write_Off_ToOpen_Reason = '#FORM.DD_WFToOpen_Reason#'

		WHERE 	Deduction_ID = '#Deduction_ID#' 
	</CFQUERY>
	</cfif>
	<BR><BR><BR><BR>
	
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">This <cfoutput>#deduction_label#</cfoutput> has been set as a regular Open <cfoutput>#deduction_label#</cfoutput>.</FONT></B></TD>
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
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<FORM NAME="WFToOpen" ACTION="DD_Write_Off_To_Open.cfm" METHOD="POST">
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Deduction_ID" VALUE="#deduction_ID#">
	</CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="FormSubmitted" VALUE="0">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><BR><BR><B><FONT COLOR="Navy" SIZE="2"><cfoutput>#stDeductionLabels["Write Off"]# To Open</cfoutput></FONT></B><HR COLOR="Orange"><BR><BR></TD>
		</TR>
		<TR>
			<TD><B>Reason:</B></TD>		
		</TR>
		<TR>
			<TD><TEXTAREA NAME="DD_WFToOpen_Reason" COLS="80" ROWS="4" onPaste="javaScript: return textareaChecklength('250', this);"  onkeyPress="javaScript: return textareaChecklength('250', this);"></TEXTAREA></TD>
		</TR>
		<TR>
			<TD ALIGN="Center"><BR><BR> 
				<CF_button
					button_name	=	""
					button_caption	=	"Back To Open"
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
		if(confirm("Press OK to Open this <cfoutput>#lcase(deduction_label)#</cfoutput>."))
		{
			document.all.FormSubmitted.value=1;
			document.all.WFToOpen.submit()
		}		
	}
	</SCRIPT>
</CFIF>
</body>
</html>
