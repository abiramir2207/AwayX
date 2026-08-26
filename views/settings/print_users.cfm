<!--- Dev Note: drachala; D29591: List User page not sorting  START
Added/Changed: added below two lines. comment above two lines.--->
<cfset users = CreateObject("component", "components.user.ajaxusermanager")/>

<cfloop from="1" to="2" index="counter">
    <cfif counter eq 1>
        <!--- Active users list --->
        <cfset userList = users.getusersList( auditInfo=1, type="0" )>
    <cfelse>
        <!--- InActive users list --->
        <cfset userList = users.getusersList( auditInfo=1, type="1" )>
    </cfif>

    <cfquery name="qoq" dbtype="query">
        SELECT Name_First + ' ' + Name_Last AS Name
                ,Address
                ,User_code AS User_Name
                ,User_Email AS Email
                ,PhoneNum AS Phone_Fax
                ,Password_Update_Date
                ,Company_Name
                ,Profiles_Desc
                ,Profiles_Short_Desc
                ,Name_First
                ,Name_Last
                ,LastLoginDate AS Last_Log_In_Date
                ,Authority_Sequence_Name
                ,Position_Label
                ,Title
                ,User_Number
                ,LastLockedDate AS Last_Locked_Date
                ,LastUnlockDate AS Last_Unlock_Date
                ,LastPasswordResetDate AS Last_Password_Reset_Date
                ,LastPinResetDate AS Last_Pin_Reset_date
                ,LastPasswordChangeDate AS Last_Password_Change_Date

                <cfif counter eq 1>
                    ,LastActivatedDate as Last_Activated_Date
                <cfelse>
                    ,LastInactivatedDate AS Last_Inactived_Date
                </cfif>

                ,CreatedDate AS Created_Date
                ,LastUnsuccessLoginDate AS Last_Unsuccess_Login_date
                ,Analytics_SSO_User_Name AS Analytics_SSO
                ,Ember_Info AS Insights_SSO
                <cfif val(application.util.query.get_setting("SingleSign_On", 0))>
                        ,Ldap_User_Name AS Single_Sign_On_User_Name
                </cfif>
        FROM userList
    </cfquery>

    <!--- format columns data --->
    <cfloop query="qoq">
        <cfscript>
            qoq[ "address" ][ qoq.currentRow ]   = application.util.string.stripHTML(qoq[ "address" ][ qoq.currentRow ]);
            qoq[ "Phone_Fax" ][ qoq.currentRow ] = application.util.string.stripHTML(qoq[ "Phone_Fax" ][ qoq.currentRow ]);

            qoq[ "Last_Log_In_Date" ][ qoq.currentRow ]          = dateFormat( qoq[ "Last_Log_In_Date" ][ qoq.currentRow ], "MM/DD/YYYY" );
            qoq[ "Password_Update_Date" ][ qoq.currentRow ]      = dateFormat( qoq[ "Password_Update_Date" ][ qoq.currentRow ], "MM/DD/YYYY" );
            qoq[ "Last_Locked_Date" ][ qoq.currentRow ]          = dateFormat( qoq[ "Last_Locked_Date" ][ qoq.currentRow ], "MM/DD/YYYY" );
            qoq[ "Last_Unlock_Date" ][ qoq.currentRow ]          = dateFormat( qoq[ "Last_Unlock_Date" ][ qoq.currentRow ], "MM/DD/YYYY" );
            qoq[ "Last_Password_Reset_Date" ][ qoq.currentRow ]  = dateFormat( qoq[ "Last_Password_Reset_Date" ][ qoq.currentRow ], "MM/DD/YYYY" );
            qoq[ "Last_Pin_Reset_date" ][ qoq.currentRow ]       = dateFormat( qoq[ "Last_Pin_Reset_date" ][ qoq.currentRow ], "MM/DD/YYYY" );
            qoq[ "Last_Password_Change_Date" ][ qoq.currentRow ] = dateFormat( qoq[ "Last_Password_Change_Date" ][ qoq.currentRow ], "MM/DD/YYYY" );

            if (counter eq 1)
                qoq[ "Last_Activated_Date" ][ qoq.currentRow ] = dateFormat( qoq[ "Last_Activated_Date" ][ qoq.currentRow ], "MM/DD/YYYY" );
            else
                qoq[ "Last_Inactived_Date" ][ qoq.currentRow ] = dateFormat( qoq[ "Last_Inactived_Date" ][ qoq.currentRow ], "MM/DD/YYYY" );


            qoq[ "Created_Date" ][ qoq.currentRow ]              = dateFormat( qoq[ "Created_Date" ][ qoq.currentRow ], "MM/DD/YYYY" );
            qoq[ "Last_Unsuccess_Login_date" ][ qoq.currentRow ] = dateFormat( qoq[ "Last_Unsuccess_Login_date" ][ qoq.currentRow ], "MM/DD/YYYY" );
        </cfscript>
    </cfloop>

    <cfscript>
        sheet_name = counter eq 1 ? "Active Users" : "Inactive Users";
        sheet[counter] = application.util.query.createExcelSheet(query=qoq, sheet_name=sheet_name);
    </cfscript>   
</cfloop>

<!--- generate excel file from query --->
<cfscript>
    output_file     = "user_report.xls";
    output_fullpath = expandPath( '/common_documents/temp_files/' ) & output_file;

    single_sheet = sheet[1];
    cfspreadsheet( action="write", fileName="#output_fullpath#", name="single_sheet", overwrite=true );

    single_sheet = sheet[2];
    cfspreadsheet( action="update", fileName="#output_fullpath#", name="single_sheet" );
</cfscript>

<!--- download excel file to browser --->
<cfoutput>
<cfheader  name = "Content-Disposition" value     = "attachment;filename=#output_file#">
<cfcontent type = "application/vnd.ms-excel" file = "#output_fullpath#" deletefile = "true">
</cfoutput>