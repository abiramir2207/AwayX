<!---
///////////////////////////////////////////////////////////////
<cf_EmailWrapper>

Purpose: Handles email formatting, logging and sending.

ATTRIBUTES:
	to="" - required. Who the email is to be sent to.
	from="" - required. Who the email is from.
	subject="" - required. Message subject.
	type="" - optional. Specifies if the email content is html or text.
	messageType="" - optional. type of email message. 1=email, 2=fax.
	generatedBy="" - required. 1=system, 2=Application, 3=User.
	appArea="" - required. id of app_area_id in the app_area table.
	userId="" - required if generatedBy = 3.
	app_area_identifier="" - if the communication had to do with a uniqueidentifier (Program_ID, Billback_ID, Deduction_ID etc.) enter it here.
	app_area_sub_identifier="" - if the communication had to do with a subset of the "app_area_identifier".
							Eg: There can be multiple Program_letters_ID for a program_ID. In fact, for app_Area_ID of 15, we have "Program_letters_ID" as
							app_area_sub_identifier.
///////////////////////////////////////////////////////////////
--->

<!--- ///	verify attributes	/// --->
<cfoutput>
    <cfparam name="attributes.to">
    <cfparam name="attributes.cc" default="">
    <cfparam name="attributes.from">
    <cfparam name="attributes.subject">
    <cfparam name="attributes.type" default="html">
    <cfparam name="attributes.messageType" default="1">
    <cfparam name="attributes.generatedBy">
    <cfparam name="attributes.appArea">
    <cfparam name="attributes.userId" default="">
    <cfparam name="attributes.app_area_identifier" default="">
    <cfparam name="attributes.app_area_sub_identifier" default="">
    <cfparam name="attributes.logMessage" default="1">
    <cfparam name="attributes.programLettersEmail" default="0">
    <cfparam name="attributes.claimRatesReportEmail" default="0">

    <!--- need to select directly from application settings table --->
    <cfset useLakebaseForAppSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForAppSettings>
	<cftry>
		<cfset AppSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAppSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAppSettings>
<cfquery name="AppSettings" datasource="#application.datasource#">
    SELECT TOP 1
    *
    FROM _application_Settings
    </cfquery>
</cfif>

    <!--- do validation for userId--->

    <cfif attributes.generatedBy eq 3 and trim(attributes.userId) eq "">
        <cfabort showError="userId is required if generatedBy = 3.">
    </cfif>

    <cfif isDefined("attributes.to") and attributes.to neq "">
      <cfswitch expression="#thisTag.ExecutionMode#">

        <!--- Start tag processing --->
           <cfcase value= "start">

            <!--- Abort this tag if it doesn't contain an end tag--->
            <cfif not thisTag.HasEndTag>
                   <cfabort showError="<cf_EmailWrapper> requires an end tag.">
            </cfif>

           </cfcase>

           <!--- End tag processing --->
        <cfcase value="end">

            <!---set up components--->
            <cfset messLog    = CreateObject("component","components.logs.MessageLog") />
            <cfset mesgAttach = CreateObject("component","components.logs.MessageLogAttach") />
            <cfset objGenFunc = createObject("component", "components.general.General_Functions")>

            <!--- BJF D10644: Get correct "from" address --->
            <cfset fromAddress = ''>
            <cfif isDefined("AppSettings.Use_Different_From_Address")
                    and isDefined("appSettings.Different_From_Address")
                    and appSettings.Use_Different_From_Address eq 1>
                <cfset fromAddress = appSettings.Different_From_Address>
            </cfif>

            <cfif trim(fromAddress) eq ''>
                <cfinclude template="/get_Contact_Admin_Email_Address.cfm">
                <cfset fromAddress = Contact_Admin_Email_Address>
            </cfif>

            <!---initialize the messageLog component--->
            <cfset messLog.init(type=attributes.messageType,to=attributes.to,cc=attributes.cc,from=fromAddress,subject=attributes.subject, generatedBy=attributes.generatedBy ,appArea=attributes.appArea,userId=attributes.userId,app_area_identifier=attributes.app_area_identifier,app_area_sub_identifier=attributes.app_area_sub_identifier) />

            <!---send email--->
            <cfif isDefined("attributes.to") and attributes.to neq "">
                <!--- sanitize email addresses --->
                <cfset variables.toEmailAddresses = application.util.string.parseEmailAddresses( attributes.to ) >     <!--- 41942 --->
                <cfset attributes.to = arrayToList( variables.toEmailAddresses ) >
            </cfif>
            <cfif isDefined("attributes.cc") and attributes.cc neq "">
                <cfset attributes.cc = trim(replace(attributes.cc," ", "","ALL")) >
            </cfif>

            <cfscript>
                table            = {};
                table.styles     = "background-color:white;border-collapse:collapse;border-bottom:3px solid ##edeef2;color:##7c7c7c;font-family:Arial, sans serif;width:98%;";
                table.attributes = 'border="0" cellpadding="0" cellspacing="0"';
            </cfscript>

            <cfmail to = "#attributes.to#"
                    cc = "#attributes.cc#"
                    from = "#fromAddress#"
                    replyto = "#attributes.from#"
                    subject = "#attributes.subject#"
                    type = "#attributes.type#">
                <!---if it's email and html then show table for email--->
                <cfif attributes.messageType eq 1>
                    <cfif attributes.type neq "html">
                        #thisTag.GeneratedContent#
                    <cfelse>
    <!------------------------------------------------------------------------------->
    <!---  do NOT insert leading white spaces to this html block of code          --->
    <!---  we want to be efficient as much as possible by generating small emails --->
    <!------------------------------------------------------------------------------->
    <html>
    <head><title>Forge Email</title></head>
    <body style="background-color:##edeef2">
    <!---  header  --->
    <table #table.attributes# style="#table.styles#;border-top:4px solid ##88272d;font-weight:bold;">
        <tr> <td style="padding:7px;font-size:18px;color:##343540;" valign="middle">Forge</td> </tr>
        <tr> <td style="padding:3px 7px 7px 7px;font-size:14px;color:##88272d;" valign="middle">Blacksmith Applications</td> </tr>
    </table>

    <!---  body  --->
    <table #table.attributes# style="#table.styles#;font-size:12px;">
        <tr> <td style="padding:15px 7px;">#thisTag.GeneratedContent#</td> </tr>
    </table>

    <!---  footer  --->
    <table #table.attributes# style="#table.styles#;font-size:9px;text-align:center;border-bottom:15px solid ##edeef2;">
        <tr> <td style="padding:3px 0;"> <a style="text-decoration:none;" href="#application.HTTPVar##cgi.server_name#">#application.returned_customer_setting.Company_Name#</a> </td> </tr>
        <tr> <td style="padding:3px 0;">Contract Management services provided by <a style="text-decoration:none;" href="//www.blacksmithapplications.com/">Blacksmith Applications, Inc.</a> </td> </tr>
    </table>
    </body>
    </html>
                    </cfif>     <!--- <cfif attributes.type neq "html"> --->

                    <cfset messLog.setMessage(thisTag.GeneratedContent) />
                </cfif>


                <!---if we have cf_EmailWrapperParam tags then we have to match them to cfmailparam--->
                <cfif isDefined("thisTag.AssocAttribs")>

                    <cfset comboErr = "Invalid attribute combination for <cf_EmailWrapperParam>. Possible combinations are: Required attributes: 'name,value'. Optional attributes: None. Required attributes: 'file'. Optional attributes: 'encoding,type'." />

                    <!---loop through each tag attribute--->
                    <cfloop index="indx" from="1" to="#ArrayLen(thisTag.AssocAttribs)#">

                        <!---do validation for cfmailparam file attribute--->
                        <cfif StructKeyExists(thisTag.AssocAttribs[indx], "file")>

                            <cfif StructKeyExists(thisTag.AssocAttribs[indx], "name") or StructKeyExists(thisTag.AssocAttribs[indx], "value")>
                                <cfabort showError="#comboErr#">
                            <cfelseif not CompareNoCase(trim(thisTag.AssocAttribs[indx].file), "")>
                                <cfabort showError="File attribute is required for <cf_EmailWrapperParam>.">
                            <cfelseif StructKeyExists(thisTag.AssocAttribs[indx], "store") and not CompareNoCase(thisTag.AssocAttribs[indx].store, "yes")>
                                <!---if we have a file attribute and we want to store it--->
                                <cfparam name="thisTag.AssocAttribs[indx].desc" default="" />
                                <cfmailparam file="#thisTag.AssocAttribs[indx].file#" />
                                <cffile action="read" file="#thisTag.AssocAttribs[indx].file#" variable="attchContent">
                                <cfset mesgAttach.setAttachments(attchContent, thisTag.AssocAttribs[indx].desc) />
                            <cfelse>
                                <cfmailparam file="#thisTag.AssocAttribs[indx].file#" />
                            </cfif>
                        </cfif>

                        <!---do validation for cfmailparam name,value attribute--->
                        <cfif StructKeyExists(thisTag.AssocAttribs[indx], "name") or StructKeyExists(thisTag.AssocAttribs[indx], "value")>
                            <cfif StructKeyExists(thisTag.AssocAttribs[indx], "file")>
                                <cfabort showError="#comboErr#">
                            <cfelseif not CompareNoCase(trim(thisTag.AssocAttribs[indx].name), "") or not CompareNoCase(trim(thisTag.AssocAttribs[indx].value), "")>
                                <cfabort showError="Name,Value attribute is required for <cf_EmailWrapperParam>.">
                            <cfelse>
                                <cfmailparam name="#thisTag.AssocAttribs[indx].name#" value="#thisTag.AssocAttribs[indx].value#" />
                            </cfif>
                        </cfif>

                    </cfloop>

                </cfif>

             </cfmail>

        <!---add any attachments to messageLog--->
            <cfset messLog.addAttachments(mesgAttach) />
            <!---commit log to database--->
            <!---
                added this condition to not save emails with passwords that are unencrypted,
                plugging a security hole.  Will now only log the message if this attribute is not
                specified in the tag or the attribute is specified to 1.
             --->
            <cfif attributes.logMessage>
                <cfset messLog.commitLog(messLog) />
            </cfif>

            <cfset thisTag.GeneratedContent = "" />

       </cfcase>

      </cfswitch>
    </cfif>
    </cfoutput>
