<cfsilent>
<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfheader name="Cache-Control" value="no-store">
<cfheader name="expires" value="#now()#">
</cfsilent>
<cfoutput><cfif isDefined("csvdata")>#csvdata#</cfif></cfoutput>