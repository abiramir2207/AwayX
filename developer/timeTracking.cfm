<!---
* ==================================================================================================== 
*    @File: \developer\timeTracking.cfm
*  @Author: Chris Nguyen
*    @Date: 2019 April 19
* 
* @Remarks: Tracking execution time and save the elapsed time to debug.log file under CF logs folder
*
* ==================================================================================================== 
--->

<cffunction name="timeBegin" output="false" hint="Starts tracking time based on a unique string">
    <cfargument name="timeLabel" required="true">

    <!--- replace all whitespaces with underscores for a clean variable name --->
    <cfset local.time_id          = replace(arguments.timeLabel, " ", "_", "all")>
    <cfset request[local.time_id] = getTickCount()>
</cffunction>    


<cffunction name="timeEnd" output="false" hint="Ends tracking time, writes the result to a .log file">
    <cfargument name="timeLabel" required="true">
    <cfargument name="miliseconds" required="false" default="true">

    <!--- replace all whitespaces with underscores for a clean variable name --->
    <cfset local.time_id = replace(arguments.timeLabel, " ", "_", "all")>
    
    <cfif structKeyExists(request, local.time_id)>
        <cfset local.quotient = arguments.miliseconds ? 1 : 1000>
        <cfoutput>#application.util.io.debugLog( arguments.timeLabel
                                                ,"took"
                                                ,numberFormat((getTickCount() - request[local.time_id]) / local.quotient, ",")
                                                ,"ms")#</cfoutput>
    </cfif>
</cffunction>    


<cffunction name="sumTimeEnd" output="false" hint="Ends tracking time for statements inside a loop">
    <cfargument name="timeLabel" required="true">

    <!--- replace all whitespaces with underscores for a clean variable name --->
    <cfset local.time_id = replace(arguments.timeLabel, " ", "_", "all")>

    <cfif structKeyExists(request, local.time_id)>
        <!--- create a total time variable if needed --->
        <cfif !structKeyExists(request, local.time_id & "_total")>
            <cfset request[local.time_id & "_total"] = 0>
        </cfif>
        <cfset request[local.time_id & "_total"] = request[local.time_id & "_total"] 
                                                    + (getTickCount() - request[local.time_id])>
    </cfif>
</cffunction>    


<cffunction name="sumTimeWrite" output="false" hint="Write tracking time information for statements inside a loop">
    <cfargument name="timeLabel" required="true">

    <!--- replace all whitespaces with underscores for a clean variable name --->
    <cfset local.time_id = replace(arguments.timeLabel, " ", "_", "all")>

    <cfif structKeyExists(request, local.time_id & "_total")>
            <cfoutput>#application.util.io.debugLog( arguments.timeLabel
                                                    ,"took"
                                                    ,numberFormat(request[local.time_id & "_total"] / 1000, ",")
                                                    ,"secs")#</cfoutput>
    </cfif>
</cffunction>    
