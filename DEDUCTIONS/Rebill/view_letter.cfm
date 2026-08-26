
<cfset useLakebaseForGetLetterInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill_log")>
<cfif useLakebaseForGetLetterInfo>
	<cftry>
		<cfset GetLetterInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_rebill_log", {
				"dd_rebill_log_id" = "eq.#DD_Rebill_Log_ID#"
			}),
			"html_file_location"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetLetterInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLetterInfo>
<cfquery name="GetLetterInfo" datasource="#application.datasource#">
SELECT * FROM DD_Rebill_Log
WHERE DD_Rebill_Log_ID = '#DD_Rebill_Log_ID#'
</cfquery>
</cfif>

<cfinclude template="#GetLetterInfo.HTML_File_Location#">

<table align="center"><tr>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"NewWindow('#GetLetterInfo.HTML_File_Location#','name','800','600','Yes', 'No')"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Print rebill letter"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>


	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"email"
			button_action	=	"window.location.href='rebill_email_create.cfm?Deduction_ID=#Deduction_ID#&DD_Rebill_Log_ID=#DD_Rebill_Log_ID#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare email contents"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>

<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"fax"
			button_action	=	"window.location.href='rebill_fax_create.cfm?Deduction_ID=#Deduction_ID#&DD_Rebill_Log_ID=#DD_Rebill_Log_ID#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare fax contents"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
 --->
</tr></table>