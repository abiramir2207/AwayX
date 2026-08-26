<!---------------------------------------------------------------------------------------------------------------------
  Template: /developer/v2/result21.cfm ( for CF 2021+ )
  Date:     2022 January
  Author:   Chris Nguyen
  Purpose:  Add result attrributes to all cfquery in a given CF file passing in from the URL
                , replace all line comments inside cfquery with block comments (to avoid issues in using captured query)
                & display the new debugged code on the screen

            https://confluence.awayx.com/x/rwRHB

  Testing:  http://meeting-pc4/result21.cfm?f=foo.cfm

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
            <cfoutput>
                <cfparam name="url.f" default="">           <!--- CF input file name --->
                <cfparam name="url.p" default="line_">      <!--- prefix for query result name --->
                <cfparam name="url.s" default="request">    <!--- scope for query results --->

                <!--- add missing dividers in url parameters --->
                <cfif not url.p contains "_">
                    <cfset url.p = url.p & "_">
                </cfif>
                <cfset url.s = replace(url.s, ".", '', "all")>

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
                        <cfif line contains "<cfquery">
                            <cfset is_in_cfquery = true>
                        </cfif>

                        <!--- look for cfquery statement --->
                        <cfif line contains "<cfquery">

                            <cfset cfquery_attrs = parseHtmlTag( line )>

                            <!--- build/update the result attribute --->
                            <!--- e.g. result="request.r.cfc1_0151"  when url.p = "cfc1"
                                        result="request.r.cfc2_0318"  when url.p = "cfc2"
                                        result="request.r.line_4832"  when only one .cfc is tracked & url.p is not specified
                                        --->
                            <cfset cfquery_attrs.attributes[ "result" ] = (url.s eq '' ? '' : url.s & '.') & "r."
                                                                           & url.p
                                                                           & numberFormat(count, "00000")>

                            <!--- place all cfquery attributes into an array --->
                            <cfset new_line = [ left(line, findNoCase( "<cfquery", line ) + 7 ) ]>
                            <cfloop collection="#cfquery_attrs.attributes#" item="attr">
                                <cfset new_line.append( '#attr#="#cfquery_attrs.attributes[ attr ]#"' )>
                            </cfloop>

                            <!--- <cfdump var="#arrayToList( new_line, ' ' )#" abort="true"> --->

                            <cfset line = arrayToList( new_line, ' ' ) & ">">
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

                        <cfif line contains "</cfquery">
                            <cfset is_in_cfquery = false>
                        </cfif>

                        #htmlCodeFormat(line)#

                    </cfloop>
                </cffunction>
            </cfoutput>

        </article>
    </main>
</body>
</html>


<cffunction
	name="ParseHTMLTag"
	access="public"
	returntype="struct"
	output="false"
	hint="Parses the given HTML tag into a ColdFusion struct.">

	<!--- Define arguments. --->
	<cfargument
		name="HTML"
		type="string"
		required="true"
		hint="The raw HTML for the tag."
		/>

	<!--- Define the local scope. --->
	<cfset var LOCAL = StructNew() />

	<!--- Create a structure for the taget tag data. --->
	<cfset LOCAL.Tag = StructNew() />

	<!--- Store the raw HTML into the tag. --->
	<cfset LOCAL.Tag.HTML = ARGUMENTS.HTML />

	<!--- Set a default name. --->
	<cfset LOCAL.Tag.Name = "" />

	<!---
		Create an structure for the attributes. Each
		attribute will be stored by it's name.
	--->
	<cfset LOCAL.Tag.Attributes = StructNew() />


	<!---
		Create a pattern to find the tag name. While it
		might seem overkill to create a pattern just to
		find the name, I find it easier than dealing with
		token / list delimiters.
	--->
	<cfset LOCAL.NamePattern = CreateObject(
		"java",
		"java.util.regex.Pattern"
		).Compile(
			"^<(\w+)"
			)
		/>

	<!--- Get the matcher for this pattern. --->
	<cfset LOCAL.NameMatcher = LOCAL.NamePattern.Matcher(
		ARGUMENTS.HTML
		) />

	<!---
		Check to see if we found the tag. We know there
		can only be ONE tag name, so using an IF statement
		rather than a conditional loop will help save us
		processing time.
	--->
	<cfif LOCAL.NameMatcher.Find()>

		<!--- Store the tag name in all upper case. --->
		<cfset LOCAL.Tag.Name = UCase(
			LOCAL.NameMatcher.Group( 1 )
			) />

	</cfif>


	<!---
		Now that we have a tag name, let's find the
		attributes of the tag. Remember, attributes may
		or may not have quotes around their values. Also,
		some attributes (while not XHTML compliant) might
		not even have a value associated with it (ex.
		disabled, readonly).
	--->
	<cfset LOCAL.AttributePattern = CreateObject(
		"java",
		"java.util.regex.Pattern"
		).Compile(
			"\s+(\w+)(?:\s*=\s*(""[^""]*""|[^\s>]*))?"
			)
		/>

	<!--- Get the matcher for the attribute pattern. --->
	<cfset LOCAL.AttributeMatcher = LOCAL.AttributePattern.Matcher(
		ARGUMENTS.HTML
		) />


	<!---
		Keep looping over the attributes while we
		have more to match.
	--->
	<cfloop condition="LOCAL.AttributeMatcher.Find()">

		<!--- Grab the attribute name. --->
		<cfset LOCAL.Name = LOCAL.AttributeMatcher.Group( 1 ) />

		<!---
			Create an entry for the attribute in our attributes
			structure. By default, just set it the empty string.
			For attributes that do not have a name, we are just
			going to have to store this empty string.
		--->
		<cfset LOCAL.Tag.Attributes[ LOCAL.Name ] = "" />

		<!---
			Get the attribute value. Save this into a scoped
			variable because this might return a NULL value
			(if the group in our name-value pattern failed
			to match).
		--->
		<cfset LOCAL.Value = LOCAL.AttributeMatcher.Group( 2 ) />

		<!---
			Check to see if we still have the value. If the
			group failed to match then the above would have
			returned NULL and destroyed our variable.
		--->
		<cfif StructKeyExists( LOCAL, "Value" )>

			<!---
				We found the attribute. Now, just remove any
				leading or trailing quotes. This way, our values
				will be consistent if the tag used quoted or
				non-quoted attributes.
			--->
			<cfset LOCAL.Value = LOCAL.Value.ReplaceAll(
				"^""|""$",
				""
				) />

			<!---
				Store the value into the attribute entry back
				into our attributes structure (overwriting the
				default empty string).
			--->
			<cfset LOCAL.Tag.Attributes[ LOCAL.Name ] = LOCAL.Value />

		</cfif>

	</cfloop>


	<!--- Return the tag. --->
	<cfreturn LOCAL.Tag />
</cffunction>
