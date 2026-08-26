<cfinclude template="/deductions/sql_Deduction_Info.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

	<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="0">
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<!---User profile--->
	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
	<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
	<cfif useLakebaseForDeductionsProfilesSettings>
		<cftry>
			<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions_profiles_settings", {
					"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDeductionsProfilesSettings = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDeductionsProfilesSettings>
	<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
		SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
	</cfquery>
	</cfif>

	<!--- Dev Note: Clay 9131: Allow Credit Write-Off (labels to match deduction type) --->
	<CFPARAM NAME="Deduction_Label" Default="Deduction" />
	<CFIF Deduction_Info.Is_Credit EQ 1>
		<cfset Deduction_Label = "Credit" />
	</CFIF>
		
	<CFIF FORM.FormSubmitted EQ 1>
	 	
		<!------*********************************************************************************
		D16948: JRS - Deduction record was sent in GL Credit interface file
		check if this deduction can be flagged as write off - START
		It is possible that someone has already flagged it as write-off, associated to a billback or deduction
		*********************************************************************************------>
		<cfset DeductionLinkManager = CreateObject("component", "components.deduction.DeductionLinkManager").init() />
		<cfset bWriteOffAvailable = DeductionLinkManager.isWriteOffAvailable(deductionId = Deduction_ID) />
		
		<cfif bWriteOffAvailable eq 0>
		
		
			<BR><BR><BR><BR>
			
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD>
						<B><FONT COLOR="Red" SIZE="3">
							<cfoutput>You cannot #LCase(stDeductionLabels["Write Off"])# this #Deduction_Label# at this point.
							<br>It is possible that this #Deduction_Label# is already flagged as #LCase(stDeductionLabels["Write Off"])# or associated to a billback<CFIF Appsettings.getDDAllowNegativeAmountCredits()>/<CFIF Deduction_Info.Is_Credit EQ 1>deduction<cfelse>credit</cfif></CFIF>.
							</cfoutput> 
						</FONT></B>
					
					</TD>
				</TR>
			</TABLE>
			<SCRIPT language="JavaScript">
			function relocateThis()
			{
				window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#FORM.Deduction_ID#</CFOUTPUT>"
			}
			window.setTimeout('relocateThis()', 3000);	
			</SCRIPT>
			
			<cfabort>
		
		</cfif>
		<!------*********************************************************************************
		check if this deduction can be flagged as write off - END
		*********************************************************************************------>
		
		<cfset useLakebaseForUpdateRebill = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUpdateRebill>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#Deduction_ID#" },
					{
						"is_write_off" = 1,
						"write_off_by" = request.AccessStructure.User_ID,
						"write_off_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
						"write_off_reason" = FORM.DD_Write_Off_Reason
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
			SET 	Is_Write_Off = 1,
					Write_Off_By = '#request.AccessStructure.User_ID#',
					Write_Off_Date = getdate(),
					Write_Off_Reason = '#FORM.DD_Write_Off_Reason#'

			WHERE 	Deduction_ID = '#Deduction_ID#' 
		</CFQUERY>
		</cfif>
		<BR><BR><BR><BR>
		
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD><B><FONT COLOR="Red" SIZE="3"><cfoutput>Approve this #Deduction_Label# to Complete the #stDeductionLabels["Write Off"]# Process.</cfoutput></FONT></B></TD>
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
		<FORM NAME="Write_Off_DD" ACTION="DD_Write_Off.cfm" METHOD="POST">
			<CFOUTPUT>
				<INPUT TYPE="hidden" NAME="Deduction_ID" VALUE="#deduction_ID#">
			
			<INPUT TYPE="Hidden" NAME="FormSubmitted" VALUE="0">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD><BR><BR><B><FONT COLOR="Navy" SIZE="2"><cfoutput>#stDeductionLabels["Write Off"]# This #Deduction_Label#</cfoutput></FONT></B><HR COLOR="Orange"><BR><BR></TD>
				</TR>
				<TR>
					<TD><B><cfoutput>#stDeductionLabels["Write Off"]# Reason:</cfoutput></B></TD>		
				</TR>
				<TR>
					<TD><TEXTAREA NAME="DD_Write_Off_Reason" COLS="80" ROWS="4" onPaste="javaScript: return textareaChecklength('250', this);"  onkeyPress="javaScript: return textareaChecklength('250', this);"></TEXTAREA></TD>
				</TR>
				<TR>
					<TD ALIGN="Center"><BR><BR>
						<cfif (DeductionsProfilesSettings.DD_Match_Central_Write_Off_Amount EQ '*') OR (DeductionsProfilesSettings.DD_Match_Central_Write_Off_Amount GTE Deduction_Info.DD_Amount) >
							<CF_button
								button_name	=	""
								button_caption	=	"#stDeductionLabels['Write Off']#"
								button_action	=	"validation()"
								button_type		=	"javascript_link"
								button_width	=	"100"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold">
							<BR><BR>
						<cfelse>
							<font color="red">* This #Deduction_Label# exceeds your threshold for #stDeductionLabels['Write Off']# </font>
							<BR><BR>
							<strong><font color="red">[ </font><font color="grey">#stDeductionLabels['Write Off']#</font><font color="red"> ]</font></strong>
							<BR><BR>
						</cfif>
					</TD>
				</TR>
			</TABLE>
			</CFOUTPUT>
		</FORM>

		<SCRIPT language="JavaScript">
			function validation()
			{		
					document.all.FormSubmitted.value=1;
					document.all.Write_Off_DD.submit();
			}
		</SCRIPT>
	</CFIF>
</body>
</html>
