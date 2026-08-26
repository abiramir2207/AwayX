<!---------------------------------------------------------------------------------------------------------------------
  Template: /developer/v2/sqlComments.cfm
  Date:     2022 January
  Author:   Chris Nguyen
  Purpose:  Replace line comments in cfquery with block comments


  Parameters:
            1. url.f = CF input file name (required)

  Steps:    a. Backup existing cfc files
            b. Run this tool on cfc files that you wish to track queries
            c. Overwrite the cfc files with content from running this tool
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CfQuery SQL Comments</title>
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">
    <style>
        body {
            max-width: 100%;
        }
        pre {
            padding: 0;
            margin: 0;
            border: 0px;
            background-color: white;
            overflow: visible;
        }
    </style>
</head>

<body>
    <header>
        <h1>CFQUERY SQL Line Comments Replacer</h1>
    </header>

    <main>
        <article>
            <cfoutput>
                <cfparam name="url.f" default="">           <!--- CF input file name --->

                <cfset generate( url.f )>


                <cffunction name="generate">
                    <cfargument name="file_name" required="true">

                    <!--- file name is a required input --->
                    <cfif arguments.file_name eq ''>
                        <p style="margin-top:25vh;text-align:center;">Please specify a CF input file name with a relative path in the URL <br> <br>
                            For example: <a href="result.cfm?f=\components\programs\message.cfc">result.cfm?f=\components\programs\message.cfc</a>
                        </p>
                        <cfreturn>
                    </cfif>

                    <!--- file name with relative path must exist --->
                    <cfif fileExists("#expandPath(arguments.file_name)#") eq false>
                        <p style="margin-top:25vh;text-align:center;">#arguments.file_name# was not found.<br><br>
                        Please check the input file name with a relative path and try again.</p>
                        <cfreturn>
                    </cfif>

                    <b>#expandPath(arguments.file_name)#</b><br>

                    <cfset count = 0>
                    <cfset is_in_cfquery = false>
                    <cfloop file="#expandPath(arguments.file_name)#" item="line">

                        <cfset count++>
                        <!--- look for cfquery statement --->
                        <cfif line contains "<cfquery">
                            <cfset is_in_cfquery = true>
                        </cfif>
                        <cfif line contains "</cfquery">
                            <cfset is_in_cfquery = false>
                        </cfif>

                        <cfif is_in_cfquery>
                            <!--- look for line comment "--" and wrap it in block comments pair --->
                            <cfif line contains "	--">
                                <cfset line = replace(line, "	--", " /*	--") & " */">
                            <cfelseif line contains " --">
                                <cfset line = replace(line, " --", " /* --") & " */">
                            <cfelseif left(line,2) is "--">
                                <cfset line = "/* " & line & " */">
                            </cfif>
                        </cfif>

                        #htmlCodeFormat(line)#
                    </cfloop>
                </cffunction>
            </cfoutput>

        </article>
    </main>
</body>
</html>

