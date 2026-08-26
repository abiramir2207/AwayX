<cfsetting enableCFOutputOnly="Yes">
<!--- 
AUTHOR: Brandon Purcell
		brandon@bpurcell.org 
		http://www.bpurcell.org
Thanks to:
	Mike Collins, Mike Punsky, Daryl Banttari, Jim Schley from Macromedia for their work on CF_Supercache

NAME: <cf_accelerate> v1.3 10/28/2003

DESCRIPTION: This tag allows you to wrap a page or a section of content in a page and cache data 
			 in a shared scope 
			 My testing has found that it is 50 times faster than <CFCACHE> when there are 10,000
			 entries in the cache.
			 
			 The difference between this tag and CF_SuperCache is that this tag stores the cache in a tree of structures
			 this improves search times for very large caches. 
			 
			 CF_Supercache stores the cached data in server.supercache.x.content if you have a large cache search times increase quickly
			 CF_Accelerate stores the cached data in application.accelerator.scriptname.primarykey.secondarykey.content
			 the tag dynamically builds a deeper structure reducing the search time with large caches, and it makes it easier to manage the cache 

ATTRIBUTES:
	SCRIPTNAME			(Optional) defaults to the cgi.script_name (strip out chars to build syntactically correct variables)
	PRIMARYKEY			(Optional) defaults to the cgi.query_string (strip out chars to build syntactically correct variables)
	SECONDARYKEY		(Optional) defaults to the string "default"
	CACHEDWITHIN		(Optional) defaults to 15 min
	STRIPWHITESPACE		(Optional) Reduces whitespace (borrowed from CF_SuperCache)
	setHeaders			(Optional) Defaults to false and sets HTTP 1.0/1.1 headers (caching directives for client side)
	noCache				(0ptional) to cache or not to cache default is false (this caches the content) set to true and it will not
	cacheScope 			(not implemented) (Optional) (Future Enhancement) What shared scope the cache will be stored in.
						To modify the default modify <cfparam name="attributes.cacheScope" default="Application">

USAGE:
	Example1 with no args will cache page for 15 minutes and create copies for each different combo of url params
	<cf_accelerate>
	...page content....
	</cf_accelerate>
	
	Example2: 
	<cf_accelerate primaryKey="US" secondaryKey="FDETX" cachedWithin="#createTimeSpan(0,0,10,0)#" StripWhitespace="true">
	...
	</cf_accelerate>
	
NOTES: 
	Modify application.* to server.* to store data in server scope

	To flush the cache add, the url parameter ?flushAccelerator=true
	you can set true to be something else to prevent unauthorized cache expiration by changing the entry
	<cfset acceleratorPassword = "true"> when the cache is flushed it will only flush the current pages
	cache stored in application.accelerator.{scriptname}
	
	TO FLUSH the ENTIRE cache use ?flushAccelerator=true&clearAll=true
	
	To output the datetimestamp of the cached entry when the cached content gets displayed
	add the url parameter ?displayTS=true
	
	Cached Data is stored in: 
		application.accelerator.scriptname.primarykey.secondarykey.content
	cacheExpires is stored in:
		application.accelerator.scriptname.primarykey.secondarykey.cacheExpires
		uses now() + 0 format sample(37915.7052431)
	timeStamp for the time the cache was created is stored in:
		application.accelerator.scriptname.primarykey.secondarykey.timeStamp
	URL to content with scriptname.cfm?URL is stored in:
		application.accelerator.scriptname.primarykey.secondarykey.contentURL

ENHANCEMENT IDEAS:
	Add url param to flush the entire cache and/or a particular entry based on 
	the primarykey and secondarykey 
	If you have questions or thoughts email brandon@bpurcell.org
	
	Thanks to:
	Mike Collins, Mike Punsky, Daryl Banttari, Jim Schley from Macromedia for their work on CF_Supercache
	that contributed to this tag
Version History:
	v1.0 10/21/2003 - Initial version added attrib.useCFCACHE to allow rollback to CFCACHE from in-memory
	v1.1 10/22/2003 - Added feature to check the primary key to see if it is syntactially
					- Correct if it is not default to CFCACHE to preserve the user experience
					- Added contentURL to the cached structure
					- Replace + and | in URL string with PLUS and OR to keep PRIMARYKEY from getting hosed
					- added url.clearALL for flushing the entire cached when used with flushAccelerator=true
	v1.2 10/22/2003 - added application.accelerator[scriptname]=cgi.SCRIPT_NAME to make it easier to view in the 
					  managment interface	
	v1.3 10/28/2003 - Removed CFCACHE fallback and default to no-caching when an error occurs, added noCACHE attribute
					  defaults to false, added attribute SCRIPTNAME to allow modifying of main structure name, improved error handling			
					  
TODO:  Add Attribute to specify the shared scope that the cache should be stored in
--->
<!--- parameters that will be used by in-memory or disk caching --->
<cfparam name="attributes.scriptName" default="#trim(rereplacenocase(CGI.SCRIPT_NAME,"[/&.-]" , "", "All"))#">
<cfparam name="attributes.cachedWithin" default="#createTimeSpan(0,0,15,0)#">
<cfparam name="attributes.cfcacheDir" default="/web/cacheContent/">
<cfparam name="attributes.secondaryKey" default="default">
<cfparam name="attributes.stripWhitespace" default="false" type="boolean">
<!--- <cfparam name="attributes.useCFCACHE" default="false"> --->
<cfparam name="attributes.setHeaders" default="false">
<cfparam name="attributes.noCache" default="false">
<cfparam name="attributes.cacheScope" default="Application">

<cfset cachedWithin=attributes.cachedWithin>
<cfif attributes.setHeaders>
	<cfset numSeconds = attributes.cachedWithin * 86400><!--- num seconds in a day * --->
	<cfset httpExpiration = GetHttpTimeString(createODBCDateTime(Now() + #attributes.cachedWithin#))>
	<CFHEADER NAME="Expires" VALUE="#httpExpiration#">
	<CFHEADER NAME="Cache-control" VALUE="public,max-age=#numSeconds#">
</cfif>
<!--- build a primary key based on the QUERY_STRING --->
<cfif not isdefined("attributes.primaryKey")>
	<!--- set it to a default from URL parameters and strip out chars to make it syntactically correct variable name --->
	<cfset PRIMARYKEY="qs#rereplacenocase(CGI.QUERY_STRING,"[=/&.%^$,?-]" , "", "All")#">
	<!--- | is used in a particular string as an OR during search --->
	<cfset PRIMARYKEY=replace(PRIMARYKEY, "|", "OR", "ALL")>
	<cfset PRIMARYKEY=replace(PRIMARYKEY, "+", "PLUS", "ALL")>
		<!--- if you pass in displayTS=true stip it out so we don't create another unique key --->
		<cfif isdefined("url.displayTS")>
			<cfset PRIMARYKEY=replaceNoCase(PRIMARYKEY, "displayTStrue", "")>
		</cfif>
	<cfelse>
	<cfset PRIMARYKEY=attributes.PRIMARYKEY>
</cfif>

<!--- set to local variables --->
		<cfset SECONDARYKEY=attributes.SECONDARYKEY> 
		<cfset stripWhiteSpace=attributes.stripWhiteSpace>
		<cfset scriptName=attributes.scriptname>

<!--- I added this in case there is a character we are missing when stripping the characters from the variable names--->
<!--- Instead of giving the user an error we will default to not caching and the error gets logged --->
<!--- in the file cachelog.log in the CF logs directory if you know that all URL strings will work --->
<!--- you can strip this code out to speed up the tag --->
<cftry>
<cfif isdefined(PRIMARYKEY)></cfif>
<cfif isdefined(SECONDARYKEY)></cfif>
<cfif isdefined(SCRIPTNAME)></cfif>
<cfcatch>
	<cfset cacheError="One of the Struct Variables was invalid do not cache: [SCRIPTNAME:#SCRIPTNAME#] [PRIMARYKEY:#PRIMARYKEY#] [SECONDARYKEY:#SECONDARYKEY#] [ERROR MESSAGE:#cfcatch.Message#]">
	<cflog text="#cacheError#" type="Error"  file="cachelog" date="yes" time="yes" application="no">
	<cfset attributes.noCACHE=true>
</cfcatch>
</cftry>
		
	
<cfif not attributes.noCACHE><!--- to cache the content or not? --->
		
		<!--- flush based on script name --->
		<cfset acceleratorPassword = "true">
		<!--- if cache flush requested, check "password" --->
		<cfif isDefined("url.flushAccelerator") and (not compare(url.flushAccelerator,acceleratorPassword))>
				<!--- flush cache contents --->
				<cflock scope="application" timeout="5" type="exclusive">
					<cfif isDefined("application.accelerator.#scriptname#")>
						<cfset structClear(application.accelerator[scriptname])>
						<!--- in the case where you want to clear the entire cache --->
						<cfif isdefined("url.clearALL")>
							<cfset structClear(application.accelerator)>
						</cfif>
					<cfelse>
						<cfset application.accelerator[scriptname]=structNew()>
						<cfset application.accelerator[scriptName].pageName = cgi.SCRIPT_NAME>
					</cfif>
				</cflock>
		<cfelse>
		<!---  end flush cache section --->
		
		<!--- caching section and output --->
			<cfif thisTag.executionMode IS "Start">
				<cflock scope="application" timeout="5" type="READONLY">
					<cfif IsDefined("application.accelerator.#scriptName#.#primarykey#.#secondaryKey#")
						AND ((now() + 0) lt application.accelerator[scriptName][primaryKey][secondaryKey].cacheExpires)
						>
						<cfif isdefined("url.displayTS")><cfoutput><!--#application.accelerator[scriptName][primaryKey][secondaryKey].timestamp#--></cfoutput></cfif>
						<cfoutput>#application.accelerator[scriptName][primaryKey][secondaryKey].content#</cfoutput>
						<!--- cfexit to skip to endtag without processing "wrapped" cfml --->
						<!--- (end-tag angle bracket moved to prevent output of whitespace) --->
						<cfsetting enableCFOutputOnly="No"
						><cfexit method="EXITTAG">
					</cfif>
				</cflock>
			<cfelse>  <!--- else executionMode is End --->
				<!--- if we got this far, the data wasn't in the cache --->
				<cfif attributes.stripWhitespace>
					<!--- this can take a few hundred mS for a large content block so it's done outside the lock --->
					<cfset thisTag.generatedContent = rereplace(thisTag.generatedContent, "[#chr(10)##chr(13)##chr(9)#]{2,}",chr(13),"ALL")>
				</cfif>
		
					<cflock scope="application" type="exclusive" timeout="10">
						<cfif not isDefined("application.accelerator.#scriptName#.#primarykey#")>
							<cfif not isDefined("application.accelerator.#scriptName#")>
								<cfif not isDefined("application.accelerator")>
										<cfset application.accelerator = StructNew()>
								</cfif>
								<cfset application.accelerator[scriptName] = StructNew()>
								<cfset application.accelerator[scriptName].pageName = cgi.SCRIPT_NAME>
								
							</cfif>
							<cfset application.accelerator[scriptName][primarykey] = StructNew()>
						</cfif>
						
						<cfset application.accelerator[scriptName][primarykey][secondaryKey]=structNew()>
						<!--- set content and expiration vars --->
						<cfset rightnow=now()>
						<cfset application.accelerator[scriptName][primarykey][secondaryKey].cacheExpires = rightnow + cachedWithin>
						<cfset application.accelerator[scriptName][primarykey][secondaryKey].content = ThisTag.GeneratedContent>
						<cfset application.accelerator[scriptName][primarykey][secondaryKey].timestamp = rightnow>
						<cfset application.accelerator[scriptName][primarykey][secondaryKey].contentURL = "#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#">
					</cflock>
					
			</cfif>
			
		</cfif>  <!--- endif from "if not url.flushAccelerator" --->
		
<cfelse>
	<!--- do not Cache data  --->
	<cfif isdefined("cacheError")>
		<cfoutput><!-- #cacheError#  --></cfoutput>
	</cfif>
</cfif>
<cfsetting enableCFOutputOnly="No">
