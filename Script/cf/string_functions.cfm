	<!--- so we don't include this file twice --->
	<cfset AlreadyBeenHere = 1 />
<CFSCRIPT>
	function StripHTML(str) 
	{
		return REReplaceNoCase(str,"<[^>]*>", "", "ALL");
	}
	function showRestrictedLength(sStr, iLen)
	{
		WriteOutput(Left(sStr, iLen));
		if(Len(sStr) GT iLen)
		{
			WriteOutput("...");
		}
	}
</CFSCRIPT>


<!---BJF NOTE: You should not numberformat the value before passing it to this function, or it will not correctly format negative values with a comma --->

<cffunction name="NegativeFormat" access="public" returntype="string" output="false">

		<cfargument name="amount" type="string" required="true"  />
		<cfargument name="isCurrency" type="boolean" required="false" default="0" />
		<cfargument name="textColor" type="string" required="false" default="red" />
		<cfargument name="leftBracket" type="string" required="false" default="(" />
		<cfargument name="rightBracket" type="string" required="false" default=")" />
		<cfargument name="margindecimals" type="boolean" required="false" default="0" />
		<cfargument name="unittype" type="boolean" required="false" default="0" />
		<cfargument name="noDecimals" type="boolean" required="false" default="0" />
		<!---White space intentionally removed --->
		<cfsavecontent variable="formattedValue"><cfoutput><span style="color: #arguments.textColor#;">#arguments.leftBracket#<cfif arguments.isCurrency EQ 1 AND isNumeric(arguments.amount) ><cfif isdefined("arguments.margindecimals") and arguments.margindecimals EQ 1><cfif arguments.unittype EQ 1>$#trim(numberformat(arguments.amount,'_-___,___,___,___,___.__'))#<cfelseif isDefined("arguments.noDecimals") and arguments.noDecimals EQ 1>$#trim(numberformat(arguments.amount,'_-___,___,___,___,___'))#<cfelse>$#trim(numberformat(arguments.amount,'_-___,___,___,___,___.___'))#</cfif>
<cfelse>#lscurrencyformat(arguments.amount)#</cfif><cfelse>#arguments.amount#</cfif>#arguments.rightBracket#</span></cfoutput></cfsavecontent>
		
		<cfreturn formattedValue />
		
</cffunction>
	
	
<cffunction name="UnitNumberFormat" access="public" returntype="string" output="false">
	<cfargument name="amount" type="string" required="true">
	<cfargument name="unittype" type="boolean" required="false" default="0">

	<cfif arguments.unittype eq 1>
		<cfreturn '$' & trim(numberformat(arguments.amount,'_-___,___,___,___,___.__'))>
	<cfelse>
		<cfreturn '$' & trim(numberformat(arguments.amount,'_-___,___,___,___,___.___'))>
	</cfif>
</cffunction>