<cfparam name="attributes.debug_on" default="0">
<cfparam name="attributes.title" default="">
<cfparam name="attributes.description" default="">
<cfparam name="attributes.variable" default="">

<cfif not isdefined("caller.debugtag")>
	<cfset caller.debugtag = structnew()>
</cfif>

<CFSET tempfilename = "debug_" & createuuid() & createuuid()>
<CFSET tempfilename = replace(tempfilename, "-", "", "ALL")>
<CFSET "caller.debugtag.files.#tempfilename#" = 1>
<CFSET tempfilename = tempfilename & ".cfm">


<cfsavecontent variable="pagecontent">
	<cfdump var="#evaluate('caller.#attributes.variable#')#">
</cfsavecontent>

<CFSET pagecontent = "<CFSET varname = ""#attributes.variable#""><CFSET title = ""#attributes.title#""><CFSET description = ""#attributes.description#""><CFSAVECONTENT variable=""errortext"">" & pagecontent & "</CFSAVECONTENT>">
<cffile action="WRITE" file="c:\inetpub\wwwroot\awayx\error_files\#tempfilename#" output="#pagecontent#" addnewline="Yes">

