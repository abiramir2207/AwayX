<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!------
<cfset useLakebaseForemail_select = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForemail_select>
	<cftry>
		<cfset email_select = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"deleted" = "eq.0",
				"is_system_administrator" = "eq.1",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForemail_select = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForemail_select>
<CFQUERY name = "email_select" datasource="#application.datasource#">
	SELECT user_email from _users where deleted = 0 and is_system_administrator = 1
</CFQUERY>
</cfif>
<CFOUTPUT query = "email_select">
<CFSET sys_admin_email = #user_email#>
</CFOUTPUT>
----->
<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">
<CFSET sys_admin_email = Contact_Admin_Email_Address>

<!--- <CFMAIL 
FROM = "#form.email_from#"
TO = "#sys_admin_email#" 
SUBJECT = "Change in field reference"> --->
<cfoutput>
<CF_EMAILWRAPPER 
	TO = "#sys_admin_email#"
	FROM = "#form.email_from#"
	SUBJECT = "Change in field reference" 
	messagetype="1" 
	generatedby="2" 
	apparea="10">

Column Name : #form.column_name#
<br>
To be refered as : #form.column_value#
<br>
Message : #send_message#
<!--- </CFMAIL> --->
</CF_EMAILWRAPPER>
</cfoutput>

<CFIF form.page_name EQ "functional">
	<CFLOCATION URL="functional_page.cfm" ADDTOKEN="No">
<CFELSEIF form.page_name EQ "cosmetics">
	<CFLOCATION URL="cosmetic_field_page.cfm" ADDTOKEN="No">
<CFELSE>
	<CFLOCATION URL="other_fields_page.cfm" ADDTOKEN="No">
</CFIF>
</body>
</html>
