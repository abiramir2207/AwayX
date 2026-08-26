<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~ setRequestVariables() ~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cfscript>
function setRequestVariables() output="false" {

    request.app_general_functions = createObject("component", "components.general.General_Functions");

    var url_components = listToArray(cgi.http_url, "/");
    request.forge_module = "";
    if (arrayLen(url_components) gt 1) {
        if (url_components[1] is "planners" or url_components[2] is "planners") {
            request.forge_module = "planners";
        }
    }

    request.is_developer = isDefined("request.accessstructure.user_code") and cgi.remote_addr contains "10.2.4."
                                        ? arrayFindNoCase([
                                                            "asrinivasarao1",
                                                            "cnguyen1",
                                                            "dkunnath",
                                                            "drachala1",
                                                            "kcullom1",
                                                            "kal",
                                                            "msaunders1",
                                                            "sharris1",
                                                            "tford1"
                                                        ], request.accessstructure.user_code)
                                        : 0;

    request.key              = isDefined("request.AccessStructure.User_ID") ? request.app_general_functions.GenerateKey() : '';
    request.requestStartTime = getTickCount();
    request.TemplateName     = replace( listLast(cgi.script_name, '/'), '/', '' );

}
</cfscript>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~ setRequestAccessStructure() ~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cfscript>
// args structure is optional due to scheduled tasks
// pass in args.user_id to help defining the proper request.AccessStructure elements
// (see process_login.cfm for more information)
function setRequestAccessStructure ( struct args ) output="false" {

    param name="args.user_id" default="";

    var qUser = queryExecute("SELECT TOP 1 _Users.*,
                                        Company_Main.Company_Name,
                                        Company_Main.Company_Main_ID,
                                        Company_Main.Company_Type_ID,
                                        Company_Main.National_Affiliation_Code,
                                        Company_Main.Company_logo
                                FROM _Users
                                LEFT JOIN Company_Main ON _Users.Company_Main_ID = Company_Main.Company_Main_ID
                                WHERE _Users.Deleted = 0
                                    AND _Users.User_ID = '" & args.user_id & "'"
                                    , [], {datasource = application.datasource});
    var user_exists = qUser.recordCount ? true : false;

    request.AccessStructure.Blacksmith_User            = user_exists ? qUser.Blacksmith_User : 0;
    request.AccessStructure.Company_logo               = user_exists ? qUser.Company_logo    : '';
    request.AccessStructure.Company_Main_ID            = user_exists ? qUser.Company_Main_ID : '';
    request.AccessStructure.Company_Name               = user_exists ? qUser.Company_Name    : '';
    request.AccessStructure.Company_Type_ID            = user_exists ? qUser.Company_Type_ID : '';
    request.AccessStructure.Name_First                 = user_exists ? qUser.Name_First      : '';
    request.AccessStructure.Name_Last                  = user_exists ? qUser.Name_Last       : '';
    request.AccessStructure.National_Affiliation_Code  = user_exists ? qUser.National_Affiliation_Code : '';
    request.AccessStructure.numberOfProductGroupLevels = isDefined("application.numberOfProductGroupLevels") ? application.numberOfProductGroupLevels : 3;
    request.AccessStructure.Profiles_ID                = user_exists ? qUser.Profiles_ID     : 0;
    request.AccessStructure.SSO_User                   = user_exists is false ? 0 : len(qUser.LDAP_User_Name) ? 1 : 0;

    request.AccessStructure.User_Code                  = user_exists ? qUser.User_Code       : '';
    request.AccessStructure.User_Directory             = user_exists is false
                                                            ? ''
                                                            : qUser.Company_Type_ID eq '1'
                                                                ? "/Manufacturers"
                                                                : qUser.Company_Type_ID eq '2'
                                                                    ? "/Distributors"
                                                                    : qUser.Company_Type_ID eq '3'
                                                                        ? "/Operators"
                                                                        : '';
    request.AccessStructure.User_Email                 = user_exists ? qUser.User_Email     : '';
    request.AccessStructure.User_ID                    = args.User_ID;
    request.AccessStructure.User_Language              = user_exists ? qUser.User_Language  : 0;
    request.AccessStructure.User_Rights_ID             = user_exists ? qUser.User_Rights_ID : 0;

    param name="args.External_Customer_Profile_Access"          default="0";
    param name="args.External_Customer_Profile_Access_CustNum"  default='';
    param name="args.External_Customer_Profile_Access_CustType" default='';
    param name="args.timeZoneOffset"                            default="300";
    param name="args.useDayLightSavingsTime"                    default="true";

    request.AccessStructure.External_Customer_Profile_Access          = args.External_Customer_Profile_Access;
    request.AccessStructure.External_Customer_Profile_Access_CustNum  = args.External_Customer_Profile_Access_CustNum;
    request.AccessStructure.External_Customer_Profile_Access_CustType = args.External_Customer_Profile_Access_CustType;
    request.AccessStructure.timeZoneOffset                            = args.timeZoneOffset;
    request.AccessStructure.useDayLightSavingsTime                    = args.useDayLightSavingsTime;

    var businessSegManager = createObject("component", "components.programs.business_segment.BusinessSegmentManager");

    request.AccessStructure.User_Business_Segments = '';
    if (isDefined("application.returned_customer_setting.business_segments_on")) {
        // 33473 - save user's assigned business segments into a request variable & session variable
        if ( businessSegManager.isEnabled() ) {
            var qUserBusinessSegments = businessSegManager.getActiveClassCodes(request.AccessStructure.User_ID, 0);
            request.AccessStructure.User_Business_Segments = valueList(qUserBusinessSegments.Business_Segment_ID);
        }
    }

}
</cfscript>

