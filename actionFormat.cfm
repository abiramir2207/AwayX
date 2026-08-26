<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\actionFormat.cfm
      Date:     July 2011
      Author:   Chris Nguyen
      Purpose:  Returns the styled caption for action
----------------------------------------------------------------------------------------------------------------------->

<cffunction name="ActionText" output="false">
  <cfargument name="caption" required="true">

  <cfreturn "<b><font color='red'>[ </font>" & (arguments.caption) & "<font color='red'> ]</font></b>">
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="CapFirst" returntype="string" output="false">
    <cfargument name="str" type="string" required="true" />

    <cfset var newstr = "" />
    <cfset var word = "" />
    <cfset var separator = "" />

    <cfloop index="word" list="#arguments.str#" delimiters=" ">
        <cfset newstr = newstr & separator & UCase(left(word,1)) />
        <cfif len(word) gt 1>
            <cfset newstr = newstr & right(word,len(word)-1) />
        </cfif>
        <cfset separator = " " />
    </cfloop>

    <cfreturn newstr />
</cffunction>

