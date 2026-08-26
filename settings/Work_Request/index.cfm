<cfoutput>
    <cfset PAGETITLE = 'Work Request'>
</cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
    <head>
        <title></title>
        <script SRC="/script/javascript/string_functions.js"></script>
        <script LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></script>
        <script SRC="/Script/javascript/dhtml.js"></script>
        <script LANGUAGE="JavaScript" SRC="work_request_component.js"></script>

        <style type="text/css">
            hh {font-size: 12px; COLOR: blue;}
            h3{margin-top:15px;}
        </style>
    </head>

    <body BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
        <cfif !application.util.query.get_setting("SalesForce_Ticket_For_WR", 0)>
            <font size="1" COLOR="Red">[</font>
            <a
                HREF="/helpsystem/webhelp/Work_request_HowToCreatethePerfectWR.htm" onclick="NewWindow('/helpsystem/webhelp/Work_request_HowToCreatethePerfectWR.htm','WR','800','600','Yes', 'Yes');return false;"
            >
                <hh>how to create the perfect work request</hh>
            </a>
            <font size="1" COLOR="Red">]</font>
        </cfif>

        <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
        <cfinclude TEMPLATE="/settings/settings_title.cfm">
        <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

        <!--- D132487: Update customer access to punchlist to point to salesforce --->
        <cfif application.util.query.get_setting("SalesForce_Ticket_For_WR", 0)>
            <h3>We will be migrating to Salesforce Service Cloud on September 16, 2024 for all work request creations.</h3>
            <h3>
                <ul>
                    <li>
                        <a
                            href="https://info.telusagcg.com/e3t/Ctc/ZT+113/cNQRg04/VX6zWr8qzzLJVjTYxH1CTHfBW5GRJ1L5kShhqN84394b3qgyTW8wLKSR6lZ3nvW22Gtgs40T5MbW19Rzrf8ybfhCW2_B-8t3Mmp1jW5_cKQS14cpjfW5D4brH6SzwQtW73tZWJ4BCC7qN6lr6tpKxzP-W7ktGdR54vXWdW24Z9kM27G61gW248_-B72CS95W5DXjk01H3vgmW43JKYy2LLZxRW4xT_br7dDpTzW2stFQ88JxKtzW17VFqG2ZW4CqVHDxHL1R9YVPN131qYlBmlKLW3NML-w7g_RhbN14HxW89WKVgN5ZfbTq9SJdVW8lnwdQ7PHp4vW7hrJ-p25vFJsW7dxz7v72R9bYW2H6zn12vb0HRW76JF352CSn0WW4NpYvc7qZ8L5W9d0z6k2rPD-ZVBtlYw82jGcWf58M1cP04"
                            target="_blank"
                        >
                            <cfoutput>
                                #application.util.string.actionLinkFormat(action = 'Step-by-Step Guide')#
                            </cfoutput>
                        </a>
                    </li>
                    <li>
                        <a
                            href="https://info.telusagcg.com/e3t/Ctc/ZT+113/cNQRg04/VX6zWr8qzzLJVjTYxH1CTHfBW5GRJ1L5kShhqN84393W3qgyTW7Y8-PT6lZ3ngN348CNGH1HJ8N4F4Nhc3vmLvW5BXVn-14dgrLW9jLymW2RNtfkV_qL0D8DrSfpW3bQMnZ4QGDDhVjD1Rf9gbT1dW3kryqj2wwLnpW3K3wGT3367S0W8C14058NsGy-W3hPxwN5dCjkLW2FSw0w5bc1K8W8mdc9W4B3QBQW4Tcrvt7Rs1zhW4Qk_Rh2dsKnbW1_G5gM30cKVyW6vjF4N1wwQ2qW4-sCyq7qcT3LVTlt_q3lhp2HN7Y3jd1DP2mGN6tQFtxJj-7lW8gttrH2fDYq-N49rcTRDvjhhW3hKW5c3WjBxwW6rmqHR4fctlpW8v0-sK46nclqf5jrL8d04"
                            target="_blank"
                        >
                            <cfoutput>
                                #application.util.string.actionLinkFormat2(action = 'Portal Demo Recording')#
                            </cfoutput>
                        </a>
                    </li>
                    <li>
                        <a
                            href="https://info.telusagcg.com/e3t/Ctc/ZT+113/cNQRg04/VX6zWr8qzzLJVjTYxH1CTHfBW5GRJ1L5kShhqN84393W3qgyTW7Y8-PT6lZ3lWW7R3X_34dPMWcN2SKY90Gp-RNN3w6H2JB55hcW2xP4Xc5MF8ZVW1QZD8h3DHFR3W9kLc3_3NvrgXW4q8Ln-60Wj65W6y3L6r2MqlXHW24yHHZ2D0DwTW5pTn2s5fdlWpW7jXdWF5gGY9bW4ykBMS94CCMyW8jxqcq79SP7PVtbPDN7k07m7W6x0s292qJgSLW8gwPj27V5fWGN7gfM09-mcY5W4znDMv21WvPhVWdV7747953SW6NCnHd8b2WX-W4hMpNs20ZwKTW1MZXV24G0cCyW3WBx--1WGBx4W3XRSPL8czRwVN1PtvfTf9f9dW9ggmwQ3Hgh1Zf6DqZNg04"
                            target="_blank"
                        >
                            <cfoutput>
                                #application.util.string.actionLinkFormat2(action = 'Customer Portal Overview')#
                            </cfoutput>
                        </a>
                    </li>
                </ul>
            </h3>

            <h3>
                <cfoutput>
                    #application.util.string.wrapText('You will receive an email invitation from Salesforce prior to start of business Monday (09/16/24) to set up your new portal credentials. Please ensure you locate this email and complete the required steps.')#
                </cfoutput><br>
                Access:
                <a href="https://telusagcg.my.site.com/ConsumerGoods" target="_blank">
                    <cfoutput>
                        #application.util.string.actionLinkFormat2(
                            action = 'Salesforce Service Cloud',
                            class = 'important'
                        )#
                    </cfoutput>
                </a>
            </h3>
        <cfelse>
            <!---
                xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                Rebate Component List Page
                xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-
            --->
            <cfparam NAME="form.display" DEFAULT="active">
            <cfparam NAME="form.command" DEFAULT="">
            <cfparam NAME="form.returnTo" DEFAULT="">
            <cfparam NAME="Form.Item_Status" DEFAULT="">
            <cfparam NAME="Form.Built_To" DEFAULT="0">
            <cfparam NAME="Form.Created_Since_Date" DEFAULT="">
            <cfscript>
            compWorkRequest = createObject('component', 'settings.Work_Request.WorkRequest');
            </cfscript>

            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

            <!--- ****************************** START COMMANDS *********************************** --->
            <cfset useLakebaseForGetCompanyName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_settings")>
<cfif useLakebaseForGetCompanyName>
	<cftry>
		<cfset GetCompanyName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_settings", {
				"select" = "company_name"
			}), "company_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCompanyName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCompanyName>
<cfquery name="GetCompanyName" datasource="#application.datasource#">
            SELECT Company_Name FROM Customer_Settings
            </cfquery>
</cfif>

            <!--- /////////////ADD COMPONENT/////////// --->
            <cfif form.command eq 'addComp'>
                <cfscript>
                stError = structNew();
                stError.bNameExists = compWorkRequest.add(
                    form.Work_Title,
                    form.Request_Type,
                    form.App_Area,
                    form.User_Created,
                    form.Installation_URL,
                    form.Client_Priority,
                    form.Client_Reference_Number,
                    GetCompanyName.Company_Name,
                    Form.URLEnvironment,
                    Form.ProgBBDDIDs,
                    Form.UserInfo,
                    Form.ErrorEvent,
                    Form.CurrentBehavior,
                    Form.ExpectedBehavior,
                    Form.MatchAttch
                );
                form.display = 'active';
                form.command = '';
                </cfscript>

                <!--- /////////////DELETE SELECTED COMPONENT/////////// --->
            <cfelseif form.command eq 'delete'>
                <cfscript>
                compWorkRequest.delete(form.compId);
                </cfscript>
            </cfif>

            <cfset form.command = ''/>

            <!--- ****************************** END COMMANDS *********************************** --->

            <!--- ****************************** START DISPLAY *********************************** --->

            <!--- /////////////DISPLAY ACTIVE/////////// --->

            <cfif form.display eq 'active'>
                <cfscript>
                qGetCompRebates = compWorkRequest.getActive();
                </cfscript>

                <!--- /////////////SEARCH RESULTS/////////// --->
            <cfelseif form.display eq 'searchResults'>

                <cfscript>
                qGetCompRebates = compWorkRequest.search(
                    form.Request_Desc,
                    form.Request_Type,
                    form.App_Area,
                    form.Client_Priority,
                    form.Item_Status,
                    form.Built_To,
                    form.Created_Since_Date
                );
                </cfscript>
            </cfif>

            <!--- ****************************** END DISPLAY *********************************** --->

            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

            <cfinclude template="work_request_header.cfm"/>

            <form ACTION="index.cfm" METHOD="post" NAME="DataForm" ID="DataForm">
                <!--switch for each action--->
                <cfswitch expression="#form.display#">
                    <cfcase value="active">
                        <cfinclude template="work_request_display.cfm"/>
                    </cfcase>

                    <cfcase value="searchResults">
                        <cfinclude template="work_request_display.cfm"/>
                    </cfcase>

                    <cfcase value="inActive">
                        <cfinclude template="work_request_display.cfm"/>
                    </cfcase>

                    <cfcase value="add">
                        <cfinclude template="work_request_add.cfm"/>
                    </cfcase>
                </cfswitch>

                <cfoutput>
                    <!--- hidden form fields --->
                    <input name="display" type="hidden" value="#form.display#"/>
                    <input name="command" type="hidden" value="#form.command#"/>
                    <input name="compId" type="hidden" value=""/>
                    <input name="returnTo" type="hidden" value="#form.returnTo#"/>
                </cfoutput>
            </form>
        </cfif>
    </body>
</html>
