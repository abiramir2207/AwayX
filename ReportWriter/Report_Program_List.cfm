<cfparam name="EffectiveDate" default="">

<cfsetting enablecfoutputonly=true>
<cfoutput><table cellpadding="0" cellspacing="2" style="width:100%">	</cfoutput>
	<cfoutput><tr valign="top" bgcolor="F2F2F2"></cfoutput>
		<cfset ListPosition = 0>
			<cfloop list="#FORM.report_program_id_list#" index="i">
				<cfset ListPosition = ListPosition + 1>
				<cfquery name="getProgramNumber" datasource="#application.datasource#">
				 SELECT contract_number,revision_version,contract_title
				 FROM Contract_Main
				 WHERE Contract_Main_ID = '#i#'
				</cfquery>

				<cfset contract_number = getProgramNumber.contract_number>
				<cfset revision_version = Right("000#getProgramNumber.revision_version#", 3)>
				<cfset contract_title = getProgramNumber.contract_title>
				<!--- Program display with the checkboxes --->
					<cfoutput><td width="1%"></cfoutput>
						<cfif form.EffectiveDate eq "">
								<cfoutput><input type="checkbox" name="report_program_id_list" value="#i#" checked></cfoutput>
						<cfelse>
						<cfoutput>&nbsp;</cfoutput>
						</cfif>
					<cfoutput></td></cfoutput>
				<!--- Just the program display, as no editing is allowed. --->
					<cfoutput><TD WIDTH="33%" VALIGN="top"></cfoutput>
						<cfoutput><FONT SIZE="1"></cfoutput>
						<cfoutput>#contract_number#-#revision_version#<br /></cfoutput>
						<cfoutput>#contract_title#</cfoutput>
						<cfoutput></font></cfoutput>
					<cfoutput></TD></cfoutput>
					<cfoutput><CFIF ListPosition MOD 3><CFELSE></tr><tr bgcolor="F2F2F2" valign="top"></CFIF></cfoutput>
			</cfloop>
	<cfoutput></tr></cfoutput>
<cfoutput></table></cfoutput>
<cfsetting enablecfoutputonly=false>
