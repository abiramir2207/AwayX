
<cfparam name="form.letter_id" default="">
<cfparam name="form.subject" default="">

<cfset subject = form.subject>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


<cfset useLakebaseForgetuseremail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetuseremail>
	<cftry>
		<cfset getuseremail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetuseremail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetuseremail>
<cfquery name="getuseremail" datasource="#application.datasource#">
select user_email from
_users
where user_id = '#request.AccessStructure.user_id#'
</cfquery>
</cfif>

<cfset fromemail = getuseremail.user_email>
<cfset subject = appSettings.getletterssubject()>
<cfoutput>
<cfloop list="#form.letter_id#" index="id">
<CF_EMAILWRAPPER 
						TO			=	"#Replace(evaluate("form.email_address_#id#"), ' ', ',', 'ALL')#"
				        FROM		=	"#fromemail#"
				        SUBJECT		=	"#subject#"
						TYPE		=	"html" 
						messagetype="0" 
						generatedby="2"
						appArea="1"
					>
						<cf_emailwrapperparam file = "#evaluate("form.letter_path_#id#")#" store="yes">
</CF_EMAILWRAPPER>
</cfloop>
</cfoutput>
<cfinclude template="include_display_letters.cfm">
<cflocation url="#includeLettersFilename#?CID=#form.contract_main_id#">