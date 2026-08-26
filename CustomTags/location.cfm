<!--- 

	Filename			:	LOCATION.cfm 
	Last modified by	:	Christopher Bradford 
	Created				:	5/10/2000 9:05:04 AM 
	Last Updated		:	5/26/2000 9:31:11 AM 
	Comments			:

	Version 1.0 

	Provides an alternative to CFLOCATION, but allows cookies to be set.
	Essentially, it uses CFHEADER to redirect the browser.
	If ADDTOKEN is used, it requires client management, just as in CFLOCATION.
	Usage is identical to CFLOCATION:

	<CF_LOCATION 
		URL="URL" 
		[ADDTOKEN="Yes|No"]>

 --->

<CFPARAM NAME="Attributes.URL" TYPE="string">
<CFPARAM NAME="Attributes.ADDTOKEN" TYPE="boolean" DEFAULT="No">

<CFIF Attributes.ADDTOKEN>

	<CFTRY>
		<CFPARAM NAME="Client.CFID">
		<CFPARAM NAME="Client.CFTOKEN">
		<CFCATCH TYPE="Any">
			<CFABORT SHOWERROR="You must have <b>CLIENTMANAGEMENT=""Yes""</b> in your CFAPPLICATION tag (usually in Application.cfm) if you choose to specify <b>ADDTOKEN=""Yes""</b> in your CF_LOCATION tag.">
		</CFCATCH>
	</CFTRY>

	<CFIF Find("?", Attributes.URL)>
		<CFSET theRest = "&">
	<CFELSE>
		<CFSET theRest = "?">
	</CFIF>

<CFSET theRest = theRest & "CFID=#Client.CFID#&CFTOKEN=#Client.CFTOKEN#">

<CFELSE>

	<CFSET theRest = "">

</CFIF>

<CFSET theURL = Attributes.URL & theRest>
<CFHEADER STATUSCODE="302" STATUSTEXT="Object Temporarily Moved">
<CFHEADER NAME="location" VALUE="#theURL#">
