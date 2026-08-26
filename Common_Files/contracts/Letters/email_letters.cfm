<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\email_letters.cfm
      Date:     June 15, 2016
      Author:   Milan Mushran
      Purpose:  Emailing letters
----------------------------------------------------------------------------------------------------------------------->

<cfparam name="form.SenderSubject" default="">

	<cfoutput>
		<!--- RSP email should be returned here only when the RSP is not a deleted user.--->
		<cfquery name="getProgramInfo" datasource="#application.datasource#">
   		SELECT Right(cm.Contract_Number, 7) as Partial_Contract_Number, 
		   		CASE
					WHEN LEN(cm.revision_version) = 4 THEN RIGHT(CAST(cm.revision_version AS VARCHAR(4)), 4)
					WHEN LEN(cm.revision_version) = 5 THEN RIGHT(CAST(cm.revision_version AS VARCHAR(5)), 5)
					ELSE RIGHT('000' + CAST(cm.revision_version AS VARCHAR(10)), 3)
				END as Revision_Version, cm.Contract_Title,
			u.User_Email As RSP_Email
			FROM Contract_Main cm
				LEFT JOIN _Users u
				ON cm.responsible_user_id = u.user_id
				AND u.deleted = 0
		WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.contract_main_id#">
		</cfquery>

		<!--- Dev Note:74085 --->
		<cfif appSettings.get_Setting('Use_this_email_for_Program_Letters') eq '1'>
			<cfset fromemail = appSettings.getDifferent_From_Address()>
		<cfelse>
			<cfset fromemail = getProgramInfo.RSP_Email>
		</cfif>

		<!---locate the generated letter. --->
		<cfquery name="rsLetters" datasource="#application.datasource#">
		SELECT	PL.Letter_Name
				,PL.Letter_Path
				,PL.Created_Date
				,PL.Operator_Name
				,PL.Distributor_Name As Name
		FROM		Program_Letters PL
		WHERE PL.Program_letters_ID =	<cfqueryparam cfsqltype="cf_sql_integer" value="#letterID#">
		</cfquery>

		<cfset pdf_attachment_file_path = replace(rsLetters.Letter_Path, '.htm','.pdf', 'all')>
		<cfset pdf_attachment_file_name = uCase(replace(rsLetters.letter_name, '_', ' ', 'all'))>

		<cfset SubjectPrefix = ''>
		<!--- If custom letter (Custom 1) app setting is ON --->
		<cfif appSettings.getlettersavailable() eq 2>
			<cfset SubjectPrefix = "General Mills" & " ">
		</cfif>

		<cfif len(trim(form.internals)) GT 0>
			<cfif rsLetters.recordCount>
				<!---
				Letter Subject format:
				1000306 001[2 spaces] Program Title [2 spaces] Distributor Name [2 spaces] Date/Timestamp
				--->
				<!--- If custom letter (Custom 1) app setting is ON --->
				<cfif appSettings.getlettersavailable() eq 2>
					<!--- If "subject" already exists --->
					<cfif form.SenderSubject neq "">
						<cfset subject = form.SenderSubject>
					<cfelse>
						<cfset subject =
							#SubjectPrefix# & getProgramInfo.Partial_Contract_Number
							& " "
							& getProgramInfo.Revision_Version
							& "  "
							& getProgramInfo.Contract_Title
							& "  "
							& dateformat(rsLetters.Created_Date,"mm_dd_yyyy")
							& "_"
							& timeformat(rsLetters.Created_Date,"hh_mm_sstt") />
					</cfif>
				<cfelse>
					<cfset subject = "#lcase(replace(pdf_attachment_file_name, '_', ' ','ALL'))# program letter">
				</cfif>

				<!--- The logic to populate the "from" attribute is on "EmailWrapper.cfm", when "programLettersEmail" is 1.
				It gets repopulated only when the email on the "from" attribute below is invalid.
				--->
				<cf_EmailWrapper
					to = "#form.internals#"
					from = "#fromemail#"
					subject = "#subject#"
					type = "HTML"
					messagetype = "1"
					generatedby = "3"
					apparea = "15"
					app_area_identifier="#form.contract_main_id#"
					app_area_sub_identifier="#letterID#"
					userId="#request.accessStructure.User_ID#"
					programLettersEmail="1">

						#Replace(EmailMessage, chr(13), "<br/>", "all")#

					<cf_emailwrapperparam file="#pdf_attachment_file_path#" />
				</cf_EmailWrapper>
			</cfif>
		</cfif>


		<!--- EMAIL LETTERS TO SELECTED OPERATORS --->
		<cfloop list="#main.operators#" index="listElement">
			<!---<cfset operatorID = ListFirst(listElement, '|')>--->
			<cfset email = ListGetAt(listElement, 2, '|')>

			<cfif rsLetters.recordCount>
				<!---
				Letter Subject format:
				1000306 001[2 spaces] Program Title [2 spaces] Distributor Name [2 spaces] Date/Timestamp
				--->
				<!--- If custom letter (Custom 1) app setting is ON --->
				<cfif appSettings.getlettersavailable() eq 2>
					<!--- If "subject" already exists --->
					<cfif form.SenderSubject neq "">
						<cfset subject = form.SenderSubject>
					<cfelse>
						<cfset subject =
							#SubjectPrefix# & getProgramInfo.Partial_Contract_Number
							& " "
							& getProgramInfo.Revision_Version
							& "  "
							& getProgramInfo.Contract_Title
							& "  "
							& rsLetters.Operator_Name
							& "  "
							& dateformat(rsLetters.Created_Date,"mm_dd_yyyy")
							& "_"
							& timeformat(rsLetters.Created_Date,"hh_mm_sstt") />
					</cfif>
				<cfelse>
					<cfset subject = "#lcase(replace(pdf_attachment_file_name, '_', ' ','ALL'))# program letter">
				</cfif>

				<!--- The logic to populate the "from" attribute is on "EmailWrapper.cfm", when "programLettersEmail" is 1.
				It gets repopulated only when the email on the "from" attribute below is invalid.
				--->
				<cf_EmailWrapper
					to = "#email#"
					from = "#fromemail#"
					subject = "#subject#"
					type = "HTML"
					messagetype = "1"
					generatedby = "3"
					apparea = "15"
					app_area_identifier="#form.contract_main_id#"
					app_area_sub_identifier="#letterID#"
					userId="#request.accessStructure.User_ID#"
					programLettersEmail="1">

						#Replace(EmailMessage, chr(13), "<br/>", "all")#

					<cf_emailwrapperparam file="#pdf_attachment_file_path#" />
				</cf_EmailWrapper>
			</cfif>
		</cfloop>

		<!--- EMAIL LETTERS TO SELECTED DISTRIBUTORS --->
		<cfloop list="#main.distributors#" index="listElement">
			<!---<cfset distributorID = ListFirst(ArrayElement, '|')>--->
			<cfset email = ListGetAt(listElement, 2, '|')>

			<cfif rsLetters.recordCount>
				<!---
				Letter Subject format:
				1000306 001[2 spaces] Program Title [2 spaces] Distributor Name [2 spaces] Date/Timestamp
				--->
				<!--- If custom letter (Custom 1) app setting is ON --->
				<cfif appSettings.getlettersavailable() eq 2>
					<!--- If "subject" already exists --->
					<cfif form.SenderSubject neq "">
						<cfset subject = form.SenderSubject>
					<cfelse>
						<cfset subject =
								#SubjectPrefix# & getProgramInfo.Partial_Contract_Number
								& " "
								& getProgramInfo.Revision_Version
								& "  "
								& getProgramInfo.Contract_Title
								& "  "
								& rsLetters.Name
								& "  "
								& dateformat(rsLetters.Created_Date,"mm_dd_yyyy")
								& "_"
								& timeformat(rsLetters.Created_Date,"hh_mm_sstt")/>
					</cfif>
				<cfelse>
					<cfset subject = "#lcase(replace(pdf_attachment_file_name, '_', ' ','ALL'))# program letter">
				</cfif>

				<!--- The logic to populate the "from" attribute is on "EmailWrapper.cfm", when "programLettersEmail" is 1.
				It gets repopulated only when the email on the "from" attribute below is invalid.
				--->
				<cf_EmailWrapper
					to = "#email#"
					from = "#fromemail#"
					subject = "#subject#"
					type = "HTML"
					messagetype = "1"
					generatedby = "3"
					apparea = "15"
					app_area_identifier="#form.contract_main_id#"
					app_area_sub_identifier="#letterID#"
					userId="#request.accessStructure.User_ID#"
					programLettersEmail="1">

						#Replace(EmailMessage, chr(13), "<br/>", "all")#

					<cf_emailwrapperparam file="#pdf_attachment_file_path#" />
				</cf_EmailWrapper>
			</cfif>
		</cfloop>
	</cfoutput>