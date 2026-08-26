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

  Testing:  http://meeting-pc4/result.cfm?f=foo.cfm

  Parameters:
            1. url.f = CF input file name (required)
            2. url.s = persistent structure name (optional, default to "request" variable). Pass blank when you do not wish to use a persistent structure like request (not recommended).
            3. url.p = result prefix (optional, default to "line").  Pass the cfc abbreviation ("phm" for PaymentHistoryManager.cfc) when you want to track multiple debugged cfc files

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
    <title>CF 2021 Result Builder</title>
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
        <h1>CFQUERY Result Attributes Builder</h1>
    </header>

    <main>
        <article>
            <cfscript>
                param name="url.f" default="";           //  CF input file name
                param name="url.p" default="line_";      //  prefix for query result name ( i.e. 'phm' for PaymentHistoryManager.cfc )
                param name="url.s" default="request";    //  scope for query results, not recommended to specify this parameter

                // add missing divider in url.p parameter
                if ( not url.p contains "_" ) {
                    url.p = url.p & "_";
                }

                // remove '.' in url.s parameter
                url.s = replace( url.s, ".", '', "all" );

                generate( url.f );
            </cfscript>
        </article>
    </main>
</body>
</html>


<cfscript>
function generate ( required file_name XHTML) {
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

    writeOutput( '<b>#expandPath( arguments.file_name )#</b><br>' );

    count         = 0;
    attr_regex    = "\s+(\w+)(?:\s*=\s*(""[^""]*""|[^\s>]*))?";
    is_in_cfquery = false;

    cfloop ( file="#expandPath( trim( arguments.file_name ) )#", item="line" ) {
        count++;

        // look for cfquery statement
        if ( line contains "<cfquery" ) {
            is_in_cfquery = true;

            // parse attributes into an array
            cfquery_attrs = REMatch( attr_regex, line );

            // find result attribute
            cfloop ( from="1", to="#arrayLen( cfquery_attrs )#", index="result_index" ) {
                if ( trim( lCase( listFirst( cfquery_attrs[ result_index ], '=') ) ) is "result" ) {
                    break;
                }
            }

            // populate result attribute
            // e.g. result="request.r.cfc1_0151"  when url.p = "cfc1"
            //      result="request.r.cfc2_0318"  when url.p = "cfc2"
            //      result="request.r.line_4832"  when only one .cfc is tracked & url.p is not specified
            cfquery_attrs[ result_index ] =  'result="' & ( url.s eq '' ? '' : url.s & '.' ) & "r."
                                                            & url.p
                                                            & numberFormat( count, "00000" )
                                                            & '"';

            line = left(line, findNoCase( "<cfquery", line ) + 7 )
                            & arrayToList( cfquery_attrs, ' ' )
                            // append '>' character if the last character is '>' otherwise just ignore because it could be part of the last attribute
                            & ( right( trim( line ), 1 ) eq ">" ? ">" : "" );
        }

        if ( is_in_cfquery ) {
            // look for line comment "--" and replace it with block comment
            if ( line contains "	--" ) {
                line = replace(line, "	--", " /* ") & " */";
            }
            else if ( line contains " --" ) {
                line = replace(line, " --", " /* ") & " */";
            }
            else if ( left( line, 2 ) is "--" ) {
                line = "/* " & mid(line, 3, len( line ) - 2) & " */";
            }
        }

        if ( line contains "</cfquery" ) {
            is_in_cfquery = false;
        }

        writeOutput( '#htmlCodeFormat( line )#' );
    }
}
</cfscript>
