<cfsetting showDebugOutput="no">
<cfinclude template="/application_datasource.cfm">

<cfscript>
    if ( structKeyExists(application, "util") ) { }
    else {
        application.util = createObject("component", "components.UtilManager").init();
    }

    // allow auditing page to be called from classic developer tools popup
    if ( ( cgi.script_name contains "_auditing.cfm" ) and ( cgi.http_referer contains "/developer/index.cfm" ) ) { }
    // allow members with a preregistered IP address
    else if ( is_developer() ) { }
    // block DOS attacks
    else {
        abort;
    }
</cfscript>

<!---initialize general functions to be used throuhout the application--->
<cfscript>
    function is_developer() output="false" hint="Determine if user is a Blacksmith web developer" {
        // gather optional list of developer IP addresses in _Settings table
        var q = queryExecute( " SELECT Value FROM _Settings WHERE Input_Name = :name ", { name = 'Developer_IPs' }, { datasource: application.datasource } );

        return     cgi.remote_addr eq "127.0.0.1"              // developer local development
                or q.Value.listFind( cgi.remote_addr );        // developer public IP addresses
    }

    request.forge_cdn = '';

    // CDN and secondary domains to pull from
    cdns = [ "https://cdn.awayx.com/base"
                , "https://smithfield2.stage.awayx.com"
                , "https://sabert2.stage.awayx.com"
                , "http://butterball.stage.awayx.com" ];

    // determine where to pull CDN resources from
    for (i = 1; i lte cdns.len() ; i++) {
        // test connection
        cfhttp(method="GET", charset="utf-8", url=cdns[i] & "/script/javascript/numeral.min.js", result="result");

        // found a good connection
        if (isDefined("result.responseHeader.status_Code") and (result.responseHeader.status_Code eq '200')) {
            request.forge_cdn = cdns[i];
            break;
        }
    }

	request.app_general_functions   = CreateObject("component","components.general.General_Functions");
	request.accessStructure.User_ID = '';
    request.forge_module            = '';
</cfscript>

<CFINCLUDE TEMPLATE="/get_App_Path.cfm">

<!--- <cfinvoke component="components.general.General_Functions" method="GenerateKey" returnVariable="key"> --->
<cfset key = request.app_general_functions.GenerateKey() />
<cfset request.key = key />