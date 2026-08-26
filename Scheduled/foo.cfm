<cfscript>
	awayx_config = expandPath("/AwayX.config");

    if ( fileExists( awayx_config ) eq false ) {
        awayx = {
                        DATASOURCE: application.datasource,
                        WEBSERVERNAME: application.webServerName
                    };
        fileWrite( awayx_config, serializeJSON( awayx ) );
    }
</cfscript>
