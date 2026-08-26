<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\email_program_claim_rates.cfm
      Date:     June 15, 2016
      Author:   Milan Mushran
      Purpose:  Emailing claim rates report
----------------------------------------------------------------------------------------------------------------------->
			<!---
			Dev Note:69439 -
			When user wants to email claim rates report and letter in one email.
			Once they have generated claom rates report for one distributor, they can select the same distributor's letter
			from the "view_letters.cfm" file and attach the same distributor's letter as well and then email the claim rates
			report and letter in one email. That is why the"letters" code has been added below as well.
			--->
			<cfset pdf_attachment_file_path = "">
			<cfif ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
				<!---locate the generated letter. --->
				<cfquery name="rsLetters" datasource="#application.datasource#">
				SELECT	PL.Letter_Path
				FROM	Program_Letters PL
				WHERE PL.Program_letters_ID =	<cfqueryparam cfsqltype="cf_sql_integer" value="#letter_ID#">
				</cfquery>

				<cfset pdf_attachment_file_path = replace(rsLetters.Letter_Path, '.htm','.pdf', 'all')>
			</cfif>

			<!--- "16" is claim rates --->
			<cfset apparea = 16>
			<!--- Dev Note:69439/69439: Claim rates report are not saved and so we cannot retreive it using an ID from the DB
			and so "apparea_subidentifier" is 0. --->
			<cfset apparea_subidentifier = 0>
			<cfif pdf_attachment_file_path neq "">
			<!--- "17" is claim rates & letters --->
				<cfset apparea = 17>
				<!--- Program letters are saved and so we can retreive it using an ID from the DB and so "apparea_subidentifier" is the letterID. --->
				<cfset apparea_subidentifier = letter_ID>
			</cfif>

	<cfoutput>
		<cfif len(trim(form.internals)) GT 0>
				<cf_emailwrapper
						to = "#form.internals#"
						from = "#form.senderAddress#"
						subject = "#form.senderSubject#"
						type = "html"
						messagetype = "1"
						generatedby ="3"
						apparea ="#apparea#"
						app_area_identifier="#form.program_id_list#"
						app_area_sub_identifier = "#apparea_subidentifier#"
						userid =	"#request.accessstructure.user_id#"
						claimRatesReportEmail="1">

							#Replace(EmailMessage, chr(13), "<br/>", "all")#

					<cfif StructKeyExists(form, 'clause')>
						#replaceNoCase(replaceNoCase(form.clause,'<pre>',''),'</pre>','')#
					</cfif>
					<cfloop list="#form.attachments#" index="vars.attachment">
						<cf_emailwrapperparam file = "#vars.attachment#">
					</cfloop>
					<cfif pdf_attachment_file_path neq "">
					<cf_emailwrapperparam file="#pdf_attachment_file_path#" />
					</cfif>
				</cf_emailwrapper>
		</cfif>

		<!--- EMAIL LETTERS TO SELECTED OPERATORS --->
		<cfloop list="#main.operators#" index="listElement">
			<!---<cfset operatorID = ListFirst(listElement, '|')>--->
			<cfset email = ListGetAt(listElement, 2, '|')>

				<cf_emailwrapper
						to = "#email#"
						from = "#form.senderAddress#"
						subject = "#form.senderSubject#"
						type = "html"
						messagetype = "1"
						generatedby ="3"
						apparea ="#apparea#"
						app_area_identifier="#form.program_id_list#"
						app_area_sub_identifier = "#apparea_subidentifier#"
						userid =	"#request.accessstructure.user_id#"
						claimRatesReportEmail="1">

							#Replace(EmailMessage, chr(13), "<br/>", "all")#

					<cfif StructKeyExists(form, 'clause')>
						#replaceNoCase(replaceNoCase(form.clause,'<pre>',''),'</pre>','')#
					</cfif>
					<cfloop list="#form.attachments#" index="vars.attachment">
						<cf_emailwrapperparam file = "#vars.attachment#">
					</cfloop>
				</cf_emailwrapper>
		</cfloop>


		<!--- EMAIL LETTERS TO SELECTED DISTRIBUTORS --->
		<cfloop list="#main.distributors#" index="listElement">
			<!---<cfset distributorID = ListFirst(ArrayElement, '|')>--->
			<cfset email = ListGetAt(listElement, 2, '|')>

				<cf_emailwrapper
						to = "#email#"
						from = "#form.senderAddress#"
						subject = "#form.senderSubject#"
						type = "html"
						messagetype = "1"
						generatedby ="3"
						apparea ="#apparea#"
						app_area_identifier="#form.program_id_list#"
						app_area_sub_identifier = "#apparea_subidentifier#"
						userid =	"#request.accessstructure.user_id#"
						claimRatesReportEmail="1">

							#Replace(EmailMessage, chr(13), "<br/>", "all")#

					<cfif StructKeyExists(form, 'clause')>
						#replaceNoCase(replaceNoCase(form.clause,'<pre>',''),'</pre>','')#
					</cfif>
					<cfloop list="#form.attachments#" index="vars.attachment">
						<cf_emailwrapperparam file = "#vars.attachment#">
					</cfloop>
					<cfif pdf_attachment_file_path neq "">
					<cf_emailwrapperparam file="#pdf_attachment_file_path#" />
					</cfif>
				</cf_emailwrapper>
		</cfloop>
	</cfoutput>