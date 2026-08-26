<cfcomponent extends="components.Base" hint="Contains Encryption Functions and Tools">
	<cfset this.passwordKey = '7y36746z2o6lfh5hgxgol85di7'>
	
	<cffunction name="getPasswordKey" output="false" returntype="String" hint="Returns Encryption Key for Default Password Encrypt and Decrypt functions">		
		<cfreturn this.passwordKey>
	</cffunction>
</cfcomponent>
