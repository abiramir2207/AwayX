
<cfcomponent hint="Message Log Attachments">

	<cfset this.attachments = ArrayNew(1) />
	
	<cffunction name="setAttachments">
		<cfargument name="attachments" type="string" required="true" />
		<cfargument name="desc" type="string" required="false" default="" />
		<cfset ArrayPrepend(this.attachments, arguments) />
	</cffunction>
	
	<cffunction name="getAttachments" returntype="array">
		<cfreturn this.attachments />
	</cffunction>
	
</cfcomponent>