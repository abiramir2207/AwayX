<!--- 
    Name:
        scheduled_tasks.cfm
    Created By:
        Tim Ford 08/27/2003
    Description:
        File used to call all scheduled tasks
--->

<cfsetting requesttimeout=1800>

<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~ add all tasks to an array ~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cfscript>
    genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
    appSettings = genSettingsManager.get();

    // <!---set the Domain for which the url is to run in--->
    HTTPVariable = "http";
    if (appSettings.getSSL_On_All_Pages() IS 1) {
        HTTPVariable = "https";
    }
    url_domain = "#HTTPVariable#://#CGI.SERVER_NAME#";

    // <!---set scripts array--->
    aScript = [];
    aScript.append( "/scheduled/removeOldLetters.cfm" );    // <!---25704--->
    // <!--- Label 37007 - Auto Renew sending wrong program email attachments --->
    if ( appSettings.getAutoRenewScheduled() ) {
        aScript.append( "/scheduled/auto_renew_programs.cfm?logPunchList=1" );
    }

    aScript.append( "/Common_Files/Contracts/Delete_Temp_Files/Delete_Temp_Files.cfm" )
            .append( "/scheduled/deleterebatefilesforPP.cfm" )
            .append( "/anything_automated/onlypublicdirectory/schedule_this_file_only.cfm" )
            .append( "/scheduled/auto_checkbook.cfm" )
            .append( "/scheduled/auto_create_next_fiscal.cfm" );

    // <!--- D35466 : Call the task which sends out email out auto approve email --->
    if (appSettings.getBillbackModuleType() eq 2) {
        aScript.append( "/scheduled/auto_approve_report.cfm" );
    }

    if ( appSettings.getFuturesPricingAvailable() ) {
        aScript.append ( "/scheduled/fp_nightly_process.cfm" );
    }

    // <!------ This need to be added before deduction_reminder.cfm ----->
    if ( appSettings.getDeduction_Module() ) {
        aScript.append( "/scheduled/deduction_status_new_auto_reminder.cfm" )
                .append( "/scheduled/deduction_reminder.cfm" );
    }

    // <!------ For price change report (drk) ----->
    if ( fileExists(ExpandPath("Update_Fixed_Price_Difference.cfm")) ) {
        aScript.append( "/scheduled/Update_Fixed_Price_Difference.cfm" );
    }

    if (left(application.returned_customer_setting.Customer_Keyword,1) EQ "P") {
        aScript.append( "/billbacks/Auto_Billback/Auto_BB_Scheduled.cfm" );
    }

    // <!--- DAA: Dev Note; AUDIT TRAIL STORAGE FOR CREATING AND MAINTAINING TABLES FOR SETTINGS AUDITS --->
    // if (appSettings.getAuditTrailStorage() neq 0) {
    //     aScript.append( "/scheduled/AuditTrail.cfm" );
    // }

    // <!--- DAA: Dev Note D16622; ITEM LANGUAGE DESCRIPTION CODES, FOR MULTI-LINGUAL PURPOSES --->
    if (appSettings.label_sets) {
        aScript.append( "/scheduled/Item_Desc_Lang_File_Read.cfm" );
    }

    if (appSettings.getReleaseSettlement()) {
        aScript.append( "/scheduled/send_rs_ack_notification.cfm" )
                .append( "/scheduled/send_rs_ack_report.cfm" )
                .append( "/scheduled/release_programs.cfm" );
    }

    // <!--- Dev Note: Kal; D13402 Open Deductions with inactive or deleted customers --->
    aScript.append( "/scheduled/Open_Deductions_Inactive_Customers.cfm" );

    // <!--- Tim Ford: Label 19149 - If program alerts is on then call the Program_Alert_Emails.cfm file --->
    if (appSettings.getProgramAlerts()) {
        aScript.append( "/scheduled/Program_Alert_Emails.cfm" );
    }

    aScript.append( "/scheduled/deleteAuditReports.cfm" )
            .append( "/scheduled/mailSent.cfm" )
            .append( "/Scheduled/Program_Alert_Payment_Notification.cfm" )
            .append ( "/Scheduled/Cancel_Pgm_No_BB_Months.cfm" )
            .append ( "/Scheduled/program_change_history.cfm" );

    // ==================================================================================
    // retrieve the optional timeout for individual scheduled task, default to 15 minutes
    // increase the timeout on slow websites if needed, timeouted task continues to run
    // ==================================================================================


    scheduled_task_timeout = val(application.util.query.get_setting("scheduled_task_timeout", 0));
    scheduled_task_timeout = scheduled_task_timeout gt 0 ? scheduled_task_timeout : 900;
</cfscript>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~ process all tasks in array ~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cfloop index="indx" from="1" to="#aScript.len()#">

    <cfscript>
        starttime = GetTickCount();
        taskName  = ListFirst(ListLast(aScript[indx], "/"), ".");
    </cfscript>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  start the task via a web request with a timeout, smithfield ran into infinite tasks --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->    
    <cfhttp url="#url_domain##aScript[indx]#" method="get" resolveurl="no" timeout="#scheduled_task_timeout#" result="result">
        <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
        <cfhttpparam type="Header" name="TE" value="deflate;q=0">
    </cfhttp>

    <cfparam name="result.statusCode" default="">

    <!---if the status code is not 200 then we have an error--->
    <cfset logText = result.StatusCode contains "200"
                        ? "#taskName# was successful - " & result.StatusCode
                        : "#taskName# failed - " & result.StatusCode>

    <cflog text="#logText#" log="scheduler" application="yes">

    <cfset ProcessTime= GetTickCount() - starttime>

    <cfquery datasource="#application.datasource#">
        INSERT INTO Scheduled_CF_Jobs(Created_Date, Message, Execution_Time, Status, Cfm_File)
            VALUES (getDate(), '#taskName#', '#ProcessTime#', <cfif result.StatusCode contains "200">1<cfelse>0</cfif>, '#url_domain##aScript[indx]#')

        DELETE FROM Scheduled_CF_Jobs
            WHERE DateDiff(d,Created_Date,getdate())  > 90
    </cfquery>

    <!---write task response contents out to file--->
    <cfset fileName = "#taskName#.htm" />
    <cfparam name="result.fileContent" default="">
    <cffile action="write" file="#request.app_general_functions.Get_Application_Path()#\scheduled\#fileName#" output="#result.FileContent#" addnewline="no">

</cfloop>