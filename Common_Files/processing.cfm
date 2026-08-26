<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\processing.cfm
      Date:     2014 July
      Author:   Chris Nguyen
      Purpose:  Displays a processing message with a spinning image on the page and then load/post page via JavaScript.
                This provides users with some visual indication that their request is being processed and they
                need to wait.

      Parameters:
          In FORM posting:
              FORM.ActualPage = required, actual posting page path (e.g. /common_files/contracts/program_rebate_action.cfm)

          or

          In URL posting:
              URL.ActualPage  = required, actual page content path (e.g. /common_files/contracts/contract_profit_analysis.cfm)

      Example:
                NewWindowTopLeft( '/common_files/processing.cfm?actualPage=/common_files/contracts/contract_profit_analysis.cfm'
                                  + '&verticalPNL=1'
                                  + '&CID=<cfoutput>#URL.CID#</cfoutput>'
                                  + '&displayPreviousVersionMargin=0'
                                  + '&margin_version=approved',
                                  'verticalPNL', screen.availWidth, (screen.availHeight - 40), 'yes', 'yes');
----------------------------------------------------------------------------------------------------------------------->
<!doctype html>
<html>
<head>
  <title>Processing request, please wait...</title>
  <cfinclude template="/common_files/jQuery.cfm">
  <cf_include files="/script/javascript/default.js, /styles/css-loader.css">
</head>

<body>
  <cfscript>   
    variables.aParameters   = [];
    request.focusHiLightOff = true;
  </cfscript>

  <cfif cgi.request_method eq "post">
    <form name="myform" method="post" action="<cfoutput>#form.actualPage#</cfoutput>">
      <cfloop collection="#form#" item="variables.formEntry">
        <cfif variables.formEntry neq "actualPage">
          <cfoutput><input type="hidden" name="#variables.formEntry#" value="#form[ variables.formEntry ]#"></cfoutput>
        </cfif> <!--- variables.formEntry neq "actualPage" --->
      </cfloop>
    </form>  <!--- name="myform" --->

    <!--- <h1>PLEASE WAIT....</h1><cfdump var="#form#" abort="true"> --->

    <script>
      show_loader( "PROCESSING YOUR REQUEST, PLEASE WAIT...");
      document.myform.submit();
    </script>

  <cfelse>  <!--- cgi.request_method neq "post"> --->
    <cfloop collection="#url#" item="variables.urlEntry">
      <cfif variables.urlEntry neq "actualPage">
        <cfset arrayAppend(variables.aParameters, variables.urlEntry & "=" & url[variables.urlEntry])>
      </cfif>
    </cfloop>
    <cfset variables.queryString = arrayToList(variables.aParameters, '&')>

    <script>
      show_loader( "PROCESSING YOUR REQUEST, PLEASE WAIT...");
      window.location = <cfoutput>"#url.actualPage#?#variables.queryString#"</cfoutput>;
    </script>
  </cfif>   <!--- cgi.request_method eq "post"> --->
</body>
</html>