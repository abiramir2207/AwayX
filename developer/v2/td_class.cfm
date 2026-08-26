<!---------------------------------------------------------------------------------------------------------------------
  Template: /developer/v2/result.cfm
  Date:     2022 January
  Author:   Chris Nguyen
  Features:
            1. Add result attrributes to all cfquery in a given CF file passing in from the URL (existing result attribute will be replaced)
            2. Result attribute has the line number where cfquery is defined
            3. Replace all line comments inside cfquery with block comments (to avoid issues in using captured query)
            4. Display the new debugged code on the screen for developers to copy/paste into appropriate file after backup non-debugged code

            https://confluence.awayx.com/x/rwRHB

  Testing:  Adding -  http://butterball.stage.awayx.com/developer/v2/result.cfm?f=/scheduled/foo.cfm

            Removing -  http://butterball.stage.awayx.com/developer/v2/result.cfm?f=/scheduled/foo.cfm&OFF

  Parameters:
            1. url.f = CF input file name (required)
            2. url.s = persistent structure name (optional, default to "request" variable). Pass blank when you do not wish to use a persistent structure like request (not recommended).
            3. url.p = result prefix (optional, default to "line").  Pass the cfc abbreviation ("phm" for PaymentHistoryManager.cfc) when you want to track multiple debugged cfc files
            4. url.off = optional, when it is specified remove all result attributes, default is to add result attributes

            <!--- e.g. result="request.r.phm_0151"   when url.p = "phm"
                       result="request.r.cpm_0318"   when url.p = "cpm"
                       result="request.r.line_4832"  when only one .cfc is tracked & url.p is not specified
             --->

  Steps:    a. Backup existing cfc files
            b. Run this builder on cfc files that you wish to track queries
            c. Overwrite the cfc files with content from running this builder
            d. Add a call to dumptoEmail( request.r ) & send it your email address in the frontend cfm page

                PaymentHistoryManager    = CreateObject("component","components.programs.paymenthistory.__PaymentHistoryManager");
                getDeductionAccountExist = PaymentHistoryManager.getDeductionAccountExist(form.contractNumber, form.contractId);
                structItemDetails        = PaymentHistoryManager.getProgramAccrualDistributorItemData(
                                                                                                        contractNumber=form.contractNumber
                                                                                                        ,contractMainID=form.contractId
                                                                                                        ,distributorComponentList=form.distributorComponentList
                                                                                                    );

                request.dumpToEmail_address = "developer@blacksmithapplications.com";
                application.util.io.dumpToEmail( request.r );
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CF Result Attr Builder</title>
    <link rel="stylesheet" href="https://cdn.awayx.com/base/styles/simplecss/simple-v1.min.css">
    <style>
        body {
            max-width: 100%;
        }
        body > * {
            grid-column: 1;
        }
        pre {
            padding: 2px 0 1px 10px;
            margin: 0;
            border: 0px;
            background-color: white;
            overflow: visible;
            font-size: 1.1rem;
            font-color: #1a1a1a;
        }
        <cfif structKeyExists(url, "off") eq false>
            pre:nth-child(1), pre:nth-child(2), pre:nth-child(3) {
                background-color: #F0E68C;
            }
            pre:nth-child(1):hover, pre:nth-child(2):hover, pre:nth-child(3):hover {
                background-color: #CCC;
            }
        </cfif>
    </style>
</head>

<body>
    <div class="main">
        <cfscript>
            param name="url.f" default="";           //  CF input file name
            param name="url.s" default="request";    //  scope for query results, not recommended to specify this parameter

            if ( structKeyExists( url, "p" ) eq false ) {
                url.p = listFirst( listLast( url.f, "\/" ), "." );
            }

            // param name="url.p" default="line_";      //  prefix for query result name ( i.e. 'phm' for PaymentHistoryManager.cfc )

            // add missing divider in url.p parameter
            if ( not url.p contains "_" ) {
                url.p = url.p & "_";
            }

            // remove '.' in url.s parameter
            url.s = replace( url.s, ".", '', "all" );

            generate( url.f );
        </cfscript>
    </div>
</body>
</html>








<cfscript>
function generate ( required file_name ) {
    if ( trim( arguments.file_name ) eq '' ) {
        writeOutput( '<p style="margin-top:25vh;text-align:center;">Please specify a CF input file name with a relative path in the URL <br> <br>
                        For example: <a href="result.cfm?f=\components\programs\message.cfc">result.cfm?f=\components\programs\message.cfc</a>
                      </p>' );
        return;
    }

    // file name with relative path must exist
    if ( fileExists("#expandPath( trim( arguments.file_name ) )#") eq false ) {
        writeOutput( '<p style="margin-top:25vh;text-align:center;">#arguments.file_name# was not found.<br><br>
                        Please check the input file name with a relative path and try again.
                      </p>' );
        return;
    }

    warning = '<!--- TODO :: BACKUP FIRST :: #expandPath( arguments.file_name )# --->';
    if ( structKeyExists( url, "off" ) eq false ) {
        // writeOutput( #htmlCodeFormat( '<!---' & repeatString( '-', len(warning) - 9 ) & '--->')# );
        // writeOutput( #htmlCodeFormat( warning )# );
        // writeOutput( #htmlCodeFormat( '<!---' & repeatString( '-', len(warning) - 9 ) & '--->')# );
    }

    count         = 0;
    attr_regex    = "\s+(\w+)(?:\s*=\s*(""[^""]*""|[^\s>]*))?";
    is_in_cfquery = false;
    new_code      = [];

    cfloop ( file="#expandPath( trim( arguments.file_name ) )#", item="line" ) {
        count++;

        if ( line contains "<td " ) {
            if ( line contains "class=" ) {
            }
            else {
                line = replaceNoCase( line, "<td ", "<td class='ln_#count#' " );
            }
        }
        else if ( line contains "<td>" ) {
            if ( line contains "class=" ) {
            }
            else {
                line = replaceNoCase( line, "<td>", "<td class='ln_#count#'>");
            }
        }

        new_code.append( line );
    }

    writeOutput( '#htmlCodeFormat( arrayToList( new_code, chr(10) & chr(13) ) )#' );
}
</cfscript>
